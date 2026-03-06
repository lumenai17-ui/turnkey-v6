# FASE 6: ACTIVATION - DISEÑO

**Versión:** 1.0.0
**Fecha:** 2026-03-06

---

## 🎯 ARQUITECTURA DE ACTIVACIÓN

```
                    ┌─────────────────────────────────────┐
                    │         FASE 6: ACTIVATION          │
                    └─────────────────────────────────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         │                            │                            │
    ┌────▼────┐                  ┌────▼────┐                  ┌────▼────┐
    │ PRE-CHECK│                  │ ACTIVATE│                  │VALIDATE │
    └────┬────┘                  └────┬────┘                  └────┬────┘
         │                            │                            │
    ┌────▼────┐                  ┌────▼────┐                  ┌────▼────┐
    │ FASE 1-5 │                  │ GATEWAY  │                  │  SMOKE  │
    │ completas │                  │ CHANNELS │                  │  TESTS  │
    │ secrets   │                  │ MODEL    │                  │  SKILLS │
    └─────────┘                  └─────────┘                  └─────────┘
```

---

## 📋 SCRIPT PRINCIPAL: activation.sh

### Estructura

```bash
#!/bin/bash
# activation.sh - FASE 6: Activar el agente completo

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funciones
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. PRE-CHECK
pre_check() {
    log_info "Verificando pre-requisitos..."
    # Verificar FASE 1-5 completadas
    # Verificar secrets
    # Verificar puertos
}

# 2. INICIAR GATEWAY
start_gateway() {
    log_info "Iniciando OpenClaw Gateway..."
    systemctl start openclaw
    sleep 30
}

# 3. VALIDAR CANALES
validate_channels() {
    log_info "Validando canales..."
    ./scripts/validate-channels.sh --all
}

# 4. SMOKE TESTS
smoke_tests() {
    log_info "Ejecutando smoke tests..."
    ./scripts/smoke-test.sh
}

# 5. BACKUP
backup_config() {
    log_info "Creando backup inicial..."
    ./scripts/backup-config.sh
}

# 6. REGISTRO
register_dashboard() {
    log_info "Registrando en dashboard..."
    ./scripts/register-dashboard.sh
}

# Main
main() {
    log_info "=== FASE 6: ACTIVATION ==="
    pre_check
    start_gateway
    validate_channels
    smoke_tests
    backup_config
    register_dashboard
    log_info "=== ACTIVACIÓN COMPLETADA ==="
}

main "$@"
```

---

## 📋 SCRIPT: smoke-test.sh

### Tests Incluidos

| # | Test | Comando | Estado |
|---|------|---------|--------|
| 1 | Gateway health | `curl localhost:18789/health` | ✅ |
| 2 | Modelo responde | Test prompt | ✅ |
| 3 | WhatsApp activo | Validar sesión | ✅ |
| 4 | Telegram responde | `/start` al bot | ✅ |
| 5 | Discord conectado | Verificar intents | ✅ |
| 6 | Email IMAP | Conexión IMAP | ✅ |
| 7 | Email SMTP | Test send | ✅ |
| 8 | Memoria persiste | Guardar y leer | ✅ |
| 9 | Web search | Búsqueda test | ✅ |
| 10 | PDF generate | Crear PDF | ✅ |

---

## 📋 SCRIPT: rollback.sh

### Estructura

```bash
#!/bin/bash
# rollback.sh - Restaurar estado anterior

ROLLBACK_DIR="$HOME/.openclaw/backup/pre-activation"

echo "=== ROLLBACK FASE 6 ==="

# 1. Detener gateway
echo "[1/4] Deteniendo gateway..."
systemctl stop openclaw

# 2. Restaurar config
echo "[2/4] Restaurando configuración..."
cp -r "$ROLLBACK_DIR/config/*" ~/.openclaw/config/
cp -r "$ROLLBACK_DIR/secrets/*" ~/.openclaw/secrets/

# 3. Reiniciar gateway
echo "[3/4] Reiniciando gateway..."
systemctl start openclaw

# 4. Verificar
echo "[4/4] Verificando estado..."
systemctl status openclaw

echo "=== ROLLBACK COMPLETADO ==="
```

---

## 📋 CONFIG: smoke-tests.json

```json
{
  "version": "1.0.0",
  "tests": [
    {
      "id": "gateway_health",
      "name": "Gateway Health Check",
      "command": "curl -s http://localhost:18789/health",
      "expected": {"status": "healthy"},
      "critical": true
    },
    {
      "id": "model_response",
      "name": "Model Response Test",
      "command": "curl -X POST http://localhost:18789/v1/chat/completions -d '{\"model\":\"glm-5\",\"messages\":[{\"role\":\"user\",\"content\":\"test\"}]}'",
      "expected": {"choices": [{"message": {"content": "*"}}]},
      "critical": true
    },
    {
      "id": "whatsapp_session",
      "name": "WhatsApp Session Active",
      "command": "validate-channels.sh --whatsapp --json",
      "expected": {"whatsapp": {"session": "active"}},
      "critical": true
    },
    {
      "id": "telegram_bot",
      "name": "Telegram Bot Responds",
      "command": "validate-channels.sh --telegram --json",
      "expected": {"telegram": {"bot": "valid"}},
      "critical": true
    },
    {
      "id": "discord_connection",
      "name": "Discord Bot Connected",
      "command": "validate-channels.sh --discord --json",
      "expected": {"discord": {"connection": "active"}},
      "critical": false
    },
    {
      "id": "email_imap",
      "name": "Email IMAP Connection",
      "command": "validate-channels.sh --email --imap --json",
      "expected": {"email": {"imap": "connected"}},
      "critical": true
    },
    {
      "id": "email_smtp",
      "name": "Email SMTP Connection",
      "command": "validate-channels.sh --email --smtp --json",
      "expected": {"email": {"smtp": "connected"}},
      "critical": true
    },
    {
      "id": "memory_persist",
      "name": "Memory Persistence",
      "command": "memory_save_test && memory_read_test",
      "expected": {"success": true},
      "critical": false
    },
    {
      "id": "web_search",
      "name": "Web Search Works",
      "command": "curl -X POST http://localhost:18789/tools/web_search -d '{\"query\":\"test\"}'",
      "expected": {"results": "*"},
      "critical": false
    },
    {
      "id": "pdf_generate",
      "name": "PDF Generation",
      "command": "curl -X POST http://localhost:18789/tools/pdf_generate -d '{\"content\":\"test\"}'",
      "expected": {"url": "*"},
      "critical": false
    }
  ]
}
```

---

## 🔄 FLUJO DE ROLLBACK

```
ERROR DETECTADO
      │
      ▼
┌─────────────────────┐
│  LOG DE ERROR       │
│  Guardar en logs/   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  EJECUTAR ROLLBACK  │
│  ./scripts/rollback.sh │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  RESTAURAR BACKUP   │
│  cp -r backup/*      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  REINICIAR GATEWAY  │
│  systemctl restart  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  NOTIFICAR          │
│  Alerta al equipo   │
└─────────────────────┘
```

---

## 📊 DASHBOARD DE ACTIVACIÓN

```
╔══════════════════════════════════════════════════════╗
║           FASE 6: ACTIVATION STATUS                  ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  PRE-CHECK                                           ║
║  ├── FASE 1-5 ............. [✅] PASSED             ║
║  ├── Secrets .............. [✅] PASSED             ║
║  └── Puerto 18789 ........ [✅] AVAILABLE           ║
║                                                      ║
║  GATEWAY                                              ║
║  ├── Start ............... [✅] RUNNING             ║
║  └── Health .............. [✅] HEALTHY              ║
║                                                      ║
║  CANALES                                              ║
║  ├── WhatsApp ............ [✅] ACTIVE              ║
║  ├── Telegram ............ [✅] ACTIVE              ║
║  ├── Discord ............. [✅] ACTIVE              ║
║  └── Email ............... [✅] ACTIVE              ║
║                                                      ║
║  SMOKE TESTS                                         ║
║  ├── Gateway health ....... [✅] PASSED             ║
║  ├── Model response ....... [✅] PASSED             ║
║  ├── WhatsApp test ......... [✅] PASSED             ║
║  ├── Telegram test ......... [✅] PASSED             ║
║  ├── Discord test .......... [✅] PASSED             ║
║  ├── Email IMAP ............ [✅] PASSED             ║
║  ├── Email SMTP ............ [✅] PASSED             ║
║  ├── Memory persist ........ [✅] PASSED             ║
║  ├── Web search ............ [✅] PASSED             ║
║  └── PDF generate .......... [✅] PASSED             ║
║                                                      ║
║  BACKUP                                               ║
║  └── Initial backup ....... [✅] CREATED             ║
║                                                      ║
║  REGISTRO                                             ║
║  └── Dashboard ............ [✅] REGISTERED          ║
║                                                      ║
║  ═══════════════════════════════════════════════    ║
║  TOTAL: 10/10 tests passed                           ║
║  STATUS: ✅ ACTIVATION COMPLETE                     ║
╚══════════════════════════════════════════════════════╝
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
phases/06-activation/
├── README.md
├── ANALISIS.md
├── DISEÑO.md
├── DECISIONES.md
├── CHECKLIST.md
├── EDGE-CASES.md
│
├── scripts/
│   ├── activation.sh
│   ├── smoke-test.sh
│   ├── rollback.sh
│   ├── backup-config.sh
│   └── register-dashboard.sh
│
├── config/
│   └── smoke-tests.json
│
├── examples/
│   └── (ejemplos)
│
└── logs/
    └── activation-TIMESTAMP.log
```

---

*Diseño completado - FASE 6 ACTIVATION*