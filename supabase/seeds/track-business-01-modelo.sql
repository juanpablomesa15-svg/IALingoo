-- =============================================
-- IALingoo — Track "Negocio con IA" / Módulo "Modelo de negocio IA"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'business';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 0;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Modelo de negocio IA no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1: Productos vs servicios vs recurrentes
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Producto, servicio o recurrente: qué construir primero',
$md$## El dilema real del que empieza

Sabés usar IA bien. Podés generar contenido, armar agentes, automatizar procesos. ¿Cómo convertís eso en ingresos?

Tres formas básicas en 2026:

### 1. Servicios (agency, freelance)

Vos resolvés un problema del cliente usando IA. Le cobrás por proyecto o por hora.

**Ejemplos 2026:**
- Armás agentes personalizados para equipos (nicho: agentes de soporte, de ventas, de investigación)
- Automatizás procesos con n8n para pymes
- Generás contenido a escala (videos, blogs, redes) para marcas
- Implementás chatbots con RAG para sitios de e-commerce
- Consultoría: auditás cómo una empresa puede integrar IA

**Pros:**
- Empieza rápido — no necesitás producto, solo un primer cliente
- Ingresos inmediatos ($500-$10k por proyecto)
- Aprendés haciendo (cada cliente te enseña el dominio)

**Contras:**
- No escala sin contratar gente
- Dependés del tiempo que metés
- Vacaciones = sin ingresos

### 2. Producto digital (one-shot)

Vendés un producto terminado una vez. Curso, template, ebook, software con licencia única.

**Ejemplos 2026:**
- Curso grabado: "Cómo construir agentes con Claude Agent SDK" — $197
- Pack de prompts específicos: "100 prompts para abogados" — $47
- Templates de n8n listos: "20 workflows para agencias de marketing" — $97
- Plugin Figma o VS Code — $29
- Ebook + Notion template — $37

**Pros:**
- Una vez hecho, vendés infinitas copias
- Margen muy alto (digital = costo marginal casi cero)
- Trabajás sin cliente breathing down your neck

**Contras:**
- Requiere marketing constante para mantener ventas
- Primer venta puede tardar meses
- Un producto solo = ingresos inestables

### 3. Recurrente / SaaS / Suscripción

El cliente paga mensual por acceso a tu sistema.

**Ejemplos 2026:**
- SaaS de nicho: "Generador de scripts UGC para e-commerce" — $49/mes
- Herramienta interna como servicio: "Panel de análisis de llamadas con IA" — $199/mes
- Suscripción de contenido: "4 videos de IA generados para tu marca cada semana" — $299/mes
- Comunidad paga + updates: $29/mes
- Bot as a Service: "Bot de WhatsApp con IA para tu tienda" — $99/mes
- Agente as a Service: "Agente que te hace lead research 24/7" — $149/mes

**Pros:**
- Ingreso predecible (MRR — Monthly Recurring Revenue)
- Compounding: cada mes sumás clientes a los del mes anterior
- El más valorado para vender después (x3-x5 MRR anual)

**Contras:**
- El más difícil de arrancar
- Churn (clientes que se van) es el enemigo
- Necesitás soporte, updates, uptime

### Matriz de decisión según tu situación

| Situación | Recomendación |
|---|---|
| Necesito ingresos YA, tengo skills | Servicios (1-3 clientes, luego productizar) |
| Tengo audiencia o canal | Producto digital (curso, template) |
| Ya validé con 5-10 clientes de servicio un dolor claro | SaaS / recurrente |
| Quiero probar sin riesgo | Info-producto primero, luego subir |

### El patrón ganador 2026: escalera

Raramente alguien empieza con SaaS y triunfa. El patrón real:

```
Servicios ──▶ Productización ──▶ SaaS
 (aprender)    (empaquetar)      (escalar)
```

1. **Mes 1-6**: vendés servicio. Atiendes 5-10 clientes. Aprendés qué dolor es real, qué solución funciona, cuánto cobrar, qué frases venden.
2. **Mes 6-12**: productizás. "Ya no te armo el agente desde cero — te vendo esta plantilla + 2hs de setup por $1500." Misma solución, 1/3 del tiempo.
3. **Mes 12+**: convertís a SaaS. El proceso que ya hacés 20 veces, lo volvés software. El cliente entra, se auto-setea, paga mensual.

Empezar en el paso 3 sin haber hecho 1 y 2 = armar la solución equivocada para nadie específico.

### Pricing 101 (2026)

- **Servicios en LATAM**: $25-$150/hora según nicho. Por proyecto: $500-$15k.
- **Info-producto**: $27-$297 (el 90%). Cursos caros solo con autoridad.
- **SaaS individual**: $19-$99/mes. SaaS B2B: $99-$999/mes.
- **Premium B2B**: $1000-$10.000/mes para empresas medianas con ROI claro.

No cobres poco "para empezar" — atraés clientes difíciles. Cobrá lo que vale, trabajá con menos clientes y mejores.

### Revenue por caso real (2026)

- **Freelance solo**: $3k-$15k/mes es alcanzable con 2-5 clientes
- **Agency 2-3 personas**: $15k-$80k/mes
- **Info-producto + comunidad**: $5k-$50k/mes según audiencia
- **SaaS bootstrapped**: $0 los primeros 6-12 meses, luego crecimiento compuesto

La IA no te hace rico mágicamente. Te da apalancamiento: hacer en 1 día lo que antes era 1 semana. Eso multiplica por 5 lo que sea que estés haciendo — si estás haciendo lo correcto.
$md$,
    0, 50,
$md$**Elegí tu modelo inicial.**

1. Respondé honesto:
   - ¿Necesitás ingresos en los próximos 30 días? (sí/no)
   - ¿Tenés audiencia propia de 1k+? (sí/no)
   - ¿Ya hiciste 5+ proyectos pagos relacionados? (sí/no)
2. Según el resultado, elegí: servicio / producto / recurrente
3. Escribí en un doc:
   - Tu modelo elegido
   - Por qué (basado en tu situación real)
   - Precio tentativo del primer paquete
   - Meta a 30 días (ej: "3 clientes de servicio" / "10 copias del curso" / "5 suscriptores")
4. Comparte el doc con alguien que confíes y pedile que te challenge la lógica$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es el patrón típico recomendado para empezar en 2026?',
   '["Lanzar SaaS desde el día 1", "Servicios → Productización → SaaS (escalera gradual aprendiendo de clientes reales)", "Solo info-productos", "Invertir capital externo ASAP"]'::jsonb,
   1, 0, 'La escalera es servicios → productización → SaaS. Te da aprendizaje real antes de construir software costoso.'),
  (v_lesson_id, '¿Qué significa MRR?',
   '["Monthly Revenue Return", "Monthly Recurring Revenue — ingresos mensuales de suscripciones", "Maximum Rate of Return", "Market Ratio Revenue"]'::jsonb,
   1, 1, 'MRR es la métrica clave de negocios recurrentes. Predecible y valorizable (x3-x5 MRR anual en venta).'),
  (v_lesson_id, '¿Cuál es una desventaja real del modelo de servicios?',
   '["No genera ingresos", "No escala sin contratar gente y depende del tiempo que vos metas", "Es ilegal", "No sirve con IA"]'::jsonb,
   1, 2, 'Servicios = trabajás por horas/proyectos. Si parás, el ingreso para. Por eso conviene productizar eventualmente.');

  -- L2: Propuesta de valor
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Propuesta de valor: qué vendés y a quién',
$md$## La trampa del "agente con IA"

Si tu oferta es *"hago agentes con IA"*, estás vendiendo una **tecnología**, no un **resultado**. Nadie paga por tecnología — pagan por lo que la tecnología les da.

Comparemos:

| Oferta técnica (débil) | Oferta por resultado (fuerte) |
|---|---|
| "Hago chatbots con IA" | "Atiendo 100% tus consultas de WhatsApp 24/7 con ventas — pagás por conversación, no por setup" |
| "Automatizaciones con n8n" | "Reduzco tu tiempo de onboarding de clientes de 3 días a 20 minutos" |
| "Contenido con IA" | "4 videos virales UGC para tu marca cada semana — o no cobro" |
| "Consultoría en IA" | "En 8 semanas tu equipo usa IA para responder el triple de tickets con la misma gente" |

Nota la diferencia: **resultado, número, plazo, garantía**.

### Los 4 componentes de una propuesta de valor fuerte

Fórmula ([Alex Hormozi "Grand Slam Offer"], adaptada):

**Resultado del sueño** + **Probabilidad percibida de éxito** + **Tiempo** + **Esfuerzo / sacrificio**

- **Resultado del sueño**: no "tendrás un bot" — sino "respondés tickets sin perder noches"
- **Prob. de éxito**: casos, testimonios, garantía, demo en vivo
- **Tiempo**: cuánto tarda en funcionar (corto = gana)
- **Esfuerzo**: lo menos que el cliente tiene que hacer (low-touch = gana)

Cuanto más alto los dos primeros y más bajo los dos últimos, más paga el mercado.

### Ejemplo comparado

**Oferta A**: "Te ayudo a automatizar tus ventas con IA — $2000"

**Oferta B**: "Implemento en 14 días un sistema que le responde a cada lead de Instagram en <3 min, califica si compra o no, y agenda demo automática con tu equipo. Si en 30 días no te trae al menos 10 demos cualificadas, te devuelvo el 100% — $2000"

Misma tecnología, mismo precio. Oferta B vende 10× más porque **el riesgo es del vendedor, no del cliente**.

### Encontrá tu "nicho × dolor"

Pregunta clave: *¿Para qué tipo específico de persona resolvés qué problema específico?*

**Matriz de nichos rentables para IA en 2026:**

| Nicho | Dolor típico | Cuánto pagan |
|---|---|---|
| Coaches / consultores solos | No alcanzan para atender clientes y marketing | $500-$3k/mes |
| Agencias de marketing | Producir 100× contenido, reportes cliente | $1k-$10k/mes |
| E-commerce SMB | Atender WhatsApp, recuperar carritos | $300-$2k/mes |
| Estudios jurídicos | Revisar contratos, drafting | $2k-$15k/mes |
| Inmobiliarias | Calificar leads, armar anuncios | $500-$3k/mes |
| Educación / infoproductores | Soporte a alumnos 24/7 | $500-$2k/mes |
| SaaS B2B medianos | Onboarding automático, success | $5k-$30k/mes |
| Empresas 50-500 empleados | Automatizar procesos internos | $10k-$100k/proyecto |

### Regla del "dolor real"

Un dolor es real si:
1. **Te lo mencionan en los primeros 3 minutos** cuando preguntás "¿qué te complica hoy?"
2. **Tienen presupuesto asignado** o están perdiendo plata por no resolverlo
3. **Ya probaron otras soluciones** (te da pie a diferenciarte)

Si tenés que "educar" al mercado sobre por qué necesitan tu solución, el mercado no la necesita. Buscá otro nicho.

### El test de los 10 mensajes

Antes de armar nada, DMeále a 10 personas de tu nicho objetivo:

> *"Hola [Nombre], estoy investigando cómo los [nicho] manejan [área]. ¿Te molesta compartir 15min? Sin pitch, solo aprender."*

Si 0 de 10 responden → nicho equivocado o mensaje equivocado
Si 3+ responden y te cuentan el mismo dolor → acertaste

Después de esos 10 calls, vas a poder escribir la propuesta en 2 oraciones.

### Ingredientes de una landing de alta conversión (1 pantalla)

1. **Headline** con resultado específico + plazo
2. **Subheadline** con el "para quién" concreto
3. **3 bullets** de mecanismo ("cómo lo hago")
4. **Prueba social**: 1-3 casos con números o testimonios
5. **CTA** con "Agendá llamada de 15min" (no "contactame")

Tiempo total para leer: <20 segundos. Si no podés pitchearlo en 20s, no está listo.

### Evitá "features", vendé outcomes

Features = qué hace tu producto (*"usa Claude Sonnet 4.6 con RAG sobre Supabase"*)

Outcomes = qué consigue el cliente (*"tu equipo de soporte responde 3× más rápido con la misma gente"*)

**Regla**: cada frase en tu landing que describa *cómo* funciona algo, reemplazála por *qué resultado da*. Los features van en una sección "¿Cómo funciona?" al final, no en el headline.

### Precios y anclaje

Tres tiers en tu oferta ganan más que uno solo:

- **Starter**: $X — oferta mínima
- **Pro**: $3X — lo que querés vender (marcalo "más popular")
- **Premium**: $10X — ancla visual; algunos lo comprarán, la mayoría no

Ancla + escasez + garantía = pricing que convierte.
$md$,
    1, 60,
$md$**Escribí tu propuesta de valor en 2 versiones.**

1. **Versión débil** (como vendría natural): una frase que menciona IA/tecnología
2. **Versión fuerte**: con los 4 componentes
   - Resultado del sueño específico
   - Prueba/garantía (puede ser hipotética al principio)
   - Plazo concreto
   - Bajo esfuerzo para el cliente
3. Probá ambas con 3 personas (amigos, comunidad, LinkedIn):
   - "¿Cuál te haría preguntar más?"
   - "¿Qué confundes o dudás?"
4. Iterá hasta que 3/3 te digan "¡eso me interesa!" sin que tengas que explicar nada$md$,
    25
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Por qué "hago agentes con IA" es una oferta débil?',
   '["Por el precio", "Porque vende tecnología, no resultado — el cliente no paga por tecnología, paga por lo que esa tecnología le da", "Porque IA no funciona", "Porque es muy barata"]'::jsonb,
   1, 0, 'Vendé outcomes, no features. Nadie contrata por "usar Claude" — contratan para conseguir algo concreto (tiempo, leads, ingresos, uptime).'),
  (v_lesson_id, '¿Qué es el test de los 10 mensajes?',
   '["Un quiz técnico", "Mandar DM a 10 personas del nicho objetivo para validar el dolor antes de construir nada", "Un test automatizado", "Una encuesta anónima"]'::jsonb,
   1, 1, 'Validación rápida de nicho + dolor antes de invertir tiempo en construir. Si nadie responde o nadie menciona el dolor, estás equivocado.'),
  (v_lesson_id, '¿Qué 4 componentes describen una oferta fuerte (Hormozi)?',
   '["Logo, tipografía, color, música", "Resultado del sueño + probabilidad percibida de éxito + tiempo + esfuerzo (menor es mejor)", "Precio, costo, margen, impuesto", "SEO, SEM, email, redes"]'::jsonb,
   1, 2, 'El valor percibido sube cuando prometés resultado concreto, con alta credibilidad, rápido, y con poco esfuerzo del cliente.');

  -- L3: Economía unitaria
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Economía del negocio IA: costos, márgenes y rentabilidad',
$md$## El mito del "la IA cuesta casi nada"

Un prompt a Haiku cuesta $0.00001. Es verdad. Pero montar un negocio real con IA involucra costos que se acumulan rápido. Si no los conocés, perdés plata sin darte cuenta.

### Costos reales de un SaaS con IA (2026)

Ejemplo: un chatbot de WhatsApp con IA para e-commerce, vendido a $99/mes por cliente.

**Costos variables (por cliente/mes):**

| Ítem | Estimado | Nota |
|---|---|---|
| Tokens Claude/GPT (500 convos × 3k tokens c/u) | $2-8 | Depende del modelo — Haiku más barato |
| API de WhatsApp (Meta / Evolution hostinger) | $5-15 | Según volumen |
| Supabase (DB + auth + storage) | $0-3 | Free tier cubre clientes chicos |
| Hosting (Vercel) | $0-2 | Lo mismo |
| Embeddings (si hay RAG) | $0.50-2 | OpenAI / Voyage |
| Logs / observability (Langfuse, Helicone) | $1-3 | Opcional pero recomendable |
| **COGS total por cliente** | **~$8-33/mes** | |

Con precio $99/mes y COGS de $20/mes, tu **margen bruto** = $79/mes (80%).

**Costos fijos mensuales:**

| Ítem | Estimado |
|---|---|
| Dominio | $1 |
| Email profesional (Google Workspace) | $6-12 |
| Herramientas (Framer/Notion/etc.) | $20-80 |
| Contador + impuestos (LATAM) | $50-150 |
| Pagos (Stripe fees ~3% + fijos) | variable |

**Break-even**: con estos números, necesitás ~5 clientes para cubrir costos fijos y empezar a ganar.

### Pricing por coste marginal NO funciona

Mistake clásico: *"un prompt me cuesta $0.01, le cobro $0.05"*. Mal.

**Vendés en base a valor, no a coste**. Si tu sistema le ahorra al cliente $2000/mes en tiempo de personal, $99 es barato para el cliente independientemente de que a vos te cueste $20 producirlo.

Regla: **price / value ratio**. Si cobrás $99 por valor de $1000+, todos felices. Si cobrás $99 por valor de $100, churn alto.

### Modelos de pricing comunes en IA-as-a-Service 2026

**1. Suscripción plana**: $X/mes, uso ilimitado (para volúmenes predecibles)
- Pro: simple de vender
- Contra: te comés el costo de power users

**2. Tiered**: $29 (starter) / $99 (pro) / $299 (business)
- Pro: capturás diferentes segmentos
- Contra: diseñar tiers lleva tiempo

**3. Per-seat (equipos)**: $19/usuario/mes
- Pro: crece con el cliente
- Contra: clientes prefieren pagar por resultado, no por seats

**4. Per-use**: $0.05 por conversación / $2 por video generado
- Pro: pricing transparente, cero fricción de entrada
- Contra: ingresos volátiles

**5. Usage-based tier**: $49/mes incluye 500 conversaciones, luego $0.05 c/u
- Pro: base recurrente + upside con uso
- Contra: requiere metering preciso

**6. Revenue share / performance**: 10% de las ventas que tu bot genere
- Pro: cero fricción ("si no vendo, no cobran")
- Contra: difícil medir atribución, tracking complejo

En 2026 lo más común es **tiered flat + overage** (modelo 5). Base predecible con upside.

### Métricas clave que vas a tener que mirar

**CAC** (Customer Acquisition Cost): cuánto gastás para conseguir un cliente
- Sumá: ads + tu tiempo en sales + tools
- Fórmula: CAC = (gasto marketing mes) / (clientes nuevos mes)
- Target: CAC < 3× del primer mes de ingresos

**LTV** (Lifetime Value): cuánto te deja un cliente mientras dura
- Fórmula simple: LTV = ARPU × duración promedio
- Ej: $99/mes × 12 meses = $1188 LTV

**LTV:CAC ratio**: ideal >3, excelente >5
- Si es <1, perdés plata con cada cliente nuevo
- Si es >10, deberías invertir MÁS en adquisición (estás dejando crecimiento sobre la mesa)

**Churn mensual**: % clientes que se van
- <3% mensual es excelente, 5% aceptable, >10% está mal
- Churn alto = LTV bajo, aunque cobres bien

**MRR** (Monthly Recurring Revenue): suma de suscripciones activas
- La métrica north-star de SaaS

**Payback period**: cuántos meses tardás en recuperar el CAC
- Target: <6 meses para SaaS bootstrap

### ¿Cuándo subir precio?

Regla: subí precio cuando:
- Tenés listas de espera o dices "sí" a todo el mundo que viene
- Tu churn es <5% (gente contenta)
- Tu CAC se está inflando (ads más caros, canales saturados)

Típicamente podés subir 30-50% sin perder clientes. Los nuevos pagan más, los viejos quedan anclados a precio original (grandfather pricing).

### ¿Cuándo bajar precio? Casi nunca.

En IA bajar precio raramente ayuda. Si nadie compra:
- El problema es la propuesta de valor, no el precio
- O estás hablándole al público equivocado

**Excepción**: introducís un **tier más barato** (nunca bajar el actual) para captar un segmento que no puede pagar el main.

### Unit economics en servicios (no-SaaS)

Si vendés servicios tipo "implementación de agente" por $3000:

- Tiempo tuyo: 20-30hs → hora efectiva = $100-150
- Costos: APIs, herramientas, hosting primer mes = $50-100
- Margen neto: $2850-2950

Pero si el mismo agente lo vendés 10 veces siendo cada vez más eficiente (templates, scripts, subagentes que te ayudan):
- Proyecto 1: 30hs → $100/h efectiva
- Proyecto 5: 10hs → $300/h efectiva
- Proyecto 10: 5hs → $600/h efectiva

Ahí está el apalancamiento. Vendés el mismo resultado con cada vez menos tiempo. El "producto" está en tus templates, no en tu tiempo.
$md$,
    2, 70,
$md$**Armá el spreadsheet de tu unit economics.**

Google Sheet con columnas:
1. **Ingreso por cliente** (mensual o promedio por proyecto)
2. **COGS por cliente** (APIs, hosting, tools marginales)
3. **Margen bruto** = ingreso - COGS
4. **Costos fijos mensuales** (tus gastos fijos del negocio)
5. **Break-even** = costos fijos / margen bruto por cliente (= cuántos clientes necesitás)
6. **LTV estimado** (margen × meses promedio)
7. **CAC objetivo** = LTV / 3

Poné números reales para TU idea. Si break-even > 50 clientes, revisá: o subí precio, o bajá costos, o cambiá modelo.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es el ratio LTV:CAC saludable?',
   '["1:1", "Mayor a 3 (ideal 5+) — cada dólar de adquisición devuelve 3+ de valor de cliente", "0.5:1", "Cualquiera sirve"]'::jsonb,
   1, 0, 'LTV:CAC >3 indica negocio saludable. <1 perdés plata. >10 podés invertir más en adquisición.'),
  (v_lesson_id, '¿Cómo deberías pricearte según el contenido?',
   '["Basado en costo + margen fijo", "Basado en valor entregado al cliente (price/value ratio), no en coste marginal", "Siempre lo más bajo del mercado", "Al azar"]'::jsonb,
   1, 1, 'Pricing basado en valor. Si le generás $2000/mes, $99 es barato incluso si a vos te cuesta $10 producirlo.'),
  (v_lesson_id, '¿Qué significa COGS?',
   '["Costo del sitio web", "Cost of Goods Sold — costos variables directamente atribuibles a producir/entregar el servicio", "Costo Organizacional Global Sumado", "Un error contable"]'::jsonb,
   1, 2, 'COGS incluye APIs, hosting, tokens, integraciones — todo lo que escala con cada cliente nuevo.');

  -- L4: Hacerlo legal y sustentable
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Hacerlo legal y sustentable: estructura, cobros, riesgos IA',
$md$## Lo aburrido que te salva o te hunde

Tenés la idea, tenés clientes, facturás. Ahora viene la parte que nadie quiere mirar pero que define si el negocio vive o muere: estructura legal, cobros, impuestos y riesgos específicos de IA.

### Estructura legal inicial (LATAM 2026)

Las opciones más comunes:

**Monotributo / Autónomo local** (Arg, Uy, Chile, Col, etc.)
- Ideal para arrancar con ingresos <$3-8k/mes según país
- Tramite corto, bajo costo
- Limita qué podés facturar en ciertos países

**Sociedad local unipersonal** (SAS Colombia, SRL / SAU Arg, Ltda Uy)
- Separa tu patrimonio del negocio
- Facturás como empresa (clientes B2B prefieren)
- Costo de mantenimiento: contador + trámites

**Estructura US — Delaware LLC + Mercury / Wise**
- Si tenés clientes internacionales que pagan en USD
- LLC Delaware: $200-500 setup + $300/año mantenimiento
- Stripe Atlas te resuelve el setup completo por $500
- Cuenta Mercury (banco digital US) sin residir en US
- Ventaja: tax pass-through (la empresa no tributa, vos sí en tu país)
- Regla: consultá contador LOCAL antes de armar esta estructura

**Patrón ganador 2026 para LATAM con clientes globales:**
1. Empezás monotributo local
2. Cuando facturás $3-5k USD/mes de clientes internacionales → Delaware LLC + Mercury
3. Cuando pasás $50k USD/año → estructura holding o C-Corp según donde quieras vivir

### Cobrar: las formas que funcionan 2026

**Para clientes locales:**
- Transferencia bancaria (mercadopago, pse, khipu)
- MercadoPago link de pago
- Tarjeta local via Culqi / Kushki / DLocal

**Para clientes internacionales (USD/EUR):**
- **Stripe** — el estándar; acepta todas las tarjetas; fee ~3% + $0.30
- **Paddle** — Merchant of Record (MoR); cobra el IVA/sales tax por vos. Ideal para SaaS
- **Lemon Squeezy** — MoR más simple, bueno para info-productos
- **Wise / Mercury / Payoneer** — recibir transferencias; no tienen checkout

**Para recurrentes:**
- Stripe Billing (suscripciones) o Chargebee
- Link tipo "pay now" que los re-autocobra

**Regla 2026**: si vendés a USA/Europa y no querés hacer compliance tax por cada estado/país → usá **Paddle o Lemon Squeezy**. Te cobran 5-7% pero te evitan pesadilla fiscal.

### Contratos básicos

No trabajés sin contrato. En 2026 firmar es 2 clicks con:
- **PandaDoc / DocuSign** — firma electrónica
- **Cal.com + Stripe** — agendás + firmás + cobrás

Contratos mínimos que necesitás:

1. **MSA (Master Service Agreement)** — servicios
   - Alcance, plazos, precio, condiciones de pago, IP, confidencialidad
2. **SOW (Statement of Work)** — alcance específico por proyecto
3. **Terms of Service + Privacy Policy** — tu web
   - Generá base con Termly / Iubenda; revisá con abogado
4. **DPA (Data Processing Agreement)** — si procesás datos de clientes (casi siempre)
   - Requerido por GDPR, LGPD Brasil, México LFPDPPP

### Riesgos específicos de un negocio IA (lo nuevo)

**1. Alucinaciones que generan daño**
- Tu agente dice "sí, Juan debe $500" cuando en realidad debe $50
- Cliente del cliente accionó en base a eso

Mitigación:
- Disclaimers visibles: *"Outputs generados por IA. Verificá información crítica"*
- Guardrails técnicos: validación contra DB, human-in-the-loop en acciones sensibles
- Logs completos de toda interacción

**2. Filtraciones de datos**
- Prompt injection que exfiltra datos
- Dev envió data real a un API sin permisos

Mitigación:
- Nunca logs con PII crudo (enmascarar)
- API keys en .env / vault, no en git
- Supabase RLS + scoping estricto

**3. Derechos de autor / IP**
- Tu modelo usa contenido generado con AI; ¿quién es el dueño?
- En USA: outputs puros-IA NO tienen copyright; con edición humana significativa, sí
- Si usás imágenes generadas para un cliente y luego resulta que el modelo "copió" un estilo → disputa

Mitigación:
- Cláusula en contrato: "outputs generados con asistencia IA"
- Modelos con términos claros (Claude, GPT-4 permiten uso comercial)
- Cuidado con Midjourney en planes Basic (no exclusividad)

**4. Sesgos y discriminación**
- Tu agente de recruiting descarta más mujeres
- Tu credit scoring discrimina por CP

Mitigación:
- Testing con datasets diversos
- Monitoreo post-deploy
- En sectores regulados (banca, salud, HR), documentación obligatoria

**5. Regulación 2026**
- **EU AI Act** — clasifica riesgos; alto-riesgo (salud, RH, crédito) tiene obligaciones fuertes
- **USA**: regulación estado por estado (California SB 1047, Colorado AI Act, etc.)
- **LATAM**: varios países trabajando en leyes; Argentina tiene guía AGN, Brasil PL 2338
- **China**: regulación estricta para contenido generado (marcado obligatorio)

Para ti como builder: si tu producto toca áreas reguladas, contratá abogado IT. Si no, seguí guidelines voluntarias (ISO/IEC 42001) para no quedar fuera de juego.

### Seguros (cuando el negocio crece)

Cuando facturás >$100k USD/año con clientes importantes, considerá:
- **E&O (Errors & Omissions)** — profesional, cubre si tu IA hace daño accidental
- **Cyber insurance** — cubre breaches de datos
- **General liability**

Valor: $50-200/mes según coberturas. Algunas empresas clientes te lo van a pedir como requisito.

### Documentá todo: el "libro de operaciones"

Notion o Google Drive con:
- Prompts maestros usados
- Arquitectura técnica
- Políticas internas
- Onboarding checklist de nuevo cliente
- Plantilla de propuesta
- Plantilla de factura
- Scripts de llamada

Cuando crezcas, si tenés esto, contratás en 1 semana. Si no, tu negocio muere cuando vos te vas.

### La cabeza sustentable

Negocio IA 2026 es maratón, no sprint. 5 reglas:

1. **No te enamores de una idea** — validá rápido, pivotá sin ego
2. **No trabajés de noche permanentemente** — creatividad baja, decisiones peores
3. **Separá finanzas personales de negocio** — cuenta aparte desde día 1
4. **Invertí 10% en educación tuya** — estás en industria que cambia cada 3 meses
5. **Comunidad importa más que tu stack** — tus clientes y aliados vienen de networking, no de ads
$md$,
    3, 70,
$md$**Setup mínimo legal y operativo (sesión de 1 tarde).**

1. **Decidí estructura** según tu situación:
   - <$3k/mes: monotributo local
   - >$3k/mes con clientes internacionales: Delaware LLC (Stripe Atlas)
2. **Abrí cuenta bancaria separada** (ni siquiera comparta con la personal)
3. **Setup Stripe + un MoR** (Paddle o LemonSqueezy) si vas a vender internacional
4. **Plantillas**:
   - Propuesta MSA básica (generá con ChatGPT adaptando a tu país, revisá con abogado luego)
   - Terms of Service + Privacy Policy (Termly / Iubenda free tier)
5. **Checklist de compliance IA** para tus clientes:
   - Disclaimer de IA en outputs
   - DPA si procesás sus datos
   - Log mínimo para auditoría

Entregable: doc Notion con todos los links, credenciales y plantillas de "mi negocio IA".$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué ventaja clave da usar Paddle o Lemon Squeezy sobre Stripe directo?',
   '["Son más baratos", "Son Merchants of Record — se hacen cargo del tax compliance (IVA/sales tax) por vos en cada jurisdicción", "Soportan criptomonedas", "Tienen mejor UI"]'::jsonb,
   1, 0, 'Paddle/LemonSqueezy cobran ~5-7% pero te evitan calcular y pagar impuestos país por país — crítico si vendés global.'),
  (v_lesson_id, '¿Cuál es un riesgo específico de un negocio con IA?',
   '["No existe riesgo", "Alucinaciones que causan daño, filtraciones de datos por prompt injection, sesgos y cumplimiento regulatorio (EU AI Act, etc.)", "Solo ciberataques", "Bajar de peso"]'::jsonb,
   1, 1, 'Los riesgos de IA son nuevos y específicos: alucinaciones, sesgos, compliance. Requieren guardrails técnicos y legales.'),
  (v_lesson_id, '¿Cuándo conviene armar una Delaware LLC desde LATAM?',
   '["Siempre desde el día 1", "Cuando ya facturás $3-5k USD/mes de clientes internacionales y querés recibir USD con menos fricción", "Nunca", "Solo si vivís en USA"]'::jsonb,
   1, 2, 'Demasiado pronto = over-engineering. Demasiado tarde = perdés ingresos por fricción. El sweet spot es cuando tenés tracción internacional clara.');

  RAISE NOTICE '✅ Módulo Modelo de negocio IA cargado — 4 lecciones + 12 quizzes';
END $$;
