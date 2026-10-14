-- Phase 2: profile editing, support tickets, safe account deletion.
-- Pattern: logic in private (SECURITY DEFINER), thin SECURITY INVOKER wrapper in public.

-- ─── Partner notification ────────────────────────────────────────────
-- Tells the active partner's app to refresh (name / avatar / couple data).
create or replace function private.notify_partner_updated()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_partner_id uuid := private.partner_id();
begin
  if v_partner_id is not null then
    perform realtime.send(
      jsonb_build_object('couple_id', private.current_couple_id()),
      'couple.updated',
      'user:' || v_partner_id::text,
      true
    );
  end if;
end;
$$;

-- ─── update_my_profile ───────────────────────────────────────────────
-- p_full_name: null = unchanged. p_avatar_path: null = unchanged,
-- '' = remove, otherwise an uploaded object at avatars/{my_id}/...
create or replace function private.update_my_profile(
  p_full_name   text default null,
  p_avatar_path text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid  uuid := private.require_app_user();
  v_name text := btrim(p_full_name);
  v_path text := btrim(p_avatar_path);
begin
  if p_full_name is not null and char_length(v_name) not between 1 and 60 then
    raise exception 'Name must be 1 to 60 characters' using errcode = '22023';
  end if;

  if v_path is not null and v_path <> '' then
    if v_path !~ ('^' || v_uid::text || '/[A-Za-z0-9_.-]{1,100}$') then
      raise exception 'Invalid avatar path' using errcode = '22023';
    end if;
    if not exists (
      select 1 from storage.objects o
      where o.bucket_id = 'avatars' and o.name = v_path
    ) then
      raise exception 'Avatar upload not found' using errcode = '22023';
    end if;
  end if;

  update public.users u
     set full_name   = coalesce(v_name, u.full_name),
         avatar_path = case
                         when p_avatar_path is null then u.avatar_path
                         else nullif(v_path, '')
                       end
   where u.id = v_uid;

  perform private.notify_partner_updated();
  return private.get_session_bootstrap();
end;
$$;

-- ─── submit_support_ticket ───────────────────────────────────────────
-- "Contact Us". Attachments are uploaded first to
-- support-attachments/{my_id}/..., then their paths are passed here.
create or replace function private.submit_support_ticket(
  p_category         public.ticket_category,
  p_subject          text,
  p_message          text,
  p_attachment_paths text[] default '{}',
  p_app_version      text default null,
  p_device_model     text default null,
  p_os_version       text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid   uuid := private.require_app_user();
  v_paths text[] := coalesce(p_attachment_paths, '{}');
  v_path  text;
  v_id    uuid;
begin
  perform private.hit_rate_limit('support_ticket', 5, interval '1 day');

  if char_length(btrim(coalesce(p_subject, ''))) not between 1 and 120 then
    raise exception 'Subject must be 1 to 120 characters' using errcode = '22023';
  end if;
  if char_length(btrim(coalesce(p_message, ''))) not between 1 and 4000 then
    raise exception 'Message must be 1 to 4000 characters' using errcode = '22023';
  end if;
  if cardinality(v_paths) > 3 then
    raise exception 'Up to 3 attachments are allowed' using errcode = '22023';
  end if;

  foreach v_path in array v_paths loop
    if v_path !~ ('^' || v_uid::text || '/') or not exists (
      select 1 from storage.objects o
      where o.bucket_id = 'support-attachments' and o.name = v_path
    ) then
      raise exception 'Invalid attachment' using errcode = '22023';
    end if;
  end loop;

  insert into public.support_tickets (
    user_id, email, category, subject, message, attachment_paths,
    app_version, device_model, os_version
  )
  select
    v_uid, u.email, coalesce(p_category, 'general'),
    btrim(p_subject), btrim(p_message), v_paths,
    left(nullif(btrim(p_app_version), ''), 32),
    left(nullif(btrim(p_device_model), ''), 64),
    left(nullif(btrim(p_os_version), ''), 32)
  from public.users u
  where u.id = v_uid
  returning id into v_id;

  return v_id;
end;
$$;

-- ─── Account deletion safety ─────────────────────────────────────────
-- Runs for every deletion path (delete-account function, dashboard):
-- archives the couple so the partner is returned to "unpaired" instead of
-- being left in an active one-member couple, then notifies the partner.
create or replace function private.handle_user_deleted()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_couple_id  uuid;
  v_partner_id uuid;
begin
  select m.couple_id into v_couple_id
  from public.couple_members m
  where m.user_id = old.id and m.left_at is null;

  if v_couple_id is not null then
    select m.user_id into v_partner_id
    from public.couple_members m
    where m.couple_id = v_couple_id and m.user_id <> old.id and m.left_at is null;

    update public.couples
       set status = 'archived',
           archived_at = now(),
           purge_after = now()
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
  end if;

  delete from public.pairing_invites where inviter_id = old.id;

  insert into public.daily_metrics as d (day, deleted_users)
  values ((now() at time zone 'utc')::date, 1)
  on conflict (day) do update set deleted_users = d.deleted_users + 1;

  return old;
end;
$$;

revoke all on function private.handle_user_deleted() from public, anon, authenticated;

create trigger users_before_delete
  before delete on public.users
  for each row execute function private.handle_user_deleted();

-- ─── Public wrappers ─────────────────────────────────────────────────

create or replace function public.update_my_profile(
  p_full_name   text default null,
  p_avatar_path text default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.update_my_profile(p_full_name, p_avatar_path); $$;

create or replace function public.submit_support_ticket(
  p_category         public.ticket_category,
  p_subject          text,
  p_message          text,
  p_attachment_paths text[] default '{}',
  p_app_version      text default null,
  p_device_model     text default null,
  p_os_version       text default null
)
returns uuid
language sql
security invoker
set search_path = ''
as $$
  select private.submit_support_ticket(
    p_category, p_subject, p_message, p_attachment_paths,
    p_app_version, p_device_model, p_os_version
  );
$$;

-- ─── Grants: signed-in users only ───────────────────────────────────

revoke all on function private.notify_partner_updated() from public, anon;
revoke all on function private.update_my_profile(text, text) from public, anon;
revoke all on function private.submit_support_ticket(public.ticket_category, text, text, text[], text, text, text) from public, anon;
revoke all on function public.update_my_profile(text, text) from public, anon;
revoke all on function public.submit_support_ticket(public.ticket_category, text, text, text[], text, text, text) from public, anon;

grant execute on function private.notify_partner_updated() to authenticated;
grant execute on function private.update_my_profile(text, text) to authenticated;
grant execute on function private.submit_support_ticket(public.ticket_category, text, text, text[], text, text, text) to authenticated;
grant execute on function public.update_my_profile(text, text) to authenticated;
grant execute on function public.submit_support_ticket(public.ticket_category, text, text, text[], text, text, text) to authenticated;

-- Profile edits go through update_my_profile (validation + partner refresh).
revoke update (full_name, avatar_path) on public.users from authenticated;
