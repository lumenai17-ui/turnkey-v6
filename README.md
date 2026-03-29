# TURNKEY v6.3 — Despliegue Automatizado de Agentes

![Version](https://img.shields.io/badge/version-6.3.0-blue)
![Status](https://img.shields.io/badge/status-functional-green)
![License](https://img.shields.io/badge/license-MIT-green)

## 🚀 ¿Qué es?

Turnkey v6.3 es el sistema de despliegue automatizado de **Lumen AI**. Transforma un formulario de configuración en un agente de IA completamente funcional desplegado en un VPS.

El cliente llena un formulario → Turnkey hace el resto → Agente listo.

## 🆕 Novedades en v6.3 (Production Layer)

| Feature | Descripción |
|---------|-------------|
| 🔁 **Swap automático** | 4GB swap con swappiness=10, idempotente |
| 🛡️ **Hardening** | UFW firewall + fail2ban + SSH hardening |
| 📊 **Tier profiles** | Detección automática: standard (≤4GB) / premium (>4GB) |
| ⚡ **Concurrencia** | Límites por tier (2 para 4GB, 3 para 8GB) |
| 🔄 **Auto-restart** | systemd `Restart=always`, RestartSec=5, loop protection |
| 🏥 **Health checks** | 8 tests (antes 5): +RAM baseline +automatizaciones |
| 💾 **Snapshots** | Configuración final guardada para recovery |
| 🔄 **System update** | apt update/upgrade automático en pre-flight |

## 📊 Estado Real del Proyecto

| Fase | Nombre | Estado | Scripts | Líneas de código |
|------|--------|--------|---------|------------------|
| 01 | Pre-Flight + Production Layer | ✅ Funcional | `pre-flight.sh` + 3 helpers | ~1,050 |
| 02 | Setup Users | ✅ Funcional | `setup-users.sh` + 5 helpers | ~900 |
| 03 | Gateway Install | ✅ Funcional | `gateway-install.sh` + 2 helpers | ~670 |
| 04 | Identity Fleet | ✅ Funcional | 4 scripts (identity, fleet, skills, knowledge) | ~2,400 |
| 05 | Bot Config | ✅ Funcional | 4 scripts (telegram, email, api-keys, validate) | ~1,700 |
| 06 | Activation | ✅ Funcional | `activation.sh` + `rollback.sh` | ~440 |
| — | **Master** | ✅ Funcional | `turnkey.sh` | ~660 |

**Total: ~7,820 líneas de bash** en 24 scripts ejecutables.

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

# Forzar un tier específico
./turnkey.sh --config mi-agente.json --tier premium
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
│   ├── 01-pre-flight/            ← Validación + Production Layer
│   │   ├── pre-flight.sh         ← Tier detect, swap, hardening, apt upgrade
│   │   └── scripts/
│   ├── 02-setup-users/           ← Crear usuario del agente
│   │   ├── setup-users.sh
│   │   └── scripts/
│   ├── 03-gateway-install/       ← Instalar OpenClaw Gateway
│   │   ├── gateway-install.sh    ← +concurrency limits, +auto-restart
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
│   └── 06-activation/            ← Activar + 8 health checks + snapshot
│       └── scripts/
│           ├── activation.sh     ← +RAM check, +auto check, +snapshot
│           └── rollback.sh
└── README.md
```

## 📋 Las 6 Fases + Production Layer

### Fase 1: Pre-Flight + Production Layer ⚡
Valida el entorno y aplica la **capa de producción obligatoria**:
1. **apt update/upgrade** — Sistema actualizado automáticamente
2. **Tier detection** — Detecta RAM y asigna tier (standard/premium)
3. **Swap setup** — 4GB swap idempotente con swappiness=10
4. **Hardening** — UFW (firewall), fail2ban (anti-brute-force), SSH (root/pass)
5. Valida dependencias, recursos, API keys, genera `turnkey-config.json` y `tier-profile.json`

### Fase 2: Setup Users
Crea usuario `bee-{nombre}`, directorios `~/.openclaw/`, y credenciales seguras.

### Fase 3: Gateway Install
Detecta/instala OpenClaw Gateway, configura puerto y systemd con:
- **maxConcurrent** basado en tier (2 para standard, 3 para premium)
- **Restart=always** con RestartSec=5
- **StartLimitBurst=3** previene restart loops infinitos

### Fase 4: Identity + Fleet
- **Identity:** Genera SOUL.md, USER.md, MEMORY.md, HEART.md, DOPAMINE.md
- **Fleet:** Configura 13 modelos con fallbacks (GLM-5, DeepSeek, Qwen, Gemma, etc.)
- **Skills:** 25 core + 14 opcionales + bundle por tipo de negocio
- **Knowledge:** Procesa PDFs, Excel, Docs del cliente

### Fase 5: Bot Config
Configura canales: Telegram (con BotFather guide), Email (IMAP/SMTP/Resend), API keys.

### Fase 6: Activation
Inicia servicios, ejecuta **8 health checks**, genera reporte y **snapshot de configuración**:
1. ✅ Archivos de configuración (JSON válido)
2. ✅ Archivos de identidad (SOUL.md, USER.md, HEART.md)
3. ✅ Health check del gateway (puerto + /health)
4. ✅ Validación de canales (Telegram token)
5. ✅ Estructura de directorios
6. ✅ Modelo LLM accesible
7. 🆕 **RAM base normal** (< 80% al inicio)
8. 🆕 **Automatizaciones cargadas**
+ 💾 **Snapshot** de toda la config para recovery

## 📊 Tier Profiles

| Aspecto | Standard (≤4GB) | Premium (>4GB) |
|---------|-----------------|----------------|
| **maxConcurrent** | 2 | 3 |
| **Swap** | 4GB | 4GB |
| **Skills** | 25 core + bundle | 25 core + bundle + extras |
| **Automatizaciones** | Moderadas | Más ricas |
| **Memoria** | Compacta | Más amplia |
| **BEE Tiers** | Tier 1 ($25) + Tier 2 ($40) | Tier 3 ($100) |

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

## 🔒 Orden de Ejecución del Builder

```
1.  Crear VPS
2.  Actualizar sistema (apt update/upgrade)    ← Production Layer
3.  Detectar tier (RAM → standard/premium)     ← Production Layer
4.  Crear swap (4GB, swappiness=10)            ← Production Layer
5.  Aplicar hardening (UFW, fail2ban, SSH)     ← Production Layer
6.  Instalar dependencias
7.  Instalar agente (OpenClaw Gateway)
8.  Inyectar config por tier + concurrencia    ← Production Layer
9.  Cargar identidad/memoria/skills
10. Registrar servicio con auto-restart        ← Production Layer
11. Ejecutar 8 health checks                   ← Production Layer
12. Guardar snapshot/config final              ← Production Layer
```

> **Regla maestra:** Primero hago el VPS estable, después meto el agente.

## 📄 Licencia

MIT — Lumen AI © 2026
