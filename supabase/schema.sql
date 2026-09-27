-- Feu de Camp : schéma Supabase
-- À coller dans le SQL Editor du projet Supabase, puis « Run ».

-- Une fiche par joueur connecté (user_id), plus des fiches « manuelles »
-- créées par un admin pour les amis sans compte Discord.
create table if not exists public.roster (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid unique references auth.users(id) on delete cascade,
  manual       boolean not null default false,
  name         text check (char_length(name) between 1 and 40),
  display_name text check (char_length(display_name) <= 80),
  avatar_url   text check (avatar_url like 'https://%'),
  race         text not null check (race in ('human','dwarf','nightelf','gnome','skyborne_a','orc','undead','tauren','troll','skyborne_h')),
  cls          text not null check (cls in ('warrior','paladin','hunter','rogue','priest','shaman','mage','warlock','druid')),
  role         text check (role in ('tank','heal','dps')),
  prof         text[] not null default '{}' check (cardinality(prof) <= 2),
  sec          text[] not null default '{}' check (cardinality(sec) <= 3),
  char_name    text check (char_length(char_name) <= 24),
  updated_at   timestamptz not null default now(),
  check ((manual and user_id is null and name is not null) or (not manual and user_id is not null))
);

-- Les admins peuvent gérer les fiches manuelles.
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

alter table public.roster enable row level security;
alter table public.admins enable row level security;

-- Lecture : réservée aux personnes connectées.
drop policy if exists "roster_lecture" on public.roster;
create policy "roster_lecture" on public.roster
  for select to authenticated using (true);

-- Chacun gère sa propre fiche, et seulement la sienne.
drop policy if exists "roster_ma_fiche_creer" on public.roster;
create policy "roster_ma_fiche_creer" on public.roster
  for insert to authenticated with check (user_id = auth.uid() and not manual);

drop policy if exists "roster_ma_fiche_modifier" on public.roster;
create policy "roster_ma_fiche_modifier" on public.roster
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and not manual);

drop policy if exists "roster_ma_fiche_retirer" on public.roster;
create policy "roster_ma_fiche_retirer" on public.roster
  for delete to authenticated using (user_id = auth.uid());

-- Les admins gèrent les fiches manuelles.
drop policy if exists "roster_admin_manuelles" on public.roster;
create policy "roster_admin_manuelles" on public.roster
  for all to authenticated using (public.is_admin() and manual) with check (public.is_admin() and manual);

-- Chacun peut savoir s'il est admin.
drop policy if exists "admins_se_voir" on public.admins;
create policy "admins_se_voir" on public.admins
  for select to authenticated using (user_id = auth.uid());

-- Mises à jour en temps réel dans la page.
do $$ begin
  alter publication supabase_realtime add table public.roster;
exception when duplicate_object then null;
end $$;
