# FASE 4: KNOWLEDGE - PROFUNDIZACIÓN Y VALIDACIÓN

**Versión:** 1.1.0
**Fecha:** 2026-03-05
**Estado:** ✅ VALIDADO Y CONECTADO

---

## 0️⃣ CONEXIÓN CON FASE 1

### Flujo Completo

```
FASE 1: PRE-FLIGHT
    │
    └─► SECCIÓN 9: CONOCIMIENTO DEL NEGOCIO
          │
          ├─► Usuario sube archivos (PDF, Excel, Docs, Imágenes, Audio)
          ├─► Usuario proporciona URLs
          │
          └─► Guarda en:
                • ~/.openclaw/workspace/temp-upload/
                • ~/.openclaw/config/pending-knowledge.json
                │
                ▼
        FASE 4: IDENTITY FLEET
                │
                └─► Lee pending-knowledge.json
                      │
                      └─► PROCESAMIENTO MULTI-AGENTE (5 agentes)
                            │
                            └─► Guarda en: ~/.openclaw/knowledge/
```

### Archivos Conectados

| Archivo | Fase | Contenido |
|---------|------|-----------|
| `INPUTS.md` | FASE 1 | Sección 9 agregada para recibir archivos |
| `pending-knowledge.json` | FASE 1 → FASE 4 | Metadatos de archivos subidos |
| `knowledge-status.json` | FASE 4 | Estado del procesamiento |
| `FLUJO-CONOCIMIENTO.md` | Global | Documento de conexión |

---

## 1️⃣ QUÉ HACE EXACTAMENTE FASE 4

### Flujo de Procesamiento

```
Usuario sube archivo (FASE 1)
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE PROCESSING                      │
│                    (Multi-Agente Auditado)                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Agente 1: CLASIFICADOR                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Input: archivo crudo (PDF, Excel, Doc, Imagen)       │   │
│  │ Proceso: Detectar tipo, tamaño, contenido           │   │
│  │ Output: metadatos, tipo detectado                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                      │                                       │
│                      ▼                                       │
│  Agente 2: EXTRACTOR                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Input: archivo + metadatos                           │   │
│  │ Proceso: Extraer texto/datos                         │   │
│  │          PDF → pdftotext (LOCAL)                     │   │
│  │          Excel → xlsx2json (LOCAL)                   │   │
│  │          Docs → pandoc (LOCAL)                       │   │
│  │          Imagen → Vision API (API KEY)               │   │
│  │ Output: texto plano, JSON, descripción               │   │
│  └─────────────────────────────────────────────────────┘   │
│                      │                                       │
│                      ▼                                       │
│  Agente 3: ORGANIZADOR                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Input: texto/datos extraídos                         │   │
│  │ Proceso: Estructurar, limpiar, categorizar           │   │
│  │ Output: datos organizados en estructura              │   │
│  └─────────────────────────────────────────────────────┘   │
│                      │                                       │
│                      ▼                                       │
│  Agente 4: INDEXADOR                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Input: datos organizados                             │   │
│  │ Proceso: Crear embeddings (API KEY)                  │   │
│  │          Indexar para búsqueda                       │   │
│  │ Output: índice vectorial, metadatos                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                      │                                       │
│                      ▼                                       │
│  Agente 5: AUDITOR                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Input: todo el proceso                                │   │
│  │ Proceso: Verificar calidad, integridad               │   │
│  │ Output: reporte de auditoría                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
        │
        ▼
Usuario ve archivo procesado (FASE 4)
```

---

## 2️⃣ QUÉ APIs NECESITA

### Por Agente

| Agente | Función | API Necesaria | Sin API Key |
|--------|---------|---------------|-------------|
| **1. CLASIFICADOR** | Detectar tipo | ❌ Ninguna | Funciona con código local |
| **2. EXTRACTOR** | Extraer contenido | ⚠️ Ver tabla abajo | Depende del formato |
| **3. ORGANIZADOR** | Estructurar datos | ❌ Ninguna | Funciona con código local |
| **4. INDEXADOR** | Crear embeddings | ✅ Ollama API | ❌ No funciona sin API |
| **5. AUDITOR** | Verificar calidad | ❌ Ninguna | Funciona con código local |

### EXTRACTOR - Detalle por Formato

| Formato | Herramienta | API Key | Sin API Key |
|---------|-------------|---------|-------------|
| **PDF (texto)** | pdftotext | ❌ No | ✅ Funciona local |
| **PDF (imágenes)** | Vision API | ✅ Sí | ❌ No procesa |
| **Excel** | xlsx2json | ❌ No | ✅ Funciona local |
| **Docs** | pandoc | ❌ No | ✅ Funciona local |
| **Imagen** | Vision API | ✅ Sí | ❌ No procesa |
| **Audio** | Whisper API | ✅ Sí | ❌ No procesa |

### INDEXADOR - Embeddings

| Función | API Key | Endpoint |
|---------|---------|----------|
| Crear embeddings | ✅ Sí | `https://ollama.com/v1/embeddings` |
| Buscar similares | ✅ Sí | Mismo endpoint |

---

## 3️⃣ DÓNDE VAN LOS API KEYS

### Estructura de Configuración

```json
{
  "knowledge": {
    "processing": {
      "pdf_text": {
        "enabled": true,
        "tool": "pdftotext",
        "api_key": null,
        "fallback": null
      },
      "pdf_images": {
        "enabled": true,
        "tool": "vision",
        "api_key": "${OLLAMA_API_KEY}",
        "fallback": "advertir_usuario"
      },
      "excel": {
        "enabled": true,
        "tool": "xlsx2json",
        "api_key": null,
        "fallback": null
      },
      "docs": {
        "enabled": true,
        "tool": "pandoc",
        "api_key": null,
        "fallback": null
      },
      "images": {
        "enabled": true,
        "tool": "vision",
        "api_key": "${OLLAMA_API_KEY}",
        "fallback": "advertir_usuario"
      },
      "audio": {
        "enabled": true,
        "tool": "whisper",
        "api_key": "${OLLAMA_API_KEY}",
        "fallback": "advertir_usuario"
      }
    },
    "indexing": {
      "embeddings": {
        "enabled": true,
        "provider": "ollamacloud",
        "model": "nomic-embed-text",
        "api_key": "${OLLAMA_API_KEY}",
        "fallback": "desabilitar_busqueda_semantica"
      }
    }
  }
}
```

---

## 4️⃣ QUÉ PASA SIN API KEY

### Escenarios

| Escenario | Qué pasa | Acción |
|-----------|----------|--------|
| **Sin OLLAMA_API_KEY** | No embeddings, no vision, no whisper | Advertir al usuario |
| **PDF con imágenes** | No puede extraer texto de imágenes | Advertir que PDF puede estar incompleto |
| **Imagen subida** | No puede analizar | Advertir que necesita API key |
| **Audio subido** | No puede transcribir | Advertir que necesita API key |

### Comportamiento del Sistema sin API Key

```
FASE 4: KNOWLEDGE PROCESSING
        │
        ├─► Verificar API key de Ollama
        │     │
        │     ├─► Si existe: Procesar todo
        │     │
        │     └─► Si NO existe:
        │           │
        │           ├─► Procesar PDF de texto ✅
        │           ├─► Procesar Excel ✅
        │           ├─► Procesar Docs ✅
        │           │
        │           ├─► PDF con imágenes ⚠️ ADVERTIR
        │           ├─► Imágenes ⚠️ ADVERTIR
        │           ├─► Audio ⚠️ ADVERTIR
        │           └─► Embeddings ❌ DESHABILITAR búsqueda semántica
```

### Mensaje al Usuario sin API Key

```markdown
## ⚠️ CONOCIMIENTO PARCIALMENTE PROCESADO

Se procesaron los siguientes archivos correctamente:
- ✅ menu.pdf (texto)
- ✅ precios.xlsx
- ✅ politicas.docx

Los siguientes archivos necesitan API key de Ollama:
- ⚠️ flyer.png → Necesita API para analizar imágenes
- ⚠️ audio-menu.mp3 → Necesita API para transcribir

Para habilitar procesamiento completo:
1. Obtén tu API key en: https://ollama.com
2. Configúrala en: ~/.openclaw/config/api-keys.json
3. Ejecuta de nuevo: process-knowledge.sh --retry
```

---

## 5️⃣ VALIDACIÓN - ES VERDAD LO QUE DOCUMENTAMOS?

### Test 1: pdftotext está disponible?

```bash
which pdftotext
# Si está instalado: /usr/bin/pdftotext
# Si no está: vacío o error
```

**Acción:** Verificar e instalar si falta.

### Test 2: xlsx2json está disponible?

```bash
which xlsx2json || npm list xlsx2json
# Si está instalado: muestra versión
# Si no está: error
```

**Acción:** Verificar e instalar si falta.

### Test 3: pandoc está disponible?

```bash
which pandoc
# Si está instalado: /usr/bin/pandoc
# Si no está: vacío o error
```

**Acción:** Verificar e instalar si falta.

### Test 4: Vision API funciona con la key de Ollama?

```bash
curl -X POST https://ollama.com/v1/chat/completions \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen3-vl:235b", "messages": [{"role": "user", "content": "Describe esta imagen"}]}'
```

**Resultado:** Si funciona, vision disponible. Si error 401, API key inválida.

### Test 5: Embeddings API funciona?

```bash
curl -X POST https://ollama.com/v1/embeddings \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "nomic-embed-text", "input": "texto de prueba"}'
```

**Resultado:** Si funciona, embeddings disponibles. Si error, no hay búsqueda semántica.

---

## 6️⃣ VERIFICACIÓN EN LOCAL

### Resultados de Validación (2026-03-05)

| Test | Resultado | Acción |
|------|-----------|--------|
| pdftotext | ✅ INSTALADO (`/usr/bin/pdftotext`) | Ninguna - Funciona |
| pandoc | ❌ NO INSTALADO | **Instalar en FASE 4** |
| xlsx2json | ❌ NO INSTALADO | **Instalar en FASE 4** |
| Vision API | ✅ FUNCIONA | Modelos disponibles |
| Embeddings | ⚠️ Endpoint diferente | Investigar endpoint |

### API Key de Ollama

| Ubicación | Estado |
|-----------|--------|
| `~/.openclaw/openclaw.json` | ✅ Configurada |
| `OLLAMA_API_KEY` env var | ❌ No configurada |

**Nota:** La API key está en el archivo de configuración, funciona correctamente.

### Modelos Disponibles (Verificado)

| Modelo | Disponible |
|--------|-----------|
| qwen3-vl:235b-instruct | ✅ Sí |
| minimax-m2 | ✅ Sí |
| kimi-k2:1t | ✅ Sí |
| glm-5 | ✅ Sí (ver openclaw.json) |

### Hallazgos Importantes

1. **pdftotext funciona** - PDFs de texto se pueden procesar
2. **pandoc falta** - Docs no se pueden procesar → **Instalar**
3. **xlsx2json falta** - Excel no se puede procesar → **Instalar**
4. **Vision API funciona** - Imágenes se pueden analizar
5. **Embeddings endpoint diferente** - Necesita investigación

### Herramientas a Instalar en FASE 4

```bash
# Instalar pandoc
sudo apt install pandoc

# Instalar alternativa para Excel (Python)
pip install openpyxl pandas

# O con npm
npm install -g xlsx2json
```

### Endpoint de Embeddings

**IMPORTANTE:** El endpoint `/v1/embeddings` no existe en Ollama Cloud.

Investigar cómo hacer embeddings con Ollama. Posibles opciones:
1. Usar modelo de embeddings local si está disponible
2. Usar embeddings de OpenAI como alternativa
3. Buscar documentación de Ollama Cloud para embeddings

---

## 7️⃣ SCRIPT DE VALIDACIÓN

```bash
#!/bin/bash
# validate-knowledge-tools.sh

echo "=== VALIDACIÓN DE HERRAMIENTAS KNOWLEDGE ==="

# Test pdftotext
if command -v pdftotext &> /dev/null; then
    echo "✅ pdftotext: $(which pdftotext)"
else
    echo "❌ pdftotext: NO INSTALADO"
    echo "   Instalar: sudo apt install poppler-utils"
fi

# Test xlsx2json
if command -v xlsx2json &> /dev/null; then
    echo "✅ xlsx2json: $(which xlsx2json)"
elif npm list xlsx2json &> /dev/null; then
    echo "✅ xlsx2json: npm instalado"
else
    echo "⚠️ xlsx2json: NO INSTALADO"
    echo "   Instalar: npm install -g xlsx2json"
fi

# Test pandoc
if command -v pandoc &> /dev/null; then
    echo "✅ pandoc: $(which pandoc)"
else
    echo "❌ pandoc: NO INSTALADO"
    echo "   Instalar: sudo apt install pandoc"
fi

# Test Ollama API Key
if [[ -n "$OLLAMA_API_KEY" ]]; then
    echo "✅ OLLAMA_API_KEY: configurada"
    
    # Test Vision
    if curl -s -X POST https://ollama.com/v1/models \
        -H "Authorization: Bearer $OLLAMA_API_KEY" | grep -q "qwen3-vl"; then
        echo "✅ Vision API: disponible"
    else
        echo "⚠️ Vision API: modelo no disponible"
    fi
    
    # Test Embeddings
    if curl -s -X POST https://ollama.com/v1/embeddings \
        -H "Authorization: Bearer $OLLAMA_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"model": "nomic-embed-text", "input": "test"}' | grep -q "embedding"; then
        echo "✅ Embeddings API: disponible"
    else
        echo "⚠️ Embeddings API: no disponible"
    fi
else
    echo "❌ OLLAMA_API_KEY: NO CONFIGURADA"
    echo "   Configurar en: ~/.openclaw/config/api-keys.json"
fi
```

---

## 8️⃣ RESULTADOS DE VALIDACIÓN

| # | Pregunta | Resultado | Acción |
|---|----------|-----------|--------|
| 1 | ¿pdftotext está instalado en LOCAL? | ✅ SÍ | Ninguna |
| 2 | ¿pandoc está instalado en LOCAL? | ❌ NO | Instalar en FASE 4 |
| 3 | ¿xlsx2json está disponible? | ❌ NO | Instalar en FASE 4 |
| 4 | ¿La API key de Ollama funciona? | ✅ SÍ | Ninguna |
| 5 | ¿Los modelos vision funcionan? | ✅ SÍ | Ninguna |
| 6 | ¿El endpoint embeddings funciona? | ❌ NO | Investigar alternativa |

---

## 9️⃣ CONCLUSIONES DE VALIDACIÓN

### ✅ Lo que SÍ Funciona

| Función | Herramienta | Estado |
|---------|-------------|--------|
| PDF texto | pdftotext | ✅ Listo |
| Vision/Imágenes | Ollama API + qwen3-vl | ✅ Listo |
| Chat completion | Ollama API | ✅ Listo |

### ❌ Lo que FALTA Instalar

| Función | Herramienta | Comando |
|---------|-------------|---------|
| Docs | pandoc | `sudo apt install pandoc` |
| Excel | openpyxl/pandas | `pip install openpyxl pandas` |

### ⚠️ Lo que NECESITA Investigación

| Función | Problema | Acción |
|---------|----------|--------|
| Embeddings | Endpoint no existe | Investigar alternativa |

### 📋 Actualización en DISEÑO

**IMPORTANTE:** El diseño debe actualizarse con:
1. Pandoc y openpyxl como dependencias a instalar
2. Endpoint de embeddings es diferente - verificar documentación de Ollama
3. Si no hay embeddings, búsqueda semántica deshabilitada

---

*Profundización en progreso - Validación pendiente*