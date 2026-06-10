# ARQUITECTURA OPENCODE

> Documentación, validación y evolución del ecosistema OpenCode del usuario.

⚠️ **Advertencia:** Este repositorio documenta la **arquitectura, validaciones y roadmap de evolución** de la configuración OpenCode/Codex del usuario. La configuración runtime real (agentes, MCP, skills, plugins, memoria Engram) **vive en rutas locales** (`~/.config/opencode/`, `~/.codex/`, `~/.engram/`, etc.) y puede diferir de lo documentado aquí. Este repositorio es un **registro de análisis y decisiones**, no un mirror de configuración.

---

## Qué es este repositorio

Contiene el análisis arquitectónico más completo del ecosistema OpenCode del usuario. Sus objetivos:

1. **Documentar cómo funciona hoy** — basado en evidencia de archivos, configuración y código.
2. **Clasificar hallazgos** — separar lo validado de lo inferido y lo no validado.
3. **Identificar conflictos y riesgos** — entre componentes, agentes, orquestadores y capas de memoria.
4. **Proponer una arquitectura objetivo** — coherente, eficiente y mantenible.
5. **Definir un roadmap de migración** — fases incrementales sin romper el sistema.

---

## Estado actual por fases

| Fase | Estado | Descripción |
|------|--------|-------------|
| **A** — Documentación base | ✅ Completada | Análisis inicial, mapa de componentes, flujo de request/response |
| **B0** — Corrección documental | ✅ Completada | Validación read-only, corrección de afirmaciones |
| **B-Security** | ⏸ Postergada | Rotación de secretos expuestos — pendiente de priorización |
| **C** — Tests de flujo | ✅ Completada | 8 tests de validación ejecutados sobre el flujo real |
| **D** — Resolución agente primario | ✅ Completada | ADR-001: Manager como único primary; docs actualizados |
| **E** — Gobernanza de memoria Engram | ▶️ En curso | Ver detalle abajo |

### Subfases de Fase E

| Subfase | Estado | Descripción |
|---------|--------|-------------|
| **E0** — Diagnóstico Engram | ✅ | Store real identificado (`~/.engram/engram.db`), procesos, binarios, project drift |
| **E1** — Pruebas controladas | ✅ | 7 tests (E-T1 a E-T7) con scope `TEST-E-MEMORY-GOVERNANCE`: todos PASSED |
| **E2** — Root cause analysis | ✅ | Engram **sí persiste**; problema real es gobernanza/config duplicada/ruido/drift |
| **E3** — Change plan | ✅ | Propuesta mínima de reparación documentada |
| **E4A** — Gap review | ✅ | Revisión read-only: brechas identificadas, recomendaciones |
| **E4A-Docs-Cleanup** | ✅ **Ahora** | ✅ README raíz actualizado; docs README convertido a índice mínimo |
| **E4B** — Stabilization | ⏸ Pendiente desbloqueo | Pin binario Engram, unificar project name, reducir ambigüedad config, validar |

---

## Arquitectura objetivo resumida

→ [Ver documento completo: 10-target-architecture.md](docs/opencode-architecture/10-target-architecture.md)

La arquitectura objetivo propone:

- **Manager** como único orquestador primario con control del pipeline completo (SDD + quality gates).
- **SDD** como flujo estructurado de implementación (explore → propose → spec → design → tasks → apply → verify → archive).
- **Engram** como sistema de memoria persistente cross-session, con gobernanza sobre captura y ruido.
- **Context Pack** como contrato estructurado para recuperación de contexto (postergado a Fase E5).
- **GPT-5.5 OAuth** como quality gate final (cuando esté disponible).

---

## Documentación principal

| Documento | Descripción |
|-----------|-------------|
| [Executive Summary](docs/opencode-architecture/00-executive-summary.md) | Resumen ejecutivo para toma de decisiones |
| [Target Architecture](docs/opencode-architecture/10-target-architecture.md) | Arquitectura objetivo propuesta |
| [Migration Roadmap](docs/opencode-architecture/12-migration-roadmap.md) | Roadmap de migración por fases |
| [Validation Test Plan](docs/opencode-architecture/13-validation-test-plan.md) | Plan de pruebas de validación |
| [Runtime Validation Results](docs/opencode-architecture/14-runtime-validation-results.md) | Resultados de validación runtime |
| [Memory Governance Policy](docs/opencode-architecture/16-memory-governance-policy.md) | Política de gobernanza de memoria |
| [Manager/Gentle Transition Plan](docs/opencode-architecture/17-manager-gentle-transition-plan.md) | Plan de transición Manager/gentle |
| [ADR Index](docs/opencode-architecture/adr/) | Architectural Decision Records |
| [Test Runs](docs/opencode-architecture/test-runs/) | Resultados de ejecuciones de prueba |

---

## Descubrimientos clave de la Fase E

- **Store real de Engram**: `~/.engram/engram.db` (NO `.codex/memories_1.sqlite`)
- **Estado**: 292 observations, 302 user_prompts, 68 sessions, 176 relations — Engram **sí persiste y escribe**
- **Riesgo principal**: duplicación de config (dos `opencode.json`), project drift (`arquitectura opencode` vs `opencode-architecture`), 302 prompts capturados sin gate de ruido, dos binarios Engram (v1.15.13 y v1.16.1)
- **Problema real**: no es que Engram no funcione — es que **no hay gobernanza** sobre qué se guarda, cómo se organiza y cómo se recupera

---

## Próximo paso

Finalizado E4A-Docs-Cleanup → **E4B — Engram Stabilization** (alcance mínimo):

- Pin de binario Engram único.
- Unificar project name a `opencode-architecture`.
- Reducir ambigüedad de configs.
- Reiniciar OpenCode.
- Validar procesos.
- Repetir `mem_save`, `mem_search`, `mem_context`, `mem_session_summary`.
- Sin tocar plugin, AGENTS.md (salvo diff mínimo aprobado), optimización de tokens ni MCP surface general.

### Roadmap posterior (orden tentativo)

| Fase | Objetivo |
|------|----------|
| **E5** | Context Pack + Memory Writer/Validator contracts |
| **E6** | Prompt capture / noise gate |
| **F** | Token reduction con Context Pack |
| **G** | Hybrid Retrieval (keyword + semántico) |
| **H** | MCP surface / memory server avanzado |

---

*Última actualización: 2026-06-10. Este documento se actualiza al completar cada fase.*
