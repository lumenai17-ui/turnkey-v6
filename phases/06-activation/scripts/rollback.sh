#!/bin/bash
# ==============================================================================
# FASE 6: ROLLBACK — Revertir despliegue
# ==============================================================================

set -euo pipefail

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

AGENT_NAME=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent-name) AGENT_NAME="$2"; shift 2 ;;
        --dry-run)    DRY_RUN=true; shift ;;
        --help)       echo "Uso: $0 --agent-name NAME [--dry-run]"; exit 0 ;;
        *)            shift ;;
    esac
done

[[ -z "$AGENT_NAME" ]] && { echo "Error: --agent-name requerido"; exit 1; }

echo -e "${YELLOW}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║              TURNKEY v6 — ROLLBACK                            ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

USERNAME="bee-${AGENT_NAME}"

# Step 1: Stop services
echo -e "${CYAN}[1/4]${NC} Deteniendo servicios..."
if [[ "$DRY_RUN" = "true" ]]; then
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Detendría: openclaw-gateway"
else
    if command -v systemctl &>/dev/null; then
        systemctl --user stop openclaw-gateway 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} Servicios detenidos"
    else
        echo -e "  ${YELLOW}⚠${NC} systemd no disponible"
    fi
fi

# Step 2: Backup current state
echo -e "${CYAN}[2/4]${NC} Creando backup..."
backup_dir="$HOME/.openclaw/backups/$(date +%Y%m%d_%H%M%S)"
if [[ "$DRY_RUN" = "true" ]]; then
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Crearía backup en: $backup_dir"
else
    mkdir -p "$backup_dir"
    cp -r "$HOME/.openclaw/config" "$backup_dir/" 2>/dev/null || true
    cp -r "$HOME/.openclaw/workspace/turnkey" "$backup_dir/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Backup en: $backup_dir"
fi

# Step 3: Remove config
echo -e "${CYAN}[3/4]${NC} Limpiando configuración..."
if [[ "$DRY_RUN" = "true" ]]; then
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Removería: ~/.openclaw/config/*"
else
    rm -f "$HOME/.openclaw/config/SOUL.md" 2>/dev/null || true
    rm -f "$HOME/.openclaw/config/USER.md" 2>/dev/null || true
    rm -f "$HOME/.openclaw/config/HEART.md" 2>/dev/null || true
    rm -f "$HOME/.openclaw/config/DOPAMINE.md" 2>/dev/null || true
    rm -f "$HOME/.openclaw/config/gateway.json" 2>/dev/null || true
    rm -f "$HOME/.openclaw/config/openclaw.json" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Configuración limpiada"
fi

# Step 4: Remove turnkey status
echo -e "${CYAN}[4/4]${NC} Limpiando estado de turnkey..."
if [[ "$DRY_RUN" = "true" ]]; then
    echo -e "  ${YELLOW}[DRY-RUN]${NC} Removería: ~/.openclaw/workspace/turnkey/*"
else
    rm -rf "$HOME/.openclaw/workspace/turnkey" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Estado limpiado"
fi

echo ""
echo -e "${GREEN}✅ Rollback completado${NC}"
echo -e "  ${YELLOW}Backup disponible en: ${backup_dir:-'(dry-run)'}${NC}"
echo ""
