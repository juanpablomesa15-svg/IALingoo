-- Mega seed part 2 (2026-04-21): 9 older tracks with quiz ARRAY fix
-- Run in Supabase SQL Editor after part 1


-- ============================================
-- FILE: seeds/track-base.sql
-- ============================================
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

-- ============================================
-- FILE: seeds/track-claude-01-basico.sql
-- ============================================
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

-- ============================================
-- FILE: seeds/track-claude-03-mcps.sql
-- ============================================
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

-- ============================================
-- FILE: seeds/track-visual-01-imagenes.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Creador Visual" / Módulo "Imágenes con IA"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'visual';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo Imágenes no encontrado.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- =============================================
  -- LECCIÓN 1: El panorama de generación de imágenes
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'El panorama de imágenes con IA',
$md$## Elige la herramienta correcta, no la más famosa

En 2026 generar imágenes con IA es trivial. Lo difícil es **elegir la herramienta correcta para el trabajo**. Cada una tiene fortalezas y debilidades reales.

### Las 5 herramientas que importan hoy

| Herramienta | Fuerte en | Débil en | Costo |
|---|---|---|---|
| **Midjourney v7** | Arte estilizado, moodboards, conceptual | Texto dentro de imagen, precisión técnica | $10-60/mes |
| **Nano Banana** (Gemini 3 Pro Image) | Edición fotorrealista, consistencia de personaje | Estilos muy artísticos | API o AI Studio |
| **GPT Image 1** | Texto dentro de imagen, diagramas, infografías | Estilos muy pictóricos | $0.04/imagen en API |
| **Flux 1.1 Pro** | Fotorrealismo extremo, piel y texturas | Costo más alto | $0.04/imagen |
| **Ideogram 3** | Tipografía artística, posters con texto | Imágenes complejas con muchos elementos | Free + paid |

**Regla práctica**: si es para inspiración visual/moodboard → Midjourney. Si es para un producto/marketing con texto o logo → GPT Image o Ideogram. Si es fotorrealismo → Flux o Nano Banana. Si necesitas editar (no generar desde cero) → Nano Banana.

### ¿Qué es "prompting de imágenes"?

Igual que con texto, prompting es el arte de **pedir bien**. Un prompt malo te da imágenes genéricas; uno bueno te da exactamente lo que viste en tu cabeza.

Un prompt de imagen tiene típicamente 4 ingredientes:

1. **Sujeto**: qué o quién aparece
2. **Estilo**: fotográfico, ilustración, 3D, pixel art...
3. **Composición**: ángulo, distancia, encuadre
4. **Ambiente**: luz, mood, paleta de color

Ejemplo malo: _"un perro"_.
Ejemplo bueno: _"un golden retriever cachorro sentado en un sofá cerca de una ventana, luz de la tarde cálida, estilo fotografía lifestyle, composición centrada, profundidad de campo suave"_.

### Lo que cambió en 2026

Dos saltos importantes que afectan cómo trabajas:

**1. Edición > Generación**
Nano Banana (de Google) revolucionó la edición: subes una foto, le pides cambios específicos ("cambia el fondo a un bosque", "quítale los lentes", "agrégale una taza de café en la mano") y respeta el resto de la imagen. Antes cada cambio requería regenerar toda la imagen.

**2. Consistencia de personaje**
Puedes crear un personaje y usarlo en 10 imágenes distintas sin que cambie su cara. Antes esto era casi imposible. Ahora es un slider.

### Los casos de uso reales

Antes de lanzarte a generar, entiende **para qué**:

- **Marketing & redes**: posts de Instagram, banners, thumbnails
- **Producto**: mockups, visualizaciones de ideas, decks
- **Branding**: moodboards, inspiración de paleta, style guides
- **Arte conceptual**: ilustración para libros, juegos, presentaciones
- **Prototipado UI**: mockups de apps y sitios antes de diseñar

Cada caso favorece una herramienta. Marketing + texto = Ideogram/GPT Image. Moodboards = Midjourney. Mockups de producto = Nano Banana/Flux.

### Lo que NO es buena idea

- **Fotos de personas reales sin consentimiento**: legal, ético, malo idea
- **Contenido engañoso**: pasarlas como reales si no lo son
- **Violar derechos de autor**: "estilo de [artista vivo]" es zona gris legal en varios países
- **Replicar imágenes con copyright** de marcas

Todas las plataformas tienen filtros que bloquean lo más obvio. Los demás límites los pones tú.

### Tu workflow básico

El patrón que vas a repetir miles de veces:

1. **Piensa qué quieres** (sujeto + estilo + composición + ambiente)
2. **Escribe un prompt descriptivo**
3. **Genera 4 variaciones**
4. **Elige la mejor, itera** (cambios pequeños, no reescribe todo)
5. **Si necesita retoque, usa una herramienta de edición** (Nano Banana)

Vas a dominar este ciclo en las próximas lecciones.$md$,
    0,
    50,
$md$**Exploración guiada.** Abre las páginas de [Midjourney](https://midjourney.com), [Gemini AI Studio](https://aistudio.google.com) (para Nano Banana) y [Ideogram](https://ideogram.ai). Para cada una:

1. Mira el feed/galería 5 minutos
2. Identifica qué estilo predomina (fotorrealista, ilustración, conceptual, tipográfico...)
3. Apunta qué caso de uso tuyo personal/laboral encaja con cada herramienta

Al terminar deberías poder decir: "para [mi caso] voy a usar [X herramienta] porque [Y]".

**Bonus**: crea cuenta en al menos una (Ideogram tiene free tier) para que mañana puedas hacer los ejercicios siguientes sin fricción.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Necesitas generar una imagen para un post de Instagram con tu logo y el texto "Lanzamiento 10 de mayo" integrado en el diseño. ¿Qué herramienta es la mejor opción?',
     to_jsonb(ARRAY[
       'Midjourney — mejor calidad artística',
       'Ideogram 3 o GPT Image — son los mejores integrando texto legible dentro de la imagen',
       'Flux 1.1 Pro — más realista',
       'Cualquiera, todas hacen bien el texto'
     ]),
     1,
     0,
     'Texto dentro de imagen fue un punto débil histórico de los generadores. Ideogram se especializó en eso desde el principio, y GPT Image también lo hace muy bien. Midjourney y Flux siguen siendo débiles con texto legible — te van a entregar algo que parece texto pero con letras raras. Para marketing con tipografía, elige la herramienta correcta.'),

    (v_lesson_id,
     '¿Cuáles son los 4 ingredientes típicos de un buen prompt de imagen?',
     to_jsonb(ARRAY[
       'Color, tamaño, resolución, formato',
       'Sujeto, estilo, composición, ambiente',
       'Marca, fecha, ubicación, audiencia',
       'Solo describir lo que quieres, la IA entiende sola'
     ]),
     1,
     0,
     'Sujeto (qué aparece), estilo (cómo se ve — fotográfico, ilustración, 3D, etc), composición (ángulo, encuadre, distancia) y ambiente (luz, mood, paleta). Un prompt que cubre estos 4 da resultados muy superiores a "un perro" o "una persona feliz". La IA rellena con sus defaults cuando falta información, y los defaults son genéricos.'),

    (v_lesson_id,
     'Ya generaste una imagen que te gusta casi, pero quieres cambiar solo el fondo y dejar el sujeto idéntico. ¿Qué camino eliges?',
     to_jsonb(ARRAY[
       'Regenerar desde cero con un prompt distinto y aceptar que cambie todo',
       'Usar una herramienta de edición como Nano Banana: sube la imagen, pídele solo el cambio de fondo, respeta el resto',
       'Abrir Photoshop manualmente',
       'No se puede cambiar solo el fondo con IA'
     ]),
     1,
     0,
     'Este fue uno de los saltos grandes de 2025-2026. Nano Banana (Gemini 3 Image) hace edición quirúrgica: cambia lo que le pides sin tocar lo demás. Regenerar desde cero es frustrante porque cada nueva generación cambia detalles que tú ya habías aprobado. Saber usar edición en vez de regeneración te ahorra horas y mantiene consistencia.');


  -- =============================================
  -- LECCIÓN 2: Prompting de imágenes en profundidad
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Prompting de imágenes en profundidad',
$md$## Lo que separa amateurs de pros

Todos pueden escribir _"un gato"_. Los buenos escriben prompts que **dan resultado la primera vez**. Esta lección es la receta completa.

### Fórmula extendida: 6 capas

Para trabajos serios, piensa así:

1. **Sujeto principal** — qué o quién
2. **Acción / pose** — qué está haciendo
3. **Setting / entorno** — dónde está
4. **Estilo visual** — fotorrealista, ilustración, 3D...
5. **Luz / hora del día** — suave, dura, golden hour, neón nocturno
6. **Cámara / composición** — ángulo, distancia, lente (si aplica)

Cada capa añade precisión. Puedes omitir algunas pero cuantas más uses, menos depende la IA de adivinar.

### Ejemplo completo deconstruído

Prompt:
> **Un barista latino de 30 años, delantal marrón**, preparando un latte art de corazón, **en una cafetería de especialidad con madera clara y plantas**, **estilo fotografía lifestyle editorial**, **luz lateral suave de ventana, hora de la mañana**, **cámara a la altura de la taza, desenfoque en el fondo, lente 50mm f/1.8**

Desglosado:

| Capa | Texto |
|---|---|
| Sujeto | barista latino, 30 años, delantal marrón |
| Acción | preparando un latte art de corazón |
| Setting | cafetería de especialidad, madera clara, plantas |
| Estilo | fotografía lifestyle editorial |
| Luz | lateral suave de ventana, mañana |
| Cámara | altura de taza, desenfoque de fondo, 50mm f/1.8 |

Resultado: predecible, usable, editorial. Muy lejos de "un barista haciendo café".

### Vocabulario de estilos (úsalo)

Estilos que funcionan muy bien:

- **Fotográficos**: cinematic, documentary, lifestyle, editorial, commercial, portrait, street photography
- **Ilustración**: flat illustration, watercolor, line art, gouache, comic book, anime
- **3D**: isometric 3D, low poly, clay render, plastic render, Pixar style
- **Otros**: pixel art, vaporwave, cyberpunk, brutalism, minimalist

Mezcla con cuidado — _"cinematic watercolor"_ rara vez sale bien. Elige un estilo dominante.

### Vocabulario de luz (oro)

| Término | Efecto |
|---|---|
| Golden hour | Tono cálido, suave, romántico |
| Blue hour | Azulado, misterioso, atardecer tardío |
| Harsh noon | Duro, sombras marcadas, contraste |
| Soft diffused | Uniforme, no hay sombras fuertes (cloudy day) |
| Neon lit | Multicolor, nocturno, cyberpunk vibe |
| Rim lighting | Borde iluminado del sujeto (dramático) |
| Low-key / high-key | Muy oscuro / muy claro |

Cambiar solo la luz puede cambiar el mood entero de una imagen.

### Negative prompts (lo que NO quieres)

Algunas herramientas permiten "negative prompts" — decir qué evitar. Útiles:

- `blurry, low quality, text` → evita difuminado, mala calidad, textos raros
- `cartoon, illustration` → si quieres fotorrealismo puro
- `extra fingers, distorted face` → problemas comunes en humanos

En Midjourney usas `--no cartoon, text`. En otras hay un campo separado.

### Aspectos (formato)

Proporciones importan:

- **1:1** → redes sociales cuadradas
- **4:5 o 9:16** → Instagram Story, TikTok, Reels
- **16:9** → thumbnails, banners web, YouTube
- **2:3** → carteles/posters, fotografía vertical

Decir el aspecto upfront evita recortar después. En Midjourney: `--ar 16:9`. En otras: setting dedicado.

### Iteración inteligente

Cuando una imagen casi está pero no:

- **"Same scene but [cambio pequeño]"** — mantiene el resto, cambia algo puntual
- **"[Prompt original], but shot from above"** — cambia solo la cámara
- **"Vary subtly"** — pide variación pequeña (Midjourney button)
- **"Zoom out" / "Zoom in"** — ajusta distancia

No reescribas todo el prompt si solo quieres un cambio. Itera específico.

### Reference images (la joya)

Casi todas las herramientas modernas aceptan imágenes de referencia:

- **Style reference**: "haz una imagen de X pero en el estilo de [imagen]"
- **Subject reference**: "usa esta persona/objeto pero en un contexto nuevo"
- **Composition reference**: "usa este encuadre pero cambia el contenido"

Subir referencias es una forma mucho más rápida de comunicar estilo que describirlo en palabras. "Rojo oxidado" es ambiguo; una imagen con ese rojo es inequívoca.

### Ejercicio mental

Antes de generar, pregúntate:

> _"Si le mandara esta descripción a un diseñador humano sin más contexto, ¿podría hacer exactamente lo que quiero?"_

Si la respuesta es no, tu prompt aún está vago. Añade capas.$md$,
    1,
    60,
$md$**Genera 3 versiones de la misma idea — una con cada nivel de prompt.**

Elige un concepto tuyo (ej: "un cuaderno de apuntes sobre un escritorio" o "un personaje para la mascota de mi app"):

1. **Versión básica**: prompt de 5-10 palabras. Ej: _"un cuaderno en un escritorio"_. Genera 4 imágenes.
2. **Versión intermedia**: agrega estilo y ambiente. Ej: _"un cuaderno de cuero marrón abierto sobre un escritorio de madera, estilo fotografía editorial, luz natural de ventana"_. Genera 4 imágenes.
3. **Versión avanzada**: las 6 capas completas + aspecto. Ej: _"un cuaderno de cuero marrón gastado, pluma estilográfica encima, escritorio de madera oscura, taza de café humeante a un costado, libros viejos al fondo, estilo fotografía lifestyle, luz lateral golden hour, vista cenital, lente 35mm, aspecto 4:5"_. Genera 4 imágenes.

**Compara los 3 resultados**. Escribe 2 frases sobre qué ganaste al ser más específico.

**Meta**: internalizar que detalle = control.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Tienes una imagen que te gusta pero quieres cambiar solo el ángulo de cámara. ¿Cuál es la mejor iteración?',
     to_jsonb(ARRAY[
       'Reescribir todo el prompt desde cero',
       'Decir "same scene but shot from above" o "same scene, camera angle from below"',
       'Generar 50 variaciones y elegir',
       'Cambiar de herramienta'
     ]),
     1,
     0,
     'Iteración quirúrgica: cambias una capa (la de cámara) y dejas las demás iguales. Esto preserva el sujeto, el estilo y el mood que ya te gustan, y solo ajusta lo que querías. Reescribir desde cero te cambia cosas que no querías cambiar y vuelve el proceso largo.'),

    (v_lesson_id,
     '¿Qué hace "--ar 16:9" en Midjourney?',
     to_jsonb(ARRAY[
       'Cambia el modelo de IA a usar',
       'Define el aspect ratio (proporción) de la imagen a 16:9, ideal para thumbnails o banners',
       'Aumenta la resolución',
       'Agrega texto a la imagen'
     ]),
     1,
     0,
     '--ar es la bandera para aspect ratio. 16:9 es el formato de thumbnails de YouTube, banners web y monitores. Otros útiles: 1:1 (redes), 9:16 (stories/TikTok), 4:5 (Instagram feed). Decirle el aspecto desde el prompt es mejor que generar cuadrado y recortar después, porque la IA compone pensando en ese formato.'),

    (v_lesson_id,
     'Quieres un estilo visual muy específico pero te cuesta describirlo en palabras. ¿Qué puedes hacer?',
     to_jsonb(ARRAY[
       'Resignarte y probar 30 prompts distintos',
       'Subir una imagen de referencia de estilo — la IA copia el estilo y aplica tu prompt',
       'Solo se puede por texto',
       'Pagar por un estilo premium'
     ]),
     1,
     0,
     'La mayoría de herramientas modernas (Midjourney, Nano Banana, Flux) aceptan imágenes de referencia. Puedes pasar una imagen como referencia de estilo ("genera X en este estilo") o de sujeto ("usa esta persona/objeto en un contexto nuevo"). Es infinitamente más preciso que intentar describir con palabras estilos complejos. Regla oro: si puedes mostrar en vez de explicar, muestra.');


  -- =============================================
  -- LECCIÓN 3: Consistencia de personaje y edición
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Consistencia de personaje y edición',
$md$## La revolución silenciosa de 2025-2026

El problema histórico de generación de imágenes: si creabas un personaje "mujer, 30 años, pelo negro corto, gafas redondas", la IA te daba una mujer distinta cada vez. Para un cómic, un libro ilustrado o un set de marketing con el mismo personaje, era casi imposible.

En 2025-2026 eso cambió. Hoy puedes crear **un personaje consistente** y usarlo en 20 escenas distintas. Esta es una de las capacidades que más valor comercial tiene.

### Cómo se logra consistencia hoy

Varias formas, de más simple a más poderosa:

**1. Character reference**
Generas un personaje base. Luego en cada nueva imagen pasas esa imagen como "character reference". La IA respeta los rasgos faciales.

En Midjourney: `--cref [URL de la imagen base]`. En otras herramientas: botón "character reference" o similar.

**2. Seeds**
Un seed es un número que determina la "semilla" de generación. Mismo prompt + mismo seed = imagen muy similar. Útil para mantener estilo consistente, menos para consistencia de cara exacta.

**3. LoRA custom (avanzado)**
Un LoRA (Low-Rank Adaptation) es un mini-modelo entrenado con tus imágenes. Le pasas 10-20 fotos de una persona y el LoRA aprende a generarla. Después cualquier prompt con ese LoRA activo la incluye. Avanzado, pero poderoso para proyectos largos.

**4. Nano Banana / Gemini Image edit**
Tienes una imagen base y le pides cambios sin alterar el personaje: "mismo sujeto pero en la playa", "mismo sujeto pero con ropa formal". Es lo más práctico para flujos de trabajo rápidos.

### Flujo típico: serie de 10 imágenes con el mismo personaje

Imagínate que creás un emprendimiento y necesitas 10 escenas con la misma mascota (un zorro naranja con lentes). Así lo haces:

1. **Genera la imagen base del personaje**: múltiples variaciones hasta que una te convenza ("el" zorro).
2. **Guarda esa imagen**.
3. **Para cada nueva escena**: usa la imagen base como character reference + prompt de la nueva escena.
4. **Revisa y corrige**: si en alguna la cara quedó distinta, regenera solo esa con más peso al reference.

Siempre revisa — la IA no es perfecta. Pero pasaste de "imposible" a "consistente en 80% de los intentos".

### Edición quirúrgica con Nano Banana

Nano Banana es el nombre cariñoso de Gemini 3 Pro Image, el modelo de edición de Google. Es el mejor hoy para:

- Cambiar fondos sin tocar el sujeto
- Quitar/agregar objetos
- Cambiar ropa, color de cabello, expresión
- Añadir elementos nuevos a una escena existente

Cómo accederlo: [aistudio.google.com](https://aistudio.google.com) → elige el modelo Gemini 3 Image → sube la imagen base.

### Ejemplos de ediciones mágicas

Con una imagen subida:

- _"Cambia el fondo a un parque con otoño, mantén la persona idéntica"_
- _"Quítale los lentes del sol, todo lo demás igual"_
- _"Agrega una taza de café en su mano derecha"_
- _"Cambia su camiseta blanca a una negra con un logo pequeño en el pecho"_
- _"Hazla sonreír sutilmente"_
- _"Cambia la hora del día a atardecer, ajusta los colores"_

Cada uno de esos hace solo el cambio pedido. En 5 minutos puedes tener 10 variaciones de la misma foto base para un set de marketing.

### In-painting y out-painting (conceptos)

Estos son los términos técnicos:

- **In-painting**: editar una zona específica de una imagen (borrar y rellenar)
- **Out-painting**: expandir una imagen más allá de sus bordes originales

Nano Banana hace ambos sin que tengas que pensar en los términos — solo describes qué quieres y él elige. Pero útil saber los nombres cuando leas documentación.

### Cuándo NO usar edición

- Cuando la imagen base ya tiene algo mal (una mano rara, proporción incorrecta). Mejor regenerar desde cero.
- Cuando pides un cambio tan grande que más rápido es prompt nuevo.
- Cuando el cambio involucra física compleja (ej. "hazlo volar mirando a la cámara"). La IA puede llegar a resultados raros.

### Workflow profesional: base + variaciones

Un patrón que usan agencias:

1. **Genera la imagen hero** (la principal) con cuidado. Dedica tiempo.
2. **Aprueba el hero con el cliente**.
3. **Deriva variaciones con edición** para los otros formatos: cuadrada, vertical, con texto, sin texto, con diferentes claims.

Con edición, 1 hero + 10 variaciones toma 1 hora. Sin edición, regenerar cada una toma 5 horas y son inconsistentes.

### Límites honestos

Aun con las mejores herramientas de 2026:

- **Manos**: siguen fallando a veces. Revisa.
- **Texto pequeño**: se deforma. Si necesitas texto chico preciso, agrégalo después en Figma/Canva.
- **Personas reales reconocibles**: las herramientas te bloquean para figuras públicas, pero ojo con consentimientos en personas comunes.
- **Consistencia perfecta**: sigue siendo ~80-90%, no 100%. Revisa siempre.$md$,
    2,
    70,
$md$**Crea un personaje consistente y úsalo en 3 escenas.**

1. **Imagina tu personaje**: una mascota, un character ficticio, o hasta un estilo de persona (no alguien real específico).
2. **Genera la imagen base** en Midjourney, Nano Banana o la que prefieras. Itera hasta que te guste.
3. **Crea 3 escenas distintas** usando ese personaje:
   - Escena A: en un contexto distinto (playa, oficina, ciudad, bosque)
   - Escena B: haciendo algo distinto (leyendo, corriendo, cocinando)
   - Escena C: en estilo visual distinto (ilustración vs foto, o noche vs día)
4. Usa **character reference** (--cref en MJ) o **Nano Banana edit** según lo que uses

**Meta**: terminar con 3 imágenes del mismo personaje que podrías usar en un set de marketing o un libro ilustrado. Nota dónde la IA acertó y dónde fue inconsistente.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué logras con "character reference" en herramientas modernas?',
     to_jsonb(ARRAY[
       'Pagar menos por cada generación',
       'Que el mismo personaje se mantenga consistente a través de múltiples imágenes distintas',
       'Aumentar la resolución final',
       'Cambiar el idioma del prompt'
     ]),
     1,
     0,
     'Character reference es la feature que resolvió uno de los problemas más frustrantes de imagen IA: la falta de consistencia. Pasas una imagen de un personaje (tu mascota, tu character, tu diseño) y la IA mantiene sus rasgos en nuevas escenas. Perfecto para sets de marketing, libros ilustrados, cómics o cualquier cosa que requiera el mismo personaje en contextos distintos.'),

    (v_lesson_id,
     'Tienes una foto de producto pero quieres 5 variaciones con fondos distintos sin que el producto cambie. ¿Qué herramienta usas?',
     to_jsonb(ARRAY[
       'Regenerar 5 veces desde cero con Midjourney',
       'Usar Nano Banana (Gemini 3 Image) para edición: mismo producto, distintos fondos',
       'Photoshop manual',
       'No es posible'
     ]),
     1,
     0,
     'Nano Banana está optimizado exactamente para este caso: cambios quirúrgicos en una imagen existente manteniendo lo demás intacto. Subes la foto del producto, en cada variación solo le dices el fondo nuevo. En 5 minutos tienes 5 variaciones. Regenerar desde cero en MJ te da 5 productos distintos — no sirve para un set cohesivo.'),

    (v_lesson_id,
     '¿Cuál es una limitación real de generación de imágenes en 2026?',
     to_jsonb(ARRAY[
       'Las imágenes salen en blanco y negro',
       'Las manos y el texto pequeño aún fallan a veces — siempre revisa, y para texto preciso mejor añadirlo en Figma/Canva después',
       'Solo se pueden hacer imágenes cuadradas',
       'No se pueden hacer personas'
     ]),
     1,
     0,
     'Seamos honestos: por impresionante que sean, las herramientas actuales tienen fallas conocidas. Manos con dedos extra, texto ilegible, reflejos físicamente imposibles. Un workflow profesional asume eso: revisa siempre manos y texto, y si necesitas texto pequeño y legible (ej. número de teléfono, URL), agrégalo en una herramienta de edición normal después de generar la imagen base.');


  -- =============================================
  -- LECCIÓN 4: Workflow profesional y casos de uso
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Workflow profesional y casos de uso',
$md$## De experimentar a producir

Lo que vimos hasta aquí fue "cómo generar". Esta lección es "cómo producir volumen con calidad". Si vas a usar imagen IA para clientes o tu propio negocio, el workflow importa más que el prompt perfecto.

### El ciclo de producción completo

Un proyecto profesional típico pasa por:

1. **Brief**: qué se necesita, para qué, audiencia, restricciones
2. **Moodboard**: 10-20 imágenes de referencia (generadas o encontradas)
3. **Concept**: elegir dirección con cliente/equipo
4. **Hero generation**: generar la imagen principal con máximo cuidado
5. **Variations**: derivar del hero todas las variantes necesarias (formatos, textos, idiomas)
6. **Post-processing**: Photoshop/Figma/Canva para detalles finales
7. **Entrega**: organizar archivos con nombres claros

Cada paso tiene su herramienta:

| Paso | Mejor herramienta |
|---|---|
| Moodboard | Midjourney (rapidez, calidad estética) |
| Hero | Flux / Midjourney / GPT Image según caso |
| Variations | Nano Banana (edición quirúrgica) |
| Texto sobre imagen | Ideogram / GPT Image |
| Post-processing | Figma / Photoshop / Canva |

### Caso real 1: Set de 10 posts para Instagram

**Brief**: lanzamiento de un curso, 10 posts en 2 semanas, estilo consistente, con texto.

**Workflow**:

1. Hero con el estilo dominante → _"cuaderno + café + plantas, lifestyle editorial, luz cálida"_
2. Aprobado el estilo, genera 10 variaciones de la misma escena con distintos objetos centrales
3. Nano Banana para ajustes (quitar cosa, mover cosa)
4. Ideogram o Canva para overlay de texto
5. Guarda con nombres: `post-01-lanzamiento.png`, `post-02-dia2.png`, etc.

Tiempo total: 2-3 horas. A mano tomaría 2-3 días.

### Caso real 2: Mockup de producto

**Brief**: mostrar cómo se vería tu app en un teléfono, 4 variantes para landing page.

**Workflow**:

1. Genera un iPhone de plástico o renderizado vacío (prompt tipo: _"iPhone 15 Pro en fondo blanco, 3/4 view, producto studio"_)
2. En Figma/Photoshop, pega el screenshot de tu app sobre la pantalla
3. En Nano Banana, si quieres un mockup más de lifestyle, sube la imagen del teléfono y pide: _"pon este teléfono en la mano de una persona trabajando en un café"_
4. Exporta 4 variaciones con distintos contextos (café, oficina, casa, en la calle)

Alternativamente, hoy muchos usan servicios como [Mockup.photos](https://mockup.photos) o herramientas de Figma directamente. Pero con IA tienes más flexibilidad.

### Caso real 3: Ilustraciones para un blog

**Brief**: 20 artículos, cada uno con una ilustración de cabecera. Estilo consistente a través de todos.

**Workflow**:

1. Define el estilo maestro: _"flat illustration, paleta pastel, líneas simples, sin texto"_
2. Para cada artículo: mismo estilo base + concepto distinto del artículo
3. Mantén un archivo de prompts: _article-01.txt_ con el prompt exacto de cada uno
4. Si el estilo se corre, usa style reference al hero del primer artículo

Con este patrón, 20 ilustraciones en 1 día.

### Librerías de prompts (tu biblioteca)

Los pros mantienen **colecciones de prompts que funcionan**. Por ejemplo:

- `prompts/fotografia-producto.md` — tu fórmula para productos
- `prompts/personas-profesionales.md` — tu fórmula para personas profesionales
- `prompts/mockups.md` — tu fórmula para mockups

Con el tiempo acumulas patrones que sabes que salen bien. Ahorra horas de experimentar.

### Costos reales

Presupuesto realista para uso profesional:

- **Midjourney Pro**: $60/mes → ~4000 imágenes
- **Flux 1.1 Pro via API**: $0.04/imagen → 1000 imágenes = $40
- **Nano Banana via AI Studio**: free tier generoso, luego pay-as-you-go
- **GPT Image via API**: $0.04/imagen estándar
- **Ideogram Pro**: $20/mes

Para un freelance trabajando activamente, un stack de $80-150/mes cubre todo.

### Errores comunes de principiantes (evítalos)

- **Prompts cortos**: "una oficina moderna" te da genérico. Detalla.
- **Mezclar estilos incompatibles**: "fotorrealista ilustración pixel art" = caos.
- **Generar sin aspect ratio**: te toca recortar después y pierdes calidad.
- **No guardar prompts buenos**: los vas a necesitar de nuevo.
- **Aceptar la primera versión**: casi nunca es la mejor. Genera 4, elige.
- **Olvidar revisar manos y texto**: siempre revisa.

### Ética y legal (cuidado)

Temas que ya son reales:

- **Derechos de autor**: "estilo de [artista vivo]" es legalmente gris. Evítalo en trabajos comerciales.
- **Personas reales**: no generes imágenes de personas públicas sin contexto claro de sátira o ficción, y nunca en situaciones comprometedoras.
- **Marcas registradas**: no recrees logos ni packaging de marcas.
- **Modelos**: cuando uses una imagen generada comercialmente, revisa los términos de la herramienta (algunos requieren plan pago para uso comercial).

### Tu plan de 30 días

Si quieres volverte pro en imagen IA:

- **Semana 1**: explora 3 herramientas a fondo (Midjourney, Nano Banana, Ideogram)
- **Semana 2**: genera 50 imágenes con prompts deliberadamente variados
- **Semana 3**: construye tu primera librería de prompts que funcionan
- **Semana 4**: haz un proyecto completo con workflow pro (set de 10, mockup, o ilustraciones consistentes)

Al día 30, no serás el mejor del mundo, pero habrás saltado más que el 95% de usuarios casuales.$md$,
    3,
    70,
$md$**Proyecto de cierre: tu primer set profesional.**

Elige uno de estos proyectos reales y hazlo end-to-end:

- **A**: 5 posts de Instagram con tema y estilo consistente (lanzamiento de algo tuyo o ficticio)
- **B**: Set de 5 imágenes para un producto real tuyo (o imaginario) — hero + 4 variaciones de contexto
- **C**: 5 ilustraciones de cabecera para un blog con estilo maestro compartido

Para cualquiera que elijas:

1. Define el brief en 3 líneas
2. Genera el hero (la principal, cuida el detalle)
3. Deriva las 4 variantes manteniendo consistencia
4. Agrega texto con la herramienta adecuada si aplica
5. Guárdalas con nombres claros
6. **Escribe un archivo `prompts-proyecto.md`** con los prompts que funcionaron, anota qué ajustes hiciste

**Meta**: tener en tu disco duro un set de 5 imágenes cohesivo que puedas enseñar y que salvaría una tarde de trabajo de un diseñador humano.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Un cliente te pide 10 posts para Instagram con estilo visual consistente. ¿Cuál es el workflow más eficiente?',
     to_jsonb(ARRAY[
       'Generar cada uno con un prompt completamente distinto y esperar que salgan similares',
       'Definir un "hero" con el estilo dominante, aprobarlo, y luego derivar los otros 9 con el mismo estilo (reference + pequeños cambios)',
       'Usar 10 herramientas distintas para tener variedad',
       'Hacerlos a mano en Photoshop'
     ]),
     1,
     0,
     'El patrón hero + variantes es lo que hacen las agencias. Consolidas la dirección visual en UNA imagen, la apruebas con el cliente, y las demás se derivan con consistencia. Genera cada una "desde cero" produce sets inconsistentes donde se nota que fueron generadas independientes. Inversión de tiempo: 2-3 horas vs 2 días.'),

    (v_lesson_id,
     '¿Cuál es la mejor práctica con prompts que funcionaron bien?',
     to_jsonb(ARRAY[
       'Olvidarlos después de usarlos, cada proyecto es único',
       'Guardarlos en una librería personal (prompts/foto-producto.md, prompts/mockups.md) para reusar y adaptar',
       'Pagarle a otra persona para que los escriba',
       'Nunca reutilizar el mismo prompt'
     ]),
     1,
     0,
     'Los profesionales mantienen librerías de prompts que saben que funcionan. Con el tiempo acumulás "fórmulas" probadas — tu manera de pedir retratos, productos, mockups, ilustraciones. Cada proyecto nuevo, partís de una de esas y adaptás. Ahorra horas. Es conocimiento tácito hecho explícito.'),

    (v_lesson_id,
     'Vas a usar una imagen generada para un proyecto comercial (cliente paga). ¿Qué debes revisar?',
     to_jsonb(ARRAY[
       'Nada, todas las imágenes IA son de uso libre',
       'Los términos de uso de la herramienta (algunos requieren plan pago para uso comercial), y evitar "estilo de [artista vivo]" o marcas registradas por riesgo legal',
       'Solo la resolución',
       'Que no tenga texto'
     ]),
     1,
     0,
     'Cada herramienta tiene términos distintos: Midjourney en plan Basic permite uso personal pero comercial requiere Standard+; otras requieren plan pagado para comercial; algunas reclaman cierta atribución. Además, legalmente es gris generar "estilo de artista X" si el artista está vivo, y recrear logos o packaging de marcas reales es copyright. Para trabajos que cobrás, dedica 10 min a leer los términos.');

  RAISE NOTICE 'Módulo "Imágenes con IA": 4 lecciones + 12 quizzes insertados.';

END $$;

-- ============================================
-- FILE: seeds/track-visual-02-video.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Creador Visual" / Módulo "Video con IA"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'visual';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo Video no encontrado.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- LECCIÓN 1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Panorama de video con IA',
$md$## De imagen estática a imagen que se mueve

El salto de 2024 a 2026 en video generativo es más grande que el de imágenes 2022-2024. Pasamos de clips de 4 segundos raros a videos de 60 segundos con coherencia, movimiento de cámara controlable y física creíble. Hoy, video con IA ya es producible.

### Las herramientas que importan en 2026

| Herramienta | Fuerte en | Duración máxima | Costo |
|---|---|---|---|
| **Sora 2** (OpenAI) | Realismo, coherencia temporal, física | 60s | Incluido en ChatGPT Plus/Pro |
| **Kling 2.0** | Movimiento y cámara, calidad cinematográfica | 30s | $10-50/mes o pay per use |
| **Veo 3** (Google) | Fotorrealismo + audio sincronizado | 60s | En Gemini Pro / Vertex AI |
| **Runway Gen-4** | Edición de clips, estilos artísticos | 20s | $15-95/mes |
| **Luma Dream Machine 3** | Speed, image-to-video rápido | 20s | Free tier + pago |

**Regla práctica 2026**:
- Fotorrealismo puro con diálogo → Veo 3
- Cinematográfico conceptual → Kling o Sora
- Rápido e iterativo → Luma
- Edición de video existente → Runway

### Los 3 modos de generar video

Toda herramienta moderna opera en alguno de estos modos:

**1. Text-to-video**
Escribes un prompt, sale un clip. El más libre pero menos controlable.

**2. Image-to-video**
Partes de una imagen (generada o foto real) y la animas. **Este es el modo más útil en la práctica** porque te deja controlar el look exacto.

**3. Video-to-video**
Tomas un video existente y lo transformas (cambias estilo, personajes, fondos). Útil para edición avanzada.

### ¿Qué tipo de videos salen bien hoy?

Honestamente — lo que funciona en 2026:

**Lo que sale excelente:**
- Paisajes, ambientes, naturaleza
- Productos girando, zooms suaves
- Personas con movimientos simples (caminar, sonreír, mirar cámara)
- Animación abstracta, transiciones

**Lo que sale aceptable con cuidado:**
- Diálogos cortos (lip-sync mejoró con Veo 3)
- Interacciones simples entre objetos
- Movimientos deportivos de baja complejidad

**Lo que aún falla:**
- Escenas largas con múltiples personajes interactuando
- Manos haciendo cosas complejas
- Texto que aparezca legible en movimiento
- Coherencia perfecta en clips largos (>30s)

### Casos de uso reales

Dónde video IA ya te ahorra tiempo o dinero:

- **Anuncios / reels**: producir 5 versiones de un ad sin rodaje
- **B-roll**: planos de apoyo para completar videos humanos
- **Intros / outros**: branding animado para canales de YouTube
- **Visualización de ideas**: mostrar un concepto de producto antes de prototipar
- **Contenido educativo**: animaciones para explicar conceptos
- **Prototipos de comercial**: antes de contratar productora

### El flujo económico

Contexto: un día de rodaje profesional cuesta $3-10k. Un ad generado con IA: $20-100.
Esto **no significa** que IA reemplaza rodaje para cualquier caso. Significa que:

- Para bocetos/previas antes de rodar, es imbatible.
- Para piezas sociales de bajo presupuesto, reemplaza rodaje.
- Para grandes campañas, complementa (b-roll, efectos).

### Conceptos que vas a encontrar

Vocabulario del mundo de video IA:

- **Keyframe**: imagen base desde la que se genera el movimiento
- **End frame**: algunos modelos permiten dar inicio y final, la IA rellena el movimiento entre ambos
- **Camera motion**: instrucciones de movimiento de cámara (pan, zoom, dolly)
- **Motion strength**: cuánto movimiento tiene el clip (0 = imagen quieta, alto = muy dinámico)
- **Seed**: número que determina la "semilla" de generación, mismo seed + mismo prompt ≈ resultado similar

### Tu primer test mental

Antes de intentar video, pregúntate:

> _"¿Este video lo puedo resumir en 1-2 ideas simples de movimiento?"_

Si sí, va a salir bien. Si requiere coreografía compleja o narrativa con diálogos, sube la dificultad.

En las próximas lecciones vas a aprender el arte de prompts para video, el flujo image-to-video y cómo armar clips más largos encadenándolos.$md$,
    0,
    50,
$md$**Explora y elige tu stack.** Ve a cada una de estas herramientas y mira 5-10 videos en sus feeds:

1. [Sora](https://sora.com) (o desde ChatGPT si eres Plus)
2. [Kling AI](https://klingai.com)
3. [Runway](https://runwayml.com)
4. [Luma Dream Machine](https://lumalabs.ai/dream-machine)

Para cada una anota:
- Qué tipo de videos predominan en su feed
- Cuál te impresiona más para TU caso personal/profesional
- Si tiene free tier o cuánto sale

Al final elige **1-2 herramientas** para enfocarte en este módulo. No intentes dominar las 4 a la vez.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál es el modo más práctico y controlable en video IA?',
     to_jsonb(ARRAY[
       'Text-to-video — escribes un prompt y generas',
       'Image-to-video — generas primero la imagen exacta que quieres, luego la animas',
       'Video-to-video — transformas videos existentes',
       'Ninguno, todos son iguales'
     ]),
     1,
     0,
     'Image-to-video te da control total sobre el look final: primero generás la imagen perfecta (donde tenés 100% de control visual), y solo después le pedís a la IA que la anime. Text-to-video es más creativo pero menos predecible — muchas veces el resultado visual no coincide con lo que tenías en la cabeza. En flujos profesionales, image-to-video gana casi siempre.'),

    (v_lesson_id,
     'Te piden un video de una persona interactuando con otra mientras hablan durante 45 segundos con diálogo específico. ¿Va a salir bien en 2026?',
     to_jsonb(ARRAY[
       'Sí, fácil',
       'Difícil — múltiples personas interactuando con diálogo largo y coherente sigue fallando, mejor hacer clips cortos y editarlos, o combinar con rodaje real',
       'No se puede hacer nada con IA',
       'Depende solo del presupuesto'
     ]),
     1,
     0,
     'La honestidad ayuda. Paisajes, productos, acciones simples y diálogos cortos salen bien. Pero múltiples personajes interactuando con diálogo específico por 45 segundos aún falla en 2026 — inconsistencias, labios no sincronizados, momentos raros. El workaround: hacer varios clips cortos con pausas, editarlos, o combinar IA con rodaje real. Lo que nunca funciona es generar un clip único largo y esperar que todo salga bien.'),

    (v_lesson_id,
     'Para producir 5 versiones de un anuncio corto (15 segundos) sin rodaje costoso, ¿cuánto cuesta hoy con IA?',
     to_jsonb(ARRAY[
       'Miles de dólares',
       'Típicamente entre $20-100 total usando herramientas pay-per-use como Sora o Kling',
       'Gratis, no tiene costo',
       'Solo funciona si tenés equipo profesional'
     ]),
     1,
     0,
     'Un día de rodaje profesional cuesta $3-10k. Generar 5 versiones de 15 segundos con IA hoy: entre $20-100 dependiendo de la herramienta y del número de iteraciones. Esto no mata el rodaje profesional para proyectos grandes, pero democratizó el contenido de marketing para pequeños negocios, creadores y tests rápidos. Un emprendedor puede testear 10 variantes de un ad antes de invertir en el rodaje final.');


  -- LECCIÓN 2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Prompting para video',
$md$## Prompting para video: sujeto + movimiento + cámara

Igual que en imágenes, un prompt de video tiene estructura. La diferencia: ahora hay un eje extra que es el **tiempo / movimiento**.

### Fórmula: 5 capas

1. **Sujeto**: qué o quién aparece (igual que imagen)
2. **Ambiente**: dónde, cuándo, mood
3. **Estilo visual**: cinematográfico, documental, animación, etc.
4. **Movimiento del sujeto**: qué hace a lo largo del clip
5. **Movimiento de cámara**: cómo se mueve la cámara

Este último es el más subestimado. Un prompt sin camera motion te da resultados dependientes del azar; con camera motion, tienes control.

### Ejemplo deconstruido

Prompt para Kling/Sora:

> **Un monje tibetano joven** caminando en cámara lenta por **un pasillo de monasterio con luz dorada filtrada**, **estilo cinematográfico con grano sutil**, **camina mirando ligeramente al suelo mientras las túnicas ondean**, **cámara lateral haciendo dolly tracking al mismo ritmo**

Desglosado:

| Capa | Texto |
|---|---|
| Sujeto | Monje tibetano joven |
| Ambiente | Pasillo monasterio, luz dorada filtrada |
| Estilo | Cinematográfico, grano sutil |
| Movimiento sujeto | Camina lento, mirando al suelo, túnicas ondean |
| Cámara | Dolly tracking lateral al ritmo del sujeto |

### Vocabulario de cámara (oro puro)

Aprender términos de cinematografía multiplica tu control:

| Término | Qué hace |
|---|---|
| **Dolly in/out** | Cámara se acerca/aleja del sujeto |
| **Pan left/right** | Cámara gira horizontalmente en un eje |
| **Tilt up/down** | Cámara gira vertical (mira arriba o abajo) |
| **Tracking shot** | Cámara se mueve junto al sujeto (lateral o siguiendo) |
| **Handheld** | Cámara en mano, ligeros movimientos naturales |
| **Static** | Cámara fija, solo el sujeto se mueve |
| **Crane / aerial** | Vista desde arriba, vuelo |
| **Orbit** | Cámara rodea al sujeto |
| **Push in** | Entrada lenta hacia el sujeto (dramático) |

Decirle a la IA "push in slowly while the subject speaks" te da un resultado predecible y cinematográfico.

### Vocabulario de movimiento de sujeto

Sé específico con cómo se mueve:

- Velocidad: _slowly, casually, rapidly, in slow motion_
- Dirección: _toward the camera, away, side to side_
- Estilo: _with a confident stride, hesitantly, gracefully_

### Ejemplo de un ajuste fino

**Prompt v1** (vago):
> _"Una mujer bebiendo café"_

Resultado: genérico, movimiento raro.

**Prompt v2** (mejorado):
> _"Una mujer de 30 años sentada en un café con luz de ventana lateral, toma su taza con ambas manos, sopla suavemente el café y bebe un sorbo pequeño, cámara estática en un plano medio, estilo documental cálido"_

Resultado: específico, creíble, usable.

### Duración y ritmo

Las herramientas típicamente generan 4-10 segundos por clip. Para videos más largos, la técnica es **encadenar clips**:

- Genera el clip A (personaje llega)
- Genera el clip B con mismo look (personaje hace X)
- Genera el clip C (personaje se va)
- En editor de video (CapCut, Premiere, o incluso iMovie), concatena

Importante: para consistencia entre clips usa la misma referencia de imagen o el mismo seed.

### Negative prompts en video

Similar a imagen, algunas herramientas aceptan negativos. Útiles:

- `jittery, shaky, low quality` → evitar tembleque
- `extra limbs, distorted` → evitar humanos raros
- `text, watermark` → evitar textos no deseados

### El truco del end frame

Algunas herramientas (Kling, Runway) te permiten:

- Dar **imagen inicial**
- Dar **imagen final**
- La IA genera el movimiento interpolado entre ambas

Esto es oro para transiciones específicas. Ejemplo: _logo cerrado → logo abierto_ en 3 segundos. Controlás los dos extremos; la IA solo hace el puente.

### Dos trampas comunes

**1. Pedir demasiado en un solo clip**
> _"Una mujer camina por el parque, se encuentra con una amiga, se abrazan, se sientan a tomar café y conversan"_

→ en 8 segundos la IA va a atropellar todo. Divide: 3 clips separados.

**2. Movimientos que violan física básica**
> _"El vaso se llena de vino solo y luego flota hacia la persona"_

→ la IA va a patinar. Si quieres efectos imposibles, herramientas como Runway con máscaras manuales te dan más control.

### Cuando el clip no sale bien

Antes de regenerar 30 veces:

1. **¿Fue el prompt ambiguo?** Probablemente sí. Añade detalles.
2. **¿Había movimientos contradictorios?** "Cámara fija pero con pan" confunde.
3. **¿Pediste algo físicamente raro?** Replantea.
4. **¿La imagen base era buena?** Si usas image-to-video, imagen mala = video malo.

Iterar inteligente > generar compulsivamente.$md$,
    1,
    60,
$md$**Prompt lab: 3 tomas de una mini-historia.**

Piensa una micro-historia de 3 tomas (ej. alguien llega a casa, se sienta, mira por la ventana). Para cada toma:

1. Escribe prompt completo con las 5 capas (sujeto, ambiente, estilo, movimiento sujeto, cámara)
2. Genera el clip en tu herramienta preferida (Sora, Kling, Luma)
3. Evalúa: ¿qué salió bien, qué salió mal?
4. Itera 1-2 veces ajustando solo la capa que falló

**Bonus**: concatena las 3 tomas en CapCut o iMovie. Agrega música de fondo libre de derechos.

**Meta**: terminar con un mini-clip de 15-30 segundos que cuente algo y donde entiendas cómo cada capa del prompt se tradujo en el resultado.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuál es la quinta capa que se suma al prompting de video vs imagen?',
     to_jsonb(ARRAY[
       'Resolución',
       'Movimiento de cámara',
       'Duración en minutos',
       'Idioma del prompt'
     ]),
     1,
     0,
     'Video introduce el eje del tiempo, y la cámara puede moverse. Decir "dolly in slowly" o "handheld tracking shot" te da resultados cinematográficos predecibles. Si no especificás, la IA toma decisiones que muchas veces no son las que querías. Aprender vocabulario de cinematografía es una inversión pequeña con retorno enorme.'),

    (v_lesson_id,
     'Tu prompt pide "una persona caminando por un parque, se encuentra con amiga, se abrazan, se sientan a conversar" en 8 segundos. ¿Qué pasa?',
     to_jsonb(ARRAY[
       'La IA lo hace perfectamente',
       'Intenta meter todo en 8 segundos y el resultado atropella todas las acciones — mejor dividir en 3 clips separados',
       'Solo funciona en Sora',
       'La IA rechaza el prompt'
     ]),
     1,
     0,
     'Error clásico. Un clip de IA funciona bien con UNA o DOS acciones claras, no con una cadena narrativa completa. Para historias más complejas: divide en clips separados, cada uno con un momento específico, luego edítalos juntos. Esto además te da más control — si un clip sale mal, regenerás solo ese.'),

    (v_lesson_id,
     'Quieres un clip donde el logo cerrado se abre al logo final en 3 segundos. ¿Qué herramienta/feature aprovechas?',
     to_jsonb(ARRAY[
       'Prompt largo explicando la transición',
       'End frame / first-and-last frame: das imagen inicial + imagen final, la IA interpola el movimiento',
       'Regenerar muchas veces hasta que salga',
       'No se puede con IA'
     ]),
     1,
     0,
     'First/last frame (también llamado end frame o two-image) es la feature perfecta para transiciones específicas. Das la imagen donde arranca y donde termina, y la IA se encarga del movimiento intermedio. Funciona excelente para logos, transformaciones, intros. Las herramientas principales que lo tienen: Kling, Runway y en ciertos flujos Sora.');


  -- LECCIÓN 3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Image-to-video y consistencia',
$md$## El flujo profesional de verdad

Los pros rara vez hacen text-to-video puro. El workflow que usan es **image-to-video**: generar la imagen estática perfecta primero, y solo después animarla. Esta lección es la receta completa.

### Por qué image-to-video gana casi siempre

Con text-to-video, el modelo tiene que resolver **dos problemas a la vez**:

1. Cómo se ve el frame de arranque (composición, estilo, personaje)
2. Cómo se mueve todo a lo largo del clip

Si una de las dos sale mal, el clip no sirve. Y normalmente hay que generar 10 veces hasta que las dos salen bien.

Con image-to-video **desacoplás los problemas**:

1. Generás la imagen estática hasta que está perfecta (15 min)
2. La animás (2 min)
3. Si el movimiento falla, reintentás solo el movimiento

El resultado final se parece mucho más a lo que tenías en la cabeza.

### Flujo paso a paso

**Paso 1: Genera la imagen base**
Usa Midjourney, Flux, Nano Banana o la que prefieras. Piensa en el frame como una foto del momento más importante del clip.

Ejemplo: para un ad de café, genera una foto donde el barista termina el latte art. Ese es tu frame clave.

**Paso 2: Pásala a tu herramienta de video**
Sora, Kling, Luma aceptan imagen como punto de partida.

**Paso 3: Prompt del movimiento**
Ahora describí solo el movimiento — no tienes que describir la escena porque ya está en la imagen:

> _"Camera slowly dollies in while the barista finishes the latte art, steam rises from the cup, subtle handheld feel"_

Corto y enfocado en movimiento.

**Paso 4: Genera y revisa**
Si no convence, ajusta solo el prompt de movimiento. No regeneres la imagen base — esa ya te gustó.

### Consistencia a través de clips

Para un video con varios clips donde aparezca la misma persona, producto o ambiente:

**Opción A: Character reference + image-to-video**
1. Genera una imagen del personaje con MJ usando `--cref` de la base
2. Usa esa imagen como punto de partida para el clip
3. Para el clip 2, genera otra imagen del personaje (MJ --cref de nuevo)
4. Cada clip tiene personaje consistente porque todas las imágenes base lo son

**Opción B: Extend video**
Algunas herramientas (Kling, Runway) permiten "extender" un clip: tomar el último frame y generar otro clip que sigue desde ahí. Útil para continuidad pura (siguiente movimiento) pero no para saltos de escena.

### Lip sync y diálogo (Veo 3)

Si necesitas un personaje hablando con audio sincronizado, Veo 3 es tu herramienta. Workflow:

1. Genera/prepara la imagen del personaje
2. Graba o escribe el diálogo
3. Veo 3 anima el personaje con lip sync

Calidad: buena para diálogos cortos y planos cerrados. Para larga duración aún es un reto.

### Efectos visuales simples con IA

Cosas que antes requerían after-effects y hoy son prompts:

- **Cambio de look / grading**: "apply a Blade Runner 2049 grade to this clip"
- **Estilización**: "turn this real video into stylized 3D animation"
- **Remove objects**: "remove the car from the street, keep everything else" (Runway lo hace bien)
- **Add objects**: "add a flock of birds flying across the sky"

Runway tiene las mejores herramientas de edición IA hoy.

### El problema del audio

La mayoría de herramientas generan **video mudo** — te toca añadir audio en post:

- **Música**: libraries de libre derechos (YouTube Audio Library, Epidemic Sound, Artlist)
- **Voz**: ElevenLabs, Resemble AI, OpenAI TTS
- **Sonido ambiente**: Freesound, librerías gratuitas

Veo 3 es excepción — genera audio ambiente coherente con la imagen y también voz. Es el primer modelo donde el audio no es un after-thought.

### Workflow completo: video promocional de 30 segundos

Caso real: hacer un promo de 30s para un producto.

1. **Storyboard** (5 min): 6 frames clave, uno cada 5s
2. **Genera 6 imágenes hero** en MJ/Flux (30 min) — una por frame
3. **Image-to-video de cada una** (20 min) — 6 clips de 5s
4. **Música y voz** (20 min) — busca música + genera voz en ElevenLabs
5. **Edita en CapCut o Premiere** (30 min) — concatena, añade transiciones, sincroniza
6. **Exporta**

Total: ~2 horas. Un rodaje equivalente: días y $1-5k.

### Herramientas de edición complementarias

No uses solo herramientas IA — la edición clásica sigue siendo clave:

- **CapCut** — gratis, increíble para redes sociales, tiene features IA integradas
- **Premiere Pro** — profesional, curva empinada
- **DaVinci Resolve** — gratis, muy potente, mejor grading del mercado
- **Descript** — edita video como si fuera texto, genial para podcasts/YouTube

Un workflow realista combina IA (generación) + editor clásico (estructura, cortes, audio).

### Tips finales

- **Empieza corto**: clips de 4-5 segundos salen mejor que de 15
- **Planos cerrados > abiertos**: menos área para que falle
- **Movimientos simples > complejos**: una acción clara por clip
- **Consistencia > perfección**: que todos los clips se vean "del mismo mundo"
- **Música cubre multitud de pecados**: imperfecciones de video se perdonan con buena música$md$,
    2,
    70,
$md$**Flujo image-to-video end-to-end.**

1. Piensa un clip tipo anuncio corto (10-15 segundos) de un producto o concepto tuyo
2. **Genera la imagen clave** (frame principal) en Midjourney o Flux hasta que te guste
3. **Anima esa imagen** en Sora/Kling/Luma con un prompt de movimiento claro (solo movimiento, no describas la escena de nuevo)
4. Agrega **música libre de derechos** en CapCut
5. Si aplica, **genera una voz** en ElevenLabs (free tier alcanza) y sincronízala

**Bonus**: genera una segunda imagen "final frame" y usa end frame feature en Kling para una transición.

**Meta**: terminar con un clip final de 10-15s exportado con audio, que sientas que podrías mostrarle a un cliente.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Por qué image-to-video es más predecible que text-to-video?',
     to_jsonb(ARRAY[
       'Porque es gratis',
       'Porque desacoplás la generación del look (en la imagen) de la generación del movimiento (en el video), pudiendo iterar cada paso por separado',
       'Porque las herramientas son mejores',
       'Porque el resultado es más rápido'
     ]),
     1,
     0,
     'En text-to-video la IA resuelve dos problemas simultáneos: composición visual y movimiento. Si uno falla, el clip entero no sirve. En image-to-video primero consolidás la imagen (una iteración), y después solo peleás con el movimiento (otra iteración). Cada paso es controlable. Los profesionales casi siempre trabajan así porque el resultado se parece mucho más a la idea original.'),

    (v_lesson_id,
     'Para un promo de 30 segundos con 6 tomas distintas del mismo personaje, ¿qué haces para mantener consistencia?',
     to_jsonb(ARRAY[
       'Generar un solo clip de 30 segundos',
       'Generar 6 imágenes del personaje usando character reference (--cref o equivalente), y hacer image-to-video de cada una',
       'Hacer rodaje real',
       'No es posible, el personaje siempre va a cambiar'
     ]),
     1,
     0,
     'Clips largos (30s) suelen inventar cosas y perder consistencia. El patrón que funciona: 6 imágenes consistentes usando character reference de una imagen base, luego animar cada una individualmente (5s x 6 = 30s), y editarlas juntas. Como las 6 imágenes base ya son consistentes, los 6 clips mantienen al mismo personaje.'),

    (v_lesson_id,
     'Necesitas un clip con un personaje hablando y diciendo una frase específica con lip sync. ¿Qué herramienta usas en 2026?',
     to_jsonb(ARRAY[
       'Cualquier modelo antiguo, todos lo hacen bien',
       'Veo 3 de Google — es el mejor modelo hoy para lip sync con audio sincronizado',
       'Solo se puede con rodaje real',
       'Midjourney'
     ]),
     1,
     0,
     'Veo 3 (lanzado en 2025-2026) es el primer modelo que hace lip sync aceptable sincronizado con audio generado. Para diálogos cortos en planos cerrados funciona bien. Los otros modelos (Sora, Kling, Luma) están enfocados más en movimiento visual que en diálogo sincronizado. Midjourney hace solo imágenes estáticas. Para lip sync largo y perfecto todavía rodaje real es más confiable.');


  -- LECCIÓN 4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Proyecto: anuncio IA de principio a fin',
$md$## Del prompt al ad publicado

Esta lección es un proyecto guiado. Al final tienes un anuncio de 20-30 segundos que podrías publicar.

### El brief

Imagina que tienes un producto (real o ficticio): un curso, una app, un servicio, un producto físico. Tu objetivo: **un video vertical (9:16) de 20-30 segundos** para Instagram Reels o TikTok, que muestre el producto y cierre con un call-to-action.

### Estructura narrativa clásica (AIDA)

Un ad que funciona sigue esta estructura:

1. **Atención** (0-3s): hook visual o pregunta
2. **Interés** (3-10s): muestra el problema o beneficio
3. **Deseo** (10-20s): muestra la solución funcionando
4. **Acción** (20-30s): CTA claro ("visita...", "registrate", etc.)

Mapea tu brief a esa estructura antes de generar nada.

### Storyboard

Un storyboard es el plan visual del video: qué ve el espectador cada pocos segundos. No necesita ser un dibujo — puede ser texto + referencias.

Template simple:

| Toma | Tiempo | Qué se ve | Cámara | Prompt imagen |
|---|---|---|---|---|
| 1 | 0-4s | Hook visual: persona frustrada con problema | Plano medio, handheld | [a completar] |
| 2 | 4-10s | Presenta el producto | Close-up producto | [a completar] |
| 3 | 10-18s | Persona usando producto, feliz | Plano medio, dolly in | [a completar] |
| 4 | 18-24s | Resultado del producto | Detalle, slow mo | [a completar] |
| 5 | 24-30s | Logo + CTA | Static, logo centrado | [a completar] |

Completa esa tabla antes de abrir cualquier herramienta IA.

### Fase de producción

**1. Genera las imágenes clave (1 hora)**
Para cada toma, genera la imagen base en MJ/Flux/Nano Banana. Mantén estilo visual consistente entre todas (misma paleta, luz, tono). Si una persona aparece en varias, usa character reference.

**2. Image-to-video (30 min)**
Para cada imagen, pásala a Sora/Kling/Luma con un prompt de movimiento. Objetivo: clips de 4-7 segundos cada uno que, sumados, den 20-30 totales.

**3. Audio**
Tres capas de audio:

- **Música**: elige una que marque el mood. YouTube Audio Library o Epidemic Sound.
- **Voz (si aplica)**: usa ElevenLabs para generar voz. Mantén el texto breve y enfocado al CTA.
- **Sonido ambiente**: opcional, pero añade realismo en los clips.

**4. Editar (1 hora)**
En CapCut, DaVinci o Premiere:
- Concatena los clips en orden
- Añade transiciones suaves (cortes directos suelen funcionar mejor que fades)
- Sincroniza con música (cortes en los beats marca diferencia)
- Superpón voz si aplica
- Añade texto final con el CTA (Canva/CapCut tienen opciones de texto animado)

**5. Exporta vertical 1080×1920, 9:16**

### Ejemplo real deconstruido

Producto: curso de fotografía móvil. Video 25s.

| Toma | Contenido | Prompt |
|---|---|---|
| 1 (4s) | Persona con celular frustrada por foto mala | _"Young woman looking disappointed at her phone screen, soft window light, handheld close-up, subtle zoom in"_ |
| 2 (5s) | Transición: celular mostrando contenido del curso | _"Phone screen close-up showing photo editing interface, clean minimal background, light push in"_ |
| 3 (8s) | Misma persona ahora segura, disparando fotos | _"Same woman holding phone, now smiling confidently taking photos in a park, golden hour, dolly tracking"_ |
| 4 (5s) | Resultados: fotos hermosas montadas | _"Beautiful phone photos displayed in a grid, clean layout, subtle slide transitions"_ |
| 5 (3s) | Logo + CTA "Aprende en 7 días" | Imagen con logo + texto, estática |

Música: upbeat motivacional. Voz: opcional con el CTA final.

### Errores comunes en proyectos reales

- **Demasiadas tomas**: 5-7 es el sweet spot. Más se vuelve confuso en 30s.
- **Estilo inconsistente entre clips**: si el clip 1 es cinematográfico y el 2 es animación, se siente mal. Define una dirección y mantenela.
- **CTA débil o tarde**: el CTA tiene que ser claro y estar al final con peso visual.
- **Música muy larga sin cortes**: corta en los beats, añade movimiento a la edición.
- **Texto con errores**: siempre revisa textos antes de exportar.

### Cuándo NO intentar esto solo con IA

Honestidad: hay casos donde IA sola no alcanza:

- Testimonios de clientes reales (necesitas persona real hablando)
- Demostraciones de producto físico de forma específica (mejor grabar)
- Campañas premium para marcas grandes (esperan calidad humana + presencia real)

En esos casos, IA complementa: b-roll, intros, cierres de marca, animaciones. No reemplaza todo.

### Tu plan de 90 días

Si querés volverte bueno en video IA:

- **Mes 1**: 5 proyectos completos de 20-30s cada uno
- **Mes 2**: domina 1 herramienta a fondo (Sora o Kling), experimenta con edición pro
- **Mes 3**: ofrece servicio a un cliente real (puede ser un freelance barato para practicar)

Al día 90, tenés portafolio + experiencia + un servicio que podés cobrar.

### Recap del track

Terminaste "Imágenes + Video con IA". Lo que sabes:

- Qué herramienta elegir según el caso
- Prompting en profundidad (5-6 capas)
- Consistencia de personaje y edición quirúrgica
- Workflow profesional image-to-video
- Producción completa de un ad

Próximo módulo del track: **Branding Pro** — logo, paleta, identidad completa con IA. Es aplicar todo esto a un sistema visual coherente.$md$,
    3,
    70,
$md$**Proyecto final: tu ad de 20-30s.**

Elige un producto/servicio/idea y produce un ad completo:

1. Escribe el brief en 5 líneas
2. Crea el storyboard con 5-7 tomas (tabla: toma, tiempo, contenido, cámara)
3. Genera imágenes base para cada toma (estilo consistente)
4. Image-to-video de cada una
5. Agrega música + voz + CTA
6. Edita en CapCut/DaVinci
7. Exporta vertical 1080×1920

**Bonus**: postealo en tu feed personal o mándaselo a un amigo diciendo "lo hice con IA en 3 horas, ¿notás la diferencia?"

**Meta**: terminar con un video que podrías mostrar a un cliente real o postear en tu feed.$md$,
    20
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'En una estructura AIDA para un ad de 30 segundos, ¿cuánto tiempo le das al hook (Atención)?',
     to_jsonb(ARRAY[
       '0 segundos, va directo al mensaje',
       'Los primeros 3 segundos son críticos — si no enganchas ahí, el espectador hace scroll en Reels/TikTok',
       'La mitad del video',
       'Solo el final'
     ]),
     1,
     0,
     'En formatos de scroll vertical (Reels, TikTok, Shorts) los primeros 3 segundos deciden si el espectador se queda o pasa. Por eso la "A" de AIDA (Atención) es el arranque y es crítica. Un hook potente visual, una pregunta provocadora o un movimiento inesperado. Si lo primero es lento o genérico, el resto del ad no importa — nadie lo ve.'),

    (v_lesson_id,
     '¿Qué es un storyboard y por qué hacerlo ANTES de generar videos?',
     to_jsonb(ARRAY[
       'Un dibujo opcional, no sirve mucho',
       'El plan visual del video (qué se ve, cuándo, con qué cámara). Hacerlo antes evita perder tiempo generando tomas que no suman a la narrativa',
       'Es solo para proyectos grandes',
       'Solo lo hacen los directores de cine'
     ]),
     1,
     0,
     'Sin storyboard vas generando al azar, a ver qué sale. Resultado: 20 clips bonitos que no cuentan nada. Con storyboard primero definís la narrativa (qué se ve cuándo y con qué cámara) y después producís exactamente eso. Ahorra tiempo y plata (cada generación IA cuesta). El storyboard puede ser simple — una tabla de texto alcanza, no necesitás dibujar.'),

    (v_lesson_id,
     'Tu ad IA queda decente pero no "brillante". ¿Qué suele marcar la diferencia entre decente y brillante?',
     to_jsonb(ARRAY[
       'Solo herramientas más caras',
       'Música bien elegida con cortes en los beats + edición (transiciones, ritmo, CTA claro) — la generación IA es 60%, el post-production es el 40% que separa decente de brillante',
       'Mayor resolución',
       'Usar Photoshop'
     ]),
     1,
     0,
     'La generación IA te da material crudo. Lo que lo convierte en un ad que la gente mira es: (1) música elegida con intención + cortes sincronizados con beats, (2) transiciones bien diseñadas, (3) ritmo general (no todo al mismo pulso), (4) un CTA claro y con peso visual. Dedica 1/3 del tiempo total del proyecto al post-production. Es donde todo se decide.');

  RAISE NOTICE 'Módulo "Video con IA": 4 lecciones + 12 quizzes insertados.';

END $$;

-- ============================================
-- FILE: seeds/track-visual-03-branding.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Creador Visual" / Módulo "Branding Pro"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'visual';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'Módulo Branding no encontrado.';
  END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- LECCIÓN 1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Estrategia de marca antes de generar',
$md$## Generar un logo no es tener una marca

Puedes tener 50 logos bonitos generados en Ideogram en 10 minutos. Pero sin una estrategia detrás, ninguno te va a servir. El logo, la paleta y la tipografía son **la punta del iceberg** — debajo hay decisiones estratégicas que deciden si la marca funciona o se olvida.

Esta lección es lo que haces **antes de abrir cualquier herramienta IA**.

### Los 4 pilares de marca (simples)

Responde estas 4 preguntas antes de generar nada:

**1. ¿Para quién es?**
Describe a tu cliente ideal en 3 líneas. Edad, qué le importa, qué le frustra, qué valora.

*Ejemplo*: "Mujeres 30-45, profesionales, con tiempo limitado, que valoran calidad por encima de precio y decoran su casa con intención."

**2. ¿Qué les ofrecés?**
Una frase que diga qué hacés y por qué importa.

*Ejemplo*: "Cursos online cortos (30 min) para aprender una habilidad concreta cada semana, pensados para gente ocupada."

**3. ¿Qué te diferencia?**
¿Por qué elegirte a vos y no al siguiente?

*Ejemplo*: "Mientras otros cursos duran meses, nosotros entregamos resultado en 7 días con una micro-habilidad por curso."

**4. ¿Qué sentir querés generar?**
3 palabras que describan el feeling de la marca.

*Ejemplo*: "moderno, cálido, enfocado"

Todas las decisiones visuales derivan de esas 4 respuestas. Sin ellas, lo visual es arbitrario.

### Arquetipo de marca

Una forma útil de pensar el tono: ¿con qué personalidad habla tu marca? Jungian archetypes son 12 arquetipos universales. Los más usados:

| Arquetipo | Ejemplos de marcas | Feel |
|---|---|---|
| **The Hero** | Nike, Adidas | Fuerza, conquista, superación |
| **The Sage** | Google, Harvard | Sabiduría, verdad, conocimiento |
| **The Creator** | Apple, Lego | Innovación, imaginación |
| **The Caregiver** | Johnson & Johnson | Cuidado, protección |
| **The Explorer** | Jeep, Patagonia | Aventura, libertad |
| **The Lover** | Chanel, Gaggia | Pasión, intimidad, elegancia |
| **The Jester** | Old Spice, Netflix | Diversión, humor |
| **The Ruler** | Rolex, Mercedes | Autoridad, élite |
| **The Magician** | Disney, Tesla | Transformación, visión |
| **The Outlaw** | Harley-Davidson | Rebeldía, desafío |
| **The Regular** | IKEA, Walmart | Pertenencia, cotidiano |
| **The Innocent** | Coca-Cola, Dove | Simplicidad, pureza |

Elegí 1, máximo 2. Eso informa el tono de todas las piezas.

### Spectrum visuales: decide antes

Antes de generar, define en qué lado del espectro estás para cada dimensión:

| Dimensión | Opción A | Opción B |
|---|---|---|
| Personalidad | Seria / profesional | Divertida / casual |
| Feel | Minimalista | Rica en detalle |
| Color | Monocromático | Multicolor |
| Forma | Geométrica / rígida | Orgánica / fluida |
| Tipografía | Moderna / sans serif | Clásica / serif o scripted |
| Tono | Frío (azules, grises) | Cálido (naranjas, tierras) |

Una marca minimalista con pastel cálido y scripted es MUY distinta a una maximalista geométrica monocromática. Decidir el espectro antes te ahorra generar 50 opciones y no saber cuál elegir.

### Moodboard: el paso crítico

Un moodboard es una colección visual de referencias que capturan el mood que buscás. Se hace **antes** de generar nada tuyo.

Pasos:

1. Abrí Pinterest o similar
2. Buscá por tus palabras clave ("minimalist wellness brand", "cozy coffee brand", etc.)
3. Guardá 20-30 imágenes que sientas tu marca
4. Observá patrones: ¿qué se repite? ¿Colores? ¿Tipo de imagen? ¿Estilo de foto?
5. Resumí en 5 bullets: "la marca se siente como X, Y, Z"

Si tenés acceso, pasá esas imágenes a Claude como referencia cuando escribas prompts. El moodboard es tu "norte" visual.

### Naming: el gran olvidado

El nombre importa tanto como el logo. Dos reglas simples:

- **Fácil de escribir y pronunciar** (en los idiomas de tu audiencia)
- **Dominio disponible** (.com o al menos el .co/.io del país)

Usa [Namelix](https://namelix.com), ChatGPT o Claude para generar nombres:

> _"Dame 20 nombres cortos para una marca de cursos online. Tono: moderno, cálido, enfocado. Debe funcionar en español e inglés. Prioritá nombres con dominios .com disponibles o nombres inventados pronunciables."_

Después, **verificá disponibilidad**: dominio, Instagram, TikTok, LinkedIn. Si tres de cuatro están ocupados, descarta.

### Legal básico

Antes de lanzar:

- **Registro de marca**: para negocios serios, consultá registro en el país donde operás (hay búsquedas gratis de marcas ya registradas)
- **Uso comercial de imágenes IA**: verificá términos de la herramienta donde generaste (algunas permiten comercial solo con plan pago)
- **Evita imitar marcas existentes**: por estética o por nombre, si te pareces demasiado es problema legal

### Lo que viene

Con estrategia definida — audiencia, oferta, arquetipo, espectro, moodboard, nombre — ahora sí podés generar. En la siguiente lección: **logo y sistema visual**.$md$,
    0,
    50,
$md$**Define tu estrategia de marca.**

Elige una marca (real tuya, idea que tengas, o inventada para practicar). Escribe en un doc:

1. **Para quién es** (3 líneas)
2. **Qué ofrecés** (1 línea)
3. **Qué te diferencia** (1 línea)
4. **3 palabras que definen el feeling**
5. **Arquetipo principal** (y secundario si aplica)
6. **Espectros visuales** (rellena la tabla: personalidad, feel, color, forma, tipo, tono)
7. **Moodboard** de 15-20 imágenes en Pinterest/board — screenshot o URL
8. **Nombre definitivo** (verificado: dominio + 2 redes disponibles)

**Meta**: tener un brief de 1 página que podrías pasarle a un estudio de diseño y entenderían exactamente qué buscás.$md$,
    10
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué es un arquetipo de marca y para qué sirve?',
     to_jsonb(ARRAY[
       'Un tipo de logo',
       'Una personalidad narrativa que define el tono de comunicación (Hero, Sage, Creator, etc.) — guía todas las decisiones visuales y de copy',
       'Un formato de archivo',
       'Solo sirve para marcas grandes'
     ]),
     1,
     0,
     'Los 12 arquetipos jungianos son personalidades universales que se repiten en marcas y narrativas. Nike es Hero (superación), Apple es Creator (innovación), Harley es Outlaw (rebeldía). Elegir uno te da un ancla de tono: "si fuéramos Hero, ¿qué diríamos?". Evita que cada post/pieza se sienta distinto. Marcas fuertes son coherentes porque tienen un arquetipo claro detrás.'),

    (v_lesson_id,
     'Antes de generar tu logo con IA, ¿qué deberías tener listo?',
     to_jsonb(ARRAY[
       'Solo una idea general en la cabeza',
       'Estrategia escrita: audiencia, oferta, diferencial, feel en 3 palabras, arquetipo, espectros visuales, moodboard',
       'Un presupuesto alto',
       'Un estudio de diseño contratado'
     ]),
     1,
     0,
     'Generar sin estrategia es generar al azar. Podés ver 50 logos bonitos y no saber cuál elegir porque no tenés un criterio. Tener la estrategia definida ANTES te deja evaluar cada opción contra tu brief: "este logo comunica el feel correcto? ¿encaja con mi arquetipo?". Es la diferencia entre generar arte random y diseñar con intención.'),

    (v_lesson_id,
     'Al elegir el nombre de tu marca, ¿qué debés verificar además de que "suene bien"?',
     to_jsonb(ARRAY[
       'Nada más, si suena bien alcanza',
       'Disponibilidad de dominio (.com o de tu país) + al menos 2 redes sociales, y que sea fácil de escribir/pronunciar en los idiomas de tu audiencia',
       'Que sea muy largo para destacar',
       'Que empiece con A para aparecer primero'
     ]),
     1,
     0,
     'Un nombre bonito con dominio ocupado es un problema. Después del primer cliente, ya es tarde para cambiar. Antes de enamorarte: verificá dominio (NameCheap, Namecheap, Google Domains), 2-3 redes (Instagram, TikTok, LinkedIn, X), y probá pronunciarlo en voz alta en los idiomas donde vas a operar. Nombres que se confunden al escribirlos ("¿va con S o con Z?") también pierden tráfico directo.');


  -- LECCIÓN 2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Logo y sistema visual',
$md$## De la idea al logo que usarás por años

Con la estrategia lista, ahora sí generamos. Pero no generamos "un logo" — generamos **un sistema visual completo**.

### ¿Qué compone un sistema de marca?

Un sistema mínimo tiene:

1. **Logo principal** — tu símbolo + wordmark (nombre) juntos
2. **Logo simplificado** — versión chica para avatar/favicon (ej. solo el símbolo)
3. **Paleta de color** — primario + secundarios + neutros
4. **Tipografía** — título + cuerpo (idealmente 2 familias de fuentes)
5. **Elementos gráficos** — patrones, texturas, íconos, ilustraciones que acompañan
6. **Fotografía** — estilo de imágenes que usas (lifestyle, producto, etc.)

Todo tiene que sentirse de la misma familia.

### Tipos de logo

Antes de generar, decide qué tipo tener:

| Tipo | Ejemplo | Pros | Cons |
|---|---|---|---|
| **Wordmark** (solo texto) | Google, Coca-Cola | Legible, directo | Depende de la tipografía |
| **Lettermark** (sigla) | IBM, CNN | Compacto | Poco memorable para marcas nuevas |
| **Pictorial** (símbolo reconocible) | Apple, Twitter | Icónico cuando maduro | Requiere fuerza de marca |
| **Abstract** (forma abstracta) | Nike, Airbnb | Flexible, moderno | Inicialmente requiere contexto |
| **Combination** (símbolo + texto) | Burger King, Adidas | Versátil | Más elementos a diseñar |
| **Emblem** (forma con texto dentro) | Starbucks, Harley | Clásico, autoritativo | Difícil de escalar pequeño |

Para negocios nuevos, **Combination** (símbolo + texto) suele ser la mejor apuesta: versátil, memorable, flexible entre aplicaciones.

### Generando con IA: el prompt correcto

Con Ideogram, GPT Image o Midjourney:

> _"Minimalist logo for [nombre], [combination style: abstract symbol + wordmark below], [arquetipo como tone], color palette [2-3 colores], simple geometric shapes, vector style, centered on white background, no text distortion"_

Ejemplo concreto:

> _"Minimalist logo for 'Lumi', combination style with abstract symbol + wordmark 'Lumi' below, Creator archetype, warm palette: soft yellow #F5C16C + navy #2A3A52 + cream #F5EFE2, geometric shapes inspired by soft rays of light, vector style, centered, white background"_

**Ideogram** hace texto mejor. **GPT Image** también. Midjourney falla en texto legible pero da mejor "feel" estético.

### Generar 20, elegir 3, refinar 1

Workflow:

1. **Genera 20 opciones** variando prompt (cambiando solo 1 elemento cada vez)
2. **Elige 3** que resuenen más con tu brief
3. **Refiná 1** con edición (Nano Banana o en Figma a mano)

No te enamores del primero. La tercera iteración casi siempre es mejor.

### Refinar en Figma

Casi ningún logo generado por IA está 100% listo. Lo usual: bajarlo, vectorizar (convertir de imagen a SVG — SVG es un formato de imagen basado en vectores que escala sin perder calidad), y ajustar en Figma.

- [Vectorizer.ai](https://vectorizer.ai) o [Recraft](https://recraft.ai) convierten PNG → SVG
- En Figma ajustás proporciones, espaciado, colores exactos
- Exportás versiones: PNG, SVG, PDF, JPG

### Paleta de color: teoría práctica

Una paleta sólida tiene:

- **1 color primario** — el que más usarás
- **1-2 colores secundarios** — para contraste o secciones distintas
- **Neutros** — blanco/crema/gris/negro para texto y fondos
- **Un acento** (opcional) — color llamativo para CTAs

Herramientas útiles:

- [Coolors.co](https://coolors.co) — generador de paletas, muchas opciones
- [Adobe Color](https://color.adobe.com) — incluye teoría (análoga, complementaria, etc.)
- [Realtimecolors](https://realtimecolors.com) — ves tu paleta aplicada a un ejemplo web

**Regla de contraste**: asegurate que texto sobre fondo tenga contraste suficiente (WCAG AA = 4.5:1). Si no lo cumple, tu marca es bonita pero inaccesible.

### Tipografía: elige 2, no 10

2 fuentes bastan casi siempre:

- **Título**: con carácter, memorable. Serif clásica o sans-serif fuerte.
- **Cuerpo**: legible, neutra. Generalmente sans-serif limpia.

Google Fonts tiene 1000+ opciones gratis. Combinaciones probadas:

- Playfair Display (título serif) + Inter (cuerpo sans)
- Montserrat (título) + Open Sans (cuerpo)
- Space Grotesk (título moderno) + Inter (cuerpo)
- DM Serif Display (título editorial) + DM Sans (cuerpo)

Evita usar fuentes muy similares — perdés jerarquía.

### Favicon y avatares

El logo chico es crítico. Probá tu símbolo a 16x16 (favicon de navegador): ¿aún se lee? Si no, simplificá.

Herramienta útil: [Realfavicon generator](https://realfavicongenerator.net) — subís PNG y te da todos los tamaños.

### Errores comunes

- **Logo muy complejo**: a 16px se vuelve mancha
- **Demasiados colores**: 2-3 máximo en logo, paleta puede tener más
- **Fuente demasiado fina**: en móvil se pierde
- **Sin versión en blanco**: necesitás versión mono (todo blanco para fondos oscuros)
- **Sin versión horizontal y vertical**: sirven para distintos contextos$md$,
    1,
    60,
$md$**Genera y refina tu logo.**

Con tu brief de la lección 1:

1. **Genera 20 logos** en Ideogram o GPT Image con un prompt bien detallado
2. **Elige 3** que resuenen con tu brief
3. **Refiná 1**: bajalo, vectorizalo con [Vectorizer.ai](https://vectorizer.ai) o [Recraft](https://recraft.ai), ajustá en Figma
4. **Genera variantes**: versión horizontal, vertical, solo símbolo, versión mono (negro solo, blanco solo)
5. **Paleta de color**: define 3-4 colores (primario + 2 secundarios + neutros) usando Coolors.co
6. **Tipografía**: elige 2 fuentes de Google Fonts (título + cuerpo)

**Entregable**: 1 archivo Figma con tu logo, paleta y tipografías. Prueba tu logo a 16x16 — ¿se lee?$md$,
    20
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     'Ideogram o GPT Image son mejores que Midjourney para logos porque:',
     to_jsonb(ARRAY[
       'Son más caros',
       'Manejan texto legible (tipografía del wordmark) — Midjourney es excelente estéticamente pero falla en letras claras',
       'Solo permiten logos',
       'No son mejores'
     ]),
     1,
     0,
     'Esto es lo más frustrante de Midjourney: genera imágenes hermosas pero las letras salen distorsionadas o con caracteres raros. Ideogram y GPT Image se entrenaron específicamente para texto legible. Para logos (donde el nombre de la marca debe leerse perfecto) son la elección correcta. Si amás el estilo estético de MJ, podés generar el símbolo ahí y combinar el wordmark en Figma.'),

    (v_lesson_id,
     'Un logo generado por IA rara vez está 100% listo. ¿Qué hacés después de generarlo?',
     to_jsonb(ARRAY[
       'Usarlo directamente tal como salió',
       'Vectorizarlo (PNG → SVG con herramientas como Vectorizer.ai) y refinarlo en Figma: ajustar proporciones, espaciado y colores exactos',
       'Generarlo 100 veces más hasta que salga perfecto',
       'Pagarle a un diseñador que lo rehaga entero'
     ]),
     1,
     0,
     'El flujo profesional: IA genera la idea visual, Figma la termina. Necesitás SVG para que escale sin pixelarse, control exacto de colores (el PNG tiene variaciones mínimas entre versiones), y ajustes finos que IA no controla (espaciado entre símbolo y texto, alineación perfecta, versiones). Vectorizar + refinar toma 30-60 min y cambia todo.'),

    (v_lesson_id,
     'Una paleta de marca sólida típicamente tiene:',
     to_jsonb(ARRAY[
       '10 colores para tener variedad',
       '1 primario + 1-2 secundarios + neutros (blanco, negro, grises) + opcional 1 acento para CTAs — en total 4-6 tonos',
       'Solo 1 color, el primario',
       'Todos los colores del arcoíris'
     ]),
     1,
     0,
     'Demasiados colores = marca indecisa. Muy pocos = marca limitada. El sweet spot: 1 primario (el dominante), 1-2 secundarios (variedad), neutros (para texto y fondos) y opcionalmente un acento llamativo para CTAs (botones de acción). Total 4-6 tonos bien usados. Con eso podés diseñar cualquier pieza sin decisiones complicadas cada vez.');


  -- LECCIÓN 3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Aplicaciones y templates',
$md$## El logo vive en piezas, no solo

Un logo en un archivo no es nada. Una marca vive en piezas reales: redes, sitio web, correo, cartas, uniformes. La prueba de un buen sistema: que todas se sientan de la misma familia.

### Lista mínima de aplicaciones

Para arrancar:

1. **Perfil y portada de redes** (Instagram, LinkedIn, X)
2. **Template de post feed** (Instagram/LinkedIn)
3. **Template de story**
4. **Tarjeta de presentación** (aunque sea digital)
5. **Firma de email**
6. **Favicon y metadata del sitio web**
7. **Header de newsletter** (si tenés)
8. **Plantilla de pitch deck / propuesta**

Cada una refuerza la identidad. Si cada post tiene un estilo distinto, la marca se siente "inestable" para el espectador.

### Templates reutilizables en Canva / Figma

**Canva** tiene plantillas prediseñadas que podés adaptar con tu paleta y logo. Rápido y accesible.

**Figma** da más control. Podés crear un "design system" con tus colores, tipografías y componentes, y reusarlos en todas las piezas.

Recomendación práctica:

- Si sos solo / arrancando: **Canva** con tus colores y logo
- Si escalás o trabajás en equipo: **Figma** con design system

### Patrón: design system en Figma

Un design system simple tiene:

- **Colors** (variables con tu paleta)
- **Text styles** (título H1, H2, cuerpo, caption)
- **Components**: botones, inputs, cards, badges
- **Templates**: post feed, story, propuesta, email

Una vez armado, cualquier pieza nueva toma 15 min. Sin design system, cada pieza toma 1 hora y queda inconsistente.

### Estilo de fotografía

Una marca también se define por el tipo de fotos que usa. Define:

- **Tono de la imagen**: natural, editorial, snap, lifestyle, studio
- **Paleta de la foto**: cálida, fría, pasteles, saturados, desaturados
- **Temas**: personas, producto, ambiente, metafóricas
- **Tratamiento**: grain, desenfoque, sin efectos, etc.

Con imágenes IA podés mantener este estilo consistente: crea un prompt base ("cozy lifestyle, warm natural light, soft grain, cream tones") y úsalo como cimiento para cada imagen nueva de la marca.

### Íconos y elementos gráficos

Más allá del logo, algunas marcas tienen:

- **Patrón / textura**: un gráfico repetitivo que aparece en backgrounds
- **Set de íconos custom**: en lugar de usar íconos genéricos
- **Ilustraciones**: personaje o estilo gráfico propio

No todas las marcas necesitan esto, pero cuando lo tienen, suman muchísimo. Con IA podés generar sets de íconos consistentes (usando style reference). Y ilustraciones custom se generan con MJ/Flux manteniendo un prompt-base de estilo.

### Voice & tone (copy): parte del branding

La marca no solo es visual. También es **cómo habla**. Define:

- **Persona del hablante** (amigo cercano, profesora, profesional serio, comediante)
- **Vocabulario** (formal vs informal, emojis o no, tecnicismos sí/no)
- **Ritmo** (frases cortas o largas, con pausas o continuo)

Guia simple:

> "Nosotros escribimos como [descripción del tono en 1 línea]. Siempre: [X, Y, Z]. Nunca: [A, B, C]."

Ejemplo:

> "Nosotros escribimos como una amiga experta contándote sobre un tema que le apasiona. Siempre: directa, con ejemplos concretos, usando 'tú' o 'vos'. Nunca: acartonado, con jerga inútil, con disclaimers innecesarios."

### Brand book: tu manual

Un brand book es un PDF (o doc de Notion) que reúne todo:

- Estrategia: audiencia, oferta, arquetipo, voice
- Logo: variantes, usos correctos, qué no hacer
- Paleta: hex + nombres + dónde usar cada color
- Tipografía: familias + jerarquía + tamaños
- Aplicaciones: ejemplos de redes, web, email
- Fotografía: estilo
- Voice & tone

Un brand book de 10-15 páginas es oro cuando:
- Contratás a alguien para diseñar algo
- Trabajás con una agencia
- Tu equipo crece y necesita alinearse

Tu brand book no tiene que ser una obra maestra. Uno bien hecho hoy vale más que uno perfecto dentro de 6 meses.

### Usar IA para el brand book mismo

Claude o GPT te pueden ayudar a escribir las secciones de texto (voice & tone, descripción de arquetipo, usos correctos del logo). Ejemplo:

> "Acá están mis 4 pilares estratégicos + arquetipo Creator. Escribe una descripción de voice & tone en 200 palabras con 'siempre/nunca', y 5 ejemplos de frases típicas que la marca diría."

Claude te devuelve contenido alineado. Vos lo editás. Ahorro: 2-3 horas.

### Test de consistencia

Antes de dar por listo el brand:

1. Ponele a alguien 5 piezas tuyas al azar (posts, logo, email, web)
2. Preguntale: "¿te parecen de la misma marca?"
3. Si no lo están, ajustá hasta que sí

Este test vale oro — a veces sentís que todo es consistente pero un ojo externo ve diferencias que vos pasaste por alto.$md$,
    2,
    70,
$md$**Crea el mini brand book de tu marca.**

En Figma, Canva o Notion, construye un doc de 6-10 páginas con:

1. **Portada** (logo + 1 línea de posicionamiento)
2. **Estrategia** (audiencia, oferta, diferencial, arquetipo, feel en 3 palabras)
3. **Logo** (variantes: horizontal, vertical, solo símbolo, mono)
4. **Paleta** (colores con hex y dónde usar cada uno)
5. **Tipografía** (familia título + cuerpo, con jerarquía H1, H2, body)
6. **Voice & tone** (1 línea de persona + siempre/nunca + 3 ejemplos de frases)
7. **3 templates aplicados** (post Instagram, story, firma email o similar)

**Bonus**: pasale el brand book a alguien y pedile que intente crear un post nuevo siguiendo las reglas. Si lo logra sin preguntarte, tu brand book funciona.

**Meta**: tener un PDF de marca que podrías entregarle a una agencia, un freelance o un empleado nuevo.$md$,
    20
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Qué es un design system en Figma y por qué vale la pena?',
     to_jsonb(ARRAY[
       'Una plantilla gratis que descargás',
       'Un conjunto de variables de color, estilos de texto y componentes reutilizables — hace que diseñar una pieza nueva tome 15 min en vez de 1h, y mantiene consistencia',
       'Una extensión de pago',
       'Solo sirve para apps grandes'
     ]),
     1,
     0,
     'Un design system es la librería de "átomos" de tu marca en Figma: colores como variables (no hex pegados), estilos de texto predefinidos (H1, body...), componentes (botón primario, card...). Cuando creás una pieza nueva, arrastrás componentes existentes. Resultado: velocidad + consistencia automática. Cuando cambiás el color primario, todas las piezas se actualizan. Es la diferencia entre diseñar con intención vs improvisar cada vez.'),

    (v_lesson_id,
     '¿Qué es "voice & tone" en branding?',
     to_jsonb(ARRAY[
       'El sonido del logo',
       'La personalidad de cómo habla la marca: vocabulario, ritmo, formalidad — parte del branding igual que lo visual',
       'Solo aplica para marcas con podcast',
       'Un sinónimo de "tipografía"'
     ]),
     1,
     0,
     'Una marca es visual Y textual. Cómo escribís tus posts, emails, captions y páginas web comunica tanto como tu logo. Voice & tone define: con qué personalidad habla tu marca, qué palabras usa, qué evita, cuán formal es. Sin un voice definido, cada pieza tiene un tono distinto y la marca se siente inconsistente. Definirlo toma 30 min y se replica en cientos de piezas.'),

    (v_lesson_id,
     'Terminás tu brand. ¿Cuál es el mejor test de consistencia?',
     to_jsonb(ARRAY[
       'Revisar vos mismo con cuidado',
       'Mostrarle a alguien externo 5 piezas al azar (posts, logo, email, web) y preguntarle si parecen de la misma marca — si duda, ajustá',
       'No hay forma de testear',
       'Esperar a que un cliente se queje'
     ]),
     1,
     0,
     'Un ojo externo sin contexto previo capta inconsistencias que vos, como autor, no ves. Le mostrás 5 piezas y preguntás: "¿te parecen de la misma marca?". Si hay duda, algo no está alineado (puede ser color, tipografía, estilo de imagen, voice). Este test rápido identifica fugas que vos ya normalizaste. Hacelo cada vez que saques nuevas piezas.');


  -- LECCIÓN 4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Iteración y evolución de marca',
$md$## Una marca no termina cuando la lanzás

Uno de los errores más comunes: tratar la marca como algo estático que se "cierra" el día del lanzamiento. Las marcas que duran evolucionan con cuidado a lo largo de los años.

### La marca como experimento continuo

Después de lanzar, vas a aprender cosas que no sabías:

- Qué colores resuenan con tu audiencia real (no la imaginada)
- Qué palabras usan tus clientes cuando hablan del producto
- Qué elementos visuales funcionan mejor en redes (los datos te lo dicen)
- Qué formatos generan más engagement

Estos aprendizajes alimentan **micro-iteraciones**: pequeños ajustes al brand que lo hacen mejor cada mes.

### Micro-iteraciones (buenas)

Cambios chicos sin revolucionar todo:

- Ajustar un tono de color para mejor contraste
- Añadir un color secundario al set
- Introducir un patrón nuevo
- Evolucionar el tono de voice (más conciso, menos formal)
- Probar una tipografía alternativa en campañas

Estas no requieren anuncio ni reboot. Simplemente vas ajustando.

### Rebrands (grandes)

A veces se justifica un cambio grande:

- Cambió el público objetivo
- La marca se percibe desactualizada
- Hubo un pivote de producto
- La competencia se apropió de tu visual y necesitás diferenciarte
- Escalaste mercado (local → global, B2C → B2B)

Rebrands son caros en atención y costo — no los hagas porque sí. Cuando los hacés, comunicalo bien: explicá el porqué, agradecé la historia anterior, mostrá continuidad.

### Cómo sabés cuándo iterar

Señales de que tu marca necesita revisión:

- **Feedback repetido**: si 5 personas distintas te dicen algo, escuchá
- **Datos de analytics**: qué posts funcionan y cuáles no
- **Comparación con competencia**: ¿te estás quedando visualmente atrás?
- **Cambio de negocio**: si pivoteaste, probablemente tu marca también debe ajustarse
- **Te sentís aburrido de tu marca**: a veces vos mismo captás que envejeció

### Sistema escalable: piensa en el futuro

Al diseñar hoy, pensá en lo que venga:

- **¿Funciona en mercados nuevos?** Si es una marca en español, ¿funciona el nombre y visual en inglés?
- **¿Escala a nuevos productos?** Si hoy vendés un curso, ¿la marca soporta 10 cursos mañana?
- **¿Funciona en otros medios?** Si hoy es digital, ¿funciona impresa? ¿En merch? ¿En un podcast?

Un sistema bien pensado hoy evita rebrands dolorosos mañana.

### Templates de escalado

Con IA podés generar rápido cuando la marca crece:

- **Nuevo producto**: aplicá el sistema a un nombre y concepto nuevo
- **Nueva campaña**: genera variaciones visuales manteniendo paleta/tono
- **Nueva red social**: adapta el sistema al formato específico (horizontal, vertical, feed, stories)
- **Merch / impreso**: generá mockups con Nano Banana para ver cómo quedaría tu logo en t-shirts, tazas, cuadernos

### El error más grande (y más común)

**Confundir "a mí me gusta" con "funciona"**.

Tu gusto no es la métrica. Lo que funciona es:

- ¿Tu audiencia lo reconoce rápido?
- ¿Comunica el feel correcto?
- ¿Se diferencia de la competencia?
- ¿Genera acción (clicks, compras, engagement)?

A veces el logo que no era tu favorito es el que convierte mejor. Tené datos antes que ego.

### Casos reales de evolución

**Airbnb** (2014): rebrand total con nuevo logo ("Bélo") para reflejar pertenencia.
**Instagram** (2016): de logo skeuomorfo a gradiente plano, para modernizar en era mobile.
**Mailchimp** (2018): mono tipografía + mono color + ilustración custom, marca muy reconocible.
**Google** (2015): de serif a sans geométrico, simplificando para la era mobile/responsive.

Todos tomaron decisiones difíciles con criterio estratégico, no estético.

### Recap del track

Terminaste **Creador Visual**. Lo que sabés:

- **Imágenes**: prompting profesional, consistencia de personaje, edición quirúrgica
- **Video**: prompting para video, image-to-video, producción de ad completo
- **Branding**: estrategia, logo con IA, brand book, iteración

Con este stack podés producir contenido visual profesional sin diseñador ni productor. El valor de este track: independencia creativa y velocidad para tu propio proyecto o para clientes.

Próximo track: **Builder Web** — usás esto mismo para construir tu sitio web.$md$,
    3,
    70,
$md$**Planea tu evolución de marca.**

Sobre tu brand book:

1. **Lista 3 cosas que podrían necesitar ajuste en 6 meses** (ej: ampliar paleta, añadir un patrón, refinar voice)
2. **Diseñá 2 escenarios de escalado**: si añadís un producto nuevo / si entrás a un mercado nuevo (ej: inglés además de español), ¿cómo se adapta tu brand?
3. **Genera 3 variaciones de tu logo con IA**: versión minimalista, versión más ornamentada, versión monocromática. Guardalos — te van a servir para campañas especiales.
4. **Define métricas de marca**: ¿cómo vas a saber si tu marca "funciona"? (menciones, engagement, reconocimiento de color, etc.)

**Meta**: tener un plan de 6-12 meses para tu marca, con momentos de revisión programados y criterios claros para decidir iterar o no.$md$,
    15
  )
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id,
     '¿Cuándo tiene sentido hacer un rebrand (cambio grande) vs micro-iteraciones (ajustes pequeños)?',
     to_jsonb(ARRAY[
       'Siempre hacer rebrand, es más impactante',
       'Rebrand solo cuando hay un cambio estructural (nuevo público, pivote, escalado a nuevos mercados). Micro-iteraciones para afinar lo que ya funciona',
       'Nunca hacer rebrand',
       'Cada 3 meses rebrand automáticamente'
     ]),
     1,
     0,
     'Rebrands tienen costo: pérdida de reconocimiento acumulado, confusión de la audiencia, inversión en re-producción de piezas. Solo se justifican cuando algo estructural cambió en el negocio. Para mejorar lo que tenés, micro-iteraciones son más seguras: cambiás un color, añadís un patrón, evolucionás voice. No hay anuncio, no hay reset.'),

    (v_lesson_id,
     'El error más grande al iterar una marca es:',
     to_jsonb(ARRAY[
       'Cambiar muy poco',
       'Confundir "a mí me gusta" con "funciona" — decisiones deben basarse en datos (reconocimiento, engagement, conversión), no solo en tu gusto personal',
       'Usar IA para los cambios',
       'Pedir feedback a alguien más'
     ]),
     1,
     0,
     'Tu gusto no es la métrica. El logo/color/voice que MÁS te gusta no necesariamente es el que más conecta con tu audiencia, el que más se reconoce o el que más convierte. Decisiones estratégicas de marca requieren datos: engagement rates, feedback de clientes, tests A/B si es posible. Los fundadores que insisten en "esto me gusta a mí" suelen terminar con marcas que no funcionan comercialmente.'),

    (v_lesson_id,
     'Al diseñar hoy, ¿qué es "pensar en lo que venga"?',
     to_jsonb(ARRAY[
       'Diseñar solo para el presente',
       'Considerar si el sistema escala a nuevos productos, mercados o medios futuros — evita rebrands dolorosos más adelante',
       'Contratar un diseñador famoso',
       'Gastar más dinero hoy'
     ]),
     1,
     0,
     'Pensar en escalabilidad: ¿funcionará si mañana lanzás un segundo producto? ¿Si el nombre se traduce al inglés? ¿Si imprimís en una t-shirt? ¿Si pasás de B2C a B2B? Un sistema flexible hoy te ahorra rehacer todo en 2 años cuando crezcas. Las marcas que escalan bien fueron diseñadas con estos escenarios en mente desde el día 1, aunque en ese momento parecieran lejanos.');

  RAISE NOTICE 'Módulo "Branding Pro": 4 lecciones + 12 quizzes insertados.';

END $$;

-- ============================================
-- FILE: seeds/track-web-01-landing.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Builder Web" / Módulo "Landing en 10 min"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'web';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Landing no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Anatomía de una landing que convierte',
$md$## Qué hace que una landing "funcione"

Una landing page es una página web con **un solo objetivo**: que el visitante haga UNA acción específica. Comprar, agendar, registrarse, descargar. No es tu sitio web completo — es una página hecha para convertir.

En 2026, podés tener una landing funcional en 10 minutos usando IA. Pero primero tenés que entender qué hace que una landing convierta. Sin eso, generás páginas bonitas que no venden.

### Estructura canónica (que funciona)

Una landing efectiva sigue esta estructura en orden:

1. **Hero** — título potente + subtítulo + CTA (Call To Action) principal
2. **Problema** — nombra el problema que tu usuario vive
3. **Solución** — presenta tu oferta como respuesta
4. **Beneficios** — 3-5 ventajas específicas (no features)
5. **Prueba social** — testimonios, logos de clientes, números
6. **Cómo funciona** — 3-4 pasos simples
7. **FAQ** — 5-7 preguntas frecuentes
8. **CTA final** — repetí la acción principal
9. **Footer** — links secundarios, legales

No todas las landings tienen todas las secciones. Pero orden importa: el visitante decide en los primeros 5 segundos. Si el Hero falla, nunca lee el resto.

### El Hero: tu único disparo

El Hero es los primeros ~600px de la página. Tiene que comunicar:

- **Qué es esto** (en 1 frase)
- **Para quién** (implícito o explícito)
- **Qué ganan** si hacen la acción

Fórmula probada:

> **[Verbo] [resultado específico]** en [tiempo/esfuerzo].
> [Descripción de 1-2 líneas que explica el cómo].
> [Botón CTA]

Ejemplos reales:

> **Aprende IA aplicada en 15 minutos al día.**
> IALingoo te enseña desde prompting hasta agentes, con práctica real, en lecciones cortas tipo Duolingo.
> **[Empezar gratis]**

> **Factura en un clic, olvidate del Excel.**
> Bill te arma facturas, las manda por WhatsApp al cliente y lleva tus cuentas.
> **[Probar 14 días gratis]**

Mal:

> "La mejor plataforma de gestión" ← vago, dice nada
> "Soluciones innovadoras para empresas" ← palabras huecas

### CTA (Call to Action)

Reglas:

- **Verbo + beneficio**: "Empieza gratis" > "Registrate". "Descarga la guía" > "Enviar".
- **Un solo CTA principal** por pantalla. Múltiples CTAs confunden.
- **Contraste visual**: el botón tiene que destacar (color distintivo, tamaño).
- **Evitá "Enviar"**: es el default aburrido. Personalizá.

### Prueba social: crítica

Decir "somos buenos" no convence. Otros diciéndolo, sí.

Tipos de prueba social, de más a menos poderosa:

1. **Números**: "12,000 usuarios activos" / "$2M procesados"
2. **Testimonios con foto y nombre real**
3. **Logos de clientes conocidos**
4. **Menciones en medios** (Forbes, TechCrunch)
5. **Case studies** (cliente específico, resultado específico)

Si sos nuevo y no tenés nada: **acepta alpha/beta users gratis a cambio de testimonios**. Primeros 10 usuarios que paguen con feedback en vez de dinero.

### Copy > diseño

Una landing fea con copy brillante convierte más que una landing bonita con copy genérico. Por orden de prioridad al construir:

1. **Claridad del mensaje** (el visitante entiende qué es en 5s)
2. **Estructura y jerarquía** (scroll natural, priorización correcta)
3. **Diseño visual** (bonito, limpio, marca)

Muchos fundadores invierten al revés: horas en diseño y copy medio pensado. Resultado: bonita pero no convierte.

### Herramientas para construir (2026)

Opciones según nivel:

| Herramienta | Nivel | Fuerte en | Contras |
|---|---|---|---|
| **Lovable** | No-code IA | Full-stack completo (con backend) | Costo mensual |
| **v0 by Vercel** | No-code IA | Componentes React de alta calidad | Solo frontend |
| **Framer** | No-code visual | Animaciones, estética premium | Curva visual |
| **Webflow** | No-code visual | Sitios completos, CMS | Más lento |
| **Carrd** | No-code simple | Landings simples ultra rápido | Limitado |
| **Claude Code + Next.js** | Código con IA | Control total, gratis hospedado en Vercel | Requiere estar cómodo con deploy |

**Recomendación 2026**: si vas a publicar algo mañana, **Lovable o v0**. Si querés control y escalar, **Claude Code + Next.js**. Carrd sigue siendo imbatible para landings de 1 página con poco contenido.

### El "prompt de landing" para IA

Cuando le pedís a Lovable o v0 una landing, tu prompt debería tener:

1. **Qué producto es** (1 línea)
2. **Para quién** (audiencia)
3. **Oferta específica** (precio si aplica)
4. **Secciones que querés** (hero + problema + solución + testimonios + CTA)
5. **Copy real** (no "lorem ipsum" — dale tus textos)
6. **Estilo visual** (paleta, referencias)

Dame todo eso, Lovable te entrega en 5 minutos una landing usable. Sin eso, te entrega una genérica que nadie quiere.

### Anti-patterns (errores comunes)

- **Hero con 3 CTAs distintos**: confunde, no convierte
- **Testimonios inventados/fake**: se huelen a kilómetros
- **Animaciones excesivas**: distraen del mensaje
- **FAQ pobladas de obviedades**: aprovechá para resolver objeciones reales
- **Footer gigante con 50 links**: simple, concentrado
- **Fondo oscuro con texto gris claro**: poca accesibilidad, cuesta leer

### El test de los 5 segundos

Mostrale tu landing a alguien por 5 segundos. Pregunta: "¿qué ofrecemos y para quién?". Si responde bien, tu hero funciona. Si duda, reescribí.$md$,
    0, 50,
$md$**Escribe el copy de tu landing.**

Elegí una idea (real tuya, o ficticia para practicar) y escribí el copy completo en un doc:

1. **Hero**: título + subtítulo + texto del CTA (usá la fórmula "[Verbo] [resultado] en [tiempo/esfuerzo]")
2. **Problema**: 1 párrafo que describa el dolor de tu usuario
3. **Solución**: 1 párrafo con tu oferta
4. **3-5 beneficios** (no features — beneficios)
5. **Prueba social**: si no tenés, escribí el plan de cómo conseguirla primera
6. **Cómo funciona**: 3-4 pasos
7. **5 FAQ** con preguntas reales que tu usuario se haría

**Meta**: tener un doc de 1 página con copy listo para pegar en Lovable/v0 en la próxima lección. No abras herramientas todavía — foco en el mensaje.$md$,
    10)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, 'La prioridad #1 al construir una landing es:',
     to_jsonb(ARRAY['Diseño visual impresionante','Claridad del mensaje — el visitante entiende qué es y para quién en 5 segundos','Cantidad de secciones','Animaciones cinematográficas']), 1, 0,
     'Una landing fea con copy clarísimo convierte más que una bonita con copy confuso. La jerarquía de inversión debería ser: claridad > estructura > diseño. Muchos fundadores lo invierten y terminan con páginas preciosas que nadie entiende. Primero escribís copy que comunique en 5 segundos qué ofrecés y para quién; después diseñás alrededor de ese mensaje.'),
    (v_lesson_id, 'Tenés un producto nuevo sin usuarios todavía. ¿Cómo conseguís prueba social real (no inventada)?',
     to_jsonb(ARRAY['Inventar testimonios','Mentir con números','Aceptar alpha/beta users gratis a cambio de feedback y testimonios — los primeros 10-20 usuarios pagan con feedback, no plata','Esperar a tener 1000 usuarios']), 2, 0,
     'Testimonios inventados se huelen a distancia. La estrategia probada para lanzar: ofrece acceso gratis o muy barato a 10-20 usuarios a cambio de feedback real y permiso para citarlos. Obtenés testimonios genuinos, product insights, y el boca a boca de esos primeros usuarios. Muchas empresas grandes arrancaron así.'),
    (v_lesson_id, '¿Cuántos CTAs principales debería tener tu hero?',
     to_jsonb(ARRAY['Cuantos más mejor','Uno solo — múltiples CTAs confunden y diluyen conversión. Un CTA principal y opcionalmente un secundario sutil ("ver demo")','Ninguno, el usuario decide solo','Tres mínimo']), 1, 0,
     'Un hero con 3 CTAs ("Empieza gratis", "Ver demo", "Hablar con ventas") parece dar opciones pero en realidad confunde y dispersa. Cada CTA extra baja la conversión del principal. Regla: un CTA principal claro, y si necesitás otro, que sea secundario visual ("ver demo" en link sin botón). La claridad de acción es parte de por qué la landing convierte.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Tu primera landing con Lovable',
$md$## De copy a landing publicada en 10 minutos

[Lovable](https://lovable.dev) es la herramienta que más democratizó el desarrollo web en 2025-2026. Le hablás en español, te construye una app web completa (frontend + backend), con posibilidad de conectar Supabase, Stripe y deploy automático.

En esta lección: pasar del copy que escribiste a una landing publicada.

### Paso 1: Arranca un proyecto nuevo

Entra a [lovable.dev](https://lovable.dev), crea cuenta (Google funciona) y clickeá "New Project".

La primera pantalla te pide el prompt inicial. Acá metés el brief de tu landing.

### Paso 2: El prompt maestro

Copia esta plantilla y llena los datos con tu info:

> Construime una landing page para **[PRODUCTO]**, dirigida a **[AUDIENCIA]**. La estructura debe ser:
>
> 1. **Hero**: título "[TU TÍTULO]", subtítulo "[TU SUBTÍTULO]", CTA "[TEXTO CTA]"
> 2. **Problema**: una sección que describa el problema: "[TU TEXTO]"
> 3. **Solución**: presenta el producto con este texto: "[TU TEXTO]"
> 4. **Beneficios**: 3-5 beneficios con íconos: [LISTA TUS BENEFICIOS]
> 5. **Cómo funciona**: 3 pasos: [PASOS]
> 6. **Testimonios**: 3 testimonios (dejá placeholder si no tenés, o pegá reales)
> 7. **CTA final**: repetí el CTA principal
> 8. **Footer**: logo + links legales
>
> Estilo visual: **[describí paleta, mood]**. Tipografía: **[serif/sans-serif, ejemplos]**. Diseño: moderno, limpio, mobile-first.
>
> Usa Next.js con Tailwind. No conectes base de datos todavía.

### Paso 3: Generar y revisar

Lovable procesa ~2-3 minutos. Te entrega:

- Una preview en vivo (iframe con tu landing)
- El código generado (podés verlo si querés)
- Un editor para seguir conversando

Revisá en la preview:

- ¿El copy es el tuyo?
- ¿El orden de secciones es correcto?
- ¿La paleta coincide?
- ¿Se ve bien en mobile? (hay un toggle para verlo)

### Paso 4: Iterá

Lo más común: el primer resultado está en un 80%. Iterá con mensajes como:

- _"Cambia el color del botón CTA a un naranja más vibrante (#F97316)"_
- _"Agrega un testimonio antes de los beneficios"_
- _"El hero se ve muy vacío, agregá una imagen/ilustración del lado derecho"_
- _"Mejora la jerarquía tipográfica del hero: más contraste entre H1 y subtítulo"_
- _"Reducí el padding vertical de cada sección, se ve muy espaciado"_

Cada mensaje es una iteración. Lovable modifica el código y actualiza la preview.

### Paso 5: Imágenes e íconos

Lovable genera íconos automáticamente (usando Lucide). Para imágenes hero puedes:

- **Subir tus propias imágenes**: botón de upload en el chat
- **Pedir que use Unsplash**: _"Usá una imagen de Unsplash relacionada con [tema]"_
- **Dejar que genere con IA**: _"Generá una imagen para el hero de una persona trabajando en laptop"_ (usa generación de imagen interna)

Usar tus imágenes (de tu producto, de tu marca) siempre convierte mejor que stock photo genérico.

### Paso 6: Formulario de captura

Para landings, casi siempre querés capturar leads (emails de interesados). Opciones:

1. **Formulario con Supabase**: _"Agregá un formulario de email en el hero que guarde en Supabase tabla 'leads'"_. Lovable conecta Supabase y configura todo.
2. **Formulario con Formspree/ConvertKit**: servicios externos que procesan emails sin backend propio
3. **Botón a WhatsApp**: _"El CTA debe abrir WhatsApp con mensaje prellenado a +57..."_

**Recomendación**: para validar rápido, Formspree free tier alcanza. Para algo serio, Supabase.

### Paso 7: Deploy (publicar)

Lovable tiene deploy integrado. Click en "Publish" y te da una URL tipo `tu-proyecto.lovable.app`. En 2 minutos tu landing está live.

Para un dominio custom (ej: `tumarca.com`) vas a tener que conectarlo — lo vemos en el módulo 2 de este track.

### Paso 8: Test en mobile

**Muy importante**: 70%+ del tráfico es mobile. Abrí tu landing desde el celular, navegá de punta a punta.

Chequeá:

- ¿El CTA es clickeable cómodamente con el pulgar?
- ¿El texto se lee bien sin zoom?
- ¿Las imágenes cargan rápido?
- ¿Los formularios funcionan?
- ¿No hay scroll horizontal raro?

Si hay algo mal, volvé al chat: _"En mobile el botón CTA queda cortado, arreglá responsive"_.

### Errores comunes al usar Lovable

- **Prompt muy vago** → resultado genérico. Dale copy específico.
- **Iterar 50 veces sin revisar** → se acumulan contradicciones. Cada ~5 iteraciones, revisá integral.
- **Pedir cambios visuales sin mencionar dónde** → especificá: "en el hero", "en la sección de beneficios"
- **No probar en mobile** → todo se rompe en el celular del primer cliente
- **Olvidar agregar analytics** → al final, pedile instalar Google Analytics o Plausible

### Alternativas cuando Lovable no alcanza

Si necesitás:

- **Diseño ultra específico (pixel-perfect)** → Figma + export con plugins + Webflow
- **Animaciones complejas** → Framer Motion + Claude Code
- **CMS para que clientes no-técnicos editen** → Webflow CMS o Framer CMS
- **Muchísimas páginas dinámicas** → Next.js propio con Claude Code

Para 90% de landings, Lovable alcanza y sobra.$md$,
    1, 70,
$md$**Construí tu landing en Lovable.**

Usa el copy que escribiste:

1. Entrá a [lovable.dev](https://lovable.dev) y crea proyecto nuevo
2. Usá el prompt maestro (en la lección) con tu copy real
3. Iterá 3-5 veces hasta que te guste (paleta, tipografía, jerarquía)
4. Agregá al menos 1 imagen propia (o usá Unsplash)
5. Agregá un formulario de captura de email (Formspree o Supabase, el que prefieras)
6. **Publicá** y conseguí tu URL `tu-proyecto.lovable.app`
7. Testeala desde tu celular
8. Mandale la URL a 2-3 amigos y pediles el "test de 5 segundos"

**Meta**: tener una landing real, publicada, testeada en mobile, que podrías mandar a un lead hoy mismo.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué diferencia a Lovable de herramientas como v0 o Webflow?',
     to_jsonb(ARRAY['Es más barato','Construye full-stack (frontend + backend + BD + deploy) desde prompt conversacional en español — v0 es solo componentes frontend, Webflow es visual no-code sin IA generativa tan potente','No usa IA','Es igual']), 1, 0,
     'Cada una tiene su nicho. v0 genera componentes React hermosos pero solo frontend. Webflow es visual drag-and-drop premium (sin chat generativo tan potente como Lovable). Lovable te da el stack completo desde conversación: frontend + backend + BD + auth + deploy, todo prompteable en español. Por eso es la más elegida para "tengo una idea y quiero una app funcional mañana".'),
    (v_lesson_id, 'Acabás de generar tu landing y te gusta el diseño en desktop. ¿Qué debés hacer antes de publicarla?',
     to_jsonb(ARRAY['Publicar de una','Testearla en mobile — abrir desde el celular y navegar completo. 70%+ del tráfico es mobile y es donde más cosas se rompen','Esperar a que alguien la revise','Nada, Lovable hace mobile perfecto']), 1, 0,
     'Lovable genera mobile-first razonablemente bien, pero nunca perfecto. Pequeñas cosas se rompen: botones cortados, textos superpuestos, scroll horizontal raro, imágenes enormes que cargan lento. Si tu primer visitante llega desde mobile y la experiencia es mala, se va. 2 minutos testando en el celular propio evitan pérdida de leads.'),
    (v_lesson_id, 'Iterás 50 veces con Lovable sin revisar integral. ¿Qué probablemente pasa?',
     to_jsonb(ARRAY['Todo mejora automáticamente','Se acumulan contradicciones entre iteraciones (por ejemplo cambiaste color 3 veces, padding 5 veces) y el resultado final tiene inconsistencias','Lovable mejora solo','Nada malo']), 1, 0,
     'Al iterar mucho sin checkpoint, Lovable puede olvidar decisiones anteriores o hacer cambios que contradicen iteraciones previas. El patrón sano: iterá 3-5 cambios, revisá la página entera (desktop + mobile), y si hay inconsistencias arreglalas en un solo mensaje integral. Sin esa pausa de revisión, lo que empezó coherente termina parcheado.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'v0 y Framer: alternativas premium',
$md$## Cuando querés más control o más estética

Lovable es fantástica para velocidad. Pero a veces querés:

- Control total del diseño a nivel pixel
- Animaciones premium
- Componentes React exportables
- Una estética específica que requiere herramienta visual

Ahí entran **v0** (de Vercel) y **Framer**.

### v0 by Vercel: componentes React premium

[v0.dev](https://v0.dev) es la herramienta de componentes más popular entre developers en 2026. Le pedís un componente o página, te genera código React + Tailwind + shadcn/ui (una librería de componentes prediseñados muy usada) listos para pegar en tu proyecto.

**Fuerte en**:
- Calidad de diseño por defecto (se ve premium sin configurar)
- Componentes específicos (forms, dashboards, pricing tables)
- Exportable: bajás el código y lo pegás en tu Next.js

**No alcanza para**:
- Backend completo (solo frontend)
- BD o auth (lo gestionás aparte)
- Deploy directo (tenés que publicar tú mismo)

**Cuándo usarlo**:
- Ya tenés un proyecto y necesitás una sección bonita rápido
- Querés prototipar diseños premium
- Necesitás componentes puntuales (tabla de precios, FAQ, testimonios)

### Usando v0 con Claude Code

El combo más poderoso en 2026:

1. En v0.dev: _"Dashboard admin con sidebar, tabla de usuarios, charts"_
2. Copiás el código generado
3. En Claude Code: _"Acá tenés este código de v0, intégralo a mi proyecto Next.js. Conecta la tabla a mi Supabase 'users'."_
4. Claude Code mete el componente, lo conecta a tu backend y corre

v0 te da el diseño premium. Claude Code te da la integración. Imbatible.

### Framer: el rey del diseño visual

[Framer](https://framer.com) es la herramienta visual más usada para landings con **estética premium**. Pensala como un Figma que publica.

**Fuerte en**:
- Animaciones on-scroll, hover, transiciones
- Aesthetic editorial / brand-first
- CMS (contenido editable sin tocar diseño)
- Framer AI: genera páginas a partir de texto
- SEO decente out-of-the-box

**No alcanza para**:
- Apps complejas (no es su fuerte)
- Full-stack (podés conectar formularios pero no lógica de negocio)
- Velocidad (curva más lenta que Lovable)

**Cuándo usarlo**:
- Portafolio / landing de agencia / sitio de marca premium
- Cuando el diseño es diferenciador del negocio (estudios creativos, moda, lujo)
- Cuando querés CMS donde no-devs publiquen posts

### Framer AI: generar con prompt

Similar a Lovable pero más enfocado en lo visual. Le das un prompt, genera página. Podés iterar visualmente o por chat.

Workflow típico:

1. Framer AI genera la primera versión
2. Ajustás visualmente en el editor (arrastrás componentes)
3. Usás Framer CMS para partes dinámicas
4. Publicás

### Webflow: el clásico maduro

[Webflow](https://webflow.com) es el que más existe. Menos AI-first, más "Photoshop para web". Muy usado por agencias.

**Fuerte en**: sitios complejos con CMS, e-commerce, control visual total.

**Contras**: curva empinada, más caro, menos "conversacional".

Si sos agencia o vas a hacer 10+ sitios, vale la inversión. Para uno solo propio, Lovable/Framer son más rápidos.

### Carrd: el minimalista

[Carrd.co](https://carrd.co) es el más simple. Una sola página scrolleable, $19/año. Ideal para:

- Portfolio personal
- Link in bio
- Pre-lanzamiento (capturar emails)
- Landing de evento
- Sitio de libro

No es AI, pero es tan simple que no necesita. 15 minutos y estás online.

### Resumen de stack 2026

Mi recomendación según caso:

| Caso | Herramienta |
|---|---|
| App completa con backend en 1 día | **Lovable** |
| Landing simple ultra rápida | **Carrd** o **Lovable** |
| Sitio con estética premium / portfolio | **Framer** |
| Componentes específicos para pegar en mi proyecto | **v0** |
| Sitio complejo con CMS y e-commerce | **Webflow** |
| Control total + escalabilidad | **Claude Code + Next.js + Vercel** |

### Combinar herramientas (power user)

Los pros en 2026 no usan una sola herramienta — combinan:

- **Diseño en Framer** → export a HTML/CSS → integración con Next.js
- **Componentes en v0** → pegados en proyecto Next.js → deploy en Vercel
- **Flujo de datos en Lovable** → rediseño visual encima en Framer
- **Frontend en Lovable + backend Supabase directo**

Conocer fortalezas de cada una te deja elegir la combinación óptima.

### Costos reales (2026)

Para que tengas referencia:

- **Lovable**: ~$20/mes plan Pro
- **v0**: Free tier generoso, $20/mes Premium
- **Framer**: $15-30/mes según plan
- **Webflow**: $14-36/mes por sitio
- **Carrd**: $19/año (si, al año)
- **Vercel (deploy de Claude Code/Next.js)**: free tier generoso, paga si escala

Para un freelancer activo, un stack de $40-80/mes cubre 90% de casos.$md$,
    2, 70,
$md$**Compara con v0 o Framer.**

Reconstruí tu landing en UNA alternativa (elegí según tu caso):

- Si querés componentes premium para pegar en Next.js → **v0**
- Si querés estética ultra premium y animaciones → **Framer**
- Si solo necesitás 1 página simple rápida → **Carrd**

Pasos:
1. Usá el mismo copy de tu landing en Lovable
2. Construila con la alternativa elegida
3. Comparalas: ¿cuál se ve mejor? ¿cuál fue más rápida? ¿cuál convertiría mejor?
4. Escribí 3-5 bullets con conclusiones

**Meta**: entender en piel propia las diferencias de cada herramienta. Esto te ayuda a elegir sabiamente en proyectos futuros.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, 'Necesitás un dashboard admin bonito con tabla y charts dentro de tu proyecto Next.js existente. ¿Cuál herramienta?',
     to_jsonb(ARRAY['Lovable, porque es full-stack','v0 — genera componentes React premium que copiás y pegás en tu Next.js existente. Lovable crearía un proyecto nuevo, no integra a uno existente fácilmente','Carrd','Webflow']), 1, 0,
     'v0 está pensado exactamente para este caso: dame código React + Tailwind para pegar en mi proyecto existente. Lovable es proyecto nuevo; integrarlo a uno existente es fricción. Carrd no hace apps. Webflow es visual pero no genera código React exportable para Next.js. v0 encaja perfecto.'),
    (v_lesson_id, 'Querés un portfolio personal con animaciones premium y estética editorial. ¿Qué elegís?',
     to_jsonb(ARRAY['Lovable','Framer — es la herramienta líder en estética premium con animaciones y se usa mucho en portfolios, estudios creativos y marcas donde el diseño es diferenciador','Google Docs','Excel']), 1, 0,
     'Framer es el gold standard para sitios donde el diseño y las animaciones son el diferenciador. Portafolios, estudios creativos, marcas de moda y lujo. Tiene CMS integrado, animaciones on-scroll nativas, y aesthetic por defecto mucho más refinada. Lovable es potente pero el output estético default es más "buena app" que "sitio editorial premium".'),
    (v_lesson_id, 'Un power user en 2026 usa una sola herramienta o varias?',
     to_jsonb(ARRAY['Solo Lovable','Combina según caso: Lovable para app completa + v0 para componentes específicos + Framer para marketing site + Claude Code para control total. Conocer fortalezas de cada una es lo que separa amateur de pro','Solo v0','Solo Framer']), 1, 0,
     'Cada herramienta tiene su nicho óptimo. Los pros eligen según el trabajo: Lovable para MVP completo, v0 para componentes premium dentro de proyectos propios, Framer para marketing sites con estética, Claude Code cuando necesitás control total. No es "cuál es mejor" sino "cuál para este caso". Con el tiempo construís intuición de qué usar cuándo.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Analytics, SEO y primeros visitantes',
$md$## Publicar no es suficiente. Necesitás saber qué pasa.

Tu landing está online. Ahora viene la parte que casi todos saltan: **medir**. Sin datos, no sabés si funciona, si se puede mejorar, ni por dónde.

Esta lección: la capa analítica y de descubrimiento básica.

### Instalá analytics básicos

Opciones (elegí una, no todas):

**Google Analytics 4 (GA4)** — el estándar, gratis, complejo
- Mide todo: visitas, fuentes, conversiones, funnel
- Curva de aprendizaje alta
- A veces bloqueado por ad-blockers (pierde datos)

**Plausible / Fathom / Simple Analytics** — alternativas privacy-first
- Simples de leer (1 pantalla te dice todo)
- ~$10/mes
- No tracking personal (no cookie banner molesto)
- Mi favorito para empezar: **Plausible**

**Vercel Analytics** — si usás Vercel
- Integrado, cero setup
- Incluido en plan Pro

Instalación: pedile a Lovable o Claude Code que te instale el script del que elegiste. Toma 30 segundos.

### Métricas que importan al inicio

Cuando recién lanzás no tenés tráfico. Las métricas útiles son:

- **Visitas únicas** (personas que llegaron)
- **Bounce rate** (% que se fue sin interactuar — <60% es bueno)
- **Páginas vistas por sesión**
- **Tiempo promedio en página**
- **Fuente de tráfico** (orgánico, social, directo, referido)
- **Conversión** (% que hizo la acción deseada)

Con 100 visitas ya ves patrones. Antes de 100, no asumas nada — muy poco data.

### SEO básico: que te encuentren en Google

SEO (Search Engine Optimization) es cómo Google te encuentra y rankea. Básicos imprescindibles:

**1. Title y Meta description**
Cada página tiene que tener:
- Un `<title>` claro (lo que sale en la pestaña y en Google)
- Una `<meta description>` de ~150 caracteres (el snippet en Google)

Pedile a Lovable: _"Agregá title y meta description optimizadas para SEO. Title: [tu mejor título]. Description: [descripción con keywords]."_

**2. Headings con jerarquía**
Tu landing debe tener:
- UN solo `<h1>` (usualmente el título del hero)
- Varios `<h2>` para secciones principales
- `<h3>` para sub-secciones

Google usa esto para entender la estructura.

**3. Imágenes con alt text**
Cada imagen necesita atributo `alt` describiendo qué es. Mejora SEO y accesibilidad.

**4. Velocidad de carga**
Página lenta = Google te rankea peor + usuarios se van. Optimizá:
- Imágenes comprimidas (WebP en vez de PNG/JPG)
- Lazy loading (las imágenes cargan al hacer scroll)
- No scripts innecesarios

**5. Mobile-friendly**
Google indexa mobile-first. Tu mobile es lo que cuenta.

**6. Sitemap y robots.txt**
Archivos que le dicen a Google qué indexar. Lovable/Vercel los crean automáticamente.

### Traigo visitantes ¿cómo?

SEO tarda meses. Para los primeros visitantes necesitás otras fuentes:

**Canales orgánicos gratis:**

- **Comunidades**: Reddit, Product Hunt, IndieHackers, Discord de tu nicho
- **Social orgánico**: posts en LinkedIn, Twitter/X, Instagram (con CTA a tu landing)
- **Referidos**: pediles a 10 amigos/colegas que compartan
- **Newsletter**: si tenés lista, anuncialo
- **Networking**: en comunidades físicas o virtuales, cuentá qué hacés

**Canales pagos (cuidado al principio):**

- **Meta Ads** (Instagram/Facebook): $5-20/día inicial para testear
- **Google Ads**: más caro, mejor para intención de compra explícita
- **TikTok Ads**: barato, bueno para B2C de consumo

Regla: no tires plata sin haber validado organically primero. Si con amigos no convierte, con plata tampoco.

### A/B testing

Cuando tengas >500 visitas/mes, empezá a testear variantes:

- Dos versiones del hero (título A vs título B)
- Dos CTAs ("Empezar gratis" vs "Probar 14 días")
- Dos fotos principales

Herramientas: Vercel tiene A/B test nativo, Google Optimize (discontinued), alternativas como VWO o Convert.

Al inicio, no te obsesiones con A/B — enfocate en traer visitantes. Con <200 visitas/mes, A/B da datos no-concluyentes.

### Open Graph y compartir

Cuando alguien pega tu link en WhatsApp, Twitter o LinkedIn, se ve un preview. Ese preview lo controla Open Graph:

- `og:title` — título del preview
- `og:description` — descripción
- `og:image` — imagen (1200x630 ideal)

Sin og:image custom, el preview se ve genérico. Con una imagen buena (ilustración del producto + título), 3x más clicks.

Pedile a Lovable: _"Agregá Open Graph tags con título, descripción e imagen [URL]. La imagen es 1200x630."_

### Capturar leads aunque no compren

Todo visitante tiene valor. Capturá su email aunque no compren:

- **Popup al salir** (exit intent): "Antes de irte, llevate esto gratis"
- **Formulario en footer**: "Suscribite para [beneficio]"
- **Lead magnet**: regalá un PDF/checklist/mini-curso a cambio del email

Tener 500 emails de gente interesada te vale más que 5000 visitas únicas que no convertís en nada.

### Herramientas útiles para lanzar

- **Plausible** / **Fathom**: analytics simple
- **Crisp** / **Intercom**: chat en la landing para preguntas
- **Formspree** / **ConvertKit**: captura de emails
- **Mailchimp** / **Substack**: newsletter
- **Typeform**: formularios bonitos para leads cualificados
- **Hotjar** / **Clarity** (de Microsoft, gratis): heatmaps de dónde hacen click

Microsoft Clarity es gratis y te muestra grabaciones de sesiones — ves cómo navega cada visitante real. Revelador.

### Iteración mensual (este es el secreto)

Al final del mes, revisa:

1. ¿Cuántos visitantes tuve?
2. ¿De dónde vinieron?
3. ¿Qué % convirtió?
4. ¿Qué sección genera scroll depth alto? ¿Cuál se saltan?
5. ¿Qué preguntas hacen los que me contactan?

Con eso, escribí 1-3 hipótesis de mejora para el mes siguiente. Lanzalas, medí, repetí.

Las landings que más convierten no nacen perfectas — evolucionan con datos mes a mes.

### Recap del módulo

Acabás de:

- Entender anatomía de landings que convierten
- Construir una landing con Lovable
- Comparar alternativas (v0, Framer, Carrd)
- Instalar analytics + SEO básico + traer primeros visitantes

Próximo módulo: **Hosting y dominio** — cómo tener tu propio `tumarca.com` y conectarlo a lo que construiste. Es el paso de "tengo algo publicado" a "tengo un negocio con URL propia".$md$,
    3, 70,
$md$**Instala analytics + SEO en tu landing.**

1. **Instalá Plausible** (o Vercel Analytics si usás Vercel). Pedile a Lovable/Claude Code que te meta el script.
2. **Agregá title + meta description** optimizados a tu landing
3. **Agregá Open Graph** con og:title, og:description y og:image (1200x630)
4. **Instalá Microsoft Clarity** (gratis) para ver heatmaps y grabaciones
5. **Compartí tu landing en 3 lugares distintos**: un post en LinkedIn, un post en Twitter/X y el grupo/Discord de tu nicho
6. **Observá los primeros visitantes** por 24-48h: ¿de dónde vienen? ¿qué hacen?
7. **Escribí 3 hipótesis de mejora** basadas en lo que veas

**Meta**: pasar de "landing publicada" a "landing con datos reales que guían tu próxima iteración".$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la ventaja de Plausible sobre Google Analytics para alguien que recién empieza?',
     to_jsonb(ARRAY['Es más caro','Es simple de leer (1 pantalla te da todo lo importante) y privacy-first (no requiere cookie banner molesto) — GA4 es más potente pero curva alta y requiere consentimiento GDPR','No tiene ventajas','Es solo para apps grandes']), 1, 0,
     'Plausible fue construido pensando en "dame lo esencial en 1 vistazo". Visitas, páginas, fuentes, conversión, bounce. En 30 segundos entendés qué pasa. GA4 es más potente pero requiere entender audiences, events, conversions y varias vistas — curva empinada. Al inicio lo simple gana. Cuando escalés, podés migrar a GA4 si hace falta.'),
    (v_lesson_id, '¿Por qué importa el Open Graph tag og:image en tu landing?',
     to_jsonb(ARRAY['No importa','Controla la imagen que aparece cuando alguien comparte tu link en WhatsApp, Twitter, LinkedIn — una buena imagen genera hasta 3x más clicks vs preview genérico','Solo para SEO','Para que Google te rankee']), 1, 0,
     'Cuando pegás un link en WhatsApp/Twitter/LinkedIn/Slack, aparece un preview con imagen + título + descripción. Sin og:image custom el preview es texto plano o una imagen genérica que no invita click. Una imagen bien diseñada (1200x630 ideal) sube el click-through rate significativamente. Es de las primeras optimizaciones ROI-positivas para cualquier landing.'),
    (v_lesson_id, 'Tenés <200 visitas al mes. ¿Deberías hacer A/B testing?',
     to_jsonb(ARRAY['Sí, siempre testear','No — con <200 visitas los datos son no-concluyentes (significancia estadística requiere cientos o miles de muestras). Enfocate primero en traer tráfico, después iterar con A/B','A/B siempre por obligación','Solo si pagas por herramientas caras']), 1, 0,
     'A/B testing requiere volumen para ser significativo. Con 100 visitas dividas en 2 variantes tenés 50 por versión: un solo click de diferencia te cambia la conclusión. Resultado: decisiones basadas en ruido. La prioridad con tráfico bajo es TRAER TRÁFICO (social, comunidades, SEO, ads chicos). Cuando tengas >500-1000 visitas/mes, ahí sí A/B empieza a dar conclusiones fiables.');

  RAISE NOTICE 'Módulo "Landing en 10 min": 4 lecciones + 12 quizzes insertados.';
END $$;

-- ============================================
-- FILE: seeds/track-web-02-hosting.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Builder Web" / Módulo "Hosting y dominio"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'web';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Hosting no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Dominios: qué son y cómo elegir',
$md$## Tu URL, tu identidad

Un dominio (ej. `tumarca.com`) es mucho más que una URL. Es parte de tu marca, de tu credibilidad y de cómo te ven los clientes.

### Anatomía de un dominio

`www.tumarca.com.ar`

- **www** — subdominio (opcional, casi obsoleto)
- **tumarca** — el nombre
- **.com** — TLD (Top Level Domain)
- **.ar** — country code (opcional, identifica país)

### ¿Qué extensión elegir?

En 2026, las opciones buenas:

| TLD | Cuándo usar | Notas |
|---|---|---|
| `.com` | Siempre que esté disponible | Estándar global, más confiable |
| `.co` | Si .com ocupado, alternativa fuerte | Muchos emprendimientos lo usan |
| `.io` | Productos tech / startups | Popular pero más caro |
| `.ai` | Productos de IA | Premium, caro ($50-200/año) |
| `.app` | Apps móviles/web | Google lo promueve |
| `.me` | Portfolio personal | Para sitio personal |
| `.[país]` | Negocios locales | ej .ar, .mx, .es, .co |

**Regla 2026**: .com si está disponible. Si no, .co o .io. Evitá TLDs raros (.xyz, .site, .online) — dan impresión de spam.

### Dónde comprar dominios

Registrars recomendados:

1. **[Namecheap](https://namecheap.com)** — económico, buen panel, $8-15/año para .com
2. **[Porkbun](https://porkbun.com)** — más barato aún, excelente UX, recomendado
3. **[Cloudflare Registrar](https://cloudflare.com)** — al costo (sin markup), requiere cuenta Cloudflare
4. **Google Domains** — ya no existe, fue adquirido por Squarespace (ahora en Squarespace Domains)

**Evitar**: GoDaddy (precios engañosos con upsells agresivos), Hostinger (OK pero upsells molestos).

### Reglas para elegir bien el nombre

- **Corto**: 6-14 caracteres ideal. Cada letra extra es 10% menos probabilidad de tipearlo bien
- **Fácil de pronunciar**: si lo decís al teléfono, ¿lo escribirían bien?
- **Sin guiones ni números**: "mi-marca.com" o "marca2.com" se ven amateur
- **No tropiece en ambos idiomas**: si operás ES+EN, ¿funciona en ambos?
- **Sin marcas registradas**: chequeá [TESS](https://tmsearch.uspto.gov) (USA) o registros locales

### Dominios premium: caros pero a veces valen

Algunos dominios están "estacionados" por revendedores y cuestan $500-50,000. ¿Vale?

**Sí vale cuando**:
- El negocio ya factura bien
- El dominio es genérico perfecto (ej. `photos.com`)
- Vas a invertir fuerte en branding

**No vale cuando**:
- Recién arrancás
- Hay alternativas creativas disponibles ($10/año)
- Se come 3 meses de runway

### Protección: privacy y renovación

Al comprar, activá 2 cosas:

**1. WHOIS Privacy**
Sin eso, tu nombre, email y teléfono quedan públicos — spammers te encuentran. La mayoría de registrars lo dan gratis.

**2. Auto-renew**
Si se vence, lo perdés. Un dominio vencido queda en "redemption" (60 días, recuperarlo cuesta $100+) o vuelve al pool (cualquiera lo agarra). Muchos negocios perdieron su dominio por olvidar renovar.

Alternativa más segura: pagá 5-10 años de una. Más barato total y no te preocupa.

### Subdominios: úsalos bien

Podés crear subdominios libres sobre tu dominio:

- `app.tumarca.com` → la app (para users logueados)
- `blog.tumarca.com` → el blog
- `docs.tumarca.com` → documentación
- `tumarca.com` → landing principal (marketing)

Esto separa marketing de producto. Común en productos SaaS.

### Emails con tu dominio

Tener `tu@tumarca.com` te da credibilidad infinita vs `tumarca@gmail.com`. Opciones:

- **Google Workspace** — $6/mes/usuario, estándar
- **Fastmail** — $5/mes/usuario, privacy-first
- **Zoho Mail** — free tier para 1 usuario
- **iCloud Mail** — gratis con Apple si configurás dominio custom

Configurás MX records (un tipo de registro DNS — DNS es el sistema que traduce nombres de dominio a direcciones IP) en tu registrar y listo.

### Errores comunes al elegir dominio

- **Dominio muy largo** ("la-mejor-consultoria-digital-colombia.com")
- **Extensión rara** (.xyz, .online — baja credibilidad)
- **Confusión por tilde** ("diseño.com" se pierde por tilde)
- **Olvidarse renovar** → perdés todo
- **Comprar 1 variante** sin comprar típicos (.com Y .co, o con/sin "s")
- **No chequear marcas registradas** → demanda potencial

### Qué pasa si el .com está ocupado

Alternativas (en orden de preferencia):

1. Agregá palabra ("getmimarca.com", "try[marca].com", "hello[marca].com")
2. Otro TLD fuerte (.co, .io si es tech)
3. Variante corta ("mrca.com")
4. Cambio creativo del nombre (a veces lo mejor es reformular)

Lo que NO hagas: comprar dominio idéntico con TLD raro y lanzar esperando que funcione igual. No funciona igual.

### Precio realista

Un dominio .com razonable cuesta $8-15/año nuevo.
Dominio premium existente: $500-5000 común, premium "perfecto" puede ser $10k-100k+.
Extensiones premium (.ai, .io): $30-100/año.

Presupuesto realista para arrancar: $15/año un solo dominio, $100/año si comprás variantes también (.com, .co, typos comunes).$md$,
    0, 50,
$md$**Elegí y comprá tu dominio.**

1. Usá [Namecheap](https://namecheap.com), [Porkbun](https://porkbun.com) o [Cloudflare Registrar](https://cloudflare.com) para buscar tu dominio
2. Verificá también: Instagram, X, TikTok, LinkedIn (al menos 2 de 4 libres)
3. Si .com está ocupado, intentá .co o agregá palabra ("get", "try", "hello")
4. Comprá **con WHOIS Privacy** activado y **auto-renew** ON
5. Bonus: comprá también variantes obvias de typo (ej. si tu dominio es "lumia.com", comprá "lumi.com" y "lumya.com" — $24/año evita confusión de usuarios)

**Meta**: terminar la lección con tu dominio comprado y a tu nombre, listo para conectar a tu landing en la siguiente lección.$md$,
    10)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué TLD elegís en 2026 si está disponible?',
     to_jsonb(ARRAY['.com — sigue siendo el estándar global más confiable','Cualquiera da igual','.xyz porque es barato','.tv']), 0, 0,
     '.com sigue siendo el default confiable: la gente lo asume, confía en él, y no lo confunde con spam. Si está ocupado, .co es la segunda mejor, o .io si sos tech. TLDs raros (.xyz, .site, .online, .click) levantan bandera roja — muchos sitios fraudulentos los usan y los usuarios/clientes lo asocian con spam. Tu dominio es tu primera impresión; invertí los $10/año en un .com bueno.'),
    (v_lesson_id, 'Al comprar un dominio, ¿qué dos cosas debés activar siempre?',
     to_jsonb(ARRAY['Nada especial','WHOIS Privacy (para que tus datos no queden públicos) y Auto-renew (para no perder el dominio si te olvidás pagar)','Solo SSL','Publicidad gratis']), 1, 0,
     'Sin WHOIS Privacy tu nombre, email y teléfono aparecen en cualquier herramienta de lookup — spammers y scammers te encuentran. La mayoría de registrars la ofrecen gratis. Auto-renew evita la catástrofe más común: te olvidás de pagar y perdés el dominio. Muchos negocios han perdido su identidad digital por olvidar la renovación. Alternativa segura: pagá 5-10 años de una vez.'),
    (v_lesson_id, 'El .com de tu marca está ocupado. ¿Cuál es el peor camino?',
     to_jsonb(ARRAY['Agregar palabra como "get" o "try" al nombre','Usar un TLD fuerte alternativo como .co','Comprar el mismo nombre con TLD raro (.xyz, .click, .site) y lanzar como si fuera igual','Reformular el nombre']), 2, 0,
     'Comprar .xyz o .click "porque el nombre me encanta" es tentador pero contraproducente. Los usuarios lo leen como spam o baja confianza, Google rankea peor, y cuando le digas el dominio al teléfono la gente va a tipear .com por default y no llegará. Mejores caminos: prefijo "get/try/hello", .co o .io si es tech, o reformular el nombre. En 2026 la credibilidad de tu TLD impacta conversión medible.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Hosting y deploy en 2026',
$md$## Donde vive tu sitio

Hosting es donde "corre" tu código para que el mundo lo vea. En 2026, la elección es mucho más simple que antes — casi siempre ganan las plataformas serverless.

### Hosting "tradicional" vs serverless

**Tradicional (shared hosting, VPS)**
- Alquilás un servidor, subís archivos por FTP (protocolo viejo de transferencia de archivos)
- Vos configurás todo: web server, base de datos, SSL
- Ejemplos: Bluehost, HostGator, DigitalOcean, Linode
- Para sitios modernos: más trabajo, menos escalable

**Serverless / Platform as a Service**
- Subís tu código, la plataforma se encarga del resto
- Auto-scaling, SSL automático, deploy con 1 click
- Ejemplos: Vercel, Netlify, Cloudflare Pages, Railway
- Para sitios modernos: dominante en 2026

En este módulo nos enfocamos en serverless. Es más simple, más rápido y casi siempre suficiente.

### Las 4 plataformas que importan

| Plataforma | Fuerte en | Precio |
|---|---|---|
| **Vercel** | Sites Next.js, integración perfecta con Claude Code/v0 | Free generoso, Pro $20/user/mes |
| **Netlify** | Sitios estáticos, formularios nativos | Free generoso, Pro $19/user/mes |
| **Cloudflare Pages** | Velocidad global, barato | Free muy generoso |
| **Railway** | Apps full-stack con DB, más backend | $5/mes arranque, escala según uso |

Para landings y apps React/Next.js: **Vercel** gana por integración.
Para sitios estáticos simples: **Cloudflare Pages** es imbatible en precio/velocidad.
Para apps con BD propia: **Railway** o **Fly.io**.

### Deploy desde Lovable

Si usaste Lovable, ya viste el botón "Publish". Funciona así:

1. Lovable desploga en su infraestructura
2. Te da URL `tu-proyecto.lovable.app`
3. Para dominio propio, tenés que conectar — lo vemos a continuación

### Deploy desde código (GitHub → Vercel)

El flujo estándar en 2026 si usás Claude Code:

1. Tu código está en un repo de GitHub (servicio que aloja código con control de versiones)
2. En Vercel, "Import Project" → elegís el repo
3. Vercel detecta framework (Next.js, Vite, etc.) y configura todo
4. Cada push a `main` = deploy automático

Setup total: 5 minutos. A partir de ahí, cada cambio que hagas en código y pushes, actualiza la web.

### Conectar tu dominio

**Desde Vercel:**

1. En tu proyecto → Settings → Domains → Add
2. Escribí tu dominio (ej: `tumarca.com`)
3. Vercel te muestra 2-3 DNS records para configurar

**En tu registrar (Namecheap/Porkbun):**

1. Entrás al panel del dominio → Advanced DNS
2. Agregás los records que Vercel te mostró (típicamente un A y un CNAME)
3. Guardás

**DNS propagation**: tarda 5min-2h. Mientras, tu sitio puede verse inestable. Después todo estable.

### SSL automático

Los navegadores modernos requieren HTTPS (URLs que empiezan con https://) para que el sitio se vea "seguro". Sin HTTPS, sale una alerta roja.

Plataformas serverless (Vercel, Netlify, Cloudflare) activan SSL automáticamente vía Let's Encrypt (certificados gratis). No tenés que hacer nada.

Si usás hosting tradicional, configuralo con Let's Encrypt manualmente o pagá certificado.

### Cloudflare: gratis y potente

Incluso si hospedás en Vercel, es buena idea meter **Cloudflare** delante:

- **CDN global** — tu sitio se cachea en 300+ ciudades, carga rápido en cualquier país
- **DDoS protection** — aguanta ataques
- **DNS management** — panel mejor que el de registrars
- **Caching avanzado** — mejor velocidad
- **Analytics básicos gratis**

Proceso:

1. Creá cuenta en [Cloudflare](https://cloudflare.com)
2. Agregás tu dominio
3. Cambiás nameservers en tu registrar a los de Cloudflare
4. En 24h, todo tu DNS lo maneja Cloudflare

Gratis para siempre en el plan free. Sumale 50 puntos a la velocidad de tu sitio.

### Configurar www vs no-www

Decisión: ¿tu sitio vive en `tumarca.com` o en `www.tumarca.com`?

En 2026 el default: **sin www**. Se ve más moderno, más corto, más clean.

Configurar: en DNS creás ambos (A record para raíz, CNAME para www) y Vercel/Netlify redirigen uno al otro automáticamente. Elegís cuál es el "principal" en settings.

### Subdominios prácticos

Si vas a tener varios productos/secciones:

- `tumarca.com` → landing principal (marketing)
- `app.tumarca.com` → la app real (login requerido)
- `blog.tumarca.com` → blog
- `docs.tumarca.com` → documentación

Cada subdominio puede ser un proyecto de Vercel independiente. Super flexible.

### Monitoreo básico

Servicios gratis que te avisan si tu sitio se cae:

- **UptimeRobot** — chequea cada 5 min, avisa por email
- **BetterStack** — más bonito pero con free tier
- **Pingdom** — clásico, free limitado

Al inicio UptimeRobot alcanza. No vas a saber que se cayó a las 3am si no lo tenés.

### Errores comunes al conectar dominio

- **Esperar 5 min y asumir que no funciona**: DNS tarda hasta 2h. Esperá
- **Usar A record hacia IP dinámica**: las IPs de Vercel cambian, usá CNAME o el ALIAS que te indiquen
- **No configurar tanto www como raíz**: 50% visitantes tipean www, 50% sin. Ambos deben funcionar
- **Olvidar HTTPS forzado**: configurá redirect automático http → https
- **DNS del registrar vs DNS de Cloudflare**: decidí dónde vive el DNS. Si pasaste a Cloudflare, tocá ahí (no en el registrar)

### Costos anuales realistas

Para una landing o app chica:

- Dominio: $15/año
- Vercel / Netlify / Cloudflare Pages: $0 (free tier alcanza para empezar)
- Cloudflare (opcional): $0
- Email (Google Workspace): $72/año/usuario
- Monitoreo: $0 (UptimeRobot free)

Total primer año: $15-90 según si querés email corporativo.

Cuando escales (>1M requests/mes, >100GB/mes tráfico), probablemente saltés a plan pago: $20/mes Vercel Pro o equivalente.$md$,
    1, 60,
$md$**Conectá tu dominio al proyecto.**

1. Si tu proyecto está en Lovable → Publish → luego conectá dominio custom siguiendo su guía
2. Si tu proyecto está en GitHub/Claude Code → importalo a Vercel y configurá dominio
3. En tu registrar: configurá los DNS records que la plataforma te indique
4. Verificá que tanto `tumarca.com` como `www.tumarca.com` funcionen
5. **Pedile a alguien** que abra `tumarca.com` y compruebe que se ve bien (elimina que pueda ser cache del browser tuyo)
6. **Bonus**: pasá a Cloudflare para CDN + DDoS gratis
7. **Instalá UptimeRobot** para que te avise si se cae

**Meta**: tener tu landing corriendo en `tumarca.com` con SSL, en mobile y desktop, monitoreada.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Por qué en 2026 casi todos usan hosting serverless (Vercel, Netlify) vs hosting tradicional?',
     to_jsonb(ARRAY['Es más caro','Es más simple (deploy automático con cada push), auto-scaling, SSL gratis, CDN global incluido — el tradicional requiere configurar todo a mano','No es así','Los tradicionales son mejores']), 1, 0,
     'Hace 10 años configurar hosting tradicional era la única opción. Hoy las plataformas serverless te dan deploy con 1 click, SSL automático con Let\\'s Encrypt, auto-scaling sin tocar nada y deploy automático cuando pusheas código. Todo con free tier generoso. El tradicional sigue existiendo para casos específicos pero para 90% de proyectos modernos (landings, apps, SaaS chicos) serverless gana cómodo.'),
    (v_lesson_id, 'Configurás DNS para tu dominio y no funciona inmediatamente. ¿Qué hacés?',
     to_jsonb(ARRAY['Borrar todo y empezar de cero','Esperar 5 min - 2h, DNS tarda en propagarse globalmente — si después de 2h sigue sin funcionar, revisá que los records estén correctos','Cambiar de registrar','Llamar a soporte de inmediato']), 1, 0,
     'DNS propagation tarda de 5 min a 2 horas en casos normales (algunos ISPs tardan hasta 24h en casos raros). El error más común: configurás DNS, no funciona en 5 min, entrás en pánico, lo cambiás, empeorás todo. Paciencia. Chequeá con [dnschecker.org](https://dnschecker.org) si se propagó globalmente. Si después de 2h sigue sin funcionar ahí sí revisá los records y ayuda de soporte.'),
    (v_lesson_id, '¿Cuál es el beneficio principal de meter Cloudflare delante de tu hosting (aunque uses Vercel)?',
     to_jsonb(ARRAY['Nada, es redundante','CDN global (tu sitio se cachea en 300+ ciudades = carga rápido en cualquier país), DDoS protection, DNS mejor — todo gratis en plan free','Es más lento','Solo sirve para sitios grandes']), 1, 0,
     'Vercel ya tiene CDN bueno, pero Cloudflare free tier agrega protección DDoS, analytics, caching avanzado y un panel de DNS mejor que casi todos los registrars — todo sin costo. Para sitios con tráfico internacional, Cloudflare + Vercel es el combo estándar. El único riesgo: si configurás mal el caching, podés servir versión vieja del sitio. Pero con opciones por defecto es seguro.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Email corporativo y productividad',
$md$## Del "@gmail" al "@tumarca"

Tener `tu@tumarca.com` en tu firma cambia cómo te perciben clientes, inversores y prospects. Es una de las pequeñas cosas que separan "hobby" de "negocio serio".

### Opciones de email corporativo

**Google Workspace** — $7/usuario/mes
- Gmail con tu dominio, Drive, Calendar, Meet, Docs
- Estándar empresarial mundial
- Excelente filtro de spam, integraciones infinitas
- Mi recomendación para 90% de casos

**Microsoft 365 Business** — $6/usuario/mes
- Outlook + Teams + Word/Excel/PowerPoint + OneDrive
- Mejor para empresas que ya usan stack Microsoft
- Teams para comunicación interna

**Zoho Mail** — gratis hasta 5 usuarios con límites
- Opción si sos solo y no querés pagar
- Interfaz menos pulida pero funcional

**Fastmail** — $5/usuario/mes
- Privacy-first, sin escanear emails
- Buena opción para equipos que valoran privacidad

### Configurar Google Workspace con tu dominio

Pasos simplificados:

1. Comprá [Google Workspace](https://workspace.google.com), elegí plan Business Starter ($7/user/mes)
2. Google te pide verificar tu dominio agregando un TXT record en DNS
3. Después, Google te da MX records para configurar también
4. Configurás MX records en tu registrar (o en Cloudflare si usás)
5. En 1-2h los emails a `@tumarca.com` llegan a tu Gmail Workspace

**Tip**: creá alias gratis — `hola@`, `info@`, `ventas@`, `soporte@` todos pueden ir a la misma inbox. Se ve profesional.

### Firma de email profesional

Una buena firma incluye:

- Tu nombre completo
- Tu rol + marca
- Link al sitio web
- Link a perfiles sociales profesionales (LinkedIn, X)
- Opcional: foto profesional pequeña
- Opcional: teléfono si aplica

Evitá:
- Frases inspiracionales largas ("La vida es como...")
- Disclaimers legales de 10 párrafos (típico de corporaciones)
- Tipografías raras o colores vibrantes

Usá [HoneyBook](https://honeybook.com) o [WiseStamp](https://wisestamp.com) para firmas bonitas, o escribilas a mano en HTML simple.

### Email deliverability: que tus emails no caigan en spam

Cuando mandás emails desde tu dominio (en especial los automáticos, como confirmaciones de compra o newsletter), Gmail/Outlook deciden si llegan a inbox o a spam.

Lo que los deja tranquilos:

**1. SPF record** — autoriza qué servidores pueden mandar en nombre de tu dominio
**2. DKIM record** — firma criptográfica para verificar autenticidad
**3. DMARC record** — política de qué hacer si SPF/DKIM fallan

Google Workspace te da estos 3 al configurar el dominio. Instalalos en DNS. Sin ellos tus emails automáticos pueden ir a spam.

**Chequeo**: mandá un mail a [mail-tester.com](https://mail-tester.com), te da un score sobre 10. Buscá 9+.

### Herramientas de productividad que suelen acompañar

Cuando tenés tu dominio configurado, solés querer:

- **Notion** o **Obsidian** — documentación interna, notas, wiki
- **Linear** o **Height** — gestión de tareas/tickets
- **Slack** o **Discord** — chat interno (si equipo >1)
- **Calendly** o **Cal.com** — agenda pública para clientes
- **Stripe** — cobros online
- **HubSpot** o **Notion con CRM** — gestión de clientes

No necesitas todo day 1. Pero saber que existen te deja planear.

### Email marketing vs email transaccional

Dos tipos distintos:

**Transaccional**: emails automáticos por acciones (confirmación de compra, reset password, onboarding)
- Herramientas: **Resend**, **Postmark**, **AWS SES**
- Precio: $0.001/email aprox
- Alta deliverability porque son "esperados"

**Marketing**: emails a tu lista (newsletter, promociones)
- Herramientas: **Mailchimp**, **ConvertKit**, **Beehiiv**, **Substack**
- Precio según tamaño de lista
- Requieren consentimiento explícito (GDPR/CAN-SPAM)

Para un negocio serio vas a usar las dos herramientas distintas. Mezclarlas no funciona bien.

### Protección contra ataques

Algunos básicos de seguridad:

- **2FA (two-factor authentication) en tu Workspace** — obligatorio, no opcional
- **Dominio privado en registrar** — ya lo activaste en lección 1
- **No pongas tu email personal en signup de servicios random** — usá un alias
- **Revisá actividad sospechosa** — Google Workspace tiene panel de seguridad

Si sos negocio con ingresos reales, considerá seguro cibernético básico. Los ataques a pequeños negocios aumentaron mucho.

### Google Workspace Admin: 3 configuraciones iniciales

Una vez tenés Workspace:

1. **Habilitá 2FA obligatorio** para todos los usuarios
2. **Configurá alias comunes** (hola@, info@, soporte@)
3. **Configurá catch-all** (opcional) — cualquier email a `*@tumarca.com` llega a tu inbox principal

Eso te deja solo configurar una vez y olvidarte.

### Nivel avanzado: email con tu marca automatizado

Para scaled businesses:

- **Welcome sequence** — nuevo user recibe 5 emails durante 2 semanas
- **Abandoned cart** — si agregaron al carrito y no compraron, reminder en 24h
- **Re-engagement** — users inactivos 30 días reciben mail
- **Newsletter automatizada** — con contenido dinámico

Esto se construye con ConvertKit/Mailchimp + Zapier o n8n para los triggers. Es el siguiente nivel después de "ya tengo email corporativo". Lo vemos en el track de n8n.$md$,
    2, 60,
$md$**Configurá tu email corporativo.**

1. Comprá **Google Workspace** (o alternativa que prefieras). El costo de 1 mes ($7) vale la pena para tener email pro
2. Configurá tu dominio siguiendo su guía (MX records, SPF, DKIM, DMARC en DNS)
3. Creá 3-4 alias: `hola@`, `info@`, `soporte@`, `ventas@` (todos llegando a tu inbox)
4. Creá tu **firma profesional** (texto simple: nombre, rol, web, LinkedIn)
5. **Test deliverability**: mandate un email desde `@tumarca.com` a un email externo. Confirmá que no cae en spam
6. Mandá uno a [mail-tester.com](https://mail-tester.com) — objetivo: 9+ puntos
7. Activá **2FA** en tu cuenta admin

**Meta**: tener `tu@tumarca.com` funcionando desde tu Gmail/Outlook habitual, con firma pro y configuración anti-spam.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la razón por la que tus emails automáticos pueden caer en spam aunque el contenido sea normal?',
     to_jsonb(ARRAY['Mala suerte','Falta configurar SPF, DKIM y DMARC en tu DNS — son 3 registros que autentican que tu dominio puede mandar esos emails','Usás Mac','Nada, siempre caen']), 1, 0,
     'Gmail/Outlook evalúan si el email es legítimo antes de decidir inbox vs spam. SPF dice "estos servidores pueden mandar emails en nombre de tumarca.com". DKIM firma el email criptográficamente. DMARC dice "si SPF/DKIM fallan, hacé X". Sin los 3, los proveedores dudan y mandan a spam por seguridad. Google Workspace te da los valores exactos al configurar el dominio.'),
    (v_lesson_id, 'Mandás emails transaccionales (confirmaciones, resets) desde tu app. ¿Qué herramienta usás?',
     to_jsonb(ARRAY['Mailchimp','Resend, Postmark o AWS SES — especializadas en transaccional (alta deliverability, API simple, $0.001/email aprox)','Tu Gmail personal','Nada, lo hace tu registrar']), 1, 0,
     'Mailchimp/ConvertKit son para marketing (newsletters, promos) — tienen regulaciones específicas, listas opt-in, y caen en spam si las usás para transaccional. Para emails automáticos de acción del usuario (bienvenida, reset password, confirmación compra), usás herramientas especializadas: Resend, Postmark, SES. Se integran a tu app por API y tienen deliverability 99%+.'),
    (v_lesson_id, 'En tu Google Workspace, ¿qué es un "alias" y para qué sirve?',
     to_jsonb(ARRAY['Una cuenta adicional pagada','Un email adicional que recibe a tu inbox principal (ej. hola@ info@ soporte@ todos llegando al mismo inbox) — gratis, hasta 30 alias por usuario','Un backup de tu email','Lo mismo que una cuenta normal']), 1, 0,
     'Los alias son emails gratis que redirigen a tu inbox principal. En vez de crear 5 usuarios (5 × $7 = $35/mes), tenés 1 usuario con 5 alias ($7/mes total). Típico setup: `hola@` recibe contacto general, `info@` para FAQs, `ventas@` para leads, `soporte@` para tickets. Todos llegan a vos, pero el que manda ve una dirección profesional específica. Gmail Workspace permite hasta 30 alias por usuario.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Seguridad, backups y mantenimiento',
$md$## Lo que nadie hace hasta que es tarde

Tu sitio está arriba, tu dominio configurado, email funcionando. Pero un solo error puede tirarlo todo: hackeo, dominio vencido, BD corrupta, deploy que rompió todo. Esta lección: la higiene para evitar desastres.

### La trinidad del desastre

Los 3 escenarios más comunes que destruyen proyectos:

1. **Olvidar renovar el dominio** → perdés la URL, todas tus campañas mueren
2. **Hackeo de cuenta** (email, registrar o hosting) → puede robarte todo
3. **Deploy que rompió producción** (y no tenés backup) → horas de downtime, clientes furiosos

Los 3 son 100% prevenibles con higiene básica.

### 2FA en todo

Two-factor authentication (requerir código de tu teléfono o app además de la contraseña) es el setting más importante de seguridad.

Activalo en:
- Registrar (Namecheap, Porkbun, Cloudflare)
- Hosting (Vercel, Netlify)
- GitHub (donde vive tu código)
- Google Workspace / Microsoft 365
- Stripe / procesador de pagos
- Banco y cuentas críticas

Preferí **apps de autenticación** (Google Authenticator, Authy, 1Password) sobre SMS. SMS es vulnerable a SIM swapping (un ataque donde roban tu número).

### Passwords: deja de reutilizarlas

Si usás la misma password en 10 sitios, uno solo comprometido compromete los 10.

Password manager obligatorio. Opciones:

- **1Password** — premium, familia $5/mes, interfaz excelente
- **Bitwarden** — open source, free tier generoso
- **Proton Pass** — si usás Proton Mail

Genera passwords de 20+ caracteres, únicas por sitio. El manager las llena por vos. 1 hora de setup inicial ahorra horas de pesadilla futura.

### Backups de lo crítico

Qué respaldar:

**1. Código fuente** → ya está en GitHub (repo es el backup)
**2. Base de datos** → backup automático
- Supabase: tiene backups automáticos diarios en plan Pro (7 días). Free tier no.
- Otras BD: configurar backup propio

**3. Imágenes y assets** → si están en S3, CloudFlare R2 o similar, configurá versioning

**4. Emails** → Google Workspace los respalda pero podés hacer export manual con Google Takeout

**5. Configs** → DNS records, API keys, variables de entorno. Guardalas en 1Password/Bitwarden.

Regla: si lo perdiera mañana, ¿cuánto me dolería? Lo que más duela, respaldá.

### Deploy seguro: staging + preview

Nunca pushees directo a producción. El flujo sano:

1. **Branch de feature**: hacés cambios en rama separada (no `main`)
2. **Preview deploy**: Vercel/Netlify auto-despliegan la rama a una URL preview
3. **Testeás** en la preview
4. **Merge a main** cuando confirma
5. **Deploy a prod** automático al mergear

Si algo sale mal, revertís el merge y producción vuelve. 30 segundos para recuperar.

Sin este flujo, un bug en código rompe tu sitio live hasta que lo arregles.

### Monitoreo real

Más allá de UptimeRobot:

- **Sentry** — te avisa cada vez que tu app tira un error en producción. Gratis hasta cierto volumen
- **Logtail / Better Stack Logs** — logs centralizados
- **Vercel Analytics** — tráfico y performance
- **Stripe dashboard** — si cobrás, notificaciones de pagos fallidos

Configurar Sentry en 10 min te ahorra descubrir bugs porque un usuario se quejó. Los ves vos primero.

### Rotación de secrets

Tus API keys (AI keys, Stripe keys, DB credentials) eventualmente se filtran por error: pusheás una por accidente a un repo público, un colaborador se va, o una herramienta se compromete.

Plan:

- Guardá secrets en variables de entorno (`.env` local, settings de la plataforma en prod)
- **Nunca** las commitees a Git (agregá `.env` a `.gitignore`)
- Si una se filtra: revocala de inmediato y generá nueva
- Cada 6-12 meses: rotalas aunque no haya incidente

Chequeo rápido: buscá en tu repo ("API_KEY=", "SECRET=") — si hay cosas escritas a mano, movelas a env vars ya.

### GDPR / privacidad

Si tenés usuarios en Europa (o en Argentina/Latam con leyes equivalentes), hay mínimos legales:

- **Política de privacidad** — qué datos recolectás y por qué
- **Términos y condiciones** — reglas de uso
- **Cookie banner** — si usás cookies no-esenciales
- **Right to delete** — podés borrar todos los datos de un user si lo pide
- **Data export** — podés entregarle sus datos si lo pide

Servicios como [Termly](https://termly.io) o [Iubenda](https://iubenda.com) generan estos docs por $10/mes.

Pedirle a Claude tu política de privacidad base puede ahorrar $50 de abogado — revisala antes de publicarla con alguien que sepa si es mercado regulado.

### El calendario de mantenimiento

Marcá en tu agenda (cada X meses):

**Mensual:**
- Revisar analytics — qué funciona, qué no
- Testear flujos críticos (signup, checkout, etc.)
- Revisar errores en Sentry

**Trimestral:**
- Actualizar dependencias (`npm update`)
- Revisar costos de servicios
- Auditar accesos (quién tiene acceso a qué)

**Anual:**
- Renovar dominio (ideal: 5+ años de una)
- Rotar secrets
- Revisar política de privacidad
- Backup manual de todo lo crítico
- Auditar tu stack: ¿usás todo lo que pagás?

### Recap del módulo

Ya tenés:

- Dominio comprado y protegido
- Hosting serverless configurado
- DNS funcionando
- SSL automático
- Email corporativo con anti-spam
- Seguridad básica (2FA, password manager, backups)

Próximo módulo: **Sitio completo** — pasás de landing simple a sitio con múltiples páginas, navegación, formularios serios e integraciones. Esto es cuando tu URL ya no es "una landing" sino un sitio de verdad.$md$,
    3, 70,
$md$**Implementá la higiene de seguridad.**

Checklist:

1. **Activa 2FA** en: registrar, hosting, GitHub, email (Google Workspace), procesador de pagos. **Usa app de autenticación, no SMS**
2. **Configurá un password manager** (1Password o Bitwarden) — migrá al menos las 10 passwords más críticas
3. **Revisá variables de entorno**: ¿hay alguna API key hardcodeada en código? Moverla a env vars
4. **Instalá Sentry** en tu proyecto Lovable/Next.js — te va a avisar de errores en prod
5. **Configurá UptimeRobot** si no lo hiciste
6. **Agendá reminders**: renovación dominio, actualización dependencias trimestral
7. **Bonus**: corré [Have I Been Pwned](https://haveibeenpwned.com) con tu email — ¿ya salió en algún leak? Si sí, cambiá las passwords afectadas

**Meta**: dormir tranquilo sabiendo que un olvido o hackeo no te hace perder meses de trabajo.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '2FA por SMS es mejor que por app de autenticación:',
     to_jsonb(ARRAY['Sí, es más simple','Falso — SMS es vulnerable a SIM swapping (atacantes roban tu número). Apps como Google Authenticator o Authy son mucho más seguras','Son iguales','No importa']), 1, 0,
     'SIM swapping es un ataque real y creciente: el atacante convence a la compañía telefónica de transferir tu número a su SIM (con social engineering o empleados corruptos), y ahora recibe tus códigos SMS. Con eso accede a todo lo que tengas SMS 2FA. Apps de autenticación (TOTP) generan códigos offline en tu dispositivo — el atacante necesita físicamente el dispositivo. Cambiá SMS por app en todo lo crítico.'),
    (v_lesson_id, 'Hacés un cambio importante en tu código. ¿Cómo deployás sin riesgo a producción?',
     to_jsonb(ARRAY['Pushear directo a main','Crear branch de feature, Vercel/Netlify generan preview URL automática, testeás ahí, mergear a main cuando confirmás — si algo sale mal, revertís el merge','Esperar al fin de semana','No deployear nunca']), 1, 0,
     'El flujo seguro: branch de feature → preview deploy automático → testeás → merge a main → deploy automático a producción. Si un bug llega a prod, revertís el merge en GitHub y producción vuelve en 30 segundos. Pushear directo a main sin testear es cómo una empresa se rompe el servidor por un typo. Las plataformas modernas te dan preview deploys gratis — es negligente no usarlos.'),
    (v_lesson_id, '¿Qué hacés si una API key tuya se filtró accidentalmente en un repo público?',
     to_jsonb(ARRAY['Borrar el commit y fingir que no pasó','Revocar inmediatamente la key desde el proveedor y generar una nueva — asumí que fue comprometida aunque borres el commit, porque ya fue scrapeada por bots','Cambiar el nombre del repo','Nada, no importa']), 1, 0,
     'Los repositorios públicos son escaneados permanentemente por bots buscando secrets. Una key expuesta 5 segundos ya fue registrada por varios scrapers. Aunque la borres del commit (incluso del historial con rebase), asumí que está comprometida: revocala del proveedor y generá nueva de inmediato. Además, configurá GitHub secret scanning para que te avise si pasa de nuevo. Git filter-branch para "limpiar" historial es inútil si ya fue robada.');

  RAISE NOTICE 'Módulo "Hosting y dominio": 4 lecciones + 12 quizzes insertados.';
END $$;

-- ============================================
-- FILE: seeds/track-web-03-sitio.sql
-- ============================================
-- =============================================
-- IALingoo — Track "Builder Web" / Módulo "Sitio completo"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'web';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Sitio completo no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'De landing a sitio completo',
$md$## Cuando una página ya no alcanza

Una landing sirve para un producto, un objetivo, una campaña. Pero a veces necesitás más: **un sitio completo** con varias páginas, navegación, blog, sección de clientes, contacto.

### ¿Necesitás un sitio o te alcanza una landing?

| Situación | Solución |
|---|---|
| Vendés un producto único | Landing |
| Curso / infoproducto | Landing + checkout |
| Consultoría / servicios múltiples | Sitio (3-5 páginas) |
| Marca con catálogo / blog | Sitio completo |
| Ecommerce | Sitio + tienda (Shopify, etc) |
| Portfolio profesional | Sitio (3-4 páginas) |

**Regla 2026**: empezá con landing. Si crece, expandís.

### Arquitectura típica de un sitio

Las páginas estándar de cualquier sitio:

1. **Home** — hero + propuesta + secciones resumen + CTAs
2. **Sobre** — historia, equipo, valores, fotos
3. **Servicios** / **Productos** — detalle de lo que ofrecés
4. **Casos** / **Clientes** — prueba social profunda
5. **Blog** — contenido que atrae tráfico orgánico (SEO)
6. **Contacto** — formulario + datos de contacto

No todos los sitios necesitan las 6. Un freelancer consultor puede tener Home + Sobre + Casos + Contacto (4 páginas).

### Sitemap: mapea antes de construir

Un sitemap es un diagrama jerárquico de las páginas y cómo conectan. Antes de generar nada en Lovable/v0, armá el sitemap:

```
Home
├── Sobre nosotros
├── Servicios
│   ├── Servicio A
│   ├── Servicio B
│   └── Servicio C
├── Casos de éxito
├── Blog
│   └── [posts individuales]
└── Contacto
```

Esto te evita rework cuando el builder AI te genera estructura y después querés agregar páginas.

### Decisión importante: ¿estático o dinámico?

**Sitio estático**:
- Todas las páginas escritas a mano (HTML generado)
- Fácil de hacer, rápido, barato
- Ideal: hasta ~15 páginas fijas

**Sitio dinámico**:
- Páginas generadas desde base de datos o CMS (sistema de gestión de contenido — software para administrar el contenido del sitio sin tocar código)
- Ideal: catálogos, blogs con 20+ posts, directorios

En 2026, para la mayoría de casos: **sitio estático con builder AI** (Lovable, v0, Framer). Si necesitás blog, agregás Notion o Sanity como CMS.

### Navegación: el esqueleto que todos ven

El **header** (barra superior) es la primera cosa que el usuario ve y la que usa para navegar. Reglas:

- **Máximo 5-6 items** en el menú principal
- **Logo a la izquierda**, menú a la derecha
- **CTA destacado** (ej. "Contactanos" o "Agendar demo") al final del menú, en botón de color
- **Responsive**: en mobile se convierte en menú hamburguesa (el ícono de 3 líneas)

El **footer** (barra inferior) suele tener:
- Links secundarios (Términos, Privacidad, FAQ)
- Redes sociales
- Dirección / contacto
- Copyright
$md$,
    0, 50,
$md$**Armá el sitemap de tu sitio** en un papel o Notion.

- Decidí cuántas páginas: home + ¿qué más?
- Dibujá la jerarquía (qué depende de qué)
- Listá el menú principal (max 5-6 items)
- Pensá el CTA destacado del header

Compartílo en papel/digital. Si no sabés qué sitio, usá el ejemplo de "consultoría de IA".$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo conviene una landing en vez de un sitio completo?',
   '["Siempre que tengas marca", "Cuando vendés un producto único o hacés una campaña específica", "Nunca — siempre mejor un sitio", "Solo en mobile"]'::jsonb,
   1, 0, 'Landing = un objetivo. Sitio = multiples secciones (servicios, blog, casos).'),
  (v_lesson_id, '¿Qué es un sitemap?',
   '["El mapa físico de la oficina", "Diagrama jerárquico de las páginas y cómo conectan", "Un archivo de Google Maps", "La URL del sitio"]'::jsonb,
   1, 1, 'El sitemap ordena la estructura antes de construir — evita rework.'),
  (v_lesson_id, '¿Cuántos items máximo conviene tener en el menú principal?',
   '["2-3", "5-6", "10-12", "Tantos como páginas haya"]'::jsonb,
   1, 2, 'Más de 6 items confunde al usuario y se ve saturado.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Navegación, layout y responsive',
$md$## El diseño que no se ve, pero funciona

Un buen layout (disposición visual de los elementos en la página) es invisible: el usuario llega, encuentra lo que busca, y ni se da cuenta del diseño. Un mal layout distrae, confunde, expulsa.

### Layout típico de una página

```
┌─────────────────────────────────┐
│  Header (logo + menú + CTA)     │
├─────────────────────────────────┤
│                                 │
│  Hero (título + imagen + CTA)   │
│                                 │
├─────────────────────────────────┤
│  Sección 1 (beneficios)         │
├─────────────────────────────────┤
│  Sección 2 (testimonios)        │
├─────────────────────────────────┤
│  Sección 3 (FAQ)                │
├─────────────────────────────────┤
│  CTA final                      │
├─────────────────────────────────┤
│  Footer (links + contacto)      │
└─────────────────────────────────┘
```

Cada sección tiene aire (espacio en blanco), un título, contenido, a veces un CTA local.

### Reglas de layout que funcionan

1. **Aire, mucho aire.** El espacio en blanco no se desperdicia — descansa los ojos y destaca el contenido.
2. **Jerarquía visual clara.** Títulos grandes, subtítulos medianos, texto chico. Un solo H1 por página.
3. **Ancho máximo del contenido.** Texto no debe ocupar más de ~750px de ancho, ilegible si es más largo.
4. **Alineación consistente.** Todo alineado a la izquierda, o todo centrado. No mezcles sin razón.
5. **Un CTA principal por sección.** Si hay 3 botones distintos, el usuario no sabe cuál tocar.

### Responsive: el diseño adapta al dispositivo

**Responsive** significa que el sitio se ve bien en mobile, tablet y desktop automáticamente. En 2026, >60% del tráfico es mobile. No-negociable.

Cosas que cambian en mobile:
- El menú se convierte en hamburguesa (ícono ☰)
- Las columnas se apilan verticalmente
- Los tamaños de fuente se ajustan
- Las imágenes se reducen
- Los padding/margin (espacios internos/externos) se achican

**Todos los builders AI de 2026 generan sitios responsive por defecto.** Lo único que tenés que hacer es **probarlo en tu teléfono** antes de publicar.

### Dark mode: ¿vale la pena?

En 2026 el 70% de usuarios usan modo oscuro en sus dispositivos. Ofrecer dark mode en tu sitio ayuda:

- Menos fatiga visual de noche
- Se ve moderno
- Ahorra batería en pantallas OLED

**Pero**: agrega complejidad. Si es tu primer sitio, dejalo para versión 2.

### Velocidad: la métrica invisible

Los sitios lentos pierden conversión. Google mide 3 métricas principales (Core Web Vitals):

- **LCP** (Largest Contentful Paint): cuánto tarda en cargar lo principal — ideal <2.5s
- **INP** (Interaction to Next Paint): cuánto tarda en responder a tu click — ideal <200ms
- **CLS** (Cumulative Layout Shift): cuánto saltan los elementos al cargar — ideal <0.1

Para verificar, usá [PageSpeed Insights](https://pagespeed.web.dev). Pegás tu URL y te da un puntaje (0-100) + sugerencias.

**En 2026**, los sitios generados con Lovable/v0 sobre Next.js suelen dar 85-95. No te obsesiones con llegar a 100.

### Prompt para generar navegación pulida en Lovable

```
Implementa un header fijo (sticky) con:
- Logo "[NOMBRE]" a la izquierda
- Links: Inicio, Servicios, Casos, Blog, Contacto
- Botón CTA "Agendar demo" en color primario
- Versión mobile: menú hamburguesa con drawer lateral
- Transición suave al hacer scroll: background semi-transparente con blur

Implementa un footer con:
- Columna 1: logo + tagline + redes (LinkedIn, Twitter, Instagram)
- Columna 2: links navegación (repiten header)
- Columna 3: legales (Términos, Privacidad, FAQ)
- Columna 4: contacto (email + ubicación)
- Fila inferior: copyright + "Hecho con ❤️ en [CIUDAD]"
```
$md$,
    1, 60,
$md$**Agregá navegación completa a tu sitio/landing.**

1. Abrí tu proyecto en Lovable/v0
2. Pedí header responsive + footer con el prompt de arriba
3. **Probá en mobile**: abrí DevTools (F12 → ícono de celular) y simulá iPhone
4. Corré PageSpeed Insights con la URL de Lovable — apuntá a puntaje >85
5. Screenshot del antes/después del PageSpeed$md$,
    18)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué significa que un sitio sea responsive?',
   '["Que responde rápido", "Que se adapta automáticamente a mobile, tablet y desktop", "Que tiene animaciones", "Que usa IA"]'::jsonb,
   1, 0, 'Responsive = diseño adapta al tamaño de pantalla. Con >60% del tráfico mobile en 2026, es obligatorio.'),
  (v_lesson_id, '¿Qué mide el LCP en los Core Web Vitals?',
   '["Cantidad de clicks", "Cuánto tarda en cargar el elemento principal", "Cuántas imágenes tiene", "El color dominante"]'::jsonb,
   1, 1, 'LCP (Largest Contentful Paint) = cuánto tarda en cargar lo más grande visible. Ideal <2.5s.'),
  (v_lesson_id, '¿Cuántos H1 debería tener una página?',
   '["Uno por sección", "Exactamente uno por página", "Al menos 5", "Ninguno"]'::jsonb,
   1, 2, 'Un solo H1 por página es la regla SEO y de accesibilidad. Los demás títulos van como H2, H3.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Formularios e integraciones reales',
$md$## Sin formulario, no hay conversión

Un formulario es donde tu visitante se convierte en lead (posible cliente que dejó sus datos). Sin formulario funcional, tu sitio es una tarjeta de visita glorificada.

### Tipos de formulario

| Tipo | Cuándo usar | Ejemplo |
|---|---|---|
| Contacto simple | Freelancers / servicios | Nombre + email + mensaje |
| Lead magnet | Infoproducto / SaaS (software como servicio) | Email a cambio de ebook/demo |
| Booking / cita | Consultoría / coaches | Calendario + form |
| Checkout | Venta directa | Producto + pago |
| Waitlist | Pre-lanzamiento | Solo email |

### Opción 1: Formulario sin backend (sin código servidor)

La opción más simple: usás un servicio externo que recibe el envío y te lo manda al email o a una hoja de cálculo.

Servicios recomendados 2026:

- **[Formspree](https://formspree.io)** — gratis hasta 50 envíos/mes, simple de integrar
- **[Getform](https://getform.io)** — similar, también tier gratis
- **[Tally](https://tally.so)** — forms estilo Typeform, embed + gratis
- **[Fillout](https://fillout.com)** — más opciones condicionales, gratis

Cómo funciona:
1. Creás cuenta en Formspree
2. Te dan una URL tipo `https://formspree.io/f/abcd1234`
3. En tu formulario HTML, el `action` apunta a esa URL
4. Cada envío te llega al email

**Ventaja**: cero código backend. Ideal para MVP.
**Desventaja**: tier gratis limitado, marca en el email.

### Opción 2: Formulario con Supabase (backend propio)

Si querés control total, guardás los envíos en tu propia base de datos (Supabase). Esto lo vemos en profundidad en el track **"Data y bases"**, pero el flujo es:

1. Tabla `contactos` en Supabase (nombre, email, mensaje, fecha)
2. Formulario → envía vía JavaScript a Supabase
3. Los datos quedan en tu panel, los podés exportar a Excel

### Opción 3: Formulario + n8n (automatización)

Lo más potente en 2026: el formulario dispara un **webhook** (una URL que recibe datos y ejecuta una acción automática) a n8n y n8n hace la magia:

- Guarda el lead en Google Sheets
- Manda email de bienvenida con IA personalizado
- Crea tarea en Notion / Trello
- Manda mensaje a Slack del equipo
- Agrega contacto a CRM (sistema de gestión de clientes)

Esto es lo que construimos en el track **"n8n y automatización"**.

### Booking con Calendly o Cal.com

Para agendar citas, no reinventes la rueda:

- **[Cal.com](https://cal.com)** — open source, gratis, moderno (recomendado 2026)
- **[Calendly](https://calendly.com)** — veterano, premium

Ambos te dan un link (`cal.com/tuusuario/30min`) que embed en tu sitio. El visitante elige horario, te llega invitación a Google Calendar automática.

### Pagos: Stripe Checkout es la respuesta

Para cobrar online (cursos, consultorías, productos digitales), **[Stripe](https://stripe.com)** es el estándar de 2026:

- Tarifa: 2.9% + $0.30 por transacción (Colombia/Argentina similar)
- Checkout hosteado: no tenés que construir nada, pegás un botón que lleva a su página segura
- Acepta tarjetas, Apple Pay, Google Pay, transferencias

Alternativas locales:
- **Mercado Pago** (LATAM) — 4-5% pero soporta efectivo y cuotas
- **Wompi / PayU** (Colombia) — similar
- **Flow / Webpay** (Chile)

**Para productos digitales globales**: Stripe.
**Para mercado local con cuotas**: Mercado Pago.

### Prompt para formulario profesional en Lovable

```
Agregá una sección "Contacto" con:

- Título: "Hablemos"
- Subtítulo: "Respondemos en menos de 24h"
- Formulario con campos:
  * Nombre (requerido)
  * Email (requerido, validar formato)
  * Empresa (opcional)
  * ¿Cómo podemos ayudarte? (textarea requerido)
- Botón "Enviar mensaje" (color primario)
- Integración: action del form apunta a https://formspree.io/f/MIID
- Mensaje de éxito después del envío
- Validación inline (errores rojos debajo del campo)

Del lado derecho (o debajo en mobile):
- Email visible: hola@marca.com
- WhatsApp con link wa.me/...
- Ubicación
```
$md$,
    2, 70,
$md$**Agregá un formulario funcional a tu sitio.**

1. Creá cuenta en [Formspree](https://formspree.io) o [Tally](https://tally.so)
2. Copiá tu URL única del form
3. En Lovable, pedí la sección de contacto con el prompt de arriba (reemplazá `MIID`)
4. Hacé un envío de prueba desde el sitio
5. Confirmá que te llegó al email
6. Agregá un link de Cal.com para agendar demo (opcional)$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es el servicio más simple para recibir envíos de un formulario sin código backend?',
   '["Stripe", "Formspree", "Calendly", "GitHub"]'::jsonb,
   1, 0, 'Formspree (o Tally, Getform) reciben el envío del form y te lo mandan por email. Cero backend.'),
  (v_lesson_id, '¿Qué procesador de pagos es estándar global en 2026?',
   '["PayPal", "Bitcoin", "Stripe", "Venmo"]'::jsonb,
   2, 1, 'Stripe es el estándar global. Para LATAM con cuotas, Mercado Pago es fuerte.'),
  (v_lesson_id, '¿Qué es un webhook?',
   '["Un link de afiliado", "Una URL que recibe datos y ejecuta una acción automática", "Un tipo de virus", "Un plugin de WordPress"]'::jsonb,
   1, 2, 'Webhook = URL pública que otra app usa para notificarte o mandarte datos. Esencial en automatización.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Blog, SEO y contenido dinámico',
$md$## Un sitio vivo pesa más que uno estático

Google ama los sitios que publican contenido útil de forma constante. Un sitio sin blog es más difícil de posicionar. Un sitio con blog bien hecho puede duplicar su tráfico orgánico (visitas gratis desde Google) en 6 meses.

### ¿Necesitás blog?

| Tu negocio | ¿Blog? |
|---|---|
| Servicios (consultoría, freelance) | Sí — casos de éxito + lecciones |
| Infoproducto / curso | Sí — contenido que previsualiza la transformación |
| Software / SaaS | Sí — tutoriales + comparativas |
| Producto físico local | Quizás — solo si hay búsquedas relevantes |
| Portfolio personal | Opcional — proyectos ya cuentan |

### Opción 1: Blog estático (archivos en carpeta)

Lovable/v0 pueden generar un blog donde cada post es un archivo. Cada vez que escribís nuevo, edita en el código y redeploys.

**Pro**: simple, rápido, SEO-friendly de entrada.
**Contra**: requiere saber cómo redeploy cada vez.

### Opción 2: Notion como CMS (recomendado 2026)

Escribís tus posts en Notion (herramienta de notas) y se publican automáticamente en tu sitio.

Herramientas que conectan Notion → Web:
- **[Super.so](https://super.so)** — convierte una página Notion en sitio completo ($12/mes)
- **[Potion.so](https://potion.so)** — similar, más customizable
- **[Feather](https://feather.so)** — específico para blog, integra con Ghost ($39/mes)

Flujo:
1. Tenés tu sitio principal en Lovable
2. Tu blog vive en `tumarca.com/blog` pintado con Super.so
3. Escribís post en Notion → aparece automáticamente publicado
4. No tocás código

### Opción 3: Sanity / Contentful / Strapi (profesional)

Si planeás tener equipo de content marketing, un CMS "de verdad" te da:
- Editor visual para redactores sin conocimientos técnicos
- Flujo de revisión (borrador → review → publicar)
- Versiones, schedule, multi-idioma

**[Sanity](https://sanity.io)** es el favorito de 2026 para equipos con developers. Gratis hasta cierto volumen.

### SEO: lo básico que importa en 2026

SEO (Search Engine Optimization — optimización para buscadores como Google) es lo que hace que la gente te encuentre gratis. En 2026, con el auge de AI Search (ChatGPT, Perplexity, Google AI Overview), el SEO clásico mutó pero siguen siendo fundamentales:

**Técnico**:
- **Meta title** (60 chars max) y **meta description** (155 chars) bien escritos por página
- **URLs limpias**: `tumarca.com/servicios/consultoria-ia` no `?id=324`
- **Schema markup** (datos estructurados — código oculto que le explica a Google qué es cada cosa) — Lovable lo genera solo
- **Sitemap.xml** y **robots.txt** — auto-generado por el builder
- **Velocidad** (Core Web Vitals, que vimos)

**Contenido**:
- **Headings jerárquicos**: H1 > H2 > H3
- **Palabras clave naturales**: no keyword stuffing
- **Long-form** (>1000 palabras) para artículos importantes
- **Imágenes con alt text** (texto alternativo que describe la imagen)
- **Links internos** entre tus posts
- **Autoridad**: links desde otros sitios hacia vos (backlinks)

**Herramientas gratis**:
- [Google Search Console](https://search.google.com/search-console) — ve qué búsquedas te traen tráfico
- [Ahrefs Webmaster Tools](https://ahrefs.com/webmaster-tools) — análisis SEO
- [Ubersuggest](https://neilpatel.com/ubersuggest) — sugerencias de keywords

### AI SEO (2026): optimizar para ChatGPT y Perplexity

En 2026, mucha gente busca en ChatGPT/Perplexity, no solo en Google. Las diferencias:

- **Contenido factual y estructurado** gana — tablas, listas, comparativas
- **Citas y fuentes** ayudan a que AI te cite
- **FAQs** (preguntas frecuentes) específicas — AI las usa para responder
- **Páginas de comparación** ("X vs Y") son muy citadas

Algunos sitios publican un `/llms.txt` (similar a robots.txt pero para IAs) que le indica a los modelos qué contenido usar. Todavía emergente.

### Estructura típica de un post que rankea

1. **Título H1**: pregunta o beneficio claro (60 chars max)
2. **Intro** (2-3 párrafos): problema + promesa del post
3. **TL;DR** (too long, didn't read): resumen en 3-5 bullets
4. **H2 secciones**: cada uno responde una subpregunta
5. **Ejemplos concretos y screenshots**
6. **FAQ al final**: 3-5 preguntas con respuestas cortas
7. **CTA**: que lea otro post relacionado o contacte
$md$,
    3, 70,
$md$**Lanzá tu blog mínimo viable.**

Elegí uno:

**Opción A (Notion CMS):**
1. Creá una página Notion "Blog de [marca]"
2. Suscribite a [Super.so](https://super.so) (tier gratis o trial)
3. Conectá la página
4. Escribí tu primer post (300+ palabras, H1, H2s, FAQ al final)

**Opción B (Blog en Lovable):**
1. Pedile a Lovable: "Agregá sección blog con 3 posts de ejemplo en `/blog`"
2. Editá los posts que generó con tu contenido real
3. Asegurate que cada post tenga meta title y description

Publicá y compartí el link en LinkedIn con contexto.$md$,
    18)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Para qué sirve un CMS como Notion con Super.so?',
   '["Para diseñar logos", "Para escribir posts en Notion que se publican automáticamente en el sitio", "Para analizar competencia", "Para mandar emails"]'::jsonb,
   1, 0, 'Notion como CMS: escribís en Notion, aparece publicado en la web sin tocar código.'),
  (v_lesson_id, '¿Qué es el meta description?',
   '["Un campo oculto que describe la página — Google lo muestra en los resultados", "El título principal", "Un tipo de foto", "El color dominante del sitio"]'::jsonb,
   0, 1, 'Meta description (155 chars max) aparece bajo el título en los resultados de búsqueda. Clave para CTR.'),
  (v_lesson_id, 'En AI SEO (ChatGPT, Perplexity), ¿qué tipo de contenido ayuda a que te citen?',
   '["Solo imágenes", "Tablas, FAQs, comparativas y contenido factual estructurado", "Videos de 10 minutos", "Contenido en mayúsculas"]'::jsonb,
   1, 2, 'Las IAs extraen mejor contenido estructurado — tablas, listas, FAQs específicas, comparativas.');

  RAISE NOTICE '✅ Módulo Sitio completo cargado — 4 lecciones + 12 quizzes';
END $$;
