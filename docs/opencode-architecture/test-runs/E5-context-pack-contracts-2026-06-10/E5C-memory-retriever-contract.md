# E5C — Memory Retriever Contract

> Contrato para buscar memoria sin contaminar contexto.

## Principio

No buscar memoria si no es necesario. Cuando se busca, minimizar resultados y descartar lo irrelevante.

## Reglas

1. **Tiny request** — NO buscar memoria.
2. **Small request** — NO buscar memoria a menos que el usuario mencione continuidad explícita.
3. **Memory-needed** — Usar `mem_context` primero (rápido, contexto reciente). Si no alcanza, `mem_search` con query mínima.
4. **Docs-needed** — No buscar memoria si los docs tienen la respuesta.
5. **SDD** — Context Pack con memorias relevantes al cambio, no al proyecto completo.

## Límites

| Recurso | Máximo |
|---|---|
| Resultados de `mem_search` | Top 3 |
| Memorias en Context Pack | 3 items |
| Queries de memoria por request | 2 |

## Criterios de descarte

Descartar memorias que sean:

- obsoletas (status deprecated o rejected)
- contradictorias con evidencia más reciente
- no relacionadas semánticamente con `clean_intent`
- sin evidencia que las respalde
- de scope equivocado (personal cuando el request es project, o viceversa)
- prompts completos como fuente primaria

## Fuente de verdad

Si existe ADR o documento Markdown que documente una decisión formal, esa es la fuente de verdad, no la memoria Engram.

## Output esperado

```json
{
  "query": "",
  "results_found": 0,
  "results_used": [],
  "results_discarded": [],
  "discard_reason": "",
  "memory_confidence": "high | medium | low",
  "needs_docs_confirmation": false
}
```

## Criterios de validación

- [ ] Reglas de cuándo buscar memoria están definidas
- [ ] Límites de resultados están definidos
- [ ] Criterios de descarte están definidos
- [ ] Jerarquía de fuente de verdad documentada
