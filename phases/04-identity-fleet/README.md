# FASE 4: IDENTITY + FLEET

**Estado:** ✅ COMPLETADO  
**Fecha:** 2026-03-06  
**Dependencias:** FASE 3 completada

---

## 📋 PROPÓSITO

Configurar identidad del agente (SOUL.md, USER.md, MEMORY.md, HEART.md, DOPAMINE.md), conectar con Fleet LUMEN v2 (modelos), configurar skills por vertical, y procesar conocimiento del negocio.

---

## 📦 REQUISITOS

### Dependencias del Sistema
| Requisito | Versión | Notas |
|-----------|---------|-------|
| Bash | >= 4.0 | Shell scripts |
| jq | >= 1.5 | Validación JSON |
| pdftotext | opcional | Procesamiento de PDFs |
| ssconvert | opcional | Procesamiento de Excel |

### Dependencias de Fases
| Fase | Archivo | Descripción |
|------|---------|-------------|
| FASE 3 | `gateway.json` | Gateway configurado |

---

## ✅ PROGRESO

| Etapa | Estado |
|-------|--------|
| ANÁLISIS | ✅ 100% |
| DISEÑO | ✅ 100% |
| DECISIONES | ✅ 100% |
| CODING | ✅ 100% |
| AUDITORÍA | ✅ 100% |

---

## 📁 ARCHIVOS

### Scripts (5 scripts, ~2,800 líneas)
| Archivo | Líneas | Descripción |
|---------|--------|-------------|
| `scripts/setup-identity.sh` | 569 | SOUL.md, USER.md, HEART.md, DOPAMINE.md, MEMORY.md |
| `scripts/setup-fleet.sh` | 586 | Fleet de 13 modelos con API key injection |
| `scripts/setup-skills.sh` | 660 | 25 core + 14 optional + bundles por vertical |
| `scripts/process-knowledge.sh` | 544 | Pipeline PDF/Excel/Doc processing |
| `scripts/setup-fase4.sh` | 437 | Orquestador de los 4 sub-scripts |

### Configuración
| Archivo | Descripción |
|---------|-------------|
| `FLEET.json` | 13 modelos con prioridad y fallback |
| `skills-bundles.json` | Bundles de skills por tipo de negocio |
| `DOPAMINE.json` | Config del sistema de satisfacción |
| `email-config.json` | Templates de email |
| `skills-bundles-config.json` | Mapeo de skills a APIs |

### Documentación
| Archivo | Descripción |
|---------|-------------|
| `ANALISIS.md` | Análisis de la fase |
| `DISEÑO.md` | Diseño de scripts |
| `DECISIONES.md` | Decisiones aprobadas |
| `AUDITORIA.md` | Resultado de auditoría |
| `SKILLS-BUNDLES.md` | Documentación de skills (24KB) |
| `SKILLS-BUNDLES-DETALLE.md` | Detalle completo de skills (45KB) |
| `PROFUNDIZACION-HABILIDADES.md` | Profundización técnica (30KB) |
| `PROFUNDIZACION-KNOWLEDGE.md` | Sistema de conocimiento (17KB) |

---

## 🔄 Flujo de la Fase

```
1. CREAR IDENTIDAD → SOUL.md, USER.md, HEART.md, DOPAMINE.md, MEMORY.md
2. CONFIGURAR FLEET → openclaw.json con 13 modelos
3. CONFIGURAR SKILLS → Bundle según tipo de negocio
4. PROCESAR CONOCIMIENTO → PDF/Excel/Doc → texto procesado
5. VERIFICAR → Archivos creados, JSON válido
```

---

## 🚀 USO

```bash
# Setup completo
./scripts/setup-fase4.sh --agent-name "mi-agente" --business-type "restaurante" --business-name "Mi Restaurante"

# Solo identidad
./scripts/setup-identity.sh --agent-name "mi-agente" --business-type "restaurante" --business-name "Mi Restaurante"

# Modo simulación
./scripts/setup-identity.sh --agent-name "test" --business-type "generico" --business-name "Test" --dry-run
```

---

## 📄 OUTPUT

El script genera en `~/.openclaw/`:
- `config/SOUL.md` — Personalidad del agente
- `config/USER.md` — Info del cliente
- `config/HEART.md` — Sistema emocional
- `config/DOPAMINE.md` — Sistema de satisfacción
- `data/MEMORY.md` — Memoria inicial
- `config/openclaw.json` — Fleet de modelos
- `config/skills-core.json` — Skills activas
- `config/.identity-status.json` — Estado de la fase

---

**Siguiente fase:** [05-bot-config](../05-bot-config/)