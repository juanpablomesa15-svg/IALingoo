-- =============================================
-- IALingoo — Track "Claude Mastery" / Módulo "MCPs y extensiones"
-- Requiere: migration 20260421_tracks_restructure
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'claude';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo MCPs no encontrado.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- =============================================
  -- LECCIÓN 1: ¿Qué es un MCP?
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    '¿Qué es un MCP?',
$md$## Claude, conectado al mundo real

Hasta ahora Claude — ya sea en el chat o en Claude Code — trabajó con lo que tú le diste: texto, archivos, pantalla. Pero imagina que pudiera **leer tu Gmail, crear eventos en tu calendario, buscar algo en tu Notion o consultar tu base de datos** cuando lo necesita. Eso lo habilita MCP.

**MCP** (Model Context Protocol) es un estándar abierto creado por Anthropic en 2024 para que los modelos de IA se conecten a aplicaciones externas. Piénsalo como un **conector universal** — el USB-C de las IAs. Antes, cada tool (cada "superpoder" que le das a un modelo) se construía a mano. Con MCP, una vez que alguien construye el conector de Gmail, cualquier IA lo puede usar.

### ¿Qué puede hacer Claude con MCPs?

Algunos conectores listos que puedes instalar hoy:

| MCP | Qué habilita |
|---|---|
| Gmail | Leer, buscar, redactar y enviar correos |
| Google Calendar | Ver eventos, crear reuniones, revisar disponibilidad |
| Google Drive | Listar archivos, leer contenido, crear documentos |
| Notion | Leer páginas, crear nuevas, actualizar bases de datos |
| Slack | Enviar mensajes, leer canales, responder hilos |
| GitHub | Leer repos, crear issues, hacer PRs (pull requests) |
| Supabase | Consultar tablas, ejecutar queries SQL |
| Browser | Abrir páginas web y leer su contenido |
| Filesystem | Leer/escribir archivos de tu computador |

Y más de 200 MCPs comunitarios para casi cualquier app popular.

### El salto mental

Sin MCP:

> Tú: "¿Qué reuniones tengo mañana?"
> Claude: "No tengo acceso a tu calendario, tendrías que contarme."

Con MCP de Calendar:

> Tú: "¿Qué reuniones tengo mañana?"
> Claude: *consulta tu calendario* "Tienes 3: a las 9am con Juan, 11am standup y 3pm demo cliente."

La conversación no cambió. Lo que cambió es que Claude ahora **puede actuar** sobre tus apps reales. El chat dejó de ser un juguete de preguntas y respuestas para volverse un asistente útil.

### Cómo funciona (la intuición)

Técnicamente un MCP es un **servidor pequeño** que expone "herramientas" (funciones que Claude puede llamar). Cuando Claude ve que necesita algo, llama a la herramienta, el servidor ejecuta, devuelve el resultado, y Claude lo integra en su respuesta.

No necesitas entender esto a fondo para usarlos. Es como usar Wi-Fi sin saber cómo funcionan los paquetes de red por debajo.

### Dónde instalar MCPs

Los MCPs se instalan en el **cliente** donde usas Claude:

- **Claude Desktop** (app de escritorio) — el más popular
- **Claude Code** (terminal o IDE como Antigravity)
- **Claude.ai web** — algunas extensiones oficiales directamente desde Configuración

Cada uno tiene su forma de instalarlos. En este módulo vamos a arrancar por Claude Desktop porque es la más amigable.

### Lo que NO es un MCP

Para evitar confusiones:

- **No es una extensión de navegador**. No vive en Chrome.
- **No es un plugin de una app específica**. No lo instalas en Gmail; lo instalas en Claude, y Claude habla con Gmail.
- **No es una app independiente**. No lo abres como abres WhatsApp.

Es una **pieza de conexión** que corre en tu computador (o en la nube) y Claude la usa cuando la necesita.

### ¿Qué vas a aprender aquí?

- Cómo instalar MCPs en Claude Desktop y Claude Code
- Los 5 MCPs más útiles para tu día a día
- Cómo configurar permisos para que Claude no haga cosas que no quieres
- Un primer flujo real donde Claude lee emails, cruza con tu calendario y te sugiere acciones

Al final del módulo tu Claude va a ser **asistente personal de verdad**, no solo un chat.$md$,
    0,
    50,
$md$**Mini-investigación**: entra a [modelcontextprotocol.io/servers](https://modelcontextprotocol.io/servers) y lista los 3 MCPs que más te llaman la atención para tu flujo de trabajo. Para cada uno anota:

1. Qué aplicación conecta
2. Qué herramienta(s) expone (leer, escribir, buscar)
3. Qué uso concreto se te ocurre para tu trabajo o vida personal

**Ejemplo**: "MCP de Notion — expone search_pages y create_page — lo usaría para que Claude busque en mis notas cuando le haga preguntas sobre un proyecto."$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué es MCP?',
     to_jsonb(ARRAY[
       'Un modelo de IA más potente que GPT-4',
       'Un estándar abierto para conectar modelos de IA a aplicaciones externas',
       'Una extensión de navegador que mejora Claude',
       'Un formato de archivo para compartir prompts'
     ]),
     1,
     0,
     'MCP (Model Context Protocol) es un estándar abierto creado por Anthropic en 2024. Define cómo un modelo de IA se conecta a apps externas (Gmail, Notion, tu base de datos, etc). La ventaja de que sea estándar: una vez que alguien construye un MCP para una app, cualquier IA lo puede usar.'),

    (v_lesson_id,
     '¿Cuál de estas cosas puede hacer Claude con un MCP instalado?',
     to_jsonb(ARRAY[
       'Leer tu inbox de Gmail y redactar respuestas',
       'Crear un evento en Google Calendar',
       'Consultar tu base de datos Supabase con SQL',
       'Todas las anteriores, cada una con su MCP correspondiente'
     ]),
     3,
     0,
     'MCP es un conector genérico. Cada app tiene su propio MCP (hay más de 200 disponibles). Una vez instalado, Claude puede hablar con esa app — leer datos, escribir, buscar, lo que el MCP exponga. Es la diferencia entre un chat "solo texto" y un asistente que actúa sobre tus herramientas reales.'),

    (v_lesson_id,
     'Un amigo te dice "instalé un MCP en mi Gmail". ¿Qué hay de malo con esa frase?',
     to_jsonb(ARRAY[
       'MCPs no existen todavía',
       'Los MCPs se instalan en el cliente de Claude (Desktop, Code), no en la app destino (Gmail)',
       'Gmail no soporta MCPs',
       'MCP solo funciona con Outlook'
     ]),
     1,
     0,
     'Confusión común: el MCP es la pieza de conexión que corre en tu computador o en la nube, y se instala en el cliente donde usas Claude (Claude Desktop, Claude Code). No se instala dentro de Gmail ni de ninguna app destino. Claude usa el MCP como puente para hablar con Gmail a través de la API pública de Google.');


  -- =============================================
  -- LECCIÓN 2: Instala tus primeros MCPs
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Instala tus primeros MCPs',
$md$## De cero a Claude conectado en 15 minutos

Vamos a instalar 3 MCPs clave para que veas la magia funcionando. Los 3 los vas a usar todos los días:

1. **Gmail** — leer y redactar correos
2. **Google Calendar** — ver y crear eventos
3. **Filesystem** — leer archivos de tu computador

### Paso 0: Instala Claude Desktop

Si aún no la tienes, descarga [Claude Desktop](https://claude.ai/download). Es la app oficial para Mac y Windows. Ábrela, loguéate con tu cuenta Claude, y listo. Se ve igual que Claude.ai pero corre localmente.

### Paso 1: Activa MCPs en Settings

En Claude Desktop ve a **Settings > Developer > Model Context Protocol**. Activa la opción. Esto desbloquea el panel de MCPs.

### Paso 2: Instala Gmail y Calendar (versiones oficiales de Anthropic)

Desde el mismo panel hay un marketplace. Busca "Gmail" y "Google Calendar" — los oficiales dicen "by Anthropic". Click en instalar.

La primera vez te va a pedir autorización OAuth (el protocolo estándar para que una app te pida permiso sobre otra app tuya). Se abre tu navegador, autorizas con tu cuenta Google, vuelves a Claude Desktop. Listo.

**Seguridad**: Google te muestra exactamente qué permisos estás dando. Si dice "leer y enviar correos" y tú solo quieres lectura, puedes buscar una versión con permisos más restringidos. **No apruebes ciegamente.**

### Paso 3: Prueba Gmail

Vuelve al chat y escribe:

> "Busca en mi Gmail los últimos 5 correos de mi jefe y resúmeme qué pide cada uno."

Claude Desktop va a detectar que necesita el MCP de Gmail. Te va a pedir **permiso la primera vez** ("¿Autorizas a Claude a usar la herramienta gmail_search?"). Apruebas. Ejecuta. Te devuelve el resumen.

### Paso 4: Prueba Calendar

> "Mira mi calendario esta semana y dime qué días tengo más libres para agendar una reunión de 1 hora."

Claude consulta el calendario, cruza los eventos, te sugiere días. De nuevo — primera vez pide permiso, luego ya no.

### Paso 5: Instala Filesystem (el más útil después)

Busca "Filesystem" en el marketplace. La diferencia: este MCP necesita que le digas **qué carpetas puede acceder**. Por seguridad, nunca le des acceso a toda tu computadora — solo a las carpetas específicas donde trabajas.

Ejemplo: dale acceso solo a `~/Documents/proyectos/` y no a tu carpeta de Descargas.

Una vez configurado, puedes:

> "En mi carpeta ~/Documents/proyectos/propuestas, lista los PDFs y resúmeme cada uno."

Claude lee los archivos, te da un resumen de todos sin que los abras uno por uno.

### El patrón de permisos

Para cada MCP, Claude te va a preguntar la primera vez que use una herramienta. Las opciones suelen ser:

- **Solo esta vez**: ejecuta esta llamada pero vuelve a preguntar la próxima
- **Siempre**: no preguntar más en esta sesión
- **Denegar**: no ejecutes

**Recomendación**: las primeras semanas usa "solo esta vez" para entender qué hace cada MCP. Cuando te sientas cómodo pasa a "siempre" para los que uses más.

### Claude Code y MCPs

Si usas Claude Code en terminal, los MCPs se configuran en `~/.claude/config.json` o dentro de la carpeta del proyecto `.claude/`. La sintaxis es un archivo JSON (un formato simple de texto con listas y claves-valor) que le dice qué MCPs cargar. Cada MCP tiene su propia forma de configurarse — lo importante es que la lógica es la misma que en Desktop: actívalo, dale permisos, úsalo.

### Troubleshooting común

**"El MCP no aparece"**: reinicia Claude Desktop. Los MCPs se cargan al arrancar.

**"Me pide credenciales cada vez"**: normal en la primera ejecución. Si pasa siempre, el OAuth se venció — reautoriza desde Settings.

**"Claude no usa el MCP aunque lo tengo"**: a veces hay que ser explícito. En vez de "¿qué tengo mañana?", di "mira mi calendario y dime qué tengo mañana". Le das la pista.

### Qué viene

Con los 3 MCPs instalados ya tienes el 80% de casos útiles cubiertos: correo, agenda y archivos. En la siguiente lección vamos a **combinarlos** — Claude leyendo un email, cruzando con calendario, y proponiendo una respuesta inteligente. Ahí es donde la magia de MCP se siente.$md$,
    1,
    60,
$md$**Instala 3 MCPs y pruébalos.**

Obligatorios:
1. **Gmail** — pruébalo con: _"Resume los 5 correos más recientes de mi inbox"_
2. **Google Calendar** — pruébalo con: _"¿Qué reuniones tengo hoy y mañana?"_
3. **Filesystem** (configurado con una sola carpeta segura) — pruébalo con: _"Lista los archivos de [tu carpeta] y dime de qué trata cada uno"_

**Bonus (elige uno):**
- Notion — _"Busca en mi Notion información sobre [tema]"_
- Slack — _"Muestra los mensajes no leídos más importantes"_
- GitHub — _"Lista mis repos y dime cuáles tienen PRs abiertos"_

**Meta**: terminar la lección con Claude conectado a al menos 3 apps reales y sintiendo "no voy a volver a usarlo sin esto".$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Al instalar el MCP de Gmail, te aparece una pantalla de Google pidiéndote autorizar permisos. ¿Qué deberías hacer?',
     to_jsonb(ARRAY[
       'Aceptar ciegamente, Anthropic es una empresa seria',
       'Leer los permisos — si dice "leer y enviar correos" y tú solo quieres lectura, buscar una versión más restrictiva',
       'Rechazar todos los permisos',
       'Ignorar la pantalla'
     ]),
     1,
     0,
     'Nunca apruebes permisos OAuth ciegamente, sin importar la empresa. Google te muestra exactamente qué le estás dando acceso. Si el MCP pide más permisos de los que necesitas para tu caso, busca una versión con permisos más restrictivos o configúralos manualmente. Esto es seguridad básica con cualquier app que se conecte a tus cuentas.'),

    (v_lesson_id,
     'Al instalar el MCP de Filesystem, ¿qué es lo más seguro?',
     to_jsonb(ARRAY[
       'Darle acceso a toda tu computadora para que pueda buscar mejor',
       'Darle acceso solo a carpetas específicas donde trabajas (ej. ~/Documents/proyectos/)',
       'No usar Filesystem, es muy riesgoso',
       'Solo darle acceso a la carpeta de Descargas'
     ]),
     1,
     0,
     'Filesystem expone herramientas para leer y escribir archivos. Darle acceso a toda tu máquina significa que Claude podría leer accidentalmente archivos sensibles (tokens, datos personales, fotos privadas). La regla: solo las carpetas donde trabajas con él. Nunca tu carpeta de Descargas (ahí viven todos los archivos que bajas, probablemente incluyendo cosas que no quieres que una IA lea) ni tu Home completo.'),

    (v_lesson_id,
     'Claude Desktop no parece usar tu MCP de Calendar aunque está instalado. ¿Qué intentas primero?',
     to_jsonb(ARRAY[
       'Borrar el MCP y reinstalar',
       'Reiniciar Claude Desktop y, si sigue, ser más explícito en la instrucción ("mira mi calendario y...")',
       'Cambiar a otro modelo',
       'Actualizar el sistema operativo'
     ]),
     1,
     0,
     'Primera causa: MCPs se cargan al arrancar, si instalaste sin reiniciar, no aparece. Segunda: a veces Claude no asume que debe usar un MCP si la instrucción es ambigua ("¿qué tengo mañana?" podría ser cualquier cosa). Ser explícito ("mira mi calendario") le da la pista para invocar la herramienta correcta.');


  -- =============================================
  -- LECCIÓN 3: Combina MCPs para flujos reales
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Combina MCPs para flujos reales',
$md$## Donde la magia empieza: varios MCPs hablando entre sí

Tener MCPs sueltos es útil. Combinarlos es **transformador**. Ahí es donde Claude deja de ser un chat y se vuelve un asistente personal de verdad.

### Ejemplo 1: Triaje de emails

Tienes 50 correos sin leer. Normalmente te toma 30 minutos decidir cuáles son importantes. Con Claude:

> "Lee los emails no leídos de las últimas 24 horas. Clasifícalos en: (1) urgente — requiere respuesta hoy, (2) importante — respuesta esta semana, (3) info — solo leer, (4) basura. Dame la lista con una línea de contexto por cada uno."

Claude consulta Gmail vía el MCP, procesa los correos, los clasifica. En 2 minutos tienes el triaje hecho. Tú solo decides qué hacer con la lista.

### Ejemplo 2: Agenda inteligente

> "Mira mi calendario de esta semana. Busca en mi Gmail si hay contexto reciente para cada reunión (emails con el tema o con los participantes). Para cada reunión, dime: hora, con quién, tema, y si hay algún email que debería leer antes."

Claude cruza calendario + email. Antes de cada meeting tienes el contexto servido. Cero preparación manual.

### Ejemplo 3: Recap diario al cerrar el día

> "Son las 6pm. Mírame el día:
> - Eventos del calendario de hoy
> - Correos importantes que llegaron
> - Commits que hice en GitHub
> - Mensajes en los canales de Slack #trabajo e #equipo
>
> Dame un resumen en 5 bullets de qué hice hoy y 3 cosas que debería priorizar mañana."

Claude consulta 4 MCPs distintos y te da un brief del día. Reemplaza el ejercicio de sentarte a recordar qué hiciste. Genial para el momento de cerrar laptop sin sensación de "¿qué hice hoy?".

### Ejemplo 4: Redacción con contexto

> "Voy a responderle a [cliente] un email. Antes, búscame todos los correos previos con esta persona, dame un resumen de nuestro histórico y luego ayúdame a redactar una respuesta al último que me mandó."

Claude busca en Gmail todo lo relacionado con esa persona, te da el contexto, y redacta una respuesta que honra la historia. Dejas de sonar genérico en correos importantes.

### Ejemplo 5: Automatización suave (no un agente, pero parecido)

> "Cada vez que llegue un correo con asunto que contenga 'factura', guardalo en mi carpeta ~/Documents/facturas/ y agrégale a mi calendario un recordatorio 3 días antes del vencimiento."

Claude no hace esto "por sí solo" — tú lo pides cuando quieres que ocurra. Pero es útil para casos puntuales. Si quieres que ocurra **sin que lo pidas**, ya entramos en territorio de agentes (siguiente track).

### El patrón mental: "cross-app thinking"

La gente que saca más valor de MCP es la que **piensa en sus datos como un grafo conectado**, no en silos.

- Gmail tiene el histórico con tus clientes
- Calendar tiene el timing de las conversaciones
- Notion tiene los apuntes y documentos
- GitHub tiene el código y las decisiones técnicas
- Slack tiene lo informal y rápido

Una pregunta como "¿cómo va el proyecto X?" requiere **tocar todos esos sistemas**. Antes, ibas a cada uno y armabas el cuadro en tu cabeza. Con MCPs, Claude lo arma en 30 segundos.

### Cuándo NO usar MCPs

Para ser honestos:

- **Para preguntas genéricas** ("explícame React"), un chat normal basta. No invoca ningún MCP.
- **Para tareas críticas con datos sensibles** (mandar un email a un cliente importante), ten cuidado con el modo "siempre aprobar" — mejor que pida confirmación cada vez.
- **Cuando los MCPs están lentos** (el de filesystem con miles de archivos puede tardar). Alternativa: ser más específico en qué carpeta mirar.

### Buenas prácticas

1. **Sé específico en qué MCPs debe usar**: "usa Calendar y Gmail para..." ayuda a Claude a no equivocarse de herramienta.
2. **Aprende a leer cuando está llamando un MCP**: te aparece un indicador. Si no aparece, probablemente no está consultando el dato real — solo respondiendo de memoria.
3. **Desinstala los que no uses**: cada MCP activo consume contexto al iniciar cada conversación. Menos = más rápido.
4. **Audita permisos cada cierto tiempo**: entra a tu cuenta Google cada 3 meses, mira qué apps tienen acceso, revoca las que ya no uses.$md$,
    2,
    70,
$md$**Construye tu flujo personal de productividad.**

Diseña y ejecuta un flujo que use **al menos 2 MCPs combinados**. Elige uno de estos o inventa el tuyo:

1. **Triaje matinal**: lee correos no leídos + calendario del día → clasifica por urgencia, dame lo crítico primero
2. **Prep reunión**: para la próxima reunión en mi calendario, busca correos previos con esos participantes y dame un brief
3. **Recap semanal**: cada viernes, combina commits GitHub + correos importantes de la semana + notas Notion en un resumen de 10 bullets
4. **Cliente importante**: busca todo el histórico con [cliente X] en Gmail + Notion y dame un brief de 1 página

Al final:
- Escribe un prompt reusable que uses cada día/semana (guárdalo en un archivo `prompts/triaje.md`)
- Dócumenta qué MCPs usa y qué decisión automatiza para ti

**Meta**: terminar con al menos un flujo que vayas a usar recurrente.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Por qué combinar MCPs es más poderoso que usarlos sueltos?',
     to_jsonb(ARRAY[
       'Porque Claude va más rápido',
       'Porque muchas preguntas reales requieren cruzar varias fuentes (ej: email + calendario + tareas) y hacerlo manual toma minutos, con Claude toma segundos',
       'Porque ahorras en el plan de Claude',
       'Porque los MCPs sueltos no funcionan bien'
     ]),
     1,
     0,
     'Tu información está repartida en muchas apps. Preguntas útiles como "qué tengo mañana y con qué contexto" requieren tocar múltiples sistemas. Antes de MCP hacías ese cruce mental. Con MCP, Claude lo hace por ti y te entrega el cuadro ya integrado. El valor no está en cada MCP aislado — está en orquestarlos.'),

    (v_lesson_id,
     'Estás a punto de dejarle permiso "siempre aprobar" al MCP de Gmail. ¿Cuándo sería una mala idea?',
     to_jsonb(ARRAY[
       'Nunca es mala idea',
       'Cuando esperas que Claude envíe correos importantes sin que tú revises — mejor mantener el modo de confirmación por acción',
       'Siempre es mala idea',
       'Solo si usas Outlook en vez de Gmail'
     ]),
     1,
     0,
     'Leer emails es relativamente seguro. Pero "enviar" o "borrar" son acciones destructivas. Dejar "siempre aprobar" para todas las herramientas de Gmail incluye enviar. Si Claude interpreta mal una instrucción y envía algo raro a un cliente, no hay Ctrl+Z. Mejor dejarle aprobado solo read/search y mantener send bajo confirmación manual.'),

    (v_lesson_id,
     'Piensas pedirle a Claude "¿cómo va el proyecto X?". ¿Qué hace más útil la pregunta?',
     to_jsonb(ARRAY[
       'Dejarla así, Claude sabrá qué hacer',
       'Decir explícitamente qué MCPs debe usar: "mira Gmail, Notion y GitHub y dame el estado de X"',
       'No importa, el resultado es el mismo',
       'Preguntar uno por uno a cada MCP'
     ]),
     1,
     0,
     'Cuando hay ambigüedad, Claude puede usar los MCPs equivocados o ninguno. Darle explícitamente "usa estos 3 MCPs" elimina la adivinanza. Con el tiempo, cuando Claude conozca tu estilo y contexto (ej. vía CLAUDE.md con info del proyecto), puedes volver a las preguntas más abiertas. Pero mientras aprende tus patrones, sé explícito — el costo es mínimo y el resultado mucho mejor.');


  -- =============================================
  -- LECCIÓN 4: Construye tu propio MCP
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Construye tu propio MCP',
$md$## El nivel que pocos alcanzan

Usar MCPs hechos por otros ya te pone en el 10% de usuarios de Claude. Pero hay un nivel más: **construir el tuyo**. Y con Claude Code es más fácil de lo que imaginas.

### ¿Cuándo tiene sentido?

No siempre. Reglas prácticas:

- **Usa un MCP oficial** si existe. Ej: para Google Drive ya hay uno oficial — no construyas otro.
- **Usa un MCP comunitario** si funciona bien. Hay más de 200 y cubren casi todo.
- **Construye el tuyo** cuando:
  - Tu app es interna (no existe un MCP público)
  - Necesitas una lógica muy específica (ej. "calcula mi health score de cliente")
  - Los MCPs existentes son genéricos y tu caso es particular

### Ejemplo real: MCP para tu stack interno

Imagina que trabajas en una empresa y tienes una base de datos interna con clientes. Quieres que Claude pueda:

- Buscar cliente por nombre o email
- Ver histórico de soporte
- Consultar el contrato actual

Ningún MCP público hace esto — es tu base de datos. La solución: tu propio MCP.

### Cómo se ve un MCP por dentro (la intuición)

Un MCP es un servidor chico que expone **herramientas**. Cada herramienta es una función con:

- **Nombre** (ej: `get_client_by_email`)
- **Descripción** (para que Claude sepa cuándo usarla)
- **Parámetros** que necesita (ej: email)
- **Lógica** que se ejecuta cuando Claude la llama

El SDK de Anthropic te da plantillas en Python y TypeScript (TypeScript es JavaScript con tipos — una forma más segura de escribir código). Clonas la plantilla, escribes tus herramientas, y listo.

### El camino más rápido (en serio)

Con Claude Code, hoy, 2026: le dices qué MCP quieres y él lo construye. Ejemplo:

> "Quiero un MCP que exponga dos herramientas: (1) 'search_client' — recibe un nombre o email, busca en mi base Supabase en la tabla 'clients' y devuelve los 5 mejores matches. (2) 'get_client_tickets' — recibe un client_id y devuelve sus últimos 10 tickets de soporte. Usa el template oficial de MCP en TypeScript. Configura para que yo pueda probarlo en Claude Desktop."

Claude Code:

1. Clona el template oficial
2. Escribe las dos herramientas con la lógica Supabase
3. Configura el archivo de conexión
4. Te da los pasos para instalarlo en Claude Desktop

En 15 minutos tienes un MCP custom corriendo. Sin haber escrito código.

### Estructura mínima de un MCP

Un archivo típico se ve así (simplificado):

```typescript
server.tool(
  "search_client",
  "Busca clientes por nombre o email",
  { query: z.string() },
  async ({ query }) => {
    const results = await supabase
      .from("clients")
      .select("*")
      .or(`name.ilike.%${query}%,email.ilike.%${query}%`)
      .limit(5);
    return { content: results };
  }
);
```

No necesitas entender cada línea. La idea es: **le pones nombre, descripción, parámetros y el código que ejecuta**. Claude lo lee y decide cuándo usarlo.

### Seguridad de MCPs custom

Cuando construyes el tuyo eres responsable de:

- **Credenciales**: los tokens y passwords en un archivo `.env` (nunca en el código) — `.env` es un archivo que los programas leen pero que no se sube a git
- **Permisos**: si la herramienta puede borrar datos, piénsalo dos veces. Mejor tener `get_*` (lectura) que `delete_*` (escritura destructiva)
- **Dónde corre**: tu MCP puede correr localmente (solo en tu máquina) o en la nube (accesible para otros). Si tu equipo lo usa, pónganlo en la nube con autenticación

### Compartir tu MCP con el equipo

Si construyes algo útil, tienes 3 opciones:

1. **Keep it private**: solo tú lo usas, corre en tu máquina
2. **Compartir interno**: lo publicas en el repo de tu empresa, todos lo instalan
3. **Open source**: lo publicas en GitHub y en el marketplace oficial de Anthropic. La comunidad de MCPs crece así

Empezar privado y graduar a compartido es la ruta natural.

### Herramientas avanzadas que vale la pena explorar

Algunos patrones de MCPs que marcan diferencia:

- **MCP con memoria**: la tool guarda información entre llamadas (ej. "recuerda que el cliente Acme pidió X")
- **MCP con confirmación**: para acciones destructivas, la tool requiere un token que Claude debe obtener primero de ti
- **MCP con cache**: si la consulta es cara, guardás el resultado por N minutos

Todo eso se puede construir con pocas líneas en el template.

### Recap de todo el track

Llegaste al final de Claude Mastery. Lo que sabes hoy:

- **Módulo 1 (Claude Básico)**: modelos, interfaz, proyectos, artefactos, archivos e imágenes
- **Módulo 2 (Claude Code)**: agente en tu terminal/IDE, primer proyecto real, slash commands, plan mode, git y refactor
- **Módulo 3 (MCPs)**: conectar Claude a tu mundo digital, combinar MCPs, construir los tuyos

Con esto, Claude deja de ser una app que abres a veces y se vuelve **una capa sobre todo tu trabajo**. Es la base para los siguientes tracks — especialmente Agentes, que se apoya 100% en MCP.$md$,
    3,
    70,
$md$**Diseña tu MCP personal.**

No tienes que construirlo (aunque puedes si quieres). El objetivo es pensar uno que resuelva un problema real tuyo:

1. **Identifica un sistema tuyo** sin MCP oficial (una DB, una API interna, una hoja de Google, un script personal)
2. **Define 2-3 herramientas** que expondría:
   - Nombre
   - Qué hace (descripción de 1 línea)
   - Parámetros que recibe
   - Qué devuelve
3. **Escribe el prompt** que le darías a Claude Code para construirlo (patrón: "Crea un MCP con template oficial en TS, expone estas N tools con esta lógica, configura para Desktop")
4. **Bonus**: si ya tienes Supabase/cualquier API o base de datos, pídele a Claude Code que lo construya de verdad — en 20 minutos debería estar probando

**Meta**: tener en la cabeza un diseño concreto de MCP hecho a la medida de tu contexto, y el prompt listo para construirlo cuando lo necesites.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuándo NO tiene sentido construir tu propio MCP?',
     to_jsonb(ARRAY[
       'Cuando ya existe un MCP oficial o comunitario que hace lo mismo',
       'Cuando tienes una app interna sin conector público',
       'Cuando necesitas lógica muy específica de tu negocio',
       'Cuando quieres exponer algo de tu base de datos propia'
     ]),
     0,
     0,
     'Si alguien ya resolvió el problema (Gmail, Calendar, Drive, Notion, etc.), úsalo. Construir algo que ya existe es trabajo desperdiciado. Los MCPs custom brillan cuando tu caso es único: una DB interna, una lógica de negocio específica, una integración con un sistema sin cobertura pública.'),

    (v_lesson_id,
     'Al construir un MCP que interactúa con tu base de datos, ¿cuál es una buena práctica de seguridad?',
     to_jsonb(ARRAY[
       'Poner las credenciales directamente en el código',
       'Guardar tokens y passwords en un archivo .env, fuera del control de versiones (git)',
       'Usar la cuenta admin de la DB',
       'No usar autenticación, más simple'
     ]),
     1,
     0,
     'Credenciales en el código = cualquiera que vea tu código las ve (si lo compartes, subes a GitHub, etc.). El archivo .env es la convención estándar: vive en tu máquina, los programas lo leen, pero no se sube a git (se agrega al .gitignore). Además, separar credenciales del código te deja rotarlas sin modificar el código.'),

    (v_lesson_id,
     'Quieres construir un MCP para tu stack, pero no eres programador experimentado. ¿Qué es lo más rápido?',
     to_jsonb(ARRAY[
       'Aprender 6 meses de Python primero',
       'Pedirle a Claude Code que lo construya sobre el template oficial, describiéndole las tools que quieres',
       'Esperar hasta que exista uno oficial',
       'Contratar a un dev'
     ]),
     1,
     0,
     'Este es el combo más poderoso de todo el curso: Claude Code construye tu MCP mientras tú conversás. Te alcanza con saber qué tools quieres exponer, con qué parámetros y qué deben devolver. Claude Code clona el template, escribe la lógica, configura y te deja probándolo en 15-20 min. Sin necesidad de ser ingeniero.');

  RAISE NOTICE 'Módulo "MCPs y extensiones": 4 lecciones + 12 quizzes insertados.';

END $$;
