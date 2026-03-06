# ACCESOS Y CREDENCIALES - FASE 5: BOT CONFIG

**Versión:** 1.0
**Fecha:** 2026-03-06
**Proyecto:** TURNKEY v6 - FASE 5 (BOT CONFIG)

---

## 📋 RESUMEN EJECUTIVO

Este documento detalla los accesos y credenciales necesarios para configurar un agente OpenClaw en la FASE 5, diferenciando claramente entre lo que **nosotros proveemos** y lo que el **cliente debe configurar**.

---

## 🔐 MODELO DE PROVISIÓN

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ACCESOS DEL AGENTE                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   NOSOTROS PROVEEMOS          │     CLIENTE CONFIGURA               │
│   ─────────────────           │     ─────────────────               │
│   • APIs compartidas          │     • Email del dominio             │
│   • Telegram bot (opcional)   │     • SMTP del dominio              │
│   • Cloudflare tunnel         │     • IMAP del dominio              │
│   • Modelo AI (Ollama Cloud)  │     • Usuario Telegram permitido    │
│                               │     • Grupos Telegram permitidos    │
│                               │     • WhatsApp (si quiere propio)   │
│                               │     • Discord (si quiere propio)    │
│                               │     • Cuentas Google OAuth          │
│                               │     • APIs premium opcionales       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. 📧 EMAIL NATIVO

### 1.1 Domainio: bee-smart.ai

**El dominio pertenece al cliente.** El cliente debe configurar los registros DNS.

### 1.2 Envío de Email (SMTP)

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Servidor SMTP** | CLIENTE | Configurar en su hosting/dominio |
| **Puerto SMTP** | CLIENTE | 587 (STARTTLS) o 465 (SSL) |
| **Usuario SMTP** | CLIENTE | Normalmente el email completo |
| **Contraseña SMTP** | CLIENTE | Crear en panel de hosting |
| **Alternativa: Resend** | NOSOTROS | API compartida disponible |

#### Opción A: SMTP Propio del Cliente

```json
{
  "email": {
    "smtp_server": "mail.bee-smart.ai",  // Cliente configura
    "smtp_port": 587,                      // Cliente configura
    "smtp_user": "bee@bee-smart.ai",       // Cliente configura
    "smtp_password": "PASSWORD_CLIENTE",   // Cliente provee
    "from_name": "Bee",
    "from_email": "bee@bee-smart.ai"
  }
}
```

#### Opción B: Resend (Nosotros Proveemos)

```json
{
  "email": {
    "provider": "resend",
    "api_key": "NOSOTROS_PROVEEMOS",       // Compartido
    "from_email": "bee@bee-smart.ai",       // Cliente verifica SPF/DKIM
    "from_name": "Bee"
  }
}
```

**⚠️ IMPORTANTE:** Si usa Resend, el cliente debe agregar registros SPF/DKIM en su DNS:

```
SPF:   v=spf1 include:_spf.resend.com ~all
DKIM:  resend._domainkey.bee-smart.ai (proporcionamos valor)
```

### 1.3 Recepción de Email (IMAP)

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Servidor IMAP** | CLIENTE | Normalmente mail.dominio.com |
| **Puerto IMAP** | CLIENTE | 993 (SSL) |
| **Usuario IMAP** | CLIENTE | El email completo |
| **Contraseña IMAP** | CLIENTE | Misma que SMTP |

```json
{
  "email_imap": {
    "server": "mail.bee-smart.ai",      // Cliente configura
    "port": 993,                         // SSL
    "user": "bee@bee-smart.ai",          // Cliente configura
    "password": "PASSWORD_CLIENTE",      // Cliente provee
    "folder": "INBOX"
  }
}
```

### 1.4 Checklist Email para Cliente

```
□ Crear cuenta de email bee@bee-smart.ai en hosting
□ Verificar que SMTP funciona (probar con cliente de correo)
□ Verificar que IMAP funciona
□ Si usa Resend: agregar registros SPF/DKIM en DNS
□ Proporcionar credenciales SMTP/IMAP
```

---

## 2. 🤖 TELEGRAM BOT

### 2.1 Bot Token

| Opción | Quién Provee | Notas |
|--------|--------------|-------|
| **Nuevo bot** | NOSOTROS | Creamos via @BotFather |
| **Bot existente del cliente** | CLIENTE | Cliente provee token |

Si creamos el bot:
```
1. Ir a @BotFather
2. /newbot
3. Nombre: "Bee Smart AI"
4. Username: "BeeSmartAI_bot" (o similar)
5. Guardar token
```

### 2.2 Configuración de Acceso

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Bot Token** | VER ARRIBA | Uno u otro |
| **Allowed Users (DM)** | CLIENTE | IDs numéricos de Telegram |
| **Allowed Groups** | CLIENTE | IDs de grupos (con -100) |
| **Webhook URL** | NOSOTROS | Si usamos tunnel |

### 2.3 Template de Configuración

```json
{
  "telegram": {
    "enabled": true,
    "bot_token": "123456789:ABCdef...",        // Nosotros o Cliente
    "dm_policy": "allowlist",
    "allow_from": [
      "1386691674"                               // Cliente provee IDs
    ],
    "group_policy": "allowlist",
    "groups": {
      "-1001234567890": {                        // Cliente provee IDs
        "require_mention": false
      }
    },
    "streaming": "partial"
  }
}
```

### 2.4 Cómo Obtener IDs

**Para Telegram ID personal:**
1. Abrir @userinfobot en Telegram
2. Enviar cualquier mensaje
3. El bot responde con tu ID numérico

**Para Group ID:**
1. Agregar @RawDataBot al grupo
2. El bot publica el ID del grupo (formato: -100XXXXXXXXXX)

### 2.5 Checklist Telegram para Cliente

```
□ Decidir: bot nuevo o existente
□ Si nuevo: nosotros creamos
□ Si existente: proporcionar token
□ Proporcionar Telegram IDs de usuarios permitidos
□ Proporcionar Group IDs si quiere usar en grupos
□ Confirmar si requiere mención (@bot) en grupos
```

---

## 3. 📱 WHATSAPP

### 3.1 Estado Actual

WhatsApp YA está configurado en LOCAL y funciona. El cliente puede:

| Opción | Descripción | Quién Configura |
|--------|-------------|-----------------|
| **A: Usar nuestro número** | Redirigir mensajes al agente del cliente | NOSOTROS |
| **B: Número propio** | El cliente vincula su WhatsApp Business | CLIENTE |

### 3.2 Opción A: Compartir Número (No Recomendado)

No es ideal para producción porque mezcla conversaciones.

### 3.3 Opción B: WhatsApp Business API (Cliente)

El cliente debe:
1. Registrar negocio en Meta Business Suite
2. Configurar WhatsApp Business API
3. Proporcionar credenciales de la API

```json
{
  "whatsapp": {
    "enabled": true,
    "provider": "meta_business",
    "phone_number_id": "CLIENTE_PROVEE",
    "business_account_id": "CLIENTE_PROVEE",
    "access_token": "CLIENTE_PROVEE",
    "webhook_verify_token": "NOSOTROS_GENERAMOS",
    "dm_policy": "allowlist",
    "allow_from": [
      "+50764301378"                           // Cliente provee
    ]
  }
}
```

### 3.4 Requisitos WhatsApp Business API

- Cuenta de Meta Business verificada
- Número de teléfono dedicado
-- App en Meta for Developers
- Webhook accesible públicamente (Cloudflare Tunnel)

### 3.5 Checklist WhatsApp para Cliente

```
□ Decidir: usar número compartido o propio
□ Si propio: registrar en Meta Business
□ Verificar negocio en Meta
□ Configurar WhatsApp Business API
□ Proporcionar credentials de API
□ Proporcionar números permitidos
```

---

## 4. 💬 DISCORD

### 4.1 Estado Actual

Discord YA está configurado en LOCAL con:
- Bot Token: `MTQ3NjcwNjUyMjU0NDIxNDAzNg...`
- Guild ID: `1476646963494653987`
- Usuarios permitidos configurados

### 4.2 Opciones para Cliente

| Opción | Descripción | Quién Configura |
|--------|-------------|-----------------|
| **A: Usar nuestro bot** | Invitar bot existente a su servidor | NOSOTROS + CLIENTE |
| **B: Bot propio** | Crear nuevo bot en Discord Dev Portal | CLIENTE |

### 4.3 Opción A: Usar Bot Existente

```json
{
  "discord": {
    "enabled": true,
    "token": "NUESTRO_BOT_TOKEN",              // Nosotros proveemos
    "guild_policy": "allowlist",
    "guilds": {
      "GUILD_ID_CLIENTE": {                    // Cliente provee
        "require_mention": false,
        "users": ["USER_ID_CLIENTE"]           // Cliente provee
      }
    },
    "dm_policy": "allowlist",
    "allow_from": ["USER_ID_CLIENTE"]          // Cliente provee
  }
}
```

### 4.4 Opción B: Bot Propio del Cliente

1. Ir a Discord Developer Portal
2. Crear nueva aplicación
3. Crear bot y obtener token
4. Invitar bot al servidor con permisos necesarios:
   - `applications.commands`
   - `bot` con: Send Messages, Read Messages, etc.

### 4.5 Cómo Obtener IDs de Discord

**Para User ID:**
1. Activar Modo Desarrollador en Discord (Settings > Advanced)
2. Click derecho en usuario > Copy ID

**Para Guild/Server ID:**
1. Click derecho en nombre del servidor > Copy ID

**Para Channel ID:**
1. Click derecho en canal > Copy ID

### 4.6 Checklist Discord para Cliente

```
□ Decidir: usar bot compartido o crear propio
□ Si bot compartido: aceptar invitación del bot
□ Si bot propio: crear en Discord Dev Portal
□ Proporcionar Guild ID del servidor
□ Proporcionar User IDs permitidos
□ Configurar permisos del bot en el servidor
```

---

## 5. 🔑 APIs COMPARTIDAS (Nosotros Proveemos)

### 5.1 APIs Incluidas

| API | Uso | Límite Mensual | Estado |
|-----|-----|----------------|--------|
| **Resend** | Email outbound | 3,000 emails | ✅ Disponible |
| **PDF.co** | Crear/editar PDFs | 5,000 páginas | ✅ Disponible |
| **Mathpix** | Leer PDFs (OCR) | 1,000 páginas | ✅ Disponible |
| **Mux** | Video processing | 100 videos | ✅ Disponible |
| **Twilio** | SMS outbound | 500 SMS | ✅ Disponible |
| **Oxylabs** | Web scraping | 1,000 requests | ✅ Disponible |
| **Gamma** | Presentaciones | 50 presentaciones | ✅ Disponible |

### 5.2 Configuración de APIs Compartidas

```json
{
  "shared_apis": {
    "resend": {
      "api_key": "re_NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "3000/month"
    },
    "pdf_co": {
      "api_key": "NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "5000/pages/month"
    },
    "mathpix": {
      "api_key": "NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "1000/pages/month"
    },
    "mux": {
      "api_key": "NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "100/videos/month"
    },
    "twilio": {
      "account_sid": "NOSOTROS_PROVEEMOS",
      "auth_token": "NOSOTROS_PROVEEMOS",
      "from_number": "+1XXXYYYZZZZ",
      "provider": "nosotros",
      "limit": "500/sms/month"
    },
    "oxylabs": {
      "api_key": "NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "1000/requests/month"
    },
    "gamma": {
      "api_key": "NOSOTROS_PROVEEMOS",
      "provider": "nosotros",
      "limit": "50/presentations/month"
    }
  }
}
```

### 5.3 Costo de APIs Compartidas

| API | Costo Aprox. |
|-----|--------------|
| Resend | ~$10/mes |
| PDF.co | ~$15/mes |
| Mathpix | ~$10/mes |
| Mux | ~$20/mes |
| Twilio | ~$10/mes |
| Oxylabs | ~$30/mes |
| Gamma | ~$10/mes |
| **TOTAL** | **~$105/mes** |

---

## 6. 🌐 DOMINIOS

### 6.1 bee-smart.ai

| Aspecto | Quién Controla | Notas |
|---------|----------------|-------|
| **Registro del dominio** | CLIENTE | Cliente es dueño |
| **DNS Management** | CLIENTE | Normalmente en Namecheap, GoDaddy, etc. |
| **Email (MX)** | CLIENTE | Configurar para mailbox |
| **SPF/DKIM/DMARC** | CLIENTE + NOSOTROS | Si usa Resend |
| **Subdominios** | CLIENTE | Opcional para tunnel |

### 6.2 Subdominios (Opcional)

| Subdominio | Uso | Quién Configura |
|------------|-----|-----------------|
| `bee.bee-smart.ai` | Cloudflare Tunnel | CLIENTE apunta, NOSOTROS tunelamos |
| `api.bee-smart.ai` | API pública (opcional) | CLIENTE |

### 6.3 Registros DNS Requeridos

**Para Email Propio:**
```
MX      bee-smart.ai    mail.bee-smart.ai    Prioridad: 10
A       mail.bee-smart.ai    IP_DEL_SERVIDOR
```

**Para Resend:**
```
TXT     bee-smart.ai    "v=spf1 include:_spf.resend.com ~all"
TXT     resend._domainkey.bee-smart.ai    "VALOR_DE_RESEND"
TXT     _dmarc.bee-smart.ai    "v=DMARC1; p=none; rua=mailto:admin@bee-smart.ai"
```

**Para Cloudflare Tunnel:**
```
CNAME   bee.bee-smart.ai    ID_TUNEL.cfargotunnel.com
```

### 6.4 Checklist Dominio para Cliente

```
□ Verificar que es dueño del dominio
□ Acceder al panel de DNS
□ Crear mailbox bee@bee-smart.ai (o el email deseado)
□ Configurar MX records si usa email propio
□ Si usa Resend: agregar SPF/DKIM
□ Si quiere tunnel: crear CNAME para subdominio
```

---

## 7. 🚇 CLOUDFLARE TUNNEL (Opcional)

### 7.1 Qué es

Cloudflare Tunnel permite exponer el agente públicamente sin abrir puertos en el firewall.

**Beneficios:**
- Sin IP pública necesaria
- HTTPS automático
- Protección DDoS de Cloudflare

### 7.2 Quién Provee

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Cuenta Cloudflare** | CLIENTE | Gratis o Pro |
| **Dominio en Cloudflare** | CLIENTE | Debe estar agregado |
| **Subdominio (CNAME)** | CLIENTE | bee.bee-smart.ai |
| **Tunnel ID y Token** | NOSOTROS | Instalamos cloudflared |

### 7.3 Configuración

**Cliente hace:**
1. Agregar dominio a Cloudflare (gratis)
2. Ir a Zero Trust > Networks > Tunnels
3. Crear nuevo tunnel
4. Copiar el token del tunnel
5. Crear CNAME: `bee` → `[tunnel-id].cfargotunnel.com`

**Nosotros hacemos:**
1. Instalar cloudflared en el servidor
2. Configurar el tunnel con el token proporcionado
3. Apuntar al puerto del gateway (18789)

```bash
# Instalamos en el servidor
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared
./cloudflared tunnel run --token TOKEN_DEL_CLIENTE
```

### 7.4 Template de Configuración

```json
{
  "cloudflare_tunnel": {
    "enabled": true,
    "tunnel_token": "CLIENTE_PROVEE_DE_CLOUDFLARE",
    "subdomain": "bee",
    "domain": "bee-smart.ai",
    "target": "http://localhost:18789"
  }
}
```

### 7.5 Checklist Cloudflare Tunnel para Cliente

```
□ Crear cuenta en Cloudflare (gratis)
□ Agregar dominio bee-smart.ai a Cloudflare
□ Ir a Zero Trust > Networks > Tunnels
□ Crear tunnel llamado "bee-agent"
□ Copiar el token del tunnel
□ Crear DNS: bee.bee-smart.ai apuntando al tunnel
□ Proporcionar el token del tunnel
```

---

## 8. 🤖 MODELO AI (Ollama Cloud)

### 8.1 Provisión

| Aspecto | Quién Provee | Notas |
|---------|--------------|-------|
| **Ollama Cloud API** | NOSOTROS | API key nuestra |
| **Modelo primario** | CONFIGURABLE | glm-5, kimi-k2.5, etc. |
| **Modelos fallback** | CONFIGURABLE | qwen3.5:397b, etc. |

### 8.2 Modelos Disponibles

| Modelo | Contexto | Razón | Uso |
|--------|----------|-------|-----|
| `glm-5` | 131K | Sí | Default, razonamiento fuerte |
| `kimi-k2.5` | 131K | No | Alternativa balanceada |
| `deepseek-v3.2` | 131K | Sí | Razonamiento profundo |
| `qwen3.5:397b` | 131K | No | Rápido, codificación |
| `minimax-m2.5` | 131K | No | Alternativa |
| `qwen3-vl:235b` | 131K | No | Visión (imágenes) |

### 8.3 Configuración

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollamacloud/glm-5",
        "fallbacks": [
          "ollamacloud/kimi-k2.5",
          "ollamacloud/qwen3.5:397b"
        ]
      }
    }
  },
  "models": {
    "providers": {
      "ollamacloud": {
        "baseUrl": "https://ollama.com/v1",
        "apiKey": "OLLAMA_CLOUD_KEY_NOSOTROS_PROVEEMOS"
      }
    }
  }
}
```

---

## 9. 📊 RESUMEN FINAL - CHECKLIST CLIENTE

### Credenciales que el CLIENTE DEBE Proveer

| # | Credencial | Obligatorio | Para |
|---|------------|-------------|------|
| 1 | Email del agente | ✅ SÍ | Identidad |
| 2 | SMTP server/user/password | ✅ SÍ | Email outbound |
| 3 | IMAP server/user/password | ✅ SÍ | Email inbound |
| 4 | Telegram IDs permitidos | ✅ SÍ | DM policy |
| 5 | Group IDs (si usa grupos) | ⬜ No | Grupos |
| 6 | WhatsApp credentials | ⬜ No | WhatsApp propio |
| 7 | Discord Guild/User IDs | ⬜ No | Discord |
| 8 | Dominio DNS access | ✅ SÍ | Email + Tunnel |
| 9 | Cloudflare tunnel token | ⬜ No | Acceso público |

### Lo que NOSOTROS PROVEEMOS

| # | Servicio | Notas |
|---|----------|-------|
| 1 | Ollama Cloud API Key | Modelo AI |
| 2 | Resend API (opcional) | Email alternativo |
| 3 | PDF.co API | Documentos |
| 4 | Mathpix API | OCR |
| 5 | Mux API | Video |
| 6 | Twilio API | SMS |
| 7 | Oxylabs API | Scraping |
| 8 | Gamma API | Presentaciones |
| 9 | Telegram bot (opcional) | Si creamos nuevo |
| 10 | Discord bot (opcional) | Si usa el nuestro |
| 11 | Cloudflare tunnel setup | Instalamos y configuramos |

---

## 10. 📝 FORMULARIO PARA CLIENTE

```
═══════════════════════════════════════════════════════════════════
                    FORMULARIO DE CREDENCIALES - FASE 5
═══════════════════════════════════════════════════════════════════

DATOS DEL AGENTE
────────────────
Nombre del agente: ____________________________________
Email del agente: _____________________________________
Personalidad: _________________________________________
Idioma: _______________________________________________

EMAIL (SMTP/IMAP)
─────────────────
Servidor SMTP: ________________________________________
Puerto SMTP: __________________________________________
Usuario SMTP: _________________________________________
Contraseña SMTP: ______________________________________
Servidor IMAP: ________________________________________
Puerto IMAP: __________________________________________
Usar Resend (Sí/No): __________________________________

TELEGRAM
────────
□ Crear bot nuevo (nosotros lo creamos)
□ Usar bot existente:

Bot Token (si existente): ______________________________
Bot Username: _________________________________________
IDs de usuarios permitidos: ____________________________
IDs de grupos permitidos: ______________________________
¿Requiere mención en grupos? (Sí/No): __________________

WHATSAPP (Opcional)
───────────────────
□ Usar número compartido (no recomendado)
□ Configurar propio:

Phone Number ID: ______________________________________
Business Account ID: __________________________________
Access Token: _________________________________________
Números permitidos: ___________________________________

DISCORD (Opcional)
──────────────────
□ Usar bot compartido
□ Crear bot propio:

Bot Token (si propio): _________________________________
Guild/Server ID: ______________________________________
User IDs permitidos: __________________________________

DOMINIO
───────
Registrador DNS: ______________________________________
Acceso al panel DNS: _________________________________
¿Usar Cloudflare para tunnel? (Sí/No): ________________
Tunnel token (si aplica): _____________________________

APIS ADICIONALES (Opcionales)
─────────────────────────────
□ OpenAI API Key: ____________________________________
□ DeepL API Key: _____________________________________
□ Google Maps Key: ___________________________________
□ Google OAuth (Calendar/Sheets): _____________________

═══════════════════════════════════════════════════════════════════
```

---

## 11. 🔒 SEGURIDAD Y ALMACENAMIENTO

### 11.1 Credenciales Sensibles

| Tipo | Almacenamiento | Encriptación |
|------|----------------|--------------|
| API Keys | `~/.openclaw/workspace/secrets/` | GPG AES256 |
| Tokens OAuth | `secrets/*.json` | GPG AES256 |
| SMTP Passwords | `secrets/email_credentials.json` | GPG AES256 |
| Bot Tokens | `openclaw.json` | Permisos 600 |

### 11.2 Backup de Credenciales

- Backup automático cada 12 horas
- Ubicación: `~/backups/secrets-encrypted/`
- Retención: 7 días

### 11.3 Acceso a Credenciales

Solo el usuario `lumen` tiene acceso a los archivos de secrets.

---

## APÉNDICE A: Configuración Actual LOCAL

### Email
```json
{
  "email": "lumen.ai17@gmail.com",
  "app_password": "nkvt caxr uqrj mbia",
  "smtp_server": "smtp.gmail.com",
  "smtp_port": 587,
  "imap_server": "imap.gmail.com",
  "imap_port": 993
}
```

### Telegram
```json
{
  "bot_token": "YOUR_TELEGRAM_BOT_TOKEN_HERE",
  "bot_name": "@Lumeniabot",
  "user_id": "1386691674"
}
```

### Discord
```json
{
  "token": "MTQ3NjcwNjUyMjU0NDIxNDAzNg...",
  "guild_id": "1476646963494653987",
  "users_allowed": ["1473760780947034295", "1476647996648329246"]
}
```

### WhatsApp
```json
{
  "enabled": true,
  "allow_from": ["+50764301378"],
  "groups": {
    "120363405651159045@g.us": { "requireMention": false },
    "120363424392879100@g.us": { "requireMention": false }
  }
}
```

### Cloudflare
```json
{
  "email": "lumen.ai17@gmail.com",
  "api_key": "51730bd5c4c7dfd10d54d16127eb7a7c950b6",
  "account_id": "d78758101e9abf9c824edbc6230c5486"
}
```

---

*Documento generado: 2026-03-06*
*Versión: 1.0*
*Para: FASE 5 - BOT CONFIG*