# PREGUNTAS - FASE 1: PRE-FLIGHT

**Fecha:** 2026-03-05
**Estado:** ✅ RESPONDIDAS

---

## ✅ Preguntas Respondidas

### P1: ¿Agregar valores por defecto adicionales?
**Respuesta:** *Definir cuáles son los valores por defecto*

**Decisión tomada:** Ver lista completa en DECISIONES.md sección "Valores por Defecto Adicionales"

---

### P2: ¿Dónde ubicar turnkey-defaults.json?
**Respuesta:** *No sé, qué sugieres*

**Sugerencia:** `~/.openclaw/workspace/turnkey/turnkey-defaults.json`

**Razón:**
- No requiere root para editar
- Consistente con estructura existente
- Junto a otros archivos de trabajo

**Estado:** ⏳ Pendiente confirmación

---

### P3: ¿Validar API key Ollama durante pre-flight?
**Respuesta:** *Sí validar, pero antes hay que validar e incluir en el setup si el cliente es Ollama pagado o gratis*

**Decisión tomada:**
1. Verificar si existe OLLAMA_API_KEY
2. Verificar tipo de cuenta (gratis/paga)
3. Validar que la key funciona

**Implementación:**
- Llamar endpoint de cuenta para verificar plan
- Guardar tipo de cuenta en turnkey-config.json
- Ajustar límites y modelos según plan

---

### P4: ¿Qué hacer si no hay API key de Ollama?
**Respuesta:** *Siempre debe haber Ollama key gratis o paga*

**Decisión tomada:**
- API key de Ollama es MANDATORIA
- Si no existe → Pedir interactivamente
- Si el usuario no tiene → Dirigir a ollama.com para obtener key gratis
- NO proceder sin key

---

### P5: ¿Cómo manejar recursos por debajo del mínimo?
**Respuesta:** *Corregir si se puede o pedir ayuda humana*

**Decisión tomada:**
- Si se puede corregir automáticamente → Corregir
- Si NO se puede corregir → Pedir intervención humana
- Ejemplos:
  - Puerto ocupado → Buscar siguiente disponible (corregir)
  - RAM insuficiente → Pedir aumentar RAM (ayuda humana)
  - Disco lleno → Sugerir limpiar (ayuda humana)

---

### P6: ¿Guardar aceptación de recursos insuficientes?
**Respuesta:** *No proceder sin recursos, el producto no funciona*

**Decisión tomada:**
- Si los recursos son.insuficientes para funcionar → NO PROCEDER
- Error crítico, no warning
- El usuario DEBE solucionar antes de continuar
- Guardar estado en turnkey-status.json para referencia

---

### P7: ¿En modo interactivo, preguntar solo lo faltante?
**Respuesta:** *Sí, ok interactivo*

**Decisión tomada:**
- Si hay config parcial → Preguntar solo lo que falta
- Si no hay config → Preguntar todo paso a paso
- Usar defaults para valores no especificados

---

### P8: ¿Formato de input interactivo?
**Respuesta:** *No sé, qué sugieres*

**Sugerencia:** Mixto (menús + texto)

**Formato:**
```
# Para opciones predefinidas: menú numerado
? Template de personalidad:
  1) restaurant
  2) hotel
  3) retail
  4) services
  5) custom
  Selecciona [1-5] (5): 

# Para valores personalizados: texto libre con default
? Nombre del agente (Agent-1709644800): MiAgente
? Rol del agente (Asistente virtual): 
```

**Estado:** ⏳ Pendiente confirmación

---

### P9: ¿Telegram por defecto o sin canales?
**Respuesta:** *Telegram por defecto (WhatsApp habilitado, Discord habilitado)*

**Decisión tomada:**
- Telegram: Habilitado por defecto (requiere token)
- WhatsApp: Habilitado por defecto (requiere config)
- Discord: Habilitado por defecto (requiere token)
- Email: Deshabilitado por defecto

**Comportamiento:**
- Si hay token/config → Canal funciona
- Si NO hay token/config → Canal habilitado pero advertir que no funcionará hasta configurar

---

## ✅ Todas las Preguntas Respondidas y Confirmadas

**Estado:** COMPLETADO - 2026-03-05

---

*Actualizado: 2026-03-05*