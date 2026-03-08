# A-17: Product Catalog

**Categoría:** E-commerce | **Fase:** F4 | **Complejidad:** 🟡 Media
**Status:** Diseñada | **APIs externas:** Ninguna

---

## 📋 Resumen

Genera un catálogo digital profesional desde un archivo Excel/PDF. El agente lee los productos, genera imágenes si faltan, crea códigos QR para cada producto, y publica una web de catálogo navegable. Todo automático.

---

## 🔍 Investigación — Qué existe

| Herramienta | Qué hace | Qué adoptamos |
|---|---|---|
| Flipsnack / Issuu | Catálogos digitales flip-page | ✅ Concepto de catálogo navegable web |
| WooCommerce | Tienda online con catálogo | ❌ Demasiado complejo para un catálogo simple |
| Google Sheets + AppSheet | Sheet → app | ✅ La idea de Excel como fuente de datos |
| Catalog Machine (SaaS) | Excel → catálogo PDF | ✅ Flujo Excel → estructura de catálogo → output |

**Diferenciador nuestro:** El agente lo hace todo conversacionalmente. "Aquí está mi Excel de productos, crea el catálogo" y listo. Incluye QR para cada producto y deploy web inmediato.

---

## 🔄 Workflow

```
┌─────────────────────────────────────────────────────────┐
│              A-17: PRODUCT CATALOG                        │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  TRIGGER: "Crea un catálogo con estos productos"          │
│     │     [webhook] → producto actualizado                │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 1: Leer fuente de datos                │          │
│  │ skill: excel_read ó pdf_read                │          │
│  │ Extraer: nombre, precio, descripción, img   │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 2: Enriquecer datos                    │          │
│  │ skill: rewrite                              │          │
│  │ Mejorar descripciones cortas                │          │
│  │ Categorizar productos automáticamente       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 3: Generar imágenes (si faltan)        │          │
│  │ skill: image_generate                       │          │
│  │ Solo para productos sin foto                │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 4: Generar QR por producto             │          │
│  │ skill: qrcode_generate                      │          │
│  │ QR → URL del producto en catálogo web       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 5: Crear catálogo web                  │          │
│  │ skill: web_create                           │          │
│  │ HTML responsive con grid de productos       │          │
│  └──┬──────────────────────────────────────────┘          │
│     │                                                     │
│  ┌──▼──────────────────────────────────────────┐          │
│  │ PASO 6: Exportar PDF (opcional)             │          │
│  │ skill: pdf_generate                         │          │
│  │ Versión imprimible del catálogo             │          │
│  └──────────────────────────────────────────────┘          │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Receta (JSON)

```json
{
  "automation_id": "A-17",
  "name": "product_catalog",
  "version": "1.0.0",
  "skills_required": ["excel_read", "pdf_read", "rewrite", "image_generate", "qrcode_generate", "web_create", "pdf_generate"],
  "estimated_cost_per_run": 0.10,
  "estimated_duration_seconds": 60,
  "steps": [
    {
      "step": 1,
      "skill": "excel_read",
      "action": "Leer productos desde Excel/PDF",
      "input": {"source": "{config.source_file}", "sheet": "{config.sheet_name}"},
      "output": "products[]{name, price, description, category, image_url}",
      "on_error": {"action": "try_pdf_read", "fallback": "Intentar como PDF si Excel falla"}
    },
    {
      "step": 2,
      "skill": "rewrite",
      "action": "Enriquecer descripciones de productos",
      "input": {"products": "{step_1.products}", "tone": "{config.description_tone}"},
      "output": "enriched_products[]",
      "on_error": {"action": "skip", "fallback": "Usar descripciones originales"}
    },
    {
      "step": 3,
      "skill": "image_generate",
      "action": "Generar imágenes para productos sin foto",
      "input": {"products_without_image": "{filter: !image_url}", "style": "product photography"},
      "output": "products_with_images[]",
      "condition": "only_if products_without_images > 0",
      "on_error": {"action": "skip", "fallback": "Usar placeholder genérico"}
    },
    {
      "step": 4,
      "skill": "qrcode_generate",
      "action": "Crear QR por producto",
      "input": {"data": "{catalog_url}/product/{product.id}", "size": 200},
      "output": "qr_codes[]",
      "condition": "only_if config.generate_qr == true",
      "on_error": {"action": "skip"}
    },
    {
      "step": 5,
      "skill": "web_create",
      "action": "Crear catálogo web responsive",
      "input": {
        "template": "{config.catalog_template}",
        "products": "{step_2.enriched_products}",
        "images": "{step_3.products_with_images}",
        "qr_codes": "{step_4.qr_codes}",
        "business_info": "{config.business_info}"
      },
      "output": "catalog_url",
      "on_error": {"action": "retry", "max_retries": 1}
    },
    {
      "step": 6,
      "skill": "pdf_generate",
      "action": "Exportar catálogo como PDF",
      "input": {"html_source": "{step_5.catalog_html}", "filename": "catalogo_{business_name}"},
      "output": "catalog_pdf_path",
      "condition": "only_if config.export_pdf == true",
      "on_error": {"action": "skip", "fallback": "Solo versión web"}
    }
  ],
  "config_schema": {
    "source_file": {"type": "string", "default": "data/products.xlsx"},
    "source_type": {"type": "string", "default": "excel", "enum": ["excel", "pdf", "csv"]},
    "sheet_name": {"type": "string", "default": "Productos"},
    "catalog_template": {"type": "string", "default": "grid_modern", "enum": ["grid_modern", "list_clean", "cards_premium"]},
    "generate_qr": {"type": "boolean", "default": true},
    "export_pdf": {"type": "boolean", "default": true},
    "description_tone": {"type": "string", "default": "comercial y atractivo"},
    "business_info": {"type": "object", "properties": {"name": "string", "logo": "string", "contact": "string"}},
    "currency": {"type": "string", "default": "USD"},
    "show_prices": {"type": "boolean", "default": true}
  }
}
```

---

## 🤖 Prompts de IA

### Prompt — Paso 2: Enriquecer descripciones

```
Mejora estas descripciones de productos para un catálogo digital. 
Tono: {description_tone}

REGLAS:
- Máximo 2 oraciones por producto
- Destacar el beneficio principal
- Incluir 1-2 adjetivos atractivos
- NO inventar características que no estén en la descripción original
- Mantener el nombre exacto del producto

Productos:
{products_json}

Responde en JSON con el mismo formato, solo cambiando "description".
```

### Prompt — Paso 3: Imagen de producto (Stable Diffusion)

```
professional product photography of {product_name},
{product_category} product,
white background, studio lighting,
clean minimal composition, centered,
commercial photography style, high quality, 4k
```

---

## ⚠️ Error Handling

| Paso | Qué puede fallar | Qué hacer |
|---|---|---|
| 1 Leer | Excel corrupto o formato inesperado | Intentar como CSV, luego abortar |
| 1 Leer | Columnas con nombres diferentes | Mapeo inteligente por IA |
| 2 Enriquecer | Descripciones en otro idioma | Detectar idioma + traducir primero |
| 3 Imágenes | Muchos productos sin foto (costo alto) | Límite: max 10 imágenes generadas |
| 4 QR | Demasiados productos (performance) | Procesar en batches de 50 |
| 5 Web | HTML mal renderizado | Validar + corregir |
| 6 PDF | Catálogo muy largo (>50 páginas) | Particionar por categoría |

---

## 📌 Ejemplo Completo

### Input:
> "Aquí está mi Excel de productos, crea el catálogo" + [products.xlsx adjunto]

### Excel de ejemplo:
| Nombre | Precio | Descripción | Categoría |
|---|---|---|---|
| Camiseta Classic | $29.99 | Camiseta algodón 100% | Ropa |
| Gorra Snapback | $19.99 | Gorra ajustable | Accesorios |
| Tote Bag Canvas | $24.99 | Bolsa de lona | Accesorios |

### Output:
```
📦 Catálogo creado:

🌐 Web: https://mi-tienda.tunneled.site/catalogo
📄 PDF: catalogo_mi_tienda.pdf (3 páginas)

📊 Estadísticas:
- Productos: 3
- Categorías: 2
- Imágenes generadas: 3 (no tenían foto)
- Códigos QR: 3
- Tiempo: 45s
- Costo: $0.03 (3 imágenes × $0.01)

¿Quieres editar algo o lo publicamos?
```

---

*Automatización A-17 — Product Catalog — Diseñada 2026-03-07*
