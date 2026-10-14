-- Phase 3: editable couple data with live partner sync, timezone-aware
-- date checks, and harder-to-abuse invite acceptance.
-- Pattern: logic in private (SECURITY DEFINER), thin SECURITY INVOKER wrapper in public.

-- ─── Timezone-aware dates ───────────────────────────────────────────
-- The calendar date of p_at for a user, from their IANA zone (falls back
-- to the stored UTC offset). Null when neither is known.
create or replace function private.user_local_date(p_uid uuid, p_at timestamptz)
returns date
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_tz     text;
  v_offset smallint;
begin
  select timezone, utc_offset_minutes into v_tz, v_offset
  from public.users where id = p_uid;

  if v_tz is not null then
    begin
      return (p_at at time zone v_tz)::date;
    exception when others then
      -- Unknown zone name; fall through to the offset.
    end;
  end if;

  if v_offset is not null then
    return ((p_at at time zone 'UTC') + make_interval(mins => v_offset))::date;
  end if;

  return null;
end;
$$;

create or replace function private.user_today(p_uid uuid)
returns date
language sql
stable
security definer
set search_path = ''
as $$ select private.user_local_date(p_uid, now()); $$;

-- "Today" in the caller's zone. Unknown zone: the latest date anywhere
-- on Earth (UTC+14), so nobody is wrongly rejected.
create or replace function private.assert_not_future(p_date date)
returns void
language plpgsql
stable
set search_path = ''
as $$
begin
  if p_date is not null and p_date > coalesce(
    private.user_today(auth.uid()),
    ((now() at time zone 'UTC') + interval '14 hours')::date
  ) then
    raise exception 'Anniversary date cannot be in the future' using errcode = '22023';
  end if;
end;
$$;

-- Table-level guard stays as a loose sanity bound; RPCs do the precise check.
create or replace function private.validate_couple()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.together_since > ((now() at time zone 'UTC') + interval '14 hours')::date then
    raise exception 'together_since cannot be in the future';
  end if;
  return new;
end;
$$;

-- ─── update_couple ───────────────────────────────────────────────────
-- Null = unchanged; use the clear flags to remove a date.
-- p_next_visit_at is the visit day at local midnight (sent as timestamptz).
create or replace function private.update_couple(
  p_together_since       date        default null,
  p_next_visit_at        timestamptz default null,
  p_clear_together_since boolean     default false,
  p_clear_next_visit     boolean     default false
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := private.require_app_user();
  v_couple_id uuid := private.current_couple_id();
  v_today     date;
begin
  if v_couple_id is null then
    raise exception 'You are not connected with a partner' using errcode = 'LK005';
  end if;

  perform private.hit_rate_limit('update_couple', 30, interval '1 hour');
  perform private.assert_not_future(p_together_since);

  if p_next_visit_at is not null then
    if p_next_visit_at > now() + interval '3 years' then
      raise exception 'Next visit must be within 3 years' using errcode = '22023';
    end if;

    v_today := private.user_today(v_uid);
    if (v_today is not null
          and private.user_local_date(v_uid, p_next_visit_at) < v_today)
       or (v_today is null and p_next_visit_at < now() - interval '1 day') then
      raise exception 'Next visit cannot be in the past' using errcode = '22023';
    end if;
  end if;

  update public.couples
  set together_since = case
                         when p_clear_together_since then null
                         else coalesce(p_together_since, together_since)
                       end,
      next_visit_at  = case
                         when p_clear_next_visit then null
                         else coalesce(p_next_visit_at, next_visit_at)
                       end
  where id = v_couple_id;

  perform private.notify_partner_updated();
  return private.get_session_bootstrap();
end;
$$;

-- ─── update_partner_nickname ─────────────────────────────────────────
-- The name I see for my partner. Private to me, so no broadcast.
create or replace function private.update_partner_nickname(p_nickname text default null)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := private.require_app_user();
  v_couple_id uuid := private.current_couple_id();
begin
  if v_couple_id is null then
    raise exception 'You are not connected with a partner' using errcode = 'LK005';
  end if;

  perform private.hit_rate_limit('update_partner_nickname', 30, interval '1 hour');

  update public.couple_members
  set partner_nickname = private.clean_nickname(p_nickname)
  where couple_id = v_couple_id and user_id = v_uid and left_at is null;

  return private.get_session_bootstrap();
end;
$$;

-- ─── Partner sees my timezone change ────────────────────────────────
create or replace function private.touch_session(
  p_app_version        text default null,
  p_timezone           text default null,
  p_utc_offset_minutes int  default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_app_version text := left(nullif(trim(p_app_version), ''), 32);
  v_timezone    text := left(nullif(trim(p_timezone), ''), 64);
  v_offset      smallint := case
                              when p_utc_offset_minutes between -720 and 840
                              then p_utc_offset_minutes
                            end;
  v_old_tz      text;
  v_old_offset  smallint;
begin
  select timezone, utc_offset_minutes into v_old_tz, v_old_offset
  from public.users where id = auth.uid();

  update public.users u
     set last_seen_at = case
                          when u.last_seen_at is null or u.last_seen_at < now() - interval '1 hour'
                          then now()
                          else u.last_seen_at
                        end,
         app_version        = coalesce(v_app_version, u.app_version),
         timezone           = coalesce(v_timezone, u.timezone),
         utc_offset_minutes = coalesce(v_offset, u.utc_offset_minutes)
   where u.id = auth.uid()
     and (
       u.last_seen_at is null
       or u.last_seen_at < now() - interval '1 hour'
       or (v_app_version is not null and v_app_version is distinct from u.app_version)
       or (v_timezone is not null and v_timezone is distinct from u.timezone)
       or (v_offset is not null and v_offset is distinct from u.utc_offset_minutes)
     );

  if (v_timezone is not null and v_timezone is distinct from v_old_tz)
     or (v_offset is not null and v_offset is distinct from v_old_offset) then
    perform private.notify_partner_updated();
  end if;
end;
$$;

-- ─── Global invite-guess breaker ────────────────────────────────────
-- Counts wrong codes across all users so many accounts can't share the
-- per-user limit to scan the code space.
create table private.global_rate_limits (
  action       text        not null,
  window_start timestamptz not null,
  hits         int         not null default 0,
  primary key (action, window_start)
);
alter table private.global_rate_limits enable row level security;
revoke all on table private.global_rate_limits from public, anon, authenticated;

-- ─── accept_invite (hardened) ───────────────────────────────────────
-- Adds: 20 wrong codes per user per day, a global wrong-code breaker
-- (300 per 10 minutes), and maps the pairing race (23505) to LK004.
create or replace function private.accept_invite(
  p_code             text,
  p_partner_nickname text default null,
  p_together_since   date default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := private.require_app_user();
  v_nickname   text := private.clean_nickname(p_partner_nickname);
  v_code       text := btrim(coalesce(p_code, ''));
  v_invite     public.pairing_invites%rowtype;
  v_since      date;
  v_couple_id  uuid;
  v_day        timestamptz := date_bin(interval '1 day', now(), timestamptz '2000-01-01');
  v_10min      timestamptz := date_bin(interval '10 minutes', now(), timestamptz '2000-01-01');
begin
  perform private.hit_rate_limit('accept_invite', 10, interval '1 hour');
  perform private.assert_not_future(p_together_since);

  if v_code !~ '^[0-9]{8}$' then
    raise exception 'Enter the 8-digit code from your partner' using errcode = '22023';
  end if;

  if private.current_couple_id() is not null then
    raise exception 'You are already connected with a partner' using errcode = 'LK001';
  end if;

  if coalesce((select hits from private.rate_limits
               where user_id = v_uid and action = 'accept_invite_fail'
                 and window_start = v_day), 0) >= 20
     or coalesce((select hits from private.global_rate_limits
                  where action = 'accept_invite_fail'
                    and window_start = v_10min), 0) >= 300 then
    raise exception 'Too many attempts. Please try again later.' using errcode = 'P0429';
  end if;

  select * into v_invite
  from public.pairing_invites
  where code = v_code and consumed_at is null
  for update;

  -- Code failures return instead of raising so the counters are committed.
  if not found or v_invite.expires_at <= now() then
    insert into private.rate_limits as r (user_id, action, window_start, hits)
    values (v_uid, 'accept_invite_fail', v_day, 1)
    on conflict (user_id, action, window_start) do update set hits = r.hits + 1;

    insert into private.global_rate_limits as g (action, window_start, hits)
    values ('accept_invite_fail', v_10min, 1)
    on conflict (action, window_start) do update set hits = g.hits + 1;

    return jsonb_build_object('error', jsonb_build_object(
      'code', 'LK002', 'message', 'This code is invalid or has expired'));
  end if;

  if v_invite.inviter_id = v_uid then
    return jsonb_build_object('error', jsonb_build_object(
      'code', 'LK003',
      'message', 'This is your own code. Share it with your partner instead.'));
  end if;

  if exists (
    select 1
    from public.couple_members cm
    join public.couples c on c.id = cm.couple_id
    where cm.user_id = v_invite.inviter_id
      and cm.left_at is null
      and c.status = 'active'
  ) then
    delete from public.pairing_invites where id = v_invite.id;
    return jsonb_build_object('error', jsonb_build_object(
      'code', 'LK004',
      'message', 'Your partner is already connected with someone else'));
  end if;

  v_since := coalesce(v_invite.inviter_together_since, p_together_since);

  begin
    -- Restore our archived couple if still within the 30-day window.
    select c.id into v_couple_id
    from public.couples c
    where c.status = 'archived'
      and c.purge_after > now()
      and exists (select 1 from public.couple_members m
                  where m.couple_id = c.id and m.user_id = v_uid)
      and exists (select 1 from public.couple_members m
                  where m.couple_id = c.id and m.user_id = v_invite.inviter_id)
    order by c.archived_at desc
    limit 1
    for update;

    if v_couple_id is not null then
      update public.couples
      set status = 'active',
          archived_at = null,
          purge_after = null,
          together_since = coalesce(v_since, together_since)
      where id = v_couple_id;

      update public.couple_members
      set left_at = null,
          partner_nickname = case
            when user_id = v_uid then coalesce(v_nickname, partner_nickname)
            else coalesce(v_invite.inviter_partner_nickname, partner_nickname)
          end
      where couple_id = v_couple_id;
    else
      insert into public.couples (together_since)
      values (v_since)
      returning id into v_couple_id;

      insert into public.couple_members (couple_id, user_id, partner_nickname)
      values (v_couple_id, v_invite.inviter_id, v_invite.inviter_partner_nickname);

      insert into public.couple_members (couple_id, user_id, partner_nickname)
      values (v_couple_id, v_uid, v_nickname);
    end if;
  exception when unique_violation then
    -- One of us got paired by another request a moment ago.
    return jsonb_build_object('error', jsonb_build_object(
      'code', 'LK004',
      'message', 'One of you was just connected with someone else. Please refresh and try again.'));
  end;

  update public.pairing_invites
  set consumed_at = now(), consumed_by = v_uid
  where id = v_invite.id;

  delete from public.pairing_invites
  where inviter_id = v_uid and consumed_at is null;

  perform realtime.send(
    jsonb_build_object('couple_id', v_couple_id),
    'couple.paired',
    'user:' || v_invite.inviter_id::text,
    true
  );

  return private.get_session_bootstrap();
end;
$$;

-- ─── Every couple change goes through the RPCs ──────────────────────
revoke update on table public.couples from authenticated;
revoke update on table public.couple_members from authenticated;
drop policy if exists couples_update_own on public.couples;
drop policy if exists couple_members_update_own on public.couple_members;

-- ─── Public wrappers ─────────────────────────────────────────────────
create or replace function public.update_couple(
  p_together_since       date        default null,
  p_next_visit_at        timestamptz default null,
  p_clear_together_since boolean     default false,
  p_clear_next_visit     boolean     default false
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.update_couple(
    p_together_since, p_next_visit_at, p_clear_together_since, p_clear_next_visit);
$$;

create or replace function public.update_partner_nickname(p_nickname text default null)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.update_partner_nickname(p_nickname); $$;

-- ─── Grants ──────────────────────────────────────────────────────────
revoke all on function
  private.user_local_date(uuid, timestamptz),
  private.user_today(uuid),
  private.update_couple(date, timestamptz, boolean, boolean),
  private.update_partner_nickname(text),
  public.update_couple(date, timestamptz, boolean, boolean),
  public.update_partner_nickname(text)
from public, anon;

grant execute on function
  private.user_local_date(uuid, timestamptz),
  private.user_today(uuid),
  private.update_couple(date, timestamptz, boolean, boolean),
  private.update_partner_nickname(text),
  public.update_couple(date, timestamptz, boolean, boolean),
  public.update_partner_nickname(text)
to authenticated;
