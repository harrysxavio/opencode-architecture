# F4B Real Compaction Validation

**Estado final F4B:** PARTIAL  
**Fecha:** 2026-06-17  
**Objetivo:** validar si una compactación natural de OpenCode produce un compacted summary con formato `RECENT_SESSION_PACK`.

> Update 2026-06-17: se aplicó `F4B-contract-hardening.md`. El contrato ahora exige explícitamente `RECENT_SESSION_PACK_VERSION`, `F4B_COMPACTION_CONTRACT_ACTIVE`, `RECENT_IDS_OR_ARTIFACTS` y `ROLLBACK_NOTE`, más un marcador seguro del hook. Esto mejora la próxima validación, pero F4B sigue PARTIAL hasta observar compactación real.

## Veredicto

No se observó compactación real durante esta validación. Por lo tanto, F4B **no puede marcarse PASS** todavía.

El plugin sigue instalado, el contrato `RECENT_SESSION_PACK_COMPACTION_CONTEXT` sigue presente en `engram.ts`, el backup existe y el harness pasa. Pero no hubo evidencia runtime de un compacted summary generado por OpenCode.

## Precheck

| Check | Resultado |
|---|---:|
| Proyecto canonical detectado | ✅ `opencode-architecture` vía process override |
| Store real | ✅ `C:\Users\harry\.engram\engram.db` |
| Legacy DB | Existe, no se usó: `C:\Users\harry\.codex\memories_1.sqlite` |
| Plugin | ✅ `C:\Users\harry\.config\opencode\plugins\engram.ts` |
| Backup | ✅ `engram.ts.f4b-f4c-backup-20260617` |
| `RECENT_SESSION_PACK_COMPACTION_CONTEXT` | ✅ presente y endurecido |
| `experimental.session.compacting` | ✅ presente |
| `output.context.push(...)` | ✅ presente |
| Hardening markers | ✅ `RECENT_SESSION_PACK_VERSION: v1`, `F4B_COMPACTION_CONTRACT_ACTIVE: true` |

## Sesión larga útil ejecutada

Se revisaron artefactos reales, no ruido artificial:

- `F4B-F4C-post-restart-validation.md`
- `README.md`
- `risk-register.md`
- `decision-log.md`

Objetivo de la revisión: validar continuidad documental, riesgos abiertos, decisiones F4-F6 y estado actual de Fase F.

## Observación de compactación

| Señal | Resultado |
|---|---:|
| `RECENT_SESSION_PACK` en `engram-debug.log` | 0 hits |
| `compacting/compaction` en `engram-debug.log` | 0 hits |
| `engram-debug.log` actualizado durante validación | No; latest write `2026-06-16T15:33:28` |
| Compacted summary visible en sesión | No observado |

Nota: `DEBUG_ENGRAM_PLUGIN=false` reduce la evidencia disponible en logs, pero si OpenCode hubiera emitido un compacted summary visible en esta sesión, debería observarse en el flujo conversacional. No ocurrió.

## Secciones RECENT_SESSION_PACK detectadas

No aplica: no hubo compacted summary real.

| Sección esperada | Detectada |
|---|---:|
| ACTIVE_PHASE | ❌ No hubo summary |
| LAST_VALIDATED_OUTCOME | ❌ No hubo summary |
| CURRENT_OBJECTIVE | ❌ No hubo summary |
| OPEN_DECISIONS | ❌ No hubo summary |
| OPEN_RISKS_AND_BLOCKERS | ❌ No hubo summary |
| RECENT_IDS_OR_ARTIFACTS | ❌ No hubo summary |
| NEXT_STEP | ❌ No hubo summary |
| REGRESSION_GATES | ❌ No hubo summary |
| ROLLBACK_NOTE | ❌ No hubo summary |

## DB counters

| Tabla | Antes | Después | Resultado |
|---|---:|---:|---:|
| observations | 328 | 328 | ✅ Sin cambios |
| user_prompts | 312 | 312 | ✅ Sin cambios |
| sessions | 79 | 79 | ✅ Sin cambios |
| memory_relations | 212 | 212 | ✅ Sin cambios |

Los contadores son mayores que en la validación anterior porque se guardó memoria de la sesión post-restart previa; durante esta validación final no cambiaron.

## Harness

Comando:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\F-regression-harness.ps1
```

Resultado:

```text
Total: 27 | PASS: 27 | FAIL: 0
```

El harness fue ampliado para validar los campos críticos de hardening y el backup adicional.

## Seguridad

- No DB migration.
- No schema changes.
- No `opencode.json`.
- No skills reales.
- No F4A/QW#2/QW#3 runtime.
- No gentle-ai.
- No `.codex/memories_1.sqlite`.
- No high-confidence secret patterns.
- No cross-project context activo.

## Challenge multiperspectiva

| Perspectiva | Resultado |
|---|---|
| Usuario | Todavía no puede confiar en F4B como validado: falta ver un summary real. |
| Técnico | Instalación es simple/reversible, pero la prueba no alcanzó el trigger de OpenCode. |
| Seguridad | Validación segura: sin secretos, sin cross-project, sin DB writes. |
| Senior engineer | Correcto mantener PARTIAL; no hay evidencia suficiente para PASS. |
| QA | La prueba detectó la ausencia de evento real, no solo presencia documental. |
| Gerente/ROI | El ahorro sigue estimado; no hay medición real de compaction. |
| Mantenibilidad | El pack es fácil de ajustar, pero depende de hook experimental. |
| gentle-ai | Patrón reusable como criterio de evaluación, sin integración. |

## Riesgo abierto

El riesgo de contrato incompleto fue mitigado por el hardening: `RECENT_IDS_OR_ARTIFACTS` y `ROLLBACK_NOTE` ahora son secciones obligatorias explícitas. El riesgo restante es runtime: falta observar una compactación real de OpenCode que use el contrato.

## Procedimiento para cerrar F4B como PASS

1. Mantener OpenCode con `engram.ts` actualizado.
2. Ejecutar una sesión canonical larga hasta compaction natural.
3. Si aparece compacted summary, verificar secciones obligatorias.
4. Verificar marcadores `RECENT_SESSION_PACK_VERSION: v1` y `F4B_COMPACTION_CONTRACT_ACTIVE: true`.
5. Verificar `RECENT_IDS_OR_ARTIFACTS` y `ROLLBACK_NOTE`.
6. Ejecutar harness después.

## Resultado final

**PARTIAL:** F4B instalado y seguro, pero sin compactación real observada.
