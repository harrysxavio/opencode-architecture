# Test T2 — Request con memoria útil

## Estado

PASSED

## Objetivo

Validar si el sistema intenta recuperar contexto previo de forma razonable y usa Markdown como fallback cuando corresponde.

## Input exacto usado

```text
Continúa con la arquitectura OpenCode que estábamos revisando.
```

## Resultado esperado

Manager debía detectar necesidad de contexto previo, intentar Memory Governance Flow con `mem_context` o `mem_search`, caer a Markdown docs si Engram no devuelve memoria útil, y no activar SDD, MCP externo ni subagentes.

## Resultado observado

Manager llamó `mem_context` con proyecto `opencode-architecture`. Engram devolvió contexto útil reciente: B1 completada, T8 ejecutado en sesión limpia, B0/B-Security documentadas, decisión estratégica Manager/gentle. No se escribió memoria. No se activó MCP externo, SDD ni subagentes.

## Flujo observado

| Paso | Actor | Acción | Evidencia | Estado |
|---|---|---|---|---|
| 1 | Manager | Detecta necesidad de contexto previo | Input “continúa” implica trabajo previo | PASSED |
| 2 | Manager | Usa Memory Governance Flow | `engram_mem_context(project="opencode-architecture")` | PASSED |
| 3 | Engram | Devuelve contexto útil reciente | Observaciones: “T8 ejecutado...”, “B1 completada...”, session summaries | PASSED |
| 4 | Manager | No escribe memoria | Sin `mem_save` durante T2 | PASSED |

## Componentes activados

| Componente | Activado | Evidencia | Comentario |
|---|---|---|---|
| Manager | Sí | Routing del test | Correcto |
| Engram mem_context | Sí | Tool call visible | Correcto para “continúa” |
| Markdown fallback | No necesario | mem_context devolvió contexto útil | Aun así Markdown sigue fuente de verdad |
| MCP externo | No | Sin Context7/NotebookLM/etc. | Correcto |
| SDD | No | No hubo pipeline | Correcto |
| Subagentes | No | Sin task | Correcto |

## Componentes que NO debían activarse

| Componente | ¿Se activó? | Riesgo | Comentario |
|---|---|---|---|
| MCP externo | No | Bajo | Correcto |
| SDD | No | Bajo | Correcto |
| Subagentes | No | Bajo | Correcto |
| Escritura de memoria | No | Bajo | Correcto |

## Métricas

| Métrica | Valor | Estado |
|---|---:|---|
| Tiempo aproximado | ~3-6s | INFERIDO |
| Tools visibles | engram_mem_context | VALIDADO |
| MCP visibles | Engram | VALIDADO |
| Memoria leída | Sí | VALIDADO |
| Memoria escrita | No | VALIDADO |
| Skills cargadas | 0 | VALIDADO |
| Subagentes llamados | 0 | VALIDADO |
| Tokens reales | — | NO DISPONIBLE |
| Tokens estimados | ~18,500–22,000 fijo + memoria recuperada | INFERIDO |

## Pass / Fail

PASSED

## Riesgos detectados

Engram devolvió contexto útil vía MCP, pero sigue existiendo contradicción técnica documentada: `memories_1.sqlite` no contiene tabla `observations`. La memoria es útil operativamente en esta prueba, pero su arquitectura de persistencia sigue pendiente de diagnóstico.

## Implicación para arquitectura objetivo

Memory Governance Flow es viable: primero `mem_context`, luego Markdown si hace falta. Fase E sigue necesaria para reparar/explicar persistencia semántica.

## Próxima acción

En Fase E, diagnosticar dónde persisten realmente las observaciones que `mem_context` devuelve.
