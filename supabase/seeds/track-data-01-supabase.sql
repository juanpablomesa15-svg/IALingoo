-- =============================================
-- IALingoo — Track "Data y bases" / Módulo "Supabase básico"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'data';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Supabase básico no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Qué es Supabase y por qué es el Firebase de 2026',
$md$## El backend que no tenés que construir

Supabase es una plataforma open source que te da **todo el backend** (la parte "invisible" que guarda datos, autentica usuarios, procesa lógica) listo para usar:

- Base de datos PostgreSQL potente
- Autenticación (email, Google, GitHub, magic links)
- Storage de archivos (tipo S3)
- Edge Functions (código serverless)
- Realtime (datos en vivo sin refresh)
- Vector DB (pgvector para IA/RAG)

Todo gratis hasta cierto volumen. Y cuando pagás, es barato.

### Supabase vs alternativas en 2026

| Plataforma | Pros | Contras |
|---|---|---|
| **Supabase** | Open source, Postgres completo, gratis generoso, pgvector incluido | Curva media |
| **Firebase** (Google) | Realtime excelente, madura | NoSQL, lock-in, cara a escala |
| **PlanetScale** | MySQL serverless, branching | Sin auth/storage integrados, deprecó tier gratis |
| **Neon** | Postgres serverless puro, branching | Sin auth/storage (hay que sumar Clerk + UploadThing) |
| **Convex** | Reactiva, TypeScript-first | Menos madura, lock-in |

**Regla 2026**: empezá con Supabase. 95% de los proyectos lo resuelven todo. Si crecés mucho o tenés requerimientos muy específicos, valoras alternativas.

### ¿Por qué SQL y no NoSQL?

En años pasados Firebase ganó por ser "más simple". En 2026, ya nadie duda: **SQL gana**. Razones:

1. **Relaciones**: un cliente tiene muchos pedidos, cada pedido tiene items. SQL lo hace nativo.
2. **Queries potentes**: SUM, AVG, JOIN, GROUP BY son imbatibles.
3. **Consistencia**: transacciones ACID evitan datos corruptos.
4. **Estándar**: SQL lo sabe todo el mundo. NoSQL es fragmentado.
5. **Postgres + IA**: vector DB, JSONB, full-text search, todo en una sola base.

Si venís de Excel, pensá que una tabla SQL es una hoja con **reglas** de tipo y relaciones.

### Qué es PostgreSQL

PostgreSQL (o "Postgres") es la base de datos SQL más potente del mundo open source. Gratis, madura (30 años), soporta todo:

- Tipos normales: INT, TEXT, BOOLEAN, DATE, TIMESTAMP
- **JSONB**: columnas que guardan JSON con queries rápidas
- **Arrays**: `TEXT[]` para listas
- **UUID**: identificadores únicos
- **Full-text search**: búsqueda tipo Google dentro de tu base
- **pgvector**: búsqueda por similitud semántica (para IA)

Supabase es "Postgres con superpoderes": te da UI, API automática, auth, storage.

### Los 4 conceptos básicos

1. **Tabla**: estructura tipo Excel con columnas y filas
2. **Columna**: campo con un tipo (nombre TEXT, edad INT, creado_en TIMESTAMP)
3. **Fila** (o registro): una entrada concreta (ej. "Juan, 30, 2026-04-21")
4. **Query**: instrucción SQL para leer, insertar, actualizar o borrar

Las 4 operaciones CRUD:

| Operación | SQL | Ejemplo |
|---|---|---|
| **C**reate | INSERT | crear cliente nuevo |
| **R**ead | SELECT | buscar clientes |
| **U**pdate | UPDATE | cambiar email de cliente |
| **D**elete | DELETE | borrar cliente |

### Los planes de Supabase

**Free** (suficiente para empezar):
- 500 MB database
- 1 GB storage
- 5 GB egress/mes (tráfico saliente)
- 50k usuarios auth activos
- Pausa si no hay actividad 7 días

**Pro** ($25/mes):
- 8 GB database
- 100 GB storage
- Backups diarios
- Nunca se pausa
- Soporte email

**Team / Enterprise**: cuando necesitás más.

Para 2026, plan Free sirve para proyectos personales, MVPs y SaaS hasta ~2000 usuarios.

### Cómo accedes a Supabase

1. **Dashboard web**: [supabase.com](https://supabase.com) — creás cuenta y gestionás todo visualmente
2. **CLI**: para proyectos serios, manejar migraciones y tipos desde terminal
3. **SDK (Software Development Kit — librerías oficiales para cada lenguaje)**: JavaScript, Python, Dart, Swift, Rust
4. **API REST**: cualquier lenguaje puede llamar directo por HTTP
5. **GraphQL**: si preferís ese estilo de queries

**Regla 2026**: empezá por dashboard web + SDK de JavaScript. 80% del trabajo se resuelve así.
$md$,
    0, 50,
$md$**Creá tu primer proyecto Supabase.**

1. Ir a [supabase.com](https://supabase.com) → Sign up (con GitHub recomendado)
2. "New project" → dale nombre "IALingoo-test"
3. Elegí password del DB (anotalo seguro)
4. Región: la más cercana (South America - São Paulo para LATAM)
5. Esperá 2-3 min a que se cree
6. Explorá las pestañas: Table Editor, SQL Editor, Auth, Storage, Edge Functions
7. Del panel API Settings, anotá: **Project URL** y **anon key** (las vas a usar)$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué NO incluye Supabase out-of-the-box?',
   '["Base de datos PostgreSQL", "Autenticación", "Storage de archivos", "CDN de videos con transcodificación automática"]'::jsonb,
   3, 0, 'Supabase trae DB, Auth, Storage, Edge Functions, Realtime, Vector. Pero no es un servicio de video-CDN completo.'),
  (v_lesson_id, '¿Por qué SQL es mejor que NoSQL para la mayoría de proyectos en 2026?',
   '["Es más viejo", "Relaciones, queries potentes, estándar universal, consistencia ACID", "No hay razón", "Es más rápido siempre"]'::jsonb,
   1, 1, 'Las razones 2026: relaciones, joins, estándar, transacciones, y Postgres + pgvector para IA.'),
  (v_lesson_id, '¿Qué son las 4 operaciones CRUD?',
   '["Crear, Renombrar, Usar, Descargar", "Create, Read, Update, Delete (las 4 acciones básicas sobre datos)", "Cortar, Reducir, Unir, Duplicar", "Compilar, Run, Uninstall, Deploy"]'::jsonb,
   1, 2, 'CRUD = las 4 operaciones fundamentales sobre una tabla: Create, Read, Update, Delete.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Crear tablas: diseño que no te vas a arrepentir',
$md$## La decisión que define tu app

Diseñar bien las tablas desde el inicio te ahorra meses de refactor. Mal diseño = todo tu código sufre.

### Regla #1: pensá en entidades y relaciones

Antes de crear tablas, preguntate: **¿cuáles son las "cosas" que existen en mi app?**

Ejemplo — app de gestión de cursos:
- Usuarios
- Cursos
- Lecciones
- Inscripciones
- Pagos

Cada entidad = una tabla. Cada tabla tiene sus propias columnas.

### Regla #2: claves primarias

Toda tabla necesita una **clave primaria** (primary key — campo único que identifica cada fila). Opciones:

- **BIGINT autoincremental** (1, 2, 3, ...): simple pero expone info ("tenemos 5 usuarios")
- **UUID** (ej. `a3d4-...`): recomendado 2026, no adivinable, distribuido

Ejemplo:

```sql
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Regla #3: foreign keys para relaciones

Una **foreign key** es una columna que apunta a otra tabla. Define la relación.

Ejemplo: "un curso tiene muchas lecciones"

```sql
CREATE TABLE cursos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo TEXT NOT NULL,
  precio INT NOT NULL,
  creado_en TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE lecciones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  curso_id UUID REFERENCES cursos(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  orden INT NOT NULL,
  contenido TEXT
);
```

`REFERENCES cursos(id)` dice "esta columna apunta al id de la tabla cursos".

`ON DELETE CASCADE` = si borrás un curso, se borran automáticamente sus lecciones.

### Regla #4: tipos correctos desde el día 1

| Dato | Tipo recomendado |
|---|---|
| ID | UUID |
| Nombre, email, texto corto | TEXT |
| Texto largo (post, mensaje) | TEXT |
| Número entero (cantidad, edad) | INT |
| Número con decimales (precio) | NUMERIC(10,2) o INT (centavos) |
| Booleano (activo/inactivo) | BOOLEAN |
| Fecha | DATE |
| Fecha y hora | TIMESTAMPTZ (con zona horaria) |
| Lista de strings | TEXT[] (array) |
| Objeto JSON flexible | JSONB |

**Tip 2026**: para **precios**, guardá en **centavos** (INT) no decimales. Evita errores de redondeo. $10.50 se guarda como `1050`.

### Regla #5: nombres consistentes

- Tablas en plural: `usuarios`, `cursos`, `pedidos`
- Columnas en singular: `nombre`, `email`, `precio_centavos`
- Foreign keys: `tabla_id` (ej. `curso_id`, `usuario_id`)
- Timestamps: siempre `created_at` y `updated_at` (estándar global)

### Crear tabla desde el Dashboard

1. Table Editor (pestaña lateral)
2. "New table"
3. Nombre: `usuarios`
4. Columnas: agregás cada una con tipo, default, constraint
5. "Save"

Supabase te genera automáticamente la API REST — ya podés insertar/leer sin escribir backend.

### Crear tabla desde SQL Editor (recomendado)

Para proyectos serios, usá SQL Editor (pestaña "SQL" lateral):

```sql
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  nombre TEXT NOT NULL,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
  avatar_url TEXT,
  metadata JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para búsquedas rápidas por email
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);

-- Trigger para auto-updatear updated_at
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $body$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

CREATE TRIGGER usuarios_updated_at
BEFORE UPDATE ON usuarios
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

Esto es lo que los profesionales usan: scripts reproducibles que podés versionar en Git.

### Constraints: las reglas que protegen tus datos

- **NOT NULL**: el campo no puede ser vacío
- **UNIQUE**: no puede haber dos filas con el mismo valor
- **CHECK**: validación custom (ej. `CHECK (edad > 0)`)
- **DEFAULT**: valor por defecto si no lo especificás
- **REFERENCES**: foreign key

Invertí tiempo en constraints bien. Te salvan de bugs futuros.

### Índices: para búsquedas rápidas

Un **índice** es una estructura que hace las búsquedas súper rápidas. Sin índice, buscar un email en 1M de filas tarda segundos. Con índice, milisegundos.

Creá índice en columnas que:
- Usás seguido en WHERE (ej. `email`, `fecha`)
- Son foreign keys (casi obligatorio)

```sql
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_pedidos_usuario_id ON pedidos(usuario_id);
```

Regla: cada foreign key debería tener índice.
$md$,
    1, 60,
$md$**Creá 2 tablas relacionadas en tu proyecto Supabase.**

1. En SQL Editor, corré este script:

```sql
CREATE TABLE proyectos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT NOT NULL,
  descripcion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE tareas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proyecto_id UUID REFERENCES proyectos(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  completada BOOLEAN DEFAULT false,
  due_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tareas_proyecto_id ON tareas(proyecto_id);
```

2. Volvé al Table Editor y verificá que se crearon
3. Insertá 1 proyecto y 3 tareas relacionadas (Table Editor → Insert row)
4. Screenshot del esquema y las filas$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué tipo conviene usar en 2026 para IDs?',
   '["INT autoincremental siempre", "UUID — no adivinable, distribuido, estándar moderno", "String random generado en el cliente", "El email del usuario"]'::jsonb,
   1, 0, 'UUID es el estándar 2026: único globalmente, no expone conteos, mejor para APIs públicas.'),
  (v_lesson_id, '¿Qué hace `ON DELETE CASCADE` en una foreign key?',
   '["Da error si intentás borrar", "Borra automáticamente las filas hijas cuando borrás el padre", "Congela la fila", "Es decorativo"]'::jsonb,
   1, 1, 'CASCADE = efecto dominó. Al borrar un curso, se borran sus lecciones asociadas automáticamente.'),
  (v_lesson_id, '¿Por qué guardar precios en centavos (INT) en vez de decimales?',
   '["Son más cortos", "Evita errores de redondeo y problemas con aritmética de floats", "Es más bonito", "Lo pide la ley"]'::jsonb,
   1, 2, 'Floats en dinero = bug futuro garantizado. Centavos como INT = precisión perfecta.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Insertar, leer, actualizar y borrar (CRUD básico)',
$md$## Hablar con tu base de datos

Dos formas de ejecutar CRUD en Supabase:

1. **SQL directo** (desde SQL Editor o código)
2. **API del SDK** (desde tu frontend/backend con `supabase-js`)

### CRUD con SQL

**CREATE (INSERT)**:

```sql
INSERT INTO usuarios (email, nombre, plan)
VALUES ('juan@example.com', 'Juan Pérez', 'pro');
```

Múltiples filas a la vez:

```sql
INSERT INTO usuarios (email, nombre)
VALUES
  ('ana@example.com', 'Ana'),
  ('luis@example.com', 'Luis'),
  ('maria@example.com', 'María');
```

**READ (SELECT)**:

```sql
-- Traer todos
SELECT * FROM usuarios;

-- Con filtro
SELECT id, nombre FROM usuarios WHERE plan = 'pro';

-- Ordenado
SELECT * FROM usuarios ORDER BY created_at DESC;

-- Limitado
SELECT * FROM usuarios LIMIT 10;

-- Con JOIN (tablas relacionadas)
SELECT u.nombre, p.titulo
FROM usuarios u
JOIN pedidos p ON p.usuario_id = u.id
WHERE p.fecha > '2026-01-01';

-- Agregados
SELECT plan, COUNT(*) as total FROM usuarios GROUP BY plan;
```

**UPDATE**:

```sql
UPDATE usuarios
SET plan = 'enterprise', updated_at = NOW()
WHERE id = 'a3d4...';
```

**Peligro**: un UPDATE sin WHERE actualiza TODO. Siempre verificá el WHERE antes de ejecutar.

**DELETE**:

```sql
DELETE FROM usuarios WHERE id = 'a3d4...';
```

Mismo peligro que UPDATE — sin WHERE borrás toda la tabla.

**Tip 2026**: en vez de DELETE, muchos prefieren **soft delete**: agregás columna `deleted_at TIMESTAMPTZ` y en vez de borrar, la seteás. Así podés recuperar.

### CRUD desde JavaScript con supabase-js

Primero, instalás el SDK:

```bash
npm install @supabase/supabase-js
```

Iniciás el cliente:

```javascript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  'https://xxx.supabase.co',   // Project URL
  'eyJhbGci...'                // anon key
);
```

**INSERT**:

```javascript
const { data, error } = await supabase
  .from('usuarios')
  .insert({ email: 'juan@example.com', nombre: 'Juan' })
  .select();

if (error) console.error(error);
else console.log('Usuario creado:', data);
```

**SELECT**:

```javascript
// Todo
const { data } = await supabase.from('usuarios').select('*');

// Con filtro
const { data } = await supabase
  .from('usuarios')
  .select('id, nombre, email')
  .eq('plan', 'pro')
  .order('created_at', { ascending: false })
  .limit(10);

// Con join (relación foreign key)
const { data } = await supabase
  .from('pedidos')
  .select(`
    id, total,
    usuario:usuarios(nombre, email)
  `);
```

**UPDATE**:

```javascript
const { data } = await supabase
  .from('usuarios')
  .update({ plan: 'enterprise' })
  .eq('id', 'a3d4...')
  .select();
```

**DELETE**:

```javascript
const { data } = await supabase
  .from('usuarios')
  .delete()
  .eq('id', 'a3d4...');
```

**UPSERT** (update si existe, insert si no):

```javascript
const { data } = await supabase
  .from('usuarios')
  .upsert({ email: 'juan@example.com', nombre: 'Juan V2' }, { onConflict: 'email' });
```

### Operadores comunes en filtros

| Operador | SQL equivalente | JS | Ejemplo |
|---|---|---|---|
| Igualdad | `=` | `.eq()` | `.eq('plan', 'pro')` |
| Distinto | `!=` | `.neq()` | `.neq('estado', 'inactivo')` |
| Mayor | `>` | `.gt()` | `.gt('edad', 18)` |
| Mayor o igual | `>=` | `.gte()` | `.gte('precio', 100)` |
| Menor | `<` | `.lt()` | `.lt('stock', 10)` |
| Contiene | `LIKE` | `.like()` | `.like('nombre', '%juan%')` |
| Contiene (case insensitive) | `ILIKE` | `.ilike()` | `.ilike('email', '%gmail%')` |
| En lista | `IN` | `.in()` | `.in('plan', ['pro', 'ent'])` |
| Null | `IS NULL` | `.is()` | `.is('deleted_at', null)` |

### Errores típicos al empezar

**Error 1: olvidarte el .select() después de insert/update**

```javascript
// ❌ No devuelve data
await supabase.from('usuarios').insert({ email: 'x' });

// ✅ Devuelve la fila insertada
await supabase.from('usuarios').insert({ email: 'x' }).select();
```

**Error 2: usar anon key en operaciones sensibles desde el frontend**

Todo lo que hace el frontend usando `anon key` está expuesto. Para operaciones sensibles (borrar usuarios, admin panel), usá **Edge Functions** con `service_role` key (nunca exposes eso al browser).

**Error 3: no manejar errores**

```javascript
const { data, error } = await supabase.from('x').select();
if (error) {
  // Mostrar mensaje al usuario, loggear, etc.
  console.error(error);
  return;
}
// Usar data solo si no hay error
```

### Realtime: actualización en vivo

Supabase tiene realtime integrado. Escuchás cambios en una tabla y tu UI se actualiza sola:

```javascript
supabase
  .channel('usuarios-changes')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'usuarios' },
    (payload) => {
      console.log('Nuevo usuario:', payload.new);
    })
  .subscribe();
```

Ideal para dashboards, chats, colaboración en tiempo real.
$md$,
    2, 70,
$md$**Hacé CRUD completo en tu proyecto.**

Desde el SQL Editor o un script Node.js:

1. INSERT 3 proyectos nuevos
2. INSERT 2 tareas por proyecto
3. SELECT todas las tareas no completadas, ordenadas por due_date
4. UPDATE: marcar 1 tarea como completada
5. DELETE: borrar un proyecto (verificá que sus tareas también se borraron por CASCADE)
6. Hacé un JOIN: SELECT de tareas con el nombre del proyecto al que pertenecen

Screenshot de los resultados de cada query.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué pasa si hacés `UPDATE usuarios SET plan=''free''` sin WHERE?',
   '["No pasa nada", "Actualiza TODOS los usuarios a plan free — accidente grave", "Da error", "Borra la tabla"]'::jsonb,
   1, 0, 'UPDATE sin WHERE afecta todas las filas. Siempre verificá el WHERE antes de ejecutar.'),
  (v_lesson_id, '¿Qué es un UPSERT?',
   '["Borrar y crear", "Si existe la clave actualiza, sino inserta (combina update + insert)", "Un error", "Un índice"]'::jsonb,
   1, 1, 'Upsert = Update + Insert. Útil cuando no sabés si la fila ya existe.'),
  (v_lesson_id, '¿Qué significa "soft delete"?',
   '["Borrar suavemente (más lento)", "En vez de borrar, marcar la fila como deleted_at = NOW() — permite recuperar", "Borrar solo los permisos", "Borrar texto pero no imágenes"]'::jsonb,
   1, 2, 'Soft delete = marcar como borrada sin eliminarla físicamente. Reversible y audit-friendly.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Conectar desde tu app: frontend, n8n, y Lovable',
$md$## Tu base ya existe. ¿Cómo la usás en producción?

Supabase expone tu base de 4 formas:
1. Dashboard (ya lo vimos)
2. SDK JavaScript/Python/etc desde tu app
3. API REST auto-generada
4. Desde n8n (nodo nativo Supabase)

### Desde una app Next.js

En 2026 el stack más común: Lovable/v0 genera Next.js + Supabase-js.

**Setup**:

```bash
npm install @supabase/supabase-js
```

Archivo `.env.local`:

```
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
```

Cliente singleton:

```javascript
// lib/supabase.js
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);
```

Uso en una página:

```javascript
'use client';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

export default function Proyectos() {
  const [proyectos, setProyectos] = useState([]);

  useEffect(() => {
    async function load() {
      const { data } = await supabase.from('proyectos').select('*');
      setProyectos(data || []);
    }
    load();
  }, []);

  return (
    <ul>
      {proyectos.map(p => <li key={p.id}>{p.nombre}</li>)}
    </ul>
  );
}
```

### Desde Lovable/v0

Lovable ya tiene integración nativa con Supabase en 2026. Pasos:

1. En Lovable, tocás "Add integration" → Supabase
2. Conectás tu proyecto (OAuth o pegando las keys)
3. Lovable lee tus tablas y te deja pedir: *"Crea un CRUD para la tabla proyectos"*
4. Genera los componentes conectados

No escribís una línea de código — Lovable usa el SDK por detrás.

### Desde n8n

Ya lo vimos en el track n8n. En cada workflow usás el nodo **Supabase**:

- Insert row: agregás fila desde datos del workflow
- Select: traés data para procesar
- Update: modificás filas
- Delete: borrás

**Regla crítica 2026**: no anteponer `=` fuera de la sintaxis de expresión `{{ }}` en los campos de n8n. Los valores literales van sin `=`.

### API REST auto-generada (PostgREST)

Supabase te da una API REST sobre tu base. Podés usarla desde cualquier lenguaje sin SDK.

Endpoint: `https://xxx.supabase.co/rest/v1/proyectos`

Headers:
```
apikey: eyJhbGci...
Authorization: Bearer eyJhbGci...
Content-Type: application/json
```

GET `?select=*&plan=eq.pro` = trae todos los proyectos con plan=pro.
POST con body `{"nombre":"x"}` = inserta.

Útil cuando no hay SDK para tu lenguaje (ej. Rust, Go, C#).

### Service role vs anon key

Tu proyecto tiene 2 keys:

**anon key** (pública):
- Se pega en el frontend
- Respeta RLS (Row Level Security — las reglas de acceso a nivel fila que vemos en módulo 2)
- Es lo que los usuarios usan

**service_role key** (secreta):
- **NUNCA** en el frontend
- Ignora RLS (acceso total)
- Úsala en Edge Functions, n8n server-side, scripts admin

**Regla sagrada**: si filtrás la service_role key, cualquiera puede leer/borrar tu base. Tratala como una password de root.

### Environment variables: buenas prácticas

**Local**: `.env.local` (nunca subir a Git — agregalo al `.gitignore`)

**Deploy**: en Vercel/Netlify/Railway, las agregás desde el dashboard:
- `NEXT_PUBLIC_SUPABASE_URL` (pública, va al browser)
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` (pública)
- `SUPABASE_SERVICE_ROLE_KEY` (secreta, solo server-side — no pongas `NEXT_PUBLIC_`)

### Testing local: Supabase CLI

Para desarrollo serio, instalá Supabase CLI:

```bash
npm install -g supabase
supabase login
supabase init
supabase start
```

Te levanta una copia de Supabase en `localhost:54321` con Postgres, Auth, Studio — todo local. Hacés migraciones con:

```bash
supabase migration new create_tareas
# editás el archivo .sql generado
supabase db push  # aplica en staging/prod
```

Esto es lo que equipos profesionales usan en 2026 para no romper producción.

### Seeding: datos de prueba

Tener data ficticia es clave para desarrollo. Creás archivo `seed.sql`:

```sql
INSERT INTO usuarios (email, nombre, plan) VALUES
  ('demo1@test.com', 'Demo 1', 'free'),
  ('demo2@test.com', 'Demo 2', 'pro');
```

Ejecutás con `supabase db reset` (borra y reinicializa).

### Logs y debugging

En el dashboard de Supabase:
- **Logs > API**: todas las requests que llegan
- **Logs > Postgres**: queries lentas, errores SQL
- **Logs > Auth**: intentos de login
- **Reports**: métricas de uso
$md$,
    3, 70,
$md$**Conectá tu proyecto a una app.**

Opción A (si estás con Lovable/v0):
1. Creá app nueva en Lovable
2. Integración → Supabase → conectá tu proyecto
3. Pedile a Lovable: "Crea una lista y formulario para la tabla proyectos"
4. Probá crear, editar, borrar desde la UI

Opción B (Node.js local):
1. Creá carpeta, `npm init -y`
2. `npm install @supabase/supabase-js dotenv`
3. Archivo `.env` con las keys
4. Script `test.js` que haga insert, select, update de tu tabla proyectos
5. `node test.js` — verificá que funcione

Screenshot de la app mostrando data y del código.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué key NUNCA debe ir al frontend?',
   '["anon key", "service_role key (acceso total, ignora RLS)", "database password", "Ninguna"]'::jsonb,
   1, 0, 'service_role = root. Solo en server-side (Edge Functions, n8n, scripts). En frontend usás anon key.'),
  (v_lesson_id, '¿Qué prefijo llevan las env vars públicas en Next.js?',
   '["PRIVATE_", "NEXT_PUBLIC_", "SECRET_", "PUBLIC_"]'::jsonb,
   1, 1, 'NEXT_PUBLIC_ las expone al browser. Sin ese prefijo, solo están en server-side.'),
  (v_lesson_id, '¿Para qué sirve Supabase CLI local?',
   '["Conectarse por SSH", "Levantar una copia local completa de Supabase para desarrollo sin tocar producción", "Ver precios", "Hacer backups"]'::jsonb,
   1, 2, 'CLI local = Postgres + Auth + Studio corriendo en tu máquina. Desarrollás sin riesgo.');

  RAISE NOTICE '✅ Módulo Supabase básico cargado — 4 lecciones + 12 quizzes';
END $$;
