-- Evolution · database schema. Paste into Supabase SQL Editor and Run.

create table if not exists public.user_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null,
  updated_at timestamptz not null default now()
);

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  stats jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.crews (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  owner uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.crew_members (
  crew_id uuid not null references public.crews(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (crew_id, user_id)
);

create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  crew_id uuid not null references public.crews(id) on delete cascade,
  title text not null,
  metric text not null,
  start_date date not null,
  end_date date not null,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.user_state   enable row level security;
alter table public.profiles     enable row level security;
alter table public.crews        enable row level security;
alter table public.crew_members enable row level security;
alter table public.challenges   enable row level security;

-- user_state: only you
drop policy if exists "own state" on public.user_state;
create policy "own state" on public.user_state for all to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- profiles: anyone signed in can read (crew pages), only you can write yours
drop policy if exists "read profiles" on public.profiles;
create policy "read profiles" on public.profiles for select to authenticated using (true);
drop policy if exists "write own profile" on public.profiles;
create policy "write own profile" on public.profiles for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "update own profile" on public.profiles;
create policy "update own profile" on public.profiles for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- crews: signed-in users can look one up by code and create their own
drop policy if exists "read crews" on public.crews;
create policy "read crews" on public.crews for select to authenticated using (true);
drop policy if exists "create crew" on public.crews;
create policy "create crew" on public.crews for insert to authenticated with check (auth.uid() = owner);
drop policy if exists "owner edits crew" on public.crews;
create policy "owner edits crew" on public.crews for update to authenticated using (auth.uid() = owner);
drop policy if exists "owner deletes crew" on public.crews;
create policy "owner deletes crew" on public.crews for delete to authenticated using (auth.uid() = owner);

-- crew_members: read all (to list a crew), join/leave yourself
drop policy if exists "read members" on public.crew_members;
create policy "read members" on public.crew_members for select to authenticated using (true);
drop policy if exists "join crew" on public.crew_members;
create policy "join crew" on public.crew_members for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "leave crew" on public.crew_members;
create policy "leave crew" on public.crew_members for delete to authenticated using (auth.uid() = user_id);

-- challenges: read all, create if you're in that crew
drop policy if exists "read challenges" on public.challenges;
create policy "read challenges" on public.challenges for select to authenticated using (true);
drop policy if exists "member creates challenge" on public.challenges;
create policy "member creates challenge" on public.challenges for insert to authenticated
  with check (auth.uid() = created_by and exists (select 1 from public.crew_members m where m.crew_id = challenges.crew_id and m.user_id = auth.uid()));
drop policy if exists "creator deletes challenge" on public.challenges;
create policy "creator deletes challenge" on public.challenges for delete to authenticated using (auth.uid() = created_by);
