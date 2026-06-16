# Duplication Map — F1

**Estado:** ✅ COMPLETED (F1)  
**Fecha:** 2026-06-16  
**Propósito:** Documentar duplicaciones detectadas entre fuentes de contexto, impacto estimado en tokens y recomendación.

---

## Metodología

Se analizaron las siguientes fuentes en busca de contenido repetido:
- `opencode.json` → Manager protocol (28,471 chars)
- `~/.config/opencode/AGENTS.md` (13,412 chars, 3 sub-secciones)
- `opencode-architecture/README.md` (~30,000 chars)
- Engram DB observations (326 registros, 388,260 chars)
- Available skills block (38 skills, 4,158 chars)
- Skill files (40 únicos, 308,002 chars)
- Tool schemas (16 tools, ~12,800 chars)
- Session history (312 user_prompts, 161,117 chars)

---

## Mapa de duplicaciones

### D1 — Reglas de persona: AGENTS.md Rules ↔ Manager Protocol Default Behavior

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | Reglas de comportamiento que aparecen en ambos archivos con diferente redacción |
| **Fuente A** | `AGENTS.md` L1-13: "Ask at most one question at a time", "Do not present option menus... unless there is a real fork with meaningful tradeoffs", "If unsure about length or detail, choose the shorter response", "Verify technical claims before stating them" |
| **Fuente B** | Manager Protocol Phase 1 (Clarification Rules): "Ask one question at a time when clarification is needed", Phase 8 (Completion Contract): "Do not claim completion without evidence", Default Behavior |
| **Impacto tokens** | ~200–400 tokens duplicados (conceptualmente, no texto exacto) |
| **Naturaleza** | 🔵 Conceptual — misma intención, texto diferente |
| **Riesgo de eliminar** | 🟢 Bajo — las reglas de AGENTS.md son más específicas; las del Manager protocol son operacionales |
| **Recomendación** | ✅ **No eliminar**. Son complementarias. AGENTS.md gobierna el estilo de respuesta; Manager protocol gobierna la orquestación. Pero en F2 (compactación) se pueden alinear para que no digan lo mismo con distintas palabras. |

### D2 — Engram Protocol: AGENTS.md ↔ Manager Protocol (referencia)

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | Definición y reglas de uso de Engram |
| **Fuente A** | `AGENTS.md` L72-166 (Engram Persistent Memory — Protocol): ~5,500 chars con instrucciones detalladas de mem_save, mem_search, session_summary, after compaction |
| **Fuente B** | Manager Protocol "Context Layer Definitions → Engram": ~200 chars con definición breve de qué es Engram |
| **Impacto tokens** | ~50–100 tokens de solapamiento (la definición de "Engram es memoria persistente" aparece en ambos) |
| **Naturaleza** | 🔵 Jerárquica — AGENTS.md tiene el protocolo detallado; Manager protocol tiene la definición conceptual |
| **Riesgo de eliminar** | 🟢 Bajo — la definición del Manager protocol puede eliminarse si AGENTS.md ya la cubre |
| **Recomendación** | ✅ **Compactar Manager protocol**: reemplazar la sección "Engram" en Context Layer Definitions con una referencia breve a "Ver AGENTS.md para el protocolo completo". Ahorro: ~100–150 tokens. |

### D3 — Estado del proyecto: README ↔ Engram session summaries ↔ Engram architecture memories

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | Información de estado de fases (E6B COMPLETE, Suite F COMPLETE, Fase F PLANNING) aparece en al menos 3 tipos de fuentes |
| **Fuente A** | `README.md`: tablas de estado de fases, resultados de tests (E6B T1-T7, Suite F F1-F6, F0) |
| **Fuente B** | Engram `session_summary` (119 registros): muchos contienen "E6B COMPLETE — T1-T7 all PASS", "Suite F COMPLETE" |
| **Fuente C** | Engram `architecture` (47 registros): algunos documentan fases completadas (#402 E4B, #403 E5, #404 E6B) |
| **Impacto tokens** | ~500–1,500 tokens de estado duplicado entre los ~1,250–3,750 que recupera mem_context |
| **Naturaleza** | 🔴 Redundante — el mismo estado se repite en N lugares, y cuando cambia hay que actualizar todos |
| **Riesgo de eliminar** | 🟡 Medio — si se eliminan session summaries antiguos, Manager pierde trazabilidad histórica |
| **Recomendación** | ✅ **No eliminar ahora**. Para F3 (mem_context Selector): implementar **dedup semántico** que evite incluir 3 memorias que dicen "E6B COMPLETE". Score más alto a la más reciente. Mantener máx 1–2 por tema. |

### D4 — Skills: Available skills block ↔ SKILL.md descriptions

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | Las descripciones cortas de skills en el bloque `<available_skills>` se derivan del contenido de los archivos SKILL.md |
| **Fuente A** | System prompt `<available_skills>`: 38 skills con nombre + línea de descripción (~4,158 chars) |
| **Fuente B** | Archivos `SKILL.md` (40 únicos, 308,002 chars): cada skill tiene descripción larga y contenido completo |
| **Impacto tokens** | ~500–1,000 tokens de descripciones que se listan en el bloque + se cargan si se invoca el skill |
| **Naturaleza** | 🟢 Esperada — el bloque es el índice; el skill file es el contenido. Es normal que el nombre/descripción aparezca en ambos |
| **Riesgo de eliminar** | N/A — no hay duplicación problemática |
| **Recomendación** | ✅ **Compactar available skills block**: usar descripciones más cortas (solo trigger keywords). No eliminar del bloque porque es el índice que usa Manager para decidir qué skills cargar. |

### D5 — Fase F estado: Documentos múltiples

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | El estado de fases F0-F6 se documenta en 4+ lugares |
| **Fuentes** | `README.md`, `implementation-roadmap.md`, `decision-log.md`, `risk-register.md`, `context-budget-contract.md` |
| **Impacto tokens** | ~300–500 tokens de estado repetido entre documentos |
| **Naturaleza** | 🟡 Normal en proyectos multi-documento |
| **Riesgo de eliminar** | N/A — son documentos separados con propósito diferente |
| **Recomendación** | ✅ **Aceptar duplicación**. No vale la pena optimizar documentos que se leen bajo demanda. El riesgo de stale state se mitiga con disciplina al actualizar. |

### D6 — User prompts: Engram DB ↔ Session history (runtime)

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | Prompts del usuario pueden aparecer tanto en session history (runtime) como en `user_prompts` (Engram DB capturados) |
| **Fuente A** | Session history runtime: los prompts del usuario en la conversación actual |
| **Fuente B** | Engram `user_prompts` (312 registros, 161,117 chars): prompts capturados con Noise Gate |
| **Impacto tokens** | Variable — depende de si retrieval futuro usa `user_prompts` |
| **Naturaleza** | 🟢 Esperada — `user_prompts` es backup persistente; session history es el contexto activo |
| **Riesgo de eliminar** | N/A — no se cargan actualmente en contexto |
| **Recomendación** | ✅ **No tocar ahora**. Cuando se diseñe retrieval de `user_prompts` (futuro), implementar dedup contra session history actual. |
| **Bloqueante** | Noise Gate E6B ya filtra ruido; no hay duplicación problemática. |

### D7 — Tool schemas: cargados en memoria vs realmente usados

| Aspecto | Detalle |
|---------|---------|
| **Contenido duplicado** | No es duplicación textual, pero hay **sobrecarga** por cargar schemas que no se usan |
| **Fuente A** | 16 tool schemas cargados completos (~12,800 chars, ~3,200–6,400 tokens) |
| **Fuente B** | Tools realmente usadas por turno: 3–5 de 16 (~800–2,000 chars) |
| **Impacto tokens** | ~2,000–4,000 tokens de schemas cargados pero no utilizados por turno |
| **Naturaleza** | 🔴 **Derrochable** — carga completa siempre, uso parcial siempre |
| **Riesgo de eliminar** | 🟡 Medio — si se cargan bajo demanda y la heurística falla, Manager no tiene la tool disponible |
| **Recomendación** | ✅ **Mover a RETRIEVE_ON_DEMAND** en F2/F3. Cargar solo tools de la fase SDD actual + tools básicas (read, write, edit, bash, glob, grep). |

---

## Resumen de duplicaciones

| ID | Fuente A | Fuente B | Impacto tokens | Tipo | Recomendación |
|:--:|----------|----------|:--------------:|:----:|---------------|
| D1 | AGENTS.md Rules | Manager Protocol Default Behavior | ~200–400 | Conceptual | Mantener, alinear en compactación |
| D2 | AGENTS.md Engram Protocol | Manager Protocol (ref. Engram) | ~50–150 | Jerárquica | Compactar Manager protocol: referenciar AGENTS.md |
| D3 | README estado fases | Engram session_summaries + architecture | ~500–1,500 | Redundante | No eliminar; dedup en retrieval (F3) |
| D4 | Available skills block | SKILL.md descriptions | ~500–1,000 | Esperada | Compactar descripciones |
| D5 | README, roadmap, decision-log, risk-register | Estado Fase F | ~300–500 | Normal multi-doc | Aceptar |
| D6 | User prompts (session) | User prompts (Engram DB) | Variable | Esperada | No tocar |
| D7 | Tool schemas (todos) | Tool schemas (usados) | ~2,000–4,000 | **Derrochable** | **Mover a bajo demanda** |

---

## Duplicaciones prioritarias para Fase F

| Prioridad | ID | Acción | Ahorro estimado | Complejidad |
|:---------:|:--:|--------|:---------------:|:-----------:|
| 🔴 1 | D7 | Tool schemas bajo demanda | ~2k–4k tokens | Media |
| 🟡 2 | D3 | Dedup de memorias con estado repetido | ~500–1.5k tokens | Media (parte de F3) |
| 🟢 3 | D2 | Compactar referencia a Engram en Manager protocol | ~50–150 tokens | Baja |
| 🟢 4 | D4 | Compactar descripciones de skills | ~500–1k tokens | Baja |
| 🟢 5 | D1 | Alinear reglas AGENTS.md/Manager protocol | ~200–400 tokens | Baja |
| ⚪ 6 | D5 | Aceptar duplicación documental | 0 tokens | N/A |
| ⚪ 7 | D6 | No tocar | 0 tokens | N/A |

---

## Riesgos de duplicación no resueltos

| Riesgo | Descripción | Mitigación |
|--------|-------------|------------|
| **Session summary explosion** | 119 session summaries (36% de observations). Si no se controla, seguirá creciendo | F3: limitar retrieval a top-3 summaries, score por relevancia |
| **Estado inconsistente** | README dice X, Engram dice Y por desactualización | Protocolo de actualización: cada cambio de fase actualiza Engram + README |
| **Cross-project leakage** | Algunas session summaries son de `retail-masivo-oc` pero podrían recuperarse en `opencode-architecture` | F3: filtro estricto por `scope=project` + verificación de proyecto |

---

*Fin de duplication-map.md — F1 COMPLETED. Sin cambios funcionales implementados.*
