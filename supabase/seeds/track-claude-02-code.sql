-- =============================================
-- IALingoo — Track "Claude Mastery" / Módulo "Claude Code"
-- Requiere: migration 20260421_tracks_restructure
-- Idempotente: re-ejecutable
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'claude';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo Claude Code no encontrado. Corre primero la migración 20260421_tracks_restructure.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- =============================================
  -- LECCIÓN 1: ¿Qué es Claude Code?
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    '¿Qué es Claude Code?',
$md$## El salto de "chatear con IA" a "trabajar con IA"

Hasta ahora usaste Claude en [claude.ai](https://claude.ai): le hablas, te responde, copias el resultado a donde lo necesites. Claude Code es otra cosa.

**Claude Code es un agente que vive en tu computador y ejecuta acciones reales.** Puede:

- Leer cualquier archivo de tu proyecto
- Escribir y modificar archivos
- Correr comandos en la terminal — CLI (la línea de comandos — esa pantalla negra donde los programadores escriben texto)
- Hacer commits de git (git es el sistema estándar para guardar versiones de tu código)
- Ejecutar tests, instalar librerías, abrir navegadores

La diferencia no es sutil. Pasas de "copiar y pegar código del chat" a "decirle qué quieres y él lo hace". Es como la diferencia entre un asesor que te dice qué cocinar y un chef que lo cocina contigo en tu cocina.

### ¿Por qué importa esto?

Un ejemplo rápido. Con Claude.ai:

> Tú: "¿Cómo cambio el color del botón?"
> Claude: "Busca el archivo Button.tsx, cambia la línea X a Y..."
> Tú: *abres el editor, buscas, pegas, revisas, guardas*

Con Claude Code:

> Tú: "Cambia el color del botón principal a morado."
> Claude Code: *lee el archivo, lo modifica, te muestra el diff, tú apruebas o corriges*

Son los mismos 30 segundos de conversación. Pero el trabajo real queda hecho.

### CLI vs IDE: dos formas de usarlo

Claude Code tiene dos interfaces y elegir la correcta cambia tu experiencia. IDE (el editor de código — como Word pero especializado en programar).

| | **Claude Code CLI** | **Antigravity (IDE)** |
|---|---|---|
| **Dónde vive** | Dentro de la terminal | En un editor con ventanas |
| **Cuándo brilla** | Proyectos donde ya sabes moverte | Cuando estás aprendiendo o exploras |
| **Velocidad** | Máxima — todo con teclado | Media — clics + teclado |
| **Aprovecha plugins del editor** | No | Sí (extensiones, linting, debugger) |
| **Para quién** | Devs o power users | Cualquiera, curva más amable |

**Regla simple**: si te intimida la terminal, empieza con **Antigravity**. Si ya te mueves bien con CLIs, el modo CLI es más rápido.

### Instalación (2 minutos)

**Opción A — Claude Code CLI:**

```bash
npm install -g @anthropic-ai/claude-code
```

Necesitas tener Node.js instalado (Node es el motor que corre JavaScript fuera del navegador — ve a [nodejs.org](https://nodejs.org) si no lo tienes). Luego en cualquier carpeta:

```bash
claude
```

La primera vez te pedirá loguearte. Se abre tu navegador, autorizas con tu cuenta Claude Pro o Max y listo.

**Opción B — Antigravity:**

Descarga [Antigravity](https://antigravity.google/) — es el IDE gratuito de Google con Claude integrado. Lo abres, abres una carpeta, y el chat ya vive al lado de tu código.

### Tu primera sesión: 60 segundos

Una vez instalado, en cualquier carpeta:

```bash
claude
```

Verás el prompt listo. Escribe:

> "Cuéntame qué hay en esta carpeta y qué tipo de proyecto es."

Claude Code va a **listar los archivos, leer los que importen y resumirte el proyecto**. Sin que tú hayas tocado nada. Esta es la magia: entiende el contexto antes de actuar.

### ¿Cuál plan necesito?

Claude Code consume más que el chat normal (lee/escribe archivos, ejecuta pasos). Necesitas mínimo **Claude Pro ($20/mes)** pero la experiencia cómoda empieza en **Max**.

Si no quieres suscribirte aún, puedes usarlo con una API key de Anthropic — pagas por uso. Bueno para probarlo sin compromiso, caro si lo usas todos los días.

### Lo que viene

En las próximas lecciones vas a:

1. Construir tu primer proyecto real desde cero
2. Dominar slash commands y plan mode (las dos herramientas que separan a los que usan Claude Code del arte de verdad)
3. Hacer git, refactor de múltiples archivos y debugging como pro

Al final de este módulo vas a haber construido una mini-app funcional usando únicamente conversación en español con Claude Code.$md$,
    0,
    50,
$md$**Instala Claude Code en tu computador.**

Elige una de las dos opciones:

**Opción A (más rápida si tienes Node):**
```bash
npm install -g @anthropic-ai/claude-code
```
Luego abre cualquier carpeta en tu terminal y escribe `claude`.

**Opción B (más amable si nunca tocaste una terminal):**
Descarga [Antigravity](https://antigravity.google/) — ábrelo, crea o abre una carpeta, y empieza desde el panel lateral.

**Primera prueba**: pídele "Cuéntame qué hay en esta carpeta y qué tipo de proyecto es". Observa cómo te responde sin que hayas copiado ni pegado nada. Esa es la diferencia con el chat normal.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál es la diferencia principal entre Claude.ai y Claude Code?',
     ARRAY[
       'Claude Code es más barato',
       'Claude Code ejecuta acciones reales (lee/escribe archivos, corre comandos), Claude.ai solo habla',
       'Claude Code usa un modelo diferente y más inteligente',
       'Son lo mismo, solo cambia el nombre'
     ],
     1,
     0,
     'Claude.ai es conversación — te dice qué hacer. Claude Code es un agente — lo hace él mismo en tu proyecto. Usan los mismos modelos Claude 4.X por debajo; la magia está en las herramientas que tiene Claude Code para actuar: leer archivos, escribir archivos, correr comandos, hacer commits.'),

    (v_lesson_id,
     'Si nunca has usado una terminal y te intimida el texto negro con comandos, ¿cuál deberías elegir para empezar?',
     ARRAY[
       'Claude Code CLI — es más rápido',
       'Antigravity (el IDE con Claude integrado) — curva de aprendizaje más amable',
       'Claude.ai — no necesitas Claude Code',
       'Esperar hasta aprender a usar la terminal'
     ],
     1,
     0,
     'Antigravity vive en un editor visual con ventanas, como cualquier app normal. Tienes el chat al lado de tu código. Cuando te sientas cómodo puedes cambiar al CLI, que es más veloz pero exige familiaridad con la terminal.'),

    (v_lesson_id,
     '¿Qué plan de Claude necesitas como mínimo para usar Claude Code cómodamente?',
     ARRAY[
       'Plan Free',
       'Plan Pro ($20/mes), aunque Max da mejor experiencia para uso diario',
       'Solo funciona con API key',
       'Plan Enterprise'
     ],
     1,
     0,
     'Claude Code no funciona con Free. Pro es el mínimo realista y te sirve para proyectos pequeños. Si lo usas todos los días, Max te va a dar más margen sin preocuparte por los límites. También puedes usarlo con una API key pagando por uso — sirve para probar, pero sale caro si lo usas seguido.');


  -- =============================================
  -- LECCIÓN 2: Tu primer proyecto real
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Tu primer proyecto real',
$md$## De cero a algo funcionando en 15 minutos

Vamos a construir algo real. No un tutorial de "hola mundo" — una mini-app que puedas usar después. La idea: **no vas a escribir ni una línea de código tú**. Solo vas a conversar en español.

### El proyecto: lista de tareas con persistencia

Suena aburrido pero es el mejor ejemplo porque toca **frontend** (lo que se ve), **backend** (lo que guarda los datos) y **deploy** (publicarlo). Todo lo esencial.

### Paso 1: crea la carpeta

Abre tu terminal o Antigravity, y crea una carpeta:

```bash
mkdir mi-todo-app
cd mi-todo-app
claude
```

Si usas Antigravity: File > Open Folder > crea una nueva carpeta vacía. El chat aparece al lado.

### Paso 2: explícale qué quieres

Esta parte es la más importante. No pidas "una todo list". Sé específico sobre qué quieres ver al final:

> "Vamos a construir una app de lista de tareas. Quiero:
> - Una página web con una caja de texto para escribir tareas
> - Un botón para agregar
> - Cada tarea tiene un checkbox para marcarla como completada
> - Las tareas se guardan aunque cierre el navegador
> - Que se vea limpio, moderno, con colores suaves
>
> Usa Next.js y Tailwind. No uses base de datos todavía — guarda en localStorage para que sea simple."

Fíjate en el patrón: **qué quieres ver (UI) + qué comportamiento (lógica) + qué restricciones (stack y simplicidad)**. Si le das esto, Claude Code te entrega algo usable.

Claude Code va a:

1. Proponerte una estructura de archivos
2. Pedirte permiso para crearlos
3. Instalar dependencias (Next.js, Tailwind)
4. Escribir los componentes
5. Mostrarte un comando para correrlo

### Paso 3: déjalo trabajar

Esto sorprende la primera vez: **no interrumpas**. Claude Code trabaja en pasos y te pide permiso en los puntos importantes. Apruébale o corrígelo. Si lo cortas a mitad de un archivo, queda la mitad hecha y es peor.

Cuando termine, te dirá:

> "Corre `npm run dev` y abre http://localhost:3000"

Haces eso. Si todo salió bien, **tienes tu app funcionando**.

### Paso 4: itera

Ahora viene lo divertido. Abre la app en el navegador, úsala y dile qué quieres cambiar, en lenguaje natural:

> "El título se ve muy pequeño, hazlo más grande y centrado"
> "Agrega un contador que diga cuántas tareas tengo pendientes"
> "Cuando marque una como completada, quiero que se ponga con una rayita encima del texto"
> "Agrega un botón rojo para borrar todas las completadas"

Cada cambio es una conversación. Claude Code modifica los archivos necesarios, te muestra el diff (el cambio línea por línea), tú apruebas, el navegador se refresca solo.

**Esto es programar sin programar.** No es un truco — es la forma real de construir software en 2026 con IA.

### CLAUDE.md: la memoria de tu proyecto

Después de unas cuantas iteraciones, tu proyecto tiene **contexto**: decisiones de diseño, stack elegido, convenciones de nombres. Claude Code lo olvida cuando cierras la sesión.

La solución: un archivo `CLAUDE.md` en la raíz de tu carpeta. Es un archivo de texto normal donde escribes (o le pides a Claude que escriba) las reglas del proyecto:

```markdown
# Mi Todo App

## Stack
- Next.js 16 con App Router
- Tailwind CSS
- localStorage (no DB por ahora)

## Convenciones
- Componentes en inglés, textos al usuario en español
- No instalar librerías sin preguntarme primero
- Mantener todo en una sola página por ahora
```

Cada vez que inicies `claude` en esa carpeta, leerá ese archivo automáticamente. **Resultado**: conserva el contexto entre sesiones. Para proyectos que duran semanas, esto es la diferencia entre repetir lo mismo cada día o llegar donde lo dejaste.

### El tipo de cosas que no esperabas poder hacer

Con el patrón que aprendiste puedes construir, en horas de chat, cosas como:

- Un portafolio personal con tu info y proyectos
- Un dashboard para rastrear tus hábitos diarios
- Un formulario para que clientes te contacten
- Un blog donde publicas con un solo comando
- Un mini-juego que funciona en el navegador

No son demos inútiles. Son cosas que **puedes desplegar y usar tú o tus clientes**. Lo único que necesitas es saber qué quieres construir.

### La diferencia con frameworks tipo Lovable o v0

Vas a ver apps como [Lovable](https://lovable.dev) o [v0](https://v0.dev) que también construyen con IA. Hay una diferencia clave:

- **Lovable/v0**: viven en la web, te entregan código generado que es difícil de modificar a mano. Buenos para prototipar rápido.
- **Claude Code**: el código es tuyo, está en tu computador, puedes editarlo, versionarlo con git y desplegarlo donde quieras. Mejor para algo que va a crecer.

No compiten — se complementan. Ves un diseño que te gusta en v0, lo bajas, le dices a Claude Code "cópiame este componente y ajústalo a mi proyecto" y sigues desde ahí.$md$,
    1,
    60,
$md$**Construye tu primera app con Claude Code.**

Elige una de estas tres (elige la que más te llame):

1. **Todo list** (la del ejemplo) — clásica pero toca todo lo esencial
2. **Timer de Pomodoro** — cuenta regresiva con botón de play/pause
3. **Contador de hábitos** — lista de hábitos con checkboxes por día

Pasos:

1. Crea una carpeta vacía, abre Claude Code ahí
2. Describe qué quieres ver (UI + comportamiento + stack)
3. Déjalo trabajar sin interrumpir
4. Cuando termine, corre el comando que te diga y abre la app en el navegador
5. Pide 3 iteraciones de cambios (color, texto, feature extra)
6. Escribe un CLAUDE.md con el stack y las reglas del proyecto

**Meta**: terminar con algo que puedas seguir editando mañana sin perder el contexto.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Estás a punto de pedirle a Claude Code que construya una app. ¿Cuál de estas peticiones te va a dar mejor resultado?',
     ARRAY[
       '"Hazme una todo list"',
       '"Hazme una app bonita"',
       '"Quiero una app de todo list con caja de texto, botón agregar, checkbox por tarea, que persista en localStorage, usando Next.js y Tailwind, diseño limpio y colores suaves"',
       '"Inicia un proyecto"'
     ],
     2,
     0,
     'La receta es siempre la misma: qué quieres ver (UI) + qué comportamiento (lógica) + qué restricciones (stack + simplicidad). Los tres juntos le dan a Claude Code suficiente para entregar algo usable sin preguntarte 10 veces. "Hazme una todo list" es tan abierto que va a empezar a preguntar cosas básicas que tú puedes decidir de una.'),

    (v_lesson_id,
     '¿Qué hace el archivo CLAUDE.md en tu proyecto?',
     ARRAY[
       'Es documentación para otros desarrolladores',
       'Le da a Claude Code contexto persistente del proyecto entre sesiones',
       'Es un archivo obligatorio que Claude Code crea solo',
       'Sirve para guardar el historial del chat'
     ],
     1,
     0,
     'CLAUDE.md es un archivo de texto en la raíz que Claude Code lee automáticamente cada vez que inicias sesión. Sirve para anotar el stack del proyecto, convenciones, decisiones pasadas y cualquier cosa que Claude debería saber sin que tú se lo repitas. Para proyectos que duran más de una sesión, es la diferencia entre empezar desde cero cada día o seguir donde lo dejaste.'),

    (v_lesson_id,
     'Claude Code está en medio de generar 4 archivos de tu app. Tú lo cortas para preguntarle algo. ¿Qué pasa?',
     ARRAY[
       'Guarda el progreso y reanuda cuando responda tu pregunta',
       'Puede dejar archivos a medias y la app queda inconsistente — mejor dejarlo terminar y luego preguntar',
       'Cancela todo y empieza desde cero',
       'Te reprende por interrumpirlo'
     ],
     1,
     0,
     'Claude Code trabaja en pasos secuenciales. Si lo interrumpes a mitad de una generación, pueden quedar archivos incompletos o inconsistentes entre sí. La regla es: déjalo terminar el paso actual, revisas el resultado, y ahí corriges o pides lo siguiente. Si de verdad necesitas cortar algo que salió mal, mejor usa plan mode (lo ves en la siguiente lección) para que planifique antes de ejecutar.');


  -- =============================================
  -- LECCIÓN 3: Slash commands y Plan Mode
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Slash commands y Plan Mode',
$md$## Las dos herramientas que separan usuarios de pros

Hasta aquí usaste Claude Code conversando naturalmente. Funciona, pero hay dos mecánicas que cuando las dominas, tu productividad se multiplica: **slash commands** y **plan mode**.

### ¿Qué son los slash commands?

Un slash command (comando que empieza con `/`) es un atajo para una acción común. En lugar de escribir una frase larga, escribes `/` seguido del comando.

Los esenciales:

| Comando | Qué hace |
|---|---|
| `/help` | Te muestra todos los comandos disponibles |
| `/clear` | Borra la conversación actual y empieza fresco |
| `/compact` | Resume la conversación para liberar contexto sin perder lo importante |
| `/cost` | Te dice cuánto has gastado en esta sesión |
| `/model` | Cambia el modelo (Opus, Sonnet, Haiku) sobre la marcha |
| `/status` | Muestra en qué carpeta estás, qué archivos modificaste, etc. |

### ¿Cuándo usar `/clear` vs `/compact`?

Es la pregunta que más se malentiende:

- **`/clear`**: empiezas una tarea nueva, no relacionada. Corta el contexto entero.
- **`/compact`**: sigues en la misma tarea pero la conversación ya es muy larga. Resume lo hecho para que Claude "recuerde" el camino sin cargar todo el historial.

Regla práctica: si cambiaste de proyecto o de tema, `/clear`. Si llevas horas en lo mismo y todo se siente pesado, `/compact`.

### Plan Mode: planifica antes de ejecutar

Hasta ahora Claude Code ha estado ejecutando directamente. Eso está bien para cambios chicos. Pero para tareas grandes — por ejemplo, "agrega autenticación con Supabase a mi app" — ejecutar de una sin pensar es peligroso: puede tocar 10 archivos, instalar librerías que no quieres, meter bugs.

**Plan Mode** hace exactamente lo que suena: Claude Code **solo piensa**, no ejecuta nada. Te entrega un plan detallado paso a paso. Tú lo apruebas, corriges o rechazas. Solo después ejecuta.

Activas plan mode con `Shift+Tab` dos veces (en CLI) o desde la barra lateral (en Antigravity). Lo notarás porque te aparece un indicador en pantalla.

### Ejemplo real de Plan Mode

Imagina que le dices:

> "Quiero agregar login con Google a mi todo list."

**Sin plan mode**: Claude Code empieza a instalar librerías, crear archivos, modificar la página principal. Si algo no te gusta, tienes que deshacer todo.

**Con plan mode**, te responde algo como:

> Plan:
> 1. Instalar `next-auth` como librería de autenticación
> 2. Crear `.env.local` con las variables GOOGLE_CLIENT_ID y GOOGLE_CLIENT_SECRET
> 3. Crear `app/api/auth/[...nextauth]/route.ts` con la config de Google
> 4. Crear `components/SignInButton.tsx`
> 5. Proteger la página principal con middleware
> 6. Mostrarte paso a paso cómo conseguir las credenciales en Google Cloud Console
>
> Voy a instalar una librería nueva (`next-auth`). ¿Apruebas?

Ahora **tú decides**. Quizás prefieres Clerk o Supabase Auth en vez de next-auth. Le dices: "Mejor usa Supabase Auth" y te re-genera el plan. Así evitas 30 minutos de deshacer cambios.

### Modos de permiso: qué puede hacer sin preguntarte

Claude Code tiene tres modos principales:

| Modo | Qué hace |
|---|---|
| **Ask (default)** | Te pregunta antes de cada acción destructiva (escribir archivos, correr comandos) |
| **Accept Edits** | Asume que apruebas ediciones de archivos. Sigue preguntando por comandos shell |
| **Bypass Permissions** | No pregunta nada. Para automatizaciones o cuando ya sabes exactamente qué va a pasar |

**Recomendación**:

- Mientras aprendes: **Ask**. Te da visibilidad de todo.
- Cuando te sientas cómodo y estés en un proyecto que ya conoces: **Accept Edits**.
- **Bypass**: solo para tareas mecánicas muy acotadas. Nunca lo dejes encendido en un proyecto que te importa.

Cambias con `Shift+Tab` (en CLI) o desde el menú de permisos (en Antigravity).

### Custom slash commands: tus propios atajos

Puedes crear tus propios slash commands para cosas que haces repetidamente. Por ejemplo, si siempre le pides "haz un commit con mensaje descriptivo y push", puedes crear `/commit`.

Estos viven en `.claude/commands/` dentro de tu proyecto. Cada comando es un archivo `.md` con las instrucciones. Ejemplo — `.claude/commands/commit.md`:

```markdown
---
description: Hace commit con mensaje descriptivo y push
---

Revisa los cambios con `git status`, escribe un mensaje de commit claro
(1-2 líneas, qué cambió y por qué), ejecuta `git commit` y `git push`.
```

Ahora cuando escribes `/commit` Claude Code ejecuta esa plantilla. Para equipos, esto es oro: todos usan los mismos atajos con el mismo comportamiento.

### Cheat sheet para tu día a día

| Situación | Qué hacer |
|---|---|
| Tarea grande o delicada | `Shift+Tab Shift+Tab` → plan mode |
| Conversación super larga, misma tarea | `/compact` |
| Cambio de proyecto | `/clear` |
| Te preocupa el costo | `/cost` cada 30 min |
| Tarea sensible (tocar auth, DB) | Quedarse en Ask |
| Tarea mecánica repetida | Crear custom command |

Dominar esto es lo que separa a alguien que "usa Claude Code" de alguien que lo **domina**. No tiene misterio — solo hábito.$md$,
    2,
    70,
$md$**Practica plan mode y slash commands en tu app.**

Sobre la app que construiste en la lección anterior:

1. Entra a plan mode (`Shift+Tab` dos veces)
2. Pide una feature mediana: _"Agrega un modo oscuro con toggle en la esquina superior derecha"_
3. **Lee el plan antes de aprobar**. Fíjate qué archivos va a tocar, qué librerías propone
4. Modifica el plan: _"Prefiero no instalar ninguna librería, usa solo Tailwind y un state de React"_
5. Aprueba la versión corregida y déjalo ejecutar
6. Después del cambio usa `/compact` para ver cómo reduce el contexto
7. Crea tu primer custom slash command en `.claude/commands/` — algo simple como `/status-app` que te resume qué tiene la app hoy

**Meta**: sentir la diferencia entre ejecutar ciegamente vs planificar primero.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Llevas 2 horas en la misma tarea con Claude Code, la conversación está larguísima y todo se siente lento. ¿Qué comando usas?',
     ARRAY[
       '/clear — borra todo y empiezas de nuevo',
       '/compact — resume la conversación manteniendo el contexto importante',
       '/help — para ver opciones',
       'Cerrar Claude Code y abrirlo de nuevo'
     ],
     1,
     0,
     '/compact es específicamente para esto: sigues en la misma tarea pero la conversación ya es tan larga que pesa. Resume lo hecho manteniendo el hilo. /clear es distinto — corta todo el contexto, úsalo cuando cambias de proyecto o de tema, no cuando sigues en lo mismo.'),

    (v_lesson_id,
     '¿Cuándo deberías usar plan mode?',
     ARRAY[
       'Siempre, sin excepción',
       'Para tareas grandes o que toquen varios archivos — donde ejecutar sin pensar puede meterte problemas',
       'Solo para tareas muy pequeñas',
       'Plan mode es opcional, no cambia mucho'
     ],
     1,
     0,
     'Plan mode brilla en tareas donde el costo de ejecutar mal es alto: agregar autenticación, refactorizar módulos grandes, tocar la base de datos. Para un cambio de color o un botón nuevo, es excesivo — la ejecución directa es más rápida. La regla práctica: si la tarea puede dañar algo que ya funciona, planifica primero.'),

    (v_lesson_id,
     'Estás editando un proyecto de un cliente real en producción. ¿Qué modo de permisos deberías usar?',
     ARRAY[
       'Bypass Permissions para ir más rápido',
       'Accept Edits para no molestar con tantas preguntas',
       'Ask (default) para tener control sobre cada acción destructiva',
       'Cualquiera, no importa'
     ],
     2,
     0,
     'En proyectos sensibles — producción, código de cliente, bases de datos reales — quédate en Ask. Te va a preguntar antes de cada acción con riesgo y eso te da la oportunidad de parar si algo no te suena. Accept Edits acelera pero en producción un archivo mal modificado puede romper algo. Bypass es solo para automatizaciones muy acotadas donde sabes exactamente qué va a hacer.'),

    (v_lesson_id,
     'Quieres crear un atajo personalizado para "revisar cambios con git status y hacer commit con mensaje descriptivo". ¿Dónde lo guardas?',
     ARRAY[
       'En el archivo CLAUDE.md',
       'Como un archivo .md dentro de .claude/commands/ de tu proyecto',
       'No se puede, solo Anthropic crea slash commands',
       'Como variable de entorno'
     ],
     1,
     0,
     'Los custom slash commands son archivos .md en la carpeta .claude/commands/ de tu proyecto (o en tu home ~/.claude/commands/ si los quieres disponibles en todos los proyectos). Cada archivo tiene frontmatter con descripción y el cuerpo son las instrucciones. Cuando escribes /nombre-del-archivo, Claude ejecuta esas instrucciones. Ideal para workflows repetidos de tu equipo.');


  -- =============================================
  -- LECCIÓN 4: Git, múltiples archivos y refactor
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Git, múltiples archivos y refactor',
$md$## El trabajo real de un programador (hecho con IA)

Ahora viene la parte que te va a sorprender. Las cosas que un programador hace todo el día — **hacer commits, trabajar con múltiples archivos, refactorizar código, debuggear** — con Claude Code son conversaciones normales en español.

### Git con Claude Code

git (el sistema estándar para guardar versiones de tu código) suele ser intimidante: decenas de comandos, ramas, merge conflicts. Con Claude Code casi nunca tecleas un comando git — solo dices lo que quieres:

> "Haz commit de lo que tengo ahora, con un mensaje que resuma lo hecho esta hora"

Claude Code corre `git status`, revisa qué cambió, redacta un mensaje descriptivo, ejecuta `git commit` y te muestra el resultado.

Otros ejemplos:

> "Crea una rama nueva para probar el modo oscuro y muévete ahí"
> "Muéstrame qué cambios hay sin commitear y dame tu opinión de cuáles son riesgosos"
> "Deshaz el último commit pero mantén los cambios en mis archivos"

Todo pasa con conversación natural. Claude Code sabe los comandos git; tú solo dices la intención.

### Múltiples archivos a la vez

Aquí está el superpoder de Claude Code que Claude.ai no tiene. Ejemplos reales:

> "Todos los archivos de mi carpeta components/ usan el color #F59E0B. Cámbialo por una variable de Tailwind `accent-500` y actualiza el tailwind.config para que ese color sea naranja."

Claude Code:

1. Busca todos los archivos donde aparece el color
2. Te lista cuáles son
3. Hace el cambio en cada uno
4. Actualiza la config
5. Te muestra un resumen: "Modifiqué 8 archivos: Button.tsx, Card.tsx, ... ¿Quieres ver los diffs?"

Lo que tomaría 20 minutos a mano, lo resuelve en 30 segundos. Y con **menos errores humanos** porque revisa todos los archivos sistemáticamente.

### Refactor: cuando la app creció y ya no se entiende

Todos los proyectos llegan a un punto donde el código es un desastre: funciones gigantes, archivos de 800 líneas, nombres que ya no tienen sentido. Un refactor (reescribir código manteniendo el comportamiento) a mano es agotador — con IA es conversación.

Ejemplo:

> "Mi archivo `pages/dashboard.tsx` tiene 600 líneas. Separa lógica de presentación: saca los componentes a su propia carpeta, los hooks de lógica a `hooks/`, y deja en dashboard.tsx solo el layout principal. No cambies comportamiento. Muéstrame el plan antes de ejecutar."

Con plan mode activo, Claude Code:

1. Lee el archivo
2. Propone una división: "Voy a crear 4 componentes y 2 hooks. Dashboard pasa de 600 líneas a ~80."
3. Tú apruebas o corriges
4. Ejecuta todo
5. Corre los tests para verificar que nada se rompió

El secreto: **pedirle explícitamente "no cambies comportamiento"**. Un refactor por definición reorganiza sin alterar qué hace la app. Si no se lo dices, a veces optimiza de más.

### Debugging: encuentra bugs conversando

Un bug (error en el comportamiento del código) te frustra. Con Claude Code lo atacas así:

1. **Describe el síntoma** — qué esperabas vs qué pasó
2. Dale el contexto: archivos relevantes, mensaje de error, o una captura
3. Pídele que **piense en voz alta** antes de cambiar nada

Ejemplo:

> "Cuando clickeo el botón de borrar tarea, a veces borra la tarea equivocada (la de arriba en vez de la correcta). Pasa solo después de marcar una como completada y luego querer borrarla. Antes de cambiar código, dime 3 hipótesis de qué puede estar mal."

Claude Code te responde con hipótesis:

> 1. El índice de la tarea no se está actualizando después de filtrar las completadas.
> 2. Hay un race condition en el state de React (React el framework de UI más popular).
> 3. El componente está usando `index` como `key` en vez del id de la tarea.

Tú lees las hipótesis, eliges la que más sentido tiene ("parece la 3, revisa por favor"), él lo confirma y arregla.

Este flujo — **hipotetizar antes de codear** — es lo que los ingenieros senior hacen por años. Con Claude Code lo tienes gratis.

### TodoWrite: cuando la tarea es grande

Para tareas que tienen 5+ pasos, Claude Code puede crear una lista interna de TODOs, ejecutar uno a uno y marcarlos como hechos. Lo hace solo cuando detecta complejidad.

Lo notas porque te aparece una lista al lado de la respuesta:

```
☑ Instalar next-auth
☑ Crear archivo de config
☐ Proteger ruta /dashboard
☐ Agregar botón de sign-out
```

No tienes que pedirlo — aparece cuando es útil. Para tareas chicas no lo usa y así la conversación queda limpia.

### Subagentes: delegar sub-tareas

Otra mecánica para tareas grandes: **subagentes**. Claude Code lanza una "copia" de sí mismo en paralelo con un contexto limpio para hacer una sub-tarea y reportar.

Ejemplo de uso:

> "Antes de refactorizar el dashboard, usa un subagente Explore para buscar todos los archivos que importen componentes de dashboard.tsx, y reporta qué va a romperse."

Ventaja: la exploración exhaustiva no contamina tu conversación principal con cientos de líneas de logs. Tú solo ves el reporte final.

### Lo que NO deberías hacer con Claude Code (todavía)

Para cerrar, honestidad:

- **No toques sistemas en producción con usuarios reales** sin entender lo que estás haciendo. Un bug en tu app personal es gracioso; en una app con 10.000 usuarios es serio.
- **No commitees secretos** (llaves de API, passwords). Claude Code es bueno avisándote, pero revisa antes de hacer push (push = subir al servidor remoto).
- **No le des bypass permissions a cualquier cosa.** Si te pide confirmar para correr `rm -rf algo`, hay una razón.
- **No uses Claude Code cuando no sepas qué quieres construir**. Funciona como amplificador — si no tienes claro el destino, solo vas a iterar en círculos.

### Recap del módulo

Acabas de aprender lo que la mayoría tarda meses en dominar:

- Qué es Claude Code y cuándo usarlo vs Claude.ai
- Construir una app real sin escribir código
- Slash commands y plan mode — las dos palancas de productividad
- Git, refactor y debugging con IA

El próximo módulo es **MCPs y extensiones** — cómo conectar Claude a tus apps (Gmail, Calendar, Slack, Notion) para que no solo escriba código sino que actúe sobre tu vida digital. El salto es gigante.$md$,
    3,
    70,
$md$**Refactor + git workflow con Claude Code.**

Sobre la app que ya construiste:

1. **Commit inicial**: _"Haz commit de todo lo que tengo con un mensaje descriptivo"_. Observa el mensaje que genera
2. **Rama nueva**: _"Crea una rama llamada 'feature-export' y muévete ahí"_
3. **Feature nueva**: agrega algo que toque múltiples archivos — por ejemplo, _"Agrega un botón que exporte las tareas a JSON, y uno que las importe. Tócame los archivos necesarios"_
4. **Refactor**: _"Mi componente principal está creciendo. Sácame la UI de la lista de tareas a su propio componente llamado TaskList. No cambies comportamiento"_
5. **Debug intencional**: rompe algo a propósito (borra una línea importante). Pídele: _"Algo se rompió, antes de arreglarlo dame 3 hipótesis de qué puede estar mal"_
6. **Merge**: _"Vuelve a main, mergea 'feature-export' y borra la rama"_

**Meta**: terminar con un workflow git real sin haber escrito un solo comando git a mano.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Quieres cambiar un color de marca que aparece en 15 archivos de tu proyecto. ¿Cómo lo haces con Claude Code?',
     ARRAY[
       'Abrir cada archivo y editar a mano',
       'Decirle en lenguaje natural: "Reemplaza el color #X por la variable Y en toda la carpeta components/", y él lo hace en todos los archivos',
       'Solo puede modificar un archivo a la vez',
       'Tienes que escribir un script para cambiar los 15'
     ],
     1,
     0,
     'Operar sobre múltiples archivos simultáneamente es uno de los superpoderes de Claude Code. Busca, lista los archivos afectados, te los muestra, ejecuta el cambio sistemáticamente y te entrega un resumen. Es sustancialmente más rápido y con menos errores humanos que hacerlo a mano, y también que con buscar-y-reemplazar de editor — porque Claude entiende contexto (no reemplaza el color si está dentro de un comentario, por ejemplo).'),

    (v_lesson_id,
     'Tu app tiene un bug raro. ¿Cuál es el mejor prompt para atacarlo con Claude Code?',
     ARRAY[
       '"Arréglalo"',
       '"Algo falla"',
       '"Cuando hago X pasa Y, pero yo esperaba Z. Antes de tocar código, dame 3 hipótesis de qué puede estar mal"',
       '"Reescribe toda la app"'
     ],
     2,
     0,
     'El patrón "describe síntoma + pide hipótesis antes de actuar" es oro. Evita que Claude Code salga corriendo a arreglar la primera cosa que ve (que puede no ser el problema real) y te enseña a pensar como un ingeniero: primero diagnóstico, luego tratamiento. Un debugging bien conducido toma la mitad del tiempo que uno donde cambias código a ciegas.'),

    (v_lesson_id,
     'Al hacer refactor grande, ¿qué instrucción es crítica que le des a Claude Code?',
     ARRAY[
       '"Optimiza todo lo que puedas mientras refactorizas"',
       '"No cambies comportamiento — solo reorganiza"',
       '"Cambia todo a tu estilo preferido"',
       'Ninguna instrucción especial, él sabe qué hacer'
     ],
     1,
     0,
     'Un refactor por definición reorganiza sin alterar qué hace la app. Si no se lo dices explícitamente, Claude Code a veces "aprovecha" para optimizar — cambia nombres, elimina cosas que parecen redundantes, reescribe lógica — y eso introduce bugs donde antes no había. La regla de oro: "refactoriza sin cambiar comportamiento", y si hay tests, "corre los tests después para verificar".');

  RAISE NOTICE 'Módulo "Claude Code": 4 lecciones + 13 quizzes insertados correctamente.';

END $$;
