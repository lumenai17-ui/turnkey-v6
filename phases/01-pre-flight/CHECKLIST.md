# CHECKLIST - FASE 1: PRE-FLIGHT

**Estado:** ⏳ Pendiente de completar

---

## ✅ Validaciones de Entorno

### Tipo de Despliegue
| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| Detectar si es VPS | `detect-environment.sh` | "vps" o "dedicado" | ⏳ |
| Identificar provider | `detect-environment.sh` | "aws", "do", "gcp", etc. | ⏳ |

### Recursos - VPS
| Check | Comando | Mínimo | Recomendado | Estado |
|-------|---------|--------|-------------|--------|
| RAM total | `free -g` | 2GB | 4GB | ⏳ |
| RAM disponible | `free -g` | 1GB | 2GB | ⏳ |
| CPU cores | `nproc` | 1 | 2 | ⏳ |
| Disco disponible | `df -BG /` | 20GB | 50GB | ⏳ |

### Recursos - Servidor Dedicado
| Check | Comando | Mínimo | Recomendado | Estado |
|-------|---------|--------|-------------|--------|
| RAM total | `free -g` | 16GB | 32GB | ⏳ |
| RAM disponible | `free -g` | 8GB | 16GB | ⏳ |
| CPU cores físicos | `nproc` | 4 | 8 | ⏳ |
| Disco disponible | `df -BG /` | 100GB | 500GB | ⏳ |

### Puertos
| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| Puerto 18789 | `netstat -tuln` | Libre | ⏳ |
| Puerto 18790 | `netstat -tuln` | Libre | ⏳ |
| Puerto 18791 | `netstat -tuln` | Libre | ⏳ |
| Puerto 18792 | `netstat -tuln` | Libre | ⏳ |
| Puerto 18793 | `netstat -tuln` | Libre | ⏳ |

---

## ✅ Validaciones de Acceso

| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| Root o sudo | `id -u` | 0 o sudo válido | ⏳ |
| Systemd disponible | `systemctl --version` |OK | ⏳ |
| curl disponible | `curl --version` | OK | ⏳ |
| jq disponible | `jq --version` | OK (o instalar) | ⏳ |

---

## ✅ Validaciones de API Keys

| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| OLLAMA_API_KEY existe | `echo $OLLAMA_API_KEY` | No vacío | ⏳ |
| Ollama API responde | `curl api.ollama.com/v1/models` | HTTP 200 | ⏳ |
| BRAVE_API_KEY existe | `echo $BRAVE_API_KEY` | No vacío | ⏳ |
| Brave API responde | `curl api.search.brave.com` | HTTP 200 | ⏳ |

---

## ✅ Validaciones de Config

| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| Nombre agente definido | - | Vacío usa default | ⏳ |
| Template seleccionado | - | restaurant/hotel/retail/services/custom | ⏳ |
| Puerto asignado | - | Puerto libre del rango | ⏳ |

---

## ✅ Validaciones de Canales (Opcionales)

| Check | Comando | Esperado | Estado |
|-------|---------|----------|--------|
| Telegram bot token | - | Formato correcto | ⏳ |
| Telegram user ID | - | Numérico | ⏳ |
| WhatsApp config | - | Si aplica | ⏳ |
| Email SMTP config | - | Si aplica | ⏳ |

---

## ✅ Output Generado

| Archivo | Validación | Estado |
|---------|------------|--------|
| `turnkey-env.json` | JSON válido con entorno detectado | ⏳ |
| `turnkey-config.json` | JSON válido con config final | ⏳ |
| `turnkey-status.json` | JSON con estado de checks | ⏳ |
| `pre-flight.log` | Log detallado de la ejecución | ⏳ |

---

## ✅ Estado Final

| Resultado | Condición | Estado |
|-----------|-----------|--------|
| ✅ PASSED | 0 errores, 0 warnings | ⏳ |
| ⚠️ PASSED WITH WARNINGS | 0 errores, >0 warnings | ⏳ |
| ❌ FAILED | >0 errores | ⏳ |

---

*Completar cuando se ejecute el script*