# A-13: Appointment Bot

**Categoría:** Operaciones | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Google Calendar API

---

## 📋 Resumen

Gestión completa de citas: el cliente solicita una cita, el agente verifica disponibilidad en Google Calendar, agenda, envía confirmación, y programa recordatorios automáticos (2h antes por SMS y email).

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Cal.com (open source) | ✅ Verificación de disponibilidad + slots |
| Calendly | ✅ Flujo conversacional: elegir fecha → confirmar |
| Google Calendar API | ✅ Lectura/escritura directa de eventos |
| n8n Calendar nodes | ✅ Check availability → create event → notify |

---

## 🔄 Workflow

```
TRIGGER: "Quiero agendar una cita"
   │     [webhook] → formulario de cita submitted
   │
   ├── PASO 1: extract_data → Extraer fecha, hora, servicio deseado
   ├── PASO 2: calendar → Verificar disponibilidad
   │   └── Si no hay → Ofrecer alternativas
   ├── PASO 3: calendar → Crear evento en Google Calendar
   ├── PASO 4: email_send → Enviar confirmación al cliente
   ├── PASO 5: cron → Programar recordatorio (2h antes)
   └── PASO 6: sms_send/email_send → Enviar recordatorio cuando toque
```

## 📝 Receta

```json
{
  "automation_id": "A-13",
  "name": "appointment_bot",
  "version": "1.0.0",
  "skills_required": ["extract_data", "calendar", "email_send", "sms_send", "cron", "reminders", "form_create"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 10,
  "external_api_setup": {
    "google_calendar_api": {
      "auth": "OAuth 2.0 (nosotros configuramos la cuenta del cliente)",
      "note": "Ya incluido en nuestro setup — no requiere acción del cliente"
    }
  },
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Extraer datos de la solicitud",
      "input": {"message": "{customer_request}"},
      "output": "desired_date, desired_time, service_type, client_name, client_phone",
      "on_error": {"action": "ask_user", "message": "¿Para qué fecha y hora necesitas la cita?"}
    },
    {
      "step": 2, "skill": "calendar",
      "action": "Verificar disponibilidad",
      "input": {
        "date": "{step_1.desired_date}",
        "time": "{step_1.desired_time}",
        "duration": "{config.slot_duration}",
        "business_hours": "{config.business_hours}"
      },
      "output": "is_available, alternative_slots[]",
      "on_error": {"action": "offer_alternatives"}
    },
    {
      "step": 3, "skill": "calendar",
      "action": "Crear evento en Google Calendar",
      "input": {
        "title": "{step_1.service_type} — {step_1.client_name}",
        "start": "{step_1.desired_date}T{step_1.desired_time}",
        "duration": "{config.slot_duration}",
        "description": "Tel: {step_1.client_phone}"
      },
      "condition": "only_if step_2.is_available",
      "output": "event_id, event_link"
    },
    {
      "step": 4, "skill": "email_send",
      "action": "Enviar confirmación",
      "input": {
        "to": "{client_email}",
        "subject": "✅ Cita confirmada — {service_type}",
        "body": "Tu cita está confirmada para {date} a las {time}. Te enviaremos un recordatorio 2 horas antes."
      },
      "output": "confirmation_sent"
    },
    {
      "step": 5, "skill": "reminders",
      "action": "Programar recordatorio",
      "input": {
        "when": "{event_start - config.reminder_before}",
        "channels": "{config.reminder_channels}",
        "message": "⏰ Recordatorio: Tu cita de {service_type} es hoy a las {time}"
      },
      "output": "reminder_scheduled"
    }
  ],
  "config_schema": {
    "business_hours": {"type": "string", "default": "09:00-18:00"},
    "slot_duration": {"type": "integer", "default": 30, "description": "Minutos por cita"},
    "reminder_before": {"type": "string", "default": "2h"},
    "reminder_channels": {"type": "array", "default": ["sms", "email"]},
    "timezone": {"type": "string", "default": "America/Bogota"},
    "services": {"type": "array", "default": [], "description": "Lista de servicios disponibles con duración"}
  }
}
```

## 🤖 Prompt — Extraer datos de cita

```
Extrae la información de esta solicitud de cita:

Mensaje: "{customer_request}"

Extrae:
- desired_date (formato YYYY-MM-DD)
- desired_time (formato HH:MM, 24h)
- service_type (qué servicio necesita)
- client_name
- client_phone (si lo menciona)

Si algún dato no está, marca como "missing".
Si la fecha es relativa ("mañana", "el viernes"), conviértela a fecha absoluta basándote en que hoy es {today}.

JSON: {"desired_date": "...", "desired_time": "...", "service_type": "...", "client_name": "...", "client_phone": "...", "missing": []}
```

---
*Automatización A-13 — Appointment Bot — Diseñada 2026-03-07*
