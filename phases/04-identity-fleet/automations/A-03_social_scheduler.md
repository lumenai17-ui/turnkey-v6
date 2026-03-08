# A-03: Social Scheduler

**Categoría:** Marketing | **Fase:** F5 | **Complejidad:** 🔴 Alta
**Status:** Diseñada | **APIs externas:** Meta API, LinkedIn API

---

## 📋 Resumen

Programa y publica contenido en redes sociales automáticamente. El agente mantiene un calendario de publicaciones y las publica a las horas óptimas usando las APIs de cada plataforma.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| Buffer / Hootsuite | ✅ Calendario de contenido + scheduling |
| Postiz (open source) | ✅ Self-hosted social scheduling |
| Later.com | ✅ Horarios óptimos por plataforma |

---

## 🔄 Workflow

```
TRIGGER: [cron] → a la hora programada
   │     "Programa este post para mañana a las 9am"
   │
   ├── PASO 1: extract_data → Obtener posts programados para ahora
   ├── PASO 2: image_generate → Ajustar imagen al formato de plataforma (si necesario)
   ├── PASO 3: webhook → Publicar via API de cada plataforma
   │   ├── Instagram: Meta Graph API → crear media container → publish
   │   ├── Facebook: Graph API → page/feed POST
   │   └── LinkedIn: LinkedIn API → ugcPosts POST
   ├── PASO 4: email_tracking → Registrar publicación
   └── PASO 5: notifications → Confirmar al dueño
```

## 📝 Receta

```json
{
  "automation_id": "A-3",
  "name": "social_scheduler",
  "version": "1.0.0",
  "skills_required": ["cron", "extract_data", "webhook", "image_generate", "rewrite", "notifications"],
  "estimated_cost_per_run": 0.00,
  "estimated_duration_seconds": 15,
  "external_api_setup": {
    "meta_graph_api": {
      "required_tokens": ["page_access_token", "instagram_business_account_id"],
      "permissions": ["pages_manage_posts", "instagram_basic", "instagram_content_publish"]
    },
    "linkedin_api": {
      "required_tokens": ["access_token", "organization_id"],
      "permissions": ["w_organization_social"]
    }
  },
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Obtener posts programados",
      "input": {"source": "data/scheduled_posts.json", "filter": "scheduled_at <= now AND status == pending"},
      "output": "posts_to_publish[]"
    },
    {
      "step": 2, "skill": "webhook",
      "action": "Publicar en plataforma correspondiente",
      "input": {"post": "{post}", "platform": "{post.platform}", "api_config": "{config}"},
      "output": "post_url, post_id",
      "loop": "for_each post",
      "on_error": {"action": "queue_retry", "retry_in": "30min"}
    },
    {
      "step": 3, "skill": "notifications",
      "action": "Confirmar publicación",
      "input": {"message": "✅ Post publicado en {platform}: {post_url}"},
      "output": "confirmed"
    }
  ],
  "config_schema": {
    "schedule": {"type": "string", "default": "09:00,13:00,18:00"},
    "timezone": {"type": "string", "default": "America/Bogota"},
    "platforms": {"type": "array", "default": ["instagram", "facebook"]},
    "auto_publish": {"type": "boolean", "default": false},
    "optimal_times": {
      "instagram": ["09:00", "12:00", "18:00"],
      "facebook": ["09:00", "13:00", "16:00"],
      "linkedin": ["08:00", "12:00", "17:00"]
    }
  }
}
```

---
*Automatización A-03 — Social Scheduler — Diseñada 2026-03-07*
