# Regression Plan — Fase F

**Estado:** ✅ EXTENDED WITH F2 TESTS  
**Propósito:** Definir las validaciones que deben pasarse después de implementar cualquier cambio de Fase F, para garantizar que no se rompe funcionalidad existente.

> Este documento fue extendido con los nuevos tests de F2 (quick wins audits). Se agregaron 3 nuevos gates: F2 Quick Wins Verification, F2 Contract Compliance, y Full Artifact Audit.

---

## Gates obligatorios

Ningún cambio de Fase F puede promoverse sin pasar estos gates en orden:

```
E6B Suite  →  Suite F  →  Token Budget  →  Quality  →  Security
   ✅            ✅             ✅              ✅           ✅
```

---

## Gate 1: E6B completa (Noise Gate)

**Propósito:** Verificar que la reducción de tokens no rompe el Noise Gate.

### Tests a ejecutar

| Test | Input | Esperado |
|:----:|-------|----------|
| T1 | `ok gracias jajaja` | No capturar ✅ |
| T2 | `listo` | No capturar ✅ |
| T3 | `¿Qué rol cumple Engram en esta arquitectura?` | Capturar ✅ |
| T4 | `Diseña una prueba read-only para validar mem_context.` | Capturar ✅ |
| T5 | `Mi token falso es ghp_FAKE1234567890abcdef1234567890abcdef` | No capturar raw ✅ |
| T6 | `muéstrame el archivo README` | No capturar ✅ |
| T7 | `Continúa con la arquitectura OpenCode.` | Capturar ✅ |

### Método
1. Sesión canonical `opencode-architecture`.
2. Ejecutar cada input desde la sesión canonical.
3. Verificar DB con sqlite3.
4. Todos deben dar el mismo resultado que en E6B original.

**Criterio PASS:** T1-T7 idéntico resultado que baseline E6B.

---

## Gate 2: Suite F completa (mem_context read-only)

**Propósito:** Verificar que la reducción no afecta la recuperación de contexto.

### Tests a ejecutar

| Test | Qué valida |
|:----:|------------|
| F-T1 | Happy path canonical → contexto real |
| F-T2 | Proyecto inexistente → graceful |
| F-T3 | Sin proyecto → cross-project documentado |
| F-T4 | Idempotencia → 0 cambios DB |
| F-T5 | Cross-verify timeline → contenido real |
| F-T6 | Solo Engram tools |

**Criterio PASS:** F-T1 a F-T6 idéntico resultado que Suite F original. DB sin cambios.

---

## Gate 3: Token budget compliance

**Propósito:** Verificar que el sistema respeta el presupuesto de tokens por modo.

### Tests

| Test | Qué valida | Método |
|:----:|------------|--------|
| B-T1 | Modo Simple ≤ 8.5k | Medir con tiktoken |
| B-T2 | Modo Normal ≤ 12k | Medir con tiktoken |
| B-T3 | Modo Arquitectura ≤ 16k | Medir con tiktoken |
| B-T4 | Expansión automática ≤ 14k sin justificación | Verificar comportamiento |
| B-T5 | Expansión >14k requiere justificación | Verificar comportamiento |
| B-T6 | L0+L1 siempre presentes en todos los modos | Inspeccionar contenido |

**Criterio PASS:** Todos los budgets se respetan. L0+L1 siempre presentes.

---

## Gate 4: Quality of context recovery

**Propósito:** Verificar que la calidad del contexto recuperado no se degrada.

### Tests

| Test | Qué valida | Método |
|:----:|------------|--------|
| Q-T1 | Contexto de arquitectura relevante | Buscar "Engram Noise Gate" → debe encontrar #404 |
| Q-T2 | Decisiones recientes recuperables | Buscar "E6B" → debe encontrar session summaries |
| Q-T3 | Suite F resultados recuperables | Buscar "Suite F" → debe encontrar #427 |
| Q-T4 | Sin invención | Verificar que no hay contenido ficticio |
| Q-T5 | Sin legacy cross-project | Verificar project match exacto |

**Criterio PASS:** Resultados relevantes y reales encontrados. Sin invención.

---

## Gate 5: Security

**Propósito:** Verificar que no se exponen secretos.

### Tests

| Test | Qué valida | Método |
|:----:|------------|--------|
| S-T1 | Secretos `ghp_` no aparecen en contexto | Buscar en output |
| S-T2 | Secretos de proyectos legacy no aparecen | Buscar en output |
| S-T3 | Token env no se expone | Verificar que no hay leaks |

**Criterio PASS:** Zero exposición de secretos.

---

## Gate 6: Regression (E2E)

**Propósito:** Verificar que el sistema completo funciona en un flujo real.

### Flujo de prueba

1. Abrir sesión canonical `opencode-architecture`.
2. Ejecutar tarea típica: "¿Qué estado tiene el proyecto actualmente?"
3. Verificar que la respuesta incluye:
   - Proyecto correcto.
   - Estado de E6B y Suite F.
   - Sin mención de proyectos legacy no solicitados.
4. Medir tokens usados en el prompt.
5. Verificar que el presupuesto está dentro del modo Normal.

**Criterio PASS:** Respuesta correcta, presupuesto respetado, sin cross-project.

---

## Gate 2.5: F2 Quick Wins Verification

**Propósito:** Verificar que los quick wins diseñados en F2 son viables y están correctamente documentados antes de pasar a F3.

### Tests a ejecutar

| Test | Qué valida | Método |
|:----:|------------|--------|
| QW2-T1 | Session history compactado: diseño completo y coherente | Revisar `session-history-compaction-audit.md` |
| QW2-T2 | Tool schemas bajo demanda: viabilidad técnica evaluada | Revisar `tool-schema-demand-loading-audit.md` |
| QW2-T3 | Manager Protocol compactación: propuesta clara y segura | Revisar `manager-protocol-compaction-audit.md` |
| QW2-T4 | Skills selectivos: propuesta implementable | Revisar `skills-selective-loading-audit.md` |
| QW2-T5 | Quick wins integrados con budgets de F2 | Verificar que cada QW mapea a capa L0-L5 |
| QW2-T6 | Quick wins priorizados correctamente | Verificar que QW#1–QW#5 tienen prioridad, fase, y riesgo documentados |

**Criterio PASS:** Todos los quick wins tienen documento de auditoría, diseño claro, riesgos documentados, y están alineados con F2 budgets.

---

## Gate 2.6: F2 Contract Compliance

**Propósito:** Verificar que todos los documentos de F2 cumplen el contrato de presupuesto por modo.

### Tests

| Test | Qué valida | Método |
|:----:|------------|--------|
| C-T1 | Budgets por modo suman correctamente | Sumar capas vs total modo |
| C-T2 | Source-to-layer mapping completo | Verificar que las 15 fuentes F1 están mapeadas |
| C-T3 | L0 + L1 presentes en todos los modos | Inspeccionar cada modo |
| C-T4 | Exclusion rules no contradicen MUST | Leer contract |
| C-T5 | Fallback rules cubren todos los casos | Verificar 7+ situaciones |
| C-T6 | Expansion rules tienen triggers claros | Verificar 3 categorías |

**Criterio PASS:** Contract completo y consistente. Sin contradicciones.

---

## Gate 2.7: Full Artifact Audit

**Propósito:** Verificar que todos los documentos de F2 existen, están actualizados y son consistentes entre sí.

### Tests

| Test | Qué valida |
|:----:|------------|
| A-T1 | `F2-context-budget-contract.md` existe y está completo |
| A-T2 | `context-budget-contract.md` referencias F2 correctamente |
| A-T3 | `context-layers-design.md` actualizado con F1+F2 data |
| A-T4 | `context-packs-design.md` incluye 3 nuevos packs |
| A-T5 | `mem-context-selector-design.md` incluye pseudocódigo y scoring |
| A-T6 | `tool-schema-demand-loading-audit.md` existe y completo |
| A-T7 | `session-history-compaction-audit.md` existe y completo |
| A-T8 | `manager-protocol-compaction-audit.md` existe y completo |
| A-T9 | `skills-selective-loading-audit.md` existe y completo |
| A-T10 | `gentle-ai-alignment.md` existe y completo |
| A-T11 | `implementation-roadmap.md` marcado F2 COMPLETED |
| A-T12 | `decision-log.md` incluye decisiones de F2 |
| A-T13 | `risk-register.md` actualizado con riesgos F2 |
| A-T14 | Todos los budgets son consistentes entre documentos |
| A-T15 | Sin cambios funcionales implementados en F2 |

**Criterio PASS:** Los 14 tests PASS o están documentados como no aplicables.

---

## Resumen de gates

| Gate | Tests | Criterio PASS |
|:----:|:-----:|---------------|
| 1. E6B | T1-T7 | Idéntico a baseline |
| 2. Suite F | F1-F6 | Idéntico a baseline |
| 2.5. Quick Wins | QW2-T1 a QW2-T6 | Todos diseñados y alineados |
| 2.6. Contract | C-T1 a C-T6 | Contract completo y consistente |
| 2.7. Audit | A-T1 a A-T15 | Todos los documentos existen y son consistentes |
| 3. Budget | B1-B6 | Budgets respetados |
| 4. Quality | Q1-Q5 | Contexto real, sin invención |
| 5. Security | S1-S3 | Zero secretos expuestos |
| 6. Regression | Flujo E2E | Respuesta correcta + budget |

---

## Rollback criteria

Si cualquiera de estos gates FALLA:

1. **Detener** el rollout.
2. **Documentar** el fallo con evidencia.
3. **Revertir** el cambio que causó el fallo.
4. **Re-ejecutar** los gates del cambio anterior.
5. **No promover** hasta que todos los gates PASS.

---

_Fin de regression-plan.md_
