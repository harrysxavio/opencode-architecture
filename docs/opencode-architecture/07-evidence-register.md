# Evidence Register — Registro Central de Evidencia

> Toda afirmación técnica relevante debe estar aquí con clasificación de estado.
>
> Estados: `VALIDADO` | `INFERIDO` | `CONFLICTO` | `NO VALIDADO` | `DECISIÓN PROPUESTA`

## 1. Agentes y Orquestación

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E001 | gentle-orchestrator configurado como agente primario | VALIDADO | `opencode.json` | 4-33 | `"mode": "primary"` para gentle-orchestrator | gentle-orchestrator es primary y compite con Manager | Verificar cuál gana en runtime |
| E002 | Manager configurado como agente primario | VALIDADO | `opencode.json` | 34-51 | `"mode": "primary"` para manager | Manager también es primary | Verificar resolución real |
| E003 | Manager tiene prohibición explícita de llamar a gentle-orchestrator | VALIDADO | `opencode.json` prompt Manager | 49 (línea del prompt) | "You MUST NOT invoke, delegate to, call, modify, override, or depend on `gentle-orchestrator`." | Separación intencional pero puede causar loop | Verificar que el prompt se cumpla |
| E004 | gentle-orchestrator tiene tools limitadas: sin glob/grep/skill | VALIDADO | `opencode.json` | 24-32 | Tools: bash, delegate, delegation_list, delegation_read, edit, read, write | Diseñado como coordinador puro | — |
| E005 | Manager tiene tool surface completa | VALIDADO | `opencode.json` | 38-48 | Tools: bash, edit, glob, grep, list, read, skill, task, todowrite | Manager puede hacer de todo | Evaluar si necesita todo siempre |
| E006 | Manager referencia subagentes que no existen (review-gpt55, debug-gpt55) | VALIDADO | Manager prompt | "Use GPT-5.5 review/debug subagents if available." + Quality gates | Prompt dice "if available" | Graceful degradation, pero funcionalidad faltante | Buscar si existen en otro lugar |
| E007 | No hay documentación de cómo OpenCode resuelve dos primarios | NO VALIDADO | opencode.json + docs | N/A | Ambos son mode: primary; no hay regla de resolución visible | Riesgo de ambigüedad | Probar en runtime con mensaje simple sin @mention |
| E008 | Manager usa task() (sync), gentle-orchestrator usa delegate (async) | VALIDADO | opencode.json permisos + prompts | gentle:4-33, manager:38-48 | gentle tiene delegate tool; manager no tiene delegate pero sí task | Diferente mecanismo de delegación | Verificar consistencia |
| E009 | Manager puede ejecutar inline; gentle-orchestrator nunca ejecuta inline | VALIDADO | Ambos prompts | Manager Operating Model, gentle Delegation Rules | Manager: "If no subagent exists, Manager performs this inline." gentle: "Delegate ALL real work to sub-agents" | Diferencia arquitectónica fundamental | — |

## 2. Configuración y Archivos

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E010 | opencode.json y opencode.jsonc coexisten con MCP duplicados | VALIDADO | `opencode.json` + `opencode.jsonc` | .json:189-212, .jsonc:3-21 | Engram aparece en ambos, Playwright aparece en .jsonc y config.toml | Posible sobrescritura o merge | Verificar merge real |
| E011 | Bearer token de GitHub expuesto en config.toml — **RESUELTO** | ✅ MITIGADO | `config.toml` | 112 | Token actualizado, 5 backups eliminados, git history sin fugas | ✅ B-Security: token rotado, sin rastros del viejo | Ninguna — resuelto |
| E012 | API key de Browserbase expuesta en URL de config.toml — **RESUELTO** | ✅ MITIGADO | `config.toml` | 126 | Sección browserbase eliminada del config | ✅ B-Security: Browserbase eliminado (ya no necesario) | Ninguna — resuelto |
| E013 | AGENTS.md (.config/opencode) tiene 259 líneas | VALIDADO | `AGENTS.md (.config)` | 1-259 | Conteo directo | ~7,000 tokens de contexto fijo | Medir tokens reales |
| E014 | AGENTS.md (.codex) tiene 449 líneas | VALIDADO | `AGENTS.md (.codex)` | 1-449 | Conteo directo | ~12,000 tokens de contexto fijo | Medir tokens reales |
| E015 | frontend-specialist duplicado en agent/ y agents/ | VALIDADO | `agent/frontend-specialist.md` vs `agents/frontend-specialist.md` | agent: 544 líneas, agents: 872 líneas | Contenido diferente | Riesgo de desincronización | Determinar cuál es la versión activa |

## 3. Memoria y Engram

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E016 | Plugin engram.ts activo con 19,136 líneas | VALIDADO | `plugins/engram.ts` | Archivo completo | Existe, está configurado en opencode.json y config.toml | Plugin masivo que inyecta contexto | Medir impacto real en tokens |
| E017 | Engram MCP configurado 3 veces | VALIDADO | `opencode.json`, `opencode.jsonc`, `config.toml` | .json:189-195, .jsonc:3-11, .toml:149-151 | 3 configuraciones para el mismo MCP | Posible duplicación | Verificar si se instancia 1 o 3 veces |
| E018 | memories_1.sqlite reportado con 4KB y sin tabla de observaciones | INFERIDO | `memories_1.sqlite` | N/A | Auditoría 1 reporta 4KB, tabla observations no existe | Engram no está escribiendo observaciones | Verificar directamente DB con SELECT |
| E019 | 32 archivos en memories/ pueden ser sesiones, no observaciones | INFERIDO | `memories/` directorio | N/A | Auditoría 1: "32 archivos en memories/" | Pueden ser estados de sesión, no memoria semántica | Listar y clasificar archivos |
| E020 | Engram protocol duplicado en 3 lugares | VALIDADO | `AGENTS.md (.config)`, `AGENTS.md (.codex)`, `engram.ts` | .config:72-166, .codex:355-449, engram.ts:64-141 | El mismo protocolo de memoria aparece en los 3 archivos | Triple fuente de instrucciones de memoria | Desduplicar y consolidar |
| E021 | Prompt capture automático sin filtro | VALIDADO | `engram.ts` | 343-381 | Hook chat.message captura prompts completos | Guarda prompts sin síntesis ni filtro | Evaluar necesidad vs ruido |
| E022 | Session close protocol no tiene evidencia de ejecución | INFERIDO | N/A | N/A | 55 sesiones indexadas pero sin mem_session_summary confirmados | El protocolo puede no estar ejecutándose | Revisar logs/DB de sesiones |
| E023 | mem_save proactivo definido pero DB vacía | CONFLICTO | `AGENTS.md` vs `memories_1.sqlite` | AGENTS:78-106 | Protocolo define guardado proactivo pero DB está vacía | Contradicción entre configuración y runtime | Ejecutar mem_save de prueba y verificar persistencia |

## 4. SDD y Subagentes

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E024 | 8 subagentes SDD configurados con mode: subagent, hidden: true | VALIDADO | `opencode.json` | 52-171 | 8 bloques de agente con `"mode": "subagent"` | Subagentes puros, sin capacidad de delegar | — |
| E025 | Todos los subagentes SDD tienen executor boundary | VALIDADO | `sdd-apply/SKILL.md` y similares | 13-21 | "Do NOT delegate. Do NOT call the Skill tool." | Límite claro de ejecución | Verificar en runtime |
| E026 | SDD persistence contract con 4 modos | VALIDADO | `persistence-contract.md` | 3-16 | Modos: engram, openspec, hybrid, none | Flexibilidad de persistencia | Verificar modo activo actual |
| E027 | OpenSpec no tiene directorios visibles en ningún proyecto | NO VALIDADO | N/A | N/A | No existen directorios `openspec/` | Modo openspec no está en uso | Buscar openspec/ en todos los proyectos |
| E028 | Ciclo SDD completo no tiene artefactos visibles | INFERIDO | Engram DB + filesystem | N/A | DB vacía + sin openspec/ | El pipeline SDD no se ha ejecutado aún | Ejecutar SDD dry-run y verificar artefactos |

## 5. Skills y Registry

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E029 | Skill registry tiene 48 skills indexadas | VALIDADO | `.atl/skill-registry.md` | 24-50 | 48 skills listadas con triggers y paths | Inventario completo de skills disponibles | Comparar con skills instaladas reales |
| E030 | Skill registry es auto-generado por gentle-ai | VALIDADO | `.atl/skill-registry.md` | 3 | "Auto-generated by gentle-ai skill-registry refresh" | Se regenera con comando CLI | Verificar frecuencia de regeneración |
| E031 | background-agents.ts refresca skill registry | VALIDADO | `background-agents.ts` | 38-53 | Llama gentle-ai skill-registry refresh | Actualización automática de registry | Verificar que funcione |
| E032 | CONTEXT_INDEX.md no existe | NO VALIDADO | N/A | N/A | No encontrado en ningún path | Posible confusión conceptual con skill-registry.md | Decidir si se necesita separado |
| E033 | Superpowers referenciado como skill pero no existe como SKILL.md | VALIDADO | Manager prompt + filesystem | Manager prompt "Try superpowers/brainstorming" | No hay SKILL.md de superpowers | Es plugin OpenAI, no skill local | Documentar la diferencia |
| E034 | graphify instalado como skill pero sin graphify-out/ | VALIDADO | `~/.agents/skills/graphify/` + projects | Skill existe, graphify-out/ no existe | Graphify no se ha usado | Skill disponible pero no operativa | No requiere acción hasta que se use |

## 6. MCP y Tools

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E035 | 9+ MCP servers configurados entre todos los archivos | VALIDADO | `opencode.json`, `opencode.jsonc`, `config.toml` | Múltiples secciones | Engram, Context7, NotebookLM, Supabase, Playwright, GitHub, fastmcp, browserbase, node_repl | Superficie MCP extensa | Medir tokens de schemas |
| E036 | Engram MCP duplicado en 3 configs | VALIDADO | .json:189-195, .jsonc:3-11, .toml:149-151 | Misma herramienta con paths ligeramente diferentes | Posible triple instanciación | Verificar en runtime |
| E037 | Playwright MCP duplicado en .jsonc y .toml | VALIDADO | .jsonc:13-21, .toml:7-9 | npx @playwright/mcp@latest en ambos | Posible doble instancia | Verificar en runtime |
| E038 | Context7 MCP duplicado en .json y .toml | VALIDADO | .json:183-188, .toml:121-124 | http vs npx | Diferentes mecanismos de conexión | Verificar cuál está activo |
| E039 | Supabase necesita auth OAuth según inventory | INFERIDO | inventory.md | Líneas 1577-1584 | Inventory reporta "needs_auth" | No operativo hasta configurar auth | Probar conexión |
| E040 | background-agents.ts plugin de 49,010 líneas | VALIDADO | `plugins/background-agents.ts` | Archivo completo | Tamaño masivo | Plugin más grande del sistema | Evaluar necesidad de refactor |

## 7. Tokens y Contexto

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E041 | Contexto fijo estimado en ~29,000 tokens — CORREGIDO B0/B1 | CONFLICTO → INFERIDO | Suma de fuentes de contexto | — | AGENTS.md (.codex) ~12k + AGENTS (.config) ~7k + system ~3k + skills ~3k + engram ~2.5k + design ~1.5k | ~29k asume ambos AGENTS.md simultáneos, lo cual es incorrecto. Rango revisado: ~18,500–22,000. B1: ✅ Manager validado como primary real. T8 preparado con metodología. | Ejecutar Test 8 ("Dime 1 frase") para medición real — pendiente de input exacto del usuario |
| E042 | Engram protocol suma ~2,500 tokens duplicados | INFERIDO | AGENTS.md (.config) + AGENTS.md (.codex) + engram.ts | .config:72-166, .codex:355-449 | Mismo contenido en 3 fuentes | ~2,500 tokens redundantes por sesión | Calcular con precisión |
| E043 | Available skills list estimado en ~3,000 tokens | INFERIDO | System prompt | — | 48 skills con triggers y descripciones | Cada skill agrega ~60 tokens promedio | Medir precisamente |
| E044 | Design skills protocol agrega ~1,500 tokens | INFERIDO | AGENTS.md (.config) | 168-259 | 90 líneas de protocolo frontend | Siempre inyectado aunque no sea request frontend | Mover a skill bajo demanda |

## 8. Plugins

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E045 | engram.ts inyecta MEMORY_INSTRUCTIONS al system prompt | VALIDADO | `engram.ts` | 426-432 | `experimental.chat.system.transform` hook | Inyección automática de instrucciones de memoria | Verificar contenido exacto inyectado |
| E046 | engram.ts captura prompts en chat.message | VALIDADO | `engram.ts` | 343-381 | Hook que guarda prompt del usuario | Captura automática de todo input | Evaluar necesidad de filtro |
| E047 | background-agents.ts escribe outputs fuera del undo tree | VALIDADO | `background-agents.ts` | 609-612, 843-876, 1302-1303 | Cita textual: "este archivo está fuera del undo tree" | Delegación async no deshacible | Documentar limitación |
| E048 | background-agents.ts desactiva nested delegate/task | VALIDADO | `background-agents.ts` | 675-691 | Desactiva anidamiento para evitar loops | Protección contra delegación recursiva | — |

## 9. Inventory

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E049 | inventory.md tiene 1,635 líneas | VALIDADO | `inventory/inventory.md` | Archivo completo | Conteo directo | Catálogo técnico extenso | Verificar precisión |
| E050 | inventory.json generado el 2026-05-28 | INFERIDO | `inventory/inventory.json` | Metadatos | Fecha en metadatos | Puede estar desactualizado | Regenerar y comparar diff |
| E051 | inventory no se carga automáticamente | VALIDADO | Uso observado | — | Solo se carga con comando inventory | No contribuye a contexto fijo | — |

## 10. Hallazgos de validación runtime (Fase B0)

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E052 | memories_1.sqlite tiene 40KB (no 4KB) pero NO tiene tabla observations | VALIDADO | `memories_1.sqlite` | `.tables` | Tablas: _sqlx_migrations, stage1_outputs (0 rows), jobs. Sin observations/prompts. | DB es de pipeline interno, no de memoria semántica de agente. Engram MCP no está escribiendo observaciones. | Reparar pipeline en Fase E |
| E053 | 8 procesos engram.exe activos simultáneamente | VALIDADO | Runtime | `Get-Process -Name "engram"` | 8 instancias con PIDs desde 22/05 hasta hoy. Dos parent PIDs (5264, 49768, 6480). | Triple configuración de Engram MCP resulta en múltiples instancias runtime. Consume recursos y puede causar conflictos. | Consolidar a 1 instancia en Fase G |
| E054 | No hay evidencia de mem_session_summary en session_index.jsonl | VALIDADO | `session_index.jsonl` | grep "summary" | 57 entradas, ninguna contiene "summary" o "session_summary". | El protocolo está definido pero no se ejecuta, o se ejecuta en otro almacenamiento. | Verificar con mem_context sobre proyecto actual |
| E055 | 27 sesiones reales (no 55 como se reportó) | VALIDADO | `sessions/` | Get-ChildItem -Depth 3 -Directory | 27 directorios de sesión desde abril a junio 2026. | El dato de 55 sesiones en documentación original es incorrecto. | — |
| E056 | Secretos expuestos en config.toml confirmados | VALIDADO | `config.toml` | Líneas 112, 126 | Línea 112: bearer_token_env_var con GitHub PAT. Línea 126: URL con Browserbase API key. Ambos en texto plano. | Riesgo 🔴 ALTO de exposición de credenciales. Mitigar en Fase B-Security. | Rotar tokens, mover a env vars |
| E057 | state_5.sqlite con 69 threads pero sin datos de memoria semántica | VALIDADO | `state_5.sqlite` | `.tables`, `SELECT COUNT(*)` | Tablas: threads (69), agent_jobs, thread_dynamic_tools, thread_spawn_edges, etc. Sin tablas observations/prompts. | DB de estado de sesiones, no de memoria persistente. | — |
| E058 | logs_2.sqlite: 14,947 entradas con trazas de conexión MCP, skills, plugins | VALIDADO | `logs_2.sqlite` | `SELECT COUNT(*)`, PRAGMA table_info | Schema completo: id, ts, level, target, feedback_log_body, module_path, thread_id. Niveles: TRACE 6744, DEBUG 4069, INFO 3992, WARN 142. | Fuente rica de datos de runtime. Puede usarse para validar comportamiento sin modificar código. | — |
| E059 | CONTEXT_INDEX.md existe en otros proyectos pero NO en workspace actual | VALIDADO | Varios proyectos | glob | Existe en PROJECT_TEMPLATE, SAMPLE_PROJECT, backup retail. No existe en ARQUITECTURA OPENCODE. | skill-registry.md cumple función de context index en este proyecto. | Decidir si unificar o crear separado |
| E060 | engram-instructions.md tiene 70 líneas como model_instructions_file | VALIDADO | `config.toml:4`, `engram-instructions.md` | model_instructions_file apunta a engram-instructions.md | Archivo de 70 líneas con protocolo Engram completo. Es la tercera fuente de instrucciones Engram (junto a AGENTS.md y plugin). | Triple fuente confirmada. Desduplicar en Fase E. | — |

## 11. Decisiones Propuestas Actualizadas (Fase B0)

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| D001 | Manager debe ser el único primary por defecto | ✅ **VALIDADO** — Manager es primary real | B1 | Observación directa + T1 + T8 | Manager respondió en toda B1 y T8 sin intervención de gentle-orch. | Decisión estratégica confirmada por evidencia runtime. Pendiente: cambiar mode en opencode.json. | Fase D |
| D002 | gentle-orchestrator como SDD Pipeline explícito | ✅ **VALIDADO** — gentle-orch no responde por defecto | B1 | Observación directa | gentle-orch no se activó en ninguna prueba B1. | ADR-001/003 confirmados. Pendiente: cambiar mode en opencode.json. | Fase D |
| D003 | Engram solo para memoria gobernada | DECISIÓN PROPUESTA | — | — | Guardar solo decisiones, bugs, aprendizajes | Reducir ruido en memoria | Validación P2 confirma DB vacía — prioridad alta |
| D004 | Mover Design Skills Protocol a skill bajo demanda | DECISIÓN PROPUESTA | — | — | Solo cargar cuando haya tarea frontend | Ahorrar ~1,500 tokens fijos | Implementar en Fase F |
| D005 | Consolidar instrucciones Engram en Markdown versionado | DECISIÓN PROPUESTA (C8) | — | — | Markdown = fuente de verdad, plugin = runtime, AGENTS.md = referencias mínimas | Ahorrar ~2,500 tokens fijos + claridad arquitectónica | Implementar en Fase E |
| D006 | Activar MCP bajo demanda | DECISIÓN PROPUESTA | — | — | No cargar todos los MCP al inicio. 8 instancias engram confirman duplicación. | Ahorrar ~5,000-10,000 tokens fijos | Aprobar ADR-007 después de B-Security |

## 12. Hallazgos de validación Fase B1 (observabilidad)

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E061 | **Manager responde por defecto — VALIDADO** | ✅ VALIDADO | Esta sesión (Manager prompt activo) | Observación directa durante B1 | Manager ejecutó toda Fase B1 (documentación, tests, análisis) sin intervención de gentle-orch. Tool calls: read, edit, write, bash, engram_mem_*. | **Manager es el agente primario real.** La ambigüedad de doble primary está resuelta en la práctica. | Ejecutar T1 con input exacto para reporte completo |
| E062 | **B-Security completada — secretos rotados** | ✅ MITIGADO | `config.toml` (~/.codex/) | Líneas 112 (actualizado), sección browserbase (eliminada) | GitHub PAT actualizado. Browserbase eliminado. 5 backups eliminados. Git history sin fugas. | R11 mitigado. Sin secretos expuestos. | Ninguna — resuelto |
| E063 | **Routing SDD diseñado pero no ejecutado end-to-end** | ⚠️ DISEÑADO | `baselines/T5-sdd-routing-baseline.md` | Reporte completo | Manager puede clasificar y delegar a gentle-orch para SDD (ADR-001/003). Pipeline de 8 fases definido. | Routing conceptual validado. Falta ejecución runtime con cambio real. | Fase C: ejecutar cambio estructurado pequeño con SDD |
| E064 | **Token baseline — ejecutado en sesión limpia** | ✅ VALIDADO PARCIAL | `baselines/T8-token-baseline.md` | Reporte completo actualizado | Input exacto: "Dime 1 frase". Output: respuesta directa de Manager. Tiempo: ~3s. Sin tools/MCP/memoria/skills/subagentes. Sin sobreorquestación. Tokens reales NO DISPONIBLES. | Baseline funcional validado. Sin sobreorquestación en request Tiny. Tokens reales no medibles sin telemetría runtime. | Obtener telemetría runtime cuando esté disponible |
| E065 | **18-observability-design.md creado** | ✅ COMPLETADO | `docs/opencode-architecture/18-observability-design.md` | Documento completo | Define métricas mínimas, fuentes de evidencia, criterios de precisión, tests planificados. | Framework de observabilidad listo para fases posteriores. | Usar en Fase C para mediciones comparables |
| E066 | **No se modificó arquitectura funcional** | ✅ VERIFICADO | N/A | N/A | Solo se crearon/actualizaron archivos .md en docs/. No se tocó opencode.json, .jsonc, AGENTS.md, prompts, MCP, plugins. | Restricción B1 respetada al 100%. | — |
| E067 | **T8 — request Tiny sin sobreorquestación en sesión limpia** | ✅ VALIDADO PARCIAL | Sesión limpia OpenCode | Input: "Dime 1 frase" | Manager respondió directo en ~3s. Clasificación: Tiny. Sin tools, MCP, memoria, skills, subagentes visibles. Output: "Una arquitectura limpia se defiende sola; el código no necesita comentarios cuando los nombres cuentan la historia." | Para request Tiny, el sistema se comporta correctamente: Manager directo, sin sobreorquestación. No hay evidencia de que gentle-orch, memoria, MCP o skills se activen innecesariamente. | Fase C: verificar si requests más complejos (Medium/Large/SDD) también evitan sobreorquestación |

## 13. Correciones de evidencia previa (Fase B0/B1)

## 13b. Hallazgos Fase C — Tests de flujo reproducibles

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| E068 | T3 confirma Markdown como fuente de verdad | ✅ VALIDADO | `test-runs/C-flow-tests-2026-06-09/T3-docs-retrieval-flow.md` | Reporte completo | Manager leyó `16-memory-governance-policy.md`, `10-target-architecture.md`, `14-runtime-validation-results.md`, `ADR-004-engram-role.md`. | Document Retriever funciona correctamente para arquitectura. | Mantener docs como fuente primaria. |
| E069 | T2 confirma recuperación de memoria útil vía `mem_context` | ✅ VALIDADO / ⚠️ PARCIAL ARQ | `T2-memory-flow.md` | Reporte completo | Engram devolvió contexto útil reciente. Sin escritura. | Memory Flow funciona operativamente, pero persistence schema sigue pendiente. | Fase E: diagnosticar persistencia real. |
| E070 | T4 confirma Context7 bajo demanda | ✅ VALIDADO | `T4-mcp-routing-flow.md` | Reporte completo | Context7 resolve/query usado solo por intención explícita. | MCP bajo demanda viable. | Fase G: consolidar MCP sin romper demanda explícita. |
| E071 | T5 revela bloqueo Manager ↔ gentle-orchestrator | ⚠️ PARTIAL | `T5-sdd-routing-flow.md` | Reporte completo | Ruta SDD diseñada, pero regla runtime actual prohíbe invocar gentle-orchestrator. | Fase D debe resolver contradicción entre ADR-003 y prompt runtime. | Ejecutar prueba end-to-end tras cambio controlado. |
| E072 | T6 confirma manejo sano de request ruidoso | ✅ VALIDADO | `T6-noisy-request-flow.md` | Reporte completo | Manager separa temas, prioriza y no activa MCP/skill/SDD sin confirmación. | Buen control de sobreorquestación. | Mantener como criterio de aceptación. |
| E073 | T7 confirma contradicción ficticia sin contaminar memoria real | ✅ VALIDADO | `T7-memory-contradiction-flow.md` | Reporte completo | No mem_save, no ADR real, no cambio Manager/gentle. | Lógica conceptual de supersedes correcta. | Fase E: implementar/testear supersedes real. |

| ID | Corrección | Estado anterior | Estado actual | Detalle |
|----|-----------|----------------|---------------|---------|
| E018 | memories_1.sqlite tamaño | INFERIDO: 4KB sin observaciones | VALIDADO: 40KB (no 4KB), sin tabla observations | DB es de pipeline interno, no de memoria semántica |
| E022 | Session close protocol evidencia | INFERIDO: no hay evidencia | VALIDADO: no hay evidencia de ejecución en session_index.jsonl | 57 entradas sin "summary" |
| E041 | Estimación de tokens | INFERIDO: ~29,000 | CONFLICTO: rango revisado ~18,500–22,000 | Ambos AGENTS.md NO se cargan simultáneamente |

| ID | Hallazgo | Estado | Archivo | Línea/sección | Evidencia | Interpretación | Próxima validación |
|----|----------|--------|---------|---------------|-----------|----------------|-------------------|
| D001 | Manager debe ser el único primary por defecto | DECISIÓN PROPUESTA | — | — | Basado en análisis de capacidad y diseño | Resolvería el conflicto de doble orquestador | Aprobar ADR-001 |
| D002 | gentle-orchestrator como SDD Pipeline explícito | DECISIÓN PROPUESTA | — | — | Mantener funcionalidad pero eliminar modo primary | Evita competencia de orquestadores | Aprobar ADR-003 |
| D003 | Engram solo para memoria gobernada | DECISIÓN PROPUESTA | — | — | Guardar solo decisiones, bugs, aprendizajes | Reducir ruido en memoria | Aprobar ADR-004 |
| D004 | Mover Design Skills Protocol a skill bajo demanda | DECISIÓN PROPUESTA | — | — | Solo cargar cuando haya tarea frontend | Ahorrar ~1,500 tokens fijos | Implementar en Fase F |
| D005 | Desduplicar instrucciones Engram | DECISIÓN PROPUESTA | — | — | Una sola fuente de instrucciones de memoria | Ahorrar ~2,500 tokens fijos | Implementar en Fase E |
| D006 | Activar MCP bajo demanda | DECISIÓN PROPUESTA | — | — | No cargar todos los MCP al inicio | Ahorrar ~5,000-10,000 tokens fijos | Aprobar ADR-007 |
