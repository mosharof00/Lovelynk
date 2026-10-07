-- ─── Tables ──────────────────────────────────────────────────────────

create table public.users (
  id                 uuid primary key references auth.users (id) on delete cascade,
  email              text not null default '',
  full_name          text not null default '' check (char_length(full_name) <= 60),
  avatar_path        text check (char_length(avatar_path) <= 255),
  auth_provider      text not null default 'email',
  timezone           text check (char_length(timezone) <= 64),
  utc_offset_minutes smallint check (utc_offset_minutes between -720 and 840),
  app_version        text check (char_length(app_version) <= 32),
  last_seen_at       timestamptz,
  last_sign_in_at    timestamptz,
  banned_at          timestamptz,
  ban_reason         text check (char_length(ban_reason) <= 500),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

comment on table public.users is 'Mobile app users (role = user). Row is created only after the email is verified.';

create index users_email_idx on public.users (lower(email));
create index users_created_at_idx on public.users (created_at desc);
create index users_last_seen_at_idx on public.users (last_seen_at desc);
create index users_search_trgm_idx on public.users
  using gin ((full_name || ' ' || email) extensions.gin_trgm_ops);

create trigger users_set_updated_at
  before update on public.users
  for each row execute function private.set_updated_at();

create table public.admins (
  id              uuid primary key references auth.users (id) on delete cascade,
  email           text not null default '',
  full_name       text not null default '' check (char_length(full_name) <= 60),
  avatar_path     text check (char_length(avatar_path) <= 255),
  is_active       boolean not null default true,
  created_by      uuid references public.admins (id) on delete set null,
  last_sign_in_at timestamptz,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

comment on table public.admins is 'Admin panel users (role = admin).';

create index admins_created_by_idx on public.admins (created_by);

create trigger admins_set_updated_at
  before update on public.admins
  for each row execute function private.set_updated_at();

create table public.notification_preferences (
  user_id            uuid primary key references public.users (id) on delete cascade,
  push_heartbeat     boolean not null default true,
  push_kiss          boolean not null default true,
  push_emoji         boolean not null default true,
  push_relationship  boolean not null default true,
  push_subscription  boolean not null default true,
  push_announcements boolean not null default true,
  quiet_hours_start  time,
  quiet_hours_end    time,
  updated_at         timestamptz not null default now(),
  constraint quiet_hours_pair check ((quiet_hours_start is null) = (quiet_hours_end is null))
);

create trigger notification_preferences_set_updated_at
  before update on public.notification_preferences
  for each row execute function private.set_updated_at();

-- ─── Role helper ─────────────────────────────────────────────────────

-- True only for an active admin whose JWT also carries role = admin.
create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '') = 'admin'
     and exists (
       select 1 from public.admins a
       where a.id = auth.uid() and a.is_active
     );
$$;

grant execute on function private.is_admin() to authenticated;

-- ─── Auth triggers ───────────────────────────────────────────────────

-- Clients can't set app_metadata, so any sign-up from the app becomes role = user.
create or replace function private.handle_auth_user_default_role()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if coalesce(new.raw_app_meta_data ->> 'role', '') not in ('user', 'admin') then
    new.raw_app_meta_data :=
      coalesce(new.raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', 'user');
  end if;
  return new;
end;
$$;

create trigger on_auth_user_default_role
  before insert on auth.users
  for each row execute function private.handle_auth_user_default_role();

-- Creates / syncs the app row once the email is verified (OTP) or the provider
-- already verified it (Apple). Unverified sign-ups never reach public tables.
create or replace function private.handle_auth_user_sync()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_name text := coalesce(
    nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
    nullif(trim(new.raw_user_meta_data ->> 'name'), ''),
    ''
  );
begin
  if new.email_confirmed_at is null then
    return new;
  end if;

  if new.raw_app_meta_data ->> 'role' = 'admin' then
    insert into public.admins (id, email, full_name, last_sign_in_at)
    values (new.id, coalesce(new.email, ''), left(v_name, 60), new.last_sign_in_at)
    on conflict (id) do update
      set email = excluded.email,
          last_sign_in_at = excluded.last_sign_in_at;
  else
    insert into public.users (id, email, full_name, auth_provider, last_sign_in_at)
    values (
      new.id,
      coalesce(new.email, ''),
      left(v_name, 60),
      coalesce(new.raw_app_meta_data ->> 'provider', 'email'),
      new.last_sign_in_at
    )
    on conflict (id) do update
      set email = excluded.email,
          last_sign_in_at = excluded.last_sign_in_at;

    insert into public.notification_preferences (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
  end if;

  return new;
end;
$$;

create trigger on_auth_user_sync
  after insert or update of email_confirmed_at, email, last_sign_in_at on auth.users
  for each row execute function private.handle_auth_user_sync();

-- ─── Admin management ────────────────────────────────────────────────

-- Owner-only (not callable through the API). Used to seed admin@lovelynk.com.
create or replace function private.promote_to_admin(p_email text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user auth.users%rowtype;
begin
  select * into v_user from auth.users where lower(email) = lower(p_email);
  if not found then
    raise exception 'No auth user with email %', p_email;
  end if;
  if v_user.email_confirmed_at is null then
    raise exception 'User % has not confirmed their email', p_email;
  end if;

  update auth.users
     set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
   where id = v_user.id;

  delete from public.users where id = v_user.id;

  insert into public.admins (id, email, full_name, last_sign_in_at)
  values (
    v_user.id,
    v_user.email,
    coalesce(nullif(trim(v_user.raw_user_meta_data ->> 'full_name'), ''), 'Admin'),
    v_user.last_sign_in_at
  )
  on conflict (id) do update set is_active = true;
end;
$$;

revoke execute on function private.promote_to_admin(text) from public, anon, authenticated;

-- Never leave the system without an active admin.
create or replace function private.guard_last_admin()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (tg_op = 'DELETE' and old.is_active)
     or (tg_op = 'UPDATE' and old.is_active and not new.is_active) then
    if not exists (
      select 1 from public.admins a where a.is_active and a.id <> old.id
    ) then
      raise exception 'Cannot remove or deactivate the last active admin';
    end if;
  end if;
  return coalesce(new, old);
end;
$$;

create trigger admins_guard_last_admin
  before update of is_active or delete on public.admins
  for each row execute function private.guard_last_admin();

-- ─── Grants and RLS ──────────────────────────────────────────────────

alter table public.users enable row level security;
alter table public.admins enable row level security;
alter table public.notification_preferences enable row level security;

revoke all on table public.users, public.admins, public.notification_preferences from anon, authenticated;

grant select on table public.users to authenticated;
grant update (full_name, avatar_path, timezone, utc_offset_minutes) on table public.users to authenticated;

grant select on table public.admins to authenticated;
grant update (full_name, avatar_path) on table public.admins to authenticated;

grant select on table public.notification_preferences to authenticated;
grant update (
  push_heartbeat, push_kiss, push_emoji, push_relationship,
  push_subscription, push_announcements, quiet_hours_start, quiet_hours_end
) on table public.notification_preferences to authenticated;

-- users: own row + admins. (Partner access is added with the couples tables.)
create policy users_select on public.users
  for select to authenticated
  using (id = (select auth.uid()) or (select private.is_admin()));

create policy users_update_own on public.users
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- admins: visible to admins only; an admin edits only their own profile.
create policy admins_select on public.admins
  for select to authenticated
  using ((select private.is_admin()));

create policy admins_update_own on public.admins
  for update to authenticated
  using (id = (select auth.uid()) and (select private.is_admin()))
  with check (id = (select auth.uid()));

create policy notification_preferences_select_own on public.notification_preferences
  for select to authenticated
  using (user_id = (select auth.uid()));

create policy notification_preferences_update_own on public.notification_preferences
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
