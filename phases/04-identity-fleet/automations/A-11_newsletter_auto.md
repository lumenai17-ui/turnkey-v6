# A-11: Newsletter Auto

**Categoría:** Web Content | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Newsletter semanal automático con contenido curado: el agente busca noticias relevantes del nicho, las resume, genera un email atractivo con template profesional, y lo envía a la lista de suscriptores.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Listmonk (open source) | ✅ Gestión de listas + templates HTML |
| Buttondown | ✅ Simplicidad: escribir → enviar |
| Mailchimp automation | ✅ Segmentación básica de audiencia |
| n8n Newsletter workflow | ✅ Cron → research → write → send |

---

## 🔄 Workflow

```
TRIGGER: [cron] → cada martes 9am (configurable)
   │
   ├── PASO 1: web_search → Buscar noticias/contenido relevante
   ├── PASO 2: summarize → Resumir 5-7 artículos top
   ├── PASO 3: rewrite → Escribir newsletter con tono de marca
   ├── PASO 4: email_templates → Ensamblar HTML con template
   ├── PASO 5: newsletter_send → Enviar a lista de suscriptores
   └── PASO 6: email_tracking → Registrar métricas
```

## 📝 Receta

```json
{
  "automation_id": "A-11",
  "name": "newsletter_auto",
  "version": "1.0.0",
  "skills_required": ["cron", "web_search", "summarize", "rewrite", "email_templates", "newsletter_send", "email_tracking"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 40,
  "steps": [
    {
      "step": 1, "skill": "web_search",
      "action": "Buscar contenido relevante del nicho",
      "input": {"queries": "{config.content_topics}", "num_results": 10, "time_filter": "past_week"},
      "output": "articles[]",
      "on_error": {"action": "use_cached", "fallback": "Usar temas pre-escritos"}
    },
    {
      "step": 2, "skill": "summarize",
      "action": "Resumir los mejores artículos",
      "input": {"articles": "{step_1.articles}", "max_items": 5, "summary_length": "2-3 oraciones"},
      "output": "curated_content[]",
      "on_error": {"action": "retry", "max_retries": 1}
    },
    {
      "step": 3, "skill": "rewrite",
      "action": "Escribir newsletter con tono de marca",
      "input": {
        "content": "{step_2.curated_content}",
        "tone": "{config.brand_tone}",
        "sections": ["intro_personal", "curated_articles", "tip_of_week", "cta"]
      },
      "output": "newsletter_body",
      "on_error": {"action": "retry", "max_retries": 1}
    },
    {
      "step": 4, "skill": "email_templates",
      "action": "Insertar en template HTML",
      "input": {"content": "{step_3.newsletter_body}", "template": "{config.template}"},
      "output": "newsletter_html",
      "on_error": {"action": "plaintext", "fallback": "Enviar como texto plano"}
    },
    {
      "step": 5, "skill": "newsletter_send",
      "action": "Enviar a toda la lista",
      "input": {
        "html": "{step_4.newsletter_html}",
        "subject": "{step_3.subject_line}",
        "subscriber_list": "{config.subscriber_list}",
        "from": "{config.from_email}"
      },
      "output": "send_results{sent, bounced, errors}",
      "on_error": {"action": "queue_and_retry"}
    },
    {
      "step": 6, "skill": "email_tracking",
      "action": "Registrar métricas",
      "input": {"campaign_id": "auto", "sent_count": "{step_5.sent}"},
      "output": "tracking_id"
    }
  ],
  "config_schema": {
    "frequency": {"type": "string", "default": "weekly"},
    "send_day": {"type": "string", "default": "tuesday"},
    "send_time": {"type": "string", "default": "09:00"},
    "content_topics": {"type": "array", "description": "Temas a buscar cada semana"},
    "subscriber_list": {"type": "string", "default": "data/subscribers.csv"},
    "template": {"type": "string", "default": "newsletter_modern"},
    "brand_tone": {"type": "string", "default": "profesional y cercano"},
    "from_email": {"type": "string"},
    "include_unsubscribe": {"type": "boolean", "default": true}
  }
}
```

## 🤖 Prompt — Escribir newsletter

```
Escribe un newsletter semanal para {business_name}.
Tono: {brand_tone}

CONTENIDO CURADO:
{curated_content_json}

ESTRUCTURA:
1. INTRO (3-4 líneas personales, saludo, contexto de la semana)
2. ARTÍCULOS CURADOS (5 items):
   - Título clickeable
   - Resumen 2-3 líneas
   - Por qué importa al lector
3. TIP DE LA SEMANA (algo útil y accionable)
4. CTA (invitar a responder, compartir, o tomar acción)

También genera:
- subject_line: Max 50 chars, que genere curiosidad
- preview_text: Max 90 chars para preview en inbox

Responde en JSON: {subject_line, preview_text, intro, articles[], tip, cta}
```

---
*Automatización A-11 — Newsletter Auto — Diseñada 2026-03-07*
