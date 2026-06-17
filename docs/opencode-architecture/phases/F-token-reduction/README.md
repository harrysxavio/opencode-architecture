# Fase F — Reducción Inteligente de Tokens

**Estado:** ✅ F0-F3 complete · ✅ F4A-lite PASS WITH WARNINGS · ⚠️ F4B partial + hardened + observable · ✅ F4C RUNTIME PASS · ✅ F5/F6/F7 docs/gates · CLOSED — PASS WITH WARNINGS
**Fecha:** 2026-06-17

## Objetivo

Reducir el consumo de contexto de OpenCode/Engram sin degradar calidad: seleccionar mejor, compactar con continuidad, rankear memorias y mantener fallback.

## Estado validado

| Validación | Estado |
|---|---:|
| E6B Noise Gate | ✅ COMPLETE — T1-T7 PASS |
| Suite F mem_context read-only | ✅ COMPLETE — F-T1-F-T6 PASS |
| F0 Token Audit Baseline | ✅ COMPLETE |
| F1 Context Inventory | ✅ COMPLETE |
| F2 Context Budget Contract | ✅ COMPLETE |
| F3 Readiness / Prototype | ✅ COMPLETE |
| F4D Runtime API Verification | ✅ COMPLETE |

## Implementado en este bloque

| Work unit | Estado | Qué cambió |
|---|---:|---|
| F4B Session History Compaction | ⚠️ PARTIAL | Instalado en `engram.ts`; contrato endurecido; validación final no disparó compaction natural |
| F4C mem_context Selector | ✅ Runtime-validado | `MEMORY_SELECTOR_INSTRUCTIONS` activo en contexto Manager |
| F5A Harness Upgrade | ✅ Implementado | Gates F4-F6/docs/security/DB invariance |
| F5B Regression Run | ✅ Ejecutado | Harness final 34/34 PASS con gates F4A-lite |
| F5C Rebaseline | ✅ Creado | Ahorro real/potencial separado |
| F6A Rollout Plan | ✅ Creado | Plan + rollback |
| F6B Executive Package | ✅ Creado | Decisiones y aprobaciones pendientes |
| F7 README/Docs | ✅ Creado | README principal + DOCUMENTATION-INDEX |

## No implementado por seguridad/aprobación

- F4A full selective loading funcional (F4A-lite si fue implementado solo sobre `description:`).
- QW#2 tool schema loading en runtime activo.
- QW#3 Manager Protocol compaction.
- Cualquier cambio de `opencode.json`.
- Cualquier modificación de gentle-ai.
- DB/schema migration.

## Documentos clave

| Documento | Propósito |
|---|---|
| `F4B-session-history-compaction-implementation-report.md` | Implementación F4B + rollback |
| `F4B-contract-hardening.md` | Campos obligatorios + observabilidad segura F4B |
| `F4C-mem-context-selector-implementation-report.md` | Implementación F4C + límites |
| `F4A-skills-selective-loading-decision.md` | Decisión no-runtime F4A |
| `F4D-tool-schema-loading-prototype-plan.md` | Plan prototype-only QW#2 |
| `F4E-manager-protocol-compaction-decision.md` | Proposal-only QW#3 |
| `F5A-regression-harness-upgrade.md` | Cobertura nueva del harness |
| `F5B-regression-run-report.md` | Resultado de regresión |
| `F5C-token-savings-rebaseline.md` | Ahorros real/propuesto/potencial |
| `F6A-controlled-rollout-plan.md` | Rollout y rollback |
| `F6B-executive-decision-package.md` | Paquete ejecutivo |
| `autonomous-F4-F6-report.md` | Reporte final del bloque |

## Ahorro esperado

| Fuente | Ahorro | Estado |
|---|---:|---|
| F4B session compaction | ~7,070 tokens / sesión 30-turn | Implementado guidance-only; medición real pendiente compaction |
| F4C selector | ~500-2,000 tokens / turno potencial | Implementado guidance-only |
| F4A-lite skills | 3,532 chars (~883-1,177 tokens) | Implementado; requiere restart para observar runtime |
| QW#2 tool schemas | ~2,000-4,000 tokens | Prototype-only |
| QW#3 Manager Protocol | ~1,200-2,300 tokens | Proposal-only |

## Rollback runtime

```powershell
Copy-Item -LiteralPath "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617" -Destination "$env:USERPROFILE\.config\opencode\plugins\engram.ts" -Force
```

Reiniciar OpenCode después.

## Próximo paso

Fase F está cerrada como `CLOSED — PASS WITH WARNINGS`. No forzar compactación. Si ocurre compactación natural, ejecutar `F4B-natural-compaction-checklist.md`. Decisiones pendientes en `F-phase-backlog.md` y `F-next-decisions-matrix.md`.

Documentos de cierre:

- `F4B-natural-compaction-checklist.md` — checklist para validar compactación real
- `F-phase-backlog.md` — backlog controlado de decisiones pendientes
- `F-next-decisions-matrix.md` — matriz ejecutiva para aprobaciones
- `F-phase-operational-closure-report.md` — reporte de cierre operacional
