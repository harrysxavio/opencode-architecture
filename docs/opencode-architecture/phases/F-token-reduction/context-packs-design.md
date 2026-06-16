# Context Packs Design

**Propósito:** Definir los "context packs" como unidades intercambiables de contexto, cada una con propósito, fuente, rango de tokens, criterios de inclusión/exclusión, riesgo y fallback.

---

## ¿Qué es un context pack?

Un **context pack** es un bloque de contexto autocontenido que representa una dimensión específica del conocimiento del proyecto. Los packs se ensamblan según el modo de operación y la tarea actual, en lugar de incluir todo el contexto disponible.

## Packs propuestos

| Pack | Capa | Tokens objetivo | Prioridad |
|:----|:----:|:---------------:|:---------:|
| `PROJECT_IDENTITY_PACK` | L1 | 300–600 | 🔴 Siempre |
| `ACTIVE_PHASE_PACK` | L2 | 400–800 | 🟡 Casi siempre |
| `VALIDATION_STATUS_PACK` | L2 | 300–500 | 🟡 Casi siempre |
| `RISK_REGISTER_PACK` | L0/L2 | 400–800 | 🟡 Casi siempre |
| `DECISION_LOG_PACK` | L3 | 500–1.000 | 🟢 Según tarea |
| `RELEVANT_MEMORY_PACK` | L3 | 1.500–3.000 | 🟢 Según tarea |
| `RECENT_SESSION_PACK` | L4 | 500–1.000 | 🟢 Según tarea |
| `TASK_SPECIFIC_PACK` | L5 | 500–1.500 | 🔵 Bajo demanda |

---

## PROJECT_IDENTITY_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Establecer identidad del proyecto canónico |
| **Fuente** | `mem_current_project`, config de sesión |
| **Tokens objetivo** | 300–600 |
| **Modo mínimo** | Simple (siempre presente) |
| **Prioridad** | 🔴 Siempre |

**Contenido:**
```
Proyecto: opencode-architecture
Store: C:\Users\harry\.engram\engram.db
Estado: E6B ✅ Suite F ✅
Legacy: arquitectura-ia (no activo)
```

**Criterios de inclusión:** Siempre.

**Criterios de exclusión:** Ninguno.

**Riesgo si falta:** 🟡 Operar en proyecto incorrecto.

**Riesgo si sobra:** 🟢 Mínimo (ocupa 300–600 tokens).

**Fallback:** Usar `mem_current_project`.

---

## ACTIVE_PHASE_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Indicar fase actual del proyecto y objetivo |
| **Fuente** | Tarea actual, session summary |
| **Tokens objetivo** | 400–800 |
| **Modo mínimo** | Normal |
| **Prioridad** | 🟡 Casi siempre |

**Contenido:**
```
Fase: F — Token Reduction (PLANNING)
Objetivo: Reducir ~40k → ~9.5k tokens modo Normal
Siguiente: F0 — Token Audit Baseline
Restricciones activas: No DB/schema/config changes
```

**Criterios de inclusión:** Siempre que haya una fase activa.

**Criterios de exclusión:** Modo Simple (tareas independientes de fase).

**Riesgo si falta:** 🟡 Decisiones desalineadas con la fase actual.

**Riesgo si sobra:** 🟢 Bajo — información compacta.

**Fallback:** Preguntar al usuario la fase actual.

---

## VALIDATION_STATUS_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Indicar qué validaciones están aprobadas |
| **Fuente** | Engram observations (session summaries) |
| **Tokens objetivo** | 300–500 |
| **Modo mínimo** | Normal |
| **Prioridad** | 🟡 Casi siempre |

**Contenido:**
```
E6B Noise Gate: T1-T7 ✅ PASS
Suite F mem_context: F1-F6 ✅ PASS
Suite G (prox): ⏳ Pendiente
```

**Criterios de inclusión:** Siempre que se haya validado algo.

**Criterios de exclusión:** Si no hay validaciones previas.

**Riesgo si falta:** 🟡 Ignorar regresiones.

**Riesgo si sobra:** 🟢 Bajo — información compacta.

**Fallback:** Engram search "session_summary" última.

---

## RISK_REGISTER_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Mantener riesgos activos visibles |
| **Fuente** | Risk register documents, Engram |
| **Tokens objetivo** | 400–800 |
| **Modo mínimo** | Normal |
| **Prioridad** | 🟡 Casi siempre |

**Contenido:**
```
🔴 Session-project mismatch: mitigado con sesión canonical
🟡 Cross-project context: requiere --project explícito
🟢 Secretos: filtro ghp_ funciona (T5 PASS)
```

**Criterios de inclusión:** Siempre que haya riesgos activos.

**Criterios de exclusión:** Modo Simple (tareas sin riesgo).

**Riesgo si falta:** 🟡 Ignorar riesgos conocidos.

**Riesgo si sobra:** 🟢 Bajo — información compacta.

**Fallback:** Leer risk-register.md del proyecto.

---

## DECISION_LOG_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Decisiones arquitectónicas vigentes |
| **Fuente** | Engram observations tipo `decision`, `architecture` |
| **Tokens objetivo** | 500–1.000 |
| **Modo mínimo** | Arquitectura |
| **Prioridad** | 🟢 Según tarea |

**Contenido:**
```
● [decision] Manager como orquestador único (2026-05-15)
● [architecture] Engram como store real, no codex (2026-05-20)
● [decision] Noise Gate con ALLOW=classified (2026-06-10)
```

**Criterios de inclusión:** Tareas de diseño, arquitectura o planificación.

**Criterios de exclusión:** Tareas simples, consultas rápidas.

**Riesgo si falta:** 🟡 Decisiones previas ignoradas, re-trabajo.

**Riesgo si sobra:** 🟡 Contexto histórico innecesario para tareas simples.

**Fallback:** Engram search con `--type=decision,architecture --limit=10`.

---

## RELEVANT_MEMORY_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Memorias relevantes del proyecto |
| **Fuente** | Engram search con selector (ver mem-context-selector-design.md) |
| **Tokens objetivo** | 1.500–3.000 |
| **Modo mínimo** | Normal |
| **Prioridad** | 🟢 Según tarea |

**Contenido:** Resultados rankeados y deduplicados del selector.

**Criterios de inclusión:** Si hay memorias con score > 0.3.

**Criterios de exclusión:** Score < 0.3, proyectos legacy, duplicados.

**Riesgo si falta:** 🟡 Perder contexto histórico relevante.

**Riesgo si sobra:** 🟡 Inflar tokens con memorias irrelevantes.

**Fallback:** Expansión L5 con búsqueda adicional.

---

## RECENT_SESSION_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Continuidad entre iteraciones |
| **Fuente** | Último session summary, últimas observaciones |
| **Tokens objetivo** | 500–1.000 |
| **Modo mínimo** | Normal |
| **Prioridad** | 🟢 Según tarea |

**Contenido:**
```
Última sesión: completó Suite F (F1-F6 PASS)
Próximo paso: Fase F — reducción de tokens
Decisiones: 9.5k no es límite rígido; objetivo 8.5k-12k
```

**Criterios de inclusión:** Si hay historial de sesión reciente y relevante.

**Criterios de exclusión:** Primera sesión, sin historial, modo Simple.

**Riesgo si falta:** 🟢 Bajo — repetición de contexto.

**Riesgo si sobra:** 🟡 Historial redundante.

**Fallback:** `engram timeline` última session_summary.

---

## TASK_SPECIFIC_PACK

| Campo | Valor |
|-------|-------|
| **Propósito** | Expansión bajo demanda para tareas específicas |
| **Fuente** | Búsqueda adicional, lectura archivos, web fetch |
| **Tokens objetivo** | 500–1.500 |
| **Modo mínimo** | Bajo demanda |
| **Prioridad** | 🔵 Solo cuando se necesita |

**Contenido:** Variable según la tarea.

**Criterios de inclusión:** Si L3 es insuficiente y la tarea justifica expansión.

**Criterios de exclusión:** Modo Simple, tareas que L0-L4 cubren.

**Riesgo si falta:** 🟢 Bajo — se puede pedir más contexto.

**Riesgo si sobra:** 🟡 Infla tokens sin beneficio.

**Fallback:** Preguntar al usuario qué contexto adicional necesita.

---

## Ensamblaje de packs por modo

| Pack | Simple | Normal | Arquitectura | Auditoría |
|:-----|:------:|:------:|:------------:|:---------:|
| PROJECT_IDENTITY | ✅ | ✅ | ✅ | ✅ |
| ACTIVE_PHASE | ❌ | ✅ | ✅ | ✅ |
| VALIDATION_STATUS | ❌ | ✅ | ✅ | ✅ |
| RISK_REGISTER | ❌ | ✅ | ✅ | ✅ |
| DECISION_LOG | ❌ | ❌ | ✅ | ✅ |
| RELEVANT_MEMORY | ❌ | ✅ | ✅ | ✅ |
| RECENT_SESSION | ❌ | ✅ | ✅ | ✅ |
| TASK_SPECIFIC | ❌ | ❌ | 🔵 Demanda | 🔵 Demanda |

---

## Presupuesto por modo (packs)

| Modo | Packs incluidos | Tokens estimados |
|:----:|:----------------|:----------------:|
| Simple | PROJECT_IDENTITY | ~500 |
| Normal | IDENTITY + PHASE + VALIDATION + RISK + MEMORY + SESSION | ~4.000–6.000 |
| Arquitectura | Todos excepto TASK_SPECIFIC | ~5.000–8.000 |
| Auditoría | Todos | ~6.000–10.000 |

---

_Fin de context-packs-design.md_
