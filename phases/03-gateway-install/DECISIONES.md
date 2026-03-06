# FASE 3: GATEWAY INSTALL - DECISIONES

**Versión:** 1.0.0
**Fecha:** 2026-03-05

---

## 📋 RESUMEN

| Total decisiones | Pendientes | Aprobadas |
|------------------|------------|-----------|
| 5 | 0 | 5 |

---

## DECISIONES

### 1️⃣ ¿Instalar siempre o solo configurar?

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | Instalar cada vez desde cero | ❌ |
| B | **Detectar y solo configurar si existe** | ✅ APROBADO |

**Razón:** El gateway puede ya estar instalado en sistemas existentes. Detectar primero evita reinstalaciones innecesarias.

**Implementación:**
- Verificar si `openclaw-gateway` existe en PATH
- Si existe, solo configurar
- Si no existe, preguntar antes de instalar

---

### 2️⃣ ¿Qué canales habilitar por defecto?

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Habilitar todos (Telegram, WhatsApp, Discord)** | ✅ APROBADO |
| B | Solo Telegram por defecto | ❌ |

**Razón:** El usuario puede deshabilitar canales fácílmente. Habilitar todos permite configuración inmediata.

**Implementación:**
- Todos los canales configurados en gateway.json
- El usuario configura tokens según necesite
- Canales sin token quedan en modo "pending"

---

### 3️⃣ ¿Configurar memoria persistente?

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Habilitar memoria persistente por defecto** | ✅ APROBADO |
| B | Memoria solo en sesión | ❌ |

**Razón:** La memoria persistente es esencial para agentes TURNKEY. Sin ella, el agente "olvida" entre sesiones.

**Implementación:**
- Memoria habilitada en gateway.json
- Path: `~/.openclaw/data/memory`
- Formato: archivos markdown por defecto

---

### 4️⃣ ¿Puerto por defecto?

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Usar 18789 (definido en FASE 1)** | ✅ APROBADO |
| B | Detectar primer puerto libre | ❌ |

**Razón:** El puerto ya fue validado en FASE 1. Usar el mismo simplifica configuración.

**Implementación:**
- Puerto por defecto: 18789
- Si está ocupado, detectar siguiente disponible
- Rango: 18789-18793

---

### 5️⃣ ¿Crear systemd service automáticamente?

| Opción | Descripción | Decisión |
|--------|-------------|----------|
| A | **Crear systemd service automáticamente** | ✅ APROBADO |
| B | El usuario lo configura manualmente | ❌ |

**Razón:** El service permite iniciar el gateway automáticamente. Crearlo simplifica la experiencia.

**Implementación:**
- Crear servicio `openclaw-gateway.service`
- Instalar en `~/.config/systemd/user/`
- Habilitar con `systemctl --user enable`

---

## 📊 RESUMEN DE DECISIONES

| # | Decisión | Valor |
|---|----------|-------|
| 1 | Instalación | Detectar y solo configurar si existe |
| 2 | Canales | Todos habilitados por defecto |
| 3 | Memoria | Habilitada en `~/.openclaw/data/memory` |
| 4 | Puerto | 18789 por defecto (rango 18789-18793) |
| 5 | Systemd | Crear automáticamente |

---

## 🔗 DEPENDENCIAS

| Decisión | Depende de |
|----------|------------|
| Puerto 18789 | FASE 1: PRE-FLIGHT |
| Directorio config | FASE 2: SETUP USERS |
| API key Ollama | Usuario debe proporcionar |

---

*Decisiones aprobadas: 2026-03-05*