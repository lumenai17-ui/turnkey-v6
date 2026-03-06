# FASE 3: GATEWAY INSTALL - ANÁLISIS

**Versión:** 1.0.0
**Fecha:** 2026-03-05
**Dependencias:** FASE 1 ✅, FASE 2 ✅

---

## 1️⃣ PROPÓSITO

Instalar y configurar OpenClaw Gateway para el agente.

---

## 2️⃣ QUÉ HACE ESTA FASE

| Función | Descripción |
|---------|-------------|
| Detectar instalación previa | Verificar si ya existe gateway |
| Descargar/Instalar OpenClaw | Si no está instalado |
| Configurar gateway.json | Archivo de configuración principal |
| Configurar canales | Telegram, WhatsApp, Discord |
| Generar claves API | Si no existen |
| Validar conectividad | Probar que funciona |

---

## 3️⃣ QUÉ ESTÁ AUTOMATIZADO

| Tarea | Automatizado | Método |
|-------|-------------|--------|
| Detectar gateway | ✅ | `which openclaw`, verificar procesos |
| Descargar OpenClaw | ⚠️ | Requiere URL/method |
| Instalar gateway | ✅ | Script de instalación |
| Configurar gateway.json | ✅ | Template + valores usuario |
| Validar API keys | ✅ | Petición de prueba |
| Iniciar gateway | ✅ | systemd service |

---

## 4️⃣ QUÉ NO ESTÁ AUTOMATIZADO

| Tarea | Razón |
|-------|-------|
| Obtener API key Ollama | El usuario debe obtenerla |
| Registrar WhatsApp Business | Proceso externo |
| Crear bot de Telegram | Proceso externo |
| Crear bot de Discord | Proceso externo |

---

## 5️⃣ DEPENDENCIAS

| Dependencia | Estado | Nota |
|-------------|--------|------|
| FASE 1: PRE-FLIGHT | ✅ Aprobado | Debe estar completado |
| FASE 2: SETUP USERS | ✅ Aprobado | Directorios creados |
| Ollama Cloud API Key | ⚠️ | Usuario debe proporcionar |

---

## 6️⃣ REQUISITOS PREVIOS

| Requisito | Cómo verificar |
|-----------|----------------|
| API key Ollama | Usuario debe proporcionar |
| Gateway no instalado | `which openclaw-gateway` |
| Node.js >= 18 | `node --version` |
| npm >= 9 | `npm --version` |
| Puertos disponibles | FASE 1 ya verificó |

---

## 7️⃣ INPUTS DEL USUARIO

| Input | Tipo | Obligatorio | Default |
|-------|------|-------------|---------|
| `ollama_api_key` | texto | ✅ Sí | - |
| `ollama_plan` | select | No | free |
| `gateway_port` | número | No | 18789 |
| `gateway_host` | texto | No | localhost |
| Auto instalar | checkbox | No | true |

---

## 8️⃣ EDGE CASES

| Caso | Qué pasa | Solución |
|------|----------|----------|
| Gateway ya instalado | Detectar versión | Preguntar: actualizar o usar existente |
| Sin Node.js | Error | Instalar Node.js o pedir al usuario |
| Sin API key | Error | Pedir interactivamente |
| Puerto ocupado | Error | Usar siguiente disponible |
| Sin permisos | Error | Pedir sudo |
| Instalación fallida | Error | Logs + rollback |
| Gateway no inicia | Error | Diagnóstico + logs |

---

## 9️⃣ OUTPUT ESPERADO

| Archivo | Contenido |
|---------|-----------|
| `gateway.json` | Configuración del gateway |
| `gateway-status.json` | Estado de la instalación |
| `gateway.log` | Log de la instalación |
| Systemd service | `openclaw-gateway.service` |

---

## 🔟 FLUJO DE EJECUCIÓN

```
INICIO
  │
  ├─► Verificar FASE 1 y 2 completadas
  │
  ├─► Detectar instalación previa
  │     ├─► Si existe: preguntar actualizar/reutilizar
  │     └─► Si no existe: continuar instalación
  │
  ├─► Verificar requisitos
  │     ├─► Node.js >= 18
  │     ├─► npm >= 9
  │     └─► Puertos disponibles
  │
  ├─► Solicitar API key Ollama
  │     ├─► Validar formato
  │     └─► Probar conexión
  │
  ├─► Instalar/Configurar Gateway
  │     ├─► Descargar si es necesario
  │     ├─► Instalar dependencias
  │     ├─► Configurar gateway.json
  │     └─► Crear systemd service
  │
  ├─► Iniciar Gateway
  │     ├─► systemctl --user start
  │     └─► Verificar que responde
  │
  └─► Generar reporte
        ├─► gateway-status.json
        └─► FIN
```

---

## 1️⃣1️⃣ COMPONENTES DEL GATEWAY

| Componente | Descripción |
|------------|-------------|
| OpenClaw Gateway Core | Motor principal |
| Channel Plugins | Telegram, WhatsApp, Discord |
| Memory Plugins | Memoria persistente |
| Model Plugins | Conexión a Ollama |

---

## 1️⃣2️⃣ PREGUNTAS PENDIENTES

| # | Pregunta | Estado |
|---|----------|--------|
| 1 | ¿Instalar siempre o solo configurar? | ⏳ Pendiente |
| 2 | ¿Qué canales habilitar por defecto? | ⏳ Pendiente |
| 3 | ¿Configurar memoria persistente? | ⏳ Pendiente |
| 4 | ¿Puerto por defecto o detectar? | ⏳ Pendiente |
| 5 | ¿Crear systemd service automáticamente? | ⏳ Pendiente |

---

## 1️⃣3️⃣ RIESGOS

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| API key inválida | Media | Alto | Validar antes de continuar |
| Puerto ocupado | Media | Medio | Detectar y usar otro |
| Instalación fallida | Baja | Alto | Rollback + logs |
| Gateway no inicia | Media | Alto | Diagnóstico automático |

---

*Análisis creado: 2026-03-05*