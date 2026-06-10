# E2 — Root Cause Analysis

## Causa raíz más probable

La memoria Engram no estaba rota; el diagnóstico anterior miró la DB equivocada (`.codex\memories_1.sqlite`). El store semántico real está en `~\.engram\engram.db` y funciona.

El problema real es de **gobernanza y configuración**:

1. Fuentes duplicadas de configuración MCP e instrucciones.
2. Binarios Engram duplicados y con versiones distintas.
3. Múltiples procesos Engram activos.
4. Persistencia de prompts habilitada sin política de ruido visible.
5. Drift de nombres de proyecto (`arquitectura opencode` vs `opencode-architecture`).
6. `mem_session_summary` funciona, pero no donde se esperaba: guarda observation `session_summary`, no `sessions.summary`.

## Matriz de hipótesis

| Hipótesis | Evidencia | Estado | Acción |
|---|---|---|---|
| Engram `mem_save` no escribe a DB esperada | id=395 aparece en `~\.engram\engram.db.observations` | NO VALIDADO como bug; la DB esperada era incorrecta | Actualizar docs y pruebas para mirar `~\.engram\engram.db` |
| `mem_context` usa contexto de sesión, no memoria durable | `mem_context` muestra observations de `~\.engram\engram.db`; CLI/DB confirma | NO | Mantener prueba DB/CLI para evidencia durable |
| Hay varias instancias Engram compitiendo | 3 procesos: 1 serve + 2 MCP | VALIDADO | Consolidar binario/config en E4 si se aprueba |
| Config duplicada crea DBs distintas | No se hallaron DBs distintas de Engram; sí hay binarios/config duplicados | PARCIAL | Unificar config para reducir procesos y ambigüedad |
| Falta tabla `observations` por diseño | Falta en `.codex\memories_1.sqlite`; existe en `~\.engram\engram.db` | VALIDADO como diagnóstico anterior incorrecto | Corregir documentación |
| session summary no está conectado | id=396 se guardó como observation; `sessions.summary` vacío | PARCIAL | Documentar contrato real o ajustar si se requiere summary en sessions |
| permisos/path incorrectos | `doctor` no reporta locks; DB WAL ok | NO | Sin acción inmediata |
| instrucciones duplicadas generan uso incorrecto | AGENTS.md + engram-instructions.md + plugin MEMORY_INSTRUCTIONS + skill | VALIDADO | Proponer consolidación mínima |
| prompts completos se guardan sin filtro suficiente | `user_prompts` tiene 302 rows; plugin captura prompts >10 chars truncados a 2000 | VALIDADO | Proponer gate/política o desactivar prompt capture si no aporta |
| project drift reduce recuperabilidad | `engram doctor --json` detectó 14 mismatches | VALIDADO | Usar proyecto explícito y consolidar nombres |
