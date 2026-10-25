// Deno Edge Function: revenuecat-webhook
// Ingests RevenueCat webhook events, updates subscription entitlements,
// records financial transactions, creates in-app notifications, and
// broadcasts Realtime access.changed to both couple partners.
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

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function toIso(ms?: number | null): string | null {
  if (!ms || typeof ms !== 'number') return null;
  return new Date(ms).toISOString();
}

function resolvePlanInterval(productId?: string): 'monthly' | 'yearly' {
  const lower = (productId ?? '').toLowerCase();
  if (lower.includes('year') || lower.includes('annual')) return 'yearly';
  return 'monthly';
}

function resolvePeriodType(periodType?: string): 'trial' | 'intro' | 'normal' {
  const lower = (periodType ?? '').toLowerCase();
  if (lower === 'trial') return 'trial';
  if (lower === 'intro') return 'intro';
  return 'normal';
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405);

  // 1. Authenticate webhook request
  const expectedAuth = Deno.env.get('REVENUECAT_WEBHOOK_AUTH');
  if (expectedAuth) {
    const authHeader = req.headers.get('Authorization') ?? req.headers.get('X-RevenueCat-Auth');
    const token = authHeader?.replace(/^Bearer\s+/i, '').trim();
    if (token !== expectedAuth) {
      console.warn('[RevenueCat] Unauthorized webhook request.');
      return json({ error: 'Unauthorized' }, 401);
    }
  }

  let body: any;
  try {
    body = await req.json();
  } catch (_) {
    return json({ error: 'Invalid JSON body' }, 400);
  }

  const event = body?.event;
  if (!event || !event.id || !event.type) {
    return json({ error: 'Invalid event structure' }, 400);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const admin = createClient(supabaseUrl, secretKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const eventId: string = event.id;
  const eventType: string = event.type;
  const environment: string = (event.environment ?? 'PRODUCTION').toLowerCase() === 'sandbox' ? 'sandbox' : 'production';
  const appUserId: string = event.app_user_id ?? '';

  // 2. Atomic Idempotency Check & Logging: store event in private.revenuecat_events
  try {
    const { data: isNewEvent, error: logErr } = await admin.rpc('log_revenuecat_event', {
      p_event_id: eventId,
      p_app_user_id: appUserId,
      p_type: eventType,
      p_environment: environment,
      p_payload: body,
    });

    if (logErr) {
      console.error(`[RevenueCat] log_revenuecat_event RPC error:`, logErr);
    } else if (isNewEvent === false) {
      console.log(`[RevenueCat] Duplicate event skipped: ${eventId}`);
      return json({ status: 'already_processed', event_id: eventId }, 200);
    }
  } catch (err) {
    console.warn(`[RevenueCat] Checking duplicate event error:`, err);
  }

  // 4. Resolve user UUID
  let resolvedUserId: string | null = null;
  if (UUID_REGEX.test(appUserId)) {
    resolvedUserId = appUserId;
  } else if (Array.isArray(event.aliases)) {
    for (const alias of event.aliases) {
      if (typeof alias === 'string' && UUID_REGEX.test(alias)) {
        resolvedUserId = alias;
        break;
      }
    }
  }

  if (!resolvedUserId) {
    console.warn(`[RevenueCat] Event ${eventId} (${eventType}) has no valid UUID app_user_id: "${appUserId}". Skipping entitlement update.`);
    return json({ status: 'unmapped_user', event_id: eventId }, 200);
  }

  // Verify user exists in public.users
  const { data: userRecord } = await admin
    .from('users')
    .select('id, full_name')
    .eq('id', resolvedUserId)
    .maybeSingle();

  if (!userRecord) {
    console.warn(`[RevenueCat] User ${resolvedUserId} not found in public.users.`);
    return json({ status: 'user_not_found', event_id: eventId }, 200);
  }

  // 5. Update public.subscription_entitlements
  const productId: string = event.product_id ?? 'lovelynk_monthly';
  const plan = resolvePlanInterval(productId);
  const periodType = resolvePeriodType(event.period_type);
  const priceAmount = event.price_in_purchased_currency ?? event.price ?? 0;
  const currency = (event.currency ?? 'GBP').toUpperCase().substring(0, 3);
  const priceUsd = event.price ?? priceAmount;
  const countryCode = (event.country_code ?? 'GB').toUpperCase().substring(0, 2);
  const startedAt = toIso(event.purchased_at_ms) ?? new Date().toISOString();
  const expiresAt = toIso(event.expiration_at_ms);
  const originalTxId = event.original_transaction_id ?? null;

  let entitlementStatus: 'active' | 'in_grace_period' | 'billing_issue' | 'expired' = 'active';
  let willRenew = true;
  let cancelledAt: string | null = null;
  let billingIssueAt: string | null = null;

  if (eventType === 'EXPIRATION') {
    entitlementStatus = 'expired';
    willRenew = false;
  } else if (eventType === 'BILLING_ISSUE') {
    entitlementStatus = 'billing_issue';
    billingIssueAt = new Date().toISOString();
  } else if (eventType === 'CANCELLATION') {
    willRenew = false;
    cancelledAt = new Date().toISOString();
    // If refund / customer support cancel, expire immediately
    if (event.cancel_reason === 'CUSTOMER_SUPPORT') {
      entitlementStatus = 'expired';
    } else {
      // Normal cancellation: remains active until expiration date
      const isStillValid = event.expiration_at_ms ? event.expiration_at_ms > Date.now() : false;
      entitlementStatus = isStillValid ? 'active' : 'expired';
    }
  } else if (eventType === 'UNCANCELLATION') {
    willRenew = true;
    cancelledAt = null;
    entitlementStatus = 'active';
  } else {
    // INITIAL_PURCHASE, RENEWAL, PRODUCT_CHANGE, TRANSFER
    entitlementStatus = 'active';
    willRenew = true;
  }

  // Grace period check
  if (event.grace_period_expiration_at_ms && event.grace_period_expiration_at_ms > Date.now()) {
    entitlementStatus = 'in_grace_period';
  }

  const entitlementPayload: Record<string, any> = {
    user_id: resolvedUserId,
    entitlement_id: 'premium',
    status: entitlementStatus,
    period_type: periodType,
    plan,
    product_id: productId,
    store: 'app_store',
    environment,
    price_amount: priceAmount,
    currency,
    price_usd: priceUsd,
    country_code: countryCode,
    current_period_started_at: startedAt,
    expires_at: expiresAt,
    will_renew: willRenew,
    original_transaction_id: originalTxId,
    updated_at: new Date().toISOString(),
  };

  if (cancelledAt) entitlementPayload.cancelled_at = cancelledAt;
  if (billingIssueAt) entitlementPayload.billing_issue_at = billingIssueAt;

  const { error: upsertErr } = await admin
    .from('subscription_entitlements')
    .upsert(entitlementPayload, { onConflict: 'user_id' });

  if (upsertErr) {
    console.error(`[RevenueCat] Failed to upsert subscription_entitlements:`, upsertErr);
  }

  // 6. Record financial transaction if applicable
  const isRefund = eventType === 'CANCELLATION' && event.cancel_reason === 'CUSTOMER_SUPPORT';
  const isCharge = ['INITIAL_PURCHASE', 'RENEWAL', 'PRODUCT_CHANGE', 'NON_RENEWING_PURCHASE'].includes(eventType);

  if ((isCharge || isRefund) && event.transaction_id) {
    let txType: 'initial_purchase' | 'renewal' | 'product_change' | 'non_renewing_purchase' | 'refund' = 'renewal';
    if (isRefund) {
      txType = 'refund';
    } else if (eventType === 'INITIAL_PURCHASE') {
      txType = 'initial_purchase';
    } else if (eventType === 'PRODUCT_CHANGE') {
      txType = 'product_change';
    } else if (eventType === 'NON_RENEWING_PURCHASE') {
      txType = 'non_renewing_purchase';
    }

    const rawAmount = Number(priceAmount) || 0;
    const amount = isRefund ? -Math.abs(rawAmount) : Math.abs(rawAmount);
    const amountUsd = isRefund ? -Math.abs(Number(priceUsd) || 0) : Math.abs(Number(priceUsd) || 0);

    const commissionPct = event.commission_percentage != null ? Number(event.commission_percentage) : 0.15;
    const taxPct = event.tax_percentage != null ? Number(event.tax_percentage) : null;
    const proceedsUsd = amountUsd * (1 - commissionPct);

    try {
      await admin
        .from('subscription_transactions')
        .insert({
          user_id: resolvedUserId,
          revenuecat_event_id: eventId,
          transaction_id: String(event.transaction_id),
          original_transaction_id: originalTxId,
          type: txType,
          product_id: productId,
          plan,
          period_type: periodType,
          amount,
          currency,
          amount_usd: amountUsd,
          tax_percentage: taxPct,
          commission_percentage: commissionPct,
          proceeds_usd: proceedsUsd,
          country_code: countryCode,
          environment,
          occurred_at: toIso(event.purchased_at_ms) ?? new Date().toISOString(),
        });
      console.log(`[RevenueCat] Recorded transaction ${eventId} (${txType}) for user ${resolvedUserId}`);
    } catch (txErr) {
      console.warn(`[RevenueCat] Transaction recording note:`, txErr);
    }
  }

  // 7. Find active partner for couple-shared subscription
  let partnerUserId: string | null = null;
  try {
    const { data: coupleMember } = await admin
      .from('couple_members')
      .select('couple_id')
      .eq('user_id', resolvedUserId)
      .is('left_at', null)
      .maybeSingle();

    if (coupleMember?.couple_id) {
      const { data: partnerMember } = await admin
        .from('couple_members')
        .select('user_id')
        .eq('couple_id', coupleMember.couple_id)
        .neq('user_id', resolvedUserId)
        .is('left_at', null)
        .maybeSingle();

      if (partnerMember?.user_id) {
        partnerUserId = partnerMember.user_id;
      }
    }
  } catch (partnerLookupErr) {
    console.warn(`[RevenueCat] Partner lookup error:`, partnerLookupErr);
  }

  // 8. Create in-app notifications on critical events
  if (eventType === 'BILLING_ISSUE') {
    await admin.from('notifications').insert({
      user_id: resolvedUserId,
      category: 'subscription',
      title: 'Billing issue with LoveLynk Plus',
      body: 'Please check your Apple App Store payment method to avoid losing couple widget features.',
      data: { event_type: eventType, expires_at: expiresAt },
    });
  } else if (eventType === 'EXPIRATION') {
    await admin.from('notifications').insert({
      user_id: resolvedUserId,
      category: 'subscription',
      title: 'LoveLynk Plus expired',
      body: 'Your subscription has ended. Renew anytime to unlock widgets and customizations.',
      data: { event_type: eventType },
    });

    if (partnerUserId) {
      await admin.from('notifications').insert({
        user_id: partnerUserId,
        category: 'subscription',
        title: 'LoveLynk Plus expired',
        body: 'The shared subscription from your partner has ended.',
        data: { event_type: eventType },
      });
    }
  }

  // 9. Broadcast Realtime access.changed to user and partner
  const broadcastPayload = {
    source: 'revenuecat_webhook',
    event_type: eventType,
    status: entitlementStatus,
    timestamp: new Date().toISOString(),
  };

  try {
    // Broadcast to primary user
    await admin.channel(`user:${resolvedUserId}`).send({
      type: 'broadcast',
      event: 'access.changed',
      payload: broadcastPayload,
    });
    console.log(`[RevenueCat] Broadcast access.changed to user ${resolvedUserId}`);

    // Broadcast to partner user (couple-shared premium)
    if (partnerUserId) {
      await admin.channel(`user:${partnerUserId}`).send({
        type: 'broadcast',
        event: 'access.changed',
        payload: { ...broadcastPayload, shared_via_partner: true },
      });
      console.log(`[RevenueCat] Broadcast access.changed to partner ${partnerUserId}`);
    }
  } catch (broadcastErr) {
    console.error(`[RevenueCat] Broadcast error:`, broadcastErr);
  }

  return json({
    status: 'success',
    event_id: eventId,
    user_id: resolvedUserId,
    partner_id: partnerUserId,
    entitlement_status: entitlementStatus,
  });
});
