# Fase F Documentation Index

## Post-restart validation

- `F4B-F4C-post-restart-validation.md` — resultado PARTIAL: F4C runtime-validado, F4B pendiente compaction real.
- `F4B-real-compaction-validation.md` — validación final: no se observó compactación natural; F4B sigue PARTIAL.
- `F4B-contract-hardening.md` — hardening del contrato RECENT_SESSION_PACK y observabilidad segura; F4B sigue PARTIAL.

## Runtime implementation

- `F4B-session-history-compaction-implementation-report.md`
- `F4B-contract-hardening.md`
- `F4C-mem-context-selector-implementation-report.md`
- `recent-session-pack.template.md`

## Decisions and boundaries

- `F4A-skills-selective-loading-decision.md`
- `F4D-tool-schema-loading-prototype-plan.md`
- `F4E-manager-protocol-compaction-decision.md`
- `decision-log.md`
- `risk-register.md`

## Regression and rollout

- `F5A-regression-harness-upgrade.md`
- `F5B-regression-run-report.md`
- `F5C-token-savings-rebaseline.md`
- `F6A-controlled-rollout-plan.md`
- `F6B-executive-decision-package.md`

## Closure and backlog

- `F4B-natural-compaction-checklist.md` — checklist para validación de compactación real
- `F-phase-backlog.md` — backlog controlado de decisiones pendientes
- `F-next-decisions-matrix.md` — matriz ejecutiva de decisiones
- `F-phase-operational-closure-report.md` — reporte de cierre operacional

## F4A-lite implementation

- `F4A-lite-skills-audit.md` — auditoría de fuentes reales de `<available_skills>`.
- `F4A-lite-skills-compact-format.md` — formato compacto aplicado.
- `proposals/F4A-lite-opencode-skills-compact.proposal.md` — proposal aprobado.
- `F4A-lite-skills-selective-loading-implementation-report.md` — implementación, validaciones pre y post-restart. Estado: RUNTIME PASS.
- `F4A-lite-backup-manifest.md` — manifest de backups centralizados.
- `F-phase-final-closure-report.md` — cierre final. Fase F: CLOSED — PASS WITH WARNINGS.

## Manager Extensions Audit (Nueva)

Los siguientes documentos auditan la integración de gentle-ai y Ponytail en la arquitectura OpenCode, como preparación para el repo `proyecto-opencode-mem`. La integración Ponytail en AGENTS.md ya fue implementada como guidance documental; la fase Architecture README & Assurance Refresh no modifica runtime.

- `../../integrations/README.md` — índice de integraciones
- `../../integrations/manager-extension-map.md` — mapa comparativo de sistemas
- `../../integrations/gentle-ai-architecture-usage-audit.md` — auditoría de gentle-ai
- `../../integrations/ponytail-integration-audit.md` — auditoría de Ponytail
- `../../integrations/ponytail-manager-integration-proposal.md` — propuesta de integración (base de implementación)
- `../../integrations/ponytail-runtime-state-reconciliation.md` — estado real: AGENTS.md guidance implementado, plugin/skills no instalados
- `../../integrations/ponytail-post-restart-validation.md` — validación post-restart pendiente
- `../../integrations/sdd-subagents-runtime-inventory.md` — inventario de 10 subagentes SDD
- `../../integrations/sdd-init-role-spec.md` — rol de `sdd-init` v3.0
- `../../integrations/sdd-pipeline-flow.md` — flujo SDD completo
- `../../integrations/manager-sdd-test-plan.md` — tests Manager/SDD diseñados
- `../../integrations/SDD-RETURN-ENVELOPE-IMPLEMENTATION-PLAN.md` — plan para aplicar `SUBAGENT_RESULT` en templates
- `../../integrations/GPT-5.5-FALLBACK-PLAN.md` — fallback review/debug
- `../../integrations/MANAGER-TINY-AMBIGUITY-GUARD.md` — regla de ambigüedad Tiny/Small
- `../../integrations/gentle-ai-boundary-test-plan.md` — tests de boundary para gentle-ai
- `../../integrations/ponytail-integration-test-plan.md` — tests de integración para Ponytail
- `../../integrations/manager-extension-decision-package.md` — paquete de decisión ejecutiva
- `../../export-readiness/MANAGER-EXTENSIONS-EXPORT-PLAN.md` — plan de exportación al nuevo repo

## Architecture README & Assurance Refresh

- `../../README-ARCHITECTURE-ASSURANCE-REFRESH-PLAN.md` — plan/auditoría del refresh del README maestro.
- `../../ARCHITECTURE-ASSURANCE-REPORT.md` — assurance report con Go/No-Go y gaps antes de `proyecto-opencode-mem`.
- `../../../README.md` — README maestro actualizado.

## Pre-Runtime Kit Readiness Gate

- `../../export-readiness/PRE-RUNTIME-KIT-READINESS-GATE.md` — gate final must/should/can/defer antes del repo nuevo.
- `../../export-readiness/PRE-RUNTIME-KIT-READINESS-REPORT.md` — reporte final PASS WITH WARNINGS y GO CONTROLADO.
- `../../export-readiness/PORTABILITY-MAP.md` — sanitización de paths absolutos.
- `../../export-readiness/OPENCODE-CONFIG-TEMPLATE-SPEC.md` — spec de config template portable.
- `../../../scripts/manager-sdd-assurance.ps1` — harness read-only Manager/SDD.

