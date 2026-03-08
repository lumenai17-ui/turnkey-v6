# A-05: SEO Content Creator

**Categoría:** Marketing | **Fase:** F4 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Genera artículos completos optimizados para SEO desde un tema o keyword. El agente investiga en la web, analiza competencia, crea un artículo largo con estructura SEO, y lo entrega como documento Word/HTML listo para publicar.

---

## 🔍 Investigación — Qué existe

| Herramienta | Qué hace | Qué adoptamos |
|---|---|---|
| ALwrity (open source) | AI writing + web research + image generation | ✅ Flujo de researchar antes de escribir |
| brightdata/seo-article-generator | Scrape Google → extract → generate con LangChain | ✅ El paso de scraping de SERPs como base |
| SEOArticlegenAI | OpenAI Davinci → artículos desde CSV | ❌ Demasiado simple, sin research |
| ContentGecko | Outline → research → draft → optimize | ✅ La estructura de 4 fases es la ideal |

**Diferenciador nuestro:** Usamos Brave Search (free tier) + Ollama Cloud (∞ tokens) + herramientas locales. Costo por artículo: ~$0.01 (vs ~$0.50-$2 con GPT-4 + APIs pagas).

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────┐
│               A-05: SEO CONTENT CREATOR                   │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  TRIGGER: "Escribe un artículo sobre {tema}"              │
│     │     "Artículo SEO para keyword: {keyword}"          │
│     │     [cron] → genera artículo semanal                │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 1: Investigar en web                   │          │
│  │ skill: web_search                           │          │
│  │ Buscar: tema + competencia en SERPs         │          │
│  │ Obtener: 5-10 resultados top                │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 2: Analizar y extraer datos            │          │
│  │ skill: summarize + extract_data             │          │
│  │ Resumir: puntos clave de cada resultado     │          │
│  │ Extraer: datos, estadísticas, citas         │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 3: Crear outline SEO                   │          │
│  │ skill: rewrite                              │          │
│  │ Generar: H1, H2s, H3s, meta description     │          │
│  │ Incluir: keywords, estructura lógica         │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 4: Escribir artículo completo          │          │
│  │ skill: rewrite                              │          │
│  │ Input: outline + datos investigados          │          │
│  │ Output: artículo 1200-2000 palabras          │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 5: Exportar documento                  │          │
│  │ skill: doc_generate                         │          │
│  │ Formato: Word (.docx) o HTML                │          │
│  └──────────────────────────────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Receta (JSON)

```json
{
  "automation_id": "A-5",
  "name": "seo_content_creator",
  "version": "1.0.0",
  "skills_required": ["web_search", "summarize", "extract_data", "rewrite", "doc_generate"],
  "estimated_cost_per_run": 0.01,
  "estimated_duration_seconds": 45,
  "steps": [
    {
      "step": 1,
      "skill": "web_search",
      "action": "Investigar tema en la web",
      "input": {
        "query": "{keyword} guía completa {language}",
        "num_results": 10
      },
      "output": "search_results[]",
      "on_error": {
        "action": "retry",
        "max_retries": 2,
        "fallback": "Escribir artículo sin research externo (solo conocimiento del LLM)"
      }
    },
    {
      "step": 2,
      "skill": "summarize",
      "action": "Resumir y extraer datos clave",
      "input": {
        "texts": "{step_1.search_results}",
        "extract": "puntos_clave, estadísticas, citas, datos_relevantes"
      },
      "output": "research_summary, key_data[], statistics[]",
      "on_error": {
        "action": "continue",
        "fallback": "Usar resultados raw sin resumen"
      }
    },
    {
      "step": 3,
      "skill": "rewrite",
      "action": "Crear outline SEO optimizado",
      "input": {
        "topic": "{keyword}",
        "research": "{step_2.research_summary}",
        "target_word_count": "{config.target_word_count}",
        "seo_keywords": "{config.seo_keywords}"
      },
      "output": "outline{title, meta_description, h2_sections[], keywords_placement}",
      "on_error": {
        "action": "retry",
        "max_retries": 1
      }
    },
    {
      "step": 4,
      "skill": "rewrite",
      "action": "Escribir artículo completo",
      "input": {
        "outline": "{step_3.outline}",
        "research_data": "{step_2.key_data}",
        "tone": "{config.tone}",
        "word_count": "{config.target_word_count}",
        "language": "{config.language}"
      },
      "output": "article_html",
      "on_error": {
        "action": "retry",
        "max_retries": 1,
        "fallback": "Entregar outline sin artículo completo"
      }
    },
    {
      "step": 5,
      "skill": "doc_generate",
      "action": "Exportar como documento",
      "input": {
        "content": "{step_4.article_html}",
        "format": "{config.output_format}",
        "filename": "{keyword_slug}_seo_article"
      },
      "output": "document_path",
      "on_error": {
        "action": "skip",
        "fallback": "Entregar como texto plano"
      }
    }
  ],
  "config_schema": {
    "target_word_count": {"type": "integer", "default": 1500, "min": 800, "max": 5000},
    "seo_keywords": {"type": "array", "default": [], "description": "Keywords secundarios a incluir"},
    "tone": {"type": "string", "default": "professional", "enum": ["professional", "casual", "technical", "friendly"]},
    "language": {"type": "string", "default": "es"},
    "output_format": {"type": "string", "default": "docx", "enum": ["docx", "html", "markdown"]},
    "include_meta": {"type": "boolean", "default": true, "description": "Incluir meta title + description"}
  }
}
```

---

## 🤖 Prompts de IA

### Prompt — Paso 3: Crear outline SEO

```
Eres un experto en SEO y content marketing. Crea un outline optimizado para SEO.

TEMA: {keyword}
DATOS INVESTIGADOS: {research_summary}
LONGITUD OBJETIVO: {target_word_count} palabras
KEYWORDS SECUNDARIOS: {seo_keywords}
IDIOMA: {language}

GENERA:
1. TITLE TAG (max 60 chars, incluye keyword principal)
2. META DESCRIPTION (max 155 chars, incluye keyword, con CTA)
3. H1 (puede diferir del title tag)
4. OUTLINE con H2 y H3:
   - Cada H2 tiene 2-4 H3
   - Incluir keyword naturalmente
   - 6-10 secciones H2
   - Última sección: conclusión
5. KEYWORDS A INCLUIR en cada sección

Formato de salida JSON:
{
  "title_tag": "...",
  "meta_description": "...",
  "h1": "...",
  "sections": [
    {"h2": "...", "h3s": ["...", "..."], "keywords": ["..."], "notes": "..."}
  ]
}
```

### Prompt — Paso 4: Escribir artículo

```
Escribe un artículo completo de {word_count} palabras basado en este outline y datos de investigación.

OUTLINE: {outline_json}
DATOS INVESTIGADOS: {key_data}
TONO: {tone}
IDIOMA: {language}

REGLAS SEO:
- Keyword principal en primer párrafo
- Keywords secundarios distribuidos naturalmente
- Párrafos cortos (2-4 oraciones)
- Listas con bullets donde sea apropiado
- Al menos 1 dato estadístico con fuente
- Interno linking placeholders: [LINK: texto]
- Formato HTML: <h2>, <h3>, <p>, <ul>, <li>, <strong>
- NO incluir <h1> (se agrega aparte)
- Cierra con conclusión + CTA

Output: SOLO el artículo en HTML, sin explicaciones.
```

---

## ⚠️ Error Handling

| Paso | Qué puede fallar | Qué hacer |
|---|---|---|
| 1 Buscar | Brave Search no disponible | Escribir con conocimiento del LLM solamente |
| 2 Resumir | Resultados no relevantes | Filtrar y usar solo los 3 mejores |
| 3 Outline | Outline demasiado corto/largo | Ajustar número de secciones |
| 4 Escribir | Artículo < 80% del word_count | Regenerar con prompt más detallado |
| 4 Escribir | Contenido duplicado/genérico | Agregar instrucción "incluir datos únicos" |
| 5 Exportar | Pandoc falla | Entregar como HTML raw |

---

## 📌 Ejemplo Completo

### Input del usuario:
> "Escribe un artículo SEO sobre 'mejores prácticas de email marketing para restaurantes'"

### Output final:
```
📝 Artículo SEO listo:

📄 Archivo: mejores-practicas-email-marketing-restaurantes.docx

📊 Estadísticas:
- Palabras: 1,647
- Secciones H2: 8
- Keywords incluidos: 12
- Meta description: ✅
- Tiempo: 38s
- Costo: $0.01

📋 Title tag: "Email Marketing para Restaurantes: 10 Mejores Prácticas [2026]"
📋 Meta: "Descubre las mejores prácticas de email marketing para restaurantes..."

¿Quieres que lo publique en WordPress o lo edito primero?
```

---

*Automatización A-05 — SEO Content Creator — Diseñada 2026-03-07*
