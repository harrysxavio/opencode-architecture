# Documentation Index

## Quick entry points

| Need | Start here |
|---|---|
| Project overview | `README.md` |
| Fase F token reduction | `docs/opencode-architecture/phases/F-token-reduction/README.md` |
| Fase F index | `docs/opencode-architecture/phases/F-token-reduction/DOCUMENTATION-INDEX.md` |
| Decisions | `docs/opencode-architecture/phases/F-token-reduction/decision-log.md` |
| Risks | `docs/opencode-architecture/phases/F-token-reduction/risk-register.md` |
| Rollout | `docs/opencode-architecture/phases/F-token-reduction/F6A-controlled-rollout-plan.md` |
| Executive package | `docs/opencode-architecture/phases/F-token-reduction/F6B-executive-decision-package.md` |
| Post-restart validation | `docs/opencode-architecture/phases/F-token-reduction/F4B-F4C-post-restart-validation.md` |
| Final F4B compaction validation | `docs/opencode-architecture/phases/F-token-reduction/F4B-real-compaction-validation.md` |
| F4B contract hardening | `docs/opencode-architecture/phases/F-token-reduction/F4B-contract-hardening.md` |
| F4B natural compaction checklist | `docs/opencode-architecture/phases/F-token-reduction/F4B-natural-compaction-checklist.md` |
| Fase F backlog | `docs/opencode-architecture/phases/F-token-reduction/F-phase-backlog.md` |
| Decision matrix | `docs/opencode-architecture/phases/F-token-reduction/F-next-decisions-matrix.md` |
| Operational closure | `docs/opencode-architecture/phases/F-token-reduction/F-phase-operational-closure-report.md` |
| Final closure (CLOSED — PASS WITH WARNINGS) | `docs/opencode-architecture/phases/F-token-reduction/F-phase-final-closure-report.md` |

## Fase F current artifacts

- `F4B-session-history-compaction-implementation-report.md`
- `F4B-contract-hardening.md`
- `F4C-mem-context-selector-implementation-report.md`
- `F4A-skills-selective-loading-decision.md` — F4A-full vs F4A-lite distinction
- `F4D-tool-schema-loading-prototype-plan.md`
- `F4E-manager-protocol-compaction-decision.md`
- `F5A-regression-harness-upgrade.md`
- `F5B-regression-run-report.md`
- `F5C-token-savings-rebaseline.md`
- `F6A-controlled-rollout-plan.md`
- `F6B-executive-decision-package.md`
- `autonomous-F4-F6-report.md`
- `F4B-natural-compaction-checklist.md`
- `F-phase-backlog.md`
- `F-next-decisions-matrix.md`
- `F-phase-operational-closure-report.md`
- `F-phase-final-closure-report.md`
- `F4A-lite-skills-selective-loading-implementation-report.md`
- `F4A-lite-backup-manifest.md`
- `F4A-lite-skills-audit.md`
- `F4A-lite-skills-compact-format.md`
- `F4A-skills-trigger-matrix.md`

## Export Readiness (senior closing phase)

- `docs/opencode-architecture/export-readiness/EXPORT-READINESS-REPORT.md` — qué es compartible y qué no.
- `docs/opencode-architecture/export-readiness/RUNTIME-EXPORT-INVENTORY.md` — inventario completo de 53 componentes.
- `docs/opencode-architecture/export-readiness/SHAREABLE-REPO-BLUEPRINT.md` — diseño del repo `opencode-agent-runtime-kit`.
- `docs/opencode-architecture/export-readiness/SANITIZATION-CHECKLIST.md` — checklist para sanitizar antes de publicar.
- `docs/opencode-architecture/export-readiness/SHAREABLE-TEST-STRATEGY.md` — estrategia de 19 tests para el nuevo repo.
- `docs/opencode-architecture/export-readiness/NEW-REPO-MIGRATION-PLAN.md` — plan de migración en 10 fases.
- `docs/opencode-architecture/export-readiness/EXPORT-DECISION-PACKAGE.md` — recomendación ejecutiva.
- `docs/opencode-architecture/export-readiness/EXPORT-READINESS-FINAL-REPORT.md` — reporte final de cierre.

## F4A-lite current implementation (RUNTIME PASS)

- `docs/opencode-architecture/phases/F-token-reduction/F4A-lite-skills-selective-loading-implementation-report.md` — implementación + validación post-restart. Estado: RUNTIME PASS.
- `docs/opencode-architecture/phases/F-token-reduction/F4A-lite-backup-manifest.md` — backups centralizados con manifest.
- `docs/opencode-architecture/phases/F-token-reduction/F4A-lite-skills-audit.md` — auditoría de fuentes reales de `<available_skills>`.
- `docs/opencode-architecture/phases/F-token-reduction/F4A-lite-skills-compact-format.md` — formato compacto aplicado.
- `docs/opencode-architecture/phases/F-token-reduction/F-phase-final-closure-report.md` — cierre final. Fase F: CLOSED — PASS WITH WARNINGS.

## Manager Extensions Audit (Implementada)

Auditoría de integración de gentle-ai y Ponytail en la arquitectura OpenCode, como preparación para el repo `proyecto-opencode-mem`.

**Ponytail Code Gate → ✅ IMPLEMENTADO en AGENTS.md.**

- `docs/opencode-architecture/integrations/README.md` — índice de integraciones
- `docs/opencode-architecture/integrations/manager-extension-map.md` — mapa comparativo de sistemas
- `docs/opencode-architecture/integrations/gentle-ai-architecture-usage-audit.md` — auditoría de gentle-ai
- `docs/opencode-architecture/integrations/ponytail-integration-audit.md` — auditoría de Ponytail
- `docs/opencode-architecture/integrations/ponytail-manager-integration-proposal.md` — propuesta de integración (base de implementación)
- `docs/opencode-architecture/integrations/ponytail-runtime-implementation-report.md` — reporte de implementación runtime
- `docs/opencode-architecture/integrations/gentle-ai-activation-policy.md` — política de activación alignment-only
- `docs/opencode-architecture/integrations/gentle-ai-boundary-test-plan.md` — tests de boundary para gentle-ai
- `docs/opencode-architecture/integrations/ponytail-integration-test-plan.md` — tests de integración para Ponytail
- `docs/opencode-architecture/integrations/manager-extension-decision-package.md` — paquete de decisión ejecutiva (actualizado post-implementación)
- `docs/opencode-architecture/export-readiness/MANAGER-EXTENSIONS-EXPORT-PLAN.md` — plan de exportación al nuevo repo
