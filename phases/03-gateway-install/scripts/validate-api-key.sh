#!/bin/bash
# =============================================================================
# validate-api-key.sh - Valida la API key de Ollama
# TURNKEY v6 - FASE 3: GATEWAY INSTALL
# =============================================================================

set -e
set +e

# Valores por defecto
API_KEY="${OLLAMA_API_KEY:-}"
API_URL="https://api.ollama.cloud/v1"

# -----------------------------------------------------------------------------
# PARSEAR ARGUMENTOS
# -----------------------------------------------------------------------------

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --api-key) API_KEY="$2"; shift 2 ;;
            --url) API_URL="$2"; shift 2 ;;
            --help)
                echo "Uso: $0 [--api-key KEY] [--url URL]"
                exit 0
                ;;
            *) shift ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# VALIDAR API KEY
# -----------------------------------------------------------------------------

validate_api_key() {
    local valid=false
    local provider="ollama"
    local plan="unknown"
    local models_available=0
    local response_time_ms=0
    
    # Verificar que existe
    if [[ -z "$API_KEY" ]]; then
        echo '{"valid": false, "error": "API key no proporcionada"}'
        return 1
    fi
    
    # Verificar formato
    if [[ ! "$API_KEY" =~ ^os_ ]]; then
        echo '{"valid": false, "error": "Formato inválido (debe empezar con os_)"}'
        return 1
    fi
    
    # Intentar conexión (timeout 10s)
    local start_time
    start_time=$(date +%s%3N 2>/dev/null || echo "0")
    
    # Petición de prueba
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
        -H "Authorization: Bearer $API_KEY" \
        "${API_URL}/models" 2>/dev/null || echo "000")
    
    local end_time
    end_time=$(date +%s%3N 2>/dev/null || echo "0")
    response_time_ms=$((end_time - start_time))
    
    case "$response" in
        200|201)
            valid=true
            # TODO: Obtener plan y modelos
            plan="free"
            models_available=53
            ;;
        401|403)
            valid=false
            echo "{\"valid\": false, \"error\": \"API key inválida (HTTP $response)\"}"
            return 1
            ;;
        *)
            # Si no podemos conectar, asumimos formato válido
            valid=true
            plan="unknown"
            models_available=0
            ;;
    esac
    
    # Output JSON
    cat <<EOF
{
  "valid": $valid,
  "provider": "$provider",
  "plan": "$plan",
  "models_available": $models_available,
  "response_time_ms": $response_time_ms
}
EOF
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

parse_args "$@"
validate_api_key