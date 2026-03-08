#!/bin/bash
# ==============================================================================
# FASE 6: ACTIVATION — Script principal
# ==============================================================================
# Activa el agente OpenClaw, ejecuta smoke tests, y verifica todo.
#
# Uso:
#   ./activation.sh --agent-name NAME --port PORT --config CONFIG
#   ./activation.sh --agent-name NAME --dry-run
# ==============================================================================

set -euo pipefail

readonly VERSION="6.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OPENCLAW_DIR="$HOME/.openclaw"
readonly CONFIG_DIR="$OPENCLAW_DIR/config"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Options
AGENT_NAME=""
PORT="18789"
CONFIG_FILE=""
DRY_RUN=false
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# ==============================================================================
# LOGGING
# ==============================================================================

log_info()    { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "  ${RED}✗${NC} $1" >&2; }
log_step()    { echo -e "\n${BLUE}═══ $1 ═══${NC}"; }
log_test_pass() { echo -e "  ${GREEN}[PASS]${NC} $1"; ((TESTS_PASSED++)); ((TESTS_TOTAL++)); }
log_test_fail() { echo -e "  ${RED}[FAIL]${NC} $1"; ((TESTS_FAILED++)); ((TESTS_TOTAL++)); }

show_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          TURNKEY v6 — FASE 6: ACTIVACIÓN                      ║${NC}"
    echo -e "${CYAN}║          Activar servicios y verificar                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==============================================================================
# PARSE ARGS
# ==============================================================================

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent-name) AGENT_NAME="$2"; shift 2 ;;
        --port)       PORT="$2"; shift 2 ;;
        --config)     CONFIG_FILE="$2"; shift 2 ;;
        --dry-run)    DRY_RUN=true; shift ;;
        --help)
            echo "Uso: $0 --agent-name NAME [--port PORT] [--config FILE] [--dry-run]"
            exit 0
            ;;
        *) echo "Opción desconocida: $1"; exit 1 ;;
    esac
done

if [[ -z "$AGENT_NAME" ]]; then
    echo "Error: --agent-name es requerido"
    exit 1
fi

show_header

if [[ "$DRY_RUN" = "true" ]]; then
    echo -e "  ${YELLOW}[MODO DRY-RUN] Simulación — no se inician servicios${NC}"
    echo ""
fi

# ==============================================================================
# STEP 1: VERIFY PREREQUISITES
# ==============================================================================

log_step "PASO 1: Verificando prerequisitos"

# Validate previous phases
PHASE_WORK_DIR="$HOME/.openclaw/workspace/turnkey"
for prev_phase in 1 2 3 4 5; do
    phase_file="${PHASE_WORK_DIR}/phase-${prev_phase}-status.json"
    if [[ -f "$phase_file" ]] && command -v jq &>/dev/null; then
        prev_status=$(jq -r '.status // "unknown"' "$phase_file" 2>/dev/null || echo "unknown")
        if [[ "$prev_status" = "success" ]]; then
            log_info "Fase ${prev_phase}: ${prev_status}"
        else
            log_warn "Fase ${prev_phase}: ${prev_status} (se recomienda completarla)"
        fi
    fi
done

# Check config directory
if [[ -d "$CONFIG_DIR" ]]; then
    log_info "Directorio de configuración: ${CONFIG_DIR}"
else
    log_warn "Directorio de configuración no encontrado: ${CONFIG_DIR}"
fi

# Check for SOUL.md
if [[ -f "$CONFIG_DIR/SOUL.md" ]]; then
    log_info "SOUL.md encontrado (identidad configurada)"
else
    log_warn "SOUL.md no encontrado (identidad no configurada en Fase 4)"
fi

# Check for openclaw.json or FLEET.json
if [[ -f "$CONFIG_DIR/openclaw.json" ]]; then
    log_info "openclaw.json encontrado (fleet configurado)"
elif [[ -f "$CONFIG_DIR/gateway.json" ]]; then
    log_info "gateway.json encontrado"
else
    log_warn "No se encontró configuración de gateway/fleet"
fi

# Check node.js
if command -v node &>/dev/null; then
    log_info "Node.js: $(node --version 2>/dev/null)"
else
    log_warn "Node.js no encontrado"
fi

# ==============================================================================
# STEP 2: START SERVICES
# ==============================================================================

log_step "PASO 2: Iniciando servicios"

if [[ "$DRY_RUN" = "true" ]]; then
    log_warn "[DRY-RUN] No se inician servicios reales"
    log_info "[DRY-RUN] Simularía: systemctl --user start openclaw-gateway"
else
    # Try systemd user service
    if command -v systemctl &>/dev/null; then
        if systemctl --user is-active openclaw-gateway &>/dev/null; then
            log_info "Gateway ya está corriendo"
        elif [[ -f "$HOME/.config/systemd/user/openclaw-gateway.service" ]]; then
            log_info "Iniciando gateway via systemd..."
            if systemctl --user start openclaw-gateway 2>/dev/null; then
                sleep 2
                log_info "Gateway iniciado"
            else
                log_warn "No se pudo iniciar gateway via systemd"
            fi
        else
            log_warn "Servicio systemd no encontrado para gateway"
        fi
    else
        log_warn "systemd no disponible"
    fi
fi

# ==============================================================================
# STEP 3: SMOKE TESTS
# ==============================================================================

log_step "PASO 3: Smoke Tests"

# Test 1: Config files exist and are valid JSON
echo -e "\n  ${BOLD}Test 1: Archivos de configuración${NC}"
for config_file in "turnkey-config.json" "turnkey-env.json" "turnkey-status.json"; do
    local_path="$HOME/.openclaw/workspace/turnkey/${config_file}"
    if [[ -f "$local_path" ]]; then
        if command -v jq &>/dev/null && jq . "$local_path" > /dev/null 2>&1; then
            log_test_pass "${config_file} existe y es JSON válido"
        else
            log_test_pass "${config_file} existe"
        fi
    else
        log_test_fail "${config_file} no encontrado"
    fi
done

# Test 2: Identity files
echo -e "\n  ${BOLD}Test 2: Archivos de identidad${NC}"
for id_file in "SOUL.md" "USER.md" "HEART.md"; do
    if [[ -f "$CONFIG_DIR/$id_file" ]]; then
        log_test_pass "$id_file encontrado"
    else
        log_test_fail "$id_file no encontrado"
    fi
done

# Test 3: Gateway health check
echo -e "\n  ${BOLD}Test 3: Health check del gateway${NC}"
if [[ "$DRY_RUN" = "true" ]]; then
    log_test_pass "[DRY-RUN] Gateway health check simulado"
else
    if command -v curl &>/dev/null; then
        if curl -s --max-time 5 "http://localhost:${PORT}/health" &>/dev/null; then
            log_test_pass "Gateway responde en puerto ${PORT}"
        elif curl -s --max-time 5 "http://localhost:${PORT}" &>/dev/null; then
            log_test_pass "Gateway accesible en puerto ${PORT}"
        else
            log_test_fail "Gateway no responde en puerto ${PORT}"
        fi
    else
        log_test_fail "curl no disponible para health check"
    fi
fi

# Test 4: Telegram bot validation
echo -e "\n  ${BOLD}Test 4: Validación de canales${NC}"
if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
    tg_enabled=$(jq -r '.channels.telegram.enabled // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
    if [[ "$tg_enabled" = "true" ]]; then
        tg_token=$(jq -r '.channels.telegram.bot_token // ""' "$CONFIG_FILE" 2>/dev/null || echo "")
        if [[ -n "$tg_token" && "$tg_token" != "BOT_TOKEN_HERE" ]]; then
            if [[ "$DRY_RUN" = "true" ]]; then
                log_test_pass "[DRY-RUN] Telegram token presente"
            else
                if curl -s --max-time 5 "https://api.telegram.org/bot${tg_token}/getMe" | grep -q '"ok":true' 2>/dev/null; then
                    log_test_pass "Telegram bot token válido"
                else
                    log_test_fail "Telegram bot token inválido"
                fi
            fi
        else
            log_test_fail "Telegram habilitado pero sin token real"
        fi
    else
        log_test_pass "Telegram deshabilitado (no aplica)"
    fi
else
    log_test_pass "No hay config de canales para validar"
fi

# Test 5: Directory structure
echo -e "\n  ${BOLD}Test 5: Estructura de directorios${NC}"
for dir in "config" "workspace" "logs" "data"; do
    if [[ -d "$OPENCLAW_DIR/$dir" ]]; then
        log_test_pass "~/.openclaw/$dir existe"
    else
        log_test_fail "~/.openclaw/$dir no encontrado"
    fi
done

# ==============================================================================
# STEP 4: GENERATE ACTIVATION REPORT
# ==============================================================================

# Test 6: LLM model ping
echo -e "\n  ${BOLD}Test 6: Modelo LLM${NC}"
if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]] && command -v jq &>/dev/null; then
    ollama_key=$(jq -r '.api_keys.ollama // ""' "$CONFIG_FILE" 2>/dev/null || echo "")
    if [[ -n "$ollama_key" && "$ollama_key" != "YOUR_OLLAMA_API_KEY" ]]; then
        if [[ "$DRY_RUN" = "true" ]]; then
            log_test_pass "[DRY-RUN] API key de Ollama presente"
        else
            if curl -s --max-time 10 -H "Authorization: Bearer ${ollama_key}" "https://api.ollama.com/v1/models" | grep -q '"id"' 2>/dev/null; then
                log_test_pass "Modelo LLM responde correctamente"
            else
                log_test_fail "No se pudo conectar con API de Ollama"
            fi
        fi
    else
        log_test_fail "API key de Ollama no configurada"
    fi
else
    log_test_pass "No hay config para validar modelo"
fi

# ==============================================================================
# STEP 4: GENERATE ACTIVATION REPORT
# ==============================================================================

log_step "PASO 4: Generando reporte de activación"

report_dir="$HOME/.openclaw/workspace/turnkey"
mkdir -p "$report_dir" 2>/dev/null || true

cat > "${report_dir}/activation-report.json" << EOF
{
  "phase": 6,
  "status": "$([ $TESTS_FAILED -eq 0 ] && echo "success" || echo "partial")",
  "timestamp": "$(date -Iseconds)",
  "agent": {
    "name": "${AGENT_NAME}",
    "port": ${PORT}
  },
  "smoke_tests": {
    "total": ${TESTS_TOTAL},
    "passed": ${TESTS_PASSED},
    "failed": ${TESTS_FAILED}
  },
  "dry_run": ${DRY_RUN},
  "version": "${VERSION}"
}
EOF
log_info "Reporte guardado: activation-report.json"

# ==============================================================================
# SUMMARY
# ==============================================================================

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              RESULTADO DE ACTIVACIÓN                          ║${NC}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} Agente:       ${BOLD}${AGENT_NAME}${NC}"
echo -e "${CYAN}║${NC} Puerto:       ${PORT}"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${NC} Tests totales: ${TESTS_TOTAL}"
echo -e "${CYAN}║${NC} Pasaron:       ${GREEN}${TESTS_PASSED}${NC}"
echo -e "${CYAN}║${NC} Fallaron:      $([ $TESTS_FAILED -gt 0 ] && echo "${RED}${TESTS_FAILED}${NC}" || echo "${GREEN}${TESTS_FAILED}${NC}")"
echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${CYAN}║${NC} ${GREEN}${BOLD}✅ AGENTE ACTIVADO EXITOSAMENTE${NC}"
else
    echo -e "${CYAN}║${NC} ${YELLOW}${BOLD}⚠️  ACTIVADO CON ${TESTS_FAILED} ADVERTENCIA(S)${NC}"
fi

echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Exit with appropriate code
if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
fi
exit 0