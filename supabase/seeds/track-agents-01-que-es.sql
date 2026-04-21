-- =============================================
-- IALingoo — Track "Agentes con IA" / Módulo "Qué es un agente"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'agents';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Qué es un agente no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Chat, asistente y agente: no es lo mismo',
$md$## Tres niveles de IA, en orden de autonomía

En 2026 todo el mundo habla de "agentes IA". La palabra se usa mal la mayoría del tiempo. Acá clarificamos.

### Nivel 1: Chat (ChatGPT clásico)

Vos escribís, la IA responde. Conversación de ida y vuelta.

- **Qué hace**: responde preguntas, ayuda a pensar, genera texto
- **Qué NO hace**: por sí solo no manda emails, no navega la web, no toca tu base de datos
- **Ejemplo**: pedirle a ChatGPT que te redacte un email

### Nivel 2: Asistente (Claude con MCPs, ChatGPT con plugins)

Chat **con herramientas**. Puede ejecutar acciones: buscar en la web, leer archivos, consultar tu calendar.

- **Qué hace**: resuelve tareas usando herramientas que vos le diste
- **Qué NO hace**: no decide autónomamente perseguir un objetivo a lo largo de tiempo. Vos le pedís, ejecuta.
- **Ejemplo**: "Buscá en mi Gmail los emails de la semana sobre el cliente X y hacé un resumen". El asistente usa la tool de Gmail, busca, resume.

### Nivel 3: Agente (el concepto real)

Un sistema donde el LLM:

1. **Recibe un objetivo** (no una instrucción paso a paso)
2. **Planea** qué pasos dar
3. **Ejecuta acciones** (con tools)
4. **Observa resultados**
5. **Ajusta el plan** según lo que vio
6. **Continúa** hasta completar el objetivo o pedir ayuda

Esto es un **loop**: think → act → observe → think → act...

- **Qué hace**: cumple objetivos abiertos y multipasos sin que le digas exactamente cómo
- **Ejemplo 1**: "Encontrá 10 leads potenciales para mi negocio y agendá llamadas con los 3 más prometedores". El agente: busca en LinkedIn, evalúa, prioriza, revisa disponibilidad en tu calendar, manda invitaciones.
- **Ejemplo 2**: "Monitoreá mis redes sociales y respondé comentarios positivos; los negativos o técnicos escalámelos". Corre 24/7, decide caso por caso.

### La diferencia clave

| Nivel | Input | Output | Autonomía |
|---|---|---|---|
| Chat | Pregunta | Respuesta | 0 |
| Asistente | Tarea concreta | Ejecuta con tools | Baja |
| Agente | Objetivo abierto | Loop de decisiones hasta lograrlo | Alta |

**Regla 2026**: si tu "agente" no tiene un loop donde el LLM decide qué hacer después (basándose en lo que vio), en realidad es un asistente o un workflow fijo.

### Anatomía de un agente

Un agente tiene 4 partes esenciales:

1. **Modelo** (LLM): el cerebro. En 2026: Claude 4.X, GPT-4.1, Gemini 2.5.
2. **Tools** (herramientas): acciones que puede ejecutar (buscar web, leer archivos, llamar APIs)
3. **Memoria**: qué recuerda entre llamadas (corto plazo = conversación actual, largo plazo = facts del usuario/dominio)
4. **Loop**: el "reactor" que itera hasta completar el objetivo

### Ejemplo: "agente" que investiga una empresa

Objetivo: "Investigá la empresa X y dame un brief ejecutivo"

Loop del agente:

```
Iter 1: pienso → necesito info general → uso tool "search_web" con query "empresa X"
Iter 2: observo resultados → relevantes los 3 primeros → uso tool "fetch_url" para cada uno
Iter 3: observo contenido → falta info financiera → uso tool "search_web" con "empresa X ingresos 2025"
Iter 4: observo → suficiente data → uso tool "write_report" con mi análisis
Iter 5: devuelvo el reporte final al usuario
```

Sin el loop, con un flow fijo en n8n, tendrías que predecir exactamente estos pasos al escribir el workflow. El agente los **descubre** según lo que va encontrando.

### ¿Por qué los agentes son la revolución 2026?

Porque desbloquean casos que antes eran imposibles sin equipos humanos:

- **SDRs (Sales Development Reps — vendedores que cualifican leads) 24/7**: investigan, contactan, responden, agendan
- **Investigadores autónomos**: juntan info de múltiples fuentes, analizan, producen reporte
- **Agentes de atención avanzada**: diagnostican problemas técnicos, investigan logs, proponen soluciones
- **Copilotos de desarrollo**: toman un ticket, escriben código, corren tests, abren PR (tipo Claude Code / Cursor en modo agent)

En 2026, las empresas que mejor adoptaron agentes ven productividad 3-10x en tareas específicas.

### Las promesas vs la realidad

Los **problemas** que aún tienen los agentes en 2026:

1. **Alucinan más que chats** (más decisiones = más chances de error)
2. **Costosos**: cada iteración es una llamada al LLM → suma rápido
3. **Lentos**: 5-10 iteraciones × 2-5s cada una = minutos
4. **Impredecibles**: a veces resuelven, a veces no. Difícil de testear.
5. **Necesitan límites estrictos**: sin límites, un agente puede hacer daño (borrar archivos, mandar mails raros, gastar dinero)

**Por eso**: agentes potentes funcionan mejor como **asistente al humano**, no como reemplazo total. El humano pone objetivo, el agente ejecuta, el humano revisa resultados antes de acciones irreversibles.

### ¿Cuándo ES agente real y cuándo no?

**SÍ es agente** (loop autónomo):
- Claude Code en modo agent: recibe tarea, explora repo, edita archivos, corre tests, itera hasta pasar
- Cursor / Zed / Aider con modo autonomous
- AutoGPT, BabyAGI (experimentales)
- OpenAI GPTs con tools + instrucciones abiertas
- ChatGPT "agents" feature (2026)

**NO es agente** (aunque se llame así):
- Workflow fijo de n8n, incluso con LLMs
- Chatbot de WhatsApp con tools pero sin loop
- Zapier con paso de OpenAI
- "AI agent" que en realidad es prompt largo

### El diagrama mental

```
┌───────────────────────────────────────┐
│          OBJETIVO DEL USUARIO         │
└─────────────────┬─────────────────────┘
                  ↓
         ┌────────────────┐
         │     LLM        │ ← memoria, contexto
         │   (piensa)     │
         └────┬───────────┘
              ↓
         ┿ ¿Ya logré el objetivo? ┿
              │              │
            NO              SÍ
              │              │
              ↓              ↓
       ┌─────────────┐  ┌──────────┐
       │ Elegir tool │  │ Respuesta│
       │   y usar    │  │  final   │
       └──────┬──────┘  └──────────┘
              ↓
       ┌──────────────┐
       │ Observar     │
       │ resultado    │
       └──────┬───────┘
              ↓
       (vuelve al LLM)
```
$md$,
    0, 50,
$md$**Identificá agentes en productos que ya usás.**

Hacé una lista de 5 productos/apps que uses y clasificá cada uno:
- ¿Es chat, asistente o agente?
- ¿Por qué?

Ejemplos que podés explorar:
- ChatGPT (modo normal vs modo con tools)
- Claude Code
- Lovable "AI" button
- Cursor
- Google Search
- Notion AI
- ChatGPT Agents

Compartí tu análisis en Notion o doc.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué hace específicamente a un agente "agente" (y no solo asistente)?',
   '["Usar GPT-4", "El loop donde el LLM decide qué hacer después basándose en lo que observó — autonomía iterativa", "Tener muchas tools", "Ser caro"]'::jsonb,
   1, 0, 'Sin loop de decisión, no hay agente. Con loop + tools + objetivo abierto, sí.'),
  (v_lesson_id, '¿Cuál NO es una parte esencial de un agente?',
   '["Modelo (LLM)", "Tools (herramientas para ejecutar acciones)", "Una interfaz gráfica elaborada", "Memoria y loop"]'::jsonb,
   2, 1, 'La UI es un detalle de implementación. Lo esencial: modelo + tools + memoria + loop.'),
  (v_lesson_id, '¿Por qué los agentes en 2026 deben tener límites estrictos?',
   '["Para ser más lentos", "Porque sin límites pueden tomar acciones irreversibles o costosas sin supervisión (borrar archivos, mandar mails, gastar dinero)", "Para ahorrar tokens", "Es obligación legal"]'::jsonb,
   1, 2, 'Autonomía sin límites = riesgo. Siempre: aprobar acciones destructivas, budget cap, human-in-the-loop.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Tools: las manos y ojos del agente',
$md$## Sin tools, el LLM solo puede hablar

Un LLM sin tools es un filósofo con las manos atadas: piensa, razona, pero no puede cambiar el mundo. Las **tools** (herramientas) son las funciones que le das para que actúe: buscar en Google, leer archivos, mandar emails, llamar APIs.

### Cómo funcionan las tools técnicamente

Los modelos 2026 (Claude 4.X, GPT-4.1) soportan **function calling** (la API permite definir funciones; el modelo elige cuál llamar con qué argumentos).

Tú le pasás al modelo:

1. La pregunta/objetivo del usuario
2. Una lista de tools disponibles (nombre, descripción, schema de argumentos)

El modelo devuelve **una de dos cosas**:

- **Texto final** ("ya tengo la respuesta, acá la tenés")
- **Tool call** ("quiero llamar la tool X con estos argumentos")

Vos ejecutás la tool, le pasás el resultado de vuelta al modelo, y repetís hasta que devuelva texto final.

### Formato de una tool (Anthropic Claude)

```json
{
  "name": "buscar_web",
  "description": "Busca información en la web. Úsala cuando necesites info actualizada o que no conocés.",
  "input_schema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "El término de búsqueda"
      },
      "num_results": {
        "type": "integer",
        "description": "Cuántos resultados traer",
        "default": 5
      }
    },
    "required": ["query"]
  }
}
```

Para OpenAI el formato es similar con ligeras diferencias (clave `type: "function"` envolviendo).

### La regla de oro: descripciones claras

El modelo **decide** qué tool usar basado en la **descripción** que le das. Malas descripciones = malas decisiones.

**❌ Mala**:
```
{
  "name": "search",
  "description": "Searches stuff"
}
```

**✅ Buena**:
```
{
  "name": "buscar_productos_catalogo",
  "description": "Busca productos en nuestro catálogo interno. Úsala cuando el usuario pregunta por precio, disponibilidad, specs o compara productos. NO la uses para búsquedas generales en internet."
}
```

En buenas descripciones:
- Qué hace exactamente
- **Cuándo** usarla
- **Cuándo NO** usarla (si hay confusión con otras)
- Ejemplos si ayuda

### Tools esenciales que casi todo agente necesita

1. **Search web**: Brave Search API, SerpAPI, Tavily. ~$0.001-0.005 por query.
2. **Fetch URL**: traer contenido de una página específica. Trivial con fetch/Jina AI Reader.
3. **Read file / List files**: acceso a archivos del usuario. Cuidado con permisos.
4. **Write / Edit file**: crear/modificar archivos. Solo agentes trusted.
5. **Execute code**: correr código arbitrario. MUY potente, MUY peligroso. Siempre en sandbox.
6. **Ask user**: pedirle clarificación al humano antes de actuar.
7. **Finish**: señal explícita de que terminó el objetivo.

### Tools específicas según el dominio

**Agente de ventas**:
- `buscar_leads(criterios)`
- `enviar_email(destinatario, asunto, cuerpo)`
- `agendar_llamada(email, fecha)`
- `actualizar_crm(lead_id, campos)`

**Agente developer**:
- `read_code(path)`
- `edit_file(path, diff)`
- `run_tests()`
- `git_commit(mensaje)`

**Agente de research**:
- `search_papers(query)`
- `fetch_paper(id)`
- `summarize(texto)`
- `save_note(título, contenido)`

### MCP: el protocolo universal 2026

**MCP (Model Context Protocol)** es un estándar creado por Anthropic en 2024, adoptado por la industria en 2025-2026. Define cómo las apps exponen tools a los modelos.

Antes: cada cliente (Claude Desktop, Cursor, etc.) tenía su propia forma de conectar tools. Fricción enorme.

Con MCP: una app publica un servidor MCP, cualquier cliente compatible lo puede usar. Hay MCPs para Gmail, Drive, Notion, GitHub, Slack, Linear, filesystems, bases de datos, y miles más.

Ya lo vimos en el track "Dominio de Claude". Muy relevante acá también: los agentes serios de 2026 usan MCPs como su forma principal de adquirir tools.

### Sandbox: correr código seguro

Si tu agente puede ejecutar código, NUNCA lo hagas en el mismo proceso del servidor. Opciones:

- **E2B** ([e2b.dev](https://e2b.dev)): sandboxes efímeras para LLMs (cloud), muy usadas 2026
- **Docker containers**: corres el código en container aislado
- **Modal** ([modal.com](https://modal.com)): serverless compute con sandbox
- **Pyodide / WebContainers**: sandbox en browser, pero limitado

Un código del agente que borra archivos, roba credenciales, o mina crypto — se contiene en la sandbox, no afecta tu infra.

### Pattern: tools con confirmación humana

Para acciones destructivas o costosas, hacé que la tool **no ejecute directamente**, sino que devuelva "preview" que el humano aprueba:

```typescript
tool: {
  name: 'enviar_email',
  description: 'Prepara un email. Requiere aprobación humana antes de enviar efectivamente.',
  execute: async (args) => {
    // Guardar en cola con status='pending_approval'
    await supabase.from('email_queue').insert({
      user_id: currentUser.id,
      to: args.to,
      subject: args.subject,
      body: args.body,
      status: 'pending_approval'
    })
    return { preview: args, status: 'awaiting_approval' }
  }
}
```

Separás "el agente decide qué mandar" de "el humano dice ok". Critical safety pattern 2026.

### Pattern: budget y caps

Un agente en un loop puede gastar cientos de dólares si no lo limitás. Antes de invocarlo:

```typescript
const agentState = {
  max_iterations: 20,
  max_cost_usd: 5.00,
  current_iter: 0,
  current_cost: 0,
  start_time: Date.now()
}

// En cada iteración:
if (agentState.current_iter >= agentState.max_iterations) stop('max iter')
if (agentState.current_cost >= agentState.max_cost_usd) stop('budget')
if (Date.now() - agentState.start_time > 15 * 60 * 1000) stop('timeout')
```

### Observabilidad

Un agente sin logs es una caja negra. Loggeá:

- Cada iteración: qué pensó, qué tool eligió, qué argumentos
- Cada resultado de tool: input, output, duración, costo
- Estado final: éxito/fracaso, tiempo total, costo total

Guardalo en Supabase / Langfuse / LangSmith. Al revisar un caso fallido, ves exactamente dónde se fue al carajo.

### Herramientas para construir agentes 2026

- **LangChain / LangGraph**: framework Python/JS, algo pesado pero maduro
- **Claude Agent SDK / OpenAI Agents SDK**: oficiales, ligeros
- **Vercel AI SDK**: excelente para Next.js, soporta tools
- **Mastra**: framework TypeScript más reciente, muy nice
- **n8n AI Agent node**: agent básico dentro de workflow n8n
- **CrewAI**: para agentes multi-rol colaborando

Para aprender, recomendamos **Claude Agent SDK** (simple, oficial, buena docu) o **Vercel AI SDK** (si ya estás en Next.js).
$md$,
    1, 70,
$md$**Diseñá las tools de un agente.**

Imaginá un agente de ejemplo (elegí uno):

- Agente que monitorea tu email y responde automáticamente a preguntas frecuentes
- Agente de research que investiga un tema y escribe artículo
- Agente de ventas que cualifica leads

Listá:

1. 5-7 tools que necesitaría
2. Para cada una, escribí: nombre, descripción clara (cuándo usar, cuándo NO), y schema de argumentos
3. Marcá cuáles requieren aprobación humana antes de ejecutar
4. Definí caps: max_iterations, max_cost, timeout

Compartí en un doc Notion o archivo.$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es function calling en un LLM?',
   '["Llamar a otro LLM", "La capacidad del modelo de elegir qué función (tool) ejecutar con qué argumentos, basándose en la pregunta del usuario", "Una API costosa", "Solo en GPT"]'::jsonb,
   1, 0, 'Function calling = el LLM decide la tool. Es la base de los agentes con tools.'),
  (v_lesson_id, '¿Qué factor DETERMINA qué tool usa el modelo?',
   '["El nombre de la tool", "La descripción que le pasás — por eso deben ser clarísimas, incluyendo cuándo usar y cuándo NO", "El orden en la lista", "La primera tool siempre"]'::jsonb,
   1, 1, 'Descripción es todo. Buenas descripciones → decisiones acertadas. Malas descripciones → agente confundido.'),
  (v_lesson_id, '¿Por qué ejecutar código de un agente en sandbox?',
   '["Para que corra más rápido", "Para aislar: si el código del agente es peligroso (borra archivos, roba credentials), no puede afectar tu infra", "Es decorativo", "Es gratis"]'::jsonb,
   1, 2, 'Sandbox (E2B, Docker, Modal) = contención obligatoria. Nunca ejecutes código del agente en el mismo proceso del servidor.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Memoria: corto y largo plazo',
$md$## Recordar lo que importa

Un agente sin memoria es como un pez: cada interacción empieza de cero. Un agente con buena memoria: aprende, personaliza, gana contexto.

### Dos tipos de memoria

**Memoria de trabajo (corto plazo)**:
- Lo que pasó en la sesión/tarea actual
- Cabe (más o menos) en la context window del modelo
- Ejemplo: las últimas 20 iteraciones del loop, el objetivo, las tools llamadas

**Memoria persistente (largo plazo)**:
- Lo que querés que recuerde entre sesiones
- Se guarda en base de datos externa
- Ejemplo: preferencias del usuario, historial, facts relevantes

### Context window: el límite físico

Cada modelo tiene un límite de cuántos tokens puede "ver" en una llamada:

| Modelo | Context window 2026 |
|---|---|
| Claude Haiku 4.5 | 200k tokens |
| Claude Sonnet 4.6 | 1M tokens |
| Claude Opus 4.7 | 1M tokens |
| GPT-4.1-mini | 128k tokens |
| GPT-4.1 | 1M tokens |
| Gemini 2.5 Pro | 2M tokens |

200k tokens = ~150k palabras = un libro corto entero. Podrías meter TODO en el prompt sin optimizar.

**Pero** — costo y velocidad escalan con tokens. 1M de tokens de input cuesta $3-15 y tarda 30+ segundos. No podés meter todo siempre.

### Estrategia 1: resumir lo viejo

Cuando la conversación se hace larga, resumí los primeros N mensajes y reemplazalos por un summary:

```
Mensaje 1: detalle...
Mensaje 2: detalle...
...
Mensaje 50: detalle...

↓ Si llegamos a 10k tokens, resumimos

[Resumen de 1-40]: El usuario preguntó por X, acordamos hacer Y, estamos explorando Z.
Mensaje 41 completo: ...
Mensaje 42 completo: ...
...
Mensaje 50 completo: ...
```

Esto es lo que hace Claude Code internamente cuando la conversación se alarga.

### Estrategia 2: retrieval (buscar lo relevante)

En vez de meter todo el historial, buscás los **fragmentos más relevantes** al mensaje actual. Es RAG aplicado a tu propia conversación.

```
1. Usuario envía mensaje nuevo
2. Embedding del mensaje
3. Buscás los 5 mensajes/facts más similares en tu DB
4. Los metés como contexto junto al mensaje actual
```

Herramientas que ya lo hacen: [Mem0](https://mem0.ai), [Zep](https://getzep.com). O lo implementás con pgvector (ya lo vimos).

### Estrategia 3: facts estructurados

En vez de guardar conversaciones enteras, extraés **facts**:

```
User: "Me llamo Juan, trabajo en Truora, uso Mac"

Facts extraídos:
- name: Juan
- company: Truora
- os: macOS
```

Los guardás en JSONB. En cada nueva conversación, los pasás como contexto en el system prompt: "Sabés del usuario: {nombre}, {empresa}, {SO}".

Cómo extraer facts: llamada LLM dedicada:

```
Extrae de esta conversación cualquier fact nuevo sobre el usuario
(preferencias, datos personales, contexto profesional) en formato:
[{key: "...", value: "..."}]

Si no hay facts nuevos, devolvé [].
```

### Dónde guardar la memoria

**Opción A: Supabase con pgvector** (recomendado para MVP):

```sql
CREATE TABLE agent_memory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  kind TEXT CHECK (kind IN ('fact', 'episode', 'preference')),
  content TEXT,
  embedding VECTOR(1536),
  metadata JSONB,
  relevance FLOAT DEFAULT 0.5,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_accessed_at TIMESTAMPTZ
);
```

**Opción B: servicios dedicados**:

- **Mem0**: memoria para agentes, API muy simple
- **Zep**: memoria temporal de chat, bastante maduro
- **Letta** (ex-MemGPT): memoria con jerarquía
- **Pinecone / Weaviate**: vector DBs dedicadas

Para empezar: Supabase. Si escalás mucho: dedicados.

### Cuándo memoria es contra-productiva

- **Tareas puntuales sin historia**: "¿cuánto es 2+2?" no necesita saber que el usuario se llama Juan
- **Privacidad**: datos sensibles (salud, finanzas) — no los memorices o encriptalos fuerte
- **Memoria sucia**: si memorizás malas conclusiones pasadas, el agente las va a repetir

**Regla 2026**: memoria opt-in. Usuario elige qué recordar. Dale la opción de "olvidar" algo.

### Memoria de equipo / compartida

En agentes B2B, puede haber memoria que todo el equipo aprovecha:

- "Nuestro cliente Acme usa plan Enterprise, contacto principal es juan@acme"
- "Todos los proyectos de esta marca requieren versiones en inglés y español"

Estructura:

```sql
CREATE TABLE team_memory (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id),
  content TEXT,
  embedding VECTOR(1536),
  -- ...
);
```

Cada agente que corre dentro de la org accede a esta memoria.

### Problemas clásicos

**1. Memoria contradictoria**: el usuario dijo A hoy, B mañana. ¿Cuál guardás?
- Solución: timestamp + preferir último. O política de merge con LLM ("¿esto contradice algún fact anterior?").

**2. Memoria stale**: "la empresa Acme tiene 50 empleados" — hace 2 años. Hoy tiene 200.
- Solución: expirar facts automáticamente. Fechas de update. Re-validar periódicamente.

**3. Explosión de memoria**: agente guarda todo, crece sin parar.
- Solución: pruning. Al llegar a N facts, borrás los menos accedidos o más viejos.

**4. Memoria errónea que se refuerza**: agente guarda conclusión equivocada, la usa después para reforzar.
- Solución: mecanismo de "este fact me sirvió / este fact me confundió", usuario puede upvote/downvote.

### Ejemplo: agente de tutor personal

```
Memoria que guarda:
- Temas que viste: {tema: "SQL básico", fecha: ..., dominio_estimado: 0.7}
- Estilo preferido: "visual con diagramas", "corto y al punto"
- Ritmo: "3 lecciones por sesión"
- Errores recurrentes: "confunde LEFT JOIN con INNER JOIN"
- Horarios: "activo de 20-22 hs"

En cada sesión nueva, el agente:
1. Carga estos facts
2. Ajusta lecciones según dominio
3. Refuerza los errores recurrentes
4. Usa el estilo preferido
```

Este tipo de personalización con memoria es lo que diferencia un tutor IA genérico de uno que **realmente te conoce**.
$md$,
    2, 70,
$md$**Diseñá la memoria del agente que pensaste en la lección 2.**

Completá en un doc:

1. ¿Qué facts del usuario necesita recordar?
2. ¿Cómo los extraés? (prompt de extracción)
3. ¿Cómo los almacenás? (estructura de tabla)
4. ¿Cómo los recuperás en cada sesión? (query)
5. ¿Qué política de actualización tenés? (contradicciones, expiración)
6. ¿Hay opt-in / opt-out para el usuario?

Compartí el diseño.$md$,
    20
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Por qué no podés simplemente meter todo el historial en cada llamada al LLM?',
   '["Lo rechaza", "Escala en costo y latencia — 1M de tokens cuesta mucho y tarda decenas de segundos", "Es ilegal", "No cabe nunca"]'::jsonb,
   1, 0, 'Context window es grande pero no gratis. Cada token cuenta en $ y velocidad.'),
  (v_lesson_id, '¿Qué son los "facts" extraídos en el patrón de memoria estructurada?',
   '["Errores", "Datos clave del usuario/dominio en formato {key, value} que se guardan y recargan cada sesión", "Publicidad", "Respuestas anteriores"]'::jsonb,
   1, 1, 'Facts estructurados son más compactos y reutilizables que guardar conversaciones completas.'),
  (v_lesson_id, 'Un fact guardado hace 2 años puede ser stale. ¿Qué estrategia ayuda?',
   '["Nada, siempre es válido", "Expiración automática, fechas de update, re-validación periódica", "Borrar todo cada semana", "No usar memoria"]'::jsonb,
   1, 2, 'Memoria stale = decisiones basadas en info obsoleta. Expiración y re-validación lo mitigan.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'El bucle de decisión: prompt y loop',
$md$## El corazón de todo agente: el loop

Vamos al código real. El loop de un agente es sorprendentemente simple.

### Pseudocódigo del loop

```
function agent_loop(objective, tools):
    messages = [
        { role: system, content: system_prompt(tools) },
        { role: user, content: objective }
    ]

    for iter in 1..MAX_ITERATIONS:
        response = llm.call(messages, tools)

        if response.finish_reason == "stop":
            return response.text  // el agente terminó

        if response.tool_calls:
            for tool_call in response.tool_calls:
                result = execute_tool(tool_call.name, tool_call.args)
                messages.append({role: assistant, tool_calls: [tool_call]})
                messages.append({role: tool, content: result})

    return "max iterations reached"
```

Fácil, ¿no? Cinco líneas de lógica real. Lo complejo está en:

- El system prompt
- Las tools (lección anterior)
- Manejar errores, costos, timeouts
- La memoria

### El system prompt: la personalidad y reglas

Prompt base para un agente:

```
Sos un agente autónomo que ayuda a [DOMINIO].

Objetivo actual: {OBJECTIVE}

Herramientas disponibles:
{TOOLS_DESCRIPTIONS}

REGLAS:
1. Descompone el objetivo en pasos concretos antes de actuar.
2. Usá una tool a la vez y observá el resultado antes de decidir el próximo paso.
3. Si una tool falla, analizá el error y probá alternativa, no loopees con la misma llamada.
4. Antes de acciones destructivas (enviar email, borrar archivos, pagos), pedí confirmación al usuario con ask_user.
5. Cuando logres el objetivo, devolvé un resumen claro con: qué hiciste, resultado, próximos pasos sugeridos.
6. Si después de varios intentos no podés, explicá qué bloqueó y qué se necesitaría.

Estilo:
- Respuestas concisas
- En español
- Reporta el "por qué" de cada decisión importante
```

### Los 3 grados de autonomía

Según qué tanto dejás al agente decidir solo:

**L1: Paso a paso con confirmación**
- Agente propone un paso, humano aprueba, ejecuta
- Máxima seguridad, lento
- Ideal: cuando el dominio es delicado (salud, finanzas)

**L2: Plan + ejecución autónoma**
- Agente presenta un plan completo, humano lo revisa, agente ejecuta sin interrupciones
- Balance: control + velocidad
- Ideal: tareas predecibles con algún riesgo

**L3: Autonomía total hasta el resultado**
- Agente hace lo que quiera hasta terminar
- Rápido, sin fricción, pero más riesgo
- Ideal: tareas informativas (research, análisis), sandboxes seguras

Elegí el grado según dominio y contexto. Podés empezar L1 y pasar a L2/L3 cuando ganás confianza.

### Anti-patrones típicos

**1. Agente que se confunde y repite**:

El LLM llama la misma tool con los mismos argumentos en bucle. Solución:

- En el system prompt: "Si una tool no produjo progreso, probá algo distinto"
- Detección: si 3 tool calls idénticas → abort
- Memoria corta de "esto ya lo probé"

**2. Agente que no termina**:

Da muchas vueltas, no converge. Solución:

- max_iterations estricto
- Tool explícita "finish" que el agente tiene que llamar para cerrar
- "Si después de 10 iteraciones no lograste X, devolvé parcial + explicación"

**3. Agente que se va de tema**:

El usuario preguntó A y el agente empezó a resolver B. Solución:

- System prompt: "No realices tareas fuera del objetivo declarado"
- Guardrails: validar cada tool call contra el objetivo
- Re-anclar: cada N iteraciones, recordar el objetivo

**4. Agente alucinante**:

Inventa resultados en vez de usar tools. Solución:

- Tools con descripción clara de CUÁNDO usarlas
- Reglas: "Antes de responder con info, confirmá con search_web"
- Modelos más capaces (Opus/Sonnet > mini/haiku para tareas complejas)

### Ejemplo simple: "agente" de investigación en Deno

```typescript
const tools = [
  {
    name: "search_web",
    description: "Busca en la web. Devuelve lista de URLs con snippets.",
    input_schema: { type: "object", properties: { query: { type: "string" } }, required: ["query"] }
  },
  {
    name: "fetch_url",
    description: "Trae el contenido de una URL específica. Útil para profundizar en un resultado.",
    input_schema: { type: "object", properties: { url: { type: "string" } }, required: ["url"] }
  },
  {
    name: "finish",
    description: "Señal de que el reporte está completo. Pasá el reporte como argumento.",
    input_schema: { type: "object", properties: { report: { type: "string" } }, required: ["report"] }
  }
]

async function executeTool(name, args) {
  switch (name) {
    case "search_web":
      const r = await fetch(`https://api.tavily.com/search?q=${encodeURIComponent(args.query)}`)
      return await r.text()
    case "fetch_url":
      const p = await fetch(args.url)
      return await p.text()
    default:
      return `Unknown tool: ${name}`
  }
}

async function runAgent(objective) {
  const messages = [
    { role: "system", content: `Sos un investigador autónomo. Objetivo: ${objective}. Usá search y fetch hasta tener suficiente info, después llamá finish con el reporte.` }
  ]

  for (let i = 0; i < 15; i++) {
    const resp = await anthropic.messages.create({
      model: "claude-haiku-4-5",
      max_tokens: 4096,
      tools,
      messages
    })

    // Procesar respuesta
    for (const block of resp.content) {
      if (block.type === "tool_use") {
        if (block.name === "finish") {
          return block.input.report
        }
        const result = await executeTool(block.name, block.input)
        messages.push({ role: "assistant", content: resp.content })
        messages.push({
          role: "user",
          content: [{ type: "tool_result", tool_use_id: block.id, content: result }]
        })
      }
    }
  }

  return "Agente alcanzó max iteraciones sin completar"
}

// Uso
const reporte = await runAgent("Investigá qué es Claude Code y cómo se compara con Cursor")
console.log(reporte)
```

~50 líneas y tenés un agente de investigación funcional.

### Debugging: lo más frustrante (y normal)

Los agentes son caóticos de debuggear porque:

- No son determinísticos (mismo input → distinto output a veces)
- Dependencias externas (la web cambió, la tool falló)
- Costos de cada corrida

**Herramientas que ayudan**:

- **Langfuse, LangSmith**: traces visuales de cada iteración con costos, latencias, decisiones
- **Weights & Biases Prompts**: para experimentar con variantes de prompt
- **Helicone**: observability simple para LLMs
- **Braintrust**: evals + observability

**Enfoque práctico 2026**:
1. Empezar con traces simples (logs estructurados en Supabase)
2. Al tener complejidad, migrar a Langfuse/LangSmith
3. Al tener producto serio, evals continuos

En el próximo módulo construimos un agente real paso a paso.
$md$,
    3, 70,
$md$**Traducí el pseudocódigo del loop.**

En un lenguaje/ambiente que te guste (Node.js, Deno, Python):

1. Tomá el ejemplo de "agente de investigación" y adaptalo a tu stack
2. Implementá las 3 tools (search_web, fetch_url, finish)
3. Usá Tavily (gratis hasta cierto volumen) o SerpAPI como search engine
4. Corré el agente con un objetivo simple: "¿Cuál es la capital de Perú y cuántos habitantes tiene?"
5. Después probá uno más complejo: "Comparar los planes de OpenAI vs Anthropic vs Google Gemini en 2026"
6. Compartí los traces (logs) de cada iteración — qué decidió, qué llamó, qué obtuvo$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, 'En el loop de un agente, ¿cuándo termina la iteración?',
   '["Siempre después de 10 iteraciones", "Cuando el modelo devuelve finish_reason=stop (no hay más tool calls) o cuando alcanza max_iterations", "Nunca", "Cuando el usuario lo detiene"]'::jsonb,
   1, 0, 'Termina por decisión del modelo (texto final) o por guardrail (max iterations/cost/timeout).'),
  (v_lesson_id, '¿Cuál es el problema del "agente que se repite en loop"?',
   '["Es normal", "Llama la misma tool con los mismos argumentos, sin progreso — hay que detectarlo y abortar", "Ahorra dinero", "Es más rápido"]'::jsonb,
   1, 1, 'Loop infinito de mismas calls = waste de dinero + no resuelve. Detectalo y cortá.'),
  (v_lesson_id, 'L1 de autonomía (agente paso a paso con confirmación) es ideal cuando...',
   '["Querés rapidez máxima", "El dominio es delicado (salud, finanzas) y necesitás máxima seguridad aunque sea lento", "Querés autonomía total", "Siempre"]'::jsonb,
   1, 2, 'L1 = máximo control. L2 = plan+ejecución. L3 = autonomía total. Elegí según riesgo y velocidad.');

  RAISE NOTICE '✅ Módulo Qué es un agente cargado — 4 lecciones + 12 quizzes';
END $$;
