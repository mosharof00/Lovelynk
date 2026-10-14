-- Pairing RPCs: invite codes, accept (create or restore couple), leave.
-- Pattern: logic in private (SECURITY DEFINER), thin SECURITY INVOKER wrapper in public.
--
-- Raised errors (PostgREST returns them as `code`):
--   P0429  too many attempts
--   LK001  caller is already paired
--   LK005  caller is not paired
--   22023  invalid input
-- accept_invite returns {"error": {code, message}} instead of raising for:
--   LK002  invite code invalid or expired
--   LK003  caller entered their own code
--   LK004  inviter is already paired with someone else

-- ─── Rate limit helper ───────────────────────────────────────────────
create or replace function private.hit_rate_limit(
  p_action text,
  p_max    int,
  p_window interval
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_start timestamptz := date_bin(p_window, now(), timestamptz '2000-01-01');
  v_hits  int;
begin
  insert into private.rate_limits as r (user_id, action, window_start, hits)
  values (auth.uid(), p_action, v_start, 1)
  on conflict (user_id, action, window_start)
    do update set hits = r.hits + 1
  returning hits into v_hits;

  if v_hits > p_max then
    raise exception 'Too many attempts. Please try again later.'
      using errcode = 'P0429';
  end if;
end;
$$;

-- ─── Input helpers ───────────────────────────────────────────────────
create or replace function private.clean_nickname(p_value text)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v text := nullif(btrim(p_value), '');
begin
  if v is not null and char_length(v) > 40 then
    raise exception 'Name must be 40 characters or less' using errcode = '22023';
  end if;
  return v;
end;
$$;

create or replace function private.assert_not_future(p_date date)
returns void
language plpgsql
stable
set search_path = ''
as $$
begin
  if p_date is not null and p_date > current_date then
    raise exception 'Anniversary date cannot be in the future' using errcode = '22023';
  end if;
end;
$$;

create or replace function private.require_app_user()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;
  if not exists (select 1 from public.users where id = v_uid) then
    raise exception 'This account cannot be used in the app' using errcode = '42501';
  end if;
  return v_uid;
end;
$$;

-- ─── get_my_invite ───────────────────────────────────────────────────
-- My open, unexpired invite or null.
create or replace function private.get_my_invite()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object('code', i.code, 'expires_at', i.expires_at)
  from public.pairing_invites i
  where i.inviter_id = auth.uid()
    and i.consumed_at is null
    and i.expires_at > now();
$$;

-- ─── create_invite ───────────────────────────────────────────────────
-- Returns my open invite (refreshing its details) or a new 24h code.
create or replace function private.create_invite(
  p_partner_nickname text default null,
  p_together_since   date default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid      uuid := private.require_app_user();
  v_nickname text := private.clean_nickname(p_partner_nickname);
  v_invite   public.pairing_invites%rowtype;
  v_code     text;
  v_attempt  int := 0;
begin
  perform private.assert_not_future(p_together_since);

  if private.current_couple_id() is not null then
    raise exception 'You are already connected with a partner' using errcode = 'LK001';
  end if;

  select * into v_invite
  from public.pairing_invites
  where inviter_id = v_uid and consumed_at is null
  for update;

  if found and v_invite.expires_at > now() then
    update public.pairing_invites
    set inviter_partner_nickname = coalesce(v_nickname, inviter_partner_nickname),
        inviter_together_since   = coalesce(p_together_since, inviter_together_since)
    where id = v_invite.id;
    return jsonb_build_object('code', v_invite.code, 'expires_at', v_invite.expires_at);
  end if;

  if found then
    delete from public.pairing_invites where id = v_invite.id;
  end if;

  perform private.hit_rate_limit('create_invite', 10, interval '1 hour');

  loop
    v_attempt := v_attempt + 1;
    v_code := lpad(
      ((('x' || encode(extensions.gen_random_bytes(4), 'hex'))::bit(32)::bigint)
        % 100000000)::text,
      8, '0'
    );
    begin
      insert into public.pairing_invites (
        code, inviter_id, inviter_partner_nickname, inviter_together_since
      )
      values (v_code, v_uid, v_nickname, p_together_since)
      returning * into v_invite;
      exit;
    exception when unique_violation then
      if v_attempt >= 5 then
        raise;
      end if;
    end;
  end loop;

  return jsonb_build_object('code', v_invite.code, 'expires_at', v_invite.expires_at);
end;
$$;

-- ─── cancel_invite ───────────────────────────────────────────────────
create or replace function private.cancel_invite()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.pairing_invites
  where inviter_id = auth.uid() and consumed_at is null;
$$;

-- ─── accept_invite ───────────────────────────────────────────────────
-- Pairs me with the inviter. Restores our archived couple if we were
-- together within the last 30 days, otherwise creates a new one.
-- Anniversary: the inviter's date wins; mine is used if they skipped it.
-- Returns my session bootstrap, or {"error": {...}} for code failures.
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
  v_uid       uuid := private.require_app_user();
  v_nickname  text := private.clean_nickname(p_partner_nickname);
  v_code      text := btrim(coalesce(p_code, ''));
  v_invite    public.pairing_invites%rowtype;
  v_since     date;
  v_couple_id uuid;
begin
  perform private.hit_rate_limit('accept_invite', 10, interval '1 hour');
  perform private.assert_not_future(p_together_since);

  if v_code !~ '^[0-9]{8}$' then
    raise exception 'Enter the 8-digit code from your partner' using errcode = '22023';
  end if;

  if private.current_couple_id() is not null then
    raise exception 'You are already connected with a partner' using errcode = 'LK001';
  end if;

  select * into v_invite
  from public.pairing_invites
  where code = v_code and consumed_at is null
  for update;

  -- Code failures return instead of raising so the rate-limit hit above
  -- is committed (a raise would roll it back and allow brute forcing).
  if not found or v_invite.expires_at <= now() then
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

  update public.pairing_invites
  set consumed_at = now(), consumed_by = v_uid
  where id = v_invite.id;

  -- My own open invite is no longer needed.
  delete from public.pairing_invites
  where inviter_id = v_uid and consumed_at is null;

  -- Inviter may be waiting on the Connect screen.
  perform realtime.send(
    jsonb_build_object('couple_id', v_couple_id),
    'couple.paired',
    'user:' || v_invite.inviter_id::text,
    true
  );

  return private.get_session_bootstrap();
end;
$$;

-- ─── leave_couple ────────────────────────────────────────────────────
-- Archives the couple for 30 days (restorable by re-pairing) and
-- notifies the partner. Returns my session bootstrap.
create or replace function private.leave_couple()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid        uuid := private.require_app_user();
  v_couple_id  uuid := private.current_couple_id();
  v_partner_id uuid := private.partner_id();
begin
  if v_couple_id is null then
    raise exception 'You are not connected with a partner' using errcode = 'LK005';
  end if;

  update public.couples
  set status = 'archived',
      archived_at = now(),
      purge_after = now() + interval '30 days'
  where id = v_couple_id;

  update public.couple_members
  set left_at = now()
  where couple_id = v_couple_id and left_at is null;

  if v_partner_id is not null then
    perform realtime.send(
      jsonb_build_object('couple_id', v_couple_id),
      'couple.left',
      'user:' || v_partner_id::text,
      true
    );
  end if;

  return private.get_session_bootstrap();
end;
$$;

-- ─── Public wrappers ─────────────────────────────────────────────────
create or replace function public.get_my_invite()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$ select private.get_my_invite(); $$;

create or replace function public.create_invite(
  p_partner_nickname text default null,
  p_together_since   date default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.create_invite(p_partner_nickname, p_together_since); $$;

create or replace function public.cancel_invite()
returns void
language sql
security invoker
set search_path = ''
as $$ select private.cancel_invite(); $$;

create or replace function public.accept_invite(
  p_code             text,
  p_partner_nickname text default null,
  p_together_since   date default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.accept_invite(p_code, p_partner_nickname, p_together_since); $$;

create or replace function public.leave_couple()
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.leave_couple(); $$;

-- ─── Grants ──────────────────────────────────────────────────────────
revoke all on function
  private.hit_rate_limit(text, int, interval),
  private.clean_nickname(text),
  private.assert_not_future(date),
  private.require_app_user(),
  private.get_my_invite(),
  private.create_invite(text, date),
  private.cancel_invite(),
  private.accept_invite(text, text, date),
  private.leave_couple()
from public, anon;

revoke all on function
  public.get_my_invite(),
  public.create_invite(text, date),
  public.cancel_invite(),
  public.accept_invite(text, text, date),
  public.leave_couple()
from public, anon;

grant execute on function
  private.hit_rate_limit(text, int, interval),
  private.clean_nickname(text),
  private.assert_not_future(date),
  private.require_app_user(),
  private.get_my_invite(),
  private.create_invite(text, date),
  private.cancel_invite(),
  private.accept_invite(text, text, date),
  private.leave_couple()
to authenticated;

grant execute on function
  public.get_my_invite(),
  public.create_invite(text, date),
  public.cancel_invite(),
  public.accept_invite(text, text, date),
  public.leave_couple()
to authenticated;
