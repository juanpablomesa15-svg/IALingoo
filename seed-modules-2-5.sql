-- =============================================
-- SEED: Módulos 2-5 - Lecciones y Quizzes
-- Ejecutar en Supabase SQL Editor
-- =============================================

-- Insertar módulos 2-5
INSERT INTO modules (title, description, order_index, icon_name, is_locked)
VALUES
  ('Builder', 'Construye páginas web, imágenes y chatbots con IA', 2, 'hammer', true),
  ('Automatizador', 'Automatiza procesos con Make.com, APIs y WhatsApp', 3, 'zap', true),
  ('AI Agents', 'Crea agentes de IA que piensan y actúan solos', 4, 'bot', true),
  ('Negocio con IA', 'Lanza tu negocio usando todo lo aprendido', 5, 'rocket', true)
ON CONFLICT DO NOTHING;

-- =============================================
-- MÓDULO 2: "Builder"
-- =============================================
DO $$
DECLARE
  v_mod2_id INT;
  v_mod3_id INT;
  v_mod4_id INT;
  v_mod5_id INT;
  v_lesson_id INT;
BEGIN
  SELECT id INTO v_mod2_id FROM modules WHERE order_index = 2 LIMIT 1;
  SELECT id INTO v_mod3_id FROM modules WHERE order_index = 3 LIMIT 1;
  SELECT id INTO v_mod4_id FROM modules WHERE order_index = 4 LIMIT 1;
  SELECT id INTO v_mod5_id FROM modules WHERE order_index = 5 LIMIT 1;

  -- =============================================
  -- LECCIÓN 5: Introducción a Claude Code
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Introducción a Claude Code',
    '## ¿Qué es Claude Code?

Hasta ahora has usado la IA como un chat: le escribes, te responde con texto. Eso está genial para preguntas y consejos, pero **Claude Code es otro nivel**.

Claude Code es una herramienta donde **la IA escribe código real por ti**. No código que copias y pegas — la IA directamente crea archivos, edita tu proyecto, y construye cosas funcionales.

### ¿Qué es un IDE?

IDE significa "Entorno de Desarrollo Integrado". Suena complicado, pero es simplemente **el programa donde se escribe código**. Piensa en él como el Word de los programadores.

Ejemplos de IDEs:
- **VS Code** (el más popular del mundo)
- **Antigravity** (VS Code con Claude Code integrado)
- **Cursor** (otro IDE con IA integrada)

### ¿Por qué no necesitas saber programar?

Esta es la parte mágica: **Claude Code entiende español**. No necesitas saber HTML, CSS, JavaScript ni nada técnico. Solo necesitas saber **pedir lo que quieres**.

En vez de escribir código, le dices:
> "Crea una página web para una panadería con fondo amarillo y un menú de productos"

Y Claude Code:
1. **Crea los archivos** necesarios
2. **Escribe todo el código** por ti
3. **Te muestra el resultado** en tu navegador

### Diferencia entre chatear con IA vs Claude Code

| Chatear con IA | Claude Code |
|---|---|
| Te da texto y explicaciones | Crea archivos y código real |
| Tú copias y pegas | La IA edita directamente |
| Para preguntas y respuestas | Para CONSTRUIR cosas |
| Resultado: una respuesta | Resultado: un producto funcionando |

> **La IA es tu programador personal.** Tú eres el jefe que dice qué hacer, y ella lo ejecuta.',
    1,
    60,
    'Abre Antigravity con Claude Code. Escríbele: "Crea un archivo HTML que diga Hola Mundo con texto grande y centrado, fondo azul y letras blancas". Mira cómo genera el código y abre el archivo en tu navegador.',
    25
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué hace Claude Code a diferencia de un chat de IA normal?', '["Solo responde preguntas", "Crea archivos y escribe código real por ti", "Traduce idiomas", "Busca información en internet"]', 1, 1, 'Claude Code no solo responde — crea archivos reales y escribe código funcional directamente en tu proyecto.'),
    (v_lesson_id, '¿Qué es un IDE?', '["Un tipo de inteligencia artificial", "El programa donde se escribe código", "Una red social", "Un sistema operativo"]', 1, 2, 'IDE es el programa que usan los programadores para escribir código, como VS Code o Antigravity.'),
    (v_lesson_id, '¿Necesitas saber programar para usar Claude Code?', '["Sí, necesitas saber JavaScript", "Sí, necesitas un título en informática", "No, solo necesitas saber pedir lo que quieres en español", "Sí, al menos HTML básico"]', 2, 3, 'Claude Code entiende español perfectamente. Solo necesitas describir lo que quieres y la IA escribe el código por ti.');
  END IF;

  -- =============================================
  -- LECCIÓN 6: Tu primera página web
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Tu primera página web',
    '## Tu primera página web

Vamos a entender las dos piezas fundamentales de cualquier página web. No necesitas memorizarlas — Claude Code las escribe por ti. Pero entender qué son te hace **mejor dando instrucciones**.

### HTML: El esqueleto

**HTML** es la estructura de una página web. Es como los huesos de un cuerpo: define qué elementos existen y en qué orden van.

- Un título → `<h1>`
- Un párrafo → `<p>`
- Una imagen → `<img>`
- Un botón → `<button>`
- Una lista → `<ul>` con `<li>`

No te preocupes por los símbolos raros. Solo necesitas saber que **HTML define QUÉ hay en la página**.

### CSS: La ropa y el diseño

**CSS** es lo que hace que una página se vea bonita. Es la ropa, los colores, las fuentes, los espacios.

Sin CSS, una página web se ve como un documento de Word aburrido. Con CSS, se ve como una app moderna y profesional.

CSS controla:
- **Colores** de fondo y texto
- **Tamaños** de letras y elementos
- **Espacios** entre secciones
- **Animaciones** y efectos
- **Diseño responsive** (que se vea bien en celular y computador)

### El truco: saber PEDIR

Lo más importante no es saber HTML o CSS. Es saber **describir lo que quieres con detalle**:

❌ Malo: "Haz una página web"
✅ Bueno: "Crea una página web para una cafetería con sección de inicio con foto grande, menú de productos con precios, horarios, y botón de WhatsApp. Colores café y crema, estilo moderno."

### Iterar es la clave

Tu primera versión nunca será perfecta — y eso está bien. El poder real está en **pedir cambios**:
- "Cambia el color principal a verde"
- "Haz el botón más grande"
- "Agrega una sección de testimonios"
- "Pon un mapa de Google con la ubicación"

Cada cambio toma segundos. En 30 minutos puedes tener una página web profesional.',
    2,
    70,
    'Dile a Claude Code: "Crea una página web para [negocio que te guste] con sección de inicio, servicios, y contacto. Que sea bonita, moderna, con colores azul y blanco". Cuando la genere, pídele cambios: "Cambia el color a verde", "Agrega un botón de WhatsApp", "Pon una sección de testimonios".',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué define el HTML en una página web?', '["Los colores y el diseño", "La estructura y los elementos que existen", "Las animaciones", "La velocidad de carga"]', 1, 1, 'HTML es el esqueleto de la página: define qué elementos hay (títulos, párrafos, imágenes, botones) y en qué orden van.'),
    (v_lesson_id, '¿Cuál es la mejor forma de pedirle a Claude Code una página web?', '["Haceme una página", "Crea una página bonita", "Crea una página web para una cafetería con sección de inicio, menú con precios, y botón de WhatsApp, colores café y crema", "Página web ya"]', 2, 2, 'Mientras más específico seas en tu descripción (contenido, secciones, colores, estilo), mejor será el resultado que la IA genera.'),
    (v_lesson_id, '¿Qué deberías hacer si la primera versión no te gusta?', '["Empezar de cero", "Buscar un programador", "Pedir cambios específicos como cambiar colores o agregar secciones", "Rendirse"]', 2, 3, 'Iterar es la clave: pide cambios puntuales como "cambia el color a verde" o "agrega una sección de testimonios". Cada cambio toma segundos.');
  END IF;

  -- =============================================
  -- LECCIÓN 7: Diseño con IA
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Diseño con IA',
    '## Diseño con IA

¿Y si pudieras tener un diseñador web profesional disponible 24/7, que genera interfaces completas en segundos? Eso ya existe.

### v0.dev — Tu diseñador de interfaces

**v0.dev** (de Vercel) es una herramienta que genera interfaces web completas a partir de una descripción en texto.

Le escribes algo como:
> "Crea una landing page para una tienda de café artesanal con hero section, galería de productos, y sección de contacto"

Y te genera **3 versiones diferentes** para que elijas. Puedes:
- Elegir la que más te guste
- Pedir modificaciones
- Combinar elementos de diferentes versiones
- Exportar el código para usarlo

### Lovable — Apps sin código

**Lovable** (antes GPT Engineer) va un paso más allá: no solo diseña la interfaz, sino que **crea una aplicación funcional completa**.

Le puedes pedir:
- "Crea una app de lista de tareas con login"
- "Haz un dashboard de ventas con gráficos"
- "Construye un formulario de reservas para un restaurante"

Y genera una app que puedes publicar directamente.

### Canva con IA

**Canva** ya integra IA para:
- Generar diseños de posts para redes sociales
- Crear presentaciones automáticamente
- Editar y mejorar fotos
- Generar textos y copy

### El truco: ser específico e iterar

La fórmula mágica es siempre la misma:
1. **Describe con detalle** lo que quieres
2. **Revisa** lo que genera
3. **Pide cambios** específicos
4. **Repite** hasta que quede perfecto

> Nunca te quedes con la primera versión. La magia está en la iteración.',
    3,
    60,
    'Ve a v0.dev y escríbele: "Crea una landing page para una tienda de café artesanal en Medellín, estilo moderno y minimalista". Genera 3 versiones y compara cuál te gusta más.',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué hace v0.dev?', '["Edita fotos", "Genera interfaces web completas a partir de texto", "Crea música", "Es una red social"]', 1, 1, 'v0.dev genera interfaces web completas a partir de descripciones en texto, ofreciendo múltiples versiones para elegir.'),
    (v_lesson_id, '¿Qué diferencia tiene Lovable de v0.dev?', '["Es más barato", "No solo diseña sino que crea aplicaciones funcionales completas", "Solo hace logos", "Es una app móvil"]', 1, 2, 'Lovable va más allá del diseño: crea aplicaciones funcionales completas que puedes publicar directamente.'),
    (v_lesson_id, '¿Cuál es la fórmula para obtener buenos resultados con herramientas de diseño IA?', '["Aceptar la primera versión", "Ser vago en las instrucciones", "Describir con detalle, revisar, pedir cambios, y repetir", "Usar solo una herramienta"]', 2, 3, 'La clave es iterar: describe con detalle, revisa el resultado, pide cambios específicos, y repite hasta que quede perfecto.');
  END IF;

  -- =============================================
  -- LECCIÓN 8: Imágenes con IA
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Imágenes con IA',
    '## Imágenes con IA

Ya no necesitas ser diseñador ni fotógrafo para tener imágenes profesionales. La IA las genera en segundos.

### DALL-E (dentro de ChatGPT)

**DALL-E** es el generador de imágenes de OpenAI. Lo usas directamente dentro de ChatGPT:
- "Genera una foto de un plato de comida colombiana con buena iluminación"
- "Crea un logo minimalista para una marca de ropa llamada Nova"
- "Haz una ilustración de una persona trabajando en su laptop en una cafetería"

### Ideogram — Rey del texto en imágenes

**Ideogram** es especialista en generar imágenes que **contienen texto legible**. Esto es súper útil para:
- Posts de Instagram con frases
- Carteles y banners
- Logotipos con nombre incluido

### Midjourney — Calidad artística

**Midjourney** genera las imágenes más artísticas y detalladas. Es ideal para:
- Fotografía conceptual
- Arte digital
- Imágenes editoriales de alta calidad

### Tips para mejores prompts visuales

Para obtener las mejores imágenes, describe:

1. **La escena**: Qué hay en la imagen
2. **El estilo**: Fotorrealista, ilustración, minimalista, vintage
3. **La iluminación**: Natural, estudio, golden hour, neón
4. **El ángulo**: Cenital (desde arriba), frontal, 45 grados
5. **El mood**: Profesional, casual, divertido, elegante

**Ejemplo completo:**
> "Foto de producto de unos audífonos inalámbricos blancos sobre fondo degradado azul a morado, iluminación de estudio suave, ángulo 3/4, estilo Apple, alta calidad"

### Usos prácticos

- **Logos** para negocios nuevos
- **Fotos de producto** cuando no tienes fotógrafo
- **Ilustraciones** para posts en redes
- **Mockups** de productos
- **Fondos** para presentaciones',
    4,
    60,
    'Genera 3 imágenes en ChatGPT con DALL-E: 1) Un logo para un negocio inventado, 2) Una foto de producto (comida, ropa, lo que quieras), 3) Una ilustración para un post de Instagram. Para cada una, prueba mejorar el prompt 3 veces.',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué herramienta es mejor para generar imágenes con texto legible?', '["DALL-E", "Midjourney", "Ideogram", "Canva"]', 2, 1, 'Ideogram se especializa en generar imágenes que contienen texto legible, ideal para posts, carteles y logos con nombre.'),
    (v_lesson_id, '¿Qué elementos debes describir para obtener mejores imágenes con IA?', '["Solo el objeto", "La escena, el estilo, la iluminación, el ángulo y el mood", "Solo el color", "El tamaño del archivo"]', 1, 2, 'Para mejores resultados describe la escena, estilo, iluminación, ángulo y mood. Mientras más detallado, mejor resultado.'),
    (v_lesson_id, '¿Cuál de estas NO es una herramienta de generación de imágenes con IA?', '["DALL-E", "Midjourney", "Make.com", "Ideogram"]', 2, 3, 'Make.com es una herramienta de automatización, no de generación de imágenes. DALL-E, Midjourney e Ideogram sí generan imágenes con IA.');
  END IF;

  -- =============================================
  -- LECCIÓN 9: Chatbots básicos
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Chatbots básicos',
    '## Chatbots básicos

Un chatbot es un programa que **conversa con personas automáticamente**. Piensa en él como un empleado virtual que nunca duerme y siempre está disponible para responder preguntas.

### Dos tipos de chatbots

**Chatbot con reglas (el robot tonto):**
- Sigue un guión fijo
- Si preguntas algo que no está en el guión, no sabe qué hacer
- Ejemplo: "Presiona 1 para ventas, 2 para soporte"

**Chatbot con IA (el robot inteligente):**
- Entiende lenguaje natural
- Responde a preguntas que nunca se le programaron
- Se adapta al contexto de la conversación
- Ejemplo: Puede responder "¿Cuánto cuesta el plan familiar?" aunque nadie escribió esa pregunta específica

### Chatbase — Tu chatbot en 5 minutos

**Chatbase** es la forma más fácil de crear un chatbot con IA:

1. **Creas una cuenta** (tiene plan gratis)
2. **Le das información**: pegas texto, subes PDFs, o das una URL de tu sitio web
3. **El chatbot aprende** de esa información
4. **Lo compartes** con un link o lo incrustas en tu página web

Lo mágico: el chatbot responde basándose en TU información. Si le cargas los precios de tu negocio, sabe los precios. Si le cargas los horarios, sabe los horarios.

### Botpress — Más control

**Botpress** es otra opción con más control:
- Permite crear flujos de conversación visuales
- Conecta con WhatsApp, Instagram, Facebook
- Tiene más opciones de personalización
- Es más complejo pero más poderoso

### Caso de uso: preguntas frecuentes

El uso #1 de chatbots para negocios es **responder preguntas frecuentes**:
- "¿Cuáles son sus horarios?"
- "¿Cuánto cuesta el servicio X?"
- "¿Dónde están ubicados?"
- "¿Hacen envíos a domicilio?"
- "¿Tienen estacionamiento?"

Sin chatbot: tú respondes las mismas preguntas 50 veces al día.
Con chatbot: el bot responde 24/7 y tú te enfocas en cosas importantes.',
    5,
    70,
    'Ve a Chatbase.co, crea una cuenta gratis. Crea un chatbot entrenado con información de un negocio (puede ser inventado): nombre, horarios, productos, precios, ubicación. Prueba hacerle preguntas como cliente y ve cómo responde.',
    35
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la diferencia principal entre un chatbot con reglas y uno con IA?', '["El precio", "El chatbot con IA entiende lenguaje natural y responde preguntas no programadas", "El color del chat", "El chatbot con reglas es más inteligente"]', 1, 1, 'Un chatbot con IA entiende lenguaje natural y puede responder preguntas que nunca se le programaron, mientras que uno con reglas solo sigue un guión fijo.'),
    (v_lesson_id, '¿Cómo aprende un chatbot de Chatbase sobre tu negocio?', '["Adivina la información", "Le cargas texto, PDFs o URLs con la información de tu negocio", "Busca en Google automáticamente", "Hay que programarlo manualmente"]', 1, 2, 'Chatbase aprende de la información que tú le proporcionas: textos, PDFs, o URLs de tu sitio web. Responde basándose en esa información.'),
    (v_lesson_id, '¿Cuál es el uso más común de chatbots en negocios?', '["Hacer memes", "Responder preguntas frecuentes automáticamente 24/7", "Enviar correos masivos", "Hackear competidores"]', 1, 3, 'El uso principal es automatizar las respuestas a preguntas frecuentes (horarios, precios, ubicación) para que el negocio pueda atender 24/7.');
  END IF;

  -- =============================================
  -- LECCIÓN 10: Proyecto - Mi página web completa
  -- =============================================
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod2_id,
    'Proyecto: Mi página web completa',
    '## Proyecto: Mi página web completa

¡Llegó la hora de juntar todo lo que aprendiste! En este proyecto vas a crear una **página web publicada en internet** para un negocio real o ficticio.

### Lo que vas a crear

Tu página web completa debe tener:

1. **Landing page profesional** — Hecha con Claude Code o v0.dev
2. **Imágenes generadas con IA** — Logos, fotos de producto, ilustraciones
3. **Chatbot integrado** — Para responder preguntas frecuentes

### Paso a paso

**Paso 1: Define tu negocio**
Elige un negocio (real o inventado). Define:
- Nombre
- Qué vende/ofrece
- Público objetivo
- 3-5 productos o servicios con precios

**Paso 2: Genera la landing page**
Usa Claude Code para crear la página. Sé específico:
> "Crea una landing page para [negocio] con hero section con imagen grande, sección de productos con precios, testimonios, ubicación con mapa, y botón de WhatsApp flotante. Colores [X], estilo moderno y profesional."

**Paso 3: Crea las imágenes**
Usa DALL-E o Ideogram para generar:
- Logo del negocio
- Fotos de productos
- Imagen de fondo para el hero

**Paso 4: Agrega el chatbot**
Crea un chatbot en Chatbase con la información del negocio e insértalo en la página.

**Paso 5: Publica**
Claude Code puede ayudarte a publicar en Vercel o Netlify gratuitamente.

**Paso 6: Pide feedback**
Comparte el link con 3 personas y pregúntales:
- ¿Entiendes qué ofrece el negocio?
- ¿Confiarías en comprar aquí?
- ¿Qué cambiarías?

### ¿Por qué esto importa?

Acabas de hacer en horas lo que antes costaba **miles de dólares y semanas de trabajo**. Esta habilidad tiene valor real en el mercado.',
    6,
    120,
    'Crea la página web completa: 1) Genera la landing en Claude Code, 2) Crea las imágenes con DALL-E, 3) Agrega un chatbot con Chatbase, 4) Publica en Vercel o Netlify (Claude Code te ayuda). Comparte el link con 3 personas y pídeles feedback.',
    60
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuáles son los 3 componentes principales de la página web del proyecto?', '["Texto, video, música", "Landing page, imágenes con IA, y chatbot", "Base de datos, API, frontend", "Logo, favicon, dominio"]', 1, 1, 'El proyecto integra los tres aprendizajes del módulo: una landing page profesional, imágenes generadas con IA, y un chatbot funcional.'),
    (v_lesson_id, '¿Dónde puedes publicar tu página web gratuitamente?', '["Amazon AWS únicamente", "Vercel o Netlify", "Solo pagando un hosting", "No se puede gratis"]', 1, 2, 'Vercel y Netlify ofrecen hosting gratuito para páginas web estáticas. Claude Code puede ayudarte con el proceso de publicación.'),
    (v_lesson_id, '¿Por qué es importante pedir feedback después de publicar?', '["Para presumir", "Para saber si el negocio se entiende y qué mejorar basado en usuarios reales", "No es importante", "Solo por costumbre"]', 1, 3, 'El feedback de personas reales te dice si tu página comunica bien, si genera confianza, y qué necesitas mejorar — es la base de cualquier producto exitoso.');
  END IF;

  -- =============================================
  -- MÓDULO 3: "Automatizador"
  -- =============================================

  -- LECCIÓN 11: ¿Qué es una automatización?
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    '¿Qué es una automatización?',
    '## ¿Qué es una automatización?

Una automatización es simplemente esto: **cuando pasa X, haz Y automáticamente**.

### La analogía del despertador

Piénsalo así:
- **Trigger (disparador):** Suena el despertador a las 6am
- **Acción:** Te levantas de la cama

Eso es una automatización. Un evento dispara una acción. Lo único que cambia es que en vez de hacerlo tú manualmente, **una herramienta lo hace por ti**.

### Ejemplos cotidianos

Ya vives rodeado de automatizaciones:
- Cuando llega un correo de "factura" → Gmail lo etiqueta automáticamente
- Cuando publicas una foto en Instagram → se comparte en Facebook también
- Cuando alguien te envía dinero → el banco te manda notificación

### Ejemplos para negocios

Ahora imagina automatizar cosas en un negocio:
- Cuando alguien llena un formulario web → guardar sus datos + enviarle un correo de bienvenida
- Cuando publicas un post en Instagram → crear automáticamente un tweet similar
- Cuando un cliente paga → generarle la factura y enviarla por correo
- Cuando recibes un correo con "urgente" → enviar alerta a tu WhatsApp

### Las herramientas

- **Make.com** (antes Integromat) — Visual, poderosa, buen plan gratis
- **Zapier** — La más conocida, más cara pero más fácil
- **n8n** — Open source, gratis si la instalas tú

### El poder de automatizar

Una empresa promedio **pierde 20-30% de su tiempo** en tareas repetitivas. Automatizar esas tareas significa:
- Más tiempo para lo importante
- Menos errores humanos
- Respuestas más rápidas a clientes
- Trabajar mientras duermes',
    1,
    50,
    'Antes de tocar herramientas, mapea 3 tareas repetitivas de tu día a día en formato "Cuando pasa X → hago Y". Ejemplo: "Cuando me escriben por WhatsApp pidiendo precio → busco en la lista de precios → copio y pego → respondo". Escríbelas.',
    20
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué es un "trigger" en una automatización?', '["El resultado final", "El evento que dispara la acción automática", "Una herramienta de diseño", "Un tipo de base de datos"]', 1, 1, 'El trigger es el evento que inicia la automatización. Es el "cuando pasa X" de la fórmula "cuando pasa X → haz Y".'),
    (v_lesson_id, '¿Cuál de estas herramientas se usa para crear automatizaciones?', '["Canva", "Make.com", "DALL-E", "ChatGPT"]', 1, 2, 'Make.com (antes Integromat) es una herramienta visual para crear automatizaciones conectando diferentes aplicaciones y servicios.'),
    (v_lesson_id, '¿Cuánto tiempo pierde una empresa promedio en tareas repetitivas?', '["5%", "10%", "20-30%", "50%"]', 2, 3, 'Las empresas pierden entre 20-30% de su tiempo en tareas repetitivas que podrían automatizarse, liberando tiempo para lo importante.');
  END IF;

  -- LECCIÓN 12: Make.com - Tu primera automatización
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    'Make.com: Tu primera automatización',
    '## Make.com: Tu primera automatización

**Make.com** (antes llamado Integromat) es una herramienta visual donde creas automatizaciones **conectando bloques** como si fueran piezas de LEGO.

### Conceptos básicos

- **Escenario**: Una automatización completa (el flujo entero)
- **Módulo**: Cada bloque dentro del escenario (cada paso)
- **Trigger**: El primer módulo que inicia el escenario
- **Webhook**: Una URL especial que recibe datos de afuera

### Cómo funciona visualmente

Imagina una línea de dominós:
1. **Primer dominó** (trigger): Algo pasa (llega un correo)
2. **Segundo dominó** (acción): Procesas (extraes el texto)
3. **Tercer dominó** (acción): Haces algo (envías un WhatsApp)

En Make.com, cada dominó es un **módulo** visual que arrastras y conectas.

### Integraciones disponibles

Make.com se conecta con +1500 apps:
- **Gmail, Outlook** → Correos
- **Google Sheets** → Hojas de cálculo
- **WhatsApp, Telegram, Slack** → Mensajería
- **Instagram, Facebook, Twitter** → Redes sociales
- **Shopify, WooCommerce** → E-commerce
- **Stripe, PayPal** → Pagos
- **Y muchas más...**

### Tu primer escenario

El escenario más simple pero útil:
1. **Trigger**: Recibes un correo en Gmail con la palabra "urgente" en el asunto
2. **Filtro**: Verificar que el asunto contiene "urgente"
3. **Acción**: Enviar un mensaje a tu WhatsApp avisándote

Esto parece simple, pero imagina cuántas variaciones puedes hacer:
- Correo con "factura" → guardar archivo en Google Drive
- Nuevo seguidor en Instagram → agregar a hoja de cálculo
- Alguien compra en tu tienda → enviar correo de agradecimiento',
    2,
    70,
    'Crea una cuenta en Make.com. Construye tu primer escenario: Cuando recibes un correo en Gmail con la palabra "urgente" en el asunto → enviar un mensaje a tu WhatsApp (o Telegram) avisándote. Actívalo y pruébalo enviándote un correo.',
    35
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué es un "escenario" en Make.com?', '["Un tipo de plantilla de diseño", "Una automatización completa con todos sus pasos", "Una base de datos", "Un tipo de correo electrónico"]', 1, 1, 'Un escenario es una automatización completa en Make.com, compuesta por módulos conectados que ejecutan un flujo de acciones.'),
    (v_lesson_id, '¿Qué es un "módulo" en Make.com?', '["El precio del plan", "Cada bloque o paso dentro de un escenario", "Un tipo de archivo", "Una extensión del navegador"]', 1, 2, 'Un módulo es cada bloque o paso dentro de un escenario. Puede ser un trigger, un filtro, o una acción como enviar un correo o guardar datos.'),
    (v_lesson_id, '¿Qué es un webhook?', '["Un tipo de virus", "Una URL especial que recibe datos externos para iniciar una automatización", "Una herramienta de diseño", "Un documento PDF"]', 1, 3, 'Un webhook es una URL especial que puede recibir datos de fuentes externas y usarlos como trigger para iniciar automatizaciones.'),
    (v_lesson_id, '¿Con cuántas apps aproximadamente se conecta Make.com?', '["50", "200", "Más de 1500", "Solo 10"]', 2, 4, 'Make.com se conecta con más de 1500 aplicaciones, desde correo y redes sociales hasta plataformas de e-commerce y pagos.');
  END IF;

  -- LECCIÓN 13: APIs para no técnicos
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    'APIs para no técnicos',
    '## APIs para no técnicos

La palabra "API" suena súper técnica, pero el concepto es simple. Vamos con una analogía:

### La analogía del mesero

Imagina que estás en un restaurante:
- **Tú** (la app) quieres pedir comida
- **El mesero** (la API) toma tu orden
- **La cocina** (el servidor) prepara la comida
- **El mesero** te trae la comida de vuelta

La API es simplemente el **mensajero** entre tu app y los datos que necesitas.

### ¿Qué es un endpoint?

Un endpoint es la **dirección específica** donde pides algo. Como las estaciones de un tren:
- `/clima` → Te da información del clima
- `/noticias` → Te da las últimas noticias
- `/productos` → Te da la lista de productos

### Autenticación: la llave de acceso

Muchas APIs requieren una **API Key** — piensa en ella como la llave de tu casa:
- Sin llave: no puedes entrar
- Con llave: accedes a los datos
- Cada persona tiene su propia llave (para controlar quién accede)

### ¿Cómo se usan las APIs en automatizaciones?

En Make.com puedes usar el módulo **HTTP** para llamar a cualquier API:

1. **Le das la URL** del endpoint
2. **Agregas tu API Key** si es necesario
3. **Recibes los datos** en formato JSON (texto estructurado)
4. **Usas esos datos** en los siguientes módulos

### APIs públicas útiles

- **wttr.in** → Clima de cualquier ciudad (gratis, sin API key)
- **NewsAPI** → Noticias del mundo
- **ExchangeRate API** → Tasas de cambio de monedas
- **RandomUser** → Datos ficticios para pruebas

### No necesitas ser programador

En Make.com, conectarte a una API es simplemente:
- Pegar una URL
- Configurar unos campos
- ¡Listo! Ya estás consumiendo una API',
    3,
    60,
    'En Make.com, crea un escenario que use una API pública: conecta el módulo HTTP a la API del clima (wttr.in) para consultar el clima de tu ciudad, y envía el resultado a tu correo cada mañana.',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, 'En la analogía del restaurante, ¿qué papel juega la API?', '["El chef", "El cliente", "El mesero que lleva tu pedido y trae la respuesta", "El dueño"]', 2, 1, 'La API es como el mesero: recibe tu pedido (petición), lo lleva a la cocina (servidor), y te trae la comida (datos de vuelta).'),
    (v_lesson_id, '¿Qué es una API Key?', '["Un tipo de moneda digital", "Una llave de acceso que identifica quién está usando la API", "Un lenguaje de programación", "Un tipo de base de datos"]', 1, 2, 'Una API Key es una llave única que identifica quién está accediendo a la API. Permite controlar el acceso y el uso.'),
    (v_lesson_id, '¿Qué necesitas en Make.com para consumir una API?', '["Saber programar en Python", "Solo pegar la URL del endpoint y configurar los campos", "Tener un servidor propio", "Pagar una suscripción premium"]', 1, 3, 'En Make.com solo necesitas pegar la URL del endpoint y configurar los campos necesarios — no requiere programación.');
  END IF;

  -- LECCIÓN 14: WhatsApp + IA
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    'WhatsApp + IA',
    '## WhatsApp + IA

En Latinoamérica, **WhatsApp es el canal #1** de comunicación. Todo pasa por ahí: ventas, soporte, cotizaciones, confirmaciones. Conectar WhatsApp con IA es un superpoder.

### ¿Por qué WhatsApp?

- **+2 mil millones** de usuarios en el mundo
- En LATAM, el **95% de la gente** lo usa a diario
- Los mensajes de WhatsApp tienen **98% de tasa de apertura** (vs 20% del correo)
- La gente **prefiere escribir por WhatsApp** que llamar o llenar formularios

### Opciones para conectar WhatsApp con IA

**1. Chatbase con WhatsApp**
- La opción más fácil
- Chatbase tiene integración directa con WhatsApp
- Creas el chatbot, lo conectas, y responde por WhatsApp
- Ideal para: preguntas frecuentes, información de productos

**2. Manychat**
- Plataforma visual para chatbots de WhatsApp
- Flujos arrastrando bloques
- Bueno para: secuencias de venta, campañas de marketing

**3. WhatsApp Cloud API (Meta)**
- La API oficial de Meta/Facebook
- Gratis (pagas solo por conversaciones activas)
- Más técnica pero más flexible
- Se conecta con Make.com o n8n

**4. Twilio**
- Plataforma de comunicaciones
- API robusta para WhatsApp
- Buena para escala grande

### Qué puede hacer un chatbot de WhatsApp

- Responder preguntas frecuentes automáticamente
- Enviar catálogos de productos con precios
- Agendar citas
- Enviar confirmaciones y recordatorios
- Escalar a un humano cuando no puede resolver
- Tomar pedidos

### La experiencia del cliente

El cliente escribe a tu WhatsApp y recibe respuesta **inmediata**, a cualquier hora. No importa si es domingo a las 3am. El chatbot responde con la información correcta porque está entrenado con TUS datos.',
    4,
    70,
    'Crea un chatbot de WhatsApp usando Chatbase (tiene integración directa) o Manychat. Entrénalo con información de un negocio y comparte el link con alguien para que lo pruebe.',
    35
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Por qué WhatsApp es tan importante para negocios en LATAM?', '["Es gratis para empresas", "Tiene 98% de tasa de apertura y el 95% de la gente lo usa a diario", "Es la única app de mensajería", "Tiene mejor diseño que Telegram"]', 1, 1, 'WhatsApp domina en LATAM con 95% de uso diario y 98% de tasa de apertura de mensajes, muy por encima del correo electrónico.'),
    (v_lesson_id, '¿Cuál es la forma más fácil de crear un chatbot de WhatsApp?', '["Programar uno desde cero", "Usar Chatbase que tiene integración directa con WhatsApp", "Contratar un equipo de desarrolladores", "Usar solo la API de Meta"]', 1, 2, 'Chatbase ofrece la forma más sencilla: creas el chatbot, le cargas información, y lo conectas directamente a WhatsApp sin necesidad de programar.'),
    (v_lesson_id, '¿Qué debe hacer un buen chatbot cuando no puede resolver una pregunta?', '["Inventar una respuesta", "Ignorar al cliente", "Escalar a un humano", "Cerrar la conversación"]', 2, 3, 'Un buen chatbot debe escalar a un humano cuando no puede resolver algo, asegurando que el cliente siempre reciba la ayuda que necesita.');
  END IF;

  -- LECCIÓN 15: Google Sheets como base de datos
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    'Google Sheets como base de datos',
    '## Google Sheets como base de datos

¿Sabías que Google Sheets puede funcionar como una **base de datos perfecta** para pequeños negocios? No necesitas Supabase, Firebase, ni nada sofisticado para empezar.

### ¿Por qué Google Sheets?

- **Gratis** y accesible desde cualquier dispositivo
- **Fácil de entender** — todos saben usar una hoja de cálculo
- **Se conecta con todo** — Make.com, Zapier, n8n
- **Compartible** — puedes dar acceso a tu equipo
- **Visual** — ves los datos inmediatamente

### Cómo estructurar tu hoja

La regla de oro: **una fila = un registro, una columna = un campo**

Ejemplo para un registro de clientes:
| Nombre | Teléfono | Email | Producto | Fecha | Estado |
|--------|----------|-------|----------|-------|--------|
| Juan | 311... | juan@... | Plan Pro | 2024-01-15 | Contactado |
| María | 300... | maria@... | Plan Basic | 2024-01-16 | Pagó |

### Conectar con automatizaciones

En Make.com puedes:
- **Agregar filas** automáticamente cuando alguien llena un formulario
- **Leer datos** para enviar correos personalizados
- **Actualizar estados** cuando cambia algo
- **Buscar información** cuando un chatbot la necesita

### Google Forms + Sheets + Make.com

La combinación ganadora:
1. **Google Forms**: Creas un formulario bonito para que la gente lo llene
2. **Google Sheets**: Las respuestas se guardan automáticamente
3. **Make.com**: Cada vez que llega una respuesta nueva → envía correo de confirmación + te notifica

### Limitaciones

Google Sheets funciona perfecto hasta ~5000 registros. Después de eso, necesitarías algo más robusto. Pero para empezar, es más que suficiente.',
    5,
    60,
    'Crea un Google Sheet con columnas: Nombre, Teléfono, Producto, Fecha. En Make.com, crea un escenario que cuando alguien llene un Google Form → los datos se guarden automáticamente en tu Sheet → te envíe un correo de notificación.',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la regla de oro para estructurar datos en Google Sheets?', '["Poner todo en una sola celda", "Una fila = un registro, una columna = un campo", "Usar colores para diferenciar datos", "Hacer una hoja por cada dato"]', 1, 1, 'La estructura correcta es: cada fila representa un registro (como un cliente) y cada columna un campo de información (nombre, teléfono, etc.).'),
    (v_lesson_id, '¿Hasta cuántos registros funciona bien Google Sheets como base de datos?', '["100", "500", "~5000", "Ilimitados"]', 2, 2, 'Google Sheets funciona perfectamente hasta aproximadamente 5000 registros. Después se necesita algo más robusto como una base de datos real.'),
    (v_lesson_id, '¿Cuál es la combinación ganadora para automatizar captación de clientes?', '["Solo WhatsApp", "Google Forms + Google Sheets + Make.com", "Solo correo electrónico", "Instagram + TikTok"]', 1, 3, 'Google Forms captura datos, Google Sheets los almacena, y Make.com automatiza acciones como enviar confirmaciones y notificaciones.');
  END IF;

  -- LECCIÓN 16: Proyecto - Sistema automático de clientes
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod3_id,
    'Proyecto: Sistema automático de clientes',
    '## Proyecto: Sistema automático de clientes

Es hora de construir algo que funciona en el mundo real: un **mini-CRM automatizado** que gestiona clientes sin que tú muevas un dedo.

### ¿Qué vas a construir?

Un sistema donde:
1. **El cliente te contacta** (formulario o WhatsApp)
2. **Sus datos se guardan** automáticamente en Google Sheets
3. **Recibe una respuesta automática** de confirmación
4. **Tú recibes una notificación** por correo o WhatsApp

Todo esto pasa **sin intervención manual**. Es como tener un asistente administrativo trabajando 24/7.

### Los componentes

**1. Google Form de contacto**
- Campos: Nombre, Teléfono, Email, Servicio de interés, Mensaje
- Diseño limpio y profesional
- Puede incrustarse en tu página web

**2. Google Sheet como base de datos**
- Columnas que coincidan con el formulario
- Columna extra: "Estado" (Nuevo, Contactado, Cerrado)
- Columna extra: "Fecha de contacto" (automática)

**3. Automatización en Make.com**
- Trigger: Nueva respuesta en Google Form
- Paso 1: Guardar datos en Google Sheet (si no se guardan automáticamente)
- Paso 2: Enviar correo de bienvenida al cliente
- Paso 3: Enviarte una notificación a ti

**4. Respuesta automática al cliente**
El correo de respuesta debe incluir:
- Agradecimiento por el contacto
- Confirmación de que recibiste su mensaje
- Tiempo estimado de respuesta
- Información relevante del servicio

### Métricas que puedes ver

Con este sistema puedes saber:
- Cuántos clientes te contactan por día/semana
- Qué servicios son los más solicitados
- Cuál es tu tiempo de respuesta
- Tasa de conversión (contactados vs pagos)

### El valor real

Este sistema lo puedes **vender como servicio** a cualquier negocio. Es simple pero poderoso, y la mayoría de negocios NO lo tienen.',
    6,
    130,
    'Construye el sistema completo: 1) Google Form de contacto, 2) Google Sheet como base de datos, 3) Make.com que conecte todo, 4) Respuesta automática al cliente, 5) Notificación a ti por correo/WhatsApp. Pruébalo con 3 personas reales.',
    60
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué es un mini-CRM automatizado?', '["Un tipo de red social", "Un sistema que gestiona clientes automáticamente sin intervención manual", "Un programa de contabilidad", "Una aplicación de música"]', 1, 1, 'Un mini-CRM automatizado es un sistema que captura, almacena y responde a clientes automáticamente, funcionando como un asistente administrativo 24/7.'),
    (v_lesson_id, '¿Qué debe incluir la respuesta automática al cliente?', '["Solo un emoji", "Agradecimiento, confirmación de recepción, y tiempo estimado de respuesta", "Solo el precio", "Nada, no hay que responder"]', 1, 2, 'La respuesta automática debe agradecer, confirmar que se recibió el mensaje, indicar tiempo de respuesta, y dar información relevante.'),
    (v_lesson_id, '¿Se puede vender este tipo de sistema como servicio?', '["No, es demasiado simple", "Sí, la mayoría de negocios no lo tienen y lo necesitan", "Solo las grandes empresas lo necesitan", "No, es ilegal"]', 1, 3, 'Este sistema es simple pero poderoso, y la mayoría de negocios no lo tienen. Es un servicio que puedes ofrecer con lo que ya aprendiste.');
  END IF;

  -- =============================================
  -- MÓDULO 4: "AI Agents"
  -- =============================================

  -- LECCIÓN 17: ¿Qué es un AI Agent?
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod4_id,
    '¿Qué es un AI Agent?',
    '## ¿Qué es un AI Agent?

Ya conoces los chatbots. Ahora vamos un nivel más arriba: los **AI Agents** (agentes de IA).

### La diferencia clave

- **Chatbot** → Responde preguntas basándose en un guión o información cargada
- **AI Agent** → Piensa, busca información, decide qué hacer, y actúa

Piensa en la diferencia así:
- **Chatbot** = Un empleado que lee un guión telefónico
- **AI Agent** = Un empleado inteligente que piensa, investiga, y resuelve problemas por su cuenta

### Ejemplo concreto

**Chatbot**: "¿Cuál es el clima hoy?" → "El clima en Medellín es 24°C"

**Agente**: "Investiga los 5 mejores restaurantes de Medellín para una cena de negocios, compara precios, revisa reseñas, y recomiéndame el mejor" → El agente:
1. Busca en internet
2. Compara opciones
3. Lee reseñas
4. Analiza precios
5. Te da una recomendación fundamentada

### Los 4 componentes de un agente

1. **Modelo de IA** (el cerebro): Claude, GPT-4, etc. — el que piensa
2. **Herramientas** (las manos): Búsqueda web, calculadora, APIs — lo que puede hacer
3. **Memoria** (el cuaderno): Recuerda conversaciones pasadas y datos importantes
4. **Instrucciones** (el manual): Las reglas y personalidad del agente (system prompt)

### ¿Por qué importan los agentes?

Los agentes son el futuro del trabajo con IA. En vez de tú hacer 5 pasos manuales, **le das una tarea al agente y él hace todo el proceso**. Es la diferencia entre manejar un carro manual y uno automático.',
    1,
    60,
    'Abre ChatGPT y prueba la diferencia: 1) Modo chatbot: "Dime el clima de Medellín" (solo responde). 2) Modo agente: "Investiga los 5 restaurantes mejor calificados en Medellín, compara precios y menú, y recomiéndame el mejor para una cena de negocios" (busca, analiza, decide). Nota la diferencia en complejidad.',
    25
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la diferencia principal entre un chatbot y un AI Agent?', '["El precio", "El chatbot responde y el agente piensa, decide y actúa", "El idioma que usan", "No hay diferencia"]', 1, 1, 'Un chatbot responde basándose en información cargada, mientras un AI Agent piensa, busca información, decide qué hacer, y ejecuta acciones por su cuenta.'),
    (v_lesson_id, '¿Cuáles son los 4 componentes de un AI Agent?', '["HTML, CSS, JavaScript, React", "Modelo de IA, herramientas, memoria e instrucciones", "CPU, RAM, disco duro, pantalla", "Login, dashboard, perfil, logout"]', 1, 2, 'Los 4 componentes son: Modelo de IA (cerebro), Herramientas (manos), Memoria (cuaderno), e Instrucciones (manual/system prompt).'),
    (v_lesson_id, '¿Qué es el "system prompt" de un agente?', '["Un error del sistema", "Las instrucciones que definen la personalidad y reglas del agente", "El nombre de una IA", "Un tipo de API"]', 1, 3, 'El system prompt son las instrucciones que definen cómo debe comportarse el agente: su personalidad, sus límites, y sus reglas de operación.');
  END IF;

  -- LECCIÓN 18: Construye un agente básico
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod4_id,
    'Construye un agente básico',
    '## Construye un agente básico

Vamos a crear tu primer agente de IA. No te asustes — es más simple de lo que parece.

### El flujo de un agente

```
Trigger (webhook/WhatsApp)
    ↓
Nodo de IA (Claude/GPT)
    ↓
Herramientas (búsqueda, cálculo)
    ↓
Respuesta al usuario
```

### El system prompt: el ADN del agente

El **system prompt** es lo más importante. Es el documento que define:
- **Quién es**: "Eres un asistente experto en nutrición"
- **Qué sabe**: "Tienes conocimiento de dietas, calorías, y planes alimenticios"
- **Qué puede hacer**: "Puedes crear planes de alimentación personalizados"
- **Qué NO puede hacer**: "No puedes dar diagnósticos médicos"
- **Cómo habla**: "Habla de forma amigable y usa ejemplos cotidianos"

### Ejemplo de system prompt

```
Eres PapaBot, un asistente amigable para la tienda de papas
"La Papa Feliz". Tu trabajo es:
- Responder preguntas sobre nuestros productos
- Dar información de precios y horarios
- Sugerir combinaciones de productos
- Tomar pedidos

Horario: Lunes a Sábado 8am-8pm
Productos: Papa rellena ($8.000), Papa frita ($5.000),
Papa gratinada ($10.000)

Si te preguntan algo que no sabes, di:
"No tengo esa información, pero puedo conectarte con
un asesor humano."

Siempre sé amigable y usa emojis ocasionalmente.
```

### Construyendo en Make.com o n8n

**En Make.com:**
1. Módulo Webhook (recibe la pregunta)
2. Módulo OpenAI/Claude (procesa con el system prompt)
3. Módulo HTTP (responde)

**En n8n:**
1. Nodo Webhook Trigger
2. Nodo AI Agent (con herramientas configuradas)
3. Nodo Response

### Ajustando el agente

La clave es **probar y ajustar**:
- Envía diferentes preguntas
- Ve dónde falla
- Mejora el system prompt
- Repite hasta que funcione bien',
    2,
    80,
    'En Make.com o n8n, crea un agente simple: cuando recibe una pregunta por webhook → consulta a Claude API → responde. Prueba enviándole diferentes tipos de preguntas y ajusta el system prompt para que responda como experto en un tema.',
    40
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué define el system prompt de un agente?', '["El color de la interfaz", "La personalidad, conocimientos, capacidades y límites del agente", "El precio del servicio", "El nombre del usuario"]', 1, 1, 'El system prompt define quién es el agente, qué sabe, qué puede hacer, qué no puede hacer, y cómo debe hablar.'),
    (v_lesson_id, '¿Cuál es el primer paso para crear un agente en Make.com?', '["Crear un módulo de diseño", "Configurar un módulo Webhook que reciba las preguntas", "Comprar un dominio", "Crear una base de datos"]', 1, 2, 'El primer paso es configurar un Webhook que actúe como la entrada — recibe las preguntas que luego serán procesadas por el módulo de IA.'),
    (v_lesson_id, '¿Qué debe hacer un buen system prompt cuando el agente no sabe algo?', '["Inventar la respuesta", "Indicar al agente que escale a un humano o diga que no tiene la información", "Ignorar la pregunta", "Cerrar la conversación"]', 1, 3, 'Un buen system prompt debe indicar al agente que reconozca cuando no sabe algo y ofrezca conectar con un humano en vez de inventar respuestas.'),
    (v_lesson_id, '¿Cuál es la clave para mejorar un agente?', '["Dejarlo como está", "Probar con diferentes preguntas, ver dónde falla, y ajustar el system prompt", "Cambiar de herramienta cada vez", "Agregar más APIs"]', 1, 4, 'La clave es un ciclo de prueba y mejora: envía preguntas diversas, identifica fallos, mejora el system prompt, y repite.');
  END IF;

  -- LECCIÓN 19: Agente con memoria
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod4_id,
    'Agente con memoria',
    '## Agente con memoria

¿Te ha pasado que hablas con un chatbot y cada mensaje empieza de cero? No recuerda nada de lo que le dijiste antes. Eso es un agente **sin memoria**. Vamos a arreglarlo.

### ¿Por qué la memoria importa?

Sin memoria:
- "Hola, me llamo Juan" → "¡Hola Juan!"
- "¿Cómo me llamo?" → "No sé tu nombre"

Con memoria:
- "Hola, me llamo Juan" → "¡Hola Juan!" (guarda: usuario = Juan)
- "¿Cómo me llamo?" → "Te llamas Juan" (lee la memoria)

### Dos tipos de memoria

**Memoria corta (conversación actual):**
- El historial de mensajes de esta conversación
- Se pierde cuando termina la sesión
- Es como la memoria RAM de un computador

**Memoria larga (entre conversaciones):**
- Datos que persisten para siempre
- Se guardan en una base de datos
- Es como el disco duro de un computador

### Implementación simple con Google Sheets

La forma más fácil de agregar memoria larga:

**Estructura de la hoja:**
| Fecha | Usuario | Mensaje | Respuesta |
|-------|---------|---------|-----------|
| 2024-01-15 | Juan | ¿Cuánto cuesta el plan? | El plan cuesta... |
| 2024-01-15 | Juan | ¿Tienen descuento? | Sí, tenemos... |

**En tu automatización:**
1. Cuando llega un mensaje → busca las últimas 5 interacciones de ese usuario
2. Incluye ese historial en el prompt: "Contexto de conversaciones anteriores: ..."
3. La IA responde con contexto
4. Guarda la nueva interacción

### Memoria con Supabase

Para algo más robusto:
- Tabla de conversaciones con user_id
- Consultas más rápidas
- Mejor para muchos usuarios
- Se conecta igual con Make.com/n8n

### El resultado

Tu agente ahora **recuerda**:
- Nombres y preferencias
- Productos que le interesaron
- Preguntas anteriores
- Contexto de la relación',
    3,
    80,
    'Agrega memoria a tu agente: cada conversación se guarda en Google Sheets (columnas: fecha, usuario, mensaje, respuesta). Cuando alguien escribe, el agente revisa las últimas 5 interacciones para dar contexto. Prueba teniendo una conversación de múltiples mensajes.',
    40
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la diferencia entre memoria corta y memoria larga en un agente?', '["No hay diferencia", "La corta es la conversación actual, la larga persiste entre conversaciones", "La corta es más cara", "La larga es solo para agentes premium"]', 1, 1, 'La memoria corta es el historial de la conversación actual (se pierde al terminar), mientras la memoria larga persiste entre conversaciones usando una base de datos.'),
    (v_lesson_id, '¿Cuál es la forma más fácil de agregar memoria larga a un agente?', '["Programar una base de datos compleja", "Guardar las conversaciones en Google Sheets", "Comprar un servidor dedicado", "No se puede agregar memoria"]', 1, 2, 'Google Sheets es la forma más simple: guardas fecha, usuario, mensaje y respuesta, y el agente consulta las últimas interacciones antes de responder.'),
    (v_lesson_id, '¿Cuántas interacciones anteriores debería consultar el agente para dar contexto?', '["Todas las que existan", "Las últimas 5 interacciones", "Solo la última", "Ninguna"]', 1, 3, 'Consultar las últimas 5 interacciones da suficiente contexto sin sobrecargar al modelo de IA con demasiada información.');
  END IF;

  -- LECCIÓN 20: Proyecto - Agente de WhatsApp 24/7
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod4_id,
    'Proyecto: Agente de WhatsApp 24/7',
    '## Proyecto: Agente de WhatsApp 24/7

Este es el proyecto más ambicioso hasta ahora: un **agente completo de WhatsApp** que atiende clientes de un negocio real, 24 horas al día, 7 días a la semana.

### Lo que vas a construir

Un agente que:
1. **Responde preguntas** sobre el negocio
2. **Da información** de productos y precios
3. **Agenda citas** (guarda en Google Sheets)
4. **Recuerda clientes** (memoria entre conversaciones)
5. **Escala a humano** cuando no puede resolver

### Arquitectura del sistema

```
Cliente escribe por WhatsApp
        ↓
Webhook recibe el mensaje
        ↓
Buscar historial del cliente (memoria)
        ↓
Enviar mensaje + historial + system prompt a la IA
        ↓
La IA decide qué hacer:
  → Responder pregunta
  → Agendar cita (escribir en Sheets)
  → Escalar a humano
        ↓
Enviar respuesta por WhatsApp
        ↓
Guardar interacción en memoria
```

### System prompt del agente

Tu system prompt debe cubrir:
- Información completa del negocio
- Lista de productos/servicios con precios
- Horarios de atención
- Políticas (cambios, devoluciones, garantías)
- Protocolo de agendamiento
- Reglas de escalamiento a humano
- Tono y personalidad

### Escalamiento a humano

El agente debe escalar cuando:
- El cliente está molesto o insatisfecho
- La pregunta es demasiado compleja
- El cliente pide explícitamente hablar con un humano
- El tema es sensible (reclamos, quejas)

### Métricas para medir éxito

Después de 24 horas funcionando, revisa:
- ¿Cuántas conversaciones tuvo?
- ¿Cuántas resolvió solo vs escaló?
- ¿Las respuestas fueron correctas?
- ¿Los clientes quedaron satisfechos?',
    4,
    150,
    'Construye el agente completo: 1) Chatbot en WhatsApp (Chatbase o n8n), 2) Entrenado con info real de un negocio, 3) Con memoria de conversaciones, 4) Con escalamiento a humano, 5) Registro de conversaciones en Google Sheets. Ponlo a funcionar 24 horas y analiza las conversaciones.',
    90
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuáles son las capacidades principales del agente de WhatsApp?', '["Solo responder hola", "Responder preguntas, dar info de productos, agendar citas, recordar clientes y escalar a humano", "Solo enviar imágenes", "Solo tomar pedidos"]', 1, 1, 'El agente combina múltiples capacidades: responder preguntas, informar sobre productos, agendar citas, mantener memoria del cliente, y escalar cuando es necesario.'),
    (v_lesson_id, '¿Cuándo debe el agente escalar a un humano?', '["Nunca", "Cuando el cliente está molesto, la pregunta es muy compleja, o pide hablar con un humano", "Solo los lunes", "Después de 5 mensajes"]', 1, 2, 'El agente debe escalar cuando el cliente está insatisfecho, cuando la pregunta es demasiado compleja, cuando el cliente lo pide, o en temas sensibles.'),
    (v_lesson_id, '¿Qué debes revisar después de que el agente funcione 24 horas?', '["Solo el diseño", "Cuántas conversaciones tuvo, cuántas resolvió solo, y si las respuestas fueron correctas", "El precio del plan", "Nada, ya está listo"]', 1, 3, 'Es crucial analizar: cantidad de conversaciones, tasa de resolución vs escalamiento, exactitud de respuestas, y satisfacción del cliente.');
  END IF;

  -- =============================================
  -- MÓDULO 5: "Negocio con IA"
  -- =============================================

  -- LECCIÓN 21: Modelos de negocio con IA
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod5_id,
    'Modelos de negocio con IA',
    '## Modelos de negocio con IA

Ya sabes crear páginas web, automatizaciones, chatbots y agentes. Ahora la pregunta es: **¿cómo convertir esto en dinero?**

### 5 modelos que funcionan

**1. Automatización como servicio**
- Cobras por automatizar procesos de negocios
- Ejemplo: "Te automatizo la captación de clientes por $500.000/mes"
- Margen alto porque lo haces una vez y cobra mensualidad
- Ideal para: restaurantes, clínicas, inmobiliarias

**2. Chatbots para empresas**
- Cobras setup + mensualidad por mantenimiento
- Ejemplo: "Chatbot de WhatsApp para tu negocio: $800.000 setup + $200.000/mes"
- El cliente ve valor inmediato (atención 24/7)
- Ideal para: cualquier negocio con atención al cliente

**3. Contenido con IA**
- Creas contenido para redes sociales usando IA
- Ejemplo: "Plan de 30 posts mensuales para Instagram: $1.200.000/mes"
- Usas ChatGPT para textos, DALL-E para imágenes
- Ideal para: marcas, restaurantes, coaches

**4. Consultoría de IA**
- Diagnosticas qué puede automatizar un negocio y lo implementas
- Ejemplo: "Auditoría de automatización: $1.500.000"
- Cobras por el conocimiento y la implementación
- Ideal para: empresas medianas

**5. SaaS con IA (herramienta con suscripción)**
- Creas una herramienta que cobra mensualidad
- Ejemplo: "App de generación de facturas con IA: $50.000/mes"
- Requiere más trabajo inicial pero escala infinitamente
- Ideal para: nichos específicos con problemas repetitivos

### Ejemplos reales en LATAM

- Agencia en Bogotá que cobra $2M/mes por manejar chatbots de 10 restaurantes
- Freelancer en México que automatiza procesos de clínicas dentales
- Emprendedor en Lima que vende generación de contenido a 20 marcas
- Startup en Buenos Aires que creó un SaaS de agendamiento con IA

### La clave: resolver problemas reales

No vendas "IA" — vende la **solución al problema**:
- No: "Le hago un chatbot con IA"
- Sí: "Le garantizo que ningún cliente se va a quedar sin respuesta, incluso a las 3am"',
    1,
    60,
    'Investiga 5 negocios en tu ciudad que podrían beneficiarse de IA. Para cada uno escribe: qué problema tienen, qué solución de IA les ayudaría, cuánto podrías cobrar, y cómo lo implementarías con lo que ya sabes.',
    30
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál modelo de negocio cobra setup + mensualidad?', '["Contenido con IA", "Chatbots para empresas", "Consultoría", "SaaS"]', 1, 1, 'El modelo de chatbots para empresas típicamente cobra un setup inicial por la creación y configuración, más una mensualidad por mantenimiento y soporte.'),
    (v_lesson_id, '¿Qué debes vender al cliente?', '["Tecnología compleja", "La solución al problema del cliente, no la IA en sí", "El modelo de IA más caro", "Cursos de programación"]', 1, 2, 'No vendas "IA" — vende la solución al problema. Al cliente le importa que sus clientes reciban respuesta 24/7, no qué tecnología lo hace posible.'),
    (v_lesson_id, '¿Qué modelo de negocio escala infinitamente?', '["Consultoría", "Automatización como servicio", "SaaS con IA (herramienta con suscripción)", "Contenido con IA"]', 2, 3, 'Un SaaS (Software as a Service) requiere más trabajo inicial pero una vez creado puede servir a miles de clientes con el mismo producto, escalando sin límite.');
  END IF;

  -- LECCIÓN 22: Encuentra tu nicho
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod5_id,
    'Encuentra tu nicho',
    '## Encuentra tu nicho

"Si le vendes a todos, no le vendes a nadie." El nicho es tu **especialización** — el tipo específico de cliente que atiendes.

### La intersección mágica

Tu nicho ideal está en la intersección de:
1. **Lo que sabes hacer** (tus habilidades con IA)
2. **Lo que necesita el mercado** (problemas reales que la gente paga por resolver)
3. **Lo que puedes cobrar** (que el precio sea justo para ambos)

### Ejemplos de nichos

- Chatbots para **restaurantes** en tu ciudad
- Automatización de citas para **clínicas dentales**
- Contenido con IA para **coaches de fitness**
- Páginas web para **inmobiliarias**
- Agentes de WhatsApp para **tiendas de ropa**

### Validación rápida

Antes de construir nada, **habla con 5 personas** de tu nicho elegido:

1. "¿Cuál es tu mayor dolor de cabeza en el día a día?"
2. "¿Cómo manejas eso actualmente?"
3. "¿Cuánto tiempo/dinero te cuesta?"
4. "Si existiera una solución automática, ¿cuánto pagarías?"
5. "¿Conoces a alguien más con el mismo problema?"

### El framework

**Problema** → Lo que le duele al cliente
**Solución** → Lo que tú puedes hacer con IA
**Propuesta de valor** → Una frase que lo resume todo
**Precio** → Lo que es justo para ambos

**Ejemplo:**
- Problema: Los restaurantes pierden clientes porque no responden WhatsApp fuera de horario
- Solución: Chatbot de WhatsApp que atiende 24/7
- Propuesta: "Nunca pierdas un cliente por no responder a tiempo"
- Precio: $300.000 setup + $150.000/mes

### Errores comunes

- ❌ Elegir un nicho porque "suena bonito" sin validar
- ❌ Intentar servir a todos los nichos al mismo tiempo
- ❌ No hablar con clientes potenciales antes de construir
- ❌ Poner precios basados en lo que tú pagarías, no en el valor que generas',
    2,
    70,
    'Define tu servicio: 1) Elige un nicho (restaurantes, médicos, inmobiliarias, etc.), 2) Define el problema que resuelves, 3) Escribe tu propuesta de valor en una frase, 4) Define tu precio, 5) Habla con 5 personas del nicho y pregúntales si pagarían. Ajusta basado en sus respuestas.',
    35
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué es un nicho en el contexto de negocios?', '["Un tipo de red social", "Un tipo específico de cliente o mercado en el que te especializas", "Un modelo de IA", "Un tipo de automatización"]', 1, 1, 'Un nicho es tu especialización: el tipo específico de cliente o industria que atiendes. Especializarte te permite ser mejor y cobrar más.'),
    (v_lesson_id, '¿Qué debes hacer ANTES de construir tu producto o servicio?', '["Comprar un dominio", "Hablar con 5 personas del nicho para validar que pagarían", "Crear todas las automatizaciones", "Publicar en redes sociales"]', 1, 2, 'Validar antes de construir es crucial: habla con 5 personas del nicho para confirmar que el problema existe y que pagarían por la solución.'),
    (v_lesson_id, '¿Cómo debes definir tus precios?', '["Lo más barato posible", "Basado en el valor que generas para el cliente, no en lo que tú pagarías", "Copiando a la competencia", "Siempre gratis al principio"]', 1, 3, 'Tus precios deben basarse en el valor que generas. Si tu chatbot le ahorra a un restaurante 2 horas diarias de trabajo, eso tiene un valor medible.');
  END IF;

  -- LECCIÓN 23: Construye tu MVP
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod5_id,
    'Construye tu MVP',
    '## Construye tu MVP

### ¿Qué es un MVP?

MVP = **Producto Mínimo Viable**. Es la versión **más simple que funciona** y te permite empezar a cobrar.

No necesita ser perfecto. No necesita tener todas las funciones. Solo necesita **resolver el problema principal del cliente**.

### Lo que ya sabes hacer

Mira lo que has aprendido en este curso:
- ✅ Crear páginas web profesionales (Claude Code / v0)
- ✅ Generar imágenes (DALL-E / Ideogram)
- ✅ Crear chatbots (Chatbase)
- ✅ Automatizar procesos (Make.com)
- ✅ Conectar APIs
- ✅ Construir agentes de IA
- ✅ Usar Google Sheets como base de datos

**Eso ES tu producto.** No necesitas más para empezar.

### Componentes de tu MVP

**1. Landing page profesional**
- Hecha con Claude Code
- Explica claramente qué haces y para quién
- Tiene testimonios (aunque sean de pruebas piloto)
- Call-to-action claro: "Agenda una demo" o "Escríbeme por WhatsApp"

**2. Producto core (el servicio principal)**
- Chatbot o agente de IA configurado
- O automatización implementada
- O generación de contenido entregada

**3. Automatización de entrega**
- Formulario de onboarding para nuevos clientes
- Respuestas automáticas
- Sistema de seguimiento

**4. Hoja de precios clara**
- 2-3 planes simples
- Qué incluye cada uno
- Sin letra chica

### La mentalidad MVP

> "Si no te da vergüenza la primera versión de tu producto, lo lanzaste demasiado tarde." — Reid Hoffman (fundador de LinkedIn)

La versión 1 no será perfecta. Pero una versión imperfecta que funciona es **infinitamente mejor** que una versión perfecta que nunca lanzas.',
    3,
    100,
    'Arma tu MVP completo: 1) Landing page profesional con Claude Code, 2) Chatbot o agente de IA como producto core, 3) Automatización de entrega/seguimiento, 4) Hoja de precios clara. Todo debe estar funcionando y accesible con un link.',
    60
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué significa MVP?', '["Mi Versión Personal", "Modelo de Venta Premium", "Producto Mínimo Viable — la versión más simple que funciona", "Marketing Virtual Profesional"]', 2, 1, 'MVP significa Producto Mínimo Viable: la versión más simple de tu producto que funciona y te permite empezar a cobrar y recibir feedback.'),
    (v_lesson_id, '¿Cuántos planes de precios debe tener tu MVP?', '["1 solo plan", "2-3 planes simples y claros", "10 planes para todos los presupuestos", "No debe tener precios fijos"]', 1, 2, 'Lo ideal es 2-3 planes simples y claros. Demasiados planes confunden al cliente; muy pocos no dan flexibilidad.'),
    (v_lesson_id, '¿Qué es mejor: una versión imperfecta que funciona o una versión perfecta que nunca lanzas?', '["La versión perfecta", "La versión imperfecta que funciona y se puede mejorar", "Ninguna, hay que esperar al momento indicado", "Depende del presupuesto"]', 1, 3, 'Una versión imperfecta que funciona te permite empezar a cobrar, recibir feedback, y mejorar. Una versión perfecta que nunca lanzas no genera nada.');
  END IF;

  -- LECCIÓN 24: Lanzamiento
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (
    v_mod5_id,
    'Lanzamiento',
    '## Lanzamiento

Este es el momento de la verdad. Todo lo que has aprendido — IA, automatización, chatbots, agentes, diseño — se junta aquí. Es hora de **salir al mercado**.

### Paso 1: Define tus primeros 3 clientes

No necesitas 100 clientes. Necesitas **3**. Y los primeros 3 se consiguen así:
- Personas que ya conoces (amigos, familia, conocidos)
- Negocios de tu barrio o ciudad
- Contactos en redes sociales
- Referidos de referidos

### Paso 2: Contacta directamente

Nada de publicar posts y esperar. **Contacta directamente:**
- Por WhatsApp: "Hola [nombre], vi que tienes [negocio]. Tengo algo que puede ayudarte a [beneficio]. ¿Te puedo contar en 5 minutos?"
- Por llamada: Mismo pitch, más personal
- En persona: La más efectiva de todas

### Paso 3: Ofrece un piloto

El piloto elimina el miedo del cliente:
- "Te lo configuro gratis por 2 semanas"
- "Si no te funciona, no me pagas nada"
- "Solo me pagas si ves resultados"

El objetivo del piloto NO es ganar dinero. Es:
- Demostrar que funciona
- Obtener un caso de éxito
- Conseguir un testimonio
- Aprender qué mejorar

### Paso 4: Entrega y cobra

Cuando el piloto funciona:
1. Muestra los resultados con datos
2. Presenta el plan de continuidad con precio
3. Cierra el acuerdo
4. Pide un testimonio escrito

### Paso 5: Tu primera venta

Tu primera venta con IA te cambia la perspectiva para siempre. De repente entiendes que:
- **Las habilidades que aprendiste tienen valor real**
- **Puedes crear algo de la nada y cobrar por ello**
- **La IA te da superpoderes que la mayoría no tiene**

### Lo que sigue

Después de tu primer cliente:
- Mejora basado en su feedback
- Consigue el segundo y tercero
- Crea un proceso repetible
- Escala con automatizaciones (meta-automatización)

> "El viaje de mil millas comienza con un solo paso." Tu primer cliente es ese paso.',
    4,
    200,
    'Lanza tu servicio: 1) Contacta 5 personas/negocios de tu nicho, 2) Ofrece un piloto, 3) Consigue al menos 1 cliente piloto, 4) Entrégale el servicio/producto, 5) Pide un testimonio escrito. Documenta todo el proceso con capturas y notas.',
    120
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_lesson_id;

  IF v_lesson_id IS NOT NULL THEN
    INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuántos clientes necesitas para empezar?', '["100", "50", "3", "Al menos 20"]', 2, 1, 'Solo necesitas 3 primeros clientes. Los primeros se consiguen por contacto directo, no por marketing masivo.'),
    (v_lesson_id, '¿Cuál es el objetivo principal de un piloto gratuito?', '["Trabajar gratis siempre", "Demostrar que funciona, obtener un caso de éxito y un testimonio", "Hacer caridad", "Practicar sin presión"]', 1, 2, 'El piloto busca demostrar resultados, conseguir un caso de éxito, obtener un testimonio, y aprender qué mejorar — no es trabajo gratis permanente.'),
    (v_lesson_id, '¿Cuál es la forma más efectiva de conseguir tus primeros clientes?', '["Publicar posts en redes y esperar", "Contactar directamente por WhatsApp, llamada o en persona", "Pagar publicidad costosa", "Esperar a que te contacten"]', 1, 3, 'El contacto directo es la forma más efectiva para los primeros clientes. Nada de publicar y esperar — habla directamente con personas que podrían necesitar tu servicio.');
  END IF;

END $$;
