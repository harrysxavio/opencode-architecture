# Migration Roadmap — Roadmap de Migración

> No propone una reescritura grande. Usa fases incrementales, cada una con criterio de salida claro.

## Fase A — Documentación y Evidencia

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Tener foto actual consolidada, clasificada y validada |
| **Cambios permitidos** | Solo archivos .md en `docs/opencode-architecture/` |
| **Archivos probables** | `docs/opencode-architecture/*.md`, `docs/opencode-architecture/adr/*.md` |
| **Riesgo** | 🟢 Bajo: solo documentación |
| **Prueba de aceptación** | Todos los docs creados, hallazgos clasificados, ADRs propuestos |
| **Duración estimada** | 1-2 sesiones |

### Tareas

1. ✅ Crear estructura de carpetas (completado en este documento)
2. ✅ Documentar foto actual (01-current-state-map)
3. ✅ Documentar flujo (02-request-response-flow)
4. ✅ Documentar responsabilidades (03-agent-responsibility-map)
5. ✅ Documentar memoria (04-memory-context-map)
6. ✅ Documentar tokens (05-token-cost-map)
7. ✅ Documentar tools/MCP/skills (06-tools-mcp-skills-map)
8. ✅ Registrar evidencia (07-evidence-register)
9. ✅ Registrar conflictos (08-conflicts-and-open-questions)
10. ✅ Registrar riesgos (09-risk-register)
11. ✅ Proponer arquitectura objetivo (10-target-architecture)
12. ✅ Proponer modelo de optimización (11-memory-and-token-optimization-model)
13. ✅ Diseñar roadmap (este documento)
14. ✅ Diseñar plan de pruebas (13-validation-test-plan)
15. ✅ Escribir ADRs
16. ⬜ **Revisión y aprobación por el usuario**

## Fase B-Security — Rotación y Externalización de Secretos ✅ COMPLETADA

> Ejecutada y resuelta antes de Fase B1. R11 mitigado.

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Eliminar secretos expuestos en texto plano de config.toml |
| **Cambios realizados** | GitHub PAT actualizado. Browserbase eliminado del config. 5 backups eliminados. |
| **Archivos afectados** | `config.toml` (~/.codex/) — línea 112 actualizada, sección browserbase eliminada |
| **Riesgo** | 🟢 Resuelto. Sin secretos expuestos. |
| **Prueba de aceptación** | ✅ Sin secretos en texto plano. Git history limpio. Backups eliminados. |

### Tareas ejecutadas

1. ✅ GitHub PAT actualizado (nuevo token proporcionado por usuario).
2. ✅ Browserbase API key eliminado del config (ya no necesario).
3. ✅ 5 backups con secretos eliminados de `~/.codex/`.
4. ✅ Git history revisado — sin fugas.
5. ✅ Sin rastros del token viejo en `~/.codex/`.
6. ⬜ Variables de entorno: no implementado (decisión del usuario: personal project, token directo en config).

---

## Fase B1 — Observabilidad Mínima ✅ COMPLETADA

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Medir flujo real sin cambiar lógica del sistema |
| **Cambios permitidos** | Solo documentación y scripts read-only. NO cambiar lógica agente/prompt/config |
| **Archivos probables** | `docs/opencode-architecture/18-observability-design.md`, `docs/opencode-architecture/baselines/` |
| **Riesgo** | 🟢 Bajo: solo documentación y scripts read-only |
| **Prueba de aceptación** | Test 8 (token baseline), Test 1 (primary real), Test 5 (SDD routing) ejecutados y documentados |

### Métricas a capturar por request (diseño — ver 18-observability-design.md)

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

## Fase C — Tests de Flujo

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Crear escenarios reproducibles que validen el comportamiento del sistema |
| **Cambios permitidos** | Solo scripts de test (no modificar agentes/config) |
| **Archivos probables** | `tests/flows/` con scripts o prompts de prueba |
| **Riesgo** | 🟢 Bajo: scripts de prueba |
| **Prueba de aceptación** | 8 escenarios del plan (13-validation-test-plan) ejecutables y documentados |

### Escenarios mínimos

1. Request simple (Tiny) — verificar overhead mínimo
2. Request con memoria — verificar recuperación
3. Request con documento — verificar lectura de docs
4. Request con MCP — verificar tool routing
5. Request SDD — verificar pipeline
6. Request ruidoso — verificar clasificación
7. Contradicción de memoria — verificar invalidation
8. Token baseline — medir overhead real

## Fase D — Resolver Agente Primario

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Eliminar ambigüedad Manager vs gentle-orchestrator |
| **Cambios permitidos** | Modificar `opencode.json` (cambiar mode de gentle-orch) + prompts |
| **Archivos probables** | `opencode.json`, AGENTS.md, gentle-orch prompt |
| **Riesgo** | 🟡 Medio: cambiar configuración de agente |
| **Prueba de aceptación** | Solo Manager responde como default. gentle-orch responde solo con mención explícita |

### Decisión propuesta (ADR-001)
- **Manager**: mantener como único `mode: "primary"` por defecto.
- **gentle-orchestrator**: cambiar a `mode: "subagent"` o eliminar su modo primary. Mantenerlo como agente invocable explícitamente para SDD.
- Si se elimina el primary de gentle-orch, actualizar su prompt para reflejar que es un SDD Pipeline invocable, no un orquestador general.

## Fase E — Gobernanza de Memoria

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Definir qué se guarda, dónde y cuándo. Reparar pipeline Engram |
| **Cambios permitidos** | Modificar engram.ts (filtros), AGENTS.md (desduplicar protocolo) |
| **Archivos probables** | `plugins/engram.ts`, AGENTS.md (.config y .codex) |
| **Riesgo** | 🟡 Medio: modificar plugin activo |
| **Prueba de aceptación** | mem_save persiste observaciones. Session summary persiste. DB tiene datos útiles |

### Tareas

1. Diagnosticar por qué `memories_1.sqlite` está vacía (no tiene tabla observations, solo tablas internas de pipeline).
2. Reparar pipeline de guardado (puede ser MCP, permisos o configuración).
3. Consolidar instrucciones Engram: Markdown versionado (engram-instructions.md) como fuente de verdad; plugin engram.ts como mecanismo runtime; remover de AGENTS.md.
4. Implementar filtro de guardado: no guardar prompts completos automáticamente.
5. Validar que `mem_session_summary` funciona correctamente.
6. Establecer política de guardado según sección 4 de 04-memory-context-map.md.

## Fase F — Reducir Contexto Fijo

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Mover instrucciones largas a docs/skills bajo demanda |
| **Cambios permitidos** | AGENTS.md (recortar), prompts de agente, mover contenido a skills/docs |
| **Archivos probables** | AGENTS.md (.config), AGENTS.md (.codex), nuevas skills bajo demanda |
| **Riesgo** | 🟡 Medio: prompts más cortos pueden perder comportamiento |
| **Prueba de aceptación** | Reducción de ~29k a ~15-18k tokens fijos. Comportamiento no degradado |

### Tareas

1. Mover Design Skills Protocol de AGENTS.md a skill bajo demanda (`frontend-design-gate` skill).
2. Reducir available skills list a solo triggers relevantes al proyecto actual (no los 48 globales).
3. Mover secciones de AGENTS.md (.codex) que no son críticas a docs/.
4. Compactar AGENTS.md (.config): remover secciones que viven en plugin.
5. Desduplicar y consolidar instrucciones de memoria (continuación de Fase E).

## Fase G — Optimizar MCP/Tool Surface

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Activar herramientas por necesidad, no siempre |
| **Cambios permitidos** | Config de MCP en opencode.json, opencode.jsonc, config.toml |
| **Archivos probables** | `opencode.json`, `opencode.jsonc`, `config.toml` |
| **Riesgo** | 🟡 Medio: MCP que no se active puede causar errores si se necesita |
| **Prueba de aceptación** | MCP se activan solo cuando el request lo requiere. Reducción de tokens de schemas. |

### Tareas

1. Consolidar MCP duplicados (Engram x3, Playwright x3, Context7 x2).
2. Decidir estrategia de activación: ¿plugin que activa MCP según intención? ¿o configuración manual?
3. Mover secretos expuestos (GitHub token, Browserbase key) a variables de entorno.
4. Evaluar si todos los MCP son necesarios o algunos pueden eliminarse.

## Fase H — Consolidar Arquitectura Objetivo

| Aspecto | Detalle |
|---------|---------|
| **Objetivo** | Implementar cambios arquitectónicos con tests de validación |
| **Cambios permitidos** | Config, prompts, plugins, skills (todo) |
| **Archivos probables** | Todos los relevantes |
| **Riesgo** | 🔴 Alto: cambios significativos |
| **Prueba de aceptación** | Arquitectura objetivo implementada y validada con tests de flujo |

### Tareas

1. Implementar cambios de ADRs aprobados.
2. Implementar observabilidad permanente.
3. Implementar modelo de memoria gobernada.
4. Implementar lazy-load de skills completo.
5. Implementar MCP bajo demanda.
6. Ejecutar test plan completo.
7. Documentar lecciones aprendidas y actualizar docs.

## 2. Resumen de fases

```mermaid
gantt
    title Roadmap de Migración
    dateFormat  YYYY-MM-DD
    axisFormat  %Y-%m-%d
    
    section Fase A
    Documentación y evidencia          :done, A, 2026-06-09, 1d

    section Fase B0
    Corrección documental + validación :done, B0, after A, 1d
    
    section Fase B-Security
    Rotación de secretos               :done, B_SEC, after B0, 1d
    
    section Fase B1
    Observabilidad mínima              :done, B1, after B_SEC, 3d
    
    section Fase C
    Tests de flujo                     :C, after B1, 3d
    
    section Fase D
    Resolver agente primario           :D, after C, 2d
    
    section Fase E
    Gobernanza de memoria              :E, after D, 4d
    
    section Fase F
    Reducir contexto fijo              :F, after E, 4d
    
    section Fase G
    Optimizar MCP surface              :G, after F, 3d
    
    section Fase H
    Consolidar arquitectura objetivo   :H, after G, 5d
```

## 3. Tabla consolidada de fases

| Fase | Objetivo | Cambios permitidos | Archivos probables | Riesgo | Prueba de aceptación |
|------|----------|-------------------|-------------------|--------|---------------------|
| **A** | Documentación y evidencia | Solo .md en docs/ | docs/opencode-architecture/*.md | 🟢 Bajo | Todos los docs creados, hallazgos clasificados |
| **B0** | Corrección documental + validación read-only | Solo .md en docs/ + comandos read-only | docs/opencode-architecture/*.md | 🟢 Bajo | Contradicciones corregidas, validaciones registradas |
| **B-Security** | Rotación y externalización de secretos | config.toml | ~/.codex/config.toml | 🟢 **Completado** | ✅ Sin secretos expuestos. Git history limpio. |
| **B1** | Observabilidad mínima | Solo documentación + scripts read-only | docs/opencode-architecture/18-observability-design.md, baselines/ | 🟢 **Completado** | ✅ Tests 8, 1, 5 ejecutados y documentados. Sin sobreorquestación en Tiny. |
| **C** | Tests de flujo | Solo scripts de test | tests/flows/* | 🟢 Bajo | 8 escenarios ejecutables |
| **D** | Consolidar MCP y skills | opencode.json, MCP, skills | Config MCP, skills/ | 🟡 Medio | MCP consolidados, skills bajo demanda |
| **E** | Reparar memoria Engram | engram.ts, AGENTS.md | plugins/engram.ts, AGENTS.md | 🟡 Medio | mem_save persiste observaciones |
| **F** | Token optimization | AGENTS.md, skills, prompts | AGENTS.md, skills/ | 🟡 Medio | ~18.5–22k → ~8.5-9.5k tokens fijos |
| **G** | Config consolidation | opencode.json, .jsonc, config.toml | Config OpenCode | 🟡 Medio | gentle-orch mode: subagent. Config única. |
| **H** | Consolidar arquitectura | Todo | Todos | 🔴 Alto | Arquitectura objetivo implementada y testeada |

## 4. Dependencias entre fases

```mermaid
graph LR
    A[Fase A: Documentación] --> B0[Fase B0: Corrección + validación]
    B0 --> B_SEC[Fase B-Security: Rotar secretos]
    B_SEC --> B1[Fase B1: Observabilidad]
    B1 --> C[Fase C: Tests de flujo]
    C --> D[Fase D: Resolver primary]
    D --> E[Fase E: Gobernanza memoria]
    E --> F[Fase F: Reducir contexto]
    F --> G[Fase G: MCP surface]
    G --> H[Fase H: Consolidar objetivo]
    
    E -.->|comparte cambios| F
    F -.->|comparte cambios| G
```

> **Nota**: B0, B-Security y B1 deben ejecutarse secuencialmente (validar, asegurar, medir). A partir de C, las fases pueden solaparse si los recursos lo permiten.
