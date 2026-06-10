# E1 — Controlled Memory Tests

Scope ficticio: `TEST-E-MEMORY-GOVERNANCE`.

## Resultado

| Test | Estado | Evidencia |
|---|---|---|
| E-T1 — `mem_context` actual | PASSED | `mem_context` y `mem_search` no encontraron probe previo; no se inventó memoria |
| E-T2 — `mem_save` ficticio | PASSED con hallazgo | Primer intento falló por `unknown_session`; después de `mem_session_start`, guardó id=395 |
| E-T3 — recuperación inmediata | PASSED | `mem_search` encontró id=395 y `mem_get_observation` recuperó contenido completo |
| E-T4 — recuperación post-nueva sesión | PARTIAL | CLI independiente `engram search` encontró id=395 y DB directa lo confirmó; falta reinicio real OpenCode |
| E-T5 — session summary | PASSED con hallazgo | `mem_session_summary` creó observation id=396; `sessions.summary` quedó vacío |
| E-T6 — no guardar ruido | PASSED simulado | No se llamó `mem_save`; DB no contiene phrase `ok gracias jajaja` en observations ni user_prompts |
| E-T7 — contradicción ficticia | PASSED | Upsert con mismo topic_key actualizó id=395 a deprecated; `revision_count=2` |

## Detalles clave

- `mem_save` no acepta nativamente `valid_until`, `status`, `supersedes`, `sensitivity`, `evidence` como campos separados. Se guardaron dentro de `content`.
- `topic_key` se normaliza a lowercase: `test-e-memory-governance/probe`.
- El upsert por `topic_key` funcionó: id=395 se mantuvo y `revision_count` pasó a 2.
- Engram generó candidatos de conflicto falsos contra un `session_summary`; se resolvió con `mem_judge relation=not_conflict`.
- E-T4 no reemplaza una validación post-restart real; solo prueba persistencia durable desde CLI/DB.

## IDs creados

| ID | Tipo | Título | Uso |
|---:|---|---|---|
| 395 | discovery | TEST-E memory persistence probe deprecated | Probe ficticio E-T2/E-T7 |
| 396 | session_summary | Session summary: opencode-architecture | Summary ficticio E-T5 |
