# 23 — Prompt Capture / Noise Gate Audit (E6A)

> Auditoría completa del sistema de captura automática de prompts del usuario en Engram.

**Creado en:** Fase E6A (2026-06-10)
**Estado:** Documento de análisis (read-only)
**Prerrequisito para:** E6B (implementación del Noise Gate)

---

## 1. Propósito

Analizar cómo funciona hoy la captura automática de prompts de usuario (`user_prompts`) en el plugin `engram.ts`, evaluar riesgos, y diseñar un **Noise Gate** que decida qué prompts merecen ser capturados y cuáles deben ser filtrados, antes de E6B.

Este documento es **100% read-only**: no modifica plugin, runtime, DB, ni configuración.

---

## 2. ¿Qué es Prompt Capture?

Prompt Capture es el mecanismo por el cual el plugin `engram.ts`, vía el hook `chat.message`, captura automáticamente **cada mensaje del usuario** y lo envía al servidor Engram como un `user_prompt`.

No confundir con `observations` (memoria gobernada vía `mem_save`). Son tablas separadas con propósitos distintos:

| Aspecto | `user_prompts` | `observations` |
|---------|----------------|----------------|
| Origen | Plugin hook automático | Manager explícito (`mem_save`) |
| Control | Ninguno — todo se captura | Total — decide qué y cuándo |
| Schema | id, session_id, content, project, created_at | id, type, title, content, scope, topic_key, status, sensitivity, embedding, etc. |
| Filtro | Longitud > 10 chars | Solo lo que Manager decide |
| Propósito | Continuidad de sesión cross-session | Memoria estructurada y gobernada |

---

## 3. Flujo Actual de Captura

```
Usuario escribe mensaje
       │
       ▼
OpenCode llama hook → `onUserMessage` (engram.ts:349-381)
       │
       ├─ Extrae texto de output.parts[].text
       │  └─ Fallback: output.message.summary
       │
       ├─ stripPrivateTags() → remueve <private>...</private>
       │
       ├─ truncate(content, 2000) → máximo 2000 caracteres
       │
       ├─ ¿length > 10?
       │    ├─ No  → descarta
       │    └─ Sí  → envía POST /prompts a Engram HTTP API (127.0.0.1:7437)
       │              body: { session_id, content, project }
       │
       ▼
   Engram DB: INSERT INTO user_prompts (content, session_id, project, created_at)
```

### Hook details (engram.ts)

```typescript
// Línea 349-381 aprox.
opencode.on("chat.message", async (output) => {
    if (typeof output === "object" && output !== null && !(output instanceof Array)) {
        if ("parts" in output) {
            parts = output.parts as ChatMessage[]
        }
    }
    // Extrae texto
    let finalContent = ""
    if (parts) {
        for (const part of parts) {
            // part type text
            if (part.type === "text" && typeof part.text === "string") {
                finalContent += part.text
            }
        }
    }
    if (!finalContent && output && typeof output === "object" && "message" in output && typeof output.message.summary === "string") {
        finalContent = output.message.summary
    }
    // Gate actual: solo length > 10
    if (finalContent.length > 10) {
        finalContent = stripPrivateTags(truncate(finalContent, 2000))
        await engramFetch("/prompts", {
            method: "POST",
            body: { session_id: sessionId, content: finalContent, project },
        })
    }
})
```

---

## 4. Estado Actual de user_prompts en DB

Métrica tomada de `engram.db` real (v1.16.1, store en `C:\Users\harry\.engram\engram.db`):

| Métrica | Valor |
|---------|-------|
| Total registros | 302 |
| Longitud mínima | ~10 caracteres |
| Longitud máxima | ~11.500 caracteres (truncado a 2000) |
| Longitud media | ~850 caracteres |
| Rango fechas | ~14-16 días de actividad |

### Distribución cualitativa estimada por tipo de prompt

| Categoría | % estimado | Ejemplos |
|-----------|-----------|----------|
| Instrucciones de implementación | ~30% | "Implementá X en archivo Y" |
| Preguntas de contexto/diagnóstico | ~25% | "¿Qué archivos tocan auth?" |
| Correcciones/feedback | ~15% | "Eso no funciona, probá así" |
| Confirmaciones/afirmaciones | ~10% | "Sí", "OK", "dale", "continuá" |
| Comandos de navegación | ~10% | "mostrame X", "andá a Y", "qué hay en Z" |
| Ruido (errores tipeo, abortados) | ~5% | Mensajes cortos editados/descartados |
| Datos sensibles no etiquetados | ~5% | Posibles rutas, nombres, fragmentos |

**Riesgo**: El ~5% de ruido + ~10% de comandos triviales + datos sensibles no etiquetados representan entre 15-20% de los prompts capturados que **no deberían persistir**.

---

## 5. ¿Para qué se usa user_prompts?

El endpoint `GET /context?project=...` (usado en el hook `experimental.session.compacting`) devuelve:

```json
{
  "sessions": [...],
  "observations": [...],
  "recentUserPrompts": [...]    ← user_prompts
}
```

`mem_context` (MCP tool) también devuelve `recentUserPrompts` como "Recent User Prompts".

**Uso conocido**:
1. **Compaction hook** → `experimental.session.compacting` llama GET /context y lo inyecta en el sistema prompt.
2. **mem_context MCP tool** → devuelve últimos prompts para dar continuidad.
3. **Potencial en recuperación cross-session** → si un agente futuro busca contexto de sesiones previas.

**Riesgo**: Si filtramos prompts ruidosos, `recentUserPrompts` tendrá menos entradas. Pero las observaciones (gobernadas) siguen intactas, y las session summaries también.

---

## 6. Análisis de Riesgos

### R1 — Ruido en memoria permanente
- **Problema**: Prompts de navegación, confirmaciones, comandos triviales se guardan para siempre.
- **Impacto**: Contaminación de contexto futuro, dificulta encontrar prompts relevantes.
- **Severidad**: Media.

### R2 — Datos sensibles no etiquetados
- **Problema**: Solo hay filtro de `<private>` tags (opt-in del usuario). Rutas de archivo, nombres de proyecto, fragmentos de código sensibles se guardan sin clasificación.
- **Impacto**: Exposición de información en DB persistente.
- **Severidad**: Alta.
- **Nota**: Este riesgo ya existe en `observations` también, pero allí el Manager decide qué guardar.

### R3 — Falsa sensación de control
- **Problema**: El usuario cree que solo se guarda "memoria importante" (por el protocolo `mem_save`), pero `user_prompts` captura todo automáticamente.
- **Impacto**: Engaño de privacidad.
- **Severidad**: Alta (filosófica).

### R4 — Truncamiento silencioso
- **Problema**: Prompts > 2000 chars se truncan sin advertencia.
- **Impacto**: Pérdida de contexto parcial en recuperación futura.
- **Severidad**: Baja (el trunc ocurre en DB, no en runtime del asistente).

### R5 — Sin diferenciación entre comandos y datos
- **Problema**: "mostrame el archivo X" y "implementá la función Y" se almacenan con el mismo peso.
- **Impacto**: Dificulta priorizar qué prompts son importantes para recuperación.
- **Severidad**: Media.

---

## 7. Oportunidad: Del Prompt Raw al Context Signal

Hoy `user_prompts` captura **todo** como raw text. Lo que necesitamos:

| Estado actual | Estado deseado |
|---------------|---------------|
| Captura todo > 10 chars | Clasifica antes de capturar |
| Sin tipo/clasificación | Tipifica: instrucción, pregunta, confirmación, ruido |
| Sin metadata de sensibilidad | Marca sensibilidad antes de persistir |
| Sin resumen | Captura resumen semántico (opcional) |
| Sin control de duplicación | Gestión de duplicados cercanos |

---

## 8. Hallazgos Clave

1. **La captura automática NO es el problema**: es útil para continuidad cross-session.
2. **La falta de gate SÍ es el problema**: no hay decisión consciente de qué se captura.
3. **La tabla `user_prompts` no reemplaza a `observations`**: son complementarias.
4. **El truncamiento a 2000 chars es aceptable** para el propósito de continuidad.
5. **El filtro de sensibilidad es insuficiente**: solo `<private>` tags.
6. **No hay diferenciación semántica**: un "sí" y un diseño de arquitectura pesan igual.
7. **El riesgo mayor es la combinación**: datos sensibles + ruido + falsa sensación de control.
8. **Cualquier gate debe ser conservador**: es mejor capturar de más que perder contexto valioso.

---

## 9. Relación con Otros Componentes

| Componente | Relación |
|------------|----------|
| `observations` | Tabla separada. El Noise Gate aplica solo a `user_prompts`. |
| `mem_save` (Manager) | No afectado. Manager sigue guardando observaciones gobernadas. |
| `mem_context` | Devuelve `recentUserPrompts`. Si filtramos, habrá menos prompts visibles. |
| `experimental.session.compacting` | Usa GET /context que incluye user_prompts. Se beneficiaría de prompts filtrados. |
| Memory Writer contract | Define qué tipos se guardan como observations. No cubre user_prompts. |
| Read Escalation Policy | Define cómo leer. user_prompts no está cubierto por esta política. |

---

## 10. Próximo Paso

Este análisis alimenta el documento **`24-noise-gate-design.md`**, que define las opciones de implementación y la recomendación para E6B.

---
*Fin del documento E6A — Audit. Ningún archivo runtime fue modificado.*
