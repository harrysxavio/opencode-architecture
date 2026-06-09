# ADR-009: Estrategia de Observabilidad y Testing

## Estado

**Propuesto** — Se requiere Fase B-Security y B0 antes de implementar.

> ⚠️ **Fase B0**: La validación P3 confirmó que no hay evidencia de session summaries ejecutándose. La validación P4 (config merge) no se pudo resolver. Estos hallazgos refuerzan la necesidad de observabilidad, pero primero deben rotarse los secretos (B-Security).

## Contexto

Actualmente el sistema **no tiene observabilidad ni tests de flujo**.

- No hay logging de: qué agente respondió, qué tools se usaron, cuántos tokens se consumieron, cuánto tiempo tomó cada request.
- No hay tests automatizados que validen el comportamiento del flujo agentic.
- Las decisiones de optimización se basan en estimaciones, no en mediciones.
- Los riesgos arquitectónicos (doble primary, memoria vacía, contexto fijo) no tienen validación empírica.

**Principio**: "Medir antes de optimizar" — no se puede mejorar lo que no se mide.

## Decisión

**Agregar observabilidad mínima antes de cualquier cambio arquitectónico. Crear tests de flujo reproducibles.**

### Observabilidad mínima

Para cada request capturar:

| Métrica | Fuente | Destino |
|---------|--------|---------|
| request_id | Generado por plugin | Log |
| agent_selected | Runtime | Log |
| manager_decision (si aplica) | Manager | Log |
| tools_called | Plugin hook | Log |
| mcp_called | Plugin hook | Log |
| memory_read (sí/no) | Plugin hook | Log |
| memory_written (sí/no) | Plugin hook | Log |
| context_sources | System prompt | Log |
| estimated_context_tokens | Plugin hook | Log |
| execution_time_ms | Plugin hook | Log |
| final_response_summary | Truncado | Log |

### Tests de flujo

8 escenarios definidos en `13-validation-test-plan.md`:

| Test | Input | Lo que valida |
|------|-------|---------------|
| T1 Simple | "Hola" | Overhead mínimo |
| T2 Memoria | "Continúa con..." | Retrieval de memoria |
| T3 Documento | "Busca en docs..." | Lectura de docs versionados |
| T4 MCP | "Consulta Zod" | Tool routing |
| T5 SDD | "Diseña cambio..." | Pipeline SDD |
| T6 Ruidoso | Multi-tema | Clasificación |
| T7 Contradicción | "Cambia decisión" | Invalidation de memoria |
| T8 Baseline | "1 frase" | Tokens mínimos |

## Razón

1. No se puede optimizar sin datos base (tokens, tiempo, decisiones).
2. Los riesgos arquitectónicos requieren validación empírica antes de cambios.
3. Los tests de flujo protegen contra regresiones durante el roadmap de migración.
4. La observabilidad permite detectar problemas temprano (como la DB de Engram vacía).

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Observabilidad mínima + tests** (esta decisión) | Datos para decidir, protección contra regresiones | Esfuerzo inicial, overhead de logging |
| **B: Solo observabilidad** | Datos sin tests | Sin protección contra regresiones |
| **C: Solo tests** | Protección contra regresiones | Sin datos para optimizar |
| **D: Ninguno** | Sin esfuerzo | Ciego, sin datos, sin protección |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Decisiones basadas en datos, no estimaciones.
- Protección contra regresiones durante el roadmap.
- Detección temprana de problemas.
- Baseline para medir éxito de optimizaciones.

## Consecuencias negativas

- Esfuerzo de implementación (plugin de logging + scripts de test).
- Pequeño overhead de logging (request_id, métricas).
- Tests manuales inicialmente (automatización progresiva).

## Evidencia

- **Documento relacionado**: `09-risk-register.md` (R09, R10), `11-memory-and-token-optimization-model.md`, `13-validation-test-plan.md`
- **Hallazgo**: No hay observabilidad ni tests en el sistema actual.
- **ID en Evidence Register**: R09, R10

## Validación requerida

1. [ ] Implementar plugin de logging mínimo (request_id + métricas básicas).
2. [ ] Ejecutar Test 8 (baseline) para medir overhead actual.
3. [ ] Ejecutar Test 1 (simple) para validar comportamiento base.
4. [ ] Documentar resultados como baseline de tokens y tiempo.
5. [ ] Iterar sobre los tests restantes según prioridad.
