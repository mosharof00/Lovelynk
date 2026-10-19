-- Phase 4: Location tracking, distance calculations, partner live snapshot, and privacy toggle.
-- Pattern: logic in private (SECURITY DEFINER), thin SECURITY INVOKER wrapper in public.

-- 1. Add location_sharing_enabled to public.users
alter table public.users
  add column if not exists location_sharing_enabled boolean not null default true;

-- 2. Distance calculation helper (Haversine in km)
create or replace function private.haversine_distance_km(
  lat1 double precision, lon1 double precision,
  lat2 double precision, lon2 double precision
)
returns double precision
language sql
immutable
set search_path = ''
as $$
  select 6371.0 * 2.0 * asin(
    sqrt(
      sin(radians(lat2 - lat1) / 2.0)^2 +
      cos(radians(lat1)) * cos(radians(lat2)) *
      sin(radians(lon2 - lon1) / 2.0)^2
    )
  );
$$;

-- 3. Replace the old throttle trigger so update_my_location has fine control
drop trigger if exists user_locations_throttle on public.user_locations;

create or replace function private.throttle_user_location()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger user_locations_throttle
  before insert or update on public.user_locations
  for each row execute function private.throttle_user_location();

-- 4. RPC set_location_sharing(p_enabled boolean)
create or replace function private.set_location_sharing(p_enabled boolean)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := private.require_app_user();
begin
  update public.users
     set location_sharing_enabled = coalesce(p_enabled, true)
   where id = v_uid;

  perform private.notify_partner_updated();
  return coalesce(p_enabled, true);
end;
$$;

-- 5. RPC get_partner_snapshot()
create or replace function private.get_partner_snapshot()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid         uuid := auth.uid();
  v_partner_id  uuid;
  v_partner     public.users%rowtype;
  v_loc         public.user_locations%rowtype;
  v_weather     public.user_weather%rowtype;
  v_my_loc      public.user_locations%rowtype;
  v_dist_km     double precision;
  v_bearing_deg double precision;
begin
  if v_uid is null then
    return null;
  end if;

  v_partner_id := private.partner_id();
  if v_partner_id is null then
    return null;
  end if;

  select * into v_partner from public.users where id = v_partner_id;
  if not found then
    return null;
  end if;

  select * into v_my_loc from public.user_locations where user_id = v_uid;

  if v_partner.location_sharing_enabled then
    select * into v_loc from public.user_locations where user_id = v_partner_id;
    if v_loc.user_id is not null and v_my_loc.user_id is not null then
      v_dist_km := private.haversine_distance_km(
        v_my_loc.latitude, v_my_loc.longitude,
        v_loc.latitude, v_loc.longitude
      );
      -- Bearing calculation
      v_bearing_deg := degrees(atan2(
        sin(radians(v_loc.longitude - v_my_loc.longitude)) * cos(radians(v_loc.latitude)),
        cos(radians(v_my_loc.latitude)) * sin(radians(v_loc.latitude)) -
        sin(radians(v_my_loc.latitude)) * cos(radians(v_loc.latitude)) * cos(radians(v_loc.longitude - v_my_loc.longitude))
      ));
      v_bearing_deg := (v_bearing_deg + 360.0) % 360.0;
    end if;
  end if;

  select * into v_weather from public.user_weather where user_id = v_partner_id;

  return jsonb_build_object(
    'partner_id',                v_partner_id,
    'location_sharing_enabled',  v_partner.location_sharing_enabled,
    'location', case
      when v_partner.location_sharing_enabled and v_loc.user_id is not null then
        jsonb_build_object(
          'latitude',            v_loc.latitude,
          'longitude',           v_loc.longitude,
          'accuracy_m',          v_loc.accuracy_m,
          'city',                v_loc.city,
          'country_code',        v_loc.country_code,
          'updated_at',          v_loc.updated_at
        )
      else null
    end,
    'distance_km',               v_dist_km,
    'bearing_degrees',           v_bearing_deg,
    'timezone',                  v_partner.timezone,
    'utc_offset_minutes',        v_partner.utc_offset_minutes,
    'weather', case
      when v_weather.user_id is not null then
        jsonb_build_object(
          'temperature_c',       v_weather.temperature_c,
          'condition',           v_weather.condition,
          'condition_id',        v_weather.condition_id,
          'icon_code',           v_weather.icon_code,
          'fetched_at',          v_weather.fetched_at
        )
      else null
    end,
    'server_now',                now()
  );
end;
$$;

-- 6. RPC update_my_location(...)
create or replace function private.update_my_location(
  p_latitude     double precision,
  p_longitude    double precision,
  p_accuracy_m   real default null,
  p_city         text default null,
  p_country_code text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid          uuid := private.require_app_user();
  v_sharing_on   boolean;
  v_lat          double precision;
  v_lng          double precision;
  v_accuracy     real;
  v_city         text;
  v_country      char(2);
  v_prev         public.user_locations%rowtype;
  v_dist_km      double precision;
  v_partner_id   uuid;
begin
  select location_sharing_enabled into v_sharing_on
  from public.users where id = v_uid;

  if not coalesce(v_sharing_on, true) then
    return jsonb_build_object(
      'accepted', false,
      'reason', 'sharing_disabled'
    );
  end if;

  if p_latitude is null or p_longitude is null or
     p_latitude < -90 or p_latitude > 90 or
     p_longitude < -180 or p_longitude > 180 then
    raise exception 'Invalid coordinates' using errcode = '22023';
  end if;

  -- Discard very low accuracy (worse than 150m) if given
  if p_accuracy_m is not null and p_accuracy_m > 150 then
    return jsonb_build_object(
      'accepted', false,
      'reason', 'inaccurate'
    );
  end if;

  -- Round to 4 decimal places (~11 meters)
  v_lat      := round(p_latitude::numeric, 4)::double precision;
  v_lng      := round(p_longitude::numeric, 4)::double precision;
  v_accuracy := case when p_accuracy_m is not null and p_accuracy_m >= 0 then p_accuracy_m end;
  v_city     := left(nullif(trim(p_city), ''), 100);
  v_country  := nullif(upper(trim(p_country_code)), '');
  if v_country is not null and v_country !~ '^[A-Z]{2}$' then
    v_country := null;
  end if;

  -- Throttle check against previous upload
  select * into v_prev from public.user_locations where user_id = v_uid;

  if v_prev.user_id is not null and v_prev.updated_at > now() - interval '45 seconds' then
    v_dist_km := private.haversine_distance_km(v_prev.latitude, v_prev.longitude, v_lat, v_lng);
    -- If moved less than 100 meters within 45 seconds, throttle gracefully
    if v_dist_km < 0.1 then
      return jsonb_build_object(
        'accepted', false,
        'reason', 'throttled',
        'next_allowed_at', v_prev.updated_at + interval '45 seconds'
      );
    end if;
  end if;

  -- Upsert
  insert into public.user_locations (
    user_id, latitude, longitude, accuracy_m, city, country_code, updated_at
  ) values (
    v_uid, v_lat, v_lng, v_accuracy, v_city, v_country, now()
  )
  on conflict (user_id) do update set
    latitude     = excluded.latitude,
    longitude    = excluded.longitude,
    accuracy_m   = excluded.accuracy_m,
    city         = coalesce(excluded.city, public.user_locations.city),
    country_code = coalesce(excluded.country_code, public.user_locations.country_code),
    updated_at   = now();

  -- Realtime broadcast if partner exists and movement > 200m or city changed
  v_partner_id := private.partner_id();
  if v_partner_id is not null then
    if v_prev.user_id is null or
       (v_dist_km is not null and v_dist_km > 0.2) or
       (v_city is not null and v_city is distinct from v_prev.city) or
       (v_prev.updated_at < now() - interval '30 minutes') then
      perform realtime.send(
        jsonb_build_object(
          'latitude', v_lat,
          'longitude', v_lng,
          'city', v_city,
          'updated_at', now()
        ),
        'partner.location',
        'user:' || v_partner_id::text,
        true
      );
    end if;
  end if;

  return jsonb_build_object(
    'accepted', true,
    'latitude', v_lat,
    'longitude', v_lng,
    'city', v_city,
    'updated_at', now()
  );
end;
$$;

-- 7. Update get_session_bootstrap to return location_sharing_enabled & partner_live
create or replace function private.get_session_bootstrap()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_uid       uuid := auth.uid();
  v_user      public.users%rowtype;
  v_couple_id uuid;
begin
  if v_uid is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  select * into v_user from public.users where id = v_uid;
  if not found then
    raise exception 'This account cannot be used in the app' using errcode = '42501';
  end if;

  v_couple_id := private.current_couple_id();

  return jsonb_build_object(
    'user', jsonb_build_object(
      'id',                       v_user.id,
      'email',                    v_user.email,
      'full_name',                v_user.full_name,
      'avatar_path',              v_user.avatar_path,
      'timezone',                 v_user.timezone,
      'utc_offset_minutes',       v_user.utc_offset_minutes,
      'created_at',               v_user.created_at,
      'location_sharing_enabled', v_user.location_sharing_enabled
    ),
    'couple', (
      select jsonb_build_object(
        'id',             c.id,
        'together_since', c.together_since,
        'next_visit_at',  c.next_visit_at,
        'created_at',     c.created_at,
        'partner', jsonb_build_object(
          'id',                       p.id,
          'full_name',                p.full_name,
          'nickname',                 me.partner_nickname,
          'avatar_path',              p.avatar_path,
          'timezone',                 p.timezone,
          'utc_offset_minutes',       p.utc_offset_minutes,
          'location_sharing_enabled', p.location_sharing_enabled
        )
      )
      from public.couples c
      join public.couple_members me
        on me.couple_id = c.id and me.user_id = v_uid and me.left_at is null
      join public.couple_members pm
        on pm.couple_id = c.id and pm.user_id <> v_uid and pm.left_at is null
      join public.users p on p.id = pm.user_id
      where c.id = v_couple_id
    ),
    'partner_live', private.get_partner_snapshot(),
    'access', private.get_my_access()
  );
end;
$$;

-- 8. Public wrappers
create or replace function public.update_my_location(
  p_latitude     double precision,
  p_longitude    double precision,
  p_accuracy_m   real default null,
  p_city         text default null,
  p_country_code text default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$ select private.update_my_location(p_latitude, p_longitude, p_accuracy_m, p_city, p_country_code); $$;

create or replace function public.set_location_sharing(p_enabled boolean)
returns boolean
language sql
security invoker
set search_path = ''
as $$ select private.set_location_sharing(p_enabled); $$;

create or replace function public.get_partner_snapshot()
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$ select private.get_partner_snapshot(); $$;

-- 9. Revoke & grant
revoke all on function private.haversine_distance_km(double precision, double precision, double precision, double precision) from public, anon;
revoke all on function private.set_location_sharing(boolean) from public, anon;
revoke all on function private.get_partner_snapshot() from public, anon;
revoke all on function private.update_my_location(double precision, double precision, real, text, text) from public, anon;

revoke all on function public.set_location_sharing(boolean) from public, anon;
revoke all on function public.get_partner_snapshot() from public, anon;
revoke all on function public.update_my_location(double precision, double precision, real, text, text) from public, anon;

grant execute on function private.haversine_distance_km(double precision, double precision, double precision, double precision) to authenticated;
grant execute on function private.set_location_sharing(boolean) to authenticated;
grant execute on function private.get_partner_snapshot() to authenticated;
grant execute on function private.update_my_location(double precision, double precision, real, text, text) to authenticated;

grant execute on function public.set_location_sharing(boolean) to authenticated;
grant execute on function public.get_partner_snapshot() to authenticated;
grant execute on function public.update_my_location(double precision, double precision, real, text, text) to authenticated;
