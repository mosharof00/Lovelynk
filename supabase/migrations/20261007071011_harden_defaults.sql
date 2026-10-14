-- Close the advisor warnings on the "automatic RLS" event-trigger function.
-- It still runs as an event trigger; it just can't be called through the API.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

-- Internal schema: helper functions and internal tables. Not exposed by the Data API.
create schema if not exists private;
revoke all on schema private from public, anon;
grant usage on schema private to authenticated;

-- Functions are executable by PUBLIC by default; require explicit grants instead.
alter default privileges in schema private revoke execute on functions from public;
alter default privileges in schema public revoke execute on functions from public;

-- Fuzzy name/email search for the admin panel.
create extension if not exists pg_trgm with schema extensions;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
