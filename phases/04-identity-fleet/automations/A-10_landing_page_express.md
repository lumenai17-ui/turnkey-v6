# A-10: Landing Page Express

**Categoría:** Web Content | **Fase:** F4 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Crea landing pages profesionales en minutos desde una descripción en lenguaje natural. El agente genera el HTML+CSS, las imágenes, el formulario de captura, y publica vía Cloudflare Tunnel. El usuario solo describe qué necesita y el agente entrega una landing funcional.

---

## 🔍 Investigación — Qué existe

| Herramienta | Qué hace | Qué adoptamos |
|---|---|---|
| Unbounce / Leadpages | Landing builders drag-and-drop | ✅ Estructura de secciones estándar (hero, beneficios, CTA, form) |
| v0.dev / bolt.new | AI genera código de UI desde prompt | ✅ El concepto de "describe y genera" |
| Carrd.co | One-page sites simples | ✅ La simplicidad — una página, un objetivo |
| Hugo / Jekyll templates | Static site generators con templates | ✅ Templates base que se personalizan |

**Diferenciador nuestro:** Generación completa (HTML + CSS + imagen + form + deploy) sin salir del chat. Costo: ~$0.02 por landing (solo la imagen con SD).

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────┐
│             A-10: LANDING PAGE EXPRESS                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  TRIGGER: "Crea una landing page para {descripción}"      │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 1: Analizar requerimientos             │          │
│  │ skill: extract_data                         │          │
│  │ Extraer: negocio, objetivo, público, CTA    │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 2: Generar copy de la landing          │          │
│  │ skill: rewrite                              │          │
│  │ Secciones: hero, beneficios, social proof,  │          │
│  │            CTA, footer                       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 3: Generar imagen hero                 │          │
│  │ skill: image_generate                       │          │
│  │ Imagen principal para la sección hero       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 4: Crear formulario de captura         │          │
│  │ skill: form_create                          │          │
│  │ Campos: nombre, email, teléfono (config)    │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 5: Ensamblar HTML + CSS                │          │
│  │ skill: web_create                           │          │
│  │ Template + copy + imagen + form = landing   │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 6: Publicar (opcional)                 │          │
│  │ skill: web_create (deploy)                  │          │
│  │ Via Cloudflare Tunnel → URL pública         │          │
│  └──────────────────────────────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Receta (JSON)

```json
{
  "automation_id": "A-10",
  "name": "landing_page_express",
  "version": "1.0.0",
  "skills_required": ["extract_data", "rewrite", "image_generate", "form_create", "web_create"],
  "estimated_cost_per_run": 0.02,
  "estimated_duration_seconds": 30,
  "steps": [
    {
      "step": 1,
      "skill": "extract_data",
      "action": "Analizar requerimientos del usuario",
      "input": {"text": "{user_request}"},
      "output": "business_name, objective, target_audience, cta_text, color_scheme",
      "on_error": {"action": "ask_user", "message": "¿Cuál es el objetivo de la landing?"}
    },
    {
      "step": 2,
      "skill": "rewrite",
      "action": "Generar todo el copy de la landing",
      "input": {"business": "{step_1.business_name}", "objective": "{step_1.objective}", "audience": "{step_1.target_audience}"},
      "output": "sections{hero_headline, hero_subtitle, benefits[], social_proof, cta_text, cta_secondary}",
      "on_error": {"action": "retry", "max_retries": 2}
    },
    {
      "step": 3,
      "skill": "image_generate",
      "action": "Generar imagen hero",
      "input": {"prompt": "hero_image_from_context", "dimensions": "1920x1080"},
      "output": "hero_image_path",
      "on_error": {"action": "skip", "fallback": "Usar gradiente CSS como hero background"}
    },
    {
      "step": 4,
      "skill": "form_create",
      "action": "Crear formulario de captura",
      "input": {"fields": "{config.form_fields}", "action_url": "{config.webhook_url}"},
      "output": "form_html",
      "on_error": {"action": "default", "fallback": "Formulario básico nombre+email"}
    },
    {
      "step": 5,
      "skill": "web_create",
      "action": "Ensamblar landing page completa",
      "input": {
        "template": "{config.template}",
        "copy": "{step_2.sections}",
        "hero_image": "{step_3.hero_image_path}",
        "form": "{step_4.form_html}",
        "colors": "{step_1.color_scheme}"
      },
      "output": "landing_html_path",
      "on_error": {"action": "retry", "max_retries": 1}
    },
    {
      "step": 6,
      "skill": "web_create",
      "action": "Publicar vía Cloudflare Tunnel",
      "input": {"html_path": "{step_5.landing_html_path}", "subdomain": "{config.subdomain}"},
      "output": "public_url",
      "confirm_with_user": true,
      "on_error": {"action": "skip", "fallback": "Entregar archivo HTML sin publicar"}
    }
  ],
  "config_schema": {
    "template": {"type": "string", "default": "modern_clean", "enum": ["modern_clean", "bold_gradient", "minimal_white", "dark_premium"]},
    "form_fields": {"type": "array", "default": ["name", "email", "phone"]},
    "webhook_url": {"type": "string", "default": "", "description": "URL para recibir submissions del form"},
    "subdomain": {"type": "string", "default": "", "description": "Subdominio para publicación"},
    "include_analytics": {"type": "boolean", "default": true},
    "include_whatsapp_button": {"type": "boolean", "default": true}
  }
}
```

---

## 🤖 Prompts de IA

### Prompt — Paso 1: Extraer requerimientos

```
Analiza esta solicitud de landing page y extrae:
1. Nombre del negocio
2. Objetivo (captar leads, vender, informar, evento)
3. Público objetivo
4. CTA principal (texto del botón)
5. Esquema de colores sugerido (2-3 colores HEX)
6. Secciones necesarias

Solicitud: "{user_request}"

Responde en JSON:
{
  "business_name": "...",
  "objective": "...",
  "target_audience": "...",
  "cta_text": "...",
  "color_scheme": {"primary": "#...", "secondary": "#...", "accent": "#..."},
  "sections_needed": ["hero", "benefits", "social_proof", "form", "footer"]
}
```

### Prompt — Paso 2: Generar copy

```
Genera el copy completo para una landing page.

NEGOCIO: {business_name}
OBJETIVO: {objective}
PÚBLICO: {target_audience}
IDIOMA: español

Genera CADA sección:

1. HERO:
   - Headline: Max 10 palabras, impactante, incluir beneficio principal
   - Subtitle: Max 25 palabras, complementa el headline
   
2. BENEFICIOS (3-4):
   - Cada uno con: emoji + título corto + descripción (1 línea)

3. SOCIAL PROOF:
   - 2-3 testimonios ficticios pero realistas (nombre, rol, texto corto)

4. CTA SECTION:
   - Headline de cierre urgente
   - Texto del botón principal
   - Texto secundario debajo del botón (ej: "Sin compromiso")

Responde en JSON estructurado.
```

### Prompt — Paso 3: Imagen hero (Stable Diffusion)

```
professional hero banner image for {business_type} landing page,
{objective} theme, modern web design style,
color palette {primary_color} {secondary_color},
wide panoramic composition, no text, no logos,
clean minimal background, bokeh effect,
4k quality, cinematic lighting
```

---

## ⚠️ Error Handling

| Paso | Qué puede fallar | Qué hacer |
|---|---|---|
| 1 Analizar | No se puede determinar el negocio | Preguntar al usuario |
| 2 Copy | Copy genérico / no persuasivo | Regenerar con más contexto |
| 3 Imagen | SD genera imagen irrelevante | Usar gradiente CSS como fallback |
| 4 Form | Webhook URL no configurada | Form guarda en JSON local |
| 5 Ensamblar | HTML mal formado | Validar con parser, corregir |
| 6 Publicar | Cloudflare Tunnel no disponible | Entregar archivo .html |

---

## 📌 Ejemplo Completo

### Input:
> "Crea una landing para mi clínica dental Dr. Sonrisas, queremos captar pacientes para limpieza dental con descuento"

### Output:
```
🌐 Landing Page lista:

📸 Hero: "Tu Sonrisa Perfecta Comienza Hoy"
📝 Subtítulo: "Limpieza dental profesional con 30% de descuento..."
✅ 4 beneficios
⭐ 3 testimonios
📋 Formulario: nombre + email + teléfono
🔗 URL: https://dr-sonrisas.tunneled.site

💰 Costo: $0.02
⏱️ Tiempo: 25s

¿La publico o quieres editarla primero?
```

---

*Automatización A-10 — Landing Page Express — Diseñada 2026-03-07*
