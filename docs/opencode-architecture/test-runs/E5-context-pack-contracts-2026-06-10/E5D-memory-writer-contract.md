# E5D — Memory Writer Contract

> Contrato para decidir cuándo y cómo guardar memoria.

## Principio

No todo lo que el modelo procesa merece ser memoria. Guardar solo lo que sea útil para sesiones futuras.

## Tipos de memoria que se guardan

| Tipo | ¿Guardar? | Razón |
|---|---|---|
| **decision** | Sí | Decisión arquitectónica o funcional confirmada |
| **preference** | Sí | Preferencia del usuario sobre cómo trabajar |
| **project_state** | Sí | Estado actual de una fase o componente |
| **technical_finding** | Sí | Descubrimiento técnico no obvio |
| **reusable_pattern** | Sí | Patrón que puede aplicarse en otros contextos |
| **architecture_rule** | Sí | Regla de arquitectura que debe respetarse |
| **session_summary** | Sí | Resumen de sesión para continuidad |
| **bug_root_cause** | Sí | Causa raíz de un bug (no el bug en sí) |

## Tipos de memoria que NO se guardan

| Tipo | ¿Guardar? | Razón |
|---|---|---|
| Prompts completos | No | Viven en user_prompts (captura automática del plugin) |
| Ruido conversacional | No | Sin valor futuro |
| Logs extensos | No | No son recuperables semánticamente |
| Outputs largos de subagentes | No | Ocupan espacio sin estructurar |
| Secretos | No | Riesgo de seguridad |
| Hipótesis no validadas | No | No son decisiones |
| Documentación que ya vive en Markdown | No | Los docs son la fuente de verdad |
| Duplicados sin topic_key | No | Contaminan el store |

## Output esperado

```json
{
  "write_decision": "save | update | skip | reject",
  "memory_type": "",
  "topic_key": "",
  "title": "",
  "summary": "",
  "evidence": [],
  "status": "proposed | approved | deprecated | rejected | resolved",
  "sensitivity": "low | medium | high",
  "reason": "",
  "requires_validation": false
}
```

## Regla de topic_key

- Toda memoria debe tener `topic_key` para permitir upserts.
- Si el mismo tema evoluciona, usar el mismo `topic_key` (no crear duplicados).
- Si no se sabe el key, usar `mem_suggest_topic_key` antes de guardar.

## Criterios de validación

- [ ] Tipos que se guardan vs no se guardan están definidos
- [ ] Output esperado tiene todos los campos
- [ ] Regla de topic_key está documentada
- [ ] No guardar secretos está explícito
- [ ] No guardar prompts completos está explícito
