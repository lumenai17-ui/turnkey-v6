#!/bin/bash
# =============================================================================
# detect-gateway.sh - Detecta si OpenClaw Gateway ya está instalado
# TURNKEY v6 - FASE 3: GATEWAY INSTALL
# =============================================================================

set -e
set +e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# DETECTAR GATEWAY
# -----------------------------------------------------------------------------

detect_gateway() {
    local installed=false
    local version=""
    local path=""
    local running=false
    local port=""
    local pid=""
    
    # Verificar si existe en PATH
    if command -v openclaw-gateway &>/dev/null; then
        installed=true
        path=$(which openclaw-gateway 2>/dev/null)
        
        # Obtener versión
        version=$(openclaw-gateway --version 2>/dev/null | head -1 || echo "unknown")
        
        # Verificar si está corriendo
        if pgrep -f "openclaw-gateway" &>/dev/null; then
            running=true
            pid=$(pgrep -f "openclaw-gateway" | head -1)
            
            # Intentar obtener puerto
            port=$(ss -tuln 2>/dev/null | grep -E ":(18789|18790|18791|18792|18793)" | head -1 | awk '{print $4}' | cut -d: -f2 || echo "")
        fi
    fi
    
    # Output JSON
    cat <<EOF
{
  "installed": $installed,
  "version": "$version",
  "path": "$path",
  "running": $running,
  "port": "$port",
  "pid": "$pid"
}
EOF
}

# -----------------------------------------------------------------------------
# MAIN
# -----------------------------------------------------------------------------

detect_gateway