#!/bin/bash
# ==============================================================================
# install-vnc.sh — Instalar x11vnc + noVNC para visualización remota
# TURNKEY v6.3 — Production Layer
# ==============================================================================
# Configura x11vnc sobre el display Xvfb (:99) donde corre Tandem Browser,
# y noVNC para acceso web desde el navegador del cliente.
#
# Stack probado:
#   Xvfb (:99) → Tandem Browser → x11vnc (5900) → noVNC (6080)
#
# Uso:
#   ./install-vnc.sh [--dry-run] [--vnc-password PASSWORD]
# ==============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

DRY_RUN=false
VNC_PASSWORD=""
VNC_PORT=5900
NOVNC_PORT=6080
DISPLAY_NUM=99

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)        DRY_RUN=true; shift ;;
        --vnc-password)   VNC_PASSWORD="$2"; shift 2 ;;
        --vnc-port)       VNC_PORT="$2"; shift 2 ;;
        --novnc-port)     NOVNC_PORT="$2"; shift 2 ;;
        *)                shift ;;
    esac
done

log_info()  { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "  ${RED}✗${NC} $1" >&2; }
log_step()  { echo -e "\n${BLUE}═══ $1 ═══${NC}"; }

# ==============================================================================
# INSTALAR x11vnc
# ==============================================================================

log_step "INSTALANDO x11vnc"

if command -v x11vnc &>/dev/null; then
    log_info "x11vnc ya instalado: $(x11vnc -version 2>&1 | head -1 || echo 'OK')"
else
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se instalaría: x11vnc"
    else
        log_info "Instalando x11vnc..."
        sudo apt-get update -qq &>/dev/null || true
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq x11vnc &>/dev/null; then
            log_info "x11vnc instalado"
        else
            log_error "No se pudo instalar x11vnc"
            exit 1
        fi
    fi
fi

# ==============================================================================
# CONFIGURAR PASSWORD VNC
# ==============================================================================

log_step "CONFIGURANDO VNC PASSWORD"

VNC_PASSWD_DIR="${HOME}/.vnc"
VNC_PASSWD_FILE="${VNC_PASSWD_DIR}/passwd"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se configuraría password VNC"
else
    mkdir -p "$VNC_PASSWD_DIR" 2>/dev/null || true
    chmod 700 "$VNC_PASSWD_DIR"

    if [[ -f "$VNC_PASSWD_FILE" ]]; then
        log_info "Password VNC ya existe"
    else
        # Generar password si no se proporcionó
        if [[ -z "$VNC_PASSWORD" ]]; then
            VNC_PASSWORD=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 8)
            log_info "Password VNC generado: ${VNC_PASSWORD}"
            # Guardar en archivo legible para el admin
            echo "$VNC_PASSWORD" > "${VNC_PASSWD_DIR}/password.txt"
            chmod 600 "${VNC_PASSWD_DIR}/password.txt"
            log_info "Password guardado en: ${VNC_PASSWD_DIR}/password.txt"
        fi

        # Crear password file para x11vnc
        x11vnc -storepasswd "$VNC_PASSWORD" "$VNC_PASSWD_FILE" 2>/dev/null || {
            log_warn "No se pudo crear passwd file con x11vnc -storepasswd"
            # Fallback: crear manualmente
            echo "$VNC_PASSWORD" | vncpasswd -f > "$VNC_PASSWD_FILE" 2>/dev/null || true
        }
        chmod 600 "$VNC_PASSWD_FILE"
        log_info "Password VNC configurado"
    fi
fi

# ==============================================================================
# CREAR SERVICIO SYSTEMD PARA x11vnc
# ==============================================================================

log_step "CREANDO SERVICIO x11vnc"

SERVICE_DIR="${HOME}/.config/systemd/user"
X11VNC_SERVICE="${SERVICE_DIR}/x11vnc.service"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se crearía: ${X11VNC_SERVICE}"
else
    mkdir -p "$SERVICE_DIR" 2>/dev/null || true

    cat > "$X11VNC_SERVICE" <<EOF
[Unit]
Description=x11vnc VNC Server (display :${DISPLAY_NUM})
After=tandem-browser.service
Requires=tandem-browser.service

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :${DISPLAY_NUM} -rfbport ${VNC_PORT} -rfbauth ${VNC_PASSWD_FILE} -shared -forever -noxdamage -repeat -nap -wait 50
Restart=always
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=3
Environment=DISPLAY=:${DISPLAY_NUM}

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload 2>/dev/null || true
    log_info "Servicio x11vnc creado"
    log_info "  → Display: :${DISPLAY_NUM}"
    log_info "  → Puerto VNC: ${VNC_PORT}"
    log_info "  → Depende de: tandem-browser.service"
fi

# ==============================================================================
# INSTALAR noVNC (acceso web)
# ==============================================================================

log_step "INSTALANDO noVNC"

NOVNC_DIR="${HOME}/.novnc"

if [[ -d "$NOVNC_DIR" ]]; then
    log_info "noVNC ya instalado en ${NOVNC_DIR}"
else
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se instalaría noVNC"
    else
        log_info "Clonando noVNC..."
        if git clone --quiet https://github.com/novnc/noVNC.git "$NOVNC_DIR" 2>/dev/null; then
            log_info "noVNC clonado"
            # Clonar websockify (requerido por noVNC)
            if [[ ! -d "${NOVNC_DIR}/utils/websockify" ]]; then
                git clone --quiet https://github.com/novnc/websockify.git "${NOVNC_DIR}/utils/websockify" 2>/dev/null || {
                    log_warn "websockify clone falló, intentando pip..."
                    pip3 install websockify 2>/dev/null || true
                }
            fi
            log_info "websockify instalado"
        else
            log_warn "No se pudo clonar noVNC"
        fi
    fi
fi

# ==============================================================================
# CREAR SERVICIO SYSTEMD PARA noVNC
# ==============================================================================

log_step "CREANDO SERVICIO noVNC"

NOVNC_SERVICE="${SERVICE_DIR}/novnc.service"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se crearía: ${NOVNC_SERVICE}"
else
    cat > "$NOVNC_SERVICE" <<EOF
[Unit]
Description=noVNC Web Client (puerto ${NOVNC_PORT})
After=x11vnc.service
Requires=x11vnc.service

[Service]
Type=simple
ExecStart=${NOVNC_DIR}/utils/novnc_proxy --vnc localhost:${VNC_PORT} --listen ${NOVNC_PORT}
Restart=always
RestartSec=5
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload 2>/dev/null || true
    log_info "Servicio noVNC creado"
    log_info "  → Puerto web: ${NOVNC_PORT}"
    log_info "  → Conecta a VNC: localhost:${VNC_PORT}"
fi

# ==============================================================================
# ABRIR PUERTOS EN UFW
# ==============================================================================

log_step "CONFIGURANDO FIREWALL"

if command -v ufw &>/dev/null; then
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se abrirían puertos ${VNC_PORT} y ${NOVNC_PORT}"
    else
        sudo ufw allow ${VNC_PORT}/tcp &>/dev/null || true
        sudo ufw allow ${NOVNC_PORT}/tcp &>/dev/null || true
        log_info "UFW: puertos ${VNC_PORT} (VNC) y ${NOVNC_PORT} (noVNC) abiertos"
    fi
else
    log_warn "UFW no instalado, puertos no configurados automáticamente"
fi

# ==============================================================================
# RESUMEN
# ==============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          VNC + noVNC INSTALADO                                ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${CYAN}Stack de visualización:${NC}"
echo -e "${GREEN}║${NC}  ┌─────────────┐    ┌──────────┐    ┌────────┐"
echo -e "${GREEN}║${NC}  │ Xvfb (:${DISPLAY_NUM})  │ →  │ x11vnc   │ →  │ noVNC  │"
echo -e "${GREEN}║${NC}  │ 1920x1080   │    │ :${VNC_PORT}   │    │ :${NOVNC_PORT} │"
echo -e "${GREEN}║${NC}  └──────┬──────┘    └──────────┘    └────────┘"
echo -e "${GREEN}║${NC}         │"
echo -e "${GREEN}║${NC}  ┌──────┴──────┐"
echo -e "${GREEN}║${NC}  │   Tandem    │"
echo -e "${GREEN}║${NC}  │  Browser    │"
echo -e "${GREEN}║${NC}  └─────────────┘"
echo -e "${GREEN}║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  VNC directo:  vnc://IP:${VNC_PORT}"
echo -e "${GREEN}║${NC}  Web (noVNC):  http://IP:${NOVNC_PORT}/vnc.html"
echo -e "${GREEN}║${NC}  Password:     ${VNC_PASSWD_DIR}/password.txt"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC}  Para iniciar:"
echo -e "${GREEN}║${NC}    systemctl --user start x11vnc"
echo -e "${GREEN}║${NC}    systemctl --user start novnc"
echo -e "${GREEN}║${NC}    systemctl --user enable x11vnc novnc"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

exit 0
