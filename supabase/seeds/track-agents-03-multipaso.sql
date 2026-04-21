-- =============================================
-- IALingoo — Track "Agentes con IA" / Módulo "Agentes multi-paso"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'agents';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Agentes multi-paso no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1: MCP a fondo
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'MCP a fondo: el USB-C de las tools',
$md$## El problema antes de MCP

En 2024, cada agente integraba sus tools a mano: una para Gmail, otra para GitHub, otra para Notion... cada equipo reimplementaba lo mismo. Tools duplicadas, inconsistentes, sin estándar.

**MCP (Model Context Protocol — protocolo abierto creado por Anthropic en noviembre 2024)** resuelve esto. Es el "USB-C" de las tools: un estándar común para que cualquier agente se conecte a cualquier herramienta.

### Cómo funciona

Dos piezas:

1. **MCP Server** — expone tools, resources y prompts. Por ejemplo: servidor de Gmail que ofrece las tools `list_emails`, `send_email`, `search`.
2. **MCP Client** (el agente) — descubre qué tools tiene disponibles y las invoca.

La comunicación usa JSON-RPC sobre stdio, SSE o HTTP. El agente no necesita saber cómo está implementado el server — solo le pregunta "¿qué tools tenés?" y las usa.

### Ecosistema MCP en 2026

Hay cientos de servers públicos ya construidos. Los más usados:

**Oficiales de Anthropic:**
- `filesystem` — leer/escribir archivos locales
- `github` — PRs, issues, commits, code search
- `slack` — enviar mensajes, leer canales
- `postgres` — queries SQL
- `brave-search` / `google` — búsqueda web
- `memory` — grafo de conocimiento persistente

**Community:**
- `gmail`, `calendar`, `drive` — Google Workspace
- `notion`, `linear`, `jira` — productividad
- `stripe`, `supabase`, `clickhouse` — datos/pagos
- `puppeteer`, `playwright` — automatización web
- `figma`, `obsidian`, `zotero` — diseño/notas

Catálogo: [modelcontextprotocol.io/servers](https://modelcontextprotocol.io/servers)

### Usar MCP en Claude Desktop

El modo más directo. Configuración en `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) o `%APPDATA%/Claude/claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/tuuser/Documents"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "ghp_xxx" }
    }
  }
}
```

Reiniciás Claude Desktop y ya tiene las tools. En chat: *"Leé mi README.md y creá un issue en github.com/mi-repo resumiendo lo que falta."*

### Usar MCP en Claude Code (la CLI)

```bash
claude mcp add filesystem npx @modelcontextprotocol/server-filesystem ~/projects
claude mcp add github --env GITHUB_TOKEN=ghp_xxx npx @modelcontextprotocol/server-github
claude mcp list
```

Ahora cualquier sesión de Claude Code tiene esas tools.

### Usar MCP desde código (Claude Agent SDK)

```javascript
import { ClaudeAgent } from '@anthropic-ai/claude-agent-sdk';
import { McpClient } from '@modelcontextprotocol/sdk';

const mcpClient = new McpClient();
await mcpClient.connect({
  command: 'npx',
  args: ['-y', '@modelcontextprotocol/server-filesystem', './docs']
});

const tools = await mcpClient.listTools();

const agent = new ClaudeAgent({
  model: 'claude-sonnet-4-6',
  tools: tools
});

const r = await agent.run('Resumí el contenido de los archivos en ./docs');
```

El SDK convierte las tools MCP a tools de Claude automáticamente.

### Construir tu propio MCP Server

Si tu sistema (ERP, CRM interno, API privada) no tiene server, armás uno en 50 líneas:

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server({ name: 'mi-empresa', version: '1.0.0' });

server.setRequestHandler('tools/list', async () => ({
  tools: [{
    name: 'get_customer',
    description: 'Obtiene info de un cliente por email',
    inputSchema: {
      type: 'object',
      properties: { email: { type: 'string' } },
      required: ['email']
    }
  }]
}));

server.setRequestHandler('tools/call', async (req) => {
  if (req.params.name === 'get_customer') {
    const c = await miApi.getCustomer(req.params.arguments.email);
    return { content: [{ type: 'text', text: JSON.stringify(c) }] };
  }
});

await server.connect(new StdioServerTransport());
```

Lo publicás en npm o lo instalás local. Cualquier agente lo usa.

### Remote MCP (HTTP/SSE)

Desde finales 2025 MCP soporta transporte remoto (no solo stdio local). Tu server corre en un endpoint HTTP, y cualquier cliente lo consume:

```json
{
  "mcpServers": {
    "mi-api-prod": {
      "url": "https://mi-empresa.com/mcp",
      "headers": { "Authorization": "Bearer xxx" }
    }
  }
}
```

Esto es lo que cambia 2026: MCPs como microservicios compartidos entre equipos.

### Seguridad MCP

Tres capas:

1. **Permisos por server** — Claude Desktop muestra qué server accede a qué cuando lo invocás
2. **Sandboxing** — el server filesystem solo ve el directorio que le pasaste en args
3. **Secrets** — las API keys van en `env`, no en el prompt, no en los logs

**Anti-patrón 2026**: poner todas tus keys en un solo MCP monolítico. Mejor servers pequeños con scope limitado.

### MCPs útiles para empezar (recomendación 2026)

Para uso personal:
- `filesystem` con scope a tus proyectos
- `github` para tus repos
- `memory` para notas persistentes
- `brave-search` para investigación

Para agente de negocio:
- `gmail` + `calendar` — el 80% del trabajo de knowledge workers
- `notion` o `linear` — gestión
- `stripe` o `supabase` — datos de producto
$md$,
    0, 60,
$md$**Instalá y probá 3 MCP servers.**

1. En Claude Desktop o Claude Code, configurá:
   - `filesystem` (apuntando a un directorio seguro)
   - `github` (con token de solo-lectura)
   - `memory` (grafo persistente)
2. Probá un prompt que use los 3: *"Buscá en GitHub issues abiertos en mi repo X, leé el README local, y guardá los 3 issues más importantes en memoria bajo el nodo 'priority-issues'."*
3. Verificá que el agente:
   - Descubrió las tools (le mostrás el output)
   - Las encadenó sin que le expliques
   - Persistió en memory

Screenshot del resultado.$md$,
    25)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué problema resuelve MCP?',
   '["Entrenar modelos más rápido", "Estandarizar cómo los agentes se conectan a tools externas — como USB-C pero para IA", "Generar imágenes", "Reemplazar prompt engineering"]'::jsonb,
   1, 0, 'MCP es un protocolo abierto para que cualquier agente pueda usar cualquier tool sin reinventar integraciones.'),
  (v_lesson_id, '¿Dónde van las API keys de un MCP server?',
   '["En el prompt del usuario", "Hardcoded en el código del server", "En la sección env del config, fuera del prompt y fuera de logs", "En un comentario del JSON"]'::jsonb,
   2, 1, 'Los secrets van siempre en env. El agente no los ve, solo usa las tools que el server expone.'),
  (v_lesson_id, '¿Qué es un Remote MCP (novedad 2025+)?',
   '["Un server que corre en tu máquina local via stdio", "Un servidor MCP expuesto vía HTTP/SSE, consumible desde cualquier cliente remoto", "Un mock para testing", "Una versión paga de MCP"]'::jsonb,
   1, 2, 'Remote MCP permite que equipos compartan servers centralizados como microservicios.');

  -- L2: Subagentes
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Subagentes: orchestrator + workers',
$md$## Cuando un solo agente no alcanza

Si tu tarea tiene **fases distintas con contextos enormes** (investigar 20 papers, analizar codebase completo, revisar 100 tickets), un único agente:
- Se queda sin contexto (tokens)
- Se pierde entre objetivos
- No puede paralelizar

**Solución**: dividir en subagentes especializados, cada uno con su propio contexto y tools.

### Patrón 1: Orchestrator + Workers

Un agente principal **delega** tareas a sub-agentes y luego **sintetiza**.

```
┌──────────────┐
│ Orchestrator │  → decide el plan
└──────┬───────┘
       │ spawnea en paralelo
   ┌───┼───┬────────┐
   ▼   ▼   ▼        ▼
[W1] [W2] [W3]   [W4]   ← workers, cada uno con su sub-tarea
   │   │   │        │
   └───┴─┬─┴────────┘
         ▼
  ┌──────────────┐
  │ Orchestrator │  → sintetiza
  └──────────────┘
```

**Ejemplo real 2026**: deep research agent.
- Orchestrator recibe *"Hacé un análisis del mercado de agentes IA en 2026"*
- Planea subqueries: tendencias técnicas, competidores, inversión VC, casos de uso, riesgos
- Spawnea 5 workers en paralelo, cada uno con sub-tarea + tools de búsqueda
- Cada worker devuelve un sub-reporte
- Orchestrator junta los 5 reportes y sintetiza el informe final

### Patrón 2: Handoff (agente que pasa el control)

Un agente atiende al principio, luego "pasa la batuta" a otro especializado.

**Ejemplo**: bot de soporte.
- Agent triage clasifica: *¿es facturación, técnico o ventas?*
- Hace handoff al agente especialista (cada uno con su system prompt, sus tools y su memoria)
- El especialista termina la conversación

### Patrón 3: Pipeline secuencial

Agentes encadenados tipo línea de ensamblado.

**Ejemplo**: generar un blog post.
1. Agente researcher — investiga el tema, devuelve notas
2. Agente outliner — arma el esqueleto
3. Agente writer — escribe el borrador
4. Agente editor — corrige estilo y SEO
5. Agente publisher — sube a Notion/CMS

Cada uno ve solo lo que necesita del anterior.

### Implementación: Claude Agent SDK con subagentes

```javascript
import { ClaudeAgent, tool } from '@anthropic-ai/claude-agent-sdk';

const researchWorker = async (topic) => {
  const worker = new ClaudeAgent({
    model: 'claude-haiku-4-5',
    systemPrompt: 'Sos un researcher. Buscá en web y devolvé notas concisas.',
    tools: [braveSearchTool, fetchPageTool],
    maxTurns: 10
  });
  const r = await worker.run(`Investigá: ${topic}. Devolvé bullet points.`);
  return r.text;
};

const orchestrator = new ClaudeAgent({
  model: 'claude-sonnet-4-6',
  systemPrompt: 'Sos el orchestrator. Planeás y sintetizás.',
  tools: [
    tool({
      name: 'research',
      description: 'Delega investigación de un sub-tema a un worker',
      inputSchema: {
        type: 'object',
        properties: { topic: { type: 'string' } },
        required: ['topic']
      },
      execute: async ({ topic }) => await researchWorker(topic)
    })
  ]
});

const result = await orchestrator.run(
  'Analizá el mercado de agentes IA en 2026. Delegá subtópicos según veas.'
);
```

El orchestrator llama `research("tendencias técnicas")`, luego `research("inversión VC")`, etc. En paralelo si el framework lo permite (Promise.all sobre las calls).

### Frameworks con subagentes nativos

- **OpenAI Agents SDK** (Swarm v2) — handoffs de primera clase
- **CrewAI** — define roles (Manager, Researcher, Writer) y los hace colaborar
- **LangGraph** — grafos de agentes con estados compartidos
- **Claude Code** — tiene subagentes built-in; en Claude Code usás el Task tool para spawnear workers

### Cuándo NO usar subagentes

- Tarea simple que cabe en 1 contexto → perdés tiempo y tokens
- Baja latencia crítica → spawn de subagente agrega 3-10s
- No podés verificar la calidad de cada worker → debugging se vuelve pesadilla

**Regla 2026**: si tu tarea dura >5 minutos o requiere paralelismo, subagentes. Si no, un solo agente con memoria buena alcanza.

### Coste y control

Un orchestrator con 5 workers = 6× llamadas al modelo. Controles:

- **Presupuesto por worker** — máximo N turns, máximo M tokens
- **Model tiering** — orchestrator con Sonnet/Opus (decide), workers con Haiku (ejecutan)
- **Logging** — guardás los turnos de cada worker en Langfuse para auditar
- **Guardrails** — el orchestrator valida outputs de workers antes de sintetizar

### Anti-patrones comunes

- **Spawnear subagentes sin plan claro** — terminan en loops redundantes
- **Pasar todo el contexto al worker** — perdés el beneficio de aislarlo
- **Esperar al worker para cada micro-decisión** — si es simple, que lo haga el orchestrator directo
$md$,
    1, 70,
$md$**Construí un mini orchestrator con 2 workers.**

1. Elegí una tarea de doble fase: ej. *"Dame los 5 mejores libros de IA + un resumen breve de cada uno"*
2. Worker 1 (Haiku): busca los 5 libros (web search)
3. Worker 2 (Haiku): para cada libro, devuelve resumen 3 frases
4. Orchestrator (Sonnet): los compagina en respuesta final
5. Medí tokens totales y tiempo total
6. Compará con hacerlo en un solo agente Sonnet — ¿ganaste en calidad? ¿en velocidad? ¿en costo?$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo tiene sentido dividir en subagentes?',
   '["Para cualquier tarea, siempre es mejor", "Cuando la tarea tiene fases distintas con contextos grandes o admite paralelismo", "Solo cuando usás LangChain", "Nunca — un agente bien prompteado siempre alcanza"]'::jsonb,
   1, 0, 'Subagentes ayudan cuando aislás contextos o paralelizás. Para tareas simples agregan latencia y costo sin beneficio.'),
  (v_lesson_id, '¿Qué es el patrón Orchestrator + Workers?',
   '["Un solo agente que se habla a sí mismo", "Un agente principal que delega sub-tareas a workers especializados y luego sintetiza los resultados", "Un cron job", "Un sistema sin LLM"]'::jsonb,
   1, 1, 'El orchestrator planea y sintetiza; los workers ejecutan sub-tareas aisladas en paralelo.'),
  (v_lesson_id, '¿Cuál es una optimización típica de costo en orchestrator+workers?',
   '["Usar Opus en todos los agentes", "Orchestrator en modelo grande (decide), workers en modelo pequeño (ejecutan)", "Reemplazar todo por GPT-3", "No usar tools"]'::jsonb,
   1, 2, 'Model tiering: razonar es caro (Sonnet/Opus), ejecutar sub-tareas concretas se puede con Haiku y ahorrás mucho.');

  -- L3: Tareas largas con checkpoints
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Tareas largas: checkpoints, resume y jobs async',
$md$## El problema de agentes que corren por horas

Un agente de "análisis exhaustivo de codebase" o "migración de 500 tickets" puede correr 30 minutos, 2 horas o un día entero. Tres riesgos:

1. **Se cae a mitad** (red, rate limit, bug) → perdés todo el progreso
2. **No podés ver qué está haciendo** → no sabés si avanza o está atascado
3. **Si el usuario cierra la ventana** → game over

La solución: **jobs asíncronos con estado persistente y checkpoints**.

### Arquitectura base

```
┌──────────┐   POST /jobs    ┌──────────┐   crea job    ┌─────────┐
│  Cliente │ ───────────────▶│  API     │──────────────▶│  DB     │
└──────────┘                 └──────────┘               │  (jobs) │
     ▲                             │                    └────┬────┘
     │ polling / realtime          ▼                         │
     │                      ┌──────────┐                     │
     │                      │  Queue   │◀────pick job────────┘
     │                      └─────┬────┘
     │                            ▼
     │                      ┌──────────────┐
     │                      │   Agent      │ corre,
     └─────progreso─────────│   Worker     │ actualiza estado
                            └──────────────┘ cada paso
```

### Modelo de datos mínimo

```sql
create table agent_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  task_description text not null,
  status text not null default 'queued',  -- queued, running, paused, completed, failed
  current_step int default 0,
  total_steps int,
  checkpoint jsonb default '{}'::jsonb,    -- estado para resume
  result jsonb,
  error text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table agent_job_events (
  id bigserial primary key,
  job_id uuid references agent_jobs(id) on delete cascade,
  event_type text not null,   -- 'step_start', 'step_done', 'tool_call', 'error'
  payload jsonb,
  created_at timestamptz default now()
);
```

### Checkpoint: el concepto

Cada vez que el agente completa un paso significativo, persiste su estado:

```javascript
async function runWithCheckpoints(jobId) {
  const job = await db.jobs.get(jobId);
  let state = job.checkpoint;

  for (let i = state.currentStep || 0; i < totalSteps; i++) {
    try {
      const stepResult = await runStep(i, state);
      state = { ...state, currentStep: i + 1, ...stepResult };

      // Checkpoint
      await db.jobs.update(jobId, {
        checkpoint: state,
        current_step: i + 1,
        status: 'running',
        updated_at: new Date()
      });

      await db.events.insert({ job_id: jobId, event_type: 'step_done', payload: { step: i } });
    } catch (e) {
      await db.jobs.update(jobId, { status: 'failed', error: e.message });
      throw e;
    }
  }

  await db.jobs.update(jobId, { status: 'completed', result: state.finalResult });
}
```

Si el proceso se cae, al reiniciar lee `current_step` y arranca desde ahí.

### Resume pattern

El agente debe ser **reanudable**. Significa:
- No asume contexto en memoria del proceso anterior
- Todo lo necesario está en `checkpoint`
- Paso N solo depende de `checkpoint` + input, no de variables vivas

Anti-patrón: variables globales mutables que no se persisten. Sos un zombie al reiniciar.

### Queue con Supabase / BullMQ / Inngest

Opciones 2026 para la cola:

- **Inngest** — serverless, durable functions, el más ergonómico para agentes largos
- **Trigger.dev** — similar a Inngest, muy buen DX para Next.js
- **BullMQ + Redis** — clásico, control total, self-host
- **Supabase + pg_cron** — minimalista, sin dependencia extra
- **Temporal** — enterprise-grade, durable workflows, curva empinada

Para empezar: **Inngest**. Ejemplo:

```typescript
import { inngest } from '@/lib/inngest';

export const runAgent = inngest.createFunction(
  { id: 'run-agent' },
  { event: 'agent/run' },
  async ({ event, step }) => {
    const plan = await step.run('plan', async () => agent.plan(event.data.task));

    const results = [];
    for (const subtask of plan.subtasks) {
      const r = await step.run(`execute-${subtask.id}`, async () => {
        return await agent.execute(subtask);
      });
      results.push(r);
    }

    return await step.run('synthesize', async () => agent.synthesize(results));
  }
);
```

`step.run` es durable: si se cae, al reintentar NO reejecuta pasos ya completados, usa el resultado cacheado. Checkpoint automático.

### Streaming del progreso al usuario

Mientras el job corre, el frontend tiene que ver avance. Dos opciones:

**Opción A — Polling simple:**
```typescript
useEffect(() => {
  const i = setInterval(async () => {
    const r = await fetch(`/api/jobs/${jobId}`);
    setJob(await r.json());
    if (['completed','failed'].includes(job.status)) clearInterval(i);
  }, 2000);
}, [jobId]);
```

**Opción B — Realtime (Supabase, Pusher, Ably):**
```typescript
const ch = supabase.channel(`job-${jobId}`)
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'agent_jobs',
    filter: `id=eq.${jobId}`
  }, (payload) => setJob(payload.new))
  .subscribe();
```

Realtime es mejor UX pero requiere infra WebSocket. Polling cada 2-5s es perfectamente aceptable hasta cierta escala.

### Human-in-the-loop (HITL)

Para tareas sensibles (enviar email a cliente, borrar datos), el agente **pausa y espera aprobación**:

1. Llega a step "enviar email" → status = `paused`, checkpoint = draft del email
2. Frontend muestra draft con botones [Aprobar] [Editar] [Cancelar]
3. Usuario aprueba → API actualiza status = `running` + aprobación en checkpoint
4. Worker detecta el cambio (polling la cola o trigger) → continúa

### Límites y guardrails

- **Timeout global** — si el job corre >2 horas, se marca `failed` (probable loop infinito)
- **Costo máximo** — acumulás tokens usados; si superás $X, pausás y avisás
- **Max turns por step** — ningún step individual corre >30 turnos del modelo
- **Dead-letter queue** — jobs que fallan 3 veces van a DLQ para revisión manual

### Observabilidad

Cada evento (`step_start`, `tool_call`, `step_done`, `error`) se guarda. Podés hacer un timeline UI que muestre:
- Qué pasos corrió
- Cuánto tardó cada uno
- Qué tools llamó
- Qué outputs intermedios produjo

Langfuse, Helicone o tu propia UI sobre `agent_job_events` resuelven esto.
$md$,
    2, 70,
$md$**Armá un job durable de 5+ pasos con checkpoints.**

Tarea: *"Analizá mi codebase y generá un README actualizado."*

Pasos:
1. Lista archivos relevantes
2. Resume cada archivo (worker con Haiku)
3. Identifica estructura general
4. Genera draft de README
5. Pide aprobación humana antes de escribirlo

Requisitos:
- Guardar estado en Supabase/archivo JSON tras cada paso
- Si matás el proceso en el paso 3, al reiniciarlo arranca en el 3 (no re-ejecuta 1 y 2)
- Paso 5 pausa el job hasta input humano
- Frontend (o CLI) muestra progreso en vivo$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es un checkpoint en un agente de larga duración?',
   '["Un log interno", "El estado persistido tras un paso, que permite resumir sin re-ejecutar lo ya hecho si el proceso se cae", "Un rate limit", "Una validación de seguridad"]'::jsonb,
   1, 0, 'El checkpoint es el estado guardado en DB. Si el proceso muere, al reiniciarse arranca desde el último checkpoint, no desde cero.'),
  (v_lesson_id, '¿Qué herramienta es adecuada para orquestar jobs de agente durables en Next.js 2026?',
   '["localStorage", "Inngest o Trigger.dev — durable functions serverless con reintentos y step caching", "console.log loop", "setInterval"]'::jsonb,
   1, 1, 'Inngest/Trigger.dev dan durabilidad sin montar infra de Redis+BullMQ a mano.'),
  (v_lesson_id, '¿Qué significa Human-in-the-loop (HITL)?',
   '["Un humano ejecuta todo", "El agente pausa en pasos sensibles y requiere aprobación humana antes de continuar", "Un bot controla al humano", "No se usa en 2026"]'::jsonb,
   1, 2, 'HITL es crítico para acciones con consecuencias: enviar emails, borrar datos, confirmar pagos. Permite autonomía controlada.');

  -- L4: Proyecto deep research agent
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Proyecto: agente de deep research',
$md$## Objetivo del proyecto

Construir un **agente de investigación profunda** que recibe un tema y devuelve un informe estructurado en 10-30 minutos:

> *"Investigá el mercado de IDE AI-first en 2026: competidores, pricing, diferenciadores, inversión VC, tracción. Devolveme un informe en Markdown."*

Output esperado:
- 2000-4000 palabras
- Secciones: executive summary, competidores, pricing, tracción, riesgos, tendencias
- Fuentes citadas inline con links
- Tablas comparativas donde aplique

Esto combina **todo** el módulo: MCP, subagentes, checkpoints, tools, memoria.

### Arquitectura

```
┌─────────────────────┐
│  Orchestrator       │
│  (Sonnet 4.6)       │
│                     │
│  1. Plan subqueries │
│  2. Spawn workers   │
│  3. Synthesize      │
└──────────┬──────────┘
           │
   ┌───────┼───────────┬─────────┬──────────┐
   ▼       ▼           ▼         ▼          ▼
[W1]    [W2]        [W3]       [W4]       [W5]
Competi Pricing     Tracción   Inversión  Tendencias
 dores                         Riesgos
   │       │           │         │          │
   │   (cada worker: Haiku + brave-search + fetch-url + memory)
   │
   └── todos guardan notas en MCP memory bajo su key
```

Cada worker:
- Tiene su sub-tópico
- Usa brave-search para encontrar 5-10 fuentes
- Usa fetch-url para leer las mejores
- Extrae insights a bullets + citas
- Guarda resultado en memory key propia

Orchestrator final:
- Lee todas las memory keys
- Arma el informe en Markdown estructurado

### Implementación paso a paso

**1. Setup del proyecto:**

```bash
mkdir deep-research-agent
cd deep-research-agent
npm init -y
npm install @anthropic-ai/claude-agent-sdk @modelcontextprotocol/sdk inngest zod
```

**2. Config MCP servers** (stdio local):

```javascript
// mcp-config.js
export const mcpServers = {
  braveSearch: {
    command: 'npx',
    args: ['-y', '@modelcontextprotocol/server-brave-search'],
    env: { BRAVE_API_KEY: process.env.BRAVE_API_KEY }
  },
  memory: {
    command: 'npx',
    args: ['-y', '@modelcontextprotocol/server-memory']
  },
  fetch: {
    command: 'npx',
    args: ['-y', '@modelcontextprotocol/server-fetch']
  }
};
```

**3. Worker de sub-tópico:**

```javascript
// worker.js
import { ClaudeAgent } from '@anthropic-ai/claude-agent-sdk';
import { loadMcpTools } from './mcp-tools.js';

export async function runWorker({ subtopic, memoryKey, mainTopic }) {
  const tools = await loadMcpTools(['braveSearch', 'fetch', 'memory']);

  const worker = new ClaudeAgent({
    model: 'claude-haiku-4-5',
    systemPrompt: `Sos un researcher especializado.

Tu sub-tópico: "${subtopic}" (contexto general: "${mainTopic}")

Metodología:
1. Hacé 2-4 búsquedas con brave-search usando queries específicas (en inglés y español si aplica).
2. Leé las 3-5 fuentes más relevantes con fetch.
3. Extraé 10-15 insights concretos (no genéricos) con links a las fuentes.
4. Guardá el resultado como markdown en memory bajo la key "${memoryKey}".

Formato del output en memory:
## ${subtopic}

- insight 1 [fuente](url)
- insight 2 [fuente](url)
...`,
    tools,
    maxTurns: 25,
    onToolCall: (c) => console.log(\`[W:\${memoryKey}] tool:\`, c.name)
  });

  await worker.run(\`Arrancá. Tu key de memory es: \${memoryKey}\`);
  return memoryKey;
}
```

**4. Orchestrator:**

```javascript
// orchestrator.js
import { ClaudeAgent, tool } from '@anthropic-ai/claude-agent-sdk';
import { runWorker } from './worker.js';
import { loadMcpTools } from './mcp-tools.js';
import { z } from 'zod';

export async function deepResearch(mainTopic) {
  const memoryTools = await loadMcpTools(['memory']);

  const planner = new ClaudeAgent({
    model: 'claude-sonnet-4-6',
    systemPrompt: 'Sos un planner. Devolvé 5-7 sub-tópicos de investigación en JSON.',
  });

  const plan = await planner.run(\`Tópico: \${mainTopic}
Devolvé JSON: { subtopics: [{ title, memoryKey }] }\`);

  const parsed = JSON.parse(plan.text.match(/\\{[\\s\\S]*\\}/)[0]);

  // Paralelizar workers
  await Promise.all(parsed.subtopics.map(s =>
    runWorker({ subtopic: s.title, memoryKey: s.memoryKey, mainTopic })
  ));

  // Sintetizador
  const synth = new ClaudeAgent({
    model: 'claude-sonnet-4-6',
    systemPrompt: \`Sos un editor. Leé memory keys \${parsed.subtopics.map(s => s.memoryKey).join(', ')} y armá un informe Markdown estructurado (Executive Summary, secciones por subtópico, Tendencias, Riesgos). Conservá todas las citas con links.\`,
    tools: memoryTools
  });

  const report = await synth.run(\`Generá el informe sobre: \${mainTopic}\`);
  return report.text;
}
```

**5. Durabilidad con Inngest** (opcional para demo, clave para prod):

```typescript
export const deepResearchJob = inngest.createFunction(
  { id: 'deep-research', retries: 2 },
  { event: 'research/start' },
  async ({ event, step }) => {
    const plan = await step.run('plan', () => planner(event.data.topic));

    const memoryKeys = await Promise.all(
      plan.subtopics.map(s =>
        step.run(\`worker-\${s.memoryKey}\`, () => runWorker(s))
      )
    );

    return await step.run('synthesize', () => synthesize(event.data.topic, memoryKeys));
  }
);
```

Cada `step.run` es checkpoint. Si se cae en el worker 3, al reintentarlo los otros 4 ya están cacheados.

**6. UI mínima (Next.js):**

- Input textarea para el tópico
- Botón "Iniciar investigación"
- Lista de subtópicos con status (pending / running / done)
- Al terminar, renderiza el markdown con syntax highlighting

### Costos esperados

Para un informe de 3000 palabras sobre un tema medio:

| Componente | Modelo | Tokens aprox | Costo |
|---|---|---|---|
| Planner | Sonnet | 2k in + 1k out | $0.02 |
| 6 workers | Haiku | 15k in + 3k out c/u | $0.15 |
| Synthesizer | Sonnet | 20k in + 5k out | $0.14 |
| **Total** | | | **~$0.30** |

Sub-dólar por informe profundo. Comparado con contratar a un analista: infinitamente más barato.

### Optimizaciones posibles

- **Caching de búsquedas**: si el mismo topic se pide dos veces, no repetir
- **Extended thinking** (Claude 4.X): para planner y synthesizer, activar reasoning largo mejora calidad
- **Model tiering agresivo**: si el subtópico es mecánico (lista de competidores), Haiku alcanza; si es analítico (riesgos regulatorios), Sonnet
- **Validación final**: un último agente "critic" revisa el informe antes de devolverlo

### Qué aprendiste en este módulo

- MCP conecta tools reales sin reimplementarlas
- Subagentes + orchestration escalan a tareas grandes
- Checkpoints hacen los jobs durables y resumibles
- Juntando las 3 cosas, un solo desarrollador construye en 2026 lo que antes requería un equipo: un sistema que investiga, razona y produce informes de calidad, con estado persistente, en minutos y por céntimos.

Este es el superpoder del track: ya no sos usuario de IA — armás sistemas de IA.
$md$,
    3, 80,
$md$**Entrega: un deep research agent funcional.**

1. Implementá el proyecto completo siguiendo la arquitectura propuesta
2. Probalo con 3 tópicos distintos (un producto, un mercado, una tecnología)
3. Medí:
   - Tiempo total por informe
   - Costo en USD por informe (usá console.anthropic.com usage)
   - Calidad subjetiva 1-10
4. Iterá:
   - ¿Qué worker produce outputs peores? Ajustá su prompt
   - ¿El orchestrator deja info fuera? Mejorá el synth prompt
   - ¿Hay redundancia entre workers? Reorganizá subtópicos
5. **Deploy opcional**: subilo a Vercel con Inngest + Supabase para que cualquiera pida informes vía UI

Entregable final: link al repo + 3 informes PDF generados + screenshot de costos.$md$,
    35
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué combinación usa el proyecto deep research?',
   '["Solo prompt engineering", "MCP (tools) + subagentes (workers paralelos) + checkpoints (durabilidad) + memoria (persistir notas)", "Solo un agente grande", "Un script sin LLM"]'::jsonb,
   1, 0, 'Este proyecto integra los tres patrones del módulo: MCP para tools reales, subagentes para paralelismo, checkpoints para durabilidad.'),
  (v_lesson_id, '¿Por qué los workers usan Haiku y el orchestrator Sonnet?',
   '["Por estética", "Model tiering — Sonnet razona (planear/sintetizar), Haiku ejecuta tareas mecánicas (buscar/extraer) y ahorra costo", "Porque Haiku no funciona de orchestrator", "Porque son el mismo modelo"]'::jsonb,
   1, 1, 'Optimización clave: usar modelo caro solo donde agrega valor (decisión/síntesis). Los workers hacen tareas concretas donde Haiku alcanza.'),
  (v_lesson_id, '¿Qué rol cumple Inngest (o Trigger.dev) en el proyecto?',
   '["Genera los prompts", "Hace durable el job: cada step se cachea, si falla en el worker 3 los 4 previos no se re-ejecutan", "Reemplaza a Claude", "Hostea la UI"]'::jsonb,
   1, 2, 'Inngest convierte el job en una durable function. Checkpoints automáticos por step, reintentos sin perder progreso.');

  RAISE NOTICE '✅ Módulo Agentes multi-paso cargado — 4 lecciones + 12 quizzes';
END $$;
