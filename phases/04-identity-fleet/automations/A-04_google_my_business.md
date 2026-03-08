# A-04: Google My Business Manager

**Categoría:** Marketing | **Fase:** F5 | **Complejidad:** 🔴 Alta
**Status:** Diseñada | **APIs externas:** Google Business Profile API

---

## 📋 Resumen

Gestiona el perfil de Google Business del cliente: responde reseñas automáticamente, actualiza información del negocio, sube fotos, y crea posts/promociones. Mantiene la presencia de Google activa y optimizada.

---

## 🔄 Workflow

```
TRIGGER: [cron] → cada 6h (revisar reseñas + actualizar)
   │     "Actualiza el horario del negocio en Google"
   │
   ├── PASO 1: scraping → Obtener reseñas nuevas (o API si disponible)
   ├── PASO 2: sentiment → Analizar sentimiento de reseñas
   ├── PASO 3: rewrite → Generar respuestas personalizadas
   ├── PASO 4: browser → Publicar respuestas via API/browser
   ├── PASO 5: image_generate → Crear post para GMB (si programado)
   └── PASO 6: notifications → Alertar si hay reseña negativa
```

## 📝 Receta

```json
{
  "automation_id": "A-4",
  "name": "google_my_business",
  "version": "1.0.0",
  "skills_required": ["scraping", "sentiment", "rewrite", "browser", "image_generate", "notifications"],
  "estimated_cost_per_run": 0.01,
  "estimated_duration_seconds": 25,
  "external_api_setup": {
    "google_business_api": {
      "auth": "OAuth 2.0",
      "required": ["account_id", "location_id"],
      "permissions": ["business.manage"],
      "note": "Requiere verificación del negocio en Google. Si API no disponible, usamos browser automation (Puppeteer) como fallback"
    }
  },
  "steps": [
    {
      "step": 1, "skill": "scraping",
      "action": "Obtener reseñas nuevas",
      "input": {"url": "google.com/maps/place/{business_id}", "type": "reviews"},
      "output": "new_reviews[]",
      "on_error": {"action": "try_api", "fallback": "Usar Google Business API si scraping falla"}
    },
    {
      "step": 2, "skill": "sentiment",
      "action": "Analizar sentimiento",
      "input": {"reviews": "{step_1.new_reviews}"},
      "output": "reviews_analyzed[]"
    },
    {
      "step": 3, "skill": "rewrite",
      "action": "Generar respuestas",
      "input": {"reviews": "{step_2.reviews_analyzed}", "tone": "{config.response_tone}"},
      "output": "responses[]"
    },
    {
      "step": 4, "skill": "browser",
      "action": "Publicar respuestas en Google",
      "input": {"responses": "{step_3.responses}", "method": "api_or_browser"},
      "output": "responses_posted",
      "guard": "{config.auto_respond_reviews}",
      "on_error": {"action": "save_draft", "fallback": "Guardar como borrador para aprobación manual"}
    }
  ],
  "config_schema": {
    "business_id": {"type": "string", "required": true},
    "auto_respond_reviews": {"type": "boolean", "default": false},
    "review_check_interval": {"type": "string", "default": "6h"},
    "response_tone": {"type": "string", "default": "professional_friendly"},
    "post_frequency": {"type": "string", "default": "weekly"}
  }
}
```

---
*Automatización A-04 — Google My Business Manager — Diseñada 2026-03-07*
