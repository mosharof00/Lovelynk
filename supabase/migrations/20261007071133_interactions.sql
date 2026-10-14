-- Heartbeat / kiss / emoji events. Detailed rows are kept 90 days (cron phase).
create table public.interactions (
  id           bigint generated always as identity primary key,
  couple_id    uuid not null references public.couples (id) on delete cascade,
  sender_id    uuid not null references public.users (id) on delete cascade,
  recipient_id uuid not null references public.users (id) on delete cascade,
  kind         public.interaction_kind not null,
  count        smallint not null default 1 check (count between 1 and 100),
  emoji        text check (char_length(emoji) <= 16),
  created_at   timestamptz not null default now(),
  constraint interactions_emoji_matches_kind check ((kind = 'emoji') = (emoji is not null)),
  constraint interactions_not_self check (sender_id <> recipient_id)
);

create index interactions_couple_created_at_idx on public.interactions (couple_id, created_at desc);
create index interactions_recipient_created_at_idx on public.interactions (recipient_id, created_at desc);
create index interactions_sender_id_idx on public.interactions (sender_id);
-- Append-only by time: BRIN keeps the purge and daily-metrics scans cheap.
create index interactions_created_at_brin_idx on public.interactions using brin (created_at);

-- Running totals, kept forever. Drives widget counts and summary headers.
create table public.interaction_totals (
  couple_id     uuid not null references public.couples (id) on delete cascade,
  sender_id     uuid not null references public.users (id) on delete cascade,
  kind          public.interaction_kind not null,
  total         bigint not null default 0 check (total >= 0),
  recent_emojis text[] not null default '{}' check (cardinality(recent_emojis) <= 9),
  last_sent_at  timestamptz,
  primary key (couple_id, sender_id, kind)
);

create index interaction_totals_sender_id_idx on public.interaction_totals (sender_id);

alter table public.interactions enable row level security;
alter table public.interaction_totals enable row level security;

revoke all on table public.interactions, public.interaction_totals from anon, authenticated;

grant select on table public.interactions to authenticated;
grant select on table public.interaction_totals to authenticated;

-- Writes happen only through send_interaction() (functions phase).
-- Admins see totals only, never individual events.
create policy interactions_select on public.interactions
  for select to authenticated
  using (couple_id = (select private.current_couple_id()));

create policy interaction_totals_select on public.interaction_totals
  for select to authenticated
  using (couple_id = (select private.current_couple_id()) or (select private.is_admin()));
