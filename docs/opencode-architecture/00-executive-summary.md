# Executive Summary — Arquitectura OpenCode

## Contexto

OpenCode es un ecosistema agentic AI con múltiples capas de orquestación, memoria, skills y herramientas. El usuario ha ejecutado 3 auditorías paralelas y solicita una consolidación documental verificable para entender la arquitectura actual y planificar su evolución.

## Hallazgos principales

### 1. Dos orquestadores primarios compiten por control

**VALIDADO**: `gentle-orchestrator` y `manager` están ambos configurados como `mode: "primary"` en `opencode.json`.

- `gentle-orchestrator` (líneas 4-33): coordinador SDD, nunca ejecuta inline, usa task/delegate para subagentes SDD.
- `manager` (líneas 34-51): orquestador global híbrido, con protocolo completo que prohíbe llamar a `gentle-orchestrator`.
- No hay documentación de cómo OpenCode resuelve cuál gana cuando ambos son primary.

**Riesgo**: El sistema puede responder con el orquestador incorrecto dependiendo de la UI o configuración adicional.

### 2. Engram no produce persistencia útil — confirmado en Fase B0

**VALIDADO**: El plugin `engram.ts` está activo (19,136 líneas), inyecta instrucciones de memoria al system prompt, captura prompts de usuario y tiene hooks de sesión. Sin embargo:

- **Fase B0**: `memories_1.sqlite` tiene **40KB (no 4KB)** pero NO tiene tabla `observations`. Su schema es de pipeline interno (`_sqlx_migrations`, `stage1_outputs`, `jobs`), no de memoria semántica.
- La carpeta `memories/` contiene solo archivos placeholder sin datos útiles.
- `rollout_summaries/` está vacío.
- `session_index.jsonl` (57 entradas) no contiene evidencia de `mem_session_summary`.
- **8 procesos engram.exe activos** confirman duplicación por triple configuración.

**Riesgo**: Toda la memoria cross-session que el sistema cree tener no está funcionando. Se requiere diagnóstico del pipeline Engram MCP en Fase E.

### 3. Contexto fijo — estimación no validada

**INFERIDO / PENDIENTE DE MEDICIÓN** — estimación basada en suma de fuentes conocidas, no en medición runtime.

| Fuente | Tokens estimados | Estado |
|--------|-----------------|--------|
| System prompt base | ~3,000 | INFERIDO |
| AGENTS.md (.codex) | ~12,000 | INFERIDO (doble conteo posible) |
| AGENTS.md (.config/opencode) | ~7,000 | INFERIDO (doble conteo posible) |
| Available skills list | ~3,000 | INFERIDO |
| Engram protocol inline | ~2,500 | INFERIDO |
| Design skills protocol | ~1,500 | INFERIDO |
| **Rango conservador** | **~18,500–22,000** | **INFERIDO** — ambos AGENTS.md NO se cargan simultáneamente |
| **Estimación conflictiva anterior** | **~29,000** | **CONFLICTO** — asume ambos AGENTS.md siempre activos |

> ⚠️ **Corrección Fase B0**: La estimación de ~29,000 asume que ambos AGENTS.md (manager + gentle-orchestrator) se cargan simultáneamente, lo cual es incorrecto porque solo UN agente está activo por sesión. El rango realista es ~18,500–22,000 tokens fijos pendiente de medir en Test 8 (baseline).

Esto es por sesión, antes del primer mensaje del usuario. Con GPT-5.5, el costo es latencia y tokens.

### 4. Duplicación de instrucciones de memoria

**VALIDADO**: El protocolo Engram aparece en **dos** AGENTS.md:
- `~/.config/opencode/AGENTS.md` (líneas 72-166)
- `~/.codex/AGENTS.md` (líneas 355-449)
- Además, `engram.ts` inyecta `MEMORY_INSTRUCTIONS` al system prompt (líneas 64-141)

**Riesgo**: Instrucciones contradictorias o redundantes que consumen tokens y pueden confundir al modelo.

### 5. Subagentes SDD bien definidos pero sin artefactos visibles

**VALIDADO**: 8 subagentes SDD (`sdd-apply`, `sdd-archive`, `sdd-design`, `sdd-explore`, `sdd-init`, `sdd-onboard`, `sdd-propose`, `sdd-spec`, `sdd-tasks`, `sdd-verify`) están configurados con `mode: "subagent"` y `hidden: true`. Cada uno tiene:

- Prompt que prohíbe delegar.
- SKILL.md con fases definidas.
- Executor boundary claro.
- Persistence contract con modo Engram/OpenSpec/hybrid/none.

**NO VALIDADO**: No hay evidencia de que el ciclo SDD completo se haya ejecutado (no hay artefactos en Engram ni directorios `openspec/`).

### 6. MCP surface extensa

**VALIDADO**: Entre `opencode.json` y `opencode.jsonc` hay **9+ MCP servers** configurados:
Engram, Context7, NotebookLM, Supabase, Playwright, GitHub, fastmcp-toolkit, browserbase, node_repl.

**Riesgo**: Cada MCP agrega tool schemas al contexto del modelo. Más MCP = más tokens de sistema + mayor superficie de error.

### 7. Skill registry funcional pero con scope limitado

**VALIDADO**: `.atl/skill-registry.md` contiene 48 skills indexadas con triggers, scopes y paths. Se usa como contexto index para que delegadores pasen paths exactos a subagentes.

**RESUELTO (Fase B0)**: `CONTEXT_INDEX.md` existe en otros proyectos (PROJECT_TEMPLATE, SAMPLE_PROJECT) pero NO en el workspace actual. `skill-registry.md` cumple la función de context index. No crear CONTEXT_INDEX.md separado.

### 8. Inventory generado pero potencialmente desactualizado

**VALIDADO**: `inventory.md` (1,635 líneas) y `inventory.json` existen con catálogo de agentes, MCP, skills, plugins.
**NO VALIDADO**: Fecha de generación: 2026-05-28. Puede estar desactualizado respecto a cambios posteriores.

## Decisión propuesta principal

**Unificar bajo un solo orquestador primario**. Mantener Manager como orquestador global por defecto. Migrar gentle-orchestrator a un rol de "SDD Pipeline especializado" invocable explícitamente, eliminando su modo `primary`.

## Arquitectura objetivo (resumen)

```
Manager (router principal)
├── Memory Router (Engram query + governance)
├── Document Retriever (Markdown versionado)
├── Tool/MCP Router (bajo demanda)
├── SDD Pipeline (gentle-orchestrator como especialista)
├── Subagentes SDD y especializados
└── Observability Logger
```

## Próximo paso inmediato

Revisar y aprobar esta documentación como línea de base antes de cualquier cambio funcional.
