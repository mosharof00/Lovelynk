insert into public.app_settings (key, value, is_public, description)
values ('app_store_id', 'null'::jsonb, true, 'Numeric App Store ID used by Rate Us fallback (e.g. "1234567890").')
on conflict (key) do nothing;
