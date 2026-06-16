# gentle-ai Alignment Audit — F2

**Estado:** ✅ AUDIT COMPLETED (2026-06-16)  
**Propósito:** Auditar la relación entre el proyecto `opencode-architecture` y `gentle-ai`, documentar las referencias cruzadas, evaluar si gentle-ai debe considerarse en la reducción de tokens, y establecer la política de alineación.

---

## Executive Summary

gentle-ai es referenciado en **6 documentos** del proyecto opencode-architecture (docs 01, 04, 06, 07, 08, 10). Sin embargo, gentle-ai **no está instalado como repo en el workspace local** — solo existe como referencia externa.

**Decisión:** gentle-ai se considera en **alineación estratégica**, no en integración técnica. La Fase F de reducción de tokens NO debe crear dependencia entre OpenCode y gentle-ai sin aprobación explícita. La auditoría de gentle-ai es informativa, no vinculante.

---

## 1. Documentos con referencias a gentle-ai

Se auditaron los 15 documentos del proyecto opencode-architecture. Se encontraron referencias a gentle-ai en 6:

| Doc | Nombre | Referencia a gentle-ai | Tipo de referencia |
|:---:|--------|------------------------|:------------------:|
| 01 | Current State Map | Menciona gentle-ai como sistema separado | ⚪ Contextual |
| 04 | Memory Context Map | Compara esquemas de memoria OpenCode vs gentle-ai | 🔵 Comparativa |
| 06 | Tools MCP Skills Map | Menciona gentle-ai tools como referencia | 🔵 Comparativa |
| 07 | Evidence Register | Tests de gentle-ai mencionados en evidencia | ⚪ Contextual |
| 08 | Conflicts and Open Questions | Pregunta sobre alineación con gentle-ai | 🔴 Decide |
| 10 | Target Architecture | Arquitectura objetivo menciona gentle-ai como referencia | 🔵 Comparativa |
| 17 | Manager gentle transition plan | **Plan de transición** Manager ↔ gentle (existente pero no activo) | 🔴 Decide |

### Referencia más significativa: Doc #17

`17-manager-gentle-transition-plan.md` contiene un plan de transición entre el Manager de OpenCode y gentle-ai. Este documento **existe pero no está activo**. La decisión actual es mantener Manager como orquestador único y gentle-ai como referencia externa.

> **⚠️ Alerta:** Si en el futuro se reactiva el plan de transición, la Fase F de reducción de tokens tendría que considerar cómo gentle-ai consume contexto.

---

## 2. ¿gentle-ai está en el workspace local?

| Check | Resultado |
|-------|:---------:|
| ¿Repositorio gentle-ai clonado localmente? | ❌ **No** |
| ¿Referencias en documentos del proyecto? | ✅ Sí — 6 documentos |
| ¿Referencias en system prompt? | ❌ No |
| ¿Referencias en Engram? | ⚠️ Mínimas — algunas session summaries legacy |
| ¿Dependencia funcional? | ❌ No — opencode-architecture funciona sin gentle-ai |

---

## 3. Impacto de gentle-ai en la reducción de tokens

### ¿gentle-ai consume tokens del contexto de OpenCode?

**No.** gentle-ai es un sistema separado. No hay tool schemas, skills, ni prompts de gentle-ai en el contexto de OpenCode.

### ¿La Fase F debe considerar gentle-ai?

**Sí, pero solo en alineación estratégica.** Las decisiones de Fase F deben:
1. **No crear dependencias** entre OpenCode y gentle-ai.
2. **Documentar** si una decisión afecta ambos sistemas.
3. **No modificar** gentle-ai ni su configuración.
4. **No asumir** que gentle-ai usará el mismo modelo de reducción de tokens.

### ¿Qué pasa si gentle-ai necesita reducción de tokens en el futuro?

Si gentle-ai implementa su propia reducción de tokens, el patrón diseñado en Fase F (capas, packs, modos, selector) **debe ser reusable**. Esta es la razón por la que se diseñó como arquitectura, no como solución específica de OpenCode.

---

## 4. Política de alineación

| # | Política | Fundamento |
|:-:|----------|------------|
| P1 | **NO** crear dependencia funcional OpenCode ↔ gentle-ai | Cada sistema debe poder operar independientemente |
| P2 | **SÍ** documentar referencias cruzadas entre sistemas | Para trazabilidad cuando se tomen decisiones compartidas |
| P3 | **NO** integrar gentle-ai en el runtime de OpenCode | Sin aprobación explícita |
| P4 | **SÍ** diseñar patrones reutilizables (Fase F) | Para que gentle-ai pueda adoptarlos si decide |
| P5 | **NO** modificar gentle-ai configuration | Está fuera del alcance de Fase F |
| P6 | **SÍ** auditar decisiones que afecten ambos sistemas | Para evitar inconsistencias |

---

## 5. GENTLE_AI_ALIGNMENT_PACK

Como parte de Fase F, se diseñó el `GENTLE_AI_ALIGNMENT_PACK` (ver `context-packs-design.md`) que se activa en modo Arquitectura+ para decisiones que afectan ambos sistemas.

### Contenido del pack

```
Estado de alineación gentle-ai:
● Sistema A (opencode-architecture): reduce ~40k→9.5k con Fase F
● Sistema B (gentle-ai): auditar pero no modificar ni integrar
● Decisión: mantener independencia; gentle-ai como referencia, no dependencia
● Riesgo: crear dependencia OpenCode↔gentle-ai sin aprobación
● Documentos con referencias cruzadas: docs/01, 04, 06, 07, 08, 10, 17
```

### Cuándo activarlo

- Tareas que afectan decisiones compartidas entre opencode-architecture y gentle-ai.
- Modo Arquitectura o superior.
- Cuando se audita o modifica un documento con referencias gentle-ai.

---

## 6. Riesgos de alineación

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Se crea dependencia OpenCode ↔ gentle-ai inadvertidamente | Baja | Medio | Política P1 explícita |
| gentle-ai adopta patrón incompatible con Fase F | Baja | Bajo | Fase F diseñada como arquitectura reusable y documentada |
| Documentos con referencias gentle-ai se desactualizan | Media | Bajo | Mantener referencias en el alignment pack |
| Plan de transición (doc #17) se reactiva sin considerar Fase F | Baja | Medio | Este documento registra la alineación actual |

---

## 7. Documentos afectados por esta auditoría

| Documento | Contiene referencia gentle-ai | Acción F2 |
|:----------|:----------------------------:|:---------:|
| `01-current-state-map.md` | ✅ Sí | ⏳ No modificar ahora |
| `04-memory-context-map.md` | ✅ Sí | ⏳ No modificar ahora |
| `06-tools-mcp-skills-map.md` | ✅ Sí | ⏳ No modificar ahora |
| `07-evidence-register.md` | ✅ Sí | ⏳ No modificar ahora |
| `08-conflicts-and-open-questions.md` | ✅ Sí | ⏳ No modificar ahora |
| `10-target-architecture.md` | ✅ Sí | ⏳ No modificar ahora |
| `17-manager-gentle-transition-plan.md` | ✅ Sí | ⏳ No modificar ahora |
| `context-packs-design.md` | ✅ Sí (nuevo pack) | ✅ Creado GENTLE_AI_ALIGNMENT_PACK |

---

## 8. Verificación: sin cambios funcionales

| Aspecto | Estado |
|---------|:------:|
| ¿Se modificó gentle-ai? | ❌ No |
| ¿Se modificó configuración de gentle-ai? | ❌ No |
| ¿Se integró gentle-ai en OpenCode? | ❌ No |
| ¿Se creó dependencia funcional? | ❌ No |
| ¿Se auditaron referencias cruzadas? | ✅ Sí |
| ¿Se documentó política de alineación? | ✅ Sí |

---

## 9. Referencias

- F1: Context Inventory → Design Skills Protocol (#4, RETRIEVE_ON_DEMAND)
- F2: Context Budget Contract → L5 (on-demand)
- F2: Context Packs Design → GENTLE_AI_ALIGNMENT_PACK
- Proyecto: `docs/opencode-architecture/17-manager-gentle-transition-plan.md`

---

*Fin de gentle-ai-alignment.md — F2 COMPLETED. Auditoría de alineación con gentle-ai completada. Sin cambios funcionales implementados.*
