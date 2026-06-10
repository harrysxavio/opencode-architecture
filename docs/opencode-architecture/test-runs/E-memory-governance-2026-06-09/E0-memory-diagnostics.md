# E0 — Memory Diagnostics Read-only

## 1. Configuración Engram activa

| Fuente | Ruta | Define Engram | Rol | Activa en runtime | Riesgo |
|---|---|---:|---|---|---|
| OpenCode config | `C:\Users\harry\.config\opencode\opencode.json` | Sí | MCP `engram` → `engram mcp --tools=agent` | Sí, OpenCode | Medio: usa PATH, puede resolver binario viejo |
| OpenCode JSONC | `C:\Users\harry\.config\opencode\opencode.jsonc` | Sí | MCP `engram` → `C:\Users\harry\bin\engram.exe mcp --tools=agent` | No confirmado/posible merge | Medio: fija binario v1.15.13 |
| Codex config | `C:\Users\harry\.codex\config.toml` | Sí | MCP `engram` → `engram mcp --tools=agent`; memories enabled | Sí, Codex | Medio: instancia MCP adicional |
| Codex instructions | `C:\Users\harry\.codex\engram-instructions.md` | No MCP | Protocolo runtime de memoria | Sí, por `model_instructions_file` | Alto: duplica protocolo |
| OpenCode agents | `C:\Users\harry\.config\opencode\AGENTS.md` | No MCP | Protocolo Engram completo | Sí, contexto global | Alto: duplica protocolo |
| OpenCode plugin | `C:\Users\harry\.config\opencode\plugins\engram.ts` | Sí indirecto | Inicia `engram serve`, captura prompts, inyecta instrucciones, compaction context | Probable | Alto: prompt capture + instrucciones duplicadas |
| Engram skill | `C:\Users\harry\.codex\skills\engram-agent\SKILL.md` | No MCP | Skill/documentación operativa | Solo si se carga | Bajo/medio: otra fuente instructiva |

## 2. Procesos Engram

| PID | Parent PID | Inicio | Ruta/binario | Config inferida | Riesgo |
|---:|---:|---|---|---|---|
| 15260 | 14576 | 2026-06-10 07:38:18 | `C:\Users\harry\bin\engram.EXE` | `engram serve` | Medio: server en v1.15.13 |
| 5816 | 8492 | 2026-06-10 07:44:40 | `C:\Users\harry\bin\engram.exe` | Codex MCP `mcp --tools=agent` | Medio: instancia MCP adicional |
| 16040 | 5524 | 2026-06-10 08:28:36 | `C:\Users\harry\bin\engram.exe` | OpenCode MCP `mcp --tools=agent` | Medio: instancia MCP adicional |

Parents relevantes:
- `8492`: `codex.exe app-server`.
- `5524`: `OpenCode.exe`.
- `14576`: `cmd.exe` hijo de OpenCode; comando observado asociado a `npx @playwright/mcp@latest`, pero el proceso hijo Engram quedó activo como `serve`.

Conclusión: después de Fase D siguen existiendo **3 procesos Engram**. No se mató ninguno.

## 3. Bases de datos y archivos de memoria

| Archivo | Tablas | Rows relevantes | ¿Memoria semántica? | Evidencia |
|---|---|---:|---|---|
| `C:\Users\harry\.engram\engram.db` | `observations`, `user_prompts`, `sessions`, `memory_relations`, FTS, sync | 292 observations, 302 prompts, 68 sessions, 176 relations | Sí | Store real Engram |
| `C:\Users\harry\.engram\engram.db.backup-20260522-165654` | Mismo schema | 213 observations, 45 prompts, 17 sessions | Sí, backup | Backup previo |
| `C:\Users\harry\.codex\memories_1.sqlite` | `_sqlx_migrations`, `jobs`, `stage1_outputs` | jobs=1, stage1_outputs=0 | No | Codex memories/pipeline interno |
| `C:\Users\harry\.codex\logs_2.sqlite` | `logs` | 17,459 logs | No | Logs técnicos |
| `C:\Users\harry\.codex\state_5.sqlite` | `threads`, `thread_dynamic_tools`, etc. | threads=69 | No | Estado Codex/OpenAI app |
| `C:\Users\harry\.codex\goals_1.sqlite` | `thread_goals` | 0 | No | Goals vacío |
| `C:\Users\harry\.codex\memories\memory_summary.md` | Markdown | placeholder | No | Codex memory repo placeholder |
| `C:\Users\harry\.codex\memories\MEMORY.md` | Markdown | placeholder | No | Sin task-group memories |
| `C:\Users\harry\.codex\memories\raw_memories.md` | Markdown | placeholder | No | “No raw memories yet” |
| `C:\Users\harry\.codex\memories\rollout_summaries\` | dir | 0 entries | No | Vacío |
| `C:\Users\harry\.codex\session_index.jsonl` | jsonl | 57 lines | No | Índice de sesiones, sin summaries |

## 4. Herramientas de memoria disponibles

| Tool | Disponible | Fuente | Qué parece hacer | Persistencia validada |
|---|---:|---|---|---|
| `mem_context` | Sí | Engram MCP | Recupera sesiones/observaciones/prompts recientes | Sí: devolvió contexto opencode-architecture |
| `mem_search` | Sí | Engram MCP | Busca en FTS observations | Sí: encontró probe E-T3 |
| `mem_get_observation` | Sí | Engram MCP | Recupera observación completa por id | Sí: id=395 |
| `mem_save` | Sí | Engram MCP | Guarda/upsert observations | Sí: id=395 |
| `mem_session_summary` | Sí | Engram MCP | Guarda summary como observation `session_summary` | Sí: id=396 |
| `mem_session_start` | Sí | Engram MCP | Crea sesión explícita | Sí: sesión ficticia E |
| `mem_judge` | Sí | Engram MCP | Marca relaciones/conflictos | Sí: not_conflict en pruebas |
| `mem_doctor` | Sí | Engram MCP/CLI | Diagnóstico read-only | Sí |

## 5. Logs redactados

`logs_2.sqlite` no tiene `target=engram`, pero sí cuerpos que mencionan Engram/tools.

| Evidencia | Conteo |
|---|---:|
| logs totales | 17,459 |
| body contiene `engram` | 71 |
| body contiene `mem_context` | 45 |
| body contiene `mem_search` | 45 |
| body contiene `mem_save` | 45 |
| body contiene `mem_session_summary` | 45 |
| body contiene `engram.db` o `memories_1.sqlite` | 0 |

Metadatos de referencias Engram aparecen en módulos `codex_api::endpoint::responses_websocket`, `codex_mcp::connection_manager`, `codex_core::client`, `codex_core::session::handlers`.

No se imprimieron cuerpos de log ni secretos.
