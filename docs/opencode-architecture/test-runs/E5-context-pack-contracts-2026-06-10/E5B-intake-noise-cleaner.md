# E5B — Intake / Noise Cleaner

> Capacidad lógica para clasificar la intención del usuario, detectar ruido y determinar qué recursos necesita el request antes de construir contexto.

## Principio

No todo input merece memoria, docs ni herramientas. El intake debe clasificar antes de actuar.

## Clasificador de request

| Tipo | Descripción | Ejemplo |
|---|---|---|
| **tiny** | Respuesta directa, sin contexto | "Dime 1 frase" |
| **small** | Respuesta con contexto mínimo | "Qué significa este error?" |
| **memory-needed** | Requiere continuidad de sesión | "Continúa con lo que veníamos haciendo" |
| **docs-needed** | Requiere consultar documentación | "Según la documentación, cuál es el rol de Manager?" |
| **tool-needed** | Requiere herramienta específica | "Ejecuta el doctor de Engram" |
| **sdd-needed** | Requiere SDD pipeline completo | "Implementa este cambio siguiendo SDD" |
| **mixed** | Múltiples intenciones | "Revisa docs, arregla memoria y optimiza tokens" |
| **noisy** | Sin intención clara o ruido | "ok gracias jajaja" |
| **ambiguous** | Intención no determinable | "Arregla todo" |
| **sensitive** | Contiene datos sensibles | Token, contraseña en el input |

## Detección de ruido

| Indicador | Acción |
|---|---|
| Saludo sin pregunta | No hacer nada |
| Agradecimiento sin request | No hacer nada |
| "jajaja", "lol", risas | No hacer nada |
| Confirmación vaga ("ok", "listo", "dale") | Preguntar si hay siguiente paso |
| Frase incompleta | Preguntar qué quiso decir |
| Repetición exacta del mismo input | Responder igual o preguntar si hay novedades |

## Detección de sensibilidad

| Patrón | Acción |
|---|---|
| `ghp_*`, `sk-*`, `Bearer *` | Rechazar guardado. Marcar sensibilidad high |
| API keys, tokens, passwords | No guardar en memoria. No escribir en contexto |
| Datos personales (DNI, email, teléfono) | No persistir. Responder sin registrar |

## Output esperado

```json
{
  "clean_intent": "",
  "request_type": "",
  "needs_memory": false,
  "needs_docs": false,
  "needs_tool": false,
  "needs_sdd": false,
  "is_noise": false,
  "is_sensitive": false,
  "requires_clarification": false,
  "do_not_do": []
}
```

## Criterios de validación

- [ ] Los 10 tipos de request están clasificados
- [ ] La detección de ruido está definida
- [ ] La detección de sensibilidad está definida
- [ ] El output esperado tiene todos los campos
- [ ] No requiere agente nuevo — es capacidad del Manager
