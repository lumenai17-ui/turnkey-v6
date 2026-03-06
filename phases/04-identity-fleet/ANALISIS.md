# FASE 4: IDENTITY FLEET - ANÁLISIS COMPLETO

**Versión:** 2.0.0
**Fecha:** 2026-03-05
**Prioridad:** 🔴 CRÍTICA
**Dependencias:** FASE 1 ✅, FASE 2 ✅, FASE 3 ✅

---

## 1️⃣ PROPÓSITO

**FASE 4 es donde el agente COBRA VIDA.**

Esta fase configura:
- **IDENTITY** → Quién es, cómo piensa, qué sabe
- **FLEET** → Qué modelos usa para responder
- **KNOWLEDGE** → Documentos, PDFs, Excel, imágenes
- **TOOLS** → Herramientas que puede usar
- **SKILLS** → Habilidades específicas
- **ACCESOS** → Credenciales y permisos

---

## 2️⃣ COMPONENTES DE IDENTITY

### 2.1 ARCHIVOS PRINCIPALES

| Archivo | Ubicación | Descripción | ¿Cuándo se crea? |
|---------|-----------|-------------|------------------|
| `SOUL.md` | `~/.openclaw/config/` | Personalidad, valores, estilo | **FASE 4** |
| `USER.md` | `~/.openclaw/config/` | Info del cliente/negocio | **FASE 4** |
| `MEMORY.md` | `~/.openclaw/data/` | Memoria inicial | **FASE 4** |
| `HEARTBEAT.md` | `~/.openclaw/config/` | Configuración de heartbeat | **FASE 4** |
| `TOOLS.md` | `~/.openclaw/config/` | Herramientas disponibles | **FASE 4** |
| `SKILLS.md` | `~/.openclaw/config/` | Habilidades del agente | **FASE 4** |

### 2.2 KNOWLEDGE (CONOCIMIENTO)

| Tipo | Ubicación | Procesamiento |
|------|-----------|---------------|
| PDFs | `~/.openclaw/knowledge/pdf/` | Extraer texto, indexar |
| Excel | `~/.openclaw/knowledge/excel/` | Convertir a JSON, indexar |
| Docs | `~/.openclaw/knowledge/docs/` | Extraer texto, indexar |
| Imágenes | `~/.openclaw/knowledge/images/` | OCR o descripción |
| URLs | `~/.openclaw/knowledge/urls/` | Scrapear y guardar |

**¿De dónde viene este conocimiento?**
- **FASE 1** → El usuario sube archivos en el formulario inicial
- **FASE 4** → Se procesan y se agregan al contexto del agente

### 2.3 ACCESOS Y CREDENCIALES

| Acceso | Dónde se guarda | En qué fase |
|--------|----------------|-------------|
| Email del agente | `~/.openclaw/config/email.json` | **FASE 4** |
| Credenciales servicios | `~/.openclaw/config/credentials.enc` | **FASE 4** |
| API keys adicionales | `~/.openclaw/config/api-keys.json` | **FASE 1** |
| Tokens bots | `~/.openclaw/config/tokens.json` | **FASE 1** |

---

## 3️⃣ COMPONENTES DE FLEET

### 3.1 FLEET LUMEN v2 (8 modelos)

| Modelo | Uso | Prioridad |
|--------|-----|-----------|
| `glm-5` | Principal (rápido, general) | 🟢 Alta |
| `kimi-k2.5` | Alternativo (más capacidad) | 🟢 Alta |
| `claude-3-sonnet` | Razonamiento complejo | 🟡 Media |
| `claude-3-haiku` | Respuestas rápidas | 🟡 Media |
| `llama-3-70b` | Código y técnico | 🟡 Media |
| `mistral-large` | Multilingüe | 🔵 Baja |
| `gpt-4-turbo` | Fallback | 🔵 Baja |
| `gemini-pro` | Vision/multimodal | 🔵 Baja |

### 3.2 CONFIGURACIÓN DE MODELOS

```json
{
  "models": {
    "primary": "glm-5",
    "fallback": ["kimi-k2.5", "claude-3-haiku"],
    "specialized": {
      "code": "llama-3-70b",
      "vision": "gemini-pro",
      "reasoning": "claude-3-sonnet"
    }
  }
}
```

---

## 4️⃣ FLUJO DE DATOS

### 4.1 Del Formulario (FASE 1) a FASE 4

```
FASE 1: FORMULARIO
    │
    ├─► Datos básicos
    │     └─► Nombre, tipo de negocio, contacto
    │
    ├─► Archivos subidos
    │     ├─► PDFs → knowledge/pdf/
    │     ├─► Excel → knowledge/excel/
    │     ├─► Docs → knowledge/docs/
    │     └─► Imágenes → knowledge/images/
    │
    ├─► API keys
    │     └─► api-keys.json
    │
    └─► Tokens de bots
          └─► tokens.json

FASE 4: IDENTITY FLEET
    │
    ├─► Lee datos de FASE 1
    │
    ├─► Crea SOUL.md
    │     └─► Template según tipo de negocio
    │
    ├─► Crea USER.md
    │     └─► Info del cliente
    │
    ├─► Procesa KNOWLEDGE
    │     ├─► Extrae texto de PDFs
    │     ├─► Convierte Excel a JSON
    │     ├─► OCR en imágenes
    │     └─► Indexa todo
    │
    ├─► Configura FLEET
    │     └─► Modelos y prioridades
    │
    └─► Configura ACCESOS
          ├─► Email del agente
          └─► Credenciales de servicios
```

---

## 5️⃣ QUÉ HACE EL AGENTE "INTELIGENTE"

### 5.1 Componentes de Inteligencia

| Componente | Archivo | Hace que el agente... |
|------------|---------|----------------------|
| **SOUL** | `SOUL.md` | Tenga personalidad y estilo |
| **USER** | `USER.md` | Conozca a su cliente |
| **MEMORY** | `MEMORY.md` | Recuerde conversaciones |
| **KNOWLEDGE** | `knowledge/` | Tenga contexto del negocio |
| **TOOLS** | `TOOLS.md` | Pueda ejecutar acciones |
| **SKILLS** | `SKILLS.md` | Tenga habilidades específicas |
| **FLEET** | `fleet.json` | Tenga modelos potentes |

### 5.2 TOOLS Disponibles por Defecto

| Tool | Descripción |
|------|-------------|
| `read` | Leer archivos |
| `write` | Escribir archivos |
| `exec` | Ejecutar comandos |
| `browser` | Navegar web |
| `web_search` | Buscar en internet |
| `web_fetch` | Descargar páginas |
| `memory_search` | Buscar en memoria |
| `whatsapp` | Enviar/recibir WhatsApp |
| `telegram` | Enviar/recibir Telegram |

### 5.3 SKILLS por Tipo de Negocio

| Negocio | Skills sugeridas |
|---------|------------------|
| Restaurante | Menu parser, reservations, orders |
| Hotel | Booking, availability, FAQ |
| Tienda | Inventory, product search, orders |
| Servicios | Calendar, appointments, reminders |
| Genérico | FAQ, contact, hours |

---

## 6️⃣ EMAIL Y ACCESOS

### 6.1 ¿DÓNDE SE CONFIGURAN?

| Dato | FASE 1 | FASE 4 | FASE 5 |
|------|--------|--------|--------|
| Email del agente | ❌ | ✅ Se configura | ✅ Se usa |
| Email del negocio | ✅ Se recibe | ✅ Se guarda | ✅ Se usa |
| WhatsApp Business | ❌ | ❌ | ✅ FASE 5 |
| Telegram Bot | ✅ Token | ✅ Se configura | ✅ Se usa |
| Discord Bot | ✅ Token | ✅ Se configura | ✅ Se usa |

### 6.2 Email del Agente

**¿El agente necesita su propio email?**

| Opción | Descripción |
|--------|-------------|
| A | Sí, crear email dedicado para el agente |
| B | No, usar email del negocio |
| C | Opcional, configurar más tarde |

**Si se crea:**
- Formato: `{agente}@tudominio.com`
- Usado para: Notificaciones, logs, alertas
- Configurado en: FASE 4
- Conectado en: FASE 5 (si aplica)

---

## 7️⃣ INPUTS DEL USUARIO

### 7.1 Datos de FASE 1

| Campo | Obligatorio | Default |
|-------|-------------|---------|
| `agent_name` | ✅ | - |
| `business_type` | ✅ | - |
| `business_name` | ✅ | - |
| `contact_email` | ✅ | - |
| `contact_phone` | No | - |
| `timezone` | No | America/Panama |
| `language` | No | es |

### 7.2 Archivos de FASE 1

| Archivo | Procesamiento |
|---------|--------------|
| PDFs | Extraer texto con pdftotext |
| Excel | Convertir a JSON con xlsx2json |
| Docs | Extraer con pandoc |
| Imágenes | OCR con tesseract o descripción con vision |

### 7.3 Configuración de FASE 4

| Campo | Obligatorio | Default |
|-------|-------------|---------|
| `create_agent_email` | No | false |
| `agent_email` | Condicional | - |
| `knowledge_enabled` | No | true |
| `tools_enabled` | No | true |
| `skills` | No | Por tipo de negocio |

---

## 8️⃣ OUTPUT DE ESTA FASE

### 8.1 Archivos Creados

```
~/.openclaw/
├── config/
│   ├── SOUL.md
│   ├── USER.md
│   ├── HEARTBEAT.md
│   ├── TOOLS.md
│   ├── SKILLS.md
│   ├── fleet.json
│   ├── openclaw.json
│   └── email.json (opcional)
│
├── data/
│   ├── MEMORY.md
│   └── knowledge-index.json
│
└── knowledge/
    ├── pdf/
    │   └── {archivo}.txt
    ├── excel/
    │   └── {archivo}.json
    ├── docs/
    │   └── {archivo}.md
    └── images/
        └── {imagen}.txt
```

### 8.2 JSON de Estado

```json
{
  "status": "passed",
  "identity": {
    "soul": "created",
    "user": "created",
    "memory": "created",
    "knowledge_files": 5,
    "tools": 10,
    "skills": 3
  },
  "fleet": {
    "primary_model": "glm-5",
    "fallback_models": ["kimi-k2.5", "claude-3-haiku"],
    "total_models": 8
  },
  "access": {
    "email_configured": true,
    "services": ["telegram", "whatsapp"]
  }
}
```

---

## 9️⃣ EDGE CASES

| Caso | Solución |
|------|----------|
| Sin archivos de conocimiento | Continuar sin KNOWLEDGE |
| Archivo muy grande | Dividir en chunks |
| Imagen sin OCR disponible | Guardar como referencia |
| Email ya existe | Usar el existente |
| Modelo no disponible | Usar fallback |
| Sin API key | Pedir interactivamente |

---

## 🔟 PREGUNTAS PENDIENTES

| # | Pregunta | Estado |
|---|----------|--------|
| 1 | ¿Crear email automático para el agente? | ⏳ Pendiente |
| 2 | ¿Procesar archivos grandes en background? | ⏳ Pendiente |
| 3 | ¿Skills automáticas por tipo de negocio? | ⏳ Pendiente |
| 4 | ¿Incluir todos los modelos del Fleet? | ⏳ Pendiente |
| 5 | ¿Indexar conocimiento con embeddings? | ⏳ Pendiente |

---

*Análisis creado: 2026-03-05*
*Versión: 2.0.0 - Extendido con conocimiento, tools y accesos*