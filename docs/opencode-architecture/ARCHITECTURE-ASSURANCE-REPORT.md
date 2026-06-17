# Architecture Assurance Report

> **Fase:** Architecture README & Assurance Refresh  
> **Fecha:** 2026-06-17  
> **Estado:** ASSURANCE COMPLETE — PASS WITH WARNINGS  
> **Alcance:** documentación, auditoría y aseguramiento. Sin cambios runtime.

---

## 1. Arquitectura esperada

La arquitectura esperada es un sistema OpenCode gobernado por un **Manager primary único**, con subagentes especializados, memoria persistente, filtros de ruido/secretos, reducción de contexto y controles de exportabilidad.

Principios esperados:

1. Manager responde por defecto y mantiene control de orquestación.
2. Subagentes SDD ejecutan fases, no compiten como primary.
3. `sdd-init` inicia SDD y produce `SDD_INIT_PACKET`.
4. Engram guarda memoria útil y recupera contexto vía `mem_context`.
5. Noise Gate evita ruido, secretos y contaminación de memoria.
6. Fase F reduce tokens con F4A-lite/F4C y mantiene F4B como PARTIAL hasta compactación natural real.
7. gentle-ai externo es alignment-only, no dependencia runtime.
8. `gentle-orchestrator` local es subagente, no gentle-ai externo.
9. Ponytail Code Gate existe como guidance en AGENTS.md, no como plugin operativo instalado.
10. El repo nuevo `proyecto-opencode-mem` debe ser sanitizado, portable y testeable.

---

## 2. Evidencia encontrada

| Evidencia | Fuente |
|---|---|
| Manager como primary único | `manager-orchestration-contract.md`, `manager-sdd-decision-package.md` |
| 10 `sdd-*` subagentes con `mode: subagent` | `sdd-subagents-runtime-inventory.md` |
| `sdd-init` existe y es v3.0 | `sdd-init-role-spec.md` |
| `gentle-orchestrator` es subagent local | `gentle-sdd-boundary.md`, `sdd-subagents-runtime-inventory.md` |
| gentle-ai externo es alignment-only | `gentle-ai-activation-policy.md`, `gentle-ai-architecture-usage-audit.md` |
| Ponytail Code Gate está en AGENTS.md | `ponytail-runtime-state-reconciliation.md`, `ponytail-runtime-implementation-report.md` |
| Ponytail plugin/skills no instalados | `ponytail-runtime-state-reconciliation.md` |
| F4A-lite RUNTIME PASS | `F4A-lite-skills-selective-loading-implementation-report.md` |
| F4B PARTIAL | `F-phase-final-closure-report.md` |
| F4C RUNTIME PASS | Fase F reports + harness |
| Regression harness 34/34 PASS | `scripts/F-regression-harness.ps1` |
| 10 gaps pre-runtime-kit | `pre-runtime-kit-gap-analysis.md` |
| 4 senior challenge actions | `manager-sdd-senior-challenge.md` |

---

## 3. Tabla obligatoria de componentes

| Componente | Esperado | Evidencia | Estado | Warning |
|---|---|---|---|---|
| Manager | Primary único, router, delegator, final synthesizer | Contract + decision package | ✅ Confirmado | Tiny ambiguity guard pendiente |
| `sdd-init` | Entry point SDD, v3.0, `SDD_INIT_PACKET` | Role spec + inventory | ✅ Confirmado | Modo standalone para repo limpio pendiente |
| `sdd-explore` | Explorar sin modificar | Inventory | ✅ Confirmado | Return envelope no aplicado formalmente |
| `sdd-propose` | Propuesta con tradeoffs | Inventory | ✅ Confirmado | Return envelope pendiente |
| `sdd-spec` | Spec testeable | Inventory | ✅ Confirmado | Return envelope pendiente |
| `sdd-design` | Diseño técnico | Inventory | ✅ Confirmado | Return envelope pendiente |
| `sdd-tasks` | Tasks verificables | Inventory | ✅ Confirmado | `ponytail: check` depende de guidance |
| `sdd-apply` | Implementación aprobada | Inventory | ✅ Confirmado | Necesita control de scope por Manager |
| `sdd-verify` | Verificación contra spec | Inventory | ✅ Confirmado | Tests nuevos no automatizados |
| `sdd-archive` | Archivo/memoria/cierre | Inventory | ✅ Confirmado | Persistencia decide Manager |
| `sdd-onboard` | Onboarding SDD | Inventory | ✅ Confirmado | Uso bajo demanda |
| `gentle-orchestrator` | Subagent local, no primary | Boundary + inventory | ✅ Confirmado | Prompt inline, no SKILL.md separado |
| gentle-ai externo | alignment-only, no runtime | Policy + audit | ✅ Confirmado | GA-B tests diseñados, no automatizados |
| Engram | Memoria persistente estructurada | Engram docs + harness | ✅ Funcional según arquitectura | No copiar DB real |
| Noise Gate | Filtra useful/noise/secret | Noise Gate docs + harness | ✅ Validado | Mantener sanitización |
| `mem_context` | Recuperación read-only | Suite F + F4C | ✅ Validado | Ranking guidance, no hard enforcement |
| F4A-lite | Compact skill descriptions | F4A-lite report | ✅ RUNTIME PASS | No confundir con F4A-full |
| F4B | RECENT_SESSION_PACK | Final closure report | ⚠️ PARTIAL | Falta compactación natural real |
| F4C | Memory selector guidance | F4C reports | ✅ RUNTIME PASS | Guidance |
| Ponytail Code Gate | Guidance code-task default | Runtime reconciliation | ✅ Implementado documental | Plugin/skills no instalados; post-restart pendiente |
| Regression Harness | 34 checks read-only | Harness run | ✅ 34/34 PASS | No cubre aún todos los Manager/SDD tests |
| Export Readiness | Plan sanitizado para repo nuevo | Export docs | ✅ Completo | Paths absolutos no portables = gap high |

---

## 4. Componentes confirmados

- Manager primary único.
- 10 SDD subagents (`sdd-init` incluido) como `mode: subagent`.
- `gentle-orchestrator` como subagente local.
- `sdd-init` v3.0 confirmado.
- F4A-lite RUNTIME PASS.
- F4C RUNTIME PASS.
- Harness 34/34 PASS.
- gentle-ai alignment-only.
- Ponytail Code Gate en AGENTS.md como guidance.

---

## 5. Componentes pendientes

| Pendiente | Tipo | Prioridad |
|---|---|---|
| Paths absolutos no portables en templates/config | Export readiness | 🔴 Must fix before repo nuevo |
| Return envelope aplicado a prompts SDD | SDD contract | 🟡 Should fix |
| Automatizar 7 tests críticos | Assurance | 🟡 Should fix |
| GPT-5.5 fallback explícito | Quality gate | 🟡 Should fix |
| Regla Tiny ambiguity | Routing | 🟡 Should fix |
| Post-restart validation de Ponytail | Runtime observation | 🟡 Should fix localmente |
| `sdd-init` standalone templates | Repo nuevo | 🟡 Can move |
| install/validate scripts | Repo nuevo | 🟡 Must/Should in repo nuevo |

---

## 6. Agentes/subagentes necesarios

| Agente/Subagente | Necesario para | Estado |
|---|---|---|
| Manager | Orquestación global | ✅ Confirmado |
| `sdd-init` | Arranque SDD | ✅ Confirmado |
| `sdd-explore` | Exploración | ✅ Confirmado |
| `sdd-propose` | Propuestas | ✅ Confirmado |
| `sdd-spec` | Especificaciones | ✅ Confirmado |
| `sdd-design` | Diseño técnico | ✅ Confirmado |
| `sdd-tasks` | Plan de tareas | ✅ Confirmado |
| `sdd-apply` | Implementación | ✅ Confirmado |
| `sdd-verify` | Verificación | ✅ Confirmado |
| `sdd-archive` | Archivo/cierre | ✅ Confirmado |
| `sdd-onboard` | Onboarding | ✅ Confirmado |
| `gentle-orchestrator` | Pipeline local opcional | ✅ Confirmado subagent |

---

## 7. Estado de Engram

Engram funciona como memoria persistente estructurada. La arquitectura validada indica:

- `mem_context` es read-only.
- Noise Gate evita guardar ruido/secretos.
- El Manager decide cuándo consultar y qué persistir.
- No se debe copiar `~/.engram/engram.db` al repo nuevo.
- No se debe tocar `.codex/memories_1.sqlite`.

**Estado:** ✅ Funcional según arquitectura validada.  
**Warning:** DB real excluida de cualquier exportación.

---

## 8. Estado de Ponytail

| Parte | Estado |
|---|---|
| AGENTS.md Code Gate | ✅ Implementado como guidance |
| Plugin Ponytail | ❌ No instalado runtime |
| Ponytail command skills | ❌ No instalados |
| Post-restart validation | ⚠️ Pendiente |
| PT-I tests | Diseñados, no automatizados |

**Conclusión:** Ponytail existe como integración documental/guidance. No afirmar plugin operativo full.

---

## 9. Estado de gentle-ai

| Elemento | Estado |
|---|---|
| gentle-ai externo | alignment-only |
| `gentle-ai` runtime dependency | ❌ No |
| Perfil `full` futuro | ❌ No incluye gentle-ai runtime |
| `gentle-orchestrator` local | ✅ Subagent OpenCode |
| `sdd-*` | ✅ OpenCode-native, inspirados en patrones SDD |

**Conclusión:** No confundir gentle-ai externo con `gentle-orchestrator` local ni con `sdd-*`.

---

## 10. Estado de Fase F

| Workstream | Estado | Evidencia |
|---|---|---|
| F4A-lite | ✅ RUNTIME PASS | 36 descriptions compactas, ahorro 3,532 chars |
| F4A-full | ⏸️ Decision-only | No implementado |
| F4B | ⚠️ PARTIAL | Contract markers presentes; falta compactación natural |
| F4C | ✅ RUNTIME PASS | Selector guidance activo |
| QW#2 | 🧪 Prototype-only | No runtime |
| QW#3 | ⏸️ Proposal-only | No runtime |
| Harness | ✅ 34/34 PASS | Sin FAIL |

---

## 11. Tests ejecutados

| Test | Resultado |
|---|---|
| `scripts/F-regression-harness.ps1` | ✅ 34/34 PASS |

El harness es read-only y valida artifacts, hooks, security, DB invariance, documentation completeness y gentle-ai boundary básico.

---

## 12. Tests diseñados pendientes

| Grupo | Tests | Estado |
|---|---|---|
| Manager/SDD | A-T1..F-T3 | Diseñados, no todos automatizados |
| gentle-ai boundary | GA-B1..GA-B7 | Diseñados |
| Ponytail | PT-I1..PT-I12 | Diseñados |
| Repo nuevo | 19 shareable tests | Diseñados para `proyecto-opencode-mem` |

---

## 13. Gaps antes del repo nuevo

| Gap | Severidad | Acción | Clasificación |
|---|---|---|---|
| Paths absolutos no portables | 🔴 Alta | Crear templates/config con paths relativos | Must fix before repo nuevo |
| Return envelope no aplicado | 🟡 Media | Actualizar prompts SDD | Should fix |
| 7 tests críticos no automatizados | 🟡 Media | Agregar scripts/harness | Should fix |
| GPT-5.5 contingency | 🟡 Media | Documentar fallback Judgment Day/inline | Should fix |
| Tiny ambiguity guard | 🟡 Media | Regla Manager | Should fix |
| Ponytail plugin no instalado | 🟢 Baja | Mantener opcional | Can move |
| Ponytail skills no instalados | 🟢 Baja | Mantener opcional | Can move |
| Ponytail post-restart pendiente | 🟡 Media | Validar localmente | Should fix |
| `sdd-init` standalone | 🟡 Media | Agregar templates | Can move |
| install/validate scripts | 🟡 Media | Crear en repo nuevo | Must/Should in repo nuevo |

---

## 14. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Exportar paths personales | Alto | Sanitization checklist + CI + templates relativos |
| Tratar gentle-ai como runtime | Medio/Alto | Boundary docs + GA-B tests |
| Decir que Ponytail plugin está instalado | Medio | README y assurance aclaran guidance-only |
| Promover F4B a PASS sin evidencia | Medio | Mantener F4B PARTIAL hasta compactación natural |
| Tests Manager/SDD quedan manuales | Medio | Automatizar 7 críticos |
| Subagentes devuelven output libre | Medio | Aplicar `SUBAGENT_RESULT` a prompts |

---

## 15. Respuestas explícitas

### ¿La arquitectura funciona según lo planteado?

Sí, en su núcleo: Manager primary único, SDD subagents confirmados, Engram/Fase F funcionando, gentle-ai separado y Ponytail como guidance. Funciona con warnings.

### ¿Qué está realmente validado?

Harness 34/34, F4A-lite runtime, F4C runtime, F4B markers/contract, gentle-ai boundary básico, documentación principal y runtime inventory.

### ¿Qué está documentado pero no automatizado?

Manager/SDD tests completos, GA-B1..GA-B7, PT-I1..PT-I12, return envelope aplicado en ejecución real.

### ¿Qué no está instalado?

Ponytail plugin y Ponytail command skills. gentle-ai runtime tampoco está instalado ni debe serlo por defecto.

### ¿Qué no debe confundirse?

- gentle-ai externo ≠ `gentle-orchestrator` local.
- `gentle-orchestrator` ≠ Manager.
- SDD subagents ≠ gentle-ai runtime.
- Ponytail guidance ≠ Ponytail plugin operativo.
- F4A-lite PASS ≠ F4A-full implementado.
- F4B PARTIAL ≠ F4B FULL PASS.

### ¿Qué falta antes de `proyecto-opencode-mem`?

Como mínimo: resolver paths portables, decidir qué tests críticos se automatizan antes, documentar fallback de GPT-5.5, aplicar/planificar return envelope, y mantener sanitización estricta.

---

## 16. Recomendación Go/No-Go

| Decisión | Veredicto |
|---|---|
| Avanzar inmediatamente a copiar runtime real | ❌ NO-GO |
| Crear `proyecto-opencode-mem` como repo nuevo sanitizado | ⚠️ GO WITH WARNINGS |
| Exportar DB/memorias/config personal | ❌ NO-GO |
| Exportar templates sanitizados + docs + skills SDD | ✅ GO, después de tratar must-fix |

**Veredicto:** `ARCHITECTURE README & ASSURANCE REFRESH PASS WITH WARNINGS`.

No avanzar a `proyecto-opencode-mem` hasta decidir qué gaps se resuelven antes y cuáles se trasladan explícitamente al repo nuevo.

---

*Fin de ARCHITECTURE-ASSURANCE-REPORT.md*
