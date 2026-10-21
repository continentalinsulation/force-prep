-- Evolution · patch 2: usernames, friends, activity feed. Paste into SQL Editor and Run.

alter table public.profiles add column if not exists handle text;
create unique index if not exists profiles_handle_idx on public.profiles (lower(handle));

create table if not exists public.friends (
  user_id uuid not null references auth.users(id) on delete cascade,
  friend_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, friend_id)
);
alter table public.friends enable row level security;
drop policy if exists "read friends" on public.friends;
create policy "read friends" on public.friends for select to authenticated using (true);
drop policy if exists "add friend" on public.friends;
create policy "add friend" on public.friends for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "remove friend" on public.friends;
create policy "remove friend" on public.friends for delete to authenticated using (auth.uid() = user_id);

create table if not exists public.events (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null,
  text text not null,
  created_at timestamptz not null default now()
);
create index if not exists events_user_time_idx on public.events (user_id, created_at desc);
alter table public.events enable row level security;
drop policy if exists "read events" on public.events;
create policy "read events" on public.events for select to authenticated using (true);
drop policy if exists "write own events" on public.events;
create policy "write own events" on public.events for insert to authenticated with check (auth.uid() = user_id);

-- let supabase-js join friends → profiles by friend_id
alter table public.friends drop constraint if exists friends_friend_profile_fk;
alter table public.friends add constraint friends_friend_profile_fk foreign key (friend_id) references public.profiles(user_id) on delete cascade;
alter table public.crew_members drop constraint if exists crew_members_profile_fk;
alter table public.crew_members add constraint crew_members_profile_fk foreign key (user_id) references public.profiles(user_id) on delete cascade;
alter table public.events drop constraint if exists events_profile_fk;
alter table public.events add constraint events_profile_fk foreign key (user_id) references public.profiles(user_id) on delete cascade;
