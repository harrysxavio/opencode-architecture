# Test T5 — SDD routing end-to-end read-only

## Estado

PARTIAL

## Objetivo

Validar routing SDD sin modificar archivos funcionales.

## Input exacto usado

```text
Diseña un cambio pequeño para registrar decisiones del Manager en un archivo de log. Modo read-only: no modifiques archivos, no escribas código, no cambies configuración. Solo ejecuta el flujo de decisión y documenta qué ruta tomarías.
```

## Resultado esperado

Manager debía clasificar Small/Medium, decidir inline vs SDD, explicar si invocaría gentle-orchestrator, indicar fases SDD y subagentes `sdd-*`, respetar read-only, no ejecutar apply real ni entrar en loop.

## Resultado observado

Manager clasifica el cambio como Small/Medium: cambio pequeño, pero estructurado y relacionado con observabilidad. La ruta ideal estratégica sería Manager → gentle-orchestrator como SDD Pipeline → `sdd-explore`, `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks` en modo read-only; no `sdd-apply` salvo aprobación posterior. Sin embargo, la regla runtime actual del Manager prohíbe invocar/delegar a `gentle-orchestrator`. Por eso el test valida el diseño de routing, pero no la invocación end-to-end.

## Flujo observado

| Paso | Actor | Acción | Evidencia | Estado |
|---|---|---|---|---|
| 1 | Manager | Clasifica como Small/Medium | Cambio pequeño pero estructurado | PASSED |
| 2 | Manager | Respeta read-only | No modifica archivos funcionales ni código | PASSED |
| 3 | Manager | Diseña ruta SDD | Manager → gentle-orch → sdd-* | PASSED |
| 4 | Manager | No invoca gentle-orch por regla runtime actual | Protocolo global: “MUST NOT invoke gentle-orchestrator” | PARTIAL |
| 5 | Manager | Evita loop | No hay delegación real | PASSED |

## Componentes activados

| Componente | Activado | Evidencia | Comentario |
|---|---|---|---|
| Manager | Sí | Clasificación/routing | Correcto |
| gentle-orchestrator | No | Regla runtime lo prohíbe | Gap principal |
| sdd-* | No | No se invocaron subagentes | Correcto bajo read-only actual |
| MCP | No | Sin MCP | Correcto |
| Escritura funcional | No | Solo docs de test | Correcto |

## Componentes que NO debían activarse

| Componente | ¿Se activó? | Riesgo | Comentario |
|---|---|---|---|
| sdd-apply | No | Bajo | Correcto |
| Escritura código/config | No | Bajo | Correcto |
| MCP externo | No | Bajo | Correcto |
| Loop Manager/gentle | No | Bajo | No hubo delegación real |

## Métricas

| Métrica | Valor | Estado |
|---|---:|---|
| Tiempo aproximado | ~2-4s | INFERIDO |
| Tools visibles | 0 para routing; docs luego | VALIDADO |
| MCP visibles | 0 | VALIDADO |
| Memoria leída | No | VALIDADO |
| Memoria escrita | No | VALIDADO |
| Skills cargadas | 0 | VALIDADO |
| Subagentes llamados | 0 | VALIDADO |
| Tokens reales | — | NO DISPONIBLE |
| Tokens estimados | ~18,500–22,000 fijo | INFERIDO |

## Pass / Fail

PARTIAL

## Riesgos detectados

- Conflicto entre arquitectura estratégica aprobada (Manager puede invocar gentle-orch como SDD Pipeline) y regla runtime actual del Manager (no invocar gentle-orchestrator).
- Fase D debe resolver este conflicto antes de cambios funcionales.

## Implicación para arquitectura objetivo

T5 confirma necesidad de Fase D: formalizar Manager único primary y convertir/usar gentle-orchestrator como pipeline invocable sin contradicción de instrucciones.

## Próxima acción

Fase D puede avanzar, pero debe incluir corrección explícita de la regla Manager ↔ gentle-orchestrator y prueba end-to-end posterior.
