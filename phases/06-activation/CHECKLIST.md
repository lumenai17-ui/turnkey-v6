# FASE 6: ACTIVATION - CHECKLIST

**Versión:** 1.0.0
**Fecha:** 2026-03-06

---

## ✅ CHECKLIST DE ACTIVACIÓN

### PRE-ACTIVACIÓN

| # | Tarea | Comando | Estado |
|---|-------|---------|--------|
| 1 | FASE 1 completada | `test -f phases/01-pre-flight/AUDITORIA.md` | ⬜ |
| 2 | FASE 2 completada | `test -f phases/02-setup-users/AUDITORIA.md` | ⬜ |
| 3 | FASE 3 completada | `test -f phases/03-gateway-install/AUDITORIA.md` | ⬜ |
| 4 | FASE 4 completada | `test -f phases/04-identity-fleet/AUDITORIA.md` | ⬜ |
| 5 | FASE 5 completada | `test -f phases/05-bot-config/AUDITORIA.md` | ⬜ |
| 6 | Secrets existen | `test -d ~/.openclaw/secrets/` | ⬜ |
| 7 | Config existe | `test -d ~/.openclaw/config/` | ⬜ |
| 8 | Puerto disponible | `ss -tlnp \| grep 18789` | ⬜ |

---

### GATEWAY

| # | Tarea | Comando | Estado |
|---|-------|---------|--------|
| 9 | Iniciar gateway | `systemctl start openclaw` | ⬜ |
| 10 | Esperar (30s) | `sleep 30` | ⬜ |
| 11 | Verificar health | `curl localhost:18789/health` | ⬜ |
| 12 | Verificar modelo | `curl localhost:18789/model` | ⬜ |

---

### CANALES

| # | Tarea | Comando | Estado |
|---|-------|---------|--------|
| 13 | Validar WhatsApp | `./scripts/validate-channels.sh --whatsapp` | ⬜ |
| 14 | Validar Telegram | `./scripts/validate-channels.sh --telegram` | ⬜ |
| 15 | Validar Discord | `./scripts/validate-channels.sh --discord` | ⬜ |
| 16 | Validar Email IMAP | `./scripts/validate-channels.sh --email --imap` | ⬜ |
| 17 | Validar Email SMTP | `./scripts/validate-channels.sh --email --smtp` | ⬜ |

---

### SMOKE TESTS

| # | Test | Comando | Crítico | Estado |
|---|------|---------|---------|--------|
| 18 | Gateway health | `curl localhost:18789/health` | ✅ | ⬜ |
| 19 | Modelo responde | Test prompt | ✅ | ⬜ |
| 20 | WhatsApp activo | Validate session | ✅ | ⬜ |
| 21 | Telegram responde | `/start` al bot | ✅ | ⬜ |
| 22 | Discord conectado | Verify intents | ❌ | ⬜ |
| 23 | Email IMAP | Connection test | ✅ | ⬜ |
| 24 | Email SMTP | Test send | ✅ | ⬜ |
| 25 | Memoria persiste | Save & read | ❌ | ⬜ |
| 26 | Web search | Search test | ❌ | ⬜ |
| 27 | PDF generate | Create PDF | ❌ | ⬜ |

---

### BACKUP

| # | Tarea | Comando | Estado |
|---|-------|---------|--------|
| 28 | Crear directorio | `mkdir -p ~/.openclaw/backup/pre-activation/` | ⬜ |
| 29 | Backup config | `cp -r ~/.openclaw/config/ backup/` | ⬜ |
| 30 | Backup secrets | `cp -r ~/.openclaw/secrets/ backup/` | ⬜ |
| 31 | Backup openclaw.json | `cp ~/.openclaw/openclaw.json backup/` | ⬜ |
| 32 | Crear timestamp | `date -Iseconds > backup/timestamp.txt` | ⬜ |

---

### REGISTRO

| # | Tarea | Comando | Estado |
|---|-------|---------|--------|
| 33 | Registrar en dashboard | `./scripts/register-dashboard.sh` | ⬜ |
| 34 | Crear log de activación | `./scripts/activation.sh > logs/activation.log` | ⬜ |
| 35 | Guardar estado | `echo "ACTIVE" > ~/.openclaw/status` | ⬜ |

---

### ENTREGA

| # | Tarea | Estado |
|---|-------|--------|
| 36 | Documentación generada | ⬜ |
| 37 | Credenciales documentadas | ⬜ |
| 38 | Plan de rollback documentado | ⬜ |
| 39 | Notificación enviada | ⬜ |

---

## 📊 RESUMEN

| Categoría | Total | Aprobados | Pendientes |
|-----------|-------|-----------|------------|
| PRE-ACTIVACIÓN | 8 | 0 | 8 |
| GATEWAY | 4 | 0 | 4 |
| CANALES | 5 | 0 | 5 |
| SMOKE TESTS | 10 | 0 | 10 |
| BACKUP | 5 | 0 | 5 |
| REGISTRO | 3 | 0 | 3 |
| ENTREGA | 4 | 0 | 4 |
| **TOTAL** | **39** | **0** | **39** |

---

## ✅ CRITERIOS DE ÉXITO

| Criterio | Mínimo | Óptimo |
|----------|--------|--------|
| Smoke tests críticos | 7/7 | 7/7 |
| Smoke tests opcionales | 3/3 | 3/3 |
| Canales principales | 3/3 | 4/4 |
| Gateway uptime | > 99% | 100% |
| Modelo response time | < 5s | < 2s |

---

## ❌ CRITERIOS DE FALLO

| Criterio | Acción |
|----------|--------|
| Faltan FASE 1-5 | Abortar, completar fases |
| Gateway no inicia | Revisar logs, rollback |
| Smoke tests críticos < 7 | Rollback |
| Puerto ocupado | Matar proceso o cambiar puerto |
| Secrets faltantes | Abortar, revisar FASE 5 |

---

*Checklist creado: 2026-03-06*
*Usar con: `./scripts/activation.sh --checklist`*