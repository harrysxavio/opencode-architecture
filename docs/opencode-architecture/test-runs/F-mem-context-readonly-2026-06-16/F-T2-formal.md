# F-T2 — Formal Test: `mem_context` con proyecto inexistente

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Store real:** `C:\Users\harry\.engram\engram.db`
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar que `mem_context(project="non-existent-project-xyz")` no falla, no inventa contexto y no produce efectos secundarios.

## Restricciones (read-only)

Ídem F-T1.

## Comandos ejecutados

### 1. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;
SELECT 'observations_total', COUNT(*) FROM observations;
SELECT 'sessions_total', COUNT(*) FROM sessions;
"
```

| Métrica | Valor antes |
|---------|:-----------:|
| `user_prompts_total` | |
| `observations_total` | |
| `sessions_total` | |

### 2. Input objetivo

```text
engram_mem_context(project="non-existent-project-xyz")
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;
SELECT 'observations_total', COUNT(*) FROM observations;
SELECT 'sessions_total', COUNT(*) FROM sessions;
"
```

## Resultado esperado

| Aspecto | Esperado |
|---------|----------|
| Respuesta sin error | ✅ Sin excepción |
| Sin sesiones del proyecto inexistente | ✅ Vacío o sin menciones |
| Sin inventar contexto | ✅ No fabrica observations |
| `user_prompts_total` sin cambios | ✅ |
| `observations_total` sin cambios | ✅ |
| `sessions_total` sin cambios | ✅ |

### Comportamiento posible (documentar cuál ocurre)

- **Opción A**: Retorna vacío `/ no sessions found for this project` — respuesta graceful.
- **Opción B**: Retorna datos de otros proyectos como fallback — documentar.
- **Opción C**: Error tool exception — documentar mensaje.

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | No hay excepción ni error | ⏳ |
| 2 | No se inventan observations | ⏳ |
| 3 | DB sin cambios post-llamada | ⏳ |
| 4 | Comportamiento documentado (A/B/C) | ⏳ |

## Riesgos detectados

- Si el MCP server falla con proyecto inexistente (Opción C), el Manager debe manejarlo gracefulmente sin cascada de errores.
- Si retorna datos de otro proyecto (Opción B), es un riesgo de contexto incorrecto para el Manager.

## Próximo paso

Ejecutar **F-T3** (sin parámetro project).
