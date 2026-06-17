# F4A-lite Skills Selective Loading Implementation Report

**Fecha:** 2026-06-17 11:09  
**Estado:** PASS WITH WARNINGS

## Qué se implementó

Se compacto el indice visible de skills usado por OpenCode (`description:` en frontmatter de `SKILL.md`) sin tocar instrucciones internas.

## Ejecución

1. Canary controlado: `hatch-pet`, `frontend-design`, `bigquery-expert`, `sandbox-data-loader`, `find-skills`.
2. Validación canary: 0 errores + harness 27/27 PASS.
3. Lote completo por grupos: `.codex/skills/`, `.config/opencode/skills/`, `Tools/.agents/skills/`, `.agents/skills/graphify`.
4. Validación completa: 0 errores.

## Evidencia

| Control | Resultado |
|---|---:|
| Skills modificadas | 36 |
| YAML/frontmatter valido | PASS |
| Solo `description:` cambiado | PASS |
| Cuerpo intacto por body hash | PASS |
| `.system` no modificado | PASS |
| Backup centralizado | PASS |
| Manifest JSON | PASS |
| `opencode.json` no modificado | PASS |

## Post-restart Validation (2026-06-17 11:18)

| Control | Resultado |
|---|---:|
| On-disk descriptions coinciden con manifest | 36/36 ✅ |
| F4B contract markers presentes | ✅ |
| F4C selector guidance activo | 9/9 PASS ✅ |
| Harness post-restart | 34/34 PASS ✅ |
| opencode.json SHA256 sin cambios | ✅ |
| Security / DB invariants | ✅ |
| Runtime `<available_skills>` cargó descripciones viejas | ⚠️ Esperado — OpenCode no reiniciado |

**FINDING:** El runtime `<available_skills>` de esta sesión aún muestra las descripciones originales (pre-F4A-lite). Las 36 descripciones en disco son correctas y compactas. OpenCode lee SKILL.md al arrancar; sin restart del proceso, el runtime cache persiste. No es un error — es comportamiento esperado.

## Warning

Se requiere reiniciar OpenCode para que el runtime reconstruya `<available_skills>` con las descripciones compactas. F4B permanece PARTIAL hasta compactacion natural real con `RECENT_SESSION_PACK`. Los 34/34 harness tests PASS y 36/36 descripciones en disco coinciden con el manifest.
