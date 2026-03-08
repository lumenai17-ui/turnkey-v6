# A-12: Invoice Autopilot

**Categoría:** Operaciones | **Fase:** F4 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Facturación automática recurrente. El agente lee la lista de clientes, genera facturas PDF profesionales con datos calculados (subtotal, impuestos, total), y las envía por email automáticamente según el ciclo de facturación configurado.

---

## 🔍 Investigación — Qué existe

| Herramienta | Qué hace | Qué adoptamos |
|---|---|---|
| InvoiceNinja (open source) | Facturación completa + 40 payment gateways + PDF | ✅ Estructura de datos de factura (items, tax, totals) |
| InvoicePlane (open source) | Self-hosted invoicing + templates | ✅ Templates de PDF personalizables |
| UniBee | Subscription billing + PDF generation | ✅ Lógica de recurrencia (monthly, biweekly) |
| Simple Invoices | Sales reports + PDF export | ✅ Simplicidad del flujo |

**Diferenciador nuestro:** No es un sistema de facturación standalone — es una automatización del agente que genera y envía facturas como parte de su flujo natural. El cliente dice "factura a Juan" y el agente lo hace. O se ejecuta solo en el ciclo programado.

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────┐
│              A-12: INVOICE AUTOPILOT                      │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  TRIGGER: [cron] → billing_cycle (mensual por default)    │
│     │     "Factura a {cliente} por {concepto}"            │
│     │     "Genera factura #{número}"                      │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 1: Cargar datos de clientes            │          │
│  │ skill: extract_data                         │          │
│  │ Leer: data/clients.json                     │          │
│  │ Filtrar: clientes con billing activo         │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 2: Calcular montos                     │          │
│  │ skill: extract_data                         │          │
│  │ Subtotal + impuestos + descuentos = total   │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 3: Generar factura PDF                 │          │
│  │ skill: invoice_generate                     │          │
│  │ Template HTML → wkhtmltopdf → PDF           │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 4: Enviar por email                    │          │
│  │ skill: email_send                           │          │
│  │ Adjuntar PDF + cuerpo profesional           │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 5: Registrar en log                    │          │
│  │ Guardar en historial de facturas            │          │
│  └──────────────────────────────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Receta (JSON)

```json
{
  "automation_id": "A-12",
  "name": "invoice_autopilot",
  "version": "1.0.0",
  "skills_required": ["extract_data", "invoice_generate", "pdf_generate", "email_send", "cron"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 10,
  "steps": [
    {
      "step": 1,
      "skill": "extract_data",
      "action": "Cargar y filtrar clientes",
      "input": {"source": "{config.clients_file}", "filter": "billing_active == true"},
      "output": "clients[]",
      "on_error": {"action": "abort", "message": "No se pudo leer el archivo de clientes"}
    },
    {
      "step": 2,
      "skill": "extract_data",
      "action": "Calcular montos por cliente",
      "input": {
        "client": "{client}",
        "items": "{client.line_items}",
        "tax_rate": "{config.tax_rate}",
        "currency": "{config.currency}"
      },
      "output": "subtotal, tax_amount, total, due_date",
      "loop": "for_each client in clients",
      "on_error": {"action": "skip_client", "fallback": "Notificar que no se pudo facturar a {client.name}"}
    },
    {
      "step": 3,
      "skill": "invoice_generate",
      "action": "Generar factura PDF",
      "input": {
        "template": "{config.invoice_template}",
        "invoice_number": "auto_increment",
        "client": "{client}",
        "items": "{client.line_items}",
        "subtotal": "{step_2.subtotal}",
        "tax": "{step_2.tax_amount}",
        "total": "{step_2.total}",
        "due_date": "{step_2.due_date}",
        "company_info": "{config.company_info}"
      },
      "output": "invoice_pdf_path",
      "on_error": {"action": "retry", "max_retries": 1}
    },
    {
      "step": 4,
      "skill": "email_send",
      "action": "Enviar factura por email",
      "input": {
        "to": "{client.email}",
        "subject": "Factura #{invoice_number} — {config.company_info.name}",
        "body_template": "invoice_email",
        "attachments": ["{step_3.invoice_pdf_path}"]
      },
      "output": "email_sent_status",
      "guard": "{config.auto_send}",
      "on_error": {"action": "queue", "fallback": "Guardar en cola y reintentar en 1h"}
    },
    {
      "step": 5,
      "skill": "none",
      "action": "Registrar en historial",
      "input": {
        "invoice_number": "{step_3.invoice_number}",
        "client": "{client.name}",
        "total": "{step_2.total}",
        "sent_at": "now",
        "status": "sent"
      },
      "output": "log_entry"
    }
  ],
  "config_schema": {
    "billing_cycle": {"type": "string", "default": "monthly", "enum": ["weekly", "biweekly", "monthly", "quarterly"]},
    "due_days": {"type": "integer", "default": 30},
    "currency": {"type": "string", "default": "USD"},
    "tax_rate": {"type": "number", "default": 0.19},
    "auto_send": {"type": "boolean", "default": true},
    "clients_file": {"type": "string", "default": "data/clients.json"},
    "invoice_template": {"type": "string", "default": "professional_blue"},
    "company_info": {
      "type": "object",
      "properties": {
        "name": {"type": "string"},
        "address": {"type": "string"},
        "tax_id": {"type": "string"},
        "logo_path": {"type": "string"},
        "email": {"type": "string"},
        "phone": {"type": "string"}
      }
    }
  },
  "client_data_schema": {
    "name": "string",
    "email": "string",
    "company": "string",
    "tax_id": "string",
    "address": "string",
    "billing_active": "boolean",
    "line_items": [
      {"description": "string", "quantity": "number", "unit_price": "number"}
    ]
  }
}
```

---

## 🤖 Prompts de IA

### Prompt — Email de factura (template)

```html
Asunto: Factura #{number} — {company_name}

Estimado/a {client_name},

Adjunto encontrará la factura #{number} correspondiente a {billing_period}.

Resumen:
- Subtotal: {currency} {subtotal}
- Impuestos ({tax_rate}%): {currency} {tax_amount}
- TOTAL: {currency} {total}

Fecha de vencimiento: {due_date}

Si tiene alguna pregunta sobre esta factura, no dude en contactarnos.

Saludos cordiales,
{company_name}
{company_phone} | {company_email}
```

> **Nota:** Esta automatización es mayormente lógica (cálculos + templates), no requiere prompts de IA extensos. Los cálculos son determinísticos.

---

## ⚠️ Error Handling

| Paso | Qué puede fallar | Qué hacer |
|---|---|---|
| 1 Cargar | Archivo de clientes no existe | Abortar + notificar admin |
| 1 Cargar | JSON malformado | Abortar + notificar admin |
| 2 Calcular | Items sin precio | Skip cliente + notificar |
| 3 PDF | wkhtmltopdf falla | Reintentar 1x |
| 4 Email | Email del cliente inválido | Loggear error + continuar con siguientes |
| 4 Email | Postfix no disponible | Encolar para reintento en 1h |
| General | Más de 100 facturas en un ciclo | Procesar en batches de 20 |

---

## 📌 Ejemplo Completo

### Input (cron trigger mensual):
```json
// data/clients.json
[
  {
    "name": "Casa Mahana",
    "email": "admin@casamahana.com",
    "company": "Restaurante Casa Mahana",
    "billing_active": true,
    "line_items": [
      {"description": "Agente IA - Plan Pro", "quantity": 1, "unit_price": 350.00}
    ]
  }
]
```

### Output:
```
🧾 Facturación automática completada:

📊 Resumen:
- Facturas generadas: 1
- Total facturado: $416.50 USD (inc. 19% IVA)
- Enviadas: 1/1

📄 Facturas:
1. #INV-2026-0047 → Casa Mahana — $416.50 — ✅ Enviada

⏱️ Tiempo: 8s
💰 Costo: $0.00 (100% local)

Próxima facturación: 2026-04-01
```

---

*Automatización A-12 — Invoice Autopilot — Diseñada 2026-03-07*
