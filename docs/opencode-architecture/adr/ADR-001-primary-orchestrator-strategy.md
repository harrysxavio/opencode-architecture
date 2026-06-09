# ADR-001: Estrategia de Orquestador Primario

## Estado

**Propuesto** — Pendiente de validación runtime. **No aprobar aún.**

> ⚠️ **Fase B0**: No se pudo validar cuál agente responde por defecto (P1). Los logs no registran selección de agente. Se requiere Test 1 para confirmar antes de decidir. Mantener estado PROPUESTO.

## Contexto

Actualmente existen **dos agentes orquestadores configurados como `mode: "primary"`** en `opencode.json`:

1. **gentle-orchestrator** (líneas 4-33): Coordinador SDD original de Gentle AI. Nunca ejecuta inline, delega todo a subagentes SDD vía task/delegate.
2. **Manager** (líneas 34-51): Orquestador global híbrido con protocolo completo (intake, diseño, SDD, review, debugging, GPT-5.5).

El Manager tiene una regla explícita que le **prohíbe** invocar a `gentle-orchestrator`. Sin embargo, ambos son primary, y no hay documentación visible de cómo OpenCode resuelve la ambigüedad cuando dos agentes tienen `mode: "primary"`.

**Riesgo identificado**: El sistema puede responder con el orquestador incorrecto dependiendo de la UI o mecanismos internos de resolución. El usuario puede estar usando gentle-orchestrator como default sin saberlo, o Manager puede estar ignorando requests que deberían ir a gentle-orch.

## Decisión

**Manager debe ser el único orquestador primario por defecto.**

`gentle-orchestrator` debe cambiar su mode de `"primary"` a `"subagent"` o ser configurado como agente invocable solo mediante mención explícita (`@gentle-orchestrator`).

## Razón

1. **Manager tiene un protocolo más completo**: intake, clasificación, diseño approval, SDH controlado, quality gates. Puede manejar cualquier tipo de request.
2. **gentle-orchestrator está diseñado solo para SDD**: su prompt le prohíbe ejecutar inline trabajo sustancial. No puede manejar requests no-SDD.
3. **Regla de no intersección**: Manager no debe llamar a gentle-orch. Si gentle-orch es primary, pueden competir.
4. **Reducción de ambigüedad**: Un solo primary elimina la pregunta de "cuál responde".
5. **Preservación de funcionalidad**: gentle-orchestrator sigue existiendo como SDD Pipeline invocable explícitamente para flujos SDD.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Manager único primary** | Elimina ambigüedad. Manager puede hacer de todo. gentle-orch sigue disponible | gentle-orch requiere mención explícita. Posible fricción si usuario está acostumbrado |
| **B: gentle-orch único primary** | Pipeline SDD más puro. Menos contexto fijo (manager prompt no se carga) | No tiene intake, diseño approval, quality gates. No puede manejar requests no-SDD |
| **C: Mantener ambos primary** | Sin cambios inmediatos | Ambigüedad continua. Riesgo de loop o agente incorrecto |
| **D: Fusión en un solo agente** | Un solo prompt que hace todo | Prompt masivo. Complejidad de mantener ambas lógicas en un agente |

**Decisión: Alternativa A** — Manager único primary, gentle-orch como SDD Pipeline invocable.

## Consecuencias positivas

- Ambigüedad resuelta: el usuario siempre sabe que Manager responde por defecto.
- gentle-orch sigue disponible para flujos SDD cuando se invoca explícitamente.
- Manager puede clasificar y redirigir a gentle-orch si detecta un request puramente SDD.
- Reducción de tokens fijos (prompt de gentle-orch no se carga si no está activo).

## Consecuencias negativas

- gentle-orch requiere mención explícita para ser invocado.
- Usuarios acostumbrados a gentle-orch como default necesitan adaptarse.
- Manager debe ser capaz de manejar todos los tipos de request, incluyendo SDD.

## Evidencia

- **Archivo**: `opencode.json`
- **Sección**: agent.gentle-orchestrator (líneas 4-33), agent.manager (líneas 34-51)
- **Hallazgo**: Ambos con `"mode": "primary"`. Sin regla de resolución visible.
- **ID en Evidence Register**: E001, E002, E007

## Validación requerida

1. [ ] Verificar que OpenCode permite cambiar mode de gentle-orchestrator a subagent.
2. [ ] Verificar que Manager responde correctamente a requests no-SDD después del cambio.
3. [ ] Verificar que `@gentle-orchestrator` sigue invocando a gentle-orch correctamente.
4. [ ] Verificar que no hay pérdida de funcionalidad SDD.
5. [ ] Probar con Test 1 (request simple) y Test 5 (request SDD) del plan de validación.
