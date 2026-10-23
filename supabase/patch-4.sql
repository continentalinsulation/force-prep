-- Evolution · patch 4: likes and comments on crew feed events. Paste into SQL Editor and Run.
create table if not exists public.event_likes (
  event_id bigint not null references public.events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);
alter table public.event_likes enable row level security;
drop policy if exists "read likes" on public.event_likes;
create policy "read likes" on public.event_likes for select to authenticated using (true);
drop policy if exists "like" on public.event_likes;
create policy "like" on public.event_likes for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "unlike" on public.event_likes;
create policy "unlike" on public.event_likes for delete to authenticated using (auth.uid() = user_id);

create table if not exists public.event_comments (
  id bigint generated always as identity primary key,
  event_id bigint not null references public.events(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  text text not null check (char_length(text) between 1 and 300),
  created_at timestamptz not null default now()
);
create index if not exists event_comments_event_idx on public.event_comments (event_id, created_at);
alter table public.event_comments enable row level security;
drop policy if exists "read comments" on public.event_comments;
create policy "read comments" on public.event_comments for select to authenticated using (true);
drop policy if exists "comment" on public.event_comments;
create policy "comment" on public.event_comments for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "delete own comment" on public.event_comments;
create policy "delete own comment" on public.event_comments for delete to authenticated using (auth.uid() = user_id);
