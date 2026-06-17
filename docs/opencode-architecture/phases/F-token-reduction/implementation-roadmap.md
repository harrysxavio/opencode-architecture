# Implementation Roadmap — Fase F

**Estado:** ✅ F0-F3 complete · ✅ F4B/F4C implemented guidance-only · ✅ F5/F6/F7 docs and gates updated
**Fecha:** 2026-06-17

## Principio

Fase F reduce tokens seleccionando mejor el contexto, no recortando a ciegas. Todo cambio debe ser mínimo, reversible, testeado, sin DB/schema migration y sin tocar `opencode.json` salvo aprobación explícita.

## Roadmap actualizado

| Fase | Estado | Resultado |
|---|---:|---|
| F0 Token Audit Baseline | ✅ COMPLETE | Baseline ~35k-45k tokens medido. |
| F1 Context Inventory | ✅ COMPLETE | Fuentes, duplicaciones y quick wins catalogados. |
| F2 Context Budget Contract | ✅ COMPLETE | Modos, capas L0-L5 y budgets definidos. |
| F3 Readiness / Prototype | ✅ COMPLETE | F4 candidates medidos: Skills, Session, Selector. |
| F4D Runtime API Verification | ✅ COMPLETE | Hooks confirmados: `session.compacting`, `system.transform`, `tool.definition`. |
| F4B Session History Compaction | ✅ IMPLEMENTED | `RECENT_SESSION_PACK_COMPACTION_CONTEXT` inyectado en `engram.ts`. |
| F4C mem_context Selector | ✅ IMPLEMENTED | `MEMORY_SELECTOR_INSTRUCTIONS` inyectado al Manager. |
| F4A Skills Selective Loading | ⏸️ DECISION ONLY | No runtime/config change; requiere aprobación. |
| QW#2 Tool Schema Loading | 🧪 PROTOTYPE ONLY | Plan/proposal sin rollout. |
| QW#3 Manager Protocol Compaction | ⏸️ PROPOSAL ONLY | No `opencode.json` change. |
| F5 Regression/Rebaseline | ✅ COMPLETE | Harness ampliado; rebaseline creado; run report generado. |
| F6 Rollout/Executive Package | ✅ READY | Rollout plan + executive package. |
| F7 README/Documentation | ✅ COMPLETE | README principal + DOCUMENTATION-INDEX actualizados. |

## Orden de implementación vigente

1. ✅ F4B — Session History Compaction usando `RECENT_SESSION_PACK`.
2. ✅ F4C — mem_context Selector vía instrucciones al Manager.
3. ✅ F5A/F5B/F5C — harness, regression run, token savings rebaseline.
4. ✅ F6 — rollout plan + executive decision package.
5. ✅ F7 — README principal y documentación central.

## Cambios funcionales aplicados

| Archivo | Cambio | Rollback |
|---|---|---|
| `~/.config/opencode/plugins/engram.ts` | Añade F4B/F4C guidance en hooks existentes | Restaurar `engram.ts.f4b-f4c-backup-20260617` |

## Cambios explícitamente NO aplicados

- No edición funcional de `opencode.json`.
- No modificación de skills reales.
- No Manager Protocol compaction.
- No tool schema loading en runtime activo.
- No gentle-ai changes.
- No DB migration.
- No schema changes.
- No `.codex/memories_1.sqlite`.

## Verification plan

1. Ejecutar `scripts/F-regression-harness.ps1`.
2. Reiniciar OpenCode para cargar plugin actualizado.
3. Validar primer compaction real y revisar `RECENT_SESSION_PACK`.
4. Si falla, restaurar backup y reiniciar.

## Rollback

```powershell
Copy-Item -LiteralPath "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617" -Destination "$env:USERPROFILE\.config\opencode\plugins\engram.ts" -Force
```

Luego reiniciar OpenCode.
