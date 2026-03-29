#!/bin/bash
# ==============================================================================
# TURNKEY v6 — Script Maestro
# ==============================================================================
# Orquesta las 6 fases del despliegue de un agente OpenClaw.
#
# Uso:
#   ./turnkey.sh --config config.json
#   ./turnkey.sh --config config.json --dry-run
#   ./turnkey.sh --config config.json --from-phase 4
#   ./turnkey.sh --help
# ==============================================================================

set -euo pipefail

readonly VERSION="6.3.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PHASES_DIR="${SCRIPT_DIR}/phases"
readonly WORK_DIR="${HOME}/.openclaw/workspace/turnkey"
readonly LOG_FILE="${WORK_DIR}/turnkey.log"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Estado global
CONFIG_FILE=""
DRY_RUN=false
FROM_PHASE=1
FORCE=false
VERBOSE=false
VPS_TIER=""
PHASE_STATUS=()

# ==============================================================================
# LOGGING
# ==============================================================================

log() {
    local level="$1"; shift
    local msg="$*"
    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    echo "[$ts] [$level] $msg" >> "$LOG_FILE" 2>/dev/null || true

    case "$level" in
        INFO)    echo -e "  ${GREEN}✓${NC} $msg" ;;
        WARN)    echo -e "  ${YELLOW}⚠${NC} $msg" ;;
        ERROR)   echo -e "  ${RED}✗${NC} $msg" >&2 ;;
        STEP)    echo -e "  ${BLUE}→${NC} $msg" ;;
        SUCCESS) echo -e "  ${CYAN}★${NC} ${BOLD}$msg${NC}" ;;
        PHASE)   echo -e "\n${MAGENTA}━━━ $msg ━━━${NC}" ;;
    esac
}

# ==============================================================================
# HEADER & USAGE
# ==============================================================================

show_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              TURNKEY v6 — Despliegue de Agentes               ║${NC}"
    echo -e "${CYAN}║                    Lumen AI © 2026                             ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║  Versión:${NC} ${VERSION}"
    echo -e "${CYAN}║  Config:${NC}  ${CONFIG_FILE:-ninguno}"
    echo -e "${CYAN}║  Modo:${NC}    $([ "$DRY_RUN" = true ] && echo "SIMULACIÓN" || echo "PRODUCCIÓN")"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_usage() {
    cat << 'EOF'
Uso: ./turnkey.sh [OPCIONES]

Orquesta las 6 fases del despliegue de un agente OpenClaw.

Opciones:
    -c, --config FILE       Archivo de configuración JSON (requerido)
    -d, --dry-run           Simular sin hacer cambios
    -f, --from-phase N      Comenzar desde la fase N (1-6)
    --force                 Continuar aunque haya warnings
    -v, --verbose           Mostrar más detalle
    -h, --help              Mostrar esta ayuda

Fases:
    1  PRE-FLIGHT       Validar entorno y prerequisitos
    2  SETUP USERS      Crear usuario y directorios
    3  GATEWAY INSTALL  Instalar/configurar OpenClaw Gateway
    4  IDENTITY FLEET   Identidad + modelos + skills + conocimiento
    5  BOT CONFIG       Configurar canales (Telegram, Email, etc.)
    6  ACTIVATION       Activar servicios y smoke tests

Production Layer (v6.3):
    --tier TIER          Forzar tier (standard|premium). Auto-detecta si no se especifica.

    El Production Layer incluye:
    - Swap automático (4GB)
    - Hardening (UFW, fail2ban, SSH)
    - Límites de concurrencia por tier
    - Auto-restart (systemd Restart=always)
    - Health checks expandidos (8 tests)
    - Snapshot de configuración final

Ejemplos:
    ./turnkey.sh --config examples/restaurant.json --dry-run
    ./turnkey.sh --config mi-agente.json
    ./turnkey.sh --config mi-agente.json --from-phase 4

EOF
    exit 0
}

# ==============================================================================
# PARSE ARGS
# ==============================================================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)     CONFIG_FILE="$2"; shift 2 ;;
            -d|--dry-run)    DRY_RUN=true; shift ;;
            -f|--from-phase) FROM_PHASE="$2"; shift 2 ;;
            --force)         FORCE=true; shift ;;
            -v|--verbose)    VERBOSE=true; shift ;;
            -t|--tier)       VPS_TIER="$2"; shift 2 ;;
            -h|--help)       show_usage ;;
            *)               log ERROR "Opción desconocida: $1"; show_usage ;;
        esac
    done

    if [[ -z "$CONFIG_FILE" ]]; then
        log ERROR "Se requiere --config FILE"
        echo ""
        show_usage
    fi

    if [[ ! -f "$CONFIG_FILE" ]]; then
        log ERROR "Archivo no encontrado: $CONFIG_FILE"
        exit 1
    fi

    if [[ "$FROM_PHASE" -lt 1 || "$FROM_PHASE" -gt 6 ]]; then
        log ERROR "--from-phase debe ser entre 1 y 6"
        exit 1
    fi
}

# ==============================================================================
# CONFIG HELPERS
# ==============================================================================

read_config() {
    local key="$1"
    local default="${2:-}"

    if ! command -v jq &>/dev/null; then
        log WARN "jq no instalado, usando defaults"
        echo "$default"
        return
    fi

    local val
    val=$(jq -r "$key // empty" "$CONFIG_FILE" 2>/dev/null || echo "")
    echo "${val:-$default}"
}

validate_config() {
    log STEP "Validando archivo de configuración..."

    if ! command -v jq &>/dev/null; then
        log WARN "jq no disponible, saltando validación JSON"
        return 0
    fi

    if ! jq . "$CONFIG_FILE" > /dev/null 2>&1; then
        log ERROR "JSON inválido en: $CONFIG_FILE"
        exit 1
    fi

    # Validar campos mínimos
    local agent_name
    agent_name=$(read_config ".agent.name")
    if [[ -z "$agent_name" ]]; then
        log ERROR "Campo requerido faltante: agent.name"
        exit 1
    fi

    local ollama_key
    ollama_key=$(read_config ".api_keys.ollama")
    if [[ -z "$ollama_key" ]]; then
        log WARN "api_keys.ollama no configurado"
    fi

    log INFO "Configuración válida: agente '${agent_name}'"
}

# ==============================================================================
# PHASE RUNNER
# ==============================================================================

save_phase_status() {
    local phase_num="$1"
    local status="$2"
    local message="$3"

    mkdir -p "$WORK_DIR" 2>/dev/null || true

    local status_file="${WORK_DIR}/phase-${phase_num}-status.json"

    if command -v jq &>/dev/null; then
        jq -n \
            --argjson phase "$phase_num" \
            --arg status "$status" \
            --arg message "$message" \
            --arg timestamp "$(date -Iseconds)" \
            --argjson dry_run "$DRY_RUN" \
            '{phase: $phase, status: $status, message: $message, timestamp: $timestamp, dry_run: $dry_run}' \
            > "$status_file"
    else
        # Fallback: basic heredoc (jq not available)
        cat > "$status_file" << EOFSTATUS
{
  "phase": $phase_num,
  "status": "$status",
  "message": "$message",
  "timestamp": "$(date -Iseconds)",
  "dry_run": $DRY_RUN
}
EOFSTATUS
    fi
}

check_phase_prereqs() {
    local phase_num="$1"

    # Phase 1 has no prereqs
    [[ "$phase_num" -le 1 ]] && return 0

    # Check previous phase status
    local prev=$((phase_num - 1))
    local prev_status_file="${WORK_DIR}/phase-${prev}-status.json"

    if [[ -f "$prev_status_file" ]]; then
        if command -v jq &>/dev/null; then
            local prev_status
            prev_status=$(jq -r '.status' "$prev_status_file" 2>/dev/null || echo "unknown")
            if [[ "$prev_status" != "success" && "$prev_status" != "skipped" ]]; then
                log WARN "Fase $prev tiene estado: $prev_status"
                if [[ "$FORCE" != "true" ]]; then
                    log ERROR "Use --force para continuar de todos modos"
                    return 1
                fi
            fi
        fi
    else
        if [[ "$FROM_PHASE" -le "$prev" ]]; then
            log WARN "Fase $prev no tiene registro de estado"
        fi
    fi

    return 0
}

# ==============================================================================
# PHASE 1: PRE-FLIGHT
# ==============================================================================

run_phase_1() {
    log PHASE "FASE 1: PRE-FLIGHT — Validación del entorno"

    local script="${PHASES_DIR}/01-pre-flight/pre-flight.sh"

    if [[ ! -f "$script" ]]; then
        log ERROR "Script no encontrado: $script"
        return 1
    fi

    local args=("--config" "$CONFIG_FILE")
    [[ "$DRY_RUN" = true ]] && args+=("--force")

    # Copy config to work dir for other phases
    mkdir -p "$WORK_DIR" 2>/dev/null || true
    cp "$CONFIG_FILE" "${WORK_DIR}/turnkey-config.json" 2>/dev/null || true

    if bash "$script" "${args[@]}"; then
        save_phase_status 1 "success" "Pre-flight completado"
        log SUCCESS "FASE 1 completada"
    else
        save_phase_status 1 "failed" "Pre-flight falló"
        log ERROR "FASE 1 falló"
        return 1
    fi
}

# ==============================================================================
# PHASE 2: SETUP USERS
# ==============================================================================

run_phase_2() {
    log PHASE "FASE 2: SETUP USERS — Configuración de usuario"

    local script="${PHASES_DIR}/02-setup-users/setup-users.sh"
    local agent_name
    agent_name=$(read_config ".agent.name" "agent")

    if [[ ! -f "$script" ]]; then
        log ERROR "Script no encontrado: $script"
        return 1
    fi

    local args=("--name" "$agent_name")
    [[ "$DRY_RUN" = true ]] && args+=("--dry-run")
    [[ "$VERBOSE" = true ]] && args+=("--verbose")

    if bash "$script" "${args[@]}"; then
        save_phase_status 2 "success" "Usuario bee-${agent_name} configurado"
        log SUCCESS "FASE 2 completada"
    else
        save_phase_status 2 "failed" "Setup users falló"
        log ERROR "FASE 2 falló"
        return 1
    fi
}

# ==============================================================================
# PHASE 3: GATEWAY INSTALL
# ==============================================================================

run_phase_3() {
    log PHASE "FASE 3: GATEWAY INSTALL — Instalación del gateway"

    local script="${PHASES_DIR}/03-gateway-install/gateway-install.sh"
    local api_key
    api_key=$(read_config ".api_keys.ollama" "")
    local port
    port=$(read_config ".agent.port" "18789")

    if [[ ! -f "$script" ]]; then
        log ERROR "Script no encontrado: $script"
        return 1
    fi

    local args=()
    [[ -n "$port" ]] && args+=("--port" "$port")
    [[ "$DRY_RUN" = true ]] && args+=("--dry-run")

    # Pass API key via env var (not CLI arg) to avoid ps/proc exposure
    if OLLAMA_API_KEY="$api_key" bash "$script" "${args[@]}"; then
        save_phase_status 3 "success" "Gateway configurado en puerto ${port}"
        log SUCCESS "FASE 3 completada"
    else
        save_phase_status 3 "failed" "Gateway install falló"
        log ERROR "FASE 3 falló"
        return 1
    fi
}

# ==============================================================================
# PHASE 4: IDENTITY + FLEET
# ==============================================================================

run_phase_4() {
    log PHASE "FASE 4: IDENTITY FLEET — Identidad + modelos + skills"

    local scripts_dir="${PHASES_DIR}/04-identity-fleet/scripts"

    # Read config values
    local agent_name
    agent_name=$(read_config ".agent.name" "agent")
    local business_type
    business_type=$(read_config ".agent.template" "generico")
    local business_name
    business_name=$(read_config ".agent.business_name" "$agent_name")
    local email
    email=$(read_config ".agent.email" "")
    local timezone
    timezone=$(read_config ".agent.timezone" "America/Panama")
    local language
    language=$(read_config ".agent.language" "es")

    # Step 1: Setup Identity
    log STEP "Paso 1/4: Configurando identidad..."
    local identity_script="${scripts_dir}/setup-identity.sh"
    if [[ -f "$identity_script" ]]; then
        local identity_args=("--agent-name" "$agent_name" "--business-type" "$business_type" "--business-name" "$business_name")
        [[ -n "$email" ]] && identity_args+=("--email" "$email")
        [[ -n "$timezone" ]] && identity_args+=("--timezone" "$timezone")
        [[ -n "$language" ]] && identity_args+=("--language" "$language")
        [[ "$DRY_RUN" = true ]] && identity_args+=("--dry-run")

        if ! bash "$identity_script" "${identity_args[@]}"; then
            log ERROR "Setup identity falló"
            save_phase_status 4 "failed" "Identity setup falló"
            return 1
        fi
    else
        log WARN "setup-identity.sh no encontrado, saltando"
    fi

    # Step 2: Setup Fleet (models)
    log STEP "Paso 2/4: Configurando fleet de modelos..."
    local fleet_script="${scripts_dir}/setup-fleet.sh"
    if [[ -f "$fleet_script" ]]; then
        local fleet_args=("--agent-name" "$agent_name" "--config" "$CONFIG_FILE")
        [[ "$DRY_RUN" = true ]] && fleet_args+=("--dry-run")

        if ! bash "$fleet_script" "${fleet_args[@]}"; then
            log WARN "Setup fleet falló (no bloqueante)"
        fi
    else
        log WARN "setup-fleet.sh no encontrado, saltando"
    fi

    # Step 3: Setup Skills
    log STEP "Paso 3/4: Configurando skills..."
    local skills_script="${scripts_dir}/setup-skills.sh"
    if [[ -f "$skills_script" ]]; then
        local skills_args=("--agent-name" "$agent_name" "--business-type" "$business_type")
        [[ "$DRY_RUN" = true ]] && skills_args+=("--dry-run")

        if ! bash "$skills_script" "${skills_args[@]}"; then
            log WARN "Setup skills falló (no bloqueante)"
        fi
    else
        log WARN "setup-skills.sh no encontrado, saltando"
    fi

    # Step 4: Process Knowledge
    log STEP "Paso 4/4: Procesando conocimiento..."
    local knowledge_script="${scripts_dir}/process-knowledge.sh"
    if [[ -f "$knowledge_script" ]]; then
        local knowledge_args=("--agent-name" "$agent_name" "--config" "$CONFIG_FILE")
        [[ "$DRY_RUN" = true ]] && knowledge_args+=("--dry-run")

        if ! bash "$knowledge_script" "${knowledge_args[@]}"; then
            log WARN "Process knowledge falló (no bloqueante)"
        fi
    else
        log WARN "process-knowledge.sh no encontrado, saltando"
    fi

    save_phase_status 4 "success" "Identidad, fleet, skills y conocimiento configurados"
    log SUCCESS "FASE 4 completada"
}

# ==============================================================================
# PHASE 5: BOT CONFIG
# ==============================================================================

run_phase_5() {
    log PHASE "FASE 5: BOT CONFIG — Canales de comunicación"

    local scripts_dir="${PHASES_DIR}/05-bot-config/scripts"
    local agent_name
    agent_name=$(read_config ".agent.name" "agent")

    # Setup Telegram
    local tg_enabled
    tg_enabled=$(read_config ".channels.telegram.enabled" "false")
    if [[ "$tg_enabled" = "true" ]]; then
        log STEP "Configurando Telegram..."
        local tg_script="${scripts_dir}/setup-telegram.sh"
        if [[ -f "$tg_script" ]]; then
            local tg_token
            tg_token=$(read_config ".channels.telegram.bot_token" "")
            local tg_users
            tg_users=$(read_config '.channels.telegram.allowed_users | join(",")' "")

            local tg_args=("--agent-name" "$agent_name")
            [[ -n "$tg_users" ]] && tg_args+=("--allowed-users" "$tg_users")
            [[ "$DRY_RUN" = true ]] && tg_args+=("--dry-run")

            # Pass token via env var (not CLI arg) to avoid ps/proc exposure
            TG_BOT_TOKEN="$tg_token" bash "$tg_script" "${tg_args[@]}" || log WARN "Telegram setup falló (no bloqueante)"
        else
            log WARN "setup-telegram.sh no encontrado"
        fi
    else
        log INFO "Telegram deshabilitado"
    fi

    # Setup Email
    local email_enabled
    email_enabled=$(read_config ".channels.email.enabled" "false")
    if [[ "$email_enabled" = "true" ]]; then
        log STEP "Configurando Email..."
        local email_script="${scripts_dir}/setup-email.sh"
        if [[ -f "$email_script" ]]; then
            local email_args=("--agent-name" "$agent_name" "--config" "$CONFIG_FILE")
            [[ "$DRY_RUN" = true ]] && email_args+=("--dry-run")

            bash "$email_script" "${email_args[@]}" || log WARN "Email setup falló (no bloqueante)"
        else
            log WARN "setup-email.sh no encontrado"
        fi
    else
        log INFO "Email deshabilitado"
    fi

    # Setup API Keys
    log STEP "Configurando API keys..."
    local api_script="${scripts_dir}/setup-api-keys.sh"
    if [[ -f "$api_script" ]]; then
        local api_args=("--agent-name" "$agent_name" "--config" "$CONFIG_FILE")
        [[ "$DRY_RUN" = true ]] && api_args+=("--dry-run")

        bash "$api_script" "${api_args[@]}" || log WARN "API keys setup falló (no bloqueante)"
    else
        log WARN "setup-api-keys.sh no encontrado"
    fi

    # Validate channels
    log STEP "Validando canales..."
    local validate_script="${scripts_dir}/validate-channels.sh"
    if [[ -f "$validate_script" ]]; then
        bash "$validate_script" --agent-name "$agent_name" || log WARN "Validación de canales falló"
    fi

    save_phase_status 5 "success" "Canales configurados"
    log SUCCESS "FASE 5 completada"
}

# ==============================================================================
# PHASE 6: ACTIVATION
# ==============================================================================

run_phase_6() {
    log PHASE "FASE 6: ACTIVATION — Activar y verificar"

    local scripts_dir="${PHASES_DIR}/06-activation/scripts"
    local agent_name
    agent_name=$(read_config ".agent.name" "agent")
    local port
    port=$(read_config ".agent.port" "18789")

    local act_script="${scripts_dir}/activation.sh"
    if [[ -f "$act_script" ]]; then
        local act_args=("--agent-name" "$agent_name" "--port" "$port" "--config" "$CONFIG_FILE")
        [[ "$DRY_RUN" = true ]] && act_args+=("--dry-run")

        if bash "$act_script" "${act_args[@]}"; then
            save_phase_status 6 "success" "Agente activado y verificado"
            log SUCCESS "FASE 6 completada"
        else
            save_phase_status 6 "failed" "Activación falló"
            log ERROR "FASE 6 falló"
            return 1
        fi
    else
        log WARN "activation.sh no encontrado"
        save_phase_status 6 "skipped" "Script no encontrado"
    fi
}

# ==============================================================================
# FINAL SUMMARY
# ==============================================================================

show_summary() {
    local agent_name
    agent_name=$(read_config ".agent.name" "agent")
    local port
    port=$(read_config ".agent.port" "18789")

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              TURNKEY v6 — DESPLIEGUE COMPLETO                 ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║${NC}  Agente:       ${CYAN}${agent_name}${NC}"
    echo -e "${GREEN}║${NC}  Usuario:      ${CYAN}bee-${agent_name}${NC}"
    echo -e "${GREEN}║${NC}  Gateway:      ${CYAN}http://localhost:${port}${NC}"

    # Show tier info if available
    local tier_file="${WORK_DIR}/tier-profile.json"
    if [[ -f "$tier_file" ]] && command -v jq &>/dev/null; then
        local tier
        tier=$(jq -r '.vps_tier // "unknown"' "$tier_file" 2>/dev/null || echo "unknown")
        local ram_mb
        ram_mb=$(jq -r '.ram_mb // 0' "$tier_file" 2>/dev/null || echo "0")
        local max_conc
        max_conc=$(jq -r '.max_concurrent // 0' "$tier_file" 2>/dev/null || echo "0")
        echo -e "${GREEN}║${NC}  Tier:         ${CYAN}${tier} (${ram_mb}MB RAM, maxConcurrent=${max_conc})${NC}"
        echo -e "${GREEN}║${NC}  Swap:         ${CYAN}4GB activo${NC}"
        echo -e "${GREEN}║${NC}  Auto-restart: ${CYAN}Restart=always, RestartSec=5${NC}"
        echo -e "${GREEN}║${NC}  Hardening:    ${CYAN}UFW + fail2ban + SSH${NC}"
    fi

    echo -e "${GREEN}║${NC}  Config dir:   ${CYAN}~/.openclaw/config/${NC}"
    echo -e "${GREEN}║${NC}  Logs:         ${CYAN}~/.openclaw/logs/${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"

    # Show phase results
    for i in $(seq 1 6); do
        local phase_file="${WORK_DIR}/phase-${i}-status.json"
        local status="⏳"
        if [[ -f "$phase_file" ]] && command -v jq &>/dev/null; then
            local s
            s=$(jq -r '.status' "$phase_file" 2>/dev/null || echo "unknown")
            case "$s" in
                success) status="✅" ;;
                failed)  status="❌" ;;
                skipped) status="⏭️" ;;
                *)       status="⏳" ;;
            esac
        elif [[ $i -lt $FROM_PHASE ]]; then
            status="⏭️"
        fi
        local phase_names=("" "PRE-FLIGHT" "SETUP USERS" "GATEWAY" "IDENTITY" "BOT CONFIG" "ACTIVATION")
        echo -e "${GREEN}║${NC}  Fase $i ${phase_names[$i]}:  $status"
    done

    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"

    if [[ "$DRY_RUN" = true ]]; then
        echo ""
        echo -e "  ${YELLOW}[SIMULACIÓN] No se hicieron cambios reales.${NC}"
        echo -e "  ${YELLOW}Ejecuta sin --dry-run para hacer el despliegue real.${NC}"
    fi

    echo ""
    echo -e "  ${BLUE}Log completo:${NC} $LOG_FILE"
    echo ""
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    parse_args "$@"
    show_header
    validate_config

    local phases=(run_phase_1 run_phase_2 run_phase_3 run_phase_4 run_phase_5 run_phase_6)

    for i in $(seq "$FROM_PHASE" 6); do
        # Check prerequisites
        if ! check_phase_prereqs "$i"; then
            log ERROR "Prerequisitos de Fase $i no cumplidos"
            break
        fi

        # Run the phase
        local func="${phases[$((i-1))]}"
        if ! $func; then
            log ERROR "Fase $i falló. Proceso detenido."
            if [[ "$FORCE" = true ]]; then
                log WARN "Continuando por --force"
                continue
            fi
            break
        fi
    done

    show_summary
}

main "$@"
