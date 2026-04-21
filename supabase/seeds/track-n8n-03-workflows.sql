-- =============================================
-- IALingoo — Track "Automatización" / Módulo "Workflows reales"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'n8n';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Workflows reales no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Sistema de leads con scoring por IA',
$md$## De lead frío a venta cerrada — automatizado

El workflow que hoy más dinero genera en servicios/infoproductos: **pipeline de leads con scoring por IA**.

### Qué resuelve

Un negocio recibe 50-500 leads por semana por distintos canales (web, WhatsApp, Instagram, referidos). Sin sistema, el equipo:
- Pierde días revisando quién es prioritario
- Contesta en orden de llegada (no de valor)
- No hace seguimiento consistente
- Pierde 40-60% de las oportunidades

Con automatización:
- Cada lead recibe respuesta en < 30 segundos
- Se clasifica automáticamente (hot / warm / cold)
- El equipo solo ve los hot
- Los warm entran a un nurture (educación) automático
- Los cold se archivan sin perder tiempo

### Arquitectura del sistema

```
Canales de entrada (web, WhatsApp, Instagram, formularios)
        ↓
Webhook central n8n
        ↓
Normalización de datos
        ↓
Enriquecimiento (buscar empresa, LinkedIn, revenue)
        ↓
Scoring con LLM
        ↓
Switch: hot / warm / cold
        ↓  ↓  ↓
    ramas según tipo
        ↓
Base de datos (Supabase) con historial
        ↓
Dashboard: ves tu pipeline en tiempo real
```

### Paso 1: tabla en Supabase

```sql
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nombre TEXT,
  email TEXT,
  whatsapp TEXT,
  empresa TEXT,
  mensaje_original TEXT,
  fuente TEXT, -- 'web', 'whatsapp', 'instagram', etc.
  score INT,
  categoria TEXT, -- 'hot', 'warm', 'cold'
  enriquecimiento JSONB, -- datos de LinkedIn, revenue, etc.
  estado TEXT DEFAULT 'nuevo', -- 'nuevo', 'contactado', 'reunion', 'ganado', 'perdido'
  assigned_to TEXT, -- email del CSM / vendedor
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Paso 2: workflow de ingesta

**Trigger**: webhook `/new-lead` que acepta data de cualquier canal.

**Normalización** (nodo Set):

```
nombre: {{ $json.name || $json.nombre || 'Sin nombre' }}
email: {{ ($json.email || '').toLowerCase().trim() }}
whatsapp: {{ ($json.phone || $json.whatsapp || '').replace(/[^0-9]/g, '') }}
mensaje: {{ $json.message || $json.mensaje || '' }}
fuente: {{ $json.source || 'web' }}
```

**Deduplicación**:

Antes de insertar, chequear si ya existe ese email/whatsapp en los últimos 7 días. Si existe, actualizá en vez de crear nuevo.

**Enriquecimiento** (opcional pero potente):

Usar servicios como [Clearbit](https://clearbit.com), [Hunter](https://hunter.io) o scraping propio para sacar:
- Empresa donde trabaja (de LinkedIn)
- Revenue estimado de la empresa
- Tamaño del equipo
- Industria

En 2026, [Apollo.io](https://apollo.io) y [PhantomBuster](https://phantombuster.com) son los más usados para esto desde n8n.

### Paso 3: scoring con LLM

El LLM analiza toda la data y devuelve un score.

Prompt del system:

```
Eres un evaluador senior de leads B2B para una consultora de IA.

Analiza los datos del lead y devuelve JSON estricto:
{
  "score": 0-100,
  "categoria": "hot" | "warm" | "cold",
  "razones": ["texto breve por cada razón"],
  "accion_sugerida": "llamar_hoy" | "nurture_email" | "archivar",
  "personalizacion": "oración personalizada para el email"
}

Criterios de score:
- Empresa > 50 empleados: +20
- Empresa en industria target (fintech, salud, retail): +20
- Menciona urgencia o deadline: +25
- Dice "presupuesto" o "equipo técnico listo": +30
- Email corporativo (no @gmail, @hotmail): +15
- Pregunta genérica sin contexto: -10
- Email @gmail + preguntas básicas: -20

Umbrales:
- hot: > 70
- warm: 40-70
- cold: < 40
```

User prompt: los datos del lead + enriquecimiento.

**Regla 2026**: usá `gpt-4.1-mini` o `claude-haiku-4-5` para esto. La tarea es clasificación simple, no necesitás un modelo caro.

### Paso 4: ramas según categoría

**Hot** (>70):
```
→ Slack del equipo comercial: "🔥 Lead hot: {{ nombre }} de {{ empresa }} — {{ razones }}"
→ Calendar: bloquear slot en 1h para llamar
→ Email personalizado con {{ personalizacion }}
→ Update lead status = 'contactado'
→ Assigned to: {{ quien_esté_libre }}
```

**Warm** (40-70):
```
→ Email automático con case study relevante
→ Agregado a secuencia de nurture (email cada 7 días con valor)
→ Notion: tarea de follow-up en 5 días
```

**Cold** (<40):
```
→ Email de agradecimiento genérico
→ Archivado en Supabase status='cold'
→ Notion: revisión manual al mes (por si algo se escapa)
```

### Paso 5: nurture automático (para warm)

Un segundo workflow Schedule diario revisa leads warm y manda contenido según días desde último contacto:

- Día 0: email de bienvenida
- Día 3: case study
- Día 7: calculadora/herramienta gratis
- Día 14: invitación a webinar
- Día 21: oferta limitada

Si en cualquier momento responde → score sube → pasa a hot.

### Métricas a trackear

En el dashboard de Supabase/Metabase:

- Leads por día (fuente)
- Tasa hot/warm/cold
- Tiempo promedio a primer contacto
- Conversión hot → reunión
- Conversión reunión → venta
- LTV promedio

**Sin métricas no podés optimizar**. Configurá esto desde el día 1.
$md$,
    0, 70,
$md$**Armá el esqueleto del sistema de leads.**

1. Creá tabla `leads` en Supabase (o usá Sheets si preferís)
2. Workflow n8n:
   - Webhook /new-lead
   - Set normalizar
   - OpenAI scoring con el system prompt
   - Switch por categoría
   - Supabase insert
3. Simulá 3 leads distintos con curl/Postman:
   - Uno "hot": "CEO de fintech con 200 empleados, necesita automatizar KYC en 2 meses, presupuesto listo"
   - Uno "warm": "Pyme 20 empleados, investigando automatización"
   - Uno "cold": "Hola, qué hacen?"
4. Verificá que cada uno se clasificó correctamente
5. Screenshot del flujo + de Supabase con las 3 filas$md$,
    30)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué modelo de IA es recomendado para scoring de leads en 2026?',
   '["El más caro siempre (claude-opus)", "gpt-4.1-mini o claude-haiku-4-5 — clasificación es tarea simple", "Solo modelos locales", "GPT-3"]'::jsonb,
   1, 0, 'Scoring es clasificación. Los modelos "mini/haiku" lo hacen bien a 10x menos costo.'),
  (v_lesson_id, '¿Qué es enriquecimiento de leads?',
   '["Traducir el nombre", "Buscar datos adicionales (empresa, revenue, LinkedIn) para evaluar mejor el lead", "Mandar regalos", "Aumentar el precio"]'::jsonb,
   1, 1, 'Enriquecimiento = añadir contexto externo (Clearbit, Apollo.io) para decisiones más informadas.'),
  (v_lesson_id, '¿Por qué es importante deduplicar leads antes de insertar?',
   '["Para ahorrar espacio", "Evitar contactar al mismo lead múltiples veces por error y ensuciar métricas", "Es obligatorio por ley", "No importa"]'::jsonb,
   1, 2, 'Duplicados = mala UX (cliente molesto) + métricas falsas. Siempre check por email/whatsapp antes de insertar.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Atención 24/7 con bot inteligente y escalamiento',
$md$## Un bot que realmente resuelve

En 2026, las PyMEs que integran un bot bien hecho reducen 60-80% la carga del equipo humano y mejoran respuesta (de 4h a <1min).

### Arquitectura del bot ideal

```
Mensaje entrante (WhatsApp/Instagram/Web chat)
        ↓
[Recuperar contexto del usuario]
  - Historial últimos 30 días
  - Datos del CRM
  - Productos/servicios que miró
        ↓
[Clasificar intención con LLM]
  - consulta_info
  - agendar_demo
  - soporte_producto
  - reclamo
  - venta_oportunidad
        ↓
Según intención, tres rutas:
  1. Bot responde solo (80% de casos)
  2. Bot + escala a humano (15%)
  3. Humano directo (5% - reclamos sensibles)
        ↓
[Guardar conversación en histórico]
        ↓
[Métricas: tiempo respuesta, satisfacción, handoff rate]
```

### Paso 1: base de conocimiento (RAG)

RAG (Retrieval-Augmented Generation — el LLM busca info relevante antes de responder) es esencial para que el bot sepa **tu negocio** y no alucine.

Flujo:

1. Subís tu documentación (FAQ, pricing, testimonios, demos) como PDFs o texto plano
2. Se procesa con embeddings (representaciones matemáticas del significado) y se guarda en vector database (Pinecone, Supabase pgvector, Weaviate)
3. Cuando llega una pregunta, buscás los 3-5 fragmentos más relevantes
4. Los pasás como contexto al LLM junto con la pregunta

En n8n, esto lo hacés con:
- Nodo **Embeddings OpenAI** (o Voyage, Cohere)
- Nodo **Supabase Vector Store** (si usás pgvector)
- Nodo **OpenAI Chat** con contexto recuperado

**Alternativa simple 2026**: hacelo con [Flowise](https://flowise.ai) o [Botpress](https://botpress.com) que ya traen RAG integrado y se conectan vía webhook a n8n.

### Paso 2: el prompt que funciona

System prompt del bot:

```
Eres [NOMBRE] de [EMPRESA]. Atendés por WhatsApp con tono [amigable/formal/etc].

Tu objetivo principal: [vender / dar soporte / agendar demos].

Reglas INQUEBRANTABLES:
1. Nunca inventes precios ni features que no están en tu contexto
2. Si no sabés algo, decí "Dejame consultarlo, vuelvo con respuesta en unos minutos"
   y escalá a humano (usando la función handoff_to_human)
3. Máximo 3 oraciones por respuesta. El usuario está en WhatsApp, no en web.
4. No uses emojis excesivos. Máximo 1 por mensaje.
5. Si detectás enojo o frustración, escalá inmediatamente

Herramientas (tools) disponibles:
- buscar_en_catalogo(query): busca productos/servicios
- agendar_demo(fecha, email): crea evento Calendar
- handoff_to_human(razon): escala al equipo humano
- consultar_estado_pedido(orden_id): para casos de soporte

Contexto relevante para esta conversación:
{{ contexto_rag }}

Historial reciente con este usuario:
{{ historial }}
```

**Tip crítico**: las reglas 1 y 2 te salvan de alucinaciones y clientes enojados. Las reglas 3-5 mejoran experiencia.

### Paso 3: detección de intención

Antes de responder, clasificá qué quiere el usuario. Esto te deja enrutar correctamente.

Prompt de clasificación:

```
Clasifica el mensaje en UNA intención:
- info_general
- pregunta_precio
- agendar_demo
- soporte_tecnico
- reclamo_o_queja
- conversacion_casual
- venta_hot (menciona urgencia o listo para comprar)

Respondé solo con el nombre de la intención, nada más.

Mensaje: {{ $json.mensaje }}
```

Luego con Switch enrutas.

### Paso 4: handoff a humano

Cuando el bot decide escalar:

1. Nodo Supabase: update conversación como "necesita humano"
2. Nodo Slack: mensaje al canal del equipo con link al chat
3. Bot al usuario: "Te paso con [Nombre], vuelvo en un momento"
4. El humano toma el chat desde la inbox (Evolution API, Twilio, etc.)
5. Cuando el humano resuelve, se vuelve a activar el bot (o no, según preferencia)

### Paso 5: métricas del bot

Guardá en cada conversación:

```
tabla: conversaciones
- id
- usuario_id
- canal
- mensajes (jsonb con todo el historial)
- intent_detectado
- resuelto_por_bot (bool)
- escalado_a_humano (bool)
- duration_minutos
- satisfaccion (pedís rating al final: 1-5)
- creado_en
```

Dashboard mostrará:
- **% resueltas por bot** (target: 70-80%)
- **Tiempo promedio de respuesta** (target: <30s)
- **Satisfaccion promedio** (target: 4+/5)
- **Top intents** (te dice qué contenido falta en FAQ)
- **Conversaciones que terminaron en venta/demo** (ROI)

### Patrones avanzados 2026

**Memoria a largo plazo**: además de los últimos 10 mensajes, guardá **facts** del usuario (ej. "empresa: Acme", "interés: plan enterprise"). Los pasás al contexto siempre.

**Proactividad**: workflows que disparan mensajes al usuario en el momento correcto (ej. 3 días después de pedir demo, si no volvió → "¿Seguís interesado?").

**Multi-lenguaje**: detectás idioma del primer mensaje y respondés en ese idioma. Prompt del LLM trabaja en inglés internamente pero responde en idioma del usuario.

**Multi-modal**: si el usuario manda foto/audio:
- Foto → Vision API (Claude Vision, GPT-4V) → analizás contenido
- Audio → Whisper API → transcribís → procesás normal

### Costos reales operando 24/7

Supongamos 2000 conversaciones/mes, 10 mensajes cada una:

- WhatsApp API: $40/mes
- OpenAI/Claude: $80/mes
- Supabase (+ pgvector): $25/mes
- n8n Cloud: $50/mes Pro
- Evolution API servidor: $10/mes

**Total**: ~$205/mes para 20k interacciones.

Si cada 100 conversaciones generan 3 ventas promedio de $500 = $30k/mes generados por el sistema. ROI > 140x.
$md$,
    1, 70,
$md$**Diseñá (en papel) tu bot ideal.**

1. Listá 5-7 intenciones que tu bot debe clasificar (info, demo, precio, soporte, etc.)
2. Escribí el system prompt del bot en tu tono de marca
3. Listá 3 "herramientas" (tools) que el bot podría usar (ej. buscar_catalogo, agendar_demo, crear_ticket)
4. Definí las condiciones de handoff a humano
5. Armá el esqueleto del workflow en n8n con los nodos principales (no tiene que funcionar 100%, solo la estructura)

Compartí el diseño en Notion o PDF.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es RAG en el contexto de un bot?',
   '["Un tipo de emoji", "Retrieval-Augmented Generation: el LLM busca info relevante en tu base antes de responder para evitar alucinaciones", "Un framework de Python", "Un error común"]'::jsonb,
   1, 0, 'RAG = buscar fragmentos relevantes + dárselos al LLM como contexto. Evita que invente.'),
  (v_lesson_id, '¿Por qué es crítica la regla "no inventes precios ni features" en el system prompt?',
   '["Es solo preferencia", "Evita que el LLM alucine información falsa al usuario, lo cual genera desconfianza y reclamos legales", "Los precios cambian mucho", "Es más barato"]'::jsonb,
   1, 1, 'Alucinaciones de precios = cliente enojado, reclamos, pérdida de reputación. La regla es salvavidas.'),
  (v_lesson_id, '¿Qué es el "handoff a humano"?',
   '["Mandar regalos", "Escalar la conversación del bot a un agente humano cuando detecta complejidad o frustración", "Cerrar el chat", "Cambiar idioma"]'::jsonb,
   1, 2, 'Handoff = saber cuándo NO responder automáticamente. Un bot inteligente conoce sus límites.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Workflows de ventas: seguimiento, upsell y reactivación',
$md$## Vender más a quien ya te conoce

El 80% del revenue sustentable en un negocio viene de clientes existentes. Estos workflows te automatizan eso.

### 1. Onboarding post-venta

Después de que alguien compra, los primeros 7 días definen si se queda o cancela:

```
[Trigger: Stripe payment success webhook] →
[Supabase: crear cliente + marcar activo] →
[Email inmediato: "Bienvenida + próximos pasos"] →
[Día 1 Schedule: email con primera lección/guía de uso] →
[Día 3 Schedule: check-in personalizado vía WhatsApp] →
[Día 7 Schedule: pedir review y testimonio]
```

Si en algún punto el cliente **no abre** los emails 3 veces seguidas → alerta al equipo para llamada proactiva.

### 2. Detección de churn (cancelación)

Señales de que un cliente va a cancelar:

- No inicia sesión hace X días
- Uso del producto bajó más del 50% mes a mes
- Tickets de soporte con tono negativo
- No abre emails del producto

Workflow:

```
[Schedule diario 9am] →
[Query: clientes con último login > 7 días] →
[Para cada uno]
  → [OpenAI: analizar patrón de uso y tickets]
  → [IF riesgo > 60%]
      → [Slack: alerta a CSM (Customer Success Manager — rol que cuida a clientes)]
      → [Email automático: "¿Cómo podemos ayudarte?"]
      → [Agendar llamada Calendly en próximas 48h]
```

### 3. Upsell inteligente

Cuando un cliente usa mucho del producto, probablemente quiera más features:

```
[Schedule semanal] →
[Query: clientes con uso > 80% de su plan] →
[OpenAI: generar pitch personalizado de upgrade] →
[Email con oferta: upgrade con 1er mes descontado]
```

Claves:

- **Timing**: mandar cuando están en el "momento de dolor" (se quedaron sin cuota, necesitaron una feature de plan superior)
- **Personalizado**: el email menciona cómo usan el producto, no es genérico
- **Oferta atractiva**: primer mes gratis, o X% off, o setup call gratis

Estudios 2026: upsell automático bien hecho convierte 15-25% vs 3-5% genérico.

### 4. Reactivación de inactivos

Clientes que se fueron o pausaron: podés traerlos de vuelta.

```
[Schedule mensual] →
[Query: ex-clientes (canceled_at < 6 meses)] →
[OpenAI: mensaje con novedades del producto relevantes a lo que usaban] →
[Email personalizado con incentivo (50% off primer mes)] →
[Si click en el email → agendar demo con equipo]
```

Tasa típica 2026: 8-12% de reactivación en campañas bien hechas.

### 5. Abandonado en carrito / reserva

Si alguien empezó a comprar pero no terminó:

```
[Trigger: Stripe checkout.session.created SIN posterior checkout.session.completed en 30 min] →
[Email 1: "¿Todo bien? Te dejaste algo"] →
[Esperar 24h]
[IF no compró] →
  [Email 2: "Últimas horas, X% off si terminás hoy"] →
[Esperar 72h]
[IF no compró] →
  [Email 3: "Última oportunidad, hablá con Juan (humano) si tenés dudas"]
```

Recuperación típica: 15-30% de los carritos abandonados.

### 6. Seguimiento de reuniones y deals

En ventas B2B, el follow-up mata deals:

```
[Trigger: meeting ended en Calendar] →
[OpenAI: escuchar grabación (si usás Otter.ai, Fathom) o leer notas] →
[Extraer: próximos pasos, objeciones, timing] →
[Email al cliente: resumen de la reunión + próximos pasos claros] →
[Notion: crear tarea con fecha de follow-up] →
[Slack al vendedor: "Esta semana hacele follow-up a X, objección era Y"]
```

### 7. Referidos

Los mejores clientes son los que llegan por referidos. Activá eso:

```
[Schedule mensual: query de clientes NPS alto (>= 9)] →
[Email personalizado: "Te invito a ganar $X por cada referido"] →
[Generar link único con UTM (parámetros que trackean de dónde viene el tráfico)] →
[Si refiere: crédito automático en próxima factura]
```

### El patrón común: todos son "if this happens, do that after X time"

Casi todos estos workflows son:

1. Detectar un evento o condición (schedule o trigger)
2. Pasar unos días/horas
3. Hacer una acción personalizada por IA
4. Medir resultado
5. Ajustar

Si dominás este patrón en n8n, construís cualquier automatización de ventas que veas en el mercado.

### Herramientas complementarias

En 2026, herramientas que integran bien con n8n para ventas:

- **HubSpot / Pipedrive**: CRM con webhooks
- **Apollo.io**: prospecting B2B
- **Calendly / Cal.com**: booking
- **Loom**: videos personalizados (se pueden generar automáticos con IA)
- **Warmly**: detección de intención B2B (quién está visitando tu sitio)
- **Clay**: enriquecimiento de leads (el favorito 2026 reemplazando Clearbit)

### Métricas de ventas que todo workflow debe trackear

- Tiempo de primer contacto
- Tasa de apertura de emails
- Tasa de click
- Tasa de respuesta
- Conversión por paso del funnel
- Tiempo promedio de cierre
- Revenue por lead (LTV / leads)
- CAC (Costo de Adquisición de Cliente)
- LTV/CAC ratio (idealmente >3)

Todo esto se guarda en tus logs y se visualiza en Metabase o Grafana.
$md$,
    2, 70,
$md$**Armá un workflow de recuperación de carrito abandonado.**

1. En n8n, creá workflow con:
   - Webhook que recibe "cart_abandoned" (simulado)
   - Wait node 1 día
   - OpenAI: generar email personalizado usando datos del cart
   - Gmail/SendGrid: enviar email
   - Wait 2 días
   - Si no vuelve → enviar segundo email con descuento
2. Testealo simulando un abandono con curl
3. Verificá que lleguen los emails en tiempo y forma

Opcional: agregá nodo Supabase para loggear cada envío y poder medir después.$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué porcentaje del revenue sustentable suele venir de clientes existentes?',
   '["10%", "30%", "80%", "100%"]'::jsonb,
   2, 0, 'El 80% proviene de retención, upsell y referidos. Solo 20% de nuevos. Por eso estos workflows son oro.'),
  (v_lesson_id, '¿Qué señal NO indica riesgo de churn?',
   '["Último login hace 30 días", "Uso bajó 50% mes a mes", "Tickets con tono negativo", "Abrió los emails del producto y respondió con preguntas"]'::jsonb,
   3, 1, 'Engagement (abrir emails, responder) = bueno. Las 3 primeras son señales de alarma.'),
  (v_lesson_id, '¿Qué pasa si enviás upsell genérico (sin personalizar)?',
   '["Convierte igual", "Convierte 3-5%, vs 15-25% del upsell personalizado con IA según uso real", "Convierte más", "No se puede hacer"]'::jsonb,
   1, 2, 'Personalización basada en uso del cliente = 3-5x mejor conversión. Por eso usamos LLMs.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Deploy, escalabilidad y el futuro',
$md$## Cuando empiezan los problemas de "éxito"

Al principio n8n Cloud con plan Starter alcanza. Pero si tu negocio crece, vas a necesitar algo más robusto.

### Cuándo migrar a self-hosted

Señales claras:

- **Ejecuciones > 10k/mes**: Plan Pro de n8n Cloud son $50/mes hasta 10k. Más que eso, self-hosted es más barato.
- **Latencia crítica**: si los workflows tardan >10s, podés tunear mejor tu servidor propio
- **Datos sensibles**: clientes en salud, fintech, gobierno exigen que datos no salgan de tu infraestructura
- **Integraciones custom**: nodos que no existen, los programás vos en el servidor

### Deploy self-hosted en 2026

**Opción 1: Railway** (recomendado para empezar)
- $5-20/mes
- Deploy con 1 click del template n8n
- Buena UI, logs incluidos
- Ideal hasta 50k ejecuciones/mes

**Opción 2: Render**
- Similar a Railway, $10-25/mes
- Más maduro para prod

**Opción 3: VPS + Docker** (Hostinger, Hetzner, DigitalOcean)
- $5-20/mes
- Requiere saber configurar Docker, Nginx, SSL
- Máximo control
- Ideal >50k ejecuciones

**Opción 4: Kubernetes** (solo si ya lo usás)
- Overkill para la mayoría
- Sentido si tu equipo ya maneja infra K8s

### Variables de entorno críticas

Cuando migrás a self-hosted, configurá:

```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=xxxxxx (largo!)

N8N_ENCRYPTION_KEY=xxxxxx (ÚNICA POR INSTALACIÓN, guárdala!)

WEBHOOK_URL=https://n8n.tudominio.com
N8N_HOST=n8n.tudominio.com
N8N_PROTOCOL=https
N8N_PORT=443

DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=xxx
DB_POSTGRESDB_DATABASE=n8n
...
```

**Regla crítica**: backup periódico del `.env` y de la base PostgreSQL donde n8n guarda workflows y credenciales.

### Escalabilidad horizontal

Cuando una sola instancia de n8n no aguanta:

- **Queue mode**: n8n se divide en worker nodes (procesan ejecuciones) + main (UI + webhooks). Escalás workers horizontalmente.
- Requires Redis para cola de jobs
- Recomendado >500k ejecuciones/mes

### Backups: la regla sagrada

- **Workflows**: exportá todo como JSON al menos una vez por semana. Guardá en GitHub/Drive/S3.
- **Credentials**: exportá también. n8n las encripta con `N8N_ENCRYPTION_KEY`.
- **Base de datos**: si usás Postgres propia, snapshot diario automático.
- **Test restore**: cada mes, hacé restore en ambiente dev para verificar que el backup sirve.

### Monitoreo productivo

En producción seria, configurá:

- **Uptime monitoring**: [UptimeRobot](https://uptimerobot.com), [BetterUptime](https://betteruptime.com) — chequea que n8n responda cada 5 min
- **Error tracking**: [Sentry](https://sentry.io) — recibe stack traces de errores
- **Logs centralizados**: [Axiom](https://axiom.co), [Grafana Loki] — buscar en logs rápidamente
- **Dashboard de métricas**: Grafana conectado a la DB de n8n para visualizar ejecuciones, duración, tasa de error

### Seguridad: lo no-negociable

1. **HTTPS siempre**. Certificado gratis con Let's Encrypt (en Railway/Render viene automático).
2. **IP whitelist para webhooks sensibles**. Solo Stripe/WhatsApp pueden hitear ciertos endpoints.
3. **Rotación de credentials cada 90 días**. Si una API key se filtra, rotá.
4. **Audit log**: quién modificó qué workflow. n8n Enterprise lo tiene; en community podés auditar con Git (export JSON al repo).
5. **Principle of least privilege**: credenciales con permisos mínimos. Una app que solo lee Sheets no necesita permisos de escribir.

### Multi-ambiente: dev, staging, prod

Instancias separadas:

- **Dev**: donde experimentás, podés romper todo
- **Staging**: espejo de prod, testing final
- **Prod**: el que los clientes usan

Tip: exportá JSONs de workflows, editá en dev, importá en staging, validás, importás en prod. Usá Git para versionar todo.

### El futuro de la automatización (2026 y más allá)

**Tendencias 2026**:

- **Agentes autónomos**: n8n ya tiene nodo **AI Agent** que ejecuta pasos de forma dinámica. En vez de flow fijo, el agente decide qué herramienta usar. Lo vemos en detalle en el track "Agentes con IA".
- **MCP (Model Context Protocol)**: estándar 2025-2026 para conectar herramientas con modelos. n8n empezó a soportarlo nativamente.
- **Voice-first**: workflows disparados por llamadas de voz (Vapi, Retell AI integran con n8n).
- **Local LLMs**: Ollama/LM Studio corriendo localmente conectados a n8n — privacidad total, cero costo por token.
- **No-code workflows con lenguaje natural**: algunos tools (Make "AI Agent") generan workflows desde "quiero que X haga Y". Todavía inmaduro pero viene fuerte.

### Cierre: qué llevarte

Ya sabés:

- Crear workflows desde cero
- Triggers, webhooks, APIs
- Integrar Gmail, Sheets, WhatsApp, OpenAI
- Manejar errores y logs
- Construir sistemas de leads, bots inteligentes, ventas automatizadas
- Hacer deploy a producción seria

Con eso tenés toda la base para construir **automatizaciones que ahorren 20-40 horas/semana** a un negocio o a vos mismo.

El siguiente paso natural es el track de **Agentes con IA**, donde das el salto de "flujo predefinido" a "IA que decide dinámicamente".
$md$,
    3, 70,
$md$**Migra un workflow a self-hosted.**

Tomá cualquier workflow que armaste:

1. Exportá como JSON desde n8n Cloud (tres puntitos → Download)
2. Deploy n8n en Railway con el template (1-click)
3. Configurá variables de entorno (al menos Basic Auth y DB)
4. Importá el JSON del workflow
5. Reconfigurá las credenciales (OAuth hay que rehacerlas)
6. Testealo
7. Opcional: conectá un dominio custom tipo n8n.tumarca.com

Screenshot del workflow corriendo en tu servidor propio.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo conviene migrar de n8n Cloud a self-hosted?',
   '["Siempre desde el inicio", "Cuando pasás ~10k ejecuciones/mes, manejás datos sensibles o querés más control", "Nunca", "Cuando tenés muchos workflows"]'::jsonb,
   1, 0, 'Self-hosted = mejor costo/mes a partir de cierto volumen, y obligatorio en industrias reguladas.'),
  (v_lesson_id, '¿Qué es `N8N_ENCRYPTION_KEY` y por qué importa?',
   '["Una contraseña random", "La clave única que encripta tus credentials — si la perdés no podés restaurar backups", "El password del admin", "Un token de GitHub"]'::jsonb,
   1, 1, 'Si perdés la encryption key, tus credentials exportadas son inutilizables. Backup OBLIGATORIO.'),
  (v_lesson_id, '¿Qué son los agentes autónomos que vienen fuerte en 2026?',
   '["Bots de WhatsApp básicos", "Nodos/sistemas donde la IA decide dinámicamente qué herramienta usar, en vez de flow predefinido", "Un nombre comercial", "Workers humanos"]'::jsonb,
   1, 2, 'Agente autónomo = loop IA + tools + memoria. Más flexible que workflow clásico. Próximo track lo cubre.');

  RAISE NOTICE '✅ Módulo Workflows reales cargado — 4 lecciones + 12 quizzes';
END $$;
