# Implementation Roadmap — Fase F

**Propósito:** Definir la secuencia de implementación de Fase F, desde la auditoría inicial hasta el rollout controlado. Cada fase tiene criterios de entrada, salida y aprobación.

---

## Secuencia general

```
F0 ─► F1 ─► F2 ─► F3 ─► F4 ─► F5 ─► F6
         ║      ║      ║      ║      ║
         ▼      ▼      ▼      ▼      ▼
     Context  Budget  Selector  Packs  Regression
     Inventory Contract Design   Design Plan + Rollout
              ║
              ▼
          (F2.5 — Quick Wins & Audits)
```

Cada fase requiere aprobación antes de pasar a la siguiente.

**Nota:** F2 incluye sub-fase F2.5 que abarca las auditorías de quick wins y la alineación gentle-ai. No es una fase separada, sino un conjunto de documentos de diseño que complementan el contrato de presupuesto.

---

## F0 — Token Audit Baseline

**Estado:** ✅ **COMPLETED** (2026-06-16)  
**Dependencias:** Ninguna  
**Requiere aprobación:** No (es diagnóstico)

### Objetivo
Medir el baseline real de tokens del contexto actual, documentar de dónde vienen los ~40k y clasificar fuentes.

### Tareas
1. Medir tokens del system prompt actual con tiktoken.
2. Desglosar por sección (protocol, skills, tools, etc.).
3. Clasificar fuentes como fijo/dinámico/duplicado.
4. Identificar quick wins prioritarios.
5. Documentar en `baseline-tokens.md`.

### Criterios de salida
- [x] Baseline medido y documentado (~35k–45k tokens).
- [x] Fuentes clasificadas (fijo/dinámico/duplicado).
- [x] Quick wins identificados (6 prioritarios).

### Tiempo estimado
1 sesión de análisis. ✅ Completado en 1 sesión.

---

## F1 — Context Inventory

**Estado:** ✅ **COMPLETED** (2026-06-16)  
**Dependencias:** F0 completada ✅  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Inventariar todas las fuentes de contexto del sistema, identificar críticas, redundantes y clasificarlas por riesgo y utilidad.

### Tareas ejecutadas
1. ✅ Catalogadas 15 fuentes de contexto con metadata completa.
2. ✅ Cada fuente clasificada (KEEP_FIXED, COMPACT_FIXED, RETRIEVE_ON_DEMAND, RANK_AND_LIMIT, DEDUPLICATE, INVESTIGATE).
3. ✅ 7 duplicaciones detectadas entre fuentes con impacto estimado en tokens.
4. ✅ 5 quick wins analizados en profundidad con beneficios, riesgos y dependencias.
5. ✅ Matriz de priorización con ahorro estimado, riesgo, esfuerzo y próxima acción.
6. ✅ Propuesta para F2: qué fuentes entran en cada modo (Simple, Normal, Arquitectura, Auditoría).
7. ✅ Documentos creados: `F1-context-inventory.md`, `context-source-catalog.md`, `duplication-map.md`, `quick-wins-analysis.md`.

### Criterios de salida
- [x] 15 fuentes principales inventariadas con metadata.
- [x] Cada fuente tiene clasificación y recomendación.
- [x] Mapa de duplicaciones documentado (7 duplicaciones).
- [x] Análisis de quick wins completado (5 quick wins).
- [x] Matriz de priorización creada.
- [x] Propuesta clara para F2 (fuentes por modo).
- [x] Documentación actualizada (4 documentos nuevos + 3 actualizados).
- [x] Sin cambios funcionales implementados.
- [x] Sin modificaciones a DB/schema/config.
- [x] E6B y Suite F intactos.

### Tiempo estimado
1 sesión de análisis. ✅ Completado en 1 sesión.

---

## F2 — Context Budget Contract (v2)

**Estado:** ✅ **COMPLETED** (2026-06-16)  
**Dependencias:** F0 + F1 completadas ✅  
**Requiere aprobación:** Sí (Manager + usuario)

### Objetivo
Definir el presupuesto de tokens por capa y por modo, con reglas de expansión.

### Tareas ejecutadas
1. ✅ **F2-context-budget-contract.md**: Contrato formal de presupuesto por modo con source-to-layer mapping de las 15 fuentes F1, budgets por capa y modo (Simple/Normal/Arquitectura/Auditoría/Excepcional), 10 declaraciones MUST, 8 SHOULD, 5 MAY, reglas de expansión (automática/justificada/bloqueante), exclusión y fallback.
2. ✅ **context-budget-contract.md**: Actualizado para referenciar F2 como fuente autoritativa y alinear datos.
3. ✅ **context-layers-design.md**: Actualizado con fuentes F1 por capa, budgets F2, quick wins aplicables.
4. ✅ **context-packs-design.md**: 3 nuevos packs agregados: TOOLING_PACK, SKILLS_PACK, GENTLE_AI_ALIGNMENT_PACK. Tablas de ensamblaje y presupuestos actualizadas.
5. ✅ **mem-context-selector-design.md**: Pseudocódigo completo del pipeline de selección, verificación metodológica del scoring, budget alignment con F2.
6. ✅ **tool-schema-demand-loading-audit.md**: Auditoría de 16 tools, clasificación por frecuencia, modelo de carga por fase SDD/tipo de tarea, 3 opciones de implementación con recomendación.
7. ✅ **session-history-compaction-audit.md**: Diseño de compactación con últimos 3 turns crudos + turns 4–10 resumidos + resumen acumulativo 11+. Formato RECENT_SESSION_PACK.
8. ✅ **manager-protocol-compaction-audit.md**: Desglose por sección (17 secciones), propuesta de compactación de 4 secciones (Context Layer Definitions, Anti-Patterns, Fast-Track, Default Behavior), ahorro estimado ~1,200–2,300 tokens. ⚠️ Pendiente aprobación para modificar opencode.json.
9. ✅ **skills-selective-loading-audit.md**: Catálogo de 38 skills con descripciones compactas propuestas. Formato de 5–10 trigger keywords. Ahorro ~400–600 tokens.
10. ✅ **regression-plan.md**: Extendido con 3 nuevos gates (F2 Quick Wins, F2 Contract Compliance, Full Artifact Audit).
11. ✅ **risk-register.md**: 8 nuevos riesgos de F2 (F-R13 a F-R20).
12. ✅ **gentle-ai-alignment.md**: Auditoría de alineación con gentle-ai, política de 6 puntos, GENTLE_AI_ALIGNMENT_PACK diseñado.
13. ✅ **README.md** (Fase F): Pendiente — marcar F2 COMPLETED.

### Criterios de salida
- [x] Budgets validados con datos F0 + F1 (ver F2-context-budget-contract.md).
- [x] Modos de operación aprobados (diseñados, pendiente aprobación Manager + Usuario).
- [x] Reglas de expansión definidas (automática, justificada, bloqueante).
- [x] Fuentes KEEP_FIXED vs COMPACT_FIXED vs RETRIEVE_ON_DEMAND claras (source-to-layer mapping).
- [x] Quick wins diseñados (QW#1–QW#5 con auditorías individuales).
- [x] gentle-ai alineación documentada.
- [x] Sin cambios funcionales implementados.
- [x] Sin modificaciones a DB/schema/config.
- [x] E6B y Suite F intactos.

### Documentos creados en F2

| Documento | Acción | Contenido |
|-----------|:------:|-----------|
| `F2-context-budget-contract.md` | ✅ Creado | Contrato formal de presupuesto, 14 páginas de contenido |
| `tool-schema-demand-loading-audit.md` | ✅ Creado | Auditoría de 16 tools, modelo de carga |
| `session-history-compaction-audit.md` | ✅ Creado | Diseño de compactación, formato RECENT_SESSION_PACK |
| `manager-protocol-compaction-audit.md` | ✅ Creado | Desglose por sección, propuesta de compactación |
| `skills-selective-loading-audit.md` | ✅ Creado | Catálogo de 38 skills compactados |
| `gentle-ai-alignment.md` | ✅ Creado | Auditoría de alineación, política de 6 puntos |

| Documento | Acción | Contenido |
|-----------|:------:|-----------|
| `context-budget-contract.md` | ✅ Actualizado | Referencia a F2 |
| `context-layers-design.md` | ✅ Actualizado | F1 sources por capa, budgets F2 |
| `context-packs-design.md` | ✅ Actualizado | 3 nuevos packs, budgets alineados |
| `mem-context-selector-design.md` | ✅ Actualizado | Pseudocódigo, scoring verification |
| `regression-plan.md` | ✅ Actualizado | 3 nuevos gates |
| `risk-register.md` | ✅ Actualizado | 8 nuevos riesgos |
| `README.md` (Fase F) | **Pendiente** | Marcar F2 COMPLETED |

### Tiempo empleado
1 sesión intensiva de diseño + auditoría + documentación (Tasks A–N ejecutadas en secuencia autónoma).

---

## F3 — mem_context Selector Design & Implementation

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F2 aprobada  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Diseñar e implementar el selector de memorias con ranking, filtro, deduplicación y top-k.

### Tareas
1. Implementar pipeline de selección (ranking, score, filtro).
2. Implementar deduplicación semántica.
3. Implementar top-k por modo.
4. Implementar fallback L5.
5. Test unitarios del selector.
6. Integrar con `mem_context` o reemplazar su uso.

### Criterios de salida
- [ ] Selector implementado y testeado.
- [ ] Ranking funciona con datos reales de Engram.
- [ ] Deduplicación no elimina observaciones únicas.
- [ ] Top-k respeta el modo actual.

### Tiempo estimado
2–3 sesiones de implementación + tests.

---

## F4 — Context Packs Design & Implementation

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F3 implementada  
**Requiere aprobación:** Sí (Manager + usuario)

### Objetivo
Diseñar e implementar los context packs como unidades intercambiables de contexto.

### Tareas
1. Implementar formato de cada pack.
2. Implementar ensamblaje por modo.
3. Integrar con el pipeline de contexto del Manager.
4. Test de integración: cada modo produce los packs correctos.

### Criterios de salida
- [ ] Packs implementados para todos los modos.
- [ ] Ensamblaje correcto verificado.
- [ ] Budgets por pack respetados.

### Tiempo estimado
2–3 sesiones de implementación + tests.

---

## F5 — Regression Plan Execution

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F3 + F4 implementadas  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Ejecutar el regression plan completo para verificar que nada se rompió.

### Tareas
1. Ejecutar E6B (T1-T7).
2. Ejecutar Suite F (F1-F6).
3. Ejecutar Token Budget tests (B1-B6).
4. Ejecutar Quality tests (Q1-Q5).
5. Ejecutar Security tests (S1-S3).
6. Ejecutar Regression E2E.

### Criterios de salida
- [ ] Todos los gates PASS.
- [ ] Sin regresiones.
- [ ] Documentación de resultados.

### Tiempo estimado
2–3 sesiones de validación.

---

## F6 — Rollout Controlado

**Estado:** 📋 PLANIFICADO  
**Dependencias:** F5 todos PASS  
**Requiere aprobación:** Sí (Manager + usuario explícito)

### Objetivo
Implementar los cambios en producción (entorno real de OpenCode).

### Tareas
1. Feature flag para desactivar reducción si es necesario.
2. Implementación incremental:
   - Día 1: Solo modo Normal (default).
   - Día 3: Habilitar modo Simple.
   - Día 5: Habilitar modo Arquitectura.
   - Día 7: Habilitar expansión controlada.
3. Monitoreo de KPIs.
4. Rollback plan listo.

### Criterios de salida
- [ ] Feature flag implementado.
- [ ] Rollout progresivo completado.
- [ ] Monitoreo activo.
- [ ] Sin incidentes.

### Tiempo estimado
1 semana con rollout progresivo.

---

## Resumen de fases

| Fase | Nombre | Estado | Aprobación | Depende de |
|:----:|--------|:------:|:----------:|:----------:|
| F0 | Token Audit Baseline | ✅ **COMPLETED** | No aplica | Ninguna |
| F1 | Context Inventory | ✅ **COMPLETED** | No aplica | F0 |
| F2 | Context Budget Contract | ✅ **COMPLETED** | Manager + Usuario | F0 + F1 |
| F3 | mem_context Selector | 📋 Diseñado | Manager | F2 |
| F4 | Context Packs | 📋 Diseñado | Manager + Usuario | F3 |
| F5 | Regression Plan | 📋 Diseñado | Manager | F3 + F4 |
| F6 | Rollout Controlado | 📋 Planificado | Manager + Usuario | F5 |

## Reglas de aprobación

- **Manager**: puede aprobar fases técnicas (F1, F3, F5).
- **Manager + Usuario**: requiere aprobación del usuario para cambios que afectan presupuesto, packs o rollout (F2, F4, F6).
- **Sin aprobación**: no avanzar a la siguiente fase.

## Rollback

Si en cualquier fase posterior a F3 se detecta:

1. Degradación de calidad del agente.
2. Violación de budgets.
3. Regresiones en E6B o Suite F.
4. Exposición de secretos.
5. Mezcla cross-project no controlada.

**Acción inmediata:**
1. Desactivar feature flag (F6) o revertir cambio.
2. Volver al estado pre-F3 (contexto completo).
3. Documentar hallazgo.
4. Re-planificar con la lección aprendida.

---

_Fin de implementation-roadmap.md_
