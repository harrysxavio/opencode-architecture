# 18 — Observability Design

> Documento creado en Fase B1. Define diseño de observabilidad mínima para medir el flujo de petición/respuesta sin cambiar la lógica del sistema.

## Objetivo

Medir el comportamiento real del sistema antes de cambiar arquitectura, agentes, memoria, MCP o prompts. Esta fase NO implementa instrumentación runtime permanente — solo define el diseño y ejecuta tests manuales controlados para establecer baseline.

## ¿Por qué ahora?

Las fases posteriores (C, D, E, F, G, H) requieren datos reales para:

1. Decidir qué optimizar primero (tokens, primary, memoria, MCP).
2. Medir impacto de cada cambio contra un baseline conocido.
3. Evitar optimizar sin datos (la trampa más común en sistemas agentic).

## Restricciones de diseño

- **No modificar** opencode.json, opencode.jsonc, AGENTS.md, prompts, modo primary, Engram, MCP, skills, subagentes, routing, token budget, SDD pipeline, configuración de agentes.
- **No cambiar** comportamiento funcional del sistema.
- **No guardar** en memoria Engram (validado como no funcional para memoria semántica).
- **No ejecutar** refactors ni optimizaciones.
- **Sí permitido**: documentación, scripts read-only, análisis de logs/sesiones/SQLite, reportes de baseline.

## Métricas mínimas por request

```json
{
  "request_id": "uuid",
  "timestamp": "ISO-8601",
  "input_type": "tiny | small | memory | docs | mcp | sdd | noisy",
  "agent_selected": "manager | gentle-orchestrator | unknown",
  "primary_resolution_method": "runtime | logs | inferred | not_validated",
  "manager_decision": "tiny | small | medium | large | not_available",
  "routing_path": ["manager", "memory", "docs", "mcp", "subagent", "sdd"],
  "tools_called": [],
  "mcp_called": [],
  "skills_loaded": [],
  "subagents_called": [],
  "memory_read": false,
  "memory_written": false,
  "documents_read": [],
  "estimated_fixed_context_tokens": null,
  "estimated_dynamic_context_tokens": null,
  "estimated_output_tokens": null,
  "total_estimated_tokens": null,
  "execution_time_ms": null,
  "errors": [],
  "final_response_summary": ""
}
```

### Explicación de métricas

| Métrica | Propósito | ¿Cómo se obtiene? |
|---------|-----------|-------------------|
| `request_id` | Trazabilidad única por request | UUID generado en el test |
| `timestamp` | Línea de tiempo | ISO-8601 al inicio del test |
| `input_type` | Clasificación del request | Manual (según taxonomía del plan de tests) |
| `agent_selected` | Qué agente responde por defecto | Observación directa + logs |
| `primary_resolution_method` | Cómo se determinó el agente | runtime \| logs \| inferred \| not_validated |
| `manager_decision` | Qué ruta tomó Manager | tiny \| small \| medium \| large \| not_available |
| `routing_path` | Secuencia de componentes atravesados | Observación directa |
| `tools_called` | Herramientas invocadas | Observación directa de tool calls |
| `mcp_called` | MCP servers activados | Logs + observación directa |
| `skills_loaded` | Skills cargados | Observación directa + logs |
| `subagents_called` | Subagentes delegados | Observación directa |
| `memory_read` | Si se consultó memoria | Observación directa |
| `memory_written` | Si se escribió memoria | Observación directa |
| `documents_read` | Documentos leídos | Observación directa |
| `estimated_fixed_context_tokens` | Contexto fijo (system prompt) | Estimación documentada |
| `estimated_dynamic_context_tokens` | Contexto dinámico (mensajes) | Estimación documentada |
| `estimated_output_tokens` | Tokens de respuesta | Estimación documentada |
| `total_estimated_tokens` | Suma estimada | fixed + dynamic + output |
| `execution_time_ms` | Tiempo de respuesta | Medición manual |
| `errors` | Errores encontrados | Observación directa |
| `final_response_summary` | Resumen de la respuesta | Manual |

## Fuentes de evidencia disponibles

| Fuente | Contenido | Utilidad para observabilidad |
|--------|-----------|------------------------------|
| `logs_2.sqlite` | 14,947 entradas con ts, level, target, module_path, file, thread_id | Trazas de conexión MCP, skills, plugins. Niveles: TRACE (6,744), DEBUG (4,069), INFO (3,992), WARN (142) |
| `state_5.sqlite` | 69 threads, agent_jobs, thread_dynamic_tools, thread_spawn_edges | Estado de sesiones activas, tools dinámicos |
| `session_index.jsonl` | 57 entradas de sesiones | Metadatos de sesiones (sin summaries) |
| Archivos de sesión en `sessions/` | Directorios por sesión | Logs detallados por sesión |
| Procesos activos | `Get-Process` | MCP servers activos, instancias engram |
| Output visible del modelo | Respuesta directa del agente | Comportamiento observado |
| MCP logs | Logs de conexión MCP en logs_2.sqlite | Qué MCP se activaron |
| Plugin logs | Trazas de plugins en logs_2.sqlite | Qué plugins participaron |

## Criterios de precisión

Cada dato debe clasificarse como:

| Clasificación | Significado |
|---------------|-------------|
| **VALIDADO** | Confirmado con evidencia runtime directa (logs, DB, proceso, output observable) |
| **INFERIDO** | Deducido de evidencia indirecta pero razonable (basado en configuración, comportamiento observado, o datos de terceros) |
| **NO DISPONIBLE** | La fuente no existe o no se puede acceder |
| **NO VALIDADO** | No se pudo confirmar ni inferir con certeza |

**No presentar inferencias como hechos.**

## Tests planificados en B1

| Test | Input | Objetivo |
|------|-------|----------|
| **T8** — Token baseline | "Dime 1 frase." | Medir overhead mínimo del sistema |
| **T1** — Primary real | "Hola, explícame en una frase qué puedes hacer." | Confirmar qué agente responde por defecto |
| **T5** — SDD Pipeline | Pregunta sobre routing SDD en modo read-only | Ver cómo enruta el sistema actual un cambio estructurado |

## Fuera de alcance de B1

- ❌ Instrumentación runtime permanente en plugins o MCP
- ❌ Modificación de opencode.json, opencode.jsonc, AGENTS.md
- ❌ Cambio de modo primary/subagent
- ❌ Reparación de Engram
- ❌ Optimización de tokens
- ❌ Refactor de cualquier tipo

## Riesgos

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| Tokens no medibles directamente | El runtime puede no exponer conteo de tokens | Usar estimación documentada y marcar como INFERIDO |
| Primary no determinable | Los logs pueden no registrar selección de agente | Marcar como NO VALIDADO — no asumir |
| Sesiones no reproducibles | El comportamiento puede variar entre sesiones | Documentar fecha/hora/contexto de cada test |
| Contaminación de memoria | Tests previos pueden afectar tests posteriores | Ejecutar en orden: T8 (mínimo) → T1 → T5 |
