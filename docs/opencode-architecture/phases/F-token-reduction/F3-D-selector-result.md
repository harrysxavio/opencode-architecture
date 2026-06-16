# F3-D: QW#4 Memorias Rankeadas — Resultado del prototipo

**Estado:** ✅ COMPLETED (2026-06-16)  
**Propósito:** Prototipar y calibrar el scoring del mem_context selector (relevance 0.5 + recency 0.3 + type 0.2) con datos realistas.

---

## Resumen

| Métrica | Valor |
|---------|:-----:|
| Observaciones en simulación | 25 (16 Fase F + 6 F1/F2 + 3 legacy) |
| Scoring evaluado | relevance 0.5 + recency 0.3 + type 0.2 |
| Configuraciones probadas | 5 variantes de pesos |
| Queries de prueba | 2 (budget/limit, auth/security) |
| Modos probados | Simple (K=5), Normal (K=10), Architecture (K=20), Audit (K=30) |
| **Veredicto** | **✅ APROBADO — mantener pesos, ajustar decay** |

---

## Hallazgos clave

### 1. El scoring actual (0.5/0.3/0.2) funciona correctamente

Para queries donde hay match de keywords, la observación relevante rankea #1 con score significativamente mayor (1.0 vs 0.4 para la segunda).

**Ejemplo: query "budget, limit"**
| Rank | Observación | Score | Tipo |
|:----:|-------------|:-----:|:----:|
| 1 | 9.5k no es límite rígido | 1.000 | decision |
| 2 | Budget definitions F2 | 0.690 | architecture |
| 3-5 | Otras (sin match) | 0.500 | decision |

**Ejemplo: query "auth, security"**
| Rank | Observación | Score | Tipo |
|:----:|-------------|:-----:|:----:|
| 1 | Older decision: auth model | 0.700 | decision |
| 2 | 9.5k no es límite rígido | 0.500 | decision |
| 3-5 | Otras (sin match) | 0.400-0.120 | mixed |

### 2. El decay de recencia (0.1/día) es demasiado agresivo

| Días desde la decisión | Recency score | Visible en top-k |
|:----------------------:|:-------------:|:----------------:|
| 0 (hoy) | 1.0 | ✅ Siempre |
| 1 | 0.9 | ✅ |
| 3 | 0.7 | ✅ |
| 5 | 0.5 | ⚠️ Borde |
| 7 | 0.3 | ⚠️ Bajo |
| 10 | 0.0 | ❌ Invisible |

**Problema:** Una decisión arquitectónica de hace 8 días (como "auth model" o "API structure") obtiene recency=0.2, lo que la deja con score total de solo ~0.45 incluso siendo relevante. Si el query no tiene match de keywords, cae a score 0.2 y queda fuera del top-10.

### 3. El peso de tipo (0.2) es adecuado pero no rescata decisiones viejas

| Tipo | Peso | Efecto en score |
|:----|:----:|:----------------|
| decision | 1.0 | +0.20 al score total |
| constraint | 0.9 | +0.18 |
| architecture | 0.7 | +0.14 |
| bugfix | 0.6 | +0.12 |
| discovery | 0.5 | +0.10 |

Sin match de keywords y sin recency, una decisión obtiene score 0.20 — insuficiente para entrar en top-10 típico.

### 4. El peso de relevancia (0.5) es el discriminador principal

Es correcto. La relevancia debe ser el factor dominante. Una observación que coincide con 2 de 3 keywords obtiene relevance=0.667, que multiplicado por 0.5 da 0.333 — suficiente para rankear por encima de observaciones sin match.

---

## Calibración recomendada

### Mantener pesos, cambiar decay

```diff
- recency = max(0, 1.0 - (daysSince * 0.1))
+ recency = max(0, 1.0 - (daysSince * 0.05))
```

**Efecto del cambio:**

| Días | Decay 0.1 (actual) | Decay 0.05 (propuesto) |
|:----:|:------------------:|:----------------------:|
| 0 | 1.0 | 1.0 |
| 5 | 0.5 | 0.75 |
| 10 | 0.0 | 0.50 |
| 15 | 0.0 | 0.25 |
| 20 | 0.0 | 0.00 |

**Beneficio:** decisiones arquitectónicas de hasta 2 semanas mantienen recencia significativa.

**Costo marginal:** ~0.05 puntos de score extra por observación vieja en cada turno. Impacto en tokens: insignificante (cambia el orden, no la cantidad de observaciones cargadas).

### No recomendado: cambiar pesos

| Variante | Resultado | Veredicto |
|:---------|:----------|:---------:|
| 0.6/0.2/0.2 (menos recencia) | Mejor para queries con match, pero decisiones viejas sin match caen a 0.12 | ❌ Muy extremo |
| 0.4/0.4/0.2 (igual rel+rec) | La decisión más reciente sin match empata con la relevante | ❌ Pierde discriminación |
| 0.5/0.2/0.3 (más tipo) | Decisiones viejas suben a 0.30 sin match | ⚠️ Aceptable |
| 0.4/0.2/0.4 (mucho tipo) | Decisiones viejas sin match (0.4) superan a discoveries con match parcial (0.35) | ❌ Invierte prioridad |

---

## Validación por modo

| Modo | K | Comportamiento observado | ¿Funciona? |
|:-----|:-:|:------------------------|:----------:|
| Simple | 5 | Retorna solo las más relevantes. Score mínimo ~0.50 | ✅ |
| Normal | 10 | Incluye decisiones genéricas (score ~0.50). Buen equilibrio | ✅ |
| Architecture | 20 | Cubre architecture + discoveries. Score mínimo ~0.44 | ✅ |
| Audit | 30 | Incluye hasta legacy con score 0.12. Cobertura completa | ⚠️ Bordes |

**Observación:** En modo Normal, el top-10 incluye ~7 decisiones de score 0.50 (por type weight + recency plena) que no tienen match de keywords. Esto es aceptable — son decisiones recientes que el Manager probablemente necesita.

---

## Veredicto

QW#4 es **APROBADO para implementación** con 1 ajuste:

1. **✅ Scoring 0.5/0.3/0.2 se mantiene** — funciona correctamente.
2. **✅ Recency decay cambia de 0.1/día a 0.05/día** — extiende ventana de visibilidad de 10 a 20 días.
3. **✅ Top-K por modo funciona** — Simple (5), Normal (10), Architecture (20), Audit (30).

**Sin blockers.** El ajuste de decay es trivial. No requiere cambios en runtime. El prototipo validó el diseño de F2 con datos realistas.

---

*Fin de F3-D-selector-result.md — Prototipo de QW#4 completado.*
