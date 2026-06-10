# E5G — Memory Quality Metrics

> Métricas para medir la calidad de las operaciones de memoria.

## Principio

Lo que no se mide no se puede mejorar. Cada operación de memoria debe dejar métricas para evaluar su calidad.

## Campos mínimos

```json
{
  "memory_query": "",
  "memory_results_count": 0,
  "memory_used_count": 0,
  "memory_discarded_count": 0,
  "memory_relevance": "high | medium | low",
  "memory_noise_detected": false,
  "memory_duplicate_topic_key": false,
  "memory_superseded_count": 0,
  "memory_write_decision": "save | update | skip | reject",
  "memory_write_reason": "",
  "memory_sensitivity": "low | medium | high",
  "memory_state": "proposed | approved | deprecated | rejected | resolved",
  "context_pack_tokens_estimated": 0,
  "docs_sections_read": 0,
  "full_files_read": 0
}
```

## Métricas de lectura

| Métrica | Qué mide | Objetivo |
|---|---|---|
| `memory_query` | Query textual usada para buscar | Poder auditar qué se buscó |
| `memory_results_count` | Resultados devueltos por Engram | Cuantos resultados crudos |
| `memory_used_count` | Resultados realmente usados | Eficiencia del filtrado |
| `memory_discarded_count` | Resultados descartados | Ruido en la busqueda |
| `memory_relevance` | Relevancia percibida | Calidad subjetiva |
| `memory_noise_detected` | Si se detectó ruido | Precisión del intake |

## Métricas de escritura

| Métrica | Qué mide | Objetivo |
|---|---|---|
| `memory_write_decision` | Decisión de guardado | Trazabilidad |
| `memory_write_reason` | Por qué se guardó o rechazó | Justificación |
| `memory_sensitivity` | Nivel de sensibilidad | Seguridad |
| `memory_state` | Estado actual | Ciclo de vida |
| `memory_duplicate_topic_key` | Si hay duplicados | Calidad del topic_key |

## Métricas de contexto

| Métrica | Qué mide | Objetivo |
|---|---|---|
| `context_pack_tokens_estimated` | Tokens del Context Pack | Control de budget |
| `docs_sections_read` | Secciones de docs leídas | Eficiencia de lectura |
| `full_files_read` | Archivos completos leídos | Detectar sobrelectura |

## Criterios de validación

- [ ] 14 campos mínimos están definidos
- [ ] Métricas de lectura están definidas
- [ ] Métricas de escritura están definidas
- [ ] Métricas de contexto están definidas
