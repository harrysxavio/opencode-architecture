# F4A-lite Skills Audit

**Fecha:** 2026-06-17 11:09  
**Estado:** ✅ auditado e implementado con canary + lote completo

## Fuente real

<available_skills> no vive en opencode.json. OpenCode lo genera desde el frontmatter description: de los SKILL.md visibles.

## Fuentes modificadas

| Fuente | Cantidad modificada | Criterio |
|---|---:|---|
| .codex/skills/ | 23 | Skills que aparecen desde esa fuente y tienen prioridad; excluye .system y _shared. |
| .config/opencode/skills/ | 8 | Skills únicas visibles desde esa fuente. |
| Tools/.agents/skills/ | 4 | Skills de proyecto visibles. |
| .agents/skills/graphify | 1 | Skill externo visible. |

## Totales

| Métrica | Valor |
|---|---:|
| Skills modificadas | 36 |
| Chars antes | 6360 |
| Chars después | 2828 |
| Ahorro | 3532 chars |

## Controles

- Solo cambió description: del frontmatter.
- Cuerpo de cada skill validado con hash antes/después.
- .system no modificado.
- opencode.json no modificado.
- No DB/schema/gentle-ai changes.
