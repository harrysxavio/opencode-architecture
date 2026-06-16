# Fase F — Reducción Inteligente de Tokens

**Estado:** 📋 PLANNING → ✅ **F0 COMPLETE** → ✅ **F1 COMPLETE** → ✅ **F2 COMPLETE**  
**Versión:** 1.0 (F0–F2 completados. F3 pendiente de aprobación)  
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
| **F0** — Token Audit Baseline | ✅ **COMPLETE** | ~35k–45k tokens medido y desglosado por fuente. 6 quick wins identificados. Duplicación Manager/AGENTS.md confirmada. [Baseline](baseline-tokens.md) |
| **F1** — Context Inventory | ✅ **COMPLETE** | 15 fuentes catalogadas, 7 duplicaciones detectadas, 5 quick wins analizados, matriz de priorización, propuesta para F2. [Inventario](F1-context-inventory.md) |
| **F2** — Context Budget Contract | ✅ **COMPLETE** | Contrato formal de presupuesto + 6 auditorías de quick wins + alineación gentle-ai. 14 tareas ejecutadas. 22 documentos totales. |
| **F3** — mem_context Selector | 📋 Diseñado | Ranking + scoring + top-k + dedup. Pendiente aprobación F2. |
| **F4** — Context Packs | 📋 Diseñado | 11 packs lógicos de contexto. Pendiente F3. |
| **F5** — Regression Plan | 📋 Diseñado | 9 gates obligatorios (52 tests). Pendiente F3+F4. |
| **F6** — Rollout Controlado | 📋 Planificado | Feature flag + monitoreo. Pendiente F5. |

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
| `risk-register.md` | 20 riesgos documentados | ✅ Actualizado |
| `regression-plan.md` | 9 gates, 52 tests | ✅ Actualizado |
| `implementation-roadmap.md` | Secuencia F0–F6 | ✅ Actualizado |
| `decision-log.md` | 22 decisiones registradas | ✅ Actualizado |

## Cómo leer esta fase

1. Empieza por **este README** para entender el qué y el por qué.
2. Lee **baseline-tokens.md** (F0) para los datos medidos reales.
3. Lee **F1-context-inventory.md** para el inventario de fuentes.
4. Lee **context-source-catalog.md** para los detalles de cada fuente.
5. Lee **duplication-map.md** para entender las duplicaciones.
6. Lee **quick-wins-analysis.md** para los quick wins priorizados.
7. Lee **F2-context-budget-contract.md** para el contrato formal de presupuesto.
8. Lee **context-layers-design.md** para la arquitectura conceptual actualizada.
9. Lee **context-packs-design.md** para los 11 packs concretos.
10. Lee **mem-context-selector-design.md** para la lógica de selección.
11. Lee **tool-schema-demand-loading-audit.md** para la auditoría de tools.
12. Lee **session-history-compaction-audit.md** para el diseño de compactación.
13. Lee **manager-protocol-compaction-audit.md** para la propuesta de compactación.
14. Lee **skills-selective-loading-audit.md** para la compactación de skills.
15. Lee **gentle-ai-alignment.md** para la alineación estratégica.
16. Lee **risk-register.md** para los riesgos y mitigaciones (20 riesgos).
17. Lee **regression-plan.md** para las validaciones (9 gates, 52 tests).
18. Lee **implementation-roadmap.md** para la secuencia de ejecución.
19. Lee **decision-log.md** para el registro de decisiones (22 decisiones).
20. Lee **autonomous-work-report.md** para el reporte ejecutivo del bloque.

---

_Fin de README — Fase F: F0 COMPLETE, F1 COMPLETE, F2 pendiente. Sin cambios funcionales implementados._
