// Deno Edge Function: refresh-weather
// Fetches current weather for a user from OpenWeather and stores it in public.user_weather.
// Throttles calls to max 1 per 30 minutes unless forced.
import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2';

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

function secretKey(): string {
  const legacy = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (legacy) return legacy;
  const keys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') ?? '{}');
  return keys.default ?? Object.values(keys)[0];
}

interface RequestPayload {
  user_id?: string;
  force?: boolean;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  if (!token) return json({ error: 'Not authenticated' }, 401);

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const admin = createClient(supabaseUrl, secretKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data: userData, error: userError } = await admin.auth.getUser(token);
  const caller = userData?.user;
  if (userError || !caller) return json({ error: 'Not authenticated' }, 401);

  let payload: RequestPayload = {};
  try {
    const text = await req.text();
    if (text) {
      payload = JSON.parse(text);
    }
  } catch (_) {
    // Body is optional
  }

  const targetUserId = payload.user_id ?? caller.id;

  // Security check: if requesting for another user, ensure they are connected partners
  if (targetUserId !== caller.id) {
    const { data: coupleMember } = await admin
      .from('couple_members')
      .select('couple_id')
      .eq('user_id', caller.id)
      .is('left_at', null)
      .maybeSingle();

    if (coupleMember) {
      const { data: partnerMember } = await admin
        .from('couple_members')
        .select('user_id')
        .eq('couple_id', coupleMember.couple_id)
        .eq('user_id', targetUserId)
        .is('left_at', null)
        .maybeSingle();

      if (!partnerMember) {
        return json({ error: 'Not permitted to refresh weather for this user' }, 403);
      }
    } else {
      return json({ error: 'Not permitted to refresh weather for this user' }, 403);
    }
  }

  // 1. Get user location
  const { data: location, error: locErr } = await admin
    .from('user_locations')
    .select('latitude, longitude, city, country_code, updated_at')
    .eq('user_id', targetUserId)
    .maybeSingle();

  if (locErr || !location) {
    return json({
      status: 'no_location',
      message: 'No location recorded for user yet.',
    });
  }

  // 2. Check cached weather
  const { data: cachedWeather } = await admin
    .from('user_weather')
    .select('temperature_c, condition, condition_id, icon_code, fetched_at')
    .eq('user_id', targetUserId)
    .maybeSingle();

  const now = Date.now();
  const cacheAgeMinutes = cachedWeather?.fetched_at
    ? (now - new Date(cachedWeather.fetched_at).getTime()) / (1000 * 60)
    : 999999;

  // Cache is valid for 30 minutes unless forced
  if (!payload.force && cachedWeather && cacheAgeMinutes < 30) {
    return json({
      status: 'cached',
      weather: cachedWeather,
      cache_age_minutes: Math.round(cacheAgeMinutes),
    });
  }

  // 3. Fetch from OpenWeather
  const apiKey = Deno.env.get('OPENWEATHER_API_KEY');
  if (!apiKey) {
    return json(
      {
        status: 'missing_api_key',
        message:
          'OPENWEATHER_API_KEY secret is not set in Supabase. Please add it to Supabase Edge Function Secrets.',
        cached: cachedWeather ?? null,
      },
      503,
    );
  }

  const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${location.latitude}&lon=${location.longitude}&appid=${apiKey}&units=metric`;
  const weatherRes = await fetch(weatherUrl);

  if (!weatherRes.ok) {
    const errorText = await weatherRes.text();
    return json(
      {
        status: 'api_error',
        code: weatherRes.status,
        message: errorText,
      },
      502,
    );
  }

  const weatherData = await weatherRes.json();
  const primaryWeather = weatherData.weather?.[0] ?? {};
  const temperatureC = Math.round(weatherData.main?.temp ?? 0);
  const condition = primaryWeather.main ?? 'Clear';
  const conditionId = primaryWeather.id ?? 800;
  const iconCode = primaryWeather.icon ?? '01d';
  const fetchedAt = new Date().toISOString();

  // 4. Upsert user_weather
  const { data: savedWeather, error: upsertErr } = await admin
    .from('user_weather')
    .upsert({
      user_id: targetUserId,
      temperature_c: temperatureC,
      condition: condition,
      condition_id: conditionId,
      icon_code: iconCode,
      fetched_at: fetchedAt,
    })
    .select()
    .single();

  if (upsertErr) {
    return json({ error: 'Failed to save weather data', details: upsertErr }, 500);
  }

  // 5. Notify partner if coupled
  try {
    const { data: coupleMember } = await admin
      .from('couple_members')
      .select('couple_id')
      .eq('user_id', targetUserId)
      .is('left_at', null)
      .maybeSingle();

    if (coupleMember) {
      const { data: partnerMember } = await admin
        .from('couple_members')
        .select('user_id')
        .eq('couple_id', coupleMember.couple_id)
        .neq('user_id', targetUserId)
        .is('left_at', null)
        .maybeSingle();

      if (partnerMember) {
        await admin.channel(`user:${partnerMember.user_id}`).send({
          type: 'broadcast',
          event: 'partner.weather',
          payload: {
            temperature_c: temperatureC,
            condition,
            condition_id: conditionId,
            icon_code: iconCode,
            fetched_at: fetchedAt,
          },
        });
      }
    }
  } catch (notifyErr) {
    console.error('Failed to broadcast partner.weather:', notifyErr);
  }

  return json({
    status: 'updated',
    weather: savedWeather,
  });
});
