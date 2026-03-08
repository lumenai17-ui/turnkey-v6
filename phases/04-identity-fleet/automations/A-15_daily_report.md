# A-15: Daily Report

**Categoría:** Operaciones | **Fase:** F6 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Resumen diario automático del negocio: métricas clave, tareas pendientes, alertas, y recomendaciones. Se envía cada mañana por email y/o Telegram para que el dueño empiece el día informado.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Databox daily snapshots | ✅ Formato de snapshot con KPIs |
| Geckoboard | ✅ Dashboard simplificado con métricas clave |
| Morning Brew format | ✅ Estilo newsletter corto y fácil de leer |

---

## 🔄 Workflow

```
TRIGGER: [cron] → 8:00 AM diario
   │
   ├── PASO 1: metrics_dashboard → Recolectar métricas del día anterior
   ├── PASO 2: summarize → Resumir actividad y alertas
   ├── PASO 3: report_generate → Crear reporte visual (HTML/PDF)
   └── PASO 4: email_send → Enviar por email + Telegram
```

## 📝 Receta

```json
{
  "automation_id": "A-15",
  "name": "daily_report",
  "version": "1.0.0",
  "skills_required": ["cron", "metrics_dashboard", "summarize", "report_generate", "email_send"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 15,
  "steps": [
    {
      "step": 1, "skill": "metrics_dashboard",
      "action": "Recolectar métricas del día anterior",
      "input": {"date_range": "yesterday", "metrics": "{config.tracked_metrics}"},
      "output": "metrics_data{leads, revenue, emails_sent, automations_run, errors}",
      "on_error": {"action": "partial", "fallback": "Reportar solo métricas disponibles"}
    },
    {
      "step": 2, "skill": "summarize",
      "action": "Generar resumen ejecutivo",
      "input": {"metrics": "{step_1.metrics_data}", "tasks": "{data/tasks.json}", "alerts": "{data/alerts.json}"},
      "output": "executive_summary, highlights[], action_items[]",
      "on_error": {"action": "raw_numbers"}
    },
    {
      "step": 3, "skill": "report_generate",
      "action": "Crear reporte visual",
      "input": {"summary": "{step_2}", "metrics": "{step_1}", "format": "html_email"},
      "output": "report_html",
      "on_error": {"action": "plaintext"}
    },
    {
      "step": 4, "skill": "email_send",
      "action": "Enviar reporte",
      "input": {
        "to": "{config.recipients}",
        "subject": "📊 Reporte Diario — {date}",
        "body": "{step_3.report_html}",
        "channels": "{config.channels}"
      },
      "output": "sent"
    }
  ],
  "config_schema": {
    "send_time": {"type": "string", "default": "08:00"},
    "recipients": {"type": "array"},
    "channels": {"type": "array", "default": ["email", "telegram"]},
    "tracked_metrics": {"type": "array", "default": ["leads", "revenue", "emails_sent", "automations_run"]},
    "include_tasks": {"type": "boolean", "default": true},
    "include_alerts": {"type": "boolean", "default": true}
  }
}
```

## 🤖 Prompt — Resumen ejecutivo

```
Genera un resumen ejecutivo diario del negocio basado en estas métricas:

MÉTRICAS: {metrics_json}
TAREAS PENDIENTES: {tasks}
ALERTAS: {alerts}

FORMATO:
1. 📊 HEADLINE: (1 línea, lo más importante del día)
2. ✅ HIGHLIGHTS: (3-5 logros o datos positivos)
3. ⚠️ ALERTAS: (si las hay)
4. 📋 PENDIENTES: (top 3 tareas prioritarias)
5. 💡 RECOMENDACIÓN: (1 acción sugerida para hoy)

Sé conciso. El dueño lee esto en 30 segundos.
```

---
*Automatización A-15 — Daily Report — Diseñada 2026-03-07*
