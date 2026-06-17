# README Architecture Assurance Refresh Plan

> **Fase:** Architecture README & Assurance Refresh  
> **Fecha:** 2026-06-17  
> **Estado:** PLAN DEFINIDO — documentación/auditoría solamente  
> **Repo objetivo:** `opencode-architecture`

---

## 1. Auditoría breve del README actual

El README actual ya explica Fase F, Engram, Noise Gate, `mem_context`, runtime local vs repo, export readiness y PASS WITH WARNINGS. Sin embargo, quedó desalineado con la fase más reciente de **Manager SDD Orchestration Audit**.

### Hallazgos

| Área auditada | Hallazgo | Corrección propuesta |
|---|---|---|
| Título y framing | El README se presenta como "Runtime, Memory & Context Control", pero ahora el documento maestro debe cubrir Manager, agentes, SDD y runtime governance. | Renombrar a `OpenCode Architecture — Manager, Memory, Agents & Runtime Governance`. |
| Manager | Está mencionado, pero no explicado como primary único, router, delegator y final synthesizer. | Agregar secciones dedicadas: rol del Manager, tabla de responsabilidades y routing flow. |
| SDD | El README anterior no cubre los 10 subagentes ni el pipeline completo. | Agregar tabla de subagentes, sequence diagram y explicación de fases. |
| `sdd-init` | No aparece como entry point real confirmado. | Agregar sección propia con estado v3.0 y formato `SDD_INIT_PACKET`. |
| gentle-ai vs gentle-orchestrator vs sdd-* | Riesgo de confundir sistema externo, subagente local y subagentes SDD. | Agregar frontera explícita y frase obligatoria de independencia runtime. |
| Ponytail | El README anterior no refleja que Ponytail Code Gate está en AGENTS.md pero plugin/skills no están instalados. | Agregar sección honesta: guidance/documentary integration, no plugin operativo full. |
| Tests Manager/SDD | README solo cubre harness Fase F, no tests A/B/C/D/E/F, GA-B ni PT-I. | Agregar sección de tests actuales, diseñados y pendientes. |
| Warnings antes del repo nuevo | Faltan los 10 gaps y las 4 acciones del senior challenge. | Agregar tabla de gaps con must/should/can/defer. |
| Links nuevos | Los 15 documentos Manager SDD no están suficientemente visibles como entrada principal. | Actualizar quick links e índices. |
| Fuente de verdad path | El prompt listaba `integrations/pre-runtime-kit-gap-analysis.md`, pero el archivo real está en `export-readiness/pre-runtime-kit-gap-analysis.md`. | Documentar path real y usarlo en README/índices. |

---

## 2. Qué se va a cambiar

1. Reescribir `README.md` como documento maestro con 25 secciones.
2. Mantener una lectura progresiva: primero no técnico, luego técnico, luego validación y export readiness.
3. Incorporar al README los resultados recientes:
   - Manager SDD Orchestration Audit: PASS WITH WARNINGS.
   - 10 subagentes SDD confirmados como `mode: subagent`.
   - `sdd-init` confirmado, versión 3.0.
   - `gentle-orchestrator` como subagente local, no primary.
   - gentle-ai externo como `alignment-only`.
   - Ponytail Code Gate implementado en AGENTS.md como guidance; plugin/skills no instalados.
   - 10 gaps pre-runtime-kit.
   - 4 acciones pendientes del senior challenge.
   - Harness 34/34 PASS.
4. Crear `docs/opencode-architecture/ARCHITECTURE-ASSURANCE-REPORT.md` con evidencia, componentes, gaps y Go/No-Go.
5. Actualizar índices: `DOCUMENTATION-INDEX.md`, `integrations/README.md`, y `phases/F-token-reduction/DOCUMENTATION-INDEX.md` si corresponde.

---

## 3. Contradicciones que se corregirán

| Contradicción / desalineación | Corrección |
|---|---|
| README dice `Subagentes SDD — 9 skills`, pero el inventario confirmó 10 incluyendo `sdd-init`. | Cambiar a 10 subagentes SDD. |
| Exportabilidad en README anterior menciona `opencode-agent-runtime-kit`, mientras la fase actual apunta a `proyecto-opencode-mem`. | Explicar ambos: nombre blueprint previo y repo objetivo actual. |
| Ponytail puede parecer plugin operativo. | Aclarar: AGENTS.md guidance activo; plugin y command skills no instalados. |
| gentle-ai puede parecer dependencia runtime. | Aclarar: solo alignment lens/documentación; `full` no incluye gentle-ai runtime. |
| F4B puede confundirse como PASS completo por harness 34/34. | Mantener `F4B PARTIAL`; harness valida markers, no compactación natural real. |
| Return envelope parece definido e implementado. | Aclarar: definido, pero todavía no aplicado a prompts SDD. |
| Tests Manager/SDD parecen automatizados. | Aclarar: diseñados; 7 críticos pendientes de automatizar. |

---

## 4. Nuevas secciones del README

El README tendrá la estructura solicitada:

1. Resumen en 1 minuto
2. Explicación para personas no técnicas
3. Explicación para personas técnicas
4. Estado actual validado
5. Arquitectura general
6. Manager: rol principal
7. Flujo de routing del Manager
8. SDD Pipeline y subagentes
9. Flujo SDD completo
10. `sdd-init`
11. Return envelope de subagentes
12. Engram y memoria
13. Noise Gate
14. Optimización de tokens — Fase F
15. Skills
16. gentle-ai
17. Ponytail Code Gate
18. Ejemplos de uso
19. Validación y tests actuales
20. Tests recomendados / pendientes
21. Warnings / gaps antes del repo nuevo
22. Runtime local vs repo
23. Camino hacia `proyecto-opencode-mem`
24. Quick links
25. Glosario

Además incluirá al menos 8 diagramas Mermaid: arquitectura general, routing, SDD sequence, Engram, Noise Gate, Fase F, runtime vs repo, export profiles, y opcionalmente assurance pipeline.

---

## 5. Fuentes usadas

Se leyeron las fuentes obligatorias indicadas por el usuario, incluyendo:

- `README.md`
- `DOCUMENTATION-INDEX.md`
- `docs/opencode-architecture/17-manager-gentle-transition-plan.md`
- Fase F: `gentle-ai-alignment.md`, `F-phase-final-closure-report.md`, `F4A-lite...`, `F5C-token-savings-rebaseline.md`
- Integraciones: gentle-ai policy/audit/boundary, Manager contract/routing/delegation, SDD inventory/init/pipeline/envelope/test plan, Ponytail reports
- Export readiness: SDD agents export plan, manager extensions export plan, shareable repo blueprint, migration plan, test strategy, final report, gap analysis

Nota de path: `pre-runtime-kit-gap-analysis.md` existe en `docs/opencode-architecture/export-readiness/`, no en `integrations/`.

---

## 6. Riesgo de sobrecargar el README

| Riesgo | Mitigación |
|---|---|
| README demasiado largo para usuario no técnico | Estructura progresiva: resumen, analogía, luego técnica. |
| Repetición de documentos existentes | README actuará como mapa maestro y linkeará detalles. No reemplaza docs profundos. |
| Diagramas excesivos | Diagramas con explicación corta debajo, no como decoración. |
| Mezclar estado validado con trabajo pendiente | Separar `Estado validado`, `Tests pendientes` y `Warnings/gaps`. |
| Maquillar warnings por querer cerrar la fase | Mantener PASS WITH WARNINGS explícito y explicar por qué. |

---

## 7. Criterio de aceptación

- README principal queda como documento maestro.
- Sirve para audiencia no técnica y técnica.
- Explica Manager, subagentes, SDD, `sdd-init`, Engram, Noise Gate, `mem_context`, Fase F, gentle-ai, Ponytail, skills y export readiness.
- Incluye al menos 8 diagramas Mermaid.
- Incluye ejemplos de uso.
- Incluye tests actuales y pendientes.
- Incluye warnings/gaps y Go/No-Go antes de `proyecto-opencode-mem`.
- No afirma que Ponytail plugin o skills estén instalados.
- No afirma que gentle-ai sea dependencia runtime.
- No promueve F4B a FULL PASS.
- Harness final: 34/34 PASS.
- No hubo cambios runtime.

---

*Fin de README-ARCHITECTURE-ASSURANCE-REFRESH-PLAN.md*
