-- ─── Current subscription state (mirror of RevenueCat) ──────────────
-- Written only by the revenuecat-webhook Edge Function. app_user_id = users.id.

create table public.subscription_entitlements (
  user_id                   uuid primary key references public.users (id) on delete cascade,
  entitlement_id            text not null default 'premium',
  status                    public.entitlement_status not null,
  period_type               public.store_period_type not null default 'normal',
  plan                      public.subscription_plan_interval,
  product_id                text not null,
  store                     text not null default 'app_store',
  environment               text not null default 'production'
                              check (environment in ('sandbox', 'production')),
  price_amount              numeric(10, 2) check (price_amount >= 0),
  currency                  char(3) check (currency ~ '^[A-Z]{3}$'),
  price_usd                 numeric(10, 2) check (price_usd >= 0),
  country_code              char(2) check (country_code ~ '^[A-Z]{2}$'),
  started_at                timestamptz,
  current_period_started_at timestamptz,
  expires_at                timestamptz,
  will_renew                boolean not null default true,
  cancelled_at              timestamptz,
  billing_issue_at          timestamptz,
  original_transaction_id   text,
  updated_at                timestamptz not null default now()
);

create index subscription_entitlements_status_expires_at_idx
  on public.subscription_entitlements (status, expires_at);
create index subscription_entitlements_plan_idx on public.subscription_entitlements (plan);

create trigger subscription_entitlements_set_updated_at
  before update on public.subscription_entitlements
  for each row execute function private.set_updated_at();

-- ─── Revenue history (one row per charge or refund) ─────────────────
-- Financial record: kept forever and survives account deletion.

create table public.subscription_transactions (
  id                      uuid primary key default gen_random_uuid(),
  user_id                 uuid references public.users (id) on delete set null,
  revenuecat_event_id     text not null unique,
  transaction_id          text not null,
  original_transaction_id text,
  type                    public.subscription_transaction_type not null,
  product_id              text not null,
  plan                    public.subscription_plan_interval,
  period_type             public.store_period_type not null default 'normal',
  amount                  numeric(10, 2) not null,
  currency                char(3) not null check (currency ~ '^[A-Z]{3}$'),
  amount_usd              numeric(10, 2) not null,
  tax_percentage          numeric(6, 4) check (tax_percentage between 0 and 1),
  commission_percentage   numeric(6, 4) check (commission_percentage between 0 and 1),
  proceeds_usd            numeric(10, 2),
  country_code            char(2) check (country_code ~ '^[A-Z]{2}$'),
  environment             text not null default 'production'
                            check (environment in ('sandbox', 'production')),
  occurred_at             timestamptz not null,
  created_at              timestamptz not null default now(),
  constraint subscription_transactions_refund_sign
    check ((type = 'refund') = (amount < 0) or amount = 0)
);

create index subscription_transactions_occurred_at_idx
  on public.subscription_transactions (occurred_at desc);
create index subscription_transactions_user_occurred_at_idx
  on public.subscription_transactions (user_id, occurred_at desc);

-- ─── Raw webhook log (internal, not exposed) ────────────────────────

create table private.revenuecat_events (
  event_id    text primary key,
  app_user_id text,
  type        text not null,
  environment text,
  payload     jsonb not null,
  received_at timestamptz not null default now()
);

create index revenuecat_events_received_at_idx on private.revenuecat_events (received_at);
alter table private.revenuecat_events enable row level security;
revoke all on table private.revenuecat_events from public, anon, authenticated;

-- ─── Grants and RLS ──────────────────────────────────────────────────

alter table public.subscription_entitlements enable row level security;
alter table public.subscription_transactions enable row level security;

revoke all on table public.subscription_entitlements, public.subscription_transactions
  from anon, authenticated;

grant select on table public.subscription_entitlements to authenticated;
grant select on table public.subscription_transactions to authenticated;

create policy subscription_entitlements_select on public.subscription_entitlements
  for select to authenticated
  using (user_id = (select auth.uid()) or (select private.is_admin()));

create policy subscription_transactions_admin_select on public.subscription_transactions
  for select to authenticated
  using ((select private.is_admin()));

-- ─── Admin views (security invoker: rows visible only to admins) ────
-- Sandbox (TestFlight) purchases are excluded.

create view public.admin_active_subscriptions
with (security_invoker = true) as
select
  e.user_id,
  u.full_name,
  u.email,
  e.plan,
  e.product_id,
  e.status,
  e.period_type,
  (e.period_type = 'trial') as is_trial,
  e.price_amount,
  e.currency,
  e.price_usd,
  e.country_code,
  e.started_at,
  e.current_period_started_at,
  e.expires_at,
  e.will_renew,
  e.cancelled_at,
  e.billing_issue_at,
  e.updated_at
from public.subscription_entitlements e
join public.users u on u.id = e.user_id
where e.environment = 'production'
  and e.status in ('active', 'in_grace_period', 'billing_issue')
  and (e.expires_at is null or e.expires_at > now())
  and (select private.is_admin());

create view public.admin_subscription_summary
with (security_invoker = true) as
select
  e.plan,
  count(*) filter (where e.period_type <> 'trial')           as paying_count,
  count(*) filter (where e.period_type = 'trial')            as trial_count,
  count(*) filter (where not e.will_renew)                   as cancelled_but_active_count,
  coalesce(sum(
    case
      when e.period_type = 'trial' then 0
      when e.plan = 'yearly' then e.price_usd / 12
      else e.price_usd
    end
  ), 0)::numeric(12, 2)                                      as estimated_mrr_usd
from public.subscription_entitlements e
where e.environment = 'production'
  and e.status in ('active', 'in_grace_period', 'billing_issue')
  and (e.expires_at is null or e.expires_at > now())
  and (select private.is_admin())
group by e.plan;

create view public.admin_revenue_daily
with (security_invoker = true) as
select
  (t.occurred_at at time zone 'UTC')::date                   as day,
  t.currency,
  count(*) filter (where t.type = 'initial_purchase')        as purchases,
  count(*) filter (where t.type = 'renewal')                 as renewals,
  count(*) filter (where t.type = 'refund')                  as refunds,
  sum(t.amount)::numeric(12, 2)                              as gross_amount,
  sum(t.amount_usd)::numeric(12, 2)                          as gross_usd,
  sum(t.proceeds_usd)::numeric(12, 2)                        as proceeds_usd
from public.subscription_transactions t
where t.environment = 'production'
group by 1, 2;

revoke all on table
  public.admin_active_subscriptions,
  public.admin_subscription_summary,
  public.admin_revenue_daily
from anon, authenticated;

grant select on table
  public.admin_active_subscriptions,
  public.admin_subscription_summary,
  public.admin_revenue_daily
to authenticated;
