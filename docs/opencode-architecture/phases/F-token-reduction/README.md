# Fase F — Reducción Inteligente de Tokens

**Estado:** 📋 PLANNING → ✅ **F0 COMPLETE** → ✅ **F1 COMPLETE**  
**Versión:** 0.2 (F0 completado, F1 completado, F2 pendiente)  
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
| **F2** — Context Budget Contract | 📋 Pendiente | Convertir hallazgos de F1 en contrato formal de presupuesto por modo |
| **F3** — mem_context Selector | 📋 Diseñado | Ranking + scoring + top-k + dedup |
| **F4** — Context Packs | 📋 Diseñado | 8 packs lógicos de contexto |
| **F5** — Regression Plan | 📋 Diseñado | 6 gates obligatorios |
| **F6** — Rollout Controlado | 📋 Planificado | Feature flag + monitoreo |

## Documentos de la fase

| Doc | Propósito | Estado |
|:---:|-----------|:------:|
| `README.md` | **Este archivo** — visión general de Fase F | ✅ Actualizado |
| `F0-token-audit-plan.md` | Cómo se hará el baseline de ~40k y de dónde vienen | ✅ Plan |
| `baseline-tokens.md` | **F0**: Baseline medido con desglose real por fuente | ✅ **COMPLETE** |
| `F1-context-inventory.md` | **F1**: Inventario completo de fuentes, clasificación y análisis | ✅ **COMPLETE** |
| `context-source-catalog.md` | **F1**: Catálogo de 15 fuentes con metadata comparable | ✅ **COMPLETE** |
| `duplication-map.md` | **F1**: Mapa de 7 duplicaciones con impacto y recomendación | ✅ **COMPLETE** |
| `quick-wins-analysis.md` | **F1**: 5 quick wins analizados en profundidad | ✅ **COMPLETE** |
| `context-budget-contract.md` | Presupuesto por capa y modo, reglas de expansión | 📋 Diseñado (pre-F1) |
| `context-layers-design.md` | Arquitectura L0 a L5: qué va en cada capa | 📋 Diseñado |
| `mem-context-selector-design.md` | Cómo se seleccionan, rankean y filtran memorias | 📋 Diseñado |
| `context-packs-design.md` | Packs de contexto: estructura, fuente, fallback | 📋 Diseñado |
| `risk-register.md` | Riesgos de la reducción y sus mitigaciones | 📋 Diseñado |
| `regression-plan.md` | Validaciones post-Fase F | 📋 Diseñado |
| `implementation-roadmap.md` | Secuencia F0-F6 para implementar después | ✅ Actualizado |
| `decision-log.md` | Decisiones tomadas durante la planificación | ✅ Actualizado |

## Cómo leer esta fase

1. Empieza por **este README** para entender el qué y el por qué.
2. Lee **baseline-tokens.md** (F0) para los datos medidos reales.
3. Lee **F1-context-inventory.md** para el inventario de fuentes.
4. Lee **context-source-catalog.md** para los detalles de cada fuente.
5. Lee **duplication-map.md** para entender las duplicaciones.
6. Lee **quick-wins-analysis.md** para los quick wins priorizados.
7. Lee **context-layers-design.md** para la arquitectura conceptual.
8. Lee **context-budget-contract.md** para los límites por modo.
9. Lee **mem-context-selector-design.md** para la lógica de selección.
10. Lee **context-packs-design.md** para los packs concretos.
11. Lee **risk-register.md** para los riesgos y mitigaciones.
12. Lee **regression-plan.md** para las validaciones post-implementación.
13. Lee **implementation-roadmap.md** para la secuencia de ejecución.
14. Lee **decision-log.md** para el registro de decisiones.

---

_Fin de README — Fase F: F0 COMPLETE, F1 COMPLETE, F2 pendiente. Sin cambios funcionales implementados._
