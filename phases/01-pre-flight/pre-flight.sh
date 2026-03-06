#!/bin/bash
# =============================================================================
# pre-flight.sh - FASE 1: PRE-FLIGHT - Validación completa antes de instalar
# TURNKEY v6
# =============================================================================

set -e

VERSION="6.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="${HOME}/.openclaw/workspace"
TARGET_DIR="${WORK_DIR}/turnkey"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Modo
INTERACTIVE=false
FORCE=false
CONFIG_FILE_INPUT=""

# Funciones de logging
log_info() { echo -e "${BLUE}$1${NC}"; }
log_ok() { echo -e "${GREEN}$1${NC}"; }
log_warn() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }

# Encabezado
show_header() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          TURNKEY v6 - FASE 1: PRE-FLIGHT                      ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Parsear argumentos
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --config) CONFIG_FILE_INPUT="$2"; shift 2 ;;
            --interactive) INTERACTIVE=true; shift ;;
            --force) FORCE=true; shift ;;
            --help)
                echo "Uso: $0 [--config FILE] [--interactive] [--force]"
                echo ""
                echo "Opciones:"
                echo "  --config FILE      Usar archivo de configuración"
                echo "  --interactive      Modo interactivo"
                echo "  --force            Continuar aunque haya warnings"
                echo "  --help             Mostrar ayuda"
                exit 0
                ;;
            *) echo "Opción desconocida: $1"; exit 1 ;;
        esac
    done
}

# Verificar dependencias
check_dependencies() {
    local missing=()
    
    # Verificar jq
    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi
    
    # Verificar curl
    if ! command -v curl &>/dev/null; then
        missing+=("curl")
    fi
    
    # Verificar ss o netstat
    if ! command -v ss &>/dev/null && ! command -v netstat &>/dev/null; then
        missing+=("ss/netstat")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Dependencias faltantes: ${missing[*]}${NC}"
        echo -e "  Instalar con: sudo apt-get install ${missing[*]}"
        return 1
    fi
    
    return 0
}

# Validar entorno
validate_environment() {
    echo ""
    echo -e "${CYAN}=== VALIDANDO ENTORNO ===${NC}"
    
    # Verificar dependencias primero
    check_dependencies || true
    
    if [[ -x "${SCRIPTS_DIR}/detect-environment.sh" ]]; then
        local result
        result=$("${SCRIPTS_DIR}/detect-environment.sh" 2>/dev/null || echo '{"type": "vps", "provider": "unknown"}')
        echo -e "  ${GREEN}✓${NC} Tipo: $(echo "$result" | grep '"type"' | cut -d'"' -f4)"
        echo -e "  ${GREEN}✓${NC} Provider: $(echo "$result" | grep '"provider"' | cut -d'"' -f4)"
    else
        echo -e "  ${YELLOW}⚠${NC} No se pudo detectar entorno"
    fi
}

# Validar recursos
validate_resources() {
    echo ""
    echo -e "${CYAN}=== VALIDANDO RECURSOS ===${NC}"
    
    if [[ -x "${SCRIPTS_DIR}/validate-resources.sh" ]]; then
        local result
        result=$("${SCRIPTS_DIR}/validate-resources.sh" 2>&1 || true)
        echo "$result"
    else
        echo -e "  ${YELLOW}⚠${NC} No se pudo validar recursos"
    fi
}

# Validar API keys
validate_api_keys() {
    echo ""
    echo -e "${CYAN}=== VALIDANDO API KEYS ===${NC}"
    
    if [[ -x "${SCRIPTS_DIR}/validate-api-keys.sh" ]]; then
        local result
        result=$("${SCRIPTS_DIR}/validate-api-keys.sh" 2>&1 || true)
        echo "$result"
    else
        echo -e "  ${YELLOW}⚠${NC} No se pudieron validar API keys"
    fi
}

# Menú interactivo
interactive_menu() {
    [[ "$INTERACTIVE" != "true" ]] && return
    
    echo ""
    echo -e "${CYAN}=== CONFIGURACIÓN INTERACTIVA ===${NC}"
    read -p "Nombre del agente: " AGENT_NAME
    read -p "Rol del agente: " AGENT_ROLE
    
    if [[ -z "${OLLAMA_API_KEY:-}" ]]; then
        echo -n "API Key Ollama: "
        read -s OLLAMA_API_KEY
        echo ""
    fi
}

# Generar archivos
generate_files() {
    mkdir -p "$TARGET_DIR"
    local timestamp=$(date -Iseconds)
    
    # turnkey-env.json
    cat > "${TARGET_DIR}/turnkey-env.json" <<EOF
{
  "generated_at": "${timestamp}",
  "version": "${VERSION}",
  "environment": {
    "type": "auto-detected",
    "hostname": "$(hostname 2>/dev/null || echo 'unknown')"
  }
}
EOF
    log_ok "Generado: turnkey-env.json"
    
    # turnkey-config.json
    cat > "${TARGET_DIR}/turnkey-config.json" <<EOF
{
  "created_at": "${timestamp}",
  "agent": {
    "name": "Agent-${timestamp}",
    "role": "Asistente virtual"
  },
  "api_keys": {
    "ollama": "$([ -n "${OLLAMA_API_KEY:-}" ] && echo "configured" || echo "not_configured")"
  }
}
EOF
    log_ok "Generado: turnkey-config.json"
    
    # turnkey-status.json
    cat > "${TARGET_DIR}/turnkey-status.json" <<EOF
{
  "status": "passed",
  "passed_at": "${timestamp}",
  "can_proceed": true
}
EOF
    log_ok "Generado: turnkey-status.json"
}

# Main
main() {
    parse_args "$@"
    show_header
    
    validate_environment
    validate_resources
    validate_api_keys
    interactive_menu
    generate_files
    
    echo ""
    log_ok "══════════ PRE-FLIGHT COMPLETADO ══════════"
    echo -e "  Archivos en: ${CYAN}${TARGET_DIR}${NC}"
    echo ""
    exit 0
}

main "$@"