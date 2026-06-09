# ADR-009: Estrategia de Observabilidad y Testing

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). Observabilidad mínima antes de cambios arquitectónicos. Tests de flujo reproducibles.

> ⚠️ **Requiere Fase B-Security primero**: No implementar logging hasta rotar secretos, para evitar exponer credenciales en logs.

---

## Contexto

Actualmente el sistema **no tiene observabilidad ni tests de flujo**:

- No hay logging de: qué agente respondió, qué tools se usaron, cuántos tokens se consumieron, cuánto tiempo tomó cada request.
- No hay tests automatizados que validen el comportamiento del flujo agentic.
- Las decisiones de optimización se basan en estimaciones, no en mediciones.
- Los riesgos arquitectónicos (doble primary resuelto en ADR-001, memoria vacía, contexto fijo) no tienen validación empírica.
- Fase B0 confirmó que no hay evidencia de session summaries ejecutándose (P3), y que no se pudo validar el agente primary por falta de logs (P1).

**Principio**: "Medir antes de optimizar" — no se puede mejorar lo que no se mide.

---

## Decisión

**Agregar observabilidad mínima antes de cualquier cambio arquitectónico funcional. Crear tests de flujo reproducibles con baseline medible.**

### Observabilidad mínima

Para cada request, capturar:

| Métrica | Fuente | ¿Cómo? | ¿Sensible? |
|---------|--------|--------|------------|
| `request_id` | Generado | Plugin o hook | No |
| `agent_selected` | Runtime OpenCode | Hook de sesión | No |
| `manager_decision` (si aplica) | Manager | Clasificación loggeada | No |
| `intent_classification` | Manager | Tiny/Small/Medium/Large/etc. | No |
| `tools_called` | Plugin hook | Intercepción de tool calls | No |
| `mcp_called` | Plugin hook | Intercepción de MCP calls | No |
| `memory_read` (sí/no) | Plugin hook | mem_search invocado | No |
| `memory_written` (sí/no) | Plugin hook | mem_save invocado | No |
| `context_sources` | System prompt | Qué docs/skills se cargaron | No |
| `estimated_context_tokens` | Plugin hook | Suma de tokens del system prompt | No |
| `execution_time_ms` | Plugin hook | Timestamp inicio-fin | No |
| `response_summary` | Truncado | Primes 200 chars de la respuesta | Depende |
| `subagent_invoked` | Manager | Qué subagente se invocó | No |
| `subagent_status` | Subagente | Envelope.status | No |

### Tests de flujo (8 escenarios)

| ID | Input | Lo que valida | Prioridad |
|----|-------|---------------|-----------|
| **T1 Simple** | "Hola" | Overhead mínimo. Manager responde sin memoria/MCP/SDD. | P1 |
| **T2 Memoria** | "Continúa con lo que veníamos haciendo" | Retrieval de memoria. Manager usa Memory Router. | P1 |
| **T3 Documento** | "Buscá en docs sobre la arquitectura de memoria" | Lectura de docs versionados. Document Retriever. | P1 |
| **T4 MCP** | "Buscá información sobre Zod validation" | Tool routing. Manager activa MCP Context7. | P2 |
| **T5 SDD** | "Diseñá e implementá un cambio en el módulo X" | Pipeline SDD completo. Manager → gentle-orch → sdd-*. | P1 |
| **T6 Ruidoso** | Multi-tema mezclado | Clasificación correcta. Manager separa intenciones. | P3 |
| **T7 Contradicción** | "Cambiá la decisión de usar X por Y" | Invalidación de memoria. Manager marca supersedes. | P2 |
| **T8 Baseline** | "Decime 1 frase" | Tokens mínimos. Medir contexto fijo sin procesamiento. | **P0** |

### Formato de resultados de test

Cada test debe documentar:

```json
{
  "test_id": "T1",
  "date": "2026-06-09",
  "input": "Hola",
  "agent_responded": "manager",
  "classification": "tiny",
  "memory_read": false,
  "memory_written": false,
  "mcp_used": false,
  "subagent_invoked": null,
  "tokens_used": 18500,
  "execution_time_ms": 3200,
  "response_summary": "Hola, ¿en qué puedo ayudarte?",
  "status": "pass"
}
```

---

## Orden de implementación

| Paso | Acción | Dependencia | Prioridad |
|------|--------|-------------|-----------|
| 1 | B-Security: rotar secretos | Ninguna | 🔴 P0 |
| 2 | Test 8: baseline de tokens | B-Security | 🔴 P0 |
| 3 | Test 1: validar Manager primary | Test 8 | 🔴 P1 |
| 4 | Logging mínimo (request_id, agent, tokens, tiempo) | B-Security | 🟡 P1 |
| 5 | Test 5: validar SDD pipeline | Tests 1+8 | 🟡 P1 |
| 6 | Tests 2, 3, 4, 6, 7 | Logging funcionando | 🟢 P2 |
| 7 | Automatización progresiva de tests | Manuales validados | 🟢 P3 |

---

## Consecuencias positivas

- Decisiones basadas en datos, no estimaciones.
- Protección contra regresiones durante el roadmap de migración.
- Detección temprana de problemas (como Engram vacío).
- Baseline para medir éxito de optimizaciones de tokens.
- Validación empírica de la arquitectura objetivo.

## Consecuencias negativas

- Esfuerzo de implementación (plugin de logging + scripts de test).
- Pequeño overhead de logging (request_id, métricas).
- Tests manuales inicialmente (automatización progresiva).
- Los logs pueden contener información sensible si no se implementa filtrado.

---

## Validación requerida

1. [ ] Implementar plugin de logging mínimo (request_id + métricas básicas).
2. [ ] Ejecutar Test 8 (baseline) para medir overhead actual.
3. [ ] Ejecutar Test 1 (simple) para validar comportamiento base.
4. [ ] Ejecutar Test 5 (SDD) para validar pipeline completo.
5. [ ] Documentar resultados como baseline de tokens y tiempo.
6. [ ] Iterar sobre tests restantes según prioridad.

---

## Evidencia

- **Fase B0**: P1 (no se pudo validar agente primary), P3 (session summaries sin evidencia), P4 (config merge no resuelto).
- **Documento relacionado**: `09-risk-register.md` (R09, R10), `13-validation-test-plan.md`.
- **ADR relacionados**: ADR-001 (primary strategy), ADR-002 (Manager role).
- **ID en Evidence Register**: R09, R10.
