# E4 — Approval Gate

## Estado

Esperando aprobación explícita del usuario antes de modificar archivos funcionales.

## Propuesta mínima para aprobación

1. Corregir documentación: Engram real vive en `~\.engram\engram.db`, no `.codex\memories_1.sqlite`.
2. Unificar referencia de binario Engram a v1.16.1 o decidir conservar v1.15.13 hasta upgrade formal.
3. Reducir duplicación instructiva: política larga en docs/runtime, regla mínima en AGENTS.
4. Mantener plugin intacto por ahora, salvo aprobación específica para gate de prompt capture.
5. Usar proyecto explícito `opencode-architecture` hasta consolidar drift.

## No se implementó

- No se tocó `opencode.json`.
- No se tocó `opencode.jsonc`.
- No se tocó `config.toml`.
- No se tocó `AGENTS.md`.
- No se tocó `engram-instructions.md`.
- No se tocó `plugins/engram.ts`.
- No se mataron procesos.
- No se borraron DBs.
- No se optimizaron tokens.
