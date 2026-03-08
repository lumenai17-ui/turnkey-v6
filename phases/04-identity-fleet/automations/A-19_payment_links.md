# A-19: Payment Links

**Categoría:** E-commerce | **Fase:** F5 | **Complejidad:** 🔴 Alta
**Status:** Diseñada | **APIs externas:** Stripe API

---

## 📋 Resumen

Crea links de pago bajo demanda usando Stripe. El agente genera el link, lo envía al cliente por email/WhatsApp/SMS, y notifica al dueño cuando se recibe el pago. Ideal para cobrar servicios, consultas, o productos sin tienda online.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Stripe Payment Links (built-in) | ✅ Concepto de link simple → pago |
| Square Invoices | ✅ Invoice con botón de pago |
| PayPal.me links | ✅ Simplicidad del flujo |

---

## 🔄 Workflow

```
TRIGGER: "Cobrale $200 a Juan por consultoría"
   │     "Crea un link de pago de $50"
   │
   ├── PASO 1: extract_data → Extraer monto, concepto, cliente
   ├── PASO 2: webhook → Crear Payment Link via Stripe API
   ├── PASO 3: email_send / sms_send → Enviar link al cliente
   ├── PASO 4: [webhook listener] → Cuando Stripe confirme pago
   └── PASO 5: notifications → Notificar al dueño "Pago recibido"
```

## 📝 Receta

```json
{
  "automation_id": "A-19",
  "name": "payment_links",
  "version": "1.0.0",
  "skills_required": ["extract_data", "webhook", "email_send", "sms_send", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 8,
  "external_api_setup": {
    "stripe_api": {
      "auth": "API Key (Secret Key)",
      "required": ["stripe_secret_key"],
      "endpoints": {
        "payment_links": "POST /v1/payment_links",
        "prices": "POST /v1/prices",
        "products": "POST /v1/products"
      },
      "webhook": {
        "event": "checkout.session.completed",
        "endpoint": "{our_webhook_url}/stripe/payment_completed"
      },
      "fees": "2.9% + $0.30 per transaction (Stripe standard)"
    }
  },
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Extraer datos del cobro",
      "input": {"request": "{user_request}"},
      "output": "amount, currency, concept, client_name, client_email, client_phone",
      "on_error": {"action": "ask_user", "message": "¿Cuánto, a quién y por qué concepto?"}
    },
    {
      "step": 2, "skill": "webhook",
      "action": "Crear Payment Link en Stripe",
      "input": {
        "api_calls": [
          {"endpoint": "/v1/products", "body": {"name": "{concept}"}},
          {"endpoint": "/v1/prices", "body": {"unit_amount": "{amount_cents}", "currency": "{currency}", "product": "{product_id}"}},
          {"endpoint": "/v1/payment_links", "body": {"line_items": [{"price": "{price_id}", "quantity": 1}]}}
        ]
      },
      "output": "payment_link_url",
      "on_error": {"action": "abort", "message": "Error creando link de pago: {error}"}
    },
    {
      "step": 3, "skill": "email_send",
      "action": "Enviar link al cliente",
      "input": {
        "to": "{step_1.client_email}",
        "subject": "Link de pago — {concept}",
        "body": "Hola {client_name}, aquí está tu link de pago:\n\n{payment_link_url}\n\nMonto: {currency} {amount}\nConcepto: {concept}\n\nEl link es seguro (procesado por Stripe)."
      },
      "output": "link_sent"
    }
  ],
  "webhook_handler": {
    "on_payment_completed": {
      "trigger": "stripe_webhook:checkout.session.completed",
      "actions": [
        {"skill": "notifications", "message": "💰 PAGO RECIBIDO: {amount} de {client_name} por {concept}"},
        {"skill": "invoice_generate", "condition": "if config.auto_invoice", "input": "generate_receipt_for_payment"}
      ]
    }
  },
  "config_schema": {
    "stripe_key": {"type": "string", "required": true, "sensitive": true},
    "currency": {"type": "string", "default": "USD"},
    "success_url": {"type": "string", "default": ""},
    "cancel_url": {"type": "string", "default": ""},
    "notify_on_payment": {"type": "boolean", "default": true},
    "auto_invoice": {"type": "boolean", "default": false}
  }
}
```

---
*Automatización A-19 — Payment Links — Diseñada 2026-03-07*
