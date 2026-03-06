#!/bin/bash
#===============================================================================
# FASE 4: IDENTITY FLEET - Script Maestro
#===============================================================================
# Propósito: Orquestar la configuración completa de Identity y Fleet
# Uso: ./setup-fase4.sh --agent-name "nombre" --business-type "tipo" --business-name "nombre"
#===============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Directorio base
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#===============================================================================
# ENCABEZADO
#===============================================================================

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${CYAN}${BOLD}              TURNKEY v6 - FASE 4: IDENTITY FLEET                ${NC}${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Este script configura:${NC}"
echo -e "   ${CYAN}•${NC} Identity (SOUL, USER, MEMORY, HEART, DOPAMINE)"
echo -e "   ${CYAN}•${NC} Fleet (13 modelos AI)"
echo -e "   ${CYAN}•${NC} Skills (39 habilidades)"
echo -e "   ${CYAN}•${NC} Knowledge (archivos del negocio)"
echo ""

#===============================================================================
# VALIDAR DEPENDENCIAS
#===============================================================================

echo -e "${YELLOW}Verificando dependencias de Fases 1-3...${NC}"

if [[ ! -f "$HOME/.openclaw/config/.identity-status.json" ]]; then
    echo -e "${RED}✗ FASE 1-3 no completadas.${NC}"
    echo -e "${YELLOW}Ejecutar primero:${NC} ./01-pre-flight/setup-pre-flight.sh"
    echo -e "${YELLOW}Luego:${NC} ./02-setup-users/setup-users.sh"
    echo -e "${YELLOW}Luego:${NC} ./03-gateway-install/setup-gateway.sh"
    exit 1
fi

echo -e "${GREEN}✓ Dependencias verificadas${NC}"
echo ""

#===============================================================================
# EJECUTAR SUB-SCRIPTS
#===============================================================================

STEP=0
TOTAL_STEPS=4

run_step() {
    local step_name="$1"
    local script="$2"
    shift 2
    local args="$@"
    
    STEP=$((STEP + 1))
    echo ""
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  Paso ${STEP}/${TOTAL_STEPS}: ${step_name}${NC}"
    echo -e "${CYAN}${BOLD}════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if "${SCRIPT_DIR}/${script}" $args; then
        echo -e "${GREEN}✓ ${step_name} completado${NC}"
    else
        echo -e "${RED}✗ Error en ${step_name}${NC}"
        echo -e "${YELLOW}Revisar logs arriba para detalles${NC}"
        exit 1
    fi
}

# Ejecutar cada paso
run_step "Setup Identity" "setup-identity.sh" "$@"
run_step "Setup Fleet" "setup-fleet.sh" "$@"
run_step "Setup Skills" "setup-skills.sh" "$@"
run_step "Process Knowledge" "process-knowledge.sh" "$@"

#===============================================================================
# RESUMEN FINAL
#===============================================================================

echo ""
echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║              ✓ FASE 4 COMPLETADA EXITOSAMENTE                 ║${NC}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Resumen de archivos creados:${NC}"
echo -e ""
echo -e "${CYAN}Identity:${NC}"
echo -e "   ✓ SOUL.md - Personalidad del agente"
echo -e "   ✓ USER.md - Información del cliente"
echo -e "   ✓ MEMORY.md - Memoria inicial"
echo -e "   ✓ HEART.md - Sistema emocional"
echo -e "   ✓ DOPAMINE.md - Sistema de satisfacción"
echo -e ""
echo -e "${CYAN}Fleet:${NC}"
echo -e "   ✓ fleet.json - 13 modelos configurados"
echo -e "   ✓ openclaw.json - Configuración de OpenClaw"
echo -e "   ✓ embeddings.json - Configuración de embeddings"
echo -e ""
echo -e "${CYAN}Skills (39 habilidades):${NC}"
echo -e "   ✓ skills-core.json - 25 habilidades CORE"
echo -e "   ✓ skills-optional.json - 14 habilidades OPCIONALES"
echo -e "   ✓ skills-bundle.json - Bundle por tipo de negocio"
echo -e "   ✓ SKILLS.md - Documentación completa"
echo -e ""
echo -e "${CYAN}Knowledge:${NC}"
echo -e "   ✓ Directorio ~/.openclaw/knowledge/"
echo -e "   ✓ index.json - Índice de archivos"
echo -e ""
echo -e "${YELLOW}Próximo paso:${NC} FASE 5 - Bot Config"
echo -e "${YELLOW}Ejecutar:${NC} ./05-bot-config/setup-fase5.sh"
echo ""

# Guardar estado maestro
cat > "$HOME/.openclaw/config/.fase4-status.json" << EOF
{
  "status": "completed",
  "completed_at": "$(date -Iseconds)",
  "steps_completed": [
    "setup-identity",
    "setup-fleet",
    "setup-skills",
    "process-knowledge"
  ],
  "total_files_created": 13,
  "next_phase": "05-bot-config"
}
EOF

exit 0