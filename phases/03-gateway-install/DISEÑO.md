# FASE 3: GATEWAY INSTALL - DISEÑO

**Versión:** 1.0.0
**Fecha:** 2026-03-05

---

## 1️⃣ SCRIPT PRINCIPAL: gateway-install.sh

### Argumentos

| Argumento | Descripción | Default |
|-----------|-------------|---------|
| `--api-key` | API key de Ollama | Solicitar |
| `--port` | Puerto del gateway | 18789 |
| `--host` | Host del gateway | localhost |
| `--config` | Archivo de configuración JSON | - |
| `--skip-install` | Solo configurar (no instalar) | false |
| `--dry-run` | Simular sin cambios | false |
| `--help` | Mostrar ayuda | - |

### Output

```json
{
  "status": "passed|failed|warning",
  "gateway": {
    "installed": true,
    "version": "1.0.0",
    "port": 18789,
    "host": "localhost",
    "url": "http://localhost:18789"
  },
  "api_key": {
    "provider": "ollama",
    "validated": true,
    "plan": "free|paid"
  },
  "services": {
    "openclaw-gateway": "running|stopped|failed"
  },
  "checks": [
    {"name": "node_version", "status": "passed", "value": "v20.10.0"},
    {"name": "npm_version", "status": "passed", "value": "10.2.3"},
    {"name": "gateway_running", "status": "passed", "value": true}
  ]
}
```

---

## 2️⃣ SCRIPTS AUXILIARES

### 2.1 detect-gateway.sh

Detecta si OpenClaw Gateway ya está instalado.

**Output:**
```json
{
  "installed": true,
  "version": "1.0.0",
  "path": "/usr/local/bin/openclaw-gateway",
  "running": true,
  "port": 18789,
  "pid": 12345
}
```

### 2.2 install-gateway.sh

Instala OpenClaw Gateway si no está presente.

**Argumentos:**
- `--method`: Método de instalación (npm, binary, docker)
- `--version`: Versión específica

**Output:**
```json
{
  "status": "installed|updated|existing",
  "method": "npm",
  "version": "1.0.0",
  "path": "/usr/local/bin/openclaw-gateway",
  "dependencies": ["node", "npm"]
}
```

### 2.3 configure-gateway.sh

Configura el gateway.json y servicios asociados.

**Argumentos:**
- `--port`: Puerto
- `--host`: Host
- `--api-key`: API key de Ollama

**Output:**
```json
{
  "config_file": "/home/lumen/.openclaw/config/gateway.json",
  "services": {
    "systemd": true,
    "service_name": "openclaw-gateway"
  }
}
```

### 2.4 validate-api-key.sh

Valida la API key de Ollama con petición de prueba.

**Output:**
```json
{
  "valid": true,
  "provider": "ollama",
  "plan": "free",
  "models_available": 53,
  "response_time_ms": 245
}
```

---

## 3️⃣ ARCHIVO DE CONFIGURACIÓN

### gateway.json

```json
{
  "gateway": {
    "name": "openclaw-gateway",
    "version": "1.0.0",
    "host": "localhost",
    "port": 18789,
    "logLevel": "info"
  },
  "api": {
    "ollama": {
      "enabled": true,
      "apiKey": "${OLLAMA_API_KEY}",
      "baseUrl": "https://api.ollama.cloud/v1",
      "defaultModel": "glm-5",
      "fallbackModel": "kimi-k2.5"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}"
    },
    "whatsapp": {
      "enabled": true,
      "sessionId": "default"
    },
    "discord": {
      "enabled": true,
      "token": "${DISCORD_BOT_TOKEN}"
    }
  },
  "memory": {
    "enabled": true,
    "path": "~/.openclaw/data/memory"
  },
  "logging": {
    "path": "~/.openclaw/logs",
    "level": "info",
    "maxSize": "10M",
    "maxFiles": 5
  }
}
```

---

## 4️⃣ SYSTEMD SERVICE

### openclaw-gateway.service

```ini
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
User=lumen
WorkingDirectory=/home/lumen/.openclaw
ExecStart=/usr/local/bin/openclaw-gateway --config /home/lumen/.openclaw/config/gateway.json
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

---

## 5️⃣ VALIDACIONES

| Check | Criterio | Acción si falla |
|-------|----------|------------------|
| Node.js >= 18 | `node --version` | Pedir instalación |
| npm >= 9 | `npm --version` | Actualizar npm |
| Puerto libre | `ss -tuln` | Usar otro puerto |
| API key válida | Petición HTTP | Pedir key correcta |
| Gateway inicia | `curl localhost:port` | Diagnóstico |

---

## 6️⃣ FLUJO INTERACTIVO

```
=== GATEWAY INSTALL ===

1. Verificando requisitos...
   ✓ Node.js: v20.10.0
   ✓ npm: 10.2.3
   ✓ Puerto 18789 disponible

2. Detectando instalación previa...
   ✓ Gateway no instalado

3. Configuración del Gateway:
   ? Puerto [18789]: ___
   ? Host [localhost]: ___
   ? API Key de Ollama: ****

4. Validando API key...
   ✓ API key válida (plan: free)
   ✓ 53 modelos disponibles

5. Instalando Gateway...
   ✓ Instalando dependencias...
   ✓ Configurando gateway.json...
   ✓ Creando systemd service...

6. Iniciando Gateway...
   ✓ Gateway iniciado en http://localhost:18789
   ✓ Health check: OK

=== GATEWAY INSTALADO ===
```

---

## 7️⃣ MODO AUTOMÁTICO

Con `--config`:
```bash
./gateway-install.sh --config gateway-config.json
```

**gateway-config.json:**
```json
{
  "api_key": "os_...",
  "gateway": {
    "port": 18789,
    "host": "localhost"
  },
  "skip_install": false,
  "channels": {
    "telegram": true,
    "whatsapp": true,
    "discord": false
  }
}
```

---

## 8️⃣ EDGE CASES Y SOLUCIONES

| Caso | Detección | Solución |
|------|-----------|----------|
| Gateway ya instalado | `which openclaw-gateway` | Preguntar: actualizar o reutilizar |
| Sin Node.js | `node --version` falla | Pedir instalación manual |
| API key inválida | HTTP 401/403 | Pedir key correcta |
| Puerto ocupado | `ss -tuln` | Usar siguiente disponible |
| Gateway no inicia | systemctl status | Mostrar logs y diagnóstico |

---

## 9️⃣ PREGUNTAS DE DECISIÓN

| # | Pregunta | Opción A | Opción B | Recomendación |
|---|----------|----------|----------|---------------|
| 1 | ¿Instalar siempre? | Instalar cada vez | Solo configurar si existe | **B: Solo configurar** |
| 2 | ¿Canales por defecto? | Todos | Solo Telegram | **A: Todos** |
| 3 | ¿Memoria persistente? | Habilitar | Deshabilitar | **A: Habilitar** |
| 4 | ¿Puerto? | Usar 18789 | Detectar libre | **A: Usar 18789** |
| 5 | ¿Systemd service? | Crear | Manual | **A: Crear** |

---

*Diseño creado: 2026-03-05*