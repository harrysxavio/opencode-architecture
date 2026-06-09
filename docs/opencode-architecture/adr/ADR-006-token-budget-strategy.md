# ADR-006: Estrategia de Token Budget

## Estado

**Propuesto** — Pendiente de baseline de tokens. **No aprobar aún.**

> ⚠️ **Fase B0**: La estimación de ~29,000 fue corregida a ~18,500–22,000 (rango conservador). Pero sigue siendo una estimación, no medido. Se requiere Test 8 (baseline) antes de decidir objetivos de reducción. Mantener PROPUESTO.

## Contexto

El sistema actual tiene un **contexto fijo estimado de ~29,000 tokens por sesión**, compuesto por:

| Fuente | Tokens |
|--------|--------|
| System prompt base | ~3,000 |
| AGENTS.md (.codex) | ~12,000 (solo si gentle-orch activo) |
| AGENTS.md (.config/opencode) | ~7,000 (solo si Manager activo) |
| Available skills list | ~3,000 |
| Engram MEMORY_INSTRUCTIONS | ~2,500 |
| Design skills protocol | ~1,500 |
| Background-agents rules | ~1,000 |

> ⚠️ **Corrección Fase B0**: La suma de ~29,000 asume ambos AGENTS.md activos simultáneamente, lo cual es incorrecto. Solo UN agente se carga por sesión. El rango conservador es **~18,500–22,000 tokens**. Pendiente de medición runtime (Test 8).

Este contexto se inyecta siempre, antes del primer mensaje del usuario. Con GPT-5.5, esto tiene impacto directo en latencia y costo.

**Problemas detectados**:
1. Instrucciones Engram duplicadas en 3 fuentes (~2,500 tokens redundantes).
2. Design skills protocol siempre inyectado aunque no haya tarea frontend (~1,500 tokens).
3. Available skills list con 48 skills aunque solo unas pocas aplican al proyecto actual (~3,000 tokens).
4. AGENTS.md (.codex) con ~12,000 tokens que incluye secciones movibles a docs.
5. MCP schemas agregando ~4,000-10,000 tokens adicionales según MCP activos.

## Decisión

**Reducir el contexto fijo de ~18,500–22,000 a ~15,000-18,000 tokens mediante lazy-loading, desduplicación y movimiento a documentación versionada.**

### Acciones concretas

1. **Desduplicar instrucciones Engram**: eliminar de AGENTS.md, dejar solo en plugin engram.ts. **Ahorro: ~2,500 tokens.**
2. **Mover Design Skills Protocol a skill bajo demanda**: crear skill `frontend-design-gate` que se cargue solo cuando haya tarea frontend. **Ahorro: ~1,500 tokens.**
3. **Reducir available skills**: en lugar de listar 48 skills globales, listar solo triggers relevantes al proyecto activo. **Ahorro: ~1,500 tokens.**
4. **Compactar AGENTS.md (.config)**: remover secciones que viven en plugin (Engram protocol). **Ahorro: ~3,000 tokens.**
5. **Mover secciones extensas de AGENTS.md (.codex) a docs/**: cargar bajo demanda con Document Retriever. **Ahorro: ~5,000 tokens.**

## Razón

1. Cada token tiene costo (monetario y de latencia) con GPT-5.5.
2. El contexto fijo no escala: más skills, más MCP, más plugins = más tokens.
3. La información que no se necesita para el request actual no debería ocupar contexto.
4. Lazy-loading es un patrón probado: cargar solo lo necesario cuando se necesita.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Lazy-loading + desduplicación** (esta decisión) | Ahorro significativo, comportamiento preservado | Requiere implementación cuidadosa |
| **B: Mantener estado actual** | Sin cambios | ~29k tokens fijos permanentemente |
| **C: Eliminar todas las fuentes no críticas** | Máximo ahorro | Riesgo de perder comportamiento necesario |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Reducción de ~11,000-14,000 tokens fijos por sesión.
- Menor latencia en requests simples.
- Menor costo operativo con GPT-5.5.

## Consecuencias negativas

- Las fuentes movidas a lazy-load pueden tardar en cargarse cuando se necesiten.
- Riesgo de que el modelo no sepa qué skills/documentos están disponibles.
- Esfuerzo de implementación: modificar AGENTS.md, crear skills, ajustar plugins.

## Evidencia

- **ID en Evidence Register**: E041, E042, E043, E044
- **Documento relacionado**: `05-token-cost-map.md`

## Validación requerida

1. [ ] Medir tokens fijos actuales con precisión (Test 8 del plan).
2. [ ] Verificar que desduplicar Engram no pierde funcionalidad de memoria.
3. [ ] Verificar que Design Skills Protocol se carga correctamente bajo demanda.
4. [ ] Medir tokens después de cada optimización.
5. [ ] Verificar comportamiento del modelo no degradado.
