# ADR-002: Rol del Manager

## Estado

**Propuesto** — Sin cambios respecto a Fase B0. Memory Router como capacidad lógica del Manager (C4 corregido).

## Contexto

El Manager es el orquestador global híbrido. Su prompt actual (~7,000 tokens) define un protocolo completo que incluye:

- Superpowers brainstorming (intake, clarificación, alternativas, diseño, aprobación)
- Graphify Context Gate (opcional)
- Gentle-AI-style SDD controlado (explore → archive)
- Superpowers quality reinforcement (TDD, review, debugging)
- GPT-5.5 final quality gates

El Manager **puede** ejecutar inline (cuando no hay subagente disponible) o **delegar** a subagentes SDD y especializados. También tiene una prohibición explícita de llamar a `gentle-orchestrator`.

**Problema detectado**: El Manager puede hacer demasiado. Sin límites claros de cuándo delegar vs ejecutar inline, puede inflar su contexto ejecutando tareas complejas que debería delegar.

## Decisión

**Manager debe ser un router/decisor, no un ejecutor universal.**

Reglas:
1. Manager **clasifica** el request (Tiny/Small/Medium/Large).
2. Para **Tiny**: responde inline (sin memoria, skills, MCP, subagentes).
3. Para **Small**: puede aplicar cambios directos (1 archivo, mecánico).
4. Para **Medium/Large**: **debe delegar** a subagentes SDD o especializados.
5. Manager **nunca** debe ejecutar inline tareas que requieran 4+ archivos, lógica nueva, diseño o tests.
6. Manager **siempre** debe sintetizar los resultados de subagentes, no pasar outputs crudos.

## Razón

1. **Separación de responsabilidades**: manager decide, subagentes ejecutan.
2. **Control de contexto**: delegar evita que el Manager acumule contexto de implementación.
3. **Eficiencia**: subagentes especializados son más rápidos y precisos en su dominio.
4. **Escalabilidad**: el Manager puede manejar más requests si no se carga con implementación.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Router puro** (esta decisión) | Manager liviano, subagentes ejecutan | Manager necesita decidir correctamente |
| **B: Ejecutor universal** (actual) | Manager puede hacer todo | Contexto inflado, posible lentitud |
| **C: Manager + gentle-orch fusión** | Un agente para todo | Prompt masivo, complejidad |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Manager más rápido en respuestas Tiny/Small.
- Menos tokens consumidos por el Manager.
- Subagentes reciben trabajo más específico.
- Mayor claridad de responsabilidades.

## Consecuencias negativas

- Manager debe clasificar correctamente (riesgo de clasificación incorrecta).
- Dependencia de subagentes disponibles (si falta subagente, Manager no puede ejecutar).
- Mayor latencia en delegación (task/subagent overhead).

## Evidencia

- **Archivo**: Manager prompt (opencode.json línea 49)
- **Hallazgo**: Manager clasifica Tiny/Small/Medium/Large pero la regla de inline vs delegación es ambigua.
- **ID en Evidence Register**: E005, E008, E009, R08

## Validación requerida

1. [ ] Verificar que Manager delega correctamente para Medium/Large.
2. [ ] Verificar que Manager responde inline solo para Tiny/Small.
3. [ ] Verificar que Manager sintetiza outputs de subagentes.
