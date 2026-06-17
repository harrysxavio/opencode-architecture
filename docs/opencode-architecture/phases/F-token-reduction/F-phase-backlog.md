# Fase F — Backlog Controlado de Decisiones Pendientes

**Propósito:** Separar por categorías el estado de cada decisión/implementación pendiente, con descripción, beneficio, riesgo y decisión necesaria.

**Fecha de cierre:** 2026-06-17

---

## A. Listo para observar (no requiere cambios)

Ítems que ya están implementados o instalados y solo requieren que ocurra un evento natural para validarse.

### A1. F4B Compactación natural

| Campo | Detalle |
|---|---|
| **Descripción** | `RECENT_SESSION_PACK_COMPACTION_CONTEXT` instalado y endurecido en `engram.ts`. Solo falta que OpenCode dispare una compactación natural. |
| **Estado** | ⚠️ PARTIAL — instalado, endurecido, observable. Sin evidencia real. |
| **Beneficio esperado** | ~7,070 tokens por sesión 30-turn (guidance). |
| **Riesgo** | El compactor de OpenCode puede ignorar el guidance; fallback Engram intacto. |
| **Archivos afectados** | `~/.config/opencode/plugins/engram.ts` |
| **Pruebas requeridas** | Checklist en `F4B-natural-compaction-checklist.md` |
| **Decisión necesaria** | Ninguna — solo observar y validar. |

---

## B. Listo para usar (no requiere aprobación)

Ítems que están runtime-validados y pueden considerarse activos.

### B1. F4C Manager Guidance

| Campo | Detalle |
|---|---|
| **Descripción** | `MEMORY_SELECTOR_INSTRUCTIONS` activo en contexto del Manager vía `experimental.chat.system.transform`. |
| **Estado** | ✅ RUNTIME PASS — validado post-restart por evidencia directa en contexto del Manager. |
| **Beneficio esperado** | ~500–2,000 tokens/turno potencial si el Manager rankea memorias correctamente. |
| **Riesgo** | Es guidance, no enforcement DB-level. Manager puede ignorarlo. |
| **Archivos afectados** | `~/.config/opencode/plugins/engram.ts` |
| **Pruebas requeridas** | Las existentes en harness (F4C-T1, F4C-T2). |
| **Decisión necesaria** | Ninguna — ya está activo post-restart. |
| **Próximo paso** | Evaluar si se necesita enforcement en Engram core después de recolectar data de uso real. |

---

## C. Requiere aprobación explícita

Ítems que no deben implementarse ni activarse sin aprobación del usuario.

### C1. F4A Skills Selective Loading

| Campo | Detalle |
|---|---|
| **Descripción** | Reducir descripciones de skills en el bloque `<available_skills>` del system prompt. Ahorro estimado ~400–1,184 tokens. |
| **Estado** | ⏸️ DECISION ONLY — no runtime, no config change. |
| **Beneficio esperado** | ~400–1,184 tokens/sesión. |
| **Riesgo** | Las descripciones actuales son informativas; el Manager invoca skills por nombre. Riesgo de falsos negativos en matching si se reduce demasiado. |
| **Archivos afectados** | System prompt de OpenCode (requiere modificar cómo se genera). Probablemente `opencode.json` o configuración de skills. |
| **Pruebas requeridas** | Validar que no hay falsos negativos en skill matching tras reducción. |
| **Decisión necesaria** | ✅ **Aprobación del usuario** — requiere tocar configuración de skills. |
| **Documento de referencia** | `F4A-skills-selective-loading-decision.md` |

---

### C2. QW#2 Tool Schema Loading

| Campo | Detalle |
|---|---|
| **Descripción** | Cargar tool schemas selectivamente según la fase SDD, no todos siempre. Ahorro estimado ~2,000–4,000 tokens. |
| **Estado** | 🧪 PROTOTYPE ONLY — plan/prototipo aislado, sin runtime activo. |
| **Beneficio esperado** | ~2,000–4,000 tokens potencial. |
| **Riesgo** | Puede reducir tool-call accuracy si el Manager no tiene schema de la tool necesaria. |
| **Archivos afectados** | Plugin runtime o lógica del Manager. |
| **Pruebas requeridas** | Medir tool-call accuracy con/sin carga selectiva antes de rollout. |
| **Decisión necesaria** | ✅ **Aprobación del usuario** antes de pasar de prototype a runtime. |
| **Documento de referencia** | `F4D-tool-schema-loading-prototype-plan.md` |

---

### C3. QW#3 Manager Protocol Compaction

| Campo | Detalle |
|---|---|
| **Descripción** | Compactar 4 secciones del Manager Protocol (Context Layer Definitions, Anti-Patterns, Fast-Track, Default Behavior). Ahorro estimado ~1,200–2,300 tokens. |
| **Estado** | ⏸️ PROPOSAL ONLY — no se tocó `opencode.json`. |
| **Beneficio esperado** | ~1,200–2,300 tokens. |
| **Riesgo** | Alto: modificar `opencode.json` puede tener consecuencias imprevistas en el comportamiento del Manager. |
| **Archivos afectados** | `opencode.json` |
| **Pruebas requeridas** | E6B + Suite F como gates; diff antes/después revisado; prueba de Manager behavior invariante. |
| **Decisión necesaria** | ✅ **Aprobación explícita del usuario**. ROI más bajo de todos los candidatos. |
| **Documento de referencia** | `F4E-manager-protocol-compaction-decision.md` |

---

### C4. Edición de `opencode.json` (cualquier propósito)

| Campo | Detalle |
|---|---|
| **Descripción** | Cualquier modificación funcional de `opencode.json`, independientemente del propósito. |
| **Estado** | ⛔ NO SIN APROBACIÓN — regla aplicada a toda la Fase F. |
| **Beneficio esperado** | Depende del propósito. |
| **Riesgo** | Alto: archivo de configuración crítico del runtime. |
| **Pruebas requeridas** | Depende del cambio; mínimo E6B + Suite F. |
| **Decisión necesaria** | ✅ **Aprobación explícita del usuario**, con propósito y diff claro. |

---

## D. Futuro / Exploración

Ítems que no están planificados para implementación inmediata pero pueden evaluarse después de cerrar Fase F.

### D1. Selector hard enforcement en retrieval layer

| Campo | Detalle |
|---|---|
| **Descripción** | Mover el guidance del F4C Selector desde instrucciones al Manager hacia enforcement en el propio retrieval de Engram (core Go). |
| **Estado** | 🔮 Idea — no hay plan ni prototipo. |
| **Beneficio esperado** | Garantizar que el ranking/dedup siempre se aplica, sin depender de disciplina del Manager. |
| **Riesgo** | Mayor complejidad; requiere modificar Engram Go. |
| **Archivos afectados** | Engram core (Go). |
| **Pruebas requeridas** | Las 23 pruebas funcionales del selector original. |
| **Decisión necesaria** | No ahora. Evaluar después de recolectar data de uso real del guidance. |

---

### D2. Integración o evaluación con gentle-ai

| Campo | Detalle |
|---|---|
| **Descripción** | Evaluar si gentle-ai (SDD pipeline) puede beneficiarse de los patrones de Fase F (RECENT_SESSION_PACK, mem_context Selector). Sin crear dependencia runtime. |
| **Estado** | 🔮 Estratégico — sin plan activo. |
| **Beneficio esperado** | Transferencia de patrones, alineación estratégica. |
| **Riesgo** | Bajo si se mantiene como evaluación/documento, no como integración. |
| **Archivos afectados** | Documentos de alineación existentes. |
| **Pruebas requeridas** | Ninguna en esta etapa. |
| **Decisión necesaria** | No ahora. Mantener patrón estratégico solamente. |
| **Documento de referencia** | `gentle-ai-alignment.md` |

---

### D3. Fase G — Hybrid Retrieval

| Campo | Detalle |
|---|---|
| **Descripción** | Combinar recuperación de memoria (Engram) con contexto fijo (packs) y contexto bajo demanda (skills, tool schemas). Siguiente fase después de F. |
| **Estado** | 🔮 En roadmap — no hay diseño ni plan. |
| **Beneficio esperado** | Arquitectura completa de contexto inteligente. |
| **Riesgo** | Bajo en esta etapa; es diseño conceptual. |
| **Archivos afectados** | Por definir. |
| **Pruebas requeridas** | Por definir. |
| **Decisión necesaria** | No ahora. Evaluar después de cerrar Fase F y validar F4B real. |
| **Roadmap** | `implementation-roadmap.md` — Fase G como 🔮 |

---

## Resumen

| Categoría | Total | Estado |
|---|---|---|
| A. Listo para observar | 1 (F4B) | ⚠️ PARTIAL |
| B. Listo para usar | 1 (F4C) | ✅ RUNTIME PASS |
| C. Requiere aprobación | 4 (F4A, QW#2, QW#3, opencode.json) | ⏸️ |
| D. Futuro | 3 (selector hard, gentle-ai, Fase G) | 🔮 |
