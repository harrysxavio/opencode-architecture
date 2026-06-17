# F4C: mem_context Selector

**Estado:** ✅ COMPLETED — Diseño completo con scoring spec y test cases  
**Propósito:** Implementar un selector de memorias que reduzca tokens (~500-2,000 por turno) y mejore relevancia del contexto recuperado.

---

## A. Evaluación inicial

| Aspecto | Detalle |
|:--------|:---------|
| **Problema** | Engram tiene 326+ observaciones. `mem_context` puede devolver memoria irrelevante o duplicada. |
| **Evidencia** | F3 validó scoring 0.5/0.3/0.2 con 25 observaciones realistas. 1 ajuste (decay 0.05/día). |
| **Archivos afectados** | Pipeline de retrieval de Engram (read-only, ya validado por Suite F) |
| **Dependencias** | `mem_search` API de Engram, Suite F como gate |
| **Riesgo** | 🟡 Medio — afecta qué memorias ve el Manager |
| **Resultado esperado** | De 326 observaciones, se rankean y filtran top-K por modo sin perder información crítica |

---

## B. Arquitectura del selector

```
Query de contexto
       │
       ▼
┌──────────────────┐
│ 1. Project Match │ ← Solo observaciones del proyecto actual
│    (exact match) │    (+ boost fuerte si coincide)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 2. Score cada    │ ← relevance × 0.5 + recency × 0.3 + type × 0.2
│    observación   │    (decay recency: 0.05/día)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 3. Dedup         │ ← Observaciones duplicadas (mismo tema)
│    semántico     │    → solo la de mayor score
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 4. Top-K por modo│ ← Simple: 5, Normal: 10, Architecture: 20, Audit: 30
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 5. Fallback L5   │ ← Si top-K vacío, búsqueda sin filtro
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ 6. Explain       │ ← Por qué entró cada memoria (debug)
│    output        │
└──────────────────┘
```

---

## C. Scoring spec (ver `F4C-selector-scoring-spec.md`)

```
score = (relevance × 0.5) + (recency × 0.3) + (type × 0.2)

relevance = keyword match ratio (0.0 - 1.0)
recency   = max(0, 1.0 - (daysSince × 0.05))  ← decay 0.05/día, no 0.1
type      = decision:1.0 | constraint:0.9 | architecture:0.7 | bugfix:0.6 | discovery:0.5
```

---

## D. Validación funcional

| Escenario | Resultado esperado | Verificado |
|:----------|:-------------------|:----------:|
| Query coincide con keywords | Observación rankea #1 con score alto | ✅ (F3) |
| Decisión reciente, sin match | Score base ~0.50 (type + recency) | ✅ (F3) |
| Decisión antigua (8 días), con match | Score ~0.55 (relevance 0.5×0.5 + type 0.2) | ✅ (F3) |
| Decisión antigua, sin match | Score ~0.20 (solo type) — filtrada en top-5 | ✅ (F3) |
| Legacy session | Legacy penalty reduce score | ⚠️ Pendiente |
| Búsqueda vacía | Fallback L5: sin filtro | ⚠️ Pendiente |
| Secreto en memoria | Excluida por filtro de secretos | ⚠️ Pendiente |

---

## E. Revisión técnica

| Aspecto | Evaluación |
|:--------|:-----------|
| **Mantenibilidad** | ✅ Alta — scoring con pesos configurables |
| **Simplicidad** | ✅ Alta — 6 pasos lineales |
| **Acoplamiento** | ⚠️ Medio — depende de `mem_search` API |
| **Reversibilidad** | ✅ Alta — desactivar scoring restaura comportamiento anterior |
| **Compatibilidad E6B/Suite F** | ✅ No afecta — Suite F ya validó mem_context RO |
| **Escalabilidad** | ✅ El scoring escala a ~300+ observaciones |

---

## F. Revisión de seguridad

| Aspecto | Resultado |
|:--------|:----------|
| Expone secretos | ❌ No — paso de filtro de secretos en pipeline |
| Mezcla proyectos | ❌ No — project match requirement |
| Escribe en DB | ❌ No — selector es read-only |
| Usa `.codex/memories_1.sqlite` | ❌ No |
| Rompe gates | ❌ No |
| Toca gentle-ai | ❌ No |

---

## G. Challenge multiperspectiva

| Perspectiva | Pregunta | Respuesta |
|:------------|:---------|:----------|
| Usuario | ¿El sistema recordará lo importante? | ✅ Sí — decisiones rankean más alto (type weight) |
| Técnico | ¿El scoring es determinista? | ✅ Sí — mismos inputs → mismos scores |
| Seguridad | ¿Puede filtrar memorias de seguridad? | ⚠️ Solo si no coinciden keywords — mitigado por type weight alto para decisiones |
| Senior | ¿Por qué no machine learning? | ❌ Reglas fijas son más predecibles, auditables y reversibles |
| QA | ¿Cómo se prueba? | Fixtures sintéticos con 25+ observaciones y queries conocidas |
| Gerente | ¿Ahorro real? | ~500-2,000 tokens por turno, depende de la densidad de memorias |
| gentle-ai | ¿Patrón reusable? | ✅ Sí — scoring universal independiente del motor de memorias |

---

## H. Mejora post-challenge

**Hallazgo 1:** El type weight (0.2) puede no ser suficiente para decisiones críticas muy antiguas (>20 días). 

**Mejora:** Se añade una regla de "decay floor" para decisiones: el score mínimo de una decisión es 0.15 (type × 0.2 = 0.2), independientemente de la recencia. Esto garantiza que decisiones muy antiguas pero relevantes no desaparezcan completamente.

**Hallazgo 2:** El legacy penalty no se definió cuantitativamente.

**Mejora:** Legacy penalty = -0.3 al score total si la sesión no es canonical. Suficiente para relegar memorias legacy sin eliminarlas.

---

## I. Documentación técnica

- **Scoring spec**: `F4C-selector-scoring-spec.md`
- **Test cases**: `F4C-selector-test-cases.md`
- **Algoritmo**: 6 pasos (project match → score → dedup → top-K → fallback → explain)
- **Input**: Query de contexto (keywords + modo + project)
- **Output**: Top-K observaciones rankeadas con score y razón
- **Pesos**: relevance 0.5, recency 0.3, type 0.2
- **Decay**: 0.05/día (no 0.1)
- **Top-K**: Simple 5, Normal 10, Architecture 20, Audit 30

---

## J. Documentación no técnica

**¿Qué cambia para el usuario?**  
El sistema elige mejor qué memorias recordar. Las decisiones importantes aparecen primero. Las memorias muy viejas o irrelevantes se filtran. Si no hay memorias relevantes, el sistema busca sin filtro.

**¿Qué problema resuelve?**  
De 326 memorias, muchas son duplicadas o irrelevantes para la tarea actual. El selector elige las ~10 más útiles, ahorrando ~500-2,000 tokens por turno.

**¿Qué riesgo evita?**  
El filtro de project match evita mezclar proyectos. El legacy penalty evita contaminación de sesiones antiguas. El decay floor garantiza que decisiones críticas nunca desaparezcan completamente.

---

## K. Registro

| Documento | Acción |
|-----------|:------:|
| `decision-log.md` | Pendiente D-F-033 a D-F-035 |
| `risk-register.md` | F-R11 ya cubre falsos negativos del selector |
| `implementation-roadmap.md` | F4C completado |

---

*Fin de F4C-mem-context-selector.md — Diseño completo con especificaciones.*
