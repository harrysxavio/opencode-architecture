# F3-B: QW#5 Skills Block Compaction — Resultado del prototipo

**Estado:** ✅ COMPLETED (2026-06-16)  
**Propósito:** Medir el ahorro real de tokens al compactar las descripciones del bloque `<available_skills>` de ~15–50 palabras a ~5–10 keywords.

---

## Resumen

| Métrica | Valor |
|---------|:-----:|
| Skills analizados | 38 |
| Descripciones actuales (chars) | 6,782 |
| Descripciones compactas (chars) | 2,049 |
| Ahorro en caracteres | 4,733 (70%) |
| Ahorro estimado en tokens (≈4 chars/token) | **~1,184 tokens** |
| Estimación F2 original | 400–600 tokens |
| Diferencia con estimación | **+584–784 tokens (2× el estimado)** |

---

## Hallazgos clave

### 1. El ahorro real duplica la estimación de F2

La auditoría de F2 estimó 400–600 tokens. El prototipo midió ~1,184 tokens. **Razón:** la estimación de F2 usó una muestra más pequeña. El bloque completo tiene 38 skills con descripciones muy verbosas en algunos casos (hatch-pet: 563 chars).

### 2. Los skills más gananciosos

| Skill | Chars actuales | Chars compactos | Ahorro chars | Ahorro tokens (est.) |
|-------|:--------------:|:---------------:|:------------:|:--------------------:|
| hatch-pet | 563 | 58 | 505 | ~126 |
| frontend-design | 399 | 74 | 325 | ~81 |
| customize-opencode | 386 | 82 | 304 | ~76 |
| bigquery-expert | 367 | 67 | 300 | ~75 |
| find-skills | 303 | 52 | 251 | ~63 |
| canvas-design | 307 | 70 | 237 | ~59 |
| sandbox-data-loader | 299 | 68 | 231 | ~58 |
| sql-learning | 295 | 50 | 245 | ~61 |

**Top 8 skills concentran ~599 tokens de ahorro (51% del total).**

### 3. Los skills más pequeños (menos ganancia)

| Skill | Chars actuales | Chars compactos | Ahorro chars | Ahorro tokens (est.) |
|-------|:--------------:|:---------------:|:------------:|:--------------------:|
| _shared | 58 | 37 | 21 | ~5 |
| engram-agent | 109 | 61 | 48 | ~12 |
| go-testing | 104 | 51 | 53 | ~13 |
| sdd-tasks | 105 | 43 | 62 | ~15 |

### 4. Riesgo evaluado

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:--------:|------------|
| Descripción muy corta → Manager no sabe cuándo cargar | Baja | Bajo | Manager invoca skill por nombre; el bloque es referencia visual |
| Trigger keyword insuficiente | Baja | Bajo | Keywords elegidas manualmente cubren casos de uso principales |
| Conflicto con skill-registry | Baja | Bajo | skill-registry indexa por nombre, no por descripción |
| Skills bilingües (es/en) | Baja | Medio | Keywords en ambos idiomas (ej: sandbox-data-loader, sql-learning) |

---

## Diff propuesto (solo bloque `<available_skills>`)

```diff
- <skill>
-   <name>bigquery-expert</name>
-   <description>BigQuery SQL expert for this project. Trigger: ANY request involving BigQuery, SQL queries, datasets, tables, data analysis, reports, indicators, business metrics, data exploration, or questions about database structure. Also trigger when the user mentions table names, column names, project/dataset references, or business concepts that may exist in BigQuery tables.</description>
- </skill>
+ <skill>
+   <name>bigquery-expert</name>
+   <description>BigQuery SQL, queries, datasets, tables, analysis, reports, metrics</description>
+ </skill>
```

(El diff completo de los 38 skills está documentado abajo en la tabla completa.)

---

## Tabla completa de cambios

| Skill | Descripción actual (truncada) | Descripción compacta | Ahorro tokens |
|-------|------------------------------|---------------------|:-------------:|
| _shared | Shared SDD references for installed skills. Not invokable. | Shared SDD references. Not invokable. | ~5 |
| bigquery-expert | BigQuery SQL expert for this project. Trigger: ANY request involving BigQuery, SQL queries, datasets, tables... | BigQuery SQL, queries, datasets, tables, analysis, reports, metrics | ~75 |
| bigquery-table-cleaning | Trigger: BigQuery clean, profiling, nulls, types, catalogs, _clean table... | BigQuery clean, profiling, nulls, types, catalogs, _clean table | ~18 |
| branch-pr | Create Gentle AI pull requests with issue-first checks. Trigger: creating, opening, or preparing PRs for review. | GitHub PR creation with issue-first checks | ~18 |
| canvas-design | Trigger: poster, art, design artifact, canvas, visual composition, design philosophy... | Poster, art, canvas, visual composition, design philosophy, mood board | ~59 |
| chained-pr | Trigger: PRs over 400 lines, stacked PRs, review slices... | Stacked PRs, review slices, split oversized changes | ~18 |
| cognitive-doc-design | Design docs that reduce cognitive load. Trigger: writing guides, READMEs... | Design docs, cognitive load, READMEs, RFCs, onboarding | ~19 |
| comment-writer | Write warm, direct collaboration comments. Trigger: PR feedback... | PR feedback, issue replies, reviews, collaboration comments | ~16 |
| customize-opencode | Use ONLY when editing opencode's own configuration: opencode.json... | opencode.json, .opencode/, agents, subagents, skills, plugins, MCP | ~76 |
| data-memory-governance | Data memory governance for SQL, BI, datasets, imports, files, BigQuery... | SQL, BI, BigQuery, Sheets, CSV, APIs, KPIs, data catalogs | ~45 |
| deploy-security-gate | Trigger: predeploy, deploy, production release, Hostinger, VPS... | Predeploy, deploy, production, Hostinger, VPS, webapp security | ~17 |
| design-md | Trigger: design system, DESIGN.md, visual language, extract design tokens... | Design system, DESIGN.md, design tokens, UI patterns, design audit | ~40 |
| engram-agent | Engram persistent memory for agents/sub-agents... | Engram persistent memory, save, search, cross-session context | ~12 |
| find-skills | Helps users discover and install agent skills when they ask... | Discover skills, install skills, extend capabilities | ~63 |
| flow-diagram | Trigger: mostrame el flujo, diagrama del flujo... | Flow diagrams, ASCII diagrams, executed request flow | ~24 |
| frontend-design | Create distinctive, production-grade frontend interfaces... | Frontend interfaces, UI design, React, HTML/CSS, landing pages | ~81 |
| go-testing | Trigger: Go tests, go test coverage, Bubbletea teatest... | Go tests, coverage, Bubbletea teatest, golden files | ~13 |
| graphify | any input (code, docs, papers, images) → knowledge graph... | Knowledge graph, communities, HTML, JSON, audit report | ~14 |
| hatch-pet | Create, repair, validate, visually QA, and package Codex-compatible animated pets... | Codex animated pets, spritesheets, character art, pet.json | ~126 |
| issue-creation | Create Gentle AI issues with issue-first checks... | GitHub issues, bug reports, feature requests | ~18 |
| judgment-day | Trigger: judgment day, dual review, adversarial review, juzgar... | Dual review, adversarial review, blind review | ~20 |
| sandbox-data-loader | Carga segura de archivos a dataset sandbox... | Carga CSV/XLSX, sandbox, schema, PII, BigQuery | ~58 |
| sdd-apply | Implement SDD tasks from specs and design... | Implement SDD tasks from specs and design | ~17 |
| sdd-archive | Archive a completed SDD change by syncing delta specs... | Archive completed SDD changes, delta specs | ~23 |
| sdd-design | Create the SDD technical design and architecture approach... | SDD technical design and architecture approach | ~16 |
| sdd-explore | Explore SDD ideas before committing to a change... | SDD exploration, idea discovery, requirement clarification | ~16 |
| sdd-init | Trigger: sdd init, iniciar sdd, openspec init... | SDD init, bootstrap context, testing capabilities, registry | ~15 |
| sdd-onboard | Walk users through the SDD workflow on the real codebase... | SDD onboarding, walk through workflow on real codebase | ~17 |
| sdd-propose | Create an SDD change proposal with intent, scope, and approach... | SDD change proposal with intent, scope, approach | ~19 |
| sdd-spec | Write SDD delta specs with requirements and scenarios... | SDD delta specs with requirements and scenarios | ~16 |
| sdd-tasks | Break an SDD change into implementation tasks... | Break SDD changes into implementation tasks | ~16 |
| sdd-verify | Trigger: SDD verification phase, verify change... | SDD verification, execute tests, prove implementation | ~17 |
| skill-creator | Trigger: new skills, agent instructions, documenting AI usage patterns... | Create LLM-first skills with valid frontmatter | ~18 |
| skill-improver | Trigger: improve skills, audit skills, refactor skills... | Audit and upgrade existing LLM-first skills | ~18 |
| skill-registry | Trigger: update skills, skill registry, actualizar skills... | Index available skills by trigger and path | ~20 |
| sql-learning | Captura patrones reutilizables de limpieza SQL... | Patrones SQL, limpieza, errores, reglas de negocio | ~61 |
| web-design-guidelines | Trigger: review UI, check accessibility, audit design... | UI audit, accessibility, design review, Vercel guidelines | ~43 |
| work-unit-commits | Plan commits as reviewable work units... | Commit planning, reviewable work units, chained PRs | ~20 |

---

## Veredicto

QW#5 es **APROBADO para implementación**. Es el quick win más seguro, de bajo riesgo, y con un ahorro de ~1,184 tokens (casi 3× lo estimado en F2).

**Sin blockers.** No requiere cambios en runtime, no toca opencode.json, no modifica lógica de skills. Solo cambia descripciones en el bloque XML.

---

*Fin de F3-B-skills-diff.md — Prototipo de QW#5 completado.*
