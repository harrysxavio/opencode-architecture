# E6B-T3 — Formal Test: Useful question should be captured

**Resultado:** ✅ PASS (retry desde sesión canonical)  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`  
**Sesión:** Nueva sesión OpenCode canonical, project `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram captura una pregunta útil:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

## Resultado ejecutivo

**PASS.** En la primera ejecución el test quedó BLOCKED por `session_project_mismatch` (sesión legacy `arquitectura opencode`). Reejecutado desde una sesión nueva canonical `opencode-architecture`, el input se capturó correctamente: `user_prompts` aumentó de `309` a `310`, creando el prompt id `343` con project `opencode-architecture` y el contenido exacto.

Esto confirma que el Noise Gate clasifica correctamente la pregunta como `question` → `shouldCapture=true`, y que la falla previa era únicamente por sesión legacy. No se modificó código, DB, schema ni config.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
- No se introdujeron cambios arquitectónicos.
- No se hicieron refactors.
- No se corrigieron temas fuera del alcance del test.
- No se usó `.codex/memories_1.sqlite`.
- Se mantuvo `C:\Users\harry\.engram\engram.db` como store real.
- No se modificaron criterios del Noise Gate.

## Comandos ejecutados

### 1. Confirmación de proyecto activo

```text
mem_current_project
```

Resultado:

```text
project=opencode-architecture
cwd=C:\Users\harry\OneDrive\Documentos\GitHub\ARQUITECTURA OPENCODE
project_source=process_override
```

### 2. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Valor |
|---|---|---:|
| DB path | `C:\Users\harry\.engram\engram.db` |
| `user_prompts_total` | 309 |
| `observations_total` | 317 |
| Último prompt | id `342`, project `opencode-architecture`, length `44` |

### 3. Input objetivo (desde sesión nueva canonical)

```text
¿Qué rol cumple Engram en esta arquitectura?
```

### 4. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---|---|---|---:|---:|
| `user_prompts_total` | 309 | 310 | 310 | ✅ PASS |
| Último `user_prompt` | id `342` | id `343` | nuevo id | ✅ PASS |
| Contenido id `343` | — | `¿Qué rol cumple Engram en esta arquitectura?` | coincide con input | ✅ PASS |
| Project id `343` | — | `opencode-architecture` | `opencode-architecture` | ✅ PASS |
| `observations_total` | 317 | 317 | N/A | ✅ Sin cambio extra |

### 5. Evidencia de log sanitizado

El log NO muestra entradas para la captura exitosa, lo cual es **esperado** por diseño: `DEBUG_ENGRAM_PLUGIN=false` y solo errores HTTP se fuerzan al log. Las entradas de mismatch posteriores (`16:04:07`) corresponden a la sesión legacy aún abierta, no a la sesión canonical.

```text
# No hay log de 201 para la captura exitosa — comportamiento correcto con DEBUG_ENGRAM_PLUGIN=false
# Las entradas 400 posteriores son de la sesión legacy, no de la canonical
```

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|---|:---:|
| 1 | Abrir sesión nueva canonical `opencode-architecture` | ✅ PASS |
| 2 | Confirmar proyecto activo y `session_project` | ✅ PASS |
| 3 | Registrar estado inicial (user_prompts, observations, último id) | ✅ PASS |
| 4 | Ejecutar input definido para E6B-T3 | ✅ PASS |
| 5 | Registrar estado posterior | ✅ PASS |
| 6 | Confirmar nuevo prompt con contenido y project correctos | ✅ PASS |
| 7 | Validar que no hubo `session_project_mismatch` | ✅ PASS |
| 8 | Actualizar documentación | ✅ PASS |
| 9 | Guardar memoria Engram del resultado | ✅ PASS |
| 10 | Reportar PASS/BLOCKED/FAIL | ✅ PASS |

## Diagnóstico

El Noise Gate clasificó correctamente la pregunta como `question` → `shouldCapture=true`. La falla del primer intento fue exclusivamente por sesión legacy (`session_project_mismatch`). En sesión canonical, la captura funciona sin errores.

## Lecciones aprendidas

- El Noise Gate no es responsable del bloqueo previo; la causa raíz fue la sesión legacy (`arquitectura opencode`).
- Tests positivos deben ejecutarse en sesión canonical para evitar falsos BLOCKED.
- El log no muestra capturas exitosas con `DEBUG_ENGRAM_PLUGIN=false` — eso es correcto.

## Próximo paso

Continuar con E6B-T4..T7 desde la sesión canonical.
