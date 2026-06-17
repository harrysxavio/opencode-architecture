# F4C: Selector Test Cases

**Propósito:** Definir casos de prueba para validar el mem_context selector.

---

## Test Suite: Scoring

### T-SCORE-1: Match exacto de keywords
```
Input:  query=["budget", "limit"], obs.title="9.5k no es límite rígido", obs.keywords=["budget","limit","range"]
Output: relevance=1.0, score≥0.85
Criterio: ✅ PASS si score > 0.8
```

### T-SCORE-2: Match parcial
```
Input:  query=["budget", "limit", "session"], obs.title="Session compaction", obs.keywords=["session"]
Output: relevance=0.333, score≈0.37
Criterio: ✅ PASS si score > 0.3 (type + recencia lo mantienen visible)
```

### T-SCORE-3: Sin match, decisión reciente
```
Input:  query=["python", "flask"], obs.title="E6B COMPLETE", obs.type="decision", obs.date=today
Output: relevance=0.0, recency=1.0, type=1.0 → score=0.5
Criterio: ✅ PASS si score ≈ 0.5
```

### T-SCORE-4: Sin match, discovery antigua
```
Input:  query=["python", "flask"], obs.title="F0 baseline", obs.type="discovery", obs.date=-15d
Output: relevance=0.0, recency=0.25, type=0.5 → score=0.175
Criterio: ✅ PASS si score < 0.2 (probablemente filtrada en top-10)
```

### T-SCORE-5: Decisión antigua con match parcial
```
Input:  query=["auth", "security"], obs.title="Older auth decision", obs.date=-8d
Output: relevance≥0.5, recency=0.6, type=1.0 → score≥0.63
Criterio: ✅ PASS si score > 0.5 (decisiones relevantes nunca se pierden)
```

### T-SCORE-6: Legacy session penalty
```
Input:  query=["budget"], obs con legacy marker
Output: score con -0.30 penalty
Criterio: ✅ PASS si el penalty reduce score en exactamente 0.30
```

---

## Test Suite: Top-K

### T-TOPK-1: Modo Simple (K=5)
```
Input:  25 observaciones, modo=Simple
Output: Solo 5 observaciones, scores > 0.4
Criterio: ✅ PASS si count = 5 y todas tienen score > 0.4
```

### T-TOPK-2: Modo Normal (K=10)
```
Input:  25 observaciones, modo=Normal
Output: 10 observaciones, rango de scores variado
Criterio: ✅ PASS si count = 10
```

### T-TOPK-3: Modo Architecture (K=20)
```
Input:  25 observaciones, modo=Architecture
Output: 20 observaciones, incluye architecture + discoveries
Criterio: ✅ PASS si count ≤ 20 y al menos 1 de tipo architecture
```

### T-TOPK-4: Modo Audit (K=30)
```
Input:  25 observaciones, modo=Audit
Output: Hasta 25 observaciones (todas las disponibles)
Criterio: ✅ PASS si count ≤ 30 pero ≥ 20
```

### T-TOPK-5: K > observaciones disponibles
```
Input:  10 observaciones, modo=Architecture (K=20)
Output: 10 observaciones (no puede devolver más de las que hay)
Criterio: ✅ PASS si count = 10 sin errores
```

---

## Test Suite: Dedup

### T-DEDUP-1: Mismo topic_key
```
Input:  2 obs con topic_key="architecture/budget", scores 0.8 y 0.6
Output: Solo la de score 0.8
Criterio: ✅ PASS si count = 1 y es la de score más alto
```

### T-DEDUP-2: Keywords 80% overlap
```
Input:  2 obs con keywords ["budget","limit","range"] y ["budget","limit","target"]
Output: Solo la de score más alto
Criterio: ✅ PASS si count = 1
```

### T-DEDUP-3: Mismo título
```
Input:  2 obs con title="E6B COMPLETE" (una de session_summary, otra de architecture)
Output: Solo la de tipo architecture (type weight más alto)
Criterio: ✅ PASS si se conserva la de tipo architecture
```

### T-DEDUP-4: Sin duplicación
```
Input:  5 obs con topics distintos
Output: Las 5 observaciones
Criterio: ✅ PASS si count = 5
```

---

## Test Suite: Fallback

### T-FALLBACK-1: Búsqueda vacía → reducir legacy penalty
```
Input:  Solo obs legacy, query sin match
Output: Se reduce legacy penalty a -0.10
Criterio: ✅ PASS si fallback step 1 se ejecuta
```

### T-FALLBACK-2: Sigue vacío → eliminar project match
```
Input:  Solo obs de otro proyecto
Output: Se elimina filtro de project match
Criterio: ✅ PASS si fallback step 2 se ejecuta
```

### T-FALLBACK-3: Sigue vacío → búsqueda sin filtro
```
Input:  No hay observaciones (DB vacía simulada)
Output: Búsqueda sin filtro (comportamiento actual)
Criterio: ✅ PASS si fallback step 3 se ejecuta y devuelve resultado
```

---

## Test Suite: Security

### T-SEC-1: Secreto en memoria
```
Input:  obs.content="token=ghp_abc123..."
Output: Excluida del resultado
Criterio: ✅ PASS si no aparece en top-K
```

### T-SEC-2: Cross-project
```
Input:  obs con project="another-project"
Output: Excluida o con penalty -0.50
Criterio: ✅ PASS si no aparece en top-10 a menos que sea fallback
```

### T-SEC-3: Secret pattern in title
```
Input:  obs.title="API key rotation", obs.keywords=["api","key"]
Output: Score normal (solo contenido, no título, tiene secreto)
Criterio: ✅ PASS si score es normal y contenido no tiene patrones de secreto
```

---

## Test Suite: Explain

### T-EXPLAIN-1: Formato del explain output
```
Input:  Cualquier query
Output: JSON con id, title, score, breakdown, reason
Criterio: ✅ PASS si todos los campos existen y tienen tipos correctos
```

### T-EXPLAIN-2: Breakdown suma al score
```
Input:  Observación con score 0.75
Output: breakdown.relevance + breakdown.recency + breakdown.type + boost - penalty = 0.75
Criterio: ✅ PASS si la suma del breakdown = score (tolerancia ±0.01)
```

---

## Resumen

| Suite | Tests | Cobertura |
|:------|:-----:|:----------|
| Scoring | 6 | Keyword match, recency, type, legacy penalty |
| Top-K | 5 | Todos los modos, borde K > disponible |
| Dedup | 4 | Topic, keywords, título, sin duplicación |
| Fallback | 3 | 3 niveles de fallback progresivo |
| Security | 3 | Secretos, cross-project, falsos positivos |
| Explain | 2 | Formato, consistencia matemática |
| **Total** | **23** | |

---

*Fin de F4C-selector-test-cases.md — 23 tests para el selector.*
