# HABILIDADES DE SUPER AGENTE — TURNKEY v6

**Versión:** 2.0.0 — Agente en Mano
**Fecha:** 2026-03-07
**Filosofía:** TODO built-in, NADA que configurar
**Regla de costos:** Proveedor más barato con calidad ≥ ⭐⭐⭐

---

## 🎯 ARQUITECTURA DE PROCESAMIENTO

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CAPAS DE PROCESAMIENTO                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  🎬 APIs MULTIMEDIA (~$17/mes)                                       │
│  ├── Stable Diffusion API → imágenes ($0.01/img)                    │
│  ├── Deepgram → voz STT+TTS ($0.006/min + $3/M chars)             │
│  └── Kling 2.1 via fal.ai → video ($0.15/5s clip)                  │
│                                                                       │
│  ☁️ OLLAMA CLOUD (∞ tokens, incluido)                                │
│  ├── LLM → summarize, translate, sentiment, classify, rewrite      │
│  ├── Vision → image_receive, ocr, qrcode_read                      │
│  └── Embeddings → memory_search (Nomic Embed)                      │
│                                                                       │
│  ⚙️ VPS LOCAL ($0)                                                   │
│  ├── Documentos → wkhtmltopdf, pdftotext, pandoc, openpyxl         │
│  ├── Email → Postfix + Dovecot (nuestro dominio)                    │
│  ├── Web → Puppeteer, Cloudflare Tunnel                             │
│  └── Sistema → cron, systemd, FFmpeg, git                           │
│                                                                       │
│  🔗 GOOGLE APIS (~$5/mes)                                            │
│  ├── Calendar → cuenta del cliente (nosotros configuramos)          │
│  ├── Sheets → cuenta del cliente (nosotros configuramos)            │
│  └── Maps → nuestra key                                             │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📋 58 SKILLS — LISTA COMPLETA

### 🎬 Multimedia — APIs externas (16 skills)

| # | Skill | Función | API | $/uso |
|---|-------|---------|-----|-------|
| 7 | voice_receive | Escuchar voicenotes | Deepgram Nova STT | $0.006/min |
| 8 | voice_send | Crear voicenotes | Deepgram Aura TTS | $3/M chars |
| 9 | audio_transcribe | Transcribir audio | Deepgram Nova STT | $0.006/min |
| 11 | image_generate | Crear imágenes | Stable Diffusion API | $0.01/img |
| 12 | image_edit | Editar imágenes | Stable Diffusion img2img | $0.01/img |
| 14 | video_create | Crear videos cortos | Kling 2.1 via fal.ai | $0.15/5s |

### ☁️ Ollama Cloud — ∞ tokens (10 skills)

| # | Skill | Función | Modelo |
|---|-------|---------|--------|
| 10 | image_receive | Analizar imágenes | qwen3-vl |
| 13 | video_process | Analizar video | qwen3-vl |
| 16 | ocr | OCR de imágenes | qwen3-vl |
| 33 | summarize | Resumir contenido | gemma3 / llama4 |
| 34 | extract_data | Extraer datos | gemma3 / llama4 |
| 35 | sentiment | Análisis sentimiento | gemma3 / llama4 |
| 36 | translate | Traducir idiomas | gemma3 / llama4 |
| 37 | memory_search | Memoria persistente | nomic-embed |
| 38 | classify | Clasificar textos | gemma3 / llama4 |
| 39 | rewrite | Reescribir textos | gemma3 / llama4 |

### ⚙️ VPS Local — $0 (38 skills)

| # | Skill | Función | Herramienta local |
|---|-------|---------|-------------------|
| 1 | email_send | Enviar email (nuestro dominio) | Postfix SMTP |
| 2 | email_read | Recibir email (nuestro dominio) | Dovecot IMAP |
| 3 | sms_send | Enviar SMS | OpenClaw Sistema |
| 4 | whatsapp_send | Mensajes WhatsApp | OpenClaw Sistema |
| 5 | telegram_send | Mensajes Telegram | OpenClaw Sistema |
| 6 | discord_send | Mensajes Discord | OpenClaw Sistema |
| 15 | video_edit | Editar video | FFmpeg |
| 17 | pdf_generate | Crear PDF | wkhtmltopdf |
| 18 | pdf_read | Leer PDF | pdftotext / Tika |
| 19 | pdf_edit | Editar PDF | qpdf / pdftk |
| 20 | doc_generate | Crear Word | pandoc |
| 21 | excel_generate | Crear Excel | python openpyxl |
| 22 | excel_read | Leer Excel | python openpyxl |
| 23 | presentation_create | Crear PPT | python-pptx |
| 24 | invoice_generate | Crear factura | wkhtmltopdf + templates |
| 25 | browser | Navegar web | Puppeteer |
| 26 | scraping | Scrapear web | Puppeteer + cheerio |
| 27 | web_search | Buscar internet | Brave Search (free tier) |
| 28 | web_fetch | Fetch URL | curl / fetch |
| 29 | web_create | Crear sitios | Templates + Cloudflare |
| 30 | form_create | Crear formularios | HTML templates |
| 31 | cron | Tareas programadas | cron / systemd |
| 32 | webhook | Webhooks | HTTP server |
| 40 | report_generate | Crear reportes | wkhtmltopdf |
| 41 | qrcode_generate | Generar QR | qrencode |
| 42 | qrcode_read | Leer QR | Ollama Vision |
| 43 | metrics_dashboard | Dashboard métricas | Charts.js + HTML |
| 44 | notifications | Notificaciones | Canales existentes |
| 45 | reviews_monitor | Monitor reseñas | scraping + cron |
| 46 | newsletter_send | Enviar newsletter | Postfix SMTP |
| 47 | email_templates | Templates email | Sistema |
| 48 | email_tracking | Email tracking | webhook + pixel |
| 49 | email_drip | Campañas drip | cron + SMTP |
| 50 | code_execute | Ejecutar código | sandbox |
| 51 | git_commit | Git commits | git |
| 52 | repo_read | Leer repos | git |
| 53 | reminders | Recordatorios | cron + canales |
| 54 | tasks | Lista tareas | Sistema |

### 🔗 Google APIs — Built-in (4 skills)

| # | Skill | Función | API |
|---|-------|---------|-----|
| 55 | calendar | Google Calendar | Cuenta cliente (nosotros config) |
| 56 | sheets | Google Sheets | Cuenta cliente (nosotros config) |
| 57 | location | Maps/ubicación | Nuestra key |
| 58 | directions | Rutas/distancias | Nuestra key |

---

## 💰 MODELO DE COSTOS v2.0

| Capa | APIs | Est. mensual |
|------|------|-------------|
| 🎬 Multimedia | SD + Deepgram + Kling | ~$17 |
| 🔗 Google | Calendar + Sheets + Maps | ~$5 |
| ☁️ Ollama Cloud | ∞ tokens | Incluido |
| ⚙️ VPS Local | 38 skills | $0 |
| **TOTAL** | | **~$22/mes** |

**Precio al cliente:** $250-400/mes → **Margen 91-94%**

---

## 🔄 PROVEEDORES INTERCAMBIABLES

Cada skill multimedia puede cambiar de proveedor editando la config:

```json
{
  "providers": {
    "image_generate": {
      "primary": "stable-diffusion",
      "alternatives": ["dalle3", "flux-pro", "midjourney"],
      "cost_per_use": 0.01
    },
    "voice_stt": {
      "primary": "deepgram-nova",
      "alternatives": ["whisper-api", "assemblyai", "google-stt"],
      "cost_per_min": 0.006
    },
    "voice_tts": {
      "primary": "deepgram-aura",
      "alternatives": ["openai-tts", "elevenlabs", "amazon-polly"],
      "cost_per_m_chars": 3.0
    },
    "video_create": {
      "primary": "kling-2.1",
      "alternatives": ["runway-gen4", "pika", "sora"],
      "cost_per_5s": 0.15
    }
  }
}
```

---

*Super Agente v2.0.0 — 58 skills built-in — Aprobado 2026-03-07*