# Manager + SDD Decision Package — Closure Phase

> **Estado:** ✅ DECISIONS CAPTURED
> **Fecha:** 2026-06-17
> **Propósito:** Registrar todas las decisiones arquitectónicas tomadas durante la fase de closure — Manager como primary, SDD pipeline, Ponytail integration, gentle-ai boundary — para persistencia en Engram y referencia cross-session.

---

## 1. Decisiones fundamentales

### D1: Manager es el único primary orchestrator

**Estado:** Aceptada ✅

**Decisión:** El Manager AGENTS.md es el único agente que actúa como orchestrator primario. Ningún subagente (sdd-*, gentle-orchestrator) compite por ese rol.

**Alternativas consideradas:**
- Tener gentle-orchestrator como co-orchestrator → Rechazado: divide responsabilidad, riesgo de loops
- Tener SDD agents como agents autónomos → Rechazado: pierde calidad gates, contexto unificado

**Fundamento:** ManagerOWNsOrchestration. Manager tiene el contexto global, los quality gates, la memoria (via Engram) y la responsabilidad de sintetizar al usuario.

**Impacto:** Todos los subagentes deben reportar al Manager. Manager decide cada fase.

---

### D2: SDD pipeline es un conjunto de subagentes delegables

**Estado:** Aceptada ✅

**Decisión:** Los 10 subagentes SDD (sdd-* ) son fases delegables que Manager invoca bajo demanda. No son autónomos.

**Alternativas consideradas:**
- SDD como pipeline secuencial auto-ejecutable → Rechazado: demasiado rígido, no permite que Manager adapte el flujo
- SDD como skills inline → Rechazado: pierde la estructura modular, difícil de mantener

**Fundamento:** Manager decide en qué orden y si ejecuta cada fase. `sdd-init` puede existir como skill con entrada estructurada. Los subagentes tienen executor override para hacer el trabajo ellos mismos y no re-delegar.

**Impacto:** sdd-init es el entry point pero no obligatorio. Manager puede saltar explore si ya conoce el contexto.

---

### D3: sdd-init existe y es el entry point SDD

**Estado:** Aceptada ✅

**Decisión:** `sdd-init` es un skill/subagente instalado que funciona como entry point estructurado para el pipeline SDD.

**Confirmación:** Verificado en runtime (`.codex/skills/sdd-init/SKILL.md` y `.config/opencode/skills/sdd-init/SKILL.md`, version 3.0, `hidden: true`).

**Fundamento:** `sdd-init` provee una estructura probada (SDD_INIT_PACKET) que Manager puede usar o no según el contexto.

**Impacto:** Si `sdd-init` no existe en un runtime nuevo, el Manager ejecuta la inicialización inline sin bloqueo del pipeline.

---

### D4: Ponytail Code Gate es documental

**Estado:** Aceptada ✅

**Decisión:** Ponytail Code Gate está integrado en AGENTS.md como guidance-only. No requiere plugin runtime ni skills instalados.

**Alternativas consideradas:**
- Ponytail como plugin runtime → Rechazado: no necesario, AGENTS.md guidance ya funciona
- Ponytail como skill → Rechazado: el guidance en AGENTS.md es suficiente para code tasks
- No integrar Ponytail → Rechazado: proporciona disciplina de simplificación valiosa

**Fundamento:** El guidance en AGENTS.md (opencode-architecture:ponytail-integration) es suficiente. Manager lo aplica durante code tasks. Los markers `ponytail:` en el código y el `ponytail: check` en SDD Tasks son mecanismos ligeros que no requieren runtime adicional.

**Impacto:** Ponytail no requiere instalación extra. Funciona desde AGENTS.md y la disciplina del Manager. `ponytail-review`, `ponytail-audit`, `ponytail-debt` skills existen en repo pero no se instalan ni se necesitan para el flujo básico.

---

### D5: gentle-ai es alignment-only

**Estado:** Aceptada ✅

**Decisión:** gentle-ai se usa como lente de alineación (evaluación arquitectónica, verificación de patrones) pero NO como runtime ejecutable.

**Alternativas consideradas:**
- gentle-ai como runtime integrado → Rechazado: el análisis completo determinó que no es necesario y añade complejidad
- gentle-ai como herramienta de debugging → Rechazado: para debugging se usan las herramientas de OpenCode (revisión, GPT-5.5)

**Fundamento:** La alineación con gentle-ai (pronósticos 2026, visión 2028) es útil para asegurar que la arquitectura no diverge de la visión futura. El runtime no aporta valor adicional sobre las herramientas existentes.

**Impacto:** `gentle-alignment` es un perfil opcional y documental. No se activa por defecto. La guía de alineación se actualiza al ritmo de los pronósticos.

---

### D6: gentle-orchestrator es subagente local

**Estado:** Aceptada ✅

**Decisión:** `gentle-orchestrator` existe en opencode.json como `mode: subagent`. Manager puede delegarle tareas Large/structured.

**Fundamento:** Es un subagente más del ecosistema. No tiene autoridad de orchestrator. Manager lo invoca como cualquier otro subagente.

**Impacto:** `gentle-orchestrator` tiene anti-loop guards en su prompt. Puede llamar a `sdd-*` subagentes. NO puede llamar a Manager. NO puede ejecutar inline.

---

### D7: Return envelope estandarizado

**Estado:** Aceptada ✅

**Decisión:** Todos los subagentes SDD deben devolver un envelope estructurado (`## SUBAGENT_RESULT`) que el Manager usa para sintetizar la respuesta final.

**Fundamento:** El Manager necesita un formato predecible para tomar decisiones y construir la respuesta al usuario.

**Impacto:** Documentado en subagent-return-envelope.md como referencia. Aplicable a todos los subagentes SDD.

---

### D8: Fallback ante subagente faltante

**Estado:** Aceptada ✅

**Decisión:** Si un subagente SDD no está disponible (no instalado, no configurado), el Manager ejecuta esa fase del pipeline directamente.

**Fundamento:** El pipeline nunca debe bloquearse por falta de un subagente. Manager es suficiente para todas las fases.

**Impacto:** Los subagentes SDD son optimización, no dependencia. Manager siempre puede operar solo.

---

## 2. Decisiones de runtime

### DR1: No modificar opencode.json durante closure

**Estado:** Aceptada ✅

**Decisión:** Durante esta fase de closure, no se modifica opencode.json. Solo se inspecciona y documenta.

**Fundamento:** Evitar cambios no controlados en la configuración activa del runtime.

---

### DR2: No modificar AGENTS.md durante closure

**Estado:** Aceptada ✅

**Decisión:** AGENTS.md solo se lee y verifica. Las modificaciones de Ponytail ya están hechas (de fases anteriores).

**Fundamento:** AGENTS.md es el entry point del Manager. Cambios en closure pueden introducir regresiones.

---

### DR3: No instalar plugins Ponytail

**Estado:** Aceptada ✅

**Decisión:** No se copia `ponytail.mjs` al runtime. No se modifica opencode.json para incluir el plugin.

**Fundamento:** El guidance en AGENTS.md es suficiente. El plugin no es necesario.

---

### DR4: No instalar skills Ponytail

**Estado:** Aceptada ✅

**Decisión:** No se copian `ponytail-review`, `ponytail-audit`, `ponytail-debt` skills al runtime.

**Fundamento:** No se necesitan para el flujo actual. Se pueden instalar en el futuro si se requiere auditoría post-implementación.

---

## 3. Decisiones de exportación

### DE1: SDD agents se exportan como skills sanitizados

**Estado:** Aceptada ✅

**Decisión:** Al crear `proyecto-opencode-mem`, los SDD agents se exportan como SKILL.md sanitizados (sin paths personales, sin referencias a runtime específico).

**Fundamento:** Los skills SDD son útiles en cualquier runtime OpenCode, independientemente de la configuración local.

---

### DE2: Config de subagentes se exporta como template

**Estado:** Aceptada ✅

**Decisión:** La configuración de opencode.json para los subagentes se exporta como `opencode.example.json`.

**Fundamento:** Cada instalación necesita adaptar la configuración a su entorno (paths, permissions).

---

### DE3: Perfil `full` incluye SDD + Ponytail + Engram

**Estado:** Aceptada ✅

**Decisión:** El perfil `full` para exportación incluye Manager, SDD agents, Engram memory, y Ponytail Code Gate guidance.

**Fundamento:** Es el conjunto mínimo para un ecosistema OpenCode completo. NO incluye gentle-ai runtime.

---

## 4. Decisiones de quality

### DQ1: Tests de Manager + SDD son ejecutables

**Estado:** Aceptada ✅

**Decisión:** Los tests definidos en manager-sdd-test-plan.md son ejecutables y deben correr como parte del regression harness.

**Fundamento:** Validar que las decisiones arquitectónicas se mantienen en el tiempo.

---

### DQ2: Manager es responsable de los quality gates finales

**Estado:** Aceptada ✅

**Decisión:** El Manager tiene la responsabilidad final de:
1. Clasificación de tareas
2. Quality gates (review, GPT-5.5, senior challenge)
3. Síntesis al usuario
4. Persistencia en Engram

**Fundamento:** Manager es el único agente con contexto completo. Subagentes ejecutan fases, Manager garantiza calidad.

---

## 5. Tabla resumen

| ID | Decisión | Estado | Prioridad |
|:--:|----------|:------:|:---------:|
| D1 | Manager es el único primary orchestrator | ✅ | 🔴 Alta |
| D2 | SDD pipeline es conjunto de subagentes delegables | ✅ | 🔴 Alta |
| D3 | sdd-init existe y es entry point SDD | ✅ | 🔴 Alta |
| D4 | Ponytail Code Gate es documental | ✅ | 🟡 Media |
| D5 | gentle-ai es alignment-only | ✅ | 🔴 Alta |
| D6 | gentle-orchestrator es subagente local | ✅ | 🔴 Alta |
| D7 | Return envelope estandarizado | ✅ | 🟡 Media |
| D8 | Fallback ante subagente faltante | ✅ | 🔴 Alta |
| DR1 | No modificar opencode.json durante closure | ✅ | 🔴 Alta |
| DR2 | No modificar AGENTS.md durante closure | ✅ | 🔴 Alta |
| DR3 | No instalar plugins Ponytail | ✅ | 🟡 Media |
| DR4 | No instalar skills Ponytail | ✅ | 🟢 Baja |
| DE1 | SDD agents exportados como skills sanitizados | ✅ | 🟡 Media |
| DE2 | Config exportada como template | ✅ | 🟡 Media |
| DE3 | Perfil full incluye SDD + Ponytail + Engram | ✅ | 🟡 Media |
| DQ1 | Tests ejecutables en harness | ✅ | 🟡 Media |
| DQ2 | Manager responsable de quality gates | ✅ | 🔴 Alta |

---

## 6. Decisiones pendientes

Actualmente no hay decisiones pendientes en esta fase de closure.

La próxima fase (proyecto-opencode-mem) requerirá decision package propio.

---

*Fin de manager-sdd-decision-package.md*
