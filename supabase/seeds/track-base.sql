-- =============================================
-- IALingoo — Track "La Base" — Contenido
-- Requiere: migration 20260421_tracks_restructure
-- Idempotente: re-ejecutable (limpia lecciones y quizzes del módulo)
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'base';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo base no encontrado. Corre primero la migración 20260421_tracks_restructure.';
  END IF;

  -- Limpieza idempotente
  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- =============================================
  -- LECCIÓN 1: ¿Qué es realmente la IA?
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    '¿Qué es realmente la IA?',
$md$## Una conversación con el texto del mundo

Imagina que alguien leyó el equivalente a **decenas de millones de libros, artículos, conversaciones y código**. No los memorizó — sino que detectó patrones: cómo empiezan las recetas, cómo se estructura un email formal, cómo argumentan los abogados, cómo piensan los programadores cuando debuggean.

Eso es un modelo de IA moderno. **No es un cerebro, es un sistema de patrones muy buenos**.

### Cómo funciona, sin magia

Cuando escribes una pregunta a Claude o ChatGPT, el modelo:

1. **Divide tu texto en pedazos pequeños** (tokens — más o menos tres cuartos de palabra cada uno)
2. **Predice el siguiente token** más probable dado todo lo anterior
3. **Repite miles de veces**, tejiendo palabras que suenan coherentes porque estadísticamente encajan

Por eso es tan buena escribiendo: cada frase bien redactada que ha visto entrena su intuición de "qué viene después".

### Lo que realmente puede hacer (y muy bien)

- ✅ Escribir, resumir, traducir, reformular textos
- ✅ Explicar conceptos complejos con analogías
- ✅ Analizar código, encontrar errores, proponer soluciones
- ✅ Leer imágenes, extraer texto, describir contenido
- ✅ Planear, estructurar ideas, hacer checklists
- ✅ Conversar con contexto largo — recuerda lo que le dijiste hace rato en el chat

### Lo que NO puede hacer

- ❌ **No tiene opiniones propias** — adopta el tono que le pidas
- ❌ **No sabe qué pasó esta semana** (salvo que tenga búsqueda web activa)
- ❌ **No recuerda conversaciones anteriores** (cada chat empieza en blanco, a menos que uses "memory" o "projects")
- ❌ **No ejecuta acciones en el mundo real** por sí sola — solo habla. Para que actúe hay que conectarla a herramientas (eso son los AI Agents, que verás más adelante)

### ⚠️ Alucinaciones: el gran riesgo

A veces la IA **inventa con total seguridad**. Fechas falsas, libros que no existen, estudios que nunca se publicaron. No miente a propósito — está "rellenando el patrón" con lo que suena plausible.

**Regla de oro**: si te da un dato específico (fecha, nombre, cifra, cita), verifícalo antes de usarlo en algo importante.

### Los 3 modelos que vas a usar

| Modelo | Hecho por | Brilla en |
|--------|-----------|-----------|
| **Claude** | Anthropic | Análisis, código, textos largos, razonamiento |
| **ChatGPT** | OpenAI | Versatilidad, ecosistema, imágenes, voz |
| **Gemini** | Google | Búsqueda, integración con Gmail/Docs/YouTube |

Todos son excelentes. En este curso usaremos principalmente **Claude** (porque es con el que trabajarás en Claude Code), pero los conceptos aplican a los tres.

### La mentalidad correcta

Trata a la IA como un **junior muy leído**:

- Si le das contexto claro → brilla
- Si asumes que sabe lo que tú sabes → se equivoca
- Si verificas lo importante → es un multiplicador de productividad
- Si confías ciegamente → te mete en problemas

Lista. Empecemos.
$md$,
    0,
    50,
$md$**Tu primer experimento real con IA**

Abre [claude.ai](https://claude.ai) (o [chatgpt.com](https://chatgpt.com)) y haz estas 3 cosas:

1. **Pregunta cotidiana**: "Tengo pollo, arroz y verduras en la nevera. Dame 3 recetas distintas en 10 minutos."
2. **Pregunta conceptual**: "Explícame cómo funciona una hipoteca como si tuviera 15 años."
3. **Pregunta con trampa**: "¿Qué ganó el último Oscar a mejor película?" — observa si te da una respuesta segura aunque no tenga datos actualizados.

Después, pídele: "¿De las 3 respuestas anteriores, en cuál podrías haber alucinado datos? Sé honesta."

**Objetivo**: notar la diferencia entre cuando la IA está en su zona de confort (texto, análisis) y cuando está inventando (datos específicos, fechas recientes).$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué hace realmente un modelo de lenguaje cuando genera una respuesta?',
     to_jsonb(ARRAY[
       'Busca la respuesta en internet en tiempo real',
       'Predice el siguiente pedazo de texto más probable según patrones que aprendió',
       'Consulta una base de datos de respuestas correctas',
       'Razona como un humano y luego escribe la respuesta'
     ]),
     1,
     0,
     'Los modelos generan texto token por token, prediciendo el siguiente más probable según los patrones aprendidos durante el entrenamiento. No "razonan" ni "saben" — simulan comprensión a partir de patrones estadísticos muy buenos.'),

    (v_lesson_id,
     '¿Cuál de estas tareas NO puede hacer bien una IA sin herramientas externas?',
     to_jsonb(ARRAY[
       'Resumir un texto largo',
       'Escribir un email formal en inglés',
       'Decirte qué pasó ayer en las noticias',
       'Explicar un concepto con analogías'
     ]),
     2,
     0,
     'Los modelos tienen un "cutoff" de conocimiento (la fecha donde terminó su entrenamiento). Sin conexión a búsqueda web o a tus datos, no saben qué pasó recientemente. Resumir, escribir y explicar son sus fortalezas naturales.'),

    (v_lesson_id,
     '¿Qué es una "alucinación" en IA?',
     to_jsonb(ARRAY[
       'Un error de software del modelo',
       'Una respuesta que la IA da con total seguridad pero que es falsa o inventada',
       'Cuando la IA no responde y se queda en blanco',
       'Un modo creativo especial para escribir ficción'
     ]),
     1,
     0,
     'Una alucinación es cuando la IA genera información plausible pero incorrecta — fechas falsas, libros que no existen, citas inventadas. Suena creíble porque encaja en el patrón, pero no es real. Por eso siempre verifica datos específicos.');

  -- =============================================
  -- LECCIÓN 2: Cómo piensa la IA (y en qué se equivoca)
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Cómo piensa la IA (y en qué se equivoca)',
$md$## Entendiendo las piezas que importan

Ya sabes que la IA predice texto. Ahora vamos a los **3 conceptos que te van a ahorrar horas de frustración**.

### 1. Tokens y ventana de contexto

Un **token** es un pedazo de texto — unas tres cuartas partes de palabra. "Hola" es un token. "Aprendizaje" son dos tokens.

La **ventana de contexto** es cuánto puede "ver" el modelo a la vez. Claude 4 maneja hasta **200,000 tokens** (unas 500 páginas). ChatGPT-4.1 llega a **1 millón**. Suficiente para meterle un libro entero.

**Qué significa para ti**: puedes pegarle documentos largos, código de varios archivos, o toda una conversación — y el modelo lo procesa como un bloque único.

### 2. Cutoff de conocimiento

El modelo terminó de entrenar en cierta fecha. Después de eso, **no sabe nada nuevo** salvo que le des acceso a búsqueda web o le pegues info actualizada tú.

Si le preguntas algo muy reciente sin contexto, tiene dos opciones:
- Decirte que no sabe (los modelos buenos lo hacen)
- **Alucinar** con confianza (los modelos distraídos lo hacen)

### 3. Determinismo vs creatividad (temperatura)

Los modelos tienen un parámetro llamado **temperatura** que controla qué tan predecibles o creativas son las respuestas:

- **Temperatura baja** (0-0.3): responde casi igual cada vez. Útil para código, extracción de datos, clasificación.
- **Temperatura alta** (0.7-1): responde más variado y creativo. Útil para escritura, brainstorming, contenido.

En chats normales no controlas esto directamente, pero **tu prompt puede empujar en cualquier dirección**: "sé preciso y no te desvíes" vs "dame ideas locas".

### Cuándo alucina más

Las alucinaciones aparecen con más fuerza cuando pides:

- **Citas exactas** de libros, papers o autores
- **Fechas específicas** de eventos poco conocidos
- **URLs o enlaces** (los inventa con frecuencia)
- **Datos numéricos precisos** sin darle la fuente
- **Funciones o librerías** de código que no existen
- **Información sobre personas reales** poco famosas

### Cómo reducir alucinaciones (3 trucos que funcionan)

**1. Da el contexto tú mismo**
Pégale el documento, el artículo, los datos. El modelo dejará de "rellenar huecos" y trabajará con lo que tiene.

**2. Pídele explícitamente que admita ignorancia**
> "Si no tienes la información, di 'no lo sé' en vez de inventar."

Los modelos modernos (Claude 4, GPT-4.1) responden muy bien a esta instrucción.

**3. Conéctalo a herramientas**
Búsqueda web, bases de datos, tus archivos. Ahí deja de adivinar y empieza a consultar. Eso es lo que hacen los **AI Agents** (los verás en el track de agentes).

### Modo "pensar paso a paso"

Claude 4 y GPT tienen un modo de **razonamiento extendido** donde el modelo piensa antes de responder. Lo activas pidiendo:

> "Piensa paso a paso antes de responder"

O en la UI, activas el botón "Extended thinking" / "o1-style reasoning". Esto mejora dramáticamente la precisión en problemas complejos (matemáticas, lógica, debugging).

### Resumen de bolsillo

| Problema | Solución |
|----------|----------|
| Responde algo viejo | Pégale contexto actualizado |
| Inventa datos | Dile "si no sabes, di no sé" |
| No profundiza | Pídele pensar paso a paso |
| Repite errores | Empieza un chat nuevo (el contexto se ensucia) |
| Es muy genérico | Dale rol, audiencia y formato específicos |

Con esto ya piensas como alguien que **entiende** la IA, no solo la usa.
$md$,
    1,
    60,
$md$**Cacería de alucinaciones (15 min)**

Tu misión: provocar una alucinación a propósito y reconocerla.

1. Pregúntale a Claude (sin activar búsqueda web):
   > "¿Cuáles fueron las 3 noticias más importantes de tecnología del mes pasado?"

2. Si te da una respuesta confiada, pídele:
   > "¿Estás seguro? ¿Tienes acceso a información de las últimas semanas?"

3. Ahora prueba lo contrario — dale contexto explícito. Pégale un artículo reciente (de cualquier medio), y pídele:
   > "Resume este artículo en 3 bullets."

**Observa la diferencia**: cuando no tiene info, inventa. Cuando le das info, es impecable.

**Bonus**: pídele una cita textual de un libro que sabes bien. Casi seguro la inventa. Confróntalo y fíjate cómo reacciona.$md$,
    12
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué es la "ventana de contexto" de un modelo?',
     to_jsonb(ARRAY[
       'La cantidad de usuarios que pueden usar el modelo al mismo tiempo',
       'La cantidad de texto (tokens) que el modelo puede procesar a la vez en una conversación',
       'El tiempo que tarda en responder',
       'El número de preguntas que puedes hacerle por día'
     ]),
     1,
     0,
     'La ventana de contexto es todo el texto que el modelo puede "ver" en una sola interacción: tu prompt, el historial del chat y cualquier documento pegado. Claude 4 maneja ~200k tokens, suficiente para un libro entero.'),

    (v_lesson_id,
     '¿En cuál de estos casos es más probable que la IA alucine?',
     to_jsonb(ARRAY[
       'Al resumir un artículo que le pegaste',
       'Al traducir un párrafo al inglés',
       'Al pedirle citas textuales de libros o datos numéricos específicos',
       'Al reformular un email con tono más profesional'
     ]),
     2,
     0,
     'Las alucinaciones se disparan con datos específicos (fechas, cifras, citas textuales, URLs). Cuando le das el material fuente o le pides tareas lingüísticas, trabaja con lo que tiene y alucina mucho menos.'),

    (v_lesson_id,
     '¿Cuál de estas NO es una forma efectiva de reducir alucinaciones?',
     to_jsonb(ARRAY[
       'Darle al modelo el contexto o documento fuente tú mismo',
       'Pedirle explícitamente que admita si no sabe algo',
       'Usar palabras más largas y técnicas en la pregunta',
       'Conectarlo a herramientas como búsqueda web'
     ]),
     2,
     0,
     'Las palabras más técnicas no reducen alucinaciones. Lo que funciona es: (1) darle el contexto, (2) pedirle que diga "no lo sé" si no está seguro, (3) conectarlo a herramientas reales (búsqueda, bases de datos).'),

    (v_lesson_id,
     'Si tu chat con la IA empieza a dar respuestas confusas o repetitivas, ¿qué es lo mejor que puedes hacer?',
     to_jsonb(ARRAY[
       'Reiniciar el modelo desde cero',
       'Empezar un chat nuevo, el contexto anterior puede estar "ensuciado"',
       'Escribir en mayúsculas para enfatizar',
       'Pagar una suscripción más alta'
     ]),
     1,
     0,
     'Cuando un chat se vuelve largo o caótico, el contexto acumulado puede confundir al modelo. Un chat nuevo con un prompt bien estructurado suele resolverlo al instante.');

  -- =============================================
  -- LECCIÓN 3: Prompting — el arte de pedir bien
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Prompting: el arte de pedir bien',
$md$## La diferencia entre una respuesta mediocre y una genial

Mismo modelo. Mismo usuario. Misma pregunta… con prompts distintos:

**Prompt flojo**:
> Háblame de marketing

→ Respuesta genérica: "El marketing es la disciplina que se encarga de promover productos y servicios… [500 palabras aburridas]"

**Prompt bueno**:
> Actúa como consultor de marketing digital para pequeños negocios. Tengo una panadería en Medellín que atiende 50 clientes al día. Quiero triplicar las ventas en 30 días con un presupuesto de $200 USD. Dame 3 campañas concretas en redes sociales, en una tabla con columnas: idea, costo estimado, dificultad (1-5), tiempo de ejecución.

→ Respuesta quirúrgica, aplicable mañana mismo.

**No cambió el modelo. Cambió la forma de pedir.**

### Los 5 pilares de un buen prompt

Piensa en ellos como un checklist mental:

**1. Rol** — ¿Quién responde?
> "Actúa como [rol]" / "Eres un [profesión] con X años de experiencia"

**2. Contexto** — ¿Qué más necesito saber?
> Tu situación, tu negocio, tu nivel, la audiencia

**3. Tarea clara** — ¿Qué hago exactamente?
> Verbo de acción: "escribe", "resume", "compara", "lista", "crea"

**4. Formato** — ¿Cómo quieres la respuesta?
> Tabla, lista, párrafo corto, bullets, JSON, email

**5. Restricciones** — ¿Qué evitar?
> Longitud, tono, cosas prohibidas

No todos los prompts necesitan los 5. Pero cuando una respuesta te deja frío, **casi seguro te faltó uno de estos**.

### Técnica 1: Few-shot (dale ejemplos)

En vez de describir el estilo que quieres, **muéstraselo**:

> Clasifica estos comentarios como "positivo" o "negativo".
>
> Ejemplo 1: "Amé el producto, súper recomendado" → positivo
> Ejemplo 2: "Tardó 3 semanas en llegar, pésimo" → negativo
>
> Ahora clasifica estos:
> 1. "Buen precio pero la calidad no es lo que esperaba"
> 2. "Rápido y justo como en la foto"

Dos ejemplos bien elegidos valen más que 10 líneas explicando el tono.

### Técnica 2: Chain-of-thought (pensar en voz alta)

Para problemas con múltiples pasos (matemáticas, lógica, análisis), agrega:

> "Piensa paso a paso antes de dar la respuesta final."

La precisión sube dramáticamente. El modelo razona en voz alta y se autocorrige.

### Técnica 3: Refinamiento iterativo

No intentes sacar la respuesta perfecta en un solo prompt. **Conversa con la IA**:

> "Dame 5 ideas de nombre para una cafetería."
> → recibes 5
> "Me gusta la idea 3. Dame 10 variaciones sobre esa."
> → refinas
> "Combina la 4 con la 7 y acórtala a 2 palabras."
> → iteras

Así se trabaja con IA en serio: como con un colega creativo.

### Errores de prompting más comunes

| Error | Ejemplo | Solución |
|-------|---------|----------|
| Pregunta ambigua | "Dime algo sobre salud" | Especifica audiencia, formato, objetivo |
| Asumir contexto | "Mejora esto" (sin pegar "esto") | Pega siempre el material |
| Pedir demasiado | "Crea una estrategia completa de negocio" | Divide en pasos |
| No iterar | Aceptas la primera respuesta | Refínala con feedback |
| Prompt en mayúsculas | "ESCRIBE UN EMAIL" | No sirve de nada, escribe normal |

### Plantilla universal (copia y guárdala)

```
Actúa como [rol].

Contexto:
- [situación concreta]
- [para quién / nivel]

Tarea: [verbo de acción + qué exactamente]

Formato: [cómo quieres la respuesta]

Restricciones:
- [longitud / tono / qué evitar]

[Si aplica] Ejemplos del output que quiero:
- [ejemplo 1]
- [ejemplo 2]
```

Esto no es magia — es comunicación clara. La misma que usarías con un humano nuevo al que le estás delegando trabajo por primera vez.
$md$,
    2,
    75,
$md$**Reescribe un prompt tuyo (15 min)**

1. Piensa en una tarea real que tengas esta semana (escribir email, planear reunión, resumir documento, crear cronograma, etc.).

2. **Prompt 1 (flojo)**: pídele a Claude esa tarea con una sola frase corta. Guarda la respuesta.

3. **Prompt 2 (bueno)**: reescribe el prompt aplicando los 5 pilares (rol, contexto, tarea, formato, restricciones). Mínimo 4 líneas.

4. **Compara** las dos respuestas. ¿Cuál te ahorra más tiempo?

**Entregable**: copia y guarda el Prompt 2 en una nota. Esa es tu primera plantilla reutilizable.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál de estos NO es uno de los 5 pilares de un buen prompt?',
     to_jsonb(ARRAY[
       'Rol (quién responde)',
       'Contexto (qué más debe saber)',
       'Idioma de la respuesta',
       'Formato (cómo debe responder)'
     ]),
     2,
     0,
     'Los 5 pilares son: rol, contexto, tarea clara, formato y restricciones. El idioma es una restricción puntual — no un pilar estructural.'),

    (v_lesson_id,
     '¿Qué es la técnica "few-shot"?',
     to_jsonb(ARRAY[
       'Pedirle al modelo que responda muy corto',
       'Mostrar 2-3 ejemplos del output que quieres para que el modelo imite el patrón',
       'Usar un modelo pequeño para ahorrar costos',
       'Hacer varias preguntas en paralelo'
     ]),
     1,
     0,
     'Few-shot significa darle ejemplos del resultado deseado. En vez de describir el estilo, lo muestras. Dos o tres ejemplos bien elegidos suelen funcionar mejor que párrafos explicando.'),

    (v_lesson_id,
     '¿Cuándo conviene agregar "piensa paso a paso" al prompt?',
     to_jsonb(ARRAY[
       'Siempre, en cualquier prompt',
       'En problemas con varios pasos: matemáticas, lógica, análisis, debugging',
       'Solo cuando el modelo se equivoca la primera vez',
       'Nunca, alarga la respuesta sin beneficio'
     ]),
     1,
     0,
     '"Piensa paso a paso" (chain-of-thought) sube la precisión en problemas que requieren múltiples pasos de razonamiento. Para preguntas simples no aporta; para problemas complejos cambia el juego.'),

    (v_lesson_id,
     'Tu primera respuesta de la IA no fue lo que esperabas. ¿Cuál es el peor siguiente paso?',
     to_jsonb(ARRAY[
       'Refinar el prompt con más contexto y pedirle de nuevo',
       'Darle feedback específico: "la respuesta es muy genérica, dame ejemplos concretos"',
       'Aceptar esa respuesta aunque no te sirva y usarla así',
       'Darle 2-3 ejemplos del tipo de respuesta que buscas'
     ]),
     2,
     0,
     'Aceptar una respuesta mediocre es el único error real. Refinar, iterar, dar ejemplos o más contexto son todas buenas prácticas — es así como se trabaja con IA en serio.');

  -- =============================================
  -- LECCIÓN 4: Tu mapa de herramientas IA
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Tu mapa de herramientas IA',
$md$## Las 5 familias que debes conocer

Hay miles de "herramientas IA" en el mercado. En realidad todas caen en **5 categorías**. Saber cuál usar para cada cosa te ahorra semanas de probar al azar.

### 1. Chat / asistentes — "pensar, escribir, analizar"

Los que ya usaste. Claude, ChatGPT, Gemini.

**Úsalos cuando**: necesitas escribir, resumir, analizar, planear, traducir, explicar, hacer brainstorming.

**Recomendación**: empieza con **Claude.ai** (plan gratis decente, Pro si lo usas todos los días — USD $20/mes).

### 2. Builders con IA — "construir software sin programar"

Herramientas donde describes lo que quieres en español y la IA **construye la aplicación**.

| Herramienta | Para qué brilla |
|-------------|-----------------|
| **Claude Code** | Proyectos serios, software real, dentro de VS Code o Antigravity |
| **Cursor** | Como VS Code pero con IA dentro. Para quienes ya programan un poco |
| **Lovable** | Landing pages y apps web completas sin código |
| **v0 (Vercel)** | Componentes UI modernos a partir de descripción |
| **Bolt.new** | Apps full-stack en el navegador |

**Úsalos cuando**: quieres un sitio web, una app interna, un chatbot con UI, o automatizar un proceso con una interfaz visual.

### 3. Automatización — "conectar apps y disparar IA"

Cuando quieres que las cosas pasen **solas**. Se dispara un evento (llega email, alguien llena form, pasa la hora X) y la herramienta ejecuta una cadena de acciones, incluyendo llamar a la IA.

| Herramienta | Cuándo |
|-------------|--------|
| **n8n** | Potente, flexible, self-hosted posible. Más técnica, curva de aprendizaje media |
| **Make.com** | UI muy visual, buena para empezar |
| **Zapier** | La más fácil de todas, pero limitada para flujos complejos |

**Úsalos cuando**: "quiero que cuando pase X, se dispare Y", sin mantener una infraestructura propia.

En este curso profundizamos en **n8n** por ser gratis, flexible y el estándar del momento para AI Agents.

### 4. Visual — "imágenes, video, audio"

IA que genera contenido no-textual.

| Herramienta | Para qué |
|-------------|----------|
| **Midjourney** | Imágenes artísticas de alta calidad. El estándar en estética |
| **Nano Banana** (Google) | Edición de imágenes con prompts en español, muy fiel |
| **Sora** (OpenAI) | Video corto a partir de texto |
| **Kling** / **Runway** | Video más largo, edición compleja, animación de personajes |
| **ElevenLabs** | Voz sintética indistinguible de humana |

**Úsalos cuando**: necesitas imágenes para contenido, video promocional, voz en off, ilustraciones de marca.

### 5. Agentes — "que tomen decisiones solas"

Un **agente** es una IA que **usa herramientas** y decide qué hacer paso a paso para cumplir un objetivo. No solo responde — actúa.

Ejemplos: un agente que monitorea tu bandeja de entrada y responde emails de soporte, un agente que investiga un tema consultando 10 fuentes, un agente que cierra ventas por WhatsApp.

Los verás a fondo en el **track de AI Agents & MCP**. Por ahora, quédate con la idea: **es el siguiente nivel después del chat**.

### Tabla maestra: "necesito X → usa Y"

| Necesito… | Herramienta ideal |
|-----------|-------------------|
| Escribir un email mejor | Claude / ChatGPT |
| Analizar un Excel de 500 filas | Claude (con archivo adjunto) |
| Construir una landing page | Lovable o v0 |
| Modificar código de mi proyecto | Claude Code en Antigravity |
| Automatizar respuestas de WhatsApp | n8n + Claude API |
| Generar 20 imágenes para redes | Midjourney o Nano Banana |
| Crear un video de 30 segundos | Sora o Kling |
| Hacer que un asistente maneje mi calendario | Agent con MCP |

### Tu stack mínimo para empezar

Con estas **3 herramientas** cubres el 80% de casos:

1. **Claude.ai** (chat)
2. **Lovable** o **Claude Code** (builder)
3. **n8n** (automatización)

Las 3 tienen plan gratis utilizable. No te compliques con 10 herramientas — domina estas primero.

### Regla de bolsillo

> **La mejor herramienta es la que ya sabes usar.**

No cambies de stack cada semana. Elige una herramienta de cada familia que vas a usar, y profundiza.
$md$,
    3,
    50,
$md$**Elige tu herramienta para 5 escenarios**

Para cada uno de estos casos, **decide qué herramienta usarías y por qué** (escríbelo en una nota):

1. Tu mamá necesita una landing page sencilla para su negocio de tortas, con fotos y formulario de contacto.
2. Tienes un PDF de 40 páginas y necesitas extraer los 10 puntos más importantes.
3. Quieres que cada vez que llegue un email con "factura" en el asunto, se guarde automáticamente en Google Drive y te notifique por WhatsApp.
4. Necesitas 15 imágenes promocionales para tu Instagram, todas con el mismo estilo.
5. Quieres construir una app interna para gestionar los pedidos de tu pequeño negocio.

**Objetivo**: terminar esta lección sabiendo exactamente con qué herramienta atacar cada tipo de problema. Sin perder tiempo evaluando 20 opciones cada vez.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué herramienta es más adecuada para "automatizar que cada email con factura se guarde en Drive"?',
     to_jsonb(ARRAY[
       'Midjourney',
       'Claude Code',
       'n8n o Make.com',
       'Lovable'
     ]),
     2,
     0,
     'Esa es una automatización clásica: trigger (email recibido) → acción (guardar en Drive + notificar). n8n y Make.com son los reyes de ese tipo de flujos.'),

    (v_lesson_id,
     'Quieres construir una landing page sin programar. ¿Qué opción NO sirve para eso?',
     to_jsonb(ARRAY[
       'Lovable',
       'v0 de Vercel',
       'Bolt.new',
       'ElevenLabs'
     ]),
     3,
     0,
     'ElevenLabs genera voz sintética, no páginas web. Lovable, v0 y Bolt.new son builders con IA pensados exactamente para sitios y apps.'),

    (v_lesson_id,
     '¿Cuál es la diferencia fundamental entre un chat de IA y un "agente"?',
     to_jsonb(ARRAY[
       'El agente es más rápido',
       'El agente usa herramientas y toma decisiones para cumplir un objetivo, no solo responde',
       'El agente es un modelo más nuevo',
       'No hay diferencia, son lo mismo'
     ]),
     1,
     0,
     'Un chat conversa. Un agente actúa: usa herramientas (búsqueda web, APIs, tu calendario, etc.), decide qué hacer a continuación y ejecuta pasos para lograr un objetivo. Es el siguiente nivel después del chat.');

  RAISE NOTICE 'Track "La Base": 4 lecciones + 13 quizzes insertados correctamente.';
END $$;
