# F-T4 — Formal Test: Verificación de cero efectos secundarios en DB

**Resultado:** ⏎ Pendiente de ejecución
**Fecha:** 2026-06-16
**Store real:** `C:\Users\harry\.engram\engram.db`
**Proyecto activo:** `opencode-architecture`

## Objetivo

Validar que una secuencia completa de llamadas a `mem_context` (3 llamadas consecutivas) no produce ningún cambio en la base de datos de Engram: sin nuevas filas en `user_prompts`, `observations`, `sessions` ni `memory_relations`.

## Restricciones (read-only)

Ídem F-T1.

## Comandos ejecutados

### 1. Baseline antes del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts', COUNT(*) FROM user_prompts
UNION ALL
SELECT 'observations', COUNT(*) FROM observations
UNION ALL
SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'memory_relations', COUNT(*) FROM memory_relations;

SELECT MAX(created_at) as last_activity FROM (
  SELECT MAX(created_at) as created_at FROM user_prompts
  UNION ALL
  SELECT MAX(created_at) FROM observations
  UNION ALL
  SELECT MAX(created_at) FROM sessions
);
"
```

Registrar timestamps de última actividad.

| Métrica | Valor antes |
|---------|:-----------:|
| `user_prompts` | |
| `observations` | |
| `sessions` | |
| `memory_relations` | |
| Última actividad (timestamp) | |

### 2. Secuencia de inputs

```text
# Llamada 1
engram_mem_context(project="opencode-architecture")

# Llamada 2
engram_mem_context(project="opencode-architecture")

# Llamada 3
engram_mem_context(project="non-existent-project-xyz")
```

### 3. Verificación después del test

```powershell
sqlite3 "C:\Users\harry\.engram\engram.db" "
SELECT 'user_prompts', COUNT(*) FROM user_prompts
UNION ALL
SELECT 'observations', COUNT(*) FROM observations
UNION ALL
SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'memory_relations', COUNT(*) FROM memory_relations;

SELECT MAX(created_at) as last_activity FROM (
  SELECT MAX(created_at) FROM user_prompts
  UNION ALL
  SELECT MAX(created_at) FROM observations
  UNION ALL
  SELECT MAX(created_at) FROM sessions
);
"
```

## Resultado esperado

| Métrica | Antes | Después | ¿Cambio? |
|---------|:-----:|:-------:|:--------:|
| `user_prompts` | | | ❌ Sin cambio |
| `observations` | | | ❌ Sin cambio |
| `sessions` | | | ❌ Sin cambio |
| `memory_relations` | | | ❌ Sin cambio |
| Último timestamp | | | ❌ Sin cambio |

## Resultado observado

(Pendiente de ejecución)

## Criterios de aceptación

| # | Criterio | Resultado |
|---|----------|:---------:|
| 1 | Baseline antes de la secuencia | ⏳ |
| 2 | Ejecutar 3 llamadas consecutivas a `mem_context` | ⏳ |
| 3 | Verificar que todas las tablas no cambiaron | ⏳ |
| 4 | Verificar que el timestamp de última actividad no cambió | ⏳ |
| 5 | Reportar PASS si cero efectos secundarios | ⏳ |

## Riesgos detectados

- Si alguna llamada dispara `session_project_mismatch` (porque Engram detecta sesión legacy), podría activar lógica de side-effect no esperada. La sesión debe ser canonical antes del test.
- Si `mem_context` internamente registra métricas de acceso en la DB (último acceso, contador de reads), el test detectará falsos positivos. Documentar si ocurre.

## Próximo paso

Ejecutar **F-T5** (no invención de contexto).
