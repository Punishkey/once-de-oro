# Once de Oro: manager de fútbol entre amigos

Cada amigo dirige un club de LaLiga 2026-27 (nadie puede repetir) y la máquina lleva los demás. Eliges alineación, formación y táctica, fichas y vendes, y el administrador juega las jornadas.

La web está en la raíz del repositorio. Usa Supabase para las cuentas y los datos.

## 1. Preparar Supabase (una sola vez)
Entra en tu proyecto de https://supabase.com y abre **SQL Editor → New query**. Ejecuta estos archivos en orden, pegando el contenido de cada uno y pulsando **Run**:
1. `supabase/1-esquema.sql` crea las tablas y los permisos. Todo el mundo puede ver la liga, cada usuario solo puede tocar su equipo y solo tú administras.
2. `supabase/2-datos-liga.sql` carga los datos de la versión anterior (fantasy). Si empiezas de cero, puedes saltártelo.
3. `supabase/4-manager.sql` convierte la liga en manager: un club por mánager y una temporada nueva desde la jornada 1. Borra los equipos de fantasy y las jornadas jugadas, pero no las cuentas.

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

## Cómo se juega
- **Mi club**: elige un club libre. Pon la táctica (defensiva, equilibrada u ofensiva), la formación y el once. Si un titular está lesionado o sancionado, juega el mejor disponible.
- **Mercado**: haz ofertas por jugadores de clubes sin mánager (cuestan el 110% de su valor) o pon a la venta a los tuyos (cobras el 90%). Todo se resuelve al jugarse la jornada.
- **Partidos**: cuentan el nivel, la forma, la táctica y jugar en casa. Hay tarjetas, sanciones y lesiones, y los jugadores suben o bajan de nivel según sus notas.
- **Dinero**: taquilla en casa, 1 M por victoria y 0,4 M por empate, y cada jornada se pagan sueldos.
- **Admin**: juega las jornadas de una en una o de cinco en cinco, deshace la última y empieza temporadas nuevas.

## Notas
- La clave de `config.js` es la pública ("anon"). No pongas nunca en la web la contraseña de la base de datos ni la clave `service_role`.
- El correo de Supabase gratuito envía pocos emails por hora. Si os registráis muchos a la vez y no llega la confirmación, espera un rato. También puedes desactivar la confirmación en Authentication → Sign In / Providers → Email → "Confirm email".
