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
     ARRAY[
       'Text-to-video — escribes un prompt y generas',
       'Image-to-video — generas primero la imagen exacta que quieres, luego la animas',
       'Video-to-video — transformas videos existentes',
       'Ninguno, todos son iguales'
     ],
     1,
     0,
     'Image-to-video te da control total sobre el look final: primero generás la imagen perfecta (donde tenés 100% de control visual), y solo después le pedís a la IA que la anime. Text-to-video es más creativo pero menos predecible — muchas veces el resultado visual no coincide con lo que tenías en la cabeza. En flujos profesionales, image-to-video gana casi siempre.'),

    (v_lesson_id,
     'Te piden un video de una persona interactuando con otra mientras hablan durante 45 segundos con diálogo específico. ¿Va a salir bien en 2026?',
     ARRAY[
       'Sí, fácil',
       'Difícil — múltiples personas interactuando con diálogo largo y coherente sigue fallando, mejor hacer clips cortos y editarlos, o combinar con rodaje real',
       'No se puede hacer nada con IA',
       'Depende solo del presupuesto'
     ],
     1,
     0,
     'La honestidad ayuda. Paisajes, productos, acciones simples y diálogos cortos salen bien. Pero múltiples personajes interactuando con diálogo específico por 45 segundos aún falla en 2026 — inconsistencias, labios no sincronizados, momentos raros. El workaround: hacer varios clips cortos con pausas, editarlos, o combinar IA con rodaje real. Lo que nunca funciona es generar un clip único largo y esperar que todo salga bien.'),

    (v_lesson_id,
     'Para producir 5 versiones de un anuncio corto (15 segundos) sin rodaje costoso, ¿cuánto cuesta hoy con IA?',
     ARRAY[
       'Miles de dólares',
       'Típicamente entre $20-100 total usando herramientas pay-per-use como Sora o Kling',
       'Gratis, no tiene costo',
       'Solo funciona si tenés equipo profesional'
     ],
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
     ARRAY[
       'Resolución',
       'Movimiento de cámara',
       'Duración en minutos',
       'Idioma del prompt'
     ],
     1,
     0,
     'Video introduce el eje del tiempo, y la cámara puede moverse. Decir "dolly in slowly" o "handheld tracking shot" te da resultados cinematográficos predecibles. Si no especificás, la IA toma decisiones que muchas veces no son las que querías. Aprender vocabulario de cinematografía es una inversión pequeña con retorno enorme.'),

    (v_lesson_id,
     'Tu prompt pide "una persona caminando por un parque, se encuentra con amiga, se abrazan, se sientan a conversar" en 8 segundos. ¿Qué pasa?',
     ARRAY[
       'La IA lo hace perfectamente',
       'Intenta meter todo en 8 segundos y el resultado atropella todas las acciones — mejor dividir en 3 clips separados',
       'Solo funciona en Sora',
       'La IA rechaza el prompt'
     ],
     1,
     0,
     'Error clásico. Un clip de IA funciona bien con UNA o DOS acciones claras, no con una cadena narrativa completa. Para historias más complejas: divide en clips separados, cada uno con un momento específico, luego edítalos juntos. Esto además te da más control — si un clip sale mal, regenerás solo ese.'),

    (v_lesson_id,
     'Quieres un clip donde el logo cerrado se abre al logo final en 3 segundos. ¿Qué herramienta/feature aprovechas?',
     ARRAY[
       'Prompt largo explicando la transición',
       'End frame / first-and-last frame: das imagen inicial + imagen final, la IA interpola el movimiento',
       'Regenerar muchas veces hasta que salga',
       'No se puede con IA'
     ],
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
     ARRAY[
       'Porque es gratis',
       'Porque desacoplás la generación del look (en la imagen) de la generación del movimiento (en el video), pudiendo iterar cada paso por separado',
       'Porque las herramientas son mejores',
       'Porque el resultado es más rápido'
     ],
     1,
     0,
     'En text-to-video la IA resuelve dos problemas simultáneos: composición visual y movimiento. Si uno falla, el clip entero no sirve. En image-to-video primero consolidás la imagen (una iteración), y después solo peleás con el movimiento (otra iteración). Cada paso es controlable. Los profesionales casi siempre trabajan así porque el resultado se parece mucho más a la idea original.'),

    (v_lesson_id,
     'Para un promo de 30 segundos con 6 tomas distintas del mismo personaje, ¿qué haces para mantener consistencia?',
     ARRAY[
       'Generar un solo clip de 30 segundos',
       'Generar 6 imágenes del personaje usando character reference (--cref o equivalente), y hacer image-to-video de cada una',
       'Hacer rodaje real',
       'No es posible, el personaje siempre va a cambiar'
     ],
     1,
     0,
     'Clips largos (30s) suelen inventar cosas y perder consistencia. El patrón que funciona: 6 imágenes consistentes usando character reference de una imagen base, luego animar cada una individualmente (5s x 6 = 30s), y editarlas juntas. Como las 6 imágenes base ya son consistentes, los 6 clips mantienen al mismo personaje.'),

    (v_lesson_id,
     'Necesitas un clip con un personaje hablando y diciendo una frase específica con lip sync. ¿Qué herramienta usas en 2026?',
     ARRAY[
       'Cualquier modelo antiguo, todos lo hacen bien',
       'Veo 3 de Google — es el mejor modelo hoy para lip sync con audio sincronizado',
       'Solo se puede con rodaje real',
       'Midjourney'
     ],
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
     ARRAY[
       '0 segundos, va directo al mensaje',
       'Los primeros 3 segundos son críticos — si no enganchas ahí, el espectador hace scroll en Reels/TikTok',
       'La mitad del video',
       'Solo el final'
     ],
     1,
     0,
     'En formatos de scroll vertical (Reels, TikTok, Shorts) los primeros 3 segundos deciden si el espectador se queda o pasa. Por eso la "A" de AIDA (Atención) es el arranque y es crítica. Un hook potente visual, una pregunta provocadora o un movimiento inesperado. Si lo primero es lento o genérico, el resto del ad no importa — nadie lo ve.'),

    (v_lesson_id,
     '¿Qué es un storyboard y por qué hacerlo ANTES de generar videos?',
     ARRAY[
       'Un dibujo opcional, no sirve mucho',
       'El plan visual del video (qué se ve, cuándo, con qué cámara). Hacerlo antes evita perder tiempo generando tomas que no suman a la narrativa',
       'Es solo para proyectos grandes',
       'Solo lo hacen los directores de cine'
     ],
     1,
     0,
     'Sin storyboard vas generando al azar, a ver qué sale. Resultado: 20 clips bonitos que no cuentan nada. Con storyboard primero definís la narrativa (qué se ve cuándo y con qué cámara) y después producís exactamente eso. Ahorra tiempo y plata (cada generación IA cuesta). El storyboard puede ser simple — una tabla de texto alcanza, no necesitás dibujar.'),

    (v_lesson_id,
     'Tu ad IA queda decente pero no "brillante". ¿Qué suele marcar la diferencia entre decente y brillante?',
     ARRAY[
       'Solo herramientas más caras',
       'Música bien elegida con cortes en los beats + edición (transiciones, ritmo, CTA claro) — la generación IA es 60%, el post-production es el 40% que separa decente de brillante',
       'Mayor resolución',
       'Usar Photoshop'
     ],
     1,
     0,
     'La generación IA te da material crudo. Lo que lo convierte en un ad que la gente mira es: (1) música elegida con intención + cortes sincronizados con beats, (2) transiciones bien diseñadas, (3) ritmo general (no todo al mismo pulso), (4) un CTA claro y con peso visual. Dedica 1/3 del tiempo total del proyecto al post-production. Es donde todo se decide.');

  RAISE NOTICE 'Módulo "Video con IA": 4 lecciones + 12 quizzes insertados.';

END $$;
