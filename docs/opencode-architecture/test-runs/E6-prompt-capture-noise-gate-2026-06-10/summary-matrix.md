# E6 — Summary Matrix

> Estado completo de la Fase E6.

## Documentos

| # | Documento | Estado |
|:-:|-----------|:------:|
| 23 | Prompt Capture Audit | ✅ Completo (pre-E6B) |
| 24 | Noise Gate Design | ✅ Completo (aprobado) |

## Tests E6A

| ID | Descripción | Resultado |
|:--:|-------------|:---------:|
| T1 | Audit completeness | ✅ PASS |
| T2 | DB inventory | ✅ PASS |
| T3 | Risk classification | ✅ PASS |
| T4 | Design options evaluation | ✅ PASS |
| T5 | Contract alignment (E5) | ✅ PASS |
| T6 | Implementation spec completeness | ✅ PASS |
| T7 | Rollback readiness | ✅ PASS |

## Tests E6B

| ID | Input | Esperado | Resultado |
|:--:|-------|----------|:---------:|
| T1 | `ok gracias jajaja` | No capturar | ✅ PASS |
| T2 | `listo` | No capturar | ✅ PASS |
| T3 | `¿Qué rol cumple Engram?` | Capturar | 🔴 BLOCKED: `/prompts` 400 `session_project_mismatch` en sesión legacy |
| T4 | `Diseña una prueba read-only...` | Capturar | ⏳ |
| T5 | `Mi token falso es ghp_...` | No capturar raw | ⏳ |
| T6 | `muéstrame el archivo README` | No capturar | ⏳ |
| T7 | `Continúa con la arquitectura...` | Capturar | ⏳ |

## Subfases diagnóstico/reparación E6B

| ID | Descripción | Resultado |
|:--:|-------------|:---------:|
| D0 | Diagnóstico read-only de carga plugin/hook | ❌ NO-GO: pregunta útil no aumentó `user_prompts` |
| D1 | Reinstalación controlada con setup oficial Engram OpenCode | ❌ NO-GO: plugin oficial descubierto pero falla por `Bun is not defined` |
| D2 | Patch mínimo Node-compatible del plugin oficial Engram | ❌ NO-GO: `Bun.*` removido y sin error `engram.ts`, pero pregunta útil no aumentó `user_prompts` |
| D3 | Hook/export diagnostic con `export default` + logs seguros temporales | ❌ NO-GO: hook entra, `finalContent=44`, POST `/prompts` responde HTTP 400 |
| D4 | Diagnóstico contrato HTTP `/sessions` + `/prompts` | ❌ NO-GO: `/prompts` falla por `session_project_mismatch` (`opencode-architecture` vs `arquitectura opencode`) |
| D5A | Diagnóstico read-only de projects y sesión legacy | ✅ PASS: sesión actual legacy en `arquitectura opencode` |
| D5B | Test de sesión limpia con project canónico | ✅ PASS: `/prompts` 201 y `user_prompts` +1 en `opencode-architecture` |
| D6 | Reimplementación Noise Gate sobre plugin Node-compatible | ✅ PASS: gate `classified`, sin `Bun.*`, sin `/projects/migrate`; smoke positivo/negativo pasó en sesión nueva canonical |

## Archivos modificados

| Archivo | Cambio | Estado |
|---------|--------|:------:|
| `plugins/engram.ts` | Plugin Node-compatible + Noise Gate D6 (`classified`) + debug normal apagado | ✅ Smoke PASS |
| `plugins/engram.ts.e6b-backup` | Backup pre-cambio | ✅ |
| `plugins/engram.ts.e6b-d2-backup` | Backup pre-D2 del plugin oficial reinstalado | ✅ |
| `plugins/engram.ts.e6b-d3-backup` | Backup pre-D3 del plugin Node-compatible | ✅ |
| `plugins/engram.ts.e6b-d4-backup` | Backup pre-D4 del plugin instrumentado | ✅ |
| `plugins/engram.ts.e6b-d6-backup` | Backup pre-D6 del plugin instrumentado antes de Noise Gate | ✅ |
| `opencode.jsonc` | Sin cambios | ✅ No necesario |
| `E6B-D1-plugin-load-repair.md` | Registro de reparación controlada + setup oficial | ✅ |
| `E6B-D2-node-compatible-plugin-patch.md` | Registro del patch Node-compatible | ✅ |
| `E6B-D3-hook-export-diagnostic.md` | Registro del diagnóstico hook/export | ✅ |
| `E6B-D4-prompts-http-contract-diagnostic.md` | Registro del diagnóstico HTTP `/prompts` | ✅ |
| `E6B-D5-session-project-mismatch.md` | Registro del diagnóstico project/session mismatch | ✅ |
| `E6B-D6-noise-gate-reimplementation.md` | Registro de reimplementación Noise Gate D6 | ✅ |

## DB

| Tabla | Acción | Estado |
|-------|--------|:------:|
| `user_prompts` | Sin modificar | ✅ Intacta |
| `observations` | Sin tocar | ✅ Intacta |
| Schema | Sin ALTER TABLE | ✅ No migrado |

## Riesgo residual post-E6B

| Riesgo | Severidad | Estado |
|--------|:---------:|:------:|
| Falsos negativos (gate muy agresivo) | 🟡 Media | Mitigado: default conservador + rollback a "all" |
| Falsos positivos (gate deja pasar ruido) | 🟢 Baja | Aceptable: mejor que perder contexto |
| Secretos pasan el gate | 🔴 Alta | Mitigado: patrones específicos. No 100% coverage |
| Datos históricos no limpiados | 🟡 Media | Aceptado: no borrar prompts existentes |
| Plugin runtime incompatible (`Bun` no disponible) | 🔴 Alta | Mitigado para `engram.ts`; persiste en `background-agents.ts` |
| Hook `chat.message` no captura tras D2 | 🔴 Alta | Bloquea E6B-T1..T7; requiere diagnóstico de export/API/hook |
| Contrato HTTP `/prompts` falla | 🔴 Alta | D3 aisló la falla en POST `/prompts` → HTTP 400; requiere D4 |
| Session/project mismatch | 🔴 Alta | D4 confirmó `/prompts` 400: sesión en `arquitectura opencode`, prompt en `opencode-architecture` |
| Instrumentación temporal D3/D4 activa | 🟢 Baja | Mitigado: `DEBUG_ENGRAM_PLUGIN=false`; solo errores HTTP sanitizados se fuerzan |

## Smoke D6 post-restart

| Smoke | Conteo previo | Conteo posterior | Resultado |
|---|---:|---:|:---:|
| Positivo `¿Qué rol cumple Engram en esta arquitectura?` | `user_prompts=308` | `user_prompts=309` | ✅ PASS |
| Negativo `ok gracias jajaja` | `user_prompts=309`, `observations=310` | `user_prompts=309`, `observations=310` | ✅ PASS |
