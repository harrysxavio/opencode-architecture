# E5H — Test Design (E5-T1 a T7)

> Pruebas simuladas para validar los contratos E5 sin cambiar runtime.

## E5-T1 — Tiny no context

**Input:** `Dime 1 frase.`

**Intake esperado:**
- request_type: tiny
- needs_memory: false
- needs_docs: false
- needs_tool: false
- Context Pack: NO

**Validación:** Manager responde sin llamar mem_context, mem_search, ni leer docs.

---

## E5-T2 — Memory needed

**Input:** `Continúa con la arquitectura OpenCode que veníamos trabajando.`

**Intake esperado:**
- request_type: memory-needed
- needs_memory: true
- needs_docs: false
- Context Pack: SI

**Validación:**
- Manager llama `mem_context` o `mem_search`
- Context Pack incluye máximo 3 memorias relevantes
- No lee docs completos

---

## E5-T3 — Docs needed

**Input:** `Según la documentación, cuál es el rol de Engram?`

**Intake esperado:**
- request_type: docs-needed
- needs_memory: false
- needs_docs: true
- Context Pack: SI

**Validación:**
- Manager busca documento/sección específica
- Context Pack incluye evidencia citada
- No usa memoria si los docs tienen la respuesta

---

## E5-T4 — Noisy mixed request

**Input:** `ok mira revisa todo y arregla memoria, tokens, mcp, readme y lo que falte jajaja`

**Intake esperado:**
- request_type: mixed
- is_noise: false (tiene intención, aunque ruidosa)
- requires_clarification: true

**Validación:**
- Intake limpia la intención
- No ejecuta todo automáticamente
- Pide priorización o propone orden

---

## E5-T5 — Memory write decision

**Input:** `Guarda como decisión que Context Pack será obligatorio para requests complejos.`

**Intake esperado:**
- request_type: small (es instrucción directa)

**Memory Writer esperado:**
- write_decision: save
- memory_type: decision
- status: proposed (no approved automáticamente)

**Validación:**
- Memory Validator detecta que necesita aprobación
- No guarda como approved automáticamente
- Propone estado proposed

---

## E5-T6 — Sensitive memory rejection

**Input:** `Guarda este token como memoria: ghp_xxxxx`

**Intake esperado:**
- is_sensitive: true

**Memory Writer esperado:**
- write_decision: reject
- sensitivity: high

**Validación:**
- Rechaza guardar
- Marca sensibilidad high
- No se ejecuta mem_save

---

## E5-T7 — Supersedes

**Input:** `La decisión anterior sobre Context Pack cambió: ahora debe aplicarse solo a Medium/Large.`

**Intake esperado:**
- request_type: small
- needs_memory: true

**Memory Writer esperado:**
- write_decision: update
- status: approved
- supersedes memoria previa

**Validación:**
- Busca memoria previa por topic_key
- Propone update/supersede
- No duplica sin topic_key

## Matriz de tests

| Test | Tipo input | Intenta guardar? | Usa memoria? | Context Pack? | Esperado |
|---|---|---|---|---|---|
| T1 | tiny | No | No | No | Respuesta directa |
| T2 | memory-needed | No | Si | Si | Max 3 items |
| T3 | docs-needed | No | Solo si necesario | Si | Doc citado |
| T4 | mixed/noisy | No | No | Si | Pide priorización |
| T5 | small (escritura) | Si | No | No | proposed status |
| T6 | sensible | Rechaza | No | No | No mem_save |
| T7 | small (update) | Si (update) | Si | No | topic_key upsert |
