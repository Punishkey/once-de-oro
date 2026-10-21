# Once de Oro en producción

La web está en la raíz del repositorio. Usa Supabase para las cuentas y los datos.

## 1. Preparar Supabase (una sola vez)
Entra en tu proyecto de https://supabase.com y abre **SQL Editor → New query**. Ejecuta estos archivos en orden, pegando el contenido de cada uno y pulsando **Run**:
1. `supabase/1-esquema.sql` crea las tablas y los permisos. Todo el mundo puede ver la liga, cada usuario solo puede tocar su equipo y solo tú administras.
2. `supabase/2-datos-liga.sql` carga la temporada 2026-27: 20 clubes, 529 jugadores, el calendario y la clasificación tras la jornada 9.

Después, en **Authentication → URL Configuration**:
- En **Site URL** pon la dirección de la web, por ejemplo `https://punishkey.github.io/once-de-oro/`.
- Añade esa misma dirección en **Redirect URLs**.

Así funcionan los enlaces de los emails de confirmación y de recuperar contraseña.

## 2. Hacerte administrador
1. Abre la web y regístrate con tu email. Confirma la cuenta desde el correo que te llega.
2. Abre `supabase/3-hacerme-admin.sql`, cambia `TU_EMAIL@ejemplo.com` por tu email y ejecútalo en el SQL Editor.
3. Recarga la web. Verás la etiqueta "Administrador" y la pestaña Admin.

## 3. Invitar a tus amigos
Pásales la dirección. Cada uno se registra con su email y contraseña y crea su equipo. En el móvil Android, desde Chrome: menú ⋮ → **Instalar aplicación** (o "Añadir a pantalla de inicio").

## Resultados de cada semana
Los martes preparo los resultados reales de la jornada. En Admin → **Pegar resultados cargados** pegas el texto que te paso, lo revisas y pulsas **Cerrar jornada**. También puedes meter los resultados a mano en el mismo formulario.

## Notas
- La clave de `config.js` es la pública ("anon"). No pongas nunca en la web la contraseña de la base de datos ni la clave `service_role`.
- El correo de Supabase gratuito envía pocos emails por hora. Si os registráis muchos a la vez y no llega la confirmación, espera un rato. También puedes desactivar la confirmación en Authentication → Sign In / Providers → Email → "Confirm email".
