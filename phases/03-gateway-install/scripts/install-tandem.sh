#!/bin/bash
# ==============================================================================
# install-tandem.sh — Instalar Tandem Browser (headless para servidor)
# TURNKEY v6.3 — Production Layer
# ==============================================================================
# Instala Tandem Browser como servicio headless en el VPS del agente.
# Requiere: Node.js 20+, npm 10+, xvfb (display virtual)
#
# Uso:
#   ./install-tandem.sh [--dry-run]
# ==============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TANDEM_DIR="${HOME}/.tandem"
readonly TANDEM_BROWSER_DIR="${TANDEM_DIR}/browser"
readonly TANDEM_TOKEN_FILE="${TANDEM_DIR}/api-token"
readonly TANDEM_PORT=8765

# Colores
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

log_info()  { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "  ${RED}✗${NC} $1" >&2; }
log_step()  { echo -e "\n${BLUE}═══ $1 ═══${NC}"; }

# ==============================================================================
# VERIFICAR PREREQUISITOS
# ==============================================================================

log_step "VERIFICANDO PREREQUISITOS PARA TANDEM BROWSER"

# Node.js 20+
if command -v node &>/dev/null; then
    NODE_VER=$(node --version | sed 's/v//' | cut -d. -f1)
    if [[ "$NODE_VER" -ge 20 ]]; then
        log_info "Node.js v$(node --version | sed 's/v//') (OK, ≥20)"
    elif [[ "$NODE_VER" -ge 18 ]]; then
        log_warn "Node.js v$(node --version | sed 's/v//') (funciona, pero 20+ recomendado)"
    else
        log_error "Node.js v$(node --version | sed 's/v//') (requiere ≥18, recomendado ≥20)"
        exit 1
    fi
else
    log_error "Node.js no instalado"
    exit 1
fi

# npm
if command -v npm &>/dev/null; then
    log_info "npm $(npm --version)"
else
    log_error "npm no instalado"
    exit 1
fi

# ==============================================================================
# INSTALAR DEPENDENCIAS DEL SISTEMA (Xvfb para headless Electron)
# ==============================================================================

log_step "INSTALANDO DEPENDENCIAS DEL SISTEMA"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se instalarían: xvfb, libgtk-3-0, libnotify-dev, libnss3, libxss1, libasound2"
else
    # Xvfb + dependencias de Electron
    sudo apt-get update -qq &>/dev/null || true
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        xvfb \
        libgtk-3-0 \
        libnotify-dev \
        libnss3 \
        libxss1 \
        libasound2 \
        libgbm1 \
        fonts-liberation \
        xdg-utils \
        &>/dev/null 2>&1 || log_warn "Algunas dependencias no se pudieron instalar"
    log_info "Dependencias de sistema instaladas"
fi

# ==============================================================================
# CLONAR/ACTUALIZAR TANDEM BROWSER
# ==============================================================================

log_step "INSTALANDO TANDEM BROWSER"

mkdir -p "$TANDEM_DIR" 2>/dev/null || true

if [[ -d "$TANDEM_BROWSER_DIR" ]]; then
    log_info "Tandem Browser ya existe en ${TANDEM_BROWSER_DIR}"
    if [[ "$DRY_RUN" == "false" ]]; then
        cd "$TANDEM_BROWSER_DIR"
        git pull --quiet 2>/dev/null || log_warn "No se pudo actualizar (sin conexión a git)"
        npm install --quiet 2>/dev/null || log_warn "npm install falló"
    fi
else
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se clonaría Tandem Browser"
    else
        log_info "Clonando Tandem Browser..."
        git clone https://github.com/hydro13/tandem-browser.git "$TANDEM_BROWSER_DIR" 2>/dev/null
        if [[ -d "$TANDEM_BROWSER_DIR" ]]; then
            cd "$TANDEM_BROWSER_DIR"
            npm install --quiet 2>/dev/null || log_warn "npm install parcial"
            npm run verify 2>/dev/null || true
            log_info "Tandem Browser clonado e instalado"
        else
            log_warn "No se pudo clonar Tandem Browser"
        fi
    fi
fi

# ==============================================================================
# GENERAR API TOKEN
# ==============================================================================

log_step "CONFIGURANDO API TOKEN"

if [[ -f "$TANDEM_TOKEN_FILE" ]]; then
    log_info "API token ya existe: ${TANDEM_TOKEN_FILE}"
else
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se generaría API token"
    else
        openssl rand -hex 32 > "$TANDEM_TOKEN_FILE"
        chmod 600 "$TANDEM_TOKEN_FILE"
        log_info "API token generado: ${TANDEM_TOKEN_FILE} (permisos 600)"
    fi
fi

# ==============================================================================
# CREAR SERVICIO SYSTEMD
# ==============================================================================

log_step "CREANDO SERVICIO SYSTEMD PARA TANDEM"

SERVICE_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/tandem-browser.service"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se crearía: ${SERVICE_FILE}"
else
    mkdir -p "$SERVICE_DIR" 2>/dev/null || true

    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Tandem Browser (headless) for OpenClaw
After=network.target openclaw-gateway.service

[Service]
Type=simple
WorkingDirectory=${TANDEM_BROWSER_DIR}
ExecStart=/usr/bin/xvfb-run --server-num=99 --server-args="-screen 0 1920x1080x24" npm start
Restart=always
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=3
Environment=NODE_ENV=production
Environment=TANDEM_PORT=${TANDEM_PORT}
Environment=TANDEM_TOKEN_FILE=${TANDEM_TOKEN_FILE}
Environment=DISPLAY=:99
Environment=TANDEM_HEADLESS=true

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload 2>/dev/null || true
    log_info "Servicio creado: tandem-browser.service"
    log_info "  → Headless via Xvfb (1920x1080)"
    log_info "  → Puerto: ${TANDEM_PORT}"
    log_info "  → Restart=always, RestartSec=5"
fi

# ==============================================================================
# RESUMEN
# ==============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          TANDEM BROWSER INSTALADO                              ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} Directorio:  ${TANDEM_BROWSER_DIR}"
echo -e "${GREEN}║${NC} API Token:   ${TANDEM_TOKEN_FILE}"
echo -e "${GREEN}║${NC} Puerto:      ${TANDEM_PORT}"
echo -e "${GREEN}║${NC} Display:     Xvfb :99 (1920x1080x24)"
echo -e "${GREEN}║${NC} Servicio:    tandem-browser.service"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} Para iniciar:"
echo -e "${GREEN}║${NC}   systemctl --user start tandem-browser"
echo -e "${GREEN}║${NC}   systemctl --user enable tandem-browser"
echo -e "${GREEN}║${NC}"
echo -e "${GREEN}║${NC} Para verificar:"
echo -e "${GREEN}║${NC}   curl -s http://127.0.0.1:${TANDEM_PORT}/status"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

exit 0
