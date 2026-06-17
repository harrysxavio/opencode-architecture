# F4C: mem_context Selector Implementation Report

**Estado:** ✅ IMPLEMENTED (Manager guidance via system transform)  
**Fecha:** 2026-06-17  
**Cambio funcional:** `~/.config/opencode/plugins/engram.ts` inyecta `MEMORY_SELECTOR_INSTRUCTIONS` en `experimental.chat.system.transform`.

## Resultado ejecutivo

Se implementó el selector en la ruta más segura: instrucciones compactas al Manager, sin modificar Engram DB, Engram core, schema ni MCP tools. No cambia el resultado de `mem_context`; cambia cómo el Manager debe rankear, deduplicar y justificar memorias recuperadas.

## 1. Evaluación inicial

Entradas revisadas: `F4C-mem-context-selector.md`, `F4C-selector-scoring-spec.md`, `F4C-selector-test-cases.md`, `F4D-runtime-api-verification.md`.

Gaps cubiertos: legacy penalty, empty search fallback, secret exclusion, exact project match y explainability.

## 2. Diseño aplicado

- score = relevance 0.5 + recency 0.3 + type 0.2;
- decay = `max(0, 1 - daysSince * 0.05)`;
- decisiones conservan floor;
- top-k por modo: 5/10/20/30/unbounded;
- penalizar legacy/cross-project;
- deduplicar por `topic_key` o contenido superpuesto;
- fallback gradual;
- excluir secretos;
- explicar memorias que cambian la respuesta.

## 3. Implementación segura

Se extendió `experimental.chat.system.transform`: antes inyectaba `MEMORY_INSTRUCTIONS`; ahora inyecta `MEMORY_INSTRUCTIONS` + `MEMORY_SELECTOR_INSTRUCTIONS`. No se agregaron herramientas nuevas ni se tocó `mem_context`.

## 4. Validación funcional

| Caso | Estado |
|---|---:|
| Hook system transform existe | ✅ |
| Instrucciones selector presentes | ✅ |
| Scoring 0.5/0.3/0.2 presente | ✅ |
| Decay 0.05 presente | ✅ |
| Top-k por modo presente | ✅ |
| Legacy/cross-project penalty presente | ✅ |
| Secret exclusion presente | ✅ |
| Explainability presente | ✅ |

## 5. Revisión técnica

Estabilidad alta: instrucciones solamente. Trazabilidad media-alta: el Manager debe explicar memorias relevantes. Mantenibilidad alta: constante aislada. Riesgo bajo: no altera DB ni endpoint `mem_context`.

## 6. Revisión de seguridad

Exact project match requerido por instrucción, legacy/cross-project penalizado, secret-like content excluido y sin cambios esperados en `.engram/engram.db`.

## 7. Challenge multiperspectiva

| Perspectiva | Conclusión |
|---|---|
| Usuario | Mejora qué memorias se usan. |
| Técnico | Versión más segura antes de enforcement en Engram core. |
| Seguridad | Evita cross-project por instrucción explícita, no enforcement DB-level. |
| Senior | Guidance primero es prudente. |
| QA | Tests sintéticos cubren ranking. |
| Gerente/ROI | Potencial ~500-2,000 tokens/turno. |
| Mantenibilidad | Constante compacta. |
| Ecosistema/gentle-ai | No integra gentle-ai. |

## 8. Mejora posterior al challenge

Se evitó modificar Engram Go. El enforcement fuerte queda como futuro si el guidance demuestra valor sin degradar calidad.

## Rollback

Restaurar backup de `engram.ts` o remover `MEMORY_SELECTOR_INSTRUCTIONS` y su concatenación. Reiniciar OpenCode.

## PASS/FAIL

**PASS con advertencia:** selector guidance, no enforcement dentro de Engram core.
