# E4B-0 — Pre-Change Snapshot

> Capturado el 2026-06-10 antes de modificar archivos.

## 1. Binarios Engram

| Ruta | Versión | En PATH | En uso |
|---|---|---|---|
| `C:\Users\harry\bin\engram.exe` | **1.15.13** | ✅ Sí | ✅ Todos los procesos activos |
| `C:\Users\harry\AppData\Local\engram\bin\engram.exe` | **1.16.1** | ❌ No | ❌ Ningún proceso |

## 2. Procesos activos pre-cambio

| PID | Comando | Binario | Inicio |
|---|---|---|---|
| 15260 | `engram serve` | v1.15.13 | 07:38 |
| 5816 | `engram mcp --tools=agent` | v1.15.13 | 07:44 |
| 14512 | `engram mcp --tools=agent` | v1.15.13 | 11:06 |
| 16040 | `engram mcp --tools=agent` | v1.15.13 | 08:28 |
| 16004 | (sin cmdline) | — | — |

## 3. Configuración pre-cambio

| Archivo | Binario | Project name |
|---|---|---|
| `opencode.json` | `"engram"` (PATH → v1.15.13) | Auto-detect (git remote vs cwd → drift) |
| `opencode.jsonc` | `C:\Users\harry\bin\engram.exe` (v1.15.13) | Auto-detect |
| `config.toml` (Codex) | `"engram"` (PATH → v1.15.13) | Auto-detect |

## 4. Store pre-cambio

```text
C:\Users\harry\.engram\engram.db
  observations:    297
  user_prompts:    302
  sessions:         69
  memory_relations: 181
```
