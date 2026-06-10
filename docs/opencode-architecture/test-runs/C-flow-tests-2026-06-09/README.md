# Fase C — Tests de Flujo Reproducibles (2026-06-09)

Esta corrida documenta pruebas reproducibles del flujo actual de OpenCode antes de modificar arquitectura funcional.

## Restricciones respetadas

- No se modificó `opencode.json`.
- No se modificó `opencode.jsonc`.
- No se modificó `AGENTS.md`.
- No se modificaron prompts, plugins, skills, subagentes, MCP ni modos `primary/subagent`.
- Solo se crearon/actualizaron documentos Markdown de evidencia.
- T7 usó scope ficticio `TEST-FLOW-C` y no guardó memoria real.

## Orden ejecutado

| Orden | Test | Estado |
|---:|---|---|
| 1 | T3 — Markdown docs retrieval | PASSED |
| 2 | T2 — Memory flow | PASSED |
| 3 | T6 — Noisy request | PASSED |
| 4 | T4 — Context7 MCP routing | PASSED |
| 5 | T5 — SDD routing read-only | PARTIAL |
| 6 | T7 — Fictitious memory contradiction | PASSED |

## Resultado ejecutivo

Manager enruta correctamente requests de documentación, memoria, MCP explícito y ruido. No hay sobreorquestación visible en T2/T3/T4/T6/T7. El único gap relevante es T5: el routing SDD está diseñado, pero la invocación real a `gentle-orchestrator` sigue bloqueada por la regla runtime actual del Manager.

## Go/No-Go preliminar

| Fase | Resultado |
|---|---|
| Fase D — Resolver agente primario | GO condicionado a resolver conflicto de regla Manager ↔ gentle-orchestrator |
| Fase E — Gobernanza memoria | GO: T2/T7 muestran necesidad clara y comportamiento esperado conceptual |
| Fase F — Optimización tokens | NO-GO hasta cerrar inventario de secciones lazy-load y/o telemetría más robusta |
