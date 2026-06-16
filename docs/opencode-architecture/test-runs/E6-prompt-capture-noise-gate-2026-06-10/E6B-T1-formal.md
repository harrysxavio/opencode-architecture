# E6B-T1 — Formal Test: Simple confirmation is not captured

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram no persiste una confirmación simple (`ok gracias jajaja`) como `user_prompt` ni genera observaciones adicionales.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
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
sqlite3 "C:\Users\harry\.engram\engram.db" "PRAGMA database_list; SELECT 'sessions_total', COUNT(*) FROM sessions; SELECT 'sessions_project_opencode_architecture', COUNT(*) FROM sessions WHERE project='opencode-architecture'; SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Valor |
|---|---:|
| DB path | `C:\Users\harry\.engram\engram.db` |
| `sessions_total` | 78 |
| `sessions_project_opencode_architecture` | 10 |
| `user_prompts_total` | 309 |
| `observations_total` | 311 |
| Último prompt | id `342`, project `opencode-architecture`, length `44` |

### 3. Input objetivo

```text
ok gracias jajaja
```

### 4. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "PRAGMA database_list; SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5; SELECT id, type, title, created_at FROM observations ORDER BY created_at DESC LIMIT 5;"
```

Resultado relevante:

| Métrica | Antes | Después | Resultado |
|---|---:|---:|:---:|
| `user_prompts_total` | 309 | 309 | ✅ No capturó |
| `observations_total` | 311 | 311 | ✅ No generó observación |
| Último `user_prompt` | id `342` | id `342` | ✅ Sin nuevo prompt |

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|:---:|
| 1 | Confirmar que Engram usa `~/.engram/engram.db` | ✅ PASS |
| 2 | Confirmar project activo `opencode-architecture` | ✅ PASS |
| 3 | Ejecutar flujo objetivo E6B-T1 | ✅ PASS |
| 4 | Registrar evidencia antes/después | ✅ PASS |
| 5 | Documentar resultado en docs | ✅ PASS |
| 6 | Guardar memoria Engram del resultado | ✅ PASS: `Validated E6B-T1 confirmation filter` |
| 7 | Reportar estado PASS/PARCIAL/BLOCKED | ✅ PASS |

## Riesgos detectados

- El riesgo de sesiones legacy sigue existiendo fuera de este test. T1 se ejecutó sobre el proyecto activo canonical `opencode-architecture`.
- `observations_total` puede cambiar por acciones explícitas de memoria del agente, por eso la comparación antes/después se hizo inmediatamente alrededor del input objetivo.

## Próximo paso

Ejecutar **E6B-T2** formal.
