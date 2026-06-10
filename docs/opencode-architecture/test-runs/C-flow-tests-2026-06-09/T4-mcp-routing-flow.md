# Test T4 — Request con MCP bajo demanda

## Estado

PASSED

## Objetivo

Validar si Manager enruta correctamente a MCP cuando el usuario pide explícitamente documentación actualizada externa.

## Input exacto usado

```text
Consulta documentación actualizada de la librería Zod usando Context7.
```

## Resultado esperado

Manager debía detectar necesidad de MCP, usar Context7 si está disponible, no usar Engram, no usar SDD, no usar subagentes y responder con evidencia de documentación actualizada.

## Resultado observado

Manager usó Context7 explícitamente. Primero resolvió la librería `Zod` a `/colinhacks/zod`; luego consultó documentación. Context7 devolvió snippets/documentación de README, docs `index.mdx`, `basics.mdx` y changelog Zod 4.

## Flujo observado

| Paso | Actor | Acción | Evidencia | Estado |
|---|---|---|---|---|
| 1 | Manager | Detecta intención explícita MCP | Input dice “usando Context7” | PASSED |
| 2 | Context7 | Resolve library ID | `/colinhacks/zod` seleccionado | PASSED |
| 3 | Context7 | Consulta docs | Query sobre schema, parse/safeParse, inferencia, Zod 4 | PASSED |
| 4 | Manager | No usa memoria/SDD/subagentes | Sin calls de Engram/task | PASSED |

## Componentes activados

| Componente | Activado | Evidencia | Comentario |
|---|---|---|---|
| Manager | Sí | Routing MCP | Correcto |
| Context7 resolve | Sí | `/colinhacks/zod` | Correcto |
| Context7 query | Sí | Docs de Zod consultadas | Correcto |
| Engram | No | No mem_context/mem_search | Correcto |
| SDD | No | Sin pipeline | Correcto |
| Subagentes | No | Sin task | Correcto |

## Componentes que NO debían activarse

| Componente | ¿Se activó? | Riesgo | Comentario |
|---|---|---|---|
| Engram | No | Bajo | Correcto |
| SDD | No | Bajo | Correcto |
| Subagentes | No | Bajo | Correcto |
| Skills | No | Bajo | Correcto |

## Métricas

| Métrica | Valor | Estado |
|---|---:|---|
| Tiempo aproximado | ~5-10s | INFERIDO |
| Tools visibles | context7_resolve-library-id, context7_query-docs | VALIDADO |
| MCP visibles | Context7 | VALIDADO |
| Memoria leída | No | VALIDADO |
| Memoria escrita | No | VALIDADO |
| Skills cargadas | 0 | VALIDADO |
| Subagentes llamados | 0 | VALIDADO |
| Tokens reales | — | NO DISPONIBLE |
| Tokens estimados | ~18,500–22,000 fijo + Context7 result | INFERIDO |

## Pass / Fail

PASSED

## Riesgos detectados

Context7 funciona bajo demanda. No se detectó activación innecesaria.

## Implicación para arquitectura objetivo

MCP bajo demanda es viable: se activa por intención explícita y no arrastra memoria/SDD.

## Próxima acción

En Fase G, consolidar MCP duplicados sin romper Context7 bajo demanda.
