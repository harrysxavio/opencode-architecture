# Skills Selective Loading Audit — F2

**Estado:** ✅ AUDIT COMPLETED (2026-06-16)  
**Propósito:** Auditar el bloque `<available_skills>` en el system prompt, evaluar la compactación de descripciones y proponer un modelo de skills selectivos por proyecto/contexto.

---

## Executive Summary

El bloque `<available_skills>` lista 38 skills con descripciones de 1–2 líneas (~4,158 chars, ~1,040 tokens). La mayoría de las descripciones son genéricas y no ayudan al matching del Manager.

**Ahorro propuesto:** Reducir descripciones a 5–10 palabras (trigger keywords) → ~500–600 tokens (**ahorro ~400–600 tokens**). Adicionalmente, si se filtran skills por proyecto, ahorro adicional de ~200–400 tokens.

**Riesgo:** Bajo. El Manager puede invocar skills por nombre incluso sin descripciones detalladas.

---

## 1. Estado actual

| Métrica | Valor |
|---------|:-----:|
| Skills listados en bloque | 38 |
| Skills únicos instalados | 40 (en 3 directorios) |
| Chars del bloque | ~4,158 |
| Est. tokens | ~1,040 |
| Descripción promedio | 15–25 palabras |
| Skills con descripciones >40 palabras | 12 (ej. `frontend-design`, `bigquery-expert`, `hatch-pet`) |

### Skills con descripciones más largas

| Skill | Descripción actual (chars) | Propuesta |
|:------|:--------------------------:|:----------|
| `frontend-design` | ~200 chars | `Frontend UI, React components, pages, layouts` |
| `bigquery-expert` | ~180 chars | `BigQuery SQL, queries, datasets, data analysis` |
| `hatch-pet` | ~160 chars | `Pet spritesheets, character art, pet.json packaging` |
| `canvas-design` | ~150 chars | `Poster, art, design artifact, visual composition` |
| `web-design-guidelines` | ~140 chars | `UI review, accessibility, UX audit, Vercel guidelines` |

---

## 2. Propuesta de descripciones compactas

### Formato actual

```xml
<skill>
  <name>frontend-design</name>
  <description>Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.</description>
</skill>
```

### Formato propuesto

```xml
<skill>
  <name>frontend-design</name>
  <description>Frontend UI, React, components, pages, visual design</description>
</skill>
```

### Reglas de compactación

| Regla | Descripción |
|-------|-------------|
| R1 | Mantener nombre exacto del skill (no cambiar). |
| R2 | Descripción: solo trigger keywords (5–10 palabras). |
| R3 | Keywords: nombre del framework/librería + principales acciones + contexto. |
| R4 | No incluir ejemplos ni casos de uso en la descripción. |
| R5 | Skills del proyecto actual tienen prioridad en el bloque. |

---

## 3. Skills por proyecto

Actualmente los 38 skills se listan sin importar el proyecto activo. Se propone **filtrar por proyecto**:

### Proyecto: opencode-architecture

Skills relevantes:
- `sdd-*` (explore, propose, spec, design, tasks, apply, verify, archive, onboard, init)
- `engram-agent`
- `graphify`
- `cognitive-doc-design`
- `skill-creator`
- `skill-improver`
- `skill-registry`
- `judgment-day`
- `flow-diagram`
- `work-unit-commits`
- `branch-pr`
- `chained-pr`
- `issue-creation`
- `comment-writer`
- `customize-opencode`
- `deploy-security-gate`

Skills NO relevantes (no listar):
- `bigquery-expert`, `bigquery-table-cleaning`, `sandbox-data-loader`, `sql-learning`
- `canvas-design`, `frontend-design`, `design-md`, `web-design-guidelines`
- `hatch-pet`, `go-testing`
- `data-memory-governance`

**Ahorro adicional:** ~200–400 tokens al no listar skills irrelevantes al proyecto.

### Limitación

El filtrado por proyecto requiere que el runtime de OpenCode soporte skills condicionales según el proyecto activo. Si no está soportado, mantener el bloque completo pero compactado.

---

## 4. Matriz de skills compactados

| Skill | Descripción actual (tokens) | Descripción propuesta |
|:------|:---------------------------:|-----------------------|
| bigquery-expert | ~50 | BigQuery SQL, queries, datasets, data analysis |
| bigquery-table-cleaning | ~40 | BigQuery clean, profiling, nulls, types |
| branch-pr | ~30 | PR creation, issue-first, GitHub |
| canvas-design | ~35 | Poster, art, design artifact, visual composition |
| chained-pr | ~25 | Stacked PRs, review slices, oversized changes |
| cognitive-doc-design | ~30 | Design docs, cognitive load, RFCs, guides |
| comment-writer | ~20 | PR feedback, reviews, GitHub comments |
| customize-opencode | ~35 | OpenCode config, agents, skills, MCP |
| data-memory-governance | ~40 | SQL, BI, datasets, data catalog, governance |
| deploy-security-gate | ~25 | Predeploy, production, security gate |
| design-md | ~25 | Design system, DESIGN.md, UI patterns |
| engram-agent | ~20 | Engram memory, save, search, MCP |
| find-skills | ~25 | Discover, install, extend capabilities |
| flow-diagram | ~20 | ASCII diagrams, request flow |
| frontend-design | ~50 | Frontend UI, React, components, pages |
| go-testing | ~20 | Go tests, coverage, Bubbletea |
| graphify | ~20 | Knowledge graph, HTML, JSON, audit |
| hatch-pet | ~40 | Pets, spritesheets, character art, pet.json |
| issue-creation | ~25 | GitHub issues, bug reports, feature requests |
| judgment-day | ~20 | Dual review, adversarial, juzgar |
| sandbox-data-loader | ~35 | CSV/XLSX load, schema detect, PII check |
| sdd-apply | ~25 | Implement SDD tasks |
| sdd-archive | ~20 | Archive SDD changes |
| sdd-design | ~25 | SDD technical design |
| sdd-explore | ~25 | SDD exploration |
| sdd-init | ~20 | SDD init, bootstrap |
| sdd-onboard | ~25 | SDD onboarding, walkthrough |
| sdd-propose | ~25 | SDD change proposal |
| sdd-spec | ~20 | SDD delta specs |
| sdd-tasks | ~20 | SDD implementation tasks |
| sdd-verify | ~20 | SDD verification |
| skill-creator | ~25 | Create LLM-first skills |
| skill-improver | ~20 | Audit, upgrade skills |
| skill-registry | ~20 | Index skills by trigger |
| sql-learning | ~25 | SQL patterns, cleaning, rules |
| web-design-guidelines | ~35 | UI audit, accessibility, Vercel guidelines |
| work-unit-commits | ~25 | Commit planning, reviewable units |

**Tokens totales propuestos:** ~500–600 (ahorro ~400–600 tokens).

---

## 5. Estrategia de implementación

### Fase 1 (F2 — documento) ✅ COMPLETADO
- Este documento: auditoría completa y propuesta de compactación.
- Definir formato compacto de descripciones.

### Fase 2 (F3 — implementación)
- Editar el bloque `<available_skills>` en el system prompt.
- Reemplazar descripciones largas por trigger keywords.
- Si es posible, filtrar skills por proyecto activo.

### Fase 3 (validación)
- Verificar que el Manager puede identificar y cargar skills correctamente con descripciones cortas.
- Verificar que no hay falsos negativos en skill matching.
- Verificar reducción de tokens.

---

## 6. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Descripción muy corta no permite matching | Baja | Bajo | Manager puede invocar skill tool por nombre sin depender del bloque |
| Skill no se carga porque descripción no matcha | Baja | Medio | Manager puede usar skill tool directamente o pedir ayuda |
| Filtro por proyecto omite skill necesario | Baja | Bajo | Mantener lista completa como respaldo |
| Skills nuevos no se agregan al bloque compacto | Baja | Bajo | Actualización periódica del bloque |

---

## 7. Pruebas recomendadas

| Test | Qué validaría |
|:----:|---------------|
| P1 | Manager puede identificar skills correctamente con descripciones cortas |
| P2 | No hay falsos negativos en skill matching |
| P3 | Manager puede invocar skill por nombre directamente |
| P4 | Reducción de tokens verificable (de ~1,040 a ~500–600) |
| P5 | Skills específicos del proyecto se cargan correctamente |

---

## 8. Referencias

- F0: Baseline tokens → Available Skills block (~1,040 tokens)
- F1: Context Inventory → Available Skills (#7, COMPACT_FIXED)
- F1: Duplication Map → D4 (Skills block vs SKILL.md descriptions)
- F1: Quick Wins Analysis → QW#5 (Skills selectivos)
- F2: Context Budget Contract → L2 budgets
- F2: Context Packs Design → SKILLS_PACK

---

*Fin de skills-selective-loading-audit.md — F2 COMPLETED. Diseño de compactación de skills block para F3.*
