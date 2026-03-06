# FASE 2: SETUP USERS - DISEÑO

**Versión:** 1.0.0
**Fecha:** 2026-03-05

---

## 1️⃣ SCRIPT PRINCIPAL: setup-users.sh

### Argumentos

| Argumento | Descripción | Default |
|-----------|-------------|---------|
| `--user` | Usuario del agente | `lumen` |
| `--home` | Directorio base | `~/.openclaw` |
| `--force` | Forzar recreación | `false` |
| `--dry-run` | Simular ejecución | `false` |
| `--help` | Mostrar ayuda | - |

### Output

```json
{
  "status": "passed|failed|warning",
  "user": {
    "name": "lumen",
    "exists": true,
    "home": "/home/lumen",
    "groups": ["lumen", "docker"]
  },
  "directories": {
    "base": "/home/lumen/.openclaw",
    "workspace": "/home/lumen/.openclaw/workspace",
    "config": "/home/lumen/.openclaw/config",
    "logs": "/home/lumen/.openclaw/logs",
    "data": "/home/lumen/.openclaw/data"
  },
  "permissions": {
    "base": "755",
    "workspace": "755",
    "config": "700",
    "logs": "755",
    "data": "755"
  }
}
```

---

## 2️⃣ SCRIPTS AUXILIARES

### 2.1 detect-user.sh

Detecta el usuario actual y sus permisos.

**Output:**
```json
{
  "current_user": "lumen",
  "uid": 1000,
  "gid": 1000,
  "groups": ["lumen", "sudo", "docker"],
  "is_root": false,
  "has_sudo": true,
  "sudo_nopasswd": false
}
```

### 2.2 create-directories.sh

Crea la estructura de directorios del agente.

**Argumentos:**
- `--base`: Directorio base
- `--user`: Usuario propietario
- `--group`: Grupo propietario

**Output:**
```json
{
  "created": [
    "/home/lumen/.openclaw",
    "/home/lumen/.openclaw/workspace",
    "/home/lumen/.openclaw/config",
    "/home/lumen/.openclaw/logs",
    "/home/lumen/.openclaw/data"
  ],
  "existing": [],
  "failed": []
}
```

### 2.3 validate-user.sh

Valida que el usuario tiene los permisos necesarios.

**Output:**
```json
{
  "user": "lumen",
  "valid": true,
  "issues": [],
  "warnings": ["sudo requiere password"]
}
```

---

## 3️⃣ ESTRUCTURA DE DIRECTORIOS

```
~/.openclaw/
├── workspace/          # Archivos de trabajo
│   ├── memory/        # Memoria del agente
│   ├── scripts/       # Scripts del agente
│   └── templates/     # Plantillas
├── config/            # Configuración
│   ├── gateway.json   # Config del gateway
│   ├── bot.json       # Config del bot
│   └── fleet.json     # Config del fleet
├── logs/              # Logs del agente
│   ├── agent.log      # Log principal
│   └── error.log      # Errores
└── data/              # Datos persistentes
    ├── cache/         # Caché
    └── backups/       # Backups
```

---

## 4️⃣ PERMISOS

| Directorio | Permisos | Razón |
|------------|----------|-------|
| `~/.openclaw` | `755` | Acceso general |
| `~/.openclaw/workspace` | `755` | Archivos de trabajo |
| `~/.openclaw/config` | `700` | Configuración sensible |
| `~/.openclaw/logs` | `755` | Logs accesibles |
| `~/.openclaw/data` | `755` | Datos persistentes |

---

## 5️⃣ VALIDACIONES

| Check | Criterio | Acción si falla |
|-------|----------|------------------|
| Usuario existe | `id` funciona | Crear usuario |
| Directorio existe | `ls` funciona | Crear directorio |
| Permisos correctos | `ls -la` muestra owner | Corregir permisos |
| Estructura completa | Todos los dir existen | Crear faltantes |

---

## 6️⃣ FLUJO INTERACTIVO

```
=== SETUP USERS ===

1. Detectando usuario actual...
   ✓ Usuario: lumen
   ✓ UID: 1000
   ✓ Grupos: lumen, sudo

2. Validando permisos...
   ✓ Sudo disponible
   ⚠ Sudo requiere password

3. Creando estructura de directorios...
   ✓ ~/.openclaw/
   ✓ ~/.openclaw/workspace/
   ✓ ~/.openclaw/config/
   ✓ ~/.openclaw/logs/
   ✓ ~/.openclaw/data/

4. Configurando permisos...
   ✓ ~/.openclaw: 755
   ✓ ~/.openclaw/config: 700

5. Generando reporte...
   ✓ users-status.json

=== SETUP USERS COMPLETADO ===
```

---

## 7️⃣ MODO AUTOMÁTICO

Con `--config`:
```bash
./setup-users.sh --config user-config.json
```

**user-config.json:**
```json
{
  "user": "lumen",
  "group": "lumen",
  "home": "/home/lumen",
  "directories": {
    "base": ".openclaw",
    "workspace": "workspace"
  },
  "permissions": {
    "config": "700"
  }
}
```

---

## 8️⃣ EDGE CASES Y SOLUCIONES

| Caso | Detección | Solución |
|------|-----------|----------|
| Usuario ya existe | `id username` | Validar permisos, continuar |
| Sin sudo | `sudo -n true` falla | Pedir password interactivamente |
| Directorio existe | `ls -d dir` retorna 0 | Validar estructura, continuar |
| Permisos incorrectos | `ls -la` differ | Corregir con chown/chmod |
| Path con espacios | `[[ $path =~ " " ]]` | Error, path inválido |
| Ejecutando como root | `[[ $EUID -eq 0 ]]` | Warning, crear usuario no-root |

---

## 9️⃣ PREGUNTAS DE DECISIÓN

| # | Pregunta | Opción A | Opción B | Recomendación |
|---|----------|----------|----------|---------------|
| 1 | ¿Crear usuario siempre? | Crear nuevo | Usar actual | **B: Usar actual** |
| 2 | ¿Permisos systemd? | Habilitar | Deshabilitar | **A: Habilitar** |
| 3 | ¿Grupos adicionales? | Agregar docker | Solo grupo base | **Contexto** |
| 4 | ¿Configurar limits? | Sí | No | **B: No** |

---

*Diseño creado: 2026-03-05*