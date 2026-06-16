# F-T6 — Formal Test: Sin activación de componentes innecesarios

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar que al invocar `mem_context` no se activan componentes que deberían permanecer inactivos: subagentes, skills, MCP servers no relacionados, tools de escritura, ni SDD pipeline.

## Restricciones (read-only)

Ídem F-T1. Este test es observacional: se ejecuta el input y se documenta qué componentes se activan (o no).

## Input objetivo

```text
engram_mem_context(project="opencode-architecture")
```

## Componentes que NO deben activarse

| Componente | ¿Se activó? | Evidencia |
|------------|:-----------:|-----------|
| **subagentes** (task/delegate) | ❌ No | Sin invocación de agentes secundarios |
| **skills** (skill tool) | ❌ No | Sin carga de SKILL.md |
| **SDD pipeline** (gentle-orchestrator) | ❌ No | Sin llamada a gentle-orch |
| **MCP no-Engram** (Context7, NotebookLM, Playwright, etc.) | ❌ No | Sin tools de otros MCP servers |
| **Escritura** (write, edit, bash efectos) | ❌ No | Sin modificación de archivos/DB |
| **mem_save** | ❌ No | Sin guardado de memoria |
| **mem_session_summary** | ❌ No | Sin resumen de sesión |

## Resultado esperado

Solo se activa el tool `engram_mem_context` de Engram MCP. Ningún otro componente se invoca.

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | Ejecutar `mem_context` como input único | ⏳ |
| 2 | Observar que solo se usa el tool Engram (ninguna delegación) | ⏳ |
| 3 | Observar que no se activan skills ni subagentes | ⏳ |
| 4 | Observar que no se activan MCP no relacionados | ⏳ |
| 5 | Reportar PASS si solo Engram tool fue usado | ⏳ |

## Riesgos detectados

- Este test requiere observación directa del flujo de ejecución. Si el Manager decide automáticamente hacer más cosas (como buscar memoria después de obtener contexto), puede haber falsos positivos de activación.
- El test debe ejecutarse como solicitud única y directa, no como parte de un flujo más grande.

## Próximo paso

Completar suite F — compilar resultados en summary-matrix.md.
