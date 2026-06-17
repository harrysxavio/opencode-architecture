# Pre-Runtime Kit Readiness Gate

> **Fase:** Pre-Runtime Kit Readiness Gate  
> **Fecha:** 2026-06-17  
> **Estado:** PASS WITH WARNINGS  
> **Alcance:** documentación, auditoría y validación read-only. No se crea repo nuevo.

---

## 1. Resultado ejecutivo

El gate reconcilia los gaps mínimos antes de crear `proyecto-opencode-mem`. No modifica runtime. La única severidad roja es **paths absolutos no portables**; queda cerrada como plan concreto mediante `PORTABILITY-MAP.md` y `OPENCODE-CONFIG-TEMPLATE-SPEC.md`.

**Veredicto del gate:** `PRE-RUNTIME KIT READINESS PASS WITH WARNINGS`.

---

## 2. Tabla final de gaps

| Gap | Estado actual | Severidad | Decisión | Bloquea repo nuevo | Acción |
|---|---|---|---|---:|---|
| Paths absolutos no portables | Confirmado en `opencode.json`, comandos, MCP, docs y ejemplos | 🔴 Alta | `MUST FIX BEFORE NEW REPO` | Sí | Crear templates con variables `${OPENCODE_CONFIG_DIR}`, `${OPENCODE_SKILLS_DIR}`, `${OPENCODE_CODEX_SKILLS_DIR}`, `${ENGRAM_DB_PATH}`, `${PROJECT_ROOT}`. No copiar config real. |
| Return envelope no aplicado a todos los prompts SDD | `SUBAGENT_RESULT` definido en docs, no presente en SKILL.md SDD; `gentle-orchestrator` ya tiene compact JSON envelope | 🟡 Media | `SHOULD FIX BEFORE NEW REPO` | No crítico | Implementar en templates del repo nuevo; no tocar runtime ahora. |
| 7 tests críticos Manager/SDD no automatizados | Test plan existe; nuevo script read-only cubre la parte automatizable | 🟡 Media | `SHOULD FIX BEFORE NEW REPO` | No crítico si reportado | Usar `scripts/manager-sdd-assurance.ps1`; mantener A-T1 funcional como WARN/manual. |
| GPT-5.5 fallback pendiente | No estaba formalizado | 🟡 Media | `SHOULD FIX BEFORE NEW REPO` | No | Crear plan de fallback documental; no tocar Manager prompt ahora. |
| Tiny ambiguity guard pendiente | No estaba formalizado | 🟡 Media | `SHOULD FIX BEFORE NEW REPO` | No | Crear política documental; aplicar a templates futuros. |
| Ponytail post-restart validation pendiente | Guidance existe; plugin/skills no instalados; comportamiento post-restart no observado aquí | 🟡 Media | `CAN MOVE TO NEW REPO` | No | Mantener pending si no hay evidencia de restart; validar con prompts controlados tras restart. |
| `sdd-init` standalone para runtime limpio | `sdd-init` existe v3.0, pero runtime limpio necesita plantilla | 🟡 Media | `CAN MOVE TO NEW REPO` | No | Incluir `SDD_INIT_PACKET` y referencias en templates del repo nuevo. |
| install/validate scripts SDD | No existen aún como kit portable | 🟡 Media | `CAN MOVE TO NEW REPO` | No | Crear en el repo nuevo usando template spec. |
| Ponytail plugin no instalado | Confirmado no instalado | 🟢 Baja | `DEFER` | No | Mantener plugin opcional, nunca default. |
| Ponytail skills no instalados | Confirmado no instalados | 🟢 Baja | `DEFER` | No | Mantener command skills opcionales, no requeridos para full. |
| gentle-orchestrator sin SKILL.md file | Prompt inline en `opencode.json` | 🟢 Baja | `CAN MOVE TO NEW REPO` | No | Exportar como config template; no crear archivo runtime ahora. |
| Skills SDD sin versionamiento central | Versiones existen por frontmatter, sin registro central | 🟢 Baja | `DEFER` | No | Evaluar skill registry en repo nuevo. |

---

## 3. Reconciliación entre fuentes

| Fuente | Clasificación previa | Reconciliación final |
|---|---|---|
| README | Paths = must, envelope/tests/fallback/tiny = should, Ponytail plugin/skills = can move/defer | Se mantiene. |
| Architecture Assurance Report | Paths must; return envelope/tests/fallback/tiny should; sdd-init/install can move | Se mantiene. |
| pre-runtime-kit gap analysis | G2 rojo; G1/G6/G8/G10 post-closure; G3/G4/G5/G7/G9 aceptables | Se precisa: G2 must before repo; G1/G6 can move; G8/G10 should before repo; G3/G4/G7 defer. |
| manager-sdd test plan | 21 tests diseñados; 7 críticos automatizables | Se crea script separado read-only para los 7 críticos automatizables/parciales. |

---

## 4. Decisiones del gate

1. **No tocar runtime real.** Todo cambio de prompts/config se mueve a templates o docs.
2. **No crear repo nuevo todavía.** Este gate solo deja la puerta lista.
3. **Paths absolutos quedan cerrados como plan**, no como modificación real.
4. **Return envelope se implementará en templates del repo nuevo**, salvo aprobación posterior para tocar prompts reales.
5. **Manager/SDD assurance se separa del harness Fase F** en un script nuevo read-only.
6. **Ponytail sigue guidance-only.** No plugin, no command skills.
7. **gentle-ai sigue alignment-only.** No runtime dependency.

---

## 5. Estado Go/No-Go

| Acción | Estado |
|---|---|
| Copiar runtime real | ❌ NO-GO |
| Copiar DB/memorias | ❌ NO-GO |
| Crear repo nuevo sin templates sanitizados | ❌ NO-GO |
| Crear repo nuevo después de este gate usando templates | ⚠️ GO CONTROLADO si ambos harnesses pasan |

---

*Fin de PRE-RUNTIME-KIT-READINESS-GATE.md*
