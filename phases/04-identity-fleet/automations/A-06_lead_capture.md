# A-06: Lead Capture

**Categoría:** Marketing | **Fase:** F5 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Formularios inteligentes que capturan leads, los guardan en un CRM simple (JSON/Excel), envían email de confirmación automática al prospecto, y notifican al dueño del negocio por su canal preferido (email/Telegram/WhatsApp).

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Typeform / Google Forms | ✅ Campos dinámicos + confirmación automática |
| HubSpot Free CRM | ✅ Concepto de pipeline: lead → contactado → cliente |
| Tally.so (open source forms) | ✅ Formularios simples sin registro |
| n8n Form Trigger | ✅ Webhook como receptor del form |

**Nuestro enfoque:** El agente crea el form, recibe submissions via webhook, extrae datos, auto-responde, y notifica. Sin plataformas externas.

---

## 🔄 Workflow

```
TRIGGER: [webhook] → formulario enviado
   │
   ├── PASO 1: extract_data → Parsear submission del form
   ├── PASO 2: classify → Clasificar lead (caliente/tibio/frío)  
   ├── PASO 3: email_send → Auto-respuesta al prospecto
   ├── PASO 4: notifications → Notificar al dueño
   └── PASO 5: Guardar en CRM (data/leads.json)
```

## 📝 Receta

```json
{
  "automation_id": "A-6",
  "name": "lead_capture",
  "version": "1.0.0",
  "skills_required": ["form_create", "webhook", "extract_data", "classify", "email_send", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 5,
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Parsear datos del formulario",
      "input": {"webhook_payload": "{raw_submission}"},
      "output": "name, email, phone, message, source",
      "on_error": {"action": "log", "fallback": "Guardar submission raw"}
    },
    {
      "step": 2, "skill": "classify",
      "action": "Clasificar lead por potencial",
      "input": {"message": "{step_1.message}", "categories": ["hot", "warm", "cold"]},
      "output": "lead_score",
      "on_error": {"action": "default", "fallback": "warm"}
    },
    {
      "step": 3, "skill": "email_send",
      "action": "Enviar auto-respuesta",
      "input": {
        "to": "{step_1.email}",
        "subject": "¡Gracias por contactarnos, {step_1.name}!",
        "template": "lead_auto_reply",
        "variables": {"name": "{step_1.name}", "business": "{config.business_name}"}
      },
      "output": "email_sent",
      "on_error": {"action": "queue", "fallback": "Reintentar en 5min"}
    },
    {
      "step": 4, "skill": "notifications",
      "action": "Notificar al dueño del negocio",
      "input": {
        "channels": "{config.notify_channels}",
        "message": "🔔 Nuevo lead {step_2.lead_score}: {step_1.name}\n📧 {step_1.email}\n📱 {step_1.phone}\n💬 {step_1.message}"
      },
      "output": "notification_sent",
      "on_error": {"action": "skip"}
    },
    {
      "step": 5, "skill": "none",
      "action": "Guardar en CRM",
      "input": {"lead": "{step_1}", "score": "{step_2.lead_score}", "timestamp": "now"},
      "output": "lead_id"
    }
  ],
  "config_schema": {
    "business_name": {"type": "string"},
    "notify_channels": {"type": "array", "default": ["email", "telegram"]},
    "auto_reply_template": {"type": "string", "default": "templates/lead_reply.html"},
    "crm_file": {"type": "string", "default": "data/leads.json"},
    "form_fields": {"type": "array", "default": ["name", "email", "phone", "message"]}
  }
}
```

## 🤖 Prompt — Clasificar lead

```
Clasifica este mensaje de un prospecto en: hot (listo para comprar), warm (interesado), cold (solo curiosidad).

Mensaje: "{message}"

Indicadores hot: menciona precio, urgencia, "cuándo", "quiero"
Indicadores warm: preguntas generales, "me interesa", solicita info  
Indicadores cold: "solo pregunto", sin compromiso, vago

Responde SOLO: hot, warm, o cold
```

## ⚠️ Error Handling

| Paso | Falla | Acción |
|---|---|---|
| 1 | Submission vacía | Log error + descartar |
| 2 | Clasificación imprecisa | Default: warm |
| 3 | Email inválido | Skip auto-respuesta |
| 4 | Canal no disponible | Intentar siguiente canal |

## 📌 Ejemplo

**Input webhook:** `{"name": "María", "email": "maria@mail.com", "phone": "+57300123", "message": "Quiero cotización para 50 invitaciones"}`

**Output:** Lead clasificado como **hot**, auto-respuesta enviada, dueño notificado por Telegram: "🔔 Nuevo lead hot: María — Quiero cotización para 50 invitaciones"

---
*Automatización A-06 — Lead Capture — Diseñada 2026-03-07*
