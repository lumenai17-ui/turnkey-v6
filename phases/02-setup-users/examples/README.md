# FASE 2: Ejemplos de Output

Este directorio contiene ejemplos de los archivos de salida generados por los scripts de FASE 2.

## Archivos de Ejemplo

| Archivo | Descripción |
|---------|-------------|
| `users-status.example.json` | Ejemplo del estado de FASE 2 tras crear usuario |
| `credentials.example.json` | Ejemplo de credenciales guardadas (FASE 7) |

## Formato de users-status.json

```json
{
    "phase": "02-setup-users",
    "script": "setup-users",
    "version": "6.0.0",
    "timestamp": "2026-03-06T15:00:00Z",
    "agent": {
        "name": "restaurante",
        "username": "bee-restaurante",
        "prefix": "bee-"
    },
    "status": "passed",
    "message": "Usuario creado exitosamente",
    "dry_run": false,
    "directories": {
        "config": "/home/bee-restaurante/.openclaw/config",
        "workspace": "/home/bee-restaurante/.openclaw/workspace",
        "logs": "/home/bee-restaurante/.openclaw/logs",
        "data": "/home/bee-restaurante/.openclaw/data"
    },
    "permissions": {
        "config": "700",
        "standard": "755"
    },
    "next_phase": "03-gateway-install"
}
```

## Dependencias

FASE 2 depende de:
- **FASE 1**: `turnkey-status.json` (validación de prerequisitos)
- **Sistema**: `jq` para output JSON
- **Permisos**: root/sudo para crear usuarios

## Output para FASE 3

FASE 2 genera:
1. `status/users-status.json` - Estado del proceso
2. `secrets/{username}.json` - Credenciales encriptadas (FASE 7)
3. Directorios en `/home/bee-{nombre}/.openclaw/`