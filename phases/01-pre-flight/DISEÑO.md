# DISEÑO - FASE 1: PRE-FLIGHT

**Estado:** ⏳ Pendiente de aprobación

---

## 🎨 1. DISEÑO DEL FLUJO

```
┌─────────────────────────────────────────────────────────────┐
│                    PRE-FLIGHT                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  INICIO                                                      │
│     │                                                        │
│     ▼                                                        │
│  1. CARGAR DEFAULTS                                          │
│     └─► Leer turnkey-defaults.json                          │
│     │                                                        │
│     ▼                                                        │
│  2. DETECTAR ENTORNO                                         │
│     ├─► ¿Servidor dedicado o VPS?                           │
│     └─► Aplicar estándares según tipo                        │
│     │                                                        │
│     ▼                                                        │
│  3. VALIDAR RECURSOS                                         │
│     ├─► RAM >= mínima según tipo                            │
│     ├─► CPU >= mínima según tipo                            │
│     ├─► Disco >= mínimo según tipo                          │
│     └─► Puertos libres en rango                             │
│     │                                                        │
│     ▼                                                        │
│  4. VALIDAR ACCESOS                                          │
│     ├─► root/sudo access                                     │
│     ├─► systemd disponible                                   │
│     └─► firewall/acceso puertos                             │
│     │                                                        │
│     ▼                                                        │
│  5. VALIDAR INFO REQUERIDA                                   │
│     ├─► API key Ollama (requerida)                          │
│     ├─► API key Brave (opcional)                            │
│     ├─► Telegram token (opcional)                           │
│     └─► Info del agente (defaults si falta)                 │
│     │                                                        │
│     ▼                                                        │
│  6. GENERAR RESUMEN                                          │
│     ├─► Mostrar configuración detectada                     │
│     ├─► Mostrar warnings                                    │
│     └─► Pedir confirmación                                  │
│     │                                                        │
│     ▼                                                        │
│  7. GUARDAR CONFIG                                           │
│     └─► turnkey-config.json, turnkey-env.json               │
│     │                                                        │
│     ▼                                                        │
│  FIN → Pasar a FASE 2                                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 2. DISEÑO DE SCRIPTS

### pre-flight.sh (principal)
```bash
#!/bin/bash
# pre-flight.sh - Validación completa antes de instalar
# Uso: ./pre-flight.sh [--config archivo] [--interactive]

OPCIONES:
  --config FILE     Usar archivo de configuración
  --interactive     Modo interactivo (preguntar lo faltante)
  --detect-only     Solo detectar, no validar
  --force           Continuar aunque haya warnings

OUTPUT:
  turnkey-env.json      Variables detectadas
  turnkey-config.json   Configuración final
  turnkey-status.json   Estado de la validación
  pre-flight.log        Log detallado
```

### scripts/detect-environment.sh
```bash
#!/bin/bash
# Detecta tipo de despliegue: servidor-dedicado o vps

SALIDA:
  TIPO="vps" | "dedicado"
  PROVIDER="aws"|"digitalocean"|"gcp"|"unknown" (si VPS)
```

### scripts/validate-resources.sh
```bash
#!/bin/bash
# Valida recursos según tipo de entorno

ENTRADA:
  TIPO (vps o dedicado)
  
SALIDA:
  RAM_OK=true|false
  CPU_OK=true|false
  DISK_OK=true|false
  PORTS_OK=true|false
  WARNINGS=[]
  ERRORS=[]
```

### scripts/validate-api-keys.sh
```bash
#!/bin/bash
# Valida API keys

ENTRADA:
  OLLAMA_API_KEY (requerida)
  BRAVE_API_KEY (opcional)
  
SALIDA:
  OLLAMA_VALID=true|false
  BRAVE_VALID=true|false
  MODELS_AVAILABLE=[]  # lista de modelos disponibles
```

---

## 🎨 3. DISEÑO DE CONFIG

### config/pre-flight-defaults.json
```json
{
  "resources": {
    "vps": {
      "ram_min_gb": 2,
      "ram_recommended_gb": 4,
      "cpu_min": 1,
      "disk_min_gb": 20
    },
    "dedicado": {
      "ram_min_gb": 16,
      "ram_recommended_gb": 32,
      "cpu_min": 4,
      "disk_min_gb": 100
    }
  },
  "required_ports": [18789, 18790, 18791, 18792, 18793],
  "validation": {
    "below_min": "warn_and_confirm",
    "below_recommended": "warn"
  }
}
```

### config/pre-flight-questions.txt
```
# Preguntas para modo interactivo

## Entorno
? Tipo de despliegue: (v)ps / (d)edicado [auto-detectar]

## Agente
? Nombre del agente [Agent-{timestamp}]: 
? Rol del agente [Asistente virtual]: 
? Emoji [🤖]: 

## API Keys
? API Key de Ollama Cloud [requerida]: 
? API Key de Brave Search [opcional]: 

## Canales
? Token de Telegram Bot [opcional]: 
? Tu Telegram User ID [opcional]: 

## Confirmación
? Configuración correcta? (s/n): 
```

---

## 🎨 4. DISEÑO DE OUTPUT

### turnkey-env.json (detectado)
```json
{
  "detected_at": "2026-03-05T12:00:00Z",
  "environment": {
    "type": "vps",
    "provider": "aws",
    "os": "Ubuntu 22.04",
    "kernel": "5.15.0-1019-aws"
  },
  "resources": {
    "ram_total_gb": 4,
    "ram_available_gb": 3.2,
    "cpu_cores": 2,
    "cpu_type": "vCPU",
    "disk_total_gb": 80,
    "disk_available_gb": 65
  },
  "network": {
    "hostname": "ip-172-31-45-123",
    "public_ip": "3.238.2.29",
    "ports_available": [18789, 18790, 18791, 18792, 18793]
  },
  "access": {
    "root": true,
    "sudo": true,
    "systemd": true,
    "firewall": "ufw"
  }
}
```

### turnkey-config.json (final)
```json
{
  "created_at": "2026-03-05T12:05:00Z",
  "agent": {
    "name": "Atlas",
    "role": "Asistente de viajes",
    "emoji": "🗺️",
    "port": 18789
  },
  "deployment": {
    "type": "vps",
    "provider": "aws"
  },
  "api_keys": {
    "ollama": "oll-xxxxxxxxxxxxx",
    "brave": "brave-xxxxxxxxxxxxx"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "bot_token": "botxxxxx",
      "allowed_users": ["123456789"]
    }
  },
  "skills": {
    "voicenote": true,
    "pdf_reader": true,
    "web_search": true
  },
  "models": {
    "primary": "ollamacloud/glm-5",
    "fallback": "ollamacloud/kimi-k2.5"
  }
}
```

### turnkey-status.json (estado)
```json
{
  "status": "passed_with_warnings",
  "passed_at": "2026-03-05T12:05:00Z",
  "checks": {
    "resources": {
      "status": "warning",
      "details": "RAM 4GB (recomendado: 8GB para mejor performance)"
    },
    "access": {
      "status": "passed"
    },
    "api_keys": {
      "status": "passed"
    },
    "channels": {
      "status": "passed",
      "warnings": ["Telegram sin token, canal deshabilitado temporalmente"]
    }
  },
  "warnings": 2,
  "errors": 0,
  "can_proceed": true
}
```

---

## 🎨 5. PENDIENTES DE DISEÑO

| # | Pregunta | Estado |
|---|----------|--------|
| 1 | ¿Agregar valores por defecto adicionales? | ⏳ |
| 2 | ¿Dónde ubicar turnkey-defaults.json? | ⏳ |
| 3 | ¿Validar API key Ollama durante pre-flight? | ⏳ |
| 4 | ¿Qué hacer si no hay API key de Ollama? | ⏳ |
| 5 | ¿Cómo manejar recursos por debajo del mínimo? | ⏳ |
| 6 | ¿Guardar aceptación de recursos insuficientes? | ⏳ |
| 7 | ¿En modo interactivo, preguntar solo lo faltante? | ⏳ |
| 8 | ¿Formato de input interactivo? | ⏳ |
| 9 | ¿Telegram por defecto o sin canales? | ⏳ |

---

*Estado: Pendiente de responder preguntas y aprobación*