# A-01: Meta Ads Manager

**Categoría:** Marketing | **Fase:** F5 | **Complejidad:** 🔴 Alta
**Status:** Diseñada | **APIs externas:** Meta Marketing API

---

## 📋 Resumen

Gestión completa de campañas en Meta (Facebook/Instagram): crear campañas, subir creativos generados con IA, leer métricas de performance, y optimizar basado en resultados. El agente actúa como un media buyer automatizado.

---

## 🔍 Investigación

| Herramienta existente | Qué adoptamos |
|---|---|
| n8n Meta Ads nodes | ✅ Estructura de API calls: campaign → adset → ad |
| AdEspresso | ✅ A/B testing de creativos automático |
| Revealbot | ✅ Rules-based optimization (stop underperforming ads) |
| Facebook Marketing API docs | ✅ Endpoints y flow de creación de ads |

---

## 🔄 Workflow

```
TRIGGER: "Crea una campaña en Facebook/Instagram"
   │     [cron] → revisar métricas diariamente
   │
   ├── PASO 1: extract_data → Extraer objetivo, público, presupuesto
   ├── PASO 2: image_generate → Crear creativos (2-3 variantes)
   ├── PASO 3: rewrite → Generar copy del ad (headline + body + CTA)
   ├── PASO 4: browser → Crear campaña via Meta Marketing API
   │   ├── 4a: Crear Campaign (objetivo)
   │   ├── 4b: Crear AdSet (público + presupuesto + schedule)
   │   └── 4c: Crear Ad (creativo + copy)
   ├── PASO 5: report_generate → Reporte de performance (si cron)
   └── PASO 6: Optimizar (pausar ads malos, escalar buenos)
```

## 📝 Receta

```json
{
  "automation_id": "A-1",
  "name": "meta_ads_manager",
  "version": "1.0.0",
  "skills_required": ["extract_data", "image_generate", "rewrite", "browser", "scraping", "report_generate"],
  "estimated_cost_per_run": 0.03,
  "estimated_duration_seconds": 45,
  "external_api_setup": {
    "meta_marketing_api": {
      "auth": "OAuth 2.0",
      "required_tokens": ["access_token", "ad_account_id"],
      "permissions": ["ads_management", "ads_read", "business_management"],
      "setup_guide": "El cliente debe crear una app en developers.facebook.com y darnos el access_token",
      "rate_limits": "200 calls/hour per ad account"
    }
  },
  "steps": [
    {
      "step": 1, "skill": "extract_data",
      "action": "Extraer parámetros de campaña",
      "input": {"request": "{user_request}"},
      "output": "objective, audience, budget, duration, platform",
      "on_error": {"action": "ask_user"}
    },
    {
      "step": 2, "skill": "image_generate",
      "action": "Crear 2-3 variantes de creativos",
      "input": {"topic": "{objective}", "format": "1080x1080 + 1080x1920", "count": 3},
      "output": "creative_images[]",
      "on_error": {"action": "skip", "fallback": "Solicitar imágenes al cliente"}
    },
    {
      "step": 3, "skill": "rewrite",
      "action": "Generar copy para cada variante",
      "input": {"objective": "{step_1.objective}", "audience": "{step_1.audience}", "variants": 3},
      "output": "ad_copies[]{headline, body, description, cta_type}",
      "on_error": {"action": "retry"}
    },
    {
      "step": 4, "skill": "browser",
      "action": "Crear campaña en Meta via API",
      "input": {
        "api_calls": [
          {"endpoint": "act_{ad_account_id}/campaigns", "method": "POST", "body": {"name": "...", "objective": "..."}},
          {"endpoint": "act_{ad_account_id}/adsets", "method": "POST", "body": {"campaign_id": "...", "targeting": "..."}},
          {"endpoint": "act_{ad_account_id}/ads", "method": "POST", "body": {"adset_id": "...", "creative": "..."}}
        ]
      },
      "output": "campaign_id, adset_id, ad_ids[]",
      "on_error": {"action": "abort", "message": "Error creando campaña en Meta: {error}"}
    },
    {
      "step": 5, "skill": "report_generate",
      "action": "Leer métricas y generar reporte",
      "input": {"campaign_id": "{campaign_id}", "metrics": ["impressions", "clicks", "ctr", "cpc", "conversions", "spend"]},
      "output": "performance_report",
      "trigger": "cron_daily"
    }
  ],
  "config_schema": {
    "meta_access_token": {"type": "string", "required": true, "sensitive": true},
    "meta_ad_account_id": {"type": "string", "required": true},
    "default_objective": {"type": "string", "default": "CONVERSIONS", "enum": ["CONVERSIONS", "TRAFFIC", "ENGAGEMENT", "REACH", "LEADS"]},
    "default_budget_daily": {"type": "number", "default": 10.00},
    "auto_optimize": {"type": "boolean", "default": false, "description": "Pausar ads con CTR < 1% automáticamente"}
  }
}
```

## 🤖 Prompt — Copy de ad (3 variantes)

```
Genera 3 variantes de copy para un ad de Facebook/Instagram.

OBJETIVO: {objective}
PÚBLICO: {audience}
PRODUCTO/SERVICIO: {product}

Por cada variante genera:
- headline: Max 40 chars, impactante
- body: Max 125 chars, beneficio + urgencia
- description: Max 30 chars, complemento
- cta_type: LEARN_MORE, SHOP_NOW, SIGN_UP, BOOK_NOW, CONTACT_US

Variante 1: Enfoque emocional
Variante 2: Enfoque de oferta/precio
Variante 3: Enfoque social proof

JSON array con las 3 variantes.
```

---
*Automatización A-01 — Meta Ads Manager — Diseñada 2026-03-07*
