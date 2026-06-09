# ADR-005: Rol de Context Index y Skill Registry

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). El Skill Registry es el índice de contexto oficial. No existe CONTEXT_INDEX.md separado. Inventory es catálogo humano, no índice de contexto.

> ✅ **Validación parcial Fase B0**: Se confirmó que CONTEXT_INDEX.md existe en otros proyectos pero NO en el workspace actual. skill-registry.md cumple la función de context index.

---

## Contexto

Actualmente existen tres conceptos que pueden confundirse:

1. **`.atl/skill-registry.md`**: Índice de 48 skills con triggers, scopes y paths. Auto-generado por `gentle-ai skill-registry refresh`. Se usa como contexto index para que delegadores pasen paths exactos a subagentes.

2. **`CONTEXT_INDEX.md`**: No existe como archivo físico en el workspace actual. Es mencionado en el prompt de `frontend-specialist` pero no se encontró implementación. Existe en otros proyectos (PROJECT_TEMPLATE, SAMPLE_PROJECT).

3. **`inventory/`**: `inventory.md` y `inventory.json` contienen catálogo técnico de agentes, MCP, skills y plugins. Generado con `generate-static-inventory.mjs`. Es un panel de control humano.

### Problemas detectados

- `frontend-specialist` busca `CONTEXT_INDEX.md`, que no existe.
- `skill-registry.md` se llama "Skill Registry" pero funciona como context index.
- `inventory/` tiene propósito diferente pero puede confundirse con un índice de contexto.
- No hay claridad sobre qué archivo contiene qué tipo de información.

---

## Decisión

**El Skill Registry es el índice de contexto oficial. No crear CONTEXT_INDEX.md separado. Inventory es catálogo humano, no índice de contexto.**

### Roles precisos

| Componente | Rol | ¿Para quién? | ¿Se carga automáticamente? |
|------------|-----|--------------|---------------------------|
| **`.atl/skill-registry.md`** | Índice de skills con triggers, paths, scopes. Context index para delegadores. | Subagentes, Manager | No. Se lee bajo demanda. |
| **`docs/opencode-architecture/`** | Arquitectura, ADRs, roadmap, decisiones, planes. Fuente de verdad. | Humanos, Manager | No. Document Retriever bajo demanda. |
| **`inventory/`** | Catálogo técnico estático. Panel de control humano. | Humanos | No. Solo consulta explícita. |
| **`inventory.json`** | Versión JSON del inventory para procesamiento. | Scripts, herramientas | No. Solo consulta explícita. |

### Reglas

1. **No existe CONTEXT_INDEX.md separado.** skill-registry.md es el context index.
2. **Si un subagente necesita contexto de skills**, debe leer `.atl/skill-registry.md`.
3. **Si un subagente necesita contexto de arquitectura**, debe leer `docs/opencode-architecture/` vía Document Retriever.
4. **Si alguien necesita un catálogo técnico**, debe leer `inventory/`.
5. **Ninguno se carga automáticamente** — todos se leen bajo demanda.

### Impacto en frontend-specialist

El prompt de `frontend-specialist` referencia `CONTEXT_INDEX.md`. Esto debe actualizarse para que:
- Si necesita skills indexadas → lea `.atl/skill-registry.md`.
- Si necesita documentación de arquitectura → lea `docs/opencode-architecture/`.
- Si necesita DESIGN.md → lo busque en la raíz del proyecto.

---

## Consecuencias positivas

- Un solo concepto de "context index": skill-registry.md.
- Menos archivos que mantener (no hay CONTEXT_INDEX.md separado).
- Claridad conceptual: cada archivo tiene un rol específico.
- Reducción de ambigüedad: no hay superposición entre skill-registry, CONTEXT_INDEX e inventory.

## Consecuencias negativas

- El nombre "skill registry" no refleja completamente que también es context index.
- `frontend-specialist` referencia CONTEXT_INDEX.md — hay que actualizar su prompt.
- Proyectos nuevos que usen la plantilla pueden necesitar crear CONTEXT_INDEX.md específico para su dominio.

---

## Validación requerida

1. [ ] Verificar que frontend-specialist funciona sin CONTEXT_INDEX.md.
2. [ ] Verificar que skill-registry.md cubre todas las necesidades de contexto de subagentes.
3. [ ] Actualizar prompt de frontend-specialist si referencia CONTEXT_INDEX.md.

---

## Evidencia

- **Fase B0**: CONTEXT_INDEX.md existe en PROJECT_TEMPLATE y SAMPLE_PROJECT pero NO en workspace actual.
- **Archivo**: `.atl/skill-registry.md` (existente, 48 skills), `inventory/` (existente).
- **ADR relacionado**: ADR-002 (Manager role — Document Retriever).
- **ID en Evidence Register**: E029, E030, E032, E059.
