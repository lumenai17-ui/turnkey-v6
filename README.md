# TURNKEY v6 — Despliegue Automatizado de Agentes

![Version](https://img.shields.io/badge/version-6.0.0-blue)
![Status](https://img.shields.io/badge/status-functional-green)
![License](https://img.shields.io/badge/license-MIT-green)

## 🚀 ¿Qué es?

Turnkey v6 es el sistema de despliegue automatizado de **Lumen AI**. Transforma un formulario de configuración en un agente de IA completamente funcional desplegado en un VPS.

El cliente llena un formulario → Turnkey hace el resto → Agente listo.

## 📊 Estado Real del Proyecto

| Fase | Nombre | Estado | Scripts | Líneas de código |
|------|--------|--------|---------|------------------|
| 01 | Pre-Flight | ✅ Funcional | `pre-flight.sh` + 3 helpers | ~400 |
| 02 | Setup Users | ✅ Funcional | `setup-users.sh` + 5 helpers | ~900 |
| 03 | Gateway Install | ✅ Funcional | `gateway-install.sh` + 2 helpers | ~500 |
| 04 | Identity Fleet | ✅ Funcional | 4 scripts (identity, fleet, skills, knowledge) | ~2,400 |
| 05 | Bot Config | ✅ Funcional | 4 scripts (telegram, email, api-keys, validate) | ~1,700 |
| 06 | Activation | ✅ Funcional | `activation.sh` + `rollback.sh` | ~400 |
| — | **Master** | ✅ Funcional | `turnkey.sh` | ~350 |

**Total: ~6,650 líneas de bash** en 24 scripts ejecutables.

## 🛠️ Quick Start

### Con archivo de configuración

```bash
# Clonar
git clone https://github.com/lumenai17-ui/turnkey-v6.git
cd turnkey-v6

# Dry-run (simula sin cambiar nada)
./turnkey.sh --config examples/restaurant.json --dry-run

# Despliegue real
./turnkey.sh --config mi-agente.json

# Desde una fase específica
./turnkey.sh --config mi-agente.json --from-phase 4
```

### Modo interactivo

```bash
cd phases/01-pre-flight
./pre-flight.sh --interactive
```

## 📁 Estructura

```
turnkey-v6/
├── turnkey.sh                    ← Script maestro (orquesta todo)
├── examples/
│   └── restaurant.json           ← Ejemplo de config para restaurante
├── phases/
│   ├── 01-pre-flight/            ← Validación del entorno
│   │   ├── pre-flight.sh
│   │   └── scripts/
│   ├── 02-setup-users/           ← Crear usuario del agente
│   │   ├── setup-users.sh
│   │   └── scripts/
│   ├── 03-gateway-install/       ← Instalar OpenClaw Gateway
│   │   ├── gateway-install.sh
│   │   └── scripts/
│   ├── 04-identity-fleet/        ← Identidad + modelos + skills
│   │   ├── scripts/
│   │   │   ├── setup-identity.sh
│   │   │   ├── setup-fleet.sh
│   │   │   ├── setup-skills.sh
│   │   │   └── process-knowledge.sh
│   │   ├── FLEET.json
│   │   └── skills-bundles.json
│   ├── 05-bot-config/            ← Canales (Telegram, Email)
│   │   └── scripts/
│   │       ├── bot-config.sh
│   │       ├── setup-telegram.sh
│   │       ├── setup-email.sh
│   │       ├── setup-api-keys.sh
│   │       └── validate-channels.sh
│   └── 06-activation/            ← Activar y verificar
│       └── scripts/
│           ├── activation.sh
│           └── rollback.sh
└── README.md
```

## 📋 Las 6 Fases

### Fase 1: Pre-Flight
Valida el entorno: dependencias, recursos (RAM, CPU, disco), API keys, y genera `turnkey-config.json`.

### Fase 2: Setup Users
Crea usuario `bee-{nombre}`, directorios `~/.openclaw/`, y credenciales seguras.

### Fase 3: Gateway Install
Detecta/instala OpenClaw Gateway, valida Node.js, configura puerto y systemd.

### Fase 4: Identity + Fleet
- **Identity:** Genera SOUL.md, USER.md, MEMORY.md, HEART.md, DOPAMINE.md
- **Fleet:** Configura 13 modelos con fallbacks (GLM-5, DeepSeek, Qwen, Gemma, etc.)
- **Skills:** 25 core + 14 opcionales + bundle por tipo de negocio
- **Knowledge:** Procesa PDFs, Excel, Docs del cliente

### Fase 5: Bot Config
Configura canales: Telegram (con BotFather guide), Email (IMAP/SMTP/Resend), API keys.

### Fase 6: Activation
Inicia servicios, ejecuta 5 smoke tests, genera reporte de activación, soporta rollback.

## 🏢 Bundles por Tipo de Negocio

| Tipo | Skills del Bundle |
|------|-------------------|
| **Restaurante** | menú, reservas, pedidos, horarios, delivery |
| **Hotel** | reservas, disponibilidad, habitaciones, check-in |
| **Tienda** | inventario, productos, pedidos, pagos, envíos |
| **Servicios** | citas, calendario, reminders, seguimiento |
| **Genérico** | FAQ, contacto, horarios, info |

## 🔧 Requisitos del VPS

- **OS:** Ubuntu 22.04+ / Debian 12+
- **RAM:** 2GB mínimo (4GB recomendado)
- **Disco:** 20GB+
- **Node.js:** v18+
- **Herramientas:** `jq`, `curl`, `bash 4+`

## 📄 Licencia

MIT — Lumen AI © 2026
