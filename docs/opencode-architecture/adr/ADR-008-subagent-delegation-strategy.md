# ADR-008: Estrategia de Delegación a Subagentes

## Estado

**Propuesto** — Sin nuevos hallazgos en Fase B0. Pendiente de resolución de primary (ADR-001).

## Contexto

Actualmente el sistema tiene múltiples mecanismos de delegación:

- **Manager**: usa `task()` (sync) para subagentes SDD y `task()` para subagentes especializados.
- **gentle-orchestrator**: usa `delegate` (async) para subagentes SDD y `task` (sync) cuando necesita resultado inmediato.
- **Subagentes SDD**: tienen executor boundary que les prohíbe delegar.
- **background-agents.ts**: implementa `delegate` tool con persistencia a disco, outputs fuera del undo tree.

**Problemas detectados**:
1. Manager y gentle-orch tienen mecanismos de delegación diferentes (task vs delegate).
2. Manager referencia subagentes que no existen (review-gpt55, debug-gpt55).
3. No hay criterios unificados de cuándo usar task sync vs delegate async.
4. background-agents.ts escribe outputs fuera del undo tree (no deshacible).
5. Subagentes especializados tienen herramientas muy restrictivas (algunos no pueden escribir).

## Decisión

**Delegar por complejidad, especialidad y costo. Mecanismo unificado: task (sync) como default, delegate (async) solo para procesos largos.**

### Reglas de delegación

| Situación | Mecanismo | ¿Quién decide? |
|-----------|-----------|----------------|
| Request Tiny | No delegar | Manager |
| Request Small (1 archivo) | No delegar (Manager inline) | Manager |
| Request Medium (2-5 archivos) | task(subagent SDD) sync | Manager |
| Request Large (5+ archivos, arquitectura) | task(subagent SDD) sync o delegate async | Manager |
| Frontend | task(frontend-specialist) sync | Manager |
| Seguridad (predeploy) | task(release-security-gate) sync | Manager |
| BigQuery profiling | task(bigquery-data-quality) sync | Manager |
| SDD pipeline completo | task(gentle-orchestrator) sync | Manager |
| Proceso async largo (>5 min) | delegate(async) via background-agents | Manager |
| Consulta externa (Context7, etc.) | Inline con MCP (no delegar) | Manager |

### Subagentes que deben existir o documentarse

| Subagente | Estado actual | Acción |
|-----------|---------------|--------|
| review-gpt55 | ❌ No existe | Decidir: implementar o eliminar referencia |
| debug-gpt55 | ❌ No existe | Decidir: implementar o eliminar referencia |
| Judgment Day | ✅ Existe como skill | Mantener, cargar bajo demanda |

## Razón

1. Unificar mecanismos reduce confusión y mantiene consistencia.
2. Delegar por complejidad evita que el Manager se sobrecargue de contexto.
3. task (sync) es más simple y predecible que delegate (async) para la mayoría de los casos.
4. delegate (async) sigue disponible para procesos que no deben bloquear.
5. Subagentes que no existen deben ser implementados o las referencias deben eliminarse.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Delegación por complejidad** (esta decisión) | Clara, predecible, unificada | Manager debe clasificar correctamente |
| **B: Solo task sync** | Simple, todo síncrono | No apto para procesos largos |
| **C: Solo delegate async** | Consistente, outputs persistidos | Latencia en cada delegación |
| **D: Mantener actual (task + delegate)** | Sin cambios | Diferentes mecanismos, confusión |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Mecanismo de delegación claro y unificado.
- Subagentes reciben solo el contexto que necesitan.
- Outputs de subagentes son predecibles (envelope).
- Async disponible para procesos largos.

## Consecuencias negativas

- Manager debe clasificar correctamente (riesgo de clasificación incorrecta).
- Subagentes faltantes (review-gpt55, debug-gpt55) necesitan decisión.
- Delegación async sigue teniendo tradeoff de fuera de undo tree.

## Evidencia

- **Archivos**: `opencode.json`, `background-agents.ts`, `sdd-apply/SKILL.md`
- **Hallazgos**: task vs delegate, executor boundary, subagentes faltantes
- **ID en Evidence Register**: E004, E006, E008, E009, E047, E048, R07

## Validación requerida

1. [ ] Verificar que task() sync funciona para subagentes SDD.
2. [ ] Verificar que delegate() async funciona para procesos largos.
3. [ ] Decidir sobre review-gpt55 y debug-gpt55: implementar o eliminar.
4. [ ] Verificar que outputs de subagentes retornan envelope correctamente.
