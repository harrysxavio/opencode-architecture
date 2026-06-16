# E6B-D6 — Noise Gate Reimplementation

**Estado:** ✅ Smoke PASS — listo para E6B-T1..T7 formal
**Fecha:** 2026-06-16

## Objetivo

Reimplementar el Noise Gate sobre el plugin Engram activo, manteniendo compatibilidad Node y evitando cualquier migración/limpieza de DB.

## Archivo modificado

- `C:\Users\harry\.config\opencode\plugins\engram.ts`

## Backup

- `C:\Users\harry\.config\opencode\plugins\engram.ts.e6b-d6-backup`
- SHA256 pre-D6: `9D1F0407B4C58788D751258E24186E0214ACF85376AC448A685B9A3FC64B7645`
- Length pre-D6: `21717`
- SHA256 post-D6: `1628EA2E1F74FC493AFB91C909998B079C01D79FED64D6AD0929D133EF79A0E1`
- Length post-D6: `24594`

## Cambios aplicados

- Se agregó `DEBUG_ENGRAM_PLUGIN = false` para apagar instrumentación normal D3/D4.
- Se conserva logging forzado solo para errores HTTP sanitizados y `session_project_mismatch`.
- Se agregó `ALLOW_PROMPT_CAPTURE: "all" | "classified" | "never" = "classified"`.
- Se agregó `classifyPrompt()` con reglas para:
  - `sensitive` → no capturar (`secret_like`).
  - `noise` → no capturar (`too_short`).
  - `confirmation` → no capturar (`simple_confirmation`).
  - `navigation` → no capturar (`trivial_navigation`).
  - `question` → capturar.
  - `instruction` → capturar por default conservador.
- El gate corre antes de `ensureSession()` y antes de `POST /prompts`.
- El body de `/prompts` se mantiene igual: `{ session_id, content, project }`.
- Se desactivó la migración automática `/projects/migrate` en el plugin para respetar la restricción D6 de no migrar/consolidar DB.

## Validación local pre-restart

| Check | Resultado |
|---|---|
| `Bun.*` en `engram.ts` | ✅ No encontrado |
| `/projects/migrate` en `engram.ts` | ✅ No encontrado |
| `export default Engram` | ✅ Presente |
| `ALLOW_PROMPT_CAPTURE` / `classifyPrompt` | ✅ Presentes |
| TypeScript transpile syntax-only | ✅ `transpile ok` |
| Classifier cases | ✅ `classifier ok` |
| `tsc` completo | ⚠️ Limitado por falta de `@types/node` |

## Casos del clasificador probados localmente

| Input | Resultado esperado | Resultado |
|---|---|:---:|
| `¿Qué rol cumple Engram en esta arquitectura?` | capturar `question` | ✅ |
| `ok gracias jajaja` | no capturar `confirmation` | ✅ |
| `muéstrame el archivo README` | no capturar `navigation` | ✅ |
| `api_key=abc1234567890` | no capturar `sensitive` | ✅ |
| `implementa el gate ahora` | capturar `instruction` | ✅ |

## Smoke runtime post-restart

OpenCode fue reiniciado y se probó en una sesión nueva canonical.

| Smoke | Input | Esperado | Resultado |
|---|---|---|:---:|
| Positivo | `¿Qué rol cumple Engram en esta arquitectura?` | `user_prompts +1` en `opencode-architecture` | ✅ PASS: `308 → 309`, id `342` |
| Negativo | `ok gracias jajaja` | `user_prompts` no aumenta y `observations` no aumenta | ✅ PASS: `user_prompts=309`, `observations=310` |

## Observación importante

Un primer intento post-restart falló por `session_project_mismatch` porque seguía usando una conversación legacy (`arquitectura opencode`). El smoke pasó al abrir una sesión nueva canonical en `opencode-architecture`.

## Próximo paso

Ejecutar E6B-T1..T7 formalmente, uno por uno.
