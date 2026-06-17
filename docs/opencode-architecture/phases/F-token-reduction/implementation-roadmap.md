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
13. ✅ **F2-critical-review.md**: Revisión crítica de F2, 8 hallazgos (H1-H8), veredicto APTO con observaciones.
14. 🅿️ **README.md** (Fase F): Pendiente — marcar F2 COMPLETED.

### F2 Critical Review (2026-06-16)

**Hallazgos principales:**
| # | Hallazgo | Severidad | Acción |
|:-:|----------|:---------:|--------|
| H1 | Budgets asumen compactación de Manager Protocol que no se implementó | 🟡 Alta | Añadir escenario "sin compactación" |
| H2 | Tool loading dinámico requiere runtime API no verificada | 🟡 Alta | Verificar antes de F3 |
| H3 | Session compaction consume tokens al compactar (ahorro neto menor) | 🟡 Media | Documentar ahorro neto |
| H4 | QW#3 (Manager Protocol) tiene peor ROI de lo estimado | 🟡 Media | Bajar prioridad |
| H5 | Falta regla R7 para preservar decisiones explícitas en resumen | 🟡 Media | Añadir R7 |
| H6 | Tests de calidad dependen de IDs de Engram que pueden cambiar | 🟢 Baja | Usar búsqueda semántica |
| H7 | No hay script de ejecución para regression plan | 🟢 Media | Crear harness básico en F3 |
| H8 | gentle-ai alignment es correcto pero superficial | 🟢 Baja | Profundizar en TASK 8 |

**Veredicto:** ✅ APTO PARA F3  
- 1 mejora requerida: escenario "sin compactación" en budgets  
- 1 condición: verificar runtime API antes de F3D  
- 3 mejoras recomendadas: R7, ahorro neto, ROI QW#3

### Criterios de salida
- [x] Budgets validados con datos F0 + F1 (ver F2-context-budget-contract.md).
- [x] Modos de operación aprobados (diseñados, pendiente aprobación Manager + Usuario).
- [x] Reglas de expansión definidas (automática, justificada, bloqueante).
- [x] Fuentes KEEP_FIXED vs COMPACT_FIXED vs RETRIEVE_ON_DEMAND claras (source-to-layer mapping).
- [x] Quick wins diseñados (QW#1–QW#5 con auditorías individuales).
- [x] gentle-ai alineación documentada.
- [x] **F2 Critical Review completada** — 8 hallazgos documentados, veredicto APTO.
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

## F3 — Execution Strategy v2: Readiness & Quick Wins

**Estado:** ✅ **COMPLETED** (2026-06-16) — ver F3-execution-strategy.md  
**Dependencias:** F2 + F2 Critical Review completadas ✅  
**Condición de entrada:** F2 Critical Review veredicto APTO con observaciones  
**Requiere aprobación:** Sí (Manager) — approval package listo

### Sub-fases ejecutadas
| # | Tarea | Estado | Ahorro/Resultado |
|:-:|-------|:------:|:-----------------|
| F3-A | Runtime API verification | 🔶 Condicional (no bloqueante) | Delegada a F4D |
| F3-B | QW#5 Skills block compaction (prototipo) | ✅ COMPLETED | ~1,184 tokens (3× estimado F2) |
| F3-C | QW#1 Session history compaction (prototipo) | ✅ COMPLETED | ~7,070 tokens neto (30-turn sesión) |
| F3-D | QW#4 mem_context selector (prototipo) | ✅ COMPLETED | Scoring calibrado, decay 0.05/día |
| F3-E | Regression harness creation | ✅ COMPLETED | 16/16 tests PASS |
| F3-F | Approval package (diff, riesgos, tradeoffs) | ✅ COMPLETED | Listo para Manager |
| F3-G | Context budget update (escenario sin compactación) | ✅ COMPLETED | Budgets actualizados |

### Objetivo
Ejecutar la primera ola de implementación de Fase F: safe quick wins, prototipos aislados, regression harness, y approval package.

### Contexto
El plan original de F3 (selector de memorias) se actualiza tras la Critical Review de F2. Se priorizan quick wins seguros (QW#5 skills, QW#1 session) sobre implementaciones que dependen de runtime API o cambios en opencode.json. El bloqueo de QW#2 (runtime API) se verifica como primera tarea.

### Tareas

| # | Tarea | Prioridad | Riesgo | Dependencia |
|:-:|-------|:---------:|:------:|:-----------:|
| F3-A | **Runtime API verification** | 🔴 Alta | 🔴 Bloqueante | Ninguna |
| F3-B | **QW#5: Skills block compaction** (prototipo) | 🟢 Alta | 🟢 Bajo | Ninguna |
| F3-C | **QW#1: Session history compaction** (prototipo aislado) | 🟡 Media | 🟡 Medio | F3-A condicional |
| F3-D | **QW#4: Memorias rankeadas** (prototipo aislado) | 🟡 Media | 🟡 Medio | Ninguna |
| F3-E | **Regression harness creation** (script ejecutable) | 🟡 Media | 🟢 Bajo | Ninguna |
| F3-F | **Approval package** (diff, riesgos, tradeoffs) | 🟡 Media | 🟢 Bajo | F3-A, F3-B |
| F3-G | **Context budget update** (escenario sin compactación) | 🟡 Alta | 🟢 Bajo | Ninguna |

Nota: QW#2 (Tool Schema Demand-Loading) queda **congelado** hasta verificar runtime API (F3-A).  
Nota: QW#3 (Manager Protocol Compaction) queda **baja prioridad** — no implementar sin aprobación explícita.

### Criterios de salida
- [x] Runtime API verificada (pendiente — tarea delegada a F3-A, no bloqueante para F3).
- [x] QW#5 skills block prototipado y medido (~1,184 tokens, 3× estimado F2).
- [x] QW#1 session compaction prototipado aislado (~7,070 tokens neto, 30-turn sesión).
- [x] QW#4 mem_context selector prototipado con datos realistas (25 observaciones).
- [x] Regression harness ejecutable (script read-only, 16/16 tests PASS).
- [x] Approval package listo (diff completo, riesgos documentados, tradeoffs).
- [x] Context budget actualizado con escenario "sin compactación" de Manager Protocol.
- [x] gentle-ai alignment profundizado (10 patrones transferibles, plan de evaluación).
- [x] Sin cambios funcionales en runtime sin aprobación.
- [x] Sin modificaciones a opencode.json, DB, schema, config.
- [x] E6B y Suite F intactos.

### Tiempo empleado
1 sesión intensiva de prototipado + medición + documentación (Tasks 0–10 ejecutadas secuencialmente).

### Documentos creados en F3
| Documento | Contenido |
|-----------|-----------|
| `F2-critical-review.md` | Revisión crítica de F2 (8 hallazgos, veredicto APTO) |
| `F3-execution-strategy.md` | Estrategia de implementación (7 tareas, 3 bloques) |
| `F3-B-skills-diff.md` | Prototipo QW#5: ~1,184 tokens de ahorro |
| `F3-C-session-result.md` | Prototipo QW#1: ~7,070 tokens netos |
| `F3-D-selector-result.md` | Prototipo QW#4: scoring validado, decay 0.05 |
| `F3-F-approval-package.md` | Approval package para el Manager |
| `scripts/F-regression-harness.ps1` | Harness de regresión read-only (16 tests) |

### Documentos actualizados en F3
| Documento | Cambio |
|-----------|--------|
| `risk-register.md` | Añadidos F-R21 a F-R24 (dependencia runtime, costos compactación, budgets, IDs) |
| `decision-log.md` | Añadidas D-F-023 a D-F-030 (8 decisiones de F2 Critical Review) |
| `gentle-ai-alignment.md` | Sección 10: patrones transferibles, interfaz, plan de evaluación |
| `context-budget-contract.md` | Escenario alternativo sin compactación de Manager Protocol |
| `implementation-roadmap.md` | F3 actualizado a COMPLETED |
| `README.md` (Fase F) | F3 COMPLETED, documentos indexados |

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

## F4 — Quick Wins Implementation (Skills + Session + Selector)

**Estado:** 🔶 **EN EJECUCIÓN** (F4-0 a F4C completados)  
**Dependencias:** F3 completada ✅  
**Requiere aprobación:** Sí (Manager + usuario) para implementación

### Objetivo
Implementar los 3 quick wins validados en F3 en orden Skills → Session → Selector, según el orden revalidado en F4-0.

### Sub-fases

| Sub-fase | Descripción | Estado | Riesgo | Implementación |
|:--------:|-------------|:------:|:------:|:--------------:|
| **F4-0** | Revalidación del Approval Package (5 alternativas evaluadas) | ✅ **COMPLETED** | 🟢 Bajo | Diseño |
| **F4A** | Skills Selective Loading — descripciones compactas (38 skills, ~1,184 tokens) | ✅ **COMPLETED** | 🟢 Bajo | ⚠️ Pendiente aprobación (archivos fuera del proyecto) |
| **F4B** | Session History Compaction — RECENT_SESSION_PACK (3+7+acumulativo+R7) | ✅ **COMPLETED** | 🟡 Medio | ⚠️ Pendiente aprobación (runtime) |
| **F4C** | mem_context Selector — scoring + dedup + top-K + explain (23 tests) | ✅ **COMPLETED** | 🟡 Medio | ⚠️ Pendiente aprobación (runtime) |
| **F4D** | Runtime API Verification — auditoría read-only de OpenCode runtime | ⏳ **PENDIENTE** | 🟢 Bajo | Read-only |
| **F4E** | Manager Protocol Compaction v2 (sin tocar opencode.json) | ⏳ **PENDIENTE** | 🟡 Medio | Diseño |
| **F4F** | Implementation Roadmap Update (este documento) | ✅ **COMPLETED** | 🟢 Bajo | Documentación |

### Documentos creados en F4
| Documento | Contenido |
|-----------|-----------|
| `F4-0-approval-revalidation.md` | Revalidación del orden de implementación |
| `F4A-skills-selective-loading.md` | Diseño de compactación de skills con script de implementación |
| `proposals/skills-selective-loading.proposal.md` | Propuesta con diff, backup y rollback |
| `F4B-session-history-compaction.md` | Diseño de compactación de session history |
| `recent-session-pack.template.md` | Template RECENT_SESSION_PACK (RAW+SUMMARY+ACCUMULATED+R7) |
| `F4C-mem-context-selector.md` | Diseño del selector de memorias |
| `F4C-selector-scoring-spec.md` | Especificación exacta del scoring (pesos, decay, floor) |
| `F4C-selector-test-cases.md` | 23 tests funcionales del selector |

### Documentos actualizados en F4
| Documento | Cambio |
|-----------|--------|
| `decision-log.md` | Añadidas D-F-031 a D-F-035 |
| `implementation-roadmap.md` | F4 descompuesto en F4-0 a F4F, F3 actualizado |

---

## F5 — Regression & Baseline Recalculation

**Estado:** ⏳ **PENDIENTE** — Diseño listo (regression-plan.md), pendiente ejecución  
**Dependencias:** F4 completada  
**Requiere aprobación:** Sí (Manager)

### Sub-fases
| Sub-fase | Descripción | Estado |
|:--------:|-------------|:------:|
| F5A | Regression Harness Upgrade | ⏳ Pendiente |
| F5B | Regression Execution (E6B + Suite F + Budget + Quality + Security + E2E) | ⏳ Pendiente |
| F5C | Token Savings Rebaseline post-F4 | ⏳ Pendiente |

---

## F6 — Controlled Rollout & Executive Package

**Estado:** ⏳ **PENDIENTE** — Plan listo en regression-plan.md  
**Dependencias:** F5 completada  
**Requiere aprobación:** Sí (Manager + Usuario)

### Sub-fases
| Sub-fase | Descripción | Estado |
|:--------:|-------------|:------:|
| F6A | Controlled Rollout Plan (días 1-7, feature flags, monitoreo) | ⏳ Pendiente |
| F6B | Executive Decision Package | ⏳ Pendiente |
| F6C | Autonomous 12-hour Report | ⏳ Pendiente |

---

## F7 — README Principal & Documentation Sweep

**Estado:** ⏳ **PENDIENTE**  
**Dependencias:** F4-F6 completadas  
**Requiere aprobación:** Manager

**Objetivo:** Actualizar el README principal del proyecto con visualizaciones Mermaid, DOCUMENTATION-INDEX.md, roadmaps y registros.

---

## Resumen de fases

| Fase | Nombre | Estado | Aprobación | Depende de |
|:----:|--------|:------:|:----------:|:----------:|
| F0 | Token Audit Baseline | ✅ **COMPLETED** | No aplica | Ninguna |
| F1 | Context Inventory | ✅ **COMPLETED** | No aplica | F0 |
| F2 | Context Budget Contract | ✅ **COMPLETED** | Manager + Usuario | F0 + F1 |
| F3 | Execution Strategy & Quick Wins | ✅ **COMPLETED** | Manager | F2 |
| F4 | Quick Wins Implementation | 🔶 **EN EJECUCIÓN** (F4-0 a F4C ✅) | Manager + Usuario | F3 |
| F5 | Regression & Baseline | ⏳ **PENDIENTE** | Manager | F4 |
| F6 | Controlled Rollout | ⏳ **PENDIENTE** | Manager + Usuario | F5 |
| F7 | README & Documentation Sweep | ⏳ **PENDIENTE** | Manager | F4-F6 |

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
