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
     ARRAY['Diseño visual impresionante','Claridad del mensaje — el visitante entiende qué es y para quién en 5 segundos','Cantidad de secciones','Animaciones cinematográficas'], 1, 0,
     'Una landing fea con copy clarísimo convierte más que una bonita con copy confuso. La jerarquía de inversión debería ser: claridad > estructura > diseño. Muchos fundadores lo invierten y terminan con páginas preciosas que nadie entiende. Primero escribís copy que comunique en 5 segundos qué ofrecés y para quién; después diseñás alrededor de ese mensaje.'),
    (v_lesson_id, 'Tenés un producto nuevo sin usuarios todavía. ¿Cómo conseguís prueba social real (no inventada)?',
     ARRAY['Inventar testimonios','Mentir con números','Aceptar alpha/beta users gratis a cambio de feedback y testimonios — los primeros 10-20 usuarios pagan con feedback, no plata','Esperar a tener 1000 usuarios'], 2, 0,
     'Testimonios inventados se huelen a distancia. La estrategia probada para lanzar: ofrece acceso gratis o muy barato a 10-20 usuarios a cambio de feedback real y permiso para citarlos. Obtenés testimonios genuinos, product insights, y el boca a boca de esos primeros usuarios. Muchas empresas grandes arrancaron así.'),
    (v_lesson_id, '¿Cuántos CTAs principales debería tener tu hero?',
     ARRAY['Cuantos más mejor','Uno solo — múltiples CTAs confunden y diluyen conversión. Un CTA principal y opcionalmente un secundario sutil ("ver demo")','Ninguno, el usuario decide solo','Tres mínimo'], 1, 0,
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
     ARRAY['Es más barato','Construye full-stack (frontend + backend + BD + deploy) desde prompt conversacional en español — v0 es solo componentes frontend, Webflow es visual no-code sin IA generativa tan potente','No usa IA','Es igual'], 1, 0,
     'Cada una tiene su nicho. v0 genera componentes React hermosos pero solo frontend. Webflow es visual drag-and-drop premium (sin chat generativo tan potente como Lovable). Lovable te da el stack completo desde conversación: frontend + backend + BD + auth + deploy, todo prompteable en español. Por eso es la más elegida para "tengo una idea y quiero una app funcional mañana".'),
    (v_lesson_id, 'Acabás de generar tu landing y te gusta el diseño en desktop. ¿Qué debés hacer antes de publicarla?',
     ARRAY['Publicar de una','Testearla en mobile — abrir desde el celular y navegar completo. 70%+ del tráfico es mobile y es donde más cosas se rompen','Esperar a que alguien la revise','Nada, Lovable hace mobile perfecto'], 1, 0,
     'Lovable genera mobile-first razonablemente bien, pero nunca perfecto. Pequeñas cosas se rompen: botones cortados, textos superpuestos, scroll horizontal raro, imágenes enormes que cargan lento. Si tu primer visitante llega desde mobile y la experiencia es mala, se va. 2 minutos testando en el celular propio evitan pérdida de leads.'),
    (v_lesson_id, 'Iterás 50 veces con Lovable sin revisar integral. ¿Qué probablemente pasa?',
     ARRAY['Todo mejora automáticamente','Se acumulan contradicciones entre iteraciones (por ejemplo cambiaste color 3 veces, padding 5 veces) y el resultado final tiene inconsistencias','Lovable mejora solo','Nada malo'], 1, 0,
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
     ARRAY['Lovable, porque es full-stack','v0 — genera componentes React premium que copiás y pegás en tu Next.js existente. Lovable crearía un proyecto nuevo, no integra a uno existente fácilmente','Carrd','Webflow'], 1, 0,
     'v0 está pensado exactamente para este caso: dame código React + Tailwind para pegar en mi proyecto existente. Lovable es proyecto nuevo; integrarlo a uno existente es fricción. Carrd no hace apps. Webflow es visual pero no genera código React exportable para Next.js. v0 encaja perfecto.'),
    (v_lesson_id, 'Querés un portfolio personal con animaciones premium y estética editorial. ¿Qué elegís?',
     ARRAY['Lovable','Framer — es la herramienta líder en estética premium con animaciones y se usa mucho en portfolios, estudios creativos y marcas donde el diseño es diferenciador','Google Docs','Excel'], 1, 0,
     'Framer es el gold standard para sitios donde el diseño y las animaciones son el diferenciador. Portafolios, estudios creativos, marcas de moda y lujo. Tiene CMS integrado, animaciones on-scroll nativas, y aesthetic por defecto mucho más refinada. Lovable es potente pero el output estético default es más "buena app" que "sitio editorial premium".'),
    (v_lesson_id, 'Un power user en 2026 usa una sola herramienta o varias?',
     ARRAY['Solo Lovable','Combina según caso: Lovable para app completa + v0 para componentes específicos + Framer para marketing site + Claude Code para control total. Conocer fortalezas de cada una es lo que separa amateur de pro','Solo v0','Solo Framer'], 1, 0,
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
     ARRAY['Es más caro','Es simple de leer (1 pantalla te da todo lo importante) y privacy-first (no requiere cookie banner molesto) — GA4 es más potente pero curva alta y requiere consentimiento GDPR','No tiene ventajas','Es solo para apps grandes'], 1, 0,
     'Plausible fue construido pensando en "dame lo esencial en 1 vistazo". Visitas, páginas, fuentes, conversión, bounce. En 30 segundos entendés qué pasa. GA4 es más potente pero requiere entender audiences, events, conversions y varias vistas — curva empinada. Al inicio lo simple gana. Cuando escalés, podés migrar a GA4 si hace falta.'),
    (v_lesson_id, '¿Por qué importa el Open Graph tag og:image en tu landing?',
     ARRAY['No importa','Controla la imagen que aparece cuando alguien comparte tu link en WhatsApp, Twitter, LinkedIn — una buena imagen genera hasta 3x más clicks vs preview genérico','Solo para SEO','Para que Google te rankee'], 1, 0,
     'Cuando pegás un link en WhatsApp/Twitter/LinkedIn/Slack, aparece un preview con imagen + título + descripción. Sin og:image custom el preview es texto plano o una imagen genérica que no invita click. Una imagen bien diseñada (1200x630 ideal) sube el click-through rate significativamente. Es de las primeras optimizaciones ROI-positivas para cualquier landing.'),
    (v_lesson_id, 'Tenés <200 visitas al mes. ¿Deberías hacer A/B testing?',
     ARRAY['Sí, siempre testear','No — con <200 visitas los datos son no-concluyentes (significancia estadística requiere cientos o miles de muestras). Enfocate primero en traer tráfico, después iterar con A/B','A/B siempre por obligación','Solo si pagas por herramientas caras'], 1, 0,
     'A/B testing requiere volumen para ser significativo. Con 100 visitas dividas en 2 variantes tenés 50 por versión: un solo click de diferencia te cambia la conclusión. Resultado: decisiones basadas en ruido. La prioridad con tráfico bajo es TRAER TRÁFICO (social, comunidades, SEO, ads chicos). Cuando tengas >500-1000 visitas/mes, ahí sí A/B empieza a dar conclusiones fiables.');

  RAISE NOTICE 'Módulo "Landing en 10 min": 4 lecciones + 12 quizzes insertados.';
END $$;
