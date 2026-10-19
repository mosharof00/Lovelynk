-- Migration: Push notifications and notification center RPCs

-- 1. Register push device (upserts token, reassigns user if device changed hands)
create or replace function public.register_push_device(
  p_fcm_token text,
  p_platform public.device_platform default 'ios'::public.device_platform,
  p_app_version text default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_token text := trim(p_fcm_token);
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  if v_token is null or length(v_token) = 0 then
    return;
  end if;

  insert into public.push_devices (user_id, fcm_token, platform, app_version, last_seen_at)
  values (v_uid, v_token, p_platform, p_app_version, now())
  on conflict (fcm_token) do update set
    user_id = excluded.user_id,
    platform = excluded.platform,
    app_version = coalesce(excluded.app_version, public.push_devices.app_version),
    last_seen_at = excluded.last_seen_at;
end;
$$;

-- 2. Unregister push device (on logout)
create or replace function public.unregister_push_device(
  p_fcm_token text
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  delete from public.push_devices
  where fcm_token = trim(p_fcm_token)
    and user_id = v_uid;
end;
$$;

-- 3. Unread notification count
create or replace function public.unread_notification_count()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_count integer;
begin
  if v_uid is null then
    return 0;
  end if;

  select count(*)::integer into v_count
  from public.notifications
  where user_id = v_uid
    and read_at is null;

  return coalesce(v_count, 0);
end;
$$;

-- 4. Mark notifications read
create or replace function public.mark_notifications_read(
  p_ids uuid[]
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  update public.notifications
  set read_at = now()
  where user_id = v_uid
    and id = any(p_ids)
    and read_at is null;
end;
$$;

-- 5. Mark all notifications read
create or replace function public.mark_all_notifications_read()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  update public.notifications
  set read_at = now()
  where user_id = v_uid
    and read_at is null;
end;
$$;

-- 6. Delete single notification
create or replace function public.delete_notification(
  p_id uuid
) returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_deleted boolean;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  delete from public.notifications
  where id = p_id
    and user_id = v_uid;

  get diagnostics v_deleted = row_count;
  return v_deleted > 0;
end;
$$;

-- 7. Get notification preferences
create or replace function public.get_notification_preferences()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_prefs record;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_prefs
  from public.notification_preferences
  where user_id = v_uid;

  if not found then
    insert into public.notification_preferences (user_id)
    values (v_uid)
    on conflict (user_id) do nothing;

    select * into v_prefs
    from public.notification_preferences
    where user_id = v_uid;
  end if;

  return jsonb_build_object(
    'push_heartbeat',      coalesce(v_prefs.push_heartbeat, true),
    'push_kiss',           coalesce(v_prefs.push_kiss, true),
    'push_emoji',          coalesce(v_prefs.push_emoji, true),
    'push_relationship',   coalesce(v_prefs.push_relationship, true),
    'push_subscription',   coalesce(v_prefs.push_subscription, true),
    'push_announcements',  coalesce(v_prefs.push_announcements, true),
    'quiet_hours_start',   v_prefs.quiet_hours_start,
    'quiet_hours_end',     v_prefs.quiet_hours_end,
    'updated_at',          v_prefs.updated_at
  );
end;
$$;

-- 8. Update notification preferences
create or replace function public.update_notification_preferences(
  p_push_heartbeat boolean default null,
  p_push_kiss boolean default null,
  p_push_emoji boolean default null,
  p_push_relationship boolean default null,
  p_push_subscription boolean default null,
  p_push_announcements boolean default null,
  p_quiet_hours_start time default null,
  p_quiet_hours_end time default null,
  p_clear_quiet_hours boolean default false
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_prefs record;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.notification_preferences (
    user_id,
    push_heartbeat,
    push_kiss,
    push_emoji,
    push_relationship,
    push_subscription,
    push_announcements,
    quiet_hours_start,
    quiet_hours_end
  ) values (
    v_uid,
    coalesce(p_push_heartbeat, true),
    coalesce(p_push_kiss, true),
    coalesce(p_push_emoji, true),
    coalesce(p_push_relationship, true),
    coalesce(p_push_subscription, true),
    coalesce(p_push_announcements, true),
    case when p_clear_quiet_hours then null else p_quiet_hours_start end,
    case when p_clear_quiet_hours then null else p_quiet_hours_end end
  )
  on conflict (user_id) do update set
    push_heartbeat     = coalesce(p_push_heartbeat, public.notification_preferences.push_heartbeat),
    push_kiss          = coalesce(p_push_kiss, public.notification_preferences.push_kiss),
    push_emoji         = coalesce(p_push_emoji, public.notification_preferences.push_emoji),
    push_relationship  = coalesce(p_push_relationship, public.notification_preferences.push_relationship),
    push_subscription  = coalesce(p_push_subscription, public.notification_preferences.push_subscription),
    push_announcements = coalesce(p_push_announcements, public.notification_preferences.push_announcements),
    quiet_hours_start  = case when p_clear_quiet_hours then null else coalesce(p_quiet_hours_start, public.notification_preferences.quiet_hours_start) end,
    quiet_hours_end    = case when p_clear_quiet_hours then null else coalesce(p_quiet_hours_end, public.notification_preferences.quiet_hours_end) end,
    updated_at         = now()
  returning * into v_prefs;

  return jsonb_build_object(
    'push_heartbeat',      v_prefs.push_heartbeat,
    'push_kiss',           v_prefs.push_kiss,
    'push_emoji',          v_prefs.push_emoji,
    'push_relationship',   v_prefs.push_relationship,
    'push_subscription',   v_prefs.push_subscription,
    'push_announcements',  v_prefs.push_announcements,
    'quiet_hours_start',   v_prefs.quiet_hours_start,
    'quiet_hours_end',     v_prefs.quiet_hours_end,
    'updated_at',          v_prefs.updated_at
  );
end;
$$;

-- 9. Trigger to broadcast notification.new on insert
create or replace function public.on_notification_inserted()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform pg_notify('pgrst', json_build_object(
    'channel', 'user:' || NEW.user_id::text,
    'event', 'notification.new',
    'payload', json_build_object(
      'id', NEW.id,
      'category', NEW.category,
      'title', NEW.title,
      'body', NEW.body,
      'data', NEW.data,
      'created_at', NEW.created_at
    )
  )::text);

  return NEW;
end;
$$;

drop trigger if exists trigger_notification_inserted on public.notifications;
create trigger trigger_notification_inserted
  after insert on public.notifications
  for each row
  execute function public.on_notification_inserted();
