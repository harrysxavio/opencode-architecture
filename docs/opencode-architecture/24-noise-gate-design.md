# 24 — Noise Gate: Design Proposal (E6A)

> Diseño del Noise Gate para la captura automática de `user_prompts` en Engram.

**Creado en:** Fase E6A (2026-06-10)
**Estado:** Propuesta de diseño — pendiente de aprobación para E6B
**Prerrequisito:** Doc 23 — Prompt Capture Audit

---

## 1. Objetivo

Agregar una **capa de decisión consciente** al hook `chat.message` del plugin `engram.ts` que clasifique cada prompt del usuario y decida:

1. **¿Este prompt merece ser persistido como user_prompt?**
2. **¿Con qué metadata (tipo, sensibilidad, resumen) debe ser persistido?**
3. **¿Debe redirigirse a observations en lugar de user_prompts?**

Sin perder continuidad cross-session, sin romper `mem_context`, sin agregar latencia perceptible.

---

## 2. Restricciones de Diseño

1. **No romper `mem_context`** — `recentUserPrompts` debe seguir funcionando.
2. **Latencia despreciable** — la clasificación debe ser O(1) o O(n) sobre el texto del prompt, sin llamadas externas.
3. **No depender del LLM** — clasificar antes de que el LLM vea el prompt (el hook se ejecuta ANTES de generar respuesta).
4. **No perder contexto valioso** — mejor falsos positivos (capturar ruido) que falsos negativos (perder contexto útil).
5. **Configurable sin modificar plugin** — el gate debe poder ajustarse vía configuración, no código.
6. **Conservador por defecto** — el gate inicial debe ser el menos restrictivo posible.

---

## 3. Opciones de Implementación

### Opción A: Gate Mínimo — Blacklist de Patrones

**Cómo funciona:**
- Lista de patrones regex (configurable en `opencode.json` o archivo externo).
- Si el prompt coincide con algún patrón → no se captura.
- Si no coincide → se captura como hoy.

**Ejemplos de patrones:**
- `/^(sí|no|ok|dale|okay|continuá|seguí|listo|hecho|ahí va|bien|perfecto|claro)$/i`
- `/^(mostrame|andá a|qué hay en|navegá a|abrí)\s/i`
- `/^(continuá con|seguí con|procedé con|adelante)$/i`

**Pros:**
- Mínimo cambio: solo agregar if + regex match.
- Latencia O(n) insignificante.
- Configurable sin modificar plugin.
- Reversible.

**Contras:**
- No captura prompts con intención híbrida ("sí, pero cambiale el color").
- No diferencia sensibilidad.
- No agrega metadata.
- La blacklist puede quedar obsoleta.

**Esfuerzo:** Bajo (~30 líneas en plugin + config).
**Riesgo:** Muy bajo.

---

### Opción B: Clasificación por Heurísticas

**Cómo funciona:**
- Reglas heurísticas sobre el texto antes de capturar.
- Clasifica en: `instruction`, `question`, `confirmation`, `navigation`, `noise`.
- Decide capturar o no según la clasificación + umbrales configurables.

**Heurísticas candidatas:**
- `confirmation` → longitud < 20 chars AND (empieza con sí/no/ok/dale/listo/bien/hecho/ahí...)
- `navigation` → empieza con verbo de exploración (mostrame, andá, qué hay, navegá, abrí)
- `noise` → longitud < 15 chars AND no contiene palabras significativas
- `question` → contiene signo de pregunta ¿? o empieza con qué/cómo/por qué/dónde/cuándo/quién
- `instruction` → contiene verbos en imperativo O palabras clave del dominio O longitud > 100 chars
- Default → `instruction` (conservador: si no estamos seguros, capturar)

**Regla de captura:**
- `noise` → NO capturar
- `navigation` → capturar con type=command (baja prioridad)
- `confirmation` → NO capturar (a menos que sea follow-up con contenido nuevo)
- `instruction` / `question` → capturar siempre

**Pros:**
- Clasificación consciente sin depender del LLM.
- Latencia O(n) baja.
- Agrega metadata útil para recuperación futura.
- Configurable por umbrales.

**Contras:**
- Más líneas de código (~100-150 en plugin).
- Las heurísticas requieren afinación inicial.
- Puede clasificar mal prompts ambiguos.

**Esfuerzo:** Medio (~100-150 líneas en plugin + schema update opcional).
**Riesgo:** Bajo-Medio.

---

### Opción C: Gate Híbrido — Heurísticas + Clasificación Diferida

**Cómo funciona:**
1. Heurísticas rápidas en hook `chat.message` para clasificación instantánea.
2. Siempre captura (como hoy) pero CON tipo y metadata.
3. Un proceso async (fuera del hook) puede re-clasificar o limpiar después.

**Pros:**
- No pierde ningún prompt (seguridad de continuidad).
- Agrega metadata progesivamente.
- Combina velocidad inicial con precisión diferida.

**Contras:**
- Sobrecarga de implementación: requiere proceso async.
- Todos los prompts se guardan igual (el cleanup es posterior).
- Mayor complejidad.

**Esfuerzo:** Alto (~300+ líneas en plugin + posible worker externo).
**Riesgo:** Medio.

---

## 4. Opción Recomendada: B — Clasificación por Heurísticas

### Justificación

| Criterio | A (Blacklist) | B (Heurísticas) | C (Híbrido) |
|----------|:---:|:---:|:---:|
| Latencia | ✅ Mínima | ✅ Baja | ⚠️ Mayor |
| Precisión | ⚠️ Baja | ✅ Media-Alta | ✅ Alta |
| Complejidad | ✅ Mínima | ✅ Media | ❌ Alta |
| Configurable | ✅ Sí | ✅ Sí | ⚠️ Parcial |
| Metadata | ❌ No | ✅ Sí | ✅ Sí |
| Riesgo romper | ✅ Mínimo | ✅ Bajo | ⚠️ Medio |
| Esfuerzo E6B | ~30 líneas | ~120 líneas | ~300+ líneas |

**Opción B** es el punto óptimo: agrega clasificación consciente con bajo riesgo y esfuerzo medio. La metadata (tipo de prompt) abre la puerta a filtrado más inteligente en `mem_context` sin cambios arquitectónicos.

---

## 5. Especificación Técnica para E6B

### 5.1 Modificaciones al Plugin `engram.ts`

#### Hook `chat.message` modificado:

```typescript
// Después de extraer finalContent y antes de enviar a Engram:

interface PromptClassifyResult {
    type: "instruction" | "question" | "confirmation" | "navigation" | "noise"
    shouldCapture: boolean
    sensitivity: "normal" | "sensitive" | "private"
}

function classifyPrompt(text: string): PromptClassifyResult {
    const trimmed = text.trim()
    const len = trimmed.length
    
    // Regla 1: Ruido — mensajes muy cortos sin contenido semántico
    if (len < 10) {
        return { type: "noise", shouldCapture: false, sensitivity: "normal" }
    }
    
    // Regla 2: Confirmación — respuestas afirmativas/negativas simples
    if (len < 30) {
        const confirmPattern = /^(s[iíí]n?|no|ok|dale|okay|listo|hecho|bien|perfecto|claro|ah[íií] voy|adelante|proced[aáe]|segu[ií]|continu[aáe]|entendido|de acuerdo|suena bien|me gusta|esa es|ah[íií] est[aá]|eso es|vamos|d[áa]le nomas|genial|excelente|b[aá]rbaro|joya|de una|tal cual|exacto|obvio|seguro|puede ser|no sé|no estoy seguro|no me convence)\s*[.!]?\s*$/i
        if (confirmPattern.test(trimmed)) {
            return { type: "confirmation", shouldCapture: false, sensitivity: "normal" }
        }
    }
    
    // Regla 3: Navegación — comandos de exploración
    const navPattern = /^(mostrame|and[aá] a|qu[eé] hay en|naveg[aá] a|abr[ií]|mostr[aá]|ense[nñ]ame|ll[eé]vame a|busc[aá]|encontr[aá]|d[oó]nde est[aá]|c[oó]mo llego a|qu[eé] contiene|mostrame el archivo|abr[ií] el archivo|listame|enumera|qu[eé] archivos|qu[eé] carpetas)/i
    if (navPattern.test(trimmed)) {
        return { type: "navigation", shouldCapture: false, sensitivity: "normal" }
    }
    
    // Regla 4: Pregunta
    const questionPattern = /[¿?]|^(qu[eé]|c[oó]mo|por qu[eé]|d[oó]nde|cu[aá]ndo|qui[eé]n|cu[aá]l|cu[aá]les|para qu[eé]|a qu[eé] hora)\s/i
    if (questionPattern.test(trimmed)) {
        return { type: "question", shouldCapture: true, sensitivity: "normal" }
    }
    
    // Regla 5: Sensibilidad — detectar patrones que podrían ser sensibles
    const sensitivePatterns = [
        /(?:api[_-]?key|apikey|secret|password|token|credential|auth[_-]?token)/i,
        /(?:contrase[nñ]a|clave|secreto|token|credencial)/i,
        /\.env/i,
        /(?:export\s+\w+)=/i,
    ]
    const hasSensitive = sensitivePatterns.some(p => p.test(trimmed))
    
    // Default: instrucción (conservador — capturar)
    return {
        type: "instruction",
        shouldCapture: true,
        sensitivity: hasSensitive ? "sensitive" : "normal",
    }
}
```

#### Nueva estructura de captura:

```typescript
const classification = classifyPrompt(finalContent)

if (classification.shouldCapture) {
    let contentToStore = finalContent
    let redactedContent: string | null = null
    
    if (classification.sensitivity === "sensitive") {
        // Almacenar también versión redactada para contexto público
        redactedContent = redactSensitive(contentToStore)
    }
    
    await engramFetch("/prompts", {
        method: "POST",
        body: {
            session_id: sessionId,
            content: contentToStore,
            project,
            type: classification.type,
            sensitivity: classification.sensitivity,
            redacted_content: redactedContent,
            char_count: finalContent.length,
        },
    })
}
```

#### Nuevo campo `allow_prompt_capture` en configuración:

```typescript
// Leer de opencode.json o variable de entorno
const allowPromptCapture = config.allow_prompt_capture ?? "classified"
// Valores: "all" (comportamiento actual), "classified" (gate activo), "never" (desactivado)
```

### 5.2 Schema Changes (user_prompts table)

Opcional para E6B — puede agregarse en migración posterior:

```sql
ALTER TABLE user_prompts ADD COLUMN type TEXT DEFAULT 'unknown';
ALTER TABLE user_prompts ADD COLUMN sensitivity TEXT DEFAULT 'normal';
ALTER TABLE user_prompts ADD COLUMN redacted_content TEXT;
ALTER TABLE user_prompts ADD COLUMN char_count INTEGER DEFAULT 0;
```

### 5.3 Modelo de Configuración

En `opencode.json` / `opencode.jsonc`:

```jsonc
{
  "plugins": {
    "engram": {
      "allow_prompt_capture": "classified",   // "all" | "classified" | "never"
      "noise_gate": {
        "enabled": true,
        "min_length": 10,                      // umbral mínimo (default: 10)
        "capture_navigation": false,            // capturar comandos de navegación
        "capture_confirmation": false,          // capturar confirmaciones
        "sensitive_detection": true,            // detectar patrones sensibles
        "custom_patterns": []                   // patrones adicionales
      }
    }
  }
}
```

### 5.4 Impacto en Componentes Existentes

| Componente | Impacto | Mitigación |
|------------|---------|------------|
| `mem_context` | Bajo — menos `recentUserPrompts` | Las observaciones y sessions no cambian |
| `experimental.session.compacting` | Bajo — contexto más limpio | Beneficioso: menos ruido en compactación |
| `mem_save` (Manager) | Ninguno | No toca observations |
| DB schema `user_prompts` | Opcional — migración para nuevos campos | Sin migración: solo agrega campos si existen |

---

## 6. Plan de Migración E6B

### Fase 1: Gate Mínimo (~30 min)
1. Agregar `classifyPrompt()` con heurísticas básicas en `engram.ts`.
2. Agregar `allow_prompt_capture: "classified"` en `opencode.jsonc`.
3. Validar con tests manuales que `mem_context` sigue funcionando.

### Fase 2: Metadata (~30 min, opcional)
4. Migrar DB para agregar columnas `type`, `sensitivity`.
5. Modificar POST /prompts para aceptar nuevos campos.
6. Actualizar GET /context para filtrar por tipo.

### Fase 3: Afinación (~1 semana, posterior)
7. Monitorear falsos positivos/negativos.
8. Ajustar patrones de heurísticas.
9. Decidir si habilitar `capture_navigation` o `capture_confirmation`.

### Rollback
- Cambiar `allow_prompt_capture` a `"all"` = comportamiento exacto actual.
- Revertir cambios en `engram.ts` (git revert).

---

## 7. Criterios de Aceptación para E6B

| # | Criterio | Método de verificación |
|---|----------|----------------------|
| 1 | Prompts de confirmación (< 30 chars, patrón afirmativo) no se capturan | Test con "sí", "ok", "dale", "listo" |
| 2 | Prompts de navegación no se capturan | Test con "mostrame X", "andá a Y" |
| 3 | Instrucciones se capturan normalmente | Test con "implementá X en archivo Y" |
| 4 | Preguntas se capturan normalmente | Test con "¿cómo funciona X?" |
| 5 | `mem_context` sigue devolviendo `recentUserPrompts` | Test E6-T3 adaptado |
| 6 | Modo `"all"` replica comportamiento actual exactamente | Test comparativo |
| 7 | Modo `"never"` no captura ningún prompt | Test con varios mensajes |
| 8 | Config sin cambios (default) sigue capturando todo | Test con config sin noise_gate |
| 9 | Rollback: cambiar a `"all"` restaura comportamiento anterior | Test A/B |

---

## 8. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|-----------|
| Falsos negativos (perder contexto útil) | Media | Medio | Heurísticas conservadoras por defecto; modo "all" como respaldo |
| Falsos positivos (no filtrar ruido) | Alta | Bajo | Mejor que falsos negativos; afinación post-implementación |
| Romper mem_context | Baja | Alto | Tests E6-T3 garantizan que mem_context sigue funcional |
| Latencia adicional | Baja | Bajo | Heurísticas son O(n) sobre texto, < 1ms en prompts típicos |
| Config confusa | Baja | Bajo | Documentación clara + default conservador |

---

## 9. Decisión

**Estado:** Pendiente de aprobación.

Para aprobar E6B, se necesita:
1. Revisar este diseño.
2. Decidir si implementar Fase 1 solamente o Fase 1 + 2.
3. Dar `?Apruebas este diseño para pasar a E6B (implementación)?`.

---
*Fin del documento E6A — Design Proposal. Ningún archivo runtime fue modificado.*
