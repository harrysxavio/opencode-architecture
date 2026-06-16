# Regression Plan — Fase F

**Propósito:** Definir las validaciones que deben pasarse después de implementar cualquier cambio de Fase F, para garantizar que no se rompe funcionalidad existente.

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

## Resumen de gates

| Gate | Tests | Criterio PASS |
|:----:|:-----:|---------------|
| 1. E6B | T1-T7 | Idéntico a baseline |
| 2. Suite F | F1-F6 | Idéntico a baseline |
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
