-- =============================================
-- IALingoo — Track "Automatización" / Módulo "Webhooks y APIs"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'n8n';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Webhooks y APIs no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Webhooks: cómo conectar apps que no se conocen',
$md$## El lenguaje universal de las integraciones

Un **webhook** es simplemente una URL pública donde una app manda datos cuando pasa algo. No inventan nada nuevo — son URLs que escuchan.

### Ejemplo cotidiano

- Stripe tiene un evento "checkout completado"
- Vos configurás en Stripe: "cuando pase, avisale a esta URL: `https://miapp.com/webhooks/stripe`"
- Cuando alguien paga, Stripe hace una **petición POST** (forma de enviar datos en internet) a esa URL con toda la info (monto, email, producto)
- Tu servidor (o n8n) recibe esos datos y actúa: envía email, entrega curso, actualiza CRM

**Webhook = push** (la app externa te empuja datos cuando ocurre algo)
**API tradicional = pull** (vos le pedís datos cada X tiempo)

Los webhooks son la base de casi todas las automatizaciones modernas porque son **tiempo real** y no desperdician recursos consultando cada rato.

### El Webhook Trigger de n8n

Cuando creás un nodo "Webhook" en n8n:

1. Te da una URL única tipo: `https://tu-instancia.n8n.cloud/webhook/a1b2c3d4`
2. Esa URL es "lo que n8n escucha"
3. Cualquier app que mande un POST/GET a esa URL dispara tu workflow
4. Los datos enviados llegan como JSON al siguiente nodo

### Modos del Webhook en n8n

Al configurar un webhook tenés opciones:

| Opción | Qué hace |
|---|---|
| **HTTP Method** | GET, POST, PUT, DELETE (POST es lo más común) |
| **Path** | Sufijo custom de la URL (ej. "/stripe-webhook") |
| **Authentication** | Opcional: Basic Auth, Header Auth — para que no cualquiera mande datos |
| **Response Mode** | Immediately (responde rápido) / When last node finishes (responde al final) |
| **Response Data** | Qué devolver: First entries JSON / All entries / No body |

### Test webhook vs Production webhook

n8n te da **dos URLs** por webhook:

- **Test URL**: se activa solo mientras el workflow está abierto con "Listen for test event". Ideal para desarrollar.
- **Production URL**: funciona 24/7 cuando el workflow está activo.

**Regla crítica 2026**: siempre que vas a dar la URL a una app externa, usá la **Production URL**. La Test URL se apaga cuando cerrás la pestaña.

### Seguridad básica

Si dejás un webhook público sin autenticación, cualquiera que descubra la URL puede disparar tu workflow. Protegelo:

**Opción 1: Header Auth**
- Configurás un header secreto en el webhook: `X-API-Key: mi-secret-largo`
- La app externa tiene que mandar ese header. Si no lo manda, rechaza.

**Opción 2: Firma HMAC**
- Usado por Stripe, GitHub, WhatsApp.
- La app externa manda una firma (hash calculado con tu secreto)
- Vos validás la firma antes de procesar. Si no coincide, descartás.

**Opción 3: IP Whitelist** (más avanzado)
- Solo aceptás requests desde IPs conocidas (ej. solo desde Stripe)

Para empezar, **Header Auth** es suficiente.

### Herramientas para debugear webhooks

**[webhook.site](https://webhook.site)**: URL temporal que muestra todo lo que le mandan. Útil para entender qué formato envía una app antes de configurar tu workflow real.

**[RequestBin](https://pipedream.com/requestbin)**: similar a webhook.site, de pipedream.

**n8n "Execution log"**: dentro de cada workflow, ves cada ejecución con la data recibida.

### Errores comunes al empezar

1. **Webhook no dispara**: estás usando Test URL pero el workflow no está en "Listen" mode. Activá el botón, o pasá a Production URL.
2. **Error 404**: la URL está mal. Copiala exacta del nodo.
3. **Datos no llegan**: la app externa manda con content-type distinto. Revisá cómo se parsean los datos en el Webhook node.
4. **Respuesta rechazada**: si la app externa espera status 200 pero tu workflow tarda mucho, usá "Response Mode: Immediately".
$md$,
    0, 50,
$md$**Probá un webhook con webhook.site y n8n.**

1. Andá a [webhook.site](https://webhook.site) — te da una URL
2. En n8n, creá workflow con Webhook Trigger
3. Copia la Production URL del webhook de n8n
4. Ahora, desde tu terminal/curl (o desde Postman), hacé:
   `POST <url-n8n>` con body JSON: `{"nombre": "test", "valor": 123}`
5. Verificá que el workflow se ejecutó en n8n
6. Screenshot de la ejecución mostrando los datos recibidos$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es la diferencia principal entre webhook y API tradicional?',
   '["Webhook es más rápido siempre", "Webhook = push (la app te avisa); API = pull (vos consultás periódicamente)", "No hay diferencia", "Webhook solo funciona con Google"]'::jsonb,
   1, 0, 'Webhook = push en tiempo real. Evita polling innecesario.'),
  (v_lesson_id, 'En n8n, ¿cuál es la diferencia entre Test URL y Production URL del webhook?',
   '["Ninguna", "Test URL solo funciona mientras está en modo Listen; Production funciona 24/7 con workflow activo", "Test es gratis y Production cuesta", "Test es más rápida"]'::jsonb,
   1, 1, 'Test URL = desarrollo activo. Production URL = cuando ya está en producción y la das a apps externas.'),
  (v_lesson_id, '¿Qué es Header Auth en un webhook?',
   '["Un tipo de email", "Exigir un header secreto específico para aceptar el request — previene que cualquiera dispare tu workflow", "Un error 500", "La firma digital del certificado"]'::jsonb,
   1, 2, 'Header Auth = primera línea de defensa. Rechaza requests sin el header correcto.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'WhatsApp Business API + ChatGPT',
$md$## Tu primer bot de WhatsApp con IA

Vamos al caso más pedido en 2026: un bot de WhatsApp que responde automáticamente con IA a consultas de clientes.

### Opciones para usar WhatsApp en 2026

| Proveedor | Pros | Contras | Precio |
|---|---|---|---|
| **WhatsApp Business API oficial** (Meta) | Oficial, escala masiva | Setup complejo, aprobación de plantillas | $0.005-0.05 por mensaje |
| **Evolution API** (open source) | Gratis, self-hosted, potente | Requiere servidor, no oficial | Servidor ~$5/mes |
| **Twilio WhatsApp API** | Fácil setup, robusto | Caro | $0.005-0.04 por mensaje |
| **360Dialog** | Foco en WhatsApp Business | Menos conocido | Variable |

**Para aprender**: Evolution API (gratis, flexible)
**Para producción oficial**: Meta o Twilio

### Arquitectura del flujo

```
Usuario manda mensaje en WhatsApp
        ↓
Evolution API recibe el mensaje
        ↓
Dispara webhook hacia n8n
        ↓
n8n procesa con Claude/GPT
        ↓
n8n manda respuesta de vuelta a Evolution API
        ↓
Evolution API manda respuesta al usuario
```

### Paso 1: setup Evolution API

1. Deploy en Railway, Render o VPS: [github.com/EvolutionAPI/evolution-api](https://github.com/EvolutionAPI/evolution-api)
2. Configurás instancia y escaneás QR con tu WhatsApp
3. Te dan endpoint: `https://tuservidor.com/`
4. Configurás webhook en Evolution para que apunte a n8n

(Alternativa 2026: muchos servicios como [evolution-api.com](https://evolution-api.com) ya lo ofrecen como SaaS por $10-30/mes para evitar el setup)

### Paso 2: workflow en n8n

**Nodo 1 — Webhook Trigger** (recibe del Evolution API):

URL que pegás en Evolution API. Method POST.

Recibís JSON con estructura similar a:

```json
{
  "data": {
    "key": { "remoteJid": "5491112345678@s.whatsapp.net" },
    "message": { "conversation": "Hola, quiero info del curso" },
    "pushName": "Juan"
  }
}
```

**Nodo 2 — Set** (extraer campos limpios):

```
numero: {{ $json.data.key.remoteJid.replace('@s.whatsapp.net', '') }}
nombre: {{ $json.data.pushName }}
mensaje: {{ $json.data.message.conversation }}
```

**Nodo 3 — OpenAI Chat Model** (o Claude):

- Model: gpt-4.1-mini (rápido y barato) o claude-haiku-4-5
- System prompt:
  ```
  Sos Laura, asistente de [TU NEGOCIO].
  Respondé en español, tono amable pero profesional.
  No inventes precios — si te preguntan, decí "te paso con alguien del equipo".
  Máximo 3 oraciones.
  ```
- User prompt: `{{ $json.mensaje }}`

**Nodo 4 — HTTP Request** (mandar respuesta a Evolution API):

```
POST https://tuservidor.com/message/sendText/tu-instancia
Headers: apikey: tu-api-key
Body JSON:
{
  "number": "{{ $('Set').item.json.numero }}",
  "text": "{{ $('OpenAI').item.json.response }}"
}
```

Activás el workflow y listo: bot funcional.

### Mejoras esenciales de un bot real

**1. Memoria de conversación**

Sin memoria, cada mensaje es aislado. Solución: guardar historial en base de datos (Supabase) y pasárselo como contexto al LLM (Large Language Model — modelo de IA conversacional como GPT o Claude).

```
[Recibir mensaje] →
[Supabase: traer últimos 10 mensajes del numero] →
[OpenAI con historial como contexto] →
[Supabase: guardar mensaje + respuesta] →
[Enviar respuesta]
```

**2. Handoff a humano**

Cuando detectás intención complicada (ej. usuario frustrado, pregunta muy específica), pasá a humano:

```
[Switch según intención del LLM]
  ├ compra → bot sigue
  ├ soporte → bot intenta
  └ hablar_humano → manda a Slack del equipo con link
```

**3. Rate limiting por usuario**

Evitar que alguien mande 500 mensajes seguidos y consuma tu crédito GPT. Guardás contador en Redis o Supabase.

**4. Template messages**

WhatsApp exige plantillas pre-aprobadas para el primer mensaje saliente (si hace 24h que no responden). Configurás templates en Meta Business.

### Costos reales de un bot WhatsApp con IA

Supongamos 1000 conversaciones/día, cada una 5 mensajes:

- **WhatsApp** (Meta API): ~$25/mes (30k mensajes × $0.0008)
- **OpenAI GPT-4.1-mini**: ~$30/mes (tokens de 5000 conversaciones)
- **n8n**: $20/mes (Cloud Starter)
- **Servidor Evolution** (si usás eso): $5/mes

**Total**: ~$80/mes para 30k conversaciones con IA.

Comparalo con contratar una persona para atender WhatsApp: $800-1500/mes. **10x-20x más barato**.

### Lo que NO hacer

- **No grabar audios sin transcripción**: audios de 2 min en el LLM son caros. Transcribí primero con Whisper API (barato).
- **No usar GPT-4 turbo o Claude Opus para todo**: 90% de respuestas las resuelve gpt-4.1-mini o claude-haiku. Solo escalá al modelo grande en casos puntuales.
- **No respondas en menos de 2 segundos**: los usuarios piensan que es un bot sin alma. Poné Wait node de 2-5s para que parezca humano.
$md$,
    1, 70,
$md$**Armá el esqueleto de un bot WhatsApp.**

Opción A (sin Evolution API — simulado):

1. En n8n, creá workflow: Webhook → OpenAI → HTTP Response
2. System prompt: "Sos asistente de [tu negocio]"
3. Testealo con curl/Postman mandando un POST con `{"mensaje": "Hola, ¿qué ofrecen?"}`
4. Verificá que responde con texto generado

Opción B (con Evolution API — real):

1. Deploy Evolution API en Railway o contratá SaaS
2. Conectá tu WhatsApp
3. Configurá webhook hacia n8n
4. Armá el workflow completo
5. Testealo mandándote un mensaje desde otro celular$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es el modelo de IA recomendado en 2026 para un bot de WhatsApp costo-eficiente?',
   '["gpt-4 turbo o claude-opus", "gpt-4.1-mini o claude-haiku-4-5 (rápidos y baratos)", "gpt-3.5", "Solo modelos locales"]'::jsonb,
   1, 0, 'Los modelos "mini/haiku" de 2026 resuelven 90% de casos a 10x menos costo que los modelos grandes.'),
  (v_lesson_id, 'Sin memoria de conversación en un bot, ¿qué pasa?',
   '["Funciona igual", "Cada mensaje es aislado — el bot no recuerda contexto previo", "El bot se vuelve más rápido", "No se puede"]'::jsonb,
   1, 1, 'Sin memoria, cada request es una conversación nueva. Guardar historial en Supabase/Redis es esencial.'),
  (v_lesson_id, 'Si la pregunta del usuario es muy compleja, ¿qué patrón es bueno?',
   '["Inventar respuesta", "Handoff a humano: detectar intención y pasar el chat a un miembro del equipo", "Cortar la conversación", "Responder en inglés"]'::jsonb,
   1, 2, 'Handoff = pasar a humano cuando el bot no puede. Es crítico para no dañar la experiencia del usuario.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Gmail, Calendar y Sheets: el trío productivo',
$md$## Automatizar tu vida profesional

Las 3 apps de Google — Gmail, Calendar, Sheets — son las que más automatizamos. Estos patrones te sirven para todo.

### Gmail: patrones frecuentes

**Patrón 1: auto-responder inteligente**

Llega un mail → Claude clasifica la intención → responde solo si es pregunta simple:

```
[Gmail Trigger: nuevo mail] →
[OpenAI: clasificar como "pregunta_simple", "venta", "spam", "otro"] →
[Switch]
  ├ pregunta_simple → [OpenAI: redactar respuesta profesional] → [Gmail: responder]
  ├ venta → [Notion: crear deal] → [Slack: avisar al equipo]
  ├ spam → [Gmail: mover a Spam]
  └ otro → [Gmail: dejar en Inbox sin tocar]
```

**Patrón 2: resumen diario**

Cada día a las 8am, juntá todos los emails no respondidos, resumilos y mandátelo:

```
[Schedule 8am] →
[Gmail: get all unread] →
[Code: armar string con asunto + remitente] →
[OpenAI: resumir en 5 bullets priorizados] →
[Email: mandate el resumen]
```

**Patrón 3: extracción de datos**

De cada factura que llega por mail, extrae proveedor + monto + fecha + guardalo en Sheets:

```
[Gmail: filtrar "factura"] →
[OpenAI: extraer JSON {proveedor, monto, fecha}] →
[Google Sheets: append row]
```

### Calendar: automatizaciones potentes

**Patrón 1: brief automático antes de reunión**

15 min antes de una reunión, genera brief con info del cliente:

```
[Schedule cada 5 min] →
[Calendar: eventos próximos 15 min] →
[Para cada evento: Notion: buscar cliente por email] →
[OpenAI: generar brief en bullets (contexto, últimas interacciones, objetivos)] →
[Email / Slack: mandarte el brief]
```

**Patrón 2: seguimiento post-meeting**

Al terminar una reunión, crear tarea en Notion:

```
[Trigger: evento termina] →
[OpenAI: prompt para pedirte resumen] →
[Notion: crear tarea de seguimiento]
```

**Patrón 3: bloqueo automático**

Al agendar meetings externos (Calendly), blocquear 15 min antes y 15 min después para prep y wrap-up.

### Sheets: la base de datos del no-técnico

Google Sheets es una mini-base de datos gratis. Casos:

- **Lista de leads** con status, fecha, fuente, score
- **Cost tracker** de tus APIs (cada llamada, cuánto costó)
- **Inventario** básico para ecommerce chico
- **Log de errores** de workflows

**Append vs Update**:

- **Append**: siempre agrega nueva fila (útil para logs)
- **Update**: modifica fila existente (útil para status)
- **Append or Update**: si existe la clave, actualiza; si no, agrega (útil para upsert)

**Tips 2026**:

- Sheets aguanta bien hasta 100k filas. Más que eso → migrá a Supabase.
- Para búsquedas rápidas, usá el nodo "Google Sheets: Read Rows Matching".
- Si tenés fórmulas, Sheets las calcula después de que n8n inserta — no te preocupes por eso.

### Ejemplo completo: sistema de tracking de leads

```
[Webhook del form web] →
[Set: limpiar datos] →
[Supabase/Sheets: guardar lead con status="nuevo"] →
[OpenAI: evaluar score (1-100) según datos] →
[IF score > 70]
  TRUE →
    [Calendar: crear event "Llamar a {{ nombre }}" mañana 10am]
    [Slack: "Lead hot entrante: {{ nombre }}"]
    [Gmail: enviar email personalizado]
  FALSE →
    [Gmail: enviar email genérico con case studies]
    [Sheets: update status "frío"]
```

### Qué integraciones existen en n8n 2026

Más de 400. Las más usadas:

**Comunicación**: Gmail, Outlook, Slack, Discord, Telegram, WhatsApp
**Calendario**: Google Calendar, Outlook Calendar, Calendly, Cal.com
**CRM**: HubSpot, Pipedrive, Salesforce, Notion
**Pagos**: Stripe, PayPal, Mercado Pago (vía HTTP)
**Bases**: Supabase, Airtable, MySQL, PostgreSQL, MongoDB
**IA**: OpenAI, Anthropic (Claude), Google (Gemini), Ollama, HuggingFace
**Almacenamiento**: Google Drive, Dropbox, S3, Notion
**Redes sociales**: LinkedIn, Twitter/X, Instagram, TikTok (vía API)
$md$,
    2, 70,
$md$**Automatizá tu inbox.**

Elegí uno:

1. **Resumen diario de emails**: armá el workflow Schedule → Gmail unread → OpenAI summarize → Email. Configurá que corra cada mañana.

2. **Auto-responder amable**: workflow que responda con "Recibí tu mensaje, vuelvo en X horas" solo a emails que llegan fuera de horario laboral (Schedule check + IF hora).

Screenshot del workflow y de un ejemplo real funcionando.$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo Google Sheets ya no alcanza y conviene migrar a Supabase?',
   '["Siempre desde el inicio", "Cuando superás ~100k filas o necesitás relaciones entre tablas", "Nunca", "Cuando tenés más de 10 columnas"]'::jsonb,
   1, 0, 'Sheets aguanta hasta ~100k filas cómodo. Más que eso o con relaciones complejas → Supabase (PostgreSQL).'),
  (v_lesson_id, 'En n8n, ¿qué hace el modo "Append or Update" en Sheets?',
   '["Solo agrega", "Solo actualiza", "Si la clave existe actualiza, sino crea nueva fila (upsert)", "Borra duplicados"]'::jsonb,
   2, 1, 'Upsert = Update + Insert. Perfecto cuando no sabés si la fila ya existe.'),
  (v_lesson_id, 'Para un auto-responder de email inteligente, ¿qué paso es clave antes de responder?',
   '["Traducir a inglés", "Clasificar la intención con un LLM para decidir si responder automáticamente o escalar", "Borrar el email original", "Reenviarlo al spam"]'::jsonb,
   1, 2, 'Clasificación con IA = núcleo del auto-responder. Evita respuestas robotizadas cuando hay consultas complejas.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Manejo de errores, logs y testing',
$md$## Los flujos que fallan en silencio son peores que los que nunca se hicieron

En producción, tu workflow va a fallar. API cae, credentials expiran, una app cambia formato. Lo importante es **detectar rápido** y **arreglar antes** de que el cliente lo note.

### Niveles de manejo de errores

**Nivel 0: nada** (NO hagas esto)
- Workflow falla, nadie se entera, los leads se pierden

**Nivel 1: notificación básica**
- Configurar Error Workflow: si falla, manda Slack/email

**Nivel 2: retry + notificación**
- Cada nodo HTTP: reintentar 3 veces con backoff
- Si sigue fallando: notificar + guardar en cola de reprocesamiento

**Nivel 3: observabilidad completa**
- Logs estructurados en Supabase
- Dashboard con métricas (errores/hora, latencia)
- Alertas según umbrales

Para la mayoría de casos, **Nivel 2** es suficiente.

### Configurar Error Workflow en n8n

1. Creá un workflow nuevo llamado "Error handler"
2. Primer nodo: **Error Trigger**
3. Segundo nodo: Slack / Email / Telegram con mensaje:
   ```
   ⚠️ Workflow fallido: {{ $json.workflow.name }}
   Nodo: {{ $json.execution.lastNodeExecuted }}
   Mensaje: {{ $json.execution.error.message }}
   Link: {{ $json.execution.url }}
   ```
4. En cada workflow productivo:
   - Settings (⚙️ arriba derecha) → Error workflow → seleccionar "Error handler"
5. Ahora cualquier falla te avisa

### Retry con backoff

En cada nodo HTTP Request:

1. Open node → Settings (engranaje)
2. **Retry On Fail**: ON
3. **Max Retries**: 3
4. **Wait Between Retries**: 1000ms (y subís a 5000ms en el 2do, 15000ms en el 3ro)

Esto evita fallos transitorios (API cayó 2 segundos).

### Continue On Fail

Si un nodo no crítico falla, ¿querés que el workflow siga o se detenga?

- **Continue On Fail: ON** → sigue con el siguiente nodo (útil cuando el dato extra es opcional)
- **Continue On Fail: OFF** (default) → detiene todo

Típico: en un bot WhatsApp, si falla "guardar en Notion" podemos seguir (solo perdemos el log). Pero si falla "enviar respuesta al usuario", ahí sí detenemos.

### Logs estructurados

Para debuggar en producción, guardá cada ejecución importante en Supabase con:

```
tabla: workflow_logs
- id
- workflow_name
- status (success/error)
- data_input (jsonb)
- data_output (jsonb)
- error_message (nullable)
- duration_ms
- created_at
```

Cada workflow importante tiene al final un nodo Supabase que inserta la fila. Después, con una query SQL podés analizar: qué workflows fallan más, cuáles son más lentos, etc.

### Testing: antes de activar producción

**Test manual**:
1. Ejecutá el workflow con "Execute workflow" y datos reales
2. Inspeccioná la salida de cada nodo
3. Verificá que los datos finales son correctos

**Test con datos variados**:
- Caso feliz (datos limpios)
- Datos faltantes (campo vacío)
- Datos raros (emoji, acentos, caracteres especiales)
- Volumen alto (¿qué pasa si llegan 50 webhooks juntos?)

**Modo shadow**:
- Poné el workflow en producción pero SIN acciones visibles (ej. sin mandar el email real)
- Solo loguea lo que haría
- Dejalo correr 48h
- Analizás logs, ajustás, después activás las acciones reales

### Versionado: guardá snapshots

n8n tiene historial de cambios pero es limitado. Para workflows críticos:

1. Click en "..." arriba derecha → Download
2. Te descarga JSON con todo el workflow
3. Guardalo en GitHub o Drive con fecha
4. Si hacés cambios y algo rompe, restaurás

**En 2026 n8n Cloud tiene mejor versionado** pero la buena costumbre es hacerlo vos también.

### Alertas proactivas: cuando empeora, no cuando falla

Además de alertar fallos, alertá degradaciones:

- Si un workflow tarda >30s (cuando antes tardaba 5s) → algo cambió
- Si la tasa de éxito baja de 99% a 95% → algo empezó a fallar
- Si el volumen baja 50% vs ayer → ¿se rompió un trigger?

Estas alertas las armás en Supabase + Grafana (dashboard gratis) o con un workflow Schedule que corre queries y alerta.

### El checklist pre-producción

Antes de activar un workflow crítico:

- [ ] Error workflow configurado
- [ ] Retry en nodos HTTP configurado
- [ ] Notificación a Slack en fallos
- [ ] Logs estructurados en Supabase
- [ ] Testeado con 5+ casos variados
- [ ] Documentado qué hace, quién lo mantiene, cómo debuggear
- [ ] Alguien más del equipo sabe dónde vivir si sos hit-by-bus
$md$,
    3, 70,
$md$**Robustecé tu workflow.**

Tomá cualquier workflow que ya armaste en este módulo y agregale:

1. Error workflow asociado que te mande email cuando algo falle
2. Retry en los nodos HTTP (3 intentos, backoff creciente)
3. Un nodo final "Supabase: insert log" con workflow_name, status, duration
4. Simulá un error (ej. metele credential inválida en un nodo) y verificá:
   - Te llegó la notificación
   - El log quedó en Supabase con error_message
5. Restaurá la credential correcta$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es un Error Workflow en n8n?',
   '["Un workflow roto", "Un workflow separado que se dispara automáticamente cuando otro workflow falla", "Un mensaje de error del navegador", "Un tipo de trigger"]'::jsonb,
   1, 0, 'Error Workflow = tu sistema de alertas centralizado. Se lo asignás a cada workflow productivo.'),
  (v_lesson_id, '¿Qué es retry con backoff?',
   '["Reintentar con delay creciente (1s, 5s, 15s) para manejar fallos transitorios", "Borrar el workflow", "Cambiar el proveedor", "Detenerse siempre"]'::jsonb,
   0, 1, 'Backoff creciente = evita saturar el servicio que falla y deja tiempo para que se recupere.'),
  (v_lesson_id, '¿Qué es el modo shadow en testing?',
   '["Copiar el workflow", "Correr el workflow en producción pero solo logueando, sin ejecutar acciones reales, hasta confirmar que funciona bien", "Borrar el workflow viejo", "Cambiar el nombre"]'::jsonb,
   1, 2, 'Shadow = modo observación. Probás con tráfico real sin riesgo de mandar emails erróneos o facturar mal.');

  RAISE NOTICE '✅ Módulo Webhooks y APIs cargado — 4 lecciones + 12 quizzes';
END $$;
