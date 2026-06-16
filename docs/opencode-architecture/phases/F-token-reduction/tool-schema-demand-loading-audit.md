# Tool Schema Demand-Loading Audit — F2

**Estado:** ✅ AUDIT COMPLETED (2026-06-16)  
**Propósito:** Evaluar la viabilidad técnica y el diseño de cargar tool schemas bajo demanda, identificando las 16 herramientas, su frecuencia de uso, dependencias y modelo de carga.

---

## Executive Summary

Las 16 tool schemas se cargan completos en cada turno (~3,200–6,400 tokens), pero solo 3–5 se usan por turno típico. El ahorro potencial es de **~2,000–4,000 tokens por turno** al cargar solo las herramientas necesarias.

**Decisión:** Depende de si OpenCode runtime soporta tool loading dinámico o selectivo. Este documento audita la viabilidad y propone el diseño.

---

## 1. Catálogo de herramientas

Se identificaron **16 herramientas** cargadas siempre en el system prompt:

| # | Tool | Frecuencia | Grupo | Dependencias |
|:-:|------|:----------:|:-----:|:------------:|
| 1 | `read` | ~100% | Core | Ninguna |
| 2 | `write` | ~100% | Core | Ninguna |
| 3 | `edit` | ~100% | Core | Ninguna |
| 4 | `bash` | ~100% | Core | Ninguna |
| 5 | `glob` | ~100% | Core | Ninguna |
| 6 | `grep` | ~100% | Core | Ninguna |
| 7 | `task` | ~50% | SDD | Ninguna |
| 8 | `skill` | ~40% | SDD | Ninguna |
| 9 | `todowrite` | ~40% | SDD | Ninguna |
| 10 | `delegate` | ~30% | SDD | Ninguna |
| 11 | `webfetch` | ~25% | Investigación | Ninguna |
| 12 | `websearch` | ~20% | Investigación | Ninguna |
| 13 | `context7_query-docs` | ~15% | BigQuery | context7_resolve-library-id |
| 14 | `context7_resolve-library-id` | ~10% | BigQuery | Ninguna |
| 15 | `delegation_list` | ~5% | Admin | delegate |
| 16 | `delegation_read` | ~5% | Admin | delegate |

### Grupo Core (6 tools, ~100% frecuencia)
read, write, edit, bash, glob, grep — siempre necesarias.

### Grupo SDD (4 tools, ~30–50% frecuencia)
task, skill, todowrite, delegate — según fase del SDD.

### Grupo Investigación (3 tools, ~15–25% frecuencia)
webfetch, websearch, context7_query-docs — solo cuando se busca información externa.

### Grupo Admin (3 tools, ~5–30% frecuencia)
context7_resolve-library-id, delegation_list, delegation_read — solo en tareas específicas.

---

## 2. Frecuencia real vs carga actual

| Categoría | Tools | Carga actual | Carga propuesta | Ahorro |
|:----------|:----:|:------------:|:---------------:|:------:|
| Core (siempre) | 6 | ✅ Siempre | ✅ Siempre | — |
| SDD (según fase) | 4 | ✅ Siempre | ❌ Por fase | ~800–1,600 |
| Investigación | 3 | ✅ Siempre | ❌ Bajo demanda | ~600–1,200 |
| Admin | 3 | ✅ Siempre | ❌ Bajo demanda | ~600–1,200 |
| **Total** | 16 | **~3,200–6,400** | **~800–2,000** | **~2,000–4,000** |

---

## 3. Modelo de carga propuesto

### Carga por fase SDD

| Fase SDD | Tools a cargar |
|:---------|:---------------|
| **Siempre (core)** | read, write, edit, bash, glob, grep |
| **SDD Explore** | core + task, delegate |
| **SDD Propose/Spec/Design** | core + task |
| **SDD Tasks** | core + task, todowrite |
| **SDD Apply** | core + task, skill, todowrite |
| **SDD Verify** | core + bash, task |
| **SDD Archive** | core + task |
| **No SDD activo** | core (6) |

### Carga por tipo de tarea

| Tipo de tarea | Tools adicionales |
|:--------------|:------------------|
| BigQuery / Data | context7_query-docs, context7_resolve-library-id |
| Investigación externa | webfetch, websearch |
| Debugging | bash (completo), task, delegate |
| Revisión / Code Review | task, delegate |
| Auditoría | delegate, delegation_list, delegation_read |

---

## 4. Viabilidad técnica

### Opción A: Tool loading dinámico vía runtime de OpenCode

| Aspecto | Detalle |
|---------|---------|
| **¿Soportado por OpenCode?** | ⚠️ **No verificado.** Requiere investigación. |
| **Depende de** | API de OpenCode para tool schemas selectivos |
| **Riesgo** | 🟡 Medio — si no está soportado, no se puede implementar |
| **Mitigación** | Preguntar a maintainers de OpenCode o revisar documentación |

### Opción B: Tool loading vía plugin interceptor

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | Plugin que intercepta la carga de tool schemas y filtra según fase |
| **Complejidad** | Alta — requiere modificar cómo OpenCode carga el system prompt |
| **Riesgo** | 🔴 Alto — puede romper el pipeline de carga |
| **Mitigación** | Feature flag + regression plan obligatorio |

### Opción C: Tool loading por decisión del Manager (recomendada para F3)

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | El Manager decide qué tools cargar según la fase/tarea y las invoca bajo demanda |
| **Complejidad** | Media — requiere lógica de clasificación en el Manager |
| **Riesgo** | 🟡 Medio — si la clasificación falla, Manager no tiene la tool disponible |
| **Mitigación** | Lazy load: si la tool no está cargada, cargarla + reintentar |

### Recomendación

**Opción C para F3: carga bajo demanda por decisión del Manager.** El Manager conoce la fase SDD y el tipo de tarea, por lo que puede determinar qué tools necesita. Implementar lazy loading como fallback: si Manager invoca una tool no cargada, cargarla en el momento.

Las herramientas core (6) siempre cargadas. El resto bajo demanda.

---

## 5. Lazy loading design

```
1. Manager identifica fase SDD → determina tools necesarias
2. Si la tool ya está cargada → usarla directamente
3. Si la tool NO está cargada:
   a. Manager solicita carga de tool schema
   b. Espera confirmación de carga
   c. Reintenta la operación
   d. Si falla, log "Tool X not available" y continúa con alternativa
```

### Cache de tools cargadas

- Mantener herramientas cargadas durante toda la sesión (no recargar por turno).
- Si una herramienta se cargó una vez, sigue disponible.
- Cleanup solo al iniciar nueva sesión.

---

## 6. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Tool necesaria no cargada por clasificación incorrecta | Media | Alto | Lazy load + reintento |
| Más tools cargadas de las necesarias por clasificación amplia | Media | Bajo | Manager puede afinar clasificación en runtime |
| Runtime no soporta carga dinámica | Media | Alto | Opción B o C: cargar todo pero con schemas compactados (sin descripciones largas) |
| Lazy load introduce latencia | Media | Bajo | Cache de tools cargadas por sesión |

---

## 7. Pruebas recomendadas

| Test | Qué validaría |
|:----:|---------------|
| T1-Tcore | Tools core (6) siempre disponibles en toda fase |
| T2-Tfase | Tools de fase cargadas correctamente según clasificación |
| T3-Tfallback | Fallback lazy load funciona cuando tool no está cargada |
| T4-Tlatencia | Latencia de lazy load aceptable (< 500ms) |
| T5-Ttoken | Reducción de tokens verificable (~2k–4k) |
| T6-Tregresion | Sin regresión en tareas de todos los tamaños (Tiny, Small, Medium, Large) |

---

## 8. Referencias

- F1: Context Source Catalog → Tool Schemas (#6)
- F1: Duplication Map → D7 (Tool schemas derrochable)
- F1: Quick Wins Analysis → QW#2
- F2: Context Budget Contract → L2/L5 budgets
- F2: Context Packs Design → TOOLING_PACK

---

*Fin de tool-schema-demand-loading-audit.md — F2 COMPLETED. Diseño de carga bajo demanda para tool schemas.*
