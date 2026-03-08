# FUNCIONALIDADES DEL SUPER AGENTE - TURNKEY v6

**Última actualización:** 2026-03-07
**Versión:** 2.0.0 — Agente en Mano
**Reglas:**
- 🎬 Multimedia → APIs externas (más baratas con ≥⭐⭐⭐)
- ⚙️ Documentos, email, scraping → Local en VPS
- ☁️ Inteligencia → Ollama Cloud (∞ tokens)
- 📧 Email desde nuestro dominio
- 🔗 Google Workspace → built-in (nosotros configuramos)

---

## ✅ FUNCIONAN SIEMPRE (58 skills built-in)

### 📱 COMUNICACIÓN (9)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 1 | Enviar Email | email_send | ⚙️ Local (Postfix — nuestro dominio) | ✅ |
| 2 | Recibir Email | email_read | ⚙️ Local (Dovecot IMAP — nuestro dominio) | ✅ |
| 3 | Enviar SMS | sms_send | OpenClaw Sistema | ✅ |
| 4 | Enviar WhatsApp | whatsapp_send | OpenClaw Sistema | ✅ |
| 5 | Enviar Telegram | telegram_send | OpenClaw Sistema | ✅ |
| 6 | Enviar Discord | discord_send | OpenClaw Sistema | ✅ |
| 7 | Escuchar voicenotes | voice_receive | 🎬 Deepgram Nova STT ($0.006/min) | ✅ |
| 8 | Enviar voicenotes | voice_send | 🎬 Deepgram Aura TTS ($3/M chars) | ✅ |
| 9 | Transcribir audio | audio_transcribe | 🎬 Deepgram Nova STT ($0.006/min) | ✅ |

### 🖼️ MULTIMEDIA (7)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 10 | Analizar imagen | image_receive | ☁️ Ollama Cloud Vision | ✅ |
| 11 | Crear imagen | image_generate | 🎬 Stable Diffusion API ($0.01/img) | ✅ |
| 12 | Editar imagen | image_edit | 🎬 Stable Diffusion img2img ($0.01/img) | ✅ |
| 13 | Procesar video | video_process | ☁️ Ollama Cloud | ✅ |
| 14 | Crear video corto | video_create | 🎬 Kling 2.1 via fal.ai ($0.15/5s) | ✅ |
| 15 | Editar video | video_edit | ⚙️ Local (FFmpeg) | ✅ |
| 16 | OCR de imágenes | ocr | ☁️ Ollama Cloud Vision | ✅ |

### 📄 DOCUMENTOS (8)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 17 | Crear PDF | pdf_generate | ⚙️ Local (wkhtmltopdf) | ✅ |
| 18 | Leer PDF | pdf_read | ⚙️ Local (pdftotext/Tika) | ✅ |
| 19 | Editar PDF | pdf_edit | ⚙️ Local (qpdf/pdftk) | ✅ |
| 20 | Crear Word | doc_generate | ⚙️ Local (pandoc) | ✅ |
| 21 | Crear Excel | excel_generate | ⚙️ Local (python openpyxl) | ✅ |
| 22 | Leer Excel | excel_read | ⚙️ Local (python openpyxl) | ✅ |
| 23 | Crear presentación | presentation_create | ⚙️ Local (python-pptx) | ✅ |
| 24 | Crear factura | invoice_generate | ⚙️ Local (wkhtmltopdf + templates) | ✅ |

### 🌐 WEB & AUTOMATIZACIÓN (8)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 25 | Navegar web | browser | ⚙️ Local (Puppeteer) | ✅ |
| 26 | Scrapear web | scraping | ⚙️ Local (Puppeteer + cheerio) | ✅ |
| 27 | Búsqueda web | web_search | Brave Search (free tier) | ✅ |
| 28 | Fetch URL | web_fetch | ⚙️ Local (curl/fetch) | ✅ |
| 29 | Crear sitio web | web_create | ⚙️ Local (templates + Cloudflare) | ✅ |
| 30 | Crear formularios | form_create | ⚙️ Local (HTML templates) | ✅ |
| 31 | Tareas programadas | cron | ⚙️ Local (cron/systemd) | ✅ |
| 32 | Webhooks | webhook | ⚙️ Local (HTTP server) | ✅ |

### 🧠 INTELIGENCIA (7)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 33 | Resumir texto | summarize | ☁️ Ollama Cloud | ✅ |
| 34 | Extraer datos | extract_data | ☁️ Ollama Cloud | ✅ |
| 35 | Análisis sentimiento | sentiment | ☁️ Ollama Cloud | ✅ |
| 36 | Traducir | translate | ☁️ Ollama Cloud | ✅ |
| 37 | Memoria persistente | memory_search | ☁️ Ollama Cloud (Nomic Embed) | ✅ |
| 38 | Clasificar textos | classify | ☁️ Ollama Cloud | ✅ |
| 39 | Reescribir textos | rewrite | ☁️ Ollama Cloud | ✅ |

### 📊 NEGOCIO (6)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 40 | Crear reporte | report_generate | ⚙️ Local (wkhtmltopdf) | ✅ |
| 41 | Generar QR | qrcode_generate | ⚙️ Local (qrencode) | ✅ |
| 42 | Leer QR | qrcode_read | ☁️ Ollama Cloud Vision | ✅ |
| 43 | Dashboard métricas | metrics_dashboard | ⚙️ Local (Charts.js + HTML) | ✅ |
| 44 | Notificaciones | notifications | ⚙️ Local (canales existentes) | ✅ |
| 45 | Monitorear reseñas | reviews_monitor | ⚙️ Local (scraping + cron) | ✅ |

### 📨 EMAIL MARKETING (4)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 46 | Newsletter | newsletter_send | ⚙️ Local (Postfix SMTP) | ✅ |
| 47 | Templates email | email_templates | ⚙️ Local (Sistema) | ✅ |
| 48 | Email tracking | email_tracking | ⚙️ Local (webhook + pixel) | ✅ |
| 49 | Email drip | email_drip | ⚙️ Local (cron + SMTP) | ✅ |

### 💻 CÓDIGO (3)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 50 | Ejecutar código | code_execute | ⚙️ Local (sandbox) | ✅ |
| 51 | Git commits | git_commit | ⚙️ Local (git) | ✅ |
| 52 | Leer repos | repo_read | ⚙️ Local (git) | ✅ |

### 📅 PRODUCTIVIDAD (2)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 53 | Recordatorios | reminders | ⚙️ Local (cron + canales) | ✅ |
| 54 | Tareas/pendientes | tasks | ⚙️ Local (Sistema) | ✅ |

### 🔗 GOOGLE WORKSPACE — BUILT-IN (4)

| # | Funcionalidad | Herramienta | Procesamiento | Estado |
|---|---------------|-------------|---------------|--------|
| 55 | Google Calendar | calendar | Google Calendar API (cuenta cliente) | ✅ |
| 56 | Google Sheets | sheets | Google Sheets API (cuenta cliente) | ✅ |
| 57 | Maps/ubicación | location | Google Maps API (nuestra key) | ✅ |
| 58 | Rutas/distancias | directions | Google Maps API (nuestra key) | ✅ |

---

## 📊 RESUMEN

| Categoría | Cantidad | Procesamiento |
|-----------|----------|---------------|
| Comunicación | 9 | Local + Deepgram |
| Multimedia | 7 | SD + Kling + Ollama Cloud |
| Documentos | 8 | 100% Local |
| Web & Auto | 8 | 100% Local |
| Inteligencia | 7 | ☁️ Ollama Cloud |
| Negocio | 6 | Local + Ollama |
| Email Mkt | 4 | 100% Local |
| Código | 3 | 100% Local |
| Productividad | 2 | 100% Local |
| Google WS | 4 | Google APIs |
| **TOTAL** | **58** | — |

---

## 💰 COSTOS POR AGENTE/MES

| API | Costo/uso | Est. mensual |
|-----|-----------|-------------|
| Ollama Cloud | ∞ tokens | Incluido |
| Stable Diffusion | $0.01/img | ~$5 |
| Deepgram (STT+TTS) | $0.006/min + $3/M | ~$5 |
| Kling 2.1 (fal.ai) | $0.15/5s clip | ~$7 |
| Google APIs | quotas estándar | ~$5 |
| **TOTAL** | | **~$22/mes** |

**Precio sugerido:** $250-400/mes → **Margen 91-94%**

---

*Versión 2.0.0 — Agente en Mano aprobado 2026-03-07*