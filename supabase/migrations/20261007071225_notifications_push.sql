-- In-app notification centre. read_at null = unseen. Kept 90 days (cron phase).
create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.users (id) on delete cascade,
  category     public.notification_category not null,
  title        text not null check (char_length(title) between 1 and 120),
  body         text not null check (char_length(body) <= 1000),
  image_path   text check (char_length(image_path) <= 255),
  data         jsonb not null default '{}',
  broadcast_id uuid references public.broadcasts (id) on delete set null,
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);

create index notifications_user_created_at_idx on public.notifications (user_id, created_at desc);
-- Keeps the unread badge count fast regardless of history size.
create index notifications_user_unread_idx on public.notifications (user_id) where read_at is null;
create index notifications_broadcast_id_idx on public.notifications (broadcast_id) where broadcast_id is not null;
create index notifications_created_at_brin_idx on public.notifications using brin (created_at);

-- FCM tokens. A token moves to whoever signed in last on that phone.
create table public.push_devices (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.users (id) on delete cascade,
  fcm_token    text not null unique check (char_length(fcm_token) <= 4096),
  platform     public.device_platform not null,
  app_version  text check (char_length(app_version) <= 32),
  last_seen_at timestamptz not null default now(),
  created_at   timestamptz not null default now()
);

create index push_devices_user_id_idx on public.push_devices (user_id);
create index push_devices_last_seen_at_idx on public.push_devices (last_seen_at);

alter table public.notifications enable row level security;
alter table public.push_devices enable row level security;

revoke all on table public.notifications, public.push_devices from anon, authenticated;

grant select, delete on table public.notifications to authenticated;
grant update (read_at) on table public.notifications to authenticated;

grant select, delete on table public.push_devices to authenticated;

-- Admins only see broadcast notifications (for read rates), never personal ones.
create policy notifications_select on public.notifications
  for select to authenticated
  using (
    user_id = (select auth.uid())
    or (broadcast_id is not null and (select private.is_admin()))
  );

create policy notifications_update_own on public.notifications
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy notifications_delete_own on public.notifications
  for delete to authenticated
  using (user_id = (select auth.uid()));

-- Registration goes through register_push_device() (functions phase).
create policy push_devices_select on public.push_devices
  for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_admin()));

create policy push_devices_delete_own on public.push_devices
  for delete to authenticated
  using (user_id = (select auth.uid()));
