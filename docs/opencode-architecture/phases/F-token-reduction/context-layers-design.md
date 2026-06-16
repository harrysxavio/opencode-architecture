# Context Layers Design

**Estado:** ✅ ENHANCED WITH F1/F2 DATA  
**Propósito:** Definir la arquitectura de contexto por capas (L0 a L5), el propósito de cada capa, su fuente, criterios de inclusión y riesgos.

> Este diseño fue actualizado con los datos de **F1 (Context Inventory)** y **F2 (Context Budget Contract)**.  
> Cada capa ahora incluye: fuentes F1 asignadas, presupuesto F2, y referencias a quick wins.

---

## Principio rector

No se busca "recortar tokens" a ciegas. Se busca **usar el mínimo contexto necesario para mantener o mejorar la calidad del resultado**.

## Arquitectura de capas

```
┌─────────────────────────────────────────────────────────┐
│  L5 — Contexto bajo demanda                             │
│  (búsqueda adicional, lectura docs, expansión)           │
├─────────────────────────────────────────────────────────┤
│  L4 — Historial reciente mínimo                         │
│  (últimas decisiones, último resultado, próximo paso)    │
├─────────────────────────────────────────────────────────┤
│  L3 — Contexto recuperado desde Engram                  │
│  (memorias rankeadas, top-k, deduplicadas)               │
├─────────────────────────────────────────────────────────┤
│  L2 — Estado activo de trabajo                          │
│  (fase actual, objetivo, restricciones operativas)       │
├─────────────────────────────────────────────────────────┤
│  L1 — Identidad del proyecto                            │
│  (nombre canonical, store real, estado validado)         │
├─────────────────────────────────────────────────────────┤
│  L0 — Reglas críticas no negociables                    │
│  (seguridad, no secretos, separación proyectos)          │
└─────────────────────────────────────────────────────────┘
```

---

## L0 — Reglas críticas no negociables

**Propósito:** Garantizar que el sistema nunca viola reglas de seguridad, separación de proyectos o exposición de datos.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | Manager Protocol (secc. reglas), AGENTS.md — Persona, OpenCode Core |
| **Clasificación F1** | KEEP_FIXED + COMPACT_FIXED |
| **Tokens objetivo (F2)** | 800–1,200 |
| **Tokens máximos (F2)** | 1,500 |
| **Presupuesto Simple** | 800–1,000 |
| **Presupuesto Normal** | 1,000–1,200 |
| **Presupuesto Arquitectura** | 1,200–1,500 |
| **Frecuencia** | Siempre presente en toda sesión |
| **Prioridad** | 🔴 Crítica — nunca omitir |
| **Quick wins aplicables** | QW#3 (Dedup Manager/AGENTS.md), QW#5 (Skills Selectivos) |

**Contenido mínimo:**
1. No exponer secretos, tokens ni credenciales.
2. No escribir en DB sin aprobación.
3. Separación estricta de proyectos.
4. Identidad canonical del proyecto.
5. Restricciones de herramientas (read-only vs write).
6. Prohibición de migrar DB/schema/config sin aprobación.
7. Reglas de persona y estilo de respuesta (AGENTS.md Persona compactada).

**Criterios de inclusión:** Siempre. No negociable.

**Criterios de exclusión:** Ninguno. Siempre presente.

**Riesgo si falta:** 🔴 Catastrófico — exposición de secretos, escritura indebida, mezcla de proyectos.

**Riesgo si sobra:** 🟢 Mínimo — reglas compactas, ocupan poco.

**Fallback:** Si no hay espacio para L0 completo, abortar la operación.

**Estrategia F2:** Compactar Manager Protocol para ~5k–8k tokens (ahorro ~2k–6k). Alinear reglas redundantes con AGENTS.md Persona (ahorro ~300–550 tokens). Skills block con descripciones cortas (ahorro ~400–600 tokens).

---

## L1 — Identidad del proyecto

**Propósito:** Establecer el contexto de proyecto en el que se opera.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | Manager Protocol (secc. identidad), Environment Info |
| **Clasificación F1** | KEEP_FIXED |
| **Tokens objetivo (F2)** | 300–600 |
| **Tokens máximos (F2)** | 800 |
| **Presupuesto Simple** | 300–400 |
| **Presupuesto Normal** | 400–600 |
| **Presupuesto Arquitectura** | 600–800 |
| **Frecuencia** | Siempre presente |
| **Prioridad** | 🔴 Alta |

**Contenido mínimo:**
1. Nombre canonical del proyecto (`opencode-architecture`).
2. Store real (`C:\Users\harry\.engram\engram.db`).
3. Estado validado de E6B y Suite F (PASS/FAIL).
4. Proyectos legacy conocidos y su estado (ej. `arquitectura-ia`).
5. Riesgos activos conocidos.
6. Directorio de trabajo, fecha, plataforma.

**Criterios de inclusión:** Siempre.

**Criterios de exclusión:** Solo si la tarea no requiere identidad de proyecto (imposible en la práctica).

**Riesgo si falta:** 🟡 Operaciones en proyecto incorrecto, contexto cruzado.

**Riesgo si sobra:** 🟢 Bajo — información compacta (~75–125 tokens de env info).

**Fallback:** Usar `mem_current_project` para obtener identidad.

**Estrategia F2:** Mantener minimal. Environment Info (~100 tokens) ya es óptimo.

---

## L2 — Estado activo de trabajo

**Propósito:** Establecer qué se está haciendo, por qué y bajo qué restricciones.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | Manager Protocol (secc. operativa), Tool Schemas core, Available Skills block |
| **Clasificación F1** | KEEP_FIXED (Manager) + COMPACT_FIXED (Skills) + RETRIEVE_ON_DEMAND (Tools core) |
| **Tokens objetivo (F2)** | 600–1,200 |
| **Tokens máximos (F2)** | 1,500 |
| **Presupuesto Simple** | 400–600 |
| **Presupuesto Normal** | 600–1,200 |
| **Presupuesto Arquitectura** | 1,200–1,500 |
| **Frecuencia** | Cada nueva tarea o cambio de fase |
| **Prioridad** | 🟡 Alta |
| **Quick wins aplicables** | QW#2 (Tool Schemas Bajo Demanda), QW#5 (Skills Selectivos) |

**Contenido mínimo:**
1. Fase actual del proyecto.
2. Objetivo de la tarea actual.
3. Decisiones vigentes que afectan la tarea.
4. Restricciones operativas activas.
5. Próximo paso acordado.
6. Tools core disponibles: read, write, edit, bash, glob, grep.
7. Available skills compactados (solo trigger keywords).

**Criterios de inclusión:** Siempre que haya una tarea activa.

**Criterios de exclusión:** Solo en modo Simple donde no hay estado de proyecto.

**Riesgo si falta:** 🟡 Contexto incorrecto, decisiones desalineadas, restricciones ignoradas.

**Riesgo si sobra:** 🟢 Bajo — pero puede inflarse si se incluyen decisiones irrelevantes.

**Fallback:** Preguntar al usuario cuál es el estado activo.

**Estrategia F2:** Tool schemas core siempre disponibles (6 tools). El resto bajo demanda según fase SDD. Available Skills con descripciones <10 palabras.

---

## L3 — Contexto recuperado desde Engram

**Propósito:** Proveer memorias relevantes del proyecto para informar la respuesta.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | Engram Memories (retrieved via mem_context) |
| **Clasificación F1** | RANK_AND_LIMIT |
| **Tokens objetivo (F2)** | 2,000–3,500 |
| **Tokens máximos (F2)** | 4,000 |
| **Presupuesto Simple** | 1,000–1,500 (top-3) |
| **Presupuesto Normal** | 2,000–3,500 (top-5) |
| **Presupuesto Arquitectura** | 3,500–4,500 (top-8) |
| **Frecuencia** | Cada tarea, con ranking dinámico |
| **Prioridad** | 🟢 Media (depende de la tarea) |
| **Quick wins aplicables** | QW#4 (Memorias Rankeadas + Top-K) |

**Contenido mínimo:**
1. Memorias rankeadas por relevancia (top-k).
2. Proyecto exact match (`scope=project`, `--project=opencode-architecture`).
3. Tipos de memoria priorizados: `architecture` (score 1.0), `decision` (1.0), `bugfix` (0.8).
4. Memorias deduplicadas (contenido similar → solo la más reciente/de mayor score).
5. Exclusión de sesiones legacy salvo riesgo histórico.
6. Score compuesto: relevancia(0.5) + recencia(0.3) + tipo(0.2).

**Ver selector detallado en:** `mem-context-selector-design.md`

**Criterios de inclusión:** Si hay memorias relevantes con score > umbral mínimo (0.3 modo Normal, 0.5 modo Simple).

**Criterios de exclusión:** 
- Memorias de proyectos legacy.
- Memorias con secretos (patrones `ghp_`, `token=`, `password`).
- Memorias con score < umbral.
- Memorias duplicadas (solo la más reciente o de score más alto).

**Riesgo si falta:** 🟡 Contexto histórico ausente, decisiones previas ignoradas.

**Riesgo si sobra:** 🟡 Infla tokens innecesariamente, ruido en la respuesta.

**Fallback:** Si `mem_context` vacío → omitir L3. Si resultados insuficientes → búsqueda adicional (L5). Si aún así vacío, reportar "Sin contexto histórico relevante".

**Estrategia F2:** F3 implementará el pipeline completo de selección. Top-k por modo definido en F2 contract.

---

## L4 — Historial reciente mínimo

**Propósito:** Proveer continuidad entre iteraciones de la misma sesión.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | Session History (compactado), AGENTS.md — Engram Protocol |
| **Clasificación F1** | COMPACT_FIXED (Session) + DEDUPLICATE (Engram Protocol) |
| **Tokens objetivo (F2)** | 600–1,200 |
| **Tokens máximos (F2)** | 1,500 |
| **Presupuesto Simple** | — (sin L4 en modo Simple) |
| **Presupuesto Normal** | 600–1,200 |
| **Presupuesto Arquitectura** | 1,200–1,500 |
| **Frecuencia** | Cada iteración |
| **Prioridad** | 🟡 Media |
| **Quick wins aplicables** | QW#1 (Session History Compactado) |

**Contenido mínimo:**
1. Últimos 3 turns crudos (máxima precisión para contexto inmediato).
2. Turns 4–10 resumidos en 1–2 líneas cada uno.
3. Turns 11+ resumen acumulativo.
4. Últimas decisiones tomadas (1-2).
5. Último resultado validado.
6. Próximo paso acordado.
7. Evidencia crítica reciente.

**Criterios de inclusión:** Si hay historial de la sesión actual.

**Criterios de exclusión:** 
- Modo Simple (no incluye L4).
- Sesiones legacy.
- Iteraciones sin decisiones relevantes.
- AGENTS.md Engram Protocol se referencia desde Manager protocol (se evita duplicación).

**Riesgo si falta:** 🟢 Bajo — repetición de decisiones, pérdida de continuidad.

**Riesgo si sobra:** 🟡 Infla tokens con historial redundante.

**Fallback:** Usar `engram timeline` para obtener resumen de última sesión.

**Estrategia F2:** Mantener últimos 3 turns crudos. Compactar el resto. AGENTS.md Engram Protocol permanece fijo (es instrucción de memoria, no duplicar).

---

## L5 — Contexto bajo demanda

**Propósito:** Proveer expansión controlada cuando la tarea lo requiere.

| Aspecto | Detalle |
|---------|---------|
| **Fuentes F1** | AGENTS.md — Design Skills, Skills Content, Tool Schemas extendidos, Project Docs, README, Fase F Docs |
| **Clasificación F1** | RETRIEVE_ON_DEMAND |
| **Tokens objetivo (F2)** | 500–1,000 |
| **Tokens máximos (F2)** | 2,000 |
| **Presupuesto Simple** | — (sin L5) |
| **Presupuesto Normal** | — (sin L5 en default) |
| **Presupuesto Arquitectura** | 500–1,000 |
| **Presupuesto Auditoría** | 1,000–1,500 |
| **Frecuencia** | Solo cuando la tarea lo requiere |
| **Prioridad** | 🔵 Baja — solo bajo demanda |

**Contenido mínimo:**
1. AGENTS.md — Design Skills Protocol (solo tareas frontend).
2. Skills Content vía skill tool (solo cuando Manager invoca un skill).
3. Tool Schemas extendidos (solo cuando la fase SDD los requiere).
4. Resultados de búsqueda adicional en Engram.
5. Lectura de archivos/documentos específicos (Project Docs, README, Fase F Docs).
6. Web fetch / web search (solo cuando la tarea requiere info externa).

**Criterios de inclusión:** Solo si L3 es insuficiente y la tarea justifica la expansión.

**Criterios de exclusión:** 
- Modo Simple y Normal (no incluyen L5 por default).
- Tareas que L0-L4 cubren completamente.
- Si excede el presupuesto del modo actual sin justificación.

**Riesgo si falta:** 🟢 Bajo — se cae a fallback / se pide más contexto.

**Riesgo si sobra:** 🟡 Expansión innecesaria que infla tokens.

**Fallback:** Preguntar al usuario si necesita más contexto.

**Estrategia F2:** L5 es solo bajo demanda. Los context packs definen qué se carga y cuándo. La activación de L5 debe justificarse (automáticamente por fase SDD o manualmente por Manager).

---

## Resumen de capas

| Capa | Nombre | Tokens (Normal) | Prioridad | Siempre presente | Fuentes F1 |
|:----:|--------|:---------------:|:---------:|:----------------:|------------|
| L0 | Core rules | 1,000–1,200 | 🔴 Crítica | ✅ Siempre | Manager Protocol (reglas), AGENTS.md Persona, OpenCode Core |
| L1 | Project identity | 400–600 | 🔴 Alta | ✅ Siempre | Manager Protocol (identidad), Environment Info |
| L2 | Active state | 600–1,200 | 🟡 Alta | ✅ Casi siempre | Manager Protocol (operativa), Tools core, Available Skills |
| L3 | Retrieved memory | 2,000–3,500 | 🟢 Media | ❌ Ranking dinámico | Engram Memories (ranked, deduped) |
| L4 | Recent history | 600–1,200 | 🟡 Media | ❌ Si hay historial | Session History (compactado), AGENTS.md Engram Protocol |
| L5 | On-demand | 500–1,000 | 🔵 Baja | ❌ Solo demanda | Design Skills, Skills Content, Tools extendidos, Project Docs |
| Buffer | Working space | 1,500–2,500 | 🟡 Holgura | ✅ | — |

### Presupuestos por modo

| Capa | Simple (6k–8.5k) | Normal (8.5k–12k) | Arquitectura (12k–16k) | Auditoría (16k–22k) |
|:----:|:-----------------:|:------------------:|:----------------------:|:-------------------:|
| L0 | 800–1,000 | 1,000–1,200 | 1,200–1,500 | 1,500 |
| L1 | 300–400 | 400–600 | 600–800 | 800 |
| L2 | 400–600 | 600–1,200 | 1,200–1,500 | 1,500 |
| L3 | 1,000–1,500 | 2,000–3,500 | 3,500–4,500 | 4,500–6,000 |
| L4 | — | 600–1,200 | 1,200–1,500 | 1,500–2,000 |
| L5 | — | — | 500–1,000 | 1,000–1,500 |
| Buffer | 1,200–1,500 | 1,500–2,500 | 2,500–3,000 | 3,000–4,000 |

---

_Fin de context-layers-design.md — Enhanced with F1/F2 data. F2 budget contract authoritative._
