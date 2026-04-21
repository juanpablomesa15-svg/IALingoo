-- =============================================
-- IALingoo — Track "Automatización" / Módulo "n8n desde cero"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'n8n';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo n8n desde cero no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, '¿Qué es n8n y por qué te va a cambiar la vida?',
$md$## Automatización sin código

n8n (pronunciado "n-eight-n", se pronuncia en inglés) es una herramienta de automatización visual. Te permite conectar apps (Gmail, WhatsApp, Notion, Google Sheets, ChatGPT, etc.) y definir flujos como:

> Cuando llegue un lead nuevo por el formulario → guardalo en Sheets → mandale un email de bienvenida generado con Claude → creá una tarea en Notion → avisame por WhatsApp.

Todo eso sin escribir código. Arrastrás "nodos" (cajitas que representan acciones) y los conectás con líneas.

### ¿n8n vs Zapier vs Make?

Las tres son herramientas de automatización visual. Diferencias clave en 2026:

| Feature | n8n | Zapier | Make (ex-Integromat) |
|---|---|---|---|
| Precio free | Self-hosted gratis o cloud $20/mes | $20/mes (100 runs) | $9/mes (1000 runs) |
| Complejidad | Media-alta (pero potente) | Muy simple | Media |
| Self-hosted | ✅ Sí | ❌ No | ❌ No |
| Open source | ✅ Sí | ❌ No | ❌ No |
| Nodo Code (JS) | ✅ Sí | Básico | ✅ Sí |
| Integraciones IA | ✅ Excelente (nativas) | OK | OK |
| Community | Enorme, GitHub activo | Pago para soporte | Buena |

**Regla 2026**: si tu workflow es simple y solo querés hacerlo rápido → Zapier. Si querés potencia, IA integrada, control total y no pagar por cada ejecución → **n8n**.

### Cloud vs Self-hosted

n8n se puede usar de dos formas:

**n8n Cloud** ([n8n.io](https://n8n.io))
- Plan Starter: $20/mes — 2500 ejecuciones
- Plan Pro: $50/mes — 10k ejecuciones
- No tenés que instalar nada
- Ideal para empezar

**Self-hosted**
- Instalás n8n en tu servidor (o laptop) con Docker
- **Gratis**, ejecuciones ilimitadas
- Requiere saber configurar servidor
- En 2026 es súper fácil con [Railway](https://railway.app), [Render](https://render.com) o [Hostinger VPS](https://hostinger.com) — 5 minutos de setup por $5-10/mes

**Recomendación para este track**: empezá con n8n Cloud (trial 14 días). Cuando tengas 3-4 flujos funcionando, migrás a self-hosted.

### La lógica de n8n: nodos + conexiones

Todo workflow en n8n tiene:

1. **Trigger** (disparador): qué lo inicia
   - Webhook (URL pública que recibe datos)
   - Schedule (cada X tiempo)
   - Email recibido / WhatsApp recibido
   - Cambio en Sheets / Notion / etc.

2. **Nodos de acción**: qué hace
   - Llamar API de OpenAI / Claude
   - Leer/escribir en Sheets
   - Mandar email / WhatsApp
   - Transformar datos (JavaScript)

3. **Conexiones** (líneas): cómo pasa la data de un nodo al siguiente

Ejemplo visual:

```
[Webhook trigger] → [Claude: clasifica intención] → [Switch por intención]
                                                    ├→ [Email de bienvenida]
                                                    ├→ [Agendar llamada Calendly]
                                                    └→ [Ticket a Notion]
```

### Casos reales para empezar

Lo que vas a construir en este track:

- **Módulo 1** (este): tu primer workflow — Gmail → Sheets
- **Módulo 2**: webhooks + WhatsApp Business + ChatGPT
- **Módulo 3**: sistema completo de leads con scoring IA, CRM y automatización de ventas 24/7

### Por qué n8n es la elección 2026

- **IA nativa**: nodos para OpenAI, Claude, Gemini, HuggingFace, Ollama (modelos locales)
- **Self-hosted**: tus datos nunca salen de tu servidor
- **400+ integraciones** que crecen cada semana
- **Comunidad activa**: el foro tiene templates para casi cualquier flujo
- **Precio**: el más competitivo para volumen

Si vas a construir un negocio basado en automatización en 2026, n8n es la plataforma.
$md$,
    0, 50,
$md$**Crea tu cuenta de n8n Cloud y explorá.**

1. Ir a [n8n.io](https://n8n.io) y hacer signup (trial 14 días gratis)
2. Completá el onboarding
3. Abrí la pestaña **Templates** del dashboard
4. Filtrá por "OpenAI" y abrí 2-3 plantillas para entender la estructura
5. No ejecutes nada todavía — solo observá cómo están conectados los nodos$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es la principal ventaja de n8n sobre Zapier?',
   '["n8n es más viejo", "n8n permite self-hosted, es open source y tiene mejor integración IA", "n8n solo funciona en Mac", "n8n requiere programar siempre"]'::jsonb,
   1, 0, 'n8n = open source + self-hosted + mejor IA nativa. Zapier es más simple pero pagás por ejecución.'),
  (v_lesson_id, '¿Qué es un trigger en n8n?',
   '["Un error", "El nodo que inicia el workflow (webhook, schedule, evento externo)", "Un tipo de pago", "El final del flujo"]'::jsonb,
   1, 1, 'Trigger = disparador. Puede ser webhook, schedule, un mail que llega, un cambio en Sheets, etc.'),
  (v_lesson_id, '¿Cuál es la recomendación para empezar este track?',
   '["Self-hosted desde el día uno", "n8n Cloud trial 14 días, migrás después cuando tengas flujos estables", "Solo usar Zapier", "Programar todo en Python"]'::jsonb,
   1, 2, 'Cloud = sin fricción para empezar. Después migrás a self-hosted cuando entiendas el producto.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Tu primer workflow: Gmail → Sheets',
$md$## Hello World de la automatización

Vamos a construir algo simple pero útil: cada email que te llegue con cierta etiqueta, se guarda automáticamente en una hoja de Google Sheets.

Úsalo para: tracking de leads, facturas, pedidos, feedback de clientes, lo que sea que llegue por email y quieras tener en una planilla.

### Paso 1: preparar Google Sheets

1. Entrá a [sheets.google.com](https://sheets.google.com)
2. Creá hoja nueva llamada "Emails importantes"
3. Primera fila (encabezados): `fecha | remitente | asunto | cuerpo`

### Paso 2: nuevo workflow en n8n

1. En tu dashboard n8n, tocá **"+ New workflow"**
2. Vas a ver un canvas vacío con un "+ Add first step"
3. Ponele nombre al workflow (arriba a la izquierda): "Gmail → Sheets leads"

### Paso 3: el trigger de Gmail

1. Click en "+ Add first step"
2. Buscá "Gmail" → elegí **"Gmail Trigger"**
3. Te pide **credenciales**: conectar tu cuenta Google (OAuth — protocolo estándar para permisos entre apps — te abre ventana de Google para autorizar)
4. Configurá:
   - **Event**: Message Received
   - **Filters**: label:"Leads" (solo procesa emails con esa etiqueta)
   - **Poll Time**: Every 5 minutes (cada cuánto revisa Gmail)
5. Click en **"Execute step"** para testear

Si todo está bien, te aparece un JSON con los emails encontrados. Eso es la data que va a pasar al siguiente nodo.

### Paso 4: agregar el nodo de Sheets

1. Click en el "+" después del nodo Gmail
2. Buscá "Google Sheets" → elegí **"Append or Update Row"**
3. Conectá credenciales Google (reutiliza las de Gmail)
4. Configurá:
   - **Document**: buscá "Emails importantes"
   - **Sheet**: Sheet1 (o cómo se llame la pestaña)
   - **Operation**: Append
   - **Columns mode**: Map each column manually
5. Mapear columnas arrastrando del JSON del nodo anterior:
   - `fecha` → `{{ $json.internalDate }}`
   - `remitente` → `{{ $json.from.value[0].address }}`
   - `asunto` → `{{ $json.subject }}`
   - `cuerpo` → `{{ $json.snippet }}`

**Tip**: la sintaxis `{{ $json.xxx }}` accede a los datos que llegaron del nodo anterior. n8n te autocompleta si tocás el ícono de "expression".

### Paso 5: activar el workflow

1. Click en **"Execute workflow"** para hacer una prueba completa
2. Si ves la fila nueva en Sheets → funciona
3. Arriba a la derecha, togglear **"Inactive" → "Active"**
4. Ahora corre automáticamente cada 5 min

### Entendiendo lo que acabás de hacer

Acabás de crear un sistema que:

- Monitorea tu Gmail 24/7
- Detecta emails con cierta etiqueta
- Los registra en una planilla accesible desde cualquier lado

**Este patrón** (trigger externo → acción en otra app) es el 60% de todos los flujos útiles.

### Debug cuando algo no funciona

**Error de credenciales** → reconectá Google OAuth
**No detecta emails** → revisá que la etiqueta exista en Gmail y tenga emails
**Datos mal mapeados** → abrí el nodo Gmail trigger, toca "Execute" y mirá qué JSON devuelve — copiá el campo exacto
**Poll Time 0 o muy alto** → default 5 min está bien

### Limits del trial

El trial de n8n Cloud permite:
- 2500 ejecuciones/mes (más que suficiente para flujos personales)
- Workflows ilimitados
- Todas las integraciones

Cuando se termine, pagás $20/mes o migrás a self-hosted.

### Variantes del mismo patrón

Una vez que entendés el esqueleto Gmail → Sheets, lo aplicás a variaciones:

- Calendly → Sheets (registra citas agendadas)
- Stripe → Sheets (registra ventas)
- Typeform → Sheets + Email al equipo
- WhatsApp (Evolution API) → Sheets + Claude análisis de sentimiento
$md$,
    1, 60,
$md$**Construí tu primer workflow funcional.**

1. Creá etiqueta "IALingoo-test" en Gmail y aplicala a 2-3 emails
2. Creá la hoja Sheets "Emails importantes" con los 4 encabezados
3. Armá el workflow Gmail Trigger → Google Sheets Append
4. Testealo con "Execute workflow"
5. Activalo
6. Mandate un email de prueba con la etiqueta — esperá 5 min y verificá que apareció en Sheets
7. Hacé screenshot del Sheets con las filas y del canvas n8n con los nodos$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, 'En n8n, ¿cómo accedés a los datos del nodo anterior?',
   '["{{ $json.campo }}", "$data[0]", "@@campo@@", "echo campo"]'::jsonb,
   0, 0, 'La sintaxis de expresiones en n8n es {{ $json.campo }} — accede al JSON que llega del nodo previo.'),
  (v_lesson_id, '¿Qué hace el Poll Time de un Gmail Trigger?',
   '["Borra emails", "Define cada cuánto n8n revisa Gmail en busca de nuevos mensajes", "Manda encuestas", "Cifra los emails"]'::jsonb,
   1, 1, 'Poll time = frecuencia de chequeo. 5 min es un buen default; más frecuente gasta más ejecuciones.'),
  (v_lesson_id, '¿Qué hace el modo "Append" en el nodo Google Sheets?',
   '["Borra la hoja", "Agrega una nueva fila al final", "Sobreescribe la primera fila", "Envía email"]'::jsonb,
   1, 2, 'Append = agrega fila nueva. Update sobreescribe; UpsertOrUpdate combina ambos según condición.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Nodos esenciales: Set, IF, Switch y Code',
$md$## Los bloques de lego que usás en todos los flujos

Una vez que dominás 4 nodos, podés construir el 80% de los flujos del mundo real. Estos son:

### 1. Set (asignar valores)

El nodo **Set** te deja crear o modificar campos del JSON que viaja entre nodos. Úsalo para:

- Limpiar / renombrar campos
- Agregar campos calculados
- Normalizar datos antes de usarlos

Ejemplo: llega `{{ $json.email }}` con mayúsculas mezcladas ("Juan@EMAIL.com") y querés normalizarlo:

```
nombre_normalizado: {{ $json.email.toLowerCase().trim() }}
```

El Set es como un "intermediario" que organiza los datos antes de mandarlos al próximo paso.

### 2. IF (condicional binario)

El nodo **IF** divide el flujo en dos caminos: TRUE y FALSE.

Ejemplo: si el lead viene con email corporativo (no @gmail, @hotmail), mandalo al equipo de enterprise. Sino, al flujo de autoservicio.

Configuración:
- Value 1: `{{ $json.email }}`
- Operation: "ends with"
- Value 2: "@gmail.com"

Si termina en @gmail (TRUE) → sale por el output verde.
Si no termina en @gmail (FALSE) → sale por el output rojo.

### 3. Switch (condicional múltiple)

**Switch** es como IF pero con más caminos. Ideal para clasificar por categorías.

Ejemplo: el usuario eligió una opción del formulario. Según la opción, distintas rutas:

- "Consulta general" → email al equipo soporte
- "Quiero demo" → agendar Calendly + email con link
- "Pricing" → email con PDF de precios
- "Partnership" → email al founder
- Default (cualquier otra cosa) → email genérico

Configurás Switch con valor de entrada y las opciones. Cada salida se conecta a un nodo distinto.

### 4. Code (JavaScript)

El nodo **Code** es el comodín. Cuando ningún nodo estándar hace lo que querés, escribís JavaScript.

Casos típicos:

- Formatear fecha en zona horaria específica
- Calcular lead score con lógica custom
- Parsear texto con regex
- Juntar datos de múltiples nodos previos

Ejemplo — calcular lead score:

```javascript
const data = $input.first().json;

let score = 0;

if (data.email.includes('@gmail.com')) score -= 10;
if (data.empresa && data.empresa.length > 0) score += 20;
if (data.facturacion === 'mas de 1M') score += 50;
if (data.urgencia === 'inmediato') score += 30;

return { json: { ...data, score: score, categoria: score > 50 ? 'hot' : 'warm' } };
```

**Reglas críticas para Code en n8n** (que te vas a encontrar):

- **No usar optional chaining** (`?.`). El runtime de n8n 2026 lo soporta mejor que antes pero para compatibilidad evitá: `obj?.prop`. Usá `obj && obj.prop`.
- **Para llamadas HTTP, no uses `fetch()`**. Usá el nodo HTTP Request por separado, o `this.helpers.httpRequest()` dentro del Code.
- **Debugeá con `console.log()`** y mirá "Execution log" en el sidebar.

### El patrón clásico

La mayoría de los workflows reales combinan estos nodos así:

```
[Trigger] → [Set: limpiar datos] → [IF o Switch: decidir] → ramas distintas
              ↓
           [Code: lógica custom]
              ↓
           [Nodos de acción]
```

### Error handling: qué pasa cuando algo falla

n8n corre los nodos en orden. Si un nodo falla, el workflow se detiene (por default).

Opciones:

- **Continue on Fail** (config del nodo): seguí con el siguiente aunque este falle
- **Error Workflow** (config del workflow): otro workflow se dispara si este falla, mandandote Slack o email

**Tip 2026**: agregá un nodo de "Slack" o "Email" al final del Error Workflow con el mensaje: "Workflow X falló, revisar en n8n URL". Así no te enterás 3 días tarde.
$md$,
    2, 70,
$md$**Agregá lógica a tu workflow Gmail → Sheets.**

1. Entre los nodos Gmail y Sheets, insertá un **Set** que agregue un campo:
   `prioridad: {{ $json.subject.toLowerCase().includes('urgente') ? 'alta' : 'normal' }}`
2. Después, agregá un **IF** con condición: `{{ $json.prioridad }}` equals "alta"
3. Rama TRUE → Sheets "Leads urgentes"
4. Rama FALSE → Sheets "Leads normales"
5. Testealo mandándote un email con "URGENTE" en el asunto
6. Verificá que va a la hoja correcta$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Para qué sirve el nodo Set en n8n?',
   '["Para ejecutar código Python", "Para crear, modificar o limpiar campos del JSON antes de mandarlo al siguiente nodo", "Para borrar la base de datos", "Para enviar emails"]'::jsonb,
   1, 0, 'Set = ajustar/normalizar datos. Es el "intermediario" más usado en n8n.'),
  (v_lesson_id, '¿Cuándo usarías Switch en vez de IF?',
   '["Cuando tenés un solo camino", "Cuando tenés más de 2 ramas posibles (clasificación múltiple)", "Nunca — IF es mejor", "Solo para webhooks"]'::jsonb,
   1, 1, 'IF = 2 ramas (true/false). Switch = 3+ ramas. Úsalo para clasificar por categoría.'),
  (v_lesson_id, 'En el nodo Code de n8n, ¿qué regla de JavaScript es recomendable evitar?',
   '["Usar const", "Usar optional chaining (obj?.prop) por compatibilidad — mejor obj && obj.prop", "Usar return", "Usar if/else"]'::jsonb,
   1, 2, 'El runtime de n8n puede tener inconsistencias con optional chaining. Mejor usar el operador && explícito.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Triggers, Schedule y el nodo HTTP Request',
$md$## Cuándo se dispara, cada cuánto, y cómo llamar a cualquier API

Hasta acá vimos el trigger de Gmail. Pero hay muchos más. Saber elegir el trigger correcto es el 30% de hacer un buen workflow.

### Tipos de triggers en n8n

| Trigger | Cuándo usar |
|---|---|
| **Webhook** | Cuando otra app (form, Stripe, WhatsApp) te manda datos |
| **Schedule** | Cada X minutos / horas / días |
| **Gmail / Outlook / IMAP** | Nuevo email |
| **Calendar** | Nueva cita / evento |
| **Sheets / Airtable / Notion** | Nueva fila / registro |
| **Form** | Formulario de n8n (sin necesidad de web externa) |
| **Manual** | Solo corre cuando lo ejecutás vos (para testing) |
| **Chat** | Usuario escribe en el chatbot embebido de n8n |
| **Cron** | Expresión cron avanzada (ej. "cada lunes a las 9am") |

### Schedule: automatizaciones periódicas

El trigger **Schedule** corre cada X tiempo. Lo más pedido:

- **Reporte diario** a las 9am: lee Sheets, calcula métricas, genera imagen con Chart, manda a Slack
- **Backup semanal**: export de Notion → Drive
- **Scraping** cada hora de un sitio competidor
- **Healthcheck**: ping a tu sitio, si falla → alerta

Configuración:

- **Trigger Interval**: Every X minutes/hours/days/weeks
- **Timezone**: elegí la tuya (America/Bogota, America/Buenos_Aires, etc.)
- **Cron expression** (modo avanzado): `0 9 * * 1-5` = "9am de lunes a viernes"

### Webhook: recibir datos desde afuera

El trigger **Webhook** te da una URL pública. Cualquier app que te mande datos a esa URL dispara el workflow.

Flujo típico:

1. Configurás el webhook en n8n → te da URL tipo `https://tuinstancia.n8n.cloud/webhook/abc123`
2. Pegás esa URL en el panel de la app externa (Stripe, Typeform, Lovable, etc.)
3. Cada vez que esa app tiene un evento, te mandan los datos
4. Tu workflow se dispara con esos datos

En el próximo módulo profundizamos webhooks con WhatsApp y Stripe.

### HTTP Request: el nodo universal

El nodo **HTTP Request** es el más poderoso: te deja llamar a **cualquier API** de internet (API = interfaz de programación, la forma en que dos programas se hablan entre sí).

Ejemplos de uso:

- Llamar a OpenAI/Claude/Gemini (aunque n8n ya tiene nodos nativos)
- Consultar el clima (api.openweathermap.org)
- Postear en LinkedIn (API de LinkedIn)
- Consultar precio de crypto (CoinGecko)
- Usar cualquier API de terceros que no tenga nodo nativo

Configuración:

- **Method**: GET, POST, PUT, DELETE, PATCH
- **URL**: el endpoint (ej. `https://api.openai.com/v1/chat/completions`)
- **Authentication**: None / Basic / OAuth2 / Custom headers
- **Headers**: ej. `Authorization: Bearer sk-xxx`
- **Body**: JSON con los datos a mandar

### Ejemplo: llamar a OpenAI desde HTTP Request

```
Method: POST
URL: https://api.openai.com/v1/chat/completions
Headers:
  Authorization: Bearer sk-xxxxx
  Content-Type: application/json
Body (JSON):
{
  "model": "gpt-4.1-mini",
  "messages": [
    {"role": "user", "content": "{{ $json.texto_usuario }}"}
  ]
}
```

La respuesta llega como JSON; accedés al texto con `{{ $json.choices[0].message.content }}`.

**Nota**: en 2026 es más fácil usar el nodo nativo **OpenAI** (o Claude, o Gemini) que tiene los campos ya mapeados.

### Credenciales: guardá secretos, no los pongas en claro

n8n tiene un sistema de **Credentials**: creás una vez con tu API key (clave secreta para acceder al servicio), se encripta, y los nodos la usan sin que vos pegues la key en cada nodo.

**Reglas críticas**:

- **Nunca pegues API keys en el body del nodo HTTP Request**. Usá el panel "Credentials" de n8n.
- Si cambiás una credential, **guardá el workflow manualmente** — n8n no auto-guarda el workflow en algunos casos.
- Separá credentials por ambiente: `OpenAI-Dev` y `OpenAI-Prod`.

### Rate limiting: no te banees a vos mismo

Muchas APIs tienen límites (ej. OpenAI: 500 requests/min tier 1). Si tu workflow hace 1000 llamadas seguidas, te banean temporalmente.

Soluciones:

- **Wait node**: agregá `Wait 1 second` entre requests
- **Batching**: agrupá items de a 10 con el nodo "Split In Batches"
- **Retry on failure**: configurá cada nodo para reintentar con backoff (espera creciente)

### El patrón "API-first" de 2026

En 2026, el 90% de los workflows potentes usan HTTP Request (o nodos IA nativos) para:

1. Recibir datos (webhook trigger)
2. Procesar con IA (OpenAI/Claude vía HTTP o nodo)
3. Tomar decisión (Switch según respuesta IA)
4. Ejecutar acción (otros HTTP requests a WhatsApp, CRM, etc.)

Este patrón lo construiremos end-to-end en el módulo 3.
$md$,
    3, 70,
$md$**Construí un workflow con trigger Schedule + HTTP Request.**

Objetivo: cada 6 horas, consultar el clima de tu ciudad y mandarte el pronóstico por email.

1. Trigger: Schedule (Every 6 hours)
2. HTTP Request:
   - GET `https://api.open-meteo.com/v1/forecast?latitude=4.7&longitude=-74&current=temperature_2m,weather_code&timezone=auto`
   - (Reemplazá lat/long por tu ciudad)
3. Set node: formatear mensaje `Temperatura actual: {{ $json.current.temperature_2m }}°C`
4. Email node: mandate el mensaje
5. Activá el workflow y esperá 6h (o corré manualmente para testear)$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué trigger usarías para correr un workflow cada lunes a las 9am?',
   '["Webhook", "Schedule con cron expression", "Manual", "Gmail"]'::jsonb,
   1, 0, 'Schedule con cron `0 9 * * 1` = "9am todos los lunes". Perfecto para reportes/backups periódicos.'),
  (v_lesson_id, '¿Por qué conviene usar Credentials en vez de pegar API keys en el nodo?',
   '["Es obligatorio por ley", "Se encripta, se reutiliza, y si rota la key la cambiás en un solo lugar", "Es más rápido escribir", "No sirve para nada"]'::jsonb,
   1, 1, 'Credentials = seguro + reutilizable + único punto de cambio. Nunca pegues keys en clear.'),
  (v_lesson_id, 'Si una API te limita a 500 requests/min, ¿qué hacés en n8n?',
   '["Llamar 1000 a la vez igual", "Usar Split In Batches + Wait entre requests para respetar el límite", "Cambiar de API", "Pagar más"]'::jsonb,
   1, 2, 'Split In Batches + Wait = control de rate. Te evita que te banéen temporalmente.');

  RAISE NOTICE '✅ Módulo n8n desde cero cargado — 4 lecciones + 12 quizzes';
END $$;
