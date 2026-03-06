#!/bin/bash
#===============================================================================
# FASE 4: IDENTITY FLEET - Process Knowledge
#===============================================================================
# Propósito: Procesar archivos de conocimiento (PDFs, Excel, Docs, Imágenes, URLs)
# Uso: ./process-knowledge.sh --agent-name "nombre"
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
DATA_DIR="$OPENCLAW_DIR/data"
KNOWLEDGE_DIR="$OPENCLAW_DIR/knowledge"
PENDING_FILE="$CONFIG_DIR/pending-knowledge.json"
TEMP_DIR="$OPENCLAW_DIR/workspace/temp-upload"

#===============================================================================
# PARÁMETROS
#===============================================================================

AGENT_NAME=""
VERBOSE=false

usage() {
    echo "Uso: $0 --agent-name NOMBRE [--verbose]"
    echo ""
    echo "Opciones:"
    echo "  --agent-name    Nombre del agente"
    echo "  --verbose       Mostrar más detalles"
    echo ""
    echo "Este script procesa archivos de pending-knowledge.json"
    echo "creado en FASE 1."
    exit 1
}

# Parsear argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent-name)
            AGENT_NAME="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
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
# VERIFICAR SKILLS
#===============================================================================

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         FASE 4: IDENTITY FLEET - Process Knowledge            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que existe skills
if [[ ! -f "$CONFIG_DIR/.skills-status.json" ]]; then
    echo -e "${RED}ERROR: Skills no configurados. Ejecutar primero ./setup-skills.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Skills verificados${NC}"

#===============================================================================
# VERIFICAR ARCHIVOS PENDIENTES
#===============================================================================

echo -e "${YELLOW}[1/6] Verificando archivos de conocimiento...${NC}"

# Crear directorios
mkdir -p "$KNOWLEDGE_DIR"/{pdf,excel,docs,images,urls,processed,embeddings}
mkdir -p "$TEMP_DIR"

if [[ ! -f "$PENDING_FILE" ]]; then
    echo -e "${YELLOW}   ⚠ No hay archivos pendientes de procesamiento${NC}"
    echo -e "${BLUE}   El archivo pending-knowledge.json se creará en FASE 1${NC}"
    echo ""
    echo -e "${GREEN}✓ Estructura de directorios creada${NC}"
    
    # Crear archivo vacío
    cat > "$PENDING_FILE" << 'EOF'
{
  "upload_date": null,
  "agent_name": null,
  "files": [],
  "urls": []
}
EOF
    
    # Guardar estado
    cat > "$CONFIG_DIR/.knowledge-status.json" << EOF
{
  "status": "skipped",
  "reason": "no_pending_files",
  "agent_name": "${AGENT_NAME}",
  "created_at": "$(date -Iseconds)"
}
EOF
    
    echo ""
    echo -e "${YELLOW}Continuando sin archivos de conocimiento...${NC}"
    echo -e "${YELLOW}Siguiente paso:${NC} ./setup-email.sh --agent-name '${AGENT_NAME}'"
    exit 0
fi

# Contar archivos pendientes
PENDING_FILES=$(grep -c '"status": "pending"' "$PENDING_FILE" 2>/dev/null || echo "0")
PENDING_URLS=$(grep -c '"status": "pending"' "$PENDING_FILE" | tail -1 || echo "0")

echo -e "${GREEN}   ✓ Archivos pendientes: ${PENDING_FILES}${NC}"
echo -e "${GREEN}   ✓ URLs pendientes: ${PENDING_URLS}${NC}"

#===============================================================================
# PROCESAR ARCHIVOS
#===============================================================================

echo -e "${YELLOW}[2/6] Procesando archivos PDF...${NC}"

# Procesar PDFs
process_pdf() {
    local input_file="$1"
    local output_file="$2"
    
    if command -v pdftotext &> /dev/null; then
        pdftotext "$input_file" "$output_file" 2>/dev/null
        return $?
    else
        echo -e "${YELLOW}   ⚠ pdftotext no instalado, instalando...${NC}"
        sudo apt-get install -y poppler-utils > /dev/null 2>&1
        pdftotext "$input_file" "$output_file" 2>/dev/null
        return $?
    fi
}

# Buscar y procesar PDFs pendientes
if [[ -d "$TEMP_DIR" ]]; then
    for pdf_file in "$TEMP_DIR"/*.pdf 2>/dev/null; do
        if [[ -f "$pdf_file" ]]; then
            filename=$(basename "$pdf_file" .pdf)
            output="$KNOWLEDGE_DIR/pdf/${filename}.txt"
            
            if process_pdf "$pdf_file" "$output"; then
                echo -e "${GREEN}   ✓ Procesado: ${filename}.pdf${NC}"
            else
                echo -e "${RED}   ✗ Error procesando: ${filename}.pdf${NC}"
            fi
        fi
    done
fi

echo -e "${YELLOW}[3/6] Procesando archivos Excel...${NC}"

# Procesar Excel (requiere Python + openpyxl)
process_excel() {
    local input_file="$1"
    local output_file="$2"
    
    python3 << 'PYEOF' 2>/dev/null
import sys
import json
try:
    import openpyxl
    wb = openpyxl.load_workbook(sys.argv[1])
    data = []
    for sheet in wb.worksheets:
        for row in sheet.iter_rows(values_only=True):
            if any(cell is not None for cell in row):
                data.append(list(row))
    with open(sys.argv[2], 'w') as f:
        json.dump(data, f, indent=2)
    print("OK")
except Exception as e:
    print(f"ERROR: {e}")
PYEOF
}

for xlsx_file in "$TEMP_DIR"/*.xlsx "$TEMP_DIR"/*.xls 2>/dev/null; do
    if [[ -f "$xlsx_file" ]]; then
        filename=$(basename "$xlsx_file" .xlsx | sed 's/.xls$//')
        output="$KNOWLEDGE_DIR/excel/${filename}.json"
        
        if python3 -c "import openpyxl" 2>/dev/null; then
            python3 -c "
import openpyxl, json, sys
wb = openpyxl.load_workbook('$xlsx_file')
data = []
for sheet in wb.worksheets:
    for row in sheet.iter_rows(values_only=True):
        if any(cell is not None for cell in row):
            data.append(list(row))
with open('$output', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && echo -e "${GREEN}   ✓ Procesado: ${filename}${NC}" || echo -e "${RED}   ✗ Error: ${filename}${NC}"
        else
            echo -e "${YELLOW}   ⚠ openpyxl no instalado, instalando...${NC}"
            pip3 install openpyxl -q 2>/dev/null
            python3 -c "
import openpyxl, json, sys
wb = openpyxl.load_workbook('$xlsx_file')
data = []
for sheet in wb.worksheets:
    for row in sheet.iter_rows(values_only=True):
        if any(cell is not None for cell in row):
            data.append(list(row))
with open('$output', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null && echo -e "${GREEN}   ✓ Procesado: ${filename}${NC}" || echo -e "${RED}   ✗ Error: ${filename}${NC}"
        fi
    fi
done

echo -e "${YELLOW}[4/6] Procesando documentos...${NC}"

# Procesar Docs (requiere pandoc)
for doc_file in "$TEMP_DIR"/*.doc "$TEMP_DIR"/*.docx 2>/dev/null; do
    if [[ -f "$doc_file" ]]; then
        filename=$(basename "$doc_file" .doc | sed 's/.docx$//')
        output="$KNOWLEDGE_DIR/docs/${filename}.md"
        
        if command -v pandoc &> /dev/null; then
            pandoc "$doc_file" -o "$output" 2>/dev/null && \
                echo -e "${GREEN}   ✓ Procesado: ${filename}${NC}" || \
                echo -e "${RED}   ✗ Error: ${filename}${NC}"
        else
            echo -e "${YELLOW}   ⚠ pandoc no instalado, omitiendo: ${filename}${NC}"
        fi
    fi
done

echo -e "${YELLOW}[5/6] Procesando imágenes...${NC}"

# Procesar imágenes (requiere vision API o tesseract)
for img_file in "$TEMP_DIR"/*.png "$TEMP_DIR"/*.jpg "$TEMP_DIR"/*.jpeg "$TEMP_DIR"/*.gif 2>/dev/null; do
    if [[ -f "$img_file" ]]; then
        filename=$(basename "$img_file")
        # Por ahora solo copiamos, el procesamiento se hace con vision API
        cp "$img_file" "$KNOWLEDGE_DIR/images/"
        echo -e "${GREEN}   ✓ Imagen guardada: ${filename}${NC}"
    fi
done

echo -e "${YELLOW}[6/6] Procesando URLs...${NC}"

# Procesar URLs (requiere curl/wget)
if command -v curl &> /dev/null; then
    # Leer URLs del archivo pending
    if [[ -f "$PENDING_FILE" ]]; then
        urls=$(grep -o '"url"[^,]*' "$PENDING_FILE" | cut -d'"' -f4 2>/dev/null || true)
        
        for url in $urls; do
            if [[ -n "$url" ]]; then
                filename=$(echo "$url" | md5sum | cut -d' ' -f1)
                output="$KNOWLEDGE_DIR/urls/${filename}.html"
                
                if curl -sL "$url" -o "$output" 2>/dev/null; then
                    echo -e "${GREEN}   ✓ URL procesada: ${url}${NC}"
                else
                    echo -e "${RED}   ✗ Error procesando URL: ${url}${NC}"
                fi
            fi
        done
    fi
fi

#===============================================================================
# CREAR ÍNDICE DE CONOCIMIENTO
#===============================================================================

echo -e "${YELLOW}Creando índice de conocimiento...${NC}"

# Contar archivos procesados
PDF_COUNT=$(ls -1 "$KNOWLEDGE_DIR/pdf"/*.txt 2>/dev/null | wc -l || echo "0")
EXCEL_COUNT=$(ls -1 "$KNOWLEDGE_DIR/excel"/*.json 2>/dev/null | wc -l || echo "0")
DOCS_COUNT=$(ls -1 "$KNOWLEDGE_DIR/docs"/*.md 2>/dev/null | wc -l || echo "0")
IMAGES_COUNT=$(ls -1 "$KNOWLEDGE_DIR/images"/* 2>/dev/null | wc -l || echo "0")
URLS_COUNT=$(ls -1 "$KNOWLEDGE_DIR/urls"/*.html 2>/dev/null | wc -l || echo "0")

TOTAL=$((PDF_COUNT + EXCEL_COUNT + DOCS_COUNT + IMAGES_COUNT + URLS_COUNT))

cat > "$KNOWLEDGE_DIR/index.json" << EOF
{
  "agent_name": "${AGENT_NAME}",
  "created_at": "$(date -Iseconds)",
  "files": {
    "pdf": ${PDF_COUNT},
    "excel": ${EXCEL_COUNT},
    "docs": ${DOCS_COUNT},
    "images": ${IMAGES_COUNT},
    "urls": ${URLS_COUNT}
  },
  "total": ${TOTAL},
  "embeddings_enabled": true,
  "embeddings_model": "nomic-embed-text"
}
EOF

echo -e "${GREEN}   ✓ Índice creado con ${TOTAL} archivos${NC}"

#===============================================================================
# ACTUALIZAR ESTADO
#===============================================================================

# Actualizar pending-knowledge.json
if [[ -f "$PENDING_FILE" ]]; then
    # Marcar todos como procesados
    sed -i 's/"status": "pending"/"status": "processed"/g' "$PENDING_FILE"
fi

# Crear knowledge-status.json
cat > "$CONFIG_DIR/.knowledge-status.json" << EOF
{
  "status": "completed",
  "agent_name": "${AGENT_NAME}",
  "files_processed": ${TOTAL},
  "breakdown": {
    "pdf": ${PDF_COUNT},
    "excel": ${EXCEL_COUNT},
    "docs": ${DOCS_COUNT},
    "images": ${IMAGES_COUNT},
    "urls": ${URLS_COUNT}
  },
  "created_at": "$(date -Iseconds)"
}
EOF

#===============================================================================
# RESUMEN
#===============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            KNOWLEDGE PROCESSING COMPLETADO                    ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Archivos procesados:${NC}"
echo -e "   ${GREEN}✓${NC} PDFs: ${PDF_COUNT}"
echo -e "   ${GREEN}✓${NC} Excel: ${EXCEL_COUNT}"
echo -e "   ${GREEN}✓${NC} Docs: ${DOCS_COUNT}"
echo -e "   ${GREEN}✓${NC} Imágenes: ${IMAGES_COUNT}"
echo -e "   ${GREEN}✓${NC} URLs: ${URLS_COUNT}"
echo -e "   ${BLUE}Total:${NC} ${TOTAL}"
echo ""
echo -e "${BLUE}Directorios creados:${NC}"
echo -e "   ${GREEN}✓${NC} $KNOWLEDGE_DIR/pdf/"
echo -e "   ${GREEN}✓${NC} $KNOWLEDGE_DIR/excel/"
echo -e "   ${GREEN}✓${NC} $KNOWLEDGE_DIR/docs/"
echo -e "   ${GREEN}✓${NC} $KNOWLEDGE_DIR/images/"
echo -e "   ${GREEN}✓${NC} $KNOWLEDGE_DIR/urls/"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} ./setup-email.sh --agent-name '${AGENT_NAME}'"
echo ""

exit 0