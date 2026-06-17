# Manager Extensions Export Plan

> **Fecha:** 2026-06-17
> **Propósito:** Definir cómo se exportarán las extensiones del Manager (gentle-ai alignment pack, Ponytail integration proposal, profiles) al nuevo repositorio `opencode-agent-runtime-kit` / `proyecto-opencode-mem`.

---

## 1. Perfiles del futuro kit

| Perfil | Contenido | Incluye gentle-ai | Incluye Ponytail |
|--------|-----------|:-----------------:|:----------------:|
| **`core`** | Manager básico + Engram + Noise Gate + F4C | ❌ No | ❌ No |
| **`full`** | core + SDD subagents + Design Skills + Graphify + harness | ❌ No | ⏸️ Propuesto (code-gate guidance) |
| **`gentle-alignment`** | Documentación de patrones gentle-ai + alignment pack | ✅ Solo documentación | ❌ No |
| **`ponytail-code-gate`** | Propuesta de integración + reglas de activación + tests | ❌ No | ✅ Propuesta documentada |
| **`ultra`** | full + ponytail-code-gate + config avanzada | ❌ No | ⚠️ Solo si se aprueba |

**Regla fundamental:** `full` NO debe incluir gentle-ai runtime. `gentle-alignment` debe ser perfil opcional solo documental.

---

## 2. gentle-ai alignment pack

### Estado actual
- Documentado en: `gentle-ai-alignment.md`, `gentle-ai-activation-policy.md`, `context-packs-design.md` (GENTLE_AI_ALIGNMENT_PACK)
- Decisión: alignment-only, sin runtime

### Formato de exportación
| Componente | Exportar como | Destino |
|------------|---------------|---------|
| `gentle-ai-alignment.md` | Doc sanitizado | `docs/alignment/gentle-ai-alignment.md` |
| `gentle-ai-activation-policy.md` | Doc de política | `docs/alignment/gentle-ai-activation-policy.md` |
| GENTLE_AI_ALIGNMENT_PACK | Doc de referencia | `docs/alignment/context-packs.md` |
| Política de alineación (P1-P6) | Incluida en doc | `docs/alignment/` |
| Patrones transferibles | Incluidos en doc | `docs/alignment/` |

### NO exportar
- Referencias a paths personales en ejemplos
- Datos de sesiones específicas
- Evaluaciones no sanitizadas

### Perfil destino
`gentle-alignment` — exclusivamente documental. No instala nada en runtime.

---

## 3. Ponytail integration proposal

### Estado actual
- Documentado en: `ponytail-integration-audit.md`, `ponytail-manager-integration-proposal.md`, `ponytail-integration-test-plan.md`, `ponytail-runtime-implementation-report.md`
- Decisión: ✅ Implementado en AGENTS.md como code-task default.

### Formato de exportación
| Componente | Exportar como | Destino |
|------------|---------------|---------|
| `ponytail-integration-audit.md` | Doc de auditoría | `docs/integrations/ponytail-audit.md` |
| `ponytail-manager-integration-proposal.md` | Propuesta | `docs/integrations/ponytail-proposal.md` |
| `ponytail-integration-test-plan.md` | Test plan | `docs/integrations/ponytail-tests.md` |
| `ponytail-runtime-implementation-report.md` | Reporte de implementación | `docs/integrations/ponytail-implementation.md` |
| Reglas de activación | Incluidas en AGENTS.md | `docs/integrations/` |
| Reglas de exclusión | Incluidas en AGENTS.md | `docs/integrations/` |

### NO exportar
- Plugin `.mjs` real de Ponytail (no se instala como parte del kit)
- Skills de Ponytail (no se distribuyen como parte del kit)
- Referencias a rutas locales donde se evaluó Ponytail

### Perfil destino
- `ponytail-code-gate` — perfil opcional con la propuesta documentada + reporte de implementación.
- ✅ Implementado en AGENTS.md actual. Decidir si incluir la sección en el template del nuevo repo.
- Si no se incluye, queda como documentación de referencia.

---

## 4. Manager AGENTS.md template

### Estado actual
- Manager Protocol documentado en system prompt de `opencode.json`
- Exportable como template sanitizado

### Formato de exportación
| Componente | Exportar como | Destino |
|------------|---------------|---------|
| Manager Protocol (sin Ponytail) | Template AGENTS.example.md | `templates/AGENTS.example.md` |
| Manager como skill | SKILL.md | `agents/manager/SKILL.md` |
| Completion Contract | Incluido en template | `templates/AGENTS.example.md` |
| Design Skills Integration | Incluido en template | `templates/AGENTS.example.md` |

### NO exportar
- Paths personales (`C:\Users\harry\`)
- Configuración específica de proyectos
- Referencias a skills no exportables

---

## 5. Engram memory-enabled profile

### Estado actual
- Engram MCP server + plugin + protocol documentado
- F4C selector guidance activo
- F4B compaction contract instalado

### Formato de exportación
| Componente | Exportar como | Destino |
|------------|---------------|---------|
| Engram protocol | Doc sanitizado | `docs/memory-rules.md` |
| F4C guidance | Doc sanitizado | `docs/memory-selector.md` |
| F4B contract | Doc sanitizado | `docs/compaction-contract.md` |
| Engram plugin | Template sanitizado | `plugins/engram.template.ts` |
| Noise Gate | Template sanitizado | `plugins/noise-gate.template.ts` |

### Perfil destino
`core` y `full` — ambos incluyen memoria Engram como funcionalidad base.

---

## 6. Mapa de perfiles → componentes

| Componente | core | full | gentle-alignment | ponytail-code-gate | ultra |
|------------|:----:|:----:|:----------------:|:------------------:|:-----:|
| Manager Protocol | ✅ | ✅ | ❌ | ❌ | ✅ |
| Engram memory | ✅ | ✅ | ❌ | ❌ | ✅ |
| Noise Gate | ✅ | ✅ | ❌ | ❌ | ✅ |
| F4B Compaction | ✅ | ✅ | ❌ | ❌ | ✅ |
| F4C Selector | ✅ | ✅ | ❌ | ❌ | ✅ |
| SDD subagents | ❌ | ✅ | ❌ | ❌ | ✅ |
| Design Skills | ❌ | ✅ | ❌ | ❌ | ✅ |
| Graphify skill | ❌ | ✅ | ❌ | ❌ | ✅ |
| Regression harness | ❌ | ✅ | ❌ | ❌ | ✅ |
| gentle-ai docs | ❌ | ❌ | ✅ | ❌ | ❌ |
| Ponytail proposal | ❌ | ❌ | ❌ | ✅ | ✅ |
| Ponytail code gate | ❌ | ✅ | ❌ | ✅ | ✅ |
| Ponytail plugin | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 7. Reglas de exportación

| # | Regla | Fundamento |
|:-:|-------|------------|
| 1 | `full` incluye Manager + agents + skills + Engram + Ponytail code gate | El perfil completo debe ser usable sin dependencias externas |
| 2 | `full` NO debe incluir gentle-ai runtime | gentle-ai alignment-only, sin integración runtime |
| 3 | `gentle-alignment` debe ser perfil opcional solo documental | Quien quiera referencias de gentle-ai puede consultarlo |
| 4 | `ponytail-code-gate` puede ser perfil opcional o subperfil de full | Según recomendación final de la auditoría |
| 5 | `ultra` nunca default | Modo ultra de Ponytail es agresivo y no debe ser default |
| 6 | Ningún perfil debe instalar plugins de terceros sin aprobación explícita | Plugin Ponytail no se incluye en el kit; se documenta cómo instalarlo si el usuario decide |

---

*Fin de MANAGER-EXTENSIONS-EXPORT-PLAN.md*
