# E6B-T7 — Formal Test: Useful continuation instruction should be captured

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`  
**Sesión:** Sesión OpenCode canonical, project `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram captura un input de continuación de arquitectura:

```text
Continúa con la arquitectura OpenCode.
```

## Resultado ejecutivo

✅ **PASS.** El Noise Gate clasificó el input como `instruction` → `shouldCapture=true` mediante el fallthrough default. `user_prompts_total` subió de `311` a `312`. Nuevo prompt id `345` con project `opencode-architecture`, contenido exacto y timestamp `16:22:54`. Sin `session_project_mismatch`.

## Mecanismo de clasificación

El input `Continúa con la arquitectura OpenCode.` (38 caracteres) pasa por la cadena de `classifyPrompt()`:

| Paso | Patrón | ¿Match? | Resultado |
|------|--------|:-------:|:----------|
| 1. sensitivePatterns | `gh[opsur]_`, api_key, secret, password, token=, bearer, .env, OPENAI_API_KEY, GITHUB_TOKEN | ❌ | Continúa |
| 2. len < 10 | — | ❌ (38 chars) | Continúa |
| 3. confirmationPattern | ok, listo, gracias, etc. | ❌ | Continúa |
| 4. navigationPattern | muéstrame, mostrar, abre, lista, etc. | ❌ | Continúa |
| 5. questionPattern | ¿? o qué/cómo/por qué/dónde/cuándo/cuál | ❌ | Continúa |
| 6. **default** | — | — | ✅ `instruction` → `shouldCapture=true` |

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
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;"
```

| Métrica | Valor |
|---|---|---:|
| `user_prompts_total` | 311 |
| `observations_total` | 322 |
| Último prompt | id `344`, project `opencode-architecture` |

### 2. Input objetivo (desde sesión canonical)

```text
Continúa con la arquitectura OpenCode.
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), content, created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---|---|---:|---:|
| `user_prompts_total` | 311 | **312** | 312 | ✅ +1 |
| Último `user_prompt` | id `344` | **id `345`** | nuevo id | ✅ |
| Contenido id `345` | — | `Continúa con la arquitectura OpenCode.` | coincide con input | ✅ |
| Longitud id `345` | — | 38 caracteres | coherente | ✅ |
| Project id `345` | — | `opencode-architecture` | canonical | ✅ |
| `observations_total` | 322 | 322 | N/A | ✅ Sin cambio extra |

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|---|:---:|
| 1 | Confirmar proyecto activo `opencode-architecture` | ✅ PASS |
| 2 | Confirmar store real | ✅ PASS |
| 3 | Registrar estado inicial (user_prompts=311, último=344) | ✅ PASS |
| 4 | Ejecutar input T7 desde sesión canonical | ✅ PASS |
| 5 | `user_prompts_total` sube a 312 | ✅ PASS: 311 → 312 |
| 6 | Nuevo prompt id 345 | ✅ PASS |
| 7 | Contenido coincide exactamente | ✅ PASS |
| 8 | Project = `opencode-architecture` | ✅ PASS |
| 9 | No hay `session_project_mismatch` | ✅ PASS |
| 10 | Actualizar documentación | ✅ PASS |
| 11 | Guardar memoria Engram | ✅ PASS |
| 12 | Reportar PASS/BLOCKED/FAIL | ✅ PASS |

## Diagnóstico

El default capture funciona correctamente para inputs que no matchean ningún patrón restrictivo. "Continúa con la arquitectura OpenCode." es un comando de continuación semánticamente útil que debe persistirse como contexto de sesión.

## Importancia de T7

T7 cierra la suite E6B validando el caso más común: un input que no es sensible, no es ruido, no es navegación, no es pregunta explícita, pero es semánticamente valioso como instrucción.

## Estado final E6B

| Test | Input | Esperado | Resultado |
|:----:|-------|----------|:---------:|
| T1 | `ok gracias jajaja` | No capturar | ✅ PASS |
| T2 | `listo` | No capturar | ✅ PASS |
| T3 | `¿Qué rol cumple Engram en esta arquitectura?` | Capturar | ✅ PASS |
| T4 | `Diseña una prueba read-only para validar mem_context.` | Capturar | ✅ PASS |
| T5 | `Mi token falso es ghp_FAKE...` | No capturar raw | ✅ PASS |
| T6 | `muéstrame el archivo README` | No capturar | ✅ PASS |
| T7 | `Continúa con la arquitectura OpenCode.` | Capturar | ✅ PASS |

**Todos los tests PASS. Suite E6B completa.**
