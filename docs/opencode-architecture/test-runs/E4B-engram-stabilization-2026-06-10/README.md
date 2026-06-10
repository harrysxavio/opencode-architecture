# E4B — Engram Stabilization

> **Duración:** 2026-06-10  
> **Estado:** ✅ Completada  
> **Objetivo:** Estabilizar Engram como memoria persistente real, reduciendo ambigüedad de binarios, configuración y proyecto.

## Archivos de la fase

| Documento | Descripción |
|---|---|
| [E4B-0-pre-change-snapshot.md](E4B-0-pre-change-snapshot.md) | Snapshot previo: binarios, procesos, configs, store |
| [E4B-1-diff-plan.md](E4B-1-diff-plan.md) | Diff propuesto y aprobado |
| [E4B-2-implementation-result.md](E4B-2-implementation-result.md) | Resultado de implementación + validación JSON |
| [E4B-3-post-restart-validation.md](E4B-3-post-restart-validation.md) | Validaciones T1–T7 post-restart + smoke test |
| [summary-matrix.md](summary-matrix.md) | Matriz resumen de resultados |

## Resumen rápido

| Cambio | Antes | Después | Estado |
|---|---|---|---|
| Binario Engram (OpenCode) | v1.15.13 (`C:\Users\harry\bin\`) | v1.16.1 (`C:\Users\harry\AppData\Local\engram\bin\`) | ✅ Aplicado |
| Project name | Auto-detect (con drift) | `--project=opencode-architecture` explícito | ✅ Aplicado |
| opencode.jsonc | v1.15.13 path hardcoded | v1.16.1 path + --project | ✅ Sincronizado |
| config.toml (Codex) | v1.15.13 (vía PATH) | Sin cambios | ⏸ No tocado |
| Plugin / AGENTS.md / MCP | — | Sin cambios | ❌ No tocado |

## Resultados de validación

| Test | Resultado | Detalle |
|---|---|---|
| T1 — Procesos | ✅ PASS | OpenCode usa v1.16.1; 3 procesos legacy v1.15.13 de sesión anterior |
| T2 — Doctor | ✅ PASS | 4/4 checks OK, sin drift, 0 errores |
| T3 — mem_context | ✅ PASS | Recupera contexto relevante de `opencode-architecture`, source `explicit_override` |
| T4 — mem_save ficticio | ✅ PASS | Memoria TEST-E4B-STABILIZATION guardada (id=400) |
| T5 — mem_search | ✅ PASS | Recupera id=400 correctamente |
| T6 — mem_session_summary | ✅ PASS | Guardado como `observations.type=session_summary` (id=401) |
| T7 — No guardar ruido | ✅ PASS | Sin `mem_save` por ruido; user_prompts sin nuevos capturados |

## Riesgos residuales

| Riesgo | Severidad | Descripción |
|---|---|---|
| Procesos v1.15.13 legacy | 🟢 Baja | 3 procesos de sesión anterior siguen activos; no interfieren con OpenCode |
| opencode.jsonc duplicación | 🟢 Baja | Ambos archivos apuntan al mismo binario y project; no hay conflicto |
| Codex usa v1.15.13 | 🟢 Baja | Store compartido, binario diferente; documentado |
| Prompt capture (plugin) | 🟡 Medio | 302 user_prompts; gate pendiente para E6 |
