# EDGE CASES - FASE 1: PRE-FLIGHT

**Descripción:** Casos especiales y cómo manejarlos

---

## 🔴 Casos Críticos (No puede continuar)

### EC-01: Sin API key de Ollama
**Situación:** El usuario no tiene API key de Ollama Cloud.

**Detección:**
```bash
[ -z "$OLLAMA_API_KEY" ] && echo "ERROR: OLLAMA_API_KEY no definida"
```

**Manejo:**
- Modo interactivo: Pedir la key
- Modo automático: Error crítico, salir

**Código de salida:** 1

---

### EC-02: API key de Ollama inválida
**Situación:** La key existe pero no funciona.

**Detección:**
```bash
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $OLLAMA_API_KEY" \
  "https://api.ollama.com/v1/models")
[ "$HTTP_CODE" != "200" ] && echo "ERROR: API key inválida"
```

**Manejo:**
- Verificar que la key tiene el formato correcto (empieza con "oll-")
- Verificar que no ha expirado
- Sugerir verificar en https://ollama.com/settings

**Código de salida:** 1

---

### EC-03: Sin acceso root/sudo
**Situación:** El usuario no tiene permisos de administrador.

**Detección:**
```bash
[ "$EUID" -ne 0 ] && ! sudo -n true 2>/dev/null && echo "ERROR: Sin acceso root/sudo"
```

**Manejo:**
- Sugerir ejecutar con sudo
- No se puede continuar

**Código de salida:** 1

---

### EC-04: Systemd no disponible
**Situación:** El OS no usa systemd (ej: Alpine, WSL1).

**Detección:**
```bash
! systemctl --version &>/dev/null && echo "ERROR: Systemd no disponible"
```

**Manejo:**
- Advertir que se necesitará método alternativo
- Sugerir usar Docker como alternativa

**Código de salida:** 1 o permitir continuar con advertencia

---

## 🟡 Casos de Warning (Puede continuar con confirmación)

### EC-05: RAM insuficiente
**Situación:** RAM detectada < mínimo según tipo de entorno.

**Detección:**
```bash
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
MIN_RAM=2  # para VPS, 16 para dedicado
[ $RAM_GB -lt $MIN_RAM ] && echo "WARNING: RAM insuficiente"
```

**Manejo:**
- Mostrar warning con RAM detectada vs mínima
- Pedir confirmación explícita para continuar
- Guardar aceptación en turnkey-status.json

**Código de salida:** 0 con warning

---

### EC-06: Puerto base ocupado
**Situación:** El puerto 18789 está en uso.

**Detección:**
```bash
netstat -tuln | grep -q ":18789 " && echo "WARNING: Puerto 18789 ocupado"
```

**Manejo:**
- Buscar siguiente puerto libre en el rango
- Asignar automáticamente puerto disponible
- Informar al usuario del puerto asignado

**Código de salida:** 0 con asignación alternativa

---

### EC-07: Sin Brave API key
**Situación:** Falta la API key de Brave Search.

**Detección:**
```bash
[ -z "$BRAVE_API_KEY" ] && echo "WARNING: Sin BRAVE_API_KEY"
```

**Manejo:**
- Advertir que web_search no estará disponible
- Deshabilitar skill automáticamente
- Continuar sin problema

**Código de salida:** 0 con warning

---

### EC-08: Sin Telegram token
**Situación:** Falta el token del bot de Telegram.

**Detección:**
```bash
[ -z "$TELEGRAM_BOT_TOKEN" ] && echo "WARNING: Sin TELEGRAM_BOT_TOKEN"
```

**Manejo:**
- Advertir que el canal Telegram no funcionará
- Sugerir configurar después
- Continuar sin problema

**Código de salida:** 0 con warning

---

## 🔵 Casos Informativos (No afecta)

### EC-09: Detrás de proxy/VPN
**Situación:** El servidor está detrás de un proxy.

**Detección:**
```bash
[ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ] && echo "INFO: Proxy detectado"
```

**Manejo:**
- Aumentar timeout para validaciones de API
- Configurar curl con proxy

**Código de salida:** 0

---

### EC-10: Virtualización anidada
**Situación:** El servidor es un container (Docker, LXC).

**Detección:**
```bash
[ -f /.dockerenv ] && echo "INFO: Ejecutando en Docker"
grep -qi 'lxc\|docker\|container' /proc/1/cgroup 2>/dev/null && echo "INFO: Container detectado"
```

**Manejo:**
- Informar al usuario
- No afecta el funcionamiento
- Puede necesitar configuración adicional de red

**Código de salida:** 0

---

### EC-11: Sin SSH keys
**Situación:** No hay claves SSH configuradas.

**Detección:**
```bash
[ ! -f ~/.ssh/id_rsa.pub ] && [ ! -f ~/.ssh/id_ed25519.pub ] && echo "INFO: Sin SSH keys"
```

**Manejo:**
- Informar que no habrá acceso SSH remoto
- No crítico para el agente
- Sugerir configurar después

**Código de salida:** 0 con info

---

## 📋 Tabla Resumen

| Código | Situación | Severidad | Acción |
|--------|-----------|-----------|--------|
| EC-01 | Sin API key Ollama | Crítico | Pedir o salir |
| EC-02 | API key Ollama inválida | Crítico | Salir |
| EC-03 | Sin root/sudo | Crítico | Salir |
| EC-04 | Sin systemd | Crítico | Salir o advertir |
| EC-05 | RAM insuficiente | Warning | Pedir confirmación |
| EC-06 | Puerto ocupado | Warning | Asignar otro |
| EC-07 | Sin Brave key | Warning | Deshabilitar web_search |
| EC-08 | Sin Telegram token | Warning | Continuar sin canal |
| EC-09 | Detrás de proxy | Info | Ajustar timeout |
| EC-10 | Container detectado | Info | Solo informar |
| EC-11 | Sin SSH keys | Info | Solo informar |

---

*Documento para referencia durante desarrollo del script*