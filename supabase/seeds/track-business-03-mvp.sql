-- =============================================
-- IALingoo — Track "Negocio con IA" / Módulo "Lanza tu MVP"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'business';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 2;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Lanza tu MVP no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1: Del post-it al MVP en 2 semanas
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Del post-it al MVP en 2 semanas',
$md$## El MVP real: mínimo, vendible, probable

MVP (Minimum Viable Product — producto mínimo viable) se malentiende muchísimo. Gente arma productos "mínimos" que son enormes en tiempo y pequeños en valor.

**Definición 2026 práctica**: lo MÁS chico que resuelve el dolor validado, lo podés construir en 1-2 semanas, y un cliente paga por usarlo.

No es:
- Una landing sin producto detrás (eso es "smoke test")
- Un prototipo para mostrar a inversores
- Todo el backlog ambicioso "recortado"

Es:
- Un producto funcional de principio a fin
- Un workflow simple pero completo
- Alguien pudiendo pagar y usarlo desde el día 1

### La pirámide de MVPs (de menos a más trabajo)

**Nivel 1 — Concierge MVP (manual con IA)**
Vos hacés todo a mano, ayudándote con IA. El cliente ve outputs finales.

Ejemplo: *"Generación de reportes semanales de competencia"*. Vos recibís input del cliente por email, corrés prompts en Claude/ChatGPT, armás el reporte, se lo mandás. 0 código.

Funciona para: 5-10 clientes máximo, precios $200-$2000/mes.

**Nivel 2 — Wizard of Oz MVP (parece automático, es manual atrás)**
Tenés UI simple (form web). El cliente llena, "aparece" output. En realidad vos procesás atrás con prompts y se lo enviás por email.

Ejemplo: form "genera brief de producto" → te llega notificación → corrés prompt → envías respuesta en 1 hora. Al cliente le parece mágico.

**Nivel 3 — No-code MVP**
Usás Lovable + Supabase + n8n + APIs IA. Funcional real end-to-end en 1-2 semanas.

Ejemplo: SaaS que el usuario se registra, ingresa datos, el agente procesa y devuelve output inmediato. Sin código custom.

**Nivel 4 — Low-code MVP**
Similar al anterior pero con lógica más compleja. Code en edge functions + UI Lovable/v0 + agente con framework.

Ejemplo: agente multi-step que interactúa con APIs externas, con auth multi-tenant.

**Nivel 5 — Custom MVP**
Framework (Next.js + Agent SDK), deploy propio, control total. Para productos que realmente necesitan diferenciación técnica.

**Regla 2026**: empezá en el nivel más bajo que tu cliente tolere. Solo subís cuando los límites se notan.

### El Service MVP: el más subestimado

Para muchos builders, el mejor MVP NO es un producto — es un **servicio con precio fijo** donde vos hacés la magia con IA por dentro.

Ejemplo concreto:
- Servicio: "Agente de atención WhatsApp para tu e-commerce — $990 setup + $299/mes"
- Lo que realmente hacés:
  1. Armás un flujo n8n custom (6 horas)
  2. Conectás a su WhatsApp (1 hora)
  3. Configurás prompts con su catálogo (2 horas)
  4. Monitoreás los primeros 30 días (1 hora/sem)

Total: 15-20 horas de trabajo tuyo, cobrás $990 + recurring. Cliente ni sabe/importa qué hay adentro.

Escalás sumando plantillas reutilizables y subagentes que automatizan tu workflow interno.

### Los 4 escenarios MVP más comunes 2026

**Escenario A — Chatbot/asistente vertical**

Cliente: un nicho específico (clínicas, inmobiliarias, coaches)
Stack: n8n + Claude/GPT + WhatsApp/web widget + Supabase (RAG)
Tiempo: 10-20hs para MVP
Precio: $99-$499/mes

**Escenario B — Generador de contenido a medida**

Cliente: marcas, agencias, creadores
Stack: Lovable + Claude + APIs de imagen/video (Midjourney, Kling, Runway)
Tiempo: 20-40hs
Precio: $49-$299/mes (o per-unit)

**Escenario C — Agente de análisis/reportes**

Cliente: equipos de ops, finanzas, CS
Stack: n8n + Claude + Google Sheets / Supabase + email digest
Tiempo: 15-25hs
Precio: $199-$999/mes

**Escenario D — Workflow automation interno**

Cliente: empresas medianas
Stack: n8n + integraciones varias + Claude + dashboards Lovable
Tiempo: 30-60hs
Precio: $2k-$15k setup + $500-$3k/mes

### Plan concreto de 14 días

**Semana 1 — Setup y construcción base**

Día 1-2: Kickoff con primer cliente (paga 50%)
- Workshop 2hs: entender su caso real
- Definí inputs, outputs, métricas de éxito
- Firma contrato/MSA + primer pago

Día 3-4: Setup técnico base
- Repo + dominio + Supabase + Vercel/Lovable
- Auth básico
- Estructura de DB

Día 5-7: Core del producto
- 1 flujo principal end-to-end
- Prompts v1 (no perfectos)
- Testing manual con datos reales del cliente

**Semana 2 — Refinamiento y entrega**

Día 8-10: Iteración con cliente
- Cliente prueba, da feedback
- Ajustás prompts, UX, outputs

Día 11-12: Polish
- Manejo de errores
- Logs básicos
- Documentación de uso

Día 13: Demo + handoff
- Sesión de training con cliente
- Checklist operativo
- Segundo pago del setup

Día 14: Go-live + monitoring
- Cliente empieza a usarlo en producción
- Revisás logs primeros días
- Entrevista de satisfacción en día 7

**Si al día 14 el cliente usa el producto y quiere seguir pagando → MVP validado.**

### Qué dejar afuera del MVP

Tentación de founder técnico: sumar features porque "son fáciles". Todas desvían.

**Dejar afuera en MVP:**
- Dashboard completo de analytics (un email semanal alcanza)
- Admin panel (Supabase Studio te da todo)
- Multi-idioma (empezá en uno)
- Mobile app (PWA o web mobile-responsive es suficiente)
- Integraciones adicionales que "estaría bueno"
- Onboarding flow elaborado (call 1-1 con cliente durante 3-4 meses)
- Self-serve signup (todos los clientes entran por venta asistida)
- Billing automático complejo (Stripe link mensual funciona)

Cada "estaría bueno" agregado = 3-10 días más. Multiplicá por 10 features y el MVP tarda 4 meses. Fracasaste.

### Reglas duras para el MVP

1. **1 cliente pagando antes de empezar** — si nadie pre-compra, no arranques
2. **1 caso de uso principal** — no tres
3. **1 integración por ahora** (WhatsApp O email, no ambas)
4. **Hardcodear todo lo que se puede** — empezás con config en JSON, no UI de admin
5. **Vos hacés el onboarding** — no armes self-serve hasta cliente 10+
6. **Nada de diseño custom** — templates de Lovable/Framer/shadcn
7. **Deploy primer día** — aunque sea "Hello World", que esté vivo en Vercel

### El test del post-launch

Pasadas 2 semanas de que el cliente use el MVP:

- ¿Lo usa >3 veces por semana? (si no, producto o integración falla)
- ¿Está pidiendo features nuevas? (señal de engagement alta)
- ¿Te refirió a alguien? (top señal de validación)
- ¿Pagaría el doble si sumás X? (upsell path claro)

Con esas respuestas, sabés si profundizás o pivotás (módulo anterior).
$md$,
    0, 50,
$md$**Plan de 14 días para TU MVP.**

1. Elegí el nivel de MVP más apropiado (Concierge, Wizard of Oz, No-code, Low-code o Custom)
2. Escribí el plan día-por-día:
   - Día 1-14 con entregable concreto por día
3. Lista de "NO VA EN EL MVP" con mínimo 10 features que te tienta sumar pero no sumás
4. Confirmá:
   - Cliente pagando (50% arranque, 50% entrega)
   - Stack definido
   - Primer prompt base escrito
5. Compartí el plan con alguien de confianza y pediles que te obliguen a no agregar features durante las 2 semanas$md$,
    25)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué NO es un MVP correcto?',
   '["Algo funcional que un cliente paga por usar", "Una landing sin producto detrás — eso es un smoke test, no un MVP", "Un producto mínimo pero completo", "Un service MVP donde vos hacés la magia por dentro"]'::jsonb,
   1, 0, 'MVP requiere producto real (manual, asistido o automatizado) que resuelva el dolor. Una landing sola es otro tipo de test.'),
  (v_lesson_id, '¿Cuál es el MVP más barato y rápido de arrancar?',
   '["Custom con framework propio", "Concierge MVP — vos hacés todo a mano ayudándote con IA, el cliente ve outputs finales", "App móvil nativa", "SaaS self-serve completo"]'::jsonb,
   1, 1, 'Concierge no requiere código. Útil para los primeros 5-10 clientes y para aprender antes de automatizar.'),
  (v_lesson_id, '¿Qué regla es clave al arrancar el MVP?',
   '["Construir todas las features del roadmap", "Tener 1 cliente pagando antes de empezar — si nadie pre-compra, no arranques", "Diseñar con figma durante 2 semanas", "Escalar desde el día 1"]'::jsonb,
   1, 2, 'Un cliente pagando por adelantado valida willingness-to-pay y te da foco. Sin eso, construís la solución equivocada.');

  -- L2: Cobrar
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Cobrar: links, suscripciones y flujo para que no te evadan',
$md$## Si no cobrás, no es negocio

Cobrar suena simple. No lo es. Te pueden decir "te paso cuando tenga tiempo" (traducción: nunca). Clientes dejan de pagar. Stripe se confunde con impuestos. Si no tenés proceso, perdés plata que ya te ganaste.

### Formas de cobrar 2026

**Links de pago (el más simple):**
- Stripe Payment Links — creás un link en 30 segundos, se lo pasás al cliente por WhatsApp
- MercadoPago / Culqi / Kushki — para Latam local
- PayPal.me — para cliente chico internacional

Ventaja: cliente paga en <2 min sin fricción. Funciona para un-off o primer pago de servicio.

**Suscripciones con Stripe Billing:**
- Creás producto → price mensual/anual → URL Checkout
- Cliente ingresa tarjeta, se auto-cobra cada mes
- Dashboards de MRR, churn, failed payments incluidos

Ventaja: recurrente automático. Standard para cualquier SaaS.

**Invoices profesionales:**
- Stripe Invoices — generás invoice con tu logo, cliente paga con link
- QuickBooks / Xero / Alegra — si necesitás contabilidad formal
- Facturama (México) / Factura.com / Afip (Argentina) — compliance local

Ventaja: empresas grandes exigen invoice formal. No podés venderles sin eso.

**Crypto (USDC):**
- Para clientes internacionales que quieren evitar wires
- Wallets: Coinbase, MetaMask, Phantom
- Plataformas que facilitan: Request Finance, Utopia
- Cuidado regulatorio en tu país

Ventaja: pago instantáneo, fees bajas, sin fricciones bancarias.

**Transferencia bancaria (B2B enterprise):**
- Wise, Mercury, Payoneer — recibir USD sin cuenta US
- Empresas grandes prefieren wire a tu empresa
- Net 30/60 days (te pagan 30-60 días después de la factura)

Ventaja: ticket grande. Desventaja: flujo de caja doloroso.

### Patrón de cobro recomendado para cada modelo

**Servicios ($500-$10k por proyecto):**
- 50% al iniciar (Stripe link)
- 50% al entregar (Stripe link)
- Contrato MSA con cláusula de pago claro

**Retainer / servicios recurrentes ($500-$5k/mes):**
- Stripe Billing mensual
- Cobro adelantado (empieza el mes, cobrás el 1ro)
- Grace period de 7 días máximo; después pausás servicio

**SaaS ($29-$299/mes):**
- Stripe Checkout self-serve
- Trial 7-14 días con tarjeta (NO sin tarjeta)
- Upgrade/downgrade en 1 click

**Enterprise ($5k+/mes):**
- Invoice + wire transfer
- Contrato anual upfront con descuento vs mensual
- Net 30 con penalty después

### Stripe setup práctico (30 min)

**Paso 1 — Crear cuenta**
- [stripe.com](https://stripe.com) → sign up
- Verificá identidad (KYC): DNI, empresa, cuenta bancaria destino
- Activación: 1-3 días hábiles

**Paso 2 — Configurar producto + precios**
Dashboard → Products → Add product:
```
Nombre: "Pro Plan"
Precio: $99 USD / mensual
Trial: 7 días
Billing: Recurring monthly
```

**Paso 3 — Integración mínima**
Opción A (no-code): usar Payment Link directamente
```
Dashboard → Payment Links → Create
Copias URL → la mandás por WhatsApp/email
```

Opción B (web): Stripe Checkout en tu landing
```javascript
// Next.js route handler
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export async function POST() {
  const session = await stripe.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: 'price_xxx', quantity: 1 }],
    success_url: 'https://tu-app.com/success',
    cancel_url: 'https://tu-app.com/pricing',
  });
  return Response.json({ url: session.url });
}
```

**Paso 4 — Webhook para sync con DB**
```javascript
// Recibís evento cuando cliente paga / cancela / falla
// Actualizás estado en Supabase
export async function POST(req) {
  const event = stripe.webhooks.constructEvent(
    await req.text(),
    req.headers.get('stripe-signature'),
    process.env.STRIPE_WEBHOOK_SECRET
  );

  if (event.type === 'checkout.session.completed') {
    const s = event.data.object;
    await supabase.from('subscriptions').insert({
      user_id: s.client_reference_id,
      stripe_customer_id: s.customer,
      status: 'active'
    });
  }
  return Response.json({ received: true });
}
```

### Merchants of Record (Paddle, Lemon Squeezy)

Si vendés SaaS/info-productos a público internacional y no querés lidiar con tax compliance por país, MoR cobra el IVA/sales tax por vos.

**Paddle**:
- Fee 5-10%
- Ideal para SaaS B2B/B2C
- Excelente para clientes US/EU

**Lemon Squeezy** (adquirido por Stripe en 2024, sigue operando):
- Fee ~5%
- Más simple UI, ideal para info-productos
- Licencias digitales, cursos, templates

**¿Cuándo usarlos?**
- Si vendés en >3 países con compliance complicado (USA state-by-state, EU VAT)
- Si no querés armar team legal/contable para tax global
- Si tus ingresos los justifican (5-10% de tu ARR)

### Dunning: recuperar pagos fallidos

En SaaS, el 10-30% de tarjetas fallan en algún momento (expira, insuficiente, banco bloquea). Si no recuperás esos pagos, perdés MRR sin necesidad.

Stripe Billing + Smart Retries + emails automáticos recupera 50-70% de pagos fallidos. Config en Dashboard:

- Retry 3-4 veces en 14 días
- Email al cliente con link a update card
- Pausa cuenta pasados 14 días
- Re-activa automático cuando paga

Tools adicionales (Baremetrics Recover, ChartMogul Dunning) mejoran 10-20% adicional.

### Cobrar en servicios sin drama

**Antes del proyecto:**
- Contrato firmado (PandaDoc o DocuSign)
- 50% upfront via link (no mandés ni una línea sin esto)
- Scope definido por escrito

**Durante:**
- Hitos con checks: *"Cuando termines X, cobras Y"*
- Si cliente pide scope extra: nuevo contrato, nuevo precio

**Después:**
- 50% restante via link al entregar
- Si cliente dilata pago: pausás trabajo, deshabilitás accesos si aplica
- Penalty: 5% por semana de atraso después de 15 días

### Red flags de clientes que no pagan

Alertas a observar:
- Negocia mucho el precio al inicio sin entender valor
- "Te pago cuando tenga el sistema funcionando"
- "¿Podés esperar unos días más?"
- No firma contrato ("confía, somos amigos")
- Paga primero pero arrastra el segundo pago

Respuestas sugeridas:
- "Mi política es 50% upfront. Te mando link de pago"
- "Entrego completo cuando recibo pago completo"
- "Si preferís esperar, cerremos cuando tengas el presupuesto listo"

Defender tu proceso de cobro = defender tu tiempo. Evitar estos clientes ahorra 10× más que conseguirlos.

### Impuestos básicos (no sos contador, pero sabelo)

Reglas mínimas:
- Tus ingresos son facturables en tu país de residencia fiscal
- Hacé factura/invoice por CADA ingreso
- Separá cuenta bancaria business
- Contratá contador local desde el día 1 ($50-200/mes, salva multas)
- Declarás ingresos aunque sean chicos (no vale la pena "ocultar")
- Si facturás >$30k USD anuales, probablemente necesitás estructura formal (LLC, SAS, etc. — ver módulo anterior)

Si vendés a USA/EU desde Latam:
- US: W-8BEN form para cada cliente (no retienen impuesto si sos no-resident)
- EU: VAT reverse charge B2B (si es empresa, no cobrás VAT; si es consumidor, sí)
- Paddle/Lemon Squeezy resuelven todo esto por vos
$md$,
    1, 60,
$md$**Setup completo de cobro en 2hs.**

1. **Stripe account**:
   - Crear cuenta + verificación KYC
   - Crear producto principal (tu MVP) con pricing
2. **Payment Link**:
   - Generar link para primer cliente
   - Probar flow end-to-end con tarjeta de prueba
3. **Invoice template** en tu herramienta contable (o Stripe Invoices)
4. **Proceso documentado** en Notion:
   - Cómo cobrás primer 50%
   - Cómo cobrás recurrente
   - Cómo manejás pagos fallidos
   - Red flags de clientes
5. **Legal mínimo**:
   - Template de contrato/MSA adaptado
   - Términos de servicio en tu web

Entregable: link de prueba funcionando + doc con proceso completo$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué es Dunning y por qué importa en SaaS?',
   '["Un tipo de contrato", "El proceso automático de reintentar pagos fallidos y notificar al cliente — recupera 50-70% de MRR que se perdería", "Una técnica de marketing", "Un modelo de pricing"]'::jsonb,
   1, 0, 'Dunning es crítico en recurrente. Tarjetas fallan constantemente; sin dunning perdés 10-30% de tu MRR sin motivo real.'),
  (v_lesson_id, '¿Qué hacer si un cliente dice "te pago cuando esté todo listo"?',
   '["Seguir trabajando porque te prometió", "Explicar tu política (50% upfront) y no arrancar hasta recibir el pago — defender el proceso de cobro es defender tu tiempo", "Bajar el precio", "Cobrar al final triplicado"]'::jsonb,
   1, 1, 'Clientes que dilatan el primer pago son red flag. Perdés tiempo y a menudo no cobrás. Mantené política firme.'),
  (v_lesson_id, '¿Cuándo conviene usar Paddle o Lemon Squeezy en vez de Stripe directo?',
   '["Nunca, son más caros", "Cuando vendés a clientes internacionales y no querés lidiar con IVA/sales tax por jurisdicción — actúan como Merchants of Record", "Para clientes locales", "Solo si usás crypto"]'::jsonb,
   1, 2, 'MoR resuelve compliance fiscal internacional por un fee de 5-10%. Mucho más barato que armar infraestructura legal propia.');

  -- L3: Primeros clientes
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Conseguir los primeros 10 clientes (de verdad)',
$md$## Los 10 primeros son los más difíciles

Del cliente 1 al 10, pasás por el valle oscuro del negocio: sin marca, sin casos, sin tracción, mucha explicación. Después del 10, todo cambia — tenés testimonios, referidos, proceso replicable.

Meta realista: **10 clientes pagos en 60-90 días** de lanzado el MVP.

### Mitos que te frenan

**Mito 1: "Necesito ads/marketing antes de vender"**
Falso. Los primeros 10 clientes casi siempre vienen de outreach directo + red, no de ads.

**Mito 2: "Tengo que esperar a tener audiencia"**
Falso. Construir audiencia toma 6-18 meses. Mientras tanto vendés con cold outreach.

**Mito 3: "Mi producto tiene que estar perfecto"**
Falso. El MVP del Día 14 alcanza. Los clientes beta saben qué están comprando: early access + atención personalizada a cambio de feedback.

**Mito 4: "No tengo experiencia, nadie va a comprar"**
Falso. Los primeros clientes compran POR TU OFERTA (resultado específico, garantía, precio), no por tu track record.

### Canales que funcionan de 0 a 10 clientes

Ordenados por efectividad real para builder solo 2026:

**1. Tu red directa (LinkedIn + WhatsApp + email personal)**
- Tasa de cierre: 10-20%
- Velocidad: clientes en 1-4 semanas
- Cantidad: 2-5 clientes de acá

Ejemplo:
- Hacés lista de 50 personas de tu nicho que ya conocés
- Mensaje honesto: *"Armé [solución específica] para [problema]. Estoy buscando 3-5 clientes beta con 50% off. ¿Te interesa que te muestre?"*
- 10 responden, 3 agendan call, 1-2 compran

**2. DMs / outreach frío directo**
- Tasa de cierre: 1-3% (de cada 100 DMs, 1-3 clientes)
- Canal principal: LinkedIn Sales Navigator
- Volumen: 30-50 DMs/día x 60 días = 2000+ touches

Plantilla inicial que convierte (probada):

```
Hola [Nombre], vi que sos [rol] en [empresa].
Estoy ayudando a [nicho] a [resultado específico]
en 2 semanas con [mecanismo breve].

Si te interesa ver cómo lo aplicaría a tu caso,
tengo 3 slots esta semana para sesiones de 20min.
Sin compromiso de compra.

[Tu nombre]
```

Keys:
- Saludo con nombre
- Contextual (por qué le escribís)
- Resultado específico, no "hago IA"
- Oferta concreta (call de 20min)
- CTA claro (agendar)
- Sin links ni PDFs en primer mensaje (LinkedIn los baja)

**3. Comunidades activas del nicho**
- Reddit específico del sector
- Grupos Facebook / WhatsApp / Discord
- Slack communities
- Indie Hackers para SaaS

Regla: aportá 3-4 semanas antes de mencionar tu producto. Después:
- Respondé consultas auténticamente
- Ocasionalmente mencioná tu tool cuando aplica
- Post ocasional de "learned while building" sin pitch fuerte

3-5 clientes pueden salir de acá si sos consistente.

**4. Referidos orgánicos (tu mejor canal a partir del cliente 5)**
Cada cliente feliz debería darte 1-2 referidos si los pedís bien.

Timing correcto:
- NO al día 1 ("recién arrancó")
- SÍ al mes 1 cuando ya vieron valor

Pregunta mágica:
> *"¿Conocés a 2-3 personas como vos — mismo tipo de negocio, mismo dolor — que podrían beneficiarse? Si hacés la intro te hago un [descuento / upgrade / bonus]."*

Incentivo: 10-20% descuento o 1 mes gratis. Cheap vs cost of customer acquisition.

**5. Content específico (long game)**
- LinkedIn posts 3x/semana sobre tu nicho
- YouTube videos quincenales
- Newsletter con insights

Resultados: 6-12 meses de consistencia. No esperes clientes los primeros 3 meses. Después, flujo inbound constante.

**6. Cold email**
- Volumen: 50-200/día
- Herramientas: Apollo, Lemlist, Instantly
- Tasa de cierre: 0.5-2%
- Cuidado: compliance (CAN-SPAM USA, LGPD Brasil, GDPR EU)

Sirve pero requiere mucho volumen y setup técnico (dominios paralelos, warm-up, templates A/B). No lo recomiendo antes del cliente 10.

**7. Ads (NO ahora)**
Paid ads solo cuando tenés:
- Oferta validada (>5 clientes comprando orgánico)
- Embudo probado (landing → call → cierre)
- Presupuesto para 2-3 meses de prueba

Antes de eso, ads queman plata. Después del cliente 10, tenemos módulo dedicado a ads rentables.

### El proceso de cold outreach disciplinado

**Semana 1 — Setup**
- Lista de 500 leads target (Sales Navigator + Apollo)
- Optimizar perfil LinkedIn (bio + banner + portfolio)
- Templates A/B de mensajes

**Semana 2-8 — Ejecución diaria**
- 30-50 DMs nuevos por día
- Follow-up a los que no respondieron (día 3, día 7, día 14)
- Agendar calls con los que responden
- 2-3 calls por día máximo

**Semana 2-8 — Calls**
- Estructura consultive, no pitch
- Diagnosticás dolor
- Proponés solución específica para su caso
- Cerrás con propuesta + link Stripe

**Semana 2-8 — Proceso post-call**
- Si cierra: onboarding inmediato (el momentum se muere en 48hs)
- Si duda: mandás caso similar + recordatorio con deadline
- Si no: agradecés, anotás objeciones, pasás al siguiente

**Rate mínimo esperado**:
- 100 DMs → 15 respuestas → 5 calls → 1 cliente
- 500 DMs/semana → 5 clientes/semana posibles

### Precios para los 10 primeros (beta)

Ofrecé **50% off vitalicio** o **3 meses gratis** a los primeros 10 a cambio de:
- Feedback honesto semanal
- Testimonio cuando vean resultados
- Caso de estudio en 2-3 meses
- 2 referidos

Todos ganan: ellos descuento real, vos tracción + social proof + referidos.

Después del cliente 10 subís precio para nuevos clientes 2-3×. Grandfathering para los early adopters (los mantenés al precio beta).

### Onboarding de los primeros clientes

Los primeros 10 son **high-touch**. No automatices. Hacé:

- Call 1-1 de kickoff (60-90 min)
- WhatsApp directo contigo por 30 días
- Revisión semanal de uso + ajustes
- Email recap mensual con métricas logradas

Parece ineficiente. No lo es: cada cliente feliz te da casos + testimonios + referidos que valen 10× el tiempo invertido. Después de cliente 10, empezás a automatizar.

### Señales de que vas bien

Primeros 30 días post-MVP:
- ≥50 DMs enviados ✅
- ≥5 calls agendadas ✅
- ≥1 cliente cerrado ✅

Primeros 90 días:
- ≥500 DMs enviados ✅
- ≥30 calls tenidas ✅
- ≥5-10 clientes cerrados ✅
- ≥1 testimonio público ✅
- ≥3 referidos recibidos ✅

Si a los 90 días no llegaste: el canal no funciona para tu oferta. Iterá oferta O cambiá canal (no ambos a la vez).

### La disciplina mata la idea

La mayoría fracasa acá. No por falta de talento — por falta de consistencia. 30 DMs/día por 60 días suena simple; menos del 5% lo sostiene.

Si sostenés 60 días: vas a tener 5-10 clientes.
Si no: tu MVP fue "proyecto", no negocio.

Pongan este texto en un post-it en tu monitor:

> *"100 DMs + 10 calls + 1 cliente = victoria. Hoy mandé [X]. ¿Cumplí mi cuota?"*
$md$,
    2, 70,
$md$**Plan de 60 días para tus primeros 10 clientes.**

1. Meta: 10 clientes pagos en 60 días
2. Canal prioritario: LinkedIn DM directo (ajustable si tu nicho no está ahí)
3. Cuota diaria:
   - 30 DMs nuevos (lunes a viernes)
   - Responder cualquier DM recibido <4hs
   - 2-3 calls de ventas por semana
4. Armado inicial (primer semana):
   - Lista de 500+ leads en Google Sheets
   - Perfil LinkedIn optimizado (bio vendedora, pero no spam)
   - 3 templates de mensajes A/B
   - Calendly/Cal.com con slots de 20min abiertos
5. Tracking semanal:
   - DMs enviados, respondidos, calls agendadas, cerrados
   - Tasa de cada paso
   - Objetiones más comunes
6. Iteración: cada 2 semanas, ajustá templates basado en data$md$,
    40
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es el canal más efectivo para los primeros 10 clientes?',
   '["Google Ads", "Red directa + cold outreach (LinkedIn DMs) — tasa de cierre mucho mayor que canales pagos antes de tener validación", "SEO desde el día 1", "TV y radio"]'::jsonb,
   1, 0, 'Outreach directo tiene mejor ratio que ads/SEO cuando todavía no tenés validación. Tu tiempo es más eficiente que tu plata al principio.'),
  (v_lesson_id, '¿Cuándo pedir referidos a un cliente nuevo?',
   '["Día 1 del servicio", "Al mes 1, cuando ya vio resultados — no antes, porque no tiene nada que referir", "Nunca", "Cuando el cliente cancela"]'::jsonb,
   1, 1, 'Referidos sin resultados tangibles suenan falsos. Esperá a que vean valor concreto antes de preguntar.'),
  (v_lesson_id, '¿Qué cuota diaria de outreach sostener por 60 días?',
   '["1 DM por semana", "30-50 DMs nuevos por día + follow-ups — consistencia es el factor #1 de diferenciación", "Solo cuando te acordás", "200 DMs al mes dividido en un día"]'::jsonb,
   1, 2, 'Volumen constante diario supera picos esporádicos. Ritmo continuo construye pipeline confiable.');

  -- L4: Próximos pasos
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Lo que viene después: escalar, sistematizar, o mantener',
$md$## Llegaste al cliente 10-20. ¿Y ahora qué?

Tres caminos posibles después del primer Milestone. Ninguno es "el correcto" — depende de tu objetivo de vida.

### Camino 1: Escalar (crecer rápido)

Vas por dinero serio, velocidad, posible exit.

**Qué hacés:**
- Contratás para delegar (VA, AE, dev)
- Invertís en ads y canales pagos
- Sumás producto / features / verticales
- Captás capital si tiene sentido (friends & family, angels, VC)
- Apuntás a $1M ARR en 12-24 meses

**Pros:**
- Crecimiento exponencial posible
- Valuación para exit eventual (3-10× ARR en 2026)
- Impacto grande

**Contras:**
- Más estrés, más empleados, más responsabilidades
- Vida personal comprimida
- Ya no sos builder — sos gerente / CEO
- Capital externo diluye control

**Señales de que este camino es para vos:**
- Querés construir algo grande, no lifestyle
- Tenés apetito por riesgo y complejidad
- Disfrutás manejar gente y procesos
- Tu mercado tiene TAM (Total Addressable Market) grande

### Camino 2: Sistematizar (lifestyle business)

Querés $10k-$50k USD/mes trabajando 20-30hs/semana.

**Qué hacés:**
- Sistematizás todo lo que hacés (SOPs, plantillas, automations)
- Contratás SELECTIVAMENTE (VA, dev part-time)
- No agrandás equipo más allá de lo necesario
- No buscás crecer por crecer — optimizás margen y tiempo libre
- Mantenés nicho específico, no expansión agresiva

**Pros:**
- Mucha libertad personal
- Ingresos sólidos ($150k-$500k USD/año)
- Sin jefes, sin inversores, sin gente
- Sostenible indefinidamente

**Contras:**
- Techo limitado (difícil pasar $1M USD/año)
- Dependencia grande de vos mismo
- Menos impacto que escalar
- Menos valuación de salida (si vendés, múltiplos bajos)

**Señales de que este camino es para vos:**
- Priorizás tiempo, familia, viajes sobre escalar
- No querés manejar gente
- Disfrutás hacer vos mismo
- Tu nicho es rentable pero chico (ej: vertical profesional específica)

### Camino 3: Mantener + diversificar

Tu negocio camina solo a nivel lifestyle, sumás otros revenue streams.

**Qué hacés:**
- Automatizás el negocio actual para minimizar tu tiempo
- Sumás info-productos / cursos / comunidad
- Invertís en otros negocios/proyectos
- Angel invertís en founders emergentes
- Creás contenido / branding personal

**Pros:**
- Anti-frágil (múltiples ingresos)
- Opcionalidad alta
- Aprendés constantemente

**Contras:**
- Nada es excelente (divides foco)
- Puede ser abrumador manejar 3-5 cosas
- Requiere disciplina alta

**Señales de que este camino es para vos:**
- Te aburrís de una sola cosa
- Tu negocio actual ya no necesita crecer
- Tenés capital para invertir
- Sos obsesivo con múltiples áreas

### Decisiones técnicas: cuándo sumar qué

Cliente 10-50:
- Documentá SOPs (Standard Operating Procedures)
- Contratá VA (Virtual Assistant) para tareas repetitivas
- Automatizá onboarding
- Sumá billing automático

Cliente 50-100:
- Contratá 1 AE (Account Executive) o CSM (Customer Success Manager)
- Empezás ads con presupuesto chico ($500-2000/mes)
- Sumás content/SEO para inbound
- Onboarding self-serve para los más chicos

Cliente 100-500:
- Equipo pequeño (3-7 personas)
- Data operations / analytics propio
- Sales team funcional
- Producto más robusto (enterprise readiness)

Cliente 500+:
- Estructura corporativa
- Departamentos funcionales (Sales, CS, Engineering, Ops)
- Exploración de nuevos mercados/productos
- Posible levantamiento de capital serio

### Habilidades a sumar en cada etapa

De solo a equipo chico:
- **Hiring**: aprender a contratar bien (contrata lento, despide rápido)
- **Delegar**: dejar de hacer vos mismo lo que otros pueden
- **Liderazgo**: inspirar + dar claridad + dar autonomía

De equipo chico a mediano:
- **Sistemas**: procesos que escalan sin vos
- **Gestión financiera**: cashflow, presupuestos, forecasting
- **Cultura**: cómo querés que sea trabajar ahí

De mediano a grande:
- **Estrategia**: dónde no jugar, foco disciplinado
- **Ecosistema**: partners, M&A, posicionamiento
- **Board management**: si tenés inversores

### Burn out real (y cómo evitarlo)

80% de founders IA 2026 reportan ansiedad/fatiga crónica. Razones:
- Hype constante (te sentís atrasado siempre)
- Modelos y herramientas cambian cada mes
- Competencia "ruidosa" en redes
- Trabajo 24/7 sin rituales de desconexión

Prevención (probada):
- **Horario fijo** — trabajo 9-18, no los weekends
- **Deep work sin notificaciones** — bloques de 2-3hs de concentración
- **Ejercicio diario** — no opcional, es infra mental
- **Sueño 7-8hs** — sin excepción (tu output decae 40% después de 1 semana mal durmiendo)
- **1-2 sesiones por mes con coach/mentor** — tener alguien afuera que te desafíe
- **Salir de redes 1 día/semana** — evitás el FOMO constante
- **Amigos no-IA** — no hablar de IA 24/7

### La mentalidad que escala más allá del MVP

Los que construyen negocios IA sólidos comparten 5 patrones:

1. **Obsesivos con el cliente real**, no con la tecnología
2. **Consistentes 6+ meses**, no "sprints heroicos"
3. **Pocas ideas ejecutadas bien**, no 20 ideas sin terminar
4. **Aprenden haciendo**, no consumiendo infinito contenido
5. **Comunidad > audiencia** — relaciones reales importan más que followers

### El viaje largo

El cliente 1-10 es el más duro. Del 10-50 es el más educativo (aprendés sistemas). Del 50+ es donde se define qué tipo de fundador querés ser.

Cualquier camino es legítimo. Lo que NO es legítimo es imitar lo que viste en Twitter sin pensar qué querés vos.

Tu IA, tu negocio, tu vida — tu decisión.
$md$,
    3, 70,
$md$**Elegí tu camino a 12 meses.**

1. Respondé honesto:
   - ¿Qué número de ingreso te cambia la vida? ($10k/mes? $50k? $500k?)
   - ¿Querés manejar gente o trabajar solo?
   - ¿Cuánto tiempo querés en tu negocio (20hs/sem? 60hs?)
   - ¿Apuntás a exit eventual o sustain indefinido?
2. Elegí camino:
   - Escalar
   - Sistematizar (lifestyle)
   - Mantener + diversificar
3. Escribí tu "Plan 12 meses":
   - Meta de ingresos end-of-year
   - Meta de clientes end-of-year
   - Número de empleados (si aplica)
   - 3-5 grandes hitos trimestrales
4. Lista de skills a sumar en los próximos 6 meses
5. Pacto anti-burnout: 3 reglas innegociables para no reventarte

Al final: vas a tener claridad sobre qué negocio estás construyendo, no solo cómo.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Qué camino es típicamente mejor si priorizás tiempo libre y no querés manejar gente?',
   '["Escalar agresivo con VC", "Sistematizar (lifestyle business) — $150k-$500k/año con equipo mínimo y mucha libertad", "Mantener a 1 cliente solo", "Cerrar el negocio"]'::jsonb,
   1, 0, 'Lifestyle business es un camino totalmente legítimo. Muchos builders ganan más y viven mejor con este modelo que escalando agresivo.'),
  (v_lesson_id, '¿Por qué el 80% de founders IA 2026 reporta burn out?',
   '["Por exceso de vacaciones", "Hype constante, modelos que cambian rápido, competencia ruidosa en redes, trabajo 24/7 sin rituales de desconexión", "Porque no leen suficiente", "Porque no usan ChatGPT"]'::jsonb,
   1, 1, 'La industria IA cambia cada mes + redes amplifican FOMO + pocos rituales de descanso = receta perfecta para fatiga crónica.'),
  (v_lesson_id, '¿Cuándo sumar primer empleado (VA o AE)?',
   '["Antes de tener clientes, para verse profesional", "Después del cliente 10-50, cuando ya tenés procesos repetitivos que delegar y cashflow para sostener el costo", "Nunca, trabajar solo siempre", "Cuando el competidor lo hace"]'::jsonb,
   1, 2, 'Contratar antes de tener procesos = caos. Después del cliente 10-50 tenés repetición suficiente y revenue para sumar gente rentable.');

  RAISE NOTICE '✅ Módulo Lanza tu MVP cargado — 4 lecciones + 12 quizzes';
END $$;
