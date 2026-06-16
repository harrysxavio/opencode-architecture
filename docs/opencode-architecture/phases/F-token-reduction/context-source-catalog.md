# Context Source Catalog — F1

**Estado:** ✅ COMPLETED (F1)  
**Fecha:** 2026-06-16  
**Propósito:** Catálogo estructurado de todas las fuentes de contexto que alimentan el sistema, con metadata comparable para decidir optimizaciones.

---

## Catálogo completo

| # | Fuente | Ubicación | Tipo | Chars | Est. tokens | Contiene | Consumidor | Clasif. F1 |
|:-:|--------|-----------|:----:|:-----:|:-----------:|----------|:----------:|:----------:|
| 1 | **Manager Protocol** | `opencode.json` → `agent.manager.prompt` | Fija | 28,471 | 7,100–14,200 | Orquestación global, fases SDD 0-8, anti-patrones, fast-track, default behavior | Manager agent | **KEEP_FIXED** (compactable) |
| 2 | **AGENTS.md — Persona** | `~/.config/opencode/AGENTS.md` (L1-70) | Fija | ~3,500 | ~875 | Rules, Personality, Language, Tone, Philosophy, Expertise, Behavior | Manager agent | **COMPACT_FIXED** |
| 3 | **AGENTS.md — Engram Protocol** | `~/.config/opencode/AGENTS.md` (L72-166) | Fija | ~5,500 | ~1,375 | Save triggers, search rules, session close, after compaction | Manager agent | **DEDUPLICATE** (vs Manager protocol Engram ref) |
| 4 | **AGENTS.md — Design Skills Protocol** | `~/.config/opencode/AGENTS.md` (L168-259) | Fija | ~4,500 | ~1,125 | Frontend Design Gate, SDD mods, review mods, Skill Creator | Manager agent | **RETRIEVE_ON_DEMAND** (solo frontend) |
| 5 | **OpenCode Core (built-in)** | Runtime (no modificable) | Fija | ~8k–12k | 2,000–3,000 | Core guardrails, system prompt base, agent primitives | Todos los agentes | **KEEP_FIXED** (no modificable) |
| 6 | **Tool Schemas** | Runtime (16 tool definitions) | Fija | ~12,800 | 3,200–6,400 | 16 definiciones con nombre, descripción, parámetros, required, descripciones | Manager agent | **RETRIEVE_ON_DEMAND** (solo tools relevantes al turno) |
| 7 | **Available Skills block** | System prompt (generado por runtime) | Fija | 4,158 | ~1,040 | Lista de 38 skills con nombre + descripción corta | Manager agent | **COMPACT_FIXED** (descripciones más cortas) |
| 8 | **Skills content (SKILL.md)** | 3 directorios, 40 skills únicos | Bajo demanda | 308,002 total | 1,250–6,250/turno | Instrucciones completas de cada skill | Manager agent (vía skill tool) | **RETRIEVE_ON_DEMAND** (ya, pero skills individuales compactables) |
| 9 | **Engram memories (retrieved)** | `engram.db` → `mem_context` output | Recuperada | 388,260 total DB | 1,250–3,750/turno | Decisiones, bugs, discoveries, session summaries, config, patterns | Manager agent (vía mem_context) | **RANK_AND_LIMIT** (top-k + dedup) |
| 10 | **Session history (current)** | Runtime (conversación activa) | Dinámica | ~5k–10k | 5,000–8,000 | User prompts + assistant responses del turno actual | Manager agent | **COMPACT_FIXED** (resumir turns antiguos) |
| 11 | **User Prompts (Engram DB)** | `engram.db` → `user_prompts` | Almacenada (con Noise Gate) | 161,117 total | ~40,000 total | Prompts capturados (útiles, filtrados por Noise Gate) | Solo retrieval futuro | **INVESTIGATE** (no se carga actualmente en contexto) |
| 12 | **Environment info** | Runtime (fecha, dir, plataforma, git) | Fija | ~300–500 | ~75–125 | Working directory, date, platform, git status | Manager agent | **KEEP_FIXED** (mínimo, no vale la pena optimizar) |
| 13 | **Project docs** | `docs/opencode-architecture/` | Bajo demanda | ~200K+ total | Variable | ADRs, architecture docs, test results, phase docs | Manager agent (vía read tool) | **RETRIEVE_ON_DEMAND** (ya, no cambiar) |
| 14 | **README principal** | `opencode-architecture/README.md` | Bajo demanda | ~30,000 | ~7,500 | Project overview, phases, findings, architecture | Manager agent (vía read tool) | **RETRIEVE_ON_DEMAND** (ya, no cambiar) |
| 15 | **Fase F docs** | `docs/.../F-token-reduction/` | Bajo demanda | 11 docs, ~80K total | ~20,000 total | Plan de reducción de tokens, diseño, riesgos | Manager agent (vía read tool) | **RETRIEVE_ON_DEMAND** (ya, no cambiar) |

---

## Clasificación por categoría

### KEEP_FIXED (debe quedar siempre en contexto base)

| Fuente | Justificación |
|--------|---------------|
| Manager Protocol | Es el core de orquestación. Sin él, el Manager no sabe cómo operar. |
| OpenCode Core | No modificable. Viene del runtime. |
| Environment info | Mínimo (~75–125 tokens). No vale la pena optimizar. |

### COMPACT_FIXED (debe quedar fija, pero más compacta)

| Fuente | Tokens actuales | Tokens objetivo estimado | Estrategia |
|--------|:---------------:|:------------------------:|------------|
| AGENTS.md — Persona | ~875 | ~500 | Compactar reglas redundantes |
| Available Skills block | ~1,040 | ~600 | Acortar descripciones, solo nombre + trigger keywords |
| Session history | ~5,000–8,000 | ~2,000–3,000 | Resumir turns antiguos, mantener los últimos 3-5 crudos |

### RETRIEVE_ON_DEMAND (debe salir del contexto base)

| Fuente | Estado actual | Acción |
|--------|:-------------:|--------|
| AGENTS.md — Design Skills Protocol | Fija (siempre cargada) | Mover a skill tool: cargar solo cuando la tarea es frontend |
| Tool Schemas | Fija (16 tools siempre cargadas) | Cargar solo schemas de tools aplicables al turno actual |
| Skills content | Ya bajo demanda | Mantener, pero compactar skills grandes (hatch-pet: 37KB) |
| Project docs | Ya bajo demanda | Mantener |
| README | Ya bajo demanda | Mantener |
| Fase F docs | Ya bajo demanda | Mantener |

### RANK_AND_LIMIT (debe seleccionarse con ranking/top-k)

| Fuente | Estado actual | Acción |
|--------|:-------------:|--------|
| Engram memories | Sin ranking ni límite fijo | Implementar: score semántico, top-5 a top-10, dedup, umbral de score |

### DEDUPLICATE (debe limpiarse por duplicación)

| Fuente A | Fuente B | Tipo de duplicación | Acción |
|----------|----------|---------------------|--------|
| AGENTS.md Engram protocol | Manager protocol (ref. Engram) | Contenido complementario, baja duplicación real | Mantener separado o unificar en Manager protocol |
| README (estado fases) | Engram session summaries | Estado del proyecto repetido en N lugares | No tocar aún (Fase F es sobre contexto inyectado, no sobre docs) |

### INVESTIGATE (falta evidencia para decidir)

| Fuente | Por qué |
|--------|---------|
| User Prompts (Engram DB, 161KB) | No se cargan en contexto actualmente. Pero si en futuro se usan para retrieval, necesitan ranking/límite. |

---

## Detalle de fuentes principales

### 1. Manager Protocol

| Atributo | Valor |
|----------|-------|
| **Archivo** | `C:\Users\harry\.config\opencode\opencode.json` (embedded) |
| **Chars** | 28,471 |
| **Est. tokens** | 7,100–14,200 (según ratio 4:1 a 2:1) |
| **¿Modificable?** | Sí (editar opencode.json) |
| **Secciones** | Manager Global Orchestration Protocol, Operating Model, Global Rule, Context Layer Definitions, Phases 0-8, Anti-Patterns, Fast-Track, Default Behavior |
| **Riesgo si falta** | 🔴 Crítico — Manager no sabe cómo orquestar |
| **Riesgo si sobra** | 🟡 Alto — consume 20-28% del presupuesto de tokens |
| **Puede compactarse** | Sí — algunas secciones (Context Layer Definitions, Fast-Track, Anti-Patterns) pueden acortarse |
| **Puede deduplicarse** | Parcial — algunas reglas se repiten con AGENTS.md |
| **Prioridad optimización** | 🔴 Alta — es la fuente individual más grande |

### 2. AGENTS.md (completo)

| Atributo | Valor |
|----------|-------|
| **Archivo** | `C:\Users\harry\.config\opencode\AGENTS.md` |
| **Chars total** | 13,412 |
| **Est. tokens** | ~3,400 |
| **Sub-secciones** | Persona (L1-70, ~3.5KB), Engram Protocol (L72-166, ~5.5KB), Design Skills (L168-259, ~4.5KB) |
| **¿Modificable?** | Sí |
| **Riesgo si falta** | 🔴 Alto — Manager pierde persona, protocolo de memoria y protocolo de diseño |
| **Riesgo si sobra** | 🟡 Medio — 10% del presupuesto |
| **Puede compactarse** | Sí — especialmente Persona (reglas redundantes) y Design Skills (solo necesario para frontend) |
| **Puede deduplicarse** | Sí — Engram Protocol tiene superposición parcial con Manager protocol |
| **Prioridad optimización** | 🟡 Media |

### 3. Engram Memories

| Atributo | Valor |
|----------|-------|
| **Base de datos** | `C:\Users\harry\.engram\engram.db` |
| **Observaciones totales** | 326 |
| **Chars totales en DB** | 388,260 |
| **Chars recuperados típicamente** | ~5k–15k por `mem_context` |
| **Est. tokens recuperados** | 1,250–3,750 |
| **Tipos de memoria** | session_summary (119), architecture (47), config (39), discovery (35), decision (26), bugfix (22), passive (17), pattern (11), preference (7), documentation (2), feature (1) |
| **Riesgo si falta** | 🟡 Medio — Manager pierde contexto cross-session |
| **Riesgo si sobra** | 🟡 Medio — 3-8% del presupuesto, pero puede crecer |
| **Puede rankearse** | Sí — implementar scoring semántico, top-k configurable |
| **Puede deduplicarse** | Sí — 119 session summaries contienen estado repetido |
| **Prioridad optimización** | 🟡 Media (después de quick wins de session history y tools) |

### 4. Tool Schemas

| Atributo | Valor |
|----------|-------|
| **Tools disponibles** | 16 |
| **Chars estimados** | ~12,800 |
| **Est. tokens** | 3,200–6,400 |
| **Tools usadas típicamente** | 3–5 por turno |
| **Riesgo si falta** | 🟡 Medio — Manager no puede usar herramientas no cargadas |
| **Riesgo si sobra** | 🟡 Medio — 8-13% del presupuesto para tools que no se usarán |
| **Pueden cargarse bajo demanda** | Sí — por fase del SDD o por decisión del Manager |
| **Prioridad optimización** | 🟡 Media |

### 5. Session History

| Atributo | Valor |
|----------|-------|
| **Ubicación** | Runtime (contexto de conversación) |
| **Tamaño típico** | ~5k–10k chars (~5k–8k tokens) |
| **Contiene** | User prompts + assistant responses del turno actual |
| **Riesgo si falta** | 🟡 Medio — Manager pierde contexto de la conversación actual |
| **Riesgo si sobra** | 🔴 Alto — en sesiones largas puede superar 10k+ tokens |
| **Puede compactarse** | Sí — resumir turns antiguos, mantener últimos 3-5 crudos |
| **Prioridad optimización** | 🔴 Alta — quick win más impactante (~3k–5k tokens) |

---

## Resumen de ahorro potencial por fuente

| Fuente | Tokens actuales | Tokens objetivo | Ahorro estimado | Categoría |
|--------|:---------------:|:---------------:|:---------------:|:---------:|
| Manager Protocol | ~7,100–14,200 | ~5,000–8,000 | ~2k–6k | COMPACT |
| AGENTS.md (Design Skills) | ~1,125 | ~0 (bajo demanda) | ~1,125 | RETRIEVE |
| Tool Schemas | ~3,200–6,400 | ~1,000–2,000 | ~2k–4k | RETRIEVE |
| Available Skills | ~1,040 | ~600 | ~440 | COMPACT |
| AGENTS.md (Persona) | ~875 | ~500 | ~375 | COMPACT |
| Session History | ~5,000–8,000 | ~2,000–3,000 | ~3k–5k | COMPACT |
| Engram Memories | ~1,250–3,750 | ~800–1,500 | ~500–2k | RANK |
| Skills Content | ~1,250–6,250 | ~1,000–3,000 | ~250–3k | COMPACT (skills grandes) |
| Duplicación | ~3,000–5,000 | ~0 | ~3k–5k | DEDUP |
| **Total** | **~22k–45k** | **~10k–18k** | **~12k–27k** | |

---

## Propuesta para F2 (Context Budget Contract)

### Modo Simple (~6k tokens)
- Manager Protocol (compactado, ~3k)
- OpenCode Core (~2k)
- Environment info (~100)
- Available Skills (compactado, ~600)
- Engram memories top-3 (~300)
- **Sin**: session history, tool schemas, skills content, AGENTS.md protocolos

### Modo Normal (~9.5k tokens)
- Manager Protocol (compactado, ~5k)
- OpenCode Core (~2k)
- Environment info (~100)
- Available Skills (compactado, ~600)
- Session history compactado (~1k)
- Engram memories top-5 (~500)
- Tool schemas esenciales (~1k)

### Modo Arquitectura (~14k tokens)
- Manager Protocol (completo, ~7k)
- OpenCode Core (~2k)
- Environment info (~100)
- Available Skills (~1k)
- Session history (~2k)
- Engram memories top-10 (~1k)
- Tool schemas (~2k)

### Modo Auditoría (~19k tokens)
- Manager Protocol (completo, ~7k)
- OpenCode Core (~3k)
- Environment info (~100)
- Available Skills (~1k)
- AGENTS.md completo (~3k)
- Session history (~3k)
- Engram memories amplias (~2k)
- Tool schemas (~3k)

### Bajo demanda (context packs)
- **Context Pack: Identity**: Project identity (modo Normal+)
- **Context Pack: Active Phase**: Current phase status (modo Normal+)
- **Context Pack: Risk Register**: Active risks (modo Arquitectura+)
- **Context Pack: Decision Log**: Recent decisions (modo Normal+)
- **Context Pack: Design Skills**: Frontend Design protocol (solo frontend)

---

*Fin de context-source-catalog.md — F1 COMPLETED. Sin cambios funcionales implementados.*
