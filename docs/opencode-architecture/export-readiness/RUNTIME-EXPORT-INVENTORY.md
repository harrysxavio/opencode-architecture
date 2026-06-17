# Runtime Export Inventory

**Fecha:** 2026-06-17  
**Propósito:** Inventario completo de todos los componentes del sistema con su estado de exportabilidad.

---

## Componentes

| # | Componente | Ruta actual | Tipo | ¿Exportable? | ¿Requiere sanitización? | Riesgo | Destino sugerido | Test necesario |
|---|---|---|---|---|---|---|---|---|
| 1 | Manager agent | `~/.config/opencode/AGENTS.md` + system prompt | Agent | ✅ Sí | Sí — rutas personales en ejemplos | 🟢 Bajo | `agents/manager/SKILL.md` + `templates/AGENTS.md` | Validar frontmatter |
| 2 | SDD Explore | `~/.codex/skills/sdd-explore/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-explore/SKILL.md` | Body hash invariante |
| 3 | SDD Propose | `~/.codex/skills/sdd-propose/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-propose/SKILL.md` | Body hash invariante |
| 4 | SDD Spec | `~/.codex/skills/sdd-spec/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-spec/SKILL.md` | Body hash invariante |
| 5 | SDD Design | `~/.codex/skills/sdd-design/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-design/SKILL.md` | Body hash invariante |
| 6 | SDD Tasks | `~/.codex/skills/sdd-tasks/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-tasks/SKILL.md` | Body hash invariante |
| 7 | SDD Apply | `~/.codex/skills/sdd-apply/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-apply/SKILL.md` | Body hash invariante |
| 8 | SDD Verify | `~/.codex/skills/sdd-verify/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-verify/SKILL.md` | Body hash invariante |
| 9 | SDD Archive | `~/.codex/skills/sdd-archive/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-archive/SKILL.md` | Body hash invariante |
| 10 | SDD Init | `~/.codex/skills/sdd-init/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-init/SKILL.md` | Body hash invariante |
| 11 | SDD Onboard | `~/.codex/skills/sdd-onboard/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sdd-onboard/SKILL.md` | Body hash invariante |
| 12 | Engram Agent | `~/.codex/skills/engram-agent/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/engram-agent/SKILL.md` | Body hash invariante |
| 13 | Hatch Pet | `~/.codex/skills/hatch-pet/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/hatch-pet/SKILL.md` | Body hash invariante |
| 14 | Judgment Day | `~/.codex/skills/judgment-day/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/judgment-day/SKILL.md` | Body hash invariante |
| 15 | Skill Creator | `~/.codex/skills/skill-creator/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/skill-creator/SKILL.md` | Body hash invariante |
| 16 | Skill Improver | `~/.codex/skills/skill-improver/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/skill-improver/SKILL.md` | Body hash invariante |
| 17 | Skill Registry | `~/.codex/skills/skill-registry/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/skill-registry/SKILL.md` | Body hash invariante |
| 18 | Work Unit Commits | `~/.codex/skills/work-unit-commits/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/work-unit-commits/SKILL.md` | Body hash invariante |
| 19 | Branch PR | `~/.codex/skills/branch-pr/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/branch-pr/SKILL.md` | Body hash invariante |
| 20 | Chained PR | `~/.codex/skills/chained-pr/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/chained-pr/SKILL.md` | Body hash invariante |
| 21 | Issue Creation | `~/.codex/skills/issue-creation/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/issue-creation/SKILL.md` | Body hash invariante |
| 22 | Cognitive Doc Design | `~/.codex/skills/cognitive-doc-design/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/cognitive-doc-design/SKILL.md` | Body hash invariante |
| 23 | Comment Writer | `~/.codex/skills/comment-writer/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/comment-writer/SKILL.md` | Body hash invariante |
| 24 | Go Testing | `~/.codex/skills/go-testing/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/go-testing/SKILL.md` | Body hash invariante |
| 25 | BigQuery Expert | `~\.agents\skills\bigquery-expert\SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/bigquery-expert/SKILL.md` | Body hash invariante |
| 26 | Frontend Design | `~\OneDrive\Documentos\GitHub\Tools\.agents\skills\frontend-design\SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/frontend-design/SKILL.md` | Body hash invariante |
| 27 | Data Memory Governance | `~\OneDrive\Documentos\GitHub\Tools\.agents\skills\data-memory-governance\SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/data-memory-governance/SKILL.md` | Body hash invariante |
| 28 | Find Skills | `~\OneDrive\Documentos\GitHub\Tools\.agents\skills\find-skills\SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/find-skills/SKILL.md` | Body hash invariante |
| 29 | Canvas Design | `~/.config/opencode/skills/canvas-design/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/canvas-design/SKILL.md` | Body hash invariante |
| 30 | Design MD | `~/.config/opencode/skills/design-md/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/design-md/SKILL.md` | Body hash invariante |
| 31 | Web Design Guidelines | `~/.config/opencode/skills/web-design-guidelines/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/web-design-guidelines/SKILL.md` | Body hash invariante |
| 32 | Sandbox Data Loader | `~/.config/opencode/skills/sandbox-data-loader/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sandbox-data-loader/SKILL.md` | Body hash invariante |
| 33 | BigQuery Table Cleaning | `~/.config/opencode/skills/bigquery-table-cleaning/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/bigquery-table-cleaning/SKILL.md` | Body hash invariante |
| 34 | SQL Learning | `~/.config/opencode/skills/sql-learning/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/sql-learning/SKILL.md` | Body hash invariante |
| 35 | Flow Diagram | `~/.config/opencode/skills/flow-diagram/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/flow-diagram/SKILL.md` | Body hash invariante |
| 36 | Deploy Security Gate | `~/.config/opencode/skills/deploy-security-gate/SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/deploy-security-gate/SKILL.md` | Body hash invariante |
| 37 | Graphify | `~\.agents\skills\graphify\SKILL.md` | Skill | ✅ Sí | No | 🟢 Bajo | `skills/graphify/SKILL.md` | Body hash invariante |
| 38 | Engram plugin | `~/.config/opencode/plugins/engram.ts` | Plugin | ⚠️ Template | Sí — paths, username, config | 🟡 Medio | `plugins/engram.template.ts` | Compilar + validar hooks |
| 39 | F4C Selector guidance | `engram.ts` (embedded) | Plugin guidance | ✅ Sí | Sí — extraer a template | 🟢 Bajo | `docs/selector-guidance.md` + `plugins/selector.template.ts` | Test de sistema transform |
| 40 | F4B Compaction contract | `engram.ts` (embedded) | Plugin guidance | ✅ Sí | Sí — extraer a template | 🟢 Bajo | `docs/compaction-contract.md` + `plugins/compaction.template.ts` | Test de compactación |
| 41 | Noise Gate | `engram.ts` (embedded) | Plugin guidance | ✅ Sí | Sí — extraer a template | 🟢 Bajo | `docs/noise-gate.md` + `plugins/noise-gate.template.ts` | Test de filtros |
| 42 | Regression harness | `scripts/F-regression-harness.ps1` | Script | ✅ Sí | Sí — rutas de proyecto | 🟢 Bajo | `scripts/regression-harness.ps1` | Ejecución exitosa |
| 43 | Backup scripts | (varios scripts .ps1) | Script | ✅ Sí | Sí — rutas personales | 🟢 Bajo | `scripts/backup/` | Validar paths relativos |
| 44 | Fase F docs | `docs/opencode-architecture/phases/F-token-reduction/` | Doc | ✅ Sí | Sí — rutas personales en ejemplos | 🟢 Bajo | `docs/` | Ninguno |
| 45 | Manager Protocol | (embedded in system prompt) | Doc | ✅ Sí | Sí — ejemplos con rutas | 🟢 Bajo | `docs/manager-protocol.md` | Ninguno |
| 46 | Engram memory rules | (embedded in system prompt + engram.ts) | Doc | ✅ Sí | No | 🟢 Bajo | `docs/memory-rules.md` | Ninguno |
| 47 | SDD agent definitions | `opencode.json` (implicit) | Config | ⚠️ Template | Sí — copia anonimizada | 🟡 Medio | `templates/opencode.example.json` | Validar schema |
| 48 | opencode.json (real) | `~/.config/opencode/opencode.json` | Config | ❌ No | Contiene config runtime personal | 🔴 Alto | No exportar | — |
| 49 | Engram DB | `~/.engram/engram.db` | Memory | ❌ No | Datos personales, decisiones | 🔴 Crítico | No exportar | — |
| 50 | Backups F4A-lite | `~/.config/opencode/backups/f4a-lite-skills-20260617/` | Backup | ❌ No | Paths absolutos, backup local | 🟡 Medio | No exportar; regenerar desde manifest | — |
| 51 | .codex/memories_1.sqlite | `~/.codex/memories_1.sqlite` | Memory | ❌ No | Datos legacy personales | 🔴 Crítico | No exportar | — |
| 52 | Decision log | `docs/.../decision-log.md` | Doc | ✅ Sí | Sí — referencias a paths personales | 🟢 Bajo | `docs/decision-log.md` | Ninguno |
| 53 | Risk register | `docs/.../risk-register.md` | Doc | ✅ Sí | Sí — referencias a contexto local | 🟢 Bajo | `docs/risk-register.md` | Ninguno |

---

## Resumen

| Categoría | Cantidad | Exportable |
|---|---|---|
| Skills (SKILL.md) | 37 | ✅ 37/37 exportables |
| Plugins (engram.ts) | 1 | ⚠️ Template sanitizado |
| Scripts | 2-5 | ✅ Con sanitización de rutas |
| Docs | 50+ | ✅ Con sanitización de ejemplos |
| Config real | 1 | ❌ No exportar |
| DB real | 2 | ❌ No exportar |
| Backups | 1 | ❌ No exportar; regenerables |

**Total exportable:** ~90% del sistema puede compartirse con sanitización adecuada.
