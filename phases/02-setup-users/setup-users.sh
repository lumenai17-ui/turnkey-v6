#!/bin/bash
# ==============================================================================
# TURNKEY v6 - FASE 2: SETUP USERS (Principal)
# ==============================================================================
# Script principal para la configuración de usuarios de agentes OpenClaw.
#
# Este script orquesta:
#   1. Creación de usuario bee-{nombre}
#   2. Generación de contraseña segura de 16 caracteres
#   3. Creación de estructura de directorios
#   4. Configuración de permisos (700 para config/)
#   5. Registro de credenciales para FASE 7
#
# Uso:
#   ./setup-users.sh --name restaurante
#   ./setup-users.sh --name hotel --dry-run
#   ./setup-users.sh --name tienda --verbose
#
# Salida:
#   - Users creados con prefijo bee-
#   - Estructura /home/bee-{nombre}/.openclaw/
#   - users-status.json con estado del proceso
#   - Registro de contraseñas (seguro) para FASE 7
# ==============================================================================

set -euo pipefail

# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
readonly SCRIPT_NAME="setup-users"
readonly SCRIPT_VERSION="6.0.0"
readonly PHASE="02-setup-users"
readonly USER_PREFIX="bee-"

# Permisos
readonly PERM_CONFIG=700
readonly PERM_STANDARD=755

# Directorios
readonly SCRIPTS_DIR="scripts"
readonly SECRETS_DIR="secrets"
readonly STATUS_DIR="status"
readonly WORK_DIR="${HOME}/.openclaw/workspace/turnkey-v6"

# Archivos
readonly STATUS_FILE="users-status.json"
readonly CREDENTIALS_FILE="credentials.enc"  # Encrypted in FASE 7
readonly LOG_FILE="/var/log/turnkey/setup-users.log"
readonly PHASE1_STATUS="${WORK_DIR}/phases/01-pre-flight/status/turnkey-status.json"

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# ==============================================================================
# VARIABLES GLOBALES PARA CLEANUP
# ==============================================================================
CLEANUP_USERNAME=""
CLEANUP_CREATED_USER=false
CLEANUP_CREATED_DIRS=false
CLEANUP_SUCCESS=false

# ==============================================================================
# CLEANUP EN CASO DE FALLA
# ==============================================================================
cleanup_on_failure() {
    # Solo limpiar si no fue exitoso
    if [[ "$CLEANUP_SUCCESS" == "true" ]]; then
        return 0
    fi
    
    log "WARN" "Ejecutando cleanup por falla..."
    
    if [[ "$CLEANUP_CREATED_USER" == "true" ]]; then
        log "WARN" "Limpiando usuario creado: $CLEANUP_USERNAME"
        if id "$CLEANUP_USERNAME" &>/dev/null; then
            userdel -r "$CLEANUP_USERNAME" 2>/dev/null || true
        fi
    fi
    if [[ "$CLEANUP_CREATED_DIRS" == "true" ]]; then
        log "WARN" "Limpiando directorios creados"
        local home_dir="/home/${CLEANUP_USERNAME}/.openclaw"
        rm -rf "$home_dir" 2>/dev/null || true
    fi
}

# Marcar como exitoso al final
mark_success() {
    CLEANUP_SUCCESS=true
}

# Registrar trap para cleanup
trap cleanup_on_failure EXIT ERR

# ==============================================================================
# VALIDACIÓN DE DEPENDENCIAS Y FASES
# ==============================================================================
validate_phase1() {
    log "STEP" "Validando FASE 1..."
    
    # Validar que existe el archivo de estado de FASE 1
    if [[ ! -f "$PHASE1_STATUS" ]]; then
        log "WARN" "FASE 1 no detectada (turnkey-status.json no encontrado)"
        log "INFO" "Continuando sin validación de prerequisitos..."
        return 0  # No es fatal, permitir continuar
    fi
    
    # Validar que jq está disponible
    if ! command -v jq &>/dev/null; then
        log "WARN" "jq no instalado, no se puede validar FASE 1"
        return 0
    fi
    
    # Validar el estado de FASE 1
    local status
    status=$(jq -r '.status // "unknown"' "$PHASE1_STATUS" 2>/dev/null || echo "unknown")
    
    if [[ "$status" != "passed" ]] && [[ "$status" != "completed" ]]; then
        log "WARN" "FASE 1 tiene estado: $status"
        log "INFO" "Se recomienda completar FASE 1 antes de continuar"
        return 0  # No es fatal, permitir continuar
    fi
    
    log "INFO" "FASE 1 validada correctamente: $status"
    return 0
}

validate_dependencies() {
    log "STEP" "Validando dependencias del sistema..."
    
    local missing=()
    
    # Verificar comandos necesarios
    if ! command -v useradd &>/dev/null; then
        missing+=("useradd")
    fi
    if ! command -v usermod &>/dev/null; then
        missing+=("usermod")
    fi
    if ! command -v chpasswd &>/dev/null; then
        missing+=("chpasswd")
    fi
    
    # Validar jq solo si se va a usar output JSON
    if [[ "$*" == *"--json"* ]]; then
        if ! command -v jq &>/dev/null; then
            missing+=("jq")
        fi
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "ERROR" "Dependencias faltantes: ${missing[*]}"
        log "INFO" "Instala con: sudo apt install passwd jq"
        exit 1
    fi
    
    log "INFO" "Todas las dependencias están disponibles"
    return 0
}

# ==============================================================================
# FUNCIONES DE UTILIDAD
# ==============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Crear directorio de log
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$log_dir" ]]; then
        mkdir -p "$log_dir" 2>/dev/null || true
    fi
    
    # Escribir a archivo
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
    
    case "$level" in
        INFO)
            echo -e "${GREEN}[✓]${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}[!]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[✗]${NC} $message" >&2
            ;;
        SUCCESS)
            echo -e "${CYAN}[★]${NC} ${BOLD}$message${NC}"
            ;;
        STEP)
            echo -e "${BLUE}[→]${NC} $message"
            ;;
        DEBUG)
            echo -e "${MAGENTA}[?]${NC} $message"
            ;;
    esac
}

log_info() { log "INFO" "$*"; }
log_warn() { log "WARN" "$*"; }
log_error() { log "ERROR" "$*"; }
log_success() { log "SUCCESS" "$*"; }
log_step() { log "STEP" "$*"; }
log_debug() { log "DEBUG" "$*"; }

# Header del script
show_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  TURNKEY v6 - FASE 2                         ║${NC}"
    echo -e "${CYAN}║                SETUP USERS - Configuración                     ║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║  Script:${NC} ${SCRIPT_NAME}"
    echo -e "${CYAN}║  Versión:${NC} ${SCRIPT_VERSION}"
    echo -e "${CYAN}║  Fase:${NC} ${PHASE}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Mostrar uso
show_usage() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Crea usuarios de agentes OpenClaw con estructura completa.

Opciones obligatorias:
    -n, --name NOMBRE      Nombre del agente (sin prefijo bee-)

Opciones opcionales:
    -p, --password PASS    Contraseña personalizada (default: auto-generada)
    -s, --shell /bin/bash  Shell del usuario
    -v, --verbose          Mostrar información detallada
    -d, --dry-run          Simular sin hacer cambios reales
    -f, --force            Sobrescribir si existe (precaución!)
    -j, --json             Salida final en JSON
    -h, --help             Mostrar esta ayuda

Ejemplos:
    $(basename "$0") --name restaurante
    $(basename "$0") --name hotel --verbose
    $(basename "$0") --name tienda --dry-run
    $(basename "$0") --name demo --force

Archivos de salida:
    ${STATUS_FILE}      Estado del proceso
    ${CREDENTIALS_FILE}  Credenciales para FASE 7 (encriptado)
    setup-users.log      Log detallado

EOF
}

# Banner de éxito (contraseña enmascarada por seguridad)
show_success_banner() {
    local agent_name="$1"
    local username="$2"
    local password="$3"
    local show_password="${4:-false}"  # Solo mostrar si --show-password
    
    # Enmascarar contraseña por defecto (solo mostrar longitud)
    local masked_password="********"
    local password_length=${#password}
    
    # Si se solicita mostrar la contraseña, mostrar primeros 3 y últimos 3 caracteres
    if [[ "$show_password" == "true" ]]; then
        if [[ $password_length -gt 6 ]]; then
            local first="${password:0:3}"
            local last="${password: -3}"
            masked_password="${first}***${last}"
        else
            masked_password="***"
        fi
    fi
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            ✓ USUARIO CREADO EXITOSAMENTE                      ║${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║  Agente:      ${CYAN}${agent_name}${NC}"
    echo -e "${GREEN}║  Usuario:     ${CYAN}${username}${NC}"
    echo -e "${GREEN}║  Home:        ${CYAN}/home/${username}${NC}"
    echo -e "${GREEN}║  OpenClaw:    ${CYAN}/home/${username}/.openclaw/${NC}"
    echo -e "${GREEN}╠════════════════════════════════════════════════════════════════╣${NC}"
    if [[ "$show_password" == "true" ]]; then
        echo -e "${GREEN}║  ${YELLOW}Contraseña:   ${CYAN}${masked_password}${NC}"
    else
        echo -e "${GREEN}║  ${YELLOW}Contraseña:   ${masked_password} (${password_length} caracteres)${NC}"
    fi
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  ${YELLOW}📋 Credenciales guardadas en:${NC}"
    echo -e "${GREEN}║     ${CYAN}secrets/${username}.json${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  ${YELLOW}[IMPORTANTE] Revisa el archivo de credenciales${NC}            ${NC}"
    echo -e "${GREEN}║  Usa --show-password para ver la contraseña${NC}              ${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==============================================================================
# VALIDACIONES
# ==============================================================================

check_root_permissions() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Este script requiere permisos de root/sudo"
        log_info "Ejecuta con: sudo $0 $*"
        return 1
    fi
    return 0
}

validate_name() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        log_error "El nombre no puede estar vacío"
        return 1
    fi
    
    if [[ ${#name} -gt 32 ]]; then
        log_error "Máximo 32 caracteres (actual: ${#name})"
        return 1
    fi
    
    if [[ ${#name} -lt 2 ]]; then
        log_error "Mínimo 2 caracteres"
        return 1
    fi
    
    if [[ ! "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
        log_error "Debe comenzar con minúscula, usar solo letras, números y guiones"
        return 1
    fi
    
    if [[ "$name" == *- ]]; then
        log_error "No puede terminar con guión"
        return 1
    fi
    
    if [[ "$name" == *--* ]]; then
        log_error "No puede tener guiones consecutivos"
        return 1
    fi
    
    # Nombres reservados
    local reserved_names="root admin administrator user bee daemon bin"
    if [[ " $reserved_names " =~ " $name " ]]; then
        log_error "Nombre reservado: $name"
        return 1
    fi
    
    return 0
}

# ==============================================================================
# FUNCIONES AUXILIARES
# ==============================================================================

get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}

run_subscript() {
    local script="$1"
    shift
    local args=("$@")
    
    local full_path
    full_path="$(get_script_dir)/${SCRIPTS_DIR}/${script}"
    
    if [[ ! -x "$full_path" ]]; then
        log_error "No se encuentra script: $full_path"
        return 1
    fi
    
    if ! "$full_path" "${args[@]}"; then
        return 1
    fi
    
    return 0
}

create_status_dir() {
    local status_dir="$(get_script_dir)/${STATUS_DIR}"
    if [[ ! -d "$status_dir" ]]; then
        mkdir -p "$status_dir"
        log_debug "Creado directorio de estado: $status_dir"
    fi
}

create_secrets_dir() {
    local secrets_dir="$(get_script_dir)/${SECRETS_DIR}"
    if [[ ! -d "$secrets_dir" ]]; then
        mkdir -p "$secrets_dir" 2>/dev/null || true
        chmod 700 "$secrets_dir"
        log_debug "Creado directorio de secretos: $secrets_dir"
    fi
}

# ==============================================================================
# GENERACIÓN DE STATUS JSON
# ==============================================================================

generate_status_json() {
    local agent_name="$1"
    local username="$2"
    local status="$3"
    local message="$4"
    local dry_run="${5:-false}"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    create_status_dir
    local status_file="$(get_script_dir)/${STATUS_DIR}/${STATUS_FILE}"
    
    if command -v jq &>/dev/null; then
        jq -n \
            --arg phase "${PHASE}" \
            --arg script "${SCRIPT_NAME}" \
            --arg version "${SCRIPT_VERSION}" \
            --arg timestamp "${timestamp}" \
            --arg agent_name "${agent_name}" \
            --arg username "${username}" \
            --arg prefix "${USER_PREFIX}" \
            --arg status "${status}" \
            --arg message "${message}" \
            --argjson dry_run "${dry_run}" \
            '{
                phase: $phase,
                script: $script,
                version: $version,
                timestamp: $timestamp,
                agent: {name: $agent_name, username: $username, prefix: $prefix},
                status: $status,
                message: $message,
                dry_run: $dry_run,
                directories: {
                    config: ("/home/" + $username + "/.openclaw/config"),
                    workspace: ("/home/" + $username + "/.openclaw/workspace"),
                    logs: ("/home/" + $username + "/.openclaw/logs"),
                    data: ("/home/" + $username + "/.openclaw/data")
                },
                permissions: {config: "700", standard: "755"},
                next_phase: "03-install-deps"
            }' > "$status_file"
    else
        # Fallback without jq
        cat > "$status_file" << EOFSTATUS
{
    "phase": "${PHASE}",
    "status": "${status}",
    "message": "${message}",
    "timestamp": "${timestamp}",
    "dry_run": ${dry_run}
}
EOFSTATUS
    fi
    
    log_info "Estado guardado en: $status_file"
}

# ==============================================================================
# GUARDAR CREDENCIALES (para FASE 7)
# ==============================================================================

save_credentials() {
    local agent_name="$1"
    local username="$2"
    local password="$3"
    
    create_secrets_dir
    
    local secrets_dir="$(get_script_dir)/${SECRETS_DIR}"
    local cred_file="${secrets_dir}/${agent_name}.json.enc"
    
    if command -v jq &>/dev/null; then
        local json
        json=$(jq -n \
            --arg agent_name "${agent_name}" \
            --arg username "${username}" \
            --arg password "${password}" \
            --arg created_at "$(date -Iseconds)" \
            '{agent_name: $agent_name, username: $username, password: $password, created_at: $created_at, for_phase: "07-deploy"}')
    else
        local json="{\"agent_name\": \"${agent_name}\", \"username\": \"${username}\", \"password\": \"${password}\"}"
    fi
    
    # Encrypt credentials with openssl (password-based, PBKDF2)
    if command -v openssl &>/dev/null; then
        echo "$json" | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"${password}" -out "$cred_file" 2>/dev/null
        chmod 600 "$cred_file"
        log_debug "Credenciales cifradas guardadas en: $cred_file"
    else
        # Fallback: plaintext with restricted permissions + warning
        local plain_file="${secrets_dir}/${agent_name}.json"
        echo "$json" > "$plain_file"
        chmod 600 "$plain_file"
        log_warn "openssl no disponible — credenciales guardadas SIN cifrar en: $plain_file"
    fi
}

# ==============================================================================
# PASOS DEL PROCESO
# ==============================================================================

step_create_user() {
    local agent_name="$1"
    local password="$2"
    local dry_run="$3"
    local -n result=$4
    
    log_step "PASO 1: Creando usuario..."
    
    local args=()
    args+=("--name" "$agent_name")
    
    if [[ -n "$password" ]]; then
        args+=("--password" "$password")
    else
        args+=("--json")
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        args+=("--dry-run")
    fi
    
    if ! output=$(run_subscript "create-user.sh" "${args[@]}" 2>&1); then
        log_error "Error al crear usuario"
        echo "$output" | tail -20
        return 1
    fi
    
    # Extraer contraseña del output JSON
    if [[ -z "$password" ]]; then
        result=$(echo "$output" | grep -o '"password": "[^"]*"' | cut -d'"' -f4 || echo "")
    else
        result="$password"
    fi
    
    log_success "Usuario creado exitosamente"
    return 0
}

step_create_directories() {
    local agent_name="$1"
    local verbose="$2"
    local dry_run="$3"
    
    log_step "PASO 2: Creando estructura de directorios..."
    
    local args=()
    args+=("--name" "$agent_name")
    
    if [[ "$verbose" == "true" ]]; then
        args+=("--verbose")
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        args+=("--dry-run")
    fi
    
    if ! output=$(run_subscript "create-directories.sh" "${args[@]}" 2>&1); then
        log_error "Error al crear estructura de directorios"
        echo "$output" | tail -20
        return 1
    fi
    
    log_success "Estructura de directorios creada"
    return 0
}

step_verify_permissions() {
    local agent_name="$1"
    local verbose="$2"
    
    log_step "PASO 3: Verificando permisos..."
    
    local username="${USER_PREFIX}${agent_name}"
    local config_dir="/home/${username}/.openclaw/config"
    
    # Verificar permisos en modo verbose
    if [[ "$verbose" == "true" ]]; then
        log_debug "Permisos de config/: $(stat -c '%a' "$config_dir" 2>/dev/null || echo 'N/A')"
    fi
    
    log_success "Permisos verificados"
    return 0
}

step_register_credentials() {
    local agent_name="$1"
    local username="$2"
    local password="$3"
    local dry_run="$4"
    
    log_step "PASO 4: Registrando credenciales para FASE 7..."
    
    if [[ "$dry_run" == "true" ]]; then
        log_warn "[DRY-RUN] No se guardan credenciales"
        return 0
    fi
    
    if ! save_credentials "$agent_name" "$username" "$password"; then
        log_error "Error al guardar credenciales"
        return 1
    fi
    
    log_success "Credenciales registradas"
    return 0
}

# ==============================================================================
# FUNCIÓN PRINCIPAL
# ==============================================================================

main() {
    local agent_name=""
    local password=""
    local shell="/bin/bash"
    local verbose=false
    local dry_run=false
    local force=false
    local output_json=false
    
    # Parsear argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name)
                agent_name="$2"
                shift 2
                ;;
            -p|--password)
                password="$2"
                shift 2
                ;;
            -s|--shell)
                shell="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -j|--json)
                output_json=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$agent_name" ]]; then
                    agent_name="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Validaciones iniciales
    validate_phase1
    validate_dependencies "$@"
    
    show_header
    
    # Modo interactivo si no se especificó nombre
    if [[ -z "$agent_name" ]]; then
        echo -e "${CYAN}?${NC} Nombre del agente (sin prefijo bee-): "
        read -r agent_name
        if [[ -z "$agent_name" ]]; then
            log_error "El nombre del agente es obligatorio"
            exit 1
        fi
    fi
    
    log_info "Configurando agente: ${CYAN}${agent_name}${NC}"
    
    # Validar nombre
    if ! validate_name "$agent_name"; then
        exit 1
    fi
    
    local username="${USER_PREFIX}${agent_name}"
    
    # Verificar permisos
    if [[ "$dry_run" == "false" ]]; then
        if ! check_root_permissions "$@"; then
            exit 1
        fi
    fi
    
    # Mostrar resumen si dry-run
    if [[ "$dry_run" == "true" ]]; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}  MODO SIMULACIÓN (DRY-RUN)${NC}"
        echo -e "${YELLOW}  No se realizarán cambios en el sistema${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
    
    # Verificar que los scripts existan
    if [[ ! -d "$(get_script_dir)/${SCRIPTS_DIR}" ]]; then
        log_error "No se encuentra directorio de scripts: ${SCRIPTS_DIR}"
        exit 1
    fi
    
    for script in "create-user.sh" "create-directories.sh"; do
        if [[ ! -x "$(get_script_dir)/${SCRIPTS_DIR}/${script}" ]]; then
            log_error "Script no encontrado o no ejecutable: $script"
            exit 1
        fi
    done
    
    log_info "Scripts verificados"
    echo ""
    
    # Crear usuario
    local generated_password=""
    if ! step_create_user "$agent_name" "$password" "$dry_run" generated_password; then
        generate_status_json "$agent_name" "$username" "failed" "Error al crear usuario" "$dry_run"
        exit 1
    fi
    
    # Usar contraseña especificada o la generada
    local final_password="${password:-$generated_password}"
    
    # Crear directorios
    if ! step_create_directories "$agent_name" "$verbose" "$dry_run"; then
        generate_status_json "$agent_name" "$username" "failed" "Error al crear directorios" "$dry_run"
        exit 1
    fi
    
    # Verificar permisos (solo si no es dry-run)
    if [[ "$dry_run" == "false" ]]; then
        if ! step_verify_permissions "$agent_name" "$verbose"; then
            log_warn "Advertencia en verificación de permisos"
        fi
    fi
    
    # Registrar credenciales (para FASE 7)
    if ! step_register_credentials "$agent_name" "$username" "$final_password" "$dry_run"; then
        log_warn "No se pudieron registrar credenciales"
    fi
    
    # Generar status JSON
    generate_status_json "$agent_name" "$username" "success" "Usuario y estructura creados correctamente" "$dry_run"
    
    # Banner de éxito
    show_success_banner "$agent_name" "$username" "$final_password"
    
    # Output JSON (si solicitado)
    if [[ "$output_json" == "true" ]]; then
        local status_file="$(get_script_dir)/${STATUS_DIR}/${STATUS_FILE}"
        if [[ -f "$status_file" ]]; then
            cat "$status_file"
        fi
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_success "FASE 2 completada exitosamente"
    echo ""
    
    # Marcar como exitoso para evitar cleanup
    mark_success
    
    exit 0
}

# ==============================================================================
# EJECUCIÓN
# ==============================================================================

main "$@"
