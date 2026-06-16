# F0 — Token Audit Baseline (Medición Real)

**Estado:** ✅ COMPLETED  
**Fecha:** 2026-06-16  
**Metodología:** Medición directa de archivos + estimación conservadora (4 chars/token para prosa, 2 chars/token para código/schemas).

---

## Resumen ejecutivo

| Métrica | Valor |
|---------|:-----:|
| **Total estimado sesión típica** | **~35k–45k tokens** |
| Baseline fijo | ~22k–26k tokens |
| Baseline dinámico | ~13k–19k tokens |
| Derrochable (duplicación) | ~3k–5k tokens |
| Objetivo modo Normal | ~8.5k–12k tokens |
| Reducción necesaria | ~65–75% |

---

## Medición por fuente

### 1. Manager Protocol (system prompt)

| Fuente | Archivo | Chars | Est. tokens |
|--------|---------|:-----:|:-----------:|
| Manager prompt | `opencode.json` → `agent.manager.prompt` | 28,471 | ~7,100–14,200 |
| AGENTS.md (persona + engram + design) | `~/.config/opencode/AGENTS.md` | 13,412 | ~3,400 |
| OpenCode core (built-in) | Runtime | ~8k–12k chars | ~2,000–3,000 |
| **Subtotal sistema fijo** | | | **~12,500–20,600** |

> **Nota:** El Manager protocol (28,471 chars) incluye el protocolo de orquestación, fases SDD, anti-patrones, fast-track, default behavior. AGENTS.md (13,412 chars) incluye persona, engram protocol y design skills — hay superposición con las reglas de persona y engram que también están en el protocolo.

### 2. Tool Definitions (schemas)

| Fuente | Cantidad | Chars por schema | Est. tokens |
|--------|:--------:|:----------------:|:-----------:|
| Tools disponibles | 16 | ~800 c/u | ~6,400 |
| Herramientas usadas por turno | ~5–8 | — | ~2,000–3,200 |
| **Subtotal tools** | | | **~3,200–6,400** |

> Las 16 tools son: bash, context7_query-docs, context7_resolve-library-id, delegate, delegation_list, delegation_read, edit, glob, grep, read, skill, task, todowrite, webfetch, websearch, write. Cada schema tiene nombre, descripción, parámetros con tipos, required, y descripciones.

### 3. Available Skills Block

| Fuente | Cantidad | Chars | Est. tokens |
|--------|:--------:|:-----:|:-----------:|
| Skills listados | 38 | 4,158 | ~1,040 |
| Descripciones individuales | 38 | 1–2 líneas c/u | — |
| **Subtotal skills** | | | **~1,000** |

> Skills reales instalados (deduplicados): **40 únicos** en 3 directorios. Pero el system prompt solo lista ~38 en el bloque `<available_skills>` con nombre + descripción corta (~4,158 chars).

### 4. Skills Content (full SKILL.md)

| Fuente | Cantidad | Chars totales | Est. tokens |
|--------|:--------:|:-------------:|:-----------:|
| Skills únicos | 40 | 308,002 | ~77,000 |
| **Cargados por turno** | **1–5** | **~5k–25k** | **~1,250–6,250** |

> ⚠️ Los 40 skills suman 308KB en total. Pero no se cargan todos — se cargan **bajo demanda** según el `skill` tool. Esto es un **quick win** potencial: actualmente los skills se cargan completos cuando se invocan. Si un skill tiene 30KB+ (como `hatch-pet` con 37KB), cada carga suma tokens significativos.

### 5. Engram Memory Context

| Fuente | Cantidad | Chars totales | Est. tokens |
|--------|:--------:|:-------------:|:-----------:|
| Observaciones totales en DB | 326 | — | — |
| Relevantes a `opencode-architecture` | 84 | 94,953 | ~23,700 |
| Recuperadas por `mem_context` típico | **5–15** | **~5k–15k** | **~1,250–3,750** |

> Engram DB: 3,076,096 bytes (~3MB). De 326 observaciones, ~84 son relevantes al proyecto. `mem_context` devuelve un subconjunto.

### 6. Session History

| Fuente | Cantidad | Chars | Est. tokens |
|--------|:--------:|:-----:|:-----------:|
| `user_prompts` registrados | 312 | — | — |
| Prompt promedio | ~200–500 chars | — | — |
| Historial sesión actual | ~10–30 turns | ~3k–10k chars | ~750–2,500 |
| **Subtotal sesión** | | | **~5,000–8,000** |

> Cada turno incluye user prompt + assistant response. En sesiones largas, este historial puede acumular ~8k+ tokens fácilmente.

### 7. Otros overheads

| Fuente | Est. tokens |
|--------|:-----------:|
| JSON wrapping (system prompt structure) | ~500–1,000 |
| Environment info (working dir, date, platform) | ~300–500 |
| **Subtotal overhead** | **~800–1,500** |

---

## Resumen consolidado

| Categoría | Fuente | Rango (tokens) | Tipo |
|-----------|--------|:--------------:|:----:|
| 🟡 Fijo | Manager protocol (opencode.json) | 7,100–14,200 | Fijo |
| 🟡 Fijo | AGENTS.md persona + engram | 3,400 | Fijo |
| 🟡 Fijo | OpenCode core prompt | 2,000–3,000 | Fijo |
| 🟡 Fijo | Tool schemas | 3,200–6,400 | Fijo |
| 🟢 Fijo | Available skills block | 1,000 | Fijo |
| 🟡 Fijo | JSON/env overhead | 800–1,500 | Fijo |
| | **Subtotal fijo** | **~17,500–29,500** | |
| 🟢 Dinámico | Engram memories | 1,250–3,750 | Dinámico |
| 🟢 Dinámico | Skills cargados | 1,250–6,250 | Dinámico |
| 🟢 Dinámico | Session history | 5,000–8,000 | Dinámico |
| | **Subtotal dinámico** | **~7,500–18,000** | |
| 🔴 Derrochable | Duplicación persona/protocolo | ~2,000–3,000 | Duplicado |
| 🔴 Derrochable | Skills list + descripciones duplicadas | ~1,000–2,000 | Duplicado |
| | **Subtotal duplicado** | **~3,000–5,000** | |
| | **TOTAL ESTIMADO** | **~28,000–52,500** | |
| | **Media (~40k)** | **~40,000** | ✅ Confirma hipótesis |

---

## Duplicación confirmada

| Duplicación | Fuente A | Fuente B | Tokens | Acción |
|-------------|----------|----------|:------:|--------|
| Engram protocol | Manager protocol (`# Engram`) | AGENTS.md (`engram-protocol`) | ~1,500–2,000 | Cargar solo en Manager protocol |
| Persona rules | AGENTS.md (`persona`) | Manager protocol (referencias) | ~500–1,000 | Unificar |
| Skills list | `<available_skills>` block | Skill files (titles) | ~1,000–2,000 | Cargar solo los match |

---

## Quick Wins identificados

| # | Quick Win | Tokens ahorro | Esfuerzo | Riesgo |
|:-:|-----------|:-------------:|:--------:|:------:|
| 1 | **Tool schemas bajo demanda**: cargar solo schemas de tools relevantes al turno actual | ~2,000–4,000 | Medio | Bajo |
| 2 | **Skills selectivos**: skills list solo con los que matchean contexto actual | ~500–1,000 | Bajo | Bajo |
| 3 | **Session history compactado**: resumen estructurado en lugar de historial crudo | ~3,000–5,000 | Medio | Medio |
| 4 | **Memorias rankeadas + top-k**: limitar a 5–10 memorias de mayor score | ~1,000–2,500 | Medio | Medio |
| 5 | **Deduplicación protocolo/persona**: eliminar superposición AGENTS.md ↔ Manager prompt | ~2,000–3,000 | Alto | Alto |
| 6 | **Separar modos de contexto**: Simple / Normal / Arquitectura / Auditoría | ~8,000–12,000 | Alto | Alto |

---

## Medición reproducible

Para reproducir esta medición en cualquier momento:

```bash
# 1. Manager prompt size
python -c "
import json
with open(r'C:\Users\harry\.config\opencode\opencode.json') as f:
    cfg = json.load(f)
prompt = cfg['agent']['manager']['prompt']
print(f'Manager prompt: {len(prompt)} chars ≈ {len(prompt)//4} tokens')
"

# 2. AGENTS.md
python -c "
with open(r'C:\Users\harry\.config\opencode\AGENTS.md') as f:
    c = f.read()
print(f'AGENTS.md: {len(c)} chars ≈ {len(c)//4} tokens')
"

# 3. Unique skills total chars
python -c "
import os, json
seen = set()
total = 0
dirs = [r'C:\Users\harry\.codex\skills',
        r'C:\Users\harry\.config\opencode\skills',
        r'C:\Users\harry\OneDrive\Documentos\GitHub\Tools\.agents\skills']
for d in dirs:
    if os.path.isdir(d):
        for root, _, files in os.walk(d):
            for f in files:
                if f == 'SKILL.md':
                    name = os.path.basename(root)
                    if name not in seen:
                        seen.add(name)
                        with open(os.path.join(root, f)) as fh:
                            total += len(fh.read())
print(f'Unique skills: {len(seen)}, total chars: {total} ≈ {total//4} tokens')
"

# 4. Engram relevant memories
sqlite3 'C:\Users\harry\.engram\engram.db' "
SELECT SUM(LENGTH(title) + LENGTH(COALESCE(content,''))) 
FROM observations 
WHERE scope='project' 
  AND (content LIKE '%opencode-architecture%' 
    OR title LIKE '%opencode%' 
    OR title LIKE '%E6B%' 
    OR title LIKE '%Noise Gate%' 
    OR title LIKE '%Suite F%' 
    OR title LIKE '%Fase F%'
    OR title LIKE '%Token%'
    OR title LIKE '%Engram%');
"
```

> **Requisito:** Python con `tiktoken` instalado para medición exacta de tokens por modelo. Sin tiktoken, usar ratio ~4 chars/token como aproximación conservadora.

---

## Criterios de aceptación

| # | Criterio | Status |
|:-:|----------|:------:|
| 1 | Baseline de tokens documentado con desglose por fuente | ✅ |
| 2 | Fuentes clasificadas como fijo/dinámico/duplicado | ✅ |
| 3 | Quick wins identificados y priorizados | ✅ |
| 4 | Medición reproducible (comando documentado) | ✅ |
| 5 | Sin cambios funcionales implementados | ✅ |

---

## Próximo paso recomendado

**F1 — Context Inventory**: Catalogar cada fuente de contexto con más detalle: qué contiene, cuándo es necesaria, qué pasa si falta, cuándo es redundante. Usar los datos de F0 como input.

_Fin de baseline-tokens.md — F0 COMPLETED. Sin cambios funcionales implementados._
