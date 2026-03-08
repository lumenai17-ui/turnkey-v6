# A-16: Customer Follow-up

**Categoría:** Operaciones | **Fase:** F5 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Seguimiento automático post-servicio o post-compra. El agente espera X horas después del servicio, envía un email/WhatsApp de seguimiento con encuesta de satisfacción, analiza el sentimiento de la respuesta, y escala al dueño si la experiencia fue negativa.

---

## 🔄 Workflow

```
TRIGGER: [cron] → revisa clientes con servicio completado hace {followup_after}
   │     [webhook] → servicio marcado como completado
   │
   ├── PASO 1: extract_data → Obtener clientes pendientes de followup
   ├── PASO 2: rewrite → Generar mensaje personalizado
   ├── PASO 3: email_send → Enviar followup + link a encuesta
   ├── PASO 4: form_create → Encuesta de satisfacción (si no existe)
   └── PASO 5: sentiment → Analizar respuesta (cuando llegue via webhook)
       └── Si negativa → notifications → Escalar al dueño
```

## 📝 Receta

```json
{
  "automation_id": "A-16",
  "name": "customer_followup",
  "version": "1.0.0",
  "skills_required": ["cron", "extract_data", "rewrite", "email_send", "form_create", "sentiment", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 8,
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Obtener clientes pendientes de followup",
      "input": {"source": "data/services_completed.json", "filter": "followup_sent == false AND completed_at < now - {config.followup_after}"},
      "output": "clients_to_followup[]"
    },
    {
      "step": 2, "skill": "rewrite",
      "action": "Generar mensaje personalizado",
      "input": {"client": "{client}", "service": "{client.service_type}", "tone": "cercano y profesional"},
      "output": "followup_message",
      "loop": "for_each client"
    },
    {
      "step": 3, "skill": "email_send",
      "action": "Enviar followup con encuesta",
      "input": {
        "to": "{client.email}",
        "subject": "¿Cómo fue tu experiencia, {client.name}?",
        "body": "{step_2.followup_message}",
        "survey_link": "{survey_url}"
      },
      "output": "email_sent"
    },
    {
      "step": 4, "skill": "form_create",
      "action": "Crear encuesta (si no existe)",
      "input": {"questions": "{config.survey_questions}", "type": "satisfaction_1_to_5"},
      "output": "survey_url",
      "condition": "only_if survey not exists"
    }
  ],
  "webhook_handler": {
    "on_survey_response": {
      "step": 5, "skill": "sentiment",
      "action": "Analizar respuesta de encuesta",
      "input": {"response": "{survey_response}"},
      "output": "satisfaction_score",
      "then": {
        "if_negative": {"skill": "notifications", "action": "Escalar al dueño", "urgency": "high"},
        "if_positive": {"action": "Log + agradecer"}
      }
    }
  },
  "config_schema": {
    "followup_after": {"type": "string", "default": "48h"},
    "channels": {"type": "array", "default": ["email"]},
    "include_survey": {"type": "boolean", "default": true},
    "survey_questions": {"type": "integer", "default": 3},
    "escalate_negative": {"type": "boolean", "default": true}
  }
}
```

## 🤖 Prompt — Mensaje de followup

```
Escribe un mensaje de seguimiento post-servicio para {client_name}.

Servicio realizado: {service_type}
Fecha: {service_date}
Tono: cercano, profesional, genuino

ESTRUCTURA:
1. Saludo personal
2. Referencia al servicio específico (no genérico)
3. Preguntar cómo fue la experiencia
4. Link a encuesta corta (3 preguntas)
5. Ofrecer ayuda si necesita algo

Máximo 100 palabras. NO suene como bot.
```

---
*Automatización A-16 — Customer Follow-up — Diseñada 2026-03-07*
