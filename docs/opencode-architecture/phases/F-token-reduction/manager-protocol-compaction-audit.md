# Manager Protocol Compaction Audit — F2

**Estado:** ✅ AUDIT COMPLETED (2026-06-16)  
**Propósito:** Auditar el Manager Protocol (28,471 chars, ~7k–14k tokens) — la fuente de contexto individual más grande — y proponer compactación para reducir a ~5k–8k tokens.

---

## Executive Summary

El Manager Protocol (contenido en `opencode.json → agent.manager.prompt`) es la fuente más grande del sistema: **28,471 chars (~7,100–14,200 tokens)**. Las secciones más compactables son Context Layer Definitions, Anti-Patterns, Fast-Track, y Default Behavior.

**Propuesta de compactación:** Reducir de ~7k–14k a ~5k–8k tokens (ahorro ~2k–6k) sin perder instrucciones críticas de orquestación.

**⚠️ ATENCIÓN:** Cualquier modificación al Manager Protocol requiere modificar `opencode.json`. Esto tiene riesgo alto y requiere aprobación explícita del usuario antes de implementar. Este documento es solo la propuesta de diseño.

---

## 1. Desglose por sección

| # | Sección | Chars | Est. tokens | ¿Compactable? | Ahorro estimado |
|:-:|---------|:-----:|:-----------:|:-------------:|:---------------:|
| 1 | Manager Global Orchestration Protocol | ~4,500 | ~1,125–2,250 | ⚠️ Parcial | ~100–200 |
| 2 | Operating Model | ~3,000 | ~750–1,500 | ❌ Core | — |
| 3 | Global Rule: Manager Owns Orchestration | ~2,500 | ~625–1,250 | ❌ Core | — |
| 4 | Context Layer Definitions | ~3,000 | ~750–1,500 | ✅ Sí | ~300–500 |
| 5 | Phase 0 — Request Classification | ~1,000 | ~250–500 | ❌ Core | — |
| 6 | Phase 1 — Brainstorming | ~2,500 | ~625–1,250 | ⚠️ Parcial | ~100–200 |
| 7 | Phase 2 — Alternatives & Design Approval | ~1,500 | ~375–750 | ⚠️ Parcial | ~100–200 |
| 8 | Phase 2.5 — Graphify Context Gate | ~3,000 | ~750–1,500 | ⚠️ Parcial | ~200–400 |
| 9 | Phase 3 — SDD (8 sub-phases) | ~5,000 | ~1,250–2,500 | ❌ Core | — |
| 10 | Phase 4 — Superpowers TDD | ~800 | ~200–400 | ❌ Core | — |
| 11 | Phase 5 — Superpowers Code Review | ~1,000 | ~250–500 | ❌ Core | — |
| 12 | Phase 6 — GPT-5.5 OAuth Final Review | ~600 | ~150–300 | ⚠️ Parcial | ~50–100 |
| 13 | Phase 7 — Debugging & RCA | ~1,200 | ~300–600 | ⚠️ Parcial | ~50–100 |
| 14 | Phase 8 — Completion Contract | ~800 | ~200–400 | ❌ Core | — |
| 15 | Anti-Patterns | ~1,600 | ~400–800 | ✅ Sí | ~200–400 |
| 16 | Fast-Track Exceptions | ~800 | ~200–400 | ✅ Sí | ~100–200 |
| 17 | Default Behavior | ~800 | ~200–400 | ✅ Sí | ~100–200 |
| | **Total** | **~28,471** | **~7,100–14,200** | | **~1,200–2,300** |

---

## 2. Propuesta de compactación por sección

### Sección 4 — Context Layer Definitions (~3,000 chars)

**Problema:** Define 4 sistemas (Superpowers, Graphify, Engram, GPT-5.5) con descripciones extensas que ya están documentadas en otros lugares.

**Propuesta:**
```
Engram: Persistencia de decisiones, bugs, session artifacts (ver AGENTS.md)
Graphify: Grafo de proyecto para impacto/relaciones (ver docs si es necesario)
Superpowers: Metodología de intake, diseño, TDD, revisión (ver skill si es necesario)
GPT-5.5: Quality gate final (ver Phase 6)
```
**Ahorro:** ~300–500 tokens. Reemplazar descripciones inline con referencias.

### Sección 15 — Anti-Patterns (~1,600 chars)

**Problema:** Lista larga de comportamientos prohibidos, algunos redundantes con las reglas de Operating Model.

**Propuesta:**
```
Prohibido: implementar sin diseño, delegar orquestación, expandir scope sin aprobar,
escribir código antes de aprobación, ignorar seguridad, cambios destructivos sin permiso,
tratar Graphify como oracle, instalar/configurar sin aprobación.
```
Compactar de ~400 a ~250 tokens. Eliminar ejemplos redundantes.

**Ahorro:** ~200–400 tokens.

### Sección 16 — Fast-Track Exceptions (~800 chars)

**Problema:** Reglas para atajo rápido que podrían ser más concisas.

**Propuesta:**
```
Fast-track permitido solo si: tarea tiny, usuario pide velocidad explícitamente,
cambio docs-only sin modificar código. Incluso en fast-track: state assumptions,
avoid unsafe actions, verify when possible, report limitations.
```
**Ahorro:** ~100–200 tokens.

### Sección 17 — Default Behavior (~800 chars)

**Problema:** Repite defaults que ya están implícitos en las fases.

**Propuesta:**
```
Default: intake interactivo, design approval requerido, SDD controlado por Manager,
TDD si tests factibles, review requerido, GPT-5.5 gate requerido, debugging si falla,
completion solo con evidencia.
```
**Ahorro:** ~100–200 tokens.

---

## 3. Tabla consolidada de cambios

| Sección | Acción | Chars actuales | Chars estimados post | Ahorro tokens |
|:--------|:------:|:---------------:|:--------------------:|:-------------:|
| Context Layer Definitions | Referenciar en lugar de definir inline | ~3,000 | ~1,500 | ~300–500 |
| Anti-Patterns | Compactar lista, eliminar redundancias | ~1,600 | ~800 | ~200–400 |
| Fast-Track Exceptions | Acortar ejemplos | ~800 | ~400 | ~100–200 |
| Default Behavior | Acortar lista | ~800 | ~400 | ~100–200 |
| Otros ajustes menores | Varios | ~1,500 | ~1,000 | ~100–300 |
| **Total** | | **~28,471** | **~19,000–22,000** | **~1,200–2,300** |

### Resultado post-compactación

| Métrica | Actual | Post-compactación |
|---------|:------:|:-----------------:|
| Chars | 28,471 | ~19,000–22,000 |
| Est. tokens (ratio 4:1) | ~7,100 | ~4,750–5,500 |
| Est. tokens (ratio 2:1) | ~14,200 | ~9,500–11,000 |
| **Est. tokens promedio** | **~7,100–14,200** | **~5,000–8,000** |

---

## 4. Secciones que NO se deben tocar

| Sección | Razón |
|:--------|-------|
| Global Rule: Manager Owns Orchestration | Es la regla fundamental del sistema |
| Operating Model | Define el workflow completo |
| Phase 0 — Request Classification | Lógica de clasificación de tareas |
| Phase 3 — SDD (8 sub-phases) | Instrucciones detalladas de cada fase SDD |
| Phase 4 — Superpowers TDD | Metodología de testing |
| Phase 5 — Superpowers Code Review | Metodología de revisión |
| Phase 8 — Completion Contract | Reglas de cierre de sesión |

---

## 5. Reglas de compactación segura

1. **No eliminar secciones completas** → solo acortar, no eliminar.
2. **No cambiar reglas de comportamiento** → solo redacción.
3. **No eliminar ejemplos** → solo acortarlos.
4. **Mantener referencias cruzadas** → si se acorta una sección, asegurar que la referencia sigue siendo válida.
5. **Mantener formato** → no cambiar XML tags, no romper estructura.
6. **Diff antes/después** → siempre verificar que no se perdió contenido crítico.
7. **Test post-cambio** → E6B + Suite F deben seguir PASS.

---

## 6. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Manager pierde regla importante al compactar | Baja | 🔴 Alto | Revisión manual diff antes/después. Test E6B + Suite F obligatorio |
| Manager no interpreta correctamente la referencia | Baja | 🟡 Medio | Mantener inline lo crítico, referenciar solo lo documentado |
| Compactación rompe formato XML de opencode.json | Baja | 🔴 Alto | Validar JSON después del cambio |
| Usuario no aprueba cambios en opencode.json | Media | 🟡 Medio | Esta propuesta solo es diseño; la implementación requiere aprobación |

---

## 7. Pruebas recomendadas

| Test | Qué validaría |
|:----:|---------------|
| P1 | Manager behavior no cambia después de compactación |
| P2 | Reglas de persona se siguen aplicando |
| P3 | Engram protocol sigue siendo accesible (referencia válida) |
| P4 | Graphify Gate sigue presente (referencia válida) |
| P5 | SDD sub-phases siguen completas |
| P6 | Reducción de tokens verificable con tiktoken |
| P7 | JSON de opencode.json sigue siendo válido |
| P8 | E6B T1-T7 siguen PASS |
| P9 | Suite F F1-F6 siguen PASS |

---

## 8. Referencias

- F0: Baseline tokens → Manager Protocol (~7k–14k)
- F1: Context Inventory → Manager Protocol (#1, KEEP_FIXED compactable)
- F1: Duplication Map → D2 (Engram protocol, ~50–150 tokens)
- F1: Quick Wins Analysis → QW#3 (Dedup Manager/AGENTS.md)
- F2: Context Budget Contract → L0 + L1 budgets

---

*Fin de manager-protocol-compaction-audit.md — F2 COMPLETED. Propuesta de compactación de Manager Protocol. Pendiente aprobación del usuario antes de implementar cambios en opencode.json.*
