# A-18: Order Manager

**Categoría:** E-commerce | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Gestión completa de pedidos: recibe órdenes via WhatsApp/Telegram/web, extrae los items del mensaje, confirma el pedido al cliente, genera recibo PDF, y notifica a cocina/bodega por el canal configurado.

---

## 🔄 Workflow

```
TRIGGER: [webhook] → mensaje del cliente con pedido
   │
   ├── PASO 1: extract_data → Extraer items, cantidades, notas
   ├── PASO 2: rewrite → Confirmar pedido al cliente (resumen)
   ├── PASO 3: pdf_generate → Generar recibo/ticket
   ├── PASO 4: notifications → Notificar a cocina/bodega
   └── PASO 5: email_send → Enviar confirmación formal
```

## 📝 Receta

```json
{
  "automation_id": "A-18",
  "name": "order_manager",
  "version": "1.0.0",
  "skills_required": ["extract_data", "rewrite", "form_create", "pdf_generate", "email_send", "sms_send", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 8,
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Extraer items del pedido",
      "input": {"message": "{customer_message}", "menu_reference": "data/menu.json"},
      "output": "order{items[], quantities[], notes, subtotal, total}",
      "on_error": {"action": "ask_customer", "message": "No entendí tu pedido. ¿Puedes repetirlo?"}
    },
    {
      "step": 2, "skill": "rewrite",
      "action": "Generar confirmación para el cliente",
      "input": {"order": "{step_1.order}", "tone": "amigable"},
      "output": "confirmation_message",
      "on_error": {"action": "template"}
    },
    {
      "step": 3, "skill": "pdf_generate",
      "action": "Generar recibo/ticket",
      "input": {"order": "{step_1.order}", "template": "receipt", "order_number": "auto"},
      "output": "receipt_pdf_path",
      "condition": "only_if config.generate_receipt",
      "on_error": {"action": "skip"}
    },
    {
      "step": 4, "skill": "notifications",
      "action": "Notificar a cocina/bodega",
      "input": {
        "channel": "{config.kitchen_notify}",
        "message": "🔔 PEDIDO #{order_number}\n{items_formatted}\n📝 Notas: {notes}\n⏰ {timestamp}"
      },
      "output": "kitchen_notified"
    },
    {
      "step": 5, "skill": "email_send",
      "action": "Confirmación formal por email",
      "input": {
        "to": "{customer_email}",
        "subject": "Pedido #{order_number} confirmado",
        "attachments": ["{step_3.receipt_pdf_path}"]
      },
      "condition": "only_if customer_email exists",
      "output": "email_sent"
    }
  ],
  "config_schema": {
    "order_channels": {"type": "array", "default": ["whatsapp", "telegram", "web"]},
    "confirmation_channel": {"type": "string", "default": "same_as_order"},
    "kitchen_notify": {"type": "string", "default": "telegram"},
    "generate_receipt": {"type": "boolean", "default": true},
    "menu_file": {"type": "string", "default": "data/menu.json"},
    "currency": {"type": "string", "default": "USD"},
    "tax_rate": {"type": "number", "default": 0.0}
  }
}
```

## 🤖 Prompt — Extraer pedido

```
Extrae los items de este pedido de un cliente:

Mensaje: "{customer_message}"
Menú disponible: {menu_json}

Extrae:
- items: lista de productos pedidos
- quantities: cantidad de cada uno
- notes: notas especiales (sin cebolla, extra queso, etc.)
- identifica si falta algo para completar el pedido

Si el item NO está en el menú, indicarlo como "no_disponible".

Responde en JSON:
{
  "items": [{"name": "...", "quantity": 1, "price": 0.00, "available": true}],
  "notes": "...",
  "complete": true/false,
  "missing_info": "..."
}
```

---
*Automatización A-18 — Order Manager — Diseñada 2026-03-07*
