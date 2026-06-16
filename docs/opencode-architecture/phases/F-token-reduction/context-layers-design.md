# Context Layers Design

**Propósito:** Definir la arquitectura de contexto por capas (L0 a L5), el propósito de cada capa, su fuente, criterios de inclusión y riesgos.

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
| **Fuente** | System prompt, Manager protocol, AGENTS.md |
| **Tokens objetivo** | 800–1.200 |
| **Tokens máximos** | 1.500 |
| **Frecuencia** | Siempre presente en toda sesión |
| **Prioridad** | 🔴 Crítica — nunca omitir |

**Contenido mínimo:**
1. No exponer secretos, tokens ni credenciales.
2. No escribir en DB sin aprobación.
3. Separación estricta de proyectos.
4. Identidad canonical del proyecto.
5. Restricciones de herramientas (read-only vs write).
6. Prohibición de migrar DB/schema/config sin aprobación.

**Criterios de inclusión:** Siempre. No negociable.

**Criterios de exclusión:** Ninguno. Siempre presente.

**Riesgo si falta:** 🔴 Catastrófico — exposición de secretos, escritura indebida, mezcla de proyectos.

**Riesgo si sobra:** 🟢 Mínimo — reglas compactas, ocupan poco.

**Fallback:** Si no hay espacio para L0 completo, abortar la operación.

---

## L1 — Identidad del proyecto

**Propósito:** Establecer el contexto de proyecto en el que se opera.

| Aspecto | Detalle |
|---------|---------|
| **Fuente** | `mem_current_project`, config de sesión |
| **Tokens objetivo** | 300–600 |
| **Tokens máximos** | 800 |
| **Frecuencia** | Siempre presente |
| **Prioridad** | 🔴 Alta |

**Contenido mínimo:**
1. Nombre canonical del proyecto.
2. Store real (path de DB).
3. Estado validado de E6B y Suite F (PASS/FAIL).
4. Proyectos legacy conocidos y su estado.
5. Riesgos activos conocidos.

**Criterios de inclusión:** Siempre.

**Criterios de exclusión:** Solo si la tarea no requiere identidad de proyecto (imposible en la práctica).

**Riesgo si falta:** 🟡 Operaciones en proyecto incorrecto, contexto cruzado.

**Riesgo si sobra:** 🟢 Bajo — información compacta.

**Fallback:** Usar `mem_current_project` para obtener identidad.

---

## L2 — Estado activo de trabajo

**Propósito:** Establecer qué se está haciendo, por qué y bajo qué restricciones.

| Aspecto | Detalle |
|---------|---------|
| **Fuente** | Tarea actual, instrucciones del usuario, fase activa |
| **Tokens objetivo** | 600–1.200 |
| **Tokens máximos** | 1.500 |
| **Frecuencia** | Cada nueva tarea o cambio de fase |
| **Prioridad** | 🟡 Alta |

**Contenido mínimo:**
1. Fase actual del proyecto.
2. Objetivo de la tarea actual.
3. Decisiones vigentes que afectan la tarea.
4. Restricciones operativas activas.
5. Próximo paso acordado.

**Criterios de inclusión:** Siempre que haya una tarea activa.

**Criterios de exclusión:** Solo en modo Simple donde no hay estado de proyecto.

**Riesgo si falta:** 🟡 Contexto incorrecto, decisiones desalineadas, restricciones ignoradas.

**Riesgo si sobra:** 🟢 Bajo — pero puede inflarse si se incluyen decisiones irrelevantes.

**Fallback:** Preguntar al usuario cuál es el estado activo.

---

## L3 — Contexto recuperado desde Engram

**Propósito:** Proveer memorias relevantes del proyecto para informar la respuesta.

| Aspecto | Detalle |
|---------|---------|
| **Fuente** | `engram search` / `mem_context` |
| **Tokens objetivo** | 2.000–3.500 |
| **Tokens máximos** | 4.000 |
| **Frecuencia** | Cada tarea, con ranking dinámico |
| **Prioridad** | 🟢 Media (depende de la tarea) |

**Contenido mínimo:**
1. Memorias rankeadas por relevancia (top-k).
2. Proyecto exact match (no cross-project).
3. Tipos de memoria priorizados: `architecture`, `decision`, `bugfix`.
4. Memorias deduplicadas.
5. Exclusión de sesiones legacy salvo riesgo histórico.

**Ver selector detallado en:** `mem-context-selector-design.md`

**Criterios de inclusión:** Si hay memorias relevantes con score > umbral mínimo.

**Criterios de exclusión:** 
- Memorias de proyectos legacy.
- Memorias con secretos.
- Memorias con score bajo.
- Memorias duplicadas (solo la más reciente o relevante).

**Riesgo si falta:** 🟡 Contexto histórico ausente, decisiones previas ignoradas.

**Riesgo si sobra:** 🟡 Infla tokens innecesariamente, ruido en la respuesta.

**Fallback:** Si `mem_context` vacío → omitir L3. Si resultados insuficientes → búsqueda adicional (L5).

---

## L4 — Historial reciente mínimo

**Propósito:** Proveer continuidad entre iteraciones de la misma sesión.

| Aspecto | Detalle |
|---------|---------|
| **Fuente** | Session summary, últimas observaciones |
| **Tokens objetivo** | 600–1.200 |
| **Tokens máximos** | 1.500 |
| **Frecuencia** | Cada iteración |
| **Prioridad** | 🟢 Media |

**Contenido mínimo:**
1. Últimas decisiones tomadas (1-2).
2. Último resultado validado.
3. Próximo paso acordado.
4. Evidencia crítica reciente.

**Criterios de inclusión:** Si hay historial de la sesión actual.

**Criterios de exclusión:** 
- Sesiones legacy.
- Iteraciones sin decisiones relevantes.

**Riesgo si falta:** 🟢 Bajo — repetición de decisiones, pérdida de continuidad.

**Riesgo si sobra:** 🟡 Infla tokens con historial redundante.

**Fallback:** Usar `engram timeline` para obtener resumen de última sesión.

---

## L5 — Contexto bajo demanda

**Propósito:** Proveer expansión controlada cuando la tarea lo requiere.

| Aspecto | Detalle |
|---------|---------|
| **Fuente** | `engram search`, lectura de archivos, web fetch |
| **Tokens objetivo** | 500–1.000 |
| **Tokens máximos** | 2.000 |
| **Frecuencia** | Solo cuando la tarea lo requiere |
| **Prioridad** | 🔵 Baja — solo bajo demanda |

**Contenido mínimo:**
1. Resultados de búsqueda adicional en Engram.
2. Lectura de archivos/documentos específicos.
3. Contexto expandido para tareas complejas.

**Criterios de inclusión:** Solo si L2 o L3 son insuficientes.

**Criterios de exclusión:** 
- Tareas simples que L0-L4 cubren.
- Si excede el presupuesto del modo actual sin justificación.

**Riesgo si falta:** 🟢 Bajo — se cae a fallback / se pide más contexto.

**Riesgo si sobra:** 🟡 Expansión innecesaria que infla tokens.

**Fallback:** Preguntar al usuario si necesita más contexto.

---

## Resumen de capas

| Capa | Nombre | Tokens (Normal) | Prioridad | Siempre presente |
|:----:|--------|:---------------:|:---------:|:----------------:|
| L0 | Core rules | 800–1.200 | 🔴 Crítica | ✅ Siempre |
| L1 | Project identity | 300–600 | 🔴 Alta | ✅ Siempre |
| L2 | Active state | 600–1.200 | 🟡 Alta | ✅ Casi siempre |
| L3 | Retrieved memory | 2.000–3.500 | 🟢 Media | ❌ Ranking dinámico |
| L4 | Recent history | 600–1.200 | 🟢 Media | ❌ Si hay historial |
| L5 | On-demand | 500–1.000 | 🔵 Baja | ❌ Solo demanda |
| Buffer | Working space | 1.500–2.500 | 🟡 Holgura | ✅ |

---

_Fin de context-layers-design.md_
