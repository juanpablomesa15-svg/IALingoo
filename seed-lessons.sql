-- =============================================
-- SEED: Módulo 1 "La Base" - Lecciones y Quizzes
-- Ejecutar en Supabase SQL Editor
-- =============================================

-- Primero, asegurémonos de que el módulo "La Base" existe
-- Si ya existe, esto no hará nada gracias al ON CONFLICT
INSERT INTO modules (title, description, order_index, icon_name, is_locked)
VALUES ('La Base', 'Fundamentos de la Inteligencia Artificial', 1, 'sparkles', false)
ON CONFLICT DO NOTHING;

-- Obtener el ID del módulo "La Base"
-- Usamos un CTE para todo el seed
DO $$
DECLARE
  v_module_id INT;
  v_lesson1_id INT;
  v_lesson2_id INT;
  v_lesson3_id INT;
  v_lesson4_id INT;
BEGIN
  -- Obtener module_id
  SELECT id INTO v_module_id FROM modules WHERE order_index = 1 LIMIT 1;

  IF v_module_id IS NULL THEN
    RAISE EXCEPTION 'No se encontró el módulo con order_index = 1';
  END IF;

  -- =============================================
  -- LECCIÓN 1: ¿Qué es la Inteligencia Artificial?
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    '¿Qué es la Inteligencia Artificial?',
    '## ¿Qué es la Inteligencia Artificial?

Imagina que tienes un asistente muy dedicado que ha leído millones de libros, artículos y conversaciones. No es un genio — es más como un estudiante muy aplicado que aprendió de **muchísimos ejemplos** y ahora puede ayudarte con tareas similares.

**Eso es básicamente la IA.**

### No es magia, son patrones

La Inteligencia Artificial funciona así:
1. **Se le muestran millones de ejemplos** (textos, imágenes, datos)
2. **Encuentra patrones** en esos ejemplos
3. **Usa esos patrones** para responder preguntas nuevas

Es como aprender a cocinar: después de ver 1000 recetas, empiezas a intuir qué ingredientes combinan bien, aunque nadie te lo diga explícitamente.

### Ya la usas todos los días

Sin darte cuenta, la IA ya es parte de tu vida:

- **Netflix/Spotify** → Te recomienda películas y música basándose en lo que ya viste
- **Gmail** → Filtra el spam automáticamente (¡y lo hace muy bien!)
- **Waze/Google Maps** → Calcula la mejor ruta analizando el tráfico en tiempo real
- **Tu celular** → Reconoce tu cara para desbloquearse

### Lo que la IA puede y NO puede hacer

✅ **Puede**: Escribir textos, resumir información, traducir, analizar datos, responder preguntas, generar ideas

❌ **No puede**: Pensar por sí misma, tener opiniones reales, garantizar que todo lo que dice es correcto, reemplazar tu criterio

### ⚠️ Importante: La IA se equivoca

A veces la IA "alucina" — genera información que **suena** correcta pero **no lo es**. Por eso, siempre debes verificar la información importante. Piensa en la IA como un asistente muy útil pero que necesita supervisión.',
    1,
    50,
    'Abre ChatGPT (chat.openai.com) o Claude (claude.ai) y hazle estas 5 preguntas:

1. ¿Qué puedo cocinar con lo que tengo en la nevera? (Descríbele lo que tienes)
2. Explícame como si tuviera 10 años qué es la inflación
3. Escríbeme un mensaje de cumpleaños para mi hermano
4. ¿Cuál es la mejor ruta para ir de Medellín a Cartagena?
5. Dame un plan de ejercicios para alguien de 48 años

Si puedes, prueba con ambas herramientas (ChatGPT y Claude) y compara las respuestas. ¿Cuál te gustó más? ¿Por qué?',
    20
  )
  RETURNING id INTO v_lesson1_id;

  -- Quizzes Lección 1
  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation)
  VALUES
    (v_lesson1_id, '¿Qué necesita una IA para aprender?', '["Un profesor humano que le enseñe", "Grandes cantidades de datos y ejemplos", "Conexión a internet permanente", "Un cerebro artificial físico"]', 1, 1, 'La IA aprende encontrando patrones en grandes cantidades de datos y ejemplos, no necesita un profesor ni un cerebro físico.'),
    (v_lesson1_id, '¿Cuál de estas es una IA que probablemente ya usas?', '["El control remoto del TV", "El filtro de spam de tu correo", "La calculadora del celular", "El Bluetooth"]', 1, 2, 'El filtro de spam de tu correo usa IA para identificar correos no deseados analizando patrones en millones de mensajes.'),
    (v_lesson1_id, '¿Puede la IA equivocarse o inventar información?', '["No, siempre da respuestas correctas", "Sí, a veces ''alucina'' y genera información falsa", "Solo se equivoca si le preguntas en otro idioma", "Solo cuando no tiene internet"]', 1, 3, 'La IA puede "alucinar" y generar información que suena correcta pero no lo es. Siempre verifica la información importante.');

  -- =============================================
  -- LECCIÓN 2: Cómo hablarle a la IA (Prompting básico)
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Cómo hablarle a la IA (Prompting básico)',
    '## Cómo hablarle a la IA

Cuando le escribes algo a una IA, eso se llama un **prompt** (se pronuncia "promPT"). Es simplemente la instrucción o pregunta que le das.

### La regla de oro

> **Mientras más contexto le des a la IA, mejor será su respuesta.**

Es como pedirle un favor a alguien: no es lo mismo decir *"hazme un correo"* que *"ayúdame a escribir un correo formal para pedirle vacaciones a mi jefe, trabajo como contador en una empresa mediana y llevo 3 años ahí"*.

### 3 Técnicas que cambian todo

#### 1. 🎯 Sé específico

| ❌ Prompt vago | ✅ Prompt específico |
|---|---|
| "Escríbeme un correo" | "Escríbeme un correo formal para pedir vacaciones a mi jefe. Soy contador, llevo 3 años en la empresa, quiero 5 días en abril." |
| "Dame una receta" | "Dame una receta fácil de almuerzo con pollo, arroz y los vegetales que tenga. Para 4 personas, máximo 30 minutos." |

#### 2. 🎭 Dale un rol

Decirle a la IA "actúa como..." mejora mucho sus respuestas:

- *"Actúa como un nutricionista y dime qué debería desayunar"*
- *"Eres un profesor de primaria. Explícame qué son las fracciones"*
- *"Actúa como un experto en finanzas personales y ayúdame a hacer un presupuesto"*

#### 3. 📋 Pide un formato

Dile cómo quieres la respuesta:

- *"Dame la respuesta en una lista de 5 puntos"*
- *"Respóndeme en máximo 3 párrafos"*
- *"Organízalo en una tabla con pros y contras"*
- *"Resúmelo en 2 oraciones"*

### La fórmula mágica

Combina las 3 técnicas:

**"Actúa como [rol]. Necesito [tarea específica con contexto]. Dame la respuesta en [formato deseado]."**

Ejemplo: *"Actúa como un experto en marketing. Necesito un correo de presentación para mi empresa de café artesanal en Medellín, dirigido a restaurantes. Dame 3 versiones: formal, casual y creativa, cada una de máximo 150 palabras."*',
    2,
    50,
    'Escribe 5 prompts para tareas reales de tu vida diaria:

1. Redactar un correo importante
2. Pedir un consejo de salud
3. Planear tu semana
4. Resumir una noticia que leíste
5. Pedir ayuda con una receta

Para cada uno, escríbelo de DOS formas:
- Primero, escríbelo simple y corto (como normalmente lo harías)
- Después, mejóralo usando las 3 técnicas que aprendiste (sé específico + dale un rol + pide formato)

Prueba ambas versiones en ChatGPT o Claude y compara los resultados. ¡Vas a notar una diferencia enorme!',
    25
  )
  RETURNING id INTO v_lesson2_id;

  -- Quizzes Lección 2
  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation)
  VALUES
    (v_lesson2_id, '¿Qué es un "prompt"?', '["Un programa de computador", "La instrucción o pregunta que le das a la IA", "Una marca de inteligencia artificial", "El botón para iniciar la IA"]', 1, 1, 'Un prompt es simplemente la instrucción, pregunta o texto que le escribes a la IA para que te responda.'),
    (v_lesson2_id, '¿Cuál de estos prompts va a darte mejor resultado?', '["''Escríbeme algo''", "''Necesito un correo''", "''Actúa como un experto en marketing y escríbeme un correo de presentación para una empresa de café en Medellín, tono profesional pero cercano, máximo 150 palabras''", "''Correo para empresa''"]', 2, 2, 'El tercer prompt es mucho mejor porque es específico, le da un rol a la IA y le pide un formato concreto.'),
    (v_lesson2_id, '¿Qué significa "darle un rol" a la IA?', '["Darle un nombre", "Pedirle que actúe como un experto específico para obtener mejor respuesta", "Asignarle una tarea en tu empresa", "Conectarla a un sistema"]', 1, 3, 'Darle un rol significa pedirle que actúe como un experto en algo específico, lo que mejora la calidad y relevancia de sus respuestas.');

  -- =============================================
  -- LECCIÓN 3: Tu caja de herramientas IA
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Tu caja de herramientas IA',
    '## Tu caja de herramientas IA

No existe UNA sola IA. Hay varias herramientas, y cada una tiene sus fortalezas. Es como tener un martillo, un destornillador y una llave — no usas el mismo para todo.

### Las 4 herramientas principales

#### 💬 ChatGPT — El conversador
- **Creado por**: OpenAI
- **Mejor para**: Conversaciones, lluvia de ideas, escritura creativa
- **Gratis**: Sí (versión básica)
- **Dónde**: [chat.openai.com](https://chat.openai.com)
- Es el más conocido y popular. Excelente para mantener conversaciones largas y generar contenido creativo.

#### 🧠 Claude — El pensador
- **Creado por**: Anthropic
- **Mejor para**: Análisis detallado, textos largos, razonamiento paso a paso
- **Gratis**: Sí (versión básica)
- **Dónde**: [claude.ai](https://claude.ai)
- Destaca en tareas que requieren pensar con cuidado y analizar documentos largos.

#### 🔍 Perplexity — El investigador
- **Creado por**: Perplexity AI
- **Mejor para**: Buscar información con **fuentes verificadas**
- **Gratis**: Sí (versión básica)
- **Dónde**: [perplexity.ai](https://perplexity.ai)
- A diferencia de las otras, te muestra de **dónde sacó la información** con enlaces a las fuentes.

#### 🌐 Gemini — El integrado
- **Creado por**: Google
- **Mejor para**: Tareas conectadas con tu cuenta de Google (Gmail, Drive, Calendar)
- **Gratis**: Sí
- **Dónde**: [gemini.google.com](https://gemini.google.com)
- Su gran ventaja es la integración con los servicios de Google que ya usas.

### ¿Cuándo usar cuál?

| Necesitas... | Usa... |
|---|---|
| Escribir un texto creativo | ChatGPT |
| Analizar un documento largo | Claude |
| Investigar un tema con fuentes | Perplexity |
| Algo relacionado con tu Gmail/Calendar | Gemini |
| No estás seguro | ¡Prueba con dos y compara! |

### El truco del experto

No te cases con una sola herramienta. **Los que mejor usan la IA son los que saben cuándo usar cada una.** Con el tiempo, vas a desarrollar tu propia intuición de cuál usar para cada tarea.',
    3,
    60,
    'Hazle la MISMA pregunta a las 4 herramientas:

"Dame un plan de 7 días para aprender a usar el computador mejor. Soy principiante, tengo 1 hora al día disponible."

Herramientas:
- ChatGPT → chat.openai.com
- Claude → claude.ai
- Perplexity → perplexity.ai
- Gemini → gemini.google.com

Después de recibir las 4 respuestas, reflexiona:
- ¿Cuál te gustó más? ¿Por qué?
- ¿Cuál fue más clara y fácil de seguir?
- ¿Cuál dio mejores pasos prácticos?
- ¿Alguna citó fuentes o enlaces útiles?

Escribe tus conclusiones en unas pocas líneas.',
    30
  )
  RETURNING id INTO v_lesson3_id;

  -- Quizzes Lección 3
  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation)
  VALUES
    (v_lesson3_id, '¿Para qué es mejor Perplexity comparado con ChatGPT?', '["Para hacer imágenes", "Para investigar temas con fuentes verificadas", "Para programar", "Para traducir idiomas"]', 1, 1, 'Perplexity se especializa en investigación y te muestra las fuentes de donde sacó la información, algo que ChatGPT no hace por defecto.'),
    (v_lesson3_id, '¿Todas las IAs dan exactamente la misma respuesta?', '["Sí, todas usan el mismo cerebro", "No, cada una tiene fortalezas diferentes y pueden dar respuestas distintas", "Solo si les preguntas en inglés", "Sí, pero en diferente formato"]', 1, 2, 'Cada IA fue entrenada de forma diferente y tiene fortalezas distintas, por lo que sus respuestas pueden variar significativamente.'),
    (v_lesson3_id, '¿Cuál herramienta está integrada con tu cuenta de Google?', '["ChatGPT", "Claude", "Perplexity", "Gemini"]', 3, 3, 'Gemini es la IA de Google y está integrada directamente con servicios como Gmail, Google Drive y Google Calendar.'),
    (v_lesson3_id, '¿Es mejor usar siempre la misma IA para todo?', '["Sí, así la IA te conoce mejor", "No, cada herramienta tiene fortalezas distintas y conviene saber cuándo usar cuál", "Sí, porque son todas iguales", "No importa, es lo mismo"]', 1, 4, 'Cada herramienta tiene fortalezas diferentes. Los que mejor aprovechan la IA son los que saben cuándo usar cada una según la tarea.');

  -- =============================================
  -- LECCIÓN 4: Tu asistente personal con IA (Proyecto)
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_module_id,
    'Tu asistente personal con IA',
    '## Tu asistente personal con IA

¡Felicidades! Ya sabes qué es la IA, cómo hablarle bien y qué herramientas existen. Ahora viene lo más importante: **convertirla en un hábito diario**.

### El problema más común

La mayoría de las personas prueban la IA una vez, dicen "¡qué genial!" y después... se les olvida usarla. Vuelven a hacer todo como antes.

**La clave no es saber que existe. La clave es USARLA todos los días.**

### Tu rutina diaria con IA

Vamos a crear una rutina simple de 3 momentos:

#### ☀️ EN LA MAÑANA — Organiza tu día
Abre Claude o ChatGPT y escríbele algo como:

> *"Buenos días. Estos son mis pendientes para hoy: [lista tus tareas]. Ayúdame a priorizarlos y organizar mi día de forma eficiente. Tengo disponible de 8am a 5pm."*

La IA te va a ayudar a ordenar tus prioridades y sugerirte un horario.

#### 🌤️ DURANTE EL DÍA — Consulta antes de buscar
Cada vez que tengas una duda o necesites ayuda con algo:
- ¿No sabes cómo redactar un mensaje? → Pregúntale a la IA
- ¿Necesitas entender un concepto? → Pregúntale a la IA
- ¿Quieres ideas para resolver un problema? → Pregúntale a la IA
- ¿Tienes que hacer un cálculo o análisis? → Pregúntale a la IA

**Antes de abrir Google, abre la IA.** No siempre será mejor, pero muchas veces te dará una respuesta más directa y personalizada.

#### 🌙 EN LA NOCHE — Reflexiona
Antes de terminar tu día, escríbele:

> *"Hoy hice estas cosas: [lista lo que hiciste]. ¿Qué observas? ¿Qué patrón ves? ¿Qué puedo mejorar mañana?"*

Te va a sorprender lo útil que es tener un "espejo" que te ayude a reflexionar.

### ¿Por qué funciona?

Porque la repetición crea el hábito. Después de una semana usando la IA así, ya no vas a poder imaginar tu día sin ella. Es como cuando aprendiste a usar WhatsApp — ahora no podrías vivir sin él.

### 🎯 Tu misión

Este es el proyecto final del módulo. No es un ejercicio de 10 minutos — es una **práctica de 3 días** que va a cambiar cómo usas la tecnología.',
    4,
    100,
    'Este es tu proyecto final del Módulo 1. Durante 3 días seguidos, sigue esta rutina:

☀️ MAÑANA (5 minutos)
Abre Claude o ChatGPT y escríbele:
"Buenos días. Estos son mis pendientes para hoy: [tu lista]. Ayúdame a priorizarlos y organizar mi día."

🌤️ DURANTE EL DÍA
Cada vez que tengas una duda o necesites ayuda con algo, pregúntale a la IA ANTES de buscar en Google. Ejemplos:
- "¿Cómo redacto un mensaje para cancelar una cita?"
- "Explícame qué significa este cobro en mi factura"
- "Dame ideas para el almuerzo con lo que tengo"

🌙 NOCHE (5 minutos)
Escríbele:
"Hoy hice estas cosas: [lista]. ¿Qué observas? ¿Qué puedo mejorar mañana?"

Después de 3 días, reflexiona:
- ¿En qué te ayudó más la IA?
- ¿En qué NO fue tan útil?
- ¿Qué cambió en tu día a día?
- ¿Vas a seguir usándola así?',
    45
  )
  RETURNING id INTO v_lesson4_id;

  -- Quizzes Lección 4
  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation)
  VALUES
    (v_lesson4_id, '¿Cuál es la clave para que la IA sea realmente útil en tu vida?', '["Usarla solo para cosas complicadas", "Convertirla en un hábito diario, no algo ocasional", "Pagar la versión premium", "Solo usarla en el computador"]', 1, 1, 'La clave es la consistencia. Usar la IA todos los días, para cosas grandes y pequeñas, es lo que la convierte en una herramienta verdaderamente útil.'),
    (v_lesson4_id, '¿Qué deberías hacer ANTES de buscar algo en Google?', '["Nada, Google siempre es mejor", "Preguntarle a la IA, que puede darte una respuesta más personalizada y directa", "Esperar a que alguien más te diga", "Buscar en Wikipedia"]', 1, 2, 'La IA puede darte respuestas más directas y personalizadas que una búsqueda de Google, especialmente cuando necesitas algo específico para tu situación.'),
    (v_lesson4_id, 'Al terminar este módulo, ¿qué deberías poder hacer?', '["Programar aplicaciones con IA", "Usar la IA como asistente diario para organizar, escribir, investigar y reflexionar", "Crear tu propia inteligencia artificial", "Vender servicios de IA"]', 1, 3, 'El objetivo del Módulo 1 es que puedas usar la IA como asistente en tu vida diaria para organizar, escribir, investigar y reflexionar.');

  RAISE NOTICE 'Seed completado: 4 lecciones y 13 quizzes insertados para el Módulo 1';
END $$;
