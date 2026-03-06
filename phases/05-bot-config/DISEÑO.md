# FASE 5: BOT CONFIG - DISEÑO

**Versión:** 1.0.0
**Fecha:** 2026-03-06

---

## 🎯 ARQUITECTURA DE CANALES

```
                    ┌─────────────────┐
                    │   OPENCLAW      │
                    │   GATEWAY       │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │WHATSAPP │         │TELEGRAM │         │ DISCORD │
    │ Channel │         │ Channel │         │ Channel │
    └────┬────┘         └────┬────┘         └────┬────┘
         │                   │                   │
    ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
    │  IMAP   │         │ Bot API │         │ Bot API │
    │ EMAIL   │         │         │         │         │
    └─────────┘         └─────────┘         └─────────┘
```

---

## 📧 EMAIL ARCHITECTURE

### Inbound (Recepción)

```
Usuario → IMAP Server → OpenClaw Gateway → Agente
                              ↓
                        Segunda lectura
                              ↓
                        Procesamiento
```

### Outbound (Envío)

```
Agente → Resend API → Usuario
      ↓
   Fallback
      ↓
   SMTP Server → Usuario
```

### Configuración

```yaml
email:
  inbound:
    protocol: IMAP
    server: imap.bee-smart.ai
    port: 993
    tls: true
    
  outbound:
    primary: Resend
    fallback: SMTP
    server: smtp.bee-smart.ai
    port: 587
    starttls: true
    
  limits:
    daily: 100
    monthly: 3000
```

---

## 💬 TELEGRAM ARCHITECTURE

### Bot Setup

```
BotFather → @nombre_bot → Token
                    ↓
            OpenClaw Gateway
                    ↓
            Webhook Configuration
                    ↓
            Allowed Users Setup
```

### Message Flow

```
Usuario → @bot → Telegram API → Webhook → OpenClaw → Agente
                                                    ↓
Usuario ← @bot ← Telegram API ← Response ←─────────┘
```

### Configuración

```yaml
telegram:
  bot_token: "123456789:ABCdef..."
  webhook_url: "https://gateway.openclaw.ai/telegram/webhook"
  polling: false
  
  allowed_users:
    - 123456789
   
  admin_users:
    - 123456789
   
  commands:
    - start
    - help
    - status
```

---

## 📱 WHATSAPP ARCHITECTURE

### Ya Configurado (LOCAL)

```yaml
whatsapp:
  session: active
  dm_policy: pairing
  
  groups:
    - id: "120363423538780483@g.us"
      name: "Lumens Ai"
      requireMention: false
      
  allowFrom:
    - "+50764301378"
```

### Replicación para Cliente

1. Copiar configuración de LOCAL
2. Actualizar `allowFrom` con número del cliente
3. Actualizar `groups` según cliente requiera
4. Re-escanear QR si es necesario

---

## 🎮 DISCORD ARCHITECTURE

### Ya Configurado (LOCAL)

```yaml
discord:
  token: "BOT_TOKEN"
  streaming: off
  
  guilds:
    - id: "1476646963494653987"
      requireMention: false
      
  allowFrom:
    - "1473760780947034295"
```

### Replicación para Cliente

1. Copiar configuración de LOCAL
2. Actualizar `allowFrom` con IDs del cliente
3. Actualizar `guilds` según cliente requiera

---

## 🔑 APIs SHARED ARCHITECTURE

### Proveemos

```
┌─────────────────────────────────────────────┐
│             APIS COMPARTIDAS                 │
├─────────────────────────────────────────────┤
│                                              │
│  Resend ────────► email_send (3,000/mes)    │
│  PDF.co ────────► pdf_generate (5,000 pág)  │
│  Mathpix ───────► pdf_read (1,000 pág)      │
│  Mux ───────────► video_edit (100 vids)     │
│  Twilio ────────► sms_send (500 SMS)        │
│  Oxylabs ───────► scraping (1,000 req)      │
│  Gamma ─────────► presentations (50/mes)   │
│                                              │
└─────────────────────────────────────────────┘
```

### Opcionales (Cliente)

```
┌─────────────────────────────────────────────┐
│             APIS OPCIONALES                  │
├─────────────────────────────────────────────┤
│                                              │
│  OpenAI ────────► voice_send, image_gen     │
│  DeepL ─────────► translate                  │
│  Google Maps ───► location                    │
│  Google OAuth ──► calendar, sheets           │
│  Suno ──────────► audio_generate             │
│  Runway ────────► video_create               │
│                                              │
└─────────────────────────────────────────────┘
```

---

## 🔒 SECURITY ARCHITECTURE

### Secrets Management

```
~/.openclaw/
├── config/
│   ├── email.yaml          # Config pública
│   ├── telegram.yaml       # Config pública
│   └── api-providers.yaml  # Config pública
│
└── secrets/
    ├── email-secrets.yaml   # Credenciales (600)
    ├── telegram-secrets.yaml # Tokens (600)
    └── api-keys.yaml        # API keys (600)
```

### Permisos

```bash
# Secrets solo lectura para usuario
chmod 600 ~/.openclaw/secrets/*.yaml
```

---

## 📊 VALIDATION FLOW

```
validate-channels.sh
│
├── WhatsApp Check
│   ├── Session active?
│   ├── Groups accessible?
│   └── DM enabled?
│
├── Telegram Check
│   ├── Token valid?
│   ├── Webhook reachable?
│   ├── Users configured?
│   └── Updates received?
│
├── Discord Check
│   ├── Token valid?
│   ├── Guilds accessible?
│   └── Intents enabled?
│
└── Email Check
    ├── IMAP connection?
    ├── SMTP connection?
    ├── Resend API key?
    └── Templates loaded?
```

---

## 📋 CONFIG FILES STRUCTURE

```
phases/05-bot-config/
├── ANALISIS.md
├── DISEÑO.md                    # Este archivo
├── DECISIONES.md
├── ACCESOS-CREDENCIALES-FASE5.md
│
├── config/
│   └── (generados por scripts)
│
├── scripts/
│   ├── setup-email.sh
│   ├── setup-telegram.sh
│   ├── validate-channels.sh
│   └── setup-api-keys.sh
│
├── examples/
│   └── (ejemplos de configuración)
│
└── logs/
    └── (logs de validación)
```

---

## 🔄 DEPLOYMENT PIPELINE

```
1. PREPARATION
   ├── Cliente provee credenciales
   ├── Cliente provee Telegram IDs
   └── Scripts preparados

2. EMAIL SETUP
   ├── setup-email.sh
   ├── Test IMAP
   ├── Test SMTP
   └── Test Resend

3. TELEGRAM SETUP
   ├── setup-telegram.sh
   ├── Create bot
   ├── Configure webhook
   └── Test bot

4. VALIDATION
   ├── validate-channels.sh
   ├── All channels OK?
   └── Generate report

5. OPTIONAL APIs
   ├── setup-api-keys.sh
   └── Configure optional APIs
```

---

*Diseño completado - FASE 5 BOT CONFIG*