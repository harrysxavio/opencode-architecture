# F3 Execution Strategy — Readiness & Quick Wins

**Estado:** ✅ DEFINIDO (2026-06-16)  
**Propósito:** Estrategia detallada de implementación para F3, primera ola de ejecución de Fase F: safe quick wins, prototipos aislados, regression harness, approval package.

---

## Contexto

F2 completó el diseño de 14 documentos + 5 quick wins. La F2 Critical Review produjo 8 hallazgos (H1-H8) y un veredicto: APTO con observaciones.

F3 es la primera fase de **implementación real**. Pero no es implementación a ciegas — es prototipado aislado, medición, verificación. La máxima de F3:

> **No tocar runtime sin approval package.**
> **No modificar opencode.json sin aprobación explícita.**
> **Todo quick win se prototipa y mide antes de activar.**

---

## Estructura de F3

F3 se divide en 7 tareas (F3-A a F3-G), ejecutadas en 3 bloques:

```
BLOQUE 1: Foundation (F3-A, F3-G)
  │
  ▼
BLOQUE 2: Implementation & Prototypes (F3-B, F3-C, F3-D, F3-E)
  │
  ▼
BLOQUE 3: Gate & Package (F3-F)
```

---

## BLOQUE 1 — Foundation

### F3-A: Runtime API Verification

**Propósito:** Verificar si OpenCode runtime expone API para tool schema loading selectivo.

**Por qué es primero:** Sin esta verificación, QW#2 (Tool Schema Demand-Loading) no puede avanzar. Es la condición de entrada para F3.

**Método de verificación:**
1. Ejecutar `opencode tool:load --help` o equivalente.
2. Buscar en documentación de OpenCode si existe API de tool schemas selectivos.
3. Si existe: documentar API, probar con un tool, medir.
4. Si no existe: QW#2 queda descartado. El ahorro de 2k–4k se recupera de otros quick wins.

**Resultados posibles:**

| Resultado | Impacto en F3 |
|-----------|:-------------:|
| API existe y funciona | QW#2 pasa a F3-D prioritario |
| API existe pero es limitada | QW#2 pasa a Opción C (Manager decide) |
| API no existe | QW#2 descartado. Documentar en decision-log |

**Criterio de salida:** ✅ Verificación completada. Resultado documentado en F3-A-result.md.

**Tiempo estimado:** 15–30 minutos.

---

### F3-G: Context Budget Update (escenario sin compactación)

**Propósito:** Añadir escenario "sin compactación de Manager Protocol" a los budgets.

**Por qué es segundo:** Es la mejora requerida #1 de la F2 Critical Review. Sin este update, los budgets dan falsa seguridad.

**Acciones:**
1. Añadir columna "Sin compactación" a F2-context-budget-contract.md.
2. Modo Normal sin compactación: objetivo 10k–14k en lugar de 8.5k–12k.
3. Documentar el supuesto: "Si QW#3 no se implementa, estos budgets aplican."
4. Actualizar context-budget-contract.md con el nuevo escenario.

**Criterio de salida:** ✅ Budgets actualizados con ambos escenarios.

**Tiempo estimado:** 15 minutos.

---

## BLOQUE 2 — Implementation & Prototypes

### F3-B: QW#5 Skills Block Compaction (prototipo)

**Propósito:** Implementar la compactación del bloque de skills (descripciones de ~15–50 palabras a ~5–10 palabras).

**Por qué es primero en implementación:** Es el quick win más seguro. Bajo riesgo, bajo esfuerzo, ~400–600 tokens de ahorro.

**Método de implementación:**
1. Leer skills actuales del system prompt (o del source de `opencode.json`).
2. Proponer descripciones compactas para cada skill.
3. Medir ahorro real con tiktoken.
4. NO modificar ningún archivo de configuración. Solo documentar el diff propuesto.
5. El diff va al approval package.

**Riesgos:**
- 🟢 Bajo. Si las descripciones son muy cortas, el Manager puede no identificar cuándo cargar un skill. Mitigación: Manager invoca por nombre, no por descripción.

**Criterio de salida:** ✅ Diff documentado. Ahorro medido. Listo para approval.

**Tiempo estimado:** 30–45 minutos.

---

### F3-C: QW#1 Session History Compaction (prototipo aislado)

**Propósito:** Prototipar la compactación del session history (3+7+acumulativo) en un entorno aislado, SIN tocar el runtime.

**Por qué es importante:** Es el quick win de mayor impacto potencial (~3k–5k tokens). Pero también el más riesgoso.

**Método de implementación:**
1. Capturar un session history real de una sesión completa de trabajo.
2. Aplicar el algoritmo 3+7+acumulativo en un script aislado (read-only).
3. Incluir regla R7 (decisiones explícitas preservadas textualmente).
4. Medir ahorro neto (bruto - costo de compactar).
5. Comparar cobertura: el resumen ¿pierde información crítica?
6. NO modificar el pipeline de captura ni el runtime.

**Regla R7 (nueva, de F2 Critical Review):**
> Si un turno contiene una decisión explícita (marcadores: "decido", "no hagas", "es mejor que", "prefiero"), esa decisión debe preservarse textualmente en el resumen, no resumirse.

**Métrica de éxito:**
- Ahorro neto > 2k tokens.
- No se pierde información crítica (validado por comparación humana o por test QW1-T4).

**Criterio de salida:** ✅ Prototipo funcionando. Ahorro medido. R7 implementada. Ahorro neto documentado.

**Tiempo estimado:** 1–2 sesiones.

---

### F3-D: QW#4 Memorias Rankeadas (prototipo aislado)

**Propósito:** Prototipar el selector con scoring semántico + top-k sobre datos reales de Engram.

**Por qué es valioso:** La verificación metodológica de F2 mostró que el scoring (relevancia 0.5 + recencia 0.3 + tipo 0.2) necesita calibración con datos reales.

**Método de implementación:**
1. Query a Engram real con `mem_search` para obtener observaciones existentes.
2. Implementar pipeline de scoring en script aislado.
3. Probar con diferentes queries y modos (Simple/Top-5, Normal/Top-10, Arquitectura/Top-20).
4. Verificar que el top-k no elimina observaciones únicas.
5. NO modificar el pipeline de retrieval ni el runtime.

**Calibración necesaria:**
- ¿El peso de 0.5 para relevancia funciona con datos reales?
- ¿La recencia (0.3) penaliza decisiones arquitectónicas antiguas pero vigentes?
- ¿El tipo (0.2) necesita ajuste por tipo de observación?

**Criterio de salida:** ✅ Scoring calibrado con datos reales. Top-k validado. Recomendaciones de ajuste documentadas.

**Tiempo estimado:** 1 sesión.

---

### F3-E: Regression Harness Creation

**Propósito:** Crear un harness ejecutable (script read-only) que ejecute los tests del regression plan automáticamente.

**Por qué es necesario:** La F2 Critical Review detectó que el regression plan no tiene scripts ejecutables (H7).

**Requisitos del harness:**
1. Read-only — no modifica nada.
2. Ejecuta al menos los tests de cobertura y budget.
3. Reporta PASS/FAIL/WARNING por test.
4. Genera un reporte en markdown o terminal.

**Tests a automatizar (prioridad):**

| ID | Test | Método |
|:--:|------|--------|
| C-T1 | All sources accounted for | Verificar que todas las fuentes F1 existen en F2 contract |
| C-T2 | Budgets match pack totals | Sumar packs por modo y comparar con budget contract |
| B-T1 | Mode Simple ≤ 8.5k | Medir con tiktoken (mock o real) |
| B-T2 | Mode Normal ≤ 12k | Medir con tiktoken (mock o real) |
| Q-T1 | Decision preserved in summary | Verificar R7 en sesión de prueba |
| Q-T2 | Top-k not empty | Verificar que el selector devuelve ≥ 1 resultado |

**Criterio de salida:** ✅ Harness ejecutable. Reporte generado. Tests pasan.

**Tiempo estimado:** 30–60 minutos.

---

## BLOQUE 3 — Gate & Package

### F3-F: Approval Package

**Propósito:** Compilar todos los cambios propuestos en un solo paquete de aprobación para el usuario.

**Por qué es el último:** Necesita los outputs de F3-A a F3-E para estar completo.

**Contenido del package:**
1. **Diff completo** de cada cambio propuesto (skills, session, selector, budgets).
2. **Ahorro estimado** total y por quick win (con ranges).
3. **Riesgos documentados** (F-R21 a F-R24 y los ajustados).
4. **Tradeoffs** para cada quick win.
5. **Orden de implementación recomendado** para F4.
6. **Pregunta al usuario:** "¿Aprobás estos cambios para F4?"

**Formato:** Un documento markdown con tablas de resumen + diffs + preguntas.

**Criterio de salida:** ✅ Approval package creado. Presentado al usuario.

**Tiempo estimado:** 30 minutos.

---

## Diagrama de dependencias

```
F3-A (Runtime API) ──► ─┐
                         ├──► F3-F (Approval Package) ──► F4
F3-G (Budget Update) ───┤
                         │
F3-B (Skills) ──────────┤
                         │
F3-C (Session) ─────────┤
                         │
F3-D (Selector) ────────┤
                         │
F3-E (Harness) ─────────┘
```

F3-A y F3-G pueden ejecutarse en paralelo (Bloque 1).  
F3-B, F3-C, F3-D, F3-E pueden ejecutarse en paralelo (Bloque 2) — no tienen dependencias entre sí.  
F3-F depende de todos los anteriores (Bloque 3).

---

## Métricas de éxito de F3

| Métrica | Target | Cómo se mide |
|---------|:------:|:-------------|
| Runtime API verificada | ✅/❌ | Documentado en F3-A-result.md |
| Budgets actualizados | Ambos escenarios | Diff de budget contract |
| Skills ahorro medido | ≥400 tokens | tiktoken antes/después |
| Session ahorro neto medido | ≥2k tokens | Script aislado |
| Selector calibrado con datos reales | Scoring validado | Query real a Engram |
| Harness ejecutable | ≥4 tests passing | Script output |
| Approval package listo | Completo | Documento creado |

---

## Riesgos de F3

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:--------:|------------|
| Runtime API no existe → QW#2 bloqueado | Alta | Medio | QW#2 descartado; ahorro se recupera de otros QW |
| Session compaction prototipo no escala | Media | Medio | Prototipo aislado → no toca runtime |
| Selector scoring no mejora baseline | Media | Bajo | Se documenta y se propone ajuste |
| Harness tests fallan por falsos positivos | Baja | Bajo | Tests read-only; no afectan nada |
| Approval package rechazado | Media | Alto | Se itera basado en feedback del usuario |

---

## Documentos asociados

| Documento | Estado | Contenido |
|-----------|:------:|-----------|
| `F3-execution-strategy.md` | ✅ Creado | Este documento — estrategia detallada |
| `F3-A-result.md` | ⬜ Pendiente | Resultado de runtime API verification |
| `F3-B-skills-diff.md` | ⬜ Pendiente | Diff de skills block compaction |
| `F3-C-session-result.md` | ⬜ Pendiente | Prototipo de session compaction |
| `F3-D-selector-result.md` | ⬜ Pendiente | Prototipo de mem_context selector |
| `F3-E-harness-result.md` | ⬜ Pendiente | Regression harness + test results |
| `F3-F-approval-package.md` | ⬜ Pendiente | Approval package para el usuario |

---

*Fin de F3-execution-strategy.md — Estrategia detallada de implementación para F3.*
