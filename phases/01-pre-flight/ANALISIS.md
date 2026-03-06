# ANÁLISIS - FASE 1: PRE-FLIGHT

**Fecha:** 2026-03-05

---

## 🔍 1. QUÉ HACE

### Objetivo
Validar que el entorno tiene todo lo necesario ANTES de instalar o crear nada.

### Sub-fases
1. Detectar tipo de despliegue (servidor dedicado vs VPS)
2. Validar recursos según tipo (RAM, CPU, Disco, Puertos)
3. Validar accesos y permisos (root, systemd, firewall)
4. Validar información requerida (API keys, canales, skills)
5. Generar configuración inicial

---

## 🔍 2. QUÉ ESTÁ AUTOMATIZADO VS MANUAL

### Automatizado (lo que debería ser)
| Función | Estado | Notas |
|---------|--------|-------|
| Detectar tipo de entorno | ⏳ No existe | Debe crearse |
| Validar RAM/CPU | ⏳ No existe | Debe crearse |
| Validar puertos libres | ⏳ No existe | Debe crearse |
| Validar API key Ollama | ⏳ No existe | Debe crearse |
| Generar config JSON | ⏳ No existe | Debe crearse |

### Manual (lo que existe)
| Función | Estado | Archivo |
|---------|--------|---------|
| Instalar dependencias | ✅ Existe | `pre-install.sh` (fuera de esta fase) |
| Crear usuarios | ❌ Hardcoded | En documentación V5 |
| Configurar OpenClaw | ⏳ Parcial | `setup-openclaw.sh` |

### Brecha identificada
- **V5 documenta PRE-FLIGHT** pero no hay script ejecutable
- **`pre-install.sh` existe** pero es de instalación, no validación
- **Falta crear** todo el sistema de validación

---

## 🔍 3. QUÉ PUEDE FALLAR

### Errores críticos (no puede continuar)
| Error | Causa | Solución |
|-------|-------|----------|
| Sin API key Ollama | Usuario no proporcionó | Pedir interactivamente |
| API key Ollama inválida | Key incorrecta | Error con mensaje claro |
| Sin acceso root/sudo | Permisos insuficientes | Error, requiere elevar permisos |
| Systemd no disponible | OS sin systemd | Error o modo alternativo |

### Warnings (puede continuar con confirmación)
| Warning | Causa | Solución |
|---------|-------|----------|
| RAM < mínimo | Servidor pequeño | Warning + pedir confirmación |
| CPU < mínimo | Pocos cores | Warning + pedir confirmación |
| Disco < mínimo | Poco espacio | Warning + advertir |
| Puerto base ocupado | Puerto en uso | Buscar siguiente disponible |
| Sin Brave API key | Falta key opcional | Deshabilitar web_search |
| Sin Telegram token | Falta configurar canal | Advertir, continuar |

### Edge cases
| Caso | Descripción | Manejo |
|------|-------------|--------|
| VPS con 1.5GB | Entre mínimo y recomendado | Warning, continuar |
| Sin SSH keys | Para acceso remoto | Warning, no crítico |
| Detrás de proxy | Conectividad limitada | Timeout más largo |
| Docker/LXC | Virtualización anidada | Detectar y advertir |

---

## 🔍 4. DEPENDENCIAS

### Dependencias de esta fase
| Dependencia | Tipo | Estado |
|-------------|------|--------|
| Acceso root/sudo | Crítica | Verificar |
| curl/wget | Requerida | Verificar o instalar |
| jq | Recomendada | Para JSON |
| netstat/ss | Requerida | Para puertos |

### Fases que dependen de esta
| Fase | Qué necesita de PRE-FLIGHT |
|------|---------------------------|
| 02-setup-users | Permisos, tipo de entorno |
| 03-gateway-install | Recursos validados, puertos |
| 04-identity-fleet | API keys validadas |
| 05-bot-config | Config inicial generada |
| 06-activation | Todo lo anterior |

---

## 📊 Estado del Análisis

| Sección | Estado |
|---------|--------|
| Qué hace | ✅ 100% |
| Automatizado vs Manual | ✅ 100% |
| Qué puede fallar | ✅ 100% |
| Dependencias | ✅ 100% |
| **TOTAL ANÁLISIS** | **✅ 100%** |

---

*Completado: 2026-03-05*