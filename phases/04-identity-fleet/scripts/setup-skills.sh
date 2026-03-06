#!/bin/bash
#===============================================================================
# FASE 4: IDENTITY FLEET - Setup Skills (Super Agente)
#===============================================================================
# Propósito: Configurar habilidades del Super Agente (39 habilidades)
# Uso: ./setup-skills.sh --agent-name "nombre" [--business-type "tipo"]
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
BUSINESS_TYPE="generico"

usage() {
    echo "Uso: $0 --agent-name NOMBRE [--business-type TIPO]"
    echo ""
    echo "Tipos de negocio y sus skills:"
    echo "  restaurante  → menu, reservas, pedidos, horarios, delivery"
    echo "  hotel        → reservas, disponibilidad, habitaciones, FAQ"
    echo "  tienda       → inventario, productos, pedidos, pagos"
    echo "  servicios    → citas, calendario, reminders, seguimiento"
    echo "  generico     → FAQ, contacto, horarios"
    echo ""
    echo "Ejemplo:"
    echo "  $0 --agent-name 'casamahana' --business-type 'restaurante'"
    exit 1
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent-name)
            AGENT_NAME="$2"
            shift 2
            ;;
        --business-type)
            BUSINESS_TYPE="$2"
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
# VERIFICAR FLEET
#===============================================================================

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         FASE 4: IDENTITY FLEET - Setup Skills                 ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que existe fleet
if [[ ! -f "$CONFIG_DIR/.fleet-status.json" ]]; then
    echo -e "${RED}ERROR: Fleet no configurado. Ejecutar primero ./setup-fleet.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Fleet verificado${NC}"

#===============================================================================
# HABILIDADES CORE (25) - SIEMPRE FUNCIONAN
#===============================================================================

echo -e "${YELLOW}[1/4] Configurando habilidades CORE (25)...${NC}"

# Cargar API keys compartidas
RESEND_KEY=""
PDFCO_KEY=""
MATHPIX_KEY=""
MUX_KEY=""
TWILIO_KEY=""
OXYLABS_KEY=""
GAMMA_KEY=""

if [[ -f "$SECRETS_DIR/API_KEYS.json" ]]; then
    RESEND_KEY=$(grep -o '"resend"[^}]*"api_key"[^,]*' "$SECRETS_DIR/API_KEYS.json" 2>/dev/null | grep -o 'api_key":"[^"]*"' | cut -d'"' -f3 || true)
    PDFCO_KEY=$(grep -o '"pdfco"[^}]*"api_key"[^,]*' "$SECRETS_DIR/API_KEYS.json" 2>/dev/null | grep -o 'api_key":"[^"]*"' | cut -d'"' -f3 || true)
    MATHPIX_KEY=$(grep -o '"mathpix"[^}]*"api_key"[^,]*' "$SECRETS_DIR/API_KEYS.json" 2>/dev/null | grep -o 'api_key":"[^"]*"' | cut -d'"' -f3 || true)
    # ... más keys según sea necesario
fi

cat > "$CONFIG_DIR/skills-core.json" << 'EOF'
{
  "version": "2.0.0",
  "description": "Habilidades CORE del Super Agente - 25 habilidades que SIEMPRE funcionan",
  "skills": {
    "documentos": [
      {
        "id": "pdf_generate",
        "name": "Generar PDFs",
        "description": "Crear documentos PDF desde templates o contenido",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "pdf_read",
        "name": "Leer PDFs",
        "description": "Extraer texto de documentos PDF",
        "provider": "nosotros",
        "api": "mathpix",
        "enabled": true,
        "monthly_limit": 1000
      },
      {
        "id": "pdf_edit",
        "name": "Editar PDFs",
        "description": "Modificar, combinar o dividir PDFs",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "doc_generate",
        "name": "Generar Word/Docs",
        "description": "Crear documentos de Word o Google Docs",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "excel_generate",
        "name": "Generar Excel",
        "description": "Crear hojas de cálculo Excel",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "excel_read",
        "name": "Leer Excel",
        "description": "Extraer datos de hojas de cálculo Excel",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "presentation_create",
        "name": "Crear Presentaciones",
        "description": "Crear presentaciones PowerPoint/Google Slides",
        "provider": "nosotros",
        "api": "gamma",
        "enabled": true,
        "monthly_limit": 50
      }
    ],
    "email": [
      {
        "id": "email_send",
        "name": "Enviar Emails",
        "description": "Enviar emails con adjuntos y templates HTML",
        "provider": "nosotros",
        "api": "resend",
        "enabled": true,
        "monthly_limit": 3000
      },
      {
        "id": "email_read",
        "name": "Leer Emails",
        "description": "Leer y procesar emails recibidos",
        "provider": "nosotros",
        "api": "imap",
        "enabled": true,
        "monthly_limit": null
      }
    ],
    "video": [
      {
        "id": "video_process",
        "name": "Procesar Videos",
        "description": "Analizar y procesar videos cortos",
        "provider": "nosotros",
        "api": "mux",
        "enabled": true,
        "monthly_limit": 100
      },
      {
        "id": "video_edit",
        "name": "Editar Videos",
        "description": "Editar, recortar, comprimir videos",
        "provider": "nosotros",
        "api": "mux",
        "enabled": true,
        "monthly_limit": 100
      }
    ],
    "automatizacion": [
      {
        "id": "browser",
        "name": "Navegador Automatizado",
        "description": "Automatizar tareas en el navegador",
        "provider": "nosotros",
        "api": "puppeteer",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "scraping",
        "name": "Web Scraping",
        "description": "Extraer datos de páginas web",
        "provider": "nosotros",
        "api": "oxylabs",
        "enabled": true,
        "monthly_limit": 1000
      },
      {
        "id": "forms",
        "name": "Formularios",
        "description": "Crear y procesar formularios",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "cron",
        "name": "Tareas Programadas",
        "description": "Programar tareas recurrentes",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "webhook",
        "name": "Webhooks",
        "description": "Recibir y enviar webhooks",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      }
    ],
    "comunicacion": [
      {
        "id": "sms_send",
        "name": "Enviar SMS",
        "description": "Enviar mensajes SMS",
        "provider": "nosotros",
        "api": "twilio",
        "enabled": true,
        "monthly_limit": 500
      },
      {
        "id": "whatsapp_send",
        "name": "Enviar WhatsApp",
        "description": "Enviar mensajes por WhatsApp",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "telegram_send",
        "name": "Enviar Telegram",
        "description": "Enviar mensajes por Telegram",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "discord_send",
        "name": "Enviar Discord",
        "description": "Enviar mensajes por Discord",
        "provider": "sistema",
        "api": "openclaw",
        "enabled": true,
        "monthly_limit": null
      }
    ],
    "negocio": [
      {
        "id": "invoice_generate",
        "name": "Generar Facturas",
        "description": "Crear facturas en PDF",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "report_generate",
        "name": "Generar Reportes",
        "description": "Crear reportes y dashboards",
        "provider": "nosotros",
        "api": "pdfco",
        "enabled": true,
        "monthly_limit": 5000
      },
      {
        "id": "qrcode_generate",
        "name": "Generar QR Codes",
        "description": "Crear códigos QR",
        "provider": "nosotros",
        "api": "externa",
        "enabled": true,
        "monthly_limit": null
      }
    ],
    "productividad": [
      {
        "id": "summarize",
        "name": "Resumir Textos",
        "description": "Crear resúmenes de textos largos",
        "provider": "cliente",
        "api": "ollama",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "extract_data",
        "name": "Extraer Datos",
        "description": "Extraer datos estructurados de textos",
        "provider": "cliente",
        "api": "ollama",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "sentiment",
        "name": "Análisis de Sentimiento",
        "description": "Analizar el sentimiento de textos",
        "provider": "cliente",
        "api": "ollama",
        "enabled": true,
        "monthly_limit": null
      },
      {
        "id": "ocr",
        "name": "OCR de Imágenes",
        "description": "Extraer texto de imágenes",
        "provider": "cliente",
        "api": "ollama-vision",
        "enabled": true,
        "monthly_limit": null
      }
    ]
  },
  "total_core": 25,
  "apis_compartidas": {
    "resend": { "limite": 3000, "costo": "$10/mes" },
    "pdfco": { "limite": 5000, "costo": "$15/mes" },
    "mathpix": { "limite": 1000, "costo": "$10/mes" },
    "mux": { "limite": 100, "costo": "$20/mes" },
    "twilio": { "limite": 500, "costo": "$10/mes" },
    "oxylabs": { "limite": 1000, "costo": "$30/mes" },
    "gamma": { "limite": 50, "costo": "$10/mes" },
    "total": { "costo": "$105/mes" }
  }
}
EOF

echo -e "${GREEN}   ✓ 25 habilidades CORE configuradas${NC}"

#===============================================================================
# HABILIDADES OPCIONALES (14) - REQUIEREN API KEY
#===============================================================================

echo -e "${YELLOW}[2/4] Configurando habilidades OPCIONALES (14)...${NC}"

cat > "$CONFIG_DIR/skills-optional.json" << 'EOF'
{
  "version": "2.0.0",
  "description": "Habilidades OPCIONALES - Requieren API key del cliente",
  "skills": [
    {
      "id": "voice_receive",
      "name": "Recibir Voz",
      "description": "Transcribir mensajes de voz",
      "required_key": "OPENAI_API_KEY",
      "enabled": false
    },
    {
      "id": "voice_send",
      "name": "Enviar Voz",
      "description": "Generar mensajes de voz (TTS)",
      "required_key": "OPENAI_API_KEY",
      "enabled": false
    },
    {
      "id": "audio_transcribe",
      "name": "Transcribir Audio",
      "description": "Transcribir archivos de audio",
      "required_key": "OPENAI_API_KEY",
      "enabled": false
    },
    {
      "id": "image_generate",
      "name": "Generar Imágenes",
      "description": "Crear imágenes con AI (DALL-E)",
      "required_key": "OPENAI_API_KEY",
      "enabled": false
    },
    {
      "id": "image_edit",
      "name": "Editar Imágenes",
      "description": "Editar imágenes con AI",
      "required_key": "OPENAI_API_KEY",
      "enabled": false
    },
    {
      "id": "audio_generate",
      "name": "Generar Música",
      "description": "Crear música con AI",
      "required_key": "SUNO_API_KEY",
      "enabled": false
    },
    {
      "id": "video_create",
      "name": "Crear Videos",
      "description": "Crear videos con AI",
      "required_key": "RUNWAY_API_KEY",
      "enabled": false
    },
    {
      "id": "translate",
      "name": "Traducción",
      "description": "Traducir textos a otros idiomas",
      "required_key": "DEEPL_API_KEY",
      "enabled": false
    },
    {
      "id": "location",
      "name": "Ubicación/Maps",
      "description": "Búsquedas de ubicación y mapas",
      "required_key": "GOOGLE_MAPS_KEY",
      "enabled": false
    },
    {
      "id": "calendar",
      "name": "Google Calendar",
      "description": "Gestionar calendario de Google",
      "required_key": "GOOGLE_OAUTH",
      "enabled": false
    },
    {
      "id": "sheets",
      "name": "Google Sheets",
      "description": "Gestionar hojas de cálculo de Google",
      "required_key": "GOOGLE_OAUTH",
      "enabled": false
    },
    {
      "id": "deep_search",
      "name": "Búsqueda Profunda",
      "description": "Búsquedas web avanzadas",
      "required_key": "PERPLEXITY_API_KEY",
      "enabled": false
    },
    {
      "id": "code_execute",
      "name": "Ejecutar Código",
      "description": "Ejecutar código en sandbox",
      "required_key": "NONE",
      "enabled": true
    },
    {
      "id": "image_receive",
      "name": "Analizar Imágenes",
      "description": "Analizar y describir imágenes",
      "required_key": "OLLAMA_API_KEY",
      "enabled": true
    }
  ],
  "total_optional": 14
}
EOF

echo -e "${GREEN}   ✓ 14 habilidades OPCIONALES configuradas${NC}"

#===============================================================================
# SKILLS BUNDLE POR TIPO DE NEGOCIO
#===============================================================================

echo -e "${YELLOW}[3/4] Configurando Skills Bundle para: ${BUSINESS_TYPE}...${NC}"

case "$BUSINESS_TYPE" in
    restaurante)
        BUNDLE='{
  "bundle": "restaurante",
  "skills": [
    "menu_parse",
    "reservations",
    "orders",
    "hours",
    "delivery",
    "faq",
    "contact"
  ],
  "custom_prompts": {
    "menu_parse": "Puedo leer el menú y responder preguntas sobre platos, precios y recomendaciones.",
    "reservations": "Puedo gestionar reservaciones para el restaurante.",
    "orders": "Puedo tomar pedidos y enviarlos a cocina.",
    "delivery": "Puedo gestionar órdenes de delivery."
  }
}'
        ;;
    hotel)
        BUNDLE='{
  "bundle": "hotel",
  "skills": [
    "reservations",
    "availability",
    "rooms",
    "faq",
    "contact",
    "hours"
  ],
  "custom_prompts": {
    "reservations": "Puedo gestionar reservaciones de habitaciones.",
    "availability": "Puedo consultar disponibilidad en tiempo real.",
    "rooms": "Puedo describir habitaciones y servicios del hotel."
  }
}'
        ;;
    tienda)
        BUNDLE='{
  "bundle": "tienda",
  "skills": [
    "inventory",
    "products",
    "orders",
    "payments",
    "faq",
    "contact"
  ],
  "custom_prompts": {
    "inventory": "Puedo consultar el inventario de productos.",
    "products": "Puedo buscar y recomendar productos.",
    "orders": "Puedo gestionar pedidos y su seguimiento."
  }
}'
        ;;
    servicios)
        BUNDLE='{
  "bundle": "servicios",
  "skills": [
    "appointments",
    "calendar",
    "reminders",
    "followup",
    "faq",
    "contact"
  ],
  "custom_prompts": {
    "appointments": "Puedo gestionar citas y agendarlas.",
    "calendar": "Puedo consultar y modificar el calendario.",
    "reminders": "Puedo enviar recordatorios de citas."
  }
}'
        ;;
    *)
        BUNDLE='{
  "bundle": "generico",
  "skills": [
    "faq",
    "contact",
    "hours",
    "location",
    "general"
  ],
  "custom_prompts": {
    "faq": "Puedo responder preguntas frecuentes.",
    "contact": "Puedo proporcionar información de contacto.",
    "hours": "Puedo informar sobre horarios de atención."
  }
}'
        ;;
esac

echo "$BUNDLE" > "$CONFIG_DIR/skills-bundle.json"

echo -e "${GREEN}   ✓ Skills Bundle configurado${NC}"

#===============================================================================
# SKILLS.MD FINAL
#===============================================================================

echo -e "${YELLOW}[4/4] Generando SKILLS.md...${NC}"

cat > "$CONFIG_DIR/SKILLS.md" << 'SKILLSEOF'
# SKILLS - Habilidades del Super Agente

**Agente:** AGENT_NAME_PLACEHOLDER
**Tipo de negocio:** BUSINESS_TYPE_PLACEHOLDER
**Total habilidades:** 39 (25 CORE + 14 OPCIONALES)
**Actualizado:** DATE_PLACEHOLDER

---

## Habilidades CORE (25) - Siempre funcionan

Estas habilidades están disponibles SIEMPRE, sin configuración adicional del cliente.

### Documentos (7)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| pdf_generate | Crear documentos PDF | 5,000 |
| pdf_read | Extraer texto de PDFs | 1,000 |
| pdf_edit | Modificar/combinar PDFs | 5,000 |
| doc_generate | Crear Word/Docs | 5,000 |
| excel_generate | Crear Excel | 5,000 |
| excel_read | Leer Excel | 5,000 |
| presentation_create | Crear presentaciones | 50 |

### Email (2)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| email_send | Enviar emails con adjuntos | 3,000 |
| email_read | Leer y procesar emails | Ilimitado |

### Video (2)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| video_process | Analizar videos | 100 |
| video_edit | Editar videos | 100 |

### Automatización (5)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| browser | Navegador automatizado | Ilimitado |
| scraping | Web scraping | 1,000 |
| forms | Formularios | Ilimitado |
| cron | Tareas programadas | Ilimitado |
| webhook | Webhooks | Ilimitado |

### Comunicación (4)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| sms_send | Enviar SMS | 500 |
| whatsapp_send | Enviar WhatsApp | Ilimitado |
| telegram_send | Enviar Telegram | Ilimitado |
| discord_send | Enviar Discord | Ilimitado |

### Negocio (3)

| Habilidad | Descripción | Límite/mes |
|-----------|-------------|------------|
| invoice_generate | Crear facturas | 5,000 |
| report_generate | Crear reportes | 5,000 |
| qrcode_generate | Crear QR codes | Ilimitado |

### Productividad (4)

| Habilidad | Descripción | Proveedor |
|-----------|-------------|-----------|
| summarize | Resumir textos | Cliente (Ollama) |
| extract_data | Extraer datos | Cliente (Ollama) |
| sentiment | Análisis de sentimiento | Cliente (Ollama) |
| ocr | OCR de imágenes | Cliente (Ollama Vision) |

---

## Habilidades OPCIONALES (14) - Requieren API key

| Habilidad | API necesaria | Estado |
|-----------|--------------|--------|
| voice_receive | OPENAI_API_KEY | ⏳ Pendiente |
| voice_send | OPENAI_API_KEY | ⏳ Pendiente |
| audio_transcribe | OPENAI_API_KEY | ⏳ Pendiente |
| image_generate | OPENAI_API_KEY | ⏳ Pendiente |
| image_edit | OPENAI_API_KEY | ⏳ Pendiente |
| audio_generate | SUNO_API_KEY | ⏳ Pendiente |
| video_create | RUNWAY_API_KEY | ⏳ Pendiente |
| translate | DEEPL_API_KEY | ⏳ Pendiente |
| location | GOOGLE_MAPS_KEY | ⏳ Pendiente |
| calendar | GOOGLE_OAUTH | ⏳ Pendiente |
| sheets | GOOGLE_OAUTH | ⏳ Pendiente |
| deep_search | PERPLEXITY_API_KEY | ⏳ Pendiente |
| code_execute | (ninguna) | ✅ Habilitado |
| image_receive | OLLAMA_API_KEY | ✅ Habilitado |

---

## Costo de APIs compartidas: ~$105/mes

| API | Límite | Costo |
|-----|--------|-------|
| Resend | 3,000 emails | $10 |
| PDF.co | 5,000 páginas | $15 |
| Mathpix | 1,000 páginas | $10 |
| Mux | 100 videos | $20 |
| Twilio | 500 SMS | $10 |
| Oxylabs | 1,000 requests | $30 |
| Gamma | 50 presentaciones | $10 |

---

## Skills Bundle por Negocio

BUNDLE_PLACEHOLDER

---

*Habilidades configuradas automáticamente en FASE 4.*
SKILLSEOF

# Reemplazar placeholders
sed -i "s|AGENT_NAME_PLACEHOLDER|${AGENT_NAME}|g" "$CONFIG_DIR/SKILLS.md"
sed -i "s|BUSINESS_TYPE_PLACEHOLDER|${BUSINESS_TYPE}|g" "$CONFIG_DIR/SKILLS.md"
sed -i "s|DATE_PLACEHOLDER|$(date -Iseconds)|g" "$CONFIG_DIR/SKILLS.md"
sed -i "s|BUNDLE_PLACEHOLDER|${BUNDLE}|g" "$CONFIG_DIR/SKILLS.md"

echo -e "${GREEN}   ✓ SKILLS.md generado${NC}"

#===============================================================================
# RESUMEN
#===============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              SKILLS SETUP COMPLETADO                          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Habilidades CORE:${NC} 25 (siempre funcionan)"
echo -e "${BLUE}Habilidades OPCIONALES:${NC} 14 (requieren API key)"
echo -e "${BLUE}Skills Bundle:${NC} ${BUSINESS_TYPE}"
echo -e "${BLUE}Total habilidades:${NC} 39"
echo ""
echo -e "${BLUE}Archivos creados:${NC}"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/skills-core.json"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/skills-optional.json"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/skills-bundle.json"
echo -e "   ${GREEN}✓${NC} $CONFIG_DIR/SKILLS.md"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} ./process-knowledge.sh --agent-name '${AGENT_NAME}'"
echo ""

# Guardar estado
cat > "$CONFIG_DIR/.skills-status.json" << EOF
{
  "status": "completed",
  "agent_name": "${AGENT_NAME}",
  "business_type": "${BUSINESS_TYPE}",
  "total_core": 25,
  "total_optional": 14,
  "total_skills": 39,
  "created_at": "$(date -Iseconds)"
}
EOF

exit 0