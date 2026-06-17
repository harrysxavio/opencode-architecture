# F4C: Selector Scoring Specification

**Propósito:** Definir el algoritmo exacto de scoring para el mem_context selector.

---

## Fórmula general

```
score = (relevance × 0.5) + (recency × 0.3) + (type × 0.2) + boost - penalty
```

---

## 1. Relevance score (peso 0.5)

Mide cuánto coincide la observación con la query de contexto.

```
relevance = matchedKeywords / totalQueryKeywords

matchedKeywords = count of query keywords found in:
  - observation.title (case-insensitive)
  - observation.content (case-insensitive)
  - observation.keywords array (case-insensitive)

totalQueryKeywords = count of keywords in the query
```

**Límite:** relevance ∈ [0.0, 1.0]

---

## 2. Recency score (peso 0.3)

Mide qué tan reciente es la observación.

```
daysSince = currentDate - observation.date (in days)
recency = max(0, 1.0 - (daysSince × 0.05))
```

**Decay rate:** 0.05/día (visibilidad completa: 0 días, visibilidad media: 10 días, invisible: 20 días)

**Decay floor para decisiones:** Si type = "decision" y recency < 0.1, recency = 0.1 (mínimo 0.1).

---

## 3. Type score (peso 0.2)

Prioriza tipos de observación por importancia.

| Type | Weight | Justificación |
|:-----|:------:|:--------------|
| decision | 1.0 | Decisiones son lo más importante de recordar |
| constraint | 0.9 | Restricciones del usuario son casi tan importantes |
| architecture | 0.7 | Decisiones arquitectónicas |
| bugfix | 0.6 | Bugs resueltos (útiles si reaparecen) |
| discovery | 0.5 | Descubrimientos no decisionales |
| config | 0.4 | Cambios de configuración |
| preference | 0.4 | Preferencias del usuario |
| (default) | 0.3 | Otros tipos |

---

## 4. Boost

Se aplican boosts adicionales en estos casos:

| Condición | Boost | Razón |
|:----------|:-----:|:------|
| Active phase matches | +0.15 | La fase activa actual es relevante |
| Observation is a risk | +0.10 | Riesgos deben estar visibles |
| Same topic as query | +0.10 | Misma temática |
| Topic is "architecture" | +0.05 | Arquitectura siempre relevante |

---

## 5. Penalty

Se aplican penalidades en estos casos:

| Condición | Penalty | Razón |
|:----------|:-------:|:------|
| Legacy session | -0.30 | No mezclar sesiones |
| Different project | -0.50 | No mezclar proyectos |
| Duplicate topic | -0.20 | Penalizar duplicados (se resuelve en dedup) |
| Contains secret pattern | **Excluir** | Nunca incluir secretos |

---

## 6. Dedup

Si dos observaciones tienen el mismo `topic_key` o keywords muy similares (>80% overlap), solo se incluye la de mayor score.

---

## 7. Top-K por modo

| Modo | K | Comportamiento |
|:-----|:-:|:---------------|
| Simple | 5 | Solo las más relevantes |
| Normal | 10 | Balance entre relevancia y cobertura |
| Architecture | 20 | Cobertura amplia |
| Audit | 30 | Casi todo, solo excluye legacy+secret |
| Exceptional | ∞ | Sin filtro (comportamiento actual) |

---

## 8. Fallback (L5)

Si después de aplicar todos los filtros el top-K está vacío:
1. Reducir legacy penalty a -0.10 (en lugar de -0.30)
2. Si sigue vacío: eliminar filtro de project match
3. Si sigue vacío: búsqueda sin filtro (comportamiento actual)

El fallback se registra en el explain output.

---

## 9. Explain output

Cada observación en el resultado incluye:

```
{
  "id": 123,
  "title": "9.5k no es límite rígido",
  "score": 0.85,
  "breakdown": {
    "relevance": 0.5,
    "recency": 0.3,
    "type": 0.2,
    "boost": 0.0,
    "penalty": -0.15
  },
  "reason": "Match alto con query 'budget limit' + decisión reciente"
}
```

---

## 10. Verificación del scoring

| Test | Input | Output esperado |
|:-----|:------|:----------------|
| Match exacto | query=["budget","limit"], obs="budget,limit" en keywords | relevance = 1.0 |
| Match parcial | query=["budget","limit","auth"], obs="budget" en keywords | relevance = 0.333 |
| Sin match | query=["auth"], obs sin keywords matching | relevance = 0.0 |
| Decisión de hoy | date=today, type=decision | score = 0 + 0.3 + 0.2 = 0.5 |
| Decisión de hace 5 días | date=-5d, type=decision | recency = 0.75, score = 0 + 0.225 + 0.2 = 0.425 |
| Decisión de hace 15 días | date=-15d, type=decision | recency = 0.25 (floor), score = 0 + 0.075 + 0.2 = 0.275 |
| Discovery de hace 20 días | date=-20d, type=discovery | recency = 0.0, score = 0 + 0 + 0.1 = 0.1 |
| Con boost (active phase) | misma fase activa | score + 0.15 |
| Con penalty (legacy) | legacy session | score - 0.30 |

---

*Fin de F4C-selector-scoring-spec.md*
