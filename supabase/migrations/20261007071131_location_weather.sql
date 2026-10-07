-- Latest position only (no history). Visible to the owner and their active partner.
create table public.user_locations (
  user_id      uuid primary key references public.users (id) on delete cascade,
  latitude     double precision not null check (latitude between -90 and 90),
  longitude    double precision not null check (longitude between -180 and 180),
  accuracy_m   real check (accuracy_m >= 0),
  city         text check (char_length(city) <= 100),
  country_code char(2) check (country_code ~ '^[A-Z]{2}$'),
  updated_at   timestamptz not null default now()
);

-- Server sets the timestamp and rejects uploads more often than once a minute.
create or replace function private.throttle_user_location()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and old.updated_at > now() - interval '60 seconds' then
    raise exception 'Location updated too frequently' using errcode = 'P0429';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger user_locations_throttle
  before insert or update on public.user_locations
  for each row execute function private.throttle_user_location();

-- Written only by the refresh-weather Edge Function.
create table public.user_weather (
  user_id       uuid primary key references public.users (id) on delete cascade,
  temperature_c smallint not null,
  condition     text not null check (char_length(condition) <= 60),
  condition_id  int not null,
  icon_code     text not null check (char_length(icon_code) <= 8),
  fetched_at    timestamptz not null default now()
);

alter table public.user_locations enable row level security;
alter table public.user_weather enable row level security;

revoke all on table public.user_locations, public.user_weather from anon, authenticated;

grant select, delete on table public.user_locations to authenticated;
grant insert (user_id, latitude, longitude, accuracy_m, city, country_code)
  on table public.user_locations to authenticated;
grant update (latitude, longitude, accuracy_m, city, country_code)
  on table public.user_locations to authenticated;

grant select on table public.user_weather to authenticated;

-- No admin access to locations or weather.
create policy user_locations_select on public.user_locations
  for select to authenticated
  using (user_id = (select auth.uid()) or user_id = (select private.partner_id()));

create policy user_locations_insert_own on public.user_locations
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy user_locations_update_own on public.user_locations
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy user_locations_delete_own on public.user_locations
  for delete to authenticated
  using (user_id = (select auth.uid()));

create policy user_weather_select on public.user_weather
  for select to authenticated
  using (user_id = (select auth.uid()) or user_id = (select private.partner_id()));
