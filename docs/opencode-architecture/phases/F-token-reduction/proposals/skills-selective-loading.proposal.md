# Proposal: Skills Selective Loading (QW#5)

**Estado:** 📋 PROPUESTA — lista para implementación con aprobación  
**Ahorro estimado:** ~1,184 tokens  
**Riesgo:** 🟢 Bajo  
**Tiempo de implementación:** ~15 minutos  
**Dependencias:** Ninguna

---

## Resumen

Reemplazar las descripciones de los 38 skills en el bloque `<available_skills>` de ~15–50 palabras a ~5–10 keywords. El cambio es puramente textual — no afecta la funcionalidad de los skills.

---

## Plan de implementación

### Paso 1: Backup

```powershell
# Backup all SKILL.md files before modifying
$backupDir = "C:\Users\harry\OneDrive\Documentos\GitHub\opencode-architecture\backups\skills-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force

# Backup .codex skills
Copy-Item "C:\Users\harry\.codex\skills\*\SKILL.md" $backupDir -Recurse -ErrorAction SilentlyContinue
# Backup .config skills
Copy-Item "C:\Users\harry\.config\opencode\skills\*\SKILL.md" $backupDir -Recurse -ErrorAction SilentlyContinue
# Backup Tools skills
Copy-Item "C:\Users\harry\OneDrive\Documentos\GitHub\Tools\.agents\skills\*\SKILL.md" $backupDir -Recurse -ErrorAction SilentlyContinue

Write-Host "Backup created at: $backupDir"
```

### Paso 2: Modificar descripciones

Para cada SKILL.md, reemplazar el campo `description:` en el frontmatter YAML con la versión compacta.

**Formato del frontmatter:**
```yaml
---
name: skill-name
description: "keyword1, keyword2, keyword3"
---
```

### Paso 3: Verificar

```powershell
# Run regression harness to confirm skills are still accessible
& ".\scripts\F-regression-harness.ps1"
```

### Paso 4: Medir ahorro real

```powershell
# Count total description characters before and after
$skills = Get-ChildItem "C:\Users\harry\.codex\skills\*\SKILL.md", 
                        "C:\Users\harry\.config\opencode\skills\*\SKILL.md",
                        "C:\Users\harry\OneDrive\Documentos\GitHub\Tools\.agents\skills\*\SKILL.md"
$totalBefore = 7082
$totalAfter = 0
foreach ($s in $skills) {
    $content = Get-Content $s.FullName -Raw
    if ($content -match 'description:\s*"(.*?)"') {
        $totalAfter += $matches[1].Length
    }
}
Write-Host "Before: ~$($totalBefore) chars (~$([math]::Round($totalBefore/4)) tokens)"
Write-Host "After:  ~$totalAfter chars (~$([math]::Round($totalAfter/4)) tokens)"
Write-Host "Saved:  ~$($totalBefore - $totalAfter) chars (~$([math]::Round(($totalBefore - $totalAfter)/4)) tokens)"
```

---

## Rollback

```powershell
# Restore from backup
Copy-Item "$backupDir\*" "C:\Users\harry\.codex\skills\" -Recurse -Force
Copy-Item "$backupDir\*" "C:\Users\harry\.config\opencode\skills\" -Recurse -Force
Copy-Item "$backupDir\*" "C:\Users\harry\OneDrive\Documentos\GitHub\Tools\.agents\skills\" -Recurse -Force
Write-Host "Rollback complete — original descriptions restored"
```

---

## Diferencias (antes → después)

| Skill | Antes (chars) | Después (chars) | Ahorro (chars) | Ahorro (tokens est.) |
|:------|:-------------:|:---------------:|:--------------:|:--------------------:|
| _shared | 58 | 37 | 21 | ~5 |
| bigquery-expert | 367* | 67 | 300 | ~75 |
| bigquery-table-cleaning | 134 | 63 | 71 | ~18 |
| branch-pr | 112 | 42 | 70 | ~18 |
| canvas-design | 307 | 70 | 237 | ~59 |
| chained-pr | 124 | 51 | 73 | ~18 |
| cognitive-doc-design | 128 | 54 | 74 | ~19 |
| comment-writer | 124 | 59 | 65 | ~16 |
| data-memory-governance | 236 | 57 | 179 | ~45 |
| deploy-security-gate | 128 | 62 | 66 | ~17 |
| design-md | 227 | 66 | 161 | ~40 |
| engram-agent | 109 | 61 | 48 | ~12 |
| find-skills | 303 | 52 | 251 | ~63 |
| flow-diagram | 147 | 52 | 95 | ~24 |
| frontend-design | 399 | 74 | 325 | ~81 |
| go-testing | 104 | 51 | 53 | ~13 |
| hatch-pet | 563* | 58 | 505 | ~126 |
| issue-creation | 115 | 44 | 71 | ~18 |
| judgment-day | 123 | 45 | 78 | ~20 |
| sandbox-data-loader | 303 | 68 | 235 | ~59 |
| sdd-apply | 109 | 41 | 68 | ~17 |
| sdd-archive | 132 | 42 | 90 | ~23 |
| sdd-design | 110 | 46 | 64 | ~16 |
| sdd-explore | 121 | 58 | 63 | ~16 |
| sdd-init | 119 | 59 | 60 | ~15 |
| sdd-onboard | 123 | 54 | 69 | ~17 |
| sdd-propose | 122 | 48 | 74 | ~19 |
| sdd-spec | 109 | 47 | 62 | ~16 |
| sdd-tasks | 105 | 43 | 62 | ~16 |
| sdd-verify | 120 | 53 | 67 | ~17 |
| skill-creator | 119 | 46 | 73 | ~18 |
| skill-improver | 115 | 43 | 72 | ~18 |
| skill-registry | 123 | 42 | 81 | ~20 |
| sql-learning | 297 | 50 | 247 | ~62 |
| web-design-guidelines | 228 | 57 | 171 | ~43 |
| work-unit-commits | 131 | 51 | 80 | ~20 |

*\*Algunos skills en Tools/.agents no tenían description en frontmatter; se usó la descripción generada por OpenCode como referencia.*

---

## Descripciones compactas propuestas

| Skill | Descripción compacta |
|:------|:---------------------|
| _shared | Shared SDD references. Not invokable. |
| bigquery-expert | BigQuery SQL, queries, datasets, tables, analysis, reports, metrics |
| bigquery-table-cleaning | BigQuery clean, profiling, nulls, types, catalogs, _clean table |
| branch-pr | GitHub PR creation with issue-first checks |
| canvas-design | Poster, art, canvas, visual composition, design philosophy, mood board |
| chained-pr | Stacked PRs, review slices, split oversized changes |
| cognitive-doc-design | Design docs, cognitive load, READMEs, RFCs, onboarding |
| comment-writer | PR feedback, issue replies, reviews, collaboration comments |
| customize-opencode | opencode.json, .opencode/, agents, subagents, skills, plugins, MCP |
| data-memory-governance | SQL, BI, BigQuery, Sheets, CSV, APIs, KPIs, data catalogs |
| deploy-security-gate | Predeploy, deploy, production, Hostinger, VPS, webapp security |
| design-md | Design system, DESIGN.md, design tokens, UI patterns, design audit |
| engram-agent | Engram persistent memory, save, search, cross-session context |
| find-skills | Discover skills, install skills, extend capabilities |
| flow-diagram | Flow diagrams, ASCII diagrams, executed request flow |
| frontend-design | Frontend interfaces, UI design, React, HTML/CSS, landing pages |
| go-testing | Go tests, coverage, Bubbletea teatest, golden files |
| graphify | Knowledge graph, communities, HTML, JSON, audit report |
| hatch-pet | Codex animated pets, spritesheets, character art, pet.json |
| issue-creation | GitHub issues, bug reports, feature requests |
| judgment-day | Dual review, adversarial review, blind review |
| sandbox-data-loader | Carga CSV/XLSX, sandbox, schema, PII, BigQuery |
| sdd-apply | Implement SDD tasks from specs and design |
| sdd-archive | Archive completed SDD changes, delta specs |
| sdd-design | SDD technical design and architecture approach |
| sdd-explore | SDD exploration, idea discovery, requirement clarification |
| sdd-init | SDD init, bootstrap context, testing capabilities, registry |
| sdd-onboard | SDD onboarding, walk through workflow on real codebase |
| sdd-propose | SDD change proposal with intent, scope, approach |
| sdd-spec | SDD delta specs with requirements and scenarios |
| sdd-tasks | Break SDD changes into implementation tasks |
| sdd-verify | SDD verification, execute tests, prove implementation |
| skill-creator | Create LLM-first skills with valid frontmatter |
| skill-improver | Audit and upgrade existing LLM-first skills |
| skill-registry | Index available skills by trigger and path |
| sql-learning | Patrones SQL, limpieza, errores, reglas de negocio |
| web-design-guidelines | UI audit, accessibility, design review, Vercel guidelines |
| work-unit-commits | Commit planning, reviewable work units, chained PRs |

---

## Tests esperados

| Test | Descripción | Método |
|:----|:------------|:-------|
| T1 | Skills siguen cargables por nombre | `skill("sdd-design")` debe funcionar |
| T2 | No hay falsos negativos en matching | Manager reconoce triggers |
| T3 | Ahorro real ≥ 1,000 tokens | Medición con tiktoken |
| T4 | Rollback funciona | Restaurar backup y verificar descripciones originales |
| T5 | Regression harness no se rompe | `scripts/F-regression-harness.ps1` debe seguir PASS |

---

*Fin de proposal — Skills Selective Loading (QW#5)*
