# E6B-T3 — Formal Test: Useful question should be captured

**Resultado:** 🔴 BLOCKED  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram captura una pregunta útil:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

## Resultado ejecutivo

El test no pudo validar la captura porque el hook llegó a `/prompts`, pero Engram rechazó la escritura con `session_project_mismatch`.

Esto bloquea E6B-T3 en la sesión actual. No se modificó código, DB, schema ni config.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
- No se introdujeron cambios arquitectónicos.
- No se hicieron refactors.
- No se corrigieron temas fuera del alcance del test.
- No se usó `.codex/memories_1.sqlite`.
- Se mantuvo `~/.engram/engram.db` como store real.

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
sqlite3 "C:\Users\harry\.engram\engram.db" "PRAGMA database_list; SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Valor |
|---|---:|
| DB path | `C:\Users\harry\.engram\engram.db` |
| `user_prompts_total` | 309 |
| `observations_total` | 315 |
| Último prompt | id `342`, project `opencode-architecture`, length `44` |

### 3. Input objetivo

```text
¿Qué rol cumple Engram en esta arquitectura?
```

### 4. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "PRAGMA database_list; SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5; SELECT id, type, title, created_at FROM observations ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---:|---:|---:|:---:|
| `user_prompts_total` | 309 | 309 | 310 | 🔴 No capturó |
| Último `user_prompt` | id `342` | id `342` | nuevo id | 🔴 Sin nuevo prompt |
| `observations_total` | 315 | 315 | N/A | ✅ Sin cambio extra |

### 5. Recheck con espera

Se esperaron 2 segundos y se volvió a consultar `user_prompts`.

Resultado: `user_prompts_total_after_wait=309`.

### 6. Evidencia de log sanitizado

Archivo:

```text
C:\Users\harry\.config\opencode\plugins\engram-debug.log
```

Evidencia relevante:

```text
2026-06-16T15:55:10.647Z | /prompts response | ok=false status=400 body={"code":"session_project_mismatch","error":"session project does not match requested project","project":"opencode-architecture","session_project":"arquitectura opencode"}
2026-06-16T15:55:10.648Z | prompt capture skipped | reason=session_project_mismatch project=opencode-architecture
2026-06-16T15:56:13.283Z | /prompts response | ok=false status=400 body={"code":"session_project_mismatch","error":"session project does not match requested project","project":"opencode-architecture","session_project":"arquitectura opencode"}
2026-06-16T15:56:13.284Z | prompt capture skipped | reason=session_project_mismatch project=opencode-architecture
```

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|:---:|
| 1 | Registrar estado inicial | ✅ PASS |
| 2 | Ejecutar input definido para E6B-T3 | ✅ PASS |
| 3 | Registrar estado posterior | ✅ PASS |
| 4 | Validar si hubo captura | 🔴 BLOCKED: escritura rechazada por `session_project_mismatch` |
| 5 | Confirmar comportamiento esperado | 🔴 BLOCKED: no se pudo validar captura positiva |
| 6 | Actualizar documentación | ✅ PASS |
| 7 | Guardar memoria Engram del resultado | ✅ PASS: `Blocked E6B-T3 by session mismatch` |
| 8 | Reportar PASS/PARCIAL/BLOCKED | 🔴 BLOCKED |

## Diagnóstico

El Noise Gate no queda refutado por este test. La evidencia muestra que la escritura fue bloqueada por una sesión legacy cuyo `session_project` es `arquitectura opencode`, mientras el plugin intenta capturar bajo el proyecto canónico `opencode-architecture`.

## Riesgos detectados

- El riesgo R20 de sesiones legacy sigue activo y puede bloquear pruebas positivas.
- Tests positivos requieren una sesión canonical limpia o una política separada de manejo/migración de sesiones legacy.

## Próximo paso

Reintentar E6B-T3 desde una sesión nueva canonical `opencode-architecture`, sin migrar DB ni tocar schema/config.
