# Test T7 — Contradicción de memoria / decisión ficticia

## Estado

PASSED

## Objetivo

Validar lógica de contradicción sin contaminar memoria real ni cambiar la decisión Manager/gentle aprobada.

## Input exacto usado

```text
En el contexto ficticio TEST-FLOW-C, cambia esta decisión anterior de prueba: antes habíamos decidido que el agente experimental fuera primary; ahora quiero que NO sea primary. No modifiques archivos reales, solo dime cómo deberías actualizar memoria y documentación si esto fuera una decisión real.
```

## Resultado esperado

Manager debía reconocer scope ficticio, no modificar ADR real, no cambiar decisión real, explicar búsqueda de memoria previa, explicar `supersedes`, explicar actualización ADR/docs si fuera real, no ejecutar `mem_save` real, no usar MCP y no usar SDD.

## Resultado observado

Manager reconoce `TEST-FLOW-C` como scope ficticio. La respuesta correcta es conceptual: buscaría memoria previa de la decisión experimental, guardaría una nueva observación con `supersedes` apuntando a la anterior, actualizaría ADR/docs solo si fuera una decisión real aprobada, y marcaría la decisión anterior como reemplazada/deprecated. No se ejecutó `mem_save`, no se modificaron ADRs reales y no se cambió la decisión Manager/gentle real.

## Flujo observado

| Paso | Actor | Acción | Evidencia | Estado |
|---|---|---|---|---|
| 1 | Manager | Reconoce scope ficticio | `TEST-FLOW-C` en input | PASSED |
| 2 | Manager | Mantiene decisión real intacta | No modifica ADR real | PASSED |
| 3 | Manager | Explica lógica `supersedes` | Nueva memoria reemplazaría anterior | PASSED |
| 4 | Manager | No guarda memoria real | Sin `mem_save` en T7 | PASSED |

## Componentes activados

| Componente | Activado | Evidencia | Comentario |
|---|---|---|---|
| Manager | Sí | Razonamiento conceptual | Correcto |
| Engram lectura | No | No necesario para test ficticio | Correcto |
| Engram escritura | No | Sin `mem_save` | Correcto |
| Markdown ADR real | No | No se modificó ADR | Correcto |
| MCP | No | Sin Context7/etc. | Correcto |
| SDD | No | Sin pipeline | Correcto |

## Componentes que NO debían activarse

| Componente | ¿Se activó? | Riesgo | Comentario |
|---|---|---|---|
| mem_save real | No | Bajo | Correcto |
| ADR real | No | Bajo | Correcto |
| MCP | No | Bajo | Correcto |
| SDD | No | Bajo | Correcto |

## Métricas

| Métrica | Valor | Estado |
|---|---:|---|
| Tiempo aproximado | ~2-4s | INFERIDO |
| Tools visibles | 0 | VALIDADO |
| MCP visibles | 0 | VALIDADO |
| Memoria leída | No | VALIDADO |
| Memoria escrita | No | VALIDADO |
| Skills cargadas | 0 | VALIDADO |
| Subagentes llamados | 0 | VALIDADO |
| Tokens reales | — | NO DISPONIBLE |
| Tokens estimados | ~18,500–22,000 fijo | INFERIDO |

## Pass / Fail

PASSED

## Riesgos detectados

Ninguno crítico. El test confirma que contradicciones ficticias pueden tratarse sin contaminar memoria real.

## Implicación para arquitectura objetivo

Fase E debe implementar soporte real de `supersedes`, invalidación y scoping para memoria gobernada.

## Próxima acción

Diseñar reparación Engram en Fase E con test de contradicción real controlado.
