# FASE 5: BOT CONFIG - DECISIONES

**Versión:** 1.0.0
**Fecha:** 2026-03-06
**Estado:** ✅ APROBADO

---

## 📋 RESUMEN

| Total decisiones | Pendientes | Aprobadas |
|------------------|------------|-----------|
| 5 | 0 | 5 |

---

## DECISIONES APROBADAS

### 1️⃣ EMAIL - bee-smart.ai DOMINIO

| Decisión | Valor |
|----------|-------|
| Dominio | bee-smart.ai (nosotros) |
| Email del agente | {nombre}@bee-smart.ai |
| Envío SMTP | mail.bee-smart.ai:587 |
| Recepción IMAP | mail.bee-smart.ai:993 |
| Fallback envío | Resend API |
| Templates | 6 incluidos |

**IMPORTANTE:**
- Dominio **bee-smart.ai** es propiedad nuestra
- IMAP (recepción) **DEBE configurarse**
- SMTP o Resend para envío

**Razón:** El agente debe poder ENVIAR y RECIBIR correos con dominio propio.

---

### 2️⃣ TELEGRAM - NOSOTROS CREAMOS EL BOT

| Decisión | Valor |
|----------|-------|
| Bot token | Nosotros proveemos |
| Webhook | Configuramos automáticamente |
| Allowed users | Cliente provee IDs |
| Long polling | Alternativa sin webhook |

**Razón:** Simplifica el proceso para el cliente. Solo necesita IDs de usuarios.

---

### 3️⃣ WHATSAPP Y DISCORD - YA CONFIGURADOS

| Canal | Estado |
|-------|--------|
| WhatsApp | ✅ Heredado de LOCAL |
| Discord | ✅ Heredado de LOCAL |

**Razón:** La configuración de LOCAL se replica para el cliente.

---

### 4️⃣ APIs COMPARTIDAS - INCLUIDAS

| API | Límite | Incluido |
|-----|--------|----------|
| Resend | 3,000/mes | ✅ |
| PDF.co | 5,000 págs | ✅ |
| Mathpix | 1,000 págs | ✅ |
| Mux | 100 videos | ✅ |
| Twilio | 500 SMS | ✅ |
| Oxylabs | 1,000 req | ✅ |
| Gamma | 50/mes | ✅ |

**Costo total:** ~$105/mes (nosotros absorbemos)

---

### 5️⃣ SCRIPTS AUTOMATIZADOS

| Script | Función |
|--------|---------|
| setup-email.sh | Configura IMAP + SMTP + Resend |
| setup-telegram.sh | Crea bot + configura webhook |
| validate-channels.sh | Valida todos los canales |
| setup-api-keys.sh | Configura APIs opcionales |

**Razón:** Automatización reduce errores y tiempo.

---

## 🔢 CHECKLIST FASE 5

| # | Tarea | Estado | Responsable |
|---|-------|--------|-------------|
| 1 | Ejecutar setup-email.sh | ⏳ Pendiente | Cliente |
| 2 | Ejecutar setup-telegram.sh | ⏳ Pendiente | Cliente |
| 3 | Proveer Telegram IDs | ⏳ Pendiente | Cliente |
| 4 | Ejecutar validate-channels.sh | ⏳ Pendiente | Sistema |
| 5 | Configurar APIs opcionales | ⏳ Opcional | Cliente |

---

## 📊 PROGRESO FASE 5

| Etapa | Estado |
|-------|--------|
| ANÁLISIS | ✅ Completado |
| DISEÑO | ✅ Completado |
| CODING | ✅ Completado |
| AUDITORÍA | ⏳ Pendiente |

---

## 📁 ARCHIVOS FASE 5

| Archivo | Estado | Tamaño |
|---------|--------|--------|
| README.md | ✅ | 1.7 KB |
| ANALISIS.md | ✅ | Nuevo |
| DISEÑO.md | ✅ | Nuevo |
| DECISIONES.md | ✅ | Este archivo |
| ACCESOS-CREDENCIALES-FASE5.md | ✅ | 22 KB |
| scripts/setup-email.sh | ✅ | 16 KB |
| scripts/setup-telegram.sh | ✅ | 22 KB |
| scripts/validate-channels.sh | ✅ | 23 KB |
| scripts/setup-api-keys.sh | ✅ | 31 KB |

---

*Decisiones aprobadas: 2026-03-06*
*Aprobado por: H (+50764301378)*
*Próximo paso: AUDITORÍA FASE 5*