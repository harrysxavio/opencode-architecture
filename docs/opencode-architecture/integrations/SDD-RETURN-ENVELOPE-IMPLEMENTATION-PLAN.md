# SDD Return Envelope Implementation Plan

> **Estado:** PLAN DEFINED — no runtime edit  
> **Fecha:** 2026-06-17  
> **Scope:** aplicar el contrato `## SUBAGENT_RESULT` en templates futuros, no en prompts reales durante este gate.

---

## 1. Resultado

La auditoría read-only confirmó que el contrato existe como documento (`subagent-return-envelope.md`), pero los `SKILL.md` SDD auditados no contienen el marker literal `SUBAGENT_RESULT`.

**Decisión:** resolverlo en el kit portable/template antes o durante creación de `proyecto-opencode-mem`; no tocar runtime real ahora.

---

## 2. Evidencia

| Fuente | Hallazgo |
|---|---|
| `docs/opencode-architecture/integrations/subagent-return-envelope.md` | Define el contrato `## SUBAGENT_RESULT`. |
| `sdd-init-role-spec.md` | Define `SDD_INIT_PACKET` y rol de `sdd-init`. |
| `.config/opencode/skills/sdd-*/SKILL.md` | No contienen marker literal `SUBAGENT_RESULT` en auditoría read-only. |
| `.codex/skills/sdd-*/SKILL.md` | No contienen marker literal `SUBAGENT_RESULT` en auditoría read-only. |
| `opencode.json` real | `gentle-orchestrator` usa compact JSON envelope, pero no necesariamente `SUBAGENT_RESULT`. |

---

## 3. Template objetivo

Cada subagente SDD debe cerrar con:

```markdown
## SUBAGENT_RESULT

status: PASS | PASS_WITH_WARNINGS | BLOCKED
phase: sdd-init | sdd-explore | sdd-propose | sdd-spec | sdd-design | sdd-tasks | sdd-apply | sdd-verify | sdd-archive | sdd-onboard
summary: <1-3 bullets>
files_read:
  - <path>
files_changed:
  - <path or none>
verification:
  - <command/result or not run + why>
risks:
  - <risk or none>
next_recommended_phase: <phase or none>
manager_action_required: <yes/no + reason>
```

---

## 4. Aplicación por fase

| Fase | Requisito adicional |
|---|---|
| `sdd-init` | Debe incluir `SDD_INIT_PACKET` y `SUBAGENT_RESULT`. |
| `sdd-explore` | Debe separar evidencia leída de hipótesis. |
| `sdd-propose` | Debe indicar scope/out-of-scope y si requiere aprobación. |
| `sdd-spec` | Debe listar acceptance criteria testables. |
| `sdd-design` | Debe listar file impact y riesgos. |
| `sdd-tasks` | Debe entregar tareas ordenadas y verificación por tarea. |
| `sdd-apply` | Debe listar archivos cambiados y desviaciones del plan. |
| `sdd-verify` | Debe incluir comandos, resultados y criterios fallidos. |
| `sdd-archive` | Debe confirmar sync/archivo/memoria o explicar waiver. |
| `sdd-onboard` | Debe cerrar con estado y siguiente fase. |

---

## 5. Criterios de aceptación

- [ ] Los 10 `sdd-*` templates contienen `## SUBAGENT_RESULT`.
- [ ] `sdd-init` conserva `SDD_INIT_PACKET`.
- [ ] Ningún subagente se presenta como primary.
- [ ] Ningún subagente delega a Manager.
- [ ] Manager sigue sintetizando la respuesta final.
- [ ] El harness futuro valida marker y fields mínimos.

---

## 6. Rollback

Como el cambio se aplicará en templates, rollback = revertir el template antes de instalar. No hay DB ni runtime real involucrado.

---

*Fin de SDD-RETURN-ENVELOPE-IMPLEMENTATION-PLAN.md*
