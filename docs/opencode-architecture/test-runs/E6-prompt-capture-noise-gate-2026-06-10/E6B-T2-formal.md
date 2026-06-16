# E6B-T2 — Formal Test: Short confirmation `listo` is not captured

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram no persiste una confirmación corta (`listo`) como `user_prompt` ni genera observaciones adicionales.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
- No se introdujeron cambios arquitectónicos.
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
| `observations_total` | 313 |
| Último prompt | id `342`, project `opencode-architecture`, length `44` |

### 3. Input objetivo

```text
listo
```

### 4. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "PRAGMA database_list; SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5; SELECT id, type, title, created_at FROM observations ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Antes | Después | Resultado |
|---|---:|---:|:---:|
| `user_prompts_total` | 309 | 309 | ✅ No capturó |
| `observations_total` | 313 | 313 | ✅ No generó observación |
| Último `user_prompt` | id `342` | id `342` | ✅ Sin nuevo prompt |

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|:---:|
| 1 | Registrar estado inicial | ✅ PASS |
| 2 | Ejecutar input definido para E6B-T2 | ✅ PASS |
| 3 | Registrar estado posterior | ✅ PASS |
| 4 | Validar comportamiento observado vs esperado | ✅ PASS |
| 5 | Documentar evidencia técnica | ✅ PASS |
| 6 | Actualizar matriz/resultados E6B | ✅ PASS |
| 7 | Guardar memoria Engram del resultado | ✅ PASS: `Validated E6B-T2 listo filter` |
| 8 | Reportar PASS/PARCIAL/BLOCKED | ✅ PASS |

## Riesgos detectados

- Ningún riesgo nuevo en T2.
- El riesgo de sesiones legacy sigue siendo externo al test; la ejecución se mantuvo bajo `opencode-architecture`.

## Próximo paso

Ejecutar **E6B-T3** formal.
