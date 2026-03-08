# A-20: Inventory Alert

**Categoría:** E-commerce | **Fase:** F5 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Monitorea niveles de inventario desde un Excel y alerta cuando un producto baja del stock mínimo. Envía notificaciones por email y Telegram con los productos que necesitan reabastecimiento.

---

## 🔄 Workflow

```
TRIGGER: [cron] → cada 12h
   │
   ├── PASO 1: excel_read → Leer inventario actual
   ├── PASO 2: extract_data → Identificar productos bajo mínimo
   ├── PASO 3: notifications → Alertar por canales configurados
   └── PASO 4: report_generate → Reporte si hay muchos low-stock
```

## 📝 Receta

```json
{
  "automation_id": "A-20",
  "name": "inventory_alert",
  "version": "1.0.0",
  "skills_required": ["excel_read", "cron", "extract_data", "email_send", "sms_send", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 5,
  "steps": [
    {
      "step": 1, "skill": "excel_read",
      "action": "Leer inventario actual",
      "input": {"source": "{config.source_file}", "columns": ["product", "current_stock", "min_stock"]},
      "output": "inventory[]",
      "on_error": {"action": "abort", "message": "No se pudo leer el archivo de inventario"}
    },
    {
      "step": 2, "skill": "extract_data",
      "action": "Identificar productos bajo mínimo",
      "input": {"inventory": "{step_1.inventory}", "threshold": "current_stock <= min_stock"},
      "output": "low_stock_items[]",
      "on_error": {"action": "abort"}
    },
    {
      "step": 3, "skill": "notifications",
      "action": "Enviar alerta de stock bajo",
      "input": {
        "channels": "{config.alert_channels}",
        "message": "⚠️ ALERTA DE INVENTARIO\n\n{low_stock_items_formatted}\n\nTotal: {count} productos bajo mínimo",
        "urgency": "high"
      },
      "condition": "only_if low_stock_items.length > 0",
      "output": "alert_sent"
    },
    {
      "step": 4, "skill": "report_generate",
      "action": "Generar reporte de inventario",
      "input": {"items": "{step_2.low_stock_items}", "template": "inventory_alert"},
      "condition": "only_if low_stock_items.length > 5",
      "output": "report_path"
    }
  ],
  "config_schema": {
    "source_file": {"type": "string", "default": "data/inventory.xlsx"},
    "check_interval": {"type": "string", "default": "12h"},
    "min_stock_threshold": {"type": "integer", "default": 5},
    "alert_channels": {"type": "array", "default": ["email", "telegram"]},
    "auto_reorder": {"type": "boolean", "default": false}
  }
}
```

---
*Automatización A-20 — Inventory Alert — Diseñada 2026-03-07*
