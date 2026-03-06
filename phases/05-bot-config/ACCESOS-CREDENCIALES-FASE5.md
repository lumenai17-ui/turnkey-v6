# ACCESOS Y CREDENCIALES - FASE 5: BOT CONFIG

**Versión:** 1.1 (SANITIZADO)
**Fecha:** 2026-03-06
**Proyecto:** TURNKEY v6 - FASE 5 (BOT CONFIG)
**⚠️ IMPORTANTE:** Este archivo contiene PLACEHOLDERS. Los valores reales deben configurarse en `~/.openclaw/secrets/`

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

### 1.1 Dominio: bee-smart.ai

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
    "smtp_server": "mail.tu-dominio.com",  // Cliente configura
    "smtp_port": 587,                       // Cliente configura
    "smtp_user": "agente@tu-dominio.com",   // Cliente configura
    "smtp_password": "PASSWORD_CLIENTE",    // Cliente provee (NO guardar aquí)
    "from_name": "Tu Agente",
    "from_email": "agente@tu-dominio.com"
  }
}
```

#### Opción B: Resend (Nosotros Proveemos)

```json
{
  "email": {
    "provider": "resend",
    "api_key": "SECRET_PLACEHOLDER",       // Ver ~/.openclaw/secrets/api-keys.yaml
    "from_email": "agente@tu-dominio.com", // Cliente verifica SPF/DKIM
    "from_name": "Tu Agente"
  }
}
```

**⚠️ IMPORTANTE:** Si usa Resend, el cliente debe agregar registros SPF/DKIM en su DNS.

### 1.3 Recepción de Email (IMAP)

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Servidor IMAP** | CLIENTE | Normalmente mail.dominio.com |
| **Puerto IMAP** | CLIENTE | 993 (SSL) |
| **Usuario IMAP** | CLIENTE | El email completo |
| **Contraseña IMAP** | CLIENTE | Misma que SMTP |

```json
{
  "imap": {
    "server": "mail.tu-dominio.com",
    "port": 993,
    "user": "agente@tu-dominio.com",
    "password": "SECRET_PLACEHOLDER"  // Ver ~/.openclaw/secrets/email-secrets.yaml
  }
}
```

---

## 2. 📱 TELEGRAM

### 2.1 Opciones de Configuración

| Opción | Quién Provee | Descripción |
|--------|--------------|-------------|
| **Bot nuevo** | NOSOTROS | Creamos bot con @BotFather |
| **Bot existente** | CLIENTE | Cliente provee token |

### 2.2 Si creamos el bot (Opción recomendada)

1. Ejecutar `setup-telegram.sh`
2. Seguir guía interactiva de BotFather
3. Guardar token en `~/.openclaw/secrets/telegram-secrets.yaml`

```json
{
  "telegram": {
    "bot_token": "SECRET_PLACEHOLDER",  // Ver ~/.openclaw/secrets/telegram-secrets.yaml
    "bot_username": "@tu_agente_bot",
    "allowed_users": [123456789, 987654321],
    "admin_users": [123456789]
  }
}
```

### 2.3 Si el cliente tiene bot existente

Proporcionar:
- Bot Token (de @BotFather)
- Bot Username (ej: @mi_bot)
- Allowed Users (IDs de usuarios permitidos)
- Admin Users (IDs de administradores)

---

## 3. 💬 WHATSAPP

### 3.1 Configuración Heredada

WhatsApp ya está configurado en LOCAL con número dedicado.

| Componente | Valor |
|------------|-------|
| **Número** | SECRET_PLACEHOLDER (ver config local) |
| **Estado** | Activo |
| **Grupos permitidos** | Configurar en runtime |

```json
{
  "whatsapp": {
    "enabled": true,
    "allow_from": ["SECRET_PLACEHOLDER"],
    "groups": {
      "GROUP_ID_PLACEHOLDER": { "requireMention": false }
    }
  }
}
```

---

## 4. 🎮 DISCORD

### 4.1 Configuración Heredada

Discord ya está configurado en LOCAL.

| Componente | Valor |
|------------|-------|
| **Token** | SECRET_PLACEHOLDER (ver config local) |
| **Guild ID** | SECRET_PLACEHOLDER |
| **Users Allowed** | SECRET_PLACEHOLDER |

```json
{
  "discord": {
    "token": "SECRET_PLACEHOLDER",  // Ver ~/.openclaw/secrets/discord-secrets.yaml
    "guild_id": "GUILD_ID_PLACEHOLDER",
    "users_allowed": ["USER_ID_PLACEHOLDER"]
  }
}
```

---

## 5. ☁️ CLOUDFLARE TUNNEL (Opcional)

### 5.1 Para Webhook Público

Si se necesita webhook público para Telegram:

| Componente | Quién Provee | Notas |
|------------|--------------|-------|
| **Cloudflare Account** | CLIENTE | Cuenta de Cloudflare |
| **Tunnel Token** | CLIENTE | Generar en Zero Trust |

```json
{
  "cloudflare_tunnel": {
    "enabled": true,
    "token": "SECRET_PLACEHOLDER",  // Cliente obtiene de Cloudflare Zero Trust
    "url": "https://tu-dominio.com/webhook/telegram"
  }
}
```

---

## 6. 🔑 APIs COMPARTIDAS

| API | Proveedor | Límite | Uso |
|-----|-----------|--------|-----|
| Ollama Cloud | NOSOTROS | Por uso | Modelo AI principal |
| Resend | NOSOTROS | 3,000 email/mes | Email alternativo |
| PDF.co | NOSOTROS | 5,000 páginas/mes | Documentos PDF |
| Mathpix | NOSOTROS | 1,000 páginas/mes | OCR de PDFs |
| Mux | NOSOTROS | 100 videos/mes | Procesamiento video |
| Twilio | NOSOTROS | 500 SMS/mes | Notificaciones |
| Oxylabs | NOSOTROS | 1,000 requests/mes | Web scraping |
| Gamma | NOSOTROS | 50 presentaciones/mes | Generar slides |
| Brave Search | NOSOTROS | 2,000 búsquedas/mes | Búsqueda web |
| Perplexity | NOSOTROS | 500 búsquedas/mes | Búsqueda AI |
| Jina AI | NOSOTROS | 10,000 embeddings/mes | Embeddings |

**Nota:** Los secrets reales están en `~/.openclaw/secrets/api-keys.yaml`

---

## 7. 📝 FORMULARIO PARA CLIENTE

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
¿Crear bot nuevo? (Sí/No): ____________________________
Si NO, Bot Token: ____________________________________
Bot Username: ________________________________________
Allowed User IDs: ____________________________________
Admin User IDs: ______________________________________

WHATSAPP (Opcional)
───────────────────
¿Usar WhatsApp propio? (Sí/No): ______________________
Si SÍ, número: _______________________________________
Si SÍ, API key: ______________________________________

DISCORD (Opcional)
──────────────────
¿Usar Discord propio? (Sí/No): ________________________
Si SÍ, Bot Token: ____________________________________
Si SÍ, Guild ID: ____________________________________

CLOUDFLARE TUNNEL (Opcional)
───────────────────────────
¿Configurar webhook público? (Sí/No): ________________
Si SÍ, dominio: ______________________________________

APIS PREMIUM (Opcional)
───────────────────────
¿OpenAI API Key? (Sí/No): ___________________________
Si SÍ, key: __________________________________________
¿Anthropic API Key? (Sí/No): _________________________
Si SÍ, key: __________________________________________
¿Otros? Especificar: ________________________________

═══════════════════════════════════════════════════════════════════
```

---

## 8. 🔒 UBICACIÓN DE SECRETS

| Tipo de Secret | Ubicación | Permisos |
|----------------|-----------|----------|
| API Keys | `~/.openclaw/secrets/api-keys.yaml` | 600 |
| Email Secrets | `~/.openclaw/secrets/email-secrets.yaml` | 600 |
| Telegram Token | `~/.openclaw/secrets/telegram-secrets.yaml` | 600 |
| Discord Token | `~/.openclaw/secrets/discord-secrets.yaml` | 600 |
| WhatsApp Session | `~/.openclaw/secrets/whatsapp-session.json` | 600 |

**⚠️ NUNCA commitear estos archivos a Git.**

---

## 9. ✅ CHECKLIST DE CONFIGURACIÓN

### Para Email

- [ ] Servidor SMTP configurado
- [ ] Puerto SMTP (587/465)
- [ ] Usuario SMTP (email completo)
- [ ] Contraseña SMTP
- [ ] Servidor IMAP
- [ ] Puerto IMAP (993)
- [ ] (Opcional) Resend API key

### Para Telegram

- [ ] Bot creado con @BotFather o token existente
- [ ] Bot username configurado
- [ ] Al menos 1 usuario permitido
- [ ] Al menos 1 administrador

### Para WhatsApp (Opcional)

- [ ] Número proporcionado o usar el de LOCAL
- [ ] API key (si propio)

### Para Discord (Opcional)

- [ ] Bot creado en Discord Developer Portal
- [ ] Token del bot
- [ ] Guild ID del servidor
- [ ] Users allowed IDs

### Para Cloudflare Tunnel (Opcional)

- [ ] Cuenta de Cloudflare
- [ ] Tunnel token generado

---

## 10. ⚠️ NOTAS DE SEGURIDAD

1. **NUNCA** guardar secrets en archivos de documentación
2. **SIEMPRE** usar permisos 600 en archivos de secrets
3. **ROTAR** tokens comprometidos inmediatamente
4. **USAR** variables de entorno cuando sea posible
5. **BACKUP** encriptado de secrets

---

*Documento actualizado: 2026-03-06*
*Versión sanitizada para Git*
*Secrets reales en: ~/.openclaw/secrets/*