# F-T1 — Formal Test: `mem_context` happy path con proyecto canonical

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Store real:** `C:\Users\harry\.engram\engram.db`
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar que `mem_context(project="opencode-architecture")` retorna contexto relevante del proyecto canonical sin inventar datos ni generar efectos secundarios.

## Restricciones (read-only)

- No se ejecuta `mem_save`, `mem_session_summary`, `mem_session_start` ni `mem_judge`.
- No se migra DB, schema ni configs.
- No se usan tools de escritura (`write`, `edit`, `bash` con efectos laterales).
- Store único validado: `~/.engram/engram.db`.

## Comandos ejecutados

### 1. Confirmación de proyecto activo

```text
mem_current_project
```

Resultado esperado:

```text
project=opencode-architecture
project_source=process_override | explicit_override
```

### 2. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;
SELECT 'observations_total', COUNT(*) FROM observations;
SELECT 'sessions_total', COUNT(*) FROM sessions;
SELECT 'relations_total', COUNT(*) FROM memory_relations;
"
```

Registrar métricas como tabla:

| Métrica | Valor antes |
|---------|:-----------:|
| `user_prompts_total` | |
| `observations_total` | |
| `sessions_total` | |
| `relations_total` | |

### 3. Input objetivo: `mem_context` canonical

```text
engram_mem_context(project="opencode-architecture")
```

### 4. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;
SELECT 'observations_total', COUNT(*) FROM observations;
SELECT 'sessions_total', COUNT(*) FROM sessions;
SELECT 'relations_total', COUNT(*) FROM memory_relations;
"
```

## Resultado esperado

| Aspecto | Esperado |
|---------|----------|
| Respuesta contiene `Recent Sessions` | ✅ Sí |
| Respuesta contiene `Recent Observations` | ✅ Sí |
| Respuesta contiene `Recent User Prompts` | ✅ Sí (riesgo conocido) |
| Observaciones son reales (no inventadas) | ✅ Coinciden con DB |
| `user_prompts_total` sin cambios | ✅ Sin nuevos prompts |
| `observations_total` sin cambios | ✅ Sin nuevas observations |
| `sessions_total` sin cambios | ✅ Sin nuevas sesiones |
| `relations_total` sin cambios | ✅ Sin nuevas relaciones |
| Proyecto listado en `Memory stats` | ✅ `opencode-architecture` presente |

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | Registrar estado inicial de DB | ⏳ |
| 2 | Ejecutar `mem_context` con proyecto canonical | ⏳ |
| 3 | Verificar que la respuesta contiene sesiones y observaciones reales | ⏳ |
| 4 | Verificar que NO inventa contexto (cotejar contra DB real) | ⏳ |
| 5 | Verificar que `recentUserPrompts` son identificables como ruido | ⏳ |
| 6 | Registrar estado posterior de DB — sin cambios | ⏳ |
| 7 | Reportar PASS/PARTIAL/BLOCKED | ⏳ |

## Riesgos detectados

- `recentUserPrompts` incluye prompts completos del usuario — ruido documentado en ADR-004.
- Sesiones legacy (`arquitectura opencode`) pueden aparecer en `Memory stats` si no se filtra por proyecto exacto.
- Si el store real no es accesible vía `sqlite3` durante el test, la verificación de baseline/post depende de `mem_diagnostic` u observación indirecta.

## Próximo paso

Ejecutar **F-T2** (proyecto inexistente).
