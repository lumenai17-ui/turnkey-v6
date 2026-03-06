# FASE 4: IDENTITY FLEET - DECISIONES

**Versión:** 2.0.0
**Fecha:** 2026-03-05
**Estado:** ✅ APROBADO (por usuario H)

---

## 📋 RESUMEN

| Total decisiones | Pendientes | Aprobadas |
|------------------|------------|-----------|
| 9 | 0 | 9 |

---

## DECISIONES APROBADAS

### 1️⃣ FLEET - IDÉNTICO A LOCAL

| Decisión | Valor |
|----------|-------|
| Modelos | 13 modelos (igual que LOCAL) |
| Agente principal | glm-5 |
| Agente thinking | deepseek-v3.1:671b |
| Agente vision | qwen3-vl:235b |
| Agente coding | qwen3-coder-next |

**Razón:** Consistencia con LUMEN LOCAL, probado y funcionando.

---

### 2️⃣ HEART - COPIA EXACTA DE LOCAL

| Decisión | Valor |
|----------|-------|
| Sistema | Escala de Consciencia Hawkins |
| Nivel base | 350 (Aceptación-Razón) |
| Rango operacional | 300-500 |
| Meta | 500+ (Amor) |

**Razón:** El sistema emocional ya está probado y funciona correctamente.

---

### 3️⃣ DOPAMINE - COPIA EXACTA DE LOCAL

| Decisión | Valor |
|----------|-------|
| Sistema | Satisfacción 1-10 |
| Nivel inicial | 7 |
| Integración | Con HEARTBEAT |

**Razón:** El sistema de satisfacción ya está probado y funciona correctamente.

---

### 4️⃣ MEMORIA - MISMA ESTRUCTURA + SECOND BRAIN

| Decisión | Valor |
|----------|-------|
| Estructura base | Igual que LOCAL |
| Second Brain | Para grupos y negocios |
| Embeddings | Habilitados (nomic-embed-text) |
| Recuperación | Contexto semántico |

**Razón:** La memoria con recuperación de contexto es esencial. Second Brain agrega valor para grupos y negocios.

---

### 5️⃣ KNOWLEDGE - MULTI-AGENTE + AUDITORÍA

| Decisión | Valor |
|----------|-------|
| Procesamiento | Multi-agente (5 agentes) |
| Auditoría | Sí, obligatoria |
| Embeddings | Sí, para búsqueda semántica |
| Formatos soportados | PDF, Excel, Docs, Imágenes, URLs |

**Agentes de procesamiento:**
1. CLASIFICADOR - Detecta tipo de archivo
2. EXTRACTOR - Extrae texto/datos
3. ORGANIZADOR - Estructura la información
4. INDEXADOR - Crea índice para búsqueda
5. AUDITOR - Verifica calidad

**Razón:** Procesamiento multi-agente asegura calidad. Auditoría garantiza infalibilidad.

---

### 6️⃣ EMAIL - DOMINIO bee.ai

| Decisión | Valor |
|----------|-------|
| Dominio | bee.ai |
| Formato | {agente}@bee.ai |
| Envío | ✅ Habilitado (Resend API) |
| Recepción | ✅ Habilitado (IMAP/POP3) |
| Adjuntos | ✅ PDFs, imágenes |
| Templates | ✅ HTML |

**Razón:** Email propio del agente. Envío Y recepción como habilidad nata.

---

### 7️⃣ HABILIDADES NATAS (BÁSICAS)

| Habilidad | Función | Habilitada | Costo |
|-----------|---------|------------|-------|
| `email_send` | Enviar emails | ✅ | Resend API |
| `email_read` | Leer emails | ✅ | IMAP gratis |
| `voice_send` | Enviar voice notes | ✅ | TTS local/API |
| `voice_receive` | Recibir voice notes | ✅ | Whisper API |
| `audio_process` | Procesar audio | ✅ | Whisper API |
| `image_generate` | Crear imágenes | ✅ | DALL-E/Flux |
| `image_receive` | Recibir/analizar imágenes | ✅ | Vision models |
| `pdf_generate` | Crear PDFs | ✅ | Puppeteer gratis |
| `pdf_read` | Leer PDFs | ✅ | pdftotext gratis |
| `video_process` | Procesar video corto | ✅ | Vision models |
| `location` | Ubicación/maps | ✅ | Google Maps |
| `calendar` | Google Calendar | ✅ | Google API |
| `sheets` | Google Sheets | ✅ | Google API |
| `translate` | Traducción | ✅ | DeepL/Google |
| `web_create` | Crear sitios web | ✅ NEW | Templates |
| `form_create` | Crear formularios | ✅ NEW | Templates |
| `newsletter_send` | Enviar newsletters | ✅ NEW | Resend |
| `code_execute` | Ejecutar código | ✅ NEW | Sandbox |
| `git_commit` | Commits git | ✅ NEW | Sistema |

**Total: 49 habilidades (35 CORE + 14 opcionales)**

**Razón:** Habilidades básicas que TODO agente debe tener. Aunque tengan costo, son esenciales.

---

### 8️⃣ SKILLS - BUNDLES POR NEGOCIO

| Bundle | Skills |
|--------|--------|
| restaurante | menu, reservas, pedidos, horarios, delivery |
| hotel | reservas, disponibilidad, habitaciones, FAQ |
| tienda | inventario, productos, pedidos, pagos |
| servicios | citas, calendario, reminders, seguimiento |
| generico | FAQ, contacto, horarios |
| **web_development (NEW)** | web_create, form_create, landing_page, web_publish, newsletter_send |

**Total: 10 bundles**

**Razón:** Bundles ahorran tiempo de configuración.

---

### 8️⃣ TOOLS - TODAS + EXTENDIDAS

| Categoría | Tools |
|-----------|-------|
| Esenciales | read, write, exec, browser, web_search, web_fetch, memory_search, whatsapp, telegram, discord, tts, nodes, canvas, cron, sessions_spawn |
| Extendidas | image_generate, pdf_generate, email_send, calendar, sheets, maps |

**Razón:** Tools infalibles es nuestro diferenciador de mercado.

---

### 9️⃣ EMBEDDINGS - HABILITADOS

| Decisión | Valor |
|----------|-------|
| Embeddings | ✅ Habilitados |
| Provider | ollamacloud |
| Modelo | nomic-embed-text |
| Chunk size | 512 |
| Overlap | 50 |

**Razón:** Búsqueda semántica es esencial para recuperación de contexto.

---

## 📊 TABLA RESUMEN

| # | Decisión | Valor |
|---|----------|-------|
| 1 | Fleet | Idéntico a LOCAL (13 modelos) |
| 2 | HEART | Copia exacta de LOCAL |
| 3 | DOPAMINE | Copia exacta de LOCAL |
| 4 | MEMORIA | Misma estructura + Second Brain |
| 5 | Knowledge | Multi-agente + auditoría |
| 6 | Email | bee.ai, envío Y recepción |
| 7 | **Habilidades Natas** | **14 habilidades básicas** |
| 8 | Skills | Bundles por tipo de negocio |
| 9 | Tools | Todas + image_generate, pdf_generate |
| 10 | Embeddings | Habilitados |

---

## 🔢 HABILIDADES NATAS (14 habilidades)

| # | Habilidad | Función | habilitada |
|---|-----------|---------|------------|
| 1 | email_send | Enviar emails | ✅ |
| 2 | email_read | Leer/recibir emails | ✅ |
| 3 | voice_send | Enviar voice notes | ✅ |
| 4 | voice_receive | Recibir voice notes | ✅ |
| 5 | audio_process | Procesar audio | ✅ |
| 6 | image_generate | Crear imágenes | ✅ |
| 7 | image_receive | Analizar imágenes | ✅ |
| 8 | pdf_generate | Crear PDFs | ✅ |
| 9 | pdf_read | Leer PDFs | ✅ |
| 10 | video_process | Procesar video | ✅ |
| 11 | location | Ubicación/maps | ✅ |
| 12 | calendar | Google Calendar | ✅ |
| 13 | sheets | Google Sheets | ✅ |
| 14 | translate | Traducción | ✅ |

---

## 🔗 DEPENDENCIAS

| Decisión | Depende de |
|----------|------------|
| Fleet | API key Ollama (FASE 1) |
| Email | Dominio bee.ai configurado |
| Embeddings | API key Ollama |
| Knowledge | Archivos de FASE 1 |

---

---

## 📊 PROGRESO ÁREAS FASE 4

| # | Área | Estado | Archivos |
|---|------|--------|----------|
| 1 | KNOWLEDGE | ✅ Completado | PROFUNDIZACION-KNOWLEDGE.md |
| 2 | HABILIDADES NATAS | ✅ Completado | SUPER-AGENTE-HABILIDADES.md, PROFUNDIZACION-HABILIDADES.md |
| 3 | HEART/DOPAMINE | ✅ Completado | HEART.md, DOPAMINE.json, heart-config.md, HEARTBEAT.md |
| 4 | SECOND BRAIN | ✅ Completado | SECOND-BRAIN.md, second-brain-config.yaml |
| 5 | Fleet | ✅ Completado | FLEET.json (copia de LOCAL) |
| 6 | Skills Bundles | ✅ Completado | SKILLS-BUNDLES.md, skills-bundles.json |
| 7 | Email bee.ai | ✅ Completado | email-config.json, email-templates.json |
| 8 | TODO | ✅ Completado | TODO.md, todo-config.json |

---

*Decisiones aprobadas: 2026-03-05*
*Aprobado por: H (+50764301378)*
*Auditoría: 2026-03-06 - ✅ APROBADA*
*Correcciones aplicadas: 3*
*Nuevas habilidades: +5 (web_create, form_create, newsletter_send, code_execute, git_commit)*
*Archivos totales: 28*
*Total habilidades: 49 (35 CORE + 14 opcionales)*
*Total bundles: 10*
*Próximo paso: FASE 5 - BOT CONFIG*