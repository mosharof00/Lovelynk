// Deno Edge Function: push-dispatch
// Sends Firebase Cloud Messaging (FCM) v1 push notifications to user devices.
// Features:
// 1. Checks notification_preferences & quiet hours in user's local timezone.
// 2. Includes unread badge count and content-available: 1 for background widget refresh.
// 3. Automatically removes invalid / unregistered tokens.
import { createClient } from 'npm:@supabase/supabase-js@2';

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

// Convert base64url to base64
function base64url(input: Uint8Array | string): string {
  const str = typeof input === 'string'
    ? input
    : String.fromCharCode(...input);
  return btoa(str)
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

// Generates Google OAuth2 access token from service account JSON using Web Crypto API
async function getGoogleAccessToken(serviceAccount: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    iat: now,
    exp: now + 3600,
  };

  const enc = new TextEncoder();
  const unsignedToken = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;

  // Parse PKCS8 private key
  const pem = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const binaryDer = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    enc.encode(unsignedToken),
  );

  const jwt = `${unsignedToken}.${base64url(new Uint8Array(signature))}`;

  // Exchange for access token
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Google token exchange failed: ${res.status} ${errText}`);
  }

  const tokenData = await res.json();
  return tokenData.access_token;
}

// Checks if current time in user's timezone falls within quiet hours (e.g. 22:00 to 07:00)
function isWithinQuietHours(
  timezone: string | null,
  startStr: string | null,
  endStr: string | null,
): boolean {
  if (!startStr || !endStr) return false;

  try {
    const tz = timezone || 'UTC';
    const formatter = new Intl.DateTimeFormat('en-US', {
      timeZone: tz,
      hour: 'numeric',
      minute: 'numeric',
      hour12: false,
    });
    const parts = formatter.formatToParts(new Date());
    const hour = parseInt(parts.find((p) => p.type === 'hour')?.value ?? '0', 10);
    const minute = parseInt(parts.find((p) => p.type === 'minute')?.value ?? '0', 10);
    const currentMins = hour * 60 + minute;

    const [startH, startM] = startStr.split(':').map((v) => parseInt(v, 10));
    const [endH, endM] = endStr.split(':').map((v) => parseInt(v, 10));
    const startMins = startH * 60 + (startM || 0);
    const endMins = endH * 60 + (endM || 0);

    if (startMins <= endMins) {
      return currentMins >= startMins && currentMins < endMins;
    } else {
      // Wraps around midnight (e.g. 22:00 to 07:00)
      return currentMins >= startMins || currentMins < endMins;
    }
  } catch (e) {
    console.error('Error evaluating quiet hours:', e);
    return false;
  }
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const admin = createClient(supabaseUrl, secretKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  let body: any = {};
  try {
    const text = await req.text();
    if (text) body = JSON.parse(text);
  } catch (_) {}

  // Can be called via database webhook { record: { ... } } or direct payload
  const notificationRecord = body.record || body;
  const notificationId = notificationRecord.id || body.notification_id;
  const targetUserId = notificationRecord.user_id || body.user_id;

  if (!targetUserId) {
    return json({ error: 'Missing target user_id' }, 400);
  }

  // 1. Fetch notification details if not fully passed
  let title = notificationRecord.title;
  let notifBody = notificationRecord.body;
  let category = notificationRecord.category || 'relationship';
  let dataPayload: Record<string, any> = notificationRecord.data || {};

  if (notificationId && (!title || !notifBody)) {
    const { data: nRow } = await admin
      .from('notifications')
      .select('title, body, category, data')
      .eq('id', notificationId)
      .maybeSingle();

    if (nRow) {
      title = nRow.title;
      notifBody = nRow.body;
      category = nRow.category;
      dataPayload = nRow.data || {};
    }
  }

  // 2. Check user notification preferences
  const { data: prefs } = await admin
    .from('notification_preferences')
    .select('*')
    .eq('user_id', targetUserId)
    .maybeSingle();

  // If user disabled push for this category, check if we should suppress alert
  let isCategoryDisabled = false;
  if (prefs) {
    if (category === 'heartbeat' && prefs.push_heartbeat === false) isCategoryDisabled = true;
    if (category === 'kiss' && prefs.push_kiss === false) isCategoryDisabled = true;
    if (category === 'emoji' && prefs.push_emoji === false) isCategoryDisabled = true;
    if (category === 'relationship' && prefs.push_relationship === false) isCategoryDisabled = true;
    if (category === 'subscription' && prefs.push_subscription === false) isCategoryDisabled = true;
    if (category === 'announcement' && prefs.push_announcements === false) isCategoryDisabled = true;
  }

  // 3. Check quiet hours in user's timezone
  const { data: userRow } = await admin
    .from('users')
    .select('timezone')
    .eq('id', targetUserId)
    .maybeSingle();

  const isQuiet = isWithinQuietHours(
    userRow?.timezone,
    prefs?.quiet_hours_start,
    prefs?.quiet_hours_end,
  );

  // 4. Fetch user's registered devices
  const { data: devices, error: devErr } = await admin
    .from('push_devices')
    .select('fcm_token, platform')
    .eq('user_id', targetUserId);

  if (devErr || !devices || devices.length === 0) {
    return json({ status: 'no_devices', count: 0 });
  }

  // 5. Get unread count for badge
  const { count: unreadCount } = await admin
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', targetUserId)
    .is('read_at', null);

  const badge = unreadCount ?? 1;

  // 6. Get Firebase service account & access token
  const saRaw = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
  if (!saRaw) {
    return json(
      {
        error: 'Missing FIREBASE_SERVICE_ACCOUNT secret in Supabase',
      },
      503,
    );
  }

  let serviceAccount: any;
  try {
    serviceAccount = JSON.parse(saRaw);
  } catch (e) {
    return json({ error: 'Failed to parse FIREBASE_SERVICE_ACCOUNT JSON' }, 500);
  }

  const accessToken = await getGoogleAccessToken(serviceAccount);
  const projectId = serviceAccount.project_id;
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const results: any[] = [];
  const staleTokens: string[] = [];

  // Stringify all data payload values for FCM compatibility
  const stringifiedData: Record<string, string> = {
    notification_id: notificationId || '',
    category: category || '',
    route: dataPayload.route || '',
  };
  for (const [k, v] of Object.entries(dataPayload)) {
    if (v != null) stringifiedData[k] = typeof v === 'string' ? v : JSON.stringify(v);
  }

  // 7. Dispatch to each device
  for (const device of devices) {
    const isSilent = isCategoryDisabled || isQuiet;

    // APNs configuration
    const apnsPayload: any = {
      headers: {
        'apns-priority': isCategoryDisabled ? '5' : '10',
        'apns-push-type': isCategoryDisabled ? 'background' : 'alert',
      },
      payload: {
        aps: {
          badge: badge,
          // content-available: 1 wakes up app & extensions to update widgets
          'content-available': 1,
          category: category,
        },
      },
    };

    if (!isCategoryDisabled) {
      apnsPayload.payload.aps.alert = {
        title: title || 'LoveLynk',
        body: notifBody || '',
      };
      if (!isQuiet) {
        apnsPayload.payload.aps.sound = 'default';
      }
    }

    const messagePayload: any = {
      message: {
        token: device.fcm_token,
        data: stringifiedData,
        apns: apnsPayload,
      },
    };

    // Include top-level notification for non-silent pushes
    if (!isSilent && title && notifBody) {
      messagePayload.message.notification = {
        title,
        body: notifBody,
      };
    }

    try {
      const fcmRes = await fetch(fcmUrl, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(messagePayload),
      });

      if (fcmRes.ok) {
        const respData = await fcmRes.json();
        results.push({ token: device.fcm_token, success: true, messageId: respData.name });
      } else {
        const errJson = await fcmRes.json();
        const errCode = errJson?.error?.details?.[0]?.errorCode || errJson?.error?.status;

        // If token is invalid or unregistered, schedule for removal
        if (
          errCode === 'UNREGISTERED' ||
          errCode === 'NOT_FOUND' ||
          fcmRes.status === 404 ||
          errJson?.error?.message?.includes('not a valid FCM registration token')
        ) {
          staleTokens.push(device.fcm_token);
        }

        results.push({
          token: device.fcm_token,
          success: false,
          status: fcmRes.status,
          error: errJson,
        });
      }
    } catch (e: any) {
      results.push({ token: device.fcm_token, success: false, error: e.message });
    }
  }

  // 8. Clean up stale tokens
  if (staleTokens.length > 0) {
    await admin.from('push_devices').delete().in('fcm_token', staleTokens);
  }

  return json({
    status: 'dispatched',
    devices_count: devices.length,
    stale_removed: staleTokens.length,
    results,
  });
});
