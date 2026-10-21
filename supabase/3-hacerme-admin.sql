-- Once de Oro · hacerte administrador
-- 1) Regístrate primero en la web con tu email.
-- 2) Cambia el email de abajo por el tuyo y ejecútalo en Supabase → SQL Editor.
insert into public.admins(user_id)
select id from auth.users where email = 'TU_EMAIL@ejemplo.com'
on conflict do nothing;

-- Comprueba que ha funcionado (debe salir tu email):
select u.email from public.admins a join auth.users u on u.id = a.user_id;
