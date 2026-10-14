create type public.couple_status as enum ('active', 'archived');

create type public.interaction_kind as enum ('heartbeat', 'kiss', 'emoji');

create type public.notification_category as enum ('relationship', 'account', 'subscription', 'system');

create type public.device_platform as enum ('ios', 'android');

create type public.entitlement_status as enum ('active', 'in_grace_period', 'billing_issue', 'expired');

create type public.store_period_type as enum ('trial', 'intro', 'normal');

create type public.subscription_plan_interval as enum ('monthly', 'yearly');

create type public.subscription_transaction_type as enum (
  'initial_purchase',
  'renewal',
  'product_change',
  'non_renewing_purchase',
  'refund'
);

create type public.broadcast_audience as enum ('all', 'premium', 'free', 'unpaired', 'paired');

create type public.broadcast_status as enum ('draft', 'scheduled', 'sending', 'sent', 'failed', 'cancelled');

create type public.ticket_category as enum ('general', 'bug', 'billing', 'account', 'feedback');

create type public.ticket_status as enum ('open', 'in_progress', 'resolved', 'closed');
