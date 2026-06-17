# F4A: Skills Selective Loading Decision

**Estado:** ✅ DECISION ONLY para F4A-full — F4A-lite ya implementado como RUNTIME PASS  
**Fecha:** 2026-06-17 (actualizado 2026-06-17)

## Decisión original (F4A-full)

F4A-full queda **postergado como cambio funcional**. No se modifica `opencode.json`, no se alteran rutas ni se implementa carga selectiva dinámica de skills.

## Lo que cambió: F4A-lite (implementado y activo)

El 2026-06-17 se aprobó e implementó **F4A-lite**: compactación solo de `description:` en frontmatter de 36 `SKILL.md`. No se tocaron cuerpos de skills, `opencode.json`, rutas ni configuración runtime.

| Dimensión | F4A-full (no implementado) | F4A-lite (✅ RUNTIME PASS) |
|---|---|---|
| Alcance | Carga selectiva dinámica de bloques de skills | Compactar solo `description:` visible |
| Ahorro | ~400-1,184 tokens | 3,532 chars (~883-1,177 tokens) |
| Riesgo | Medio-alto (falsos negativos en matching) | Bajo (solo cambia descripción visible, no matching) |
| `opencode.json` | Requiere cambio | No tocado |
| Cuerpos de skills | Potencialmente afectados | Intactos (body hash verificado) |
| Estado | ⏸️ Pendiente de aprobación | ✅ RUNTIME PASS |

## Alternativas originales (actualizadas con F4A-lite)

| Alternativa | Ahorro real | Riesgo | Estado |
|---|---:|---|---|
| Hook agrega SKILLS_PACK contextual | Bajo / puede duplicar | Bajo | Solo diseño |
| Reducir bloque en `opencode.json` | ~400-1,184 tokens | Medio | Requiere aprobación |
| **F4A-lite: editar descripciones en `SKILL.md`** | **3,532 chars (~883-1,177 tokens)** | **Bajo** | **✅ RUNTIME PASS** |
| No hacer nada | 0 | Ninguno | Superado por F4A-lite |

## Challenge

Usuario: evita cambios globales no aprobados. Técnico: F4A-lite demostró que editar solo `description:` es seguro y efectivo. Seguridad: no tocar config ni cuerpos reduce riesgo. Senior: F4A-lite correcto; F4A-full debe evaluarse con datos de uso real. QA: harness valida que no hay regresión. Gerente: F4A-lite ya dio ~1,000 tokens de ahorro sin riesgo.

## Próxima decisión requerida

Si se aprueba **F4A-full**: elegir `opencode.json` compactado, SKILLS_PACK por hook u otra estrategia. F4A-lite ya está activo y no necesita cambios adicionales.
