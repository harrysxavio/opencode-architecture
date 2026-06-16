# Fase F — Reducción Inteligente de Tokens

**Estado:** 📋 PLANNING  
**Versión:** 0.1 (planificación, sin implementación funcional)  
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

| Fase | Estado | Evidencia |
|:----:|:------:|:----------|
| E6B Noise Gate | ✅ COMPLETE (T1-T7 PASS) | Session summaries #408-#426 en Engram |
| Suite F mem_context RO | ✅ COMPLETE (F-T1-F-T6 PASS) | Observation #427 en Engram |
| Store real | ✅ `C:\Users\harry\.engram\engram.db` | DB intacta |
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

## Documentos de la fase

| Doc | Propósito |
|:---:|-----------|
| `README.md` | **Este archivo** — visión general de Fase F |
| `F0-token-audit-plan.md` | Cómo se hará el baseline de ~40k y de dónde vienen |
| `context-budget-contract.md` | Presupuesto por capa y modo, reglas de expansión |
| `context-layers-design.md` | Arquitectura L0 a L5: qué va en cada capa |
| `mem-context-selector-design.md` | Cómo se seleccionan, rankean y filtran memorias |
| `context-packs-design.md` | Packs de contexto: estructura, fuente, fallback |
| `risk-register.md` | Riesgos de la reducción y sus mitigaciones |
| `regression-plan.md` | Validaciones post-Fase F |
| `implementation-roadmap.md` | Secuencia F0-F6 para implementar después |
| `decision-log.md` | Decisiones tomadas durante la planificación |

## Cómo leer esta fase

1. Empieza por **este README** para entender el qué y el por qué.
2. Lee **F0-token-audit-plan.md** para entender de dónde vienen los tokens.
3. Lee **context-layers-design.md** para la arquitectura conceptual.
4. Lee **context-budget-contract.md** para los límites por modo.
5. Lee **mem-context-selector-design.md** para la lógica de selección.
6. Lee **context-packs-design.md** para los packs concretos.
7. Lee **risk-register.md** para los riesgos y mitigaciones.
8. Lee **regression-plan.md** para las validaciones post-implementación.
9. Lee **implementation-roadmap.md** para la secuencia de ejecución.
10. Lee **decision-log.md** para el registro de decisiones.

---

_Fin de README — Fase F en estado PLANNING. Sin cambios funcionales implementados._
