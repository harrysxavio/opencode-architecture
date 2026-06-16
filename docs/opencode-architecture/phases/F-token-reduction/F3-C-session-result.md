# F3-C: QW#1 Session History Compaction — Resultado del prototipo

**Estado:** ✅ COMPLETED (2026-06-16)  
**Propósito:** Prototipar y medir la compactación del session history (3+7+acumulativo + R7) en un entorno aislado.

---

## Resumen

| Métrica | Valor |
|---------|:-----:|
| Algoritmo | 3+7+acumulativo + R7 |
| Sesión simulada | 30 turns (típica sesión de arquitectura) |
| Ahorro snapshot (un turno) | ~588 tokens (65% de compresión) |
| Ahorro neto acumulado (30t) | **~7,070 tokens** ✅ |
| Ahorro neto acumulado (60t) | ~41,900 tokens ✅✅ |
| R7 activa | ✅ Decisiones preservadas textualmente |
| Estimación F2 original | 3k–5k tokens (snapshot, no acumulativo) |

---

## Hallazgos clave

### 1. El ahorro real es ACUMULATIVO, no snapshot

La auditoría de F2 estimó 3k–5k tokens como ahorro "en un momento dado." Pero el beneficio real es que **cada turno carga la versión compactada**, no la historia cruda. El ahorro se multiplica por la cantidad de turns.

| Tipo de sesión | Turns | Ahorro neto | Uso típico |
|:---------------|:-----:|:-----------:|:-----------|
| Corta | 15 | ~455 tokens | Consulta rápida, respuesta directa |
| Media | 20 | ~1,860 tokens | Feature pequeña, debugging |
| **Típica** | **30** | **~7,070 tokens** | **Sesión de arquitectura, diseño, implementación** |
| Larga | 40 | ~15,480 tokens | Refactor grande, integración |
| Muy larga | 60 | ~41,900 tokens | Investigación profunda, múltiples features |
| Extrema | 100 | ~133,140 tokens | Sesión marathon (raro) |

### 2. La escritura de resúmenes tiene costo, pero es marginal

Por cada evento de compactación (~150 tokens para escribir/actualizar resúmenes), se ahorran cientos de tokens en cada turno subsiguiente.

| Turns | Eventos de compactación | Costo total | Ahorro bruto | Neto |
|:-----:|:----------------------:|:-----------:|:------------:|:----:|
| 15 | 2 | 300 | 755 | 455 |
| 30 | 5 | 750 | 7,820 | 7,070 |
| 60 | 11 | 1,650 | 43,550 | 41,900 |

**Relación costo/beneficio:** por cada token gastado en compactar, se ahorran ~10–26 tokens en contexto a lo largo de la sesión.

### 3. R7 (decisiones preservadas) no impacta significativamente el ahorro

| Aspecto | Sin R7 | Con R7 | Diferencia |
|---------|:------:|:------:|:----------:|
| Summary (turns 4-10) | ~100 tokens | ~122 tokens | +22 tokens |
| Accumulated block | ~110 tokens | ~131 tokens | +21 tokens |
| **Costo de R7** | — | **+43 tokens** por sesión | **0.6% del ahorro** |

La regla R7 agrega un costo marginal insignificante comparado con el beneficio de preservar decisiones críticas textualmente.

### 4. El algoritmo 3+7+acumulativo funciona mejor para sesiones largas

Para sesiones de **menos de 15 turns**, la compactación no vale la pena (ahorro neto <500 tokens). Para sesiones típicas de arquitectura (20-40 turns), el ahorro es sustancial.

**Recomendación:** Activar compactación solo después del turno 10 (o cuando la sesión supere ~500 tokens de historial). Esto evita pagar el costo de inicialización en sesiones cortas.

---

## Detalle del prototipo

### Fixture de prueba

Se simuló una sesión real de 30 turns trabajando en Fase F (diseño de arquitectura, budgets, quick wins). Cada turno contiene interacciones típicas de Manager-Usuario con decisiones, constraints, solicitudes y reportes de progreso.

### Algoritmo aplicado

```
Turns 1-3:    RAW (sin cambios)
Turns 4-10:   SUMMARY (1-2 líneas cada uno con template estructurado)
              + R7: decisiones y constraints preservados textualmente
Turns 11+:    ACCUMULATED (párrafo que crece ~15 tokens cada 5 turns)
              + decisiones recientes preservadas textualmente
```

### Ejemplo de salida compactada (30-turn session)

**RAW block (turns 28-30):**
```
Turn 28 — Assistant: Session compaction simulated. 30-turn session analyzed.
Turn 29 — User: Add R7: preserve decisions textually in summaries.
Turn 30 — Assistant: R7 implemented. [decision — R7 added, preserved textually]
```

**SUMMARY block (turns 4-10):**
```
Turn 4 — Assistant: 9.5k as range not limit. D-F-001. [decision — preserved]
Turn 5 — User: F1: catalog sources. NO config changes. [constraint — preserved]
Turn 6 — Assistant: 15 sources cataloged. 7 duplications.
Turn 7 — User: Show duplications impact and quick win ROI.
Turn 8 — Assistant: 7 duplications. 5 quick wins.
Turn 9 — User: F2 budgets per mode. L0-L5 layers.
Turn 10 — Assistant: Modes designed. L0 ~4k to L5 ~500.
```

**ACCUMULATED block (turns 11-30):**
```
Turns 11-15: Expansion rules defined. 5 audits created. Risk register + regression plan.
Turns 16-20: Selector design 0.5/0.3/0.2. Roadmap F0-F6.
Turns 21-25: F2 Critical Review — 8 findings APTO. F3 strategy.
Turns 26-30: Skills ~1,184 tokens. Session compaction prototype. R7 added. [decision — R7 added]
```

---

## Veredicto

QW#1 es **APROBADO para implementación.** El ahorro neto para sesiones típicas (~7k tokens en 30 turns) justifica ampliamente la complejidad.

**Recomendaciones:**
1. Activar compactación después del turno 10 (no antes).
2. Incluir R7 (costo marginal ~43 tokens, beneficio alto en preservación de decisiones).
3. El acumulado debe actualizarse cada ~5 turns o cuando ocurra un evento significativo.
4. No compactar sesiones de <15 turns (no vale la pena).

---

*Fin de F3-C-session-result.md — Prototipo de QW#1 completado.*
