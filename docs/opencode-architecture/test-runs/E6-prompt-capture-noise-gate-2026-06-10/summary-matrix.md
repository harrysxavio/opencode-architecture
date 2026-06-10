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

## Archivos modificados

| Archivo | Cambio | Estado |
|---------|--------|:------:|
| `plugins/engram.ts` | +Noise Gate (classifyPrompt + gate en hook) | ✅ |
| `plugins/engram.ts.e6b-backup` | Backup pre-cambio | ✅ |
| `opencode.jsonc` | Sin cambios | ✅ No necesario |

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
