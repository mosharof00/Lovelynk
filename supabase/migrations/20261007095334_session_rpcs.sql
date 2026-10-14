-- Session RPCs used right after sign-in / on app open.
-- Pattern: logic in private (SECURITY DEFINER), thin SECURITY INVOKER wrapper in public.

-- ─── get_my_access ───────────────────────────────────────────────────
-- Premium if I or my active partner have a live entitlement. The partner's
-- subscription details stay hidden; only the derived access is returned.
create or replace function private.get_my_access()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with granting as (
    select
      e.*,
      case when e.user_id = auth.uid() then 'self' else 'partner' end as source
    from public.subscription_entitlements e
    where (e.user_id = auth.uid() or e.user_id = private.partner_id())
      and e.status in ('active', 'in_grace_period', 'billing_issue')
      and (e.expires_at is null or e.expires_at > now())
    order by
      (e.user_id = auth.uid()) desc,
      (e.period_type <> 'trial') desc,
      e.expires_at desc nulls first
    limit 1
  )
  select coalesce(
    (select jsonb_build_object(
       'is_premium', true,
       'source',     g.source,
       'is_trial',   g.period_type = 'trial',
       'plan',       g.plan,
       'status',     g.status,
       'expires_at', g.expires_at,
       'will_renew', case when g.source = 'self' then g.will_renew end
     ) from granting g),
    jsonb_build_object(
      'is_premium', false,
      'source',     'none',
      'is_trial',   false,
      'plan',       null,
      'status',     null,
      'expires_at', null,
      'will_renew', null
    )
  );
$$;

-- ─── get_session_bootstrap ───────────────────────────────────────────
-- One call after sign-in / on app open: my profile, my couple + partner, access.
create or replace function private.get_session_bootstrap()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := auth.uid();
  v_user      public.users%rowtype;
  v_couple_id uuid;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_user from public.users where id = v_uid;
  if not found then
    raise exception 'This account cannot be used in the app' using errcode = '42501';
  end if;

  v_couple_id := private.current_couple_id();

  return jsonb_build_object(
    'user', jsonb_build_object(
      'id',                 v_user.id,
      'email',              v_user.email,
      'full_name',          v_user.full_name,
      'avatar_path',        v_user.avatar_path,
      'timezone',           v_user.timezone,
      'utc_offset_minutes', v_user.utc_offset_minutes,
      'created_at',         v_user.created_at
    ),
    'couple', (
      select jsonb_build_object(
        'id',             c.id,
        'together_since', c.together_since,
        'next_visit_at',  c.next_visit_at,
        'created_at',     c.created_at,
        'partner', jsonb_build_object(
          'id',                 p.id,
          'full_name',          p.full_name,
          'nickname',           me.partner_nickname,
          'avatar_path',        p.avatar_path,
          'timezone',           p.timezone,
          'utc_offset_minutes', p.utc_offset_minutes
        )
      )
      from public.couples c
      join public.couple_members me
        on me.couple_id = c.id and me.user_id = v_uid and me.left_at is null
      join public.couple_members pm
        on pm.couple_id = c.id and pm.user_id <> v_uid and pm.left_at is null
      join public.users p on p.id = pm.user_id
      where c.id = v_couple_id
    ),
    'access', private.get_my_access()
  );
end;
$$;

-- ─── touch_session ───────────────────────────────────────────────────
-- Called on app open/resume. Writes only when something changed or once an
-- hour for last_seen_at, so frequent calls stay cheap.
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
begin
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
end;
$$;

-- ─── Public wrappers (what the app calls via supabase.rpc) ──────────

create or replace function public.get_my_access()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$ select private.get_my_access(); $$;

create or replace function public.get_session_bootstrap()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$ select private.get_session_bootstrap(); $$;

create or replace function public.touch_session(
  p_app_version        text default null,
  p_timezone           text default null,
  p_utc_offset_minutes int  default null
)
returns void
language sql
security invoker
set search_path = ''
as $$ select private.touch_session(p_app_version, p_timezone, p_utc_offset_minutes); $$;

-- ─── Grants: signed-in users only ───────────────────────────────────

revoke all on function private.get_my_access() from public, anon;
revoke all on function private.get_session_bootstrap() from public, anon;
revoke all on function private.touch_session(text, text, int) from public, anon;
revoke all on function public.get_my_access() from public, anon;
revoke all on function public.get_session_bootstrap() from public, anon;
revoke all on function public.touch_session(text, text, int) from public, anon;

grant execute on function private.get_my_access() to authenticated;
grant execute on function private.get_session_bootstrap() to authenticated;
grant execute on function private.touch_session(text, text, int) to authenticated;
grant execute on function public.get_my_access() to authenticated;
grant execute on function public.get_session_bootstrap() to authenticated;
grant execute on function public.touch_session(text, text, int) to authenticated;
