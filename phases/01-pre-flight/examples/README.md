# EJEMPLOS DE USO - FASE 1: PRE-FLIGHT

## Ejemplo 1: Modo automático con config

```bash
# Crear archivo de configuración
cat > turnkey-config-input.json << EOF
{
  "agent": {
    "name": "Atlas",
    "role": "Asistente de viajes",
    "template": "services"
  },
  "api_keys": {
    "ollama": "oll-xxxxxxxxxxxx",
    "brave": "brave-xxxxxxxxxxxx"
  }
}
EOF

# Ejecutar pre-flight
./pre-flight.sh --config turnkey-config-input.json

# Resultado: turnkey-env.json, turnkey-config.json, turnkey-status.json
```

---

## Ejemplo 2: Modo interactivo

```bash
# Ejecutar en modo interactivo
./pre-flight.sh --interactive

# El script preguntará paso a paso:
? Tipo de despliegue: [v]ps / [d]edicado (auto-detectar): v
? Nombre del agente: (Agent-1709644800): MiAgente
? Rol del agente: (Asistente virtual): Asistente de ventas
...
```

---

## Ejemplo 3: Solo detección

```bash
# Solo detectar el entorno, sin validar
./pre-flight.sh --detect-only

# Resultado: turnkey-env.json con información del sistema
```

---

## Ejemplo 4: Forzar continuación

```bash
# Continuar aunque haya warnings
./pre-flight.sh --config my-config.json --force
```

---

## Ejemplo 5: Output de ejemplo

### turnkey-env.json
```json
{
  "detected_at": "2026-03-05T12:00:00Z",
  "environment": {
    "type": "vps",
    "provider": "aws"
  },
  "resources": {
    "ram_total_gb": 4,
    "cpu_cores": 2,
    "disk_available_gb": 65
  }
}
```

### turnkey-config.json
```json
{
  "agent": {
    "name": "Atlas",
    "port": 18789
  },
  "api_keys": {
    "ollama": "oll-xxx"
  }
}
```

### turnkey-status.json
```json
{
  "status": "passed_with_warnings",
  "warnings": 2,
  "errors": 0,
  "can_proceed": true
}
```