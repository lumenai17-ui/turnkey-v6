# ACCESOS Y CREDENCIALES — TURNKEY v6

**Versión:** 2.0.0 — Agente en Mano
**Fecha:** 2026-03-07
**⚠️ IMPORTANTE:** Este archivo contiene PLACEHOLDERS. Los valores reales se guardan en `~/.openclaw/secrets/`

---

## 📋 RESUMEN EJECUTIVO

Este documento detalla los accesos y credenciales necesarios para configurar un agente v2.0, diferenciando entre lo que **nosotros proveemos** y lo que el **cliente configura**.

---

## 🔐 MODELO DE PROVISIÓN v2.0

```
┌──────────────────────────────────────────────────────────────────────┐
│                        ACCESOS DEL AGENTE v2.0                       │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   NOSOTROS PROVEEMOS              │     CLIENTE PROVEE (si aplica)   │
│   ──────────────────              │     ────────────────────────     │
│   • Ollama Cloud (∞ tokens)       │     • Cuenta Google (Cal/Sheets) │
│   • Deepgram API key              │     • WordPress credentials      │
│   • Stable Diffusion API key      │     • Meta Ads access token      │
│   • Kling 2.1 via fal.ai key      │     • Stripe secret key          │
│   • Google Maps API key            │     • Telegram User ID           │
│   • Brave Search key               │     • WhatsApp número (si propio)│
│   • Email: Postfix+Dovecot        │     • Discord Token (si propio)  │
│   • Cloudflare Tunnel             │     • Knowledge base docs         │
│   • VPS completo                   │     • Info del negocio           │
│   • Bot de Telegram                │     • Branding (colores, tono)   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 1. ☁️ OLLAMA CLOUD (NOSOTROS)

| Componente | Quién Provee | Modelo |
|---|---|---|
| LLM (texto) | NOSOTROS | gemma3 / llama4 |
| Vision | NOSOTROS | qwen3-vl |
| Embeddings | NOSOTROS | nomic-embed |
| Tokens | ∞ incluidos | — |

```json
{"ollama_cloud": {"api_key": "SECRET_PLACEHOLDER", "base_url": "https://cloud.ollama.ai"}}
```

---

## 2. 🎬 MULTIMEDIA APIS (NOSOTROS)

| API | Quién Provee | Uso | Costo |
|---|---|---|---|
| **Deepgram** | NOSOTROS | STT (voz→texto) + TTS (texto→voz) | $0.006/min + $3/M chars |
| **Stable Diffusion** | NOSOTROS | Generación de imágenes | $0.01/img |
| **Kling 2.1 via fal.ai** | NOSOTROS | Generación de video | $0.15/5s |

```json
{
  "deepgram": {"api_key": "SECRET_PLACEHOLDER"},
  "stable_diffusion": {"api_key": "SECRET_PLACEHOLDER"},
  "fal_ai": {"api_key": "SECRET_PLACEHOLDER"}
}
```

---

## 3. 🔗 GOOGLE APIS

| API | Quién Provee | Configuración |
|---|---|---|
| **Maps** | NOSOTROS (key) | Nuestra key compartida |
| **Calendar** | CLIENTE (cuenta) | Nosotros configuramos OAuth |
| **Sheets** | CLIENTE (cuenta) | Nosotros configuramos OAuth |

### Google Calendar / Sheets — Proceso OAuth:
1. Cliente provee email de Google
2. Nosotros enviamos link de autorización
3. Cliente acepta permisos
4. Queda conectado automáticamente

```json
{
  "google_maps": {"api_key": "SECRET_PLACEHOLDER"},
  "google_calendar": {"client_email": "negocio@gmail.com", "oauth_token": "SECRET_PLACEHOLDER"},
  "google_sheets": {"same_as_calendar": true}
}
```

---

## 4. 🌐 BRAVE SEARCH (NOSOTROS)

| Componente | Quién Provee |
|---|---|
| API Key | NOSOTROS |
| Tier | Free (2,000 búsquedas/mes) |

```json
{"brave_search": {"api_key": "SECRET_PLACEHOLDER"}}
```

---

## 5. 📧 EMAIL (NOSOTROS)

| Componente | Quién Provee | Notas |
|---|---|---|
| **Postfix SMTP** | NOSOTROS | Nuestro server, nuestro dominio |
| **Dovecot IMAP** | NOSOTROS | Nuestro server |
| **Email address** | NOSOTROS | {agente}@nuestro-dominio |

> **Nota v2.0:** Ya no usamos Resend. El email es nativo con Postfix+Dovecot en nuestro VPS.

```json
{
  "email": {
    "provider": "postfix_dovecot",
    "address": "casamahana@nuestro-dominio.ai",
    "smtp": {"host": "mail.nuestro-dominio.ai", "port": 587},
    "imap": {"host": "mail.nuestro-dominio.ai", "port": 993}
  }
}
```

---

## 6. 📱 CANALES DE COMUNICACIÓN

### Telegram
| Quién | Componente |
|---|---|
| NOSOTROS | Creamos el bot con @BotFather |
| CLIENTE | Provee su User ID para allowed_users |

### WhatsApp (opcional)
| Quién | Componente |
|---|---|
| CLIENTE | Provee número de WhatsApp del negocio |
| NOSOTROS | Configuramos la conexión |

### Discord (opcional)
| Quién | Componente |
|---|---|
| CLIENTE | Crea bot en Discord Developer Portal |
| CLIENTE | Provee token + guild ID |

---

## 7. 🔌 INTEGRACIONES EXTERNAS (OPCIONALES — CLIENTE PROVEE)

| Integración | Quién Provee | Qué necesita el cliente |
|---|---|---|
| **WordPress** | CLIENTE | URL + usuario + Application Password |
| **Meta Ads** | CLIENTE | Access token + Ad Account ID |
| **Stripe** | CLIENTE | Secret Key (sk_live_...) |
| **Google My Business** | CLIENTE | Business URL/ID |

---

## 8. 🔒 UBICACIÓN DE SECRETS

| Tipo | Ubicación | Permisos |
|---|---|---|
| API Keys (nuestras) | `~/.openclaw/secrets/api-keys.yaml` | 600 |
| Email config | `~/.openclaw/secrets/email-config.yaml` | 600 |
| Telegram Token | `~/.openclaw/secrets/telegram.yaml` | 600 |
| Google OAuth | `~/.openclaw/secrets/google-oauth.yaml` | 600 |
| Cliente APIs | `~/.openclaw/secrets/client-apis.yaml` | 600 |

**⚠️ NUNCA commitear secrets a Git.**

---

## 9. ❌ APIs ELIMINADAS EN v2.0

Las siguientes APIs de v1.0 ya **NO se usan**:

| API eliminada | Reemplazada por |
|---|---|
| Resend | Postfix+Dovecot (local) |
| PDF.co | pdftotext / qpdf / Tika (local) |
| Mathpix | Ollama Vision qwen3-vl (Ollama Cloud) |
| Twilio | OpenClaw Sistema (local) |
| Mux | FFmpeg (local) |
| Oxylabs | Puppeteer + cheerio (local) |
| Gamma | python-pptx (local) |
| Perplexity | Brave Search free tier |
| Jina AI | nomic-embed via Ollama Cloud |
| OpenAI (DALL-E) | Stable Diffusion API |
| OpenAI (Whisper) | Deepgram Nova STT |
| OpenAI (TTS) | Deepgram Aura TTS |
| DeepL | Ollama Cloud (gemma3/llama4) |
| Runway | Kling 2.1 via fal.ai |
| Suno | Eliminado (no hay skill audio_generate) |

---

*ACCESOS Y CREDENCIALES v2.0.0 — TURNKEY v6 — 2026-03-07*