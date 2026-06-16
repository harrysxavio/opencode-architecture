# E6B — Test Results

> Tests post-implementación del Noise Gate. Se ejecutan en sesión nueva post-restart.

**Estado:** ✅ D6 smoke PASS — E6B-T3..T6 PASS

---

## Resumen

| Test | Input | Esperado | Resultado |
|:----:|-------|----------|:---------:|
| T1 | `ok gracias jajaja` | No capturar user_prompt | ✅ PASS |
| T2 | `listo` | No capturar user_prompt | ✅ PASS |
| T3 | `¿Qué rol cumple Engram en esta arquitectura?` | Capturar user_prompt | ✅ PASS |
| T4 | `Diseña una prueba read-only para validar mem_context.` | Capturar user_prompt | ✅ PASS |
| T5 | `Mi token falso es ghp_TEST_FAKE_TOKEN_1234567890` | No capturar raw | ✅ PASS |
| T6 | `muéstrame el archivo README` | No capturar | ✅ PASS |
| T7 | `Continúa con la arquitectura OpenCode.` | Capturar (contiene contenido útil) | ⏳ |

## Método de verificación

Para cada test:

1. Enviar input.
2. Esperar respuesta.
3. Consultar DB:
   ```sql
   SELECT COUNT(*) FROM user_prompts;
   SELECT created_at, LENGTH(content), SUBSTR(content, 1, 50) FROM user_prompts ORDER BY created_at DESC LIMIT 3;
   ```
4. Verificar que el conteo aumentó o no según lo esperado.
5. Para T5 (secreto), verificar que NO hay un registro cuyo content contenga `ghp_`.

## Resultados

### Pre-smoke D6

| Check | Resultado |
|---|---|
| `Bun.*` removido de `engram.ts` | ✅ |
| `/projects/migrate` desactivado/no presente | ✅ |
| `export default Engram` preservado | ✅ |
| `ALLOW_PROMPT_CAPTURE = "classified"` | ✅ |
| `classifyPrompt()` presente | ✅ |
| Transpile syntax-only | ✅ `transpile ok` |
| Classifier sample cases | ✅ `classifier ok` |
| `tsc` completo | ⚠️ No concluyente: falta `@types/node` |

### Smoke runtime pendiente

OpenCode fue reiniciado. Primer intento en conversación legacy falló por `session_project_mismatch`; el smoke válido se ejecutó en sesión nueva canonical.

| Smoke | Input | Resultado |
|---|---|:---:|
| Positivo | `¿Qué rol cumple Engram en esta arquitectura?` | ✅ `user_prompts 308 → 309`, id `342`, project `opencode-architecture` |
| Negativo | `ok gracias jajaja` | ✅ `user_prompts=309` sin aumento; `observations=310` sin aumento |

### Estado E6B-T1..T7

| Test | Estado | Evidencia |
|---|:---:|---|
| T1 | ✅ PASS | `user_prompts_total` se mantuvo en `309`; `observations_total` se mantuvo en `311`; último prompt siguió siendo id `342`. Ver `E6B-T1-formal.md`. |
| T2 | ✅ PASS | `user_prompts_total` se mantuvo en `309`; `observations_total` se mantuvo en `313`; último prompt siguió siendo id `342`. Ver `E6B-T2-formal.md`. |
| T3 | ✅ PASS | `user_prompts_total` subió de `309` a `310`; nuevo id `343` con project `opencode-architecture` y contenido `¿Qué rol cumple Engram en esta arquitectura?`; sin `session_project_mismatch`. Ver `E6B-T3-formal.md`. |
| T4 | ✅ PASS | `user_prompts_total` subió de `310` a `311`; nuevo id `344` con project `opencode-architecture` y contenido `Diseña una prueba read-only para validar mem_context.`; sin `session_project_mismatch`. Ver `E6B-T4-formal.md`. |
| T5 | ✅ PASS | `user_prompts_total` se mantuvo en `311`; `observations_total` se mantuvo en `320`; zero registros con `ghp_` en DB. Respuesta del AI confirmó filtro: "No se guarda en Engram — el Noise Gate clasifica esto como credential". Ver `E6B-T5-formal.md`. |
| T6 | ✅ PASS | `user_prompts_total` se mantuvo en `311`; `observations_total` se mantuvo en `321`; zero registros con "muéstrame" en DB; sin `session_project_mismatch`. Ver `E6B-T6-formal.md`. |
| T7 | ⏳ | Pendiente |
