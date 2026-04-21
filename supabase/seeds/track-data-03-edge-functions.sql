-- =============================================
-- IALingoo — Track "Data y bases" / Módulo "Edge Functions"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'data';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Edge Functions no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, '¿Qué es serverless y por qué lo queremos?',
$md$## Código que vive solo cuando lo necesitás

**Serverless** (sin servidor — en realidad hay servidor, pero no te preocupás por él) es un modelo donde subís una función, y el proveedor la corre **solo cuando la llaman**. Pagás por ejecución, no por hora.

### Servidor tradicional vs serverless

**Servidor tradicional (VPS, EC2)**:
- Está corriendo 24/7 esperando tráfico
- Pagás por hora aunque no haya nadie
- Vos administrás: actualizaciones, seguridad, escala
- Si hay pico masivo, se cae

**Serverless (Edge Functions)**:
- No hay servidor "encendido" hasta que alguien llama la función
- Cold start (primer pedido) tarda ~50-300ms
- Escalado automático a miles de requests/s
- Pagás solo ejecuciones reales
- Cero mantenimiento de infraestructura

### ¿Cuándo usar Edge Functions vs backend tradicional?

| Situación | Serverless (EF) | Backend tradicional |
|---|---|---|
| API ligera | ✅ Perfecto | Overkill |
| Procesamiento por request (webhooks, transformación) | ✅ Perfecto | OK |
| Tarea que dura <30s | ✅ | OK |
| Tarea que dura minutos/horas | ❌ (timeout) | ✅ |
| Requiere WebSockets persistentes | ❌ | ✅ |
| Estado compartido entre requests | ❌ | ✅ (con Redis) |
| Proceso batch diario | ✅ (Scheduled) | ✅ |

**Regla 2026**: para 80% de las tareas típicas de una app, serverless alcanza. Solo cuando necesitás conexiones persistentes o procesamiento largo, backend tradicional.

### Supabase Edge Functions: basadas en Deno

Las Edge Functions de Supabase corren en **Deno** (runtime de JavaScript/TypeScript moderno, alternativa a Node.js):

- TypeScript nativo
- Imports URL-based (no npm install)
- Web standards (fetch, Request, Response)
- Se ejecutan en edge (Cloudflare Workers en múltiples regiones)

### Cuándo usar Edge Function en Supabase

Casos típicos:

1. **Webhook handler**: Stripe te manda evento → tu función procesa pago
2. **API wrapper**: cliente frontend llama tu EF → ella llama a OpenAI con tu API key secreta (nunca exponés la key)
3. **Transformación de data**: cron que corre cada hora, limpia tabla, genera resumen
4. **Autenticación custom**: login con método no estándar
5. **Integración con servicios externos**: mandar email vía Resend, Slack, etc.

### Arquitectura típica

```
Cliente (browser/mobile) →
  Supabase Auth (login) →
  Frontend hace fetch a:
    /functions/v1/mi-funcion →
  Edge Function:
    - valida que usuario está logueado
    - llama OpenAI con key secreta
    - guarda en DB con service_role
    - devuelve respuesta al cliente
```

El patrón clave: **Edge Functions tienen acceso a `SUPABASE_SERVICE_ROLE_KEY`** (que jamás exponés al cliente). Esto te deja hacer operaciones privilegiadas de forma segura.

### Limitaciones a saber

- **Timeout**: 150 segundos max (Supabase). Para tareas largas, usar background job.
- **Memoria**: 256 MB default, ajustable. Para procesamiento pesado (ML local), no alcanza.
- **Cold start**: primer request después de inactividad tarda más.
- **Sin estado persistente**: no podés guardar variables entre requests. Usá DB o KV store.

### Precios 2026

Plan Free: 500k invocaciones/mes + 2 GB de egress.
Plan Pro: 2M invocaciones/mes incluidas; $2 por 1M extras.

Para comparar: Vercel/Netlify Functions cuestan similar. Cloudflare Workers es más barato pero integración con Supabase más manual.

### Setup local con Supabase CLI

Para desarrollar EFs en tu máquina:

```bash
npm install -g supabase
supabase login
supabase link --project-ref xxx  # xxx = id de tu proyecto
supabase functions new hello-world
```

Esto crea carpeta `supabase/functions/hello-world/index.ts` con template:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name } = await req.json()
  return new Response(JSON.stringify({ message: `Hello ${name}!` }), {
    headers: { "Content-Type": "application/json" }
  })
})
```

Testeás local:

```bash
supabase functions serve hello-world
# En otra terminal:
curl -X POST http://localhost:54321/functions/v1/hello-world \
  -H "Content-Type: application/json" \
  -d '{"name":"Juan"}'
```

Deploy:

```bash
supabase functions deploy hello-world
```

Listo, tu función está en producción.

### Invocar desde el cliente

```javascript
const { data, error } = await supabase.functions.invoke('hello-world', {
  body: { name: 'Juan' }
});
```

Supabase agrega automáticamente el header con el JWT del usuario — la función puede saber quién llamó.
$md$,
    0, 50,
$md$**Creá y desplegá tu primera Edge Function.**

1. Instalá Supabase CLI (si no lo hiciste)
2. `supabase functions new hola-mundo`
3. Editá `index.ts` para que devuelva `{"mensaje": "Hola desde edge functions en [hora actual]"}`
4. `supabase functions deploy hola-mundo`
5. Desde tu frontend (o curl), invocá la función
6. Verificá que devuelve la respuesta

Screenshot del curl/fetch y de la respuesta.$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es la principal ventaja de serverless sobre un servidor tradicional?',
   '["Es más rápido siempre", "No pagás cuando no hay tráfico, escala automático, cero mantenimiento de infra", "No tiene límites", "Es más lindo"]'::jsonb,
   1, 0, 'Serverless = pay-per-use + auto-scale + managed. Ideal para tráfico variable y equipos chicos.'),
  (v_lesson_id, '¿Qué runtime usan las Edge Functions de Supabase?',
   '["Node.js", "Deno (TypeScript nativo, imports por URL, web standards)", "Python", "Go"]'::jsonb,
   1, 1, 'Supabase eligió Deno por su modernidad, seguridad y compatibilidad con estándares web.'),
  (v_lesson_id, '¿Cuándo NO conviene una Edge Function?',
   '["Webhooks de Stripe", "Tareas que duran minutos/horas o requieren WebSockets persistentes", "API wrappers", "Cron de limpieza diaria"]'::jsonb,
   1, 2, 'Timeout de ~150s y sin estado persistente limitan workloads largos. Para eso, backend tradicional.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Llamar OpenAI/Claude desde Edge Function',
$md$## El caso de uso #1 en 2026: proxy seguro a LLMs

Nunca pongas la API key de OpenAI/Claude en tu frontend. Alguien inspecciona la red, la roba, y te vacía la cuenta.

La solución: Edge Function que actúa de **proxy** (intermediario). Tu frontend la llama; ella llama al LLM con tu key secreta.

### Setup: guardar la key como secret

```bash
supabase secrets set OPENAI_API_KEY=sk-xxxxx
```

Esto la guarda encriptada. Las funciones la leen con `Deno.env.get('OPENAI_API_KEY')`.

**Nunca pongas la key directamente en el código fuente.**

### Edge Function básica para OpenAI

Creás `supabase/functions/chat/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Preflight OPTIONS (requerido para CORS desde browser)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Verificar auth
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    )
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders })
    }

    // 2. Leer prompt del body
    const { mensaje } = await req.json()

    // 3. Llamar OpenAI
    const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4.1-mini',
        messages: [
          { role: 'system', content: 'Sos un asistente amable.' },
          { role: 'user', content: mensaje }
        ]
      }),
    })

    const openaiJson = await openaiRes.json()
    const respuesta = openaiJson.choices[0].message.content

    // 4. (opcional) guardar en DB el chat
    const adminSupabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    await adminSupabase.from('chat_history').insert({
      user_id: user.id,
      mensaje,
      respuesta
    })

    return new Response(JSON.stringify({ respuesta }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: corsHeaders,
    })
  }
})
```

Deploy:

```bash
supabase functions deploy chat
```

Desde tu app:

```javascript
const { data, error } = await supabase.functions.invoke('chat', {
  body: { mensaje: 'Cuéntame un chiste' }
});
console.log(data.respuesta);
```

Todo se resuelve server-side. La key nunca toca el browser.

### Streaming de respuestas (UX moderna)

Los LLMs generan tokens de a uno — podés mostrar la respuesta mientras se genera (como hace ChatGPT).

```typescript
const openaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  headers: { /* ... */ },
  body: JSON.stringify({
    model: 'gpt-4.1-mini',
    messages: [...],
    stream: true // ← clave
  }),
})

// Pasar el stream directamente al cliente
return new Response(openaiRes.body, {
  headers: { 'Content-Type': 'text/event-stream' },
})
```

Cliente lee el stream con `ReadableStream`:

```javascript
const response = await fetch('/functions/v1/chat', {...});
const reader = response.body.getReader();
const decoder = new TextDecoder();
while (true) {
  const { value, done } = await reader.read();
  if (done) break;
  const chunk = decoder.decode(value);
  // Agregás chunk a la UI
}
```

### Pattern: rate limiting por usuario

Evitar que un usuario agote tu cuota de OpenAI:

```typescript
// Antes de llamar OpenAI
const { count } = await adminSupabase
  .from('chat_history')
  .select('*', { count: 'exact', head: true })
  .eq('user_id', user.id)
  .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString())

if (count >= 50) {
  return new Response('Rate limit: max 50 mensajes/hora', { status: 429 })
}
```

### Cost tracking

Registrar cuánto te costó cada llamada:

```typescript
const tokensUsed = openaiJson.usage.total_tokens
const cost = tokensUsed * 0.00000015 // precio 2026 gpt-4.1-mini

await adminSupabase.from('llm_costs').insert({
  user_id: user.id,
  model: 'gpt-4.1-mini',
  tokens: tokensUsed,
  cost_usd: cost,
})
```

Al fin de mes vas al panel y ves quién consumió cuánto.

### Llamar Claude

Similar a OpenAI, con URL distinta:

```typescript
const claudeRes = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: {
    'x-api-key': Deno.env.get('ANTHROPIC_API_KEY') ?? '',
    'anthropic-version': '2023-06-01',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model: 'claude-haiku-4-5',
    max_tokens: 1024,
    messages: [
      { role: 'user', content: mensaje }
    ],
    system: 'Sos un asistente amable.'
  }),
})

const claudeJson = await claudeRes.json()
const respuesta = claudeJson.content[0].text
```

### Patrón "tools": dejar al LLM decidir qué hacer

Los modelos de 2026 (GPT-4.1, Claude 4.X) pueden elegir entre herramientas que vos le das:

```typescript
const tools = [
  {
    name: 'buscar_producto',
    description: 'Busca productos en catálogo por query',
    input_schema: {
      type: 'object',
      properties: { query: { type: 'string' } },
      required: ['query']
    }
  },
  {
    name: 'crear_pedido',
    description: 'Crea un pedido nuevo',
    input_schema: { /* ... */ }
  }
]

// El LLM decide qué tool usar. Devuelve JSON indicando cuál + argumentos.
// Vos ejecutás esa tool y le das el resultado en otra llamada.
```

Este es el concepto de "agente" — lo profundizamos en el próximo track.

### CORS: el dolor de cabeza común

Si vas a llamar desde browser, configurá correctamente los headers CORS (Cross-Origin Resource Sharing — permisos para llamar desde otro dominio):

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*', // o tu dominio exacto
  'Access-Control-Allow-Headers': 'authorization, content-type',
}

// Responder al preflight OPTIONS
if (req.method === 'OPTIONS') {
  return new Response('ok', { headers: corsHeaders })
}
```

Sin esto, el browser bloquea la llamada aunque el servidor funcione.
$md$,
    1, 70,
$md$**Creá un chatbot protegido con Edge Function.**

1. Guardá tu OPENAI_API_KEY como secret:
   `supabase secrets set OPENAI_API_KEY=sk-xxx`
2. Creá function `chat` con el código del ejemplo
3. Deploy: `supabase functions deploy chat`
4. En tu frontend (simple HTML o Lovable), hacé un input + botón "Enviar"
5. Al submit, `supabase.functions.invoke('chat', { body: { mensaje } })`
6. Mostrá la respuesta
7. Bonus: agregá rate limiting (máx 10 por hora por usuario)

Screenshot del chatbot funcionando y del código.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Por qué NUNCA debés poner la OpenAI API key en el frontend?',
   '["Es muy larga", "Cualquiera puede inspeccionar la red, robar la key y vaciarte la cuenta", "Los browsers la bloquean", "No funciona"]'::jsonb,
   1, 0, 'Cualquier cosa que va al browser está expuesta. La key debe vivir en server/edge, nunca en cliente.'),
  (v_lesson_id, '¿Para qué sirve el streaming de respuestas LLM?',
   '["Ahorrar dinero", "Mostrar la respuesta a medida que se genera (UX tipo ChatGPT) en vez de esperar el final", "Cifrar datos", "Traducir idiomas"]'::jsonb,
   1, 1, 'Streaming = UX moderna, primer token en <1s. El usuario ve texto apareciendo en vez de pantalla en blanco.'),
  (v_lesson_id, '¿Qué es el patrón "tools" con LLMs?',
   '["Usar muchos modelos a la vez", "El LLM elige qué función ejecutar de un set que le das, con argumentos estructurados", "Comprar plugins", "Usar extensiones del navegador"]'::jsonb,
   1, 2, 'Tools = LLM decide y orquesta. Es la base de los agentes autónomos del próximo track.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Triggers de base de datos y cron jobs',
$md$## Código que corre sin que nadie lo llame

Hasta acá las Edge Functions respondían a requests HTTP. Pero también podés hacer que corran:

1. Cuando pasa algo en la base de datos (insert, update, delete)
2. Cada X tiempo (cron)

### Database triggers: reaccionar a cambios

Postgres tiene "triggers" que ejecutan código cuando algo pasa en una tabla. Supabase te permite que esa ejecución **llame a una Edge Function**.

**Caso típico**: cuando se inserta un nuevo cliente → mandar email de bienvenida.

Setup:

1. Creás la Edge Function `send-welcome-email`
2. En Dashboard → Database → Functions → creás un webhook trigger que llama a la EF

O por SQL:

```sql
-- Función que llama a la Edge Function
CREATE OR REPLACE FUNCTION notify_new_user()
RETURNS TRIGGER AS $body$
DECLARE
  request_id BIGINT;
BEGIN
  SELECT net.http_post(
    url := 'https://xxx.supabase.co/functions/v1/send-welcome-email',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer SERVICE_ROLE_KEY"}'::jsonb,
    body := jsonb_build_object('user_id', NEW.id, 'email', NEW.email)
  ) INTO request_id;
  RETURN NEW;
END;
$body$ LANGUAGE plpgsql;

-- Trigger que ejecuta la función al insertar
CREATE TRIGGER on_new_profile
AFTER INSERT ON profiles
FOR EACH ROW EXECUTE FUNCTION notify_new_user();
```

Requiere extensión `pg_net` habilitada.

### Supabase Database Webhooks (más simple)

Alternativa gráfica sin SQL:

1. Dashboard → Database → Webhooks
2. "Create a new hook"
3. Tabla: `profiles`
4. Event: INSERT
5. URL: `https://xxx.supabase.co/functions/v1/send-welcome-email`
6. Guardás

Mucho más rápido y manejable por interfaz.

### Realtime: alternativa a triggers

Otra opción: tu frontend escucha cambios en tiempo real y reacciona. No involucra Edge Function.

```javascript
supabase
  .channel('clients-listener')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'clientes' },
    (payload) => {
      console.log('Nuevo cliente:', payload.new);
      // Acción en UI
    })
  .subscribe();
```

Cuándo usar:
- **Realtime**: UI reactiva, colaboración en vivo, chat
- **Database webhook + EF**: acciones del servidor (email, integraciones, workflows)

### Cron jobs: tareas programadas

Supabase tiene integración con **pg_cron** (extensión PostgreSQL). Ejecuta funciones SQL o llama EFs a intervalos fijos.

Habilitar extensión:

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

Programar una EF que corra cada 6h:

```sql
SELECT cron.schedule(
  'daily-digest',          -- nombre
  '0 */6 * * *',           -- cron expression: cada 6h en punto
  $$
    SELECT net.http_post(
      url := 'https://xxx.supabase.co/functions/v1/daily-digest',
      headers := '{"Authorization": "Bearer SERVICE_ROLE_KEY"}'::jsonb
    );
  $$
);
```

**Expresiones cron comunes**:

| Cron | Significado |
|---|---|
| `* * * * *` | Cada minuto |
| `0 * * * *` | Cada hora en punto |
| `0 9 * * *` | Cada día a las 9am UTC |
| `0 9 * * 1` | Cada lunes a las 9am UTC |
| `*/15 * * * *` | Cada 15 min |
| `0 0 1 * *` | El primero de cada mes a medianoche |

**Tip 2026**: Supabase cron usa UTC. Si querés 9am de Bogotá, son las 14:00 UTC.

### Casos de uso de cron + EF

1. **Digest diario**: cada mañana, resumir actividad de la app, mandar email a admins
2. **Cleanup**: borrar soft-deleted hace >30 días, notificaciones viejas, logs
3. **Scheduling de emails**: "mandale este email a cliente X el 15 del mes"
4. **Sync con APIs externas**: cada hora, pull data de Stripe / Shopify / CRM
5. **Backup custom**: daily dump a S3

### Pattern: background jobs cortos con trigger + EF

Cuando una request del cliente requiere proceso largo, no lo hagas síncrono — respondé rápido y procesá en background:

```
Cliente → POST /generar-reporte (EF rápida que solo crea fila en `jobs` con status=pending)
             ↓ devuelve job_id en <100ms
Cliente hace polling o escucha realtime cambios en `jobs`

En paralelo:
Trigger DB on INSERT en `jobs` → llama a EF `process-job`
EF procesa (LLM, scraping, etc) → update jobs.status='done' + result
```

Esto es el patrón "async CE generation" que usamos en CSM Center (ver memoria project).

### Escribir logs útiles

```typescript
console.log(`[chat] user ${user.id}, mensaje length ${mensaje.length}`)
console.error(`[chat] OpenAI error:`, err)
```

En Dashboard → Edge Functions → [tu función] → Logs, ves todos los `console.*` con timestamp y nivel.

**Buena práctica 2026**: logs estructurados (JSON):

```typescript
console.log(JSON.stringify({
  event: 'chat_completed',
  user_id: user.id,
  tokens: openaiJson.usage.total_tokens,
  model: 'gpt-4.1-mini',
  duration_ms: Date.now() - startTime
}))
```

Te deja filtrar/analizar con herramientas como Axiom, Datadog.

### Testing: qué testear y cómo

- **Unit tests**: funciones puras internas, con Deno's `deno test`
- **Integration tests**: llamás a la EF con curl/fetch desde test, verificás respuesta
- **Mocking**: simulás respuestas de OpenAI/servicios externos para no pagar por test

```typescript
// test.ts
import { assertEquals } from "https://deno.land/std/assert/mod.ts"

Deno.test("valida input", async () => {
  const res = await fetch('http://localhost:54321/functions/v1/chat', {
    method: 'POST',
    body: JSON.stringify({}), // sin mensaje
  })
  assertEquals(res.status, 400)
})
```

### CI/CD: deploy automático

Ideal: cada push a `main` en GitHub → deploy automático de EFs.

Opciones:

1. **GitHub Actions** + `supabase functions deploy` en el workflow
2. **Vercel** no soporta Supabase EFs (son cosas distintas); deployás por separado
3. **Supabase branching** (beta 2026): cada PR tiene su propia instancia Supabase con EFs deployadas
$md$,
    2, 70,
$md$**Armá cron job + trigger en tu proyecto.**

Parte A (cron):
1. Creá EF `daily-cleanup` que borre notas con `deleted_at < NOW() - INTERVAL '30 days'`
2. Programala con pg_cron para correr cada día a las 3am
3. Insertá notas de prueba con `deleted_at` viejo
4. Esperá el cron (o ejecutá manual con `SELECT net.http_post(...)`)
5. Verificá que se borraron

Parte B (trigger):
1. Creá EF `log-new-user` que loggea en Slack/Discord cuando se crea un profile
2. Creá Database Webhook que llama esa EF en INSERT en profiles
3. Signup usuario nuevo → verificá que llegó el mensaje$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo conviene un Database Webhook en vez de Realtime?',
   '["Siempre Realtime", "Para acciones server-side (email, integraciones, workflows) que deben ocurrir sí o sí — Realtime solo sirve para UI", "Son iguales", "Nunca"]'::jsonb,
   1, 0, 'Realtime = UI reactiva. Webhooks + EF = acciones server-side garantizadas.'),
  (v_lesson_id, '¿Qué extensión de Postgres permite programar tareas cron en Supabase?',
   '["pg_schedule", "pg_cron", "pg_timer", "pg_tasks"]'::jsonb,
   1, 1, 'pg_cron es la extensión estándar. Se combina con pg_net para llamar Edge Functions.'),
  (v_lesson_id, '¿Qué patrón usar para procesos largos disparados por request del cliente?',
   '["Bloquear el request hasta que termine", "Crear fila en tabla jobs (status=pending), responder rápido con job_id, procesar async por trigger+EF, cliente escucha realtime", "Ignorar el request", "Llamar varias veces"]'::jsonb,
   1, 2, 'Async job pattern: respuesta inmediata + procesamiento en background + notificación via realtime. Evita timeouts.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Patrones avanzados: vector DB y RAG',
$md$## Supabase como base de datos para IA

Una de las tendencias más fuertes de 2025-2026: **RAG (Retrieval-Augmented Generation)**, que vimos en n8n. La parte de "Retrieval" se hace con **vector databases**.

Supabase incluye **pgvector**, una extensión de Postgres que convierte cualquier tabla en vector DB. Resultado: tenés una sola base para todo.

### ¿Qué es un embedding?

Un **embedding** es un vector (lista de números) que representa el "significado" de un texto. Textos similares → vectores cercanos en el espacio.

Ejemplo simplificado:
- "gato" → [0.8, 0.1, 0.3, ...]
- "felino" → [0.82, 0.09, 0.31, ...] (muy parecido)
- "auto" → [0.1, 0.7, 0.2, ...] (diferente)

Los embeddings típicos tienen 1536 o 3072 dimensiones (con OpenAI text-embedding-3-small/large).

Los generás con APIs:
- OpenAI: `text-embedding-3-small` ($0.02 / 1M tokens)
- Voyage AI: `voyage-2` (recomendado 2026, mejor para recuperación)
- Cohere embed-v3: alternativa sólida
- Locales: `nomic-embed-text` con Ollama (gratis)

### Setup pgvector en Supabase

```sql
-- Habilitar extensión
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabla con columna vector
CREATE TABLE documentos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contenido TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  embedding VECTOR(1536),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para búsqueda rápida (ivfflat o hnsw)
CREATE INDEX ON documentos
USING hnsw (embedding vector_cosine_ops);
```

### Flujo RAG completo

```
1. Cargás tus documentos (FAQs, manuales, PDFs)
     ↓
2. Partís en chunks (~500 tokens cada uno)
     ↓
3. Generás embedding de cada chunk con OpenAI
     ↓
4. Guardás chunk + embedding en `documentos`
     ↓
5. Usuario hace pregunta
     ↓
6. Generás embedding de la pregunta
     ↓
7. Query SQL: "dame los 5 documentos más similares al embedding de la pregunta"
     ↓
8. Pasás esos 5 al LLM como contexto + la pregunta
     ↓
9. LLM responde fundado en tus docs
```

### Código: insertar documento

Edge Function `ingest-doc`:

```typescript
const { contenido } = await req.json()

// 1. Chunk (simple: por párrafos o por longitud)
const chunks = chunkText(contenido, 500)

// 2. Para cada chunk, generar embedding
for (const chunk of chunks) {
  const embRes = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST',
    headers: { /* auth */ },
    body: JSON.stringify({
      model: 'text-embedding-3-small',
      input: chunk
    })
  })
  const embJson = await embRes.json()
  const embedding = embJson.data[0].embedding

  // 3. Insertar
  await supabase.from('documentos').insert({
    contenido: chunk,
    embedding: embedding
  })
}
```

### Código: buscar documentos similares

```typescript
const { pregunta } = await req.json()

// 1. Embed de la pregunta
const qEmb = await generateEmbedding(pregunta)

// 2. Query similar
const { data: docs } = await supabase.rpc('match_documents', {
  query_embedding: qEmb,
  match_count: 5
})

// 3. Llamar LLM con contexto
const contexto = docs.map(d => d.contenido).join('\n\n')

const resp = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  body: JSON.stringify({
    model: 'gpt-4.1-mini',
    messages: [
      {
        role: 'system',
        content: `Responde basándote SOLO en este contexto. Si no está, decí "no tengo esa información".\n\nContexto:\n${contexto}`
      },
      { role: 'user', content: pregunta }
    ]
  })
})
```

La función SQL `match_documents`:

```sql
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding VECTOR(1536),
  match_count INT
) RETURNS TABLE (id UUID, contenido TEXT, similitud FLOAT)
LANGUAGE SQL STABLE AS $body$
  SELECT
    id,
    contenido,
    1 - (embedding <=> query_embedding) AS similitud
  FROM documentos
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
$body$;
```

`<=>` es el operador de distancia coseno — mide qué tan "cerca" están los vectores.

### Tips de RAG que funcionan

**1. Chunking bien hecho**: ni muy chico (pierde contexto) ni muy grande (imprecisión). 300-500 tokens es el sweet spot. Respetá párrafos, no cortes mid-oración.

**2. Metadatos útiles**: guardá `{fuente: 'manual-v2', seccion: '3.2', fecha: '...'}` en `metadata`. Podés filtrar por eso además de similitud.

**3. Híbrido con full-text search**: combiná similitud vectorial con búsqueda tradicional. Supabase soporta full-text (tsvector) junto a pgvector.

**4. Re-ranking**: los 20 más similares → los pasás a un modelo "reranker" (como Cohere Rerank) que los reordena mejor → te quedás con los 5 top. Mejora mucho la calidad.

**5. Evaluación**: construí un set de 30 preguntas con respuestas esperadas. Cada vez que cambiás el sistema, corré el set y medís calidad.

### Cuándo NO usar RAG

- **Datos que cambian constantemente**: si tus docs cambian cada hora, re-embedding es caro
- **Preguntas que requieren razonamiento matemático / código**: LLM no "recupera", ejecuta
- **Contextos muy chicos**: si tenés 5 FAQs, pegalos directamente al prompt y evitás toda la infra

### Alternativas a pgvector

Si crecés mucho:

- **Pinecone**: SaaS dedicado, muy performante, $70+/mes
- **Weaviate**: open source, self-hosted, potente
- **Qdrant**: open source, Rust, rápido

Pero: hasta ~1M de documentos, pgvector en Supabase aguanta perfecto y te evita mantener otra base.

### Caso 2026: "chat con tus docs"

Es el MVP que más se construye:

- Usuario sube PDFs de su empresa
- Sistema los ingesta (chunk + embed + store)
- Hay un chat donde pregunta cosas; responde basado en los docs
- Agregás permisos: cada usuario/org solo busca en sus propios docs (con RLS en tabla documentos)

Negocios reales que usan esto:
- Legaltech: chat con contratos
- HR: chat con políticas de RRHH
- Customer support: chat con documentación del producto
- Educación: chat con apuntes del curso

### Costos aproximados

Para 10k chunks de ~500 tokens:
- Embeddings (una vez): 5M tokens × $0.02 = $0.10
- Storage en Supabase: casi cero
- Por query: 1 embedding de la pregunta ($0.00001) + 1 GPT call ($0.001-0.01)

Un RAG con 10k docs y 1000 preguntas/día cuesta ~$30/mes. Accesible incluso para MVPs.
$md$,
    3, 70,
$md$**Construí un mini-RAG funcional.**

1. Habilitá extensión vector en Supabase
2. Creá tabla `documentos` con columna embedding VECTOR(1536)
3. Creá función `match_documents`
4. Edge Function `ingest` que recibe texto y lo chunkea + embeddea + guarda
5. Edge Function `ask` que recibe pregunta y devuelve respuesta usando RAG
6. Ingestá 3-5 documentos propios (copiá tus FAQs, manuales, lo que sea)
7. Hacé 3 preguntas y verificá que responde con info de tus docs

Screenshot de las preguntas + respuestas y del código de las EFs.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es un embedding?',
   '["Un tipo de password", "Un vector numérico que representa el significado semántico de un texto — textos similares tienen vectores cercanos", "Una foto", "Un archivo PDF"]'::jsonb,
   1, 0, 'Embedding = "significado en números". Los usamos para búsqueda semántica, no solo de palabras exactas.'),
  (v_lesson_id, '¿Qué operador usa pgvector para distancia coseno?',
   '["<<>>", "<=>", "~=", "=="]'::jsonb,
   1, 1, 'El operador <=> mide distancia coseno entre vectores. Menor distancia = más similares.'),
  (v_lesson_id, '¿Cuándo NO tiene sentido implementar RAG?',
   '["Cuando tenés muchos docs", "Cuando solo tenés 5 FAQs — los podés pegar directo al prompt sin toda la infra vectorial", "Cuando los docs son PDFs", "Nunca es buena idea"]'::jsonb,
   1, 2, 'RAG tiene costo de setup y complejidad. Para <20 docs, pegarlos directo al prompt es más simple y efectivo.');

  RAISE NOTICE '✅ Módulo Edge Functions cargado — 4 lecciones + 12 quizzes';
END $$;
