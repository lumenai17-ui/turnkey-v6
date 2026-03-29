#!/bin/bash
# ==============================================================================
# install-gws.sh — Pre-instalar Google Workspace CLI
# TURNKEY v6.3 — Production Layer
# ==============================================================================
# Pre-instala GWS CLI para que el cliente solo tenga que conectar su cuenta.
# El agente tiene un skill de guía para ayudar al cliente con el setup.
#
# Uso:
#   ./install-gws.sh [--dry-run]
# ==============================================================================

set -euo pipefail

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

log_step "VERIFICANDO PREREQUISITOS PARA GWS CLI"

if ! command -v node &>/dev/null; then
    log_error "Node.js no instalado (requerido para GWS CLI)"
    exit 1
fi

if ! command -v npm &>/dev/null; then
    log_error "npm no instalado (requerido para GWS CLI)"
    exit 1
fi

log_info "Node.js $(node --version) detectado"

# ==============================================================================
# INSTALAR GWS CLI
# ==============================================================================

log_step "INSTALANDO GOOGLE WORKSPACE CLI"

if command -v gws &>/dev/null; then
    GWS_VER=$(gws --version 2>/dev/null || echo "unknown")
    log_info "GWS CLI ya instalado: v${GWS_VER}"
else
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "[DRY-RUN] Se ejecutaría: npm install -g @googleworkspace/cli"
    else
        log_info "Instalando GWS CLI via npm..."
        if npm install -g @googleworkspace/cli 2>/dev/null; then
            GWS_VER=$(gws --version 2>/dev/null || echo "installed")
            log_info "GWS CLI instalado: v${GWS_VER}"
        else
            log_warn "No se pudo instalar GWS CLI (npm install falló)"
            log_warn "El cliente podrá instalarlo manualmente: npm install -g @googleworkspace/cli"
        fi
    fi
fi

# ==============================================================================
# CREAR DIRECTORIO DE CONFIGURACIÓN
# ==============================================================================

log_step "PREPARANDO CONFIGURACIÓN"

GWS_CONFIG_DIR="${HOME}/.config/gws"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se crearía: ${GWS_CONFIG_DIR}"
else
    mkdir -p "$GWS_CONFIG_DIR" 2>/dev/null || true
    chmod 700 "$GWS_CONFIG_DIR"
    log_info "Directorio de config: ${GWS_CONFIG_DIR} (permisos 700)"
fi

# ==============================================================================
# CREAR GUÍA DE CONEXIÓN PARA EL AGENTE
# ==============================================================================

log_step "GENERANDO GUÍA DE CONEXIÓN"

GWS_GUIDE="${HOME}/.openclaw/config/GWS-SETUP-GUIDE.md"

if [[ "$DRY_RUN" == "true" ]]; then
    log_warn "[DRY-RUN] Se crearía: ${GWS_GUIDE}"
else
    mkdir -p "$(dirname "$GWS_GUIDE")" 2>/dev/null || true
    cat > "$GWS_GUIDE" <<'EOFGUIDE'
# 🔧 Guía de Conexión — Google Workspace CLI

## Estado: ✅ Pre-instalado | ⏳ Pendiente de configurar

GWS CLI está listo para usar. Solo necesitas conectar tu cuenta de Google.

## 📋 Pasos para conectar

### Paso 1: Crear proyecto en Google Cloud (si no tienes uno)
1. Ve a https://console.cloud.google.com
2. Crea un proyecto nuevo (o usa uno existente)
3. Habilita las APIs que necesites:
   - Google Calendar API
   - Google Sheets API
   - Google Drive API
   - Gmail API

### Paso 2: Crear credenciales OAuth
1. En Google Cloud Console → APIs & Services → Credentials
2. Click "Create Credentials" → "OAuth client ID"
3. Tipo: Desktop application
4. Descarga el archivo JSON de credenciales

### Paso 3: Configurar GWS CLI
```bash
gws auth setup
```
Sigue las instrucciones en pantalla. Te pedirá:
- ID del proyecto de Google Cloud
- El archivo de credenciales OAuth

### Paso 4: Verificar conexión
```bash
# Probar Calendar
gws calendar events list --max-results 5

# Probar Sheets
gws sheets spreadsheets get --spreadsheet-id YOUR_ID

# Probar Drive
gws drive files list --max-results 5
```

## 🚀 Comandos útiles

| Servicio | Comando | Descripción |
|----------|---------|-------------|
| Calendar | `gws calendar events list` | Ver próximos eventos |
| Calendar | `gws calendar events create` | Crear evento |
| Sheets | `gws sheets values get` | Leer datos |
| Sheets | `gws sheets values update` | Escribir datos |
| Drive | `gws drive files list` | Listar archivos |
| Drive | `gws drive files upload` | Subir archivo |
| Gmail | `gws gmail messages list` | Listar emails |

## ❓ ¿Necesitas ayuda?

Pregúntame: "Ayúdame a conectar Google Workspace" y te guío paso a paso.
EOFGUIDE
    chmod 644 "$GWS_GUIDE"
    log_info "Guía creada: ${GWS_GUIDE}"
fi

# ==============================================================================
# RESUMEN
# ==============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          GWS CLI PRE-INSTALADO                                ║${NC}"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} CLI:         gws (Google Workspace CLI)"
echo -e "${GREEN}║${NC} Config dir:  ${GWS_CONFIG_DIR}"
echo -e "${GREEN}║${NC} Guía:        ${GWS_GUIDE}"
echo -e "${GREEN}║${NC} Estado:      Pre-instalado, pendiente de config del cliente"
echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║${NC} El cliente solo necesita:"
echo -e "${GREEN}║${NC}   1. Crear proyecto en Google Cloud"
echo -e "${GREEN}║${NC}   2. Habilitar APIs"
echo -e "${GREEN}║${NC}   3. Ejecutar: gws auth setup"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

exit 0
