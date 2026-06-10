# 14 — Runtime Validation Results

> Documento creado en Fase B0. Almacena resultados de validaciones read-only ejecutadas para confirmar o refutar supuestos de la arquitectura OpenCode. Actualizado en Fase B1 con resolución de B-Security y resultado de T8.

## Estado general

**Completado (Fase B0)** — 7 de 7 validaciones ejecutadas.
**Resuelto (Fase B-Security)** — P7: secretos rotados, backups eliminados, git history sin fugas.
**Completado (Fase B1)** — T8 ejecutado en sesión limpia. T1 validado (Manager primary real). T5 diseñado.

## Objetivo

Validar con evidencia runtime los principales supuestos de la arquitectura OpenCode, sin modificar archivos funcionales.

---

## Validaciones ejecutadas

| ID | Validación | Estado | Método | Resultado | Evidencia | Impacto |
|----|-----------|--------|--------|-----------|-----------|---------|
| P1 | Agente primary por defecto | NO VALIDADO | Revisión de logs (logs_2.sqlite 14,947 entradas), session_index.jsonl (57 entradas), rollout files | No se encontró evidencia en logs de cuál agente responde por defecto. Ambos quedan `mode: "primary"` en opencode.json. Los logs tienen target `codex_core::session::handlers` pero no registran selección de agente. | logs_2.sqlite, session_index.jsonl, rollout files | 🔴 ALTO: no se puede confirmar cuál agente responde sin Test 1 o testeo directo |
| P2 | Engram DB — observaciones | VALIDADO NO FUNCIONAL | sqlite3 directo sobre memories_1.sqlite (40KB) | DB NO tiene tablas `observations` ni `prompts`. Solo tablas: `_sqlx_migrations`, `stage1_outputs` (0 rows), `jobs`. Schema es de pipeline interno, no de memoria semántica. Tamaño 40KB (no 4KB como se reportó). | memories_1.sqlite `.tables` y `.schema` | 🔴 ALTO: Engram MCP no está escribiendo observaciones. La DB es para procesamiento interno, no para memoria agente. |
| P3 | Session summaries | NO VALIDADO | grep en session_index.jsonl + memories/ | session_index.jsonl tiene 57 entradas pero NINGUNA contiene "summary" o "session_summary". memories/memory_summary.md contiene solo placeholder ("No durable memory yet"). rollout_summaries/ vacío. | session_index.jsonl, memories/memory_summary.md | 🟡 MEDIO: protocolo mem_session_summary definido pero sin evidencia de ejecución real |
| P4 | Config merge (opencode.json + .jsonc) | NO VALIDADO | Revisión de archivos + logs | Ambos archivos existen. opencode.json (63KB) tiene agents, MCP. opencode.jsonc (621 bytes) tiene engram (path diferente) y playwright. No hay evidencia runtime de si se fusionan o sobreescriben. | opencode.json, opencode.jsonc | 🟡 MEDIO: no se puede confirmar merge behavior sin test específico |
| P5 | MCP duplicados en runtime | PARCIAL — 8 procesos engram | procesos + configs | Engram en 3 configs (opencode.json, .jsonc, config.toml). Playwright en 2 (.jsonc, .toml). Context7 en 2 (.json, .toml). **8 procesos engram.exe activos simultáneamente** confirman múltiples instancias. | `Get-Process -Name "engram"`, archivos de config | 🟡 MEDIO: duplicación confirmada en config, 8 instancias runtime consumiendo recursos |
| P6 | frontend-specialist activo | VALIDADO — duplicado confirmado | file listing | agent/frontend-specialist.md (22,019 bytes) y agents/frontend-specialist.md (14,899 bytes) — ambos existen con diferente contenido. | agent/ y agents/ file listing | 🟡 MEDIO: duplicado con contenido diferente, no se sabe cuál gana |
| P7 | Secretos expuestos | ✅ RESUELTO (B-Security) | Rotación manual + actualización config + limpieza backups | GitHub PAT actualizado (nuevo token). Browserbase API key eliminado (ya no needed). 5 backups con secretos eliminados de ~/.codex/. Git history sin fugas. Sin rastros de tokens viejos en ~/.codex/. | config.toml (actualizado), git log, ~/.codex/ (limpio) | 🟢 RESUELTO: B-Security completada. Sin secretos expuestos. |
| T8 | Token baseline (Tiny) | ✅ VALIDADO PARCIAL | Test 8 ejecutado en sesión limpia | Input: "Dime 1 frase". Output: respuesta directa de Manager. Tiempo: ~3s. Sin tools, MCP, memoria, skills ni subagentes visibles. Sin sobreorquestación. | `baselines/T8-token-baseline.md` | 🟢 Baseline funcional validado. Tokens reales NO DISPONIBLES (runtime no expone conteo). Contexto fijo INFERIDO: ~18,500–22,000. |

---

## Validaciones pendientes

| ID | Validación | Por qué importa | Comando sugerido | Riesgo | Prioridad |
|----|-----------|-----------------|-------------------|--------|-----------|
| P4 | Merge de configs | Determina qué MCP/skills están activos realmente | Consultar docs de OpenCode o probar con MCP exclusivo en .jsonc | 🟡 Medio | P2 (Fase C) |
| P3 | Session summaries | Determina si memoria cross-session funciona | Ejecutar mem_session_summary y verificar DB | 🟡 Medio | P2 (Fase C) |

### Validaciones resueltas en B1

| ID | Validación | Resultado |
|----|-----------|-----------|
| P1 | Agente primary real | ✅ **Resuelto**: Manager responde por defecto (validado por observación directa durante B1 y T1). |
| T8 | Token baseline | ✅ **Validado parcial**: baseline funcional en sesión limpia. Manager responde directo sin tools/MCP/memoria/skills/subagentes. Tokens reales NO DISPONIBLES. |

---

## Datos complementarios

### Hallazgos adicionales fuera de las validaciones planificadas

| Hallazgo | Detalle | Fuente |
|----------|---------|--------|
| **Sesiones reales: 27, no 55** | La documentación previa reportaba 55 sesiones. El conteo real es 27 directorios de sesión. | `Get-ChildItem sessions/ -Recurse -Directory -Depth 3` |
| **engram-instructions.md: 70 líneas** | El archivo referenciado en `config.toml` como `model_instructions_file` contiene el protocolo Engram. | config.toml línea 4, engram-instructions.md |
| **logs_2.sqlite: 14,947 entradas** | DB de logs con schema completo (ts, level, target, module_path, file, thread_id). Contiene trazas de conexión MCP, skills, plugins. Niveles: TRACE (6,744), DEBUG (4,069), INFO (3,992), WARN (142). | logs_2.sqlite `SELECT COUNT(*)`, PRAGMA table_info |
| **state_5.sqlite: 69 threads** | DB de estado con tablas threads (69), agent_jobs, thread_dynamic_tools, thread_spawn_edges. Sin tablas de observaciones. | state_5.sqlite `.tables`, `SELECT COUNT(*) FROM threads` |
| **goals_1.sqlite: vacía** | Tabla thread_goals con 0 registros. | goals_1.sqlite |
| **memories/ directory** | Contiene memory_summary.md (placeholder), MEMORY.md (placeholder), raw_memories.md (37 bytes vacío), rollout_summaries/ (vacío), extensions/, .git. Sin memoria durable. | Get-ChildItem memories/ |
| **8 procesos engram.exe** | Múltiples instancias de Engram MCP ejecutándose, con PIDs: 17124 (desde 22/05), 48308, 22004, 52620, 9792, 39920, 8552, 8972 (hoy). Dos parent PIDs diferentes (5264 y 49768, 6480). | Get-Process |
| **CONTEXT_INDEX.md existe en otros proyectos** | Existe en PROJECT_TEMPLATE y SAMPLE_PROJECT de arquitectura-ia, y en backup retail. NO existe en el workspace actual de ARQUITECTURA OPENCODE. | glob |
| **MCP servers en config.toml: 7** | playwright, github, fastmcp-toolkit, context7, browserbase, node_repl, engram. | config.toml grep `[mcp_servers.` |

---

## Conclusiones

1. **Engram (memoria semántica) NO está operativo.** La DB tiene schema de pipeline interno, no de observaciones. No hay tabla `observations` ni `prompts`. La memoria cross-session no funciona como se esperaba.

2. **Secretos expuestos — RESUELTOS.** ✅ B-Security completada en Fase B1. GitHub PAT actualizado, Browserbase eliminado, backups limpios.

3. **Agente primary — VALIDADO.** ✅ Manager responde por defecto. Validado por observación directa durante B1 y confirmado en T1/T8.

4. **Session summaries no tienen evidencia.** El protocolo está definido pero no hay rastro de ejecución en session_index.jsonl ni en memories/.

5. **Múltiples instancias de Engram confirman duplicación.** 8 procesos engram.exe corriendo indican que la triple configuración (opencode.json, .jsonc, config.toml) resulta en instancias múltiples.

6. **Baseline de tokens — INFERIDO.** Rango estimado: ~18,500–22,000 tokens fijos. T8 validó que un request Tiny se resuelve sin sobreorquestación, pero tokens reales NO DISPONIBLES por falta de telemetría runtime.

7. **27 sesiones, no 55.** El dato de 55 sesiones en la documentación original es incorrecto.

---

## Recomendación Go / No-Go

### Fase B-Security: **✅ COMPLETADA**

**Resolución:**
- GitHub PAT actualizado (nuevo token proporcionado por usuario).
- Browserbase API key eliminado del config (ya no necesario).
- 5 backups con secretos eliminados.
- Git history sin fugas.
- Sin rastros del token viejo en `~/.codex/`.

### Fase B1 (observabilidad): **✅ COMPLETADA**

**Resultados:**
- ✅ B-Security completada.
- ✅ Test 8 (baseline tokens) — ejecutado en sesión limpia. Sin sobreorquestación.
- ✅ Test 1 (primary real) — Manager validado como agente primario.
- ✅ Test 5 (SDD routing) — diseñado y documentado, pendiente ejecución end-to-end.

### Para pasar a Fase C (tests de flujo): **✅ GO**

**Condiciones cumplidas:**
- ✅ B-Security completada.
- ✅ Baseline funcional validado (T8 — sin sobreorquestación en Tiny).
- ✅ Manager validado como primary real.
- ✅ Observabilidad diseñada (18-observability-design.md).
- ✅ Rutas SDD diseñadas.
- ⚠️ Tokens reales NO DISPONIBLES — no bloqueante para Fase C.

### Para modificar configuración (opencode.json, AGENTS.md, config.toml): **NO-GO 🔴**

**Razón:**
- El agente primary real ya fue validado: Manager responde por defecto.
- El baseline funcional T8 ya fue validado; tokens reales siguen NO DISPONIBLES.
- T5 reveló un conflicto de regla runtime: Manager no puede invocar gentle-orchestrator aunque la arquitectura estratégica lo requiere para SDD.
- No se ha resuelto la duplicación de MCP.
- Cualquier cambio de configuración debe esperar a Fase D/G con test específico de regresión.

---

## Fase C — Tests de Flujo Reproducibles (2026-06-09)

| Test | Estado | Resultado runtime | Riesgo |
|---|---|---|---|
| T2 — Memoria útil | PASSED | `mem_context` recuperó contexto útil reciente. Sin escritura. | Engram persistence sigue sin diagnóstico definitivo |
| T3 — Markdown docs | PASSED | Manager leyó docs Markdown y respondió desde fuente versionada. | Bajo |
| T4 — MCP Context7 | PASSED | Context7 activado explícitamente para Zod. Sin memoria/SDD/subagentes. | Bajo |
| T5 — SDD read-only | PARTIAL | Manager diseñó ruta SDD, pero no puede invocar gentle-orchestrator por regla runtime actual. | Alto para Fase D |
| T6 — Request ruidoso | PASSED | Manager separa temas, prioriza y no ejecuta todo. | Bajo |
| T7 — Contradicción ficticia | PASSED | Manejo conceptual correcto, sin memoria real ni ADR real. | Bajo |

### Go / No-Go post-Fase C

- **Fase D — Resolver agente primario**: **GO condicionado**. T1/T8 validan Manager como default; T5 revela que hay que resolver explícitamente la contradicción Manager ↔ gentle-orchestrator.
- **Fase E — Gobernanza memoria**: **GO**. T2/T7 muestran necesidad clara y camino conceptual; Engram sigue requiriendo diagnóstico de persistencia.
- **Fase F — Optimización tokens**: **NO-GO**. Aún falta inventario de lazy-load y/o telemetría más robusta.
