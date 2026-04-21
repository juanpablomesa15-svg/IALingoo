-- =============================================
-- IALingoo — Track "Claude Mastery" / Módulo "Claude Básico"
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
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo Claude Básico no encontrado. Corre primero la migración 20260421_tracks_restructure.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- =============================================
  -- LECCIÓN 1: Bienvenido a Claude
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Bienvenido a Claude',
$md$## Tu nuevo coworker más productivo

Claude es el modelo de IA que vas a usar como base en este curso. Está hecho por **Anthropic** (empresa fundada por exinvestigadores de OpenAI) y se diferencia por tres cosas que vas a sentir desde el primer día:

- **Es muy bueno razonando** con documentos largos
- **Es directo** — no te llena de disclaimers ni respuestas evasivas
- **Escribe código excelente** — por eso es el motor de Claude Code, Cursor y muchos más

### Cómo se ve la interfaz

Entra a [claude.ai](https://claude.ai) con tu cuenta Google y verás:

- **Panel izquierdo**: tus conversaciones anteriores + proyectos
- **Centro**: la caja para escribir
- **Arriba a la derecha**: selector de modelo

Eso es todo. Muy minimalista a propósito — el foco es la conversación.

### Los 3 modelos de la familia Claude 4

Claude no es un solo modelo, son varios. Piensa en ellos como en los tamaños de un café: elige según el trabajo.

| Modelo | Para qué sirve | Velocidad | Costo |
|--------|----------------|-----------|-------|
| **Claude Opus 4** | Tareas complejas: código serio, análisis profundo, razonamiento largo | Más lento | Más caro |
| **Claude Sonnet 4** | El caballo de batalla. 95% de los casos. Equilibrio perfecto | Rápido | Medio |
| **Claude Haiku 4** | Tareas simples y repetitivas, clasificación, resúmenes cortos | Muy rápido | Barato |

**Consejo práctico**: en el chat de claude.ai, **empieza siempre con Sonnet**. Solo cambia a Opus cuando Sonnet se quede corto (problemas realmente complejos) o a Haiku cuando quieras velocidad máxima.

### Plan gratis vs Pro

| Plan | Qué da | Cuándo vale la pena |
|------|--------|---------------------|
| **Gratis** | Sonnet limitado (unos 20–30 mensajes cada 5 horas) | Probar, aprender, uso ocasional |
| **Pro** ($20/mes) | Opus y Sonnet ampliamente + Projects + más features | Si lo usas todos los días |
| **Max** ($100–200/mes) | Todavía más uso + acceso a funciones adelantadas | Uso profesional intenso |

Para este curso, el plan **gratis alcanza** para todo. Si te enganchas y empiezas a usarlo todos los días, Pro se paga solo.

### Conversación básica: 3 reglas de oro

**1. Un tema por conversación**
Cuando cambies de tema, abre un chat nuevo. Los contextos largos y mezclados confunden al modelo.

**2. Contexto al inicio**
En tu primer mensaje deja claros el **rol**, el **objetivo** y el **formato**. Ya lo practicaste en la lección de prompting de "La Base".

**3. Iterar es normal**
No esperes la respuesta perfecta al primer intento. Conversa. "Esto está bien, pero hazlo más corto", "cambia el tono a profesional", "agrega ejemplos".

### Atajos de teclado útiles

En claude.ai:

- **Enter** → envía
- **Shift + Enter** → salto de línea (no envía)
- **Ctrl/Cmd + K** → abre la barra de comandos
- **Ctrl/Cmd + /** → lista de atajos

### Lo que NO vas a encontrar aquí (ni debes buscar)

- ❌ Generación de imágenes (Claude no las genera — para eso es Midjourney o Nano Banana que verás en "Creador Visual")
- ❌ Voz/audio (Claude responde en texto; para voz hay ChatGPT Voice o ElevenLabs)
- ❌ Memoria permanente entre chats (salvo dentro de un proyecto, que verás en la lección 2)

Claude es campeón en **texto + código + análisis**. Eso es su zona.

### Tu rutina ideal con Claude

Un día cualquiera, podrías abrir Claude para:

- Escribir un email difícil
- Resumir un documento largo
- Analizar datos que tienes en un Excel
- Debatir una decisión con alguien que te cuestiona bien
- Aprender un tema nuevo con explicaciones adaptadas a ti

**Piensa en Claude como un coworker al que puedes consultar 24/7.** Entre mejor sepas pedirle, más útil es.
$md$,
    0,
    50,
$md$**Adopta a Claude como tu coworker (10 min)**

1. Entra a [claude.ai](https://claude.ai) y crea cuenta si no la tienes.
2. Fíjate en el selector de modelo arriba a la derecha. Asegúrate de estar en **Sonnet 4**.
3. En un chat nuevo, pega esto (es una plantilla de prompt bien construida):

> Actúa como mi asistente personal. Voy a hacerte consultas variadas durante la próxima semana sobre mi trabajo, proyectos personales y aprendizaje. Responde siempre:
> - Directo, sin introducciones largas
> - En español de Colombia, tono profesional pero cercano
> - En formato markdown (listas, tablas, negritas cuando aporten)
> - Si no tienes la información, dilo en vez de inventar
>
> Confirma que entendiste preguntándome: ¿en qué estás trabajando hoy?

4. Responde su pregunta con algo real que tengas en mente.

**Objetivo**: terminar con una conversación activa que ya te sirvió para algo concreto, y confirmar que la experiencia se siente como hablar con un colega capaz — no con un buscador.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál de los modelos Claude conviene usar por defecto para el 95% de tus tareas diarias?',
     to_jsonb(ARRAY[
       'Claude Opus 4 — para estar seguros de tener la mejor calidad',
       'Claude Sonnet 4 — el equilibrio perfecto entre calidad y velocidad',
       'Claude Haiku 4 — el más barato',
       'El que la IA elija automáticamente'
     ]),
     1,
     0,
     'Sonnet es el caballo de batalla: suficiente para prácticamente todo el trabajo diario. Opus es para problemas muy complejos (y más lento/caro), Haiku para tareas simples a escala.'),

    (v_lesson_id,
     'Estás conversando con Claude sobre tu proyecto de negocio y de repente cambias a preguntarle sobre una receta de cocina. ¿Qué es lo más recomendable?',
     to_jsonb(ARRAY[
       'Seguir en el mismo chat, Claude maneja bien los cambios de tema',
       'Abrir un chat nuevo para la receta y dejar el del negocio aparte',
       'Primero cerrar explícitamente el tema del negocio',
       'Cambiar a Opus para que entienda mejor'
     ]),
     1,
     0,
     'Mezclar temas muy distintos ensucia el contexto y aumenta errores. Regla simple: un tema por chat. Tus conversaciones anteriores quedan guardadas por si necesitas volver.'),

    (v_lesson_id,
     'Claude NO hace nativamente cuál de estas cosas:',
     to_jsonb(ARRAY[
       'Analizar un documento PDF largo que le pegas',
       'Escribir y explicar código',
       'Generar imágenes a partir de texto',
       'Razonar sobre un problema paso a paso'
     ]),
     2,
     0,
     'Claude no genera imágenes (sí las lee e interpreta, pero no las crea). Para imágenes usarás herramientas como Midjourney o Nano Banana en el track Creador Visual.');

  -- =============================================
  -- LECCIÓN 2: Proyectos — memoria persistente de Claude
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Proyectos: memoria persistente',
$md$## El problema de empezar cada chat en blanco

Cada chat normal con Claude arranca **sin recordar nada** de conversaciones anteriores. Le tienes que re-explicar quién eres, qué estás haciendo, cómo te gusta el formato… cada vez.

Los **Proyectos** (Projects) resuelven eso. Es como crear una carpeta donde:

- Todos los chats comparten el mismo contexto
- Puedes cargar archivos que Claude siempre va a tener a mano
- Defines un "system prompt" (las instrucciones base que Claude siempre respeta dentro de ese proyecto)

### Anatomía de un proyecto

Cuando creas un proyecto tienes tres zonas:

**1. Nombre y descripción**
Solo para ti, para organizarte.

**2. Instrucciones personalizadas** (system prompt — las instrucciones base que le dicen a Claude cómo comportarse siempre dentro de ese proyecto)
Acá escribes: "Actúa como X, responde así, evita esto, siempre menciona Y". Claude respeta estas instrucciones en **todos** los chats del proyecto.

**3. Knowledge / conocimiento**
Una carpeta donde subes archivos (PDF, Word, markdown, código) que Claude consultará como referencia permanente.

### Cuándo crear un proyecto

No todo merece proyecto. Úsalos cuando:

- ✅ Vas a tener **varias conversaciones sobre el mismo tema** (tu negocio, tu tesis, un cliente recurrente)
- ✅ Quieres que Claude **siempre conozca ciertos archivos** (tu catálogo, tu plan de negocio, tu documentación)
- ✅ Necesitas un **tono o formato consistente** (estilo de tu marca, plantilla de emails)

### Ejemplos reales de proyectos útiles

**Proyecto "Mi negocio"**
- Knowledge: catálogo de productos, precios, políticas, preguntas frecuentes
- Instrucciones: "Actúa como mi socio de negocio. Cuando te pregunte por estrategia, usa el contexto del catálogo y mantén tono comercial colombiano"
- Uso: planear campañas, escribir descripciones de producto, responder dudas de clientes

**Proyecto "Estudios IA"**
- Knowledge: apuntes de las lecciones de IALingoo que vas tomando
- Instrucciones: "Eres mi tutor personal de IA. Responde como si yo fuera principiante, con analogías y ejemplos del día a día"
- Uso: aclarar dudas de cualquier lección, practicar prompts, pedirte ejercicios

**Proyecto "Inglés profesional"**
- Knowledge: emails que has escrito, libro de estilo de tu empresa
- Instrucciones: "Cuando te pegue un texto, ofréceme una versión en inglés profesional de negocios, y explícame 2 cambios clave"
- Uso: escribir emails, pulir presentaciones, traducir documentos

### Cómo crear tu primer proyecto (paso a paso)

1. En claude.ai, en el panel izquierdo, haz click en **"Projects"**
2. **"Create project"** → dale nombre y descripción
3. En **"Custom instructions"**, escribe las instrucciones permanentes (ver ejemplo abajo)
4. En **"Project knowledge"**, sube los archivos relevantes
5. Listo — ya puedes crear chats dentro de ese proyecto

### Plantilla de instrucciones para un proyecto

```
Contexto: [quién soy, qué hago, qué busco]

Actúa como: [rol que quiero que tome]

Formato de respuesta:
- [estilo: directo / casual / formal / etc.]
- [idioma: español de Colombia, inglés, etc.]
- [uso de markdown: sí / no]

Siempre:
- [cosas que debe respetar]

Nunca:
- [cosas a evitar]

Si no sabes algo, dilo. No inventes.
```

### Limitaciones a tener en cuenta

- El tamaño de los archivos de knowledge tiene límite (en plan Pro, suele ser generoso pero no infinito)
- Un chat dentro del proyecto aún puede llenar su ventana de contexto si se extiende mucho
- El knowledge **no se actualiza solo** — si cambias un PDF, hay que re-subirlo

### Un patrón que funciona

Al menos **un proyecto por cada gran tema de tu vida**:
- Trabajo
- Aprendizaje (IA, idiomas, lo que sea)
- Proyectos personales
- Emprendimiento si aplica

Con 3-4 proyectos bien definidos, Claude deja de sentirse como un chatbot y empieza a sentirse como un equipo que te conoce.
$md$,
    1,
    60,
$md$**Crea tu primer Proyecto (15 min)**

1. Piensa en un tema sobre el que vas a tener muchas conversaciones con Claude (trabajo, un proyecto personal, aprender algo).

2. En claude.ai → **Projects** → **Create project**. Ponle nombre.

3. En **Custom instructions**, usa esta plantilla y rellénala con tu caso:

> Contexto: soy [rol / situación]. Estoy trabajando en [proyecto / objetivo].
> Actúa como: [rol que quieres que Claude tome].
> Formato: español de Colombia, directo, con listas o tablas cuando aporte.
> Siempre: sé específico, dame ejemplos concretos, pregunta si te falta contexto.
> Nunca: inventes datos específicos. Si no sabes, dilo.

4. **Sube 1 archivo al knowledge** (un PDF, un documento, unos apuntes). Si no tienes ninguno, crea una nota en markdown con un resumen de tu situación y súbela.

5. Crea un chat dentro del proyecto y haz una pregunta que aproveche el contexto cargado.

**Objetivo**: sentir la diferencia entre un chat aislado y un chat "que te conoce". Es el upgrade más grande que hace cualquier usuario serio de Claude.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál es el propósito principal de los Proyectos en Claude?',
     to_jsonb(ARRAY[
       'Tener un chat más rápido',
       'Acceder a modelos especiales que no están en chats normales',
       'Mantener contexto, instrucciones y archivos compartidos entre varias conversaciones sobre el mismo tema',
       'Compartir conversaciones públicamente con otros usuarios'
     ]),
     2,
     0,
     'Los Projects existen para resolver el problema de "empezar en blanco cada vez". Agrupan chats relacionados bajo un system prompt común y un knowledge cargado una sola vez.'),

    (v_lesson_id,
     '¿Qué es el "system prompt" o "custom instructions" de un proyecto?',
     to_jsonb(ARRAY[
       'Las preguntas que ya le hiciste a Claude',
       'Las instrucciones base que Claude respeta en TODOS los chats de ese proyecto',
       'Un archivo con ejemplos de respuestas correctas',
       'El nombre del proyecto'
     ]),
     1,
     0,
     'El system prompt es el conjunto de instrucciones permanentes: rol, tono, reglas, formato. Claude las lee al inicio de cada chat dentro del proyecto y actúa en consecuencia.'),

    (v_lesson_id,
     'Cuál de estos NO es un buen uso de Proyectos:',
     to_jsonb(ARRAY[
       'Un proyecto "Mi negocio" con catálogo y políticas como knowledge',
       'Un proyecto "Tutor de IA" para estudiar todo IALingoo',
       'Un proyecto para una única pregunta suelta sobre una receta',
       'Un proyecto "Cliente X" para un freelancer con varios clientes'
     ]),
     2,
     0,
     'Un proyecto tiene overhead de setup (instrucciones, knowledge). Para una pregunta única, usar un chat normal es más rápido. Los proyectos brillan cuando vuelves al mismo tema muchas veces.');

  -- =============================================
  -- LECCIÓN 3: Artefactos — construye dentro del chat
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Artefactos: construye dentro del chat',
$md$## Claude no solo te dice — te entrega

Un **artefacto** (artifact) es algo que Claude genera **al lado** de la conversación, en un panel aparte. En vez de mandarte un bloque de código perdido en el chat, te abre una ventana tipo "documento" donde ves el resultado, puedes editarlo, descargarlo o —en algunos casos— usarlo en vivo.

Es la diferencia entre que tu compañero te describa un diagrama… o que te lo dibuje en una servilleta.

### Tipos de artefactos que Claude puede crear

**1. Documentos y textos largos**
Cartas, reportes, ensayos, planes, contratos. Cualquier cosa que merezca "salir del chat" para poder editarse cómodamente.

**2. Código**
En cualquier lenguaje: Python, JavaScript, HTML, SQL, etc. Queda con sintaxis coloreada y botón de copiar.

**3. Páginas web interactivas (HTML + CSS + JavaScript)**
Aquí Claude brilla: puedes pedirle un prototipo de página y Claude lo genera **funcionando en vivo**. Un calendario clickeable, una calculadora, un quiz, un dashboard simulado.

**4. Diagramas y visuales (SVG y Mermaid)**
SVG (un formato de imagen basado en texto — ideal para íconos, diagramas y gráficos simples) o Mermaid (una forma de dibujar diagramas de flujo, arquitecturas o líneas de tiempo escribiendo texto).

**5. React components**
Para quien empieza a tocar programación web, Claude puede generar componentes React (la forma moderna de construir interfaces web interactivas) y renderizarlos ahí mismo.

### Cuándo Claude crea un artefacto (y cuándo no)

Claude decide automáticamente si tu pedido merece un artefacto. La lógica general:

- ✅ **Crea artefacto** cuando el contenido es largo, independiente y probablemente vas a reutilizarlo (un documento, un script, una web)
- ❌ **Responde inline** cuando es algo corto o conversacional ("dame 3 ideas", "¿qué piensas de X?")

Si Claude no lo hizo y tú lo querías, solo pide: "haz esto como artefacto".

### Ejemplos concretos

**Pedido**: "Dame una landing page simple para una cafetería en Medellín, con menú, horarios y mapa de ubicación."

**Resultado**: artefacto HTML con una página que puedes ver en vivo. Colores, tipografía, secciones. La ajustas iterando.

---

**Pedido**: "Hazme un quiz interactivo de 5 preguntas sobre tipos de café, que marque la respuesta correcta y muestre el puntaje al final."

**Resultado**: un mini-juego funcional. Sí, así como lees.

---

**Pedido**: "Diagrama de flujo del proceso de un pedido de e-commerce: desde 'cliente entra' hasta 'producto entregado'."

**Resultado**: diagrama Mermaid listo para copiar a Notion o Confluence.

---

**Pedido**: "Un Excel con presupuesto familiar mensual de 12 categorías, con fórmulas de totales y porcentajes."

**Resultado**: tabla estructurada que copias a Google Sheets.

### Cómo iterar sobre un artefacto

Cuando ya hay un artefacto abierto, le puedes pedir cambios sin rehacerlo todo:

- "Cambia los colores a algo más cálido"
- "Agrega una sección de testimonios"
- "Hazlo responsive (que se adapte a móviles)"
- "Quita la tercera columna"

Claude edita **ese mismo artefacto** y mantiene el historial — puedes volver a una versión anterior si te arrepientes.

### Descargar o reutilizar

Todo artefacto tiene opciones para:

- **Copiar** el contenido al portapapeles
- **Descargar** como archivo (`.html`, `.md`, `.py`, etc.)
- **Compartir** con un link público (si tienes Claude Pro)
- **Remix**: empezar otro chat con ese artefacto como base

### El cambio mental que trae artefactos

Antes de artefactos, Claude era "alguien a quien le preguntabas".
Con artefactos, Claude es **alguien que construye contigo**.

No pares en respuestas. **Pide entregables.**

> ❌ "Explícame cómo se haría una página de precios"
> ✅ "Hazme una página de precios con 3 planes, comparativa con check/X, y botón de contacto"

La segunda formulación te ahorra 20 minutos de trabajo.
$md$,
    2,
    70,
$md$**Construye algo útil con un artefacto (15 min)**

Elige UNA de estas tres opciones y pídele a Claude que te la entregue como artefacto:

**Opción A — Documento**: un plan semanal de ejercicio en casa, adaptado a 30 minutos al día, sin equipamiento. Pide: tabla de 7 días con calentamiento, ejercicio principal y enfriamiento.

**Opción B — Web interactiva**: una calculadora de propina para restaurantes, con campos para monto de cuenta, porcentaje de propina (10/15/20%) y cuántas personas pagan. Que muestre el total por persona.

**Opción C — Diagrama**: un diagrama Mermaid del flujo de atención al cliente ideal, desde "cliente llega con problema" hasta "cliente resuelto y satisfecho".

**Después de recibir el primer artefacto, itéralo 2 veces**:
1. Pide un cambio estético (colores, orden, más detalle).
2. Pide un cambio funcional (una sección nueva, una regla extra).

**Objetivo**: sentir el poder de iterar sobre algo concreto, no solo conversar. Así es como la IA deja de ser un buscador elegante y se vuelve tu co-constructor.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué es un "artefacto" en Claude?',
     to_jsonb(ARRAY[
       'Un modelo más antiguo de Claude',
       'Un error cuando la IA no entiende la pregunta',
       'Un entregable (documento, código, web, diagrama) que aparece en un panel aparte del chat',
       'Un tipo de archivo que solo se puede abrir en Windows'
     ]),
     2,
     0,
     'Un artefacto es un entregable "al lado de la conversación": un documento editable, un bloque de código, una página web funcional, un diagrama. Te permite trabajar con resultados concretos, no solo con respuestas.'),

    (v_lesson_id,
     '¿Cuál de estos pedidos es MÁS probable que Claude entregue como artefacto?',
     to_jsonb(ARRAY[
       'Dame 3 ideas de nombre para mi negocio',
       '¿Qué piensas sobre la tendencia del home office?',
       'Hazme una landing page en HTML para mi cafetería, con menú y horarios',
       'Explícame con 2 frases qué es el marketing'
     ]),
     2,
     0,
     'Claude tiende a crear artefacto cuando el contenido es largo, independiente y reutilizable (una web, un documento, un diagrama). Respuestas cortas o conversacionales se quedan inline.'),

    (v_lesson_id,
     'Tienes un artefacto de una página web, pero quieres cambiar los colores y agregar una sección nueva. ¿Qué es lo mejor?',
     to_jsonb(ARRAY[
       'Pedirle a Claude que empiece de cero con una nueva conversación',
       'Copiar el código a otro lado y editarlo manualmente',
       'Pedirle directamente los cambios: Claude edita el mismo artefacto manteniendo versiones anteriores',
       'No se puede, los artefactos son de solo lectura'
     ]),
     2,
     0,
     'Los artefactos son iterativos por diseño. Claude edita el mismo artefacto y guarda el historial — puedes volver a una versión anterior si te arrepientes. Es la misma filosofía de Google Docs: trabajas sobre el mismo documento, no sobre copias.');

  -- =============================================
  -- LECCIÓN 4: Features avanzadas que casi nadie usa bien
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Features avanzadas: archivos, imágenes y búsqueda',
$md$## Subir del 20% al 80% de Claude

La mayoría usa Claude solo como chat de texto. Si te quedas ahí, te estás perdiendo la mitad de la herramienta. Estas tres features cambian el juego.

### 1. Adjuntar archivos

Al lado de la caja de texto hay un botón de **clip** 📎. Ahí subes:

- **PDF** (hasta unas 500 páginas según el plan)
- **Word, Excel, PowerPoint**
- **Imágenes** (PNG, JPG, WebP)
- **Código** (cualquier archivo de texto)
- **Markdown, CSV, JSON**

Claude **lee y entiende el contenido completo**. No necesitas copiar y pegar ni resumir antes.

**Casos donde brilla:**
- "Resume este PDF de 80 páginas en 10 bullets"
- "Este Excel tiene las ventas del trimestre. Identifica los 3 productos que más bajaron y proponme hipótesis"
- "Este contrato (PDF). Explícame en español simple las cláusulas que más me deberían preocupar como contratista"
- "Acá tienes mi código (5 archivos). Encuentra el bug que hace que el botón no funcione"

**Truco**: sube varios archivos a la vez para que Claude los cruce. Ej: tu CV + la descripción de un puesto → te dice cómo alinear tu CV para ese puesto específico.

### 2. Imágenes: subir y analizar

Claude **ve imágenes**. Subes una foto o captura de pantalla y la analiza.

**Qué puede hacer con una imagen:**
- Extraer texto (OCR — reconocimiento óptico de caracteres, que convierte texto de una imagen en texto editable)
- Describir qué hay en ella
- Leer gráficas y sacar conclusiones
- Analizar diseño (UI/UX de una app, layout de una web)
- Revisar matemáticas o diagramas escritos a mano
- Identificar objetos, plantas, comidas, ropa

**Ejemplos útiles:**
- Foto de una factura → "extrae los items y totales en una tabla"
- Captura de un dashboard → "explica qué indica esta métrica y si es buena o mala"
- Foto de una pizarra con apuntes → "transcribe esto y reorganízalo"
- Foto de un plato de comida → "estima las calorías y dame la receta"

### 3. Búsqueda web en vivo

En el plan Pro (y en algunos casos gratis), Claude puede **buscar en internet** si la pregunta lo amerita. No todo el tiempo — solo cuando detecta que necesita información actualizada.

**Cuándo usa búsqueda:**
- Preguntas sobre eventos recientes
- Precios actuales, estado del mercado
- Documentación de herramientas que cambian rápido

**Cómo forzarlo** si quieres asegurarte: pide explícitamente "busca en web" o "con información actualizada a hoy".

**Importante**: sigue siendo buena idea verificar. La búsqueda reduce alucinaciones, no las elimina.

### 4. Ejecutar código (Analysis tool)

Claude puede **ejecutar código Python** dentro del chat para calcular, analizar datos o procesar archivos. Es una herramienta (tool) que el modelo llama cuando detecta que un cálculo preciso ayuda.

**Casos típicos:**
- "Este CSV tiene 5000 filas. Cuenta cuántas ventas hay por región y dame la región top."
- "Analiza la tendencia de este Excel y proyecta los próximos 3 meses"
- "Convierte estos valores de USD a COP usando una tasa de 4200"

A diferencia de una simple respuesta, aquí Claude **calcula de verdad**, no adivina. Precisión real en datos.

### 5. Voice mode (solo app móvil)

En la app móvil de Claude (iOS y Android, gratis) puedes **hablarle por voz** y te responde. Es útil manejando, cocinando, o en caminatas de "brainstorming".

### Combina features — ahí está el superpoder

El valor real no está en cada feature aislada. Está en combinarlas:

> **Un flujo real**:
> 1. Subes el PDF de un estudio de mercado (feature de archivos)
> 2. Subes una captura de tu dashboard actual de ventas (feature de imágenes)
> 3. Le pides: "Compara lo que dice el estudio con mi situación actual y dame 3 movidas para los próximos 90 días, en artefacto documento"
> 4. Claude analiza el PDF, lee tu dashboard, cruza la info y te entrega un plan accionable en un documento editable.

Esto no es ciencia ficción. Es lo que hace un coworker junior bien entrenado — y lo tienes disponible 24/7 por USD 20 al mes.

### Lo que NO hace (importante)

- ❌ No ejecuta código de tu máquina (eso lo hace Claude Code, la siguiente lección)
- ❌ No envía emails ni toma acciones en tus apps (eso son los agentes + MCP, track más adelante)
- ❌ No genera imágenes ni video (usa herramientas del track Creador Visual)
- ❌ No recuerda entre chats normales (usa Projects para persistir contexto)

### Tu rutina avanzada

Cuando interiorices estas features, vas a dejar de abrir Google para:

- Leer documentos largos (se los pegas a Claude y le preguntas)
- Analizar datos de Excels (se los mandas directamente)
- Entender capturas de pantalla técnicas (se las subes y pregunta)
- Investigar temas complejos (con búsqueda web, sintetiza en minutos)

Claude deja de ser "un chat elegante" y se vuelve **el sistema operativo donde procesas información**.
$md$,
    3,
    70,
$md$**Prueba 3 features que nunca habías usado (15 min)**

Haz estas 3 mini-tareas, una por feature:

**1. Archivos**
Sube un PDF que tengas a la mano (factura, contrato, apuntes, lo que sea) y pídele:
> "Resume los 5 puntos más importantes de este documento en bullets y dime qué debería preguntarme al leerlo."

**2. Imagen**
Toma captura de pantalla de tu app favorita (WhatsApp, Spotify, tu banco) y súbela:
> "Analiza el diseño de esta interfaz. ¿Qué 3 cosas están bien hechas y qué 2 cosas mejorarías si fueras un diseñador UX?"

**3. Búsqueda o análisis de código**
Copia 20 filas de datos cualquiera (un Excel, una tabla web) y pégalas. Pide:
> "Analiza estos datos y dame la observación más interesante que encuentres, con un gráfico si aplica."

**Objetivo**: terminar la lección con la sensación de "no sabía que podía hacer eso". Son las features que la mayoría descubre después de meses — tú las tienes desde el día uno.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál de estos archivos puedes subirle directamente a Claude para que lo analice?',
     to_jsonb(ARRAY[
       'Un PDF de 80 páginas',
       'Un Excel con 5000 filas',
       'Una imagen con texto (captura, foto, diagrama)',
       'Todos los anteriores'
     ]),
     3,
     0,
     'Claude acepta PDF, Word, Excel, imágenes, archivos de código, CSV, JSON, markdown. Puedes subir varios a la vez y pedirle que los cruce. Es la feature que más tiempo ahorra en el día a día.'),

    (v_lesson_id,
     'Tienes un CSV con 5000 filas de ventas y quieres contar las ventas por región con precisión. ¿Qué feature es la clave?',
     to_jsonb(ARRAY[
       'Búsqueda web',
       'Ejecución de código (analysis tool) — Claude corre Python para calcular de verdad',
       'Voice mode',
       'Proyectos'
     ]),
     1,
     0,
     'Para cálculos precisos sobre datos, el analysis tool corre Python real dentro del chat. Sin esa feature, Claude podría aproximar o equivocarse. Con ella, hace los mismos cálculos que harías en Excel o con un script.'),

    (v_lesson_id,
     'Cuál de estas cosas Claude.ai NO hace por sí solo:',
     to_jsonb(ARRAY[
       'Leer e interpretar una imagen que le subas',
       'Analizar un PDF largo y resumirlo',
       'Enviar un email a tu cliente por ti',
       'Ejecutar código Python para calcular algo'
     ]),
     2,
     0,
     'Claude.ai habla — no actúa en tus apps. Para que envíe emails o tome acciones en otros sistemas se necesitan agentes + MCP (que verás en el track de AI Agents). El chat normal está acotado a lectura y generación.');

  RAISE NOTICE 'Módulo "Claude Básico": 4 lecciones + 12 quizzes insertados correctamente.';
END $$;
