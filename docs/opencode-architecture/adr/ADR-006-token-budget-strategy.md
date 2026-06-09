# ADR-006: Estrategia de Token Budget

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). Reducir contexto fijo mediante lazy-loading, desduplicación y movimiento a documentación versionada.

> ⚠️ **Pendiente de medición baseline**: La estimación se corrigió de ~29k a ~18,500–22,000 (Fase B0) pero sigue siendo estimación. Se requiere Test 8 antes de implementar optimizaciones.

---

## Contexto

El sistema actual tiene un **contexto fijo estimado de ~18,500–22,000 tokens por sesión**, compuesto por:

| Fuente | Tokens estimados | Estado |
|--------|-----------------|--------|
| System prompt base | ~3,000 | INFERIDO |
| AGENTS.md (agente activo) | ~7,000–12,000 | INFERIDO (depende del agente) |
| Available skills list | ~3,000 | INFERIDO |
| Engram MEMORY_INSTRUCTIONS | ~2,500 | INFERIDO |
| Design skills protocol | ~1,500 | INFERIDO |
| **Total estimado** | **~18,500–22,000** | **INFERIDO — pendiente de Test 8** |

> ⚠️ **Corrección Fase B0**: La estimación anterior de ~29,000 asumía ambos AGENTS.md activos simultáneamente, lo cual es incorrecto. Solo el agente activo carga su AGENTS.md.

Con la decisión de ADR-001 (Manager único primary), el AGENTS.md de gentle-orchestrator (~12,000 tokens) ya no se carga por defecto. Esto reduce automáticamente el piso del rango.

### Problemas detectados

1. **Instrucciones Engram duplicadas** en 3 fuentes (~2,500 tokens redundantes).
2. **Design skills protocol siempre inyectado** aunque no haya tarea frontend (~1,500 tokens).
3. **Available skills list** con 48 skills aunque solo unas pocas aplican al proyecto activo (~3,000 tokens).
4. **AGENTS.md** (~7,000–12,000 tokens) incluye secciones movibles a docs.
5. **MCP schemas** agregando ~4,000–10,000 tokens adicionales según MCP activos.

---

## Decisión

**Reducir el contexto fijo de ~18,500–22,000 a ~15,000–18,000 tokens mediante:**

1. **Desduplicar instrucciones Engram** (~2,500 tokens de ahorro)
   - Eliminar protocolo Engram de AGENTS.md.
   - Dejar solo en plugin engram.ts como mecanismo runtime.
   - Markdown versionado (engram-instructions.md) como fuente de verdad humana.

2. **Mover Design Skills Protocol a skill bajo demanda** (~1,500 tokens de ahorro)
   - Crear skill `frontend-design-gate` que se cargue solo cuando haya tarea frontend.
   - Eliminar del Manager prompt.

3. **Reducir available skills** (~1,500 tokens de ahorro)
   - En lugar de listar 48 skills, listar solo las relevantes al proyecto activo.
   - Las skills específicas se descubren vía skill registry.

4. **Compactar AGENTS.md** (~3,000–5,000 tokens de ahorro)
   - Remover secciones que viven en plugin o docs.
   - Mantener solo instrucciones operativas mínimas.

5. **MCP bajo demanda** (~4,000–10,000 tokens de ahorro en requests no-MCP)
   - No cargar schemas de MCP que no se usarán.
   - Activar solo cuando el request lo requiera.

### Objetivo de contexto fijo post-optimización

| Fuente | Antes | Después | Diferencia |
|--------|-------|---------|------------|
| System prompt base | ~3,000 | ~3,000 | 0 |
| AGENTS.md (manager activo) | ~7,000 | ~4,000–5,000 | -2,000–3,000 |
| Available skills | ~3,000 | ~1,500 | -1,500 |
| Engram instructions | ~2,500 | ~0 (en plugin) | -2,500 |
| Design skills protocol | ~1,500 | ~0 (skill bajo demanda) | -1,500 |
| MCP schemas (default) | ~4,000–10,000 | ~0 (bajo demanda) | -4,000–10,000 |
| **Total** | **~18,500–22,000** | **~8,500–9,500** | **-10,000–12,500** |

---

## Consecuencias positivas

- Reducción significativa de tokens fijos por sesión (~50-60%).
- Menor latencia en requests simples.
- Menor costo operativo (especialmente con GPT-5.5).
- Comportamiento preservado: la información está disponible bajo demanda.

## Consecuencias negativas

- Las fuentes movidas a lazy-load pueden tardar en cargarse cuando se necesiten.
- Riesgo de que el modelo no sepa qué skills/documentos están disponibles.
- Esfuerzo de implementación: modificar AGENTS.md, crear skills, ajustar plugins.
- Las optimizaciones deben validarse una por una para no romper comportamiento.

---

## Prioridad de implementación

| Prioridad | Acción | Ahorro estimado | Dependencia |
|-----------|--------|-----------------|-------------|
| P0 | Mover secretos a env vars (B-Security) | — | Ninguna |
| P1 | MCP bajo demanda | ~4,000–10,000 | B-Security completada |
| P1 | Desduplicar instrucciones Engram | ~2,500 | Reparar pipeline Engram |
| P2 | Mover Design Skills Protocol a skill | ~1,500 | Ninguna |
| P2 | Compactar AGENTS.md | ~2,000–3,000 | ADR-001 completado |
| P3 | Reducir available skills | ~1,500 | Proyecto estable |

---

## Validación requerida

1. [ ] Medir tokens fijos actuales con precisión (Test 8).
2. [ ] Medir tokens después de cada optimización.
3. [ ] Verificar que desduplicar Engram no pierde funcionalidad de memoria.
4. [ ] Verificar que Design Skills Protocol se carga correctamente bajo demanda.
5. [ ] Verificar comportamiento del modelo no degradado.
6. [ ] Medir latencia de requests con y sin MCP activos.

---

## Evidencia

- **Fase B0**: Estimación corregida de ~29k a ~18,500–22,000.
- **Archivo**: `05-token-cost-map.md`.
- **ADR relacionados**: ADR-001 (primary — gentle-orch AGENTS.md ya no se carga), ADR-004 (Engram — desduplicación), ADR-007 (MCP — bajo demanda).
- **ID en Evidence Register**: E041, E042, E043, E044.
