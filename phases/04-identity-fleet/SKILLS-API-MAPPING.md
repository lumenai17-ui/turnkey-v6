# SKILLS → API → FALLBACK — Mapa Completo v2.0

**58 skills | Versión:** 2.0.0 | **Fecha:** 2026-03-08

---

## 📌 Resumen por proveedor

| Proveedor | Skills | Costo | Quién provee |
|---|---|---|---|
| Herramientas locales (VPS) | 31 | $0 | NOSOTROS (instaladas) |
| Ollama Cloud (LLM + Vision) | 9 | $0 (∞ tokens) | NOSOTROS (key) |
| Deepgram (voz) | 3 | ~$5/mes | NOSOTROS (key) |
| Stable Diffusion (imágenes) | 2 | ~$5/mes | NOSOTROS (key) |
| Kling/fal.ai (video) | 1 | ~$7/mes | NOSOTROS (key) |
| Postfix+Dovecot (email) | 3 | $0 | NOSOTROS (server) |
| Canales (TG/WA/Discord/SMS) | 4 | $0 | Config en setup |
| Google APIs | 4 | ~$5/mes | NOSOTROS (key) + OAuth cliente |
| Brave Search | 1 | $0 | NOSOTROS (key free tier) |
| **TOTAL** | **58** | **~$22/mes** | |

---

## 1. HERRAMIENTAS LOCALES (31 skills — VPS)

> Todas corren en el VPS, costo $0, siempre funcionan. Se instalan en Fase 2.

| # | Skill | Herramienta | Fallback | Instalación | Validación |
|---|---|---|---|---|---|
| 1 | `pdf_generate` | wkhtmltopdf | Puppeteer → PDF | `apt install wkhtmltopdf` | `wkhtmltopdf --version` |
| 2 | `pdf_read` | pdftotext + Tika | Ollama Vision (OCR) | `apt install poppler-utils` | `pdftotext -v` |
| 3 | `pdf_edit` | qpdf + pdftk | — | `apt install qpdf pdftk-java` | `qpdf --version` |
| 4 | `doc_generate` | pandoc | LibreOffice CLI | `apt install pandoc` | `pandoc --version` |
| 5 | `excel_generate` | python openpyxl | — | `pip install openpyxl` | `python3 -c "import openpyxl"` |
| 6 | `excel_read` | python openpyxl | — | `pip install openpyxl` | `python3 -c "import openpyxl"` |
| 7 | `presentation_create` | python-pptx | — | `pip install python-pptx` | `python3 -c "import pptx"` |
| 8 | `invoice_generate` | wkhtmltopdf (HTML→PDF) | — | mismo que #1 | mismo que #1 |
| 9 | `video_edit` | FFmpeg | — | `apt install ffmpeg` | `ffmpeg -version` |
| 10 | `video_process` | FFmpeg + Ollama Vision | — | FFmpeg + Ollama Cloud | `ffmpeg -version` |
| 11 | `browser` | Puppeteer (headless) | Playwright | `npm install puppeteer` | `node -e "require('puppeteer')"` |
| 12 | `scraping` | Puppeteer + cheerio | curl + regex | `npm install cheerio` | `node -e "require('cheerio')"` |
| 13 | `webhook` | Express HTTP server | — | incluido en OpenClaw | test POST a localhost |
| 14 | `cron` | node-cron / systemd | — | incluido en OpenClaw | `systemctl status cron` |
| 15 | `form_create` | HTML + Express | — | incluido | test render form |
| 16 | `web_create` | HTML generator + Tunnel | — | incluido | test URL pública |
| 17 | `web_fetch` | node-fetch / curl | — | incluido | `curl --version` |
| 18 | `qrcode_generate` | qrencode / node-qrcode | — | `apt install qrencode` | `qrencode --version` |
| 19 | `qrcode_read` | zbar / jsQR | Ollama Vision | `apt install zbar-tools` | `zbarimg --version` |
| 20 | `code_execute` | Sandbox (VM/Docker) | shell directo | Docker o firejail | `docker --version` |
| 21 | `git_commit` | git CLI | — | `apt install git` | `git --version` |
| 22 | `repo_read` | git CLI | — | incluido con git | — |
| 23 | `reminders` | cron + canales | — | incluido | — |
| 24 | `tasks` | JSON store local | — | incluido | — |
| 25 | `email_templates` | Handlebars / EJS | — | `npm install handlebars` | — |
| 26 | `email_tracking` | pixel tracker + DB | — | incluido | — |
| 27 | `email_drip` | cron + email_send | — | incluido | — |
| 28 | `metrics_dashboard` | Chart.js + HTML | — | incluido | — |
| 29 | `report_generate` | wkhtmltopdf + Charts | — | mismo que #1 | — |
| 30 | `notifications` | usa canales activos | fallback a email | incluido | — |
| 31 | `reviews_monitor` | scraping + cron | — | incluido | — |

### Resumen de instalación local:

```bash
# APT (sistema)
apt install -y wkhtmltopdf poppler-utils qpdf pdftk-java pandoc \
  ffmpeg git qrencode zbar-tools

# PIP (Python)
pip install openpyxl python-pptx

# NPM (Node)
npm install puppeteer cheerio handlebars node-qrcode
```

---

## 2. OLLAMA CLOUD (9 skills — ∞ tokens)

> Nuestra key. Procesamiento de texto/lenguaje + visión. Sin límite de tokens.

| # | Skill | Modelo primario | Modelo fallback | Costo |
|---|---|---|---|---|
| 32 | `summarize` | gemma3 | llama4 | $0 (incluido) |
| 33 | `translate` | gemma3 | llama4 | $0 |
| 34 | `extract_data` | gemma3 | llama4 | $0 |
| 35 | `sentiment` | gemma3 | llama4 | $0 |
| 36 | `classify` | gemma3 | llama4 | $0 |
| 37 | `rewrite` | gemma3 | llama4 | $0 |
| 38 | `memory_search` | nomic-embed | — | $0 |
| 39 | `image_receive` | qwen3-vl | llama4-vision | $0 |
| 40 | `ocr` | qwen3-vl | pdftotext (local) | $0 |

**API Key:** `OLLAMA_CLOUD_KEY`
**Fallback chain:** gemma3 → llama4 → error

---

## 3. DEEPGRAM (3 skills — ~$5/mes)

> Nuestra key. Voz: speech-to-text y text-to-speech.

| # | Skill | API | Fallback | Costo |
|---|---|---|---|---|
| 41 | `voice_receive` | Deepgram Nova-2 STT | Whisper local (lento) | $0.006/min |
| 42 | `voice_send` | Deepgram Aura TTS | Piper TTS local | $3/M chars |
| 43 | `audio_transcribe` | Deepgram Nova-2 STT | Whisper local | $0.006/min |

**API Key:** `DEEPGRAM_API_KEY`
**Fallback local:** Whisper (STT, ~10x más lento) / Piper (TTS, calidad media)

---

## 4. STABLE DIFFUSION (2 skills — ~$5/mes)

> Nuestra key. Generación y edición de imágenes.

| # | Skill | API | Fallback | Costo |
|---|---|---|---|---|
| 44 | `image_generate` | Stable Diffusion XL | Describe con texto (no genera) | $0.01/img |
| 45 | `image_edit` | SD img2img / inpaint | — | $0.01/img |

**API Key:** `STABLE_DIFFUSION_KEY`
**Sin fallback real** — si SD falla, el agente avisa que no puede generar imágenes.

---

## 5. KLING / FAL.AI (1 skill — ~$7/mes)

> Nuestra key. Generación de video con IA.

| # | Skill | API | Fallback | Costo |
|---|---|---|---|---|
| 46 | `video_create` | Kling 2.1 via fal.ai | FFmpeg slideshow (imágenes) | $0.15/5s |

**API Key:** `FAL_AI_KEY`
**Fallback:** Crear slideshow con FFmpeg (no es video IA, pero funciona como fallback básico)

---

## 6. POSTFIX + DOVECOT (3 skills — $0)

> Nuestro server. Email completamente local.

| # | Skill | Herramienta | Fallback | Costo |
|---|---|---|---|---|
| 47 | `email_send` | Postfix SMTP | SMTP del cliente (si configuró) | $0 |
| 48 | `email_read` | Dovecot IMAP | IMAP del cliente | $0 |
| 49 | `newsletter_send` | Postfix batch send | — | $0 |

**Sin API key** — configurado en VPS durante Fase 2.

---

## 7. CANALES (4 skills — config en setup)

| # | Skill | Herramienta | Requiere | Fallback |
|---|---|---|---|---|
| 50 | `sms_send` | Integración SMS local | Config canal | email como fallback |
| 51 | `whatsapp_send` | WhatsApp Web bridge | Número del cliente | Telegram como fallback |
| 52 | `telegram_send` | Telegram Bot API | Bot token (nosotros creamos) | email como fallback |
| 53 | `discord_send` | Discord.js | Bot token (cliente provee) | email como fallback |

**Fallback universal de canales:** Si un canal falla → intentar email → log error.

---

## 8. GOOGLE APIS (4 skills — ~$5/mes)

| # | Skill | API | Requiere | Costo |
|---|---|---|---|---|
| 54 | `calendar` | Google Calendar API | OAuth (cuenta Google cliente) | ~$0 |
| 55 | `sheets` | Google Sheets API | OAuth (misma cuenta) | ~$0 |
| 56 | `location` | Google Maps API | Nuestra key | ~$5/mes |
| 57 | `directions` | Google Directions API | Nuestra key | incluido en Maps |

**API Keys nuestras:** `GOOGLE_MAPS_KEY`
**OAuth del cliente:** Nosotros configuramos, cliente solo acepta permisos.

---

## 9. BRAVE SEARCH (1 skill — $0)

| # | Skill | API | Fallback | Costo |
|---|---|---|---|---|
| 58 | `web_search` | Brave Search API | DuckDuckGo scraping | $0 (2K búsquedas/mes) |

**API Key:** `BRAVE_SEARCH_KEY`

---

## ✅ Checklist de provisión por agente

### Nuestras keys (asignar a cada agente):
- [ ] `OLLAMA_CLOUD_KEY` — gemma3, llama4, qwen3-vl, nomic-embed
- [ ] `DEEPGRAM_API_KEY` — Nova STT + Aura TTS
- [ ] `STABLE_DIFFUSION_KEY` — SDXL
- [ ] `FAL_AI_KEY` — Kling 2.1
- [ ] `GOOGLE_MAPS_KEY` — Maps + Directions
- [ ] `BRAVE_SEARCH_KEY` — Search

### Herramientas locales (instalar en VPS):
- [ ] wkhtmltopdf, poppler-utils, qpdf, pdftk-java
- [ ] pandoc, ffmpeg, git, qrencode, zbar-tools
- [ ] openpyxl, python-pptx (Python)
- [ ] puppeteer, cheerio, handlebars, node-qrcode (Node)

### Del cliente (solo si aplica):
- [ ] Cuenta Google → OAuth para Calendar + Sheets
- [ ] WordPress → URL + user + app password
- [ ] Meta Ads → access token + ad account ID
- [ ] Stripe → secret key
- [ ] WhatsApp → número
- [ ] Discord → bot token + guild ID

---

*SKILLS-API-MAPPING v2.0.0 — TURNKEY v6 — 2026-03-08*
