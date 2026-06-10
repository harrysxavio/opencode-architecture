# Baseline T8 — Token Baseline

## Input usado

```
Dime 1 frase.
```

## Fecha/hora

2026-06-09 ~22:34 — Ejecutado en sesión limpia (nuevo chat OpenCode, sin contexto previo).

## Resultado observado

**✅ EJECUTADO en sesión limpia. Resultado funcional VALIDADO. Tokens reales NO DISPONIBLES.**

| Aspecto | Detalle |
|---------|---------|
| Sesión limpia | ✅ Sí — nuevo chat OpenCode |
| Input exacto | `"Dime 1 frase."` |
| Output exacto | `"Una arquitectura limpia se defiende sola; el código no necesita comentarios cuando los nombres cuentan la historia."` |
| Tiempo aproximado | ~3 segundos |
| Clasificación del agente | Tiny — "one clear answer, no file changes, no ambiguity" |

## Métricas

| Métrica | Valor | Estado | Evidencia |
|---------|-------|--------|-----------|
| agente que respondió | **Manager** | ✅ VALIDADO | Output visible del runtime. Clasificación Tiny explícita. |
| tiempo de respuesta | ~3 segundos | ✅ VALIDADO | Medición manual |
| tokens input reales | — | ❌ NO DISPONIBLE | El runtime no expone conteo de tokens |
| tokens output reales | — | ❌ NO DISPONIBLE | El runtime no expone conteo de tokens |
| contexto fijo estimado | ~18,500–22,000 | ⚠️ INFERIDO | Basado en suma de fuentes conocidas (ver 00-executive-summary.md) |
| tools activadas | **Ninguna** | ✅ VALIDADO | Sin tool calls observables |
| MCP activados | **Ninguno** | ✅ VALIDADO | Sin MCP visibles |
| memoria consultada | **No** | ✅ VALIDADO | Sin acceso a memoria visible |
| memoria escrita | **No** | ✅ VALIDADO | Sin escritura de memoria visible |
| skills cargadas | **Ninguna** | ✅ VALIDADO | Sin skills cargadas |
| subagentes activados | **Ninguno** | ✅ VALIDADO | Sin subagentes visibles |

## Estimación de contexto fijo (INFERIDA)

| Fuente | Tokens estimados | Nota |
|--------|-----------------|------|
| System prompt base | ~3,000 | Presente en toda sesión |
| AGENTS.md activo | ~12,000–19,000 | Depende de cuál agente se active |
| Available skills list | ~3,000 | Variable según proyecto |
| Engram protocol inline | ~2,500 | Inyectado por plugin |
| Design skills protocol | ~1,500 | En Manager prompt |
| **Rango** | **~18,500–22,000** | **INFERIDO** — pendiente de telemetría runtime |

## Línea de baseline

| Concepto | Valor | Estado |
|----------|-------|--------|
| Estimación anterior conflictiva | ~29,000 | ❌ INCORRECTA — asumía ambos AGENTS.md simultáneos |
| Estimación corregida preliminar | ~18,500–22,000 | ⚠️ INFERIDO |
| Baseline T8 real | Pendiente de telemetría runtime | ❌ NO DISPONIBLE |
| Objetivo estratégico futuro | ~8,500–9,500 | 📐 META |

## Qué se activó

- **Manager**: responde directo, clasifica como Tiny.
- **Ninguna tool**, **ningún MCP**, **ninguna skill**, **ningún subagente**, **ninguna memoria**.

## Qué NO se activó

- ❌ gentle-orchestrator — no fue invocado.
- ❌ Memoria (lectura o escritura) — no se consultó ni escribió.
- ❌ MCP — ningún MCP externo activado.
- ❌ Skills — ningún skill cargado.
- ❌ Subagentes — ninguna delegación.
- ❌ SDD Pipeline — no se activó.
- ❌ Herramientas innecesarias — tool surface no se tocó.

## Conclusión

**T8: VALIDADO como baseline funcional/comportamental.**

Para un request Tiny en sesión limpia:

1. **Manager responde directo.** ✅
2. **No se activa gentle-orchestrator.** ✅
3. **No se activa memoria visible.** ✅
4. **No se activa MCP visible.** ✅
5. **No se cargan skills visibles.** ✅
6. **No se llaman subagentes.** ✅
7. **No entra a SDD.** ✅
8. **No hay sobreorquestación visible.** ✅

**Limitación**: tokens reales NO DISPONIBLES. El runtime no expone conteo de tokens. Toda métrica de tokens sigue siendo INFERIDA hasta tener telemetría runtime.

## Riesgos

- Sin telemetría runtime, la optimización de tokens (Fase F) dependerá de estimaciones, no de mediciones.
- El comportamiento de request Tiny está validado como limpio. Requests más complejos (Medium, Large, SDD) pueden activar más componentes.
- No hay evidencia de que el conteo de tokens sea accesible sin instrumentación del runtime.

## Próxima acción

- ✅ T8 completado como baseline funcional.
- Usar este baseline como referencia para Fase C (tests de flujo).
- Si en el futuro se obtiene telemetría runtime, actualizar con tokens reales.
