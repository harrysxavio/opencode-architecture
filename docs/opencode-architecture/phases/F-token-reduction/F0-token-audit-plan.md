# F0 — Token Audit Baseline

**Propósito:** Medir o estimar de dónde salen los ~40k tokens del contexto actual, separar por fuentes, y documentar hallazgos antes de cualquier cambio.

---

## Hipótesis de origen de los ~40k tokens

Basado en el análisis de la arquitectura existente, los ~40k tokens por sesión típica probablemente se distribuyen así:

| Fuente | Tokens estimados | % del total | Tipo |
|--------|:----------------:|:-----------:|:----:|
| System prompt (Manager global orchestration protocol) | ~8k–10k | 20–25% | Fijo |
| Skills cargados (`<available_skills>` block) | ~3k–5k | 8–12% | Fijo bajo demanda |
| AGENTS.md / persona rules | ~2k–3k | 5–8% | Fijo |
| Engram protocol + session history | ~3k–4k | 8–10% | Fijo |
| Herramientas definidas (tools list + schemas) | ~6k–8k | 15–20% | Fijo |
| Contexto de proyecto (archivos, estructura) | ~4k–6k | 10–15% | Dinámico |
| Memorias recuperadas de Engram | ~3k–5k | 8–12% | Dinámico |
| Historial de sesión / mensajes recientes | ~5k–8k | 12–20% | Dinámico |
| Duplicación entre fuentes | ~3k–5k | 8–12% | **Derrochable** |

**Estimación total:** ~36k–52k tokens → promedia ~40k.

## Categorización

### Contexto fijo (siempre presente, cueste lo que cueste)

| Fuente | ¿Es negociable? | Prioridad |
|--------|:---------------:|:---------:|
| Core guardrails (no secretos, no escritura indebida, separación proyectos) | No | 🔴 Crítica |
| Identity (proyecto canonical, store real, estado validado) | Parcial (puede compactarse) | 🟡 Alta |
| Tool definitions (schemas de herramientas disponibles) | Parcial (solo las relevantes a la tarea) | 🟡 Alta |
| Manager orchestration protocol (reglas de operación) | Parcial (referencia vs inline) | 🟡 Alta |

### Contexto dinámico (varía por sesión/tarea)

| Fuente | ¿Es negociable? | Prioridad |
|--------|:---------------:|:---------:|
| Memorias Engram recuperadas | Sí (ranking, top-k, dedup) | 🟢 Media |
| Historial de sesión | Sí (resúmenes estructurados) | 🟢 Media |
| Archivos de proyecto relevantes | Sí (bajo demanda) | 🟢 Media |
| Skills cargados | Sí (solo si aplican a la tarea) | 🟢 Media |

### Contexto duplicado / derrochable

| Fuente | Problema | Acción |
|--------|----------|--------|
| System prompt + AGENTS.md comparten reglas de persona | ~1k–2k duplicados | Deduplicar |
| Skills list en system prompt + available_skills | ~1k–2k duplicados | Cargar solo skills match |
| Tool schemas completos vs solo los que se usarán | ~3k–5k sobrantes | Cargar bajo demanda |
| Memorias que se solapan temáticamente | ~1k–2k duplicados | Deduplicación semántica |

## Metodología de auditoría

### Paso 1: Medición real con herramienta de conteo

```bash
# Pseudocódigo — contar tokens del system prompt real
# Usar tiktoken o similar para medir el system prompt actual
# Registrar: total de tokens, tokens por sección
```

### Paso 2: Inventario de fuentes

| Fuente | Archivo / Origen | Tokens | ¿Se puede reducir? |
|--------|------------------|:------:|:------------------:|
| System prompt | `opencode.jsonc` o built-in | TBD | Sí (compactar reglas) |
| Manager protocol | Manager prompt | TBD | Sí (referencia vs inline) |
| AGENTS.md | `~/.config/opencode/AGENTS.md` | TBD | Sí (separar por modo) |
| Skills | `<available_skills>` block | TBD | Sí (solo relevantes) |
| Tools | Tool definitions | TBD | Sí (carga bajo demanda) |
| Memorias | Engram `mem_context` | TBD | Sí (ranking + top-k) |
| Session history | Mensajes recientes | TBD | Sí (resumen estructurado) |

### Paso 3: Identificar quick wins

1. **Tool definitions bajo demanda**: en lugar de cargar 30+ schemas de herramientas, cargar solo los que aplican al paso actual.
2. **Skills selectivos**: en lugar de listar 30+ skills disponibles, listar solo los que matchean el contexto de la tarea.
3. **Memorias rankeadas**: en lugar de incluir todo el contexto de Engram, rankear por relevancia y limitar a top-5 o top-10.
4. **Session history compactado**: en lugar de mensajes crudos, resumen estructurado de la sesión.

### Paso 4: Documentar baseline

Crear archivo `baseline-tokens.md` (post-medición) con:

- Tokens totales del system prompt actual
- Desglose por sección
- Desglose por tipo (fijo, dinámico, duplicado)
- Candidatos a reducción prioritarios

## Riesgos de medir mal

| Riesgo | Impacto | Mitigación |
|--------|:-------:|------------|
| Medir solo system prompt y olvidar contexto dinámico | Subestimación del total | Medir en sesión real con tarea típica |
| Usar tokenizer incorrecto | Tokens incorrectos | Usar tiktoken con modelo correcto (gpt-4, claude) |
| No considerar variación por tarea | Baseline no representativo | Medir en 3 tipos de tarea: simple, normal, arquitectura |
| Confundir tokens de entrada con tokens de salida | Sobreestimación | Medir solo prompt de entrada |

## Criterios de aceptación de F0

1. ✅ Baseline de tokens documentado con desglose por fuente.
2. ✅ Fuentes clasificadas como fijo/dinámico/duplicado.
3. ✅ Quick wins identificados y priorizados.
4. ✅ Medición reproducible (comando documentado).
5. ✅ Sin cambios funcionales implementados.

---

_Fin de F0-token-audit-plan.md_
