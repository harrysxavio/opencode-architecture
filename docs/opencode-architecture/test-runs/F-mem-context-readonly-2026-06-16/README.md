# F — Read-only validation of `mem_context`

Diseño de prueba read-only para validar `mem_context` como tool de contexto sin efectos secundarios.

## Tests

| ID | Escenario | Prioridad |
|----|-----------|-----------|
| F-T1 | Happy path — proyecto canonical | Alta |
| F-T2 | Proyecto inexistente | Alta |
| F-T3 | Sin parámetro project | Alta |
| F-T4 | Sin efectos secundarios en DB | Alta |
| F-T5 | No invención de contexto | Media |
| F-T6 | Sin activación de componentes innecesarios | Media |

## Estado

⏳ Diseñado — pendiente de ejecución
