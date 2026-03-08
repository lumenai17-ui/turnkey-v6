#!/bin/bash
#===============================================================================
# FASE 4: IDENTITY FLEET - Setup Skills (Super Agente v2.0)
#===============================================================================
# Propósito: Configurar 58 habilidades built-in del Super Agente
# Uso: ./setup-skills.sh --agent-name "nombre" [--business-type "tipo"]
# Versión: 2.0.0 — Agente en Mano
# Actualizado: 2026-03-07
#===============================================================================

set -euo pipefail

#-------------------------------------------------------------------------------
# CONFIGURACIÓN
#-------------------------------------------------------------------------------

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Directorios
readonly OPENCLAW_DIR="$HOME/.openclaw"
readonly CONFIG_DIR="$OPENCLAW_DIR/config"
readonly SECRETS_DIR="$OPENCLAW_DIR/workspace/secrets"

# Estado
CLEANUP_NEEDED=false
CREATED_FILES=()

#-------------------------------------------------------------------------------
# FUNCIONES
#-------------------------------------------------------------------------------

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

cleanup_on_failure() {
    local exit_code=$?
    
    if [[ "$CLEANUP_NEEDED" == "true" && $exit_code -ne 0 ]]; then
        log_error "Falló la configuración. Limpiando archivos parciales..."
        
        for file in "${CREATED_FILES[@]}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
                log_warning "Removido: $file"
            fi
        done
        
        rm -f "$CONFIG_DIR/.skills-status.json" 2>/dev/null || true
    fi
    
    exit $exit_code
}

mark_success() {
    CLEANUP_NEEDED=false
}

usage() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --agent-name NOMBRE     Nombre del agente (requerido)"
    echo "  --business-type TIPO    Tipo: restaurante, hotel, tienda, servicios, generico"
    echo "  --dry-run               Simular ejecución"
    echo "  --help                  Mostrar esta ayuda"
    echo ""
    echo "Modelo v2.0 — Agente en Mano:"
    echo "  58 habilidades BUILT-IN (todas funcionan siempre)"
    echo "  20 automatizaciones pre-configuradas"
    echo "  Costo aproximado: ~\$22/mes por agente"
    echo ""
    echo "Tipos de negocio y sus skills:"
    echo "  restaurante  → menu, reservas, pedidos, horarios, delivery"
    echo "  hotel        → reservas, disponibilidad, habitaciones, FAQ"
    echo "  tienda       → inventario, productos, pedidos, pagos"
    echo "  servicios    → citas, calendario, reminders, seguimiento"
    echo "  generico     → FAQ, contacto, horarios"
    echo ""
    echo "Ejemplo:"
    echo "  $0 --agent-name 'casamahana' --business-type 'restaurante'"
    exit 0
}

validate_json() {
    local file="$1"
    if command -v jq &>/dev/null; then
        if ! jq . "$file" > /dev/null 2>&1; then
            log_error "JSON inválido: $file"
            return 1
        fi
    fi
    return 0
}

#-------------------------------------------------------------------------------
# PARÁMETROS
#-------------------------------------------------------------------------------

# Trap para cleanup
trap cleanup_on_failure EXIT ERR

AGENT_NAME=""
BUSINESS_TYPE="generico"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --agent-name)
            AGENT_NAME="$2"
            shift 2
            ;;
        --business-type)
            BUSINESS_TYPE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Parámetro desconocido: $1"
            usage
            ;;
    esac
done

# Validar parámetros
if [[ -z "$AGENT_NAME" ]]; then
    log_error "--agent-name es obligatorio"
    usage
fi

# Normalizar business-type
case "$BUSINESS_TYPE" in
    restaurante|hotel|tienda|servicios|generico)
        ;;
    *)
        log_warning "business-type '$BUSINESS_TYPE' no reconocido, usando 'generico'"
        BUSINESS_TYPE="generico"
        ;;
esac

# Hacer variables readonly
readonly AGENT_NAME BUSINESS_TYPE DRY_RUN

#===============================================================================
# ENCABEZADO
#===============================================================================

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     FASE 4: IDENTITY FLEET - Setup Skills v2.0              ║${NC}"
echo -e "${BLUE}║     Agente en Mano — 58 Skills Built-in                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo -e "${YELLOW}[MODO DRY-RUN]${NC} Solo simulación"
    echo ""
fi

#===============================================================================
# VALIDAR PREREQUISITOS
#===============================================================================

CLEANUP_NEEDED=true

log_info "Verificando prerequisitos..."

# Verificar que existe fleet
if [[ ! -f "$CONFIG_DIR/.fleet-status.json" ]]; then
    log_error "Fleet no configurado"
    log_warning "Ejecutar primero: ./setup-fleet.sh"
    exit 1
fi

log_success "Fleet verificado"

#===============================================================================
# HABILIDADES BUILT-IN (58) — Todo funciona siempre
#===============================================================================

log_info "[1/4] Configurando 58 habilidades BUILT-IN..."

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "[DRY-RUN] Crearía: $CONFIG_DIR/skills-builtin.json"
else
    cat > "$CONFIG_DIR/skills-builtin.json" << 'BUILTIN_EOF'
{
  "version": "2.0.0",
  "model": "agente-en-mano",
  "description": "58 habilidades BUILT-IN — Todas funcionan siempre sin configuración del cliente",
  "total_skills": 58,
  "cost_per_month": "~$22",
  "skills": {
    "comunicacion": {
      "_count": 9,
      "email_send": {
        "enabled": true,
        "provider": "postfix",
        "processing": "local",
        "description": "Enviar emails desde nuestro dominio",
        "cost": "incluido"
      },
      "email_read": {
        "enabled": true,
        "provider": "dovecot",
        "processing": "local",
        "description": "Leer y procesar emails (IMAP)",
        "cost": "incluido"
      },
      "sms_send": {
        "enabled": true,
        "provider": "openclaw",
        "processing": "sistema",
        "description": "Enviar SMS",
        "cost": "incluido"
      },
      "whatsapp_send": {
        "enabled": true,
        "provider": "openclaw",
        "processing": "sistema",
        "description": "Enviar WhatsApp",
        "cost": "incluido"
      },
      "telegram_send": {
        "enabled": true,
        "provider": "openclaw",
        "processing": "sistema",
        "description": "Enviar Telegram",
        "cost": "incluido"
      },
      "discord_send": {
        "enabled": true,
        "provider": "openclaw",
        "processing": "sistema",
        "description": "Enviar Discord",
        "cost": "incluido"
      },
      "voice_receive": {
        "enabled": true,
        "provider": "deepgram_nova_stt",
        "processing": "api_externa",
        "description": "Recibir y transcribir voicenotes",
        "cost": "$0.006/min"
      },
      "voice_send": {
        "enabled": true,
        "provider": "deepgram_aura_tts",
        "processing": "api_externa",
        "description": "Generar voicenotes (TTS)",
        "cost": "$3/M chars"
      },
      "audio_transcribe": {
        "enabled": true,
        "provider": "deepgram_nova_stt",
        "processing": "api_externa",
        "description": "Transcribir audio",
        "cost": "$0.006/min"
      }
    },
    "multimedia": {
      "_count": 7,
      "image_receive": {
        "enabled": true,
        "provider": "ollamacloud_vision",
        "processing": "ollamacloud",
        "description": "Analizar imágenes",
        "cost": "incluido"
      },
      "image_generate": {
        "enabled": true,
        "provider": "stable_diffusion",
        "processing": "api_externa",
        "description": "Crear imágenes",
        "cost": "$0.01/img"
      },
      "image_edit": {
        "enabled": true,
        "provider": "stable_diffusion_img2img",
        "processing": "api_externa",
        "description": "Editar imágenes",
        "cost": "$0.01/img"
      },
      "video_process": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Analizar/procesar video",
        "cost": "incluido"
      },
      "video_create": {
        "enabled": true,
        "provider": "kling_2.1_fal",
        "processing": "api_externa",
        "description": "Crear video corto con IA",
        "cost": "$0.15/5s"
      },
      "video_edit": {
        "enabled": true,
        "provider": "ffmpeg",
        "processing": "local",
        "description": "Editar video",
        "cost": "incluido"
      },
      "ocr": {
        "enabled": true,
        "provider": "ollamacloud_vision",
        "processing": "ollamacloud",
        "description": "OCR de imágenes",
        "cost": "incluido"
      }
    },
    "documentos": {
      "_count": 8,
      "pdf_generate": {
        "enabled": true,
        "provider": "wkhtmltopdf",
        "processing": "local",
        "description": "Crear documentos PDF",
        "cost": "incluido"
      },
      "pdf_read": {
        "enabled": true,
        "provider": "pdftotext_tika",
        "processing": "local",
        "description": "Leer/extraer texto de PDFs",
        "cost": "incluido"
      },
      "pdf_edit": {
        "enabled": true,
        "provider": "qpdf_pdftk",
        "processing": "local",
        "description": "Editar/combinar PDFs",
        "cost": "incluido"
      },
      "doc_generate": {
        "enabled": true,
        "provider": "pandoc",
        "processing": "local",
        "description": "Crear documentos Word",
        "cost": "incluido"
      },
      "excel_generate": {
        "enabled": true,
        "provider": "python_openpyxl",
        "processing": "local",
        "description": "Crear Excel",
        "cost": "incluido"
      },
      "excel_read": {
        "enabled": true,
        "provider": "python_openpyxl",
        "processing": "local",
        "description": "Leer Excel",
        "cost": "incluido"
      },
      "presentation_create": {
        "enabled": true,
        "provider": "python_pptx",
        "processing": "local",
        "description": "Crear presentaciones PowerPoint",
        "cost": "incluido"
      },
      "invoice_generate": {
        "enabled": true,
        "provider": "wkhtmltopdf_templates",
        "processing": "local",
        "description": "Crear facturas",
        "cost": "incluido"
      }
    },
    "web_automatizacion": {
      "_count": 8,
      "browser": {
        "enabled": true,
        "provider": "puppeteer",
        "processing": "local",
        "description": "Navegador automatizado",
        "cost": "incluido"
      },
      "scraping": {
        "enabled": true,
        "provider": "puppeteer_cheerio",
        "processing": "local",
        "description": "Web scraping",
        "cost": "incluido"
      },
      "web_search": {
        "enabled": true,
        "provider": "brave_search",
        "processing": "api_externa",
        "description": "Búsqueda web",
        "cost": "free tier"
      },
      "web_fetch": {
        "enabled": true,
        "provider": "curl_fetch",
        "processing": "local",
        "description": "Fetch URL contenido",
        "cost": "incluido"
      },
      "web_create": {
        "enabled": true,
        "provider": "templates_cloudflare",
        "processing": "local",
        "description": "Crear sitio web",
        "cost": "incluido"
      },
      "form_create": {
        "enabled": true,
        "provider": "html_templates",
        "processing": "local",
        "description": "Crear formularios HTML",
        "cost": "incluido"
      },
      "cron": {
        "enabled": true,
        "provider": "cron_systemd",
        "processing": "local",
        "description": "Tareas programadas",
        "cost": "incluido"
      },
      "webhook": {
        "enabled": true,
        "provider": "http_server",
        "processing": "local",
        "description": "Webhooks entrantes/salientes",
        "cost": "incluido"
      }
    },
    "inteligencia": {
      "_count": 7,
      "summarize": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Resumir textos",
        "cost": "incluido"
      },
      "extract_data": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Extraer datos estructurados",
        "cost": "incluido"
      },
      "sentiment": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Análisis de sentimiento",
        "cost": "incluido"
      },
      "translate": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Traducción multilenguaje",
        "cost": "incluido"
      },
      "memory_search": {
        "enabled": true,
        "provider": "ollamacloud_nomic_embed",
        "processing": "ollamacloud",
        "description": "Memoria persistente (embeddings)",
        "cost": "incluido"
      },
      "classify": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Clasificar textos/intents",
        "cost": "incluido"
      },
      "rewrite": {
        "enabled": true,
        "provider": "ollamacloud",
        "processing": "ollamacloud",
        "description": "Reescribir textos (tono, estilo)",
        "cost": "incluido"
      }
    },
    "negocio": {
      "_count": 6,
      "report_generate": {
        "enabled": true,
        "provider": "wkhtmltopdf",
        "processing": "local",
        "description": "Crear reportes",
        "cost": "incluido"
      },
      "qrcode_generate": {
        "enabled": true,
        "provider": "qrencode",
        "processing": "local",
        "description": "Generar códigos QR",
        "cost": "incluido"
      },
      "qrcode_read": {
        "enabled": true,
        "provider": "ollamacloud_vision",
        "processing": "ollamacloud",
        "description": "Leer códigos QR",
        "cost": "incluido"
      },
      "metrics_dashboard": {
        "enabled": true,
        "provider": "chartsjs_html",
        "processing": "local",
        "description": "Dashboard de métricas",
        "cost": "incluido"
      },
      "notifications": {
        "enabled": true,
        "provider": "canales_existentes",
        "processing": "local",
        "description": "Sistema de notificaciones",
        "cost": "incluido"
      },
      "reviews_monitor": {
        "enabled": true,
        "provider": "scraping_cron",
        "processing": "local",
        "description": "Monitorear reseñas",
        "cost": "incluido"
      }
    },
    "email_marketing": {
      "_count": 4,
      "newsletter_send": {
        "enabled": true,
        "provider": "postfix_smtp",
        "processing": "local",
        "description": "Enviar newsletters masivos",
        "cost": "incluido"
      },
      "email_templates": {
        "enabled": true,
        "provider": "sistema",
        "processing": "local",
        "description": "Templates de email HTML",
        "cost": "incluido"
      },
      "email_tracking": {
        "enabled": true,
        "provider": "webhook_pixel",
        "processing": "local",
        "description": "Tracking de apertura/clicks",
        "cost": "incluido"
      },
      "email_drip": {
        "enabled": true,
        "provider": "cron_smtp",
        "processing": "local",
        "description": "Secuencias de email automatizadas",
        "cost": "incluido"
      }
    },
    "codigo": {
      "_count": 3,
      "code_execute": {
        "enabled": true,
        "provider": "sandbox",
        "processing": "local",
        "description": "Ejecutar código en sandbox",
        "cost": "incluido"
      },
      "git_commit": {
        "enabled": true,
        "provider": "git",
        "processing": "local",
        "description": "Git commits",
        "cost": "incluido"
      },
      "repo_read": {
        "enabled": true,
        "provider": "git",
        "processing": "local",
        "description": "Leer repositorios",
        "cost": "incluido"
      }
    },
    "productividad": {
      "_count": 2,
      "reminders": {
        "enabled": true,
        "provider": "cron_canales",
        "processing": "local",
        "description": "Recordatorios automáticos",
        "cost": "incluido"
      },
      "tasks": {
        "enabled": true,
        "provider": "sistema",
        "processing": "local",
        "description": "Gestión de tareas/pendientes",
        "cost": "incluido"
      }
    },
    "google_workspace": {
      "_count": 4,
      "calendar": {
        "enabled": true,
        "provider": "google_calendar_api",
        "processing": "google_api",
        "description": "Google Calendar (nosotros configuramos)",
        "cost": "incluido"
      },
      "sheets": {
        "enabled": true,
        "provider": "google_sheets_api",
        "processing": "google_api",
        "description": "Google Sheets (nosotros configuramos)",
        "cost": "incluido"
      },
      "location": {
        "enabled": true,
        "provider": "google_maps_api",
        "processing": "google_api",
        "description": "Maps y ubicación (nuestra key)",
        "cost": "~$5/mes"
      },
      "directions": {
        "enabled": true,
        "provider": "google_maps_api",
        "processing": "google_api",
        "description": "Rutas y distancias (nuestra key)",
        "cost": "incluido en maps"
      }
    }
  }
}
BUILTIN_EOF

    if validate_json "$CONFIG_DIR/skills-builtin.json"; then
        CREATED_FILES+=("$CONFIG_DIR/skills-builtin.json")
        log_success "58 habilidades BUILT-IN configuradas"
    else
        log_error "Error creando skills-builtin.json"
        exit 1
    fi

    # Eliminar archivos del modelo viejo si existen
    if [[ -f "$CONFIG_DIR/skills-core.json" ]]; then
        rm -f "$CONFIG_DIR/skills-core.json"
        log_warning "Eliminado modelo viejo: skills-core.json"
    fi
    if [[ -f "$CONFIG_DIR/skills-optional.json" ]]; then
        rm -f "$CONFIG_DIR/skills-optional.json"
        log_warning "Eliminado modelo viejo: skills-optional.json"
    fi
fi

#===============================================================================
# AUTOMATIZACIONES BUILT-IN (20)
#===============================================================================

log_info "[2/4] Vinculando 20 automatizaciones built-in..."

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "[DRY-RUN] Vincularía automatizaciones-builtin.json"
else
    # Verificar que existe automatizaciones-builtin.json en el directorio de fase
    AUTOMATIONS_SOURCE="$(dirname "$(dirname "$0")")/automatizaciones-builtin.json"

    if [[ -f "$AUTOMATIONS_SOURCE" ]]; then
        cp "$AUTOMATIONS_SOURCE" "$CONFIG_DIR/automatizaciones-builtin.json"
        CREATED_FILES+=("$CONFIG_DIR/automatizaciones-builtin.json")
        log_success "20 automatizaciones vinculadas"
    else
        log_warning "automatizaciones-builtin.json no encontrado en fase, se creará en activación"
    fi
fi

#===============================================================================
# SKILLS BUNDLE (por tipo de negocio)
#===============================================================================

log_info "[3/4] Configurando Skills Bundle para '$BUSINESS_TYPE'..."

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "[DRY-RUN] Crearía: $CONFIG_DIR/skills-bundle.json"
else
    # Bundle según tipo de negocio
    case "$BUSINESS_TYPE" in
        restaurante)
            BUNDLE_DESC="Habilidades para restaurantes"
            BUNDLE='{"bundle":"restaurante","skills":["menu","reservas","pedidos","horarios","delivery","faq"],"context":{"menu":"Puedo consultar el menú y precios.","reservas":"Puedo gestionar reservaciones.","pedidos":"Puedo tomar pedidos para llevar o delivery.","horarios":"Puedo informar horarios de atención.","delivery":"Puedo coordinar entregas a domicilio."}}'
            ;;
        hotel)
            BUNDLE_DESC="Habilidades para hoteles"
            BUNDLE='{"bundle":"hotel","skills":["reservas","disponibilidad","habitaciones","faq","checkin","amenidades"],"context":{"reservas":"Puedo gestionar reservaciones de habitaciones.","disponibilidad":"Puedo consultar disponibilidad en tiempo real.","habitaciones":"Puedo mostrar tipos de habitaciones y precios.","faq":"Puedo responder preguntas frecuentes del hotel.","checkin":"Puedo gestionar check-in y check-out.","amenidades":"Puedo informar sobre servicios del hotel."}}'
            ;;
        tienda)
            BUNDLE_DESC="Habilidades para tiendas"
            BUNDLE='{"bundle":"tienda","skills":["inventario","productos","pedidos","pagos","faq","envios"],"context":{"inventario":"Puedo consultar disponibilidad de productos.","productos":"Puedo mostrar catálogo y precios.","pedidos":"Puedo procesar pedidos.","pagos":"Puedo informar métodos de pago.","faq":"Puedo responder preguntas frecuentes.","envios":"Puedo coordinar envíos."}}'
            ;;
        servicios)
            BUNDLE_DESC="Habilidades para servicios"
            BUNDLE='{"bundle":"servicios","skills":["citas","calendario","reminders","seguimiento","faq","pagos"],"context":{"citas":"Puedo agendar y gestionar citas.","calendario":"Puedo mostrar disponibilidad.","reminders":"Puedo enviar recordatorios.","seguimiento":"Puedo dar seguimiento a clientes.","faq":"Puedo responder preguntas frecuentes.","pagos":"Puedo informar sobre pagos."}}'
            ;;
        *)
            BUNDLE_DESC="Habilidades genéricas"
            BUNDLE='{"bundle":"generico","skills":["faq","contacto","horarios","info","ayuda"],"context":{"faq":"Puedo responder preguntas frecuentes.","contacto":"Puedo proporcionar información de contacto.","horarios":"Puedo informar horarios de atención.","info":"Puedo dar información general.","ayuda":"Puedo ayudar con consultas diversas."}}'
            ;;
    esac

    echo "$BUNDLE" > "$CONFIG_DIR/skills-bundle.json"
    
    if validate_json "$CONFIG_DIR/skills-bundle.json"; then
        CREATED_FILES+=("$CONFIG_DIR/skills-bundle.json")
        log_success "Skills Bundle: $BUNDLE_DESC"
    else
        log_error "Error creando skills-bundle.json"
        exit 1
    fi
fi

#===============================================================================
# SKILLS.MD — Documentación generada
#===============================================================================

log_info "[4/4] Generando SKILLS.md..."

if [[ "$DRY_RUN" == "true" ]]; then
    log_warning "[DRY-RUN] Crearía: $CONFIG_DIR/SKILLS.md"
else
    cat > "$CONFIG_DIR/SKILLS.md" << SKILLSEOF
# SKILLS - Habilidades del Super Agente v2.0

**Agente:** ${AGENT_NAME}
**Tipo de negocio:** ${BUSINESS_TYPE}
**Total habilidades:** 58 BUILT-IN (todas funcionan siempre)
**Automatizaciones:** 20 pre-configuradas
**Actualizado:** $(date -Iseconds)

---

## Modelo: Agente en Mano

TODAS las 58 habilidades funcionan desde el día 1, sin configuración del cliente.

### Procesamiento

| Tipo | Proveedor | Costo |
|------|-----------|-------|
| ⚙️ Local | VPS (documentos, email, scraping, código) | Incluido |
| ☁️ Ollama Cloud | Inteligencia (∞ tokens) | Incluido |
| 🎬 Multimedia | Deepgram, Stable Diffusion, Kling 2.1 | ~\$17/mes |
| 🔗 Google | Calendar, Sheets, Maps | ~\$5/mes |

**Costo total por agente:** ~\$22/mes

---

## 58 Skills Built-in

### 📱 Comunicación (9)
- email_send — Enviar emails (Postfix local)
- email_read — Leer emails (Dovecot IMAP)
- sms_send — Enviar SMS
- whatsapp_send — Enviar WhatsApp
- telegram_send — Enviar Telegram
- discord_send — Enviar Discord
- voice_receive — Recibir voicenotes (Deepgram Nova STT)
- voice_send — Enviar voicenotes (Deepgram Aura TTS)
- audio_transcribe — Transcribir audio (Deepgram Nova STT)

### 🖼️ Multimedia (7)
- image_receive — Analizar imágenes (Ollama Cloud Vision)
- image_generate — Crear imágenes (Stable Diffusion)
- image_edit — Editar imágenes (SD img2img)
- video_process — Procesar video (Ollama Cloud)
- video_create — Crear video (Kling 2.1 via fal.ai)
- video_edit — Editar video (FFmpeg local)
- ocr — OCR de imágenes (Ollama Cloud Vision)

### 📄 Documentos (8)
- pdf_generate — Crear PDFs (wkhtmltopdf)
- pdf_read — Leer PDFs (pdftotext/Tika)
- pdf_edit — Editar PDFs (qpdf/pdftk)
- doc_generate — Crear Word (pandoc)
- excel_generate — Crear Excel (openpyxl)
- excel_read — Leer Excel (openpyxl)
- presentation_create — Crear presentaciones (python-pptx)
- invoice_generate — Crear facturas (wkhtmltopdf + templates)

### 🌐 Web & Automatización (8)
- browser — Navegador automatizado (Puppeteer)
- scraping — Web scraping (Puppeteer + cheerio)
- web_search — Búsqueda web (Brave free tier)
- web_fetch — Fetch URL (curl/fetch)
- web_create — Crear sitio web (templates + Cloudflare)
- form_create — Crear formularios (HTML templates)
- cron — Tareas programadas (cron/systemd)
- webhook — Webhooks (HTTP server)

### 🧠 Inteligencia (7)
- summarize — Resumir textos (Ollama Cloud)
- extract_data — Extraer datos (Ollama Cloud)
- sentiment — Análisis sentimiento (Ollama Cloud)
- translate — Traducción (Ollama Cloud)
- memory_search — Memoria persistente (Nomic Embed)
- classify — Clasificar textos (Ollama Cloud)
- rewrite — Reescribir textos (Ollama Cloud)

### 📊 Negocio (6)
- report_generate — Crear reportes
- qrcode_generate — Generar QR
- qrcode_read — Leer QR
- metrics_dashboard — Dashboard métricas
- notifications — Sistema notificaciones
- reviews_monitor — Monitorear reseñas

### 📨 Email Marketing (4)
- newsletter_send — Newsletters (Postfix SMTP)
- email_templates — Templates email
- email_tracking — Tracking apertura/clicks
- email_drip — Secuencias automatizadas

### 💻 Código (3)
- code_execute — Ejecutar código (sandbox)
- git_commit — Git commits
- repo_read — Leer repos

### 📅 Productividad (2)
- reminders — Recordatorios (cron + canales)
- tasks — Tareas/pendientes

### 🔗 Google Workspace (4)
- calendar — Google Calendar (nosotros configuramos)
- sheets — Google Sheets (nosotros configuramos)
- location — Maps/ubicación (nuestra key)
- directions — Rutas/distancias (nuestra key)

---

## Bundle: ${BUSINESS_TYPE}

${BUNDLE_DESC}

---

*Habilidades configuradas en FASE 4 — Modelo v2.0 Agente en Mano.*
SKILLSEOF

    CREATED_FILES+=("$CONFIG_DIR/SKILLS.md")
    log_success "SKILLS.md generado"
fi

#===============================================================================
# GUARDAR ESTADO
#===============================================================================

if [[ "$DRY_RUN" != "true" ]]; then
    log_info "Guardando estado..."
    
    cat > "$CONFIG_DIR/.skills-status.json" << EOF
{
  "status": "completed",
  "model": "agente-en-mano",
  "version": "2.0.0",
  "agent_name": "${AGENT_NAME}",
  "business_type": "${BUSINESS_TYPE}",
  "total_skills": 58,
  "builtin_skills": 58,
  "optional_skills": 0,
  "automations": 20,
  "bundle": "${BUSINESS_TYPE}",
  "cost_per_month": "~\$22",
  "created_at": "$(date -Iseconds)"
}
EOF

    validate_json "$CONFIG_DIR/.skills-status.json" || true
fi

mark_success

#===============================================================================
# RESUMEN
#===============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         SKILLS SETUP v2.0 COMPLETADO                         ║${NC}"
echo -e "${GREEN}║           Agente en Mano — 58 Built-in                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Agente:${NC} ${AGENT_NAME}"
echo -e "${BLUE}Tipo de negocio:${NC} ${BUSINESS_TYPE}"
echo -e "${BLUE}Costo mensual:${NC} ~\$22/mes"
echo ""
echo -e "${BLUE}Habilidades configuradas:${NC}"
echo -e "   ${GREEN}✓${NC} 58 habilidades BUILT-IN (todas funcionan siempre)"
echo -e "   ${GREEN}✓${NC} 20 automatizaciones pre-configuradas"
echo -e "   ${GREEN}✓${NC} Bundle: ${BUSINESS_TYPE}"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/skills-builtin.json (58 skills)"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/automatizaciones-builtin.json (20 automations)"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/skills-bundle.json (${BUSINESS_TYPE})"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/SKILLS.md"
echo ""
echo -e "${BLUE}Procesamiento:${NC}"
echo -e "   ⚙️  Local (VPS): documentos, email, scraping, código"
echo -e "   ☁️  Ollama Cloud: inteligencia (∞ tokens)"
echo -e "   🎬 APIs externas: Deepgram + SD + Kling (~\$17/mes)"
echo -e "   🔗 Google APIs: Calendar + Sheets + Maps (~\$5/mes)"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} ./process-knowledge.sh --agent-name '${AGENT_NAME}'"
echo ""

exit 0