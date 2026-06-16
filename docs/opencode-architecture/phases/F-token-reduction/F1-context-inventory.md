# F1 — Context Inventory

**Estado:** ✅ COMPLETED  
**Fecha:** 2026-06-16  
**Propósito:** Inventario técnico y accionable de todas las fuentes de contexto que alimentan el sistema, clasificando qué contiene cada una, cuándo es necesaria, qué riesgo tiene si falta/sobra, y recomendación para Fase F.

---

## Precheck de entorno

| Check | Resultado | Detalle |
|:-----:|:---------:|---------|
| Directorio de trabajo | ✅ | `C:\Users\harry\OneDrive\Documentos\GitHub\opencode-architecture` |
| Engram DB | ✅ | `C:\Users\harry\.engram\engram.db` — 3,076,096 bytes (~3MB) |
| opencode.json | ✅ | `C:\Users\harry\.config\opencode\opencode.json` — 64,295 bytes |
| AGENTS.md | ✅ | `C:\Users\harry\.config\opencode\AGENTS.md` — 13,412 bytes |
| `.codex/memories_1.sqlite` | ⚠️ Existe (40KB) — **NO USAR** | Store legacy, no es Engram |
| E6B Noise Gate tests | ✅ | `test-runs/E6-prompt-capture-noise-gate-2026-06-10` presente |
| Suite F tests | ✅ | `test-runs/F-mem-context-readonly-2026-06-16` presente |
| F-token-reduction docs | ✅ | 11 documentos existentes (contando este) |
| Git repo | ✅ | Repositorio activo en ruta canonical |

---

## Fuentes inventariadas

Se identificaron y catalogaron **15 fuentes de contexto**:

| # | Fuente | Categoría F1 | Est. tokens | Prioridad |
|:-:|--------|:------------:|:-----------:|:---------:|
| 1 | Manager Protocol | **KEEP_FIXED** (compactable) | 7,100–14,200 | 🔴 Alta |
| 2 | AGENTS.md — Persona | **COMPACT_FIXED** | ~875 | 🟡 Media |
| 3 | AGENTS.md — Engram Protocol | **DEDUPLICATE** | ~1,375 | 🟢 Baja |
| 4 | AGENTS.md — Design Skills | **RETRIEVE_ON_DEMAND** | ~1,125 | 🟡 Media |
| 5 | OpenCode Core (built-in) | **KEEP_FIXED** (no mod) | 2,000–3,000 | ⚪ N/A |
| 6 | Tool Schemas (16 tools) | **RETRIEVE_ON_DEMAND** | 3,200–6,400 | 🟡 Media |
| 7 | Available Skills block (38) | **COMPACT_FIXED** | ~1,040 | 🟢 Baja |
| 8 | Skills Content (40 SKILL.md) | **RETRIEVE_ON_DEMAND** | 1,250–6,250 | 🟢 Baja |
| 9 | Engram Memories (retrieved) | **RANK_AND_LIMIT** | 1,250–3,750 | 🟡 Media |
| 10 | Session History (current) | **COMPACT_FIXED** | 5,000–8,000 | 🔴 Alta |
| 11 | User Prompts (Engram DB) | **INVESTIGATE** | ~40K total (no in context) | ⚪ Futuro |
| 12 | Environment Info | **KEEP_FIXED** (mínimo) | ~75–125 | ⚪ N/A |
| 13 | Project Docs | **RETRIEVE_ON_DEMAND** | Variable | ⚪ Ya óptimo |
| 14 | README principal | **RETRIEVE_ON_DEMAND** | ~7,500 | ⚪ Ya óptimo |
| 15 | Fase F Docs | **RETRIEVE_ON_DEMAND** | ~20K total | ⚪ Ya óptimo |

**Detalle de cada fuente** — ver [context-source-catalog.md](context-source-catalog.md)

---

## Hallazgos principales

### H1 — La fuente individual más grande es el Manager Protocol

Con 28,471 chars (~7,100–14,200 tokens), el Manager Protocol es **la fuente más grande y la de mayor prioridad de optimización**. Representa 20–28% del total de la sesión típica.

**Posible compactación:**
- Sección "Context Layer Definitions" (Superpowers, Graphify, Engram, GPT-5.5) — referencia a otros docs vs definiciones inline
- Sección "Anti-Patterns" — ~400 tokens, puede acortarse
- Sección "Fast-Track Exceptions" — ~200 tokens, puede acortarse
- Sección "Default Behavior" — ~200 tokens, puede acortarse

**Estimación post-compactación:** ~5,000–8,000 tokens (ahorro ~2k–6k).

### H2 — AGENTS.md tiene 3 sub-fuentes con comportamientos diferentes

AGENTS.md (13,412 chars) no es una fuente homogénea. Tiene 3 sub-secciones con clasificaciones distintas:

| Sub-sección | Chars | Clasificación | Justificación |
|-------------|:-----:|:-------------:|---------------|
| Persona (L1-70) | ~3,500 | COMPACT_FIXED | Reglas de estilo de respuesta. Necesarias siempre, pero compactables. |
| Engram Protocol (L72-166) | ~5,500 | DEDUPLICATE | Instrucciones de memoria. Ligeramente duplicadas con Manager protocol. |
| Design Skills (L168-259) | ~4,500 | RETRIEVE_ON_DEMAND | Solo necesario para tareas frontend. **No debería cargarse siempre.** |

### H3 — El session history es el quick win más impactante

Aunque el Manager Protocol es la fuente más grande, el session history es el quick win que más tokens puede ahorrar por sí solo (~3k–5k). Además, no requiere cambios en `opencode.json` ni en el runtime de OpenCode — solo mejorar cómo se gestiona el historial de conversación.

### H4 — Engram tiene un problema de proporción: 36% son session summaries

De 326 observaciones, 119 (36%) son session summaries. Esto significa que `mem_context` puede estar devolviendo estado repetido ("E6B COMPLETE" aparece en 5+ summaries, 3+ architecture memories y el README). La solución no es eliminar summaries, sino **deduplicar en retrieval** (F3).

### H5 — Tool schemas: 16 herramientas, pero solo 3-5 se usan por turno

Las 16 herramientas cargadas siempre son una sobrecarga significativa (~3,200–6,400 tokens). Herramientas como `context7_query-docs`, `websearch`, `webfetch`, `delegation_list`, `delegation_read` no se usan en la mayoría de los turnos.

**Clasificación de tools por frecuencia de uso:**

| Grupo | Tools | Frecuencia |
|:-----:|-------|:----------:|
| Core (siempre) | read, write, edit, bash, glob, grep | ~100% |
| Frecuentes | task, skill, todowrite, delegate, webfetch | ~40-60% |
| Ocasionales | websearch, context7_*, delegation_list, delegation_read | ~10-30% |

---

## Duplicaciones críticas

Se identificaron **7 duplicaciones** entre fuentes. Las más relevantes:

| ID | Fuente A | Fuente B | Tokens | Tipo | Acción |
|:--:|----------|----------|:------:|:----:|--------|
| D7 | Tool schemas (16 cargados) | Tools usadas (3-5) | ~2k–4k | **Derrochable** | Mover a bajo demanda |
| D3 | README estado fases | Engram session_summaries | ~500–1.5k | Redundante | Dedup en F3 |
| D1 | AGENTS.md Rules | Manager Protocol Defaults | ~200–400 | Conceptual | Alinear en compactación |

**Detalle completo:** [duplication-map.md](duplication-map.md)

---

## Quick Wins priorizados

| Prioridad | Quick Win | Ahorro | Esfuerzo | Fase |
|:---------:|-----------|:------:|:--------:|:----:|
| 🔴 1 | Tool schemas bajo demanda | ~2k–4k | Medio-Alto | F3 |
| 🟡 2 | Session history compactado | ~3k–5k | Medio | F2/F3 |
| 🟡 3 | Dedup Manager/AGENTS.md | ~300–550 (+1,125) | Bajo-Medio | F2 |
| 🟢 4 | Memorias rankeadas + top-k | ~500–2k | Medio | F3 |
| 🟢 5 | Skills selectivos | ~400–600 | Bajo | F2 |

**Análisis detallado:** [quick-wins-analysis.md](quick-wins-analysis.md)

---

## Matriz de priorización

| # | Fuente | Tokens actuales | Tokens objetivo | Ahorro | Riesgo | Esfuerzo | Prioridad | Categoría | Próxima acción |
|:-:|--------|:---------------:|:---------------:|:------:|:------:|:--------:|:---------:|:----------:|----------------|
| 1 | Session History | 5,000–8,000 | 2,000–3,000 | ~3k–5k | 🟡 Medio | Medio | **🔴 1** | COMPACT | Diseñar compactador de historial |
| 2 | Tool Schemas | 3,200–6,400 | 1,000–2,000 | ~2k–4k | 🟡 Medio | Medio-Alto | **🔴 2** | RETRIEVE | Evaluar soporte runtime para tool loading dinámico |
| 3 | Manager Protocol | 7,100–14,200 | 5,000–8,000 | ~2k–6k | 🟡 Medio | Medio | **🟡 3** | COMPACT | Compactar secciones redundantes |
| 4 | Engram Memories | 1,250–3,750 | 800–1,500 | ~500–2k | 🟡 Medio | Medio | **🟡 4** | RANK | Diseñar ranking + top-k (F3) |
| 5 | AGENTS.md — Design Skills | ~1,125 | ~0 (bajo demanda) | ~1,125 | 🟢 Bajo | Bajo | **🟡 5** | RETRIEVE | Mover a invocación por skill tool |
| 6 | Available Skills | ~1,040 | ~600 | ~440 | 🟢 Bajo | Bajo | **🟢 6** | COMPACT | Acortar descripciones |
| 7 | AGENTS.md — Persona | ~875 | ~500 | ~375 | 🟢 Bajo | Bajo | **🟢 7** | COMPACT | Compactar reglas redundantes |
| 8 | Duplicación (DD1-DD7) | ~3,000–5,000 | ~0 | ~3k–5k | Variable | Variable | **En paralelo** | DEDUP | Según plan de cada duplicación |
| 9 | Skills Content | 1,250–6,250 | 1,000–3,000 | ~250–3k | 🟢 Bajo | Medio | 🟢 Baja | COMPACT | Skills grandes (hatch-pet 37KB) |
| 10 | User Prompts (DB) | ~40K total | — | — | — | — | ⚪ Futuro | INVESTIGATE | No tocar hasta F-G |

---

## Propuesta para F2 (Context Budget Contract)

### Fuentes fijas (modo Normal)
1. **Manager Protocol** (compactado ~5k tokens)
2. **OpenCode Core** (~2k tokens, no modificable)
3. **Environment Info** (~100 tokens)
4. **Available Skills** (compactado ~600 tokens)

### Fuentes dinámicas con límite
5. **Session History** (compactado ~1k tokens, últimos 3 crudos + resumen)
6. **Engram Memories** (top-5 rankeadas, ~500 tokens)
7. **Tool Schemas** (core 6 siempre + fase actual, ~1k tokens)

### Fuentes bajo demanda (context packs)
8. **AGENTS.md — Design Skills Protocol** → solo tareas frontend
9. **AGENTS.md — Engram Protocol** → siempre fijo (es instrucción de memoria)
10. **Project Docs / README / Fase F docs** → bajo demanda (ya)

### Modos propuestos

| Modo | Tokens objetivo | Fuentes incluidas |
|:----:|:---------------:|-------------------|
| **Simple** | ~6k | Manager Protocol (compactado), OpenCode Core, Env, Skills (compactado), Engram top-3 |
| **Normal** | ~9.5k | Simple + Session History (compactado) + Tool Schemas core + Engram top-5 |
| **Arquitectura** | ~14k | Normal + Manager Protocol (completo) + AGENTS.md (completo) + Session History (más detalle) + Engram top-10 |
| **Auditoría** | ~19k | Arquitectura + AGENTS.md completo + Session History completo + Tool Schemas completo + Engram amplio |
| **Excepcional** | >22k | Auditoría + todo disponible, con justificación documentada |

---

## Documentos creados/actualizados

| Archivo | Acción | Contenido |
|---------|:------:|-----------|
| `F1-context-inventory.md` | ✅ Creado | Este archivo — reporte principal de F1 |
| `context-source-catalog.md` | ✅ Creado | Catálogo de 15 fuentes con metadata completa |
| `duplication-map.md` | ✅ Creado | 7 duplicaciones documentadas con impacto y recomendación |
| `quick-wins-analysis.md` | ✅ Creado | 5 quick wins analizados en profundidad |
| `README.md` (Fase F) | **Pendiente actualizar** | Marcar F0 COMPLETE y F1 COMPLETE |
| `implementation-roadmap.md` | **Pendiente actualizar** | Marcar F1 completado |
| `decision-log.md` | **Pendiente actualizar** | Registrar decisiones de F1 |
| `README.md` (principal) | ✅ Ya actualizado | Ya refleja F0 COMPLETE |

Se actualizarán los documentos pendientes a continuación.

---

## Riesgos detectados

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|:--:|--------|:-----------:|:-------:|------------|
| F1-R1 | **Tool loading dinámico no soportado por runtime** | Media | Alto | Verificar con OpenCode si hay API para tool loading selectivo. Si no, postergar a F3. |
| F1-R2 | **Compactación de Manager protocol rompe comportamiento** | Baja | Alto | Diff texto completo antes/después. Validación con Suite F + E6B. |
| F1-R3 | **Session history compactado pierde contexto crítico** | Baja | Medio | Mantener últimos 3 turns crudos + resumen estructurado (no generación libre). |
| F1-R4 | **Cross-project leakage en Engram dedup** | Baja | Medio | Filtro estricto por `scope=project` en F3. |
| F1-R5 | **Quick wins sin implementar por dependencias externas** | Media | Medio | Priorizar quick wins sin dependencias externas (QW4, QW5). |
| F1-R6 | **Duplicación documental crece sin control** | Media | Bajo | No afecta tokens de contexto (docs se leen bajo demanda). Solo riesgos de stale state. |

---

## Confirmación: sin cambios funcionales

| Aspecto | Estado |
|---------|:------:|
| ¿Se modificó DB? | ❌ No |
| ¿Se modificó schema? | ❌ No |
| ¿Se modificó config? | ❌ No |
| ¿Se modificó Noise Gate? | ❌ No |
| ¿Se modificó mem_context? | ❌ No |
| ¿Se modificó pipeline de captura? | ❌ No |
| ¿Se eliminaron archivos? | ❌ No |
| ¿Se eliminaron memorias? | ❌ No |
| ¿Se implementaron cambios funcionales? | ❌ No |
| ¿Se usó `.codex/memories_1.sqlite`? | ❌ No |
| ¿Solo diagnóstico, clasificación y documentación? | ✅ Sí |

**F1 es 100% diagnóstico.** Ningún cambio funcional fue implementado.

---

## Recomendación para F2

F2 (Context Budget Contract) debe tomar los hallazgos de F1 y convertirlos en un **contrato formal de presupuesto de tokens por modo**. Las acciones recomendadas:

1. **Definir budgets exactos** por modo (Simple, Normal, Arquitectura, Auditoría, Excepcional) usando los rangos de F1.
2. **Compactar fuentes KEEP_FIXED**: Manager Protocol y Available Skills.
3. **Mover a RETRIEVE_ON_DEMAND**: Design Skills Protocol de AGENTS.md.
4. **Diseñar compactador de session history** (preparar spec para F3).
5. **Investigar soporte runtime** para tool loading dinámico.
6. **Refinar propuesta de context packs** para F4.

**No implementar cambios en runtime todavía.** F2 debe producir el contrato; F3-F4 implementan.

---

*Fin de F1-context-inventory.md — F1 COMPLETED. Sin cambios funcionales implementados.*
