# Quick Wins Analysis — F1

**Estado:** ✅ COMPLETED (F1)  
**Fecha:** 2026-06-16  
**Propósito:** Profundizar los quick wins identificados en F0, analizando beneficio, riesgo, dependencias y secuencia recomendada.

---

## Quick Win 1: Session History Compactado

### Descripción
Reemplazar turns antiguos del historial de conversación con resúmenes estructurados, manteniendo los últimos 3–5 turns en crudo para precisión inmediata.

### Estado actual
- Session history completo: ~5,000–8,000 tokens por sesión típica
- En sesiones largas (+20 turns): puede superar 10,000 tokens
- No hay diferenciación entre turns recientes (necesitan precisión) y antiguos (pueden resumirse)

### Propuesta concreta
| Turno | Acción |
|:-----:|--------|
| Últimos 1-3 | Mantener crudos (máxima precisión para el contexto inmediato) |
| Turns 4-10 | Resumen de 1-2 líneas por turno: qué pidió el usuario, qué se respondió |
| Turns 11+ | Resumen acumulativo: "El usuario pidió X, Y, Z. Se implementaron A, B. Queda pendiente C." |

### Beneficio estimado
- **Ahorro**: ~3,000–5,000 tokens por sesión (37–62% del presupuesto actual de session history)
- **Objetivo**: ~1,500–2,500 tokens

### Complejidad
| Aspecto | Valor |
|---------|:-----:|
| Esfuerzo de implementación | Medio |
| ¿Requiere código nuevo? | Sí — lógica de compactación en runtime |
| ¿Requiere cambios en plugin? | No |
| ¿Requiere cambios en DB? | No |
| ¿Requiere cambios en config? | Posiblemente (feature flag) |

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Resumen pierde detalle crítico | Baja | Medio | Mantener últimos 3 turns crudos |
| Resumen alucina información | Baja | Medio | Usar template estructurado, no generación libre |
| Mayor latencia por generación de resúmenes | Media | Bajo | Resumir asíncronamente, cachear resultado |

### Dependencias
- Ninguna bloqueante. Se puede implementar independientemente.
- Ideal después de F0 (completado) y F1 (en curso).
- Recomendado para F2 o F3.

### Pruebas necesarias
| Test | Qué validaría |
|:----:|---------------|
| QW1-T1 | Resumen conserva decisiones clave del turno original |
| QW1-T2 | Turns recientes (1-3) se mantienen intactos |
| QW1-T3 | Turns antiguos se reemplazan por resumen |
| QW1-T4 | Manager puede seguir el hilo de la conversación con el resumen |
| QW1-T5 | Calidad de respuesta no se degrada con resumen vs history completo |

### ¿Requiere aprobación?
**Sí** — modifica el contexto que recibe el Manager. Aunque no toca runtime directamente, cambiar cómo se entrega session history puede afectar calidad de respuestas. Requiere validación con Suite F (idempotencia) y tests de regresión.

---

## Quick Win 2: Tool Schemas Bajo Demanda

### Descripción
En lugar de cargar los schemas completos de las 16 herramientas disponibles en cada turno, cargar solo los schemas de herramientas que aplican al turno actual, según la fase SDD o el tipo de tarea.

### Estado actual
- 16 tools cargadas siempre: bash, context7_query-docs, context7_resolve-library-id, delegate, delegation_list, delegation_read, edit, glob, grep, read, skill, task, todowrite, webfetch, websearch, write
- Tools usadas típicamente por turno: 3–5
- Tools básicas siempre necesarias: read, write, edit, bash, glob, grep (~6 tools)

### Propuesta concreta
| Fase SDD / Tipo de tarea | Tools a cargar |
|--------------------------|----------------|
| **Siempre (core)** | read, write, edit, bash, glob, grep |
| **SDD Explore** | + task, delegate |
| **SDD Apply** | + task, skill, todowrite |
| **SDD Verify** | + bash, task |
| **Investigación/BigQuery** | + context7_*, webfetch, websearch |
| **Auditoría** | + delegate, delegation_list, delegation_read |

Las tools no listadas para la fase actual se cargan bajo demanda cuando el Manager las invoca explícitamente.

### Beneficio estimado
- **Ahorro**: ~2,000–4,000 tokens por turno (cargar ~6 tools core + ~2-3 específicas vs 16 completas)
- **Objetivo**: reducir de ~3,200–6,400 a ~1,000–2,000 tokens

### Complejidad
| Aspecto | Valor |
|---------|:-----:|
| Esfuerzo de implementación | Medio-Alto |
| ¿Requiere código nuevo? | Sí — lógica de tool loader selectivo |
| ¿Requiere cambios en runtime? | Depende de si OpenCode soporta tool loading dinámico |
| ¿Requiere cambios en config? | Posiblemente |

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Tool necesaria no está cargada | Media | Alto | Fallback: cargar tool + reintentar; mantener group "todas" como respaldo |
| Clasificación incorrecta de fase | Baja | Medio | El Manager decide la clasificación; si duda, carga grupo completo |
| Mayor latencia | Media | Bajo | Carga perezosa (lazy load) con cache |

### Dependencias
- Requiere entender si el runtime de OpenCode permite tool loading dinámico.
- Puede requerir cambios en `opencode.json` o plugin.

### Pruebas necesarias
| Test | Qué validaría |
|:----:|---------------|
| QW2-T1 | Tools core (6) siempre disponibles |
| QW2-T2 | Tools de fase cargadas correctamente según clasificación |
| QW2-T3 | Fallback funciona si tool no cargada |
| QW2-T4 | Sin regresión en tareas normales (Tiny, Small, Medium, Large) |
| QW2-T5 | Consumo de tokens se reduce en ~2k–4k |

### ¿Requiere aprobación?
**Sí** — cambios en runtime o plugin. Requiere validación exhaustiva.

---

## Quick Win 3: Memorias Rankeadas + Top-K

### Descripción
Implementar ranking semántico de memorias Engram recuperadas, limitar a top-K configurables según modo, y deduplicar contenido redundante.

### Estado actual
- 326 observaciones en DB, 84 relevantes al proyecto
- `mem_context` recupera sin ranking explícito ni límite fijo
- Session summaries dominan (119/326 = 36%) — riesgo de inflar contexto con estado repetido

### Propuesta concreta
| Modo | Top-K | Score mínimo | Acción |
|:----:|:-----:|:------------:|--------|
| Simple | 3 | 0.5 | Solo memorias de alta relevancia |
| Normal | 5 | 0.3 | Balance entre cobertura y tamaño |
| Arquitectura | 10 | 0.2 | Más contexto para decisiones complejas |
| Auditoría | 15 | 0.1 | Máxima cobertura posible |

**Dedup**: si 2+ memorias tienen contenido similar (mismo tema, mismo estado), solo incluir la de score más alto.

### Beneficio estimado
- **Ahorro**: ~500–2,000 tokens por llamada a mem_context
- **Objetivo**: de ~1,250–3,750 a ~800–1,500 tokens

### Complejidad
| Aspecto | Valor |
|---------|:-----:|
| Esfuerzo de implementación | Medio |
| ¿Requiere código nuevo? | Sí — ranking, scoring, top-k, dedup |
| ¿Requiere cambios en Engram? | No (usa mem_search existente) |
| ¿Requiere cambios en DB? | No |

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Score threshold excluye memoria valiosa | Media | Medio | Modo Normal usa threshold bajo (0.3); Auditoría usa 0.1 |
| Dedup elimina memoria con matiz diferente | Baja | Bajo | Dedup solo si contenido es >80% similar |
| Ranking no refleja relevancia real | Media | Alto | Baseline de calidad antes de implementar: comparar top-5 humano vs algoritmo |

### Dependencias
- F0 completado ✅
- F1 en curso
- F2 (budget contract) debe definir top-K por modo
- Se implementa como F3 (mem_context Selector Design & Implementation)

### Pruebas necesarias
| Test | Qué validaría |
|:----:|---------------|
| QW3-T1 | Top-K funciona correctamente en modo Normal (top-5) |
| QW3-T2 | Score threshold filtra memorias irrelevantes |
| QW3-T3 | Dedup no elimina memorias únicas |
| QW3-T4 | Tiempo de respuesta aceptable |
| QW3-T5 | Idempotencia: misma consulta = mismo ranking |

### ¿Requiere aprobación?
**Sí** — es F3 del roadmap. Requiere aprobación de diseño y tests.

---

## Quick Win 4: Skills Selectivos

### Descripción
Reducir el tamaño del bloque `<available_skills>` en el system prompt, acortando descripciones a solo nombre + keywords de activación, y listando solo skills relevantes al contexto del proyecto/tarea.

### Estado actual
- 38 skills listados con descripción de 1-2 líneas (~4,158 chars, ~1,040 tokens)
- Muchas descripciones son genéricas: "Trigger: ..." o "Use when ..."
- Algunas descripciones son largas pero no aportan información de matching

### Propuesta concreta
| Cambio | Descripción |
|--------|-------------|
| Descripciones cortas | Reducir a 5-10 palabras: nombre + trigger keywords |
| Skills por proyecto | En proyecto frontend, no listar skills de data/BigQuery |
| Skills por contexto | En tareas de arquitectura, listar skills de diseño/documentación |

Formato propuesto:
```xml
<skill>
  <name>bigquery-expert</name>
  <description>BigQuery SQL queries, datasets, data analysis</description>
</skill>
```

### Beneficio estimado
- **Ahorro**: ~400–600 tokens (de ~1,040 a ~500–600)
- **Ahorro adicional**: si se filtran skills por proyecto, ~200–400 tokens más

### Complejidad
| Aspecto | Valor |
|---------|:-----:|
| Esfuerzo de implementación | Bajo |
| ¿Requiere código nuevo? | Mínimo — editar descripciones en plugin/runtime |
| ¿Requiere cambios en DB? | No |
| ¿Requiere cambios en config? | No |

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Descripción muy corta no permite matching | Baja | Bajo | Usar trigger keywords precisos |
| Skill no se carga porque descripción no matcha | Baja | Medio | Manager puede invocar skill tool sin depender del bloque |

### Dependencias
- Ninguna. Se puede hacer independientemente.
- Ideal como tarea rápida post-F2.

### Pruebas necesarias
| Test | Qué validaría |
|:----:|---------------|
| QW4-T1 | Manager puede identificar skills correctamente con descripciones cortas |
| QW4-T2 | No hay falsos negativos en skill matching |
| QW4-T3 | Reducción de tokens verificable |

### ¿Requiere aprobación?
**Sí** — cambios en el system prompt afectan el matching de skills. Aprobación rápida (bajo riesgo).

---

## Quick Win 5: Deduplicación Manager Protocol / AGENTS.md

### Descripción
Identificar y eliminar superposición de contenido entre el Manager Protocol (opencode.json) y AGENTS.md. Especialmente: reglas de comportamiento redundantes, referencias duplicadas a Engram.

### Estado actual
- Manager Protocol: 28,471 chars (~7,100–14,200 tokens)
- AGENTS.md: 13,412 chars (~3,400 tokens)
- Ambos cargados secuencialmente como parte del system prompt del Manager agent
- Duplicación identificada: ~200–400 tokens en reglas de comportamiento + ~50–150 tokens en referencias a Engram

### Propuesta concreta
| Cambio | Fuente afectada | Ahorro |
|--------|:---------------:|:------:|
| Compactar sección "Engram" en Manager protocol → referenciar AGENTS.md | Manager protocol | ~100–150 tokens |
| Alinear redacción de reglas duplicadas (sin eliminar) | Manager protocol + AGENTS.md | ~200–400 tokens (por no duplicar concepto) |
| Mover Design Skills Protocol a skill tool (solo frontend) | AGENTS.md | ~1,125 tokens (no es dedup, es retrieve) |

### Beneficio estimado
- **Ahorro directo**: ~300–550 tokens por eliminar duplicación textual
- **Ahorro indirecto**: ~1,125 tokens por mover Design Skills a bajo demanda (no es duplicación, pero se suma)

### Complejidad
| Aspecto | Valor |
|---------|:-----:|
| Esfuerzo de implementación | Bajo-Medio |
| ¿Requiere código nuevo? | Mínimo — editar opencode.json y AGENTS.md |
| ¿Requiere cambios en DB? | No |
| ¿Requiere cambios en config? | Sí — editar opencode.json |

### Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Manager pierde regla importante al compactar | Baja | Alto | Revisión manual diff antes/después |
| Manager no carga Engram protocol si se mueve | Baja | Alto | AGENTS.md Engram protocol debe permanecer fijo |

### Dependencias
- F0 completado ✅
- F1 en curso
- Recomendado para F2 (compactación de protocolo)

### Pruebas necesarias
| Test | Qué validaría |
|:----:|---------------|
| QW5-T1 | Manager behavior no cambia después de compactación |
| QW5-T2 | Reglas de persona se siguen aplicando |
| QW5-T3 | Engram protocol sigue siendo accesible |
| QW5-T4 | Reducción de tokens verificable |

### ¿Requiere aprobación?
**Sí** — modifica el system prompt del Manager. Riesgo alto porque puede afectar comportamiento.

---

## Priorización de Quick Wins

| Prioridad | Quick Win | Ahorro tokens | Esfuerzo | Riesgo | Dependencias | Fase |
|:---------:|-----------|:-------------:|:--------:|:-----:|:------------:|:----:|
| 🔴 1 | Tool schemas bajo demanda | ~2k–4k | Medio-Alto | Medio | Runtime OpenCode | F3 |
| 🟡 2 | Session history compactado | ~3k–5k | Medio | Medio | Ninguna | F2/F3 |
| 🟡 3 | Dedup Manager/AGENTS.md | ~300–550 (+1,125 indirecto) | Bajo-Medio | Medio | Ninguna | F2 |
| 🟢 4 | Memorias rankeadas + top-k | ~500–2k | Medio | Medio | F0, F1, F2 | F3 |
| 🟢 5 | Skills selectivos | ~400–600 | Bajo | Bajo | Ninguna | F2 |

### Secuencia recomendada

```
F2 (ahora)
├── Compactar Manager protocol (QW5)
├── Skills selectivos (QW4)
└── Preparar budget contract

F3 (próximo)
├── Tool schemas bajo demanda (QW1)
├── Session history compactado (QW2)
└── Implementar mem_context Selector (QW3 dedup + ranking)

F4 (después)
├── Context Packs
└── Consolidar quick wins
```

---

## Quick wins NO recomendados para Fase F

| Quick win | Por qué no |
|-----------|------------|
| Eliminar session summaries antiguos de Engram DB | Pérdida de trazabilidad histórica. Mejor dedup en retrieval (F3). |
| Fusionar AGENTS.md en opencode.json | Mayor riesgo de rotura, menor mantenibilidad. |
| Eliminar tool schemas por completo | Manager necesita poder usar todas las tools. El problema es cuándo se cargan, no que existan. |
| Comprimir AGENTS.md eliminando secciones enteras | Cada sección tiene propósito (persona, engram, design). Perdería funcionalidad. |

---

*Fin de quick-wins-analysis.md — F1 COMPLETED. Sin cambios funcionales implementados.*
