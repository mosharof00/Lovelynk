-- ─── Tables ──────────────────────────────────────────────────────────

create table public.couples (
  id             uuid primary key default gen_random_uuid(),
  status         public.couple_status not null default 'active',
  together_since date check (together_since >= date '1900-01-01'),
  next_visit_at  timestamptz,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  archived_at    timestamptz,
  purge_after    timestamptz,
  constraint couples_archived_consistency
    check ((status = 'archived') = (archived_at is not null))
);

create index couples_status_created_at_idx on public.couples (status, created_at desc);
create index couples_purge_after_idx on public.couples (purge_after) where purge_after is not null;

create trigger couples_set_updated_at
  before update on public.couples
  for each row execute function private.set_updated_at();

create or replace function private.validate_couple()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.together_since > current_date then
    raise exception 'together_since cannot be in the future';
  end if;
  return new;
end;
$$;

create trigger couples_validate
  before insert or update of together_since on public.couples
  for each row execute function private.validate_couple();

create table public.couple_members (
  couple_id        uuid not null references public.couples (id) on delete cascade,
  user_id          uuid not null references public.users (id) on delete cascade,
  partner_nickname text check (char_length(partner_nickname) between 1 and 40),
  joined_at        timestamptz not null default now(),
  left_at          timestamptz,
  primary key (couple_id, user_id)
);

comment on column public.couple_members.partner_nickname is
  'The nickname this user gives their partner. Private to the couple.';

-- One active couple per user.
create unique index couple_members_one_active_idx
  on public.couple_members (user_id) where left_at is null;
create index couple_members_user_id_idx on public.couple_members (user_id);

-- Exactly two active members per couple.
create or replace function private.guard_couple_member_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform 1 from public.couples where id = new.couple_id for update;
  if (
    select count(*) from public.couple_members
    where couple_id = new.couple_id and left_at is null
  ) >= 2 then
    raise exception 'A couple can only have two members';
  end if;
  return new;
end;
$$;

create trigger couple_members_limit
  before insert on public.couple_members
  for each row execute function private.guard_couple_member_limit();

create table public.pairing_invites (
  id                       uuid primary key default gen_random_uuid(),
  code                     char(8) not null check (code ~ '^[0-9]{8}$'),
  inviter_id               uuid not null references public.users (id) on delete cascade,
  inviter_partner_nickname text check (char_length(inviter_partner_nickname) between 1 and 40),
  inviter_together_since   date,
  expires_at               timestamptz not null default (now() + interval '24 hours'),
  consumed_at              timestamptz,
  consumed_by              uuid references public.users (id) on delete set null,
  created_at               timestamptz not null default now()
);

create unique index pairing_invites_open_code_idx
  on public.pairing_invites (code) where consumed_at is null;
create unique index pairing_invites_one_open_per_inviter_idx
  on public.pairing_invites (inviter_id) where consumed_at is null;
create index pairing_invites_consumed_by_idx on public.pairing_invites (consumed_by);
create index pairing_invites_expires_at_idx on public.pairing_invites (expires_at);

-- ─── Couple helpers (used by RLS everywhere) ────────────────────────

create or replace function private.current_couple_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select cm.couple_id
  from public.couple_members cm
  join public.couples c on c.id = cm.couple_id
  where cm.user_id = auth.uid()
    and cm.left_at is null
    and c.status = 'active'
  limit 1;
$$;

create or replace function private.partner_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select cm.user_id
  from public.couple_members cm
  where cm.couple_id = private.current_couple_id()
    and cm.user_id <> auth.uid()
    and cm.left_at is null
  limit 1;
$$;

grant execute on function private.current_couple_id() to authenticated;
grant execute on function private.partner_id() to authenticated;

-- ─── Grants and RLS ──────────────────────────────────────────────────

alter table public.couples enable row level security;
alter table public.couple_members enable row level security;
alter table public.pairing_invites enable row level security;

revoke all on table public.couples, public.couple_members, public.pairing_invites from anon, authenticated;

grant select on table public.couples to authenticated;
grant update (together_since, next_visit_at) on table public.couples to authenticated;

grant select on table public.couple_members to authenticated;
grant update (partner_nickname) on table public.couple_members to authenticated;

grant select on table public.pairing_invites to authenticated;

create policy couples_select on public.couples
  for select to authenticated
  using (id = (select private.current_couple_id()) or (select private.is_admin()));

create policy couples_update_own on public.couples
  for update to authenticated
  using (id = (select private.current_couple_id()))
  with check (id = (select private.current_couple_id()));

-- Admins have no access: nicknames stay private to the couple.
create policy couple_members_select on public.couple_members
  for select to authenticated
  using (couple_id = (select private.current_couple_id()));

create policy couple_members_update_own on public.couple_members
  for update to authenticated
  using (user_id = (select auth.uid()) and couple_id = (select private.current_couple_id()))
  with check (user_id = (select auth.uid()));

create policy pairing_invites_select_own on public.pairing_invites
  for select to authenticated
  using (inviter_id = (select auth.uid()));

-- Partners can now see each other's user row.
drop policy users_select on public.users;
create policy users_select on public.users
  for select to authenticated
  using (
    id = (select auth.uid())
    or id = (select private.partner_id())
    or (select private.is_admin())
  );
