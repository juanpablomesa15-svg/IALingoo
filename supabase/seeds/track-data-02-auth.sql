-- =============================================
-- IALingoo — Track "Data y bases" / Módulo "Auth y seguridad"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'data';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Auth y seguridad no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Auth: login, signup y magic links',
$md$## Auth = quién sos

Authentication (autenticación) es el proceso de verificar la identidad del usuario. Es una de las cosas más críticas (si falla, cualquiera accede a cualquier cosa) y más aburridas de construir desde cero.

Supabase Auth la resuelve por vos con UI y backend listos.

### Métodos de autenticación 2026

| Método | UX | Seguridad | Complejidad |
|---|---|---|---|
| **Email + password** | Familiar pero fricción | Media (dependiente de password del usuario) | Baja |
| **Magic link** | Súper fluido | Alta (email = ownership) | Baja |
| **OAuth** (Google, Apple, GitHub) | 1-click, familiar | Alta | Baja |
| **Passkeys** | El futuro, sin password | Muy alta | Media |
| **Phone OTP** | Ideal mobile LATAM | Alta | Media |
| **SAML/SSO** | Enterprise | Alta | Alta |

**Recomendación 2026 para apps nuevas**:
- B2C (consumidor): **Magic link + Google OAuth**
- B2B (empresas): **Email+password + SSO (SAML)** para enterprise
- Mobile LATAM: **Phone OTP** (SMS) como primer método

### Por qué magic link gana en 2026

Magic link = mandás email al usuario con un link único. Hace click → logueado.

Ventajas:
- Sin password que olvidar / hackear
- Validás email automáticamente
- UX buenísima (1 campo)
- El email es la "source of truth" de identidad

Desventajas:
- Depende de que llegue el mail (spam, delays)
- Desktop → mobile puede ser incómodo si lo abrís en otro dispositivo

### Setup en Supabase (toma 5 minutos)

1. Dashboard → Auth → Providers
2. **Email**: prendido por default. Elegí si usar password, magic link, o ambos.
3. **Google OAuth**:
   - En Google Cloud Console, crear OAuth client ID
   - Pegás Client ID + Secret en Supabase
   - Guardás
4. Redirect URLs: `https://tudominio.com/auth/callback` y `localhost:3000/auth/callback` para dev

### Código cliente (Next.js)

**Signup con email+password**:

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'juan@example.com',
  password: 'super-secreto-largo',
  options: {
    data: { nombre: 'Juan' } // metadata extra
  }
});
```

**Login con password**:

```javascript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'juan@example.com',
  password: 'super-secreto-largo'
});
```

**Magic link**:

```javascript
const { error } = await supabase.auth.signInWithOtp({
  email: 'juan@example.com',
  options: {
    emailRedirectTo: 'https://tudominio.com/auth/callback'
  }
});
```

**Google OAuth**:

```javascript
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: 'https://tudominio.com/auth/callback' }
});
```

**Logout**:

```javascript
await supabase.auth.signOut();
```

**Verificar sesión actual**:

```javascript
const { data: { user } } = await supabase.auth.getUser();
if (user) {
  console.log('Logueado:', user.email);
} else {
  console.log('No hay sesión');
}
```

### Escuchar cambios de auth

```javascript
const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    // Redirigir al dashboard
  } else if (event === 'SIGNED_OUT') {
    // Redirigir a login
  }
});
```

### Tabla auth.users: qué guarda Supabase

Cada vez que alguien se registra, Supabase crea una fila en `auth.users` con:

- `id` (UUID)
- `email`
- `phone`
- `encrypted_password` (hash, no texto plano)
- `email_confirmed_at`
- `last_sign_in_at`
- `raw_user_meta_data` (JSONB con metadata custom)
- `created_at`

**Importante**: **no toques `auth.users` directamente**. Creá una tabla `profiles` con foreign key al `auth.users.id` y guardá ahí nombre, avatar, bio, etc. Es la convención 2026.

### Tabla profiles: el patrón estándar

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre TEXT,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: cuando se crea auth.users, crear profile automáticamente
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $body$
BEGIN
  INSERT INTO profiles (id, nombre)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'nombre');
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

Ahora cada vez que alguien se registra, se crea automáticamente su profile.

### Verificación de email

Por default, Supabase exige confirmación de email antes de dejar loguear. El usuario recibe un mail con link de confirmación.

Para desarrollo podés desactivarlo (Auth → Settings → "Confirm email" OFF). Pero en producción, **dejalo activado** para evitar cuentas falsas.

### Templates de email

Supabase te deja customizar los templates de email (confirmación, reset password, magic link, invite):

1. Auth → Email Templates
2. Editás HTML con placeholders `{{ .ConfirmationURL }}`

**Tip 2026**: los templates default son feos. Invertí 30 min en diseñarlos con tu marca — impacta la tasa de confirmación.

### Email provider: cuándo migrar

Supabase manda emails gratis hasta cierto volumen. Si escalás, configurás tu propio SMTP (Sendgrid, Resend, Postmark):

Auth → SMTP Settings → pegás credenciales.

Recomendación 2026: [Resend](https://resend.com) — excelente UX developer, 100 emails/día gratis, $20/mes por 50k.

### Multi-factor auth (2FA)

Para apps serias, activá 2FA con TOTP (Time-based One-Time Password — los códigos de 6 dígitos de Google Authenticator, Authy, 1Password):

```javascript
// El usuario enrola
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: 'totp',
  friendlyName: 'Mi iPhone'
});
// data.totp.qr_code → mostrarle QR al usuario
// Escaneó con su app → ingresa código

await supabase.auth.mfa.challengeAndVerify({
  factorId: data.id,
  code: '123456'
});
```

En el próximo login, además del password pide código TOTP.
$md$,
    0, 50,
$md$**Activá auth en tu proyecto Supabase.**

1. Dashboard → Auth → Providers → verificá que Email está ON con password + magic link
2. Creá página simple HTML/Next.js con 2 botones: "Sign up" y "Magic link"
3. Implementá signup con email+password
4. Implementá login con magic link
5. Después de loguearte, mostrá el email del usuario en pantalla
6. Screenshot del flujo completo funcionando$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Por qué magic link es recomendado para B2C en 2026?',
   '["Es más caro", "Sin password que olvidar, valida email automáticamente, UX de 1 campo", "Es obsoleto", "Solo funciona en Gmail"]'::jsonb,
   1, 0, 'Magic link = email como identidad, sin passwords, UX buenísima. Pega bien en consumer.'),
  (v_lesson_id, '¿Dónde guardás datos extra del usuario (nombre, avatar, bio)?',
   '["En auth.users directamente", "En una tabla profiles con foreign key al auth.users.id", "En localStorage", "No se pueden guardar"]'::jsonb,
   1, 1, 'Convención 2026: auth.users es de Supabase (no tocar). Tu tabla profiles extiende con campos propios.'),
  (v_lesson_id, '¿Qué hace el trigger `on_auth_user_created`?',
   '["Borra cuentas viejas", "Crea automáticamente un profile cada vez que se registra un usuario en auth.users", "Envía emails", "Valida contraseñas"]'::jsonb,
   1, 2, 'Trigger auto-crea profile. Sin él, tendrías que crear el profile manualmente en cada signup.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Row Level Security (RLS): el superpoder de Supabase',
$md$## La pregunta que te salva la vida: "¿quién puede leer esto?"

RLS (Row Level Security — seguridad a nivel fila) es una feature de PostgreSQL que Supabase aprovecha genialmente. Define **qué filas puede leer/modificar cada usuario** directamente en la base de datos.

### Por qué es crítico

Sin RLS, tu anon key deja hacer SELECT de cualquier tabla. Si alguien inspecciona tu frontend y encuentra la key, puede leer toda tu base.

Con RLS:
- Juan solo ve sus propios pedidos
- María solo edita sus propios posts
- Los admins ven todo

**Regla 2026 inquebrantable**: activá RLS en TODAS las tablas antes de ir a producción. Las que son realmente públicas usan policy `SELECT TRUE`.

### Activar RLS en una tabla

```sql
ALTER TABLE pedidos ENABLE ROW LEVEL SECURITY;
```

**Efecto**: cuando RLS está ON y no hay policies, **nadie puede leer nada** (excepto service_role). Es deny-by-default.

### Definir policies

Una **policy** es una regla que dice "quién puede hacer qué bajo qué condiciones".

Ejemplo: "cada usuario ve solo sus propios pedidos":

```sql
CREATE POLICY "Users see own orders"
ON pedidos
FOR SELECT
USING (auth.uid() = usuario_id);
```

Traducción:
- `FOR SELECT`: aplica cuando leen
- `USING`: condición que debe cumplirse
- `auth.uid()`: función de Supabase que devuelve el UUID del usuario logueado
- `usuario_id`: columna de tu tabla con el owner del pedido

### Los 4 tipos de operaciones

- **FOR SELECT**: leer
- **FOR INSERT**: crear
- **FOR UPDATE**: modificar
- **FOR DELETE**: borrar

Podés crear una policy por operación, o `FOR ALL` para todas.

### Ejemplos clásicos

**1. "Cada uno ve solo lo suyo"**:

```sql
CREATE POLICY "users see own"
ON pedidos FOR SELECT
USING (auth.uid() = usuario_id);
```

**2. "Todos ven, solo dueño edita"** (ej. posts de blog):

```sql
CREATE POLICY "public read"
ON posts FOR SELECT
USING (true);

CREATE POLICY "owner edit"
ON posts FOR UPDATE
USING (auth.uid() = autor_id)
WITH CHECK (auth.uid() = autor_id);
```

**`WITH CHECK`**: condición que se aplica a los datos **nuevos** (post-modificación). Sin esto, un usuario podría hacer update cambiando autor_id a otra persona.

**3. "Solo admins pueden borrar"**:

```sql
CREATE POLICY "admin delete"
ON pedidos FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND rol = 'admin'
  )
);
```

**4. "Insert solo si auth.uid() coincide con usuario_id"**:

```sql
CREATE POLICY "insert own"
ON pedidos FOR INSERT
WITH CHECK (auth.uid() = usuario_id);
```

Así un usuario no puede crear un pedido "a nombre de otro".

### Roles: claims dentro del JWT

Cuando un usuario está logueado, Supabase genera un **JWT** (JSON Web Token — token firmado que prueba la sesión) que incluye su ID y metadata.

Dentro de RLS podés usar:

- `auth.uid()` — UUID del usuario
- `auth.role()` — el rol ("authenticated" o "anon")
- `auth.jwt()` — JSON completo del token

**Agregar claims custom** (ej. rol "admin"):

1. Definís un trigger o función que setea `raw_app_meta_data.rol = 'admin'` al usuario
2. Ese claim entra al JWT
3. En policy: `USING (auth.jwt()->>'rol' = 'admin')`

### Testing policies

Supabase dashboard te deja simular:

1. Table Editor → abrís tabla → tocás "Policies"
2. "Impersonate user" → elegís qué usuario (o anónimo)
3. Ejecutás queries como si fueras ese usuario
4. Ves qué filas devuelve

Así testeás sin tener que loguearte como cada usuario.

### Errores comunes

**"RLS policy violation"**: el usuario intentó algo que ninguna policy permite. Revisá policies de esa operación.

**"Column does not exist"**: la policy usa `usuario_id` pero la tabla no lo tiene. Agregá la columna o ajustá el nombre.

**Recursión infinita**: si una policy consulta otra tabla que también tiene RLS con policy similar, Supabase puede loopear. Solución: marcá la función como `SECURITY DEFINER` (corre con permisos elevados, sin RLS).

### Pattern: helper functions

Para policies complejas, usá functions:

```sql
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $body$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = user_id AND rol = 'admin'
  );
$body$ LANGUAGE SQL SECURITY DEFINER STABLE;

-- Usás en policies:
CREATE POLICY "admin full access"
ON pedidos FOR ALL
USING (is_admin(auth.uid()));
```

Más limpio, reusable, testeable.

### Checklist pre-producción

- [ ] RLS activado en TODAS las tablas
- [ ] Policy de SELECT que limita por owner
- [ ] Policy de INSERT que verifica que usuario_id coincide
- [ ] Policy de UPDATE que no deja cambiar ownership
- [ ] Policy de DELETE solo admin o owner
- [ ] Testeado con user de prueba
- [ ] Testeado con anon (sin login) — debe devolver vacío en tablas protegidas
$md$,
    1, 70,
$md$**Implementá RLS en una tabla.**

1. En tu proyecto Supabase, creá tabla `notas`:

```sql
CREATE TABLE notas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  titulo TEXT,
  contenido TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users see own notas" ON notas FOR SELECT USING (auth.uid() = usuario_id);
CREATE POLICY "users insert own notas" ON notas FOR INSERT WITH CHECK (auth.uid() = usuario_id);
CREATE POLICY "users update own notas" ON notas FOR UPDATE USING (auth.uid() = usuario_id);
CREATE POLICY "users delete own notas" ON notas FOR DELETE USING (auth.uid() = usuario_id);
```

2. Creá 2 usuarios de prueba
3. Logueate con user A, insertá 2 notas
4. Logueate con user B, intentá leer las notas de A (debería devolver vacío)
5. Intentá insertar una nota "de parte de A" — debería fallar con RLS violation

Screenshot de ambos tests.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, 'Con RLS activado en una tabla SIN policies, ¿qué pasa?',
   '["Todos pueden leer", "Nadie puede leer/escribir (excepto service_role) — deny by default", "Solo admin puede", "Es lento"]'::jsonb,
   1, 0, 'RLS activado + 0 policies = bloqueo total. Deny-by-default es la filosofía correcta de seguridad.'),
  (v_lesson_id, '¿Cuál es la diferencia entre `USING` y `WITH CHECK` en una policy?',
   '["Son iguales", "USING filtra qué filas existentes son visibles; WITH CHECK valida qué valores nuevos se permiten", "USING es para SELECT, WITH CHECK para DELETE", "Ninguna"]'::jsonb,
   1, 1, 'USING = filtro de lectura (filas visibles). WITH CHECK = validación de escritura (nuevos valores permitidos).'),
  (v_lesson_id, '¿Qué función devuelve el UUID del usuario logueado en una policy RLS?',
   '["current_user()", "auth.uid()", "session.user.id", "get_current_id()"]'::jsonb,
   1, 2, 'auth.uid() es la función estándar de Supabase para acceder al ID del usuario autenticado en policies.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Roles, permisos y multi-tenant',
$md$## Más allá de "propio vs ajeno"

En apps reales, los permisos son más sofisticados. Tres patrones comunes:

### Patrón 1: roles (user, admin, staff)

Sistema clásico con 2-3 roles. Usuario tiene rol asignado. Las acciones se permiten según rol.

**Implementación con claim en JWT**:

Edge Function trigger que al signup asigna rol default:

```sql
-- En profile hay columna rol
CREATE POLICY "admins can do anything"
ON pedidos FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND rol IN ('admin', 'staff')
  )
);
```

Para promover usuario a admin: desde panel de admin que actualiza `profiles.rol = 'admin'`. Después el siguiente login recarga el JWT con nuevos claims.

### Patrón 2: teams / organizations (multi-tenant)

Usuario pertenece a una o más "orgs". Ve solo data de sus orgs.

**Tablas**:

```sql
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE organization_members (
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rol TEXT DEFAULT 'member' CHECK (rol IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (org_id, user_id)
);

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Policy**: "ves projects de orgs donde sos miembro":

```sql
CREATE POLICY "members see org projects"
ON projects FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM organization_members
    WHERE org_id = projects.org_id
    AND user_id = auth.uid()
  )
);
```

Y una policy que solo owners pueden invitar gente:

```sql
CREATE POLICY "owners invite"
ON organization_members FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM organization_members
    WHERE org_id = organization_members.org_id
    AND user_id = auth.uid()
    AND rol = 'owner'
  )
);
```

Este patrón lo usan Notion, Linear, Slack, cualquier SaaS B2B.

### Patrón 3: permisos granulares (ACL)

Más flexible: cada recurso tiene lista de usuarios con permisos específicos (read, write, admin).

```sql
CREATE TABLE document_permissions (
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  permission TEXT CHECK (permission IN ('read', 'write', 'admin')),
  PRIMARY KEY (document_id, user_id)
);
```

Se usa en Notion, Google Docs, Figma. Complejo pero potente.

**Para empezar**, usá patrón 1 o 2. ACL solo cuando lo necesitás de verdad.

### Invitaciones: el flujo clásico

Owner invita a alguien por email:

1. Insert en tabla `invitations` con email + org_id + token único + expires_at
2. Email al invitado con link `https://tuapp.com/join?token=xxx`
3. Invitado hace click → signup/login
4. Al loguear, tu app verifica token, crea membership en `organization_members`, borra invitation
5. Redirige al dashboard de la org

Supabase tiene función `supabase.auth.admin.inviteUserByEmail()` pero requiere service_role (solo backend).

### Secrets: variables de entorno seguras

En 2026, nunca guardes:

- API keys (Stripe, OpenAI, etc.)
- Passwords de DB
- Webhook secrets

En código fuente o Git. Usá:

- `.env.local` (gitignore)
- Vercel/Railway dashboard (env vars)
- Supabase Vault (nativo, para secretos dentro de edge functions)

**Regla 2026**: si ves una clave hardcodeada en el código, asumí que ya se filtró. Rotala.

### Encriptación de datos sensibles

Algunos datos (SSN, tarjetas, documentos) nunca deberían estar en claro ni en la base. Opciones:

**1. Encriptación en aplicación**: vos encriptás antes de insertar, desencriptás al leer. Usás librerías como `crypto-js` en JS.

**2. pgcrypto** (extension Postgres): encriptación dentro de la base. Útil para ciertas columnas.

**3. Ni siquiera guardes**: si podés, no lo guardes. Las tarjetas NUNCA las toques — usá Stripe tokens.

### Backups y recuperación ante desastres

Supabase Pro y superiores tienen backup diario automático (7 días retenidos).

En plan Free: **hacelo vos**. Opciones:

- Cron job que corre `pg_dump` y sube a S3/Drive
- Supabase CLI: `supabase db dump > backup.sql`

**Regla 2026**: una vez al mes, **restaurá** el backup en un proyecto Supabase de test. Los backups que no probaste no son backups.

### Audit log: saber quién hizo qué

Para apps regulares (salud, finanzas), loggear acciones críticas:

```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT,
  resource TEXT,
  resource_id UUID,
  metadata JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

Cada vez que alguien borra, edita datos sensibles, exporta info: inserta fila acá.

### Rate limiting

Sin rate limiting, un bot puede hacer 10000 requests/minuto a tu API y vaciarte el plan.

Supabase no lo trae nativo en free. Opciones:

- **Vercel Edge Middleware** con [Upstash Rate Limit](https://upstash.com)
- **Cloudflare Rate Limiting** (si usás su CDN)
- **Propio**: tabla `api_calls` con user_id y created_at, count últimos 60s, rechazar si > N

### Monitoreo de seguridad

Configurá alertas en:

- Intentos de login fallidos >5 consecutivos
- Access a endpoints admin desde IPs raras
- Picos anómalos de requests
- Modificaciones de RLS policies

En producción seria, herramientas como Datadog, New Relic, Sentry.

### El checklist final de seguridad

- [ ] RLS activado en todas las tablas
- [ ] service_role key solo en server-side
- [ ] .env nunca en Git
- [ ] Email verification en producción
- [ ] 2FA disponible para admins
- [ ] Backups testeados
- [ ] Rate limiting en endpoints públicos
- [ ] Secrets rotados cada 90 días
- [ ] Audit log para acciones sensibles
- [ ] HTTPS siempre, nunca HTTP
$md$,
    2, 70,
$md$**Implementá multi-tenant básico.**

1. Creá tablas `organizations`, `organization_members`, `projects` con RLS
2. Definí policies:
   - Todos los miembros de una org ven los projects
   - Solo owners pueden invitar
3. Creá 2 usuarios y 2 orgs
4. Simulá: user A miembro de org 1. user B miembro de org 2.
5. Cada uno debería ver SOLO los projects de su org

Escribí el SQL y las policies, compartí.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, 'En un sistema multi-tenant, ¿cómo se relaciona usuario con organización?',
   '["Columna org_id directamente en auth.users", "Tabla organization_members con (org_id, user_id, rol)", "No hay relación", "Un campo JSON en profile"]'::jsonb,
   1, 0, 'Tabla pivot organization_members permite: múltiples orgs por usuario, roles distintos por org, auditable.'),
  (v_lesson_id, '¿Qué hacés con números de tarjetas de crédito en tu base?',
   '["Guardarlos encriptados", "NUNCA los guardes — usás tokens de Stripe/PayPal", "Solo los últimos 4", "En texto plano pero con RLS"]'::jsonb,
   1, 1, 'La regla PCI: nunca almacenes tarjetas. Stripe te da un token reusable; guardás solo eso.'),
  (v_lesson_id, '¿Qué significa que los backups no probados "no son backups"?',
   '["Frase bonita", "Si nunca intentás restaurar, no sabés si sirven — muchos descubren que son inutilizables recién en la emergencia", "No importa", "Son más pequeños"]'::jsonb,
   1, 2, 'Un backup no probado = esperanza. Probalo mensualmente restaurando en un proyecto de test.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Storage: subir archivos, imágenes y documentos',
$md$## Cuando tu app maneja más que texto

Storage en Supabase = bucket (contenedor) tipo S3 de Amazon pero integrado con tu auth.

Usos típicos:
- Avatares de usuarios
- Imágenes de productos
- PDFs de facturas
- Videos cortos
- Documentos que suben clientes

### Buckets: públicos vs privados

**Bucket público**:
- Cualquiera con la URL ve el archivo
- Ideal: avatares, logos, imágenes de productos (lo que ya va a ser visible)

**Bucket privado**:
- URL no sirve si no tenés permiso
- Supabase genera URLs firmadas temporales
- Ideal: facturas, documentos legales, videos pagos, data sensible

### Crear bucket

Dashboard → Storage → "New bucket":

- **Name**: ej. `avatares`
- **Public**: ON (si es público) o OFF (privado)
- **File size limit**: 50 MB default, ajustable
- **Allowed MIME types**: ej. solo `image/*` para avatares

### Subir archivo desde cliente

```javascript
const file = event.target.files[0]; // del input type="file"

const { data, error } = await supabase.storage
  .from('avatares')
  .upload(`${userId}/avatar.png`, file, {
    cacheControl: '3600',
    upsert: true // sobrescribe si existe
  });
```

Path recomendado: `{user_id}/nombre_archivo.ext`. Así cada usuario tiene su carpeta.

### Obtener URL pública

```javascript
const { data } = supabase.storage
  .from('avatares')
  .getPublicUrl(`${userId}/avatar.png`);

// data.publicUrl → 'https://xxx.supabase.co/storage/v1/object/public/avatares/...'
```

### URLs firmadas (buckets privados)

```javascript
const { data, error } = await supabase.storage
  .from('facturas')
  .createSignedUrl(`${userId}/factura-abc.pdf`, 60); // válida 60 segundos

// data.signedUrl → URL temporal
```

Le das esa URL al cliente; después de 60s no funciona más. Ideal para documentos legales/privados.

### Descargar archivo

```javascript
const { data, error } = await supabase.storage
  .from('avatares')
  .download(`${userId}/avatar.png`);

// data es un Blob, podés mostrarlo o guardarlo
```

### Listar archivos

```javascript
const { data, error } = await supabase.storage
  .from('avatares')
  .list(userId, { limit: 100 });
```

### Eliminar archivos

```javascript
await supabase.storage
  .from('avatares')
  .remove([`${userId}/avatar.png`]);
```

### Policies de Storage (RLS para archivos)

Igual que con tablas, Storage tiene policies RLS. Ejemplo: cada uno sube y lee solo sus propios avatares:

```sql
-- SELECT: leer
CREATE POLICY "users see own avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);

-- INSERT: subir
CREATE POLICY "users upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);

-- UPDATE: modificar
CREATE POLICY "users update own avatar"
ON storage.objects FOR UPDATE
USING (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);

-- DELETE: borrar
CREATE POLICY "users delete own avatar"
ON storage.objects FOR DELETE
USING (bucket_id = 'avatares' AND (storage.foldername(name))[1] = auth.uid()::text);
```

`storage.foldername(name)[1]` extrae la primera carpeta del path. Si subiste a `abc123/avatar.png`, devuelve `abc123` — comparás contra `auth.uid()`.

### Transformaciones de imagen (image transformations)

Supabase Pro te deja transformar imágenes al vuelo:

```javascript
const { data } = supabase.storage
  .from('avatares')
  .getPublicUrl('abc/avatar.png', {
    transform: {
      width: 200,
      height: 200,
      resize: 'cover',
      quality: 80
    }
  });
```

Útil para no guardar múltiples tamaños — Supabase genera el que pedís.

### Límites y precios

**Plan Free**:
- 1 GB storage
- 2 GB egress/mes (tráfico de descargas)
- 50 MB por archivo
- Sin image transformations

**Plan Pro**:
- 100 GB storage incluido, $0.021/GB extra
- 250 GB egress incluido
- 50 MB por archivo (ajustable)
- Image transformations incluido

Para videos largos o almacenamiento masivo, considerá Cloudflare R2 o Bunny.net (baratos y sin egress fees).

### CDN: servir rápido globalmente

Los archivos en buckets públicos se sirven vía Cloudflare CDN (cacheo global) automáticamente. Sin config extra, tus archivos cargan rápido desde cualquier parte del mundo.

### Patrón: upload + preview + metadata

Flujo típico en una app:

1. Usuario elige archivo → frontend lo muestra en preview
2. Al submit, subís a Storage → obtenés URL
3. Insertás fila en tabla con esa URL + metadata (tamaño, tipo, nombre original)
4. En la UI, cargás la URL

**Tabla del patrón**:

```sql
CREATE TABLE uploads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  file_path TEXT NOT NULL,
  file_name TEXT,
  file_size INT,
  mime_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Seguridad en uploads

Antes de aceptar un archivo:

- **Validar MIME type**: no aceptes `application/x-executable`
- **Validar tamaño**: rechazá si > 10 MB (o lo que sea razonable)
- **Escanear virus** en archivos críticos: hay servicios como [ClamAV](https://www.clamav.net) o [Cloudmersive](https://cloudmersive.com)
- **No confíes en el nombre**: el usuario puede mandar `../../etc/passwd` — usá UUID como nombre

### Casos de uso concretos

- **Perfiles con avatar**: bucket público `avatares`, policy propia
- **Facturas del negocio**: bucket privado `facturas`, signed URLs de 1h
- **Ecommerce con imágenes de producto**: bucket público `productos`, image transform para thumbnails
- **Compartir documentos**: bucket privado + signed URLs vía email con token de 7 días
$md$,
    3, 70,
$md$**Implementá sistema de avatares.**

1. Creá bucket `avatares` en Dashboard → Storage
2. Marcarlo como **público**
3. Aplicá las 4 policies (SELECT, INSERT, UPDATE, DELETE) del ejemplo
4. En Lovable/Next.js:
   - Creá componente con `<input type="file" accept="image/*" />`
   - Al cambiar, subí a `avatares/{user_id}/avatar.png`
   - Mostrá la URL pública como `<img>`
5. Loguéate con 2 usuarios distintos: verificá que cada uno ve solo su avatar

Screenshot del flujo.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo conviene un bucket privado con signed URLs?',
   '["Siempre — más seguro", "Para archivos que deben tener acceso controlado (facturas, contratos, videos pagos)", "Para imágenes de productos ecommerce", "Nunca"]'::jsonb,
   1, 0, 'Privado + signed URLs = archivos que solo ven quienes vos autorizás, con expiración temporal.'),
  (v_lesson_id, '¿Por qué poner user_id como primera carpeta del path del archivo?',
   '["Se ve más ordenado", "Permite RLS policies que limitan acceso por user usando storage.foldername(name)[1]", "Es obligatorio", "Hace más rápido el upload"]'::jsonb,
   1, 1, 'Path `{user_id}/archivo.ext` es patrón clave para policies que comparan contra auth.uid().'),
  (v_lesson_id, '¿Qué deberías validar en un upload antes de aceptarlo?',
   '["Nada, Supabase valida solo", "MIME type, tamaño máximo, y NO confiar en el nombre del archivo original", "Solo el nombre", "El color predominante"]'::jsonb,
   1, 2, 'Validación básica evita ataques: ejecutables, archivos enormes, path traversal con nombres raros.');

  RAISE NOTICE '✅ Módulo Auth y seguridad cargado — 4 lecciones + 12 quizzes';
END $$;
