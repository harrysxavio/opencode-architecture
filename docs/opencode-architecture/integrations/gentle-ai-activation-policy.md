# gentle-ai Activation Policy

> **Estado:** ✅ POLÍTICA DEFINIDA — No modifica runtime
> **Fecha:** 2026-06-17
> **Propósito:** Formalizar cómo aparece gentle-ai dentro de la arquitectura OpenCode sin integrarlo como dependencia runtime. Definir cuándo, cómo y por qué se "llama" conceptualmente a gentle-ai.

---

## 1. ¿Qué es gentle-ai dentro de esta arquitectura?

gentle-ai es un **conjunto de patrones de arquitectura, evaluación y gobernanza** que OpenCode Architecture reconoce como referencia estratégica. No es un componente runtime. No es un skill. No es un subagente. No es una dependencia.

Dentro de OpenCode Architecture, gentle-ai existe como:
- **Documentación de alineación** (`gentle-ai-alignment.md`)
- **Context pack evaluativo** (`GENTLE_AI_ALIGNMENT_PACK`)
- **Benchmark de referencia** para comparar enfoques
- **Lente de evaluación** que el Manager puede aplicar conceptualmente
- **Fuente de patrones** que ya fueron adoptados en SDD y Manager

---

## 2. ¿Qué NO es gentle-ai?

| No es | Por qué |
|-------|---------|
| Dependencia runtime de OpenCode | Sin plugin, MCP, imports ni config |
| Agente obligatorio del Manager | Manager no necesita gentle-ai para funcionar |
| Skill instalable por defecto | No hay SKILL.md de gentle-ai |
| Subagente invocable | `gentle-orchestrator` existe como subagente pero no se usa |
| Tool en el ecosistema MCP | No hay tool schemas de gentle-ai |
| Perfil `full` del kit exportable | `full` debe ser 100% OpenCode-nativo |
| Reemplazo del Manager | Manager orquesta; gentle-ai es referencia |
| Reemplazo de Engram | Engram es memoria; gentle-ai es criterio |
| Reemplazo de Ponytail | Ponytail simplifica código; gentle-ai evalúa arquitectura |

---

## 3. ¿Por qué no debe ser dependencia runtime?

| Razón | Detalle |
|-------|---------|
| **Independencia** | OpenCode debe funcionar sin sistemas externos |
| **Mantenibilidad** | gentle-ai evoluciona independientemente; una dependencia runtime requeriría sincronización |
| **Complejidad** | Cada integración runtime añade superficie de ataque y testing |
| **Claridad** | El Manager es el orquestador. Un sistema externo como referencia es más claro que como dependencia |
| **Fase F** | La reducción de tokens se diseñó para OpenCode nativo, no para acomodar gentle-ai |
| **Portabilidad** | El kit exportable debe ser auto-contenido |

---

## 4. ¿Por qué no debe estar dentro del perfil `full`?

El perfil `full` del futuro `opencode-agent-runtime-kit` / `proyecto-opencode-mem` debe ser:
- 100% OpenCode-nativo
- Instalable sin dependencias externas
- Auto-contenido en skills, plugins y documentación
- Mantenible por la comunidad OpenCode

gentle-ai rompe estas propiedades porque:
- No es parte del ecosistema OpenCode
- Requiere que el usuario conozca gentle-ai para que tenga sentido
- No hay código de gentle-ai que distribuir (solo patrones)

---

## 5. ¿Qué significa `alignment-only`?

| Principio | Significado |
|-----------|-------------|
| **Reconocimiento** | gentle-ai existe como referencia en la documentación |
| **Sin dependencia** | No hay runtime, plugin, MCP, skill ni tool |
| **Trazabilidad** | Decisiones que afectan ambos sistemas se documentan |
| **Patrones reutilizables** | SDD pipeline, quality gates, decision packages — adoptados de gentle-ai pero implementados como OpenCode nativo |
| **Futuro evaluable** | Si gentle-ai cambia, se evalúa si los patrones siguen siendo relevantes |

---

## 6. ¿Cuándo sí aparece gentle-ai?

| Situación | ¿Usar gentle-ai lens? | ¿Qué se usa? |
|-----------|:---------------------:|--------------|
| Diseñar repo instalable | ✅ Sí | Patrones de exportación, perfiles, fases |
| Revisar arquitectura del Manager | ✅ Sí | Evaluación de orquestación, anti-patterns |
| Diseñar test harness | ✅ Sí | Estructura de gates, regression strategy |
| Decidir integración de terceros | ✅ Sí | Análisis de impacto, risk register |
| Diseñar quality gates | ✅ Sí | Blind review, decision package, archive |
| Evaluar arquitectura cross-system | ✅ Sí | Alignment pack, reconciliación |
| Senior challenge de decisión | ✅ Sí | Validación desde múltiples dimensiones |
| Planificar fases de proyecto | ✅ Sí | Rollout plan, closure criteria |
| Diseñar perfiles exportables | ✅ Sí | Qué va en cada perfil y por qué |

---

## 7. ¿Cuándo NO aparece gentle-ai?

| Situación | ¿Usar gentle-ai lens? | Alternativa |
|-----------|:---------------------:|-------------|
| Escribir función debounce | ❌ No | Ponytail Code Gate |
| Editar README simple | ❌ No | Manager directo |
| Resumir Fase F | ❌ No | Documentación directa |
| Buscar en Engram | ❌ No | mem_context |
| Tarea Tiny/Small de código | ❌ No | Ponytail o Manager directo |
| Conversación conceptual sin decisión | ❌ No | Manager directo |
| Crear post LinkedIn | ❌ No | Manager directo |
| Responder pregunta técnica simple | ❌ No | Manager directo |

---

## 8. ¿Cómo se "llama" desde el Manager como lente de evaluación?

El Manager no ejecuta gentle-ai. En su lugar, puede **aplicar el lente de evaluación conceptual** preguntando:

> "¿Qué haría gentle-ai aquí? ¿Qué patrones de su pipeline aplicarían?"

Esto aparece en:
- **Senior challenge** (Manager Extension Decision Package): antes del veredicto final
- **Diseño de arquitectura**: cuando se evalúan opciones de diseño
- **Propuesta de integración**: cuando se decide si integrar un sistema externo
- **Quality gates**: cuando se revisa la completitud de un entregable

**No es un comando. No es un tool. Es un lente de evaluación.**

---

## 9. Nombres para referencias conceptuales

| Nombre | Uso |
|--------|-----|
| `gentle-ai Alignment Pack` | Documentación de alineación estratégica |
| `gentle-pattern review` | Revisión de diseño contra patrones gentle-ai |
| `gentle-style architecture challenge` | Desafío arquitectónico al estilo gentle-ai |
| `gentle-inspired evaluation gate` | Quality gate inspirado en gentle-ai |
| `gentle-ai benchmark lens` | Comparación con benchmarks de gentle-ai |

**Estos nombres solo se usan en documentación, no en código runtime.**

---

## 10. Patrones de gentle-ai ya útiles (adoptados en OpenCode)

| Patrón | Dónde vive en OpenCode |
|--------|------------------------|
| **SDD pipeline** (explore→propose→spec→design→tasks→apply→verify→archive) | SDD subagents (9 skills) |
| **Evaluación por fases** | Manager phases 0-8 |
| **Revisión adversarial** | Judgment Day skill |
| **Evidence-based decisions** | Decision log, risk register |
| **Decision package** | Manager Extension Decision Package |
| **Quality gates** | Regression harness (34 gates) |
| **Rollback mindset** | Backup + manifest + rollback plan |
| **Archive/cierre ordenado** | SDD Archive phase, session summary |
| **Completion Contract** | Manager Phase 8 |
| **Thin orchestrator** | Manager como orquestador, no ejecutor |
| **Anti-loop guardrails** | Manager Protocol anti-patterns |

---

## 11. Diferencia con Ponytail

| Dimensión | Ponytail | gentle-ai |
|-----------|----------|-----------|
| **Propósito** | Código mínimo necesario | Arquitectura, evaluación, gobernanza |
| **Cuándo se usa** | Code tasks | Decisiones arquitectónicas, diseño cross-system |
| **Qué produce** | Simplificaciones, menos código | Decisiones, documentación, evaluación |
| **Riesgo principal** | Simplificar demasiado | Crear dependencia innecesaria |
| **Modo default** | `full` en code tasks | `alignment-only`, sin runtime |
| **¿Integración runtime?** | ✅ Sí (documental en AGENTS.md) | ❌ No |
| **¿Plugin?** | ❌ No instalado | ❌ No aplica |
| **¿Skills?** | ❌ No instalados | ❌ No aplica |
| **¿Lente evaluativo?** | ✅ Ponytail Code Gate | ✅ gentle-ai Alignment Pack |

**Regla simple:** ¿Estás escribiendo código? → Ponytail. ¿Estás decidiendo arquitectura? → gentle-ai lens.

---

## 12. Diferencia con Engram

| Dimensión | Engram | gentle-ai |
|-----------|--------|-----------|
| **Propósito** | Memoria persistente | Criterio de evaluación / patrón |
| **Qué guarda** | Decisiones, bugs, aprendizajes | Nada — es referencia externa |
| **Runtime** | ✅ MCP server activo | ❌ No |
| **Se consulta** | Con `mem_search`, `mem_context` | No se consulta runtime |
| **Persistencia** | DB SQLite (`~/.engram/engram.db`) | No persiste datos |
| **Dependencia Manager** | ✅ Sí | ❌ No |

**Regla simple:** ¿Necesitás recordar? → Engram. ¿Necesitás evaluar? → gentle-ai lens.

---

## 13. Diferencia con el Manager

| Dimensión | Manager | gentle-ai |
|-----------|---------|-----------|
| **Rol** | Ejecuta y orquesta | Patrón/lente que el Manager puede aplicar |
| **Runtime** | ✅ Agente primario | ❌ No |
| **Decisiones** | Las toma y ejecuta | Las inspira conceptualmente |
| **Dependencia** | Central en la arquitectura | Externa, opcional |
| **Código** | Escribe, revisa, delega | No escribe código |

**Regla simple:** El Manager hace. gentle-ai inspira cómo hacerlo.

---

## 14. Tests para evitar integración accidental

| Test | ID | Descripción |
|------|:--:|-------------|
| Manager no requiere gentle-ai | GA-B1 | Verificar que no hay gentle-ai en agentes |
| Perfil full no incluye gentle-ai | GA-B2 | Verificar que perfil full es OpenCode-nativo |
| gentle-ai solo en docs/alignment | GA-B3 | Grep en archivos runtime = 0 |
| No hay tool gentle-ai obligatoria | GA-B4 | Verificar MCP servers |
| No hay subagente gentle-ai obligatorio | GA-B5 | Verificar agentes en opencode.json |
| No hay dependencia OpenCode ↔ gentle-ai | GA-B6 | Verificar imports, plugins, config |
| Integración futura requiere decision record | GA-B7 | Verificar decision-log.md |

---

## 15. Condiciones para integración futura real

| Condición | Detalle |
|-----------|---------|
| C1 | Existe un decision record aprobado |
| C2 | Se define un contrato de interfaz (AlignmentContract) |
| C3 | Adapter del lado de OpenCode |
| C4 | Adapter del lado de gentle-ai |
| C5 | Tests de boundary siguen pasando |
| C6 | Integración reversible sin pérdida |
| C7 | No aumenta contexto fijo del Manager |
| C8 | No hay dependencia circular |

---

## 16. Sección conceptual propuesta para futuro AGENTS.md

> ⚠️ **NO APLICADA.** Documentada como propuesta conceptual para referencia futura.

```markdown
## gentle-ai Alignment Pack — architecture/evaluation only

Use gentle-ai patterns as an evaluation lens for architecture, agent design,
workflow design, regression strategy and decision packages.

Do not treat gentle-ai as a runtime dependency, tool, required agent, or
default Manager dependency.

Activate this lens only for:
- architecture decisions
- agent/skill design
- workflow design
- regression strategy
- senior challenge
- cross-system decisions
- exportable kit design

Do not activate for:
- simple code tasks
- documentation-only work
- normal memory retrieval
- small fixes
- non-technical writing
- routine status reporting
```

---

## 17. Tabla de activación rápida

| Situación | ¿Usar gentle-ai lens? | ¿Usar Ponytail? | Herramienta principal |
|-----------|:---------------------:|:---------------:|-----------------------|
| Diseñar repo instalable | ✅ Sí | ❌ No | gentle-ai Alignment Pack |
| Escribir función debounce | ❌ No | ✅ Sí | Ponytail Code Gate |
| Revisar arquitectura Manager | ✅ Sí | ❌ No | gentle-ai lens |
| Hacer code review de PR | ⚠️ Solo si es Large | ✅ Sí | Ponytail + Code Review |
| Decidir integrar sistema externo | ✅ Sí | ❌ No | gentle-ai decision package |
| Editar README | ❌ No | ❌ No | Manager directo |
| Diseñar test harness | ✅ Sí | ❌ No | gentle-ai lens |
| Debugging de bug | ❌ No | ❌ No | Manager debugging phase |
| Crear skill nuevo | ✅ Sí | ❌ No | gentle-ai lens + skill-creator |
| Resumir documentación | ❌ No | ❌ No | Manager directo |
| Senior challenge | ✅ Sí | ❌ No | gentle-ai lens |
| Crear post LinkedIn | ❌ No | ❌ No | Manager directo |

---

## 18. Resumen ejecutivo

```text
gentle-ai es a OpenCode Architecture como un libro de arquitectura es a un arquitecto:
- Lo lee para inspirarse
- Aplica los patrones que aprendió
- Pero no necesita tener el libro abierto mientras trabaja
- Y si el libro cambia, sigue construyendo con lo que ya sabe
```

---

*Fin de gentle-ai-activation-policy.md*
