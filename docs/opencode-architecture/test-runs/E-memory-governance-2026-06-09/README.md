# Fase E — Memory Governance / Engram

Estado: **E0/E1/E2/E3 completados — esperando aprobación E4 para reparar**.

Objetivo: diagnosticar el flujo de memoria de OpenCode/Engram sin tocar configuración funcional, sin optimizar tokens y sin contaminar memoria real fuera del scope ficticio `TEST-E-MEMORY-GOVERNANCE`.

## Resultado ejecutivo

- Engram **sí tiene storage semántico real**: `C:\Users\harry\.engram\engram.db`.
- La DB previamente auditada (`C:\Users\harry\.codex\memories_1.sqlite`) **no es el store semántico de Engram**; es un store interno de Codex memories/pipeline.
- `mem_save`, `mem_search`, `mem_get_observation`, `mem_context` y `mem_session_summary` funcionan operativamente.
- `mem_session_summary` persiste como `observations.type = session_summary`, no como `sessions.summary`.
- Persisten prompts en `user_prompts`/`prompts_fts`; hay 302 prompts en Engram DB.
- Sigue habiendo múltiples procesos Engram: 1 `serve` + 2 `mcp --tools=agent`.
- Hay binarios Engram duplicados: `C:\Users\harry\bin\engram.exe` v1.15.13 y `C:\Users\harry\AppData\Local\engram\bin\engram.exe` v1.16.1.
- Hay drift de project names: `arquitectura opencode` vs `opencode-architecture`.

## Go / No-Go

**GO condicionado para E4 reparación mínima**, con aprobación explícita del usuario.

No implementar todavía sin aprobación: `config.toml`, `opencode.json`, `opencode.jsonc`, `AGENTS.md`, `engram-instructions.md`, `plugins/engram.ts`.
