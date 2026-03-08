# A-08: WordPress Publisher

**Categoría:** Web Content | **Fase:** F5 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** WordPress REST API

---

## 📋 Resumen

Publica contenido en WordPress automáticamente: crea posts, sube imágenes, asigna categorías y tags, y configura SEO metadata. Funciona como complemento de A-05 (SEO Content Creator) y A-09 (Blog Autopilot).

---

## 🔄 Workflow

```
TRIGGER: "Publica este artículo en WordPress"
   │     [webhook] → artículo aprobado para publicar
   │
   ├── PASO 1: extract_data → Preparar datos del post (title, body, category, tags)
   ├── PASO 2: image_generate → Crear featured image si no tiene
   ├── PASO 3: browser/webhook → Subir imagen a WP Media Library via API
   ├── PASO 4: browser/webhook → Crear post via WP REST API
   └── PASO 5: notifications → Confirmar publicación con URL
```

## 📝 Receta

```json
{
  "automation_id": "A-8",
  "name": "wordpress_publisher",
  "version": "1.0.0",
  "skills_required": ["extract_data", "rewrite", "image_generate", "browser", "notifications"],
  "estimated_cost_per_run": 0.01,
  "estimated_duration_seconds": 20,
  "external_api_setup": {
    "wordpress_rest_api": {
      "auth": "Application Password",
      "required": ["wp_url", "wp_user", "wp_app_password"],
      "endpoints": {
        "posts": "/wp-json/wp/v2/posts",
        "media": "/wp-json/wp/v2/media",
        "categories": "/wp-json/wp/v2/categories"
      },
      "setup_guide": "En WordPress: Users → Edit → Application Passwords → Generate"
    }
  },
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Preparar datos del post",
      "input": {"content": "{article_html}", "metadata": "{seo_metadata}"},
      "output": "title, body_html, excerpt, categories[], tags[], seo{title, description}"
    },
    {
      "step": 2, "skill": "image_generate",
      "action": "Crear featured image",
      "input": {"topic": "{title}", "style": "blog_header", "dimensions": "1200x630"},
      "output": "featured_image_path",
      "condition": "only_if no featured_image provided"
    },
    {
      "step": 3, "skill": "browser",
      "action": "Subir imagen y crear post via WP REST API",
      "input": {
        "api_calls": [
          {"endpoint": "{wp_url}/wp-json/wp/v2/media", "method": "POST", "body": "featured_image"},
          {"endpoint": "{wp_url}/wp-json/wp/v2/posts", "method": "POST", "body": {"title": "...", "content": "...", "status": "{config.default_status}", "featured_media": "..."}}
        ]
      },
      "output": "post_url, post_id"
    },
    {
      "step": 4, "skill": "notifications",
      "action": "Confirmar publicación",
      "input": {"message": "📝 Post publicado: {post_url}\nStatus: {status}"},
      "output": "confirmed"
    }
  ],
  "config_schema": {
    "wp_url": {"type": "string", "required": true},
    "wp_user": {"type": "string", "required": true},
    "wp_app_password": {"type": "string", "required": true, "sensitive": true},
    "default_category": {"type": "string", "default": "Blog"},
    "default_status": {"type": "string", "default": "draft", "enum": ["draft", "publish", "pending"]}
  }
}
```

---
*Automatización A-08 — WordPress Publisher — Diseñada 2026-03-07*
