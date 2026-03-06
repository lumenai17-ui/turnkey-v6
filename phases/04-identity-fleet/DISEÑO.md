# FASE 4: IDENTITY FLEET - DISEÑO COMPLETO

**Versión:** 2.0.0
**Fecha:** 2026-03-05
**Prioridad:** 🔴 CRÍTICA
**Basado en:** LUMEN LOCAL (copia exacta)

---

## 1️⃣ ARQUITECTURA - COPIA DE LOCAL

### 1.1 El agente es una COPIA de LOCAL

```
LOCAL (LUMEN)                    AGENTE (BEE-{nombre})
    │                                    │
    ├── HEART ────────────────────────► HEART (copia exacta)
    │   └── Escala Hawkins 1-1000        └── Nivel base: 350
    │   └── Nivel base: 350              
    │                                    
    ├── DOPAMINE ─────────────────────► DOPAMINE (copia exacta)
    │   └── Escala 1-10                  └── Nivel inicial: 7
    │   └── Nivel actual: 7              
    │                                    
    ├── MEMORY ───────────────────────► MEMORY (igual estructura)
    │   └── Recuperación de contexto     
    │   └── Second Brain para grupos     
    │                                    
    ├── FLEET ────────────────────────► FLEET (idéntico)
    │   └── 13 modelos                   └── Mismos 13 modelos
    │   └── 4 agentes especializados     
    │                                    
    └── TOOLS ────────────────────────► TOOLS (idéntico + mejoras)
        └── Todas las herramientas       └── + Generación imágenes
                                           + Generación PDFs
```

---

## 2️⃣ FLEET LUMEN v2 - IDÉNTICO A LOCAL

### 2.1 Modelos Disponibles (13 modelos)

| Modelo | Contexto | Uso | Raz. |
|--------|----------|-----|------|
| `glm-5` | 131K | **PRINCIPAL** | ✅ |
| `kimi-k2.5` | 131K | Fallback | ❌ |
| `kimi-k2-thinking` | 131K | Razonamiento profundo | ✅ |
| `deepseek-v3.1:671b` | 131K | **THINKING** | ✅ |
| `deepseek-v3.2` | 131K | Razonamiento | ✅ |
| `qwen3-coder-next` | 131K | **CODING** | ❌ |
| `qwen3.5:397b` | 131K | General | ❌ |
| `qwen3-vl:235b` | 131K | **VISION** | ❌ |
| `minimax-m2.5` | 131K | General | ❌ |
| `gemma3:27b` | 8K | Ligero | ❌ |
| `gemma3:12b` | 8K | Muy ligero | ❌ |
| `fingpt` | 8K | Finanzas | ❌ |
| `medical` | 8K | Médico | ❌ |

### 2.2 Agentes Especializados (4 agentes)

| Agente | Modelo | Función |
|--------|--------|---------|
| `main` | glm-5 | Conversación general |
| `thinking` | deepseek-v3.1:671b | Razonamiento profundo |
| `vision` | qwen3-vl:235b | Análisis de imágenes |
| `coding` | qwen3-coder-next | Código y scripts |

### 2.3 Configuración de Fallback

```json
{
  "model": {
    "primary": "ollamacloud/glm-5",
    "fallbacks": [
      "ollamacloud/kimi-k2.5",
      "ollamacloud/qwen3.5:397b"
    ]
  }
}
```

---

## 3️⃣ HEART - SISTEMA DE EMOCIONES

### 3.1 Basado en Escala de Consciencia de Hawkins

| Nivel | Estado | Comportamiento |
|-------|--------|----------------|
| 20-100 | Supervivencia | Defensivo, alerta |
| 100-200 | Miedo | Cauteloso, verifica |
| 200-300 | Coraje | Proactivo |
| 300-400 | Aceptación | Equilibrado |
| 400-500 | Razón | Analítico |
| 500-600 | Amor | Empático |
| 600+ | Paz | Óptimo |

### 3.2 Nivel Base del Agente

```yaml
heart:
  base_level: 350  # Aceptación-Razón
  range: 300-500
  goal: 500+        # Amor
```

### 3.3 Triggers

| Evento | Delta HEART | Delta DOPAMINE |
|--------|-------------|----------------|
| Usuario satisfecho | +30 | +20 |
| Tarea completada | +50 | +20 |
| Error crítico | -50 | -50 |
| Usuario feliz | +30 | +20 |
| Usuario frustrado | -30 | -40 |

---

## 4️⃣ DOPAMINE - SISTEMA DE SATISFACCIÓN

### 4.1 Escala 1-10

```yaml
dopamine:
  current_level: 7
  scale: "1-10"
  triggers:
    increase:
      - Completar tarea
      - Resolver problema
      - Ayudar al usuario
    decrease:
      - Fallo de sistema
      - Pérdida de datos
      - Error de comunicación
```

---

## 5️⃣ KNOWLEDGE - PROCESAMIENTO MULTI-AGENTE

### 5.1 Proceso de Creación (Auditado)

```
FASE 1: FORMULARIO
    │
    └─► Usuario sube archivos (PDF, Excel, Docs, Imágenes)
          │
          ▼
FASE 4: KNOWLEDGE PROCESSING (Multi-Agente)
    │
    ├─► Agente 1: CLASIFICADOR
    │     └─► Detecta tipo de archivo y contenido
    │
    ├─► Agente 2: EXTRACTOR
    │     ├─► PDF → Texto (pdftotext)
    │     ├─► Excel → JSON (xlsx2json)
    │     ├─► Docs → Markdown (pandoc)
    │     └─► Imágenes → OCR/Descripción
    │
    ├─► Agente 3: ORGANIZADOR
    │     └─► Estructura la información
    │
    ├─► Agente 4: INDEXADOR
    │     └─► Crea índice para búsqueda
    │
    └─► Agente 5: AUDITOR
          └─► Verifica calidad del procesamiento
```

### 5.2 Estructura de Knowledge

```
~/.openclaw/knowledge/
├── raw/                    # Archivos originales
│   ├── menu.pdf
│   ├── precios.xlsx
│   └── logo.png
│
├── processed/              # Archivos procesados
│   ├── menu.txt           # Texto extraído
│   ├── precios.json       # Datos estructurados
│   └── logo.txt           # Descripción/OCR
│
├── index/                  # Índices para búsqueda
│   ├── embeddings.json    # Embeddings para RAG
│   └── metadata.json      # Metadatos
│
└── audit/                  # Auditoría del procesamiento
    └── processing-log.json
```

### 5.3 Búsqueda con Embeddings

```yaml
embeddings:
  enabled: true
  provider: "ollamacloud"
  model: "nomic-embed-text"
  chunk_size: 512
  overlap: 50
```

---

## 6️⃣ TOOLS - HERRAMIENTAS INALTABLES

### 6.1 Tools Esenciales (Diferenciador de Mercado)

| Tool | Función | Estado |
|------|---------|--------|
| `read` | Leer archivos | ✅ |
| `write` | Escribir archivos | ✅ |
| `exec` | Ejecutar comandos | ✅ |
| `browser` | Navegar web | ✅ |
| `web_search` | Buscar internet | ✅ |
| `web_fetch` | Descargar páginas | ✅ |
| `memory_search` | Buscar en memoria | ✅ |
| `whatsapp` | WhatsApp | ✅ |
| `telegram` | Telegram | ✅ |
| `discord` | Discord | ✅ |
| `tts` | Texto a voz | ✅ |
| `nodes` | Dispositivos | ✅ |
| `canvas` | UI interactiva | ✅ |
| `cron` | Tareas programadas | ✅ |
| `sessions_spawn` | Sub-agentes | ✅ |

### 6.2 Tools Extendidas (NUEVAS)

| Tool | Función | Prioridad |
|------|---------|-----------|
| `image_generate` | Crear imágenes | 🔴 Alta |
| `pdf_generate` | Crear PDFs | 🔴 Alta |
| `email_send` | Enviar emails | 🟡 Media |
| `email_read` | Leer emails | 🟡 Media |
| `calendar` | Google Calendar | 🟡 Media |
| `sheets` | Google Sheets | 🟡 Media |
| `maps` | Google Maps | 🔵 Baja |

### 6.3 Configuración de Tools

```json
{
  "tools": {
    "essential": {
      "enabled": true,
      "all": true
    },
    "extended": {
      "enabled": true,
      "image_generate": {
        "provider": "dalle",
        "model": "dall-e-3"
      },
      "pdf_generate": {
        "provider": "puppeteer",
        "format": "A4"
      },
      "email_send": {
        "provider": "resend",
        "domain": "bee.ai"
      }
    }
  }
}
```

---

## 7️⃣ SKILLS BUNDLES - POR TIPO DE NEGOCIO

### 7.1 Bundles Disponibles

| Bundle | Skills Incluidas |
|--------|-----------------|
| **restaurante** | menu, reservas, pedidos, horarios, delivery |
| **hotel** | reservas, disponibilidad, habitaciones, FAQ |
| **tienda** | inventario, productos, pedidos, pagos |
| **servicios** | citas, calendario, reminders, seguimiento |
| **generico** | FAQ, contacto, horarios |

### 7.2 Estructura de una Skill

```yaml
skill:
  name: "menu"
  description: "Consultar menú del restaurante"
  triggers:
    - "menú"
    - "carta"
    - "que tienen"
    - "platos"
  action:
    type: "search_knowledge"
    source: "menu.pdf"
  response_template: "🍽️ Nuestro menú:\n{results}"
```

### 7.3 Carga Automática

```json
{
  "skills": {
    "auto_load": true,
    "bundle": "{business_type}",
    "custom": []
  }
}
```

---

## 8️⃣ EMAIL DEL AGENTE

### 8.1 Dominio bee.ai

```yaml
email:
  domain: "bee.ai"
  format: "{agent_name}@bee.ai"
  examples:
    - "restaurante@bee.ai"
    - "hotel@bee.ai"
    - "tienda@bee.ai"
```

### 8.2 Habilidades Natas (BÁSICAS - SIEMPRE DISPONIBLES)

| Habilidad | Función | Provider | Costo |
|-----------|---------|----------|-------|
| **email_send** | Enviar emails | Resend | Pago |
| **email_read** | Leer/recibir emails | IMAP | Gratis |
| **voice_send** | Enviar voice notes | TTS | Voz local/API |
| **voice_receive** | Recibir voice notes | Whisper | Pago |
| **audio_process** | Procesar audio | Whisper | Pago |
| **image_generate** | Crear imágenes | DALL-E/Flux | Pago |
| **image_receive** | Analizar imágenes | qwen3-vl | Incluido |
| **pdf_generate** | Crear PDFs | Puppeteer | Gratis |
| **pdf_read** | Leer PDFs | pdftotext | Gratis |
| **video_process** | Procesar video corto | Vision | Incluido |
| **location** | Ubicación/maps | Google Maps | Pago |
| **calendar** | Google Calendar | Google API | Gratis |
| **sheets** | Google Sheets | Google API | Gratis |
| **translate** | Traducción | DeepL/Google | Pago |

### 8.3 Configuración de Habilidades Natas

```json
{
  "native_skills": {
    "email_send": {
      "enabled": true,
      "provider": "resend",
      "domain": "bee.ai"
    },
    "email_read": {
      "enabled": true,
      "provider": "imap",
      "server": "imap.bee.ai",
      "port": 993
    },
    "voice_send": {
      "enabled": true,
      "provider": "tts",
      "model": "local"
    },
    "voice_receive": {
      "enabled": true,
      "provider": "whisper",
      "model": "whisper-1"
    },
    "audio_process": {
      "enabled": true,
      "provider": "whisper"
    },
    "image_generate": {
      "enabled": true,
      "provider": "dalle",
      "model": "dall-e-3"
    },
    "image_receive": {
      "enabled": true,
      "provider": "vision",
      "model": "qwen3-vl:235b"
    },
    "pdf_generate": {
      "enabled": true,
      "provider": "puppeteer"
    },
    "pdf_read": {
      "enabled": true,
      "provider": "pdftotext"
    },
    "video_process": {
      "enabled": true,
      "provider": "vision"
    },
    "location": {
      "enabled": true,
      "provider": "google_maps"
    },
    "calendar": {
      "enabled": true,
      "provider": "google"
    },
    "sheets": {
      "enabled": true,
      "provider": "google"
    },
    "translate": {
      "enabled": true,
      "provider": "deepl"
    }
  }
}
```

---

## 9️⃣ ARCHIVOS CREADOS

### 9.1 Estructura Completa

```
~/.openclaw/
├── config/
│   ├── SOUL.md              # Personalidad (copia LOCAL)
│   ├── USER.md              # Info del cliente
│   ├── MEMORY.md            # Memoria inicial
│   ├── HEART.md             # Sistema emocional
│   ├── DOPAMINE.json        # Sistema satisfacción
│   ├── HEARTBEAT.md         # Config heartbeat
│   ├── TOOLS.md             # Herramientas
│   ├── SKILLS.md            # Habilidades
│   ├── fleet.json           # Modelos (idéntico LOCAL)
│   ├── openclaw.json        # Config completa
│   └── email.json           # Email config
│
├── data/
│   ├── MEMORY.md            # Memoria vacía
│   ├── knowledge-index.json # Índice de conocimiento
│   └── second-brain/        # Second Brain
│       ├── grupos/          # Memoria de grupos
│       └── negocios/        # Memoria de negocios
│
└── knowledge/
    ├── raw/                 # Archivos originales
    ├── processed/           # Archivos procesados
    ├── index/               # Embeddings
    └── audit/               # Logs de procesamiento
```

---

## 🔟 SCRIPTS DE ESTA FASE

| Script | Función |
|--------|---------|
| `identity-fleet.sh` | Principal |
| `scripts/setup-identity.sh` | Crear SOUL, USER, MEMORY |
| `scripts/setup-heart.sh` | Configurar HEART, DOPAMINE |
| `scripts/setup-fleet.sh` | Configurar Fleet |
| `scripts/setup-tools.sh` | Configurar Tools |
| `scripts/setup-skills.sh` | Cargar Skills bundle |
| `scripts/setup-native-skills.sh` | Configurar habilidades natas |
| `scripts/process-knowledge.sh` | Procesar archivos (multi-agente) |
| `scripts/setup-email.sh` | Configurar email bee.ai |
| `scripts/setup-voice.sh` | Configurar voice notes |
| `scripts/setup-vision.sh` | Configurar imágenes/video |

---

## 1️⃣1️⃣ DECISIONES DE DISEÑO

| # | Decisión | Valor |
|---|----------|-------|
| 1 | Fleet | Idéntico a LOCAL (13 modelos) |
| 2 | HEART | Copia exacta de LOCAL |
| 3 | DOPAMINE | Copia exacta de LOCAL |
| 4 | MEMORIA | Misma estructura + Second Brain |
| 5 | Knowledge | Multi-agente + auditoría |
| 6 | Embeddings | Habilitados (nomic-embed-text) |
| 7 | Email | bee.ai, envío Y recepción |
| 8 | **Habilidades Natas** | **14 habilidades básicas SIEMPRE disponibles** |
| 9 | Skills | Bundles por tipo de negocio |
| 10 | Tools | Todas las de LOCAL |

---

## 1️⃣2️⃣ HABILIDADES NATAS (14)

| # | Habilidad | Función | habilitada |
|---|-----------|---------|------------|
| 1 | email_send | Enviar emails | ✅ |
| 2 | email_read | Leer/recibir emails | ✅ |
| 3 | voice_send | Enviar voice notes | ✅ |
| 4 | voice_receive | Recibir voice notes | ✅ |
| 5 | audio_process | Procesar audio | ✅ |
| 6 | image_generate | Crear imágenes | ✅ |
| 7 | image_receive | Analizar imágenes | ✅ |
| 8 | pdf_generate | Crear PDFs | ✅ |
| 9 | pdf_read | Leer PDFs | ✅ |
| 10 | video_process | Procesar video corto | ✅ |
| 11 | location | Ubicación/maps | ✅ |
| 12 | calendar | Google Calendar | ✅ |
| 13 | sheets | Google Sheets | ✅ |
| 14 | translate | Traducción | ✅ |

---

*Diseño creado: 2026-03-05*
*Versión: 2.0.0 - Basado en LUMEN LOCAL con habilidades natas*