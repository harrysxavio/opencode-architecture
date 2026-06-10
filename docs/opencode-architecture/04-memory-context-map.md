# Memory and Context Map — Mapa de Memoria y Contexto

## 1. Clasificación de todas las fuentes de memoria/contexto

| Fuente | Tipo | Persistente | Automática | Bajo demanda | Quién escribe | Quién lee | Valor | Riesgo de ruido | Estado |
|--------|------|-------------|------------|--------------|--------------|-----------|-------|----------------|--------|
| AGENTS.md (.config/opencode) | System instruction | ✅ Sí | ✅ Sí | ❌ No | Usuario | Manager | Alto: persona + protocolos | Medio: engran protocol duplicado | ✅ Activo |
| AGENTS.md (.codex) | System instruction | ✅ Sí | ✅ Sí (Codex engine) | ❌ No | Usuario | gentle-orch | Alto: orquestación SDD | Medio: engran duplicado | ✅ Activo |
| Manager prompt (inline) | Agent prompt | ✅ Sí (en config) | ✅ Sí (cuando Manager activo) | ❌ No | Usuario | Manager | Alto: orquestación global | Bajo | ✅ Activo |
| gentle-orch prompt (inline) | Agent prompt | ✅ Sí (en config) | ✅ Sí (cuando gentle activo) | ❌ No | Usuario | gentle-orch | Alto: coordinación SDD | Bajo | ✅ Activo |
| Engram MEMORY_INSTRUCTIONS | System instruction | ✅ Sí (en plugin) | ✅ Sí (system transform) | ❌ No | Plugin engram.ts | Todos los agentes | Alto: protocolo memoria | Medio: duplica AGENTS.md | ✅ Activo |
| Background-agents delegation rules | System instruction | ✅ Sí (en plugin) | ✅ Sí (system transform) | ❌ No | Plugin background-agents.ts | Todos los agentes | Alto: reglas delegación | Bajo | ✅ Activo |
| Available skills list (system) | Runtime tool schema | ❌ No (generada) | ✅ Sí (OpenCode runtime) | ❌ No | OpenCode runtime | Todos los agentes | Alto: matching de skills | Medio: 3k tokens | ✅ Activo |
| Tool schemas nativas | Runtime tool schema | ❌ No | ✅ Sí | ❌ No | OpenCode runtime | Todos los agentes | Alto: capacidades | Bajo | ✅ Activo |
| MCP tool schemas | Runtime tool schema | ❌ No | ✅ Sí (si MCP activo) | ❌ No | OpenCode runtime + config | Agentes con MCP | Medio: capacidades adicionales | Alto: ~2-8k tokens c/u | ✅ Activo |
| Engram observations (mem_save) | Episodic memory | ✅ Sí (`~/.engram/engram.db`) | ❌ No | ✅ Sí (mem_search) | Manager/subagentes | Manager/subagentes | Alto: decisiones + bugs | Bajo si gobernado | ✅ Validado E1 |
| Engram prompts (capturados) | Episodic memory | ✅ Sí (SQLite) | ✅ Sí (plugin hook) | ❌ No (se guarda auto) | Plugin engram.ts | Solo retrieval | Medio: contexto de decisión | Alto: prompts completos sin síntesis | ✅ Activo |
| Session summaries (mem_session_summary) | Episodic memory | ✅ Sí (`observations.type=session_summary`) | ❌ No (manual) | ✅ Sí (mem_context) | Manager | Manager | Alto: resumen cross-session | Bajo si bien escrito | ✅ Validado E1 |
| SDD artifacts (mem_save) | SDD artifact | ✅ Sí (SQLite) | ❌ No (fin de fase) | ✅ Sí (mem_search) | Subagentes SDD | Subagentes SDD | Alto: trazabilidad SDD | Bajo (capture_prompt: false) | ⚠️ Sin artefactos visibles |
| SDD artifacts (openspec/) | SDD artifact | ✅ Sí (filesystem) | ❌ No (fin de fase) | ✅ Sí (lectura directa) | Subagentes SDD | Subagentes SDD | Alto: especificaciones versionadas | Bajo | ❌ No implementado |
| Skill registry (.atl/skill-registry.md) | Skill registry | ✅ Sí (.md file) | ❌ No (refresh manual) | ✅ Sí (lectura directa) | gentle-ai CLI | gentle-orch, subagentes | Alto: índice de skills | Bajo | ✅ Activo |
| Inventory (inventory.md) | Inventory | ✅ Sí (.md file) | ❌ No (generación manual) | ✅ Sí (comando inventory) | generate-static-inventory.mjs | Usuario, auditoría | Medio: catálogo técnico | Medio: puede estar stale | ⚠️ Cache |
| CONTEXT_INDEX.md | Project memory | ❌ No existe | ❌ No | ❌ No | — | frontend-specialist lo busca | N/A | N/A | ❌ Ausente |
| Graphify graph | External document | ❌ No existe (sin graphify-out/) | ❌ No | ❌ No | — | Manager | N/A | N/A | ❌ No implementado |
| Session index (session_index.jsonl) | Episodic memory | ✅ Sí (JSONL) | ✅ Sí (Codex engine) | ❌ No | Codex engine | Codex engine | Medio: historial sesiones | Bajo | ✅ Activo |
| State DB (state_5.sqlite) | Episodic memory | ✅ Sí (SQLite) | ✅ Sí (Codex engine) | ❌ No | Codex engine | Codex engine | Medio: estado sesiones | Bajo | ✅ Activo |
| Session files (sessions/) | Episodic memory | ✅ Sí (archivos) | ✅ Sí (Codex engine) | ❌ No | Codex engine | Codex engine | Medio: historial | Medio: 67 archivos | ✅ Activo |
| Memory files (memories/) | Episodic memory | ✅ Sí (archivos) | ✅ Sí (Codex engine) | ❌ No | Codex engine | Codex engine | Medio: 32 archivos | Medio | ✅ Activo |
| Design skills protocol (AGENTS.md) | Procedural memory | ✅ Sí (.md) | ✅ Sí | ❌ No | Usuario | Manager | Alto: frontend design gate | Bajo | ✅ Activo |
| Design/DESIGN.md | Project memory | ✅ Sí (.md) | ❌ No | ✅ Sí (lectura directa) | Usuario/agentes | frontend-specialist | Medio: design system | Bajo | ✅ Activo |
| SDD skills (sdd-*.md) | Procedural memory | ✅ Sí (.md) | ❌ No (skill tool) | ✅ Sí (skill tool) | Usuario/system | Subagentes SDD | Alto: fases SDD | Bajo | ✅ Activo |

## 2. Reglas recomendadas de memoria

### 2.1 Qué guardar en Engram

| Tipo | Guardar | Ejemplo |
|------|---------|---------|
| Decisiones arquitectónicas | ✅ Sí | "Elegir Manager como único primary" |
| Preferencias persistentes | ✅ Sí | "El usuario quiere respuestas cortas" |
| Hallazgos técnicos validados | ✅ Sí | "FTS5 no escapa caracteres especiales" |
| Bugs relevantes resueltos | ✅ Sí | "Root cause: null pointer en parseInput" |
| Patrones reutilizables | ✅ Sí | "Patrón de validación para IDs" |
| Resúmenes de sesión útiles | ✅ Sí | "Resumen de lo completado y pendientes" |
| Estado de largo plazo de proyectos | ✅ Sí | "Arquitectura opencode en fase de documentación" |
| Decisiones específicas SDD | ⚠️ Sí, con capture_prompt: false | Artefactos de fases SDD |
| Errores conocidos | ✅ Sí | "El MCP de Supabase necesita auth" |

### 2.2 Qué NO guardar en Engram

| Tipo | NO guardar | Razón |
|------|------------|-------|
| Conversación transitoria | ❌ No | Sin valor cross-session |
| Texto largo sin síntesis | ❌ No | Consume espacio y tokens |
| Prompts completos del usuario | ❌ No (salvo necesario para contexto) | Ruido, duplicado con sesiones |
| Logs extensos | ❌ No | No son recuperables semanticamente |
| Resultados duplicados de archivos | ❌ No | Ya están en el filesystem |
| Artefactos que viven mejor en Markdown | ❌ No | El versionado es mejor fuente de verdad |
| Información sensible | ❌ No | Riesgo de seguridad |
| Ruido exploratorio | ❌ No | Hipótesis no validadas |

### 2.3 Qué debe vivir en Markdown versionado

| Tipo | Formato | Ejemplos |
|------|---------|----------|
| Arquitectura | .md en docs/ | `docs/opencode-architecture/` |
| ADRs | .md en docs/*/adr/ | `ADR-001-primary-orchestrator.md` |
| Roadmaps | .md | `12-migration-roadmap.md` |
| Test plans | .md | `13-validation-test-plan.md` |
| Diagramas | .md con Mermaid | `02-request-response-flow.md` |
| Inventario humano | .md | `inventory/inventory.md` (actualizado) |
| Decisiones de diseño | .md | `design/DESIGN.md` |
| Especificaciones SDD cerradas | .md en openspec/ | (cuando se implemente) |

### 2.4 Qué debe vivir en Skill Registry

| Elemento | Descripción |
|----------|-------------|
| Índice de skills | Lista completa de skills disponibles |
| Trigger | Qué activa cada skill |
| Ruta | Path al SKILL.md |
| Scope | user, agent, system |
| Uso esperado | Para qué sirve |

### 2.5 Qué debe vivir en Inventory

| Elemento | Descripción |
|----------|-------------|
| Catálogo técnico generado | Lista de agentes, tools, MCP, plugins |
| Estado de configuración | Fecha de generación, paths |
| Métricas | Conteo por categoría |
| Dependencias | Relaciones entre componentes |

## 3. Propuesta de acceso a memoria por capa

```mermaid
graph TD
    subgraph "Capa 1: Contexto de Sistema (fijo)"
        C1[System prompt base<br/>~3k tokens]
        C1_2[Tool schemas<br/>~2-10k tokens]
    end
    
    subgraph "Capa 2: Contexto del Agente Activo"
        C2[Prompt del agente<br/>~7-12k tokens]
        C2_2[Instrucciones plugin<br/>~2-3k tokens]
    end
    
    subgraph "Capa 3: Memoria Recuperada (bajo demanda)"
        C3[Engram observations<br/>mem_search + mem_get_observation]
        C3_2[Session summaries<br/>mem_context]
    end
    
    subgraph "Capa 4: Documentación Versionada (bajo demanda)"
        C4[Markdown docs<br/>read tool]
        C4_2[ADRs, diseño, specs<br/>read tool]
    end
    
    subgraph "Capa 5: Skills (bajo demanda por trigger)"
        C5[skill() tool<br/>carga SKILL.md]
    end
    
    subgraph "Capa 6: MCP (bajo demanda)"
        C6[MCP tools<br/>Context7, NotebookLM, etc.]
    end
    
    C1 --> C2
    C2 --> C3
    C3 --> C4
    C4 --> C5
    C5 --> C6
```

## 4. Problemas detectados en el modelo actual de memoria

1. **Triple fuente de instrucciones de memoria**: AGENTS.md (.config), AGENTS.md (.codex) y engram.ts MEMORY_INSTRUCTIONS.
2. **Confusión de stores**: `C:\Users\harry\.codex\memories_1.sqlite` no tiene observations/prompts porque no es el store semántico de Engram. El store real es `C:\Users\harry\.engram\engram.db` y sí tiene observations/prompts.
3. **Prompt capture sin control**: `engram.ts` captura prompts completos del usuario sin filtro.
4. **Sin invalidación**: No hay mecanismo para marcar memoria como obsoleta o superseded.
5. **Sin métricas**: No se mide cuánta memoria se guarda, recupera o es útil.
6. **Sin gobernanza de sensibilidad**: No se clasifica la sensibilidad de lo guardado.
7. **Session summary no está en `sessions.summary`**: E1 validó que `mem_session_summary` guarda una observation `session_summary`; `session_index.jsonl` y `sessions.summary` no son la evidencia correcta.

## 4.1 Corrección Fase E0/E1

| Creencia previa | Corrección validada |
|---|---|
| Engram DB no tiene `observations` | Falso para Engram real; `~/.engram/engram.db` sí tiene 292 observations |
| `mem_save` no persiste | Falso; E-T2/E-T3 guardó y recuperó id=395 |
| `mem_context` quizá solo usa sesión actual | Falso/parcial; recupera observations persistidas del store Engram |
| `mem_session_summary` no funciona | Falso; funciona, pero como observation `session_summary` |
| Riesgo principal = memoria inexistente | Corrección: riesgo principal = ruido, duplicación, drift y prompt capture |

## 5. Modelo propuesto de fuente de verdad para instrucciones Engram

> ⚠️ **Corrección Fase B0 (C8)**: Resolver contradicción entre plugin .ts y Markdown.

| Fuente | Rol actual | Rol propuesto | Estado de decisión |
|--------|-----------|---------------|-------------------|
| **engram.ts** (plugin) | Inyecta MEMORY_INSTRUCTIONS al system prompt | **Mecanismo runtime mínimo**: inyecta instrucciones operativas al modelo | ✅ Mantener |
| **AGENTS.md** (.config y .codex) | Contienen protocolo Engram inline | **Remover** instrucciones Engram de AGENTS.md; dejar solo referencias al plugin | DECISIÓN PROPUESTA |
| **engram-instructions.md** (model_instructions_file) | Archivo de instrucciones referenciado en config.toml | **Fuente de verdad versionada**: mantener como Markdown versionado que el plugin y el modelo consultan | DECISIÓN PROPUESTA |
| **Docs/ADRs** | No existe actualmente | **Razonamiento arquitectónico**: decisiones de diseño sobre memoria deben vivir en ADRs y documentación, no enterradas en plugin .ts | DECISIÓN PROPUESTA |

**Principio**: Markdown versionado = fuente de verdad humana. Plugin Engram = mecanismo runtime mínimo. AGENTS.md = instrucciones operativas mínimas sin protocolo Engram.
