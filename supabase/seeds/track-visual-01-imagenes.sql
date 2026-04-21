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
     ARRAY[
       'Midjourney — mejor calidad artística',
       'Ideogram 3 o GPT Image — son los mejores integrando texto legible dentro de la imagen',
       'Flux 1.1 Pro — más realista',
       'Cualquiera, todas hacen bien el texto'
     ],
     1,
     0,
     'Texto dentro de imagen fue un punto débil histórico de los generadores. Ideogram se especializó en eso desde el principio, y GPT Image también lo hace muy bien. Midjourney y Flux siguen siendo débiles con texto legible — te van a entregar algo que parece texto pero con letras raras. Para marketing con tipografía, elige la herramienta correcta.'),

    (v_lesson_id,
     '¿Cuáles son los 4 ingredientes típicos de un buen prompt de imagen?',
     ARRAY[
       'Color, tamaño, resolución, formato',
       'Sujeto, estilo, composición, ambiente',
       'Marca, fecha, ubicación, audiencia',
       'Solo describir lo que quieres, la IA entiende sola'
     ],
     1,
     0,
     'Sujeto (qué aparece), estilo (cómo se ve — fotográfico, ilustración, 3D, etc), composición (ángulo, encuadre, distancia) y ambiente (luz, mood, paleta). Un prompt que cubre estos 4 da resultados muy superiores a "un perro" o "una persona feliz". La IA rellena con sus defaults cuando falta información, y los defaults son genéricos.'),

    (v_lesson_id,
     'Ya generaste una imagen que te gusta casi, pero quieres cambiar solo el fondo y dejar el sujeto idéntico. ¿Qué camino eliges?',
     ARRAY[
       'Regenerar desde cero con un prompt distinto y aceptar que cambie todo',
       'Usar una herramienta de edición como Nano Banana: sube la imagen, pídele solo el cambio de fondo, respeta el resto',
       'Abrir Photoshop manualmente',
       'No se puede cambiar solo el fondo con IA'
     ],
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
     ARRAY[
       'Reescribir todo el prompt desde cero',
       'Decir "same scene but shot from above" o "same scene, camera angle from below"',
       'Generar 50 variaciones y elegir',
       'Cambiar de herramienta'
     ],
     1,
     0,
     'Iteración quirúrgica: cambias una capa (la de cámara) y dejas las demás iguales. Esto preserva el sujeto, el estilo y el mood que ya te gustan, y solo ajusta lo que querías. Reescribir desde cero te cambia cosas que no querías cambiar y vuelve el proceso largo.'),

    (v_lesson_id,
     '¿Qué hace "--ar 16:9" en Midjourney?',
     ARRAY[
       'Cambia el modelo de IA a usar',
       'Define el aspect ratio (proporción) de la imagen a 16:9, ideal para thumbnails o banners',
       'Aumenta la resolución',
       'Agrega texto a la imagen'
     ],
     1,
     0,
     '--ar es la bandera para aspect ratio. 16:9 es el formato de thumbnails de YouTube, banners web y monitores. Otros útiles: 1:1 (redes), 9:16 (stories/TikTok), 4:5 (Instagram feed). Decirle el aspecto desde el prompt es mejor que generar cuadrado y recortar después, porque la IA compone pensando en ese formato.'),

    (v_lesson_id,
     'Quieres un estilo visual muy específico pero te cuesta describirlo en palabras. ¿Qué puedes hacer?',
     ARRAY[
       'Resignarte y probar 30 prompts distintos',
       'Subir una imagen de referencia de estilo — la IA copia el estilo y aplica tu prompt',
       'Solo se puede por texto',
       'Pagar por un estilo premium'
     ],
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
     ARRAY[
       'Pagar menos por cada generación',
       'Que el mismo personaje se mantenga consistente a través de múltiples imágenes distintas',
       'Aumentar la resolución final',
       'Cambiar el idioma del prompt'
     ],
     1,
     0,
     'Character reference es la feature que resolvió uno de los problemas más frustrantes de imagen IA: la falta de consistencia. Pasas una imagen de un personaje (tu mascota, tu character, tu diseño) y la IA mantiene sus rasgos en nuevas escenas. Perfecto para sets de marketing, libros ilustrados, cómics o cualquier cosa que requiera el mismo personaje en contextos distintos.'),

    (v_lesson_id,
     'Tienes una foto de producto pero quieres 5 variaciones con fondos distintos sin que el producto cambie. ¿Qué herramienta usas?',
     ARRAY[
       'Regenerar 5 veces desde cero con Midjourney',
       'Usar Nano Banana (Gemini 3 Image) para edición: mismo producto, distintos fondos',
       'Photoshop manual',
       'No es posible'
     ],
     1,
     0,
     'Nano Banana está optimizado exactamente para este caso: cambios quirúrgicos en una imagen existente manteniendo lo demás intacto. Subes la foto del producto, en cada variación solo le dices el fondo nuevo. En 5 minutos tienes 5 variaciones. Regenerar desde cero en MJ te da 5 productos distintos — no sirve para un set cohesivo.'),

    (v_lesson_id,
     '¿Cuál es una limitación real de generación de imágenes en 2026?',
     ARRAY[
       'Las imágenes salen en blanco y negro',
       'Las manos y el texto pequeño aún fallan a veces — siempre revisa, y para texto preciso mejor añadirlo en Figma/Canva después',
       'Solo se pueden hacer imágenes cuadradas',
       'No se pueden hacer personas'
     ],
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
     ARRAY[
       'Generar cada uno con un prompt completamente distinto y esperar que salgan similares',
       'Definir un "hero" con el estilo dominante, aprobarlo, y luego derivar los otros 9 con el mismo estilo (reference + pequeños cambios)',
       'Usar 10 herramientas distintas para tener variedad',
       'Hacerlos a mano en Photoshop'
     ],
     1,
     0,
     'El patrón hero + variantes es lo que hacen las agencias. Consolidas la dirección visual en UNA imagen, la apruebas con el cliente, y las demás se derivan con consistencia. Genera cada una "desde cero" produce sets inconsistentes donde se nota que fueron generadas independientes. Inversión de tiempo: 2-3 horas vs 2 días.'),

    (v_lesson_id,
     '¿Cuál es la mejor práctica con prompts que funcionaron bien?',
     ARRAY[
       'Olvidarlos después de usarlos, cada proyecto es único',
       'Guardarlos en una librería personal (prompts/foto-producto.md, prompts/mockups.md) para reusar y adaptar',
       'Pagarle a otra persona para que los escriba',
       'Nunca reutilizar el mismo prompt'
     ],
     1,
     0,
     'Los profesionales mantienen librerías de prompts que saben que funcionan. Con el tiempo acumulás "fórmulas" probadas — tu manera de pedir retratos, productos, mockups, ilustraciones. Cada proyecto nuevo, partís de una de esas y adaptás. Ahorra horas. Es conocimiento tácito hecho explícito.'),

    (v_lesson_id,
     'Vas a usar una imagen generada para un proyecto comercial (cliente paga). ¿Qué debes revisar?',
     ARRAY[
       'Nada, todas las imágenes IA son de uso libre',
       'Los términos de uso de la herramienta (algunos requieren plan pago para uso comercial), y evitar "estilo de [artista vivo]" o marcas registradas por riesgo legal',
       'Solo la resolución',
       'Que no tenga texto'
     ],
     1,
     0,
     'Cada herramienta tiene términos distintos: Midjourney en plan Basic permite uso personal pero comercial requiere Standard+; otras requieren plan pagado para comercial; algunas reclaman cierta atribución. Además, legalmente es gris generar "estilo de artista X" si el artista está vivo, y recrear logos o packaging de marcas reales es copyright. Para trabajos que cobrás, dedica 10 min a leer los términos.');

  RAISE NOTICE 'Módulo "Imágenes con IA": 4 lecciones + 12 quizzes insertados.';

END $$;
