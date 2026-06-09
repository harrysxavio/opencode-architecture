# ADR-008: Estrategia de Delegación a Subagentes

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). Delegar por complejidad, especialidad y costo. Contexto mínimo, envelope compacto.

> ✅ **Integrado con ADR-001 y ADR-002**: Manager decide qué delegar, gentle-orchestrator delega fases SDD, subagentes ejecutan sin delegar.

---

## Contexto

Actualmente el sistema tiene múltiples mecanismos de delegación:

- **Manager**: usa `task()` (sync) para subagentes.
- **gentle-orchestrator**: usa `delegate` (async) para subagentes SDD y `task` (sync) cuando necesita resultado inmediato.
- **Subagentes SDD**: tienen executor boundary que les prohíbe delegar.
- **background-agents.ts**: implementa `delegate` tool con persistencia a disco.

### Problemas detectados

1. Manager y gentle-orch tienen mecanismos de delegación diferentes (task vs delegate).
2. Manager referencia subagentes que no existen (`review-gpt55`, `debug-gpt55`).
3. No hay criterios unificados de cuándo usar task sync vs delegate async.
4. background-agents.ts escribe outputs fuera del undo tree (no deshacible).
5. Subagentes especializados tienen herramientas muy restrictivas (algunos no pueden escribir).

---

## Decisión

**Delegar por complejidad, especialidad y costo. Mecanismo unificado: task (sync) como default, delegate (async) solo para procesos largos.**

### Principios de delegación

1. **Contexto mínimo**: el subagente recibe solo lo que necesita para su tarea, no todo el contexto del Manager.
2. **Envelope compacto**: todo subagente retorna `{status, summary, evidence, decisions, risks, next_action}`.
3. **Executor boundary**: subagentes SDD NO delegan. Subagentes especializados NO delegan.
4. **Sync por defecto**: `task()` sync es el mecanismo estándar. `delegate()` async solo para procesos >5 min.
5. **Síntesis obligatoria**: el Manager sintetiza el envelope del subagente, no pasa outputs crudos.

### Matriz de delegación

| Situación | ¿Delega? | ¿A quién? | Mecanismo | Contexto mínimo |
|-----------|----------|-----------|-----------|-----------------|
| Tiny (1 respuesta) | ❌ No | — | Inline | — |
| Small (1 archivo, mecánico) | ❌ No | — | Inline | — |
| Lectura 1-3 archivos | ❌ No | — | Inline | — |
| Lectura 4+ archivos | ✅ Sí | explore subagent | task() sync | Paths + qué buscar |
| Medium (2-5 archivos, lógica nueva) | ✅ Sí | sdd-apply | task() sync | Spec + design + tareas |
| SDD Pipeline completo | ✅ Sí | gentle-orchestrator | task() sync | Objetivo + archivos + restricciones |
| Frontend | ✅ Sí | frontend-specialist | task() sync | DESIGN.md + requisitos |
| Seguridad (predeploy) | ✅ Sí | release-security-gate | task() sync | URL + tipo de deploy |
| BigQuery profiling | ✅ Sí | bigquery-data-quality | task() sync | Dataset + tabla + columnas |
| SQL cleaning | ✅ Sí | sql-cleaning-agent | task() sync | Tabla + criterios |
| Proceso async >5 min | ✅ Sí | background-agents | delegate() async | Tarea + dependencias |
| Consulta MCP (Context7, web) | ❌ No | — | Inline | — |
| Guardar memoria | ❌ No | — | Inline (mem_save directo del Manager) | — |

### Envelope de retorno (estándar para todo subagente)

```json
{
  "status": "success | blocked | partial | failed",
  "phase": "sdd-explore | sdd-apply | frontend | security | ...",
  "summary": "Texto breve de 2-3 oraciones",
  "evidence": ["archivo1.md", "archivo2.ts"],
  "decisions": ["Decisión 1", "Decisión 2"],
  "risks": ["Riesgo 1", "Riesgo 2"],
  "artifacts": ["ruta/artefacto1.md"],
  "next_recommended_action": "Sugerencia para el Manager"
}
```

### Subagentes que no existen: decisión

| Subagente | Existe | Decisión |
|-----------|--------|----------|
| **review-gpt55** | ❌ No | **No implementar.** Manager usa Judgment Day skill + Superpowers review. No necesita GPT-5.5 como subagente separado. |
| **debug-gpt55** | ❌ No | **No implementar.** Manager usa Superpowers debugging + inline analysis. No necesita GPT-5.5 como subagente separado. |
| **Judgment Day** | ✅ Como skill | **Preservar.** Cargar bajo demanda para Medium/Large tasks. |
| **data-memory-curator** | ✅ Como subagente | **Evaluar evolución** a memory-curator con gobernanza general de memoria (ver ADR-004). |

---

## Reglas para subagentes SDD (executor boundary)

Los subagentes SDD (`sdd-explore`, `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, `sdd-archive`) deben:

1. **Ejecutar su fase específica** sin expandir scope.
2. **NO delegar** a nadie (executor boundary estricto).
3. **Leer skills** antes de trabajar (skill tool).
4. **Hacer retrieval de artefactos previos** vía mem_search → mem_get_observation.
5. **Persistir artifacts** vía mem_save con `capture_prompt: false`.
6. **Retornar envelope** con status/summary/next.

### Lo que NO deben hacer

- **NO delegar tareas** a otros agentes.
- **NO llamar task/delegate**.
- **NO expandir scope** de la fase.
- **NO modificar artefactos** de fases anteriores sin coordinación.
- **NO ejecutar inline** tareas de implementación (solo sdd-apply puede).

---

## Consecuencias positivas

- Mecanismo de delegación claro y unificado (task sync como default).
- Subagentes reciben solo el contexto que necesitan (ahorro de tokens).
- Outputs predecibles (envelope estandarizado).
- Async disponible para procesos largos sin bloquear.
- Executor boundary protege contra delegación en cadena.
- No se invierten recursos en subagentes que no existen (review-gpt55, debug-gpt55).

## Consecuencias negativas

- Manager debe clasificar correctamente (riesgo de clasificación incorrecta).
- Si un subagente falla, el Manager debe decidir si reintentar, degradar o escalar.
- Delegación async sigue teniendo tradeoff de fuera de undo tree.
- data-memory-curator necesita decisión de evolución (memory-curator general).

---

## Validación requerida

1. [ ] Verificar que task() sync funciona para subagentes SDD.
2. [ ] Verificar que delegate() async funciona para procesos largos.
3. [ ] Verificar que outputs de subagentes retornan envelope correctamente.
4. [ ] Verificar que subagentes SDD respetan executor boundary.
5. [ ] Verificar que Manager sintetiza envelopes correctamente.

---

## Evidencia

- **Archivos**: `opencode.json`, `background-agents.ts`, `sdd-apply/SKILL.md`.
- **ADR relacionados**: ADR-001 (gentle-orch como SDD pipeline), ADR-002 (Manager como router).
- **ID en Evidence Register**: E004, E006, E008, E009, E047, E048.
