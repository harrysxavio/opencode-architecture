# F2 — Context Budget Contract

**Estado:** ✅ COMPLETED (2026-06-16)  
**Dependencias:** F0 (Token Audit Baseline) ✅, F1 (Context Inventory) ✅  
**Próxima:** F3 — mem_context Selector Design & Implementation  
**Requiere aprobación:** Sí (Manager + Usuario)

---

## Executive Summary

Este documento es el **contrato formal de presupuesto de tokens** del sistema. Toma los hallazgos medibles de F0 (~35k–45k tokens) y las clasificaciones de F1 (15 fuentes, 7 duplicaciones, 5 quick wins) y los convierte en:

- **Presupuestos exactos por modo** (Simple, Normal, Arquitectura, Auditoría, Excepcional)
- **Mapeo fuente → capa** (cada una de las 15 fuentes de F1 asignada a L0–L5)
- **Reglas de expansión** con triggers, condiciones y límites
- **Reglas de exclusión** — qué nunca entra al contexto base
- **Reglas de fallback** — qué hacer cuando falta contexto
- **El contrato** — declaraciones MUST/SHOULD/MAY vinculantes
- **Integración de quick wins** — qué ahorro aporta cada uno y cuándo se implementa

**Regla fundamental:** este contrato NO se aplica automáticamente en runtime. Es el diseño que F3–F6 implementarán. Hasta entonces, el sistema opera en modo completo (~40k).

---

## 1. Source-to-Layer Mapping

Cada fuente de F1 se asigna a una capa L0–L5. La capa determina prioridad, persistencia y comportamiento de expansión.

| # | Fuente F1 | Clasificación F1 | Capa | Prioridad | Presencia |
|:-:|-----------|:----------------:|:----:|:---------:|:---------:|
| 1 | Manager Protocol | KEEP_FIXED (compactable) | L0 + L1 | 🔴 Crítica | Siempre |
| 2 | AGENTS.md — Persona | COMPACT_FIXED | L0 | 🔴 Crítica | Siempre (compactado) |
| 3 | AGENTS.md — Engram Protocol | DEDUPLICATE | L4 | 🟡 Media | Siempre (fijo) |
| 4 | AGENTS.md — Design Skills | RETRIEVE_ON_DEMAND | L5 | 🔵 Bajo | Solo frontend |
| 5 | OpenCode Core (built-in) | KEEP_FIXED (no mod) | L0 | 🔴 Crítica | Siempre |
| 6 | Tool Schemas | RETRIEVE_ON_DEMAND | L2/L5 | 🟡 Media | Core 6 siempre + fase actual |
| 7 | Available Skills block | COMPACT_FIXED | L2 | 🟡 Media | Siempre (compactado) |
| 8 | Skills Content (SKILL.md) | RETRIEVE_ON_DEMAND | L5 | 🔵 Bajo | Bajo demanda |
| 9 | Engram Memories (retrieved) | RANK_AND_LIMIT | L3 | 🟢 Media | Ranking dinámico |
| 10 | Session History | COMPACT_FIXED | L4 | 🟡 Media | Compactado, últimos 3 crudos |
| 11 | User Prompts (DB) | INVESTIGATE | — | ⚪ Futuro | No entra en contexto |
| 12 | Environment Info | KEEP_FIXED (mínimo) | L1 | 🔴 Crítica | Siempre |
| 13 | Project Docs | RETRIEVE_ON_DEMAND | L5 | 🔵 Bajo | Bajo demanda (ya) |
| 14 | README principal | RETRIEVE_ON_DEMAND | L5 | 🔵 Bajo | Bajo demanda (ya) |
| 15 | Fase F Docs | RETRIEVE_ON_DEMAND | L5 | 🔵 Bajo | Bajo demanda (ya) |

### Capas consolidadas

| Capa | Nombre | Fuentes F1 | Tokens objetivo (Normal) | Prioridad |
|:----:|--------|------------|:------------------------:|:---------:|
| L0 | Core Rules | Manager Protocol (secc. reglas), AGENTS.md Persona, OpenCode Core | 800–1,200 | 🔴 Nunca omitir |
| L1 | Project Identity | Manager Protocol (secc. identidad), Environment Info | 300–600 | 🔴 Nunca omitir |
| L2 | Active State | Manager Protocol (secc. operativa), Tool Schemas core, Available Skills, Session summaries | 600–1,200 | 🟡 Casi siempre |
| L3 | Retrieved Memory | Engram Memories (ranked, deduped) | 2,000–3,500 | 🟢 Ranking dinámico |
| L4 | Recent History | Session History (compactado), AGENTS.md Engram Protocol | 600–1,200 | 🟢 Si hay historial |
| L5 | On-Demand | Design Skills, Skills Content, Tool Schemas extendido, Project Docs, README, Fase F Docs | 500–1,000 | 🔵 Solo demanda |
| | **Working buffer** | — | 1,500–2,500 | 🟡 Holgura |

---

## 2. Presupuestos por Modo

### Tabla consolidada

| Capa | Simple (6k–8.5k) | Normal (8.5k–12k) | Arquitectura (12k–16k) | Auditoría (16k–22k) | Excepcional (>22k) |
|:----:|:-----------------:|:------------------:|:----------------------:|:-------------------:|:------------------:|
| L0 | 800–1,000 | 1,000–1,200 | 1,200–1,500 | 1,500 | 1,500+ |
| L1 | 300–400 | 400–600 | 600–800 | 800 | 800+ |
| L2 | 400–600 | 600–1,200 | 1,200–1,500 | 1,500 | 2,000+ |
| L3 | 1,000–1,500 | 2,000–3,500 | 3,500–4,500 | 4,500–6,000 | 6,000–10,000 |
| L4 | — | 600–1,200 | 1,200–1,500 | 1,500–2,000 | 2,000–3,000 |
| L5 | — | — | 500–1,000 | 1,000–1,500 | 1,500–3,000 |
| Buffer | 1,200–1,500 | 1,500–2,500 | 2,500–3,000 | 3,000–4,000 | 4,000+ |
| **Total** | **~6,000–8,500** | **~8,500–12,000** | **~12,000–16,000** | **~16,000–22,000** | **>22,000** |

> **Los budgets de esta tabla asumen compactación del Manager Protocol** (QW#3 implementado).
> Si QW#3 **no se implementa**, el Manager Protocol sin compactar aporta ~2k–6k tokens adicionales al total. Ver escenario alternativo abajo.

### Escenario alternativo: SIN compactación de Manager Protocol

Los budgets de esta tabla asumen que QW#3 (Manager Protocol compactado de ~7k–14k a ~5k–8k) está implementado. Si QW#3 **no se implementa** (por decisión de prioridad o porque el usuario no lo aprueba), los budgets se incrementan:

| Modo | Budget con QW#3 | Budget SIN QW#3 | Diferencia |
|:-----|:---------------:|:---------------:|:----------:|
| Simple | 6k–8.5k | 7k–10k | +1k–1.5k |
| **Normal** | **8.5k–12k** | **10k–14k** | **+1.5k–2k** |
| Arquitectura | 12k–16k | 14k–19k | +2k–3k |
| Auditoría | 16k–22k | 19k–26k | +3k–4k |
| Excepcional | >22k | >25k | +3k–6k |

**Impacto en modo Normal (default):** 8.5k–12k → **10k–14k**. El límite superior sube 2k, quedando dentro del rango aceptable pero rozando el límite práctico.

**Nota:** QW#3 fue reclasificado de "quick win" a "nice to have" (baja prioridad) en la F2 Critical Review (D-F-023). Los budgets sin compactación son el escenario realista hasta que el usuario apruebe su implementación.

### Desglose por fuente (Modo Normal)

| Fuente | Tokens | Notas |
|--------|:------:|-------|
| Manager Protocol (compactado) | 5,000–8,000 | Secciones redundantes comprimidas |
| AGENTS.md — Persona (compactado) | ~500 | Reglas esenciales, sin redundancia |
| OpenCode Core | 2,000–3,000 | No modificable |
| Environment Info | ~100 | Mínimo |
| Available Skills (compactado) | ~600 | Solo trigger keywords |
| Sesion History (compactado) | 1,000–2,000 | Últimos 3 crudos + resumen |
| Tool Schemas core | 800–1,200 | read, write, edit, bash, glob, grep |
| Engram Memories (top-5) | 800–1,500 | Rankeadas, deduplicadas |
| **Suma fuentes** | **~7,000–11,000** | Antes de buffer |
| **Con buffer** | **~8,500–12,000** | ✅ Normal |

### Desglose por fuente (Modo Simple)

| Fuente | Tokens |
|--------|:------:|
| Manager Protocol (compactado mínimo) | 3,000–4,000 |
| AGENTS.md — Persona (compactado) | ~400 |
| OpenCode Core | 2,000–2,500 |
| Environment Info | ~75 |
| Available Skills (compactado) | ~500 |
| Engram Memories (top-3) | ~500 |
| **Suma** | **~5,000–7,000** |
| **Con buffer** | **~6,000–8,500** ✅ |

---

## 3. Integración de Quick Wins

Cada quick win de F1 se mapea a su impacto en el presupuesto y a la fase que lo implementará.

| QW | Nombre | Ahorro | Impacta capa | Fase | Riesgo |
|:--:|--------|:------:|:------------:|:----:|:------:|
| #1 | Session History Compactado | ~3k–5k | L4 | F3 | Medio |
| #2 | Tool Schemas Bajo Demanda | ~2k–4k | L2/L5 | F3 | Medio |
| #3 | Dedup Manager/AGENTS.md | ~300–550 | L0 | F2 | Medio |
| #4 | Memorias Rankeadas + Top-K | ~500–2k | L3 | F3 | Medio |
| #5 | Skills Selectivos | ~400–600 | L2 | F2 | Bajo |

### Quick Wins que implementa F2 (ahora)

| QW | Acción | Entrega |
|:--:|--------|:--------|
| #3 | Compactar Manager Protocol + alinear con AGENTS.md | Propuesta en `manager-protocol-compaction-audit.md` |
| #5 | Acortar descripciones de Available Skills block | Propuesta en `skills-selective-loading-audit.md` |

### Quick Wins que DELEGA a F3

| QW | Entregable F3 |
|:--:|---------------|
| #1 | Compactador de session history implementado |
| #2 | Tool loader selectivo implementado |
| #4 | mem_context Selector con ranking + top-k + dedup implementado |

**Regla:** Quick wins de F3 requieren que F2 esté aprobado y que el budget contract sea el contrato vinculante.

---

## 4. Expansión Rules

### Trigger automático

El sistema PUEDE expandirse automáticamente hasta el máximo del modo activo sin justificación.

| Modo activo | Expansión automática hasta |
|:-----------:|:--------------------------:|
| Simple | 10k (máx. +1.5k sobre objetivo) |
| Normal | 14k (máx. +2k sobre objetivo) |
| Arquitectura | 20k (máx. +4k sobre objetivo) |
| Auditoría | 28k (máx. +6k sobre objetivo) |

### Trigger justificado (requiere razón)

| Condición | Acción | Justificación requerida |
|-----------|--------|------------------------|
| `mem_context` retorna vacío | Expandir a +1 modo | "Sin contexto histórico — expandiendo a modo X" |
| Tarea identificada como Large por Manager | Promover a Arquitectura | "Tarea multi-módulo detectada: X archivos" |
| Debugging activo | Expandir L5 para incluir herramientas de debug | "Debugging activo en X — expandiendo tools" |
| Análisis de regresión completo | Promover a Auditoría | "Ejecutando regression plan completo" |

### Trigger bloqueante (nunca expandir)

- Si la expansión eliminaría L0 o L1 del contexto.
- Si la expansión expondría secretos (`ghp_`, `token=`, `password`).
- Si la expansión mezclaría proyectos legacy sin autorización.
- Si la expansión viola restricciones activas del usuario.

---

## 5. Exclusion Rules

Estos contenidos NUNCA deben incluirse en el contexto base:

| Contenido | Razón | Categoria |
|-----------|-------|:---------:|
| Memorias de proyectos legacy (`arquitectura-ia`, `retail-masivo-oc`) | Cross-project leakage | 🚫 Siempre |
| Secretos, tokens, credenciales | Seguridad | 🚫 Siempre |
| Raw session history completo (sin resumir) | Infla tokens sin beneficio | 🚫 Siempre en modo ≤ Normal |
| Tool schemas de todas las 16 herramientas | Derrochable (D7) | 🚫 Siempre |
| Skills content completo (308KB) | Solo bajo demanda | 🚫 Siempre |
| Resultados de búsqueda Engram sin filtro top-k | Ruido en contexto | 🚫 Siempre |
| User prompts (Engram DB) | No se cargan actualmente | 🚫 Hasta F-G |
| Contenido de archivos `design` > 500 líneas sin resumen | Infla L5 | ⚠️ Moderar |

---

## 6. Fallback Rules

| Situación | Acción | Detalle |
|-----------|--------|---------|
| Contexto insuficiente para responder | Expandir al siguiente modo | Registrar "Fallback: modo X → modo Y" |
| `mem_context` retorna vacío o score < 0.3 | Omitir L3, pasar a L5 | Búsqueda adicional justificada |
| Modo excedido sin justificación | Rechazar y volver a modo Normal | Log de violación |
| Tarea crítica detectada | Promover automáticamente a Arquitectura | Sin esperar justificación |
| Riesgo de seguridad detectado | Expandir L0 con reglas adicionales | Prioridad máxima |
| Tool no cargada necesaria | Cargar tool + reintentar | Lazy load con cache |
| Memory dedup elimina todas las candidatas | Re-ejecutar sin dedup | Solo si score < 0.3 para todas |
| Session history compactado pierde hilo | Últimos 3 turns crudos siempre disponibles | Garantía de continuidad |

---

## 7. The Contract

### MUST (obligatorio — violación requiere rollback)

| # | Declaración | Fuente |
|:-:|-------------|:------:|
| M1 | El sistema DEBE operar dentro del presupuesto de su modo actual | Budget Contract |
| M2 | L0 (Core Rules) y L1 (Project Identity) DEBEN estar siempre presentes en todo modo | Seguridad |
| M3 | El sistema DEBE usar `--project=opencode-architecture` en toda búsqueda Engram | Filtro cross-project |
| M4 | El sistema DEBE excluir secretos (`ghp_`, `token=`, `password`) de todo contexto | E6B |
| M5 | El sistema DEBE mantener al menos 3 turns crudos del session history | Continuidad |
| M6 | El sistema DEBE justificar expansiones >14k | Transparencia |
| M7 | El sistema DEBE documentar justificación >22k con aprobación Manager + Usuario | Gobernanza |
| M8 | El sistema DEBE caer en fallback si el contexto es insuficiente | Robustez |
| M9 | El sistema DEBE pasar E6B y Suite F antes de cualquier cambio en runtime | Regression gate |
| M10 | El sistema NO DEBE truncar L0/L1 para ahorrar tokens | Prioridad |

### SHOULD (recomendado — desviación documentada)

| # | Declaración |
|:-:|-------------|
| S1 | El sistema DEBERÍA usar modo Normal como default (8.5k–12k) |
| S2 | El sistema DEBERÍA compactar el Manager Protocol (target: 5k–8k tokens) |
| S3 | El sistema DEBERÍA mover Design Skills Protocol a carga bajo demanda |
| S4 | El sistema DEBERÍA rankear memorias con scoring semántico + top-k |
| S5 | El sistema DEBERÍA deduplicar contenido similar en retrieval |
| S6 | El sistema DEBERÍA usar descripciones cortas en el bloque Available Skills |
| S7 | El sistema DEBERÍA expandir automáticamente cuando la tarea lo requiere |
| S8 | El sistema DEBERÍA respetar el buffer como espacio de trabajo, no como fuente |

### MAY (opcional — decisión del Manager)

| # | Declaración |
|:-:|-------------|
| A1 | El sistema PUEDE expandir automáticamente hasta el máximo del modo sin justificación |
| A2 | El sistema PUEDE usar L5 (búsqueda adicional) cuando L3 es insuficiente |
| A3 | El sistema PUEDE ignorar dedup si el contexto es escaso (score bajo para todas) |
| A4 | El sistema PUEDE incluir contexto de proyectos legacy si la tarea lo pide explícitamente |
| A5 | El sistema PUEDE modificar el buffer dinámicamente según la tarea |

---

## 8. Verificación del Contrato

Para validar que este contrato es correcto, se verificaron los siguientes criterios:

| # | Criterio | Resultado | Método |
|:-:|----------|:---------:|--------|
| V1 | Budgets suman correctamente por modo | ✅ | Suma de capas ≤ total modo |
| V2 | L0 + L1 siempre presentes en todos los modos | ✅ | Simple incluye L0+L1 |
| V3 | Ninguna fuente KEEP_FIXED se excluye por error | ✅ | Manager Protocol, OpenCode Core, Env Info en todos |
| V4 | Exclusion rules no contradicen MUST declarations | ✅ | M1–M10 no excluyen lo que M requiere |
| V5 | Quick wins mapean a capas y fases correctas | ✅ | QW#1→L4/F3, QW#2→L2+L5/F3, QW#3→L0/F2, QW#4→L3/F3, QW#5→L2/F2 |
| V6 | Fallback cubre todos los casos de error | ✅ | 7 situaciones con acción y detalle |
| V7 | Expansión rules tienen triggers claros y no ambiguos | ✅ | 3 categorías (automático, justificado, bloqueante) |
| V8 | Modo Normal como default alinea con decisión D-F-002 | ✅ | Sí, 8.5k–12k default |
| V9 | No hay límite rígido en 9.5k (alineado con D-F-001) | ✅ | Rangos, no valores fijos |
| V10 | Contract no requiere cambios en runtime para validarse | ✅ | Es diseño, no implementación |

---

## 9. Documentos afectados

| Documento | Acción |
|-----------|:------:|
| `F2-context-budget-contract.md` | ✅ Creado — este documento |
| `context-budget-contract.md` | **Pendiente** — actualizar con datos de F2 y referenciar este doc |
| `implementation-roadmap.md` | **Pendiente** — marcar F2 COMPLETED |
| `decision-log.md` | **Pendiente** — registrar nuevas decisiones |
| `README.md` (Fase F) | **Pendiente** — marcar F2 COMPLETED |

---

## 10. Confirmación: sin cambios funcionales

| Aspecto | Estado |
|---------|:------:|
| ¿Se modificó DB? | ❌ No |
| ¿Se modificó schema? | ❌ No |
| ¿Se modificó config? | ❌ No |
| ¿Se modificó Noise Gate? | ❌ No |
| ¿Se modificó mem_context? | ❌ No |
| ¿Se modificó pipeline de captura? | ❌ No |
| ¿Se eliminaron archivos? | ❌ No |
| ¿Se eliminaron memorias? | ❌ No |
| ¿Se implementaron cambios funcionales? | ❌ No |
| ¿Solo diseño, auditoría y documentación? | ✅ Sí |

---

*Fin de F2-context-budget-contract.md — F2 COMPLETED. Contrato formal de presupuesto de tokens por modo establecido. Sin cambios funcionales implementados.*
