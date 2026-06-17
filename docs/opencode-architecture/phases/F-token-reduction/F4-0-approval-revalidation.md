# F4-0: Approval Package Revalidation

**Estado:** ✅ COMPLETED (2026-06-16)  
**Propósito:** Revalidar el orden de implementación aprobado (Skills → Session → Selector) antes de ejecutar F4.

---

## 1. Resumen de la decisión original

El F3 Approval Package recomendó este orden:

```
F4.1: QW#5 Skills Block Compaction  →  F4.2: QW#1 Session History Compaction  →  F4.3: QW#4 mem_context Selector
```

El usuario aprobó este orden para F4/F5/F6. Esta tarea F4-0 revalida si esa decisión sigue siendo óptima.

---

## 2. Evaluación de alternativas

### 2.1 Opción A: Skills → Session → Selector (recomendado actual)

| Criterio | Evaluación |
|:---------|:-----------|
| **Ahorro** | Skills ~1,184t → Session ~7,070t → Selector ~500-2,000t. Total: ~8,500-10,200t |
| **Riesgo** | 🟢 (Skills) → 🟡 (Session) → 🟡 (Selector). Escalada gradual. |
| **Reversibilidad** | Skills: ✅ Trivial (revertir descripciones). Session: ⚠️ Requiere desactivar compactación. Selector: ✅ Desactivar scoring. |
| **Impacto calidad** | Skills: 🟢 Ninguno. Session: 🟡 Potencial pérdida de matices. Selector: 🟡 Potencial filtrado excesivo. |
| **Testing** | Skills: ✅ Harness existente. Session: ⚠️ Requiere fixture sintético. Selector: ⚠️ Requiere fixtures de memoria. |
| **Dependencia runtime** | Skills: ❌ Ninguna. Session: ⚠️ Media (persistencia de historial). Selector: ⚠️ Media (integración con mem_context). |
| **gentle-ai reusable** | Skills: ⚠️ Parcial (diferente formato de skills). Session: ✅ Sí (patrón de compactación universal). Selector: ✅ Sí (scoring universal). |

### 2.2 Opción B: Session → Selector → Skills

| Criterio | Evaluación |
|:---------|:-----------|
| **Ahorro** | Session primero da ~7,070t más rápido. Pero si falla, no se recupera. |
| **Riesgo** | 🟡 (Session primero sin experiencia) → 🟡 → 🟢. Riesgo concentrado al inicio. |
| **Reversibilidad** | Session es la menos reversible. Hacerla primero es más riesgoso. |
| **Veredicto** | ❌ — Menos seguro. No recomendado. |

### 2.3 Opción C: Selector → Session → Skills

| Criterio | Evaluación |
|:---------|:-----------|
| **Ahorro** | Selector tiene el ahorro más incierto (500-2,000t). Hacerlo primero retrasa ganancias seguras. |
| **Riesgo** | 🟡 (Selector) → 🟡 → 🟢. Selector requiere diseño más fino. |
| **Reversibilidad** | Selector tiene scoring configurable, es más fácil de revertir que Session. |
| **Veredicto** | ❌ — Selector tiene ahorro incierto. Mejor ganar confianza con Skills primero. |

### 2.4 Opción D: Skills + Session en paralelo, luego Selector

| Criterio | Evaluación |
|:---------|:-----------|
| **Ahorro** | Skills y Session son independientes. Se pueden ejecutar en paralelo. |
| **Riesgo** | 🟢 + 🟡 en paralelo. Riesgo de que Session falle y contamine Skills. |
| **Complejidad** | Media — requiere coordinar dos cambios simultáneos. |
| **Veredicto** | ⚠️ Posible pero innecesario. Skills es tan rápido (~15 min) que no gana nada el paralelismo. |

### 2.5 Opción E: Solo documentación y tests (ninguna implementación)

| Criterio | Evaluación |
|:---------|:-----------|
| **Ahorro** | 0 tokens. No se reduce nada. |
| **Riesgo** | 🟢 Ninguno. Pero no avanza el objetivo. |
| **Veredicto** | ❌ — El usuario aprobó implementación segura. No implementar sería desperdiciar el bloque autónomo. |

---

## 3. Challenge multiperspectiva al orden

| Perspectiva | Pregunta | Respuesta |
|:------------|:---------|:----------|
| **Usuario** | ¿Este orden me da valor rápido? | ✅ Skills es implementación inmediata (~15 min, ~1,184 tokens). |
| **Técnico** | ¿El orden minimiza riesgo de regresión? | ✅ Sí, escala de 🟢 a 🟡 gradualmente. |
| **Seguridad** | ¿Skills puede introducir vulnerabilidad? | ❌ No — solo cambia texto de descripciones. |
| **Senior** | ¿Es mejor arquitectura hacer Selector primero? | ❌ No — Selector requiere diseño más fino. Skills es quick win puro. |
| **QA** | ¿Se puede testear cada paso? | ✅ Skills: sí. Session: requiere fixture. Selector: requiere fixtures Engram. |
| **Gerente** | ¿El orden maximiza ROI temprano? | ✅ Skills da ~1,184 tokens sin riesgo. Session da ~7,070 tokens después. |
| **gentle-ai** | ¿El orden produce patrones reutilizables? | ✅ Session y Selector producen patrones universales. Skills es más específico. |

---

## 4. Decisión: el orden se mantiene

```
┌─────────────────────────────────────────────────────────────┐
│  ✅ Skills → Session → Selector                             │
│                                                             │
│  Skills primero porque:                                     │
│    1. Riesgo más bajo (🟢)                                   │
│    2. Implementación inmediata (~15 min)                    │
│    3. Ahorro real medido (~1,184 tokens)                   │
│    4. Sin dependencias de runtime                           │
│    5. Crea confianza para los siguientes pasos              │
│                                                             │
│  Session después porque:                                    │
│    1. Mayor ahorro (~7,070 tokens)                         │
│    2. Ya tenemos prototipo validado en F3                   │
│    3. Riesgo medio (🟡), manejable con R7                   │
│                                                             │
│  Selector al final porque:                                  │
│    1. Ahorro más incierto (500-2,000t)                     │
│    2. Requiere diseño más fino                              │
│    3. Depende de aprendizaje de Skills + Session            │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Ajuste post-challenge

**Hallazgo del challenge:** Se identificó que el orden original no consideraba que Skills **no requiere implementación en runtime** — es un cambio puramente textual en el system prompt. Esto significa que se puede implementar **sin necesidad de feature flag, sin pruebas de regresión extensivas, y sin rollback complejo.**

**Mejora aplicada:** Se añade una **Fase F4A Quick Track**: Skills se implementa inmediatamente sin esperar a F5. Session y Selector pasan por el proceso completo de validación antes de implementarse.

**Decisión documentada:** D-F-031 en decision-log.

---

## 6. Documentos afectados

| Documento | Acción |
|-----------|:------:|
| `F4-0-approval-revalidation.md` | ✅ Creado — este documento |
| `decision-log.md` | Agregar D-F-031 |
| `implementation-roadmap.md` | Confirmar orden |
| `F3-F-approval-package.md` | Referencia cruzada |

---

*Fin de F4-0-approval-revalidation.md — Orden confirmado: Skills → Session → Selector.*
