-- One row per UTC day, written by compute_daily_metrics() (cron phase).
-- Dashboard charts read this instead of scanning large tables.
create table public.daily_metrics (
  day                    date primary key,
  total_users            int not null default 0,
  new_users              int not null default 0,
  active_users           int not null default 0,
  deleted_users          int not null default 0,
  total_active_couples   int not null default 0,
  new_couples            int not null default 0,
  disconnected_couples   int not null default 0,
  premium_users          int not null default 0,
  trial_users            int not null default 0,
  premium_couples        int not null default 0,
  heartbeats             int not null default 0,
  kisses                 int not null default 0,
  emojis                 int not null default 0,
  support_tickets_opened int not null default 0,
  new_subscriptions      int not null default 0,
  renewals               int not null default 0,
  cancellations          int not null default 0,
  revenue_gross_usd      numeric(12, 2) not null default 0,
  revenue_proceeds_usd   numeric(12, 2) not null default 0,
  refunds_usd            numeric(12, 2) not null default 0,
  computed_at            timestamptz not null default now()
);

alter table public.daily_metrics enable row level security;
revoke all on table public.daily_metrics from anon, authenticated;
grant select on table public.daily_metrics to authenticated;

create policy daily_metrics_admin_select on public.daily_metrics
  for select to authenticated
  using ((select private.is_admin()));

-- Fixed-window counters used by rate-limited RPCs (functions phase).
create table private.rate_limits (
  user_id      uuid not null references public.users (id) on delete cascade,
  action       text not null,
  window_start timestamptz not null,
  hits         int not null default 0,
  primary key (user_id, action, window_start)
);

create index rate_limits_window_start_idx on private.rate_limits (window_start);
alter table private.rate_limits enable row level security;
revoke all on table private.rate_limits from public, anon, authenticated;
