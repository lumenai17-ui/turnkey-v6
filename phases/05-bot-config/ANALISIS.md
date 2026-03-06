# FASE 5: BOT CONFIG - ANÁLISIS

**Versión:** 1.0.0
**Fecha:** 2026-03-06
**Prioridad:** 🟡 MEDIA
**Dependencias:** FASE 4 ✅

---

## 1️⃣ PROPÓSITO

**FASE 5 configura los canales de comunicación del agente.**

Esta fase:
- Configura **Email** (envío y recepción)
- Configura **Telegram** (bot y webhooks)
- Valida **WhatsApp** (ya configurado)
- Valida **Discord** (ya configurado)
- Configura **APIs compartidas**

---

## 2️⃣ COMPONENTES

### 2.1 EMAIL

| Componente | Proveedor | Estado |
|------------|-----------|--------|
| Dominio | bee-smart.ai | ✅ Nosotros |
| Envío SMTP | mail.bee-smart.ai:587 | ⏳ Pendiente cliente |
| Envío Resend | API (fallback) | ✅ Disponible |
| Recepción IMAP | mail.bee-smart.ai:993 | ❌ NO configurado |
| Templates | Sistema | ✅ Preparado |

**IMPORTANTE:**
- El dominio **bee-smart.ai** es propiedad nuestra
- El agente tendrá email `{agente}@bee-smart.ai`
- **IMAP debe configurarse** para recibir correos
- **SMTP o Resend** para enviar correos

### 2.2 TELEGRAM

| Componente | Proveedor | Estado |
|------------|-----------|--------|
| Bot Token | Nosotros | ✅ Se crea |
| Webhook | Sistema | ✅ Preparado |
| Allowed Users | Cliente | ⏳ Pendiente IDs |

### 2.3 WHATSAPP (ya configurado en LOCAL)

| Componente | Estado |
|------------|--------|
| Sesión | ✅ Activa |
| Grupos | ✅ Configurados |
| DM | ✅ Habilitado |

### 2.4 DISCORD (ya configurado en LOCAL)

| Componente | Estado |
|------------|--------|
| Token | ✅ Activo |
| Guilds | ✅ Configurados |
| Users | ✅ Permitidos |

### 2.5 APIs COMPARTIDAS

| API | Límite | Costo |
|-----|--------|-------|
| Resend | 3,000/mes | $10/mes |
| PDF.co | 5,000 págs | $15/mes |
| Mathpix | 1,000 págs | $10/mes |
| Mux | 100 videos | $20/mes |
| Twilio | 500 SMS | $10/mes |
| Oxylabs | 1,000 req | $30/mes |
| Gamma | 50/mes | $10/mes |

**Total: ~$105/mes** (nosotros proveemos)

---

## 3️⃣ FLUJO DE CONFIGURACIÓN

```
1. EMAIL SETUP
   ├── setup-email.sh
   ├── Configurar IMAP
   └── Validar conexión

2. TELEGRAM SETUP
   ├── setup-telegram.sh
   ├── Crear bot con BotFather
   ├── Configurar webhook
   └── Validar bot funciona

3. VALIDATE CHANNELS
   └── validate-channels.sh
       ├── WhatsApp ✅
       ├── Telegram ✅
       ├── Discord ✅
       └── Email ✅

4. API KEYS
   └── setup-api-keys.sh
       ├── OpenAI (opcional)
       ├── DeepL (opcional)
       ├── Google Maps (opcional)
       └── Google OAuth (opcional)
```

---

## 4️⃣ ARCHIVOS DE CONFIGURACIÓN

### 4.1 Scripts

| Archivo | Propósito | Líneas |
|---------|-----------|--------|
| `setup-email.sh` | Configurar IMAP + SMTP | 400+ |
| `setup-telegram.sh` | Crear bot + webhook | 500+ |
| `validate-channels.sh` | Validar canales | 600+ |
| `setup-api-keys.sh` | Configurar APIs | 800+ |

### 4.2 Configuraciones

| Archivo | Genera |
|---------|--------|
| `~/.openclaw/config/email.yaml` | Email config |
| `~/.openclaw/config/telegram.yaml` | Telegram config |
| `~/.openclaw/config/api-providers.yaml` | APIs config |
| `~/.openclaw/secrets/email-secrets.yaml` | Email secrets |
| `~/.openclaw/secrets/telegram-secrets.yaml` | Telegram secrets |
| `~/.openclaw/secrets/api-keys.yaml` | API keys |

---

## 5️⃣ LO QUE EL CLIENTE DEBE PROVEER

### OBLIGATORIO

| Item | Descripción | Ejemplo |
|------|-------------|---------|
| Email del agente | Dirección de email | bee@bee-smart.ai |
| SMTP completo | Servidor, puerto, user, pass | mail.bee-smart.ai:587 |
| IMAP completo | Servidor, puerto, user, pass | mail.bee-smart.ai:993 |
| Telegram IDs | IDs numéricos de usuarios | 123456789 |

### OPCIONAL

| Item | Descripción |
|------|-------------|
| Telegram bot propio | Token existente |
| WhatsApp Business | Número propio |
| Discord server | Guild ID existente |
| Cloudflare Tunnel | Token de tunnel |
| APIs premium | OpenAI, DeepL, etc. |

---

## 6️⃣ LO QUE NOSOTROS PROVEEMOS

### INCLUIDO (sin costo adicional)

| Servicio | Límite | Estado |
|----------|--------|--------|
| Ollama Cloud | Ilimitado* | ✅ Activo |
| Resend | 3,000/mes | ✅ Activo |
| PDF.co | 5,000 págs | ✅ Activo |
| Mathpix | 1,000 págs | ✅ Activo |
| Mux | 100 videos | ✅ Activo |
| Twilio | 500 SMS | ✅ Activo |
| Oxylabs | 1,000 req | ✅ Activo |
| Gamma | 50/mes | ✅ Activo |

### CONFIGURAMOS

| Servicio | Descripción |
|----------|-------------|
| Telegram bot | Creamos el bot |
| Email templates | 6 templates |
| Webhooks | Configuramos |
| Validación | Testeamos todo |

---

## 7️⃣ VALIDACIONES

### EMAIL

```bash
# Test IMAP
./validate-channels.sh --email --test-imap

# Test SMTP
./validate-channels.sh --email --test-smtp
```

### TELEGRAM

```bash
# Test bot token
./validate-channels.sh --telegram --test-token

# Test webhook
./validate-channels.sh --telegram --test-webhook
```

### COMPLETO

```bash
# Validar todo
./validate-channels.sh --all
```

---

## 8️⃣ CASOS EDGE

| Caso | Solución |
|------|----------|
| Email sin credenciales | Usar Resend como fallback |
| Telegram sin IDs | Pedir al usuario que inicie bot |
| WhatsApp caído | Re-scanner QR |
| Discord sin permisos | Verificar intents |
| API key inválida | Script muestra error y pasos |

---

## 9️⃣ PREGUNTAS FRECUENTES

**Q: ¿Puedo usar mi propio bot de Telegram?**
A: Sí. Opcionalmente puedes proveer tu token existente.

**Q: ¿Qué pasa si no tengo servidor de email?**
A: Usamos Resend (3,000 emails/mes gratis) como fallback.

**Q: ¿Puedo agregar más usuarios de Telegram después?**
A: Sí. El script permite agregar usuarios en cualquier momento.

**Q: ¿Las APIs compartidas tienen límite?**
A: Sí. Ver tabla arriba. Para más, cliente puede agregar sus propias APIs.

---

## 🔟 SIGUIENTE PASO

**FASE 6: ACTIVATION** → Validación final y activación del agente.

---

*Análisis completado - FASE 5 BOT CONFIG*