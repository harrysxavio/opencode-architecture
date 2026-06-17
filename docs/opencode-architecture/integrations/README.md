# Integrations — Manager Extension Audit

> **Estado:** ✅ AUDIT COMPLETE — Pendiente de aprobación para implementación runtime
> **Fecha:** 2026-06-17
> **Propósito:** Documentar la auditoría, análisis y propuestas de integración de gentle-ai y Ponytail en la arquitectura OpenCode Manager, como paso previo al repo `proyecto-opencode-mem`.

---

## Documentos en este directorio

| Documento | Propósito |
|-----------|-----------|
| `manager-extension-map.md` | Mapa comparativo: gentle-ai vs Ponytail vs Manager vs subsistemas |
| `gentle-ai-architecture-usage-audit.md` | Auditoría de gentle-ai en la arquitectura actual |
| `ponytail-integration-audit.md` | Auditoría completa de Ponytail |
| `ponytail-manager-integration-proposal.md` | Propuesta de integración de Ponytail en AGENTS.md (no aplicada) |
| `gentle-ai-boundary-test-plan.md` | Tests para evitar integración accidental de gentle-ai |
| `ponytail-integration-test-plan.md` | Tests para validar integración de Ponytail |
| `manager-extension-decision-package.md` | Paquete de decisión ejecutiva final |

## Documentos de exportación relacionados

| Documento | Propósito |
|-----------|-----------|
| `../export-readiness/MANAGER-EXTENSIONS-EXPORT-PLAN.md` | Plan de exportación de extensiones al nuevo repo |

---

## Reglas de esta auditoría

- **No runtime changes.** Ningún archivo runtime se modifica (AGENTS.md, opencode.json, plugins, skills, DB).
- **No instalaciones.** No se instala Ponytail, gentle-ai, ni ninguna dependencia.
- **Propuesta, no implementación.** La integración de Ponytail en AGENTS.md está documentada como propuesta, no aplicada.
- **Decisión base validada:** gentle-ai se mantiene como `alignment-only`, no como dependencia runtime.
- **Ponytail no está instalado localmente** — se audita desde repo público.

---

## Veredicto rápido

| Sistema | Estado recomendado | ¿Implementar ahora? |
|---------|-------------------|---------------------|
| gentle-ai | alignment-only, sin runtime | ❌ No |
| Ponytail | Code Gate (SDD Design → SDD Tasks) | ⏸️ Pendiente de aprobación |
| Manager Protocol | Actualizar Completion Contract + Code Review | ⏸️ Pendiente de aprobación |

---

*Fin de integrations/README.md*
