# OpenCode Architecture Documentation

> Mapa documental completo de la arquitectura actual de OpenCode y propuesta de evolución.

## Propósito

Esta carpeta contiene el análisis arquitectónico más completo del ecosistema OpenCode del usuario. Su objetivo es:

1. **Documentar cómo funciona hoy** — basado en evidencia de archivos, configuración y código.
2. **Clasificar hallazgos** — separar lo validado de lo inferido y lo no validado.
3. **Identificar conflictos y riesgos** — entre componentes, agentes, orquestadores y capas de memoria.
4. **Proponer una arquitectura objetivo** — coherente, eficiente y mantenible.
5. **Definir un roadmap de migración** — fases incrementales sin romper el sistema.

## Estado actual del análisis

| Dimensión | Estado |
|-----------|--------|
| Auditorías ejecutadas | 3 (paralelas) |
| Archivos analizados | 25+ (config, plugins, skills, agent prompts) |
| Hallazgos clasificados | 60+ |
| Conflictos detectados | 12 |
| Riesgos identificados | 15 |
| ADRs propuestos | 9 |
| Pruebas de validación diseñadas | 8 |
| Documentos creados | 16 |

## Cómo leer esta documentación

| Orden | Documento | Qué encontrarás |
|-------|-----------|-----------------|
| 1 | `00-executive-summary.md` | Resumen ejecutivo para toma de decisiones |
| 2 | `01-current-state-map.md` | Foto actual del ecosistema: zonas, componentes, archivos |
| 3 | `02-request-response-flow.md` | Flujo real de petición a respuesta con diagramas |
| 4 | `03-agent-responsibility-map.md` | Matriz de responsabilidades de cada agente |
| 5 | `04-memory-context-map.md` | Mapa completo de fuentes de memoria y contexto |
| 6 | `05-token-cost-map.md` | Mapa de consumo de tokens por capa |
| 7 | `06-tools-mcp-skills-map.md` | Inventario de tools, MCP y skills |
| 8 | `07-evidence-register.md` | Registro central de toda la evidencia recopilada |
| 9 | `08-conflicts-and-open-questions.md` | Conflictos entre auditorías y preguntas abiertas |
| 10 | `09-risk-register.md` | Registro de riesgos con severidad y mitigación |
| 11 | `10-target-architecture.md` | Arquitectura objetivo propuesta |
| 12 | `11-memory-and-token-optimization-model.md` | Modelo de capas de memoria y optimización |
| 13 | `12-migration-roadmap.md` | Roadmap de migración por fases |
| 14 | `13-validation-test-plan.md` | Plan de pruebas para validar el flujo |
| — | `adr/ADR-001` a `ADR-009` | Architectural Decision Records |

## Qué está validado

- **Dos orquestadores primarios**: Manager y gentle-orchestrator coexisten con `mode: "primary"`.
- **Manager no puede llamar a gentle-orchestrator**: regla explícita en su prompt.
- **Sistema SDD completo**: 8 subagentes SDD con skills, executor boundary y persistence contract.
- **Plugin Engram activo**: engram.ts inyecta instrucciones de memoria y captura prompts.
- **Plugin background-agents activo**: delegate/delegation_read/delegation_list funcionales.
- **MCP surface extensa**: 9+ MCP servers configurados entre opencode.json y opencode.jsonc.
- **Skill registry operativo**: 48 skills indexadas en `.atl/skill-registry.md`.
- **Inventory generado**: inventario con agentes, MCP, skills, plugins (posiblemente desactualizado).

## Qué falta validar

- **Engram realmente escribiendo observaciones**: `memories_1.sqlite` reportado con 4KB y tabla vacía.
- **OpenSpec implementado**: referenciado en persistence contract pero sin directorios `openspec/` visibles.
- **Graphify en uso**: instalado como skill pero sin `graphify-out/` en ningún proyecto.
- **Superpowers como skill físico**: referenciado en prompts del Manager pero sin SKILL.md local.
- **GPT-5.5 review/debug subagentes**: `@review-gpt55` y `@debug-gpt55` no existen como agentes configurados.
- **Context Index**: no existe `CONTEXT_INDEX.md` — posible confusión con `skill-registry.md`.
- **Session Close Protocol ejecutándose**: 55 sesiones indexadas sin evidencia de `mem_session_summary`.
- **Resolución real de agente primario**: cuál gana cuando ambos son `mode: "primary"` no está documentado por OpenCode.

## Próximos pasos recomendados (roadmap actualizado)

> ⚠️ **Corrección Fase B0**: El roadmap se ha reordenado. Seguridad (secretos expuestos) debe ir ANTES de observabilidad, memoria, MCP o cambios arquitectónicos.

1. **Fase A**: ✅ Documentación base — completada.
2. **Fase B0**: ✅ Corrección documental + validación read-only — completada (este documento).
3. **Fase B-Security**: 🔴 Rotar secretos expuestos y mover a variables de entorno (R11). Antes de cualquier cambio funcional.
4. **Fase B1**: Implementar observabilidad mínima.
5. **Fase C**: Tests de flujo — ejecutar los 8 tests definidos.
6. **Fase D**: Resolver agente primario (Manager único primary vía ADR-001).
7. **Fase E**: Gobernanza de memoria Engram.
8. **Fase F**: Reducir contexto fijo y optimizar token budget.
9. **Fase G**: Optimizar MCP surface.
10. **Fase H**: Consolidar arquitectura objetivo.

## Reglas de calidad de esta documentación

- Toda afirmación técnica clasificada como `VALIDADO`, `INFERIDO`, `CONFLICTO`, `NO VALIDADO` o `DECISIÓN PROPUESTA`.
- No se mezclan hechos con opiniones.
- Cada hallazgo importante incluye archivo, ruta y evidencia.
- No se modificó código funcional, configuración, agentes ni prompts activos.
