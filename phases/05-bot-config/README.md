# FASE 5: BOT CONFIG

**Estado:** ✅ COMPLETADO  
**Fecha:** 2026-03-06  
**Dependencias:** FASE 4 completada

---

## 📋 PROPÓSITO

Configurar canales de comunicación (Telegram, Email), API keys del sistema, y validar conectividad de cada canal.

---

## 📦 REQUISITOS

### Dependencias del Sistema
| Requisito | Versión | Notas |
|-----------|---------|-------|
| Bash | >= 4.0 | Shell scripts |
| curl | cualquiera | Validación de APIs |
| jq | >= 1.5 | Parseo JSON |
| Python 3 | >= 3.6 | Test de email IMAP (opcional) |

### Dependencias de Fases
| Fase | Archivo | Descripción |
|------|---------|-------------|
| FASE 4 | `.identity-status.json` | Identidad configurada |

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

### Scripts (5 scripts, ~3,400+ líneas)
| Archivo | Tamaño | Descripción |
|---------|--------|-------------|
| `scripts/bot-config.sh` | 465 líneas | Orquestador — Telegram → Email → API keys |
| `scripts/setup-telegram.sh` | 662 líneas | BotFather guide, webhook, validación `getMe` |
| `scripts/setup-email.sh` | 531 líneas | IMAP/SMTP/Resend con python validation |
| `scripts/setup-api-keys.sh` | ~900 líneas | Todas las API keys → `.env` con `chmod 600` |
| `scripts/validate-channels.sh` | ~700 líneas | Validación post-setup de cada canal |

### Documentación
| Archivo | Descripción |
|---------|-------------|
| `ANALISIS.md` | Análisis de la fase |
| `DISEÑO.md` | Diseño de scripts |
| `DECISIONES.md` | Decisiones aprobadas |
| `AUDITORIA.md` | Resultado de auditoría |
| `ACCESOS-CREDENCIALES-FASE5.md` | Referencia de credenciales (12KB) |

---

## 🔄 Flujo de la Fase

```
1. CONFIGURAR TELEGRAM → Bot token, allowed users, webhook
2. CONFIGURAR EMAIL → IMAP/SMTP/Resend (si habilitado)
3. CONFIGURAR API KEYS → Todas las keys → .env protegido
4. VALIDAR CANALES → Test de conectividad por canal
5. ACTUALIZAR CONFIG → Agregar canales a openclaw.json
```

---

## 📡 Canales Soportados

| Canal | Estado | Script |
|-------|--------|--------|
| Telegram | ✅ Implementado | `setup-telegram.sh` |
| Email (IMAP/SMTP) | ✅ Implementado | `setup-email.sh` |
| WhatsApp | ⏳ Pendiente | No implementado aún |
| Discord | ⏳ Pendiente | No implementado aún |

> [!NOTE]
> WhatsApp y Discord están planificados pero no tienen scripts implementados todavía. El sistema funciona sin ellos.

---

## 🚀 USO

```bash
# Configuración completa de canales
./scripts/bot-config.sh --agent-name "mi-agente" --config /path/to/config.json

# Solo Telegram
./scripts/setup-telegram.sh --agent-name "mi-agente" --token "BOT_TOKEN" --allowed-users "123456"

# Solo Email
./scripts/setup-email.sh --agent-name "mi-agente" --config /path/to/config.json

# Validar canales después de setup
./scripts/validate-channels.sh --agent-name "mi-agente"

# Modo simulación
./scripts/bot-config.sh --agent-name "test" --config config.json --dry-run
```

---

## 📄 OUTPUT

El script genera:
- `~/.openclaw/config/.env` — API keys protegidas (`chmod 600`)
- `~/.openclaw/config/telegram.json` — Config de Telegram
- `~/.openclaw/config/email.json` — Config de Email
- `~/.openclaw/config/channels-status.json` — Estado de canales

---

**Siguiente fase:** [06-activation](../06-activation/)