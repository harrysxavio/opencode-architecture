# F5B: Regression Run Report

**Estado:** ✅ PASS  
**Fecha:** 2026-06-17 post-restart validation + F4B hardening
**Comando:** `powershell -ExecutionPolicy Bypass -File scripts\F-regression-harness.ps1`

## Resultado

```text
Total: 27 | PASS: 27 | FAIL: 0
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
- F4B hardening markers presentes: `RECENT_SESSION_PACK_VERSION: v1`, `F4B_COMPACTION_CONTRACT_ACTIVE: true`.
- F4B critical sections presentes: `RECENT_IDS_OR_ARTIFACTS`, `ROLLBACK_NOTE`.
- Safe observability marker presente: `F4B RECENT_SESSION_PACK compaction hook entered`.

## Post-restart run

El harness se volvió a ejecutar durante la validación post-restart y mantuvo:

```text
Total: 23 | PASS: 23 | FAIL: 0
```

Además, los contadores Engram permanecieron invariantes:

```text
observations=326
user_prompts=312
sessions=79
memory_relations=209
```

## Final F4B real compaction validation run

Durante la validación final de F4B se reejecutó el harness:

```text
Total: 23 | PASS: 23 | FAIL: 0
```

Counters durante esa validación:

```text
observations=328
user_prompts=312
sessions=79
memory_relations=212
```

No hubo cambios antes/después de la validación final. La diferencia contra `326/209` viene de memorias guardadas en la validación post-restart anterior.

## F4B hardening run

Después de endurecer el contrato F4B y ampliar el harness:

```text
Total: 27 | PASS: 27 | FAIL: 0
```

Gates nuevos:

- `F4B-T3` — hardening markers presentes.
- `F4B-T4` — secciones críticas presentes.
- `F4B-T5` — observabilidad segura presente.
- `F4-RB2` — backup hardening presente.

Engram DB size durante harness:

```text
before=3076096 after=3076096
```

`opencode.json` y DB/schema no fueron modificados por el hardening.

## Debugging realizado

El primer run del harness falló porque los nuevos gates se insertaron antes de la definición de `Test-Check`. Se reescribió el harness como v2.0 limpio.

El segundo run detectó falsos positivos de secretos por fixtures E6B (`FAKE/TEST`) y por `sk-classification` en nombre de archivo. Se ajustó el scanner para distinguir fixtures y keys reales de alta entropía.

## Riesgo residual

La compactación real de OpenCode no se puede validar hasta reiniciar OpenCode y permitir que el runtime dispare compaction.
