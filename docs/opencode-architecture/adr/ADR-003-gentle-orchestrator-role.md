# ADR-003: Rol de gentle-orchestrator

## Estado

**Propuesto** — Depende de ADR-001 (que sigue pendiente de validación).

> ⚠️ **Fase B0**: Sin validación de agente primary (P1), este ADR no puede avanzar. Mantener PROPUESTO. Se requiere Test 1 para confirmar agente default antes de decidir sobre gentle-orchestrator.

## Contexto

`gentle-orchestrator` es el orquestador SDD original de Gentle AI. Su prompt (~12,000 tokens en AGENTS.md de .codex) lo define como:

- **Coordinador, no ejecutor**: nunca ejecuta trabajo inline sustancial.
- **Delegador serial**: delega todo trabajo real a subagentes SDD vía task/delegate.
- **Mantiene conversación thin**: solo sintetiza resultados.

Actualmente es `mode: "primary"` junto con Manager.

**Problema detectado**: gentle-orchestrator está diseñado exclusivamente para el pipeline SDD. No tiene intake, diseño approval, quality gates, TDD, review ni debugging. Si responde como default a un request no-SDD, no puede manejar la solicitud adecuadamente.

## Decisión

**gentle-orchestrator debe ser un SDD Pipeline especializado, invocable explícitamente, no un orquestador primario por defecto.**

Cambios:
1. Cambiar `mode` de `"primary"` a `"subagent"` (o remover primary).
2. Mantener su prompt de coordinación SDD intacto.
3. Debe responder solo cuando se le invoque explícitamente (`@gentle-orchestrator`) o cuando Manager lo invoque para SDD.
4. Manager puede invocar gentle-orchestrator para tareas estrictamente SDD cuando sea beneficioso.

## Razón

1. **Especialización**: gentle-orchestrator es excelente para SDD, insuficiente para otras tareas.
2. **Eliminación de ambigüedad**: deja de competir con Manager como primary.
3. **Preservación de inversión**: todo el pipeline SDD y skills asociados se mantienen.
4. **Flexibilidad**: sigue disponible para cuando el usuario quiera un flujo puramente SDD.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: SDD Pipeline invocable** (esta decisión) | Preserva funcionalidad, elimina ambigüedad | Requiere invocación explícita |
| **B: Eliminar gentle-orchestrator** | Simplifica al máximo | Pérdida de pipeline SDD puro |
| **C: Fusionar con Manager** | Un agente unificado | Prompt masivo, complejidad |
| **D: Mantener como primary pero mejorar prompt** | Sin cambios de configuración | Ambigüedad persiste |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Ambigüedad de primary resuelta.
- Pipeline SDD intacto y usable.
- Manager puede invocarlo cuando sea beneficioso.

## Consecuencias negativas

- El usuario debe acordarse de usar `@gentle-orchestrator` para flujo SDD puro.
- Manager necesita lógica para decidir cuándo delegar a gentle-orch vs ejecutar SDD directamente.

## Evidencia

- **Archivo**: `opencode.json` (líneas 4-33), AGENTS.md (.codex)
- **Hallazgo**: gentle-orchestrator mode: primary, prompt de coordinación pura, tools limitadas.
- **ID en Evidence Register**: E001, E004, E008, E009, C001

## Validación requerida

1. [ ] Verificar que gentle-orchestrator responde solo con mención explícita.
2. [ ] Verificar que el pipeline SDD sigue funcionando cuando se invoca.
3. [ ] Verificar que Manager puede delegar SDD a gentle-orch si es beneficioso.
