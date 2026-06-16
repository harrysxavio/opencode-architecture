# E6B-T4 — Formal Test: Instruction/design prompt should be captured

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`  
**Sesión:** Sesión OpenCode canonical, project `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram captura un input de diseño/instrucción:

```text
Diseña una prueba read-only para validar mem_context.
```

## Resultado ejecutivo

✅ **PASS.** El input se capturó correctamente como `user_prompt`. `user_prompts_total` aumentó de `310` a `311`, creando el prompt id `344` con project `opencode-architecture` y el contenido exacto. Sin `session_project_mismatch`. El Noise Gate clasificó correctamente como `instruction` → `shouldCapture=true`.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
- No se introdujeron cambios arquitectónicos.
- No se hicieron refactors.
- No se usó `.codex/memories_1.sqlite`.
- Se mantuvo `C:\Users\harry\.engram\engram.db` como store real.
- No se modificaron criterios del Noise Gate.

## Comandos ejecutados

### 1. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), SUBSTR(content,1,60), created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado:

| Métrica | Valor |
|---|---|---:|
| DB path | `C:\Users\harry\.engram\engram.db` |
| `user_prompts_total` | 310 |
| `observations_total` | 318 |
| Último prompt | id `343`, project `opencode-architecture`, length `44`, contenido `¿Qué rol cumple Engram en esta arquitectura?` |

### 2. Input objetivo (desde sesión canonical)

```text
Diseña una prueba read-only para validar mem_context.
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), SUBSTR(content,1,80), created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---|---|---|---:|---:|
| `user_prompts_total` | 310 | 311 | 311 | ✅ PASS |
| Último `user_prompt` | id `343` | id `344` | nuevo id | ✅ PASS |
| Contenido id `344` | — | `Diseña una prueba read-only para validar mem_context.` | coincide con input | ✅ PASS |
| Longitud id `344` | — | 53 caracteres | coherente | ✅ PASS |
| Project id `344` | — | `opencode-architecture` | `opencode-architecture` | ✅ PASS |
| `observations_total` | 318 | 319 | N/A | ✅ Sin cambio extra |

### 4. Evidencia de `session_project_mismatch`

No se observó `session_project_mismatch`. El log sanitizado (con `DEBUG_ENGRAM_PLUGIN=false`) no fuerza capturas exitosas; la DB es la fuente de verdad y confirma la escritura sin errores.

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|---|:---:|
| 1 | Confirmar proyecto activo `opencode-architecture` | ✅ PASS |
| 2 | Confirmar store real `C:\Users\harry\.engram\engram.db` | ✅ PASS |
| 3 | Registrar estado inicial (user_prompts, observations, último id) | ✅ PASS |
| 4 | Ejecutar input definido para E6B-T4 desde sesión canonical | ✅ PASS |
| 5 | Registrar estado posterior | ✅ PASS |
| 6 | Confirmar nuevo prompt con contenido y project correctos | ✅ PASS |
| 7 | Validar que no hubo `session_project_mismatch` | ✅ PASS |
| 8 | Actualizar documentación (T4-formal, test-results, summary-matrix) | ✅ PASS |
| 9 | Guardar memoria Engram del resultado | ✅ PASS |
| 10 | Reportar PASS/BLOCKED/FAIL | ✅ PASS |

## Diagnóstico

El Noise Gate clasifica inputs de diseño/instrucción como `instruction` → `shouldCapture=true`, y la captura fluye correctamente en sesión canonical. No hay regresión respecto a T3.

## Lecciones aprendidas

- Inputs de diseño/instrucción se capturan sin problemas, lo cual es esperado y deseado.
- La suite F (mem_context tests) fue creada exitosamente por el AI en sesión canonical como respuesta al input.

## Próximo paso

Continuar con E6B-T5 (token falso/should not capture raw) desde la sesión canonical.
