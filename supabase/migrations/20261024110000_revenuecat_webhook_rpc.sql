-- Atomically logs incoming RevenueCat events into private.revenuecat_events.
-- Returns true if this is a new event, or false if already processed (idempotent).
create or replace function public.log_revenuecat_event(
  p_event_id text,
  p_app_user_id text,
  p_type text,
  p_environment text,
  p_payload jsonb
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (select 1 from private.revenuecat_events where event_id = p_event_id) then
    return false;
  end if;

  insert into private.revenuecat_events (event_id, app_user_id, type, environment, payload, received_at)
  values (p_event_id, p_app_user_id, p_type, p_environment, p_payload, now());

  return true;
end;
$$;

revoke all on function public.log_revenuecat_event(text, text, text, text, jsonb) from public, anon, authenticated;
grant execute on function public.log_revenuecat_event(text, text, text, text, jsonb) to service_role;
