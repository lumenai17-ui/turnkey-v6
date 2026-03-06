# 🔍 PROPUESTA AUDITORÍA ESCALONADA - TURNKEY v6

**Objetivo:** Verificar si el constructor de agentes funcionará correctamente
**Método:** 6 FASES × 5 CAPAS = 30 auditorías secuenciales
**Modalidad:** Resultado de FASE N alimenta FASE N+1

---

## 🎯 CONCEPTO

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUJO DE AUDITORÍA                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  FASE 1 PRE-FLIGHT                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ CAPA 1: Documentación → ⬜                               │   │
│  │ CAPA 2: Código         → ⬜                               │   │
│  │ CAPA 3: Dependencias   → ⬜                               │   │
│  │ CAPA 4: Flujo          → ⬜                               │   │
│  │ CAPA 5: Integración    → ⬜                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│                    ┌─────────────┐                               │
│                    │ RESULTADO:  │                               │
│                    │ ✓ APROBADO  │ → Continúa                   │
│                    │ ⚠ CON OBS.  │ → Corregir → Repetir         │
│                    │ ✗ RECHAZADO  │ → Reparar → Repetir         │
│                    └─────────────┘                               │
│                           │                                      │
│                           ▼                                      │
│  FASE 2 SETUP USERS                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ CAPA 1-5...                                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                      │
│                           ▼                                      │
│  FASE 3 ... FASE 6                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 ESTRUCTURA DE TRABAJO

### Por cada FASE:

| Paso | Acción | Resultado |
|------|--------|-----------|
| 1 | Capa 1: Documentación | ⬜ Puntuación 1-10 |
| 2 | Capa 2: Código | ⬜ Puntuación 1-10 |
| 3 | Capa 3: Dependencias | ⬜ Puntuación 1-10 |
| 4 | Capa 4: Flujo | ⬜ Puntuación 1-10 |
| 5 | Capa 5: Integración | ⬜ Puntuación 1-10 |
| 6 | **Consolidado FASE** | **Promedio + Decisión** |

### Decisión por FASE:

| Resultado | Acción |
|-----------|--------|
| ✅ **APROBADO** (≥8/10) | Continuar a siguiente FASE |
| ⚠️ **CON OBSERVACIONES** (6-7/10) | Corregir menores y continuar |
| ❌ **RECHAZADO** (<6/10) | PARAR, reparar, repetir FASE |

---

## 🤖 LOS 5 AGENTES (Activados por FASE)

### 📚 AGENTE 1: BIBLIOTECARIO
**Capa: Documentación**

**Pregunta central:** ¿Hay suficiente documentación para ejecutar esta fase?

**Revisa por fase:**
- README.md existe y es claro
- Comentarios en scripts
- Ejemplos de inputs/outputs
- Troubleshooting específico

---

### 🔧 AGENTE 2: INGENIERO
**Capa: Código**

**Pregunta central:** ¿Los scripts de esta fase son robustos?

**Revisa por fase:**
- Manejo de errores
- Validación de inputs
- Permisos de archivos
- Rollback implementado

---

### 🔗 AGENTE 3: ARQUITECTO
**Capa: Dependencias**

**Pregunta central:** ¿Esta fase tiene todo lo que necesita?

**Revisa por fase:**
- Prerequisitos de la fase anterior
- Variables de entorno requeridas
- Archivos de configuración
- APIs externas necesarias

---

### 🚦 AGENTE 4: VERIFICADOR
**Capa: Flujo**

**Pregunta central:** ¿Esta fase se ejecuta en el orden correcto?

**Revisa por fase:**
- Pre-condiciones verificadas
- Post-condiciones definidas
- Estados de error manejados
- Checklists de validación

---

### 🎯 AGENTE 5: INTEGRADOR
**Capa: Integración**

**Pregunta central:** ¿Esta fase se integra bien con las demás?

**Revisa por fase:**
- Entradas de fase anterior correctas
- Salidas para fase siguiente correctas
- Puntos de falla identificados
- Rollback entre fases

---

## 📋 CHECKLIST POR FASE

---

### 🟦 FASE 1: PRE-FLIGHT

**Objetivo:** Validar prerequisitos del sistema

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md existe y explica propósito | ⬜ |
| 1.2 | INPUTS.md lista todos los campos | ⬜ |
| 1.3 | Scripts tienen comentarios | ⬜ |
| 1.4 | Ejemplos de outputs | ⬜ |
| 1.5 | Errores comunes documentados | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | Scripts con `set -e` | ⬜ |
| 2.2 | Validación de sistema operativo | ⬜ |
| 2.3 | Validación de recursos (RAM, CPU) | ⬜ |
| 2.4 | Validación de puertos | ⬜ |
| 2.5 | Mensajes de error claros | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Lista de paquetes requeridos | ⬜ |
| 3.2 | Versión mínima de cada paquete | ⬜ |
| 3.3 | Validación de APIs externas | ⬜ |
| 3.4 | Fallback si falta algo | ⬜ |
| 3.5 | Documentación de prerequisitos | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta primero siempre | ⬜ |
| 4.2 | Genera output para FASE 2 | ⬜ |
| 4.3 | No requiere inputs de usuario (automático) | ⬜ |
| 4.4 | Checklist de validación claro | ⬜ |
| 4.5 | AUDITORIA.md refleja checks reales | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | Output usable por FASE 2 | ⬜ |
| 5.2 | No rompe si se ejecuta múltiples veces | ⬜ |
| 5.3 | Rollback disponible | ⬜ |
| 5.4 | Logs guardados para debugging | ⬜ |
| 5.5 | Estados guardados en archivo | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 1

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

### 🟦 FASE 2: SETUP USERS

**Objetivo:** Configurar usuarios del sistema

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md explica creación de usuarios | ⬜ |
| 1.2 | Formato de usuario documentado | ⬜ |
| 1.3 | Permisos explicados | ⬜ |
| 1.4 | Ejemplos de usuarios | ⬜ |
| 1.5 | Troubleshooting de permisos | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | Validación de usuario existente | ⬜ |
| 2.2 | Creación segura de contraseñas | ⬜ |
| 2.3 | Manejo de permisos | ⬜ |
| 2.4 | Idempotencia (no duplicar usuarios) | ⬜ |
| 2.5 | Rollback de usuario creado | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Requiere FASE 1 completada | ⬜ |
| 3.2 | Valida output de FASE 1 | ⬜ |
| 3.3 | Permisos del sistema verificados | ⬜ |
| 3.4 | No requiere APIs externas | ⬜ |
| 3.5 | Documentación de usuarios creados | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta después de FASE 1 | ⬜ |
| 4.2 | Genera status/users-status.json | ⬜ |
| 4.3 | Valida usuarios creados | ⬜ |
| 4.4 | Continúa si usuario ya existe | ⬜ |
| 4.5 | AUDITORIA.md refleja checks | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | Usuarios usables por FASE 3 | ⬜ |
| 5.2 | No afecta FASE 1 si falla | ⬜ |
| 5.3 | Estado guardado para FASE 3 | ⬜ |
| 5.4 | Logs claros | ⬜ |
| 5.5 | Rollback limpio | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 2

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

### 🟦 FASE 3: GATEWAY INSTALL

**Objetivo:** Instalar OpenClaw Gateway

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md explica instalación | ⬜ |
| 1.2 | Requisitos de sistema documentados | ⬜ |
| 1.3 | Puertos y servicios explicados | ⬜ |
| 1.4 | Troubleshooting de instalación | ⬜ |
| 1.5 | URLs de referencia | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | Detección de gateway existente | ⬜ |
| 2.2 | Instalación automatizada | ⬜ |
| 2.3 | Validación de instalación | ⬜ |
| 2.4 | Inicio del servicio | ⬜ |
| 2.5 | Rollback de instalación | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Requiere FASE 1-2 completadas | ⬜ |
| 3.2 | Valida usuarios del sistema | ⬜ |
| 3.3 | Puertos disponibles | ⬜ |
| 3.4 | Paquetes del sistema | ⬜ |
| 3.5 | API key de LLM | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta después de FASE 2 | ⬜ |
| 4.2 | Valida gateway corriendo | ⬜ |
| 4.3 | Health check implementado | ⬜ |
| 4.4 | Logs de instalación | ⬜ |
| 4.5 | AUDITORIA.md completo | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | Gateway usable por FASE 4 | ⬜ |
| 5.2 | Puerto accesible | ⬜ |
| 5.3 | API responde | ⬜ |
| 5.4 | Modelos disponibles | ⬜ |
| 5.5 | No deja procesos zombies | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 3

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

### 🟦 FASE 4: IDENTITY FLEET

**Objetivo:** Configurar identidad del agente

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md explica identidad | ⬜ |
| 1.2 | FLEET.json documentado | ⬜ |
| 1.3 | Habilidades explicadas | ⬜ |
| 1.4 | Templates de ejemplo | ⬜ |
| 1.5 | Troubleshooting de configuración | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | Validación de configuración | ⬜ |
| 2.2 | Scripts de setup | ⬜ |
| 2.3 | Generación de archivos | ⬜ |
| 2.4 | Validación de JSON | ⬜ |
| 2.5 | Rollback de configuración | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Requiere FASE 3 (gateway) | ⬜ |
| 3.2 | Modelos disponibles | ⬜ |
| 3.3 | APIs de habilidades | ⬜ |
| 3.4 | Config de identidad completa | ⬜ |
| 3.5 | Sin dependencias circulares | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta después de FASE 3 | ⬜ |
| 4.2 | Valida FLEET.json generado | ⬜ |
| 4.3 | Habilidades cargadas | ⬜ |
| 4.4 | Identidad verificada | ⬜ |
| 4.5 | AUDITORIA.md completo | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | FLEET.json usable por FASE 5 | ⬜ |
| 5.2 | Modelos accesibles | ⬜ |
| 5.3 | Habilidades funcionan | ⬜ |
| 5.4 | No sobrescribe config anterior | ⬜ |
| 5.5 | Backup de config | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 4

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

### 🟦 FASE 5: BOT CONFIG

**Objetivo:** Configurar canales (WhatsApp, Telegram, Email)

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md explica canales | ⬜ |
| 1.2 | Credenciales documentadas | ⬜ |
| 1.3 | Ejemplos de configuración | ⬜ |
| 1.4 | Troubleshooting por canal | ⬜ |
| 1.5 | Validación de canales explicada | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | Scripts de configuración robustos | ⬜ |
| 2.2 | Validación de credenciales | ⬜ |
| 2.3 | Manejo de errores por canal | ⬜ |
| 2.4 | Secrets protegidos | ⬜ |
| 2.5 | Rollback por canal | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Requiere FASE 4 completada | ⬜ |
| 3.2 | Tokens de Telegram | ⬜ |
| 3.3 | QR de WhatsApp | ⬜ |
| 3.4 | Credenciales Email IMAP/SMTP | ⬜ |
| 3.5 | APIs externas (Resend, etc.) | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta después de FASE 4 | ⬜ |
| 4.2 | Valida cada canal | ⬜ |
| 4.3 | Continúa si canal falla | ⬜ |
| 4.4 | Logs por canal | ⬜ |
| 4.5 | AUDITORIA.md por canal | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | Canales accesibles en FASE 6 | ⬜ |
| 5.2 | Config no rompe identidad | ⬜ |
| 5.3 | WhatsApp funciona | ⬜ |
| 5.4 | Telegram funciona | ⬜ |
| 5.5 | Email funciona | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 5

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

### 🟦 FASE 6: ACTIVATION

**Objetivo:** Activar el agente completo

#### CAPA 1: Documentación (Bibliotecario)
| # | Check | Estado |
|---|-------|--------|
| 1.1 | README.md explica activación | ⬜ |
| 1.2 | Checklist de activación | ⬜ |
| 1.3 | Rollback documentado | ⬜ |
| 1.4 | Smoke tests explicados | ⬜ |
| 1.5 | Troubleshooting post-activación | ⬜ |

**Puntuación:** ___/10

#### CAPA 2: Código (Ingeniero)
| # | Check | Estado |
|---|-------|--------|
| 2.1 | activation.sh robusto | ⬜ |
| 2.2 | Validación de prerequisitos | ⬜ |
| 2.3 | Rollback automático | ⬜ |
| 2.4 | Logs detallados | ⬜ |
| 2.5 | Idempotente | ⬜ |

**Puntuación:** ___/10

#### CAPA 3: Dependencias (Arquitecto)
| # | Check | Estado |
|---|-------|--------|
| 3.1 | Requiere FASE 1-5 completadas | ⬜ |
| 3.2 | Valida AUDITORIA.md de cada fase | ⬜ |
| 3.3 | Gateway corriendo | ⬜ |
| 3.4 | Canales activos | ⬜ |
| 3.5 | Modelo accesible | ⬜ |

**Puntuación:** ___/10

#### CAPA 4: Flujo (Verificador)
| # | Check | Estado |
|---|-------|--------|
| 4.1 | Se ejecuta último | ⬜ |
| 4.2 | Smoke tests pasan | ⬜ |
| 4.3 | rollback.sh disponible | ⬜ |
| 4.4 | Estados guardados | ⬜ |
| 4.5 | AUDITORIA.md final | ⬜ |

**Puntuación:** ___/10

#### CAPA 5: Integración (Integrador)
| # | Check | Estado |
|---|-------|--------|
| 5.1 | Todo funciona junto | ⬜ |
| 5.2 | No hay SPOF | ⬜ |
| 5.3 | Monitoreo disponible | ⬜ |
| 5.4 | Actualización posible | ⬜ |
| 5.5 | Rollback total funciona | ⬜ |

**Puntuación:** ___/10

#### RESULTADO FASE 6

| Capa | Puntuación |
|------|------------|
| Documentación | /10 |
| Código | /10 |
| Dependencias | /10 |
| Flujo | /10 |
| Integración | /10 |
| **PROMEDIO** | **/10** |

**Decisión:** [ ] APROBADO [ ] CON OBS. [ ] RECHAZADO

---

## 📊 RESUMEN FINAL

| FASE | Doc | Código | Deps | Flujo | Int | Promedio | Decisión |
|------|-----|--------|------|-------|-----|----------|----------|
| 1 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| 2 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| 3 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| 4 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| 5 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| 6 | /10 | /10 | /10 | /10 | /10 | /10 | [ ] |
| **TOTAL** | | | | | | **/10** | [ ] |

---

## 🎯 FLUJO DE EJECUCIÓN

```
INICIO
  │
  ▼
FASE 1 ──► CAPAS 1-5 ──► RESULTADO
  │                           │
  │                      ┌────┴────┐
  │                      │ ≥8: OK  │──► FASE 2
  │                      │ 6-7: FIX│──► Corregir → Repetir
  │                      │ <6: STOP│──► Reparar → Repetir
  │                      └─────────┘
  ▼
FASE 2 ──► CAPAS 1-5 ──► RESULTADO
  │
  ▼
FASE 3 ──► CAPAS 1-5 ──► RESULTADO
  │
  ▼
FASE 4 ──► CAPAS 1-5 ──► RESULTADO
  │
  ▼
FASE 5 ──► CAPAS 1-5 ──► RESULTADO
  │
  ▼
FASE 6 ──► CAPAS 1-5 ──► RESULTADO
  │
  ▼
FIN ──► INFORME FINAL
```

---

## 🚀 PROPUESTA DE EJECUCIÓN

### Opción A: Auditoría Completa (Yo la ejecuto)

1. **FASE 1:** Ejecuto 5 capas → Resultado
2. Si APROBADO → **FASE 2:** Ejecuto 5 capas → Resultado
3. Si APROBADO → **FASE 3:** ...
4. Continuar hasta FASE 6
5. Generar informe final

### Opción B: Auditoría Externa (Tú usas otros agentes)

1. Te doy los 5 prompts
2. Los usas con Claude/GPT-4/DeepSeek
3. Me das los resultados
4. Yo consolido

---

## 📝 ¿QUIERES QUE EJECUTE LA AUDITORÍA?

**¿Empiezo con FASE 1?**

Responde:
- **"EMPIEZA"** → Ejecuto FASE 1 (5 capas) ahora
- **"MODIFICA"** → Ajusto la propuesta
- **"EXTERNA"** → Te doy los prompts para otros agentes