# DECISIONES - FASE 1: PRE-FLIGHT

**Fecha:** 2026-03-05

---

## ✅ Decisiones Tomadas

| # | Fecha | Decisión | Opción elegida | Razón | Quién |
|---|-------|----------|----------------|-------|-------|
| 1 | 2026-03-05 | Metodología de trabajo | Opción A: Fase por fase | Más control, diseño profundo | HB |
| 2 | 2026-03-05 | Mínimos de recursos | Negociables con warnings | Flexibilidad | HB |
| 3 | 2026-03-05 | Valores por defecto | "Por defecto" no "Obligatorio" | Menos fricción | HB |
| 4 | 2026-03-05 | Detección de tipo | Auto-detectar con override | Automatización + control | LOCAL |
| 5 | 2026-03-05 | API key Ollama | Requerida, validar con ping | Sin ella no hay agente | LOCAL |
| 6 | 2026-03-05 | Valores por defecto adicionales | Definir lista específica | Ver sección detallada | HB |
| 7 | 2026-03-05 | Ubicación config | Pendiente sugerencia | Ver opciones en análisis | HB |
| 8 | 2026-03-05 | Validar Ollama | Sí, pero primero verificar plan (gratis/paga) | Distinguir tipo de cuenta | HB |
| 9 | 2026-03-05 | Sin API key Ollama | Siempre debe haber key (gratis o paga) | Mandatorio | HB |
| 10 | 2026-03-05 | Recursos insuficientes | Corregir si se puede, pedir ayuda humana | Intentar resolver | HB |
| 11 | 2026-03-05 | Sin recursos mínimos | NO proceder, producto no funciona | Bloquear instalación | HB |
| 12 | 2026-03-05 | Modo interactivo | Preguntar solo lo faltante | Más rápido | HB |
| 13 | 2026-03-05 | Input interactivo | Pendiente sugerencia | Ver opciones | HB |
| 14 | 2026-03-05 | Canales por defecto | Telegram + WhatsApp + Discord habilitados | Multi-canal | HB |

---

## 📋 Detalle de Decisiones

### Decisión 6: Valores por Defecto Adicionales

**Valores por defecto definidos:**

| Categoría | Parámetro | Default | Negociable |
|-----------|-----------|---------|------------|
| **Identidad** | Nombre | Agent-{timestamp} | Sí |
| | Rol | Asistente virtual | Sí |
| | Emoji | 🤖 | Sí |
| | Idioma | es | Sí |
| **Despliegue** | Tipo | vps | Sí (auto-detectar) |
| | Puerto | 18789 | Sí (auto-asignar) |
| **Modelos** | Primario | glm-5 | Sí |
| | Fallback | kimi-k2.5 | Sí |
| **Canales** | Telegram | Habilitado (requiere token) | Sí |
| | WhatsApp | Habilitado (requiere config) | Sí |
| | Discord | Habilitado (requiere token) | Sí |
| | Email | Deshabilitado | Sí |
| **Skills** | voicenote | Habilitada | Sí |
| | pdf_reader | Habilitada | Sí |
| | web_search | Habilitada (si hay Brave key) | Sí |

---

### Decisión 7: Ubicación de turnkey-defaults.json

**Opciones a considerar:**

| Opción | Ventajas | Desventajas |
|--------|----------|-------------|
| A) Embebido en script | Un solo archivo, simple | Difícil de modificar |
| B) `/etc/turnkey/` | Ubicación estándar Linux | Requiere root para editar |
| C) `~/.openclaw/workspace/turnkey/` | Junto a otros archivos | Más fácil de editar |

**Sugerencia:** Opción C - `~/.openclaw/workspace/turnkey/turnkey-defaults.json`
- No requiere root
- Junto a otros archivos de configuración
- Fácil de editar manualmente si necesario
- Consistente con estructura existente

---

### Decisión 8: Validación de Ollama

**Flujo actualizado:**

```
1. Verificar si existe OLLAMA_API_KEY
   ├─► Si NO existe: Pedir interactivamente
   └─► Si existe: Continuar
   
2. Verificar tipo de cuenta
   ├─► Llamar API para verificar plan
   ├─► Gratis: Límites de uso, modelos básicos
   └─► Paga: Sin límites, modelos avanzados
   
3. Validar que la key funciona
   ├─► Ping a /v1/models
   ├─► Si falla: Error crítico
   └─► Si funciona: Continuar
```

---

### Decisión 13: Formato de Input Interactivo

**Opciones a considerar:**

| Opción | Ventajas | Desventajas |
|--------|----------|-------------|
| A) Menú numerado | Más claro, menos errores | Más líneas de código |
| B) Texto libre | Más flexible | Más propenso a errores |
| C) Mixto | Menús para opciones, texto para valores | Balanceado |

**Sugerencia:** Opción C - Mixto
- Menús numerados para opciones predefinidas (template, modelo)
- Texto libre para valores personalizados (nombre, rol)
- Defaults entre paréntesis para aceptar con Enter

---

## ✅ Decisiones Confirmadas

| # | Pregunta | Decisión Final | Confirmado |
|---|----------|----------------|------------|
| 7 | Ubicación config | `~/.openclaw/workspace/turnkey/turnkey-defaults.json` | ✅ 2026-03-05 |
| 13 | Formato interactivo | Mixto (menús para opciones, texto para valores) | ✅ 2026-03-05 |

---

*Actualizado: 2026-03-05*