-- ─── Broadcasts (admin announcements) ───────────────────────────────

create table public.broadcasts (
  id                 uuid primary key default gen_random_uuid(),
  title              text not null check (char_length(title) between 1 and 80),
  body               text not null check (char_length(body) between 1 and 500),
  image_path         text check (char_length(image_path) <= 255),
  deep_link          text check (char_length(deep_link) <= 255),
  audience           public.broadcast_audience not null default 'all',
  send_push          boolean not null default true,
  status             public.broadcast_status not null default 'draft',
  scheduled_at       timestamptz,
  sent_at            timestamptz,
  recipients_count   int not null default 0 check (recipients_count >= 0),
  push_success_count int not null default 0 check (push_success_count >= 0),
  push_failure_count int not null default 0 check (push_failure_count >= 0),
  created_by         uuid default auth.uid() references public.admins (id) on delete set null,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create index broadcasts_status_scheduled_at_idx on public.broadcasts (status, scheduled_at);
create index broadcasts_created_at_idx on public.broadcasts (created_at desc);
create index broadcasts_created_by_idx on public.broadcasts (created_by);

create trigger broadcasts_set_updated_at
  before update on public.broadcasts
  for each row execute function private.set_updated_at();

-- ─── Support tickets ("Contact Us") ─────────────────────────────────

create table public.support_tickets (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references public.users (id) on delete set null,
  email            text not null check (char_length(email) <= 254),
  category         public.ticket_category not null default 'general',
  subject          text not null check (char_length(subject) between 1 and 120),
  message          text not null check (char_length(message) between 1 and 4000),
  attachment_paths text[] not null default '{}' check (cardinality(attachment_paths) <= 3),
  app_version      text check (char_length(app_version) <= 32),
  device_model     text check (char_length(device_model) <= 64),
  os_version       text check (char_length(os_version) <= 32),
  status           public.ticket_status not null default 'open',
  assigned_to      uuid references public.admins (id) on delete set null,
  admin_reply      text check (char_length(admin_reply) <= 4000),
  replied_at       timestamptz,
  resolved_at      timestamptz,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index support_tickets_user_created_at_idx on public.support_tickets (user_id, created_at desc);
create index support_tickets_status_created_at_idx on public.support_tickets (status, created_at desc);
create index support_tickets_assigned_to_idx on public.support_tickets (assigned_to);

create trigger support_tickets_set_updated_at
  before update on public.support_tickets
  for each row execute function private.set_updated_at();

-- Separate table: users and admins share the database role, so a column on
-- support_tickets couldn't be hidden from the ticket owner.
create table public.support_ticket_notes (
  id         uuid primary key default gen_random_uuid(),
  ticket_id  uuid not null references public.support_tickets (id) on delete cascade,
  admin_id   uuid default auth.uid() references public.admins (id) on delete set null,
  note       text not null check (char_length(note) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index support_ticket_notes_ticket_id_idx on public.support_ticket_notes (ticket_id, created_at);
create index support_ticket_notes_admin_id_idx on public.support_ticket_notes (admin_id);

-- ─── App settings ────────────────────────────────────────────────────

create table public.app_settings (
  key         text primary key check (key ~ '^[a-z0-9_]{1,64}$'),
  value       jsonb not null,
  is_public   boolean not null default false,
  description text check (char_length(description) <= 300),
  updated_by  uuid references public.admins (id) on delete set null,
  updated_at  timestamptz not null default now()
);

create or replace function private.stamp_app_setting()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.updated_at := now();
  if private.is_admin() then
    new.updated_by := auth.uid();
  end if;
  return new;
end;
$$;

create trigger app_settings_stamp
  before insert or update on public.app_settings
  for each row execute function private.stamp_app_setting();

insert into public.app_settings (key, value, is_public, description) values
  ('min_ios_version',     '"1.0.0"', true,  'Older app versions must update before continuing'),
  ('latest_ios_version',  '"1.0.0"', true,  'Newer version available prompt (optional update)'),
  ('maintenance_mode',    'false',   true,  'When true, the app shows the maintenance message'),
  ('maintenance_message', '""',      true,  'Message shown during maintenance'),
  ('support_email',       'null',    true,  'Support contact email shown in the app'),
  ('terms_url',           'null',    true,  'Terms of Use URL'),
  ('privacy_url',         'null',    true,  'Privacy Policy URL');

-- ─── Admin audit log (append-only) ──────────────────────────────────

create table public.admin_audit_log (
  id          bigint generated always as identity primary key,
  admin_id    uuid references public.admins (id) on delete set null,
  action      text not null check (char_length(action) <= 64),
  target_type text not null check (char_length(target_type) <= 64),
  target_id   text check (char_length(target_id) <= 128),
  details     jsonb not null default '{}',
  created_at  timestamptz not null default now()
);

create index admin_audit_log_created_at_idx on public.admin_audit_log (created_at desc);
create index admin_audit_log_admin_id_idx on public.admin_audit_log (admin_id, created_at desc);
create index admin_audit_log_target_idx on public.admin_audit_log (target_type, target_id);

create or replace function private.prevent_audit_update()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'admin_audit_log is append-only';
end;
$$;

create trigger admin_audit_log_no_update
  before update on public.admin_audit_log
  for each row execute function private.prevent_audit_update();

-- Records every change an admin makes to admin-managed tables.
create or replace function private.audit_admin_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_row jsonb := to_jsonb(coalesce(new, old));
begin
  if private.is_admin() then
    insert into public.admin_audit_log (admin_id, action, target_type, target_id, details)
    values (
      auth.uid(),
      tg_table_name || '.' || lower(tg_op),
      tg_table_name,
      coalesce(v_row ->> 'id', v_row ->> 'key'),
      jsonb_strip_nulls(jsonb_build_object(
        'old', case when tg_op <> 'INSERT' then to_jsonb(old) end,
        'new', case when tg_op <> 'DELETE' then to_jsonb(new) end
      ))
    );
  end if;
  return coalesce(new, old);
end;
$$;

create trigger broadcasts_audit
  after insert or update or delete on public.broadcasts
  for each row execute function private.audit_admin_change();

create trigger support_tickets_audit
  after update on public.support_tickets
  for each row execute function private.audit_admin_change();

create trigger app_settings_audit
  after insert or update or delete on public.app_settings
  for each row execute function private.audit_admin_change();

create trigger admins_audit
  after insert or update or delete on public.admins
  for each row execute function private.audit_admin_change();

-- ─── Grants and RLS ──────────────────────────────────────────────────

alter table public.broadcasts enable row level security;
alter table public.support_tickets enable row level security;
alter table public.support_ticket_notes enable row level security;
alter table public.app_settings enable row level security;
alter table public.admin_audit_log enable row level security;

revoke all on table
  public.broadcasts, public.support_tickets, public.support_ticket_notes,
  public.app_settings, public.admin_audit_log
from anon, authenticated;

grant select, delete on table public.broadcasts to authenticated;
grant insert (title, body, image_path, deep_link, audience, send_push, status, scheduled_at)
  on table public.broadcasts to authenticated;
grant update (title, body, image_path, deep_link, audience, send_push, status, scheduled_at)
  on table public.broadcasts to authenticated;

grant select on table public.support_tickets to authenticated;
grant update (status, assigned_to, admin_reply, replied_at, resolved_at)
  on table public.support_tickets to authenticated;

grant select on table public.support_ticket_notes to authenticated;
grant insert (ticket_id, note) on table public.support_ticket_notes to authenticated;

grant select on table public.app_settings to anon, authenticated;
grant insert, update, delete on table public.app_settings to authenticated;

grant select on table public.admin_audit_log to authenticated;

-- Broadcasts: admins only. Sending/sent/failed states are set by the dispatcher.
create policy broadcasts_admin_select on public.broadcasts
  for select to authenticated
  using ((select private.is_admin()));

create policy broadcasts_admin_insert on public.broadcasts
  for insert to authenticated
  with check (
    (select private.is_admin())
    and created_by = (select auth.uid())
    and status in ('draft', 'scheduled')
  );

create policy broadcasts_admin_update on public.broadcasts
  for update to authenticated
  using ((select private.is_admin()) and status in ('draft', 'scheduled'))
  with check ((select private.is_admin()) and status in ('draft', 'scheduled', 'cancelled'));

create policy broadcasts_admin_delete_draft on public.broadcasts
  for delete to authenticated
  using ((select private.is_admin()) and status = 'draft');

-- Support tickets: owners read their own; admins read and update all.
-- Creation goes through submit_support_ticket() (functions phase).
create policy support_tickets_select on public.support_tickets
  for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_admin()));

create policy support_tickets_admin_update on public.support_tickets
  for update to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

create policy support_ticket_notes_admin_select on public.support_ticket_notes
  for select to authenticated
  using ((select private.is_admin()));

create policy support_ticket_notes_admin_insert on public.support_ticket_notes
  for insert to authenticated
  with check ((select private.is_admin()) and admin_id = (select auth.uid()));

-- App settings: public keys readable before sign-in; admins manage all.
create policy app_settings_public_select on public.app_settings
  for select to anon
  using (is_public);

create policy app_settings_select on public.app_settings
  for select to authenticated
  using (is_public or (select private.is_admin()));

create policy app_settings_admin_insert on public.app_settings
  for insert to authenticated
  with check ((select private.is_admin()));

create policy app_settings_admin_update on public.app_settings
  for update to authenticated
  using ((select private.is_admin()))
  with check ((select private.is_admin()));

create policy app_settings_admin_delete on public.app_settings
  for delete to authenticated
  using ((select private.is_admin()));

create policy admin_audit_log_admin_select on public.admin_audit_log
  for select to authenticated
  using ((select private.is_admin()));
