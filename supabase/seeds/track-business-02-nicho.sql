-- =============================================
-- IALingoo — Track "Negocio con IA" / Módulo "Encuentra tu nicho"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'business';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Encuentra tu nicho no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1: Cómo elegir nicho
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Cómo elegir un nicho que paga (y no te aburre)',
$md$## Un mal nicho mata todo lo demás

Podés tener mejor stack, mejor landing, mejor agente — si tu nicho no tiene dolor ni dinero, no vendés. Y al revés: con un nicho correcto, incluso una ejecución mediocre te deja comer.

### Los 3 ejes del nicho ganador

Un nicho rentable se sienta en la intersección:

```
           [Pagan]
              │
              │
              ●  ← acá vivís
              │
        ──────┼──────
              │
        [Dolor]   [Podés servir]
```

- **Dolor real y actual** (no hipotético)
- **Pagan por resolverlo** (tienen presupuesto o lo están perdiendo)
- **Podés servirles** (experiencia, contactos, idioma, geografía)

Si falla uno, el nicho no cierra.

### Patrones de nicho rentable en IA 2026

**Patrón 1 — "Dolor conocido × tecnología nueva"**
Problemas viejos que IA ahora resuelve 10× mejor.

Ejemplos:
- Atención de WhatsApp en e-commerce (antes: operador humano; ahora: agente 24/7)
- Generación de variaciones creativas para ads (antes: diseñador; ahora: prompt + Nano Banana)
- Scraping y análisis de competencia (antes: pasantes; ahora: agente autónomo)
- Transcripción + resumen de reuniones (antes: tomar notas; ahora: Otter/Fireflies + agente)

**Patrón 2 — "Profesional independiente sin tiempo"**
Un pro que factura bien pero pierde noches en tareas repetitivas.

Ejemplos:
- Abogado: revisión de contratos
- Contador: categorización de gastos y armado de informes
- Coach: respondiendo lo mismo a 20 alumnos
- Realtor: armando descripciones y contestando leads
- Médico: escribiendo informes

Pagan bien porque liberás su hora de $100-$500.

**Patrón 3 — "Industria pesada de data no aprovechada"**
Sectores con mucha información que nadie procesa.

Ejemplos:
- Bienes raíces: clasificar y matchear inventario
- Automotriz: análisis de reviews y post-venta
- Logística: rutas, anomalías, reportes
- Seguros: procesamiento de claims
- Retail: análisis de stock/rotación/ventas

**Patrón 4 — "SaaS existente que necesita su layer de IA"**
Empresas con producto pero sin tiempo de sumar IA.

Ejemplos:
- Sumarle chatbot RAG a un CMS existente
- Recomendaciones personalizadas en un marketplace
- Scoring de leads en un CRM
- Auto-tagging en una tool de knowledge management

Pagan setup + mensualidad. B2B premium.

### Cómo detectar si un nicho tiene dinero

Señales de presupuesto:
- **Gastan en tools**: si tu nicho paga Slack, HubSpot, Notion, Framer, Cal.com... paga por SaaS
- **Gastan en agencias**: si contratan agencias de diseño, marketing, dev — tienen plata
- **Tienen empleados**: cada empleado = posibilidad de reemplazar o potenciar
- **Facturan >$10k/mes**: pueden invertir $500-$2k/mes sin pensarlo

Señales de dolor con dinero:
- Buscan "cómo automatizar X" en Google / ChatGPT
- Pagan freelancers para tareas repetitivas
- Están perdiendo oportunidades por no atender rápido
- Regulaciones nuevas los obligan a cumplir algo

Señales de **nicho malo**:
- "No tenemos presupuesto" = no te ven valor
- Pagan todo por Fiverr/Upwork barato
- No pueden articular qué les duele
- Responden "estaría bueno eso" en vez de "te compro ya"

### La regla del X×V (experiencia × vinculación)

Fórmula para elegir entre varios nichos candidatos:

**Tu ventaja = Experiencia que tenés + Acceso a esa comunidad**

Ejemplos:
- Fuiste coach → coaches te responden más rápido, hablás su idioma
- Trabajaste en retail → sabés qué duele en retail real
- Tu padre es abogado → tenés puerta abierta en ese gremio
- Vivís en Medellín → ventaja para pymes Medellín que prefieren alguien local

Los mejores nichos casi siempre están **junto a vos** (tu carrera pasada, tu red, tu ciudad, tu hobby obsesivo).

### Micro-nichos ganan a macro-nichos

Evitá:
- "Ayudo a empresas a automatizar con IA"
- "Consultoría en IA para negocios"

Preferí:
- "Automatizo la atención de WhatsApp para marcas de skincare mexicanas con 1k-10k ventas/mes"
- "Implementación de agente legal para estudios argentinos de 3-10 abogados especializados en laboral"

Ventajas del micro-nicho:
- Mensajes de marketing mucho más claros
- Cerrás venta en 1-2 calls (hablás su idioma)
- Referidos orgánicos dentro del gremio
- Menos competencia ("nadie tan específico existe")

Cuando dominás el micro, expandís a adyacentes.

### Los 4 niveles de dolor (profundidad)

**N1 - Molestia**: "es un bajón"
→ No paga

**N2 - Problema**: "me genera problemas"
→ Paga poco, churn alto

**N3 - Dolor**: "me cuesta tiempo/plata real"
→ Paga bien, se queda

**N4 - Trauma**: "si no lo resuelvo, pierdo la empresa"
→ Paga lo que sea, cliente de oro

Tu oferta tiene que resolver N3 o N4. Si tu nicho solo reconoce N1-N2, cambiá.

### Lista 2026 de nichos infra-explotados en LATAM

Oportunidades concretas poco saturadas:

1. **Clínicas dentales** — atención de leads + reminders + review request con IA
2. **Academias de idiomas / deportes / música** — soporte a alumnos + marketing local
3. **Asesores de seguros** — calificación de leads + cotizador automático
4. **Inmobiliarias no-top** — matching comprador/oferta + follow-up
5. **Contadores independientes** — clasificación automática de comprobantes + reportes
6. **Tiendas de nicho** (pesca, vinos, cosplay, etc.) — recomendación + atención WhatsApp
7. **Colegios privados** — admisiones + soporte a padres
8. **Veterinarias** — reminders de vacunación + triage síntomas
9. **Estudios de tatuaje/barbería** — booking + follow-up clientes
10. **Consultorios psicología** — gestión de turnos + seguimiento emocional entre sesiones (con cuidado ético)

### Test rápido antes de comprometerte

Antes de meter 3 meses en un nicho, chequeá:

1. **¿Conozco a 5 personas de ese nicho que me abrirían DM hoy?**
2. **¿El nicho factura >$10k USD/mes promedio?**
3. **¿Pagan otros SaaS o servicios actualmente ($100+/mes)?**
4. **¿Puedo nombrar 3 dolores específicos que tienen sin googlear?**
5. **¿Me aburre el nicho?** (si sí, pasá al próximo — vas a estar 1-3 años ahí)

3/5 sí = viable. 5/5 = lanzate.
$md$,
    0, 50,
$md$**Lista corta de 3 nichos candidatos.**

1. Lista **10 nichos posibles** según:
   - Tu experiencia pasada
   - Personas en tu red
   - Industrias que te interesan
2. Para cada uno, respondé el test de los 5:
   - Accedo a 5 personas ya
   - Facturan >$10k/mes
   - Pagan SaaS/servicios
   - Sé 3 dolores específicos
   - No me aburre
3. Quedate con los **3 que más sí tengan**
4. Escribí 2 frases por nicho: *"Para [perfil específico] resuelvo [dolor específico]"*

Entregable: 3 opciones escritas que vas a validar en la siguiente lección.$md$,
    20)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuáles son los 3 ejes de un nicho rentable?',
   '["Grande, online y gratis", "Dolor real + dinero para pagarlo + que vos puedas servirles", "Moda, jóvenes y viral", "Global, escalable y digital"]'::jsonb,
   1, 0, 'Un nicho sin dolor, sin plata o donde no podés servir falla. Los tres ejes deben darse a la vez.'),
  (v_lesson_id, '¿Qué nivel de dolor hace que el cliente pague bien y se quede?',
   '["N1 molestia", "N3 dolor real (tiempo/plata perdidos) y N4 trauma existencial", "N0 ninguno", "Solo molestias estéticas"]'::jsonb,
   1, 1, 'Resolvés N3-N4 → negocio sano. Si solo resolvés molestias (N1-N2), cobrás poco y hay mucho churn.'),
  (v_lesson_id, '¿Por qué micro-nichos ganan a macro-nichos?',
   '["Porque son más chicos y aburridos", "Mensajes más claros, cierre más rápido, referidos orgánicos, menos competencia específica", "Porque son más baratos", "No es cierto, macro siempre gana"]'::jsonb,
   1, 2, 'Especificidad vende. Preferí "clínicas dentales de Medellín con 3+ doctores" antes que "empresas de salud".');

  -- L2: Validar rápido
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Validación rápida: 30 conversaciones, cero código',
$md$## El error #1 de founders técnicos: construir antes de hablar

"Voy a armar una demo primero y después muestro". NO.

Construir antes de validar = 3 meses de trabajo tirado si el dolor no era real.

**Regla 2026**: hasta que no hables con 30 personas del nicho, NO construís nada. Código cero.

### El framework "Mom Test" actualizado para IA

Rob Fitzpatrick enseñó esto hace 10 años; aplica idéntico.

**Malas preguntas (te mienten):**
- "¿Usarías un producto que...?"
- "¿Cuánto pagarías por X?"
- "¿Te parece buena idea?"

Respuestas: "sí claro", "suena útil", "yo lo compraría". Todas mentira cortés. Nadie te va a decir "tu idea es floja" en la cara.

**Buenas preguntas (te dicen la verdad sin querer):**
- "¿Cuál es la última vez que esto pasó?"
- "Contame qué hiciste cuando eso te pasó"
- "¿Cuánto te costó eso?" (en tiempo, plata, oportunidad perdida)
- "¿Qué otras cosas probaste?"
- "¿Por qué no funcionó?"

Preguntás por el **pasado real**, no por el **futuro hipotético**.

### Estructura de call de validación (20-30 min)

**Minuto 0-3 — Rompehielo + context**
"Gracias por tu tiempo. Estoy investigando cómo [tipo de profesional como vos] maneja [área específica]. No te voy a vender nada — solo aprender."

**Minuto 3-10 — Explorar workflow actual**
- "Contame qué hacés un día típico en esa área"
- "¿Qué parte te chupa más tiempo?"
- "¿La última vez que eso fue un problema, qué pasó?"

**Minuto 10-20 — Profundizar el dolor**
- "¿Cuánto tiempo te lleva eso por semana?"
- "¿Qué intentaste para resolverlo?"
- "¿Cuánto te cuesta eso en plata o en oportunidades?"

**Minuto 20-25 — Test suave de solución**
- "Si existiera algo que hiciera [solución] ¿te ayudaría? ¿Cómo?"
- "¿Pagarías por algo así?" (NO — mala pregunta. Mejor: *"¿Qué te haría dudar de probarlo?"*)
- Mostrá posible solución (mock, descripción) y observá reacción

**Minuto 25-30 — Cierre + siguiente paso**
- "¿Cómo resolverían algunos de tus colegas este problema?" (te abre pipeline)
- "Cuando tenga algo para mostrar ¿te puedo avisar?" (asks para cuando tengas MVP)
- "¿Conocés a 1-2 personas más que deba hablar?" (referidos warm)

### Cómo conseguir esas 30 calls

**Canal 1 — Tu red primero**
- DM directo a LinkedIn/WhatsApp a gente que ya conocés del nicho
- Post pidiendo: *"Estoy investigando [tema] — ¿alguien en [nicho] me da 20min?"*
- Rate esperado: 30-50% responde

**Canal 2 — Grupos y comunidades**
- Grupos de Facebook / WhatsApp / Discord del nicho
- Subreddits específicos
- Regla: aportá valor 2 semanas antes de pedir cualquier cosa
- NO hagas spam; pedí 1-1 con DMs personales

**Canal 3 — LinkedIn outreach masivo**
- Buscá por cargo + industria
- Mandá 20-50 DMs por día con mensaje corto y genuino
- Rate esperado: 5-15% responde

**Canal 4 — Eventos / meetups**
- 1 evento del nicho vale por 20 DMs
- "¿Te jode si agendamos 20min la próxima semana?"

**Plantilla DM LinkedIn (copiá):**
> Hola [Nombre], vi que trabajás en [empresa/nicho]. Estoy investigando cómo los [cargo] manejan [área específica] en 2026. Nada de pitch — busco entender mejor el día a día. ¿Te jode darme 20 min la próxima semana? Yo me adapto a tu agenda.

No vendas en el primer mensaje. No digas "IA" ni "agente" ni "SaaS" — atrae vendedores, espanta a verdaderos prospectos.

### Qué anotar de cada call

Doc por conversación con:
- Fecha + nombre + rol + empresa
- **Dolores mencionados textuales** (copiá sus frases, no parafraseo)
- Herramientas que ya usan (tu competencia)
- Qué intentaron y por qué falló
- Nivel de urgencia/emoción al contarlo (1-5)
- Si aceptó que le muestres algo cuando esté listo (SI/NO)

Al final de las 30 calls, armá una tabla comparativa. Patrones van a saltar solos.

### Señales de validación positiva

Tu nicho está validado si:
- **3+ personas mencionan el mismo dolor con palabras casi iguales**
- **La mayoría ya intentó algo** (no es dolor ignorable)
- **Te dan nombres de colegas con el mismo problema** (ecosistema)
- **Respondieron emocionalmente** al hablar del dolor (no frío)
- **Aceptaron que les muestres el MVP cuando esté**

Señales de que hay que cambiar:
- Tenés que insistir/guiar para que mencionen el problema
- Responden "podría ser útil" sin pasión
- Nadie te refiere
- Cambian de tema rápido cuando hablás de soluciones
- "Ya tenemos resuelto eso con [tool existente]"

### Validar pricing sin pricing

Nunca preguntes "¿cuánto pagarías?". Preguntá:

- "Si resuelvo esto en [plazo], con [garantía]... ¿cuánto te ahorraría por mes?"
- "¿Qué presupuesto se asigna en tu empresa para [área]?"
- "Pasaste de X a Y cuando contrataste [competidor/freelancer] — ¿cuánto te costó ese cambio?"

Ellos te van a revelar el rango. Tu precio suele ser 1/3 a 1/10 de lo que les "cuesta" hoy el dolor.

### Pre-venta: el siguiente paso

Si tu validación fue sólida, el próximo paso NO es construir. Es **pre-vender**:

- "Ahora estoy armándolo — si firmás hoy, 50% off primeros 3 meses"
- "Agarro 5 clientes beta que me van a guiar durante 8 semanas — plata va a founders"

Cada compromiso previo al build:
- Confirma que pagan (no solo que "les interesa")
- Financia el desarrollo
- Te da usuarios desde el día 1
- Revela objeciones reales

Si nadie pre-compra a 50% off, el nicho/oferta no es tan válida como pensaste. Mejor descubrirlo ahora que después de 3 meses de código.

### Cuánto dura la fase de validación

- Semana 1-2: armás lista de 50-100 leads, mandás DMs
- Semana 2-4: hacés 20-30 calls
- Semana 4: analizás patrones, decidís go/no-go
- Semana 5-6: pre-vendés a los top 5-10 candidatos

**Total: ~6 semanas**. Si sos disciplinado, menos. No saltes esta fase.
$md$,
    1, 60,
$md$**Hacé 10 calls de validación esta semana.**

1. De tus 3 nichos candidatos (lección anterior), elegí el más accesible
2. Armá lista de **30 leads** concretos (LinkedIn + red + grupos)
3. Mandá DM con la plantilla (ajustada a tu voz)
4. Agendá 10 calls de 20min esta semana
5. Durante cada call:
   - Usá preguntas "Mom Test" (pasado real, no futuro hipotético)
   - Anotá frases textuales
   - Conseguí al menos 1 referido por call
6. Al final, armá doc con:
   - Dolores más mencionados (top 3)
   - Nivel de urgencia promedio
   - Tools que ya usan
   - Decisión: ¿avanzo con este nicho o cambio?$md$,
    40
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es una buena pregunta de validación (Mom Test)?',
   '["¿Usarías mi producto?", "Contame la última vez que [problema] te pasó — ¿qué hiciste?", "¿Te parece buena idea?", "¿Cuánto pagarías por esto?"]'::jsonb,
   1, 0, 'Preguntás por el pasado real, no el futuro hipotético. Las respuestas al pasado son verificables; al futuro, suelen ser mentiras corteses.'),
  (v_lesson_id, '¿Cuál es una señal de validación SÓLIDA?',
   '["Todos te dicen que les parece buena idea", "3+ personas independientes mencionan el mismo dolor con palabras casi iguales y te derivan a otras con el mismo problema", "Todos reaccionan con entusiasmo", "Los competidores están felices"]'::jsonb,
   1, 1, 'Repetición espontánea del dolor (mismas palabras) + referidos = dolor real de la industria, no fantasía tuya.'),
  (v_lesson_id, '¿Qué hacés después de validar, antes de construir?',
   '["Construir el MVP completo de inmediato", "Pre-vender a los top candidatos — si nadie paga 50% off la validación era débil", "Hacer otras 30 calls", "Comenzar con ads"]'::jsonb,
   1, 2, 'Pre-venta confirma willingness to pay real. Si nadie compromete dinero por adelantado, el dolor no era tan caro como parecía.');

  -- L3: Pivotar
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Pivotar sin morir en el intento',
$md$## Pivotar ≠ fracasar

Un pivot es cambiar algo significativo del negocio cuando los datos te dicen que el rumbo actual no cierra. No es rendirse — es usar lo que aprendiste para apuntar mejor.

Casi todos los negocios exitosos pivotaron al menos una vez:
- Slack era un juego (Tiny Speck → Glitch → Slack)
- YouTube era sitio de citas
- Shopify era tienda de snowboard

En IA 2026 el ritmo es más rápido. Un pivot que antes tardaba 6 meses, ahora lo hacés en 6 semanas (los modelos y herramientas son más rápidos, no el mercado).

### Tipos de pivot

**1. Zoom-in pivot**
Un feature chiquito era lo valioso; lo convertís en todo el producto.

Ejemplo: armaste suite completa para agencias; resulta que solo usan el módulo "generador de briefs". Pivot: vendés solo eso, más barato, a más agencias.

**2. Zoom-out pivot**
Lo que creías que era todo el producto, resulta ser solo una feature de algo mayor.

Ejemplo: vendías "asistente de ventas por WhatsApp"; resulta que necesitan también seguimiento en CRM, reportes, campañas. Pivot: te convertís en plataforma omnicanal con IA.

**3. Customer segment pivot**
Mismo producto, otro tipo de cliente.

Ejemplo: apuntabas a solopreneurs ($29/mes); resulta que no pagan pero PyMEs de 10-50 empleados sí ($299/mes).

**4. Customer need pivot**
Mismo cliente, otro problema que sí paga.

Ejemplo: clínicas dentales no pagan por "atención WhatsApp" (no les duele lo suficiente) pero SÍ pagan por "recuperación de pacientes inactivos" (revenue directo).

**5. Business model pivot**
Cambiás cómo cobrás.

Ejemplo: freemium → paid-only. One-time → suscripción. Per-seat → per-usage.

**6. Technology pivot**
Misma promesa, mejor tecnología.

Ejemplo: empezaste con GPT-3.5; migrás a Claude Sonnet 4.6 + RAG + agente. Mejor calidad, pero ahora tu economic unit cambia.

**7. Channel pivot**
Mismo producto, otro canal de distribución.

Ejemplo: vendías direct-to-consumer por ads Meta; pasás a B2B via partnerships con agencias.

### Señales de que toca pivotar

**Señales fuertes (pivot ya):**
- 3+ meses sin clientes pagos a pesar de marketing
- Churn >20% mensual (clientes se van rápido)
- Sales cycle >6 meses (demasiado esfuerzo por venta)
- Necesitás educar demasiado al cliente sobre el problema

**Señales medianas (ajustá, no pivotes aún):**
- Cerrás ventas pero margen es muy bajo
- Un tipo de cliente paga; otros no
- Unit economics no cierran pero la demanda está
- Producto funciona pero canal de adquisición no

**Señales débiles (solo ejecutá mejor):**
- "Sentís" que no avanza pero los números son ok
- Compararte con otros
- Cansancio personal

No pivotes por cansancio. Pivotá por datos.

### Cómo pivotar sin matar todo

**Paso 1 — Post-mortem objetivo**
Armá doc con:
- Hipótesis originales
- Qué asumiste que NO se cumplió
- Qué aprendiste inesperadamente (a veces lo más valioso)
- Lista de opciones alternativas

**Paso 2 — Validá el pivot ANTES de re-construir**
Exactamente la misma mecánica de la lección anterior:
- 10-15 calls con nuevos candidatos (o mismos clientes con nueva oferta)
- Medí: ¿dolor repetido? ¿pagarían? ¿mejor que lo anterior?

**Paso 3 — Reutilizá todo lo que puedas**
- Prompts ya perfectos
- Infraestructura (DB, auth, hosting)
- Contenido / landing / domain
- Relaciones con clientes actuales

Un pivot NO implica empezar de cero. Usualmente reusás 60-80% del trabajo.

**Paso 4 — Comunicá a clientes actuales**
Si tenés clientes en el modelo viejo:
- Ser honesto: "Estamos evolucionando hacia X"
- Ofrecer grandfathering (precio o acceso mantenido)
- Darles 60-90 días para decidir si siguen o salen

Abandonar clientes sin aviso destroza reputación. En nichos chicos, todos se conocen.

**Paso 5 — Dale mínimo 3 meses al nuevo rumbo**
Pivotar cada mes es no pivotar, es girar en círculos. Una vez que decidís, comprometete 3 meses antes de re-evaluar.

### El doble riesgo del pivot en IA

Pivot en 2026 tiene un problema extra: la tecnología se mueve más rápido que el mercado.

Si tu pivot es "por tecnología nueva" (ej: *"Voy a rehacer todo con Claude 5.0 cuando salga"*), cuidado:
- Los modelos cambian cada 3-6 meses
- Si solo pivotás por tech, vas a pivotar infinitas veces
- La tecnología es commodity rápidamente; el moat está en el dominio y la distribución

**Regla 2026**: pivotá por **cliente o problema**, no por **tecnología**. La tecnología sola no es moat.

### Caso estudio: pivots comunes en el mercado IA 2026

**Caso A — "Agente genérico" → "Agente vertical"**
Muchos armaron "asistentes con IA" genéricos. No vendieron. Pivotaron a verticales: asistente legal, asistente médico, asistente inmobiliario. Con la misma tecnología, 10× más venta.

**Caso B — "SaaS IA" → "Servicios + SaaS"**
Varios armaron SaaS de IA (self-serve). Clientes no lo usaban (no sabían configurarlo). Pivotaron a modelo híbrido: servicio de implementación ($3k setup) + licencia mensual ($199/mes). Onboarding asistido resolvió adopción.

**Caso C — "Plataforma" → "Feature de plataforma existente"**
Algunos armaron plataformas completas. Descubrieron que Notion, Slack, Salesforce eran mejores distribuidores. Pivotaron a plugin/integration: crecimiento 5-10× usando el canal ajeno.

**Caso D — "B2C" → "B2B"**
Muchos apps de IA para consumidor compiten con ChatGPT directo (imposible ganar). Pivot: vender al departamento de RRHH, marketing, ventas de empresas. Precios 10-100× más altos.

### Cuándo NO pivotar

- Tenés 1-2 clientes pagando → ajustá ejecución, no pivotes
- Competidor lanzó algo igual → diferenciá, no pivotes
- No conseguís pricing → probá pricing diferente primero
- Tu marketing es flojo → arreglá marketing primero
- Tenés fatiga personal → descansá una semana antes de decidir

El 80% de los que "necesitan pivotar" realmente necesitan **ejecutar mejor lo que tienen**.

### Heurística final: la regla de 10-15

Si en 3 meses lograste:
- <10 calls de ventas → problema de canal, no de producto
- 10-20 calls sin cierre → problema de oferta o precio
- 20-50 calls con cierre lento → ajustá embudo
- **>50 calls y <3 clientes pagos → momento real de pivotar**

Con data real es fácil decidir. Sin data, no pivotes — ejecutá más.
$md$,
    2, 70,
$md$**Diagnóstico de pivot (si estás frustrado con tu nicho actual).**

1. Completá un auto-diagnóstico honesto:
   - ¿Cuántas calls de ventas hiciste en los últimos 3 meses?
   - ¿Cuántos clientes pagos lograste?
   - ¿Cuál es tu churn?
   - ¿Qué señal de pivot aplica (1 a 7 de la lección)?
2. Si los números dicen "pivot":
   - Escribí qué mantenés (clientes, infra, aprendizajes)
   - Escribí qué cambiás (cliente, problema, canal, tech, modelo)
   - Armá la nueva oferta en 2 frases
   - Agendá 10 calls con el nuevo perfil en 1 semana
3. Si los números dicen "no pivot":
   - Identificá la cosa UNA que más te traba (canal, oferta, precio)
   - Planeá 30 días enfocados solo a esa palanca$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuándo es señal fuerte de pivotar?',
   '["Te sentís cansado un día", "3+ meses sin clientes pagos a pesar de marketing, churn >20% o sales cycle >6 meses", "Te gusta más otra idea", "Un competidor hizo algo parecido"]'::jsonb,
   1, 0, 'Pivot se decide por datos objetivos (tiempo sin tracción, churn, ciclo de venta), no por emociones o FOMO.'),
  (v_lesson_id, '¿Qué NO hacer al pivotar?',
   '["Validar el nuevo rumbo con 10-15 calls antes de construir", "Pivotar por tecnología nueva sin cambiar cliente ni problema (la tecnología es commodity en 2026)", "Reutilizar infra existente", "Comunicar a clientes actuales"]'::jsonb,
   1, 1, 'Pivotar por tecnología = girar en círculos. Los moats reales están en dominio + distribución, no en "usar el último modelo".'),
  (v_lesson_id, '¿Cuánto tiempo comprometerte al nuevo rumbo después de pivotar?',
   '["Una semana", "Mínimo 3 meses antes de re-evaluar — pivotar mensualmente es no pivotar, es girar sin avanzar", "Un año fijo", "Nada, pivotar cada semana"]'::jsonb,
   1, 2, 'Los negocios toman meses en mostrar tracción. Cambiar cada poco tiempo imposibilita leer señales reales.');

  -- L4: Construir moat
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  SELECT v_module_id, 'Construir defensibilidad: tu moat en un mundo de IA commoditizada',
$md$## El problema de 2026: todos pueden copiar en una tarde

La IA bajó a cero el costo de construir. Si tu producto es *"chatbot con IA"*, mañana tres competidores lo clonan con Lovable + n8n + Claude en 4 horas.

La pregunta real: **¿qué tenés vos que otros NO pueden copiar así de fácil?**

Eso es **moat** (foso, trinchera). Lo que te defiende del próximo competidor.

### Moats que NO son moats en 2026

Olvidate de estos como diferenciadores:

- **"Tecnología propietaria"** — los modelos base son commodity (Claude, GPT, Gemini)
- **"Mejor prompt engineering"** — dura 3 meses hasta que alguien lo replica
- **"Mejor UI"** — Lovable y Framer democratizaron diseño bonito
- **"Velocidad del first-mover"** — sin otros moats, se evapora

Estos te dan ventaja temporal (3-6 meses). Ningún negocio real se construye sobre eso.

### Moats reales 2026 (por importancia)

**1. Distribución propia**
Audiencia construida durante meses/años que te escucha y confía.

Ejemplos:
- Newsletter con 10k suscriptores del nicho
- Comunidad en Discord/WhatsApp con 500+ miembros activos
- Canal YouTube con 50k subs de profesionales
- Red de partners/referidos en el sector

Construcción: 6-24 meses, pero imposible de comprar o copiar rápidamente.

**2. Datos propietarios**
Data que solo vos tenés y hace el producto mejor con el tiempo.

Ejemplos:
- Base de X mil contratos anotados específicos del nicho
- Dataset de conversaciones reales del sector (anonimizado)
- Benchmarks curados de competencia
- Knowledge base construida con cada cliente

En IA: datos propios → fine-tuning propio → output único. Difícil de copiar.

**3. Marca y confianza**
Percepción del mercado de que sos EL referente del nicho.

Ejemplos:
- "Cuando pienso IA para veterinarias, pienso en X"
- Aparecés en podcasts/medios del nicho
- Líderes del sector usan y recomiendan tu producto

Construcción: 2-5 años. Nadie la compra con dinero — se gana con consistencia.

**4. Network effects**
Cada usuario nuevo hace el producto más valioso para los demás.

Ejemplos:
- Marketplace: más clientes atraen más proveedores
- Directorio/base de datos: más contribuyentes = más valor
- Plataforma de colaboración: más miembros = más útil

Difícil en IA-as-a-Service simple. Más común en productos sociales/marketplaces.

**5. Switching costs altos**
Una vez que te integran, salirse es caro.

Ejemplos:
- Tu agente está integrado con CRM, email, ERP, workflows del cliente
- Clientes entrenaron su equipo en tu tool
- Tus prompts/workflows customizados son IP del cliente

Tip: diseñá para profundizar con el cliente (más integraciones, más datos, más colaboración interna) = más switching cost.

**6. Economía de escala**
Tu costo por cliente baja con volumen; competidores chicos no pueden igualar precio.

Ejemplos:
- Negociaste tarifa preferencial con API providers por volumen
- Amortizás costos fijos (hosting, soporte) entre muchos clientes
- Scripts de automatización reducen tu costo operativo marginal casi a cero

**7. Especialización vertical profunda**
Conocés el dominio tan bien que nadie genérico puede competir.

Ejemplos:
- Agente para radiólogos que sabe de terminología médica + DICOM + protocolos HL7
- Tool para studios de animación que entiende After Effects + Premiere + renderización
- SaaS para bodegas de vino que habla el idioma de enología + distribución + DO

La especialización profunda es el moat más accesible para builders solos.

**8. Regulación / compliance**
Certificaciones/permisos que son caros o lentos de obtener.

Ejemplos:
- SOC 2 Type II ($50-150k y 6-12 meses)
- HIPAA para salud en USA
- Certificación bancaria para fintech
- ISO 27001

Competidores chicos no pueden acceder a clientes enterprise sin esto.

### La regla del 2×2: dónde pegás tu moat

Eje X: ¿qué tan rápido se copia tu producto? (1 hora a 2 años)
Eje Y: ¿qué tan único sos en servir al nicho? (intercambiable a único)

```
   Alto(único)
       │
       │  ●⭐ zona de oro
       │  (especialización + marca)
       │
       │  ●      ●
       │  (data) (distrib)
       │
   ────┼────────────────────── → Tiempo para copiar
       │
       │  ●  ← zona muerte
       │  (solo producto)
    Bajo
```

Tu negocio debe combinar **2-3 moats** distintos. Uno solo no alcanza.

### Moat "paquete" recomendado para solos en 2026

Combinación realista para un builder independiente:

1. **Especialización vertical profunda** (aprendés el nicho por dentro)
2. **Distribución propia** (creás audiencia en ese nicho durante 12+ meses)
3. **Switching costs medios** (profundizás integraciones con cada cliente)

Con esto, aunque alguien copie tu producto técnico, no te saca los clientes ni la audiencia.

### Cómo construir cada moat (práctico)

**Especialización:**
- Inmergir en el nicho: asistí a eventos, leé newsletters, seguí líderes
- Publicá contenido técnico del nicho (LinkedIn, blog, YouTube)
- Participá en grupos/slacks/discord del sector
- Meta: después de 6 meses, podés sostener una conversación técnica de 2hs con un pro del nicho

**Distribución propia:**
- Elegí UN canal (newsletter, YouTube, LinkedIn, Discord)
- Publicá 2-3 por semana consistente, 12 meses mínimo
- Metete en conversaciones del nicho (aportá, no vendas)
- Guest posts, podcast appearances, colaboraciones

**Datos propietarios:**
- Cada cliente contribuye data (anonimizada) que mejora el producto
- Hacés benchmarks públicos que nadie más tiene
- Sumás dataset curado por dominio

**Marca:**
- Tené una posición/opinión clara sobre el nicho
- Consistencia visual y verbal
- Casos de éxito y testimonios con números
- Presencia en medios del sector

### Preguntas para testear tu moat cada 6 meses

1. Si un competidor bien financiado copia mi producto, ¿en cuánto tiempo me alcanza?
2. ¿Qué tengo que NO se pueda comprar con dinero?
3. ¿Mi cliente cambiarse a un competidor sería fácil o difícil? ¿Por qué?
4. ¿En qué soy claramente mejor que Top 3 competidores? ¿Cómo lo probaría?
5. ¿Qué construí este trimestre que profundiza mi moat?

Si no tenés respuesta clara a estas preguntas, tu moat es débil. Invertí tiempo a construirlo aunque el producto ya funcione.

### Moats "anti-IA" que los grandes NO pueden copiar

Como solo/equipo chico, tenés moats que OpenAI, Google, Meta NO pueden replicar:

- **Atención personalizada** — CEO te contesta en 5 minutos
- **Customización extrema** — adaptás el producto por cliente sin escalar comité
- **Precio accesible** — sin overhead corporativo podés cobrar menos
- **Velocidad de iteración** — cambiás en 1 día lo que a Google le lleva 6 meses
- **Acceso directo al founder** — clientes valoran hablar con quien decide

Usá esto agresivamente. Es tu ventaja real vs gigantes.
$md$,
    3, 70,
$md$**Mapea tu moat actual y los 3 a construir.**

1. Hacé lista de los 8 tipos de moat (distribución, datos, marca, network effects, switching costs, escala, especialización, regulación)
2. Para cada uno, puntuate 0-10 honestamente
3. Identificá:
   - **Tus 2 moats actuales más fuertes** (dónde ya sos bueno)
   - **Los 3 moats que querés construir en los próximos 12 meses**
4. Por cada moat a construir:
   - Una acción mensual concreta
   - Cómo vas a medir progreso
5. Setup:
   - Trackear la métrica cada mes
   - Revisar en 3 meses y 6 meses si estás avanzando

Sin moat no sos negocio — sos proyecto que muere con el próximo modelo de Anthropic.$md$,
    30
  WHERE v_module_id IS NOT NULL
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
  (v_lesson_id, '¿Cuál es un moat real en 2026?',
   '["Usar el modelo de IA más nuevo", "Distribución propia (audiencia construida) + especialización vertical profunda + switching costs", "Prompt engineering mejor que el resto", "UI más bonita"]'::jsonb,
   1, 0, 'Tecnología se copia en horas; audiencias, dominio y integraciones profundas no. Esos son los moats que sobreviven a la commoditización.'),
  (v_lesson_id, '¿Qué ventaja tenés como builder solo vs gigantes IA?',
   '["Acceso a modelos propietarios", "Atención personalizada, velocidad de iteración, customización extrema, acceso directo al founder", "Más presupuesto", "Más datos"]'::jsonb,
   1, 1, 'Tu ventaja son las cosas que no escalan — personalización, velocidad y relación directa. Los gigantes NO pueden replicar eso.'),
  (v_lesson_id, '¿Qué NO es un moat sólido en 2026?',
   '["Audiencia propia", "Tecnología propietaria basada en usar mejor un modelo público (Claude/GPT) — se copia en meses", "Datos propios del nicho", "Especialización vertical profunda"]'::jsonb,
   1, 2, 'Los modelos base son commodity. Cualquier ventaja técnica construida sobre Claude/GPT desaparece cuando el competidor adopta la misma stack.');

  RAISE NOTICE '✅ Módulo Encuentra tu nicho cargado — 4 lecciones + 12 quizzes';
END $$;
