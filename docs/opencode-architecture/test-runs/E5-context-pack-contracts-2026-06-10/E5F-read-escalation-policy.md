# E5F — Read Escalation Policy

> Política progresiva de lectura: cuánto leer según la necesidad.

## Principio

No leer más de lo necesario. Cada línea leída ocupa tokens de contexto. Leer lo justo para responder.

## Escala

| Nivel | Acción | Cuándo |
|---|---|---|
| **1. Tiny** | Responder sin memoria, sin docs, sin tools | Request directo, sin contexto necesario |
| **2. Small** | Contexto mínimo (mem_context si aplica) | Pregunta con referencia a continuidad |
| **3. Memory-needed** | `mem_context` o `mem_search` con query mínima | Request que requiere continuidad de sesión |
| **4. Docs-needed** | Buscar documento específico + sección relevante | Pregunta sobre documentación existente |
| **5. File-needed** | Leer sección relevante de archivo | Bug, error, o comportamiento específico |
| **6. Full-file** | Leer archivo completo | Solo si es necesario para entender contexto |
| **7. Project audit** | Leer múltiples archivos | Solo si el usuario lo pide explícitamente |

## Criterio de stop

| Condición | Acción |
|---|---|
| Hay evidencia suficiente para responder | Dejar de leer |
| El doc no tiene la respuesta | No leer más docs del mismo tema |
| La memoria contradice el doc | Preferir doc como fuente de verdad |
| El usuario confirmó comprensión | No profundizar |
| Se alcanzó el token budget | Detener y reportar limite alcanzado |

## Output esperado

```json
{
  "escalation_level": 1,
  "resources_read": [],
  "stop_reason": "",
  "token_estimate": 0,
  "cached": false
}
```

## Criterios de validación

- [ ] 7 niveles de escalada están definidos
- [ ] Criterio de stop está documentado
- [ ] Output esperado tiene todos los campos
