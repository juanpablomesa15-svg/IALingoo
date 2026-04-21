-- =============================================
-- IALingoo — Track "Builder Web" / Módulo "Hosting y dominio"
-- =============================================

DO $$
DECLARE
  v_track_id   INT;
  v_module_id  INT;
  v_lesson_id  INT;
BEGIN
  SELECT id INTO v_track_id  FROM tracks  WHERE slug = 'web';
  SELECT id INTO v_module_id FROM modules WHERE track_id = v_track_id AND order_index = 1;

  IF v_module_id IS NULL THEN RAISE EXCEPTION 'Módulo Hosting no encontrado.'; END IF;

  DELETE FROM quiz_attempts   WHERE quiz_id IN (SELECT id FROM quizzes WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id));
  DELETE FROM lesson_progress WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM quizzes         WHERE lesson_id IN (SELECT id FROM lessons WHERE module_id = v_module_id);
  DELETE FROM lessons         WHERE module_id = v_module_id;

  -- L1
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Dominios: qué son y cómo elegir',
$md$## Tu URL, tu identidad

Un dominio (ej. `tumarca.com`) es mucho más que una URL. Es parte de tu marca, de tu credibilidad y de cómo te ven los clientes.

### Anatomía de un dominio

`www.tumarca.com.ar`

- **www** — subdominio (opcional, casi obsoleto)
- **tumarca** — el nombre
- **.com** — TLD (Top Level Domain)
- **.ar** — country code (opcional, identifica país)

### ¿Qué extensión elegir?

En 2026, las opciones buenas:

| TLD | Cuándo usar | Notas |
|---|---|---|
| `.com` | Siempre que esté disponible | Estándar global, más confiable |
| `.co` | Si .com ocupado, alternativa fuerte | Muchos emprendimientos lo usan |
| `.io` | Productos tech / startups | Popular pero más caro |
| `.ai` | Productos de IA | Premium, caro ($50-200/año) |
| `.app` | Apps móviles/web | Google lo promueve |
| `.me` | Portfolio personal | Para sitio personal |
| `.[país]` | Negocios locales | ej .ar, .mx, .es, .co |

**Regla 2026**: .com si está disponible. Si no, .co o .io. Evitá TLDs raros (.xyz, .site, .online) — dan impresión de spam.

### Dónde comprar dominios

Registrars recomendados:

1. **[Namecheap](https://namecheap.com)** — económico, buen panel, $8-15/año para .com
2. **[Porkbun](https://porkbun.com)** — más barato aún, excelente UX, recomendado
3. **[Cloudflare Registrar](https://cloudflare.com)** — al costo (sin markup), requiere cuenta Cloudflare
4. **Google Domains** — ya no existe, fue adquirido por Squarespace (ahora en Squarespace Domains)

**Evitar**: GoDaddy (precios engañosos con upsells agresivos), Hostinger (OK pero upsells molestos).

### Reglas para elegir bien el nombre

- **Corto**: 6-14 caracteres ideal. Cada letra extra es 10% menos probabilidad de tipearlo bien
- **Fácil de pronunciar**: si lo decís al teléfono, ¿lo escribirían bien?
- **Sin guiones ni números**: "mi-marca.com" o "marca2.com" se ven amateur
- **No tropiece en ambos idiomas**: si operás ES+EN, ¿funciona en ambos?
- **Sin marcas registradas**: chequeá [TESS](https://tmsearch.uspto.gov) (USA) o registros locales

### Dominios premium: caros pero a veces valen

Algunos dominios están "estacionados" por revendedores y cuestan $500-50,000. ¿Vale?

**Sí vale cuando**:
- El negocio ya factura bien
- El dominio es genérico perfecto (ej. `photos.com`)
- Vas a invertir fuerte en branding

**No vale cuando**:
- Recién arrancás
- Hay alternativas creativas disponibles ($10/año)
- Se come 3 meses de runway

### Protección: privacy y renovación

Al comprar, activá 2 cosas:

**1. WHOIS Privacy**
Sin eso, tu nombre, email y teléfono quedan públicos — spammers te encuentran. La mayoría de registrars lo dan gratis.

**2. Auto-renew**
Si se vence, lo perdés. Un dominio vencido queda en "redemption" (60 días, recuperarlo cuesta $100+) o vuelve al pool (cualquiera lo agarra). Muchos negocios perdieron su dominio por olvidar renovar.

Alternativa más segura: pagá 5-10 años de una. Más barato total y no te preocupa.

### Subdominios: úsalos bien

Podés crear subdominios libres sobre tu dominio:

- `app.tumarca.com` → la app (para users logueados)
- `blog.tumarca.com` → el blog
- `docs.tumarca.com` → documentación
- `tumarca.com` → landing principal (marketing)

Esto separa marketing de producto. Común en productos SaaS.

### Emails con tu dominio

Tener `tu@tumarca.com` te da credibilidad infinita vs `tumarca@gmail.com`. Opciones:

- **Google Workspace** — $6/mes/usuario, estándar
- **Fastmail** — $5/mes/usuario, privacy-first
- **Zoho Mail** — free tier para 1 usuario
- **iCloud Mail** — gratis con Apple si configurás dominio custom

Configurás MX records (un tipo de registro DNS — DNS es el sistema que traduce nombres de dominio a direcciones IP) en tu registrar y listo.

### Errores comunes al elegir dominio

- **Dominio muy largo** ("la-mejor-consultoria-digital-colombia.com")
- **Extensión rara** (.xyz, .online — baja credibilidad)
- **Confusión por tilde** ("diseño.com" se pierde por tilde)
- **Olvidarse renovar** → perdés todo
- **Comprar 1 variante** sin comprar típicos (.com Y .co, o con/sin "s")
- **No chequear marcas registradas** → demanda potencial

### Qué pasa si el .com está ocupado

Alternativas (en orden de preferencia):

1. Agregá palabra ("getmimarca.com", "try[marca].com", "hello[marca].com")
2. Otro TLD fuerte (.co, .io si es tech)
3. Variante corta ("mrca.com")
4. Cambio creativo del nombre (a veces lo mejor es reformular)

Lo que NO hagas: comprar dominio idéntico con TLD raro y lanzar esperando que funcione igual. No funciona igual.

### Precio realista

Un dominio .com razonable cuesta $8-15/año nuevo.
Dominio premium existente: $500-5000 común, premium "perfecto" puede ser $10k-100k+.
Extensiones premium (.ai, .io): $30-100/año.

Presupuesto realista para arrancar: $15/año un solo dominio, $100/año si comprás variantes también (.com, .co, typos comunes).$md$,
    0, 50,
$md$**Elegí y comprá tu dominio.**

1. Usá [Namecheap](https://namecheap.com), [Porkbun](https://porkbun.com) o [Cloudflare Registrar](https://cloudflare.com) para buscar tu dominio
2. Verificá también: Instagram, X, TikTok, LinkedIn (al menos 2 de 4 libres)
3. Si .com está ocupado, intentá .co o agregá palabra ("get", "try", "hello")
4. Comprá **con WHOIS Privacy** activado y **auto-renew** ON
5. Bonus: comprá también variantes obvias de typo (ej. si tu dominio es "lumia.com", comprá "lumi.com" y "lumya.com" — $24/año evita confusión de usuarios)

**Meta**: terminar la lección con tu dominio comprado y a tu nombre, listo para conectar a tu landing en la siguiente lección.$md$,
    10)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Qué TLD elegís en 2026 si está disponible?',
     to_jsonb(ARRAY['.com — sigue siendo el estándar global más confiable','Cualquiera da igual','.xyz porque es barato','.tv']), 0, 0,
     '.com sigue siendo el default confiable: la gente lo asume, confía en él, y no lo confunde con spam. Si está ocupado, .co es la segunda mejor, o .io si sos tech. TLDs raros (.xyz, .site, .online, .click) levantan bandera roja — muchos sitios fraudulentos los usan y los usuarios/clientes lo asocian con spam. Tu dominio es tu primera impresión; invertí los $10/año en un .com bueno.'),
    (v_lesson_id, 'Al comprar un dominio, ¿qué dos cosas debés activar siempre?',
     to_jsonb(ARRAY['Nada especial','WHOIS Privacy (para que tus datos no queden públicos) y Auto-renew (para no perder el dominio si te olvidás pagar)','Solo SSL','Publicidad gratis']), 1, 0,
     'Sin WHOIS Privacy tu nombre, email y teléfono aparecen en cualquier herramienta de lookup — spammers y scammers te encuentran. La mayoría de registrars la ofrecen gratis. Auto-renew evita la catástrofe más común: te olvidás de pagar y perdés el dominio. Muchos negocios han perdido su identidad digital por olvidar la renovación. Alternativa segura: pagá 5-10 años de una vez.'),
    (v_lesson_id, 'El .com de tu marca está ocupado. ¿Cuál es el peor camino?',
     to_jsonb(ARRAY['Agregar palabra como "get" o "try" al nombre','Usar un TLD fuerte alternativo como .co','Comprar el mismo nombre con TLD raro (.xyz, .click, .site) y lanzar como si fuera igual','Reformular el nombre']), 2, 0,
     'Comprar .xyz o .click "porque el nombre me encanta" es tentador pero contraproducente. Los usuarios lo leen como spam o baja confianza, Google rankea peor, y cuando le digas el dominio al teléfono la gente va a tipear .com por default y no llegará. Mejores caminos: prefijo "get/try/hello", .co o .io si es tech, o reformular el nombre. En 2026 la credibilidad de tu TLD impacta conversión medible.');

  -- L2
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Hosting y deploy en 2026',
$md$## Donde vive tu sitio

Hosting es donde "corre" tu código para que el mundo lo vea. En 2026, la elección es mucho más simple que antes — casi siempre ganan las plataformas serverless.

### Hosting "tradicional" vs serverless

**Tradicional (shared hosting, VPS)**
- Alquilás un servidor, subís archivos por FTP (protocolo viejo de transferencia de archivos)
- Vos configurás todo: web server, base de datos, SSL
- Ejemplos: Bluehost, HostGator, DigitalOcean, Linode
- Para sitios modernos: más trabajo, menos escalable

**Serverless / Platform as a Service**
- Subís tu código, la plataforma se encarga del resto
- Auto-scaling, SSL automático, deploy con 1 click
- Ejemplos: Vercel, Netlify, Cloudflare Pages, Railway
- Para sitios modernos: dominante en 2026

En este módulo nos enfocamos en serverless. Es más simple, más rápido y casi siempre suficiente.

### Las 4 plataformas que importan

| Plataforma | Fuerte en | Precio |
|---|---|---|
| **Vercel** | Sites Next.js, integración perfecta con Claude Code/v0 | Free generoso, Pro $20/user/mes |
| **Netlify** | Sitios estáticos, formularios nativos | Free generoso, Pro $19/user/mes |
| **Cloudflare Pages** | Velocidad global, barato | Free muy generoso |
| **Railway** | Apps full-stack con DB, más backend | $5/mes arranque, escala según uso |

Para landings y apps React/Next.js: **Vercel** gana por integración.
Para sitios estáticos simples: **Cloudflare Pages** es imbatible en precio/velocidad.
Para apps con BD propia: **Railway** o **Fly.io**.

### Deploy desde Lovable

Si usaste Lovable, ya viste el botón "Publish". Funciona así:

1. Lovable desploga en su infraestructura
2. Te da URL `tu-proyecto.lovable.app`
3. Para dominio propio, tenés que conectar — lo vemos a continuación

### Deploy desde código (GitHub → Vercel)

El flujo estándar en 2026 si usás Claude Code:

1. Tu código está en un repo de GitHub (servicio que aloja código con control de versiones)
2. En Vercel, "Import Project" → elegís el repo
3. Vercel detecta framework (Next.js, Vite, etc.) y configura todo
4. Cada push a `main` = deploy automático

Setup total: 5 minutos. A partir de ahí, cada cambio que hagas en código y pushes, actualiza la web.

### Conectar tu dominio

**Desde Vercel:**

1. En tu proyecto → Settings → Domains → Add
2. Escribí tu dominio (ej: `tumarca.com`)
3. Vercel te muestra 2-3 DNS records para configurar

**En tu registrar (Namecheap/Porkbun):**

1. Entrás al panel del dominio → Advanced DNS
2. Agregás los records que Vercel te mostró (típicamente un A y un CNAME)
3. Guardás

**DNS propagation**: tarda 5min-2h. Mientras, tu sitio puede verse inestable. Después todo estable.

### SSL automático

Los navegadores modernos requieren HTTPS (URLs que empiezan con https://) para que el sitio se vea "seguro". Sin HTTPS, sale una alerta roja.

Plataformas serverless (Vercel, Netlify, Cloudflare) activan SSL automáticamente vía Let's Encrypt (certificados gratis). No tenés que hacer nada.

Si usás hosting tradicional, configuralo con Let's Encrypt manualmente o pagá certificado.

### Cloudflare: gratis y potente

Incluso si hospedás en Vercel, es buena idea meter **Cloudflare** delante:

- **CDN global** — tu sitio se cachea en 300+ ciudades, carga rápido en cualquier país
- **DDoS protection** — aguanta ataques
- **DNS management** — panel mejor que el de registrars
- **Caching avanzado** — mejor velocidad
- **Analytics básicos gratis**

Proceso:

1. Creá cuenta en [Cloudflare](https://cloudflare.com)
2. Agregás tu dominio
3. Cambiás nameservers en tu registrar a los de Cloudflare
4. En 24h, todo tu DNS lo maneja Cloudflare

Gratis para siempre en el plan free. Sumale 50 puntos a la velocidad de tu sitio.

### Configurar www vs no-www

Decisión: ¿tu sitio vive en `tumarca.com` o en `www.tumarca.com`?

En 2026 el default: **sin www**. Se ve más moderno, más corto, más clean.

Configurar: en DNS creás ambos (A record para raíz, CNAME para www) y Vercel/Netlify redirigen uno al otro automáticamente. Elegís cuál es el "principal" en settings.

### Subdominios prácticos

Si vas a tener varios productos/secciones:

- `tumarca.com` → landing principal (marketing)
- `app.tumarca.com` → la app real (login requerido)
- `blog.tumarca.com` → blog
- `docs.tumarca.com` → documentación

Cada subdominio puede ser un proyecto de Vercel independiente. Super flexible.

### Monitoreo básico

Servicios gratis que te avisan si tu sitio se cae:

- **UptimeRobot** — chequea cada 5 min, avisa por email
- **BetterStack** — más bonito pero con free tier
- **Pingdom** — clásico, free limitado

Al inicio UptimeRobot alcanza. No vas a saber que se cayó a las 3am si no lo tenés.

### Errores comunes al conectar dominio

- **Esperar 5 min y asumir que no funciona**: DNS tarda hasta 2h. Esperá
- **Usar A record hacia IP dinámica**: las IPs de Vercel cambian, usá CNAME o el ALIAS que te indiquen
- **No configurar tanto www como raíz**: 50% visitantes tipean www, 50% sin. Ambos deben funcionar
- **Olvidar HTTPS forzado**: configurá redirect automático http → https
- **DNS del registrar vs DNS de Cloudflare**: decidí dónde vive el DNS. Si pasaste a Cloudflare, tocá ahí (no en el registrar)

### Costos anuales realistas

Para una landing o app chica:

- Dominio: $15/año
- Vercel / Netlify / Cloudflare Pages: $0 (free tier alcanza para empezar)
- Cloudflare (opcional): $0
- Email (Google Workspace): $72/año/usuario
- Monitoreo: $0 (UptimeRobot free)

Total primer año: $15-90 según si querés email corporativo.

Cuando escales (>1M requests/mes, >100GB/mes tráfico), probablemente saltés a plan pago: $20/mes Vercel Pro o equivalente.$md$,
    1, 60,
$md$**Conectá tu dominio al proyecto.**

1. Si tu proyecto está en Lovable → Publish → luego conectá dominio custom siguiendo su guía
2. Si tu proyecto está en GitHub/Claude Code → importalo a Vercel y configurá dominio
3. En tu registrar: configurá los DNS records que la plataforma te indique
4. Verificá que tanto `tumarca.com` como `www.tumarca.com` funcionen
5. **Pedile a alguien** que abra `tumarca.com` y compruebe que se ve bien (elimina que pueda ser cache del browser tuyo)
6. **Bonus**: pasá a Cloudflare para CDN + DDoS gratis
7. **Instalá UptimeRobot** para que te avise si se cae

**Meta**: tener tu landing corriendo en `tumarca.com` con SSL, en mobile y desktop, monitoreada.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Por qué en 2026 casi todos usan hosting serverless (Vercel, Netlify) vs hosting tradicional?',
     to_jsonb(ARRAY['Es más caro','Es más simple (deploy automático con cada push), auto-scaling, SSL gratis, CDN global incluido — el tradicional requiere configurar todo a mano','No es así','Los tradicionales son mejores']), 1, 0,
     'Hace 10 años configurar hosting tradicional era la única opción. Hoy las plataformas serverless te dan deploy con 1 click, SSL automático con Let''s Encrypt, auto-scaling sin tocar nada y deploy automático cuando pusheas código. Todo con free tier generoso. El tradicional sigue existiendo para casos específicos pero para 90% de proyectos modernos (landings, apps, SaaS chicos) serverless gana cómodo.'),
    (v_lesson_id, 'Configurás DNS para tu dominio y no funciona inmediatamente. ¿Qué hacés?',
     to_jsonb(ARRAY['Borrar todo y empezar de cero','Esperar 5 min - 2h, DNS tarda en propagarse globalmente — si después de 2h sigue sin funcionar, revisá que los records estén correctos','Cambiar de registrar','Llamar a soporte de inmediato']), 1, 0,
     'DNS propagation tarda de 5 min a 2 horas en casos normales (algunos ISPs tardan hasta 24h en casos raros). El error más común: configurás DNS, no funciona en 5 min, entrás en pánico, lo cambiás, empeorás todo. Paciencia. Chequeá con [dnschecker.org](https://dnschecker.org) si se propagó globalmente. Si después de 2h sigue sin funcionar ahí sí revisá los records y ayuda de soporte.'),
    (v_lesson_id, '¿Cuál es el beneficio principal de meter Cloudflare delante de tu hosting (aunque uses Vercel)?',
     to_jsonb(ARRAY['Nada, es redundante','CDN global (tu sitio se cachea en 300+ ciudades = carga rápido en cualquier país), DDoS protection, DNS mejor — todo gratis en plan free','Es más lento','Solo sirve para sitios grandes']), 1, 0,
     'Vercel ya tiene CDN bueno, pero Cloudflare free tier agrega protección DDoS, analytics, caching avanzado y un panel de DNS mejor que casi todos los registrars — todo sin costo. Para sitios con tráfico internacional, Cloudflare + Vercel es el combo estándar. El único riesgo: si configurás mal el caching, podés servir versión vieja del sitio. Pero con opciones por defecto es seguro.');

  -- L3
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Email corporativo y productividad',
$md$## Del "@gmail" al "@tumarca"

Tener `tu@tumarca.com` en tu firma cambia cómo te perciben clientes, inversores y prospects. Es una de las pequeñas cosas que separan "hobby" de "negocio serio".

### Opciones de email corporativo

**Google Workspace** — $7/usuario/mes
- Gmail con tu dominio, Drive, Calendar, Meet, Docs
- Estándar empresarial mundial
- Excelente filtro de spam, integraciones infinitas
- Mi recomendación para 90% de casos

**Microsoft 365 Business** — $6/usuario/mes
- Outlook + Teams + Word/Excel/PowerPoint + OneDrive
- Mejor para empresas que ya usan stack Microsoft
- Teams para comunicación interna

**Zoho Mail** — gratis hasta 5 usuarios con límites
- Opción si sos solo y no querés pagar
- Interfaz menos pulida pero funcional

**Fastmail** — $5/usuario/mes
- Privacy-first, sin escanear emails
- Buena opción para equipos que valoran privacidad

### Configurar Google Workspace con tu dominio

Pasos simplificados:

1. Comprá [Google Workspace](https://workspace.google.com), elegí plan Business Starter ($7/user/mes)
2. Google te pide verificar tu dominio agregando un TXT record en DNS
3. Después, Google te da MX records para configurar también
4. Configurás MX records en tu registrar (o en Cloudflare si usás)
5. En 1-2h los emails a `@tumarca.com` llegan a tu Gmail Workspace

**Tip**: creá alias gratis — `hola@`, `info@`, `ventas@`, `soporte@` todos pueden ir a la misma inbox. Se ve profesional.

### Firma de email profesional

Una buena firma incluye:

- Tu nombre completo
- Tu rol + marca
- Link al sitio web
- Link a perfiles sociales profesionales (LinkedIn, X)
- Opcional: foto profesional pequeña
- Opcional: teléfono si aplica

Evitá:
- Frases inspiracionales largas ("La vida es como...")
- Disclaimers legales de 10 párrafos (típico de corporaciones)
- Tipografías raras o colores vibrantes

Usá [HoneyBook](https://honeybook.com) o [WiseStamp](https://wisestamp.com) para firmas bonitas, o escribilas a mano en HTML simple.

### Email deliverability: que tus emails no caigan en spam

Cuando mandás emails desde tu dominio (en especial los automáticos, como confirmaciones de compra o newsletter), Gmail/Outlook deciden si llegan a inbox o a spam.

Lo que los deja tranquilos:

**1. SPF record** — autoriza qué servidores pueden mandar en nombre de tu dominio
**2. DKIM record** — firma criptográfica para verificar autenticidad
**3. DMARC record** — política de qué hacer si SPF/DKIM fallan

Google Workspace te da estos 3 al configurar el dominio. Instalalos en DNS. Sin ellos tus emails automáticos pueden ir a spam.

**Chequeo**: mandá un mail a [mail-tester.com](https://mail-tester.com), te da un score sobre 10. Buscá 9+.

### Herramientas de productividad que suelen acompañar

Cuando tenés tu dominio configurado, solés querer:

- **Notion** o **Obsidian** — documentación interna, notas, wiki
- **Linear** o **Height** — gestión de tareas/tickets
- **Slack** o **Discord** — chat interno (si equipo >1)
- **Calendly** o **Cal.com** — agenda pública para clientes
- **Stripe** — cobros online
- **HubSpot** o **Notion con CRM** — gestión de clientes

No necesitas todo day 1. Pero saber que existen te deja planear.

### Email marketing vs email transaccional

Dos tipos distintos:

**Transaccional**: emails automáticos por acciones (confirmación de compra, reset password, onboarding)
- Herramientas: **Resend**, **Postmark**, **AWS SES**
- Precio: $0.001/email aprox
- Alta deliverability porque son "esperados"

**Marketing**: emails a tu lista (newsletter, promociones)
- Herramientas: **Mailchimp**, **ConvertKit**, **Beehiiv**, **Substack**
- Precio según tamaño de lista
- Requieren consentimiento explícito (GDPR/CAN-SPAM)

Para un negocio serio vas a usar las dos herramientas distintas. Mezclarlas no funciona bien.

### Protección contra ataques

Algunos básicos de seguridad:

- **2FA (two-factor authentication) en tu Workspace** — obligatorio, no opcional
- **Dominio privado en registrar** — ya lo activaste en lección 1
- **No pongas tu email personal en signup de servicios random** — usá un alias
- **Revisá actividad sospechosa** — Google Workspace tiene panel de seguridad

Si sos negocio con ingresos reales, considerá seguro cibernético básico. Los ataques a pequeños negocios aumentaron mucho.

### Google Workspace Admin: 3 configuraciones iniciales

Una vez tenés Workspace:

1. **Habilitá 2FA obligatorio** para todos los usuarios
2. **Configurá alias comunes** (hola@, info@, soporte@)
3. **Configurá catch-all** (opcional) — cualquier email a `*@tumarca.com` llega a tu inbox principal

Eso te deja solo configurar una vez y olvidarte.

### Nivel avanzado: email con tu marca automatizado

Para scaled businesses:

- **Welcome sequence** — nuevo user recibe 5 emails durante 2 semanas
- **Abandoned cart** — si agregaron al carrito y no compraron, reminder en 24h
- **Re-engagement** — users inactivos 30 días reciben mail
- **Newsletter automatizada** — con contenido dinámico

Esto se construye con ConvertKit/Mailchimp + Zapier o n8n para los triggers. Es el siguiente nivel después de "ya tengo email corporativo". Lo vemos en el track de n8n.$md$,
    2, 60,
$md$**Configurá tu email corporativo.**

1. Comprá **Google Workspace** (o alternativa que prefieras). El costo de 1 mes ($7) vale la pena para tener email pro
2. Configurá tu dominio siguiendo su guía (MX records, SPF, DKIM, DMARC en DNS)
3. Creá 3-4 alias: `hola@`, `info@`, `soporte@`, `ventas@` (todos llegando a tu inbox)
4. Creá tu **firma profesional** (texto simple: nombre, rol, web, LinkedIn)
5. **Test deliverability**: mandate un email desde `@tumarca.com` a un email externo. Confirmá que no cae en spam
6. Mandá uno a [mail-tester.com](https://mail-tester.com) — objetivo: 9+ puntos
7. Activá **2FA** en tu cuenta admin

**Meta**: tener `tu@tumarca.com` funcionando desde tu Gmail/Outlook habitual, con firma pro y configuración anti-spam.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '¿Cuál es la razón por la que tus emails automáticos pueden caer en spam aunque el contenido sea normal?',
     to_jsonb(ARRAY['Mala suerte','Falta configurar SPF, DKIM y DMARC en tu DNS — son 3 registros que autentican que tu dominio puede mandar esos emails','Usás Mac','Nada, siempre caen']), 1, 0,
     'Gmail/Outlook evalúan si el email es legítimo antes de decidir inbox vs spam. SPF dice "estos servidores pueden mandar emails en nombre de tumarca.com". DKIM firma el email criptográficamente. DMARC dice "si SPF/DKIM fallan, hacé X". Sin los 3, los proveedores dudan y mandan a spam por seguridad. Google Workspace te da los valores exactos al configurar el dominio.'),
    (v_lesson_id, 'Mandás emails transaccionales (confirmaciones, resets) desde tu app. ¿Qué herramienta usás?',
     to_jsonb(ARRAY['Mailchimp','Resend, Postmark o AWS SES — especializadas en transaccional (alta deliverability, API simple, $0.001/email aprox)','Tu Gmail personal','Nada, lo hace tu registrar']), 1, 0,
     'Mailchimp/ConvertKit son para marketing (newsletters, promos) — tienen regulaciones específicas, listas opt-in, y caen en spam si las usás para transaccional. Para emails automáticos de acción del usuario (bienvenida, reset password, confirmación compra), usás herramientas especializadas: Resend, Postmark, SES. Se integran a tu app por API y tienen deliverability 99%+.'),
    (v_lesson_id, 'En tu Google Workspace, ¿qué es un "alias" y para qué sirve?',
     to_jsonb(ARRAY['Una cuenta adicional pagada','Un email adicional que recibe a tu inbox principal (ej. hola@ info@ soporte@ todos llegando al mismo inbox) — gratis, hasta 30 alias por usuario','Un backup de tu email','Lo mismo que una cuenta normal']), 1, 0,
     'Los alias son emails gratis que redirigen a tu inbox principal. En vez de crear 5 usuarios (5 × $7 = $35/mes), tenés 1 usuario con 5 alias ($7/mes total). Típico setup: `hola@` recibe contacto general, `info@` para FAQs, `ventas@` para leads, `soporte@` para tickets. Todos llegan a vos, pero el que manda ve una dirección profesional específica. Gmail Workspace permite hasta 30 alias por usuario.');

  -- L4
  INSERT INTO lessons (module_id, title, content_md, order_index, xp_reward, practical_task, estimated_minutes)
  VALUES (v_module_id, 'Seguridad, backups y mantenimiento',
$md$## Lo que nadie hace hasta que es tarde

Tu sitio está arriba, tu dominio configurado, email funcionando. Pero un solo error puede tirarlo todo: hackeo, dominio vencido, BD corrupta, deploy que rompió todo. Esta lección: la higiene para evitar desastres.

### La trinidad del desastre

Los 3 escenarios más comunes que destruyen proyectos:

1. **Olvidar renovar el dominio** → perdés la URL, todas tus campañas mueren
2. **Hackeo de cuenta** (email, registrar o hosting) → puede robarte todo
3. **Deploy que rompió producción** (y no tenés backup) → horas de downtime, clientes furiosos

Los 3 son 100% prevenibles con higiene básica.

### 2FA en todo

Two-factor authentication (requerir código de tu teléfono o app además de la contraseña) es el setting más importante de seguridad.

Activalo en:
- Registrar (Namecheap, Porkbun, Cloudflare)
- Hosting (Vercel, Netlify)
- GitHub (donde vive tu código)
- Google Workspace / Microsoft 365
- Stripe / procesador de pagos
- Banco y cuentas críticas

Preferí **apps de autenticación** (Google Authenticator, Authy, 1Password) sobre SMS. SMS es vulnerable a SIM swapping (un ataque donde roban tu número).

### Passwords: deja de reutilizarlas

Si usás la misma password en 10 sitios, uno solo comprometido compromete los 10.

Password manager obligatorio. Opciones:

- **1Password** — premium, familia $5/mes, interfaz excelente
- **Bitwarden** — open source, free tier generoso
- **Proton Pass** — si usás Proton Mail

Genera passwords de 20+ caracteres, únicas por sitio. El manager las llena por vos. 1 hora de setup inicial ahorra horas de pesadilla futura.

### Backups de lo crítico

Qué respaldar:

**1. Código fuente** → ya está en GitHub (repo es el backup)
**2. Base de datos** → backup automático
- Supabase: tiene backups automáticos diarios en plan Pro (7 días). Free tier no.
- Otras BD: configurar backup propio

**3. Imágenes y assets** → si están en S3, CloudFlare R2 o similar, configurá versioning

**4. Emails** → Google Workspace los respalda pero podés hacer export manual con Google Takeout

**5. Configs** → DNS records, API keys, variables de entorno. Guardalas en 1Password/Bitwarden.

Regla: si lo perdiera mañana, ¿cuánto me dolería? Lo que más duela, respaldá.

### Deploy seguro: staging + preview

Nunca pushees directo a producción. El flujo sano:

1. **Branch de feature**: hacés cambios en rama separada (no `main`)
2. **Preview deploy**: Vercel/Netlify auto-despliegan la rama a una URL preview
3. **Testeás** en la preview
4. **Merge a main** cuando confirma
5. **Deploy a prod** automático al mergear

Si algo sale mal, revertís el merge y producción vuelve. 30 segundos para recuperar.

Sin este flujo, un bug en código rompe tu sitio live hasta que lo arregles.

### Monitoreo real

Más allá de UptimeRobot:

- **Sentry** — te avisa cada vez que tu app tira un error en producción. Gratis hasta cierto volumen
- **Logtail / Better Stack Logs** — logs centralizados
- **Vercel Analytics** — tráfico y performance
- **Stripe dashboard** — si cobrás, notificaciones de pagos fallidos

Configurar Sentry en 10 min te ahorra descubrir bugs porque un usuario se quejó. Los ves vos primero.

### Rotación de secrets

Tus API keys (AI keys, Stripe keys, DB credentials) eventualmente se filtran por error: pusheás una por accidente a un repo público, un colaborador se va, o una herramienta se compromete.

Plan:

- Guardá secrets en variables de entorno (`.env` local, settings de la plataforma en prod)
- **Nunca** las commitees a Git (agregá `.env` a `.gitignore`)
- Si una se filtra: revocala de inmediato y generá nueva
- Cada 6-12 meses: rotalas aunque no haya incidente

Chequeo rápido: buscá en tu repo ("API_KEY=", "SECRET=") — si hay cosas escritas a mano, movelas a env vars ya.

### GDPR / privacidad

Si tenés usuarios en Europa (o en Argentina/Latam con leyes equivalentes), hay mínimos legales:

- **Política de privacidad** — qué datos recolectás y por qué
- **Términos y condiciones** — reglas de uso
- **Cookie banner** — si usás cookies no-esenciales
- **Right to delete** — podés borrar todos los datos de un user si lo pide
- **Data export** — podés entregarle sus datos si lo pide

Servicios como [Termly](https://termly.io) o [Iubenda](https://iubenda.com) generan estos docs por $10/mes.

Pedirle a Claude tu política de privacidad base puede ahorrar $50 de abogado — revisala antes de publicarla con alguien que sepa si es mercado regulado.

### El calendario de mantenimiento

Marcá en tu agenda (cada X meses):

**Mensual:**
- Revisar analytics — qué funciona, qué no
- Testear flujos críticos (signup, checkout, etc.)
- Revisar errores en Sentry

**Trimestral:**
- Actualizar dependencias (`npm update`)
- Revisar costos de servicios
- Auditar accesos (quién tiene acceso a qué)

**Anual:**
- Renovar dominio (ideal: 5+ años de una)
- Rotar secrets
- Revisar política de privacidad
- Backup manual de todo lo crítico
- Auditar tu stack: ¿usás todo lo que pagás?

### Recap del módulo

Ya tenés:

- Dominio comprado y protegido
- Hosting serverless configurado
- DNS funcionando
- SSL automático
- Email corporativo con anti-spam
- Seguridad básica (2FA, password manager, backups)

Próximo módulo: **Sitio completo** — pasás de landing simple a sitio con múltiples páginas, navegación, formularios serios e integraciones. Esto es cuando tu URL ya no es "una landing" sino un sitio de verdad.$md$,
    3, 70,
$md$**Implementá la higiene de seguridad.**

Checklist:

1. **Activa 2FA** en: registrar, hosting, GitHub, email (Google Workspace), procesador de pagos. **Usa app de autenticación, no SMS**
2. **Configurá un password manager** (1Password o Bitwarden) — migrá al menos las 10 passwords más críticas
3. **Revisá variables de entorno**: ¿hay alguna API key hardcodeada en código? Moverla a env vars
4. **Instalá Sentry** en tu proyecto Lovable/Next.js — te va a avisar de errores en prod
5. **Configurá UptimeRobot** si no lo hiciste
6. **Agendá reminders**: renovación dominio, actualización dependencias trimestral
7. **Bonus**: corré [Have I Been Pwned](https://haveibeenpwned.com) con tu email — ¿ya salió en algún leak? Si sí, cambiá las passwords afectadas

**Meta**: dormir tranquilo sabiendo que un olvido o hackeo no te hace perder meses de trabajo.$md$,
    15)
  RETURNING id INTO v_lesson_id;

  INSERT INTO quizzes (lesson_id, question, options, correct_index, order_index, explanation) VALUES
    (v_lesson_id, '2FA por SMS es mejor que por app de autenticación:',
     to_jsonb(ARRAY['Sí, es más simple','Falso — SMS es vulnerable a SIM swapping (atacantes roban tu número). Apps como Google Authenticator o Authy son mucho más seguras','Son iguales','No importa']), 1, 0,
     'SIM swapping es un ataque real y creciente: el atacante convence a la compañía telefónica de transferir tu número a su SIM (con social engineering o empleados corruptos), y ahora recibe tus códigos SMS. Con eso accede a todo lo que tengas SMS 2FA. Apps de autenticación (TOTP) generan códigos offline en tu dispositivo — el atacante necesita físicamente el dispositivo. Cambiá SMS por app en todo lo crítico.'),
    (v_lesson_id, 'Hacés un cambio importante en tu código. ¿Cómo deployás sin riesgo a producción?',
     to_jsonb(ARRAY['Pushear directo a main','Crear branch de feature, Vercel/Netlify generan preview URL automática, testeás ahí, mergear a main cuando confirmás — si algo sale mal, revertís el merge','Esperar al fin de semana','No deployear nunca']), 1, 0,
     'El flujo seguro: branch de feature → preview deploy automático → testeás → merge a main → deploy automático a producción. Si un bug llega a prod, revertís el merge en GitHub y producción vuelve en 30 segundos. Pushear directo a main sin testear es cómo una empresa se rompe el servidor por un typo. Las plataformas modernas te dan preview deploys gratis — es negligente no usarlos.'),
    (v_lesson_id, '¿Qué hacés si una API key tuya se filtró accidentalmente en un repo público?',
     to_jsonb(ARRAY['Borrar el commit y fingir que no pasó','Revocar inmediatamente la key desde el proveedor y generar una nueva — asumí que fue comprometida aunque borres el commit, porque ya fue scrapeada por bots','Cambiar el nombre del repo','Nada, no importa']), 1, 0,
     'Los repositorios públicos son escaneados permanentemente por bots buscando secrets. Una key expuesta 5 segundos ya fue registrada por varios scrapers. Aunque la borres del commit (incluso del historial con rebase), asumí que está comprometida: revocala del proveedor y generá nueva de inmediato. Además, configurá GitHub secret scanning para que te avise si pasa de nuevo. Git filter-branch para "limpiar" historial es inútil si ya fue robada.');

  RAISE NOTICE 'Módulo "Hosting y dominio": 4 lecciones + 12 quizzes insertados.';
END $$;
