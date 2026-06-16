# Context Budget Contract

**Estado:** ✅ ALIGNED WITH F2  
**Propósito:** Definir el presupuesto de tokens por capa y por modo, las reglas de expansión y el contrato que el sistema debe respetar.

> **⚠️ Este documento fue actualizado por F2.**  
> El documento fuente y autoritativo es [`F2-context-budget-contract.md`](F2-context-budget-contract.md).  
> Este archivo permanece como referencia resumida y debe leerse en conjunto con F2 para datos completos (source-to-layer mapping, quick win integration, full contract MUST/SHOULD/MAY).

---

_→ Ver [`F2-context-budget-contract.md`](F2-context-budget-contract.md) para la definición completa de modos, presupuestos detallados, y el contrato MUST/SHOULD/MAY._

## Reglas de exclusión

Estos contenidos **nunca** deben incluirse en el presupuesto base:

- Memorias de proyectos legacy (ej. `arquitectura-ia`) salvo riesgo histórico justificado.
- Secretos, tokens, credenciales, API keys.
- Raw session history sin resumir.
- Tool schemas de herramientas no aplicables a la tarea.
- Skills que no matchean el contexto actual.
- Resultados de búsqueda completos sin filtro top-k.

## Reglas de fallback

| Situación | Acción |
|-----------|--------|
| Contexto insuficiente para responder | Expansión controlada al siguiente modo |
| `mem_context` retorna vacío | Incluir mínimo: identidad + reglas + estado activo |
| Modo excedido sin justificación | Rechazar y volver a modo Normal |
| Tarea crítica detectada | Promover automáticamente a modo Arquitectura |
| Riesgo de seguridad detectado | Expandir L0 con reglas adicionales de seguridad |

## Contrato

1. El sistema DEBE operar dentro del presupuesto de su modo actual.
2. El sistema PUEDE expandirse hasta el máximo del modo sin justificación.
3. El sistema DEBE justificar expansiones >14k.
4. El sistema DEBE mantener L0 y L1 siempre presentes.
5. El sistema DEBE caer en fallback si el contexto es insuficiente.
6. El sistema NO DEBE truncar L0/L1 para ahorrar tokens.
7. El sistema NO DEBE incluir secretos en ningún modo.

---

_Fin de context-budget-contract.md_
