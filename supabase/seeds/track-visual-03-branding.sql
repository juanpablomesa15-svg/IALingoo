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
     ARRAY[
       'Un tipo de logo',
       'Una personalidad narrativa que define el tono de comunicación (Hero, Sage, Creator, etc.) — guía todas las decisiones visuales y de copy',
       'Un formato de archivo',
       'Solo sirve para marcas grandes'
     ],
     1,
     0,
     'Los 12 arquetipos jungianos son personalidades universales que se repiten en marcas y narrativas. Nike es Hero (superación), Apple es Creator (innovación), Harley es Outlaw (rebeldía). Elegir uno te da un ancla de tono: "si fuéramos Hero, ¿qué diríamos?". Evita que cada post/pieza se sienta distinto. Marcas fuertes son coherentes porque tienen un arquetipo claro detrás.'),

    (v_lesson_id,
     'Antes de generar tu logo con IA, ¿qué deberías tener listo?',
     ARRAY[
       'Solo una idea general en la cabeza',
       'Estrategia escrita: audiencia, oferta, diferencial, feel en 3 palabras, arquetipo, espectros visuales, moodboard',
       'Un presupuesto alto',
       'Un estudio de diseño contratado'
     ],
     1,
     0,
     'Generar sin estrategia es generar al azar. Podés ver 50 logos bonitos y no saber cuál elegir porque no tenés un criterio. Tener la estrategia definida ANTES te deja evaluar cada opción contra tu brief: "este logo comunica el feel correcto? ¿encaja con mi arquetipo?". Es la diferencia entre generar arte random y diseñar con intención.'),

    (v_lesson_id,
     'Al elegir el nombre de tu marca, ¿qué debés verificar además de que "suene bien"?',
     ARRAY[
       'Nada más, si suena bien alcanza',
       'Disponibilidad de dominio (.com o de tu país) + al menos 2 redes sociales, y que sea fácil de escribir/pronunciar en los idiomas de tu audiencia',
       'Que sea muy largo para destacar',
       'Que empiece con A para aparecer primero'
     ],
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
     ARRAY[
       'Son más caros',
       'Manejan texto legible (tipografía del wordmark) — Midjourney es excelente estéticamente pero falla en letras claras',
       'Solo permiten logos',
       'No son mejores'
     ],
     1,
     0,
     'Esto es lo más frustrante de Midjourney: genera imágenes hermosas pero las letras salen distorsionadas o con caracteres raros. Ideogram y GPT Image se entrenaron específicamente para texto legible. Para logos (donde el nombre de la marca debe leerse perfecto) son la elección correcta. Si amás el estilo estético de MJ, podés generar el símbolo ahí y combinar el wordmark en Figma.'),

    (v_lesson_id,
     'Un logo generado por IA rara vez está 100% listo. ¿Qué hacés después de generarlo?',
     ARRAY[
       'Usarlo directamente tal como salió',
       'Vectorizarlo (PNG → SVG con herramientas como Vectorizer.ai) y refinarlo en Figma: ajustar proporciones, espaciado y colores exactos',
       'Generarlo 100 veces más hasta que salga perfecto',
       'Pagarle a un diseñador que lo rehaga entero'
     ],
     1,
     0,
     'El flujo profesional: IA genera la idea visual, Figma la termina. Necesitás SVG para que escale sin pixelarse, control exacto de colores (el PNG tiene variaciones mínimas entre versiones), y ajustes finos que IA no controla (espaciado entre símbolo y texto, alineación perfecta, versiones). Vectorizar + refinar toma 30-60 min y cambia todo.'),

    (v_lesson_id,
     'Una paleta de marca sólida típicamente tiene:',
     ARRAY[
       '10 colores para tener variedad',
       '1 primario + 1-2 secundarios + neutros (blanco, negro, grises) + opcional 1 acento para CTAs — en total 4-6 tonos',
       'Solo 1 color, el primario',
       'Todos los colores del arcoíris'
     ],
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
     ARRAY[
       'Una plantilla gratis que descargás',
       'Un conjunto de variables de color, estilos de texto y componentes reutilizables — hace que diseñar una pieza nueva tome 15 min en vez de 1h, y mantiene consistencia',
       'Una extensión de pago',
       'Solo sirve para apps grandes'
     ],
     1,
     0,
     'Un design system es la librería de "átomos" de tu marca en Figma: colores como variables (no hex pegados), estilos de texto predefinidos (H1, body...), componentes (botón primario, card...). Cuando creás una pieza nueva, arrastrás componentes existentes. Resultado: velocidad + consistencia automática. Cuando cambiás el color primario, todas las piezas se actualizan. Es la diferencia entre diseñar con intención vs improvisar cada vez.'),

    (v_lesson_id,
     '¿Qué es "voice & tone" en branding?',
     ARRAY[
       'El sonido del logo',
       'La personalidad de cómo habla la marca: vocabulario, ritmo, formalidad — parte del branding igual que lo visual',
       'Solo aplica para marcas con podcast',
       'Un sinónimo de "tipografía"'
     ],
     1,
     0,
     'Una marca es visual Y textual. Cómo escribís tus posts, emails, captions y páginas web comunica tanto como tu logo. Voice & tone define: con qué personalidad habla tu marca, qué palabras usa, qué evita, cuán formal es. Sin un voice definido, cada pieza tiene un tono distinto y la marca se siente inconsistente. Definirlo toma 30 min y se replica en cientos de piezas.'),

    (v_lesson_id,
     'Terminás tu brand. ¿Cuál es el mejor test de consistencia?',
     ARRAY[
       'Revisar vos mismo con cuidado',
       'Mostrarle a alguien externo 5 piezas al azar (posts, logo, email, web) y preguntarle si parecen de la misma marca — si duda, ajustá',
       'No hay forma de testear',
       'Esperar a que un cliente se queje'
     ],
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
     ARRAY[
       'Siempre hacer rebrand, es más impactante',
       'Rebrand solo cuando hay un cambio estructural (nuevo público, pivote, escalado a nuevos mercados). Micro-iteraciones para afinar lo que ya funciona',
       'Nunca hacer rebrand',
       'Cada 3 meses rebrand automáticamente'
     ],
     1,
     0,
     'Rebrands tienen costo: pérdida de reconocimiento acumulado, confusión de la audiencia, inversión en re-producción de piezas. Solo se justifican cuando algo estructural cambió en el negocio. Para mejorar lo que tenés, micro-iteraciones son más seguras: cambiás un color, añadís un patrón, evolucionás voice. No hay anuncio, no hay reset.'),

    (v_lesson_id,
     'El error más grande al iterar una marca es:',
     ARRAY[
       'Cambiar muy poco',
       'Confundir "a mí me gusta" con "funciona" — decisiones deben basarse en datos (reconocimiento, engagement, conversión), no solo en tu gusto personal',
       'Usar IA para los cambios',
       'Pedir feedback a alguien más'
     ],
     1,
     0,
     'Tu gusto no es la métrica. El logo/color/voice que MÁS te gusta no necesariamente es el que más conecta con tu audiencia, el que más se reconoce o el que más convierte. Decisiones estratégicas de marca requieren datos: engagement rates, feedback de clientes, tests A/B si es posible. Los fundadores que insisten en "esto me gusta a mí" suelen terminar con marcas que no funcionan comercialmente.'),

    (v_lesson_id,
     'Al diseñar hoy, ¿qué es "pensar en lo que venga"?',
     ARRAY[
       'Diseñar solo para el presente',
       'Considerar si el sistema escala a nuevos productos, mercados o medios futuros — evita rebrands dolorosos más adelante',
       'Contratar un diseñador famoso',
       'Gastar más dinero hoy'
     ],
     1,
     0,
     'Pensar en escalabilidad: ¿funcionará si mañana lanzás un segundo producto? ¿Si el nombre se traduce al inglés? ¿Si imprimís en una t-shirt? ¿Si pasás de B2C a B2B? Un sistema flexible hoy te ahorra rehacer todo en 2 años cuando crezcas. Las marcas que escalan bien fueron diseñadas con estos escenarios en mente desde el día 1, aunque en ese momento parecieran lejanos.');

  RAISE NOTICE 'Módulo "Branding Pro": 4 lecciones + 12 quizzes insertados.';

END $$;
