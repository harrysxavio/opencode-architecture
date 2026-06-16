# mem_context Selector Design

**Estado:** ✅ ENHANCED WITH F2 DATA (pseudocode, scoring verification, budget alignment)  
**Propósito:** Definir cómo se seleccionan, rankean, filtran y presentan las memorias de Engram para minimizar tokens mientras se maximiza relevancia.

> Este diseño fue actualizado con los datos de F2. Incluye pseudocódigo del pipeline completo, verificación metodológica del scoring, y alineación de top-k con budgets por modo.

---

## Visión general

El selector de memorias reemplaza la inclusión de todo el contexto de Engram por un proceso de:

1. **Búsqueda**: query semántica contra Engram.
2. **Ranking**: scoring por relevancia, recencia, tipo.
3. **Filtro**: project exact match, exclusión legacy, score mínimo.
4. **Deduplicación**: eliminar observaciones redundantes.
5. **Top-k**: limitar a las N más relevantes.
6. **Presentación**: formatear como contexto compacto.

### Pseudocódigo del pipeline completo

```
function select_memories(task, mode):
    # 1. Construir query
    query = build_query(task, mode)
    
    # 2. Buscar en Engram
    results = engram_search(
        query=query,
        project="opencode-architecture",
        scope="project",
        limit=20,           # siempre pedir suficientes para ranking
        types=["architecture", "decision", "bugfix", "config", 
               "discovery", "session_summary"]
    )
    
    if results is empty:
        return fallback_search(task)   # → L5
    
    # 3. Ranking / Scoring
    scored = []
    for obs in results:
        score = (
            relevance_score(obs, task) * 0.5 +
            recency_score(obs)         * 0.3 +
            type_score(obs.type)       * 0.2
        )
        scored.append((obs, score))
    
    # 4. Filtro
    filtered = [
        (obs, score) for (obs, score) in scored
        if score >= threshold[mode]         # threshold mínimo
        and obs.project == "opencode-architecture"
        and not contains_sensitive(obs.content)
        and obs.scope != "legacy"           # excluir legacy
    ]
    
    if filtered is empty:
        return fallback_search(task)
    
    # 5. Deduplicación semántica
    deduped = semantic_dedup(filtered)
    # Si contenido similar → solo el de score más alto
    
    # 6. Top-k
    k = get_k_for_mode(mode)
    top_k = deduped[:k]  # ordenado por score descendente
    
    # 7. Formatear
    return format_context(top_k)


function build_query(task, mode):
    keywords = extract_keywords(task)  # sustantivos + verbos principales
    if keywords is empty:
        keywords = ["opencode-architecture", "current_state"]
    if mode == "Simple":
        keywords += ["decision", "architecture"]
    return " ".join(keywords[:10])  # max 10 palabras


function get_k_for_mode(mode):
    match mode:
        "Simple":       return 3
        "Normal":       return 5
        "Arquitectura": return 8
        "Auditoría":    return 12
        "Excepcional":  return 20


function get_threshold(mode):
    match mode:
        "Simple":       return 0.5
        "Normal":       return 0.3
        "Arquitectura": return 0.2
        "Auditoría":    return 0.1
        "Excepcional":  return 0.0
```

### Verificación metodológica del scoring

El scoring compuesto se basa en 3 dimensiones. La siguiente tabla muestra cómo se verifica cada una:

| Dimensión | Peso | Método de verificación | Riesgo si incorrecto |
|:---------:|:----:|------------------------|:--------------------:|
| **Relevancia** | 0.5 | Extraer keywords de la tarea actual. Si hay match exacto en título → 1.0. Match parcial → 0.7. Match de fase/proyecto → 0.5. | 🟡 Si el keyword extraction es pobre, el ranking pierde precisión |
| **Recencia** | 0.3 | Timestamp de la observación. Últimas 24h → 1.0. Última semana → 0.8. Último mes → 0.5. >1 mes → 0.3. >3 meses → 0.1. | 🟢 Bajo — la recencia se puede verificar empíricamente |
| **Tipo** | 0.2 | Mapeo fijo de tipo → score (ver tabla tipos). | 🟢 Bajo — es un mapeo estático |

**Validación cruzada:** Ejecutar el selector sobre memorias conocidas (ej. #404 "E6B Noise Gate", #427 "Suite F") y verificar que el score refleja la relevancia esperada.

### Budget alignment con F2

| Modo | top-k | Threshold | Tokens target (L3) | Tokens máx (L3) |
|:----:|:-----:|:---------:|:------------------:|:----------------:|
| Simple | 3 | 0.5 | 1,000–1,500 | 2,000 |
| Normal | 5 | 0.3 | 2,000–3,500 | 4,000 |
| Arquitectura | 8 | 0.2 | 3,500–4,500 | 6,000 |
| Auditoría | 12 | 0.1 | 4,500–6,000 | 8,000 |
| Excepcional | 20 | 0.0 | 6,000–10,000 | 12,000 |

> Budgets definidos en `F2-context-budget-contract.md` y validados en `context-layers-design.md`.

---

## Pipeline de selección

```
Input: Tarea/query actual
  │
  ▼
┌──────────────────────┐
│  1. Construir query   │  ← extraer keywords de la tarea
│     de búsqueda       │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  2. Buscar en Engram  │  ← engram search con --project=canonical
│     con proyecto fijo │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  3. Ranking           │  ← score = f(relevancia, recencia, tipo)
│     scoring           │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  4. Filtro            │  ← project match, score mínimo, sin legacy
│     de resultados     │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  5. Deduplicación     │  ← contenido similar → solo el más reciente
│     semántica         │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  6. Top-k             │  ← k=5 para Normal, k=10 para Arquitectura
│     limit             │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  7. Formatear salida  │  ← compacto: título + 1 línea de contenido
│     como contexto     │
└──────────┬───────────┘
           ▼
    Output: Contexto Engram optimizado
```

---

## 1. Construcción de query

La query de búsqueda se construye a partir de:

- **Keywords de la tarea actual**: extraer sustantivos y verbos principales.
- **Fase actual del proyecto**: incluir como contexto adicional.
- **Tipo de memoria preferido**: architecture, decision, bugfix, config.

**Reglas:**
- Si la tarea tiene keywords claras → usarlas como query.
- Si la tarea es vaga → usar fase actual + "architecture" + "decision".
- Si no hay keywords → usar "opencode-architecture" + "current state".
- Limitar query a 5-10 palabras.

---

## 2. Búsqueda en Engram

**Parámetros fijos:**

| Parámetro | Valor | Razón |
|-----------|:-----:|-------|
| `--project` | `opencode-architecture` | Evitar cross-project |
| `--limit` | 20 | Obtener suficientes para ranking |
| `--scope` | `project` | Solo observaciones del proyecto |

**Parámetros variables:**

| Parámetro | Default | Expansión |
|-----------|:-------:|-----------|
| `--type` | architecture,decision,bugfix,config | Todos los tipos si resultados < k |

---

## 3. Scoring / Ranking

Cada observación recibe un score compuesto:

```
score = (relevancia × 0.5) + (recencia × 0.3) + (tipo × 0.2)
```

### Relevancia (0.0 – 1.0)
- Match exacto de keywords en título o contenido → 1.0
- Match parcial de keywords → 0.7
- Match de fase o proyecto → 0.5
- Sin match relevante → 0.2

### Recencia (0.0 – 1.0)
- Últimas 24h → 1.0
- Última semana → 0.8
- Último mes → 0.5
- Más de 1 mes → 0.3
- Más de 3 meses → 0.1

### Tipo (0.0 – 1.0)
| Tipo | Score | Razón |
|------|:-----:|-------|
| `architecture` | 1.0 | Decisiones de alto nivel |
| `decision` | 1.0 | Decisiones activas |
| `bugfix` | 0.8 | Lecciones aprendidas |
| `config` | 0.7 | Configuraciones relevantes |
| `discovery` | 0.6 | Hallazgos técnicos |
| `session_summary` | 0.5 | Resumen de sesión |
| `pattern` | 0.7 | Patrones establecidos |
| `preference` | 0.6 | Preferencias del usuario |

---

## 4. Filtro de resultados

### Criterios de inclusión

- `project == "opencode-architecture"` (exact match).
- `score >= 0.3` (mínimo de relevancia).
- Tipo en lista permitida (architecture, decision, bugfix, config, discovery, session_summary).
- Contenido sin patrones sensibles.

### Criterios de exclusión

- `project != "opencode-architecture"` → excluir (salvo riesgo histórico justificado).
- `score < 0.3` → excluir.
- Contenido con `ghp_`, `secret`, `password`, `token=` → redactar o excluir.
- Observaciones de sesiones legacy (`arquitectura opencode`).
- Duplicados semánticos (solo el más reciente).

### Manejo de legado

- Las sesiones legacy (`arquitectura opencode`, `arquitectura-ia`) NO deben incluirse en el contexto activo.
- Solo se mencionan como riesgo histórico si son relevantes para la tarea actual.
- Si una tarea menciona explícitamente el legado, se permite búsqueda separada con advertencia.

---

## 5. Deduplicación semántica

### Estrategia

1. Agrupar observaciones por tema similar.
2. Del mismo tema, conservar solo la más reciente o la de mayor score.
3. Temas similares detectados por: mismo título normalizado, mismo `topic_key`, contenido overlapping >60%.

### Ejemplo

```
Obs #402: "E4B completada — Engram estabilizado"
Obs #404: "E6B-safe implementado — Noise Gate"
Obs #421: "Diseñada suite F"
```

No hay duplicación → se conservan las 3.

```
Obs #420: "E6B-T3 PASS from canonical session" (bugfix)
Obs #419: "Session summary..." (session_summary, contiene info de T3)
```

Si el contenido de #419 cubre lo mismo que #420 → deduplicar, conservar #420.

---

## 6. Top-k limit

| Modo | k máximo | Threshold mínimo | Tokens estimados |
|:----:|:--------:|:----------------:|:----------------:|
| Simple | 3 | 0.5 | ~1,000–1,500 |
| Normal | 5 | 0.3 | ~2,000–3,500 |
| Arquitectura | 8 | 0.2 | ~3,500–4,500 |
| Auditoría | 12 | 0.1 | ~4,500–6,000 |
| Excepcional | 20 | 0.0 | ~6,000–10,000 |

### Regla de corte

- Siempre respetar `k` máximo del modo.
- Si hay menos de `k` observaciones con `score >= 0.3`, usar las disponibles (no inventar).
- Si hay más de `k` observaciones, cortar por score descendente.

---

## 7. Formateo de salida

Cada observación se presenta en formato compacto:

```
┌─────────────────────────────────────────┐
│ ● [{tipo}] {título} ({score})           │
│   {contenido — primera línea, max 120c} │
└─────────────────────────────────────────┘
```

**Ejemplo real:**
```
● [architecture] E6B-safe implementado — Noise Gate (0.92)
  Implementado Noise Gate en plugins/engram.ts como clasificador heurístico
```

Si el contenido es muy largo:
```
● [architecture] E4B completada — Engram estabilizado (0.85)
  What: E4B completada: opencode.json y opencode.jsonc modificados...
```

---

## Manejo de casos borde

| Caso | Comportamiento |
|------|----------------|
| **No memories found** | Omitir L3, pasar a L5 (búsqueda adicional). Si L5 también vacío, reportar "Sin contexto histórico relevante". |
| **Cross-project results** | Si `--project` no se usó, los resultados pueden mezclar proyectos. En ese caso, filtrar por `project == canonical`. |
| **Sensitive content in memory** | Redactar o excluir automáticamente. No exponer raw. |
| **Memory with full secret in title** | Excluir completamente. Reportar como "memoria excluida por seguridad". |
| **Too many low-relevance results** | Si score < 0.3 para todos, retornar vacío. No incluir ruido. |
| **Session legacy mencionada** | Solo incluir si la tarea lo pide explícitamente, con advertencia de legacy. |

---

## Fallback para búsqueda adicional (L5)

Si L3 retorna insuficiente contexto:

1. **Expandir query**: usar términos más generales de la tarea.
2. **Expandir tipos**: incluir todos los tipos de observación.
3. **Aumentar k**: +50% sobre el límite del modo.
4. **Suelta el filtro de legacy**: solo si la tarea requiere contexto histórico completo.
5. **Leer archivos**: si Engram no tiene contexto, leer archivos del proyecto directamente.

Cada paso de expansión DEBE justificarse (por qué se necesita más contexto).

---

## Resumen

| Componente | Comportamiento |
|------------|----------------|
| Query | Keywords de tarea + fase actual |
| Búsqueda | `--project=opencode-architecture`, `--limit=20` |
| Score | relevancia(0.5) + recencia(0.3) + tipo(0.2) |
| Filtro | project exact match, score >= 0.3, sin legacy |
| Dedup | Contenido similar → solo el más relevante |
| Top-k | k=5 Normal, k=8 Arquitectura, k=12 Auditoría |
| Formato | Compacto: título + 1 línea de contenido |
| Fallback | Búsqueda expandida → lectura archivos |

---

_Fin de mem-context-selector-design.md_
