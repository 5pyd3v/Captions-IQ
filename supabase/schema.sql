-- Caption IQ — Supabase schema
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run).
--
-- Auth model: anonymous sign-in. The app calls
-- `supabase.auth.signInAnonymously()` on first launch, which gives every
-- install a stable auth.uid() with no login screen. Row Level Security
-- below ensures each device can only ever see its own history.
--
-- Note: enable "Anonymous Sign-Ins" under
-- Authentication → Providers → Anonymous in the Supabase dashboard,
-- otherwise signInAnonymously() will be rejected by the server.

create extension if not exists "pgcrypto";

create table if not exists public.scan_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  title text not null,
  image_count integer not null default 0,
  raw_text text not null default '',
  summary_en text not null default '',
  summary_roman_ur text not null default ''
);

create index if not exists scan_sessions_user_id_created_at_idx
  on public.scan_sessions (user_id, created_at desc);

alter table public.scan_sessions enable row level security;

drop policy if exists "scan_sessions_select_own" on public.scan_sessions;
create policy "scan_sessions_select_own"
  on public.scan_sessions for select
  using (auth.uid() = user_id);

drop policy if exists "scan_sessions_insert_own" on public.scan_sessions;
create policy "scan_sessions_insert_own"
  on public.scan_sessions for insert
  with check (auth.uid() = user_id);

drop policy if exists "scan_sessions_update_own" on public.scan_sessions;
create policy "scan_sessions_update_own"
  on public.scan_sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "scan_sessions_delete_own" on public.scan_sessions;
create policy "scan_sessions_delete_own"
  on public.scan_sessions for delete
  using (auth.uid() = user_id);
