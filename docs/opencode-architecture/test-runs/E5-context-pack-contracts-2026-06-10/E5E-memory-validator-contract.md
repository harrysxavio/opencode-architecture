# E5E — Memory Validator Contract

> Validación antes de guardar decisiones críticas.

## Principio

No toda decisión que parece importante lo es. Validar antes de guardar evita contaminar memoria con ruido, hipótesis o información incompleta.

## Preguntas de validación

Antes de guardar una decisión, responder:

1. **Evidencia**: La afirmación está respaldada por evidencia verificable?
2. **Decisión vs hipótesis**: Es una decisión confirmada o solo una hipótesis?
3. **Contradicción**: Contradice una memoria previa no deprecated?
4. **Fuente de verdad**: Debería vivir en ADR/Markdown antes que en Engram?
5. **topic_key**: Tiene un topic_key que permita upsert?
6. **Estado**: Tiene un estado asignado?
7. **Sensibilidad**: Tiene nivel de sensibilidad?
8. **Resumen**: Puede resumirse en menos de 150 palabras?
9. **Supersede**: Debe invalidar una memoria anterior?

## Estados de memoria

| Estado | Significado |
|---|---|
| **proposed** | Propuesta sin validar. No usar como fuente de verdad |
| **approved** | Validada y aceptada. Usar como referencia |
| **deprecated** | Reemplazada por una decisión más reciente |
| **rejected** | Considerada y rechazada. No reabrir sin nueva evidencia |
| **resolved** | Problema solucionado. Mantener como registro histórico |

## Reglas críticas

| Regla | Acción |
|---|---|
| Hipótesis sin validar | Guardar como `proposed`, no como `approved` |
| Decisión sin evidencia | No guardar hasta tener evidencia |
| Secreto detectado | Rechazar guardado. Marcar sensibilidad high |
| Prompt completo | No guardar como memoria gobernada |
| Contradicción con memoria previa | Evaluar si es update, supersede o conflicto. No ignorar |

## Output esperado

```json
{
  "validation_decision": "pass | reject | modify | escalate",
  "issues_found": [],
  "suggested_status": "",
  "suggested_topic_key": "",
  "supersedes_id": null,
  "requires_approval": false,
  "reason": ""
}
```

## Criterios de validación

- [ ] 9 preguntas de validación están definidas
- [ ] 5 estados de memoria están definidos
- [ ] Reglas críticas están documentadas
- [ ] Output esperado tiene todos los campos
- [ ] No guardar hipótesis como approved está explícito
