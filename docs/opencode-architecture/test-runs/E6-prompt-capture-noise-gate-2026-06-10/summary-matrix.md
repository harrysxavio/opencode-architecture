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
| T1 | `ok gracias jajaja` | No capturar | ⏳ |
| T2 | `listo` | No capturar | ⏳ |
| T3 | `¿Qué rol cumple Engram?` | Capturar | ⏳ |
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

## Archivos modificados

| Archivo | Cambio | Estado |
|---------|--------|:------:|
| `plugins/engram.ts` | Plugin oficial Node-compatible + instrumentación D3 temporal; Noise Gate aún no reimplementado | ❌ Hook entra pero `/prompts` responde HTTP 400 |
| `plugins/engram.ts.e6b-backup` | Backup pre-cambio | ✅ |
| `plugins/engram.ts.e6b-d2-backup` | Backup pre-D2 del plugin oficial reinstalado | ✅ |
| `plugins/engram.ts.e6b-d3-backup` | Backup pre-D3 del plugin Node-compatible | ✅ |
| `plugins/engram.ts.e6b-d4-backup` | Backup pre-D4 del plugin instrumentado | ✅ |
| `opencode.jsonc` | Sin cambios | ✅ No necesario |
| `E6B-D1-plugin-load-repair.md` | Registro de reparación controlada + setup oficial | ✅ |
| `E6B-D2-node-compatible-plugin-patch.md` | Registro del patch Node-compatible | ✅ |
| `E6B-D3-hook-export-diagnostic.md` | Registro del diagnóstico hook/export | ✅ |
| `E6B-D4-prompts-http-contract-diagnostic.md` | Registro del diagnóstico HTTP `/prompts` | ✅ |

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
