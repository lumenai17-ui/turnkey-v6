# INPUTS - FASE 1: PRE-FLIGHT

**Descripción:** Formulario de entrada que recibe el script pre-flight.sh

---

## 📋 MODO DE USO

El script puede recibir inputs de dos formas:

| Modo | Descripción |
|------|-------------|
| **Automático** | `--config archivo.json` con todos los datos |
| **Interactivo** | `--interactive` pregunta paso a paso |

---

## 📝 FORMULARIO COMPLETO

### SECCIÓN 1: ENTORNO

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `deployment_type` | select | No | auto-detectar | `vps` o `dedicado` |
| `provider` | texto | No | auto-detectar | AWS, DigitalOcean, GCP, otro |

**Pregunta interactiva:**
```
? Tipo de despliegue:
  1) VPS (cloud)
  2) Servidor dedicado
  [Auto-detectar] (Enter para auto-detectar): __
```

**Validación:**
- Si se omite → auto-detectar
- Si auto-detectar falla → preguntar

---

### SECCIÓN 1B: NIVEL DE AGENTE

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `agent_level` | select | No | `1` | Nivel 1-5 de capacidades |

**Pregunta interactiva:**
```
? Nivel de agente:
  1) Básico - Chat con memoria y búsqueda web ($5-10/mes)
  2) Comunicación - Multi-canal: WhatsApp, Telegram, Email ($15-25/mes)
  3) Multimedia - Imagen, audio, voz, PDFs ($30-50/mes)
  4) Negocio - Ads, Reviews, CRM, Dashboards ($50-100/mes)
  5) Autónomo - Cron, Browser, Multi-agente ($100-200/mes)
  
  Selecciona [1-5] (1): __
```

**Validación:**
- Nivel influye en skills incluidas por defecto
- Nivel influye en APIs requeridas
- Nivel 4 y 5 requieren más configuración

**Ver detalle de niveles:** `docs/AGENTE-HABIL-DEFINICION.md`

---

### SECCIÓN 2: IDENTIDAD DEL AGENTE

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `agent_name` | texto | No | `Agent-{timestamp}` | Nombre del agente |
| `agent_role` | texto | No | `Asistente virtual` | Rol/descripción |
| `agent_emoji` | texto | No | `🤖` | Emoji identificador |
| `agent_language` | select | No | `es` | Idioma principal |
| `agent_template` | select | No | `custom` | Template de personalidad |

**Preguntas interactivas:**
```
? Nombre del agente (Agent-1709644800): __
? Rol del agente (Asistente virtual): __
? Emoji identificador (🤖): __
? Idioma principal:
  1) es - Español
  2) en - English
  3) pt - Português
  Selecciona [1-3] (1): __
? Template de personalidad:
  1) restaurant - Restaurante/cafetería
  2) hotel - Hotel/hostal
  3) retail - Tienda/e-commerce
  4) services - Servicios profesionales
  5) custom - Personalizado
  Selecciona [1-5] (5): __
```

**Validación:**
- `agent_name`: No vacío, sin caracteres especiales
- `agent_emoji`: Debe ser un emoji válido (opcional)
- `agent_template`: Debe ser uno de la lista

---

### SECCIÓN 3: API KEYS

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `ollama_api_key` | texto | **SÍ** | - | API key de Ollama Cloud |
| `ollama_plan` | select | No | auto-detectar | `free` o `paid` |
| `brave_api_key` | texto | No | - | API key de Brave Search |
| `openai_api_key` | texto | No | - | API key de OpenAI (opcional) |

**Preguntas interactivas:**
```
? API Key de Ollama Cloud (REQUERIDO): __
? Verificando key... [✓ Validada - Plan: FREE]
? API Key de Brave Search (opcional, para web_search): __
? API Key de OpenAI (opcional): __
```

**Validación:**
- `ollama_api_key`: **OBLIGATORIO**, debe ser válido (ping a API)
- `ollama_plan`: Se detecta automáticamente al validar key
- Si `ollama_api_key` inválido → Error crítico, no continuar
- Si `brave_api_key` falta → Deshabilitar skill web_search con warning

---

### SECCIÓN 3A: APIs COMPARTIDAS (PROVEEMOS NOSOTROS)

**Estas APIs las proveemos como servicio. El cliente NO las configura.**

| API | Habilidades | Límite | Nota |
|-----|-------------|--------|------|
| **Resend** | email_send | 3,000 emails/mes | Dominio bee.ai |
| **IMAP** | email_read | Sin límite | Servidor bee.ai |
| **PDF.co** | pdf_generate | 5,000 páginas/mes | Procesamiento PDF |
| **Mathpix** | pdf_read | 1,000 páginas/mes | Extracción PDF |
| **Mux** | video_hosting | 100 videos/mes | Hosting de videos |

**Configuración automática:**
```json
{
  "shared_apis": {
    "resend": {
      "api_key": "re_xxxx_shared",
      "domain": "bee.ai",
      "from": "{agent_name}@bee.ai"
    },
    "pdf_co": {
      "api_key": "pdf_xxxx_shared"
    },
    "mathpix": {
      "api_key": "math_xxxx_shared"
    }
  }
}
```

**Mensaje al cliente:**
```
✅ APIs incluidas en el servicio:
   • Email (enviar y recibir)
   • PDFs (crear y leer)
   • Video hosting

   Sin configuración adicional.
```

---

### SECCIÓN 3B: API KEYS DEL CLIENTE (CONFIGURA EN FASE 1)

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `openai_api_key` | texto | No | - | API key de OpenAI (Whisper, DALL-E, TTS) |
| `deepl_api_key` | texto | No | - | API key de DeepL (traducción) |
| `google_maps_key` | texto | No | - | API key de Google Maps (ubicaciones) |

**Preguntas interactivas:**
```
? API Key de OpenAI (opcional, para voz e imágenes): __
? API Key de DeepL (opcional, para traducción): __
? API Key de Google Maps (opcional, para ubicaciones): __
```

**Habilidades que habilitan:**

| API Key | Habilidades habilitadas | Costo estimado |
|---------|------------------------|---------------|
| `openai_api_key` | voice_receive, voice_send, image_generate, audio_process | ~$0.006/min audio, $0.04-0.12/img |
| `deepl_api_key` | translate | Gratis 500,000 chars/mes |
| `google_maps_key` | location | Gratis $200 crédito/mes |

**Validación:**
- Si falta una API key → La habilidad sigue disponible pero con limitaciones
- Mostrar mensaje claro: "Para [habilidad], necesito API key de [provider]"
- Nunca fallar silenciosamente

---

### SECCIÓN 3B: API KEYS ADICIONALES (HABILIDADES NATAS)

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `openai_api_key` | texto | No | - | API key de OpenAI (Whisper, DALL-E, TTS) |
| `resend_api_key` | texto | No | - | API key de Resend (email) |
| `deepl_api_key` | texto | No | - | API key de DeepL (traducción) |
| `google_maps_key` | texto | No | - | API key de Google Maps (ubicaciones) |

**Preguntas interactivas:**
```
? API Key de OpenAI (opcional, para voz e imágenes): __
? API Key de Resend (opcional, para enviar emails): __
? API Key de DeepL (opcional, para traducción): __
? API Key de Google Maps (opcional, para ubicaciones): __
```

**Habilidades que habilitan:**

| API Key | Habilidades habilitadas | Costo estimado |
|---------|------------------------|---------------|
| `openai_api_key` | voice_receive, voice_send, image_generate | ~$0.006/min audio, $0.04-0.12/img |
| `resend_api_key` | email_send | Gratis 3,000 emails/mes |
| `deepl_api_key` | translate | Gratis 500,000 chars/mes |
| `google_maps_key` | location | Gratis $200 crédito/mes |

**Validación:**
- Si falta una API key → La habilidad sigue disponible pero con limitaciones
- Mostrar mensaje claro: "Para [habilidad], necesito API key de [provider]"
- Nunca fallar silenciosamente

---

### SECCIÓN 3C: GOOGLE OAUTH (CALENDAR Y SHEETS)

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `google_oauth_configured` | bool | No | `false` | Si OAuth de Google está configurado |
| `google_client_id` | texto | Condicional | - | Client ID de Google Cloud |
| `google_client_secret` | texto | Condicional | - | Client Secret de Google Cloud |

**Preguntas interactivas:**
```
? ¿Configurar Google Calendar y Sheets? (s/n) (n): __

  Si sí:
  ? URL de Google Cloud Console: https://console.cloud.google.com
  ? 1. Crear proyecto OAuth 2.0
  ? 2. Habilitar Calendar API y Sheets API
  ? 3. Crear credenciales OAuth
  ? 4. Pegar Client ID: __
  ? 5. Pegar Client Secret: __
```

**Habilidades que habilitan:**

| Configuración | Habilidades habilitadas |
|--------------|------------------------|
| `google_oauth_configured` | calendar, sheets |

**Nota:** OAuth de Google se configura en FASE 5, no en PRE-FLIGHT.

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `model_primary` | select | No | `glm-5` | Modelo principal |
| `model_fallback` | select | No | `kimi-k2.5` | Modelo de respaldo |

**Preguntas interactivas:**
```
? Modelo principal:
  1) glm-5 (recomendado, balanceado)
  2) kimi-k2.5 (gran contexto)
  3) deepseek-v3.2 (razonamiento)
  4) qwen3.5:397b (potente)
  Selecciona [1-4] (1): __
? Modelo de respaldo:
  1) kimi-k2.5
  2) deepseek-v3.2
  Selecciona [1-2] (1): __
```

**Validación:**
- Lista de modelos depende del plan de Ollama (free vs paid)
- Si plan free → solo modelos disponibles en free

---

### SECCIÓN 5: CANALES

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `telegram_enabled` | bool | No | `true` | Habilitar Telegram |
| `telegram_bot_token` | texto | Condicional | - | Token del bot |
| `telegram_allowed_users` | lista | Condicional | - | IDs de usuarios permitidos |
| `whatsapp_enabled` | bool | No | `true` | Habilitar WhatsApp |
| `whatsapp_config` | objeto | Condicional | - | Config de WhatsApp Business |
| `discord_enabled` | bool | No | `true` | Habilitar Discord |
| `discord_bot_token` | texto | Condicional | - | Token del bot de Discord |
| `email_enabled` | bool | No | `false` | Habilitar Email |
| `email_address` | texto | Condicional | - | Dirección de email del agente |
| `email_imap_host` | texto | Condicional | - | Servidor IMAP (ej: mail.bee-smart.ai) |
| `email_imap_port` | número | No | `993` | Puerto IMAP |
| `email_imap_user` | texto | Condicional | - | Usuario IMAP |
| `email_imap_password` | texto | Condicional | - | Contraseña IMAP |
| `email_smtp_host` | texto | Condicional | - | Servidor SMTP (ej: mail.bee-smart.ai) |
| `email_smtp_port` | número | No | `587` | Puerto SMTP |
| `email_smtp_user` | texto | Condicional | - | Usuario SMTP |
| `email_smtp_password` | texto | Condicional | - | Contraseña SMTP |

**Preguntas interactivas:**
```
? Configurar Telegram ahora? (s/n) (s): __
  ? Token del bot de Telegram: __
  ? Tu Telegram User ID: __
  ? IDs adicionales permitidos (separados por coma): __

? Configurar WhatsApp ahora? (s/n) (n): __
  (Si sí, preguntar config de WhatsApp Business)

? Configurar Discord ahora? (s/n) (n): __
  ? Token del bot de Discord: __

? Configurar Email ahora? (s/n) (n): __
  Si sí:
  ? Dirección de email del agente (ej: bee@bee-smart.ai): __
  ? Servidor IMAP (ej: mail.bee-smart.ai): __
  ? Puerto IMAP (993): __
  ? Usuario IMAP (ej: bee@bee-smart.ai): __
  ? Contraseña IMAP: __
  ? Servidor SMTP (ej: mail.bee-smart.ai): __
  ? Puerto SMTP (587): __
  ? Usuario SMTP (ej: bee@bee-smart.ai): __
  ? Contraseña SMTP: __
  
  ? ¿Usar Resend como alternativa para envío? (s/n) (s): __
    Si sí:
    ? API Key de Resend: __
```

**Validación:**
- Si `telegram_enabled=true` y no hay token → Warning, continuar sin Telegram
- `telegram_allowed_users`: Validar que sean números
- Si `email_enabled=true` y faltan credenciales IMAP/SMTP → Warning, continuar sin Email
- Credenciales IMAP y SMTP se guardan en `secrets/email-secrets.yaml`

---

### SECCIÓN 6: SKILLS (SELECCIONABLES DEL CATÁLOGO)

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `skills` | lista | No | Ver defaults | Skills seleccionadas del catálogo |

**Preguntas interactivas:**
```
? Skills básicas (incluidas):
  [✓] mem.persistent - Memoria persistente
  [✓] mem.search - Búsqueda en memoria
  [✓] search.web - Búsqueda web
  [✓] doc.pdf-read - Leer PDFs
  [✓] sys.exec - Ejecutar comandos
  [✓] sys.backup - Backup automático

? Skills de comunicación (selecciona las que necesites):
  [✓] com.email - Email IMAP/SMTP
  [✓] com.whatsapp - WhatsApp Business
  [✓] com.telegram - Telegram Bot
  [✓] com.discord - Discord Bot
  [ ] com.sms - SMS (requiere Twilio)
  
  Selecciona números separados por coma (ej: 1,2,3) o Enter para continuar: __

? Skills de documentos:
  [✓] doc.pdf-read - Leer PDFs (incluido)
  [ ] doc.pdf-create - Crear PDFs de calidad
  [ ] doc.docx - Manejar Word
  [ ] doc.excel - Manejar Excel
  [ ] doc.slides - Crear presentaciones
  
  Selecciona: __

? Skills de multimedia:
  [ ] audio.transcribe - Transcribir audios (requiere Whisper)
  [ ] audio.tts - Generar voz (requiere ElevenLabs)
  [ ] img.analyze - Analizar imágenes (incluido)
  [ ] img.create - Crear imágenes (requiere DALL-E/SD)
  [ ] vid.create - Crear videos (requiere Runway/Pika)
  
  Selecciona: __

? Skills de negocio - Marketing:
  [ ] biz.meta-ads - Meta Ads Manager
  [ ] biz.google-ads - Google Ads Manager
  [ ] biz.social-post - Publicar en redes
  [ ] biz.email-market - Email marketing
  
  Selecciona: __

? Skills de negocio - CRM:
  [ ] biz.kommo - Kommo CRM
  [ ] biz.hubspot - HubSpot CRM
  [ ] biz.pipeline - Gestión de leads
  
  Selecciona: __

? Skills de negocio - Reportes:
  [ ] biz.morning-brief - Resumen diario automático
  [ ] biz.reports - Generar reportes PDF
  [ ] biz.analytics - Dashboard de métricas
  [ ] biz.reviews - Monitoreo de reseñas
  
  Selecciona: __

? Skills de sistema avanzadas:
  [ ] sys.browser - Control de navegador
  [ ] sys.node - Control de dispositivos remotos
  [ ] sys.cron - Tareas programadas
  
  Selecciona: __

? Calendario:
  [ ] cal.google - Google Calendar
  [ ] cal.outlook - Outlook Calendar
  
  Selecciona: __
```

**Validación:**
- Verificar que APIs requeridas están disponibles
- Mostrar warning si skill requiere API no configurada
- Permitir agregar APIs después

**Defaults incluidos (sin costo):**
- `mem.persistent` - Memoria persistente
- `mem.search` - Búsqueda en memoria
- `search.web` - Búsqueda web (requiere Brave API)
- `doc.pdf-read` - Leer PDFs
- `sys.exec` - Ejecutar comandos
- `sys.backup` - Backup automático

**Ver catálogo completo:** `docs/SKILLS-CATALOG.md`

---

### SECCIÓN 7: PUERTO

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `agent_port` | número | No | `18789` | Puerto para el gateway |

**Pregunta interactiva:**
```
? Puerto para el gateway (18789): __
```

**Validación:**
- Debe ser número entre 1024-65535
- Si está ocupado → Buscar siguiente disponible en rango 18789-18793
- Si todos ocupados → Error, pedir puerto manual

---

### SECCIÓN 9: CONOCIMIENTO DEL NEGOCIO (ARCHIVOS)

| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| `knowledge_files` | archivos | No | - | Archivos del negocio |
| `knowledge_urls` | lista | No | - | URLs del negocio |

**Preguntas interactivas:**
```
? ¿Tienes archivos del negocio para subir? (s/n) (s): __

  Arrastra archivos aquí o escribe la ruta:
  (PDF, Excel, Word, Imágenes, Audio)
  
  Archivos:
  [✓] menu.pdf (2.3 MB) - Menú del restaurante
  [✓] precios.xlsx (156 KB) - Lista de precios
  [✓] logo.png (45 KB) - Logo del negocio
  [ ] [Arrastra más archivos o Enter para continuar]

? ¿Tienen URLs del negocio? (web, redes sociales, etc) (s/n) (n): __
  ? URL del sitio web: __
  ? URL de Instagram: __
  ? URL de Facebook: __
  ? URL de Google Maps: __
```

**Tipos de archivo soportados:**

| Tipo | Extensiones | Procesamiento |
|------|------------|---------------|
| **PDF** | `.pdf` | Extraer texto con pdftotext |
| **Excel** | `.xlsx`, `.xls` | Convertir a JSON |
| **Word** | `.doc`, `.docx` | Extraer texto con pandoc |
| **Imagen** | `.png`, `.jpg`, `.jpeg` | Analizar con Vision API |
| **Audio** | `.mp3`, `.wav`, `.ogg` | Transcribir con Whisper |
| **URL** | `https://...` | Scrapear contenido |

**Validación:**
- Tamaño máximo por archivo: 50 MB
- Total máximo: 200 MB
- Si archivo muy grande → Warning, permitir continuar
- Si tipo no soportado → Warning, omitir

**Qué hace FASE 1 con los archivos:**

1. Recibe archivos
2. Valida tipo y tamaño
3. Guarda en: `~/.openclaw/workspace/temp-upload/`
4. Guarda metadatos en: `~/.openclaw/config/pending-knowledge.json`
5. **NO procesa** - eso es tarea de FASE 4

**Archivo de metadatos (pending-knowledge.json):**
```json
{
  "upload_date": "2026-03-05T10:00:00Z",
  "files": [
    {
      "original_name": "menu.pdf",
      "saved_as": "file_001.pdf",
      "path": "~/.openclaw/workspace/temp-upload/file_001.pdf",
      "size_bytes": 2411724,
      "type": "application/pdf",
      "status": "pending"
    },
    {
      "original_name": "precios.xlsx",
      "saved_as": "file_002.xlsx",
      "path": "~/.openclaw/workspace/temp-upload/file_002.xlsx",
      "size_bytes": 159744,
      "type": "application/vnd.ms-excel",
      "status": "pending"
    }
  ],
  "urls": [
    {
      "url": "https://mirestaurante.com",
      "type": "website",
      "status": "pending"
    }
  ]
}
```

---

### SECCIÓN 10: CONFIRMACIÓN FINAL

**Pregunta interactiva:**
```
╔══════════════════════════════════════════════════════════╗
║ RESUMEN DE CONFIGURACIÓN                                 ║
╠══════════════════════════════════════════════════════════╣
║ Agente: Atlas 🗺️                                         ║
║ Rol: Asistente de viajes                                 ║
║ Template: services                                       ║
║ Puerto: 18789                                            ║
╠══════════════════════════════════════════════════════════╣
║ Entorno: VPS (AWS)                                       ║
║ RAM: 4GB ✓ | CPU: 2 cores ✓ | Disco: 65GB ✓            ║
╠══════════════════════════════════════════════════════════╣
║ API Ollama: ✓ Validada (Plan: FREE)                     ║
║ API Brave: ✓ Configurada                                 ║
╠══════════════════════════════════════════════════════════╣
║ Canales: Telegram ✓, WhatsApp ✗, Discord ✗             ║
║ Skills: voicenote ✓, pdf_reader ✓, web_search ✓         ║
╚══════════════════════════════════════════════════════════╝

? Configuración correcta? (s/n) (s): __
? Guardar configuración? (s/n) (s): __
```

---

## 📄 FORMATO JSON (modo automático)

```json
{
  "deployment": {
    "type": "vps",
    "provider": "aws"
  },
  "agent": {
    "name": "Atlas",
    "role": "Asistente de viajes",
    "emoji": "🗺️",
    "language": "es",
    "template": "services",
    "port": 18789
  },
  "shared_apis": {
    "resend": {
      "api_key": "re_shared_xxxx",
      "domain": "bee.ai",
      "from": "{agent_name}@bee.ai"
    },
    "pdf_co": {
      "api_key": "pdf_shared_xxxx"
    },
    "mathpix": {
      "api_key": "math_shared_xxxx"
    }
  },
  "api_keys": {
    "ollama": "oll-xxxxxxxxxxxxxx",
    "brave": "brave-xxxxxxxxxxxxxx",
    "openai": "sk-xxxxxxxxxxxxxx",
    "deepl": "xxxxxxxxxxxxxxxxxx",
    "google_maps": "AIzaSyxxxxxxxxxxxxxxxx"
  },
  "models": {
    "primary": "glm-5",
    "fallback": "kimi-k2.5"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "bot_token": "botxxxxxxxxxx",
      "allowed_users": ["123456789", "987654321"]
    },
    "whatsapp": {
      "enabled": false
    },
    "discord": {
      "enabled": false
    },
    "email": {
      "enabled": true,
      "address": "bee@bee-smart.ai",
      "imap": {
        "host": "mail.bee-smart.ai",
        "port": 993,
        "user": "bee@bee-smart.ai",
        "password": "********"
      },
      "smtp": {
        "host": "mail.bee-smart.ai",
        "port": 587,
        "user": "bee@bee-smart.ai",
        "password": "********"
      },
      "resend_api_key": "re_xxxxxxxxxxxx"
    }
  },
  "skills": {
    "voicenote": true,
    "pdf_reader": true,
    "web_search": true,
    "image_analysis": false
  },
  "knowledge": {
    "files": [
      {
        "path": "~/.openclaw/workspace/temp-upload/menu.pdf",
        "type": "pdf",
        "size": 2411724,
        "description": "Menú del restaurante"
      },
      {
        "path": "~/.openclaw/workspace/temp-upload/precios.xlsx",
        "type": "xlsx",
        "size": 159744,
        "description": "Lista de precios"
      }
    ],
    "urls": [
      {
        "url": "https://mirestaurante.com",
        "type": "website"
      }
    ]
  }
}
```

---

## ⚠️ CAMPOS OBLIGATORIOS VS OPCIONALES

### Obligatorios (error si faltan)

| Campo | Razón |
|-------|-------|
| `ollama_api_key` | Sin ella no hay IA |

### Opcionales con default

| Campo | Default | Nota |
|-------|---------|------|
| `deployment_type` | auto-detectar | |
| `agent_name` | `Agent-{timestamp}` | |
| `agent_role` | `Asistente virtual` | |
| `agent_emoji` | `🤖` | |
| `agent_language` | `es` | |
| `agent_template` | `custom` | |
| `model_primary` | `glm-5` | |
| `model_fallback` | `kimi-k2.5` | |
| `agent_port` | `18789` | |
| `telegram_enabled` | `true` | |
| `whatsapp_enabled` | `true` | |
| `discord_enabled` | `true` | |
| `email_enabled` | `false` | |
| `skill_voicenote` | `true` | |
| `skill_pdf_reader` | `true` | |
| `skill_web_search` | `true` | |

### Condicionalmente obligatorios

| Campo | Condición |
|-------|-----------|
| `telegram_bot_token` | Si `telegram_enabled=true` |
| `telegram_allowed_users` | Si `telegram_enabled=true` |
| `whatsapp_config` | Si `whatsapp_enabled=true` |
| `discord_bot_token` | Si `discord_enabled=true` |
| `email_address` | Si `email_enabled=true` |
| `email_imap_host` | Si `email_enabled=true` |
| `email_imap_user` | Si `email_enabled=true` |
| `email_imap_password` | Si `email_enabled=true` |
| `email_smtp_host` | Si `email_enabled=true` |
| `email_smtp_user` | Si `email_enabled=true` |
| `email_smtp_password` | Si `email_enabled=true` |

---

## 🔄 FLUJO DE VALIDACIÓN

```
1. Cargar config (archivo o interactivo)
   ↓
2. Validar campos obligatorios
   ├─► ollama_api_key falta → Error crítico
   └─► ollama_api_key existe → Validar con API
       ├─► Inválida → Error crítico
       └─► Válida → Detectar plan (free/paid)
   ↓
3. Aplicar defaults a campos vacíos
   ↓
4. Validar campos condicionales
   └─► Canal habilitado sin token → Warning
   ↓
5. Validar recursos del sistema
   ├─► RAM insuficiente → Error, no proceder
   ├─► CPU insuficiente → Error, no proceder
   └─► Puerto ocupado → Auto-asignar siguiente
   ↓
6. Mostrar resumen y confirmar
   ↓
7. Guardar turnkey-config.json
```

---

## ❓ PREGUNTAS SOBRE EL FORMULARIO

1. **¿Falta algún campo?** Revisar si hay datos adicionales que necesitemos
2. **¿El orden es correcto?** sección 1→8 tiene sentido?
3. **¿Las validaciones son correctas?** Hay algo que cambiaría?
4. **¿El resumen final es claro?** Muestra todo lo importante?

---

*Documento para revisar antes de CODING*