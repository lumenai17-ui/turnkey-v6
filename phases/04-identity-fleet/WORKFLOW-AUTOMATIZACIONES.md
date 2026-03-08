# Workflow: Diseño Multiagente de Automatizaciones

**Versión:** 1.0.0
**Fecha:** 2026-03-07
**Propósito:** Proceso estándar para diseñar e implementar cada automatización del Super Agente v2.0

---

## 🔄 PROCESO MULTIAGENTE (por automatización)

Cada automatización pasa por **4 fases** antes de considerarse completa:

```
┌─────────────────────────────────────────────────────────────────┐
│                PIPELINE POR AUTOMATIZACIÓN                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  FASE 1: INVESTIGAR (Agente Investigador)                        │
│  ├── Buscar repos/herramientas existentes similares              │
│  ├── Analizar cómo lo resuelven n8n, Zapier, Make               │
│  ├── Identificar mejores prácticas del mercado                   │
│  └── Documentar: qué existe, qué sirve, qué no                  │
│                                                                   │
│  FASE 2: DISEÑAR (Agente Arquitecto)                             │
│  ├── Definir workflow paso a paso                                │
│  ├── Mapear cada paso a nuestros skills (58 built-in)            │
│  ├── Diseñar prompts de IA para cada skill usado                 │
│  ├── Definir input/output schemas                                │
│  ├── Diseñar error handling y fallbacks                          │
│  └── Combinar lo mejor externo + nuestros skills                 │
│                                                                   │
│  FASE 3: CONSTRUIR (Agente Constructor)                          │
│  ├── Escribir la receta completa en JSON                         │
│  ├── Crear prompts finales                                       │
│  ├── Crear templates (HTML, email, etc.) si aplica               │
│  ├── Escribir pseudocódigo de orquestación                       │
│  └── Documentar configuración requerida                          │
│                                                                   │
│  FASE 4: VALIDAR (Agente Auditor)                                │
│  ├── Verificar que todos los skills existen en las 58            │
│  ├── Verificar que los prompts son claros y específicos          │
│  ├── Verificar error handling (¿qué pasa si falla X?)            │
│  ├── Verificar que la config tiene todos los campos              │
│  ├── Simular un caso de uso completo (dry-run mental)            │
│  └── Comparar con la solución existente investigada              │
│                                                                   │
│  OUTPUT: Archivo completo de automatización                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📄 FORMATO DE SALIDA (por automatización)

Cada automatización completada produce un archivo: `automations/A-XX_nombre.md`

### Estructura del archivo:

```markdown
# A-XX: Nombre de la Automatización

## Resumen
- Qué hace, para quién, cuándo se ejecuta

## Investigación
- Qué existe en el mercado (links, repos, herramientas)
- Qué adoptamos de lo existente
- Qué hacemos diferente y por qué

## Workflow
- Paso 1 → Paso 2 → Paso 3 → Output
- Diagrama de flujo
- Condiciones y bifurcaciones

## Receta (JSON)
- Steps con skill, prompt, input, output, on_error
- Config schema completo

## Prompts de IA
- Prompt exacto para cada skill de IA usado
- Variables del prompt
- Ejemplos de output esperado

## Templates
- HTML de email (si aplica)
- Templates de documentos (si aplica)

## Error Handling
- Tabla: qué puede fallar → qué hacer
- Fallbacks y reintentos

## Ejemplo Completo
- Input del usuario (caso real)
- Ejecución paso a paso
- Output final
```

---

## 📋 ORDEN DE EJECUCIÓN

### Ronda 1 — F4 (se activan primero, más sencillas)

| # | Automatización | Complejidad | Motivo de prioridad |
|---|---|---|---|
| A-2 | Post Creator | 🟢 Baja | No requiere APIs externas, solo IA |
| A-5 | SEO Content Creator | 🟢 Baja | No requiere APIs externas, solo IA |
| A-10 | Landing Page Express | 🟡 Media | Requiere templates HTML |
| A-12 | Invoice Autopilot | 🟡 Media | Requiere templates de factura |
| A-17 | Product Catalog | 🟡 Media | Requiere leer Excel + generar web |

### Ronda 2 — F5 operaciones internas (14 automatizaciones)

| # | Automatización | Complejidad | APIs externas |
|---|---|---|---|
| A-6 | Lead Capture | 🟢 Baja | Ninguna |
| A-7 | Competitor Watch | 🟢 Baja | Ninguna |
| A-9 | Blog Autopilot | 🟡 Media | WordPress REST API |
| A-11 | Newsletter Auto | 🟡 Media | Ninguna |
| A-13 | Appointment Bot | 🟡 Media | Google Calendar API |
| A-14 | Review Responder | 🟡 Media | Ninguna |
| A-15 | Daily Report | 🟢 Baja | Ninguna |
| A-16 | Customer Follow-up | 🟢 Baja | Ninguna |
| A-18 | Order Manager | 🟡 Media | Ninguna |
| A-19 | Payment Links | 🔴 Alta | Stripe API |
| A-20 | Inventory Alert | 🟢 Baja | Ninguna |

### Ronda 3 — F5 APIs externas complejas

| # | Automatización | Complejidad | APIs externas |
|---|---|---|---|
| A-1 | Meta Ads Manager | 🔴 Alta | Meta Marketing API |
| A-3 | Social Scheduler | 🔴 Alta | Meta API, LinkedIn API |
| A-4 | Google My Business | 🔴 Alta | Google Business API |
| A-8 | WordPress Publisher | 🟡 Media | WordPress REST API |

### Ronda 4 — F6 (dependen de todo lo anterior)

| # | Automatización | Complejidad | Dependencias |
|---|---|---|---|
| A-15 | Daily Report | 🟡 Media | metrics_dashboard, report_generate |

---

## ✅ CHECKLIST DE CALIDAD (por automatización)

Antes de marcar una automatización como completa:

- [ ] ¿Todos los skills usados existen en las 58 built-in?
- [ ] ¿Los prompts de IA son específicos y producen buen output?
- [ ] ¿Hay error handling para cada paso que puede fallar?
- [ ] ¿La config tiene valores por defecto razonables?
- [ ] ¿El ejemplo de uso es realista y completo?
- [ ] ¿Se investigó qué existe en el mercado?
- [ ] ¿Se adoptó lo mejor de lo existente?
- [ ] ¿El workflow es el más simple posible?
- [ ] ¿Funciona sin intervención del usuario (si es automática)?
- [ ] ¿El costo por ejecución es razonable?

---

## 💡 RECOMENDACIONES ADICIONALES

### 1. Cost Guard — Límites de costo por automatización

Cada automatización que use APIs de pago debería tener un `cost_limit`:

```json
{
  "cost_guard": {
    "max_per_execution": 0.50,
    "max_per_day": 5.00,
    "max_per_month": 50.00,
    "alert_at": 0.80,
    "action_on_limit": "pause_and_notify"
  }
}
```

**Por qué:** Previene que un loop infinito o un cliente que abusa queme tu presupuesto de APIs.

### 2. Audit Trail — Log de cada ejecución

Cada ejecución de automatización debería guardarse:

```json
{
  "execution_log": {
    "id": "exec-uuid",
    "automation": "A-2",
    "trigger": "manual",
    "started_at": "2026-03-07T10:00:00Z",
    "steps": [
      {"step": 1, "skill": "rewrite", "status": "ok", "duration_ms": 1200},
      {"step": 2, "skill": "image_generate", "status": "ok", "duration_ms": 3400}
    ],
    "total_cost": 0.02,
    "result": "success"
  }
}
```

**Por qué:** Saber qué corre, cuánto cuesta, y detectar problemas.

### 3. Feature Flags — Activar/desactivar por cliente

No todos los clientes necesitan las 20 automatizaciones:

```json
{
  "client_automations": {
    "restaurante_casamahana": {
      "enabled": ["A-2", "A-12", "A-13", "A-14", "A-15", "A-18"],
      "disabled": ["A-1", "A-3", "A-4", "A-8", "A-9"]
    }
  }
}
```

**Por qué:** Un restaurante no necesita WordPress Publisher ni Meta Ads Manager desde el día 1.

### 4. Warm-up Sequence — Activación progresiva

No activar las 20 de golpe. Ir encendiendo gradualmente:

```
Semana 1: A-15 Daily Report (el cliente ve valor inmediato)
Semana 2: A-2 Post Creator + A-12 Invoice
Semana 3: A-13 Appointment Bot + A-14 Review Responder
Semana 4: El resto según necesidad
```

**Por qué:** Menos riesgo, cliente ve valor rápido, tickets de soporte manejables.

### 5. Dry-Run Mode — Modo prueba

Toda automatización debería poder correr en modo "simulación" antes de ir en vivo:

```json
{
  "dry_run": true,
  "actions": "log_only",
  "send_emails": false,
  "generate_files": true,
  "notify_admin": true
}
```

**Por qué:** Probar que todo funciona sin enviar emails reales ni publicar contenido real.

---

*Workflow v1.0.0 — Proceso multiagente para automatizaciones — TURNKEY v6*
