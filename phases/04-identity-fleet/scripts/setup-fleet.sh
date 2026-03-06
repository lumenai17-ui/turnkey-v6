#!/bin/bash
#===============================================================================
# FASE 4: IDENTITY FLEET - Setup Fleet
#===============================================================================
# Propósito: Configurar fleet de modelos (13 modelos, igual que LOCAL)
# Uso: ./setup-fleet.sh --agent-name "nombre" [--ollama-key "key"]
#===============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración
OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_DIR="$OPENCLAW_DIR/config"
SECRETS_DIR="$OPENCLAW_DIR/workspace/secrets"

#===============================================================================
# PARÁMETROS
#===============================================================================

AGENT_NAME=""
OLLAMA_KEY=""

usage() {
    echo "Uso: $0 --agent-name NOMBRE [--ollama-key KEY]"
    echo ""
    echo "Parámetros:"
    echo "  --agent-name    Nombre del agente (obligatorio)"
    echo "  --ollama-key    API key de Ollama Cloud (obligatorio si no está en config)"
    echo ""
    echo "Ejemplo:"
    echo "  $0 --agent-name 'casamahana' --ollama-key 'sk-xxx'"
    exit 1
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent-name)
            AGENT_NAME="$2"
            shift 2
            ;;
        --ollama-key)
            OLLAMA_KEY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Parámetro desconocido: $1${NC}"
            usage
            ;;
    esac
done

# Validar parámetros
if [[ -z "$AGENT_NAME" ]]; then
    echo -e "${RED}ERROR: --agent-name es obligatorio${NC}"
    usage
fi

#===============================================================================
# VERIFICAR IDENTITY
#===============================================================================

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         FASE 4: IDENTITY FLEET - Setup Fleet                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que existe identity
if [[ ! -f "$CONFIG_DIR/.identity-status.json" ]]; then
    echo -e "${RED}ERROR: Identity no configurado. Ejecutar primero ./setup-identity.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Identity verificado${NC}"

#===============================================================================
# API KEY OLLAMA
#===============================================================================

echo -e "${YELLOW}[1/4] Verificando API key de Ollama...${NC}"

# Buscar API key en varios lugares
if [[ -z "$OLLAMA_KEY" ]]; then
    # Buscar en secrets
    if [[ -f "$SECRETS_DIR/API_KEYS.json" ]]; then
        OLLAMA_KEY=$(grep -o '"ollamacloud"[^}]*"apiKey"[^,]*' "$SECRETS_DIR/API_KEYS.json" 2>/dev/null | grep -o 'apiKey":"[^"]*"' | cut -d'"' -f3 || true)
    fi
    
    # Buscar en config de openclaw
    if [[ -z "$OLLAMA_KEY" ]] && [[ -f "$CONFIG_DIR/openclaw.json" ]]; then
        OLLAMA_KEY=$(grep -o '"apiKey"[^,]*' "$CONFIG_DIR/openclaw.json" 2>/dev/null | head -1 | cut -d'"' -f3 || true)
    fi
    
    # Buscar en archivo .ollama-key
    if [[ -z "$OLLAMA_KEY" ]] && [[ -f "$CONFIG_DIR/.ollama-key" ]]; then
        OLLAMA_KEY=$(cat "$CONFIG_DIR/.ollama-key")
    fi
fi

if [[ -z "$OLLAMA_KEY" ]]; then
    echo -e "${RED}ERROR: No se encontró API key de Ollama Cloud${NC}"
    echo -e "${YELLOW}Opciones:${NC}"
    echo "  1. Proporcionar con --ollama-key"
    echo "  2. Crear archivo $CONFIG_DIR/.ollama-key con la key"
    echo "  3. Configurar en $SECRETS_DIR/API_KEYS.json"
    exit 1
fi

echo -e "${GREEN}   ✓ API key de Ollama encontrada${NC}"

#===============================================================================
# CONFIGURAR FLEET.JSON
#===============================================================================

echo -e "${YELLOW}[2/4] Configurando Fleet de modelos...${NC}"

# Fleet de 13 modelos (igual que LOCAL)
cat > "$CONFIG_DIR/fleet.json" << 'EOF'
{
  "version": "2.0.0",
  "description": "Fleet de modelos LUMEN v2 - 13 modelos",
  "providers": {
    "ollamacloud": {
      "baseUrl": "https://ollama.com/v1",
      "apiKey": "OLLAMA_API_KEY_PLACEHOLDER",
      "api": "openai-completions"
    }
  },
  "models": [
    {
      "id": "glm-5",
      "name": "GLM-5",
      "provider": "ollamacloud",
      "role": "primary",
      "reasoning": true,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Modelo principal - rápido, general, con razonamiento"
    },
    {
      "id": "kimi-k2.5",
      "name": "Kimi K2.5",
      "provider": "ollamacloud",
      "role": "fallback",
      "reasoning": false,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Alternativo - más capacidad de contexto"
    },
    {
      "id": "kimi-k2-thinking",
      "name": "Kimi K2 Thinking",
      "provider": "ollamacloud",
      "role": "thinking",
      "reasoning": true,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Thinking - para razonamiento profundo"
    },
    {
      "id": "deepseek-v3.1:671b",
      "name": "DeepSeek V3.1 671B",
      "provider": "ollamacloud",
      "role": "thinking",
      "reasoning": true,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Thinking - modelo de razonamiento más potente"
    },
    {
      "id": "deepseek-v3.2",
      "name": "DeepSeek V3.2",
      "provider": "ollamacloud",
      "role": "fallback",
      "reasoning": true,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Alternativo - nueva versión de DeepSeek"
    },
    {
      "id": "qwen3-coder-next",
      "name": "Qwen3 Coder Next",
      "provider": "ollamacloud",
      "role": "coding",
      "reasoning": false,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Coding - especializado en código"
    },
    {
      "id": "qwen3.5:397b",
      "name": "Qwen3.5 397B",
      "provider": "ollamacloud",
      "role": "fallback",
      "reasoning": false,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Alternativo - modelo grande y capaz"
    },
    {
      "id": "qwen3-vl:235b",
      "name": "Qwen3-VL 235B",
      "provider": "ollamacloud",
      "role": "vision",
      "reasoning": false,
      "input": ["text", "image"],
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Vision - para análisis de imágenes"
    },
    {
      "id": "minimax-m2.5",
      "name": "MiniMax M2.5",
      "provider": "ollamacloud",
      "role": "fallback",
      "reasoning": false,
      "contextWindow": 131072,
      "maxTokens": 16384,
      "description": "Alternativo - modelo multilingüe"
    },
    {
      "id": "gemma3:27b",
      "name": "Gemma3 27B",
      "provider": "ollamacloud",
      "role": "light",
      "reasoning": false,
      "contextWindow": 8192,
      "maxTokens": 4096,
      "description": "Light - modelo ligero para tareas simples"
    },
    {
      "id": "gemma3:12b",
      "name": "Gemma3 12B",
      "provider": "ollamacloud",
      "role": "light",
      "reasoning": false,
      "contextWindow": 8192,
      "maxTokens": 4096,
      "description": "Light - modelo muy ligero"
    },
    {
      "id": "fingpt",
      "name": "FinGPT",
      "provider": "ollamacloud",
      "role": "specialized",
      "reasoning": false,
      "contextWindow": 8192,
      "maxTokens": 4096,
      "description": "Specialized - finanzas y análisis financiero"
    },
    {
      "id": "medical",
      "name": "Medical",
      "provider": "ollamacloud",
      "role": "specialized",
      "reasoning": false,
      "contextWindow": 8192,
      "maxTokens": 4096,
      "description": "Specialized - medicina y salud"
    }
  ],
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollamacloud/glm-5",
        "fallbacks": [
          "ollamacloud/kimi-k2.5",
          "ollamacloud/qwen3.5:397b"
        ]
      },
      "workspace": "~/.openclaw/workspace",
      "compaction": {
        "mode": "safeguard"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    },
    "list": [
      {
        "id": "main",
        "model": {
          "primary": "ollamacloud/glm-5"
        },
        "subagents": {
          "allowAgents": ["main", "thinking", "vision", "coding"]
        }
      },
      {
        "id": "thinking",
        "model": {
          "primary": "ollamacloud/deepseek-v3.1:671b"
        }
      },
      {
        "id": "vision",
        "model": {
          "primary": "ollamacloud/qwen3-vl:235b"
        }
      },
      {
        "id": "coding",
        "model": {
          "primary": "ollamacloud/qwen3-coder-next"
        }
      }
    ]
  }
}
EOF

# Reemplazar placeholder con la key real
sed -i "s|OLLAMA_API_KEY_PLACEHOLDER|${OLLAMA_KEY}|g" "$CONFIG_DIR/fleet.json"

echo -e "${GREEN}   ✓ Fleet configurado con 13 modelos${NC}"

#===============================================================================
# CONFIGURAR OPENCLAW.JSON
#===============================================================================

echo -e "${YELLOW}[3/4] Configurando openclaw.json...${NC}"

# Crear o actualizar openclaw.json
if [[ -f "$CONFIG_DIR/openclaw.json" ]]; then
    # Backup del existente
    cp "$CONFIG_DIR/openclaw.json" "$CONFIG_DIR/openclaw.json.bak"
    echo -e "${BLUE}   Backup creado: openclaw.json.bak${NC}"
fi

cat > "$CONFIG_DIR/openclaw.json" << EOF
{
  "meta": {
    "agentName": "${AGENT_NAME}",
    "createdAt": "$(date -Iseconds)",
    "version": "2026.3.5"
  },
  "models": {
    "providers": {
      "ollamacloud": {
        "baseUrl": "https://ollama.com/v1",
        "apiKey": "${OLLAMA_KEY}",
        "api": "openai-completions",
        "models": [
          {
            "id": "glm-5",
            "name": "GLM-5",
            "reasoning": true,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 16384
          },
          {
            "id": "kimi-k2.5",
            "name": "Kimi K2.5",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 16384
          },
          {
            "id": "deepseek-v3.1:671b",
            "name": "DeepSeek V3.1 671B",
            "reasoning": true,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 16384
          },
          {
            "id": "qwen3-vl:235b",
            "name": "Qwen3-VL 235B",
            "reasoning": false,
            "input": ["text", "image"],
            "contextWindow": 131072,
            "maxTokens": 16384
          },
          {
            "id": "qwen3-coder-next",
            "name": "Qwen3 Coder Next",
            "reasoning": false,
            "input": ["text"],
            "contextWindow": 131072,
            "maxTokens": 16384
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollamacloud/glm-5",
        "fallbacks": [
          "ollamacloud/kimi-k2.5",
          "ollamacloud/qwen3.5:397b"
        ]
      },
      "workspace": "~/.openclaw/workspace",
      "compaction": {
        "mode": "safeguard"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    },
    "list": [
      {
        "id": "main",
        "model": {
          "primary": "ollamacloud/glm-5"
        },
        "subagents": {
          "allowAgents": ["main", "thinking", "vision", "coding"]
        }
      },
      {
        "id": "thinking",
        "model": {
          "primary": "ollamacloud/deepseek-v3.1:671b"
        }
      },
      {
        "id": "vision",
        "model": {
          "primary": "ollamacloud/qwen3-vl:235b"
        }
      },
      {
        "id": "coding",
        "model": {
          "primary": "ollamacloud/qwen3-coder-next"
        }
      }
    ]
  },
  "memory": {
    "enabled": true,
    "embeddings": {
      "enabled": true,
      "provider": "ollamacloud",
      "model": "nomic-embed-text"
    }
  },
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "boot-md": {
          "enabled": true
        },
        "session-memory": {
          "enabled": true
        }
      }
    }
  }
}
EOF

echo -e "${GREEN}   ✓ openclaw.json configurado${NC}"

#===============================================================================
# CONFIGURAR EMBEDDINGS
#===============================================================================

echo -e "${YELLOW}[4/4] Configurando embeddings...${NC}"

mkdir -p "$DATA_DIR/embeddings"

cat > "$CONFIG_DIR/embeddings.json" << EOF
{
  "enabled": true,
  "provider": "ollamacloud",
  "model": "nomic-embed-text",
  "chunkSize": 512,
  "overlap": 50,
  "indexDir": "$DATA_DIR/embeddings"
}
EOF

echo -e "${GREEN}   ✓ Embeddings configurados${NC}"

#===============================================================================
# RESUMEN
#===============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              FLEET SETUP COMPLETADO                           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Modelos configurados:${NC}"
echo -e "   ${GREEN}✓${NC} Primary: glm-5"
echo -e "   ${GREEN}✓${NC} Thinking: deepseek-v3.1:671b"
echo -e "   ${GREEN}✓${NC} Vision: qwen3-vl:235b"
echo -e "   ${GREEN}✓${NC} Coding: qwen3-coder-next"
echo -e "   ${GREEN}✓${NC} + 9 modelos de fallback/especializados"
echo ""
echo -e "${BLUE}Total modelos en fleet:${NC} 13"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/fleet.json"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/openclaw.json"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/embeddings.json"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} ./setup-skills.sh --agent-name '${AGENT_NAME}'"
echo ""

# Guardar estado
cat > "$CONFIG_DIR/.fleet-status.json" << EOF
{
  "status": "completed",
  "agent_name": "${AGENT_NAME}",
  "total_models": 13,
  "primary_model": "glm-5",
  "thinking_model": "deepseek-v3.1:671b",
  "vision_model": "qwen3-vl:235b",
  "coding_model": "qwen3-coder-next",
  "embeddings_enabled": true,
  "created_at": "$(date -Iseconds)"
}
EOF

exit 0