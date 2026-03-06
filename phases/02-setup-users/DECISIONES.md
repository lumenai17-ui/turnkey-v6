# FASE 2: SETUP USERS - DECISIONES

**Versión:** 2.0.0
**Fecha:** 2026-03-05
**Estado:** ✅ APROBADO (revisado con usuario)

---

## 📋 RESUMEN

| Total decisiones | Pendientes | Aprobadas |
|------------------|------------|-----------|
| 6 | 0 | 6 |

---

## DECISIONES REVISADAS CON USUARIO

### 1️⃣ NOMENCLATURA DE USUARIO

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | `lumen-{nombre}` | ❌ |
| B | `bee-{nombre}` | ✅ APROBADO |
| C | Personalizado | ❌ |

**Razón:** `bee-{nombre}` es único y fácil de identificar.

**Ejemplos:**
- `bee-restaurante`
- `bee-hotel`
- `bee-tienda`

---

### 2️⃣ CONTRASEÑA

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Autogenerada 16 caracteres** | ✅ APROBADO |
| B | Pedir al usuario | ❌ |
| C | Sin contraseña (SSH key) | ❌ |

**Formato:** Mayúsculas, minúsculas, números, símbolos
**Ejemplo:** `xK9#mP2$vL5@nQ8!`

**Guardado:** Encriptada con AES-256 para FASE 7 (Registry)

---

### 3️⃣ GRUPOS DEL USUARIO

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Solo su grupo** | ✅ APROBADO |
| B | + docker | ❌ |
| C | + docker + systemd-journal | ❌ |

**Razón:** Máximo aislamiento de datos entre agentes.

**Grupo creado:** `bee-{nombre}` (solo ese grupo)

---

### 4️⃣ DIRECTORIOS

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Aislados por usuario** | ✅ APROBADO |
| B | Compartidos | ❌ |

**Estructura:**
```bash
/home/bee-{nombre}/.openclaw/
├── config/      (700) - API keys protegidas
├── workspace/   (755) - Archivos de trabajo
├── logs/        (755) - Logs accesibles
└── data/        (755) - Datos persistentes
```

---

### 5️⃣ PERMISOS

| Directorio | Permisos | Razón |
|------------|----------|-------|
| `/home/bee-{nombre}` | 700 | Solo el usuario accede |
| `.openclaw/config/` | 700 | API keys protegidas |
| `.openclaw/workspace/` | 755 | Archivos de trabajo |
| `.openclaw/logs/` | 755 | Logs accesibles |
| `.openclaw/data/` | 755 | Datos persistentes |

**Nota:** Permisos 700 solo afectan archivos, NO la red. El agente sigue pudiendo conectarse a Telegram, WhatsApp, internet.

---

### 6️⃣ CONTEXTO WSL vs DOCKER

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | Preguntar en FASE 2 | ❌ |
| B | **Leer desde FASE 1** | ✅ APROBADO |
| C | Auto-detectar | ❌ |

**Flujo:**
1. FASE 1 pregunta: `deployment_type` (wsl o docker)
2. FASE 2 lee esa decisión
3. FASE 2 adapta comportamiento

**Comportamiento según tipo:**

| FASE 1 dice | FASE 2 hace |
|-------------|-------------|
| `wsl` | Crear usuario `bee-{nombre}` en WSL |
| `docker` | Usuario en Dockerfile, scripts configuran directorios |

---

## 📊 RESUMEN DE DECISIONES

| # | Decisión | Valor |
|---|----------|-------|
| 1 | Usuario | `bee-{nombre}` |
| 2 | Contraseña | Autogenerada 16 chars |
| 3 | Grupos | Solo su grupo |
| 4 | Directorios | Aislados por usuario |
| 5 | Permisos | 700 config, 755 resto |
| 6 | Contexto | Leído desde FASE 1 |

---

## 🔗 DEPENDENCIAS

| Decisión | Depende de |
|----------|------------|
| Contexto WSL/Docker | FASE 1: `deployment_type` |
| Nombre del agente | FASE 1: `agent_name` |

---

## 📝 SCRIPTS A GENERAR

| Script | Función |
|--------|---------|
| `setup-users.sh` | Principal - crea usuario y estructura |
| `create-user.sh` | Crea usuario con contraseña |
| `create-directories.sh` | Crea estructura de directorios |
| `generate-password.sh` | Genera contraseña segura |

---

## 📂 OUTPUT ESPERADO

```json
{
  "status": "passed",
  "agent": {
    "name": "restaurante",
    "user": "bee-restaurante",
    "home": "/home/bee-restaurante",
    "password_generated": true,
    "groups": ["bee-restaurante"]
  },
  "directories": {
    "base": "/home/bee-restaurante/.openclaw",
    "config": "/home/bee-restaurante/.openclaw/config",
    "workspace": "/home/bee-restaurante/.openclaw/workspace",
    "logs": "/home/bee-restaurante/.openclaw/logs",
    "data": "/home/bee-restaurante/.openclaw/data"
  }
}
```

---

*Decisiones aprobadas: 2026-03-05*
*Revisado con usuario: Sí*
*Cambios respecto a versión 1.0: Usuario `lumen` → `bee-{nombre}`, directorios aislados, permisos actualizados*