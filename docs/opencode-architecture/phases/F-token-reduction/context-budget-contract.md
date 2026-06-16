# Context Budget Contract

**Propósito:** Definir el presupuesto de tokens por capa y por modo, las reglas de expansión y el contrato que el sistema debe respetar.

---

## Modos de operación

| Modo | Tokens objetivo | Expansión máxima | Uso típico |
|:----:|:---------------:|:----------------:|------------|
| **Simple** | 6k–8.5k | 10k | Consultas, confirmaciones, tareas triviales |
| **Normal** | 8.5k–12k | 14k | Diseño, implementación, revisión estándar |
| **Arquitectura** | 12k–16k | 20k | Cambios multi-módulo, diseño arquitectónico |
| **Auditoría** | 16k–22k | 28k | Suites de test completas, regresiones |
| **Excepcional** | >22k | Sin límite (justificado) | Crisis, debugging complejo, análisis profundo |

## Reglas de expansión

1. **Por defecto**: modo Normal (8.5k–12k).
2. **Expansión automática permitida** hasta 14k sin justificación.
3. **Expansión >14k** requiere: modo explícito o justificación en la tarea.
4. **Expansión >22k** requiere: justificación documentada + aprobación (Manager o usuario).
5. **Nunca expandir** si eso implica: eliminar L0 reglas, exponer secretos, o violar restricciones.

## Presupuesto por capa (modo Normal)

| Capa | Componente | Tokens objetivo | Tokens máx | Prioridad |
|:----:|------------|:---------------:|:----------:|:---------:|
| L0 | Core rules & guardrails | 800–1.200 | 1.500 | 🔴 Siempre incluido |
| L1 | Project identity | 300–600 | 800 | 🔴 Siempre incluido |
| L2 | Active task state | 600–1.200 | 1.500 | 🟡 Casi siempre |
| L3 | Retrieved mem_context | 2.000–3.500 | 4.000 | 🟢 Ranking dinámico |
| L4 | Recent session | 600–1.200 | 1.500 | 🟢 Resumen estructurado |
| L5 | On-demand context | 500–1.000 | 2.000 | 🔵 Bajo demanda |
| | **Working buffer** | 1.500–2.500 | 3.000 | 🟡 Holgura |
| | **Total modo Normal** | **8.500–12.000** | **14.000** | |

## Presupuesto por modo

| Capa | Simple | Normal | Arquitectura | Auditoría |
|:----:|:------:|:------:|:------------:|:---------:|
| L0 | 800 | 1.000 | 1.200 | 1.500 |
| L1 | 300 | 500 | 600 | 800 |
| L2 | 600 | 1.000 | 1.200 | 1.500 |
| L3 | 1.500 | 3.000 | 4.000 | 5.000 |
| L4 | 600 | 1.000 | 1.200 | 1.500 |
| L5 | 500 | 1.000 | 1.500 | 2.000 |
| Buffer | 1.200 | 2.000 | 2.300 | 3.700 |
| **Total** | **~6.500** | **~9.500** | **~12.000** | **~16.000** |

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
