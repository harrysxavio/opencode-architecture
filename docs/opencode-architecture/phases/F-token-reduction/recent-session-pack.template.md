# RECENT_SESSION_PACK — Template

**Propósito:** Proporcionar un resumen estructurado del session history para reducir tokens sin perder continuidad.

---

## Estructura del pack

```
┌─────────────────────────────────────────────────────────────┐
│  RECENT_SESSION_PACK                                        │
│  ├── RAW_BLOCK (últimos 3 turns, sin modificar)            │
│  ├── SUMMARY_BLOCK (turns 4-10, 1-2 líneas c/u)            │
│  └── ACCUMULATED_BLOCK (turns 11+, párrafo creciente)      │
└─────────────────────────────────────────────────────────────┘
```

---

## RAW_BLOCK

```
Turn {N-2} — {User/Assistant}: {texto completo}
Turn {N-1} — {User/Assistant}: {texto completo}
Turn {N}   — {User/Assistant}: {texto completo}
```

**Reglas:**
- Siempre los últimos 3 turns, sin excepción.
- Si la sesión tiene ≤ 3 turns, solo RAW_BLOCK.
- Si la sesión tiene ≤ 10 turns, RAW + SUMMARY, sin ACCUMULATED.

---

## SUMMARY_BLOCK

```
Turn {N-10} — {actor}: {acción} — {resultado} [{tipo}]
Turn {N-9} — {actor}: {acción} — {resultado} [{tipo}]
...
Turn {N-4} — {actor}: {acción} — {resultado} [{tipo}]
```

**Tipos:**
- `[decision]` — decisión explícita (se preserva textualmente por R7)
- `[constraint]` — restricción impuesta por el usuario
- `[progress]` — avance reportado
- `[request]` — solicitud del usuario
- `[question]` — pregunta del usuario

**Regla R7 (obligatoria):**
Si un turno contiene una decisión explícita con marcadores (`decido`, `no hagas`, `es mejor que`, `prefiero`), la decisión se preserva textualmente en el resumen.

---

## ACCUMULATED_BLOCK

```
Turns {inicio-fin}: {resumen de 1-3 oraciones}.
Decisiones clave: {decisiones textuales}.
Pendiente: {próximos pasos}.
Riesgos activos: {riesgos mencionados}.
```

**Reglas:**
- Se actualiza cada ~5 turns o cuando ocurre un evento significativo.
- Las decisiones recientes se agregan como texto textual (R7).
- Los riesgos activos se mantienen hasta que se resuelven.
- El bloque no debe exceder ~200 tokens (crece ~15 tokens cada 5 turns).

---

## Ejemplo completo (sesión de 30 turns)

```
### RAW_BLOCK (turns 28-30)
Turn 28 — Assistant: Session compaction simulated. 30-turn session analyzed.
Turn 29 — User: Add R7: preserve decisions textually in summaries.
Turn 30 — Assistant: R7 implemented. [decision — R7 added, preserved textually]

### SUMMARY_BLOCK (turns 4-10)
Turn 4 — Assistant: 9.5k as range not limit. D-F-001. [decision]
Turn 5 — User: F1: catalog sources. NO config changes. [constraint]
Turn 6 — Assistant: 15 sources cataloged. 7 duplications. [progress]
Turn 7 — User: Show duplications impact and quick win ROI. [request]
Turn 8 — Assistant: 7 duplications. 5 quick wins. [progress]
Turn 9 — User: F2 budgets per mode. L0-L5 layers. [request]
Turn 10 — Assistant: Modes designed. L0 ~4k to L5 ~500. [progress]

### ACCUMULATED_BLOCK (turns 11-30)
Turns 11-15: Expansion rules defined. 5 audits created. Risk register + regression plan.
Turns 16-20: Selector design 0.5/0.3/0.2. Roadmap F0-F6.
Turns 21-25: F2 Critical Review — 8 findings APTO. F3 strategy.
Turns 26-30: Skills ~1,184 tokens. Session compaction prototype. R7 added.
Decisiones clave: R7 added (turn 30).
```

---

## Reglas de compactación

| Regla | Descripción |
|:------|:------------|
| R1 | Últimos 3 turns siempre crudos |
| R2 | Turns 4-10: 1-2 líneas cada uno |
| R3 | Turns 11+: párrafo acumulativo |
| R4 | El acumulado se actualiza cada ~5 turns |
| R5 | Si la sesión tiene ≤ 3 turns: solo RAW |
| R6 | Si la sesión tiene ≤ 10 turns: RAW + SUMMARY, sin ACCUMULATED |
| **R7** | **Decisiones explícitas se preservan textualmente** |
| R8 | El resumen usa template estructurado, no generación libre |
| R9 | Secretos (`ghp_`, `token=`, `password`) se excluyen del resumen |
| R10 | El pack se puede desactivar (fallback a history completo) |

---

## Activación/desactivación

El RECENT_SESSION_PACK se activa automáticamente cuando:
- La sesión supera 10 turns, O
- El session history supera ~500 tokens

Se desactiva (fallback a history completo) cuando:
- El usuario pregunta sobre un turno específico anterior al turno 10
- Se detecta que el resumen perdió información crítica
- Modo Excepcional (>22k tokens)

---

## Métricas de eficiencia

| Duración sesión | Sin compactación | Con compactación | Ahorro |
|:---------------:|:----------------:|:----------------:|:------:|
| 15 turns | ~4,200 tokens | ~3,445 tokens | ~455t (11%) |
| 20 turns | ~7,350 tokens | ~5,040 tokens | ~1,860t (25%) |
| **30 turns** | **~16,275 tokens** | **~8,455 tokens** | **~7,070t (43%)** |
| 60 turns | ~64,050 tokens | ~20,500 tokens | ~41,900t (65%) |

*Nota: el ahorro es acumulativo a lo largo de toda la sesión, no por turno.*

---

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|:-------|:-----------|
| Pérdida de contexto para decisión antigua | R7 preserva decisiones textualmente; Engram tiene la memoria completa |
| Resumen alucina información | Template estructurado (R8), no generación libre |
| Usuario no encuentra turno específico | Fallback desactiva compactación |
| Compatibilidad con E6B/Suite F | Pack no modifica DB ni runtime existente |

---

*Fin de recent-session-pack.template.md — Template listo para implementación.*
