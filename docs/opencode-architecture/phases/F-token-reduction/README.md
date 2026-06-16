# Fase F — Reducción Inteligente de Tokens

**Estado:** 📋 PLANNING → ✅ **F0** → ✅ **F1** → ✅ **F2** → ✅ **F3 COMPLETE**  
**Versión:** 1.0 (F0–F3 completados. F4 pendiente de aprobación)  
**Fecha:** 2026-06-16

---

## ¿Qué es Fase F?

Fase F es la fase de reducción inteligente del consumo de contexto (tokens) del pipeline OpenCode/Engram. El objetivo no es "recortar tokens a ciegas", sino **usar el mínimo contexto necesario para mantener o mejorar la calidad del resultado del agente**.

## ¿Por qué existe?

El consumo de contexto del sistema se estima en ~40k tokens fijos por sesión típica. Esto limita:

- Capacidad de procesar tareas largas sin perder contexto por límite de ventana.
- Costo operativo por uso excesivo de tokens.
- Velocidad de respuesta al procesar más datos de los necesarios.
- Escalabilidad para sesiones múltiples o complejas.

## ¿Qué problema resuelve?

1. **Contexto inflado**: se incluye más información de la necesaria para tareas simples.
2. **Duplicación**: el mismo contexto aparece en múltiples fuentes (system prompt, memorias, historial).
3. **Falta de selectividad**: no hay distinción entre contexto crítico y ruido.
4. **Ausencia de modos**: todas las tareas reciben el mismo presupuesto de contexto.

## ¿Qué NO va a hacer Fase F?

- ❌ No va a eliminar memoria persistida.
- ❌ No va a truncar contexto indiscriminadamente.
- ❌ No va a comprometer calidad del agente por ahorro de tokens.
- ❌ No va a modificar DB, schema ni config sin aprobación.
- ❌ No va a tocar el Noise Gate (E6B).
- ❌ No va a romper E6B ni Suite F.
- ❌ No va a mezclar sesiones legacy salvo riesgo documentado.
- ❌ No va a exponer secretos ni datos sensibles.
- ❌ No va a implementar cambios funcionales durante la planificación.

## Estado previo validado

| Validación | Estado | Evidencia |
|:-----------|:------:|:----------|
| E6B Noise Gate | ✅ COMPLETE (T1-T7 PASS) | Session summaries #408-#426 en Engram |
| Suite F mem_context RO | ✅ COMPLETE (F-T1-F-T6 PASS) | Observation #427 en Engram |
| F0 Token Audit Baseline | ✅ COMPLETE | baseline-tokens.md con medición real |
| F1 Context Inventory | ✅ COMPLETE | F1-context-inventory.md + 3 sub-documentos |
| **F2 Context Budget Contract** | ✅ **COMPLETE** | F2-context-budget-contract.md + 14 tareas ejecutadas |
| **F2 Critical Review** | ✅ **COMPLETE** | F2-critical-review.md — 8 hallazgos, veredicto APTO |
| **F3 Execution Strategy** | ✅ **COMPLETE** | F3-execution-strategy.md — 7 tareas (F3-A a F3-G) |
| **F3 Prototypes** | ✅ **QW#5: ~1,184t / QW#1: ~7,070t / QW#4: Validado** | F3-B-skills-diff.md, F3-C-session-result.md, F3-D-selector-result.md |
| **F3 Approval Package** | ✅ **LISTO** | F3-F-approval-package.md — ahorro total: ~8,500–10,200 tokens |
| **Regression Harness** | ✅ **16/16 PASS** | scripts/F-regression-harness.ps1 |
| Store real | ✅ `C:\Users\harry\.engram\engram.db` | DB intacta, 326 observations, 312 user_prompts |
| `.codex/memories_1.sqlite` | Existe (40KB) pero **no se usa** | Engram es el store real |

## Objetivo de reducción

Reducir el consumo fijo de contexto desde ~40k tokens hacia un modo normal de **~8.5k–12k tokens**, con objetivo operativo cercano a **~9.5k**, sin comprometer calidad, seguridad, recuperación de contexto ni estabilidad del sistema.

## Modos de operación objetivo

| Modo | Rango de tokens | Cuándo se usa |
|:----:|:---------------:|---------------|
| Simple | 6k–8.5k | Tareas triviales, consultas rápidas, confirmaciones |
| Normal | 8.5k–12k | Tareas estándar (diseño, implementación, revisión) |
| Arquitectura | 12k–16k | Diseño arquitectónico, cambios multi-módulo |
| Auditoría/Regresión | 16k–22k | Validación completa de suites, regresiones |
| Excepcional | >22k | Solo con justificación explícita documentada |

## Enfoque de contexto inteligente

No se trata de comprimir todo con un algoritmo único. Se trata de **mejorar la selección de qué entra y qué no entra en el contexto activo**:

1. **Por capas**: contexto crítico siempre presente (L0-L1), contexto recuperable bajo demanda (L5).
2. **Por packs**: agrupación lógica de contexto en unidades intercambiables.
3. **Por modo**: el presupuesto de tokens varía según la complejidad de la tarea.
4. **Por ranking**: las memorias no se incluyen todas — se rankean, filtran y deduplican.
5. **Por fallback**: si no hay contexto suficiente, se pide más.

## Progreso de fases

| Sub-fase | Estado | Descripción |
|:--------:|:------:|-------------|
| **F0** — Token Audit Baseline | ✅ **COMPLETE** | ~35k–45k tokens medido y desglosado por fuente. 6 quick wins identificados. |
| **F1** — Context Inventory | ✅ **COMPLETE** | 15 fuentes catalogadas, 7 duplicaciones detectadas, 5 quick wins analizados. |
| **F2** — Context Budget Contract | ✅ **COMPLETE** | Contrato formal de presupuesto + 6 auditorías + alineación gentle-ai. 14 tareas. 22 docs. |
| **F2 Critical Review** | ✅ **COMPLETE** | 8 hallazgos, veredicto APTO con observaciones. Budgets actualizados. |
| **F3 — Execution Strategy** | ✅ **COMPLETE** | 7 tareas (F3-A a F3-G) en 3 bloques. Prototipos de QW#5, QW#1, QW#4. |
| **F3 — QW#5 Skills Block** | ✅ **~1,184 tokens** | Skills compactados: 38 skills, 70% menos caracteres. 3× estimado F2. |
| **F3 — QW#1 Session Compaction** | ✅ **~7,070 tokens** | 3+7+acumulativo+R7. Ahorro neto para sesión típica 30 turns. |
| **F3 — QW#4 Selector** | ✅ **Validado** | Scoring calibrado. Decay recomendado: 0.05/día. |
| **F3 — Regression Harness** | ✅ **16/16 PASS** | Script read-only con 4 gates y 16 tests. |
| **F3 — Approval Package** | ✅ **LISTO** | Ahorro total ~8,500–10,200 tokens. Pendiente aprobación para F4. |
| **F4** — Quick Wins Implementation | 📋 Pendiente aprobación | QW#5 → QW#1 → QW#4 en orden de riesgo creciente. |
| **F5** — Regression Execution | 📋 Pendiente F4 | Ejecutar regression plan completo post-cambios. |
| **F6** — Rollout Controlado | 📋 Pendiente F5 | Feature flag + monitoreo. |

## Documentos de la fase

| Doc | Propósito | Estado |
|:---:|-----------|:------:|
| `README.md` | **Este archivo** — visión general de Fase F | ✅ Actualizado |
| `F0-token-audit-plan.md` | Cómo se hará el baseline | ✅ Plan |
| `baseline-tokens.md` | **F0**: Baseline medido | ✅ **COMPLETE** |
| `F1-context-inventory.md` | **F1**: Inventario de fuentes | ✅ **COMPLETE** |
| `context-source-catalog.md` | **F1**: Catálogo de 15 fuentes | ✅ **COMPLETE** |
| `duplication-map.md` | **F1**: Mapa de duplicaciones | ✅ **COMPLETE** |
| `quick-wins-analysis.md` | **F1**: Quick wins priorizados | ✅ **COMPLETE** |
| **`F2-context-budget-contract.md`** | **F2: Contrato formal de presupuesto por modo** | **✅ COMPLETE** |
| `context-budget-contract.md` | Presupuesto resumido (referencia F2) | ✅ Alineado |
| `context-layers-design.md` | Arquitectura L0–L5 con F1/F2 data | ✅ Actualizado |
| `context-packs-design.md` | 11 packs de contexto | ✅ Actualizado |
| `mem-context-selector-design.md` | Selector con pseudocódigo y scoring | ✅ Actualizado |
| **`tool-schema-demand-loading-audit.md`** | **F2: Auditoría tools** | **✅ COMPLETE** |
| **`session-history-compaction-audit.md`** | **F2: Auditoría session history** | **✅ COMPLETE** |
| **`manager-protocol-compaction-audit.md`** | **F2: Propuesta compactación Manager** | **✅ COMPLETE** |
| **`skills-selective-loading-audit.md`** | **F2: Auditoría skills block** | **✅ COMPLETE** |
| **`gentle-ai-alignment.md`** | **F2: Alineación gentle-ai** | **✅ COMPLETE** |
| **`autonomous-work-report.md`** | **F2: Reporte ejecutivo del bloque** | **✅ COMPLETE** |
| `risk-register.md` | 24 riesgos documentados (F-R01 a F-R24) | ✅ Actualizado |
| `regression-plan.md` | 9 gates, 52 tests | ✅ Actualizado |
| `implementation-roadmap.md` | Secuencia F0–F6 | ✅ Actualizado |
| `decision-log.md` | 30 decisiones registradas (D-F-001 a D-F-030) | ✅ Actualizado |
| **`F2-critical-review.md`** | **F3: Revisión crítica de F2** | **✅ COMPLETE** |
| **`F3-execution-strategy.md`** | **F3: Estrategia de implementación** | **✅ COMPLETE** |
| **`F3-B-skills-diff.md`** | **F3: Prototipo QW#5 (~1,184t)** | **✅ COMPLETE** |
| **`F3-C-session-result.md`** | **F3: Prototipo QW#1 (~7,070t)** | **✅ COMPLETE** |
| **`F3-D-selector-result.md`** | **F3: Prototipo QW#4 (validado)** | **✅ COMPLETE** |
| **`F3-F-approval-package.md`** | **F3: Paquete de aprobación** | **✅ LISTO** |
| `scripts/F-regression-harness.ps1` | **F3: Harness de regresión (16/16 PASS)** | **✅ COMPLETE** |

## Cómo leer esta fase

### Para entender el diseño (F0–F2):
1. Empieza por **este README** para entender el qué y el por qué.
2. Lee **F2-context-budget-contract.md** para el contrato formal de presupuesto.
3. Lee **decision-log.md** para las 30 decisiones registradas.
4. Lee **risk-register.md** para los 24 riesgos documentados.
5. Lee **implementation-roadmap.md** para la secuencia de ejecución.

### Para entender los prototipos (F3):
6. Lee **F2-critical-review.md** para la revisión crítica de F2 (8 hallazgos).
7. Lee **F3-execution-strategy.md** para la estrategia de implementación.
8. Lee **F3-B-skills-diff.md** para el prototipo de QW#5 (~1,184 tokens).
9. Lee **F3-C-session-result.md** para el prototipo de QW#1 (~7,070 tokens).
10. Lee **F3-D-selector-result.md** para el prototipo de QW#4 (selector calibrado).
11. Lee **F3-F-approval-package.md** para el paquete de aprobación.

### Para referencia:
12. Lee **context-layers-design.md** para la arquitectura L0–L5.
13. Lee **context-packs-design.md** para los 11 packs de contexto.
14. Lee **mem-context-selector-design.md** para la lógica de selección.
15. Lee **tool-schema-demand-loading-audit.md** para la auditoría de tools.
16. Lee **session-history-compaction-audit.md** para el diseño de compactación.
17. Lee **manager-protocol-compaction-audit.md** para la propuesta de compactación.
18. Lee **skills-selective-loading-audit.md** para la compactación de skills.
19. Lee **gentle-ai-alignment.md** para la alineación estratégica (profundizada en F3).
20. Lee **regression-plan.md** para las validaciones (9 gates, 52 tests).

---

_Fin de README — Fase F: F0 ✅, F1 ✅, F2 ✅, F3 ✅ (prototipos completados). Pendiente aprobación del approval package para F4. Sin cambios funcionales implementados._
