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
