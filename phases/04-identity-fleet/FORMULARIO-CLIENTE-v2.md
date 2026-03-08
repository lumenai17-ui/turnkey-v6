# FORMULARIO DE ONBOARDING — TURNKEY v6

**Versión:** 2.0.0 — Agente en Mano
**Fecha:** 2026-03-07
**Propósito:** Recopilar TODA la información necesaria para levantar un agente completo en una sola sesión

---

## 📌 MODELO DE PROVISIÓN v2.0

```
┌──────────────────────────────────────────────────────────────────────┐
│                    ¿QUIÉN PROVEE QUÉ?                                │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  🟢 NOSOTROS PROVEEMOS (incluido en el servicio):                    │
│  ├── Ollama Cloud (LLM ∞ tokens)                                    │
│  ├── Deepgram API key (voz STT+TTS)                                 │
│  ├── Stable Diffusion API key (imágenes)                             │
│  ├── Kling 2.1 via fal.ai (video)                                   │
│  ├── Google Maps API key (ubicación/rutas)                           │
│  ├── Brave Search key (búsqueda web)                                │
│  ├── Email: Postfix+Dovecot (nuestro dominio)                       │
│  ├── VPS completo con todo instalado                                 │
│  ├── Cloudflare Tunnel (web pública)                                 │
│  ├── Bot de Telegram (lo creamos nosotros)                           │
│  └── 58 skills + 20 automatizaciones                                │
│                                                                      │
│  🟡 EL CLIENTE PROVEE (solo si aplica):                              │
│  ├── Cuenta Google (Calendar + Sheets) → nosotros config OAuth       │
│  ├── WordPress (URL + user + app password) → si tiene blog           │
│  ├── Meta Business (access token) → si quiere ads/redes API          │
│  ├── Stripe (secret key) → si quiere cobrar online                   │
│  ├── Información del negocio, branding, knowledge base               │
│  └── Canales extra (WhatsApp propio, Discord propio)                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## SECCIÓN 1: IDENTIDAD DEL NEGOCIO

> Todo esto lo llena el cliente o su vendedor en la primera reunión.

```
═════════════════════════════════════════════════════════════════
                    1. DATOS DEL NEGOCIO
═════════════════════════════════════════════════════════════════

Nombre del negocio: ___________________________________________
Nombre del agente: ____________________________________________
  (Ejemplo: "Luna" para una boutique, "Max" para un gym)

Tipo de negocio:
  [ ] Restaurante/Café       [ ] Hotel/Hospedaje
  [ ] Tienda/Retail           [ ] Servicios profesionales
  [ ] Salud/Belleza           [ ] Fitness/Gym
  [ ] Educación               [ ] Inmobiliaria
  [ ] E-commerce              [ ] Otro: _________________

Descripción corta del negocio (1-2 líneas):
_______________________________________________________________
_______________________________________________________________

País: ________________  Ciudad: ________________
Timezone: ________________ (ej: America/Bogota, America/Panama)
Idioma principal: [ ] Español  [ ] English  [ ] Otro: ________
Segundo idioma (opcional): ____________________________________

Dirección física: ____________________________________________
Teléfono del negocio: ________________________________________
Email del negocio: ____________________________________________
Website (si tiene): ___________________________________________

Horario de atención:
  Lunes a viernes: __________ a __________
  Sábados: __________ a __________
  Domingos: __________ a __________
  Feriados: [ ] Cerrado  [ ] Igual que entre semana

Persona de contacto (dueño/admin):
  Nombre: ____________________________________________________
  Teléfono personal: _________________________________________
  Email personal: _____________________________________________
  Telegram User ID: ___________________________________________
```

---

## SECCIÓN 2: BRANDING

> Necesario para que el agente genere contenido acorde a la marca.

```
═════════════════════════════════════════════════════════════════
                    2. BRANDING
═════════════════════════════════════════════════════════════════

Colores de marca:
  Color primario (HEX): #_____________________________________
  Color secundario (HEX): #___________________________________
  Color de acento (HEX): #____________________________________
  (Si no tienen, usamos defaults profesionales)

Logo:
  [ ] Archivo adjunto: ______________  [ ] URL: ______________
  [ ] No tiene logo (generamos uno temporal)

Tono de comunicación:
  [ ] Profesional y formal
  [ ] Profesional y amigable
  [ ] Casual y cercano
  [ ] Divertido y relajado
  [ ] Técnico y preciso
  [ ] Otro: __________________________________________________

Frases que SÍ debe usar el agente:
  1. ________________________________________________________
  2. ________________________________________________________
  3. ________________________________________________________

Frases que NUNCA debe usar el agente:
  1. ________________________________________________________
  2. ________________________________________________________

Emoji del agente: _____ (ej: 🍽️ para restaurante, 💪 para gym)

Nombre que usa el agente para referirse a sí mismo: __________
  (ej: "Soy Luna, la asistente de Boutique XYZ")
```

---

## SECCIÓN 3: CANALES DE COMUNICACIÓN

> Mínimo 1 canal necesario. Telegram es el más fácil de arrancar.

```
═════════════════════════════════════════════════════════════════
                    3. CANALES
═════════════════════════════════════════════════════════════════

TELEGRAM (recomendado — lo configuramos nosotros):
  [ ] SÍ, crear bot nuevo (lo hacemos nosotros)
  [ ] SÍ, ya tengo bot → Token: ______________________________
  [ ] NO

  Quién puede hablar con el bot:
    User IDs permitidos: ______________________________________
    (Ayudamos al cliente a obtener su ID)

EMAIL:
  [ ] SÍ, usar email de nuestro dominio (incluido)
      → Email asignado: {agente}@{nuestro-dominio}
  [ ] SÍ, usar email del cliente
      → Servidor SMTP: _______________________________________
      → Puerto SMTP: _________________________________________
      → Usuario: ______________________________________________
      → Contraseña: ___________________________________________
      → Servidor IMAP: ________________________________________
      → Puerto IMAP: __________________________________________
  [ ] NO

WHATSAPP:
  [ ] SÍ, conectar WhatsApp del negocio
      → Número: _______________________________________________
  [ ] NO (se puede agregar después)

DISCORD:
  [ ] SÍ, conectar servidor Discord
      → Bot Token: ____________________________________________
      → Guild ID: _____________________________________________
  [ ] NO
```

---

## SECCIÓN 4: GOOGLE APIS

> Necesario para Calendar, Sheets, Maps. Nosotros configuramos el OAuth.

```
═════════════════════════════════════════════════════════════════
                    4. GOOGLE APIS
═════════════════════════════════════════════════════════════════

GOOGLE CALENDAR (gestión de citas):
  [ ] SÍ, conectar
      → Email de la cuenta Google: ____________________________
      → (Nosotros lo configuramos: el cliente solo acepta permisos)
  [ ] NO, no necesito gestión de citas

GOOGLE SHEETS (reportes, datos):
  [ ] SÍ, conectar
      → Misma cuenta que Calendar: [ ] SÍ  [ ] Otra: _________
  [ ] NO

GOOGLE MAPS (ubicación, rutas):
  [ ] SÍ (usamos nuestra key, no requiere nada del cliente)
  [ ] NO

Nota: El proceso es simple — le enviamos un link al cliente,
acepta los permisos de Google, y queda conectado.
```

---

## SECCIÓN 5: INTEGRACIONES EXTERNAS

> Solo si el cliente las necesita. Todas son opcionales.

```
═════════════════════════════════════════════════════════════════
                    5. INTEGRACIONES (OPCIONALES)
═════════════════════════════════════════════════════════════════

WORDPRESS (blog/website):
  [ ] SÍ, conectar WordPress
      → URL del sitio: ________________________________________
      → Usuario admin: ________________________________________
      → Application Password: _________________________________
        (Guía: Users → Edit → Application Passwords → Generate)
  [ ] NO

META ADS (Facebook/Instagram Ads):
  [ ] SÍ, conectar Meta Ads
      → Access Token: _________________________________________
      → Ad Account ID: ________________________________________
      → (Requiere app en developers.facebook.com)
  [ ] NO

STRIPE (cobros online):
  [ ] SÍ, conectar Stripe
      → Secret Key (sk_live_...): _____________________________
      → (El cliente lo obtiene de dashboard.stripe.com/apikeys)
  [ ] NO

GOOGLE MY BUSINESS:
  [ ] SÍ, gestionar perfil de Google
      → Business ID/URL: ______________________________________
  [ ] NO
```

---

## SECCIÓN 6: AUTOMATIZACIONES

> El cliente elige cuáles activar. Recomendamos empezar con 3-5 e ir sumando.

```
═════════════════════════════════════════════════════════════════
                    6. AUTOMATIZACIONES A ACTIVAR
═════════════════════════════════════════════════════════════════

MARKETING (¿cuáles quiere activas?):
  [ ] A-02 Post Creator — Crear posts con imagen+copy para redes
  [ ] A-05 SEO Content Creator — Artículos optimizados SEO
  [ ] A-06 Lead Capture — Formularios inteligentes → CRM
  [ ] A-07 Competitor Watch — Monitorear competidores
  [ ] A-01 Meta Ads Manager — Gestionar campañas (req. Meta API)
  [ ] A-03 Social Scheduler — Programar publicaciones

WEB CONTENT:
  [ ] A-10 Landing Page Express — Crear landing pages
  [ ] A-08 WordPress Publisher — Publicar en WordPress (req. WP)
  [ ] A-09 Blog Autopilot — Blog semanal automático (req. WP)
  [ ] A-11 Newsletter Auto — Newsletter semanal

OPERACIONES:
  [ ] A-12 Invoice Autopilot — Facturación automática
  [ ] A-13 Appointment Bot — Gestión de citas (req. Google Cal)
  [ ] A-14 Review Responder — Responder reseñas
  [ ] A-15 Daily Report — Resumen diario del negocio
  [ ] A-16 Customer Follow-up — Seguimiento post-servicio

E-COMMERCE:
  [ ] A-17 Product Catalog — Catálogo digital desde Excel
  [ ] A-18 Order Manager — Gestión de pedidos
  [ ] A-19 Payment Links — Links de pago (req. Stripe)
  [ ] A-20 Inventory Alert — Alertas de stock bajo

RECOMENDACIONES POR TIPO DE NEGOCIO:
  Restaurante: A-02, A-12, A-13, A-14, A-15, A-18
  Tienda:      A-02, A-12, A-17, A-19, A-20
  Servicios:   A-02, A-05, A-06, A-12, A-13, A-16
  Hotel:       A-02, A-04, A-13, A-14, A-15
```

---

## SECCIÓN 7: KNOWLEDGE BASE

> Todo lo que el agente necesita saber sobre el negocio.

```
═════════════════════════════════════════════════════════════════
                    7. KNOWLEDGE BASE
═════════════════════════════════════════════════════════════════

WEBSITE (scrapeamos automáticamente):
  URL principal: ______________________________________________
  Otras URLs importantes:
    1. ________________________________________________________
    2. ________________________________________________________
    3. ________________________________________________________

DOCUMENTOS (el cliente adjunta):
  [ ] Menú / Carta de servicios / Catálogo de productos
  [ ] Lista de precios
  [ ] Preguntas frecuentes (FAQ)
  [ ] Políticas (devoluciones, cancelaciones, etc.)
  [ ] Manual de marca / brand guidelines
  [ ] Otro: __________________________________________________

DATOS ESPECIALES:
  Horarios especiales: ________________________________________
  Formas de pago aceptadas: ___________________________________
  Zona de delivery (si aplica): _______________________________
  Redes sociales:
    Instagram: ________________________________________________
    Facebook: _________________________________________________
    LinkedIn: _________________________________________________
    TikTok: ___________________________________________________
    Twitter/X: ________________________________________________

INSTRUCCIONES ESPECIALES PARA EL AGENTE:
  (Cosas que el agente debe saber/hacer/evitar)
  1. ________________________________________________________
  2. ________________________________________________________
  3. ________________________________________________________
```

---

## SECCIÓN 8: FACTURACIÓN

> Datos para facturación automática (si activa A-12).

```
═════════════════════════════════════════════════════════════════
                    8. FACTURACIÓN (si aplica)
═════════════════════════════════════════════════════════════════

Nombre fiscal: ________________________________________________
NIT / Tax ID: _________________________________________________
Dirección fiscal: _____________________________________________
Moneda: [ ] USD  [ ] COP  [ ] EUR  [ ] Otro: _________________
Tasa de impuestos (%): ________________________________________
Método de cobro preferido:
  [ ] Transferencia  [ ] Stripe  [ ] Otro: ___________________
```

---

## SECCIÓN 9: CHECKLIST DE ENTREGA (uso interno)

> Nosotros llenamos esto durante el setup.

```
═════════════════════════════════════════════════════════════════
                    CHECKLIST INTERNO
═════════════════════════════════════════════════════════════════

SETUP COMPLETADO POR: ________________  FECHA: ________________

NUESTRAS APIS CONFIGURADAS:
  [ ] Ollama Cloud key asignada
  [ ] Deepgram key configurada
  [ ] Stable Diffusion key configurada
  [ ] Kling/fal.ai key configurada
  [ ] Google Maps key configurada
  [ ] Brave Search key configurada

CANALES ACTIVADOS:
  [ ] Telegram → Bot: @_________________
  [ ] Email → ________________@{dominio}
  [ ] WhatsApp → ________________
  [ ] Discord → ________________

GOOGLE APIS CONECTADAS:
  [ ] Calendar → OAuth completo
  [ ] Sheets → OAuth completo
  [ ] Maps → Key configurada

INTEGRACIONES EXTERNAS:
  [ ] WordPress → Conectado y probado
  [ ] Meta Ads → Token validado
  [ ] Stripe → Key validada
  [ ] Google My Business → Conectado

AUTOMATIZACIONES ACTIVADAS:
  [ ] _________ [ ] _________ [ ] _________
  [ ] _________ [ ] _________ [ ] _________

KNOWLEDGE BASE CARGADA:
  [ ] Website scrapeado
  [ ] Documentos indexados
  [ ] FAQ configurado

DRY-RUN COMPLETADO:
  [ ] Todas las automatizaciones activas probadas en modo dry-run
  [ ] Cliente notificado de resultados

ENTREGADO AL CLIENTE:
  [ ] Acceso a Telegram bot
  [ ] Instrucciones de uso
  [ ] Horario de warm-up explicado
```

---

*Formulario de Onboarding v2.0.0 — TURNKEY v6 — 2026-03-07*
