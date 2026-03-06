#!/bin/bash
# =============================================================================
# gateway-install.sh - FASE 3: GATEWAY INSTALL - Instalar y configurar Gateway
# TURNKEY v6
# =============================================================================

set -e
set +e  # Ignorar errores no críticos

VERSION="6.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Valores por defecto
GATEWAY_PORT="${GATEWAY_PORT:-18789}"
GATEWAY_HOST="${GATEWAY_HOST:-localhost}"
OLLAMA_API_KEY="${OLLAMA_API_KEY:-}"
SKIP_INSTALL=false
DRY_RUN=false
CONFIG_FILE=""

# Arrays para resultados
declare -a WARNINGS=()
declare -a ERRORS=()
declare -a CHECKS=()

# -----------------------------------------------------------------------------
# FUNCIONES DE LOGGING
# -----------------------------------------------------------------------------

log_info() { echo -e "${BLUE}$1${NC}"; }
log_ok() { echo -e "${GREEN}$1${NC}"; }
log_warn() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }

# -----------------------------------------------------------------------------
# MOSTRAR AYUDA
# -----------------------------------------------------------------------------

show_help() {
    echo -e "${CYAN}Uso: $0 [opciones]${NC}"
    echo ""
    echo "Opciones:"
    echo "  --api-key KEY     API key de Ollama Cloud"
    echo "  --port PORT        Puerto del gateway (default: 18789)"
    echo "  --host HOST        Host del gateway (default: localhost)"
    echo "  --config FILE      Archivo de configuración JSON"
    echo "  --skip-install     Solo configurar, no instalar"
    echo "  --dry-run          Simular sin hacer cambios"
    echo "  --help             Mostrar esta ayuda"
    echo ""
    echo "Variables de entorno:"
    echo "  OLLAMA_API_KEY     API key de Ollama Cloud"
    echo "  GATEWAY_PORT       Puerto del gateway"
    echo "  GATEWAY_HOST       Host del gateway"
    echo ""
    echo "Ejemplos:"
    echo "  $0 --api-key os_xxx"
    echo "  $0 --config gateway-config.json"
    echo "  $0 --dry-run"
    exit 0
}

# -----------------------------------------------------------------------------
# PARSEAR ARGUMENTOS
# -----------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --api-key) OLLAMA_API_KEY="$2"; shift 2 ;;
            --port) GATEWAY_PORT="$2"; shift 2 ;;
            --host) GATEWAY_HOST="$2"; shift 2 ;;
            --config) CONFIG_FILE="$2"; shift 2 ;;
            --skip-install) SKIP_INSTALL=true; shift ;;
            --dry-run) DRY_RUN=true; shift ;;
            --help) show_help ;;
            *) log_error "Opción desconocida: $1"; exit 1 ;;
        esac
    done
    
    # Cargar config desde archivo si existe
    if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
        log_info "Cargando configuración desde: $CONFIG_FILE"
        # TODO: Parsear JSON
    fi
}

# -----------------------------------------------------------------------------
# VERIFICAR REQUISITOS
# -----------------------------------------------------------------------------

check_requirements() {
    log_info "=== VERIFICANDO REQUISITOS ==="
    
    # Node.js
    if command -v node &>/dev/null; then
        local node_version
        node_version=$(node --version 2>/dev/null | sed 's/v//')
        local node_major=$(echo "$node_version" | cut -d. -f1)
        
        if [[ $node_major -ge 18 ]]; then
            log_ok "Node.js: v${node_version}"
            CHECKS+=("{\"name\": \"node_version\", \"status\": \"passed\", \"value\": \"v${node_version}\"}")
        else
            log_error "Node.js versión antigua: v${node_version} (requiere >= 18)"
            ERRORS+=("Node.js versión antigua")
            CHECKS+=("{\"name\": \"node_version\", \"status\": \"error\", \"value\": \"v${node_version}\"}")
        fi
    else
        log_error "Node.js no instalado"
        ERRORS+=("Node.js no instalado")
        CHECKS+=("{\"name\": \"node_version\", \"status\": \"error\", \"value\": \"not_installed\"}")
    fi
    
    # npm
    if command -v npm &>/dev/null; then
        local npm_version
        npm_version=$(npm --version 2>/dev/null)
        local npm_major=$(echo "$npm_version" | cut -d. -f1)
        
        if [[ $npm_major -ge 9 ]]; then
            log_ok "npm: ${npm_version}"
            CHECKS+=("{\"name\": \"npm_version\", \"status\": \"passed\", \"value\": \"${npm_version}\"}")
        else
            log_warn "npm versión antigua: ${npm_version} (requiere >= 9)"
            WARNINGS+=("npm versión antigua")
            CHECKS+=("{\"name\": \"npm_version\", \"status\": \"warning\", \"value\": \"${npm_version}\"}")
        fi
    else
        log_error "npm no instalado"
        ERRORS+=("npm no instalado")
        CHECKS+=("{\"name\": \"npm_version\", \"status\": \"error\", \"value\": \"not_installed\"}")
    fi
    
    # Puerto
    if ss -tuln 2>/dev/null | grep -q ":${GATEWAY_PORT} "; then
        log_warn "Puerto ${GATEWAY_PORT} está en uso"
        WARNINGS+=("Puerto ${GATEWAY_PORT} en uso")
        CHECKS+=("{\"name\": \"port_available\", \"status\": \"warning\", \"value\": \"${GATEWAY_PORT}\"}")
    else
        log_ok "Puerto ${GATEWAY_PORT} disponible"
        CHECKS+=("{\"name\": \"port_available\", \"status\": \"passed\", \"value\": \"${GATEWAY_PORT}\"}")
    fi
    
    # API key
    if [[ -n "$OLLAMA_API_KEY" ]]; then
        log_ok "API key proporcionada (${OLLAMA_API_KEY:0:10}...)"
        CHECKS+=("{\"name\": \"api_key\", \"status\": \"provided\"}")
    else
        log_warn "API key no proporcionada - Se solicitará más adelante"
        WARNINGS+=("API key no proporcionada")
        CHECKS+=("{\"name\": \"api_key\", \"status\": \"missing\"}")
    fi
    
    echo ""
}

# -----------------------------------------------------------------------------
# DETECTAR GATEWAY EXISTENTE
# -----------------------------------------------------------------------------

detect_gateway() {
    log_info "=== DETECTANDO GATEWAY EXISTENTE ==="
    
    local gateway_path
    gateway_path=$(which openclaw-gateway 2>/dev/null || echo "")
    
    if [[ -n "$gateway_path" ]]; then
        log_ok "Gateway encontrado: $gateway_path"
        
        # Verificar si está corriendo
        if pgrep -f "openclaw-gateway" &>/dev/null; then
            log_ok "Gateway está corriendo"
            CHECKS+=("{\"name\": \"gateway_installed\", \"status\": \"existing\", \"running\": true}")
        else
            log_warn "Gateway instalado pero no corriendo"
            WARNINGS+=("Gateway no está corriendo")
            CHECKS+=("{\"name\": \"gateway_installed\", \"status\": \"existing\", \"running\": false}")
        fi
        
        return 0
    else
        log_info "Gateway no instalado"
        CHECKS+=("{\"name\": \"gateway_installed\", \"status\": \"not_installed\"}")
        return 1
    fi
    
    echo ""
}

# -----------------------------------------------------------------------------
# VALIDAR API KEY
# -----------------------------------------------------------------------------

validate_api_key() {
    log_info "=== VALIDANDO API KEY ==="
    
    if [[ -z "$OLLAMA_API_KEY" ]]; then
        log_warn "API key no proporcionada"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            log_warn "[DRY-RUN] Se solicitaría API key interactivamente"
            return 0
        fi
        
        # Solicitar interactivamente
        echo -n "Ingrese su API key de Ollama Cloud: "
        read -s OLLAMA_API_KEY
        echo ""
        
        if [[ -z "$OLLAMA_API_KEY" ]]; then
            log_error "API key es obligatoria"
            ERRORS+=("API key es obligatoria")
            return 1
        fi
    fi
    
    # Validar formato
    if [[ ! "$OLLAMA_API_KEY" =~ ^os_ ]]; then
        log_error "API key inválida (debe empezar con 'os_')"
        ERRORS+=("API key con formato inválido")
        return 1
    fi
    
    log_ok "API key válida (formato correcto)"
    
    # TODO: Validar contra API de Ollama
    # Por ahora solo validamos formato
    
    CHECKS+=("{\"name\": \"api_key_valid\", \"status\": \"passed\", \"key_prefix\": \"${OLLAMA_API_KEY:0:10}\"}")
    
    echo ""
}

# -----------------------------------------------------------------------------
# CONFIGURAR GATEWAY
# -----------------------------------------------------------------------------

configure_gateway() {
    log_info "=== CONFIGURANDO GATEWAY ==="
    
    local config_dir="${HOME}/.openclaw/config"
    local config_file="${config_dir}/gateway.json"
    
    # Crear directorio si no existe
    if [[ ! -d "$config_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_warn "[DRY-RUN] Se crearían: $config_dir"
        else
            mkdir -p "$config_dir"
            log_ok "Creado: $config_dir"
        fi
    fi
    
    # Crear configuración
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se crearía: $config_file"
    else
        cat > "$config_file" <<EOF
{
  "gateway": {
    "name": "openclaw-gateway",
    "version": "${VERSION}",
    "host": "${GATEWAY_HOST}",
    "port": ${GATEWAY_PORT},
    "logLevel": "info"
  },
  "api": {
    "ollama": {
      "enabled": true,
      "apiKey": "${OLLAMA_API_KEY}",
      "baseUrl": "https://api.ollama.cloud/v1"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": ""
    },
    "whatsapp": {
      "enabled": true,
      "sessionId": "default"
    },
    "discord": {
      "enabled": true,
      "token": ""
    }
  },
  "memory": {
    "enabled": true,
    "path": "${HOME}/.openclaw/data/memory"
  },
  "logging": {
    "path": "${HOME}/.openclaw/logs",
    "level": "info",
    "maxSize": "10M",
    "maxFiles": 5
  }
}
EOF
        log_ok "Creado: $config_file"
        CHECKS+=("{\"name\": \"gateway_config\", \"status\": \"created\"}")
    fi
    
    echo ""
}

# -----------------------------------------------------------------------------
# CREAR SYSTEMD SERVICE
# -----------------------------------------------------------------------------

create_systemd_service() {
    log_info "=== CREANDO SYSTEMD SERVICE ==="
    
    local service_dir="${HOME}/.config/systemd/user"
    local service_file="${service_dir}/openclaw-gateway.service"
    
    # Crear directorio si no existe
    if [[ ! -d "$service_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_warn "[DRY-RUN] Se crearían: $service_dir"
        else
            mkdir -p "$service_dir"
            log_ok "Creado: $service_dir"
        fi
    fi
    
    # Crear service
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se crearía: $service_file"
    else
        cat > "$service_file" <<EOF
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openclaw-gateway --config ${HOME}/.openclaw/config/gateway.json
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
        log_ok "Creado: $service_file"
        CHECKS+=("{\"name\": \"systemd_service\", \"status\": \"created\"}")
        
        # Recargar systemd
        systemctl --user daemon-reload 2>/dev/null || true
    fi
    
    echo ""
}

# -----------------------------------------------------------------------------
# GENERAR REPORTE
# -----------------------------------------------------------------------------

generate_report() {
    log_info "=== GENERANDO REPORTE ==="
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    # gateway-status.json
    cat > "${HOME}/.openclaw/gateway-status.json" <<EOF
{
  "generated_at": "${timestamp}",
  "version": "${VERSION}",
  "gateway": {
    "host": "${GATEWAY_HOST}",
    "port": ${GATEWAY_PORT},
    "url": "http://${GATEWAY_HOST}:${GATEWAY_PORT}"
  },
  "api_key": {
    "provider": "ollama",
    "configured": $([ -n "$OLLAMA_API_KEY" ] && echo "true" || echo "false")
  },
  "checks": [$(IFS=,; echo "${CHECKS[*]}")],
  "warnings": $(printf '%s\n' "${WARNINGS[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]"),
  "errors": $(printf '%s\n' "${ERRORS[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
}
EOF
    
    log_ok "Generado: ${HOME}/.openclaw/gateway-status.json"
    
    # Resumen final
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          GATEWAY INSTALL CONFIGURADO                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        log_error "ERRORES:"
        for err in "${ERRORS[@]}"; do
            log_error "  ✗ $err"
        done
        exit 1
    elif [[ ${#WARNINGS[@]} -gt 0 ]]; then
        log_warn "WARNINGS:"
        for warn in "${WARNINGS[@]}"; do
            log_warn "  ⚠ $warn"
        done
    else
        log_ok "Todo configurado correctamente"
    fi
    
    echo ""
    log_info "Gateway URL: ${CYAN}http://${GATEWAY_HOST}:${GATEWAY_PORT}${NC}"
    log_info "Config: ${CYAN}${HOME}/.openclaw/config/gateway.json${NC}"
    echo ""
    
    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Para iniciar el gateway:"
        echo -e "  ${CYAN}systemctl --user start openclaw-gateway${NC}"
        echo -e "  ${CYAN}systemctl --user enable openclaw-gateway${NC}"
        echo ""
    fi
    
    exit 0
}

# -----------------------------------------------------------------------------
# ENCABEZADO
# -----------------------------------------------------------------------------

show_header() {
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          TURNKEY v6 - FASE 3: GATEWAY INSTALL                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

main() {
    parse_args "$@"
    show_header
    
    log_info "Puerto: ${GATEWAY_PORT}"
    log_info "Host: ${GATEWAY_HOST}"
    [[ "$DRY_RUN" == "true" ]] && log_warn "MODO DRY-RUN - No se harán cambios"
    echo ""
    
    check_requirements
    detect_gateway || true
    validate_api_key
    configure_gateway
    create_systemd_service
    generate_report
}

main "$@"