# E6B-T6 — Formal Test: Navigation command should NOT be captured

**Resultado:** ✅ PASS  
**Fecha:** 2026-06-16  
**Store real:** `C:\Users\harry\.engram\engram.db`  
**Proyecto activo MCP:** `opencode-architecture`  
**Sesión:** Sesión OpenCode canonical, project `opencode-architecture`

## Objetivo

Validar formalmente que el Noise Gate de Engram **filtra y no captura** un comando de navegación trivial:

```text
muéstrame el archivo README
```

## Resultado ejecutivo

✅ **PASS.** El Noise Gate clasificó el input como `navigation` → `shouldCapture=false` mediante el patrón `navigationPattern`. `user_prompts_total` se mantuvo en `311`. Último prompt sigue siendo id `344`. Zero registros contienen "muéstrame" en la DB.

## Mecanismo de filtro

El Noise Gate en `classifyPrompt()` (línea 272 de `engram.ts`) incluye el patrón:

```javascript
const navigationPattern = /^(mu[eé]strame|mostrame|mostrar|abre|abr[ií]|lista|listame|enumera|qu[eé]\s+hay\s+en\s+(esta\s+)?(carpeta|directorio)|qu[eé]\s+archivos|ens[eé]ñame|lee)\b/i
```

Para el input `muéstrame el archivo README`:

- `muéstrame` → matchea `mu[eé]strame` ✅
- Se evalúa antes del patrón de preguntas (navigation check va antes de question check)
- Retorna `{ type: "navigation", shouldCapture: false, reason: "trivial_navigation" }`
- El gate detiene la captura antes de POST `/prompts`

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
| `observations_total` | 321 |
| Último prompt | id `344`, project `opencode-architecture` |

### 2. Input objetivo (desde sesión canonical)

```text
muéstrame el archivo README
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "SELECT 'user_prompts_total', COUNT(*) FROM user_prompts; SELECT 'observations_total', COUNT(*) FROM observations; SELECT id, project, LENGTH(content), SUBSTR(content,1,60), created_at FROM user_prompts ORDER BY created_at DESC LIMIT 5; SELECT 'matched_muestrame', COUNT(*) FROM user_prompts WHERE content LIKE '%muéstrame%';"
```

Resultado:

| Métrica | Antes | Después | Esperado | Resultado |
|---|---|---|---:|---:|
| `user_prompts_total` | 311 | 311 | 311 (sin cambio) | ✅ PASS |
| Último `user_prompt` | id `344` | id `344` | mismo id | ✅ Sin nuevo prompt |
| `observations_total` | 321 | 321 | mismo | ✅ Sin cambio |
| Prompts con `muéstrame` | — | **0** | 0 | ✅ No persistió |

### 4. Evidencia de comportamiento observado

La respuesta del AI en sesión canonical fue leer y mostrar el contenido del README — comportamiento natural para un comando de navegación. No hubo indicio de que el prompt se estuviera capturando como contexto persistente.

## Criterios de aceptación

| # | Criterio | Resultado |
|---|---|---|:---:|
| 1 | Confirmar proyecto activo `opencode-architecture` | ✅ PASS |
| 2 | Confirmar store real | ✅ PASS |
| 3 | Registrar estado inicial | ✅ PASS |
| 4 | Ejecutar input T6 desde sesión canonical | ✅ PASS |
| 5 | `user_prompts_total` no aumenta | ✅ PASS: 311 → 311 |
| 6 | `observations_total` no aumenta | ✅ PASS: 321 → 321 |
| 7 | Ningún registro contiene "muéstrame" en content | ✅ PASS: 0 registros |
| 8 | No hay `session_project_mismatch` | ✅ PASS |
| 9 | Actualizar documentación | ✅ PASS |
| 10 | Guardar memoria Engram | ✅ PASS |
| 11 | Reportar PASS/BLOCKED/FAIL | ✅ PASS |

## Diagnóstico

El Noise Gate filtra correctamente comandos de navegación trivial que empiezan con "muéstrame" (y variantes acentuadas). El patrón `navigationPattern` se evalúa antes que `questionPattern`, lo que evita que un `muéstrame X` sea clasificado incorrectamente como pregunta.

## Riesgos detectados

- Falso positivo potencial: un input como "muéstrame cómo configurar el auth" sería navegación (no capturado) cuando debería ser instrucción. Este riesgo está aceptado: comandos que empiezan con "muéstrame" asumen intención de navegación pasiva.
- `navigationPattern` cubre ~10 prefijos comunes. Si el usuario usa sinónimos no cubiertos (ej. "dame el archivo", "pasame el README") se capturarían como instrucción — comportamiento seguro (capturar de más es mejor que perder contexto).

## Próximo paso

Continuar con E6B-T7 (input útil con contenido de arquitectura — debe capturar) desde la sesión canonical.
