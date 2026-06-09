# ADR-005: Rol de Context Index y Skill Registry

## Estado

**Propuesto** — Validación parcial en Fase B0.

> ⚠️ **Fase B0**: Se confirmó que CONTEXT_INDEX.md existe en otros proyectos (PROJECT_TEMPLATE, SAMPLE_PROJECT, backup retail) pero NO en el workspace actual. skill-registry.md cumple la función de context index en este proyecto. Decisión de no crear CONTEXT_INDEX.md separado se mantiene.

## Contexto

Actualmente existen (o se mencionan) tres conceptos similares:

1. **`.atl/skill-registry.md`**: Índice de 48 skills con triggers, scopes y paths. Auto-generado por `gentle-ai skill-registry refresh`. Se usa como contexto index para que delegadores pasen paths exactos a subagentes.

2. **`CONTEXT_INDEX.md`**: No existe como archivo físico en ningún path visible. Es mencionado en el prompt de `frontend-specialist` pero no se encontró implementación.

3. **`inventory/`**: `inventory.md` y `inventory.json` contienen catálogo técnico de agentes, MCP, skills y plugins. Se genera con `generate-static-inventory.mjs`. Es un panel de control humano, no un índice de contexto para subagentes.

**Problema detectado**: El `frontend-specialist` busca `CONTEXT_INDEX.md`, que no existe. `skill-registry.md` cumple la función de índice de contexto. `inventory/` tiene propósito diferente pero puede confundirse.

## Decisión

**Skill registry es el índice de contexto oficial para subagentes. No crear CONTEXT_INDEX.md separado. Inventory es catálogo humano, no índice de contexto.**

1. **`.atl/skill-registry.md`** = Context Index oficial para subagentes. Contiene triggers, paths, scopes.
2. **`inventory/`** = Catálogo técnico para humanos. No se inyecta como contexto automático.
3. No crear `CONTEXT_INDEX.md` separado.
4. Si `frontend-specialist` necesita contexto, debe leer `.atl/skill-registry.md` o usar `mem_search`.

## Razón

1. Tener dos índices de contexto (skill-registry + CONTEXT_INDEX) sería redundante.
2. skill-registry ya cumple la función: contiene skills indexadas con triggers y paths.
3. Inventory es para humanos, no para subagentes en runtime.
4. Reducir conceptos = reducir confusión.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Unificar en skill-registry** (esta decisión) | Un solo índice, claro y mantenible | Requiere actualizar referencias a CONTEXT_INDEX.md |
| **B: Crear CONTEXT_INDEX.md separado** | Separación conceptual clara | Otro archivo que mantener, posible desincronización |
| **C: Fusionar con inventory** | Un solo archivo de referencia | Inventory es humano, no apto para subagentes |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Un solo índice de contexto para subagentes.
- Menos archivos que mantener.
- Claridad conceptual: skill-registry = índice de contexto, inventory = catálogo humano.

## Consecuencias negativas

- El nombre "skill registry" no refleja completamente que también es context index.
- `frontend-specialist` referencia CONTEXT_INDEX.md — hay que actualizar su prompt.

## Evidencia

- **Archivos**: `.atl/skill-registry.md` (existente), `CONTEXT_INDEX.md` (no existe), `inventory/` (existente)
- **Hallazgo**: skill-registry cumple función de context index. CONTEXT_INDEX.md no existe.
- **ID en Evidence Register**: E029, E030, E032, C005

## Validación requerida

1. [ ] Verificar que frontend-specialist no necesita CONTEXT_INDEX.md separado.
2. [ ] Verificar que skill-registry.md cubre todas las necesidades de contexto de subagentes.
3. [ ] Actualizar prompt de frontend-specialist si referencia CONTEXT_INDEX.md.
