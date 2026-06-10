# E6B — Test Results

> Tests post-implementación del Noise Gate. Se ejecutan en sesión nueva post-restart.

**Estado:** ⏳ Pendiente de restart OpenCode

---

## Resumen

| Test | Input | Esperado | Resultado |
|:----:|-------|----------|:---------:|
| T1 | `ok gracias jajaja` | No capturar user_prompt | ⏳ |
| T2 | `listo` | No capturar user_prompt | ⏳ |
| T3 | `¿Qué rol cumple Engram en esta arquitectura?` | Capturar user_prompt | ⏳ |
| T4 | `Diseña una prueba read-only para validar mem_context.` | Capturar user_prompt | ⏳ |
| T5 | `Mi token falso es ghp_TEST_FAKE_TOKEN_1234567890` | No capturar raw | ⏳ |
| T6 | `muéstrame el archivo README` | No capturar | ⏳ |
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

*(Completar post-ejecución)*
