-- Buckets: size and type limits are enforced by Storage before upload.
-- Paths always start with the owner's id: {owner_id}/...
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
  ('avatars',             'avatars',             false, 2097152, array['image/jpeg', 'image/png', 'image/webp']),
  ('support-attachments', 'support-attachments', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
  ('admin-assets',        'admin-assets',        false, 2097152, array['image/jpeg', 'image/png', 'image/webp']),
  ('public-assets',       'public-assets',       true,  5242880, array['image/jpeg', 'image/png', 'image/webp']);

-- ─── avatars: {user_id}/avatar_{ts}.webp ─────────────────────────────
-- Owner, active partner and admins can read; only the owner can write.

create policy avatars_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'avatars'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or (storage.foldername(name))[1] = (select private.partner_id())::text
      or (select private.is_admin())
    )
  );

create policy avatars_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy avatars_update_own on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy avatars_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ─── support-attachments: {user_id}/{ticket_id}/{file} ──────────────
-- Owner uploads and reads; admins read.

create policy support_attachments_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'support-attachments'
    and (
      (storage.foldername(name))[1] = (select auth.uid())::text
      or (select private.is_admin())
    )
  );

create policy support_attachments_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy support_attachments_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'support-attachments'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ─── admin-assets: {admin_id}/... ───────────────────────────────────

create policy admin_assets_select on storage.objects
  for select to authenticated
  using (bucket_id = 'admin-assets' and (select private.is_admin()));

create policy admin_assets_insert_own on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'admin-assets'
    and (select private.is_admin())
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy admin_assets_update_own on storage.objects
  for update to authenticated
  using (
    bucket_id = 'admin-assets'
    and (select private.is_admin())
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'admin-assets'
    and (select private.is_admin())
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy admin_assets_delete_own on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'admin-assets'
    and (select private.is_admin())
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ─── public-assets: broadcasts/{id}/..., app/... ────────────────────
-- Public bucket: files are served by URL without a policy. Only admins manage them.

create policy public_assets_admin_select on storage.objects
  for select to authenticated
  using (bucket_id = 'public-assets' and (select private.is_admin()));

create policy public_assets_admin_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'public-assets' and (select private.is_admin()));

create policy public_assets_admin_update on storage.objects
  for update to authenticated
  using (bucket_id = 'public-assets' and (select private.is_admin()))
  with check (bucket_id = 'public-assets' and (select private.is_admin()));

create policy public_assets_admin_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'public-assets' and (select private.is_admin()));
