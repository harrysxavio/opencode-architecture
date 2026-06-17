# F4B/F4C Post-Restart Validation

**Estado final:** PARTIAL  
**Fecha:** 2026-06-17  
**Contexto:** Validación post-restart de `~/.config/opencode/plugins/engram.ts`.

## Resultado ejecutivo

F4C quedó runtime-validado: la instrucción `F4C Memory Context Selector — Manager Guidance` está activa en el contexto del Manager de esta sesión, lo que prueba que `experimental.chat.system.transform` cargó el bloque actualizado después del restart.

F4B queda PARTIAL: el hook y la instrucción `RECENT_SESSION_PACK_COMPACTION_CONTEXT` están presentes y el harness valida su instalación, pero no se pudo disparar una compactación real de OpenCode desde esta sesión sin forzar runtime/config. Según la regla del usuario, no se marca PASS hasta ver un compacted summary real con formato `RECENT_SESSION_PACK`.

## Precheck

| Check | Resultado |
|---|---:|
| Proyecto activo | ✅ `opencode-architecture` |
| Project source | `process_override` |
| Store real Engram | ✅ `C:\Users\harry\.engram\engram.db` |
| `.codex/memories_1.sqlite` | Existe pero no se usó |
| Backup `engram.ts` | ✅ `engram.ts.f4b-f4c-backup-20260617` |
| Plugin actualizado en disco | ✅ F4B/F4C constants presentes |
| `opencode.json` | No tocado |
| gentle-ai | No tocado |

## Evidencia de carga del plugin

### F4C — runtime evidence

El contexto activo del Manager incluye:

```text
F4C Memory Context Selector — Manager Guidance
```

Esto no está en el prompt base original; proviene de `MEMORY_SELECTOR_INSTRUCTIONS` inyectado por `experimental.chat.system.transform`.

### F4B — static/runtime-ready evidence

`engram.ts` contiene:

- `RECENT_SESSION_PACK_COMPACTION_CONTEXT`
- `experimental.session.compacting`
- `output.context.push(RECENT_SESSION_PACK_COMPACTION_CONTEXT)`

El harness también valida esos puntos.

### Logs

`engram-debug.log` no registra eventos nuevos porque `DEBUG_ENGRAM_PLUGIN=false`. Esto limita evidencia de log, pero no contradice la carga runtime de F4C.

## F4C selector guidance validation

Se consultó Engram con `mem_context` para proyecto explícito `opencode-architecture`.

Resultado observado:

- Trajo memoria canonical relevante: Suite F, E6B, Engram roles y Noise Gate.
- Mostró stats: 79 sessions, 326 observations.
- No usó `.codex/memories_1.sqlite`.
- `mem_search` no encontró F4B/F4C porque esos cambios todavía no fueron guardados como observaciones de Engram; eso es esperado.

Aplicación del selector:

| Criterio F4C | Resultado |
|---|---:|
| Exact project match | ✅ `project=opencode-architecture` explícito |
| Top-k | ✅ Contexto limitado y relevante |
| Dedup | ✅ No se repitieron memorias equivalentes en output activo |
| Legacy/cross-project penalty | ✅ No se usó memoria legacy como fuente activa |
| Secret exclusion | ✅ Sin secretos en salida |
| Explainability | ✅ Este reporte documenta qué fuentes influyeron |

**Veredicto F4C:** PASS WITH WARNINGS. Es guidance activo, no enforcement DB-level.

## F4B compaction validation

No se pudo disparar compaction real desde esta sesión sin forzar runtime. Se ejecutó validación segura:

| Check | Resultado |
|---|---:|
| Hook existe | ✅ |
| Context push instalado | ✅ |
| Template actualizado | ✅ |
| Secret rule `[REDACTED]` | ✅ |
| No mix projects | ✅ |
| Fallback Engram `FIRST ACTION REQUIRED` intacto | ✅ |

**Veredicto F4B:** PARTIAL. Preparado y cargable; falta evidencia de compacted summary real.

## DB counters

Antes/después de checks read-only:

| Tabla | Antes | Después | Resultado |
|---|---:|---:|---:|
| observations | 326 | 326 | ✅ Sin cambios |
| user_prompts | 312 | 312 | ✅ Sin cambios |
| sessions | 79 | 79 | ✅ Sin cambios |
| memory_relations | 209 | 209 | ✅ Sin cambios |

## Regression harness

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\F-regression-harness.ps1
```

Resultado:

```text
Total: 23 | PASS: 23 | FAIL: 0
```

## Security validation

- No DB/schema migration.
- No config changes adicionales.
- No `opencode.json`.
- No high-confidence secret patterns.
- No `.codex/memories_1.sqlite`.
- No gentle-ai.
- No QW#2/F4A/QW#3 runtime.

## Challenge multiperspectiva

| Perspectiva | Resultado |
|---|---|
| Usuario | F4C puede confiarse por evidencia runtime; F4B todavía requiere ver compaction real. |
| Técnico | Implementación simple, reversible y en hooks existentes. |
| Seguridad | Sin secretos, sin cross-project activo, sin DB writes. |
| Senior engineer | Guidance es suficiente para primera etapa; enforcement futuro puede ir a Engram core si se valida. |
| QA | Harness detecta instalación y boundaries; no detecta compaction real. |
| Gerente/ROI | Mantener F4C y F4B preparado se justifica; ahorro F4B sigue estimado hasta compaction real. |
| Mantenibilidad | Riesgo si cambian hooks `experimental.*`; rollback documentado. |
| gentle-ai | Patrón reusable, sin dependencia. |

## Procedimiento exacto para cerrar F4B

1. Mantener OpenCode reiniciado con `engram.ts` actualizado.
2. Ejecutar una sesión canonical larga hasta que OpenCode dispare compaction.
3. Confirmar que el compacted summary contiene:
   - `ACTIVE_PHASE`
   - `LAST_VALIDATED_OUTCOME`
   - `CURRENT_OBJECTIVE`
   - `OPEN_DECISIONS`
   - `OPEN_RISKS_AND_BLOCKERS`
   - `NEXT_STEP`
   - `REGRESSION_GATES`
4. Confirmar que no contiene secretos ni contexto legacy activo.

## Resultado final

**PARTIAL:** F4C runtime-validado. F4B instalado y listo, pero compaction real pendiente.
