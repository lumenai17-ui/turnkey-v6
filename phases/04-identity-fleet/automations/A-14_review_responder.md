# A-14: Review Responder

**Categoría:** Operaciones | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Detecta reseñas nuevas en Google, Yelp y TripAdvisor via scraping, analiza el sentimiento, genera respuestas profesionales personalizadas, y notifica al dueño. Las respuestas negativas se escalan automáticamente.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Birdeye (SaaS) | ✅ Detección multi-plataforma + respuesta sugerida |
| ReviewTrackers | ✅ Clasificación por sentimiento + alertas |
| GatherUp | ✅ Templates de respuesta adaptables |
| n8n + Google Business API | ❌ API requiere verificación — preferimos scraping |

---

## 🔄 Workflow

```
TRIGGER: [cron] → cada 6h
   │
   ├── PASO 1: scraping → Buscar reseñas nuevas en plataformas
   ├── PASO 2: sentiment → Analizar sentimiento de cada reseña
   ├── PASO 3: rewrite → Generar respuesta personalizada
   ├── PASO 4: notifications → Notificar al dueño
   │   └── Si negativa → 🔴 ALERTA URGENTE
   └── PASO 5: Guardar en historial
```

## 📝 Receta

```json
{
  "automation_id": "A-14",
  "name": "review_responder",
  "version": "1.0.0",
  "skills_required": ["scraping", "sentiment", "rewrite", "cron", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 20,
  "steps": [
    {
      "step": 1, "skill": "scraping",
      "action": "Buscar reseñas nuevas",
      "input": {"platforms": "{config.platforms}", "business_name": "{config.business_name}"},
      "output": "new_reviews[]",
      "on_error": {"action": "partial", "fallback": "Revisar plataformas que respondan"}
    },
    {
      "step": 2, "skill": "sentiment",
      "action": "Analizar sentimiento",
      "input": {"reviews": "{step_1.new_reviews}"},
      "output": "reviews_with_sentiment[]{text, rating, sentiment, emotions}",
      "on_error": {"action": "classify_by_stars"}
    },
    {
      "step": 3, "skill": "rewrite",
      "action": "Generar respuestas personalizadas",
      "input": {
        "reviews": "{step_2.reviews_with_sentiment}",
        "tone": "{config.response_tone}",
        "business_name": "{config.business_name}"
      },
      "output": "suggested_responses[]",
      "on_error": {"action": "template", "fallback": "Usar template genérico por sentimiento"}
    },
    {
      "step": 4, "skill": "notifications",
      "action": "Notificar al dueño",
      "input": {
        "channels": "{config.notify_channels}",
        "reviews": "{step_2.reviews_with_sentiment}",
        "responses": "{step_3.suggested_responses}",
        "urgency": "based_on_sentiment"
      },
      "output": "notifications_sent"
    },
    {
      "step": 5, "skill": "none",
      "action": "Guardar en historial",
      "input": {"reviews": "{step_2}", "responses": "{step_3}", "timestamp": "now"},
      "output": "logged"
    }
  ],
  "config_schema": {
    "platforms": {"type": "array", "default": ["google"]},
    "business_name": {"type": "string"},
    "check_interval": {"type": "string", "default": "6h"},
    "auto_respond": {"type": "boolean", "default": false, "description": "Si true, publica la respuesta automáticamente"},
    "response_tone": {"type": "string", "default": "professional_friendly"},
    "notify_channels": {"type": "array", "default": ["email", "telegram"]},
    "escalate_negative": {"type": "boolean", "default": true}
  }
}
```

## 🤖 Prompt — Generar respuesta a reseña

```
Genera una respuesta profesional a esta reseña de {platform}.

NEGOCIO: {business_name}
RESEÑA: "{review_text}"
RATING: {stars}/5
SENTIMIENTO: {sentiment}
TONO: {response_tone}

REGLAS:
- Si positiva: agradecer, mencionar algo específico de la reseña, invitar a volver
- Si neutral: agradecer, ofrecer mejorar, invitar a contactar
- Si negativa: disculparse, reconocer el problema, ofrecer solución, dar contacto directo
- Máximo 100 palabras
- Firma: Equipo {business_name}

Responde SOLO con la respuesta, sin explicaciones.
```

---
*Automatización A-14 — Review Responder — Diseñada 2026-03-07*
