# A-09: Blog Autopilot

**Categoría:** Web Content | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** WordPress REST API

---

## 📋 Resumen

Genera y publica artículos de blog semanales automáticamente. Combina A-05 (SEO Content Creator) + A-08 (WordPress Publisher) en un flujo completo: investiga trending topics, escribe artículo, genera imagen, y publica como draft o directamente.

---

## 🔄 Workflow

```
TRIGGER: [cron] → semanal (configurable)
   │
   ├── PASO 1: web_search → Encontrar trending topics del nicho
   ├── PASO 2: summarize → Seleccionar mejor tema de la semana
   ├── PASO 3: → Ejecutar A-05 (SEO Content Creator) con el tema
   ├── PASO 4: image_generate → Crear featured image
   ├── PASO 5: → Ejecutar A-08 (WordPress Publisher) con el artículo
   └── PASO 6: notifications → Confirmar publicación
```

## 📝 Receta

```json
{
  "automation_id": "A-9",
  "name": "blog_autopilot",
  "version": "1.0.0",
  "skills_required": ["web_search", "summarize", "rewrite", "image_generate", "browser"],
  "estimated_cost_per_run": 0.02,
  "estimated_duration_seconds": 60,
  "chains": ["A-5_seo_content_creator", "A-8_wordpress_publisher"],
  "steps": [
    {
      "step": 1, "skill": "web_search",
      "action": "Encontrar trending topics",
      "input": {"queries": "{config.topics_keywords}", "time_filter": "past_week"},
      "output": "trending_topics[]"
    },
    {
      "step": 2, "skill": "summarize",
      "action": "Seleccionar mejor tema",
      "input": {"topics": "{step_1.trending_topics}", "criteria": "relevancia + volumen de búsqueda + competencia baja"},
      "output": "selected_topic, keyword"
    },
    {
      "step": 3, "skill": "chain:A-5",
      "action": "Ejecutar SEO Content Creator",
      "input": {"keyword": "{step_2.keyword}", "config": "{config.article_config}"},
      "output": "article_html, seo_metadata"
    },
    {
      "step": 4, "skill": "image_generate",
      "action": "Crear featured image",
      "input": {"topic": "{step_2.selected_topic}", "dimensions": "1200x630"},
      "output": "featured_image"
    },
    {
      "step": 5, "skill": "chain:A-8",
      "action": "Publicar en WordPress",
      "input": {"article": "{step_3.article_html}", "image": "{step_4.featured_image}", "status": "{config.auto_publish ? 'publish' : 'draft'}"},
      "output": "post_url"
    }
  ],
  "config_schema": {
    "frequency": {"type": "string", "default": "weekly"},
    "topics_keywords": {"type": "array", "description": "Keywords del nicho para buscar trending topics"},
    "auto_publish": {"type": "boolean", "default": false},
    "word_count": {"type": "integer", "default": 1200},
    "article_config": {"type": "object", "description": "Config para A-05"}
  }
}
```

> **Nota:** Esta automatización es un **chain** — encadena A-05 + A-08. No reinventa sus pasos, los reutiliza.

---
*Automatización A-09 — Blog Autopilot — Diseñada 2026-03-07*
