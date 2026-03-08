# Skills Bundles - TURNKEY v6

**Versión:** 2.0.0 — Agente en Mano
**Fecha:** 2026-03-07
**Área:** FASE 4 - ÁREA 6 - SKILLS BUNDLES

---

## 📋 RESUMEN

| Concepto | Definición |
|-----------|------------|
| **Skills Bundles** | Conjuntos preconfigurados de habilidades específicas por tipo de negocio |
| **Habilidades Natas** | 14 habilidades básicas que TODO agente debe tener |
| **Habilidades Built-in** | **58 habilidades** que funcionan SIEMPRE (nosotros proveemos todo) |
| **Automatizaciones** | 20 automatizaciones pre-configuradas |
| **Costo** | ~$22/mes por agente |

---

## 1️⃣ QUÉ SON LOS SKILLS BUNDLES

### Definición

Un **Skill Bundle** es un paquete preconfigurado de capacidades específicas diseñadas para un tipo de negocio particular. Cada bundle incluye:

1. **Skills específicas del negocio** - Funcionalidades que el negocio necesita
2. **Intents predefinidos** - Frases que activan cada skill
3. **Responses personalizadas** - Respuestas adaptadas al negocio
4. **Configuración de flujos** - Workflows automatizados

### Estructura de un Bundle

```json
{
  "bundle": "restaurante",
  "skills": ["menu", "reservas", "pedidos", "horarios", "delivery"],
  "custom_prompts": {
    "menu": "Puedo leer el menú y responder preguntas sobre platos...",
    "reservas": "Puedo gestionar reservaciones para el restaurante...",
    "pedidos": "Puedo tomar pedidos y enviarlos a cocina...",
    "horarios": "Puedo informar sobre horarios de atención..."
  },
  "intents": {
    "menu": ["¿qué tienen?", "menú", "carta", "platos", "comida"],
    "reservas": ["reservar", "mesa", "reservación", "disponibilidad"],
    "pedidos": ["pedir", "ordenar", "orden", "delivery", "llevar"]
  }
}
```

---

## 2️⃣ HABILIDADES DEL AGENTE

### Habilidades Natas (14 Obligatorias) — TODAS BUILT-IN

| # | Habilidad | Función | Procesamiento | Estado |
|---|-----------|---------|---------------|--------|
| 1 | email_send | Enviar emails | ⚙️ Local (Postfix — nuestro dominio) | ✅ Siempre |
| 2 | email_read | Leer emails | ⚙️ Local (Dovecot IMAP) | ✅ Siempre |
| 3 | voice_send | Enviar voice notes | 🎬 Deepgram Aura TTS ($3/M chars) | ✅ Siempre |
| 4 | voice_receive | Recibir voice notes | 🎬 Deepgram Nova STT ($0.006/min) | ✅ Siempre |
| 5 | audio_transcribe | Transcribir audio | 🎬 Deepgram Nova STT ($0.006/min) | ✅ Siempre |
| 6 | image_generate | Crear imágenes | 🎬 Stable Diffusion API ($0.01/img) | ✅ Siempre |
| 7 | image_receive | Analizar imágenes | ☁️ Ollama Cloud Vision | ✅ Siempre |
| 8 | pdf_generate | Crear PDFs | ⚙️ Local (wkhtmltopdf) | ✅ Siempre |
| 9 | pdf_read | Leer PDFs | ⚙️ Local (pdftotext) | ✅ Siempre |
| 10 | video_process | Procesar video | ☁️ Ollama Cloud | ✅ Siempre |
| 11 | location | Ubicación/maps | 🔗 Google Maps API (nuestra key) | ✅ Siempre |
| 12 | calendar | Google Calendar | 🔗 Google Calendar API (cuenta cliente) | ✅ Siempre |
| 13 | sheets | Google Sheets | 🔗 Google Sheets API (cuenta cliente) | ✅ Siempre |
| 14 | translate | Traducción | ☁️ Ollama Cloud | ✅ Siempre |

### Habilidades Built-in Restantes (44) — TODAS funcionan siempre

```
┌─────────────────────────────────────────────────────────────────────┐
│          HABILIDADES BUILT-IN (58 total = 14 natas + 44)           │
│            Todas funcionan SIEMPRE — Nosotros proveemos            │
├─────────────────────────────────────────────────────────────────────┤
│ COMUNICACIÓN ADICIONAL (4)                                         │
│   • sms_send         • whatsapp_send                               │
│   • telegram_send    • discord_send                                │
├─────────────────────────────────────────────────────────────────────┤
│ MULTIMEDIA (4)                                                     │
│   • image_edit (SD img2img)    • video_create (Kling 2.1/fal.ai)  │
│   • video_edit (FFmpeg local)  • ocr (Ollama Cloud Vision)        │
├─────────────────────────────────────────────────────────────────────┤
│ DOCUMENTOS (5)                                                     │
│   • pdf_edit (qpdf)         • doc_generate (pandoc)               │
│   • excel_generate          • excel_read (openpyxl)               │
│   • presentation_create (python-pptx)                              │
├─────────────────────────────────────────────────────────────────────┤
│ WEB & AUTOMATIZACIÓN (8)                                           │
│   • browser (Puppeteer)     • scraping (Puppeteer+cheerio)        │
│   • web_search (Brave free) • web_fetch (curl/fetch)              │
│   • web_create (templates)  • form_create (HTML templates)        │
│   • cron (cron/systemd)     • webhook (HTTP server)               │
├─────────────────────────────────────────────────────────────────────┤
│ INTELIGENCIA (6)                                                   │
│   • summarize       • extract_data     • sentiment                │
│   • memory_search   • classify         • rewrite                  │
│   (Todas ☁️ Ollama Cloud)                                          │
├─────────────────────────────────────────────────────────────────────┤
│ NEGOCIO (6)                                                        │
│   • invoice_generate  • report_generate  • qrcode_generate        │
│   • qrcode_read       • metrics_dashboard • notifications         │
│   • reviews_monitor                                                │
├─────────────────────────────────────────────────────────────────────┤
│ EMAIL MARKETING (4)                                                │
│   • newsletter_send   • email_templates                           │
│   • email_tracking    • email_drip                                │
│   (Postfix SMTP local)                                             │
├─────────────────────────────────────────────────────────────────────┤
│ CÓDIGO (3)                                                         │
│   • code_execute (sandbox) • git_commit   • repo_read             │
├─────────────────────────────────────────────────────────────────────┤
│ PRODUCTIVIDAD (2)                                                  │
│   • reminders (cron + canales) • tasks (Sistema)                  │
├─────────────────────────────────────────────────────────────────────┤
│ GOOGLE WORKSPACE (1 adicional)                                     │
│   • directions (Google Maps API — nuestra key)                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3️⃣ SKILLS BUNDLES POR TIPO DE NEGOCIO

### 3.1 Bundle: RESTAURANTE

```json
{
  "bundle": "restaurante",
  "version": "1.0.0",
  "skills": [
    {
      "id": "menu_parse",
      "name": "Menú Digital",
      "description": "Mostrar menú, precios, recomendar platos",
      "intents": ["menú", "carta", "platos", "comida", "¿qué tienen?", "precios"],
      "responses": {
        "default": "Nuestro menú incluye: {menu_items}. ¿Te gustaría que te recomiende algo?",
        "price": "{item} cuesta {price}. ¿Deseas agregarlo a tu orden?"
      },
      "requires": ["pdf_read", "extract_data", "summarize"]
    },
    {
      "id": "reservations",
      "name": "Reservaciones",
      "description": "Gestionar reservaciones de mesas",
      "intents": ["reservar", "mesa", "reservación", "disponibilidad", "para cuántos"],
      "responses": {
        "available": "¡Perfecto! Tenemos disponibilidad para {people} personas el {date} a las {time}.",
        "unavailable": "Lo siento, no tenemos disponibilidad para esa fecha. ¿Te gustaría probar otro día?"
      },
      "requires": ["calendar", "form_create"]
    },
    {
      "id": "orders",
      "name": "Pedidos",
      "description": "Tomar pedidos y enviar a cocina",
      "intents": ["pedir", "ordenar", "orden", "quiero", "me trae", "para llevar"],
      "responses": {
        "confirm": "Tu orden incluye: {items}. Total: {total}. ¿Confirmas?",
        "sent": "¡Orden confirmada! Tiempo estimado: {estimated_time} minutos."
      },
      "requires": ["form_create", "pdf_generate"]
    },
    {
      "id": "hours",
      "name": "Horarios",
      "description": "Informar horarios de atención",
      "intents": ["horarios", "horario", "¿a qué hora?", "¿cuándo abren?", "¿cuándo cierran?"],
      "responses": {
        "default": "Nuestros horarios son: {hours}. ¿Necesitas algo más?"
      },
      "requires": []
    },
    {
      "id": "delivery",
      "name": "Delivery",
      "description": "Gestionar órdenes de delivery",
      "intents": ["delivery", "domicilio", "llevar", "a domicilio", "envío", "dirección"],
      "responses": {
        "zones": "Hacemos delivery a: {zones}. Costo de envío: {delivery_cost}.",
        "eta": "Tiempo estimado de entrega: {eta} minutos."
      },
      "requires": ["location", "directions", "form_create"]
    },
    {
      "id": "faq",
      "name": "Preguntas Frecuentes",
      "description": "Responder preguntas comunes",
      "intents": ["¿tienen?", "¿aceptan?", "¿puedo?", "estacionamiento", "niños", "mascotas"],
      "requires": ["extract_data"]
    },
    {
      "id": "contact",
      "name": "Contacto",
      "description": "Información de contacto",
      "intents": ["teléfono", "dirección", "ubicación", "contacto", "¿dónde están?"],
      "requires": ["location", "directions"]
    }
  ],
  "total_skills": 7,
  "dependencies_builtin": ["email_send", "pdf_generate", "calendar", "form_create", "location", "directions"]
}
```

### 3.2 Bundle: HOTEL

```json
{
  "bundle": "hotel",
  "version": "1.0.0",
  "skills": [
    {
      "id": "reservations",
      "name": "Reservaciones",
      "description": "Gestionar reservaciones de habitaciones",
      "intents": ["reservar", "habitación", "reservación", "disponibilidad", "noches"],
      "responses": {
        "available": "Tenemos disponibilidad para {nights} noches en {room_type}. Precio: {price}/noche.",
        "unavailable": "Lo siento, no tenemos disponibilidad para esas fechas."
      },
      "requires": ["calendar", "form_create"]
    },
    {
      "id": "availability",
      "name": "Disponibilidad",
      "description": "Consultar disponibilidad en tiempo real",
      "intents": ["¿hay disponibilidad?", "¿cuánto cuesta?", "¿tienen habitaciones?"],
      "requires": ["calendar"]
    },
    {
      "id": "rooms",
      "name": "Habitaciones",
      "description": "Describir habitaciones y servicios",
      "intents": ["habitaciones", "tipos", "suites", "servicios", "¿qué incluyen?"],
      "responses": {
        "describe": "Nuestras habitaciones {room_type} incluyen: {amenities}.",
        "amenities": "Servicios del hotel: {services_list}."
      },
      "requires": ["pdf_read", "summarize"]
    },
    {
      "id": "faq",
      "name": "Preguntas Frecuentes",
      "description": "Responder preguntas comunes de huéspedes",
      "intents": ["check-in", "check-out", "wifi", "estacionamiento", "desayuno", "piscina"],
      "requires": ["extract_data"]
    },
    {
      "id": "contact",
      "name": "Contacto",
      "description": "Información del hotel",
      "intents": ["teléfono", "dirección", "ubicación", "contacto"],
      "requires": ["location", "directions"]
    },
    {
      "id": "hours",
      "name": "Horarios",
      "description": "Horarios de servicios",
      "intents": ["horarios", "¿a qué hora?", "recepción", "spa", "restaurante"],
      "requires": []
    }
  ],
  "total_skills": 6,
  "dependencies_builtin": ["email_send", "calendar", "form_create", "location", "directions", "pdf_generate"]
}
```

### 3.3 Bundle: TIENDA/RETAIL

```json
{
  "bundle": "tienda",
  "version": "1.0.0",
  "skills": [
    {
      "id": "inventory",
      "name": "Inventario",
      "description": "Consultar disponibilidad de productos",
      "intents": ["¿tienen?", "stock", "disponibilidad", "¿hay?"],
      "responses": {
        "available": "Sí, tenemos {product} en stock. Cantidad: {quantity}.",
        "unavailable": "Lo siento, {product} está agotado. ¿Te gustaría que te avisemos cuando vuelva?"
      },
      "requires": ["excel_read", "extract_data"]
    },
    {
      "id": "products",
      "name": "Productos",
      "description": "Buscar y recomendar productos",
      "intents": ["productos", "¿qué tienen?", "catálogo", "buscar", "recomendación"],
      "responses": {
        "search": "Encontré {count} productos: {products_list}.",
        "recommend": "Te recomiendo {product} por {reason}."
      },
      "requires": ["summarize", "sentiment"]
    },
    {
      "id": "orders",
      "name": "Pedidos",
      "description": "Gestionar carrito y checkout",
      "intents": ["pedir", "comprar", "checkout", "carrito", "agregar"],
      "responses": {
        "cart": "Tu carrito tiene {items}. Total: {total}.",
        "checkout": "Pedido confirmado. Número de orden: {order_number}."
      },
      "requires": ["form_create", "pdf_generate"]
    },
    {
      "id": "payments",
      "name": "Pagos",
      "description": "Métodos de pago y facturación",
      "intents": ["pagar", "métodos de pago", "tarjeta", "efectivo", "factura"],
      "responses": {
        "methods": "Aceptamos: {payment_methods}.",
        "invoice": "Tu factura está lista. Enviando a {email}."
      },
      "requires": ["invoice_generate", "email_send"]
    },
    {
      "id": "promotions",
      "name": "Promociones",
      "description": "Descuentos y ofertas activas",
      "intents": ["promociones", "descuentos", "ofertas", "cupones"],
      "requires": ["pdf_read"]
    },
    {
      "id": "faq",
      "name": "Preguntas Frecuentes",
      "description": "FAQ de la tienda",
      "intents": ["devoluciones", "garantía", "envíos", "horario"],
      "requires": ["extract_data"]
    },
    {
      "id": "contact",
      "name": "Contacto",
      "description": "Información de contacto",
      "intents": ["teléfono", "dirección", "ubicación", "whatsapp"],
      "requires": ["location"]
    }
  ],
  "total_skills": 7,
  "dependencies_builtin": ["email_send", "pdf_generate", "excel_read", "form_create", "location"]
}
```

### 3.4 Bundle: SERVICIOS PROFESIONALES

```json
{
  "bundle": "servicios",
  "version": "1.0.0",
  "skills": [
    {
      "id": "appointments",
      "name": "Citas",
      "description": "Agendar y gestionar citas",
      "intents": ["cita", "agendar", "reservar", "consulta", "disponibilidad"],
      "responses": {
        "available": "Tenemos disponibilidad el {date} a las {time}. ¿Confirmas?",
        "confirm": "Cita confirmada para {date} a las {time} con {professional}."
      },
      "requires": ["calendar", "form_create"]
    },
    {
      "id": "calendar",
      "name": "Calendario",
      "description": "Consultar disponibilidad del profesional",
      "intents": ["calendario", "horarios", "¿cuándo puedes?", "disponibilidad"],
      "requires": ["calendar"]
    },
    {
      "id": "reminders",
      "name": "Recordatorios",
      "description": "Enviar recordatorios de citas",
      "intents": ["recordar", "recordatorio", "avisame", "no olvides"],
      "responses": {
        "set": "Recordatorio configurado para {date}. Te avisaré {hours_before} horas antes."
      },
      "requires": ["cron", "sms_send", "email_send", "reminders"]
    },
    {
      "id": "followup",
      "name": "Seguimiento",
      "description": "Seguimiento post-servicio",
      "intents": ["seguimiento", "¿cómo quedó?", "resultado"],
      "requires": ["email_send", "form_create"]
    },
    {
      "id": "faq",
      "name": "Preguntas Frecuentes",
      "description": "FAQ del servicio",
      "intents": ["precios", "duración", "proceso", "requisitos"],
      "requires": ["extract_data"]
    },
    {
      "id": "contact",
      "name": "Contacto",
      "description": "Información de contacto",
      "intents": ["teléfono", "email", "ubicación", "whatsapp"],
      "requires": ["location"]
    }
  ],
  "total_skills": 6,
  "dependencies_builtin": ["email_send", "calendar", "form_create", "cron", "sms_send", "reminders"]
}
```

### 3.5 Bundle: GENÉRICO

```json
{
  "bundle": "generico",
  "version": "1.0.0",
  "skills": [
    {
      "id": "faq",
      "name": "Preguntas Frecuentes",
      "description": "Responder preguntas frecuentes del negocio",
      "intents": ["¿qué?", "¿cómo?", "¿cuándo?", "¿dónde?", "¿por qué?"],
      "requires": ["extract_data", "pdf_read"]
    },
    {
      "id": "contact",
      "name": "Contacto",
      "description": "Proporcionar información de contacto",
      "intents": ["contacto", "teléfono", "email", "whatsapp", "ubicación", "dirección"],
      "requires": ["location"]
    },
    {
      "id": "hours",
      "name": "Horarios",
      "description": "Informar horarios de atención",
      "intents": ["horarios", "horario", "¿a qué hora?", "¿cuándo abren?", "¿cuándo cierran?"],
      "requires": []
    },
    {
      "id": "location",
      "name": "Ubicación",
      "description": "Mostrar ubicación y mapa",
      "intents": ["ubicación", "¿dónde están?", "dirección", "mapa", "llegar"],
      "requires": ["location", "directions"]
    },
    {
      "id": "general",
      "name": "Consultas Generales",
      "description": "Responder consultas generales",
      "intents": ["hola", "buenos días", "información", "ayuda", "necesito"],
      "requires": ["summarize"]
    }
  ],
  "total_skills": 5,
  "dependencies_builtin": ["location", "directions", "pdf_read", "extract_data"]
}
```

---

## 4️⃣ ORGANIZACIÓN EN OPENCLAW

### Estructura de Archivos

```
~/.openclaw/
├── config/
│   ├── skills-builtin.json     # 58 habilidades BUILT-IN (todas funcionan)
│   ├── skills-bundle.json      # Bundle seleccionado según negocio
│   ├── automatizaciones-builtin.json  # 20 automatizaciones
│   └── SKILLS.md               # Documentación completa
│
├── knowledge/
│   ├── menu/                   # Menú (para restaurantes)
│   │   └── menu.pdf
│   ├── products/               # Productos (para tiendas)
│   │   └── catalog.xlsx
│   ├── services/               # Servicios (para profesionales)
│   │   └── services.pdf
│   └── faq/                    # FAQ común
│       └── faq.json
│
└── prompts/
    ├── restaurante/
    │   ├── menu_parse.txt
    │   ├── reservations.txt
    │   └── orders.txt
    ├── hotel/
    │   ├── reservations.txt
    │   └── rooms.txt
    ├── tienda/
    │   ├── inventory.txt
    │   └── orders.txt
    ├── servicios/
    │   ├── appointments.txt
    │   └── reminders.txt
    └── generico/
        ├── faq.txt
        └── contact.txt
```

### Configuración en openclaw.json

```json
{
  "skills": {
    "builtin": {
      "enabled": true,
      "source": "config/skills-builtin.json",
      "total": 58,
      "model": "agente-en-mano"
    },
    "automations": {
      "enabled": true,
      "source": "config/automatizaciones-builtin.json",
      "total": 20
    },
    "bundle": {
      "type": "restaurante",
      "source": "config/skills-bundle.json",
      "skills": ["menu", "reservas", "pedidos", "horarios", "delivery"]
    }
  }
}
```

### Flujo de Activación

```
┌─────────────────────────────────────────────────────────────────────┐
│               FLUJO DE SKILLS — Agente en Mano v2.0                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. SETUP INICIAL                                                   │
│     └── ./setup-skills.sh --agent-name "nombre" --business-type "X" │
│         └── Carga 58 skills BUILT-IN (un solo JSON)                │
│             └── Vincula 20 automatizaciones                        │
│                 └── Selecciona bundle de negocio                   │
│                                                                     │
│  2. KNOWLEDGE PROCESSING                                           │
│     └── Carga documentos del negocio                               │
│         └── Menu (restaurantes)                                    │
│         └── Productos (tiendas)                                    │
│         └── Servicios (profesionales)                              │
│         └── FAQ genérico                                           │
│                                                                     │
│  3. ACTIVACIÓN                                                     │
│     └── TODAS las skills se activan automáticamente                │
│         └── 58 BUILT-IN: Siempre activas                          │
│         └── 20 AUTOMATIONS: Siempre disponibles                   │
│         └── BUNDLE: Activas según tipo de negocio                 │
│                                                                     │
│  4. EJECUCIÓN                                                      │
│     └── Usuario pregunta → Intent detection                        │
│         └── Skill seleccionada → Response generada                │
│             └── Acción ejecutada si aplica                        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 5️⃣ RESUMEN FINAL

### Tabla Comparativa

| Tipo | Cantidad | Configuración | Ejemplos |
|------|----------|---------------|----------|
| **Habilidades Natas** | 14 | Siempre presentes | email, voice, images, translate |
| **Habilidades Built-in** | 58 | Todas funcionan siempre | pdf, video, sms, browser, classify, rewrite |
| **Automatizaciones** | 20 | Pre-configuradas | post_creator, invoice_autopilot, daily_report |
| **Skills Bundle** | 5-7/negocio | Por tipo de negocio | menu, reservations, orders |

### Costo por Agente/mes

| API | Costo/uso | Est. mensual |
|-----|-----------|-------------|
| Ollama Cloud | ∞ tokens | Incluido |
| Stable Diffusion | $0.01/img | ~$5 |
| Deepgram (STT+TTS) | $0.006/min + $3/M | ~$5 |
| Kling 2.1 (fal.ai) | $0.15/5s clip | ~$7 |
| Google APIs | quotas estándar | ~$5 |
| **TOTAL** | | **~$22/mes** |

**Precio sugerido:** $250-400/mes → **Margen 91-94%**

### Diferenciador de Mercado

| Nosotros | Competencia |
|----------|-------------|
| **58 habilidades built-in** | 5-10 básicas |
| **20 automatizaciones** | 0-3 manuales |
| **Documentos completos** | Solo texto |
| **Email enviar + recibir + marketing** | Solo enviar |
| **Video processing + creación** | No disponible |
| **SMS + WhatsApp + Telegram + Discord** | Solo 1-2 canales |
| **Web scraping + búsqueda** | No disponible |
| **Clasificación + reescritura IA** | No disponible |
| **Bundles por negocio** | No disponible |
| **~$22/mes costo real** | $100-500/mes |

---

## 📎 ARCHIVOS RELACIONADOS

| Archivo | Propósito |
|---------|-----------|
| `skills-builtin.json` | 58 habilidades BUILT-IN (único JSON) |
| `automatizaciones-builtin.json` | 20 automatizaciones pre-configuradas |
| `skills-bundle.json` | Bundle según tipo de negocio |
| `SKILLS.md` | Documentación de usuario (generada) |
| `setup-skills.sh` | Script de configuración v2.0 |

---

*Documento actualizado para FASE 4 ÁREA 6 — TURNKEY v6*
*Modelo: v2.0 — Agente en Mano*
*Fecha: 2026-03-07*