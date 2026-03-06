# FASE 6: ACTIVATION - ANÁLISIS

**Versión:** 1.0.0
**Fecha:** 2026-03-06
**Prioridad:** 🔴 ALTA
**Dependencias:** FASE 1-5 completadas

---

## 1️⃣ PROPÓSITO

**FASE 6 activa y valida el agente completo.**

Esta fase:
- Inicia todos los servicios
- Ejecuta smoke tests de todos los canales
- Verifica funcionamiento del modelo
- Registra en dashboard (si aplica)
- Crea backup inicial
- Documenta plan de rollback

---

## 2️⃣ COMPONENTES A ACTIVAR

### 2.1 GATEWAY

| Componente | Comando | Validación |
|------------|---------|------------|
| OpenClaw Gateway | `systemctl start openclaw` | `systemctl status openclaw` |
| Puerto | 18789 | `curl localhost:18789/health` |

### 2.2 CANALES

| Canal | Validación | Comando |
|-------|-------------|---------|
| WhatsApp | Sesión activa | `validate-channels.sh --whatsapp` |
| Telegram | Bot responde | `validate-channels.sh --telegram` |
| Discord | Bot conectado | `validate-channels.sh --discord` |
| Email | IMAP/SMTP OK | `validate-channels.sh --email` |

### 2.3 MODELO

| Validación | Comando | Esperado |
|------------|---------|----------|
| Modelo carga | `curl localhost:18789/model` | glm-5 |
| Modelo responde | Test prompt | Respuesta coherente |
| Fallback funciona | Cambiar modelo | kimi-k2.5 |

### 2.4 HABILIDADES

| Habilidad | Test | Estado |
|-----------|------|--------|
| email_send | Enviar test | ✅ |
| email_read | Leer inbox | ✅ |
| pdf_generate | Crear PDF | ✅ |
| pdf_read | Leer PDF | ✅ |
| voice_send | Enviar voicenote | ✅ |
| voice_receive | Recibir voicenote | ✅ |
| image_receive | Analizar imagen | ✅ |
| web_search | Buscar web | ✅ |
| browser | Navegar | ✅ |

---

## 3️⃣ SMOKE TESTS

### Test 1: Gateway Health

```bash
curl -s http://localhost:18789/health | jq .
```

**Esperado:**
```json
{
  "status": "healthy",
  "version": "2026.3.3",
  "uptime": "00:05:23"
}
```

### Test 2: Modelo Responde

```bash
curl -X POST http://localhost:18789/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "glm-5", "messages": [{"role": "user", "content": "Di hola"}]}'
```

**Esperado:** Respuesta con "Hola" o similar.

### Test 3: WhatsApp Activo

```bash
validate-channels.sh --whatsapp --test
```

**Esperado:**
```
✅ WhatsApp session: active
✅ Groups accessible: 1
✅ DM enabled: true
```

### Test 4: Telegram Bot

```bash
validate-channels.sh --telegram --test
```

**Esperado:**
```
✅ Bot token: valid
✅ Webhook: configured
✅ Bot responds: /start -> Welcome!
```

### Test 5: Email IMAP/SMTP

```bash
validate-channels.sh --email --test
```

**Esperado:**
```
✅ IMAP connection: OK
✅ SMTP connection: OK
✅ Test email sent: OK
✅ Test email received: OK
```

---

## 4️⃣ FLUJO DE ACTIVACIÓN

```
┌─────────────────────────────────────────────────────────────┐
│                    FASE 6: ACTIVATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. PRE-CHECK                                                │
│     ├── Verificar FASE 1-5 completadas                       │
│     ├── Verificar credenciales en secrets/                   │
│     └── Verificar puertos disponibles                        │
│                                                              │
│  2. INICIAR GATEWAY                                          │
│     ├── systemctl start openclaw                             │
│     ├── Esperar 30 segundos                                   │
│     └── Verificar health                                      │
│                                                              │
│  3. VALIDAR CANALES                                          │
│     ├── WhatsApp                                              │
│     ├── Telegram                                              │
│     ├── Discord                                               │
│     └── Email                                                 │
│                                                              │
│  4. SMOKE TESTS                                              │
│     ├── Gateway health                                        │
│     ├── Modelo responde                                       │
│     ├── Habilidades básicas                                   │
│     └── Fallback funciona                                     │
│                                                              │
│  5. BACKUP INICIAL                                           │
│     ├── Snapshot de config                                    │
│     ├── Backup de secrets                                     │
│     └── Guardar estado                                        │
│                                                              │
│  6. REGISTRO                                                 │
│     ├── Registrar en dashboard                                │
│     ├── Documentar accesos                                    │
│     └── Guardar rollback plan                                │
│                                                              │
│  7. ENTREGA                                                  │
│     ├── Documentación al cliente                              │
│     ├── Credenciales de acceso                                │
│     └── Plan de soporte                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 5️⃣ SCRIPTS NECESARIOS

| Script | Propósito |
|--------|-----------|
| `activation.sh` | Script principal de activación |
| `smoke-test.sh` | Ejecutar todos los smoke tests |
| `rollback.sh` | Restaurar estado anterior |
| `register-dashboard.sh` | Registrar en dashboard |
| `backup-config.sh` | Crear backup de configuración |

---

## 6️⃣ VALIDACIONES PRE-ACTIVACIÓN

| # | Validación | Comando | Critico |
|---|------------|---------|---------|
| 1 | FASE 1 completa | `test -f phases/01-pre-flight/AUDITORIA.md` | ✅ |
| 2 | FASE 2 completa | `test -f phases/02-setup-users/AUDITORIA.md` | ✅ |
| 3 | FASE 3 completa | `test -f phases/03-gateway-install/AUDITORIA.md` | ✅ |
| 4 | FASE 4 completa | `test -f phases/04-identity-fleet/AUDITORIA.md` | ✅ |
| 5 | FASE 5 completa | `test -f phases/05-bot-config/AUDITORIA.md` | ✅ |
| 6 | Secrets existen | `test -d ~/.openclaw/secrets/` | ✅ |
| 7 | Puerto disponible | `ss -tlnp | grep 18789` | ✅ |
| 8 | Gateway instalado | `systemctl status openclaw` | ✅ |

---

## 7️⃣ CASOS DE ERROR

| Error | Solución |
|-------|----------|
| Puerto ocupado | Matar proceso o cambiar puerto |
| Gateway no inicia | Revisar logs, verificar config |
| WhatsApp no conecta | Re-escanear QR |
| Telegram no responde | Verificar token y webhook |
| Email falla | Verificar IMAP/SMTP en FASE 5 |
| Modelo no carga | Verificar API key de Ollama |

---

## 8️⃣ ROLLBACK PLAN

Si algo falla:

```bash
# 1. Detener gateway
systemctl stop openclaw

# 2. Restaurar config
cp -r ~/.openclaw/backup/pre-activation/* ~/.openclaw/

# 3. Reiniciar gateway
systemctl start openclaw

# 4. Verificar estado
systemctl status openclaw
```

---

## 9️⃣ CHECKLIST DE ENTREGA

| # | Item | Responsable |
|---|------|-------------|
| 1 | Gateway activo | Sistema |
| 2 | Todos los canales funcionan | Sistema |
| 3 | Smoke tests pasan | Sistema |
| 4 | Backup creado | Sistema |
| 5 | Documentación entregada | Sistema |
| 6 | Credenciales entregadas | Sistema |
| 7 | Plan de rollback documentado | Sistema |
| 8 | Soporte inicial explicado | Sistema |

---

## 🔟 SIGUIENTE PASO

**FASE 7: DOCUMENTACIÓN FINAL** → Entrega completa al cliente.

---

*Análisis completado - FASE 6 ACTIVATION*