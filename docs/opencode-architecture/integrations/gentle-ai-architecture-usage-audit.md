# gentle-ai Architecture Usage Audit

> **Estado:** ✅ AUDIT COMPLETED — Decisión validada
> **Fecha:** 2026-06-17
> **Propósito:** Auditar el uso de gentle-ai dentro de la arquitectura OpenCode, validar la decisión de mantenerlo como alignment-only, y documentar condiciones para una posible integración futura.

---

## 1. ¿Qué es gentle-ai dentro de esta arquitectura?

gentle-ai es un **sistema externo de referencia estratégica**. No es un componente runtime de OpenCode. No es un skill. No es un subagente. No es un plugin. No es una dependencia.

En la arquitectura actual, gentle-ai aparece solo en:
- Documentos de auditoría de alineación (`gentle-ai-alignment.md`)
- Context pack `GENTLE_AI_ALIGNMENT_PACK` (modo Arquitectura+)
- Plan de transición Manager/gentle (existente pero no activo)
- Menciones contextuales en 7 documentos del proyecto

**Decisión base validada:** gentle-ai NO es dependencia runtime de OpenCode. gentle-ai NO se usa en el Manager por defecto. gentle-ai NO se instala como parte obligatoria del Manager.

---

## 2. ¿Qué partes de gentle-ai son útiles?

| Patrón/Componente | Útil como | ¿Transferible? |
|-------------------|-----------|:--------------:|
| SDD Pipeline (explore→propose→spec→design→tasks→apply→verify→archive) | Metodología reusable | ✅ Ya implementado en SDD subagents |
| Thin orchestrator pattern | Principio arquitectónico | ✅ Manager lo sigue |
| Return envelope (compacto) | Contrato de comunicación | ⚠️ Ya existe en Manager |
| Phase delegation con subagentes | Patrón de orquestación | ✅ SDD subagents implementan esto |
| Superpowers brainstorming | Metodología de intake | ⚠️ Se usa en Manager cuando está disponible |
| Noise/quality gates | Concepto de calidad | ✅ Manager tiene sus propios gates |

---

## 3. ¿Qué patrones de gentle-ai conviene reutilizar?

| Patrón | Dónde aplica | Prioridad |
|--------|-------------|:---------:|
| Clasificación Tiny/Small/Medium/Large | Manager Phase 0 | ✅ Ya implementado |
| SDD phase skills con executor override | SDD subagents | ✅ Ya implementado |
| Completion Contract con secciones | Manager Phase 8 | ✅ Ya implementado |
| `gentle-ai doctor` → ecosistema diagnostics | Manager Phase 7 (debugging) | 🟡 Bajo — `opencode` no tiene equivalente directo |
| Context packs design | Fase F | ✅ Diseñado |
| Anti-loop guardrails | Manager Protocol | ✅ Ya implementado |

---

## 4. ¿Qué NO debe integrarse todavía?

| Componente | Razón |
|------------|-------|
| `gentle-orchestrator` como agente primario | Decisión tomada: Manager es el único primario |
| `gentle-ai` como skill obligatorio | No debe haber dependencia runtime |
| `gentle-ai` en tool schemas | Sin aprobación explícita |
| `gentle-ai` en plugin hooks | Sin aprobación explícita |
| `gentle-ai` como perfil `full` en repo nuevo | El perfil `full` debe ser OpenCode-nativo |

---

## 5. ¿El Manager debe invocar gentle-ai?

**No.** El Manager actual no invoca `gentle-orchestrator`. La decisión arquitectónica (ADR-001, ADR-003) establece que:

- Manager es el único orquestador primario.
- `gentle-orchestrator` pasó a `mode: subagent`.
- Manager NO debe usar `gentle-orchestrator` por defecto.
- Manager usa SDD subagents directamente.

Esta decisión **sigue siendo correcta** y no se recomienda cambiarla.

---

## 6. ¿gentle-ai debe ser subagente?

**No.** gentle-ai (como sistema) no debe ser subagente de OpenCode. `gentle-orchestrator` (el agente) existe como subagente, pero no se usa por defecto.

Si en el futuro se decidiera integrar, gentle-ai debería ser:
- Un skill opcional invocable bajo demanda
- No un subagente con tools delegadas
- No un agente primario

---

## 7. ¿gentle-ai debe ser tool?

**No.** No debe haber tool schemas de gentle-ai en OpenCode sin aprobación explícita. Las tools de gentle-ai (`mem_save`, `mem_search`, etc.) son conceptualmente equivalentes a las de Engram, pero no deben duplicarse ni solaparse.

---

## 8. ¿gentle-ai debe tener perfil instalable en el repo nuevo?

**No en el perfil `full`.** Podría existir un perfil opcional `gentle-alignment` que contenga solo documentación y patrones referenciales. Pero:

- No debe incluir código runtime.
- No debe incluir plugins.
- No debe ser parte del perfil `full`.
- No debe ser instalable por defecto.

---

## 9. ¿Qué significa alignment-only?

**alignment-only** significa:

1. gentle-ai se reconoce como sistema relacionado estratégicamente.
2. Se documentan referencias cruzadas para trazabilidad.
3. No hay dependencia runtime entre OpenCode y gentle-ai.
4. No se modifican configuraciones de gentle-ai desde OpenCode.
5. Los patrones de Fase F son reutilizables por gentle-ai si decide adoptarlos.
6. Cualquier integración futura requiere: decision record + contrato + adapter + tests.

---

## 10. ¿Qué condiciones permitirían una integración futura?

| Condición | Detalle |
|-----------|---------|
| **C1** | Existe un decision record aprobado que justifica la integración |
| **C2** | Se define un contrato de interfaz (AlignmentContract) |
| **C3** | Se implementa un adapter del lado de OpenCode |
| **C4** | Se implementa un adapter del lado de gentle-ai |
| **C5** | Los tests de gentle-ai boundary siguen pasando |
| **C6** | La integración es reversible sin pérdida de datos |
| **C7** | La integración no aumenta el contexto fijo del Manager |
| **C8** | No hay dependencia circular gentle-ai ↔ OpenCode |

---

## 11. ¿Qué tests evitarían integración accidental?

Ver `gentle-ai-boundary-test-plan.md` para el plan completo.

Tests mínimos:
1. Manager no requiere gentle-ai → debe responder sin gentle-ai
2. Perfil `full` no incluye gentle-ai runtime → verificar inventario
3. gentle-ai solo aparece en `docs/alignment/` → grep en docs no runtime
4. No hay tool `gentle-ai` obligatoria → verificar schemas runtime
5. No hay subagente `gentle-ai` obligatorio → verificar agentes en opencode.json
6. No hay dependencia OpenCode ↔ gentle-ai → verificar imports, plugins, config
7. Cualquier integración futura requiere decision record → verificar log

---

## 12. Recomendación

### Mantener gentle-ai como `alignment-only`

| Dimensión | Decisión |
|-----------|----------|
| Runtime | ❌ NO usar gentle-ai dentro del Manager por defecto |
| Documentación | ✅ SÍ mantener referencias en docs/alignment/ |
| Perfiles | ❌ NO incluir gentle-ai en perfil `full` |
| Perfiles | ⚠️ Perfil `gentle-alignment` opcional solo documental/patrones |
| Dependencia | ❌ NO crear dependencia runtime OpenCode ↔ gentle-ai |
| Patrones | ✅ SÍ documentar patrones reutilizables de gentle-ai |
| Integración futura | ⏸️ Pendiente de C1-C8 |

### ¿Cambiar la decisión base?

**No.** La decisión base sigue siendo correcta. No hay evidencia que justifique cambiar la política de alineación.

| Argumento | Postura |
|-----------|---------|
| "gentle-ai tiene mejores patrones de SDD" | ✅ Ya se adoptaron los patrones de SDD en Manager. La implementación es independiente. |
| "gentle-ai debería ser el orquestador" | ❌ Manager ganó esa decisión en ADR-001. No hay razón para revertir. |
| "gentle-ai tiene tools de memoria mejores" | ❌ Engram es el sistema de memoria de OpenCode. Son arquitecturas diferentes. |
| "habría menos código duplicado" | ❌ No hay código duplicado. Hay documentación referencial. La duplicación sería la integración, no su ausencia. |

---

*Fin de gentle-ai-architecture-usage-audit.md*
