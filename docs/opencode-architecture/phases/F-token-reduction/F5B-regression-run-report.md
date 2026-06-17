# F5B: Regression Run Report

**Estado:** ✅ PASS  
**Fecha:** 2026-06-17  
**Comando:** `powershell -ExecutionPolicy Bypass -File scripts\F-regression-harness.ps1`

## Resultado

```text
Total: 23 | PASS: 23 | FAIL: 0
ALL TESTS PASSED
Read-only: YES (no files modified by harness)
```

## Gates ejecutados

| Gate | Resultado |
|---|---:|
| Artifact Integrity | ✅ PASS |
| Budget and Prototype Evidence | ✅ PASS |
| Runtime Hooks and Guidance | ✅ PASS |
| Decision Boundaries | ✅ PASS |
| Security and DB Invariance | ✅ PASS |
| Documentation Completeness | ✅ PASS |
| gentle-ai Boundary | ✅ PASS |

## Evidencia clave

- `RECENT_SESSION_PACK_COMPACTION_CONTEXT` presente en `engram.ts`.
- `MEMORY_SELECTOR_INSTRUCTIONS` presente en `engram.ts`.
- Backup runtime existe: `engram.ts.f4b-f4c-backup-20260617`.
- Engram DB size unchanged: `3076096` bytes antes/después.
- `.codex/memories_1.sqlite` existe pero no fue leído/escrito.
- No high-confidence secret patterns en docs/scripts.
- README principal contiene 6 diagramas Mermaid.
- F4A/QW#2/QW#3 permanecen en boundaries documentados.

## Debugging realizado

El primer run del harness falló porque los nuevos gates se insertaron antes de la definición de `Test-Check`. Se reescribió el harness como v2.0 limpio.

El segundo run detectó falsos positivos de secretos por fixtures E6B (`FAKE/TEST`) y por `sk-classification` en nombre de archivo. Se ajustó el scanner para distinguir fixtures y keys reales de alta entropía.

## Riesgo residual

La compactación real de OpenCode no se puede validar hasta reiniciar OpenCode y permitir que el runtime dispare compaction.
