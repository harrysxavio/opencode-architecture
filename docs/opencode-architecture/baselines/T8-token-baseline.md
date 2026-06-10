# Baseline T8 — Token Baseline

## Input usado

**Esperado:** `"Dime 1 frase."`
**Ejecutado:** Pendiente de ejecución con input exacto. El reporte actual documenta la metodología y estimaciones basadas en la configuración conocida.

## Fecha/hora

2026-06-09 — Reporte preparado en Fase B1. Ejecución pendiente.

## Resultado observado

⚠️ **NO EJECUTADO con input exacto.** La ejecución requiere que el usuario envíe "Dime 1 frase" como request independiente para medir el overhead mínimo del sistema sin contaminación de contexto.

## Metodología propuesta para la ejecución

1. Usuario envía: `"Dime 1 frase."`
2. Capturar timestamp de inicio.
3. Observar comportamiento del agente: tools, MCP, memoria, skills.
4. Capturar timestamp de respuesta completa.
5. Documentar toda tool call observada.
6. Si el runtime expone conteo de tokens, registrarlo. Si no, estimar con método documentado.

## Métricas

| Métrica | Valor | Estado | Evidencia |
|---------|-------|--------|-----------|
| agente que respondió | **Manager** (esperado) | NO VALIDADO | Pendiente de confirmación runtime |
| tiempo de respuesta | — | NO DISPONIBLE | Pendiente de medición |
| tokens input reales | — | NO DISPONIBLE | El runtime no expone conteo de tokens |
| tokens output reales | — | NO DISPONIBLE | El runtime no expone conteo de tokens |
| contexto fijo estimado | ~18,500–22,000 | INFERIDO | Basado en suma de fuentes conocidas (ver 00-executive-summary.md) |
| tools activadas | — | NO VALIDADO | Pendiente de observación |
| MCP activados | — | NO VALIDADO | Pendiente de observación |
| memoria consultada | — | NO VALIDADO | Pendiente de observación |
| memoria escrita | — | NO VALIDADO | Pendiente de observación |
| skills cargadas | — | NO VALIDADO | Pendiente de observación |

## Estimación de contexto fijo (INFERIDA — pendiente de medición)

| Fuente | Tokens estimados | Nota |
|--------|-----------------|------|
| System prompt base | ~3,000 | Presente en toda sesión |
| AGENTS.md activo | ~12,000–19,000 | Depende de cuál agente se active |
| Available skills list | ~3,000 | Variable según proyecto |
| Engram protocol inline | ~2,500 | Inyectado por plugin |
| Design skills protocol | ~1,500 | En Manager prompt |
| **Rango** | **~18,500–22,000** | **INFERIDO** — pendiente de medición real |

> ⚠️ **No usar 29,000 como baseline.** La estimación de 29k asume ambos AGENTS.md siempre activos, lo cual es incorrecto (solo UN agente responde por sesión).

## Qué se activó

Pendiente de observación.

## Qué NO se activó

Pendiente de observación.

## Conclusión

El Test 8 requiere ejecución con el input exacto para establecer baseline real. Este documento prepara la metodología y el formato. La ejecución tomará < 30 segundos cuando el usuario envía "Dime 1 frase."

## Riesgos

- El contexto de la sesión actual (Fase B1) puede contaminar la medición. Ejecutar en sesión limpia o al inicio de una nueva sesión.
- Si el runtime no expone tokens, toda métrica de tokens será INFERIDA, no VALIDADA.

## Próxima acción

Usuario envía: `"Dime 1 frase."` → Capturar métricas → Actualizar este reporte.
