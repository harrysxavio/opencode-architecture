# E4B — Summary Matrix

> Resultados consolidados de la fase E4B.

## Cambios aplicados

| Cambio | Archivo | Antes | Después | Resultado |
|---|---|---|---|---|
| Pin binario + project | `opencode.json` | `"engram"` (v1.15.13) | `C:\...\engram.exe` (v1.16.1) + `--project` | ✅ |
| Pin binario + project | `opencode.jsonc` | `C:\...\bin\engram.exe` (v1.15.13) | `C:\...\AppData\...\engram.exe` (v1.16.1) + `--project` | ✅ |
| Codex | `config.toml` | `"engram"` (v1.15.13) | Sin cambios | ⏸ No tocado |

## Tests de validación

| Test | Resultado | Evidencia |
|---|---|---|
| **T1** — Procesos post-restart | ✅ PASS | OpenCode usa v1.16.1; 3 legacy v1.15.13 |
| **T2** — Doctor | ✅ PASS | 4/4 checks OK, 0 errores, 0 warnings |
| **T3** — mem_context | ✅ PASS | Contexto relevante de `opencode-architecture` |
| **T4** — mem_save ficticio | ✅ PASS | Memoria guardada (id=400) |
| **T5** — mem_search | ✅ PASS | Memoria recuperada (id=400) |
| **T6** — mem_session_summary | ✅ PASS | `observations.type=session_summary` (id=401) |
| **T7** — No guardar ruido | ✅ PASS | Sin `mem_save` por ruido |

## Go/No-Go para E5

| Criterio | Estado |
|---|---|
| Binario Engram único para OpenCode | ✅ v1.16.1 |
| Project name estable como `opencode-architecture` | ✅ `--project` explícito |
| `mem_save` persiste post-restart | ✅ |
| `mem_search` recupera post-restart | ✅ |
| `mem_context` recupera contexto relevante | ✅ |
| `mem_session_summary` validado con contrato real | ✅ (`observations.type=session_summary`) |
| No se rompió Manager/gentle | ✅ |
| No se tocó plugin | ✅ |
| No se tocó token optimization | ✅ |
| No se tocó MCP surface general | ✅ |

**Veredicto: ✅ GO para E5**
