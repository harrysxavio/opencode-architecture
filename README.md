# OpenCode Architecture — Agentic Runtime, Memory & Context Control

> Documentación, auditoría y evolución de una arquitectura OpenCode real.
>
> El foco: gobernar el flujo de peticiones, la memoria persistente, el consumo de tokens, las herramientas MCP y la delegación entre agentes, para que el modelo reciba **contexto limpio, mínimo, trazable y validado**.

⚠️ **Advertencia importante:** Este repositorio documenta la **arquitectura, validaciones y roadmap de evolución** del ecosistema OpenCode/Codex del usuario. La configuración runtime real (agentes, MCP, skills, plugins, memoria Engram) **vive en rutas locales** (`~/.config/opencode/`, `~/.codex/`, `~/.engram/`) y puede diferir de lo documentado aquí. Este es un **registro de análisis y decisiones**, no un mirror de configuración.

---

## Resumen

Este repositorio recorre la auditoría completa de un ecosistema OpenCode en producción: sus agentes, orquestadores, memoria, herramientas y configuración.

No es solo documentación pasiva. Es un **registro vivo de decisiones, pruebas, riesgos, ADRs y roadmap**, construido sobre evidencia real — archivos leídos, comandos ejecutados, configuraciones inspeccionadas y outputs verificados.

Cada fase responde a una pregunta concreta:

| Fase | Pregunta | Estado |
|------|----------|:------:|
| **A** — Documentación base | ¿Qué hay en el ecosistema? | ✅ |
| **B0** — Corrección documental | ¿Las afirmaciones iniciales son correctas? | ✅ |
| **B-Security** — Seguridad | ¿Hay secretos expuestos? | ✅ |
| **B1** — Observabilidad | ¿Cuánto consume realmente cada request? | ✅ |
| **C** — Tests de flujo | ¿El flujo funciona como creemos? | ✅ |
| **D** — Manager vs gentle | ¿Manager y gentle-orchestrator compiten o cooperan? | ✅ |
| **E0-E6** — Memoria Engram | ¿Engram realmente guarda memoria? ¿Y cómo gobernarla? | ✅ |
| **Suite F** — mem_context RO | ¿mem_context es seguro en modo read-only? | ✅ |
| **F** — Reducción de tokens | ¿Podemos reducir ~40k → ~9.5k tokens sin perder calidad? | 📋 **F0 completado** |
| **G** — Hybrid Retrieval | ¿Búsqueda combinada keyword + semántica? | 🔮 Futuro |
| **H** — Consolidación MCP | ¿Superficie MCP optimizada, memory server avanzado? | 🔮 Futuro |

---

## Problema que se está resolviendo

El ecosistema OpenCode analizado tenía:

- **Múltiples capas de contexto** duplicadas entre `AGENTS.md`, plugin `engram.ts`, prompts de subagentes y skills.
- **Agentes primarios ambiguos** — Manager y gentle-orchestrator declarados ambos como `mode: "primary"`.
- **Instrucciones duplicadas** — el protocolo de memoria vivía en al menos 3 lugares distintos.
- **Engram mal entendido** — los diagnósticos iniciales miraron la base de datos equivocada y concluyeron erróneamente que Engram "no persistía".
- **MCP duplicados** — 9+ servidores configurados, varios redundantes, secretos expuestos en texto plano.
- **Riesgo de tokens altos** — sin medición ni control del contexto que recibe el modelo.
- **Ausencia de evidencia** — no había registro sistemático de qué ocurría realmente en runtime.

El objetivo de este repositorio **no es agregar más agentes**. Es:

1. **Reducir ambigüedad** — quién orquesta, quién ejecuta, quién decide.
2. **Gobernar la memoria** — qué se guarda, cómo se organiza, cómo se recupera.
3. **Entregar contexto mínimo y trazable** al modelo, no un volcado de instrucciones.
4. **Medir antes de optimizar** — baseline de tokens, tiempo, decisiones.

---

## Principio rector

> **El modelo no debe ser una base de datos.**
>
> El modelo debe recibir **contexto limpio, mínimo, trazable y validado**.
>
> La memoria debe ser una **biblioteca viva de decisiones, errores, criterios, reglas y estado útil**; no un basurero de prompts ni conversaciones completas.

Cada línea que inyectamos al modelo tiene un costo: ocupa espacio en la ventana de contexto, compite con instrucciones más importantes y puede introducir ruido. Gobernar ese espacio es el trabajo central de este proyecto.

---

## Arquitectura objetivo

| Componente | Rol | Estado |
|------------|-----|:------:|
| **Manager** | Orquestador primario, router, decisor, sintetizador final. Controla el pipeline completo. | ✅ Estable |
| **gentle-orchestrator** | SDD Pipeline invocable por Manager en tareas Medium/Large. **No compite como primary.** | ✅ Estable |
| **sdd-{explore,propose,spec,design,tasks,apply,verify,archive}** | Subagentes ejecutores de cada fase SDD. No orquestan. | ✅ Estable |
| **Engram** | Sistema de memoria persistente cross-session, gobernado por política (no por defecto). | ✅ E4B-E6B estabilizado |
| **Noise Gate (E6B)** | Filtro de prompts capturados: bloquea ruido, secretos, navegación trivial; captura solo lo útil. | ✅ Implementado |
| **Context Packs (E5)** | 7 contratos (Context Pack, Writer, Validator, Read Escalation, Quality Metrics, Intake Cleaner). | ✅ Completado |
| **Markdown versionado** | Fuente de verdad formal de decisiones arquitectónicas (docs/, ADRs). | ✅ Activo |
| **Skill registry** | Índice de capacidades disponibles para el Manager. | ✅ Activo |
| **Inventory** | Catálogo técnico de agentes, MCP, skills y plugins. | ✅ Cache |
| **MCP / tools** | Bajo demanda. No cargados todos al inicio. | ✅ Activo |
| **Context Layers (L0-L5)** | 6 capas de contexto: Core, Identity, Phase, Memory, Session, Task. | 📋 Diseñado (Fase F) |
| **mem_context Selector** | Ranking + scoring + top-k + dedup de memorias Engram. | 📋 Diseñado (F3) |
| **Context Packs (8 packs)** | PROJECT_IDENTITY, ACTIVE_PHASE, VALIDATION_STATUS, RISK_REGISTER, DECISION_LOG, RELEVANT_MEMORY, RECENT_SESSION, TASK_SPECIFIC. | 📋 Diseñado (F4) |
| **Token Budget Contract** | 5 modos (Simple ~6k, Normal ~9.5k, Arquitectura ~14k, Auditoría ~19k, Excepcional >22k). | 📋 Diseñado (F2) |

---

## Qué se validó hasta ahora

| Área | Estado | Hallazgo |
|------|:------:|----------|
| **Manager primary** | ✅ Validado | Manager responde por defecto en sesiones sin mención explícita de gentle-orchestrator |
| **gentle-orchestrator como SDD** | ✅ Resuelto | Pasó a ser SDD Pipeline subagent; ya no compite como primary |
| **Tiny flow** | ✅ Validado | Manager responde directo sin sobreorquestación para cambios pequeños |
| **B-Security — secretos** | ✅ Completado | Secretos rotados (GitHub PAT, Browserbase), git history limpio, 5 backups eliminados |
| **B1 — Observabilidad** | ✅ Completado | Baseline T8 ejecutado, T1 validado, diseño de observabilidad creado (ADR-009) |
| **Tokens reales — baseline** | ✅ **F0 completado** | ~40k por sesión típica **medido y desglosado por fuente**. Manager protocol: 28.5KB (~7k–14k tokens). AGENTS.md: 13.4KB (~3.4k tokens). 40 skills únicos: 308KB total (~77k tokens, cargados bajo demanda). Herramientas: 16 schemas (~3k–6k tokens). Engram: 84 memorias relevantes (~95KB). Duplicación Manager/AGENTS.md confirmada (~2k–3k tokens). **Baseline documentado con medición reproducible.** |
| **Engram store real** | ✅ Validado | Store real es `~/.engram/engram.db`. **NO** `.codex/memories_1.sqlite`. DB: ~3MB, 326 observaciones, 312 user_prompts, 79 sesiones, 209 relaciones. |
| **Engram herramientas** | ✅ Validado | `mem_save`, `mem_search`, `mem_context`, `mem_session_summary`, `mem_judge` funcionan operativamente |
| **Engram persistencia** | ✅ Validado | Engram MCP/DB funcionan. Noise Gate implementado (E6B) y validado T1-T7 PASS. Captura funciona en sesión canonical. |
| **E6B — Noise Gate** | ✅ **COMPLETE** | 7 tests PASS. Ruido trivial filtrado (T1-T2). Preguntas útiles capturadas (T3-T4). Secretos `ghp_` bloqueados (T5). Navegación trivial filtrada (T6). Default capture funciona (T7). |
| **Suite F — mem_context RO** | ✅ **COMPLETE** | 6 tests PASS. Happy path canonical (F1). Proyecto inexistente graceful (F2). Cross-project documentado (F3). Idempotencia — 0 cambios DB (F4). Timeline cotejado con sqlite3 (F5). Solo Engram tools — sin subagentes ni escritura (F6). |
| **Riesgo Engram** | ⚠️ Parcial | Project drift persiste en sesiones legacy; sesión canonical `opencode-architecture` funciona sin mismatch. Suite F validó mem_context read-only (F1-F6 PASS). |
| **MCP** | 🔶 Parcial | Context7 funciona bajo intención explícita. Playwright operativo. Duplicación entre opencode.json y .jsonc. |
| **Context Pack (E5)** | ✅ Completado | 7 contratos definidos y testeados. 7 tests PASS. |
| **F0 — Token Audit Baseline** | ✅ **COMPLETED** | ~35k–45k tokens medido. 6 fuentes fijas (~17.5k–29.5k), 3 fuentes dinámicas (~7.5k–18k), duplicación confirmada (~3k–5k). 6 quick wins identificados. Medición reproducible documentada. **Sin cambios funcionales.** |
| **Hybrid Retrieval** | 🔮 Futuro | No bloquear Engram stabilization. Se abordará como Fase G. |

---

## Engram en esta arquitectura

### ¿Qué es Engram?

Engram es el **sistema de memoria persistente cross-session** del ecosistema OpenCode. No es un simple log de conversaciones — es una **biblioteca viva** de decisiones, bugs, descubrimientos, sesiones y estado del proyecto, accesible desde cualquier sesión futura mediante búsqueda semántica y contextual.

### ¿Cómo está integrado?

```
┌─────────────────────────────────────────────────────────────────┐
│                      OpenCode Runtime                           │
├─────────────────────────────────────────────────────────────────┤
│  AGENTE (Manager / subagentes)                                  │
│    │                                                            │
│    ├─ mem_save() ──────────────► Engram MCP ──► engram.db      │
│    ├─ mem_search() ◄─────────────── "         ◄── "            │
│    ├─ mem_context() ◄────────────── "         ◄── "            │
│    └─ mem_session_summary() ────► "         ──► "              │
│                                                                 │
│  PLUGIN (engram.ts) — Noise Gate activo                        │
│    │                                                            │
│    └─ Captura prompts útiles ──► user_prompts (SQLite)          │
│       (filtra ruido, secretos, navegación trivial)             │
│                                                                 │
│  DATABASE (~/.engram/engram.db) — ~3MB                          │
│    ├─ observations (326): decisiones, bugs, descubrimientos     │
│    ├─ user_prompts (312): prompts capturados con Noise Gate     │
│    ├─ sessions (79): sesiones registradas                       │
│    └─ memory_relations (209): vínculos entre memorias           │
└─────────────────────────────────────────────────────────────────┘
```

### ¿Qué almacena?

Engram guarda **solo lo que aporta valor cross-session**:

| Tipo | ¿Se guarda? | Ejemplo |
|------|:-----------:|---------|
| Decisiones arquitectónicas | ✅ Sí | "Manager único primary. gentle es SDD pipeline" |
| Bugs resueltos con root cause | ✅ Sí | "N+1 query en UserList — root cause: falta de eager loading" |
| Descubrimientos no obvios | ✅ Sí | "FTS5 no escapa caracteres especiales en búsqueda" |
| Patrones establecidos | ✅ Sí | "Patrón de validación para IDs numéricos" |
| Resúmenes de sesión | ✅ Sí | "E6B COMPLETE — T1-T7 PASS" |
| Preferencias del usuario | ✅ Sí | "Respuestas cortas, Rioplatense, voseo" |
| Artefactos SDD (técnicos) | ✅ Sí (sin prompt capture) | "sdd/change-name/explore, propose, spec, design, tasks" |
| Prompts útiles del usuario | ✅ Sí (con Noise Gate) | Preguntas de arquitectura, instrucciones de diseño |
| Ruido trivial | ❌ No (filtrado) | "listo", "ok gracias jajaja" |
| Secretos / tokens | ❌ No (bloqueado) | `ghp_*`, `sk-*` |
| Navegación trivial | ❌ No (filtrado) | "muéstrame el README" |
| Conversaciones enteras | ❌ No | Solo lo relevante, no el diálogo completo |

### ¿Cómo lo usa el Manager?

El Manager orquesta la memoria así:

1. **Al iniciar una tarea**: `mem_search(query, project)` para saber si ya hay contexto previo.
2. **Para entender el proyecto**: `mem_context` recupera el resumen de sesiones recientes y decisiones activas.
3. **Al descubrir algo importante**: `mem_save(type, title, content)` guarda el hallazgo.
4. **Al cerrar sesión**: `mem_session_summary` registra el progreso para la próxima sesión.
5. **Para filtrar ruido**: El Noise Gate (E6B) decide qué prompts merecen ser capturados en `user_prompts`.

### ¿Qué fases de evolución atravesó?

| Fase | Logro |
|:----:|-------|
| **E0-E3** — Diagnóstico | Identificó el store real (`~/.engram/engram.db`), corrigió el error de diagnóstico de Fase B0 que apuntaba a la DB equivocada |
| **E4B** — Estabilización | Pin a v1.16.1 + `--project=opencode-architecture`. Tests T1-T7 PASS. Sin session_project_mismatch en sesión canonical |
| **E5** — Gobernanza | 7 contratos (Context Pack, Writer, Validator, Read Escalation, Quality Metrics, Intake Cleaner). 7 tests PASS |
| **E6A/E6B** — Noise Gate | Filtro de captura implementado y validado: ruido bloqueado, secretos bloqueados, preguntas útiles capturadas |
| **Suite F** — Read-only | `mem_context` validado en modo solo-lectura: idempotente, sin cambios DB, graceful en proyectos inexistentes |
| **F (planning)** — Token reduction | F0 completado (baseline ~40k). F1-F6 diseñados: capas L0-L5, selector con ranking/scoring/top-k, 8 context packs, 5 modos de budget |

### ¿Qué NO es Engram?

- ❌ **No es una base de datos conversacional** — no guarda cada interacción.
- ❌ **No reemplaza los ADRs** — las decisiones formales viven en Markdown versionado.
- ❌ **No es Graphify** — Graphify es grafo de relaciones del proyecto, Engram es memoria semántica de decisiones.
- ❌ **No es un reemplazo de config** — la configuración runtime vive en `opencode.json`.
- ❌ **No es el store de `.codex/memories_1.sqlite`** — esa DB es de Codex legacy, no de Engram.

---

## Roadmap ejecutado y planificado

| Fase | Estado | Descripción |
|------|:------:|-------------|
| **A** — Documentación base | ✅ | Mapa inicial de componentes, flujo request/response, inventario |
| **B0** — Corrección documental | ✅ | Validación read-only de afirmaciones iniciales, corrección de hallazgos |
| **B-Security** — Seguridad | ✅ | Rotación de secretos expuestos, limpieza de git history y backups |
| **B1** — Observabilidad mínima | ✅ | Baseline de tokens (T8), validación Manager primary (T1), ADR-009 |
| **C** — Tests de flujo | ✅ | 8 tests reproducibles ejecutados sobre flujo real (T1-T8) |
| **D** — Manager ↔ gentle | ✅ | ADR-001/003/008: Manager como único primary, gentle como SDD pipeline |
| **E0-E3** — Diagnóstico Engram | ✅ | Store real identificado, pruebas controladas, root cause, change plan |
| **E4A** — Gap review | ✅ | Revisión read-only de brechas en arquitectura de memoria |
| **E4A-Docs-Cleanup** | ✅ | README raíz reescrito, docs README convertido a índice mínimo |
| **E4A-Docs-Cleanup-v2** | ✅ | README raíz enriquecido como entrada completa del proyecto |
| **E4B** — Engram stabilization | ✅ **Completada** | Pin a v1.16.1 + `--project=opencode-architecture`. Tests T1-T7 PASSED |
| **E5** — Context Pack | ✅ **Completada** | 7 contratos (Context Pack, Writer, Validator, Read Escalation, Quality Metrics, Intake Cleaner). 7 tests PASSED |
| **E6A** — Prompt Capture Audit & Design | ✅ **Completada** | Audit de plugin engram.ts y DB, Noise Gate design (Opción B — Heurísticas). 7 tests PASSED |
| **E6B** — Noise Gate implementation | ✅ **COMPLETE** | Noise Gate reimplementado y validado formalmente. T1-T7 all PASS. Secretos bloqueados, ruido filtrado, captura útil funcionando. |
| **Suite F** — mem_context read-only | ✅ **COMPLETE** | mem_context validado en modo read-only: happy path, graceful en proyecto inexistente, cross-project documentado, idempotencia. F1-F6 all PASS. |
| **F0** — Token Audit Baseline | ✅ **COMPLETE** | ~35k–45k tokens medido y desglosado por fuente. 6 quick wins identificados. Duplicación Manager/AGENTS.md confirmada. Baseline documentado con medición reproducible. |
| **F1** — Context Inventory | 📋 Pendiente | Catalogar cada fuente de contexto con más detalle (qué contiene, cuándo es necesaria, redundancia) |
| **F2** — Context Budget Contract | 📋 Diseñado | 5 modos (Simple ~6k, Normal ~9.5k, Arquitectura ~14k, Auditoría ~19k, Excepcional >22k). Budgets por capa L0-L5. |
| **F3** — mem_context Selector | 📋 Diseñado | Ranking por score semántico, top-k configurable, deduplicación, filtro de proyectos legacy |
| **F4** — Context Packs | 📋 Diseñado | 8 packs (PROJECT_IDENTITY, ACTIVE_PHASE, VALIDATION_STATUS, RISK_REGISTER, DECISION_LOG, RELEVANT_MEMORY, RECENT_SESSION, TASK_SPECIFIC) |
| **F5** — Regression Plan Execution | 📋 Diseñado | 6 gates obligatorios (E6B, Suite F, Token Budget, Quality, Security, Regression E2E). Rollback criteria. |
| **F6** — Rollout Controlado | 📋 Planificado | Feature flag, monitoreo, rollback plan. Aprobación explícita del usuario requerida. |
| **G** — Hybrid Retrieval | 🔮 Futuro | Búsqueda combinada keyword + semántica |
| **H** — MCP consolidation | 🔮 Futuro | Superficie MCP optimizada, memory server avanzado |

---

## Cómo leer este repositorio

| Si quieres entender… | Lee |
|----------------------|-----|
| **Visión general y decisiones ejecutivas** | [00-executive-summary.md](docs/opencode-architecture/00-executive-summary.md) |
| **La foto completa del ecosistema hoy** | [01-current-state-map.md](docs/opencode-architecture/01-current-state-map.md) |
| **Cómo fluye una petición de principio a fin** | [02-request-response-flow.md](docs/opencode-architecture/02-request-response-flow.md) |
| **Quién hace qué (matriz de agentes)** | [03-agent-responsibility-map.md](docs/opencode-architecture/03-agent-responsibility-map.md) |
| **Memoria y contexto: fuentes, Engram, riesgos** | [04-memory-context-map.md](docs/opencode-architecture/04-memory-context-map.md), [16-memory-governance-policy.md](docs/opencode-architecture/16-memory-governance-policy.md), test-runs E |
| **Cuánto cuesta cada request en tokens** | [05-token-cost-map.md](docs/opencode-architecture/05-token-cost-map.md), [11-memory-and-token-optimization-model.md](docs/opencode-architecture/11-memory-and-token-optimization-model.md) |
| **Inventario de tools, MCP y skills** | [06-tools-mcp-skills-map.md](docs/opencode-architecture/06-tools-mcp-skills-map.md) |
| **Evidencia recopilada (cada afirmación con fuente)** | [07-evidence-register.md](docs/opencode-architecture/07-evidence-register.md) |
| **Conflictos entre auditorías y preguntas abiertas** | [08-conflicts-and-open-questions.md](docs/opencode-architecture/08-conflicts-and-open-questions.md) |
| **Riesgos con severidad y mitigación** | [09-risk-register.md](docs/opencode-architecture/09-risk-register.md) |
| **Arquitectura objetivo** | [10-target-architecture.md](docs/opencode-architecture/10-target-architecture.md) |
| **Roadmap completo por fases** | [12-migration-roadmap.md](docs/opencode-architecture/12-migration-roadmap.md) |
| **Plan de pruebas de validación** | [13-validation-test-plan.md](docs/opencode-architecture/13-validation-test-plan.md) |
| **Resultados de validaciones ejecutadas** | [14-runtime-validation-results.md](docs/opencode-architecture/14-runtime-validation-results.md) |
| **Estrategia de transición Manager/gentle** | [17-manager-gentle-transition-plan.md](docs/opencode-architecture/17-manager-gentle-transition-plan.md), ADR-001, ADR-003, ADR-008 |
| **Decisiones arquitectónicas (ADRs)** | [docs/opencode-architecture/adr/](docs/opencode-architecture/adr/) |
| **Ejecuciones reales de pruebas** | [docs/opencode-architecture/test-runs/](docs/opencode-architecture/test-runs/) |
| **Context Pack Contract** | [19-context-pack-contract.md](docs/opencode-architecture/19-context-pack-contract.md), test-runs/E5 |
| **Memory Writer/Validator** | [20-memory-writer-validator-contract.md](docs/opencode-architecture/20-memory-writer-validator-contract.md), test-runs/E5 |
| **Read Escalation Policy** | [21-read-escalation-policy.md](docs/opencode-architecture/21-read-escalation-policy.md) |
| **Memory Quality Metrics** | [22-memory-quality-metrics.md](docs/opencode-architecture/22-memory-quality-metrics.md) |
| **Prompt Capture Audit (E6A)** | [23-prompt-capture-audit.md](docs/opencode-architecture/23-prompt-capture-audit.md) |
| **Noise Gate Design (E6A)** | [24-noise-gate-design.md](docs/opencode-architecture/24-noise-gate-design.md) |
| **Arquitectura de proyecto replicable** | [15-replicable-project-architecture.md](docs/opencode-architecture/15-replicable-project-architecture.md) |
| **Fase F — Token Reduction (PLANNING)** | [docs/opencode-architecture/phases/F-token-reduction/](docs/opencode-architecture/phases/F-token-reduction/) |
| **F0 — Token Audit Baseline** | [docs/opencode-architecture/phases/F-token-reduction/baseline-tokens.md](docs/opencode-architecture/phases/F-token-reduction/baseline-tokens.md) |

---

## Hallazgos clave descubiertos en las auditorías

### 🔍 Engram: el diagnóstico que miraba la DB equivocada

El hallazgo más impactante de la Fase E: el diagnóstico inicial (Fase B0) inspeccionó `.codex/memories_1.sqlite` y concluyó que Engram "no persistía memoria". **Esa DB no es el store semántico de Engram.** El store real es `~/.engram/engram.db`, con 326 observaciones, 312 prompts capturados, 79 sesiones registradas y 209 relaciones.

**Engram sí funciona.** El problema real era otro: faltaba gobernanza sobre qué se guarda, cómo se organiza y cómo se recupera. Eso se resolvió con el Noise Gate (E6B) y los contratos (E5).

### 🏗️ Manager y gentle-orchestrator ya no compiten

La ambigüedad de `mode: "primary"` quedó resuelta en Fase D: Manager es el orquestador real, gentle-orchestrator opera como SDD Pipeline invocable. Las ADR-001, ADR-003 y ADR-008 documentan la separación.

### 🧪 E6B — Noise Gate: ruido bloqueado, secretos detenidos, captura útil

El Noise Gate implementado sobre el plugin `engram.ts` filtra en 3 capas:

| Capa | Función | Resultado |
|:----:|---------|:---------:|
| **Confirmaciones triviales** | Bloquea "listo", "ok gracias", "dale" | T1-T2 PASS |
| **Secretos** | Bloquea `ghp_*`, `sk-*`, cualquier patrón de credencial | T5 PASS |
| **Navegación trivial** | Bloquea "muéstrame el archivo X", "abrí tal cosa" | T6 PASS |
| **Default capture** | Captura preguntas útiles, instrucciones de diseño | T3-T4, T7 PASS |

7 tests formales PASS. Sin session_project_mismatch en sesión canonical.

### ✅ Suite F — mem_context read-only no modifica nada

Se validó que `mem_context` es seguro en modo read-only:

| Afirmación | Evidencia |
|------------|-----------|
| Happy path canonical funciona | F1: 3 architecture memories relevantes |
| Proyecto inexistente no falla | F2: "No memories found" graceful |
| Cross-project se documenta correctamente | F3: devuelve contexto con nota de proyecto ajeno |
| Es 100% idempotente | F4: 0 cambios en DB tras 10 ejecuciones |
| Timeline cotejado con datos reales | F5: contenido verificado contra sqlite3 |
| Solo usa Engram tools | F6: sin subagentes, sin escritura, sin efectos secundarios |

### 📏 El costo real de contexto: ~40k tokens medidos y desglosados

**F0** completó la primera medición sistemática. Esto es lo que encontramos:

| Fuente | Est. tokens | % estimado |
|--------|:-----------:|:----------:|
| Manager protocol (28.5KB) | ~7,100–14,200 | 20–28% |
| AGENTS.md persona + engram (13.4KB) | ~3,400 | 7–10% |
| OpenCode core prompt (built-in) | ~2,000–3,000 | 5–7% |
| Tool schemas (16 tools) | ~3,200–6,400 | 8–13% |
| Skills block + skills cargados | ~2,300–7,300 | 6–15% |
| Engram memories (84 relevantes, ~95KB) | ~1,250–3,750 | 3–8% |
| Session history | ~5,000–8,000 | 12–18% |
| **Duplicación Manager/AGENTS.md** | **~2,000–3,000** | **5–7% derrochable** |
| **Total** | **~35k–45k** | **100%** |

**Sorpresa confirmada:** El Manager protocol (28.5KB) y el AGENTS.md (13.4KB) **se superponen** — el protocolo de Engram y las reglas de persona están en ambos. Eso son ~2k–3k tokens que se pueden recuperar solo con deduplicación.

**Quick wins identificados (F0):**

1. **Session history compactado** (resumen vs crudo) → ~3k–5k tokens
2. **Tool schemas bajo demanda** → ~2k–4k tokens
3. **Memorias rankeadas + top-k** → ~1k–2.5k tokens
4. **Skills selectivos** (solo los que matchean) → ~500–1k tokens
5. **Deduplicación Manager/AGENTS.md** → ~2k–3k tokens
6. **Separar modos de contexto** (Simple/Normal/Arquitectura/Auditoría) → ~8k–12k tokens

### 🧩 No implementar híbrido ni MCP avanzado hasta Engram estable y tokens gobernados

Hybrid Retrieval (semántico + keyword) y MCP memory server son tentadores, pero premature optimization. Primero hay que tener:
1. ✅ La memoria baseline funcionando (E4B)
2. ✅ Con gobernanza (E5 contratos, E6B Noise Gate)
3. ✅ Validada en modo read-only (Suite F)
4. 📋 Con reducción de tokens planificada (Fase F)
5. 🔮 Recién entonces: G (Hybrid), H (MCP consolidation)

### 📐 El principio rector aplicado en cada fase

> **El modelo no es una base de datos.**

Este principio recorrió todas las fases: el LLM no debe recibir conversaciones enteras, logs ni ruido. Debe recibir contexto curado, con las decisiones activas, errores conocidos, estado actual y referencias a documentos relevantes. Cada fase aplicó este principio:

- **E5**: Contratos Writer/Validator evitan guardar ruido en Engram.
- **E6B**: Noise Gate evita capturar prompts triviales o secretos.
- **Suite F**: `mem_context` solo lee, nunca escribe.
- **Fase F**: Capas L0-L5 y Context Packs diseñados para entregar **el mínimo contexto necesario para cada tipo de tarea**.

---

## Qué NO es este repositorio

- ❌ No es un mirror completo de la configuración local de OpenCode.
- ❌ No contiene secretos, tokens ni credenciales.
- ❌ No reemplaza las rutas runtime (`~/.config/opencode/`, `~/.codex/`, `~/.engram/`).
- ❌ No debe usarse para aplicar cambios en runtime sin validación cruzada.
- ❌ No busca crear sobreingeniería de agentes — el objetivo es **simplificar y gobernar**, no agregar capas.

---

## Estado de seguridad

| Aspecto | Estado |
|---------|:------:|
| Secretos en config.toml | ✅ B-Security completada. GitHub PAT actualizado, Browserbase eliminado |
| Git history | ✅ Sin fugas. Verificado con `git log --all -p` |
| Backups | ✅ 5 backups con secretos eliminados de `~/.codex/` |
| Riesgo residual | 🟢 Bajo. No hay secretos en texto plano en ninguna ubicación conocida |
| Noise Gate (E6B) | ✅ Bloquea `ghp_*`, `sk-*` y patrones de credenciales en captura de prompts |
| Regla vigente | No guardar secretos en docs, Engram, prompts ni ADRs. Las credenciales viven fuera del repositorio |

---

## Estado actual y próximo paso

**Estado actual:** `E6B COMPLETE — T1-T7 all PASS` + `Suite F COMPLETE — F1-F6 all PASS` + **`F0 COMPLETE — baseline ~40k medido`**. Noise Gate implementado y validado. mem_context validado en modo read-only. Baseline de tokens medido con desglose por fuente. **Fase F en progreso — F0 completado, F1 pendiente.**

**Estado fases:** E0-E4B ✅, E5 ✅, E6A ✅, E6B ✅, Suite F ✅, **F0 ✅**, F1-F6 📋 Pendiente/Diseñado.

### Resultados de E4B

| Test | Resultado | Detalle |
|------|:---------:|---------|
| T1 — Procesos | ✅ PASS | OpenCode usa v1.16.1; 3 procesos legacy v1.15.13 sin interferencia |
| T2 — Doctor | ✅ PASS | 4/4 checks OK, 0 errores, 0 drift |
| T3 — mem_context | ✅ PASS | Recupera contexto relevante de `opencode-architecture`, source `explicit_override` |
| T4 — mem_save ficticio | ✅ PASS | Memoria TEST-E4B-STABILIZATION guardada (id=400) |
| T5 — mem_search | ✅ PASS | Recupera id=400 correctamente |
| T6 — mem_session_summary | ✅ PASS | Guardado como `observations.type=session_summary` (id=401) |
| T7 — No guardar ruido | ✅ PASS | Sin `mem_save` por ruido; user_prompts sin nuevos capturados |

### Lo que E4B NO modificó

- ❌ Plugin `engram.ts`
- ❌ `AGENTS.md`
- ❌ Optimización de tokens
- ❌ MCP surface general
- ❌ Hybrid Retrieval
- ❌ Memory server avanzado

### Resultados de E5 — Context Pack Contracts

| Test | Resultado | Detalle |
|------|:---------:|---------|
| T1 — Context Pack contract | ✅ PASS | 3.000 tokens, 3 memorias, 3 secciones, 2 archivos. Sin ambigüedades |
| T2 — Intake/Cleaner contract | ✅ PASS | 4 etapas: intake → clean → classify → store. Sin solapamiento con Writer |
| T3 — Memory Retriever contract | ✅ PASS | 3 retrievers (recent, search, context), 2 combinadores (priority, cascade) |
| T4 — Memory Writer contract | ✅ PASS | 8 tipos guardan, 7 tipos no guardan. Sin ambigüedad en "comando de navegación" |
| T5 — Memory Validator contract | ✅ PASS | 4 validadores (3 obligatorios, 1 informativo). Validación pre-escritura |
| T6 — Read Escalation Policy | ✅ PASS | 7 niveles definidos con criterio de stop en evidencia suficiente |
| T7 — Memory Quality Metrics | ✅ PASS | 14 campos mínimos, 6 dimensiones de calidad |

**Archivos creados:** 4 documentos centrales (19-22), 9 reportes de test en `test-runs/E5/`

### Resultados de E6A — Prompt Capture Audit & Design

| Test | Resultado | Detalle |
|------|:---------:|---------|
| T1 — Audit completeness | ✅ PASS | Flujo, hook, filtros actuales, diferencia user_prompts vs observations documentados |
| T2 — DB inventory | ✅ PASS | 302 registros, min/max/avg verificados contra DB real |
| T3 — Risk classification | ✅ PASS | R1-R5 identificados con mitigaciones en diseño |
| T4 — Design options evaluation | ✅ PASS | 3 opciones evaluadas (A: Blacklist, B: Heurísticas, C: Híbrido). Recomendación: B |
| T5 — Contract alignment (E5) | ✅ PASS | Noise Gate y contratos E5 son complementarios, sin conflicto |
| T6 — Implementation spec completeness | ✅ PASS | Spec accionable: código, schema, config, migración, rollback |
| T7 — Rollback readiness | ✅ PASS | 4 escenarios con plan de rollback. Tiempo máximo: 10s (config switch) |

**Archivos creados:** 2 documentos (23-audit, 24-design), 7 tests en `test-runs/E6/`

### E6B — Noise Gate: COMPLETE ✅

El Noise Gate fue implementado (D6) sobre el plugin Node-compatible y validado formalmente con 7 tests (T1-T7) todos PASS.

**Resumen de validación:**

| Test | Input | Resultado |
|:----:|-------|:---------:|
| T1 | `ok gracias jajaja` | ✅ Filtrado (confirmación trivial) |
| T2 | `listo` | ✅ Filtrado (confirmación trivial) |
| T3 | `¿Qué rol cumple Engram en esta arquitectura?` | ✅ Capturado (pregunta útil) |
| T4 | `Diseña una prueba read-only para validar mem_context.` | ✅ Capturado (instrucción diseño) |
| T5 | `Mi token falso es ghp_FAKE...` | ✅ Bloqueado (secreto detectado) |
| T6 | `muéstrame el archivo README` | ✅ Filtrado (navegación trivial) |
| T7 | `Continúa con la arquitectura OpenCode.` | ✅ Capturado (default capture) |

**Store real:** `C:\Users\harry\.engram\engram.db` — intacto, sin cambios de schema.
**Plugin:** `engram.ts` con `ALLOW_PROMPT_CAPTURE="classified"`, `DEBUG_ENGRAM_PLUGIN=false`.
**Sesión requerida:** Canonical `opencode-architecture` (legacy `arquitectura opencode` causa `session_project_mismatch`).

### Suite F — mem_context read-only: COMPLETE ✅

| Test | Qué validó | Resultado |
|:----:|------------|:---------:|
| F-T1 | Happy path canonical | ✅ PASS — 3 architecture memories relevantes |
| F-T2 | Proyecto inexistente | ✅ PASS — "No memories found" graceful |
| F-T3 | Sin --project | ✅ PASS — cross-project documentado |
| F-T4 | Idempotencia | ✅ PASS — 0 cambios DB |
| F-T5 | Cross-verify timeline | ✅ PASS — cotejo con sqlite3 |
| F-T6 | Solo Engram tools | ✅ PASS — sin subagentes ni escritura |

### F0 — Token Audit Baseline: COMPLETE ✅

| Métrica | Valor |
|---------|:-----:|
| Total estimado sesión típica | ~35k–45k tokens |
| Fuentes fijas | ~17.5k–29.5k tokens |
| Fuentes dinámicas | ~7.5k–18k tokens |
| Duplicación Manager/AGENTS.md | ~2k–3k tokens derrochables |
| Archivo entregado | `baseline-tokens.md` con desglose, quick wins y medición reproducible |
| Cambios funcionales | ❌ **0** — solo medición y documentación |

**Principales quick wins identificados:**
1. Session history compactado → ~3k–5k tokens
2. Tool schemas bajo demanda → ~2k–4k tokens
3. Memorias rankeadas + top-k → ~1k–2.5k tokens
4. Skills selectivos → ~500–1k tokens
5. Deduplicación Manager/AGENTS.md → ~2k–3k tokens
6. Separar modos de contexto → ~8k–12k tokens

---

*Última actualización: 2026-06-16. E6B COMPLETE, Suite F COMPLETE, F0 COMPLETE, Fase F en progreso.*
