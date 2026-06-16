# F-T3 — Formal Test: `mem_context` sin parámetro project

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Store real:** `C:\Users\harry\.engram\engram.db`
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar el comportamiento de `mem_context` cuando se invoca sin filtro de proyecto (parámetro `project` omitido). Determinar si retorna un contexto útil del proyecto activo o sobrecarga con datos de múltiples proyectos.

## Restricciones (read-only)

Ídem F-T1.

## Comandos ejecutados

### 1. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts_total', COUNT(*) FROM user_prompts;
SELECT 'observations_total', COUNT(*) FROM observations;
SELECT 'sessions_total', COUNT(*) FROM sessions;
SELECT project, COUNT(*) as obs_count FROM observations GROUP BY project ORDER BY obs_count DESC;
"
```

| Métrica | Valor antes |
|---------|:-----------:|
| `user_prompts_total` | |
| `observations_total` | |
| `sessions_total` | |
| Proyectos en observations | lista |

### 2. Input objetivo

```text
engram_mem_context
```

(sin parámetro project)

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
| Contexto del proyecto activo (o implícito) | ✅ Retorna datos útiles |
| Sin inventar contexto | ✅ |
| `user_prompts_total` sin cambios | ✅ |
| `observations_total` sin cambios | ✅ |
| `sessions_total` sin cambios | ✅ |

### Comportamiento posible (documentar cuál ocurre)

- **Opción A**: Retorna contexto del proyecto detectado automáticamente (desde CWD o session activa).
- **Opción B**: Retorna datos de todos los proyectos (ruido cruzado).
- **Opción C**: Retorna vacío o error si no se provee project explícito.

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | No hay excepción ni error | ⏳ |
| 2 | El contexto retornado es coherente (no mezcla proyectos sin distinción) | ⏳ |
| 3 | No se inventan observations | ⏳ |
| 4 | DB sin cambios post-llamada | ⏳ |
| 5 | Comportamiento documentado (A/B/C) | ⏳ |

## Riesgos detectados

- Si retorna datos de todos los proyectos (Opción B), el Manager recibiría ruido cruzado de proyectos no relacionados.
- El comportamiento por defecto (sin project) debe estar documentado para que el Manager sepa cuándo omitir el filtro.

## Próximo paso

Ejecutar **F-T4** (verificación de efectos secundarios en DB).
