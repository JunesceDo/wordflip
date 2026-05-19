-- WordFlip — Supabase Schema
-- Chạy file này 1 lần trong Supabase SQL Editor

-- ── Decks ──────────────────────────────────────────────
create table if not exists decks (
  id         text primary key,
  name       text not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ── Cards ──────────────────────────────────────────────
create table if not exists cards (
  id         bigserial primary key,
  deck_id    text not null references decks(id) on delete cascade,
  word       text not null,
  meaning    text not null,
  phonetic   text default '',
  example    text default '',
  due        bigint default null,   -- unix ms, null = new card
  interval   int default 0,
  updated_at timestamptz default now()
);

create index if not exists idx_cards_deck on cards(deck_id);
create index if not exists idx_cards_due  on cards(due);

-- ── Study log ──────────────────────────────────────────
create table if not exists study_log (
  date  date primary key,
  count int default 0
);

-- ── Auto-update updated_at ──────────────────────────────
create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

drop trigger if exists touch_decks on decks;
create trigger touch_decks
  before update on decks
  for each row execute function touch_updated_at();

drop trigger if exists touch_cards on cards;
create trigger touch_cards
  before update on cards
  for each row execute function touch_updated_at();

-- ── Row Level Security ─────────────────────────────────
-- Bật RLS nhưng cho phép tất cả (single-user, dùng anon key)
-- Nếu muốn bảo mật hơn thì thêm auth sau

alter table decks     enable row level security;
alter table cards     enable row level security;
alter table study_log enable row level security;

-- Policy: anon có thể đọc/ghi tất cả
create policy "allow all" on decks     for all using (true) with check (true);
create policy "allow all" on cards     for all using (true) with check (true);
create policy "allow all" on study_log for all using (true) with check (true);
