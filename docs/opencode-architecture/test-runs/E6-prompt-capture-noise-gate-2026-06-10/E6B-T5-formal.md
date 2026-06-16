# E6B-T5 — Formal Test: Secret/token should NOT be captured raw

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`  
**Sesión:** Sesión OpenCode canonical, project `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram **filtra y no persiste** un input que contiene un token falso con formato GitHub PAT:

```text
Mi token falso es ghp_FAKE1234567890abcdef1234567890abcdef
```

## Resultado ejecutivo

✅ **PASS.** El Noise Gate clasificó el input como `sensitive` → `shouldCapture=false` mediante el patrón `/gh[opsur]_[a-z0-9_]{10,}/i`. El prompt **no llegó a POST `/prompts`**. `user_prompts_total` se mantuvo en `311`. Zero registros contienen `ghp_` en la DB.

## Restricciones respetadas

- No se migró DB.
- No se tocó schema.
- No se tocaron configs.
- No se introdujeron cambios arquitectónicos.
- No se hicieron refactors.
- No se usó `.codex/memories_1.sqlite`.
- Se mantuvo `C:\Users\harry\.engram\engram.db` como store real.
- No se modificaron criterios del Noise Gate.

## Mecanismo de filtro

El Noise Gate en `classifyPrompt()` (línea 248 de `engram.ts`) incluye el patrón:

```javascript
/gh[opsur]_[a-z0-9_]{10,}/i
```

Para el input `Mi token falso es ghp_FAKE1234567890abcdef1234567890abcdef`:

- `ghp_` → matchea `gh[opsur]_` ✅
- `FAKE1234567890abcdef1234567890abcdef` → 40 chars alfanuméricos, matchea `[a-z0-9_]{10,}` (case-insensitive) ✅
- Retorna `{ type: "sensitive", shouldCapture: false, reason: "secret_like" }`
- El gate detiene la captura **antes** de POST `/prompts`

## Comandos ejecutados

### 1. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), SUBSTR(content,1,60), created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5;"
```

Resultado:

| Métrica | Valor |
|---|---|---:|
| `user_prompts_total` | 311 |
| `observations_total` | 320 |
| Último prompt | id `344`, project `opencode-architecture` |

### 2. Input objetivo (desde sesión canonical)

```text
Mi token falso es ghp_FAKE1234567890abcdef1234567890abcdef
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), SUBSTR(content,1,80), created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5; SELECT 'any_ghp', COUNT(*) FROM user_prompts WHERE content LIKE '%ghp_%';"
```

Resultado:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---|---|---:|---:|
| `user_prompts_total` | 311 | 311 | 311 (sin cambio) | ✅ PASS |
| Último `user_prompt` | id `344` | id `344` | mismo id | ✅ Sin nuevo prompt |
| `observations_total` | 320 | 320 | mismo | ✅ Sin cambio |
| Prompts con `ghp_` | — | **0** | 0 | ✅ No persistió |

### 4. Confirmación adicional — ningún prompt contiene el token

```sql
SELECT COUNT(*) FROM user_prompts WHERE content LIKE '%ghp_%';
-- Resultado: 0 ✅
```

### 5. Evidencia de comportamiento observado en sesión canonical

La respuesta del AI en la sesión canonical confirmó explícitamente el filtro:

> "No se guarda en Engram — el Noise Gate clasifica esto como credential por el prefijo ghp_ y lo filtra."

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|---|:---:|
| 1 | Confirmar proyecto activo `opencode-architecture` | ✅ PASS |
| 2 | Confirmar store real | ✅ PASS |
| 3 | Registrar estado inicial | ✅ PASS |
| 4 | Ejecutar input T5 desde sesión canonical | ✅ PASS |
| 5 | `user_prompts_total` no aumenta | ✅ PASS: 311 → 311 |
| 6 | `observations_total` no aumenta | ✅ PASS: 320 → 320 |
| 7 | Ningún registro contiene `ghp_` en content | ✅ PASS: 0 registros |
| 8 | Token raw no se persiste en DB | ✅ PASS |
| 9 | No se expone token en logs (DEBUG_ENGRAM_PLUGIN=false) | ✅ PASS |
| 10 | Actualizar documentación | ✅ PASS |
| 11 | Guardar memoria Engram | ✅ PASS |
| 12 | Reportar PASS/BLOCKED/FAIL | ✅ PASS |

## Diagnóstico

El Noise Gate filtra correctamente secretos con formato `ghp_` (GitHub PAT) antes de que lleguen a POST `/prompts`. El patrón `/gh[opsur]_[a-z0-9_]{10,}/i` cubre los formatos conocidos de GitHub tokens. No hay falsos negativos para este caso.

## Riesgos detectados

- El patrón actual cubre `ghp_`, `ghs_`, `gho_`, `ghu_`, `ghr_` — los formatos conocidos de GitHub. Coverage aceptable para esta fase.
- No cubre otros formatos de secretos (AWS keys, Slack tokens, etc.) — riesgo aceptado y documentado en el risk register (R05).

## Próximo paso

Continuar con E6B-T6 (muéstrame el archivo README — no capturar) desde la sesión canonical.
