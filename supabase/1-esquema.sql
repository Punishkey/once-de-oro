-- Once de Oro · esquema de base de datos para Supabase
-- Pégalo entero en Supabase → SQL Editor → New query → Run. Se puede ejecutar más de una vez.

create extension if not exists pgcrypto;

-- Administradores (solo tú)
create table if not exists public.admins(user_id uuid primary key references auth.users on delete cascade);
alter table public.admins enable row level security;
drop policy if exists "admins: ver el propio" on public.admins;
create policy "admins: ver el propio" on public.admins for select using (user_id = auth.uid());

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists(select 1 from public.admins where user_id = auth.uid()) $$;
grant execute on function public.is_admin() to anon, authenticated;

-- Liga: clubes, jugadores, calendario y ajustes (una sola fila)
create table if not exists public.liga(
  id int primary key default 1 check (id = 1),
  data jsonb not null,
  updated_at timestamptz not null default now());
-- Jornadas cerradas: puntos, goles y cambios de precio y nivel
create table if not exists public.jornadas(round int primary key, data jsonb not null, updated_at timestamptz not null default now());
-- Resultados reales pendientes de revisar por el admin
create table if not exists public.reales(round int primary key, data jsonb not null, updated_at timestamptz not null default now());
-- Equipo de cada usuario
create table if not exists public.managers(
  user_id uuid primary key default auth.uid() references auth.users on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now());

alter table public.liga enable row level security;
alter table public.jornadas enable row level security;
alter table public.reales enable row level security;
alter table public.managers enable row level security;

-- Todo el mundo puede ver la liga, las jornadas y los equipos; solo el admin los cambia.
do $$
declare t text;
begin
  foreach t in array array['liga','jornadas'] loop
    execute format('drop policy if exists "leer" on public.%I', t);
    execute format('create policy "leer" on public.%I for select using (true)', t);
    execute format('drop policy if exists "admin escribe" on public.%I', t);
    execute format('create policy "admin escribe" on public.%I for all using (public.is_admin()) with check (public.is_admin())', t);
  end loop;
end $$;

drop policy if exists "admin lee" on public.reales;
create policy "admin lee" on public.reales for select using (public.is_admin());
drop policy if exists "admin escribe" on public.reales;
create policy "admin escribe" on public.reales for all using (public.is_admin()) with check (public.is_admin());

-- Cada usuario solo crea y cambia su propio equipo; el admin puede borrar cualquiera.
drop policy if exists "leer" on public.managers;
create policy "leer" on public.managers for select using (true);
drop policy if exists "crear el propio" on public.managers;
create policy "crear el propio" on public.managers for insert with check (user_id = auth.uid());
drop policy if exists "cambiar el propio" on public.managers;
create policy "cambiar el propio" on public.managers for update using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "borrar" on public.managers;
create policy "borrar" on public.managers for delete using (user_id = auth.uid() or public.is_admin());

-- Carga automática de resultados reales con una clave propia (no hace falta iniciar sesión).
create table if not exists public.secretos(clave text primary key, valor text not null);
alter table public.secretos enable row level security;  -- sin políticas: nadie la lee desde la web
insert into public.secretos values ('carga', encode(gen_random_bytes(24), 'hex')) on conflict (clave) do nothing;

create or replace function public.cargar_reales(p_clave text, p_round int, p_data jsonb) returns void
language plpgsql security definer set search_path = public as $$
begin
  if p_clave is null or p_clave <> (select valor from public.secretos where clave = 'carga') then
    raise exception 'clave incorrecta';
  end if;
  insert into public.reales(round, data, updated_at) values (p_round, p_data, now())
  on conflict (round) do update set data = excluded.data, updated_at = now();
end $$;
revoke all on function public.cargar_reales(text, int, jsonb) from public;
grant execute on function public.cargar_reales(text, int, jsonb) to anon, authenticated;

-- Cambios en directo
do $$
declare t text;
begin
  foreach t in array array['liga','jornadas','reales','managers'] loop
    if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
