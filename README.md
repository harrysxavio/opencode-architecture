# OpenCode Architecture — Agentic Runtime, Memory & Context Control

> Documentación, auditoría y evolución de una arquitectura OpenCode real
>
> El foco: gobernar el flujo de peticiones, la memoria persistente, el consumo de tokens, las herramientas MCP y la delegación entre agentes, para que el modelo reciba **contexto limpio, mínimo, trazable y validado**.

⚠️ **Advertencia importante:** Este repositorio documenta la **arquitectura, validaciones y roadmap de evolución** del ecosistema OpenCode/Codex del usuario. La configuración runtime real (agentes, MCP, skills, plugins, memoria Engram) **vive en rutas locales** (`~/.config/opencode/`, `~/.codex/`, `~/.engram/`) y puede diferir de lo documentado aquí. Este es un **registro de análisis y decisiones**, no un mirror de configuración.

---

## Resumen

Este repositorio recorre la auditoría completa de un ecosistema OpenCode en producción: sus agentes, orquestadores, memoria, herramientas y configuración.

No es solo documentación pasiva. Es un **registro vivo de decisiones, pruebas, riesgos, ADRs y roadmap de migración**, construido sobre evidencia real — archivos leídos, comandos ejecutados, configuraciones inspeccionadas y outputs verificados.

Cada fase responde a una pregunta concreta:

| Fase | Pregunta |
|------|----------|
| A | ¿Qué hay en el ecosistema? |
| B0 | ¿Las afirmaciones iniciales son correctas? |
| B-Security | ¿Hay secretos expuestos? |
| B1 | ¿Cuánto consume realmente cada request? |
| C | ¿El flujo funciona como creemos? |
| D | ¿Manager y gentle-orchestrator compiten o cooperan? |
| E | ¿Engram realmente guarda memoria? ¿Y cómo gobernarla? |

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

| Componente | Rol |
|---|---|
| **Manager** | Orquestador primario, router, decisor, sintetizador final. Controla el pipeline completo. |
| **gentle-orchestrator** | SDD Pipeline invocable por Manager en tareas Medium/Large. **No compite como primary.** |
| **sdd-{explore,propose,spec,design,tasks,apply,verify,archive}** | Subagentes ejecutores de cada fase SDD. No orquestan. |
| **Engram** | Sistema de memoria persistente cross-session, gobernado por política (no por defecto). |
| **Markdown + ADRs** | Fuente de verdad formal de decisiones arquitectónicas. |
| **Skill registry** | Índice de capacidades disponibles para el Manager. |
| **Inventory** | Catálogo técnico de agentes, MCP, skills y plugins. |
| **MCP / tools** | Bajo demanda. No cargados todos al inicio. |
| **Context Pack** | Contrato futuro (Fase E5) para entregar contexto estructurado y limpio al modelo. |

---

## Qué se validó hasta ahora

| Área | Estado | Hallazgo |
|---|---|---|
| **Manager primary** | ✅ Validado | Manager responde por defecto en sesiones sin mención explícita de gentle-orchestrator |
| **gentle-orchestrator** | ✅ Resuelto | Pasó a ser SDD Pipeline subagent; ya no compite como primary |
| **Tiny flow** | ✅ Validado | Manager responde directo sin sobreorquestación para cambios pequeños |
| **Tokens reales** | ✅ Validado (parcial) | Test T8 midió ~40k tokens de input en sesión típica. Falta medición sistemática |
| **B-Security** | ✅ Completado | Secretos rotados (GitHub PAT, Browserbase), git history limpio, 5 backups eliminados |
| **B1 — Observabilidad** | ✅ Completado | Baseline T8 ejecutado, T1 validado, diseño de observabilidad creado (ADR-009) |
| **Engram store real** | ✅ Validado | Store real es `~/.engram/engram.db`. NO `.codex/memories_1.sqlite` |
| **Engram herramientas** | ✅ Validado | `mem_save`, `mem_search`, `mem_context`, `mem_session_summary`, `mem_judge` funcionan operativamente |
| **Engram persistencia** | ✅ Validado | 292 observations, 302 user_prompts, 68 sessions — Engram **sí escribe** |
| **Riesgo Engram** | ⚠️ Parcial | Project drift resuelto (E4B). Prompt capture sin gate (302 capturas), duplicación opencode.jsonc, bin legacy v1.15.13 en Codex |
| **MCP** | 🔶 Parcial | Context7 funciona bajo intención explícita. Playwright operativo. Duplicación entre opencode.json y .jsonc |
| **Context Pack** | ⏳ Pendiente | Requerimiento detectado en E4A. Necesario antes de optimizar tokens |
| **Hybrid Retrieval** | 🔮 Futuro | No bloquear Engram stabilization. Se abordará como Fase G |

---

## Roadmap ejecutado y planificado

| Fase | Estado | Descripción |
|---|---|---|
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
| **E6B** — Noise Gate implementation | ⏳ Pendiente de aprobación | Implementar gate con heurísticas en plugin + config |
| **F** — Token reduction | ⏳ Pendiente (post-E5) | Reducción de contexto con Context Pack como base |
| **G** — Hybrid Retrieval | 🔮 Futuro | Búsqueda combinada keyword + semántica |
| **H** — MCP consolidation | 🔮 Futuro | Superficie MCP optimizada, memory server avanzado |

---

## Cómo leer este repositorio

| Si quieres entender… | Lee |
|---|---|
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

---

## Hallazgos clave descubiertos en las auditorías

### 🔍 Engram: el diagnóstico que miraba la DB equivocada

El hallazgo más impactante de la Fase E: el diagnóstico inicial (Fase B0) inspeccionó `.codex/memories_1.sqlite` y concluyó que Engram "no persistía memoria". **Esa DB no es el store semántico de Engram.** El store real es `~/.engram/engram.db`, con 292 observaciones, 302 prompts capturados y 68 sesiones registradas.

**Engram sí funciona.** El problema real es otro: no hay gobernanza sobre qué se guarda, cómo se organiza, ni cómo se recupera.

### 🏗️ Manager y gentle-orchestrator ya no compiten

La ambigüedad de `mode: "primary"` quedó resuelta en Fase D: Manager es el orquestador real, gentle-orchestrator opera como SDD Pipeline invocable. Las ADR-001, ADR-003 y ADR-008 documentan la separación.

### 📏 El costo real de contexto

El test T8 midió ~40k tokens de input en una sesión típica. La optimización de tokens debe esperar hasta tener:

1. Context Pack como contrato estructurado (E5).
2. Engram estabilizado (E4B).
3. Ruido de prompt capture controlado (E6).

### 🧩 No implementar híbrido ni MCP avanzado hasta Engram estable

Hybrid Retrieval (semántico + keyword) y MCP memory server son tentadores, pero premature optimization. Primero hay que tener la memoria baseline funcionando con gobernanza.

### 📐 El modelo no es una base de datos

Este principio recorrió todas las fases: el LLM no debe recibir conversaciones enteras, logs, ni ruido. Debe recibir contexto curado, con las decisiones activas, errores conocidos, estado actual y referencias a documentos relevantes.

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
|---|---|
| Secretos en config.toml | ✅ B-Security completada. GitHub PAT actualizado, Browserbase eliminado |
| Git history | ✅ Sin fugas. Verificado con `git log --all -p` |
| Backups | ✅ 5 backups con secretos eliminados de `~/.codex/` |
| Riesgo residual | 🟢 Bajo. No hay secretos en texto plano en ninguna ubicación conocida |
| Regla vigente | No guardar secretos en docs, Engram, prompts ni ADRs. Las credenciales viven fuera del repositorio |

---

## Estado actual y próximo paso

**Estado actual:** `E6A — Prompt Capture Audit & Design` ✅ Completada. Pendiente aprobación para E6B.

**Estado E global:** E0-E4B ✅ completados. E5 ✅ completado. E6A ✅ completado. E6B ⏳ pendiente de aprobación de diseño.

### Resultados de E4B

| Test | Resultado | Detalle |
|---|---|---|
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

### Pendiente: aprobación para E6B

El diseño del Noise Gate (doc 24) está listo para implementación. Se necesita aprobación explícita para:
1. Modificar `engram.ts` (agregar clasificador heurístico)
2. Agregar configuración `allow_prompt_capture` + `noise_gate` en `opencode.jsonc`
3. Opcional: migrar schema de `user_prompts` para nuevos campos

---

*Última actualización: 2026-06-10. Este README se actualiza al completar cada fase del roadmap.*
