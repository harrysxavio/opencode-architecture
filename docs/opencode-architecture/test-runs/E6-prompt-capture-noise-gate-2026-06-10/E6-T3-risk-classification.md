# E6-T3: Risk Classification Completeness

**Objetivo:** Verificar que todos los riesgos identificados en el audit tienen mitigación propuesta en el diseño.

## Matriz Riesgo-Mitigación

| Riesgo | Audit (23) | Diseño (24) | Mitigación |
|--------|:----------:|:-----------:|------------|
| R1 — Ruido en memoria permanente | ✅ Sección 6 | ✅ Secciones 3, 4 | Heurísticas filtran noise/confirmation/navigation |
| R2 — Datos sensibles no etiquetados | ✅ Sección 6 | ✅ Sección 5.1 | Sensitive pattern detection + redacted_content |
| R3 — Falsa sensación de control | ✅ Sección 6 | ⚠️ Filosófico | El gate hace explícito qué se captura |
| R4 — Truncamiento silencioso | ✅ Sección 6 | ⚠️ Baja prioridad | Se documenta, no se resuelve en E6B |
| R5 — Sin diferenciación comandos/datos | ✅ Sección 6 | ✅ Sección 5.1 | Clasificación por tipo |

## Resultado: ✅ PASS (con observación)

R3 es un riesgo filosófico. Se mitiga parcialmente haciendo explícito en `AGENTS.md` que user_prompts se capturan con gate. R4 se documenta como conocido sin acción inmediata.
