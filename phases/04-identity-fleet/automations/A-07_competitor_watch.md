# A-07: Competitor Watch

**Categoría:** Marketing | **Fase:** F5 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Monitorea competidores automáticamente: scraping de precios, cambios en sus sitios web, y nuevas ofertas. Genera reportes comparativos semanales y alerta en tiempo real cuando detecta cambios importantes.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Visualping | ✅ Detección de cambios en páginas web |
| Prisync (price monitoring) | ✅ Estructura de monitoreo de precios |
| Brandwatch | ✅ Reportes comparativos |
| n8n + cheerio scraping | ✅ Scraping periódico con cron |

---

## 🔄 Workflow

```
TRIGGER: [cron] → cada 24h (configurable)
   │
   ├── PASO 1: scraping → Scrapear sitios de competidores
   ├── PASO 2: extract_data → Extraer precios y ofertas
   ├── PASO 3: summarize → Comparar con snapshot anterior
   ├── PASO 4: report_generate → Crear reporte si hay cambios
   └── PASO 5: email_send → Enviar alerta/reporte
```

## 📝 Receta

```json
{
  "automation_id": "A-7",
  "name": "competitor_watch",
  "version": "1.0.0",
  "skills_required": ["scraping", "cron", "extract_data", "summarize", "report_generate", "email_send"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 30,
  "steps": [
    {
      "step": 1, "skill": "scraping",
      "action": "Scrapear sitios de competidores",
      "input": {"urls": "{config.competitors[].url}", "selectors": "{config.competitors[].selectors}"},
      "output": "scraped_data[]",
      "on_error": {"action": "partial", "fallback": "Continuar con competidores que sí respondieron"}
    },
    {
      "step": 2, "skill": "extract_data",
      "action": "Extraer precios y ofertas",
      "input": {"html_data": "{step_1.scraped_data}", "extract": "prices, offers, new_products"},
      "output": "current_snapshot",
      "on_error": {"action": "skip", "fallback": "Usar datos raw"}
    },
    {
      "step": 3, "skill": "summarize",
      "action": "Comparar con snapshot anterior y detectar cambios",
      "input": {"current": "{step_2.current_snapshot}", "previous": "{data/competitor_snapshots.json}"},
      "output": "changes[], has_significant_changes",
      "on_error": {"action": "continue"}
    },
    {
      "step": 4, "skill": "report_generate",
      "action": "Crear reporte comparativo",
      "input": {"changes": "{step_3.changes}", "competitors": "{config.competitors}"},
      "output": "report_pdf_path",
      "condition": "only_if step_3.has_significant_changes OR config.report_frequency matches today",
      "on_error": {"action": "skip"}
    },
    {
      "step": 5, "skill": "email_send",
      "action": "Enviar alerta o reporte",
      "input": {
        "to": "{config.alert_email}",
        "subject": "🔍 Cambios detectados en competidores",
        "body": "{step_3.changes_summary}",
        "attachments": ["{step_4.report_pdf_path}"]
      },
      "output": "alert_sent",
      "condition": "only_if step_3.has_significant_changes",
      "on_error": {"action": "queue"}
    }
  ],
  "config_schema": {
    "competitors": {"type": "array", "items": {"url": "string", "name": "string", "selectors": {"prices": "string", "products": "string"}}},
    "check_interval": {"type": "string", "default": "24h"},
    "alert_on_price_change": {"type": "boolean", "default": true},
    "alert_email": {"type": "string"},
    "report_frequency": {"type": "string", "default": "weekly"},
    "price_change_threshold": {"type": "number", "default": 0.05, "description": "% de cambio para alertar"}
  }
}
```

## 🤖 Prompt — Comparar snapshots

```
Compara estos dos snapshots de competidores y detecta cambios significativos:

ANTERIOR: {previous_snapshot}
ACTUAL: {current_snapshot}

Reporta:
1. Cambios de precios (indicar % de cambio)
2. Productos nuevos
3. Productos eliminados
4. Ofertas/promociones nuevas
5. Cambios en la página (diseño, contenido)

Clasifica cada cambio: 🔴 URGENTE | 🟡 IMPORTANTE | 🟢 INFORMATIVO

Responde en JSON.
```

---
*Automatización A-07 — Competitor Watch — Diseñada 2026-03-07*
