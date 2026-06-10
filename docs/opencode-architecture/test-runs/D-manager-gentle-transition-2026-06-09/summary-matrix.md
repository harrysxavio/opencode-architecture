# Summary Matrix — Fase D

| Área | Estado | Evidencia | Riesgo | Próxima acción |
|---|---|---|---|---|
| JSON válido | PASSED | `opencode.json OK` | Bajo | Reiniciar OpenCode |
| Manager primary efectivo | PASSED | D-T1 post-restart: `agent=manager`, `mode=manager` | Bajo | Mantener |
| gentle no-primary | PASSED_FOR_TINY | D-T1: no apareció gentle-orchestrator | Medio | Validar SDD en D-T5 |
| Manager puede invocar gentle | APPLIED_NOT_RUNTIME_VALIDATED | Prompt actualizado | Medio | Ejecutar D-T5 |
| Anti-loop | APPLIED_NOT_RUNTIME_VALIDATED | Guardrails en prompts | Medio | Ejecutar dry-run |
| Docs/MCP/simple flow | PENDING | Requiere D-T3/D-T1 | Bajo | Ejecutar tests |
| Token overhead real | RISK | D-T1 reportó 40,017 input tokens / 40,091 total | Alto para Fase F | Investigar tras D/E |
