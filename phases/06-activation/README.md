# FASE 6: ACTIVACIÓN

**Estado:** ✅ COMPLETADO  
**Fecha:** 2026-03-07  
**Dependencias:** FASE 5 completada

---

## 📋 PROPÓSITO

Iniciar servicios, ejecutar smoke tests (5 tests), verificar funcionamiento completo, generar reporte de activación, y proporcionar rollback si algo falla.

---

## 📦 REQUISITOS

### Dependencias del Sistema
| Requisito | Versión | Notas |
|-----------|---------|-------|
| Bash | >= 4.0 | Shell scripts |
| curl | cualquiera | Health checks |
| jq | >= 1.5 | Validación JSON |
| systemctl | cualquiera | Gestión de servicios |

### Dependencias de Fases
| Fase | Archivo | Descripción |
|------|---------|-------------|
| FASE 1 | `turnkey-config.json` | Configuración base |
| FASE 4 | `SOUL.md`, `USER.md` | Archivos de identidad |
| FASE 3 | `gateway.json` | Config del gateway |

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

### Scripts
| Archivo | Líneas | Descripción |
|---------|--------|-------------|
| `scripts/activation.sh` | 298 | Script principal — 4 pasos + 5 smoke tests |
| `scripts/rollback.sh` | 84 | Rollback — stop services, backup, cleanup |

### Documentación
| Archivo | Descripción |
|---------|-------------|
| `ANALISIS.md` | Análisis de la fase |
| `DISEÑO.md` | Diseño de scripts |
| `DECISIONES.md` | Decisiones aprobadas |
| `CHECKLIST.md` | Checklist de activación |
| `AUDITORIA.md` | Resultado de auditoría |

---

## 🔄 Flujo de la Fase

```
1. VERIFICAR PREREQUISITOS → Config, identidad, Node.js
2. INICIAR SERVICES → systemctl start openclaw-gateway
3. SMOKE TESTS (5):
   ├── Test 1: Archivos de configuración (JSON válido)
   ├── Test 2: Archivos de identidad (SOUL.md, USER.md, HEART.md)
   ├── Test 3: Health check del gateway (puerto)
   ├── Test 4: Validación de canales (Telegram token)
   └── Test 5: Estructura de directorios
4. GENERAR REPORTE → activation-report.json
```

---

## 🚀 USO

```bash
# Activación completa
./scripts/activation.sh --agent-name "mi-agente" --port 18789 --config /path/to/config.json

# Modo simulación
./scripts/activation.sh --agent-name "mi-agente" --dry-run

# Rollback si algo falla
./scripts/rollback.sh --agent-name "mi-agente"
```

---

## 📄 OUTPUT

El script genera:
- `~/.openclaw/workspace/turnkey/activation-report.json` — Reporte con tests pasados/fallidos

---

## ⚠️ ROLLBACK

Si la activación falla, usar `rollback.sh`:

```bash
./scripts/rollback.sh --agent-name "mi-agente"
```

Esto ejecuta:
1. **Stop services** — `systemctl --user stop openclaw-gateway`
2. **Backup estado** — Copia config actual a `.bak`
3. **Limpiar** — Remover archivos parciales

---

**Fase anterior:** [05-bot-config](../05-bot-config/)