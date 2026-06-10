# E5A — Context Pack Contract

> Contrato formal del paquete mínimo de contexto que el Manager construye antes de responder o delegar.

## Principio

No todo request necesita contexto completo. El Context Pack debe ser **proporcional al tipo de request**: tiny recibe casi nada, sdd recibe contexto estructurado, noisy/mixed recibe limpieza de intención antes de buscar memoria.

## Formato

```json
{
  "request_id": "uuid",
  "request_type": "tiny | small | memory | docs | mcp | sdd | noisy | mixed",
  "clean_intent": "",
  "user_goal": "",
  "active_decisions": [],
  "project_rules": [],
  "known_errors": [],
  "relevant_memory": [],
  "relevant_docs": [],
  "relevant_files": [],
  "constraints": [],
  "evidence": [],
  "do_not_do": [],
  "open_questions": [],
  "token_budget": {
    "max_dynamic_context_tokens": 3000,
    "max_memory_items": 3,
    "max_doc_sections": 3,
    "max_file_reads": 2
  },
  "trace": {
    "memory_queries": [],
    "docs_queries": [],
    "discarded_context": [],
    "reason_for_context": ""
  }
}
```

## Reglas por tipo de request

| Request type | Context Pack | Reglas |
|---|---|---|
| **tiny** | No construir | Responder directo. Sin memoria, sin docs, sin contexto dinámico |
| **small** | Opcional | Context Pack mínimo si hay duda. Sin memoria si no es necesario |
| **memory** | Sí | Máximo 3 memorias. `mem_context` o `mem_search` con query mínima |
| **docs** | Sí | Secciones específicas, NO docs completos. Evidencia citada |
| **mcp** | Sí | Contexto mínimo + intención exacta para la tool |
| **sdd** | Sí | Context Pack compacto para gentle-orchestrator. Sin ruido |
| **noisy/mixed** | Sí | Primero limpiar intención. No buscar memoria hasta tener `clean_intent` |
| **ambiguous** | Sí | Preguntar antes de construir contexto completo |

## Token budget

| Recurso | Máximo | Notas |
|---|---|---|
| Contexto dinámico total | 3.000 tokens | Suma de memorias + docs + files |
| Memorias recuperadas | 3 items | Top resultados relevantes |
| Secciones de doc | 3 secciones | No documentos completos |
| Archivos leídos | 2 archivos | Solo secciones relevantes |

> Excepcion: SDD requests pueden recibir hasta 5.000 tokens de contexto dinámico con justificación explícita.

## Trace

Cada Context Pack debe incluir `trace` para auditoría:

- qué queries de memoria se ejecutaron
- qué docs se consultaron
- qué contexto se descartó y por qué
- razón de por qué se construyó este contexto

## Output esperado

El Manager debe producir un Context Pack como objeto mental o documento antes de ejecutar una respuesta que requiera más que tiny. No necesita serializarse a JSON en cada request, pero el contrato debe estar presente en la lógica de decisión.

## Criterios de validación

- [ ] Context Pack existe como contrato documentado
- [ ] Las reglas por tipo de request están definidas
- [ ] El token budget está definido
- [ ] El trace está especificado
- [ ] El principio de proporcionalidad está explícito
