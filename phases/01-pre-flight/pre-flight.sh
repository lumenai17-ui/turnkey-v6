#!/bin/bash
# ==============================================================================
# pre-flight.sh — FASE 1: PRE-FLIGHT
# ==============================================================================
# Validación completa del entorno antes de instalar.
# Soporta modo config (--config FILE) y modo interactivo (--interactive).
#
# TURNKEY v6 — Modelo v2.0.0 (Agente en Mano)
# 58 skills built-in + 20 automatizaciones
# ==============================================================================

set -euo pipefail

readonly VERSION="6.2.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
readonly WORK_DIR="${HOME}/.openclaw/workspace/turnkey"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Opciones
CONFIG_FILE=""
INTERACTIVE=false
FORCE=false
WARNINGS=0
ERRORS=0

# ============================
# Config values — IDENTIDAD
# ============================
DEPLOY_TYPE=""
AGENT_NAME=""
BUSINESS_NAME=""
BUSINESS_TYPE="generico"
AGENT_ROLE=""
AGENT_EMOJI="🤖"
AGENT_LANG="es"
AGENT_LANG2=""
AGENT_PORT=18789
TIMEZONE="America/Bogota"
BUSINESS_HOURS_WEEKDAY=""
BUSINESS_HOURS_SAT=""
BUSINESS_HOURS_SUN=""

# ============================
# Config values — BRANDING
# ============================
BRAND_PRIMARY_COLOR=""
BRAND_SECONDARY_COLOR=""
BRAND_ACCENT_COLOR=""
BRAND_TONE="profesional_y_amigable"
BRAND_LOGO=""

# ============================
# Config values — CONTACTO
# ============================
OWNER_NAME=""
OWNER_PHONE=""
OWNER_EMAIL=""
OWNER_TELEGRAM_ID=""
BUSINESS_PHONE=""
BUSINESS_EMAIL=""
BUSINESS_ADDRESS=""
BUSINESS_WEBSITE=""

# ============================
# Config values — CANALES
# ============================
TG_ENABLED="false"
TG_CREATE_NEW="true"
TG_TOKEN=""
TG_USERS=""
EMAIL_ENABLED="true"
EMAIL_USE_OURS="true"
WA_ENABLED="false"
WA_NUMBER=""
DISCORD_ENABLED="false"

# ============================
# Config values — GOOGLE APIS
# ============================
GCAL_ENABLED="false"
GCAL_EMAIL=""
GSHEETS_ENABLED="false"
GMAPS_ENABLED="true"

# ============================
# Config values — INTEGRACIONES
# ============================
WP_ENABLED="false"
WP_URL=""
WP_USER=""
WP_APP_PASSWORD=""
META_ADS_ENABLED="false"
STRIPE_ENABLED="false"
GMB_ENABLED="false"
GMB_URL=""

# ============================
# Config values — MODELOS
# ============================
MODEL_PRIMARY="gemma3"
MODEL_FALLBACK="llama4"
MODEL_VISION="qwen3-vl"
MODEL_EMBEDDINGS="nomic-embed"

# ============================
# Config values — AUTOMATIONS
# ============================
AUTOMATIONS_ENABLED=""

# ==============================================================================
# LOGGING
# ==============================================================================

log_info()    { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)) || true; }
log_error()   { echo -e "  ${RED}✗${NC} $1" >&2; ((ERRORS++)) || true; }
log_step()    { echo -e "\n${BLUE}═══ $1 ═══${NC}"; }

show_header() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       TURNKEY v6 — FASE 1: PRE-FLIGHT (v2.0)                 ║${NC}"
    echo -e "${GREEN}║       58 skills built-in + 20 automatizaciones               ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==============================================================================
# PARSE ARGS
# ==============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --config)      CONFIG_FILE="$2"; shift 2 ;;
            --interactive) INTERACTIVE=true; shift ;;
            --force)       FORCE=true; shift ;;
            --help)
                echo "Uso: $0 [--config FILE] [--interactive] [--force]"
                echo ""
                echo "  --config FILE      Cargar configuración desde JSON (v2.0)"
                echo "  --interactive      Modo interactivo (pregunta paso a paso)"
                echo "  --force            Continuar aunque haya warnings"
                echo "  --help             Mostrar ayuda"
                exit 0
                ;;
            *) echo "Opción desconocida: $1"; exit 1 ;;
        esac
    done

    if [[ -z "$CONFIG_FILE" ]]; then
        INTERACTIVE=true
    fi
}

# ==============================================================================
# LOAD CONFIG FROM JSON (v2.0 format)
# ==============================================================================

load_config() {
    if [[ -z "$CONFIG_FILE" || ! -f "$CONFIG_FILE" ]]; then
        return 0
    fi

    log_step "CARGANDO CONFIGURACIÓN v2.0"

    if ! command -v jq &>/dev/null; then
        log_error "jq es necesario para leer config JSON. Instale: apt install jq"
        return 1
    fi

    if ! jq . "$CONFIG_FILE" > /dev/null 2>&1; then
        log_error "JSON inválido: $CONFIG_FILE"
        return 1
    fi

    # Check version
    local cfg_version
    cfg_version=$(jq -r '.version // "1.0.0"' "$CONFIG_FILE")
    if [[ "$cfg_version" != "2.0.0" ]]; then
        log_warn "Config file es versión $cfg_version (esperado 2.0.0)"
    fi

    # === IDENTIDAD ===
    DEPLOY_TYPE=$(jq -r '.deployment.type // "auto-detect"' "$CONFIG_FILE")
    AGENT_NAME=$(jq -r '.agent.name // ""' "$CONFIG_FILE")
    BUSINESS_NAME=$(jq -r '.agent.business_name // ""' "$CONFIG_FILE")
    BUSINESS_TYPE=$(jq -r '.agent.business_type // "generico"' "$CONFIG_FILE")
    AGENT_ROLE=$(jq -r '.agent.role // "Asistente virtual"' "$CONFIG_FILE")
    AGENT_EMOJI=$(jq -r '.agent.emoji // "🤖"' "$CONFIG_FILE")
    AGENT_LANG=$(jq -r '.agent.language // "es"' "$CONFIG_FILE")
    AGENT_LANG2=$(jq -r '.agent.secondary_language // ""' "$CONFIG_FILE")
    AGENT_PORT=$(jq -r '.agent.port // 18789' "$CONFIG_FILE")
    TIMEZONE=$(jq -r '.agent.timezone // "America/Bogota"' "$CONFIG_FILE")
    BUSINESS_HOURS_WEEKDAY=$(jq -r '.agent.business_hours.weekdays // ""' "$CONFIG_FILE")
    BUSINESS_HOURS_SAT=$(jq -r '.agent.business_hours.saturday // ""' "$CONFIG_FILE")
    BUSINESS_HOURS_SUN=$(jq -r '.agent.business_hours.sunday // ""' "$CONFIG_FILE")

    # === BRANDING ===
    BRAND_PRIMARY_COLOR=$(jq -r '.branding.primary_color // ""' "$CONFIG_FILE")
    BRAND_SECONDARY_COLOR=$(jq -r '.branding.secondary_color // ""' "$CONFIG_FILE")
    BRAND_ACCENT_COLOR=$(jq -r '.branding.accent_color // ""' "$CONFIG_FILE")
    BRAND_TONE=$(jq -r '.branding.tone // "profesional_y_amigable"' "$CONFIG_FILE")
    BRAND_LOGO=$(jq -r '.branding.logo_path // ""' "$CONFIG_FILE")

    # === CONTACTO ===
    OWNER_NAME=$(jq -r '.contact.owner_name // ""' "$CONFIG_FILE")
    OWNER_PHONE=$(jq -r '.contact.owner_phone // ""' "$CONFIG_FILE")
    OWNER_EMAIL=$(jq -r '.contact.owner_email // ""' "$CONFIG_FILE")
    OWNER_TELEGRAM_ID=$(jq -r '.contact.owner_telegram_id // ""' "$CONFIG_FILE")
    BUSINESS_PHONE=$(jq -r '.contact.business_phone // ""' "$CONFIG_FILE")
    BUSINESS_EMAIL=$(jq -r '.contact.business_email // ""' "$CONFIG_FILE")
    BUSINESS_ADDRESS=$(jq -r '.contact.address // ""' "$CONFIG_FILE")
    BUSINESS_WEBSITE=$(jq -r '.contact.website // ""' "$CONFIG_FILE")

    # === CANALES ===
    TG_ENABLED=$(jq -r '.channels.telegram.enabled // false' "$CONFIG_FILE")
    TG_CREATE_NEW=$(jq -r '.channels.telegram.create_new_bot // true' "$CONFIG_FILE")
    TG_TOKEN=$(jq -r '.channels.telegram.bot_token // ""' "$CONFIG_FILE")
    TG_USERS=$(jq -r '(.channels.telegram.allowed_users // []) | join(",")' "$CONFIG_FILE")
    EMAIL_ENABLED=$(jq -r '.channels.email.enabled // true' "$CONFIG_FILE")
    EMAIL_USE_OURS=$(jq -r '.channels.email.use_our_domain // true' "$CONFIG_FILE")
    WA_ENABLED=$(jq -r '.channels.whatsapp.enabled // false' "$CONFIG_FILE")
    WA_NUMBER=$(jq -r '.channels.whatsapp.number // ""' "$CONFIG_FILE")
    DISCORD_ENABLED=$(jq -r '.channels.discord.enabled // false' "$CONFIG_FILE")

    # === GOOGLE APIS ===
    GCAL_ENABLED=$(jq -r '.google_apis.calendar.enabled // false' "$CONFIG_FILE")
    GCAL_EMAIL=$(jq -r '.google_apis.calendar.google_account_email // ""' "$CONFIG_FILE")
    GSHEETS_ENABLED=$(jq -r '.google_apis.sheets.enabled // false' "$CONFIG_FILE")
    GMAPS_ENABLED=$(jq -r '.google_apis.maps.enabled // true' "$CONFIG_FILE")

    # === INTEGRACIONES ===
    WP_ENABLED=$(jq -r '.integrations.wordpress.enabled // false' "$CONFIG_FILE")
    WP_URL=$(jq -r '.integrations.wordpress.url // ""' "$CONFIG_FILE")
    META_ADS_ENABLED=$(jq -r '.integrations.meta_ads.enabled // false' "$CONFIG_FILE")
    STRIPE_ENABLED=$(jq -r '.integrations.stripe.enabled // false' "$CONFIG_FILE")
    GMB_ENABLED=$(jq -r '.integrations.google_my_business.enabled // false' "$CONFIG_FILE")

    # === MODELOS ===
    MODEL_PRIMARY=$(jq -r '.models.primary // "gemma3"' "$CONFIG_FILE")
    MODEL_FALLBACK=$(jq -r '.models.fallback // "llama4"' "$CONFIG_FILE")
    MODEL_VISION=$(jq -r '.models.vision // "qwen3-vl"' "$CONFIG_FILE")
    MODEL_EMBEDDINGS=$(jq -r '.models.embeddings // "nomic-embed"' "$CONFIG_FILE")

    # === AUTOMATIZACIONES ===
    AUTOMATIONS_ENABLED=$(jq -r '(.automations.enabled // []) | join(",")' "$CONFIG_FILE")

    log_info "Configuración v2.0 cargada: agente '${AGENT_NAME}' (${BUSINESS_TYPE})"
}

# ==============================================================================
# INTERACTIVE MODE (v2.0)
# ==============================================================================

ask_interactive() {
    [[ "$INTERACTIVE" != "true" ]] && return 0

    log_step "1/7 — IDENTIDAD DEL NEGOCIO"

    if [[ -z "$AGENT_NAME" ]]; then
        echo -ne "  ${CYAN}?${NC} Nombre del agente: "
        read -r AGENT_NAME
        AGENT_NAME="${AGENT_NAME:-Agente}"
    fi

    if [[ -z "$BUSINESS_NAME" ]]; then
        echo -ne "  ${CYAN}?${NC} Nombre del negocio: "
        read -r BUSINESS_NAME
        BUSINESS_NAME="${BUSINESS_NAME:-$AGENT_NAME}"
    fi

    echo -e "  ${CYAN}?${NC} Tipo de negocio:"
    echo "    1) restaurante     2) hotel"
    echo "    3) tienda          4) servicios"
    echo "    5) salud_belleza   6) fitness"
    echo "    7) educacion       8) inmobiliaria"
    echo "    9) ecommerce       0) generico"
    echo -ne "  Selecciona [0-9] (0): "
    read -r type_choice
    case "$type_choice" in
        1) BUSINESS_TYPE="restaurante" ;;
        2) BUSINESS_TYPE="hotel" ;;
        3) BUSINESS_TYPE="tienda" ;;
        4) BUSINESS_TYPE="servicios" ;;
        5) BUSINESS_TYPE="salud_belleza" ;;
        6) BUSINESS_TYPE="fitness" ;;
        7) BUSINESS_TYPE="educacion" ;;
        8) BUSINESS_TYPE="inmobiliaria" ;;
        9) BUSINESS_TYPE="ecommerce" ;;
        *) BUSINESS_TYPE="generico" ;;
    esac

    echo -ne "  ${CYAN}?${NC} Timezone [America/Bogota]: "
    read -r tz_input
    TIMEZONE="${tz_input:-America/Bogota}"

    # === BRANDING ===
    log_step "2/7 — BRANDING"

    echo -ne "  ${CYAN}?${NC} Color primario HEX [dejar vacío para default]: #"
    read -r color_input
    BRAND_PRIMARY_COLOR="${color_input:+#$color_input}"

    echo -e "  ${CYAN}?${NC} Tono de comunicación:"
    echo "    1) Profesional y formal"
    echo "    2) Profesional y amigable"
    echo "    3) Casual y cercano"
    echo "    4) Divertido y relajado"
    echo -ne "  Selecciona [1-4] (2): "
    read -r tone_choice
    case "$tone_choice" in
        1) BRAND_TONE="profesional_formal" ;;
        3) BRAND_TONE="casual_cercano" ;;
        4) BRAND_TONE="divertido_relajado" ;;
        *) BRAND_TONE="profesional_y_amigable" ;;
    esac

    # === CONTACTO ===
    log_step "3/7 — CONTACTO DEL DUEÑO"

    echo -ne "  ${CYAN}?${NC} Nombre del dueño/admin: "
    read -r OWNER_NAME

    echo -ne "  ${CYAN}?${NC} Email del dueño: "
    read -r OWNER_EMAIL

    echo -ne "  ${CYAN}?${NC} Teléfono del dueño: "
    read -r OWNER_PHONE

    echo -ne "  ${CYAN}?${NC} Website del negocio (si tiene): "
    read -r BUSINESS_WEBSITE

    # === CANALES ===
    log_step "4/7 — CANALES DE COMUNICACIÓN"

    echo -ne "  ${CYAN}?${NC} ¿Activar Telegram? (s/n) [s]: "
    read -r tg_answer
    if [[ ! "$tg_answer" =~ ^[nN] ]]; then
        TG_ENABLED="true"
        echo -ne "  ${CYAN}?${NC} ¿Crear bot nuevo? (s/n) [s]: "
        read -r tg_new
        if [[ "$tg_new" =~ ^[nN] ]]; then
            TG_CREATE_NEW="false"
            echo -ne "  ${CYAN}?${NC} Token del bot existente: "
            read -r TG_TOKEN
        fi
        echo -ne "  ${CYAN}?${NC} Tu Telegram User ID: "
        read -r TG_USERS
    fi

    echo -ne "  ${CYAN}?${NC} ¿Activar WhatsApp? (s/n) [n]: "
    read -r wa_answer
    if [[ "$wa_answer" =~ ^[sS] ]]; then
        WA_ENABLED="true"
        echo -ne "  ${CYAN}?${NC} Número de WhatsApp: "
        read -r WA_NUMBER
    fi

    # === GOOGLE APIS ===
    log_step "5/7 — GOOGLE APIS"

    echo -ne "  ${CYAN}?${NC} ¿Conectar Google Calendar? (s/n) [n]: "
    read -r gcal_answer
    if [[ "$gcal_answer" =~ ^[sS] ]]; then
        GCAL_ENABLED="true"
        echo -ne "  ${CYAN}?${NC} Email de la cuenta Google: "
        read -r GCAL_EMAIL
        GSHEETS_ENABLED="true"  # Si Calendar, también Sheets
    fi

    # === INTEGRACIONES ===
    log_step "6/7 — INTEGRACIONES OPCIONALES"

    echo -ne "  ${CYAN}?${NC} ¿Tiene WordPress? (s/n) [n]: "
    read -r wp_answer
    if [[ "$wp_answer" =~ ^[sS] ]]; then
        WP_ENABLED="true"
        echo -ne "  ${CYAN}?${NC} URL del WordPress: "
        read -r WP_URL
    fi

    echo -ne "  ${CYAN}?${NC} ¿Conectar Stripe (cobros)? (s/n) [n]: "
    read -r stripe_answer
    if [[ "$stripe_answer" =~ ^[sS] ]]; then
        STRIPE_ENABLED="true"
    fi

    # === AUTOMATIZACIONES ===
    log_step "7/7 — AUTOMATIZACIONES"

    echo -e "  ${CYAN}ℹ${NC} Automatizaciones recomendadas para ${BOLD}${BUSINESS_TYPE}${NC}:"
    case "$BUSINESS_TYPE" in
        restaurante) echo "    → A-02, A-12, A-13, A-14, A-15, A-18" ;;
        hotel)       echo "    → A-02, A-04, A-13, A-14, A-15" ;;
        tienda)      echo "    → A-02, A-12, A-17, A-19, A-20" ;;
        servicios)   echo "    → A-02, A-05, A-06, A-12, A-13, A-16" ;;
        ecommerce)   echo "    → A-02, A-06, A-17, A-18, A-19, A-20" ;;
        *)           echo "    → A-02, A-12, A-15 (mínimo)" ;;
    esac

    echo -ne "  ${CYAN}?${NC} ¿Usar las recomendadas? (s/n) [s]: "
    read -r auto_answer
    if [[ ! "$auto_answer" =~ ^[nN] ]]; then
        case "$BUSINESS_TYPE" in
            restaurante) AUTOMATIONS_ENABLED="A-02,A-12,A-13,A-14,A-15,A-18" ;;
            hotel)       AUTOMATIONS_ENABLED="A-02,A-04,A-13,A-14,A-15" ;;
            tienda)      AUTOMATIONS_ENABLED="A-02,A-12,A-17,A-19,A-20" ;;
            servicios)   AUTOMATIONS_ENABLED="A-02,A-05,A-06,A-12,A-13,A-16" ;;
            ecommerce)   AUTOMATIONS_ENABLED="A-02,A-06,A-17,A-18,A-19,A-20" ;;
            *)           AUTOMATIONS_ENABLED="A-02,A-12,A-15" ;;
        esac
        log_info "Automatizaciones seleccionadas: ${AUTOMATIONS_ENABLED}"
    fi
}

# ==============================================================================
# VALIDATIONS
# ==============================================================================

check_dependencies() {
    log_step "VERIFICANDO DEPENDENCIAS"

    local deps=("curl" "bash" "jq")
    local optional=("ss" "wkhtmltopdf" "pdftotext" "pandoc" "ffmpeg" "git" "qrencode" "puppeteer")

    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log_info "$dep disponible"
        else
            log_error "$dep NO encontrado (requerido)"
        fi
    done

    for dep in "${optional[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log_info "$dep disponible"
        else
            log_warn "$dep no encontrado (se instala en Fase 2)"
        fi
    done
}

validate_environment() {
    log_step "VALIDANDO ENTORNO"

    if [[ -f /etc/os-release ]]; then
        local os_name
        os_name=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' || echo "Unknown")
        log_info "OS: $os_name"
    else
        log_info "OS: $(uname -s) $(uname -r)"
    fi

    log_info "Hostname: $(hostname 2>/dev/null || echo 'unknown')"
}

validate_resources() {
    log_step "VALIDANDO RECURSOS"

    # RAM
    if command -v free &>/dev/null; then
        local ram_gb
        ram_gb=$(free -g 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "0")
        if [[ "$ram_gb" -ge 2 ]]; then
            log_info "RAM: ${ram_gb}GB (mínimo: 2GB)"
        else
            log_warn "RAM: ${ram_gb}GB (mínimo recomendado: 2GB)"
        fi
    fi

    # CPU
    if command -v nproc &>/dev/null; then
        local cpus
        cpus=$(nproc 2>/dev/null || echo "1")
        log_info "CPU: ${cpus} cores"
    fi

    # Disk
    if command -v df &>/dev/null; then
        local disk_gb
        disk_gb=$(df -BG / 2>/dev/null | awk 'NR==2 {gsub(/G/,"",$4); print $4}' || echo "0")
        if [[ "$disk_gb" -ge 20 ]]; then
            log_info "Disco disponible: ${disk_gb}GB (mínimo: 20GB)"
        else
            log_warn "Disco: ${disk_gb}GB (mínimo recomendado: 20GB)"
        fi
    fi

    # Port
    if command -v ss &>/dev/null; then
        if ss -tuln 2>/dev/null | grep -q ":${AGENT_PORT} " 2>/dev/null; then
            log_warn "Puerto ${AGENT_PORT} está ocupado"
        else
            log_info "Puerto ${AGENT_PORT} disponible"
        fi
    fi
}

validate_config() {
    log_step "VALIDANDO CONFIGURACIÓN v2.0"

    # Required fields
    if [[ -n "$AGENT_NAME" ]]; then
        log_info "Agente: ${AGENT_NAME} (${BUSINESS_TYPE})"
    else
        log_error "Nombre del agente no configurado"
    fi

    if [[ -n "$BUSINESS_NAME" ]]; then
        log_info "Negocio: ${BUSINESS_NAME}"
    else
        log_error "Nombre del negocio no configurado"
    fi

    # Branding
    if [[ -n "$BRAND_PRIMARY_COLOR" ]]; then
        log_info "Branding: color primario ${BRAND_PRIMARY_COLOR}"
    else
        log_warn "Branding: sin colores configurados (se usarán defaults)"
    fi
    log_info "Tono: ${BRAND_TONE}"

    # Channels — at least 1
    local channels_active=0
    [[ "$TG_ENABLED" = "true" ]] && ((channels_active++))
    [[ "$EMAIL_ENABLED" = "true" ]] && ((channels_active++))
    [[ "$WA_ENABLED" = "true" ]] && ((channels_active++))
    [[ "$DISCORD_ENABLED" = "true" ]] && ((channels_active++))

    if [[ $channels_active -gt 0 ]]; then
        log_info "Canales activos: ${channels_active}"
    else
        log_error "Ningún canal activo (necesita al menos 1)"
    fi

    # Google APIs
    if [[ "$GCAL_ENABLED" = "true" ]]; then
        if [[ -n "$GCAL_EMAIL" ]]; then
            log_info "Google Calendar: ${GCAL_EMAIL}"
        else
            log_warn "Google Calendar habilitado pero sin email de cuenta"
        fi
    fi

    # Integrations that need credentials
    if [[ "$WP_ENABLED" = "true" && -z "$WP_URL" ]]; then
        log_warn "WordPress habilitado pero sin URL"
    fi

    # Automations
    if [[ -n "$AUTOMATIONS_ENABLED" ]]; then
        local auto_count
        auto_count=$(echo "$AUTOMATIONS_ENABLED" | tr ',' '\n' | wc -l)
        log_info "Automatizaciones seleccionadas: ${auto_count}"
    else
        log_warn "Sin automatizaciones seleccionadas"
    fi

    # Models
    log_info "Modelos: ${MODEL_PRIMARY} / ${MODEL_FALLBACK} / ${MODEL_VISION}"
}

# ==============================================================================
# GENERATE OUTPUT FILES (v2.0)
# ==============================================================================

generate_output() {
    log_step "GENERANDO ARCHIVOS DE CONFIGURACIÓN v2.0"

    mkdir -p "$WORK_DIR" 2>/dev/null || true
    local timestamp
    timestamp=$(date -Iseconds)

    # --- turnkey-env.json ---
    cat > "${WORK_DIR}/turnkey-env.json" << EOF
{
  "generated_at": "${timestamp}",
  "version": "${VERSION}",
  "model_version": "2.0.0",
  "environment": {
    "type": "${DEPLOY_TYPE:-auto-detect}",
    "hostname": "$(hostname 2>/dev/null || echo 'unknown')",
    "os": "$(uname -s 2>/dev/null || echo 'unknown')",
    "kernel": "$(uname -r 2>/dev/null || echo 'unknown')"
  },
  "resources": {
    "ram_gb": $(free -g 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 0),
    "cpu_cores": $(nproc 2>/dev/null || echo 1),
    "disk_available_gb": $(df -BG / 2>/dev/null | awk 'NR==2 {gsub(/G/,"",$4); print $4}' || echo 0)
  }
}
EOF
    log_info "Generado: turnkey-env.json"

    # --- turnkey-config.json (v2.0 complete) ---
    if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "${WORK_DIR}/turnkey-config.json"
    else
        local automations_json="[]"
        if [[ -n "$AUTOMATIONS_ENABLED" ]]; then
            automations_json=$(echo "$AUTOMATIONS_ENABLED" | tr ',' '\n' | sed 's/^/"/;s/$/"/' | paste -sd, | sed 's/^/[/;s/$/]/')
        fi

        cat > "${WORK_DIR}/turnkey-config.json" << EOF
{
  "version": "2.0.0",
  "generated_at": "${timestamp}",
  "deployment": {"type": "${DEPLOY_TYPE:-auto-detect}"},
  "agent": {
    "name": "${AGENT_NAME}",
    "business_name": "${BUSINESS_NAME}",
    "business_type": "${BUSINESS_TYPE}",
    "role": "${AGENT_ROLE:-Asistente virtual de ${BUSINESS_NAME}}",
    "emoji": "${AGENT_EMOJI}",
    "language": "${AGENT_LANG}",
    "timezone": "${TIMEZONE}",
    "port": ${AGENT_PORT}
  },
  "branding": {
    "primary_color": "${BRAND_PRIMARY_COLOR}",
    "secondary_color": "${BRAND_SECONDARY_COLOR}",
    "accent_color": "${BRAND_ACCENT_COLOR}",
    "tone": "${BRAND_TONE}"
  },
  "contact": {
    "owner_name": "${OWNER_NAME}",
    "owner_email": "${OWNER_EMAIL}",
    "owner_phone": "${OWNER_PHONE}",
    "website": "${BUSINESS_WEBSITE}"
  },
  "channels": {
    "telegram": {"enabled": ${TG_ENABLED}, "create_new_bot": ${TG_CREATE_NEW}},
    "email": {"enabled": ${EMAIL_ENABLED}, "use_our_domain": ${EMAIL_USE_OURS}},
    "whatsapp": {"enabled": ${WA_ENABLED}},
    "discord": {"enabled": ${DISCORD_ENABLED}}
  },
  "google_apis": {
    "calendar": {"enabled": ${GCAL_ENABLED}, "email": "${GCAL_EMAIL}"},
    "sheets": {"enabled": ${GSHEETS_ENABLED}},
    "maps": {"enabled": ${GMAPS_ENABLED}}
  },
  "integrations": {
    "wordpress": {"enabled": ${WP_ENABLED}},
    "meta_ads": {"enabled": ${META_ADS_ENABLED}},
    "stripe": {"enabled": ${STRIPE_ENABLED}},
    "google_my_business": {"enabled": ${GMB_ENABLED}}
  },
  "models": {
    "primary": "${MODEL_PRIMARY}",
    "fallback": "${MODEL_FALLBACK}",
    "vision": "${MODEL_VISION}",
    "embeddings": "${MODEL_EMBEDDINGS}"
  },
  "skills": {"mode": "all_builtin", "total": 58},
  "automations": {"enabled": ${automations_json}}
}
EOF
    fi
    log_info "Generado: turnkey-config.json (v2.0)"

    # --- turnkey-status.json ---
    local final_status="passed"
    local can_proceed=true

    if [[ $ERRORS -gt 0 ]]; then
        final_status="failed"
        can_proceed=false
    elif [[ $WARNINGS -gt 0 ]]; then
        final_status="passed_with_warnings"
    fi

    cat > "${WORK_DIR}/turnkey-status.json" << EOF
{
  "phase": 1,
  "status": "${final_status}",
  "timestamp": "${timestamp}",
  "model_version": "2.0.0",
  "warnings": ${WARNINGS},
  "errors": ${ERRORS},
  "can_proceed": ${can_proceed},
  "agent": {
    "name": "${AGENT_NAME}",
    "business_type": "${BUSINESS_TYPE}",
    "port": ${AGENT_PORT},
    "skills": 58,
    "automations_selected": $(echo "$AUTOMATIONS_ENABLED" | tr ',' '\n' | wc -l)
  }
}
EOF
    log_info "Generado: turnkey-status.json"
}

# ==============================================================================
# SUMMARY
# ==============================================================================

show_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           RESUMEN DE CONFIGURACIÓN v2.0                      ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Agente:      ${BOLD}${AGENT_NAME}${NC} ${AGENT_EMOJI}"
    echo -e "${CYAN}║${NC} Negocio:     ${BUSINESS_NAME} (${BUSINESS_TYPE})"
    echo -e "${CYAN}║${NC} Timezone:    ${TIMEZONE}"
    echo -e "${CYAN}║${NC} Tono:        ${BRAND_TONE}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Skills:      ${BOLD}58 built-in${NC} (siempre activas)"
    echo -e "${CYAN}║${NC} LLM:         ${MODEL_PRIMARY} (fallback: ${MODEL_FALLBACK})"
    echo -e "${CYAN}║${NC} Vision:      ${MODEL_VISION}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Telegram:    $([ "$TG_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}║${NC} Email:       $([ "$EMAIL_ENABLED" = "true" ] && echo "✅ (nuestro dominio)" || echo "❌")"
    echo -e "${CYAN}║${NC} WhatsApp:    $([ "$WA_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}║${NC} Discord:     $([ "$DISCORD_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} G Calendar:  $([ "$GCAL_ENABLED" = "true" ] && echo "✅ ($GCAL_EMAIL)" || echo "❌")"
    echo -e "${CYAN}║${NC} G Sheets:    $([ "$GSHEETS_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}║${NC} G Maps:      $([ "$GMAPS_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} WordPress:   $([ "$WP_ENABLED" = "true" ] && echo "✅ ($WP_URL)" || echo "❌")"
    echo -e "${CYAN}║${NC} Meta Ads:    $([ "$META_ADS_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}║${NC} Stripe:      $([ "$STRIPE_ENABLED" = "true" ] && echo "✅" || echo "❌")"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Automations: ${AUTOMATIONS_ENABLED:-ninguna}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC} Warnings:    ${WARNINGS}"
    echo -e "${CYAN}║${NC} Errores:     ${ERRORS}"
    echo -e "${CYAN}║${NC} Estado:      $([ $ERRORS -eq 0 ] && echo "✅ PUEDE PROCEDER" || echo "❌ TIENE ERRORES")"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"

    if [[ $ERRORS -gt 0 && "$FORCE" != "true" ]]; then
        echo ""
        echo -e "  ${RED}Hay $ERRORS errores. Use --force para continuar.${NC}"
    fi

    echo ""
    echo -e "  ${BLUE}Archivos en:${NC} ${WORK_DIR}/"
    echo ""
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    parse_args "$@"
    show_header

    load_config
    ask_interactive

    check_dependencies
    validate_environment
    validate_resources
    validate_config

    generate_output
    show_summary

    if [[ $ERRORS -gt 0 && "$FORCE" != "true" ]]; then
        exit 1
    fi

    exit 0
}

main "$@"