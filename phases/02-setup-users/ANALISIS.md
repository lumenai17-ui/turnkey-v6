# FASE 2: SETUP USERS - ANÁLISIS

**Versión:** 1.0.0
**Fecha:** 2026-03-05
**Dependencias:** FASE 1 completada ✅

---

## 1️⃣ PROPÓSITO

Configurar usuarios y permisos necesarios para el agente OpenClaw.

---

## 2️⃣ QUÉ HACE ESTA FASE

| Función | Descripción |
|---------|-------------|
| Crear usuario del sistema | Usuario dedicado para el agente |
| Configurar permisos | Permisos necesarios para el agente |
| Crear directorios | Estructura de directorios del agente |
| Configurar sudo | Accesos sudo necesarios |
| Crear grupos | Grupos necesarios para la operación |

---

## 3️⃣ QUÉ ESTÁ AUTOMATIZADO

| Tarea | Automatizado | Método |
|-------|-------------|--------|
| Detectar usuario actual | ✅ | `whoami`, `id` |
| Crear usuario agente | ✅ | `useradd` |
| Crear directorios | ✅ | `mkdir -p` |
| Configurar permisos | ✅ | `chown`, `chmod` |
| Verificar sudo | ✅ | `sudo -l` |
| Validar entorno | ✅ | Scripts de FASE 1 |

---

## 4️⃣ QUÉ NO ESTÁ AUTOMATIZADO

| Tarea | Razón |
|-------|-------|
| Password de sudo | requiere interacción humana |
| Permisos de red externa | depende del firewall |
| Accesos a servicios | requiere configuración específica |

---

## 5️⃣ DEPENDENCIAS

| Dependencia | Estado | Nota |
|-------------|--------|------|
| FASE 1: PRE-FLIGHT | ✅ Aprobado | Debe estar completado |
| Acceso sudo/root | ⚠️ | Puede requerir password |
| Sistema operativo | ✅ | Detectado en FASE 1 |

---

## 6️⃣ QUÉ DEBE VALIDAR EL USUARIO

| Validación | Input | Default |
|------------|-------|---------|
| Nombre de usuario agente | Texto | `lumen` |
| Directorio base | Path | `~/.openclaw` |
| Permisos adicionales | Checkboxes | Leer lista |

---

## 7️⃣ VALORES POR DEFECTO

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `AGENT_USER` | `lumen` | Usuario del agente |
| `AGENT_GROUP` | `lumen` | Grupo del agente |
| `AGENT_HOME` | `~/.openclaw` | Directorio base |
| `WORKSPACE_DIR` | `~/.openclaw/workspace` | Directorio de trabajo |
| `CONFIG_DIR` | `~/.openclaw/config` | Directorio de configuración |
| `LOGS_DIR` | `~/.openclaw/logs` | Directorio de logs |
| `DATA_DIR` | `~/.openclaw/data` | Directorio de datos |

---

## 8️⃣ EDGE CASES

| Caso | Qué pasa | Solución |
|------|----------|----------|
| Usuario ya existe | Reutilizar | Validar permisos |
| Sin acceso sudo | Error | Pedir password |
| Directorio existe | Reutilizar | Validar estructura |
| Permisos insuficientes | Error | Pedir elevación |
| Path con espacios | Error | Validar y rechazar |
| Usuario root | Warning | No recomendado |

---

## 9️⃣ OUTPUT ESPERADO

| Archivo | Contenido |
|---------|-----------|
| `setup-users.log` | Log de la ejecución |
| `users-status.json` | Estado de usuarios creados |
| `directory-structure.json` | Estructura de directorios |

---

## 🔟 FLUJO DE EJECUCIÓN

```
INICIO
  │
  ├─► Verificar FASE 1 completada
  │
  ├─► Detectar usuario actual
  │     ├─► Si es root: warning
  │     └─► Si es usuario normal: continuar
  │
  ├─► Validar accesos sudo
  │     ├─► Si tiene sudo: continuar
  │     └─► Si no tiene: pedir password
  │
  ├─► Crear/validar usuario agente
  │     ├─► Si existe: validar permisos
  │     └─► Si no existe: crear
  │
  ├─► Crear estructura de directorios
  │     ├─► ~/.openclaw/
  │     ├─► ~/.openclaw/workspace/
  │     ├─► ~/.openclaw/config/
  │     ├─► ~/.openclaw/logs/
  │     └─► ~/.openclaw/data/
  │
  ├─► Configurar permisos
  │     ├─► chown usuario:grupo
  │     └─► chmod 755 directorios
  │
  ├─► Validar estructura
  │     └─► Verificar todo existe
  │
  └─► Generar reporte
        ├─► users-status.json
        └─► FIN
```

---

## 1️⃣1️⃣ PREGUNTAS PENDIENTES

| # | Pregunta | Estado | Decisión |
|---|----------|--------|----------|
| 1 | ¿Crear usuario siempre o usar el actual? | ✅ Resuelto | Crear usuario `bee-{nombre}` |
| 2 | ¿Permisos para systemd? | ✅ Resuelto | No necesario (solo su grupo) |
| 3 | ¿Grupos adicionales (docker, etc)? | ✅ Resuelto | Solo su grupo (máximo aislamiento) |
| 4 | ¿Configurar limits.conf? | ✅ Resuelto | No necesario |
| 5 | ¿Nomenclatura de usuario? | ✅ Resuelto | `bee-{nombre}` |
| 6 | ¿Contraseña? | ✅ Resuelto | Autogenerada 16 chars |
| 7 | ¿Directorios aislados o compartidos? | ✅ Resuelto | Aislados por usuario |
| 8 | ¿Contexto WSL vs Docker? | ✅ Resuelto | Leído desde FASE 1 |

---

## 1️⃣2️⃣ RIESGOS

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Sin sudo | Media | Alto | Pedir password |
| Usuario existente | Baja | Medio | Reutilizar |
| Permisos incorrectos | Media | Medio | Validar después |

---

*Análisis creado: 2026-03-05*