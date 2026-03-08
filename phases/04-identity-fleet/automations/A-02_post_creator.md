# A-02: Post Creator

**Categoría:** Marketing | **Fase:** F4 | **Complejidad:** 🟢 Baja
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Crea contenido visual completo para redes sociales: **imagen generada con IA + copy optimizado + hashtags**. El usuario solo dice "crea un post sobre X" y el agente entrega todo listo para publicar.

---

## 🔍 Investigación — Qué existe

| Herramienta | Qué hace | Qué adoptamos |
|---|---|---|
| Langchain Social Media Agent | Scrape URL → marketing report → posts para Twitter/LinkedIn | ✅ El concepto de generar copy específico por plataforma |
| n8n Social Media Templates | GPT-4 → contenido + hashtags + CTAs + emojis por plataforma | ✅ La estructura de prompt con CTAs y emojis opcionales |
| Open Content Generator | Genera posts para LinkedIn/Reddit/X desde una interfaz | ✅ La idea de formatos adaptados por red social |
| Auto Social Media Content Generator | OpenAI texto + Canva imágenes + scheduler | ❌ Canva no aplica — usamos Stable Diffusion |

**Diferenciador nuestro:** Todo con nuestros skills (Ollama Cloud + Stable Diffusion), sin depender de OpenAI ni Canva. Costo por post: ~$0.02 (vs ~$0.10 con OpenAI+DALL-E).

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────┐
│                  A-02: POST CREATOR                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  TRIGGER: "Crea un post sobre {tema}"                     │
│     │     "Post para Instagram de {producto}"             │
│     │     [cron] → genera post automático diario          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 1: Analizar contexto                   │          │
│  │ skill: classify                             │          │
│  │ Determinar: plataforma, tono, formato       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 2: Generar copy                        │          │
│  │ skill: rewrite                              │          │
│  │ Input: tema + plataforma + tono marca       │          │
│  │ Output: copy optimizado para la red         │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 3: Generar hashtags                    │          │
│  │ skill: summarize                            │          │
│  │ Input: copy + tema + plataforma             │          │
│  │ Output: 10-15 hashtags relevantes           │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 4: Generar imagen                      │          │
│  │ skill: image_generate                       │          │
│  │ Input: tema + colores marca + estilo        │          │
│  │ Output: imagen 1080x1080 (IG) ó 1200x630   │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 5: Ensamblar y entregar                │          │
│  │ Combinar: imagen + copy + hashtags          │          │
│  │ Preguntar: ¿Publicar, editar o descartar?   │          │
│  └──────────────────────────────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Receta (JSON)

```json
{
  "automation_id": "A-2",
  "name": "post_creator",
  "version": "1.0.0",
  "skills_required": ["classify", "rewrite", "summarize", "image_generate"],
  "estimated_cost_per_run": 0.02,
  "estimated_duration_seconds": 15,
  "steps": [
    {
      "step": 1,
      "skill": "classify",
      "action": "Analizar contexto del post",
      "input": {
        "text": "{user_request}",
        "categories": ["instagram", "facebook", "linkedin", "twitter", "tiktok", "general"]
      },
      "output": "platform, tone, format_type",
      "on_error": {
        "action": "default",
        "fallback": {"platform": "instagram", "tone": "casual", "format_type": "square"}
      }
    },
    {
      "step": 2,
      "skill": "rewrite",
      "action": "Generar copy optimizado",
      "input": {
        "topic": "{tema}",
        "platform": "{step_1.platform}",
        "brand_tone": "{config.brand_tone}",
        "max_length": "{platform_limits[platform]}"
      },
      "output": "copy_text",
      "on_error": {
        "action": "retry",
        "max_retries": 2,
        "fallback": "Generar copy genérico sin optimización de plataforma"
      }
    },
    {
      "step": 3,
      "skill": "summarize",
      "action": "Generar hashtags relevantes",
      "input": {
        "text": "{step_2.copy_text}",
        "topic": "{tema}",
        "platform": "{step_1.platform}",
        "count": 15
      },
      "output": "hashtags_list",
      "on_error": {
        "action": "skip",
        "fallback": "Entregar post sin hashtags"
      }
    },
    {
      "step": 4,
      "skill": "image_generate",
      "action": "Crear visual del post",
      "input": {
        "prompt": "constructed_from_template",
        "style": "{config.visual_style}",
        "dimensions": "{platform_dimensions[platform]}",
        "brand_colors": "{config.brand_colors}"
      },
      "output": "image_path",
      "on_error": {
        "action": "retry",
        "max_retries": 1,
        "fallback": "Entregar post solo con copy (sin imagen)"
      }
    },
    {
      "step": 5,
      "skill": "none",
      "action": "Ensamblar y presentar resultado",
      "input": {
        "copy": "{step_2.copy_text}",
        "hashtags": "{step_3.hashtags_list}",
        "image": "{step_4.image_path}"
      },
      "output": "complete_post",
      "confirm_with_user": true
    }
  ],
  "config_schema": {
    "brand_tone": {"type": "string", "default": "profesional y amigable", "description": "Tono de la marca"},
    "brand_colors": {"type": "array", "default": ["#2563EB", "#F59E0B"], "description": "Colores de marca en HEX"},
    "visual_style": {"type": "string", "default": "modern, clean, professional", "description": "Estilo visual"},
    "default_platform": {"type": "string", "default": "instagram", "enum": ["instagram", "facebook", "linkedin", "twitter"]},
    "include_hashtags": {"type": "boolean", "default": true},
    "include_emojis": {"type": "boolean", "default": true},
    "language": {"type": "string", "default": "es"}
  },
  "platform_limits": {
    "instagram": {"caption_max": 2200, "hashtags_max": 30, "dimensions": "1080x1080"},
    "facebook": {"text_max": 63206, "dimensions": "1200x630"},
    "linkedin": {"text_max": 3000, "dimensions": "1200x627"},
    "twitter": {"text_max": 280, "dimensions": "1200x675"},
    "tiktok": {"caption_max": 2200, "dimensions": "1080x1920"}
  }
}
```

---

## 🤖 Prompts de IA

### Prompt — Paso 1: Clasificar contexto

```
Analiza esta solicitud de post para redes sociales y determina:
1. Plataforma objetivo (instagram/facebook/linkedin/twitter/general)
2. Tono apropiado (casual/profesional/humorístico/inspiracional/informativo)
3. Formato (imagen_cuadrada/imagen_horizontal/carrusel/story)

Solicitud: "{user_request}"

Responde SOLO en JSON:
{"platform": "...", "tone": "...", "format_type": "..."}
```

### Prompt — Paso 2: Generar copy

```
Eres un copywriter experto en redes sociales para negocios en Latinoamérica.

Genera un copy para {platform} sobre: {topic}

REGLAS:
- Tono: {brand_tone}
- Máximo: {max_length} caracteres
- Idioma: español
- {if include_emojis} Incluir 2-4 emojis relevantes
- Incluir un CTA (call to action) claro
- NO incluir hashtags (se generan aparte)

FORMATO para {platform}:
- Instagram: Hook en primera línea, luego valor, cierra con CTA
- Facebook: Conversacional, pregunta al final
- LinkedIn: Profesional, datos o insight, cierra con reflexión
- Twitter: Directo, impactante, max 250 chars para dejar espacio a link

Genera SOLO el copy, sin explicaciones.
```

### Prompt — Paso 3: Generar hashtags

```
Genera {count} hashtags relevantes para este post de {platform}:

Copy: {copy_text}
Tema: {topic}

REGLAS:
- Mezclar: 5 populares (alto volumen) + 5 de nicho (específicos) + 5 de marca
- En español
- Sin el símbolo # (lo agrego yo)
- Relevantes al contenido, NO genéricos
- Formato: una palabra o frase corta por hashtag

Responde SOLO la lista de hashtags, uno por línea.
```

### Prompt — Paso 4: Generar imagen (Stable Diffusion)

```
{visual_style} social media post image about {topic},
brand colors {brand_colors_as_text},
clean composition, no text overlay,
professional photography style,
{platform_aspect_ratio},
high quality, 4k
```

---

## ⚠️ Error Handling

| Paso | Qué puede fallar | Qué hacer |
|---|---|---|
| 1 Clasificar | LLM no retorna JSON válido | Usar defaults: instagram, casual, cuadrado |
| 2 Copy | Copy demasiado largo | Truncar inteligentemente + avisar |
| 2 Copy | LLM genera contenido inapropiado | Filtro de contenido → regenerar |
| 3 Hashtags | Hashtags irrelevantes | Aceptar, el usuario puede editar |
| 4 Imagen | Stable Diffusion falla/timeout | Reintentar 1x. Si falla, entregar solo copy |
| 4 Imagen | Imagen de baja calidad | Entregar + preguntar si quiere regenerar |
| General | Costo excede $0.50 | Abortar y notificar admin |

---

## 📌 Ejemplo Completo

### Input del usuario:
> "Crea un post para Instagram sobre nuestro nuevo menú de verano, somos un restaurante mexicano moderno"

### Ejecución:

**Paso 1 — Clasificar:**
```json
{"platform": "instagram", "tone": "casual", "format_type": "imagen_cuadrada"}
```

**Paso 2 — Copy:**
```
🌮 ¡El verano llegó a tu mesa! 🌴

Presentamos nuestro nuevo menú de temporada con los sabores más frescos de México. Aguachile de mango, tacos de pescado al pastor y margaritas de frutos tropicales.

Dale a tu paladar unas vacaciones sin salir de la ciudad. 🍹

📍 Reserva tu mesa → link en bio
```

**Paso 3 — Hashtags:**
```
menuverano, cocinamexicana, restaurantemexicano, foodie, 
comidamexicana, gastronomiamexicana, menutemporada, 
tacoslovers, aguachile, margaritas, foodstagram, 
instafood, nuevomenu, saboresdeméxico, verano2026
```

**Paso 4 — Imagen:**
Prompt SD: `modern clean professional food photography, mexican summer menu, tropical fruits, tacos, margaritas, vibrant colors #2563EB #F59E0B, square composition, no text, 4k`

**Output al usuario:**
```
🎨 Post listo para Instagram:

📸 [imagen generada]

📝 Copy:
🌮 ¡El verano llegó a tu mesa! 🌴
[...]

#️⃣ Hashtags: #menuverano #cocinamexicana [...]

💰 Costo: $0.02
⏱️ Tiempo: 12s

¿Lo publico, lo edito o genero otra versión?
```

---

*Automatización A-02 — Post Creator — Diseñada 2026-03-07*
*Proceso: Investigar → Diseñar → Construir → Validar*
