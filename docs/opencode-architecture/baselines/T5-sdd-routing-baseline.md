# Baseline T5 — SDD Pipeline Routing

## Input usado

> "Quiero validar en modo read-only cómo enrutarías un cambio estructurado pequeño usando el pipeline SDD. No modifiques archivos. Solo explica qué agente tomaría la tarea, qué fases SDD aplicarían y qué subagentes participarían."

## Fecha/hora

2026-06-09 — Ejecutado durante Fase B1.

## Resultado observado

### Respuesta del Manager

Como Manager, mi routing para un cambio estructurado pequeño usando SDD sería:

**1. Clasificación de intención**

El Manager recibe el request y lo clasifica. Un "cambio estructurado pequeño" típicamente cae en **Small** o **Medium** según:
- Número de archivos afectados
- Complejidad de la lógica
- Riesgo de cambio

Para un cambio pequeño estructurado (ej. agregar una validación, modificar un comportamiento concreto), clasificaría como **Small**.

**2. Ruta de decisión del Manager**

```
User Request (cambio estructurado pequeño)
  → Manager clasifica como Small/Medium
  → Manager ejecuta intake rápido (si es necesario)
  → Manager presenta diseño → espera aprobación
  → Manager decide: ¿puedo ejecutar inline o necesito SDD?
      → Si < 3 archivos + lógica simple → inline (Small)
      → Si > 3 archivos + lógica nueva o estructurada → SDD Pipeline
```

**3. Si decide SDD Pipeline (para cambios estructurados):**

```
Manager invoca gentle-orchestrator como SDD Pipeline
  → gentle-orchestrator coordina:
      → sdd-explore: explorar código afectado
      → sdd-propose: proponer enfoque
      → sdd-spec: escribir especificaciones
      → sdd-design: diseñar implementación
      → sdd-tasks: desglosar en tareas
      → sdd-apply: implementar
      → sdd-verify: verificar contra spec
      → sdd-archive: archivar cambio
  → Resultado vuelve a Manager
  → Manager hace quality gate final
  → Manager sintetiza respuesta al usuario
```

**4. ¿Invoca gentle-orchestrator?**

**Sí, cuando corresponde.** El ADR-001 (Opción B aprobada) establece que Manager SÍ invoca gentle-orchestrator cuando el flujo lo requiere. La regla anterior ("Manager no llama a gentle-orchestrator") fue reemplazada por ADR-003.

**5. ¿Respeta la regla actual?**

✅ Sí. La regla actual (ADR-001/ADR-003) es: Manager llama a gentle-orchestrator para cambios estructurados que requieren SDD. No hay riesgo de loop porque gentle-orchestrator delega a subagentes, no de vuelta a Manager.

**6. ¿Usa subagentes?**

Sí: sdd-explore, sdd-propose, sdd-spec, sdd-design, sdd-tasks, sdd-apply, sdd-verify, sdd-archive (cuando gentle-orchestrator los invoca).

**7. ¿Usa memoria?**

Sí: Manager usa Engram para memoria de decisiones. gentle-orchestrator y subagentes SDD guardan artefactos según su persistence contract (modo Engram/OpenSpec/hybrid/none).

**8. ¿Usa MCP?**

Depende del cambio. Si el cambio requiere leer documentación externa → Context7. Si requiere persistencia → Engram. Si requiere datos → según necesidad.

## Evidencia

| Elemento | Resultado |
|----------|-----------|
| agente inicial | **Manager** (clasifica el request) |
| ruta propuesta | Manager → (inline | gentle-orch → sdd-*) → Manager → quality gate |
| si invoca gentle-orchestrator | **Sí** — para cambios estructurados que requieren SDD completo |
| si respeta regla actual | ✅ Sí (ADR-001/003) |
| si hay riesgo de loop | 🟢 Bajo — gentle-orch delega a sdd-*, no retorna a Manager sin completar |
| si usa subagentes | Sí — sdd-* mediante gentle-orchestrator |
| si usa memoria | Sí — Engram para decisiones Manager, artefactos SDD |
| si usa MCP | Depende del cambio específico |
| si bloquea por regla anterior | No — la regla "Manager no llama a gentle-orch" fue reemplazada |

## Métricas

| Métrica | Valor | Estado |
|---------|-------|--------|
| agente inicial | Manager | VALIDADO |
| ruta propuesta | Manager → gentle-orch → sdd-* → Manager | INFERIDO (diseño, no ejecución) |
| invoca gentle-orch | Sí | INFERIDO (diseño aprobado, no ejecutado aún) |
| respeta regla actual | Sí | VALIDADO |
| riesgo de loop | Bajo | INFERIDO |
| usa subagentes | Sí (8 fases SDD) | INFERIDO |
| usa memoria | Sí | INFERIDO |
| usa MCP | Condicional | INFERIDO |

## Conclusión

**El routing SDD está diseñado y aprobado (ADR-001/003) pero NO se ha ejecutado end-to-end en runtime.**

El Manager tiene la capacidad conceptual de:
1. Clasificar el request.
2. Decidir si ejecuta inline o delega a SDD Pipeline.
3. Invocar gentle-orchestrator cuando corresponde.
4. Recibir el resultado y hacer quality gate.

La regla "Manager no llama a gentle-orchestrator" fue corregida por ADR-003: ahora Manager SÍ invoca cuando el flujo lo requiere.

Sin embargo, esto NO se ha probado en runtime. Para validación completa, se necesita ejecutar un cambio real usando el pipeline SDD.

## Riesgos

- El pipeline SDD completo (8 fases) no se ha ejecutado nunca end-to-end en este sistema.
- Los subagentes sdd-* existen como configuración pero no se ha verificado que respondan correctamente.
- La integración Manager → gentle-orchestrator puede tener problemas de permisos, contexto o timeout no anticipados.
- gentle-orchestrator no se ha invocado desde Manager en sesiones reales aún.

## Próxima acción

Ejecutar un cambio estructurado pequeño usando el pipeline SDD para validar el routing end-to-end en runtime. Esto corresponde a Fase C (Tests de Flujo).
