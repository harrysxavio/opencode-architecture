# Fase D — Manager ↔ gentle-orchestrator Transition

## Estado

D3_APPLIED__D4_RESTART_REQUIRED

## Resumen ejecutivo

Se aplicó el cambio mínimo autorizado en `C:\Users\harry\.config\opencode\opencode.json`:

- `gentle-orchestrator` cambió de `mode: "primary"` a `mode: "subagent"`.
- El prompt del Manager reemplazó la prohibición absoluta de invocar `gentle-orchestrator` por una regla controlada.
- El prompt de `gentle-orchestrator` declara que es SDD Pipeline subagent, no primary.
- Se agregaron guardrails anti-loop y envelope compacto obligatorio.
- JSON validado correctamente con Node.

## Estado de validación

OpenCode fue reiniciado y D-T1 fue ejecutado en sesión limpia. D-T1 pasó: Manager respondió directo, `gentle-orchestrator` no apareció, no hubo tools/MCP/memoria/skills/subagentes. Faltan D-T5-read-only, D-T5-pipeline-dry-run y D-T3.

## Hallazgo importante

D-T1 expuso tokens reales: 40,017 input tokens, 27 output, 47 reasoning, 40,091 total. El routing Tiny está sano, pero el overhead real de contexto es mayor que la estimación preliminar.

## Archivos funcionales modificados

| Archivo | Cambio |
|---|---|
| `C:\Users\harry\.config\opencode\opencode.json` | mode + prompts Manager/gentle |

## Archivos funcionales NO modificados

- `opencode.jsonc`
- `AGENTS.md`
- Engram
- MCP
- skills
- sdd-* subagentes
- plugins
- secretos
