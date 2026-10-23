-- Evolution · patch 5: trainer mode (coach ↔ client links, assignments). Paste into SQL Editor and Run.
create table if not exists public.coach_links (
  coach_id uuid not null references auth.users(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','active')),
  created_at timestamptz not null default now(),
  primary key (coach_id, client_id)
);
alter table public.coach_links enable row level security;
drop policy if exists "see own links" on public.coach_links;
create policy "see own links" on public.coach_links for select to authenticated using (auth.uid() = coach_id or auth.uid() = client_id);
drop policy if exists "coach requests" on public.coach_links;
create policy "coach requests" on public.coach_links for insert to authenticated with check (auth.uid() = coach_id);
drop policy if exists "client accepts" on public.coach_links;
create policy "client accepts" on public.coach_links for update to authenticated using (auth.uid() = client_id) with check (auth.uid() = client_id);
drop policy if exists "either ends it" on public.coach_links;
create policy "either ends it" on public.coach_links for delete to authenticated using (auth.uid() = coach_id or auth.uid() = client_id);

create table if not exists public.coach_assignments (
  id bigint generated always as identity primary key,
  coach_id uuid not null references auth.users(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  goal text not null,
  days int not null default 5,
  mins int not null default 30,
  note text,
  applied boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.coach_assignments enable row level security;
drop policy if exists "see own assignments" on public.coach_assignments;
create policy "see own assignments" on public.coach_assignments for select to authenticated using (auth.uid() = coach_id or auth.uid() = client_id);
drop policy if exists "coach assigns" on public.coach_assignments;
create policy "coach assigns" on public.coach_assignments for insert to authenticated with check (auth.uid() = coach_id and exists (select 1 from public.coach_links l where l.coach_id = auth.uid() and l.client_id = client_id and l.status = 'active'));
drop policy if exists "client marks applied" on public.coach_assignments;
create policy "client marks applied" on public.coach_assignments for update to authenticated using (auth.uid() = client_id) with check (auth.uid() = client_id);

-- A coach can read an active client's state (read only).
drop policy if exists "coach reads client state" on public.user_state;
create policy "coach reads client state" on public.user_state for select to authenticated
  using (exists (select 1 from public.coach_links l where l.coach_id = auth.uid() and l.client_id = user_state.user_id and l.status = 'active'));
