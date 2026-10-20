-- Migration: Interaction RPCs (Heartbeat, Kiss, Emoji)
-- Supports live interactions between paired couples, running totals, today activity feeds, and realtime push sync.

-- 1. send_interaction
create or replace function private.send_interaction(
  p_kind  public.interaction_kind,
  p_count smallint default 1,
  p_emoji text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid            uuid := auth.uid();
  v_couple_id      uuid;
  v_partner_id     uuid;
  v_sender_name    text;
  v_clean_emoji    text;
  v_title          text;
  v_body           text;
  v_interaction_id bigint;
  v_payload        jsonb;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  v_couple_id := private.current_couple_id();
  if v_couple_id is null then
    raise exception 'Active couple required';
  end if;

  select cm.user_id into v_partner_id
  from public.couple_members cm
  where cm.couple_id = v_couple_id
    and cm.user_id <> v_uid
    and cm.left_at is null;

  if v_partner_id is null then
    raise exception 'Partner not found';
  end if;

  -- Validate count (must be between 1 and 100)
  if p_count is null or p_count < 1 or p_count > 100 then
    raise exception 'Interaction count must be between 1 and 100';
  end if;

  -- Validate emoji vs kind
  if p_kind = 'emoji' then
    v_clean_emoji := trim(p_emoji);
    if v_clean_emoji is null or length(v_clean_emoji) = 0 or length(v_clean_emoji) > 16 then
      raise exception 'Emoji is required for emoji interaction (max 16 characters)';
    end if;
  else
    if p_emoji is not null and length(trim(p_emoji)) > 0 then
      raise exception 'Emoji must be null for % interactions', p_kind;
    end if;
    v_clean_emoji := null;
  end if;

  -- Rate limit: max 120 per minute
  perform private.hit_rate_limit('send_interaction', 120, interval '1 minute');

  -- Insert into interactions
  insert into public.interactions (
    couple_id,
    sender_id,
    recipient_id,
    kind,
    count,
    emoji,
    created_at
  ) values (
    v_couple_id,
    v_uid,
    v_partner_id,
    p_kind,
    p_count,
    v_clean_emoji,
    now()
  )
  returning id into v_interaction_id;

  -- Upsert running totals in interaction_totals for (couple_id, sender_id, kind)
  insert into public.interaction_totals (
    couple_id,
    sender_id,
    kind,
    total,
    recent_emojis,
    last_sent_at
  ) values (
    v_couple_id,
    v_uid,
    p_kind,
    p_count,
    case when p_kind = 'emoji' then array[v_clean_emoji] else '{}'::text[] end,
    now()
  )
  on conflict (couple_id, sender_id, kind) do update set
    total = public.interaction_totals.total + excluded.total,
    recent_emojis = case
      when excluded.kind = 'emoji' then
        (array_prepend(v_clean_emoji, array_remove(public.interaction_totals.recent_emojis, v_clean_emoji)))[1:9]
      else public.interaction_totals.recent_emojis
    end,
    last_sent_at = excluded.last_sent_at;

  -- Determine sender name as viewed by partner:
  -- If the partner gave caller a nickname, use it. Otherwise use caller's first name.
  select coalesce(cm.partner_nickname, nullif(trim(split_part(u.full_name, ' ', 1)), ''), 'Your partner') into v_sender_name
  from public.users u
  left join public.couple_members cm
    on cm.couple_id = v_couple_id and cm.user_id = v_partner_id and cm.left_at is null
  where u.id = v_uid;

  if v_sender_name is null or length(trim(v_sender_name)) = 0 then
    v_sender_name := 'Your partner';
  end if;

  -- Notification title and body
  if p_kind = 'heartbeat' then
    v_title := 'Heartbeat ❤️';
    if p_count = 1 then
      v_body := v_sender_name || ' sent you a heartbeat ❤️';
    else
      v_body := v_sender_name || ' sent you ' || p_count || ' heartbeats ❤️';
    end if;
  elsif p_kind = 'kiss' then
    v_title := 'Kiss 💋';
    if p_count = 1 then
      v_body := v_sender_name || ' sent you a kiss 💋';
    else
      v_body := v_sender_name || ' sent you ' || p_count || ' kisses 💋';
    end if;
  else
    v_title := 'Emoji ' || v_clean_emoji;
    v_body := v_sender_name || ' sent you ' || v_clean_emoji;
  end if;

  -- Create notification row in public.notifications
  insert into public.notifications (
    user_id,
    category,
    title,
    body,
    data,
    created_at
  ) values (
    v_partner_id,
    'relationship'::public.notification_category,
    v_title,
    v_body,
    jsonb_build_object(
      'type', 'interaction',
      'kind', p_kind::text,
      'count', p_count,
      'emoji', v_clean_emoji,
      'sender_id', v_uid,
      'sender_name', v_sender_name,
      'route', '/activities'
    ),
    now()
  );

  -- Broadcast realtime interaction.new specifically to partner's user topic
  v_payload := jsonb_build_object(
    'interaction_id', v_interaction_id,
    'kind', p_kind::text,
    'count', p_count,
    'emoji', v_clean_emoji,
    'sender_id', v_uid,
    'sender_name', v_sender_name,
    'created_at', now()
  );

  begin
    perform realtime.broadcast_from(
      'user:' || v_partner_id::text,
      'interaction.new',
      v_payload
    );
  exception when others then
    raise warning 'interaction.new broadcast failed: %', SQLERRM;
  end;

  return jsonb_build_object(
    'success', true,
    'interaction_id', v_interaction_id,
    'kind', p_kind::text,
    'count', p_count,
    'emoji', v_clean_emoji,
    'created_at', now()
  );
end;
$$;


-- 2. get_interaction_summary
create or replace function private.get_interaction_summary()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid                     uuid := auth.uid();
  v_couple_id               uuid;
  v_partner_id              uuid;
  v_partner_name            text;
  v_my_name                 text;
  v_tz                      text;
  v_today_start             timestamptz;
  v_heartbeats_from_partner bigint := 0;
  v_heartbeats_from_me      bigint := 0;
  v_kisses_from_partner     bigint := 0;
  v_kisses_from_me          bigint := 0;
  v_emojis_from_partner     bigint := 0;
  v_emojis_from_me          bigint := 0;
  v_partner_recent_emojis   text[] := '{}';
  v_my_recent_emojis        text[] := '{}';
  v_today_heartbeats_p      bigint := 0;
  v_today_heartbeats_me     bigint := 0;
  v_today_kisses_p          bigint := 0;
  v_today_kisses_me         bigint := 0;
  v_today_emojis_p          bigint := 0;
  v_today_emojis_me         bigint := 0;
  v_heartbeat_activity      jsonb := '[]'::jsonb;
  v_kiss_activity           jsonb := '[]'::jsonb;
  v_emoji_activity          jsonb := '[]'::jsonb;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  v_couple_id := private.current_couple_id();
  if v_couple_id is null then
    return jsonb_build_object(
      'heartbeats_from_partner', 0,
      'heartbeats_from_me', 0,
      'kisses_from_partner', 0,
      'kisses_from_me', 0,
      'emoji_count_from_partner', 0,
      'emoji_count_from_me', 0,
      'partner_recent_emojis', '[]'::jsonb,
      'my_recent_emojis', '[]'::jsonb,
      'today_heartbeat_activity', '[]'::jsonb,
      'today_kiss_activity', '[]'::jsonb,
      'today_emoji_activity', '[]'::jsonb
    );
  end if;

  select cm.user_id into v_partner_id
  from public.couple_members cm
  where cm.couple_id = v_couple_id
    and cm.user_id <> v_uid
    and cm.left_at is null;

  -- Caller's name and partner's display name
  select full_name, timezone into v_my_name, v_tz
  from public.users
  where id = v_uid;

  if v_partner_id is not null then
    select coalesce(cm.partner_nickname, nullif(trim(split_part(u.full_name, ' ', 1)), ''), 'Partner') into v_partner_name
    from public.users u
    left join public.couple_members cm
      on cm.couple_id = v_couple_id and cm.user_id = v_uid and cm.left_at is null
    where u.id = v_partner_id;
  else
    v_partner_name := 'Partner';
  end if;

  -- 1. All-time running totals
  select
    coalesce(sum(case when kind = 'heartbeat' and sender_id = v_partner_id then total else 0 end), 0),
    coalesce(sum(case when kind = 'heartbeat' and sender_id = v_uid then total else 0 end), 0),
    coalesce(sum(case when kind = 'kiss' and sender_id = v_partner_id then total else 0 end), 0),
    coalesce(sum(case when kind = 'kiss' and sender_id = v_uid then total else 0 end), 0),
    coalesce(sum(case when kind = 'emoji' and sender_id = v_partner_id then total else 0 end), 0),
    coalesce(sum(case when kind = 'emoji' and sender_id = v_uid then total else 0 end), 0)
  into
    v_heartbeats_from_partner,
    v_heartbeats_from_me,
    v_kisses_from_partner,
    v_kisses_from_me,
    v_emojis_from_partner,
    v_emojis_from_me
  from public.interaction_totals
  where couple_id = v_couple_id;

  -- Recent emojis from partner and from me
  if v_partner_id is not null then
    select coalesce(recent_emojis, '{}'::text[]) into v_partner_recent_emojis
    from public.interaction_totals
    where couple_id = v_couple_id and sender_id = v_partner_id and kind = 'emoji';
  end if;

  select coalesce(recent_emojis, '{}'::text[]) into v_my_recent_emojis
  from public.interaction_totals
  where couple_id = v_couple_id and sender_id = v_uid and kind = 'emoji';

  -- 2. Today's start timestamp in user's timezone
  begin
    v_today_start := (now() at time zone coalesce(v_tz, 'UTC'))::date::timestamp at time zone coalesce(v_tz, 'UTC');
  exception when others then
    v_today_start := date_trunc('day', now());
  end;

  -- Today's counts
  select
    coalesce(sum(case when kind = 'heartbeat' and sender_id = v_partner_id then count else 0 end), 0),
    coalesce(sum(case when kind = 'heartbeat' and sender_id = v_uid then count else 0 end), 0),
    coalesce(sum(case when kind = 'kiss' and sender_id = v_partner_id then count else 0 end), 0),
    coalesce(sum(case when kind = 'kiss' and sender_id = v_uid then count else 0 end), 0),
    coalesce(sum(case when kind = 'emoji' and sender_id = v_partner_id then count else 0 end), 0),
    coalesce(sum(case when kind = 'emoji' and sender_id = v_uid then count else 0 end), 0)
  into
    v_today_heartbeats_p,
    v_today_heartbeats_me,
    v_today_kisses_p,
    v_today_kisses_me,
    v_today_emojis_p,
    v_today_emojis_me
  from public.interactions
  where couple_id = v_couple_id
    and created_at >= v_today_start;

  -- Today's Heartbeat activity list (limit 50, newest first)
  select coalesce(jsonb_agg(sub.item), '[]'::jsonb)
  into v_heartbeat_activity
  from (
    select jsonb_build_object(
      'id', i.id,
      'sender_name', case when i.sender_id = v_uid then 'Me' else v_partner_name end,
      'is_from_me', (i.sender_id = v_uid),
      'count', i.count,
      'emoji', i.emoji,
      'at', i.created_at
    ) as item
    from public.interactions i
    where i.couple_id = v_couple_id
      and i.kind = 'heartbeat'
      and i.created_at >= v_today_start
    order by i.created_at desc
    limit 50
  ) sub;

  -- Today's Kiss activity list (limit 50, newest first)
  select coalesce(jsonb_agg(sub.item), '[]'::jsonb)
  into v_kiss_activity
  from (
    select jsonb_build_object(
      'id', i.id,
      'sender_name', case when i.sender_id = v_uid then 'Me' else v_partner_name end,
      'is_from_me', (i.sender_id = v_uid),
      'count', i.count,
      'emoji', i.emoji,
      'at', i.created_at
    ) as item
    from public.interactions i
    where i.couple_id = v_couple_id
      and i.kind = 'kiss'
      and i.created_at >= v_today_start
    order by i.created_at desc
    limit 50
  ) sub;

  -- Today's Emoji activity list (limit 50, newest first)
  select coalesce(jsonb_agg(sub.item), '[]'::jsonb)
  into v_emoji_activity
  from (
    select jsonb_build_object(
      'id', i.id,
      'sender_name', case when i.sender_id = v_uid then 'Me' else v_partner_name end,
      'is_from_me', (i.sender_id = v_uid),
      'count', i.count,
      'emoji', i.emoji,
      'at', i.created_at
    ) as item
    from public.interactions i
    where i.couple_id = v_couple_id
      and i.kind = 'emoji'
      and i.created_at >= v_today_start
    order by i.created_at desc
    limit 50
  ) sub;

  return jsonb_build_object(
    'heartbeats_from_partner', v_heartbeats_from_partner,
    'heartbeats_from_me', v_heartbeats_from_me,
    'kisses_from_partner', v_kisses_from_partner,
    'kisses_from_me', v_kisses_from_me,
    'emoji_count_from_partner', v_emojis_from_partner,
    'emoji_count_from_me', v_emojis_from_me,
    'partner_recent_emojis', to_jsonb(coalesce(v_partner_recent_emojis, '{}'::text[])),
    'my_recent_emojis', to_jsonb(coalesce(v_my_recent_emojis, '{}'::text[])),
    'today_heartbeats_from_partner', v_today_heartbeats_p,
    'today_heartbeats_from_me', v_today_heartbeats_me,
    'today_kisses_from_partner', v_today_kisses_p,
    'today_kisses_from_me', v_today_kisses_me,
    'today_emojis_from_partner', v_today_emojis_p,
    'today_emojis_from_me', v_today_emojis_me,
    'today_heartbeat_activity', v_heartbeat_activity,
    'today_kiss_activity', v_kiss_activity,
    'today_emoji_activity', v_emoji_activity
  );
end;
$$;


-- 3. get_interaction_feed (cursor-paginated)
create or replace function private.get_interaction_feed(
  p_kind   public.interaction_kind default null,
  p_before timestamptz default null,
  p_limit  int default 30
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid          uuid := auth.uid();
  v_couple_id    uuid;
  v_partner_id   uuid;
  v_partner_name text;
  v_limit        int := coalesce(p_limit, 30);
  v_rows         jsonb;
  v_has_more     boolean := false;
  v_next_cursor  timestamptz := null;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  v_couple_id := private.current_couple_id();
  if v_couple_id is null then
    return jsonb_build_object(
      'items', '[]'::jsonb,
      'has_more', false,
      'next_cursor', null
    );
  end if;

  select cm.user_id into v_partner_id
  from public.couple_members cm
  where cm.couple_id = v_couple_id
    and cm.user_id <> v_uid
    and cm.left_at is null;

  if v_partner_id is not null then
    select coalesce(cm.partner_nickname, nullif(trim(split_part(u.full_name, ' ', 1)), ''), 'Partner') into v_partner_name
    from public.users u
    left join public.couple_members cm
      on cm.couple_id = v_couple_id and cm.user_id = v_uid and cm.left_at is null
    where u.id = v_partner_id;
  else
    v_partner_name := 'Partner';
  end if;

  if v_limit < 1 then v_limit := 30; end if;
  if v_limit > 100 then v_limit := 100; end if;

  -- Fetch limit + 1 to determine has_more
  with feed_cte as (
    select
      i.id,
      i.kind::text as kind,
      i.count,
      i.emoji,
      i.sender_id,
      i.recipient_id,
      (i.sender_id = v_uid) as is_from_me,
      case when i.sender_id = v_uid then 'Me' else v_partner_name end as sender_name,
      i.created_at
    from public.interactions i
    where i.couple_id = v_couple_id
      and (p_kind is null or i.kind = p_kind)
      and (p_before is null or i.created_at < p_before)
    order by i.created_at desc
    limit (v_limit + 1)
  )
  select
    coalesce(jsonb_agg(
      jsonb_build_object(
        'id', id,
        'kind', kind,
        'count', count,
        'emoji', emoji,
        'sender_id', sender_id,
        'recipient_id', recipient_id,
        'is_from_me', is_from_me,
        'sender_name', sender_name,
        'created_at', created_at
      ) order by created_at desc
    ), '[]'::jsonb)
  into v_rows
  from (
    select * from feed_cte limit v_limit
  ) bounded;

  -- Check if more items exist
  select exists(
    select 1
    from public.interactions i
    where i.couple_id = v_couple_id
      and (p_kind is null or i.kind = p_kind)
      and (p_before is null or i.created_at < p_before)
    order by i.created_at desc
    offset v_limit
    limit 1
  ) into v_has_more;

  if jsonb_array_length(v_rows) > 0 and v_has_more then
    v_next_cursor := (v_rows->(jsonb_array_length(v_rows) - 1)->>'created_at')::timestamptz;
  end if;

  return jsonb_build_object(
    'items', v_rows,
    'has_more', v_has_more,
    'next_cursor', v_next_cursor
  );
end;
$$;


-- 4. Public wrappers
create or replace function public.send_interaction(
  p_kind  public.interaction_kind,
  p_count smallint default 1,
  p_emoji text default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.send_interaction(p_kind, p_count, p_emoji); $$;

create or replace function public.get_interaction_summary()
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.get_interaction_summary(); $$;

create or replace function public.get_interaction_feed(
  p_kind   public.interaction_kind default null,
  p_before timestamptz default null,
  p_limit  int default 30
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.get_interaction_feed(p_kind, p_before, p_limit); $$;


-- 5. Revoke & grant
revoke all on function private.send_interaction(public.interaction_kind, smallint, text) from public, anon;
revoke all on function private.get_interaction_summary() from public, anon;
revoke all on function private.get_interaction_feed(public.interaction_kind, timestamptz, int) from public, anon;

revoke all on function public.send_interaction(public.interaction_kind, smallint, text) from public, anon;
revoke all on function public.get_interaction_summary() from public, anon;
revoke all on function public.get_interaction_feed(public.interaction_kind, timestamptz, int) from public, anon;

grant execute on function private.send_interaction(public.interaction_kind, smallint, text) to authenticated;
grant execute on function private.get_interaction_summary() to authenticated;
grant execute on function private.get_interaction_feed(public.interaction_kind, timestamptz, int) to authenticated;

grant execute on function public.send_interaction(public.interaction_kind, smallint, text) to authenticated;
grant execute on function public.get_interaction_summary() to authenticated;
grant execute on function public.get_interaction_feed(public.interaction_kind, timestamptz, int) to authenticated;
