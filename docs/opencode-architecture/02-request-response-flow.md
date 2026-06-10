# Request-Response Flow — Flujo Actual de Petición a Respuesta

> ⚠️ **Corrección Fase B0/B1**: El diagrama siguiente muestra ambos AGENTS.md (#2 y #3) como fuentes simultáneas de contexto. En realidad, solo el AGENTS.md del agente ACTIVO se carga. La suma de ~29k asume ambos simultáneamente — el rango corregido es **~18,500–22,000 tokens** (INFERIDO). Pendiente de medición real con Test 8.

## 1. Diagrama Mermaid del flujo actual

```mermaid
flowchart TB
    USR["🧑 Usuario escribe prompt"] --> CENG["Codex Engine<br/>inicia sesión"]

    subgraph "LAYER 0: Session Init"
        CENG --> SESSION["Lee config.toml<br/>→ modelo gpt-5.5<br/>→ memories on<br/>→ plugins activos"]
        SESSION --> SYS["
            Construye system prompt:
            1. System base (~3k tokens)
            2. AGENTS.md ~/.codex/ (~12k tokens)
            3. AGENTS.md ~/.config/ (~7k tokens)
            4. Available skills list (~3k tokens)
            5. Engram MEMORY_INSTRUCTIONS (~2.5k tokens)
            6. Design skills protocol (~1.5k tokens)
            7. Background-agents delegation rules
            8. Tool schemas (nativas + MCP)
             = ~18,5k–22k tokens base (INFERIDO)
             → Nota: 29k asume ambos AGENTS.md simultáneos. Solo UNO se carga.
        "]
    end

    subgraph "LAYER 1: Agent Resolution"
        SYS --> AR{"¿Cómo se resuelve<br/>el agente activo?"}
        AR -->|"@gentle-orchestrator<br/>o /sdd-*"| GO[gentle-orchestrator: primary]
        AR -->|"@manager o default"| MGR[Manager: primary]
        AR -->|"Otro @agent"| OTHER[Agente especializado]
    end

    subgraph "LAYER 2a: GENTLE-ORCHESTRATOR PATH"
        GO --> GO_DEC{"¿Inline o delegate?"}
        GO_DEC -->|"1-3 archivos<br/>lectura simple"| GO_INLINE[Responde inline]
        GO_DEC -->|"4+ archivos<br/>escritura<br/>tests<br/>tools externos"| GO_DELEGATE[Delega a subagente SDD]
        GO_DELEGATE -->|"task/delegate"| SDD_SUB[Subagente SDD]
        SDD_SUB --> SDD_WORK[Hace el trabajo<br/>NO delega más]
        SDD_WORK --> SDD_RET[Retorna envelope<br/>status/summary/next]
        SDD_RET --> GO_SYNTH[Sintetiza respuesta]
    end

    subgraph "LAYER 2b: MANAGER PATH"
        MGR --> MGR_CLASIF{"Clasifica request<br/>Tiny / Small / Medium / Large"}
        MGR_CLASIF -->|"Tiny"| MGR_INLINE[Responde inline]
        MGR_CLASIF -->|"Small"| MGR_SMALL[Intake corto + diseño<br/>+ aprobación + apply]
        MGR_CLASIF -->|"Medium"| MGR_MED[Intake completo<br/>+ diseño approval<br/>+ SDD controlado]
        MGR_CLASIF -->|"Large"| MGR_LARGE[Full workflow:<br/>Intake → Alternativas →<br/>Diseño → Aprobación<br/>→ Graphify → SDD<br/>→ TDD → Review<br/>→ GPT-5.5 gate
        ]
        
        MGR_SMALL --> MGR_SDD{"¿Usa subagente SDD?"}
        MGR_MED --> MGR_SDD
        MGR_LARGE --> MGR_SDD
        
        MGR_SDD -->|"sdd-explore"| MGR_EX[sdd-explore subagent]
        MGR_SDD -->|"sdd-propose"| MGR_PR[sdd-propose subagent]
        MGR_SDD -->|"sdd-spec"| MGR_SP[sdd-spec subagent]
        MGR_SDD -->|"sdd-design"| MGR_DE[sdd-design subagent]
        MGR_SDD -->|"sdd-tasks"| MGR_TA[sdd-tasks subagent]
        MGR_SDD -->|"sdd-apply"| MGR_AP[sdd-apply subagent]
        MGR_SDD -->|"sdd-verify"| MGR_VE[sdd-verify subagent]
        MGR_SDD -->|"sdd-archive"| MGR_AR[sdd-archive subagent]
        
        MGR_SDD -->|"No subagente"| MGR_INLINE_WORK[Manager ejecuta<br/>inline siguiendo<br/>protocolo SDD]
        
        MGR_AP -->|"¿Frontend?"| MGR_FE[frontend-specialist]
        MGR_AP --> QUALITY[Quality gates:<br/>TDD → Review →<br/>Debugging]
        
        MGR_LARGE -->|"Opcional"| GRAPHIFY[Graphify Context Gate]
        MGR_LARGE -->|"Opcional"| GPT55[GPT-5.5 review gate]
    end

    subgraph "LAYER 3: Tools & MCP"
        SDD_WORK --> TOOLS[Tools nativas:<br/>read, write, edit, bash,<br/>glob, grep, skill, task]
        MGR_INLINE_WORK --> TOOLS
        SDD_WORK --> MCP[MCP servers:<br/>Engram, Context7, NotebookLM,<br/>Supabase, Playwright, GitHub,<br/>Browserbase, node_repl, fastmcp]
    end

    subgraph "LAYER 4: Memory"
        MCP --> ENGRAM_MCP[Engram MCP:<br/>mem_save, mem_search,<br/>mem_context, mem_session_summary]
        ENGRAM_MCP --> SQLITE[(memories_1.sqlite)]
        PLUGIN_ENG["engram.ts plugin<br/>prompt capture<br/>system transform<br/>compaction hooks"] -.->|hooks| CENG
    end

    subgraph "LAYER 5: Delegation Async"
        PLUGIN_BG["background-agents.ts<br/>delegate tool<br/>delegation_read<br/>delegation_list<br/>persistOutput"] -.->|delegate| SUB_SESSION[Sesión aislada]
        SUB_SESSION --> SUB_OUTPUT[Output persistido a disco]
        SUB_OUTPUT --> SUB_NOTIFY[Notificación compacta]
    end

    GO_SYNTH --> RESP[Respuesta final al usuario]
    MGR_INLINE --> RESP
    MGR_FE --> RESP
    QUALITY --> RESP
    GPT55 --> RESP
    SUB_NOTIFY --> RESP
```

## 2. Flujo paso a paso

### Paso 0: Inicio de sesión
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Codex Engine | Config persistida | Cargar config.toml + AGENTS.md + plugins | Sesión iniciada | config.toml líneas 1-5, 90-96 | — |
| Engram plugin | Hook session.created | Crear o reusar sesión | session_id | engram.ts líneas 240-253 | — |
| Engine | Fuentes de contexto | Construir system prompt con todas las capas | ~18,5k–22k tokens sistema (INFERIDO) ⚠️ | Inferido de suma de fuentes; corregido de ~29k (asumía ambos AGENTS.md simultáneos) | 🔴 ALTO: contexto fijo masivo — pendiente de medición real con Test 8 |

### Paso 1: Resolución de agente
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| OpenCode runtime | Prompt del usuario + config | ¿Hay @mention o comando? | Agente seleccionado | opencode.json líneas 4-51 | 🔴 ALTO: dos primaries, resolución ambigua |

### Paso 2: Agente activo — Manager
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Manager | Prompt del usuario | Clasificar como Tiny/Small/Medium/Large | Estrategia a seguir | Manager prompt (protocolo líneas 50-80) | 🟡 MEDIO: clasificación manual, no automática |

### Paso 3: Ejecución Manager
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Manager | Clasificación | ¿Usar subagente SDD o inline? | Delegación o ejecución directa | Manager prompt (Operating Model) | 🟡 MEDIO: puede delegar a subagentes que no existen (review-gpt55, debug-gpt55) |

### Paso 4: Subagente SDD
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Subagente SDD | Contexto + skills | Ejecutar fase, NO delegar | Envelope con status/summary/next | sdd-phase-common.md líneas 3-6 | 🟢 BAJO: executor boundary claro |

### Paso 5: Memoria
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Engram plugin | Hook post-mensaje | Capturar prompt | SQLite | engram.ts líneas 349-381 | 🟡 MEDIO: guarda prompts completos |
| Manager/Subagente | Decisión/bug/fix | mem_save | Observación SQLite | AGENTS.md líneas 78-106 | 🔴 ALTO: memoria guardada pero DB vacía |

### Paso 6: Cierre de sesión
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Manager | Fin de sesión | mem_session_summary | Resumen persistido | AGENTS.md líneas 134-156 | 🟡 MEDIO: no verificado si se ejecuta |

### Paso 7: Respuesta final
| Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|-------|---------|----------|--------|-----------|--------|
| Agente activo | Resultados de subagentes + tools | Sintetizar respuesta | Mensaje al usuario | — | 🟢 BAJO |

## 3. Tabla consolidada de flujo

| Paso | Actor | Entrada | Decisión | Salida | Evidencia | Riesgo |
|------|-------|---------|----------|--------|-----------|--------|
| 0 | Codex Engine | Config persistida | Iniciar sesión, cargar contexto | ~18,5k–22k tokens (INFERIDO) | Inferido de suma de fuentes (corregido de ~29k) | 🔴 Contexto fijo masivo — pendiente Test 8 |
| 1 | Runtime | Prompt usuario | ¿@mention? ¿comando? | Agente seleccionado | opencode.json:4-51 | 🔴 Dos primaries |
| 2a | Manager | Prompt usuario | Tiny/Small/Medium/Large | Estrategia | Manager prompt | 🟡 Clasificación manual |
| 2b | gentle-orch | Prompt usuario | ¿Inline o delegate? | Acción | gentle-orch prompt | 🟢 Claro |
| 3 | Manager/gentle | Estrategia | ¿Subagente? ¿cuál? | Delegación | sdd-apply prompt:19-21 | 🟡 Subagentes faltantes |
| 4 | Subagente SDD | Contexto + skill | Ejecutar inline, no delegar | Envelope | sdd-phase-common.md:3-6 | 🟢 Executor boundary |
| 5 | Engram plugin | Post-mensaje | Capturar prompt | SQLite | engram.ts:349-381 | 🟡 Prompts completos |
| 6 | Manager | Decisión relevante | mem_save | Observación | AGENTS.md:78-106 | 🔴 DB vacía |
| 7 | Manager | Fin sesión | mem_session_summary | Resumen | AGENTS.md:134-156 | 🟡 No verificado |
| 8 | Agente activo | Resultados | Sintetizar | Respuesta | — | 🟢 |

## 4. Puntos de alto consumo de tokens

| Punto | Componente | Tokens estimados | Naturaleza |
|-------|-----------|-----------------|------------|
| System prompt completo | Codex Engine | ~18,500–22,000 (INFERIDO) ⚠️ | Fijo por sesión. Corregido de ~29k (asumía ambos AGENTS.md). Pendiente Test 8. |
| Tool schemas MCP | OpenCode runtime | ~2,000-8,000 | Fijo según MCP activos |
| Skill content cargado | skill() tool | ~2,000-10,000+ | Variable por trigger |
| Output de subagentes | task/delegate | ~1,000-20,000+ | Variable por tarea |
| Memoria recuperada | mem_search + mem_get_observation | ~500-5,000+ | Variable por query |
| Archivos leídos | read tool | ~500-50,000+ | Variable por archivo |
