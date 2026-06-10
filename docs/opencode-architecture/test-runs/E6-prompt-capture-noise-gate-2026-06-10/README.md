# E6 — Prompt Capture / Noise Gate Audit & Design (2026-06-10)

## Estado: ✅ Completada (read-only)

Fase E6A completada. Pendiente aprobación para E6B (implementación).

## Documentos creados

| Doc | Archivo | Descripción |
|:---:|---------|-------------|
| 23 | `docs/opencode-architecture/23-prompt-capture-audit.md` | Auditoría completa del sistema de captura automática de prompts |
| 24 | `docs/opencode-architecture/24-noise-gate-design.md` | Diseño del Noise Gate con 3 opciones y recomendación (Opción B) |

## Tests

| ID | Resultado | Archivo |
|:--:|:---------:|---------|
| T1 | ✅ PASS | [E6-T1-audit-completeness.md](E6-T1-audit-completeness.md) |
| T2 | ✅ PASS | [E6-T2-db-inventory.md](E6-T2-db-inventory.md) |
| T3 | ✅ PASS | [E6-T3-risk-classification.md](E6-T3-risk-classification.md) |
| T4 | ✅ PASS | [E6-T4-design-options-evaluation.md](E6-T4-design-options-evaluation.md) |
| T5 | ✅ PASS | [E6-T5-contract-alignment.md](E6-T5-contract-alignment.md) |
| T6 | ✅ PASS | [E6-T6-implementation-spec-completeness.md](E6-T6-implementation-spec-completeness.md) |
| T7 | ✅ PASS | [E6-T7-rollback-readiness.md](E6-T7-rollback-readiness.md) |

## Hallazgos principales

1. **302 user_prompts** capturados automáticamente sin ningún filtro semántico.
2. **El plugin `engram.ts`** captura en hook `chat.message` con solo gate de longitud > 10 chars.
3. **Riesgo R2 (datos sensibles)** es el más severo: solo filtro de `<private>` tags.
4. **Opción recomendada**: Clasificación por Heurísticas (Opción B) — punto óptimo entre precisión y esfuerzo.
5. **E5 contracts no afectados**: Noise Gate opera sobre `user_prompts`, los contratos E5 gobiernan `observations`.
6. **Rollback en 10 segundos**: cambiar `allow_prompt_capture` a `"all"` restaura comportamiento actual.
