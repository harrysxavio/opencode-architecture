# F-T5 — Formal Test: No invención de contexto

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Store real:** `C:\Users\harry\.engram\engram.db`
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar que `mem_context` no inventa sesiones, observaciones ni prompts. Verificar que todo lo retornado existe realmente en la DB y que el contenido coincide con lo almacenado.

## Restricciones (read-only)

Ídem F-T1.

## Comandos ejecutados

### 1. Obtener IDs reales de la DB

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT id, type, substr(title, 1, 60) as title_preview, created_at
FROM observations
WHERE project = 'opencode-architecture'
ORDER BY created_at DESC
LIMIT 10;
"
```

### 2. Llamar a `mem_context`

```text
engram_mem_context(project="opencode-architecture")
```

### 3. Verificación: cotejar cada observation listada

Para cada observation mencionada en la respuesta de `mem_context`:

```text
engram_mem_get_observation(id=<ID>)
```

Verificar que el contenido de `mem_get_observation` coincide con el resumen mostrado por `mem_context`.

## Resultado esperado

| Aspecto | Esperado |
|---------|----------|
| Todas las observaciones referenciadas existen | ✅ IDs reales en DB |
| Contenido de resumen coincide con observation real | ✅ Sin invención de detalles |
| Sin observaciones con IDs inexistentes | ✅ |
| Sin sesiones ficticias | ✅ |
| `user_prompts` listados corresponden a prompts reales en DB | ✅ |

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | Obtener IDs reales de observations del proyecto | ⏳ |
| 2 | Ejecutar `mem_context` y capturar IDs listados | ⏳ |
| 3 | Verificar que cada ID listado existe en DB | ⏳ |
| 4 | Verificar que el contenido del resumen coincide con la observation real | ⏳ |
| 5 | Reportar PASS si no hay invención; FAIL si se encuentra al menos un ID ficticio | ⏳ |

## Riesgos detectados

- `mem_context` podría truncar o resumir observaciones largas, mostrando solo un fragmento. Esto no es invención, pero podría parecerlo si no se distingue entre resumen y contenido exacto.
- El orden de `Recent Observations` en la respuesta puede no coincidir exactamente con el `ORDER BY created_at DESC` de la DB si Engram aplica su propio ranking.

## Próximo paso

Ejecutar **F-T6** (sin activación de componentes innecesarios).
