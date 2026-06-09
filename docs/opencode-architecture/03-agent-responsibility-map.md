# Agent Responsibility Map — Mapa de Responsabilidades

## 1. Matriz de responsabilidades actual vs recomendada

| Actor | Responsabilidad actual | Responsabilidad recomendada | Puede delegar | Puede escribir memoria | Puede usar MCP | Riesgo actual |
|-------|----------------------|---------------------------|---------------|----------------------|----------------|---------------|
| **Manager** | Orquestador global: intake, diseño, SDD, review, debugging, GPT-5.5 gate | Router principal + decisor estratégico. NO ejecutor universal. | ✅ Sí (subagentes SDD + especializados) | ✅ sí (proactivo) | ✅ sí (bajo demanda) | 🔴 ALTO: prompt ~7k, puede hacer inline, referencia subagentes inexistentes |
| **gentle-orchestrator** | Coordinador SDD, nunca ejecuta inline | SDD Pipeline especializado. NO orquestador primario por defecto. | ✅ Sí (solo subagentes SDD) | ⚠️ Solo por subagentes | ⚠️ Limitado por tools | 🔴 ALTO: compite como primary con Manager |
| **sdd-apply** | Implementar código | Implementar código (sin cambios) | ❌ No (executor boundary) | ✅ sí (progress + artifacts) | ✅ sí (según tarea) | 🟢 BAJO |
| **sdd-explore** | Investigar codebase | Investigar codebase (sin cambios) | ❌ No | ✅ sí (artifacts) | ✅ sí (según tarea) | 🟢 BAJO |
| **sdd-propose** | Crear propuestas | Crear propuestas (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **sdd-spec** | Escribir especificaciones | Escribir especificaciones (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **sdd-design** | Diseño técnico | Diseño técnico (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **sdd-tasks** | Planificar tareas | Planificar tareas (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **sdd-verify** | Validar implementación | Validar implementación (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **sdd-archive** | Archivar cambios | Archivar cambios (sin cambios) | ❌ No | ✅ sí | ✅ sí | 🟢 BAJO |
| **frontend-specialist** | Implementación frontend visual | Implementación frontend visual (sin cambios) | ❌ No | ⚠️ Limitado | ⚠️ Solo tools diseño | 🟡 MEDIO: duplicado en agent/ y agents/ |
| **release-security-gate** | Gate predeploy | Gate predeploy (sin cambios) | ❌ No | ❌ No | ✅ sí (webfetch) | 🟢 BAJO |
| **bigquery-data-quality** | Profiling BQ | Profiling BQ (sin cambios) | ❌ No | ❌ No | ❌ No (solo tools nativas) | 🟢 BAJO |
| **sql-cleaning-agent** | Limpieza SQL | Limpieza SQL (sin cambios) | ❌ No | ❌ No | ❌ No | 🟢 BAJO |
| **data-memory-curator** | Sincronizar capas de memoria | Sincronizar capas de memoria (sin cambios). **No modelado en arquitectura objetivo — evaluar si debe integrarse con Memory Router.** | ❌ No | ❌ No | ❌ No | 🟢 BAJO. Ausente en diagrama objetivo. Pendiente decisión. |

## 2. Lo que DEBE hacer cada actor

> ⚠️ **Corrección Fase B0**: Separar ESTADO ACTUAL de ARQUITECTURA OBJETIVO. No mezclarlos.

### ESTADO ACTUAL — Manager DEBE
- Clasificar requests como Tiny/Small/Medium/Large.
- Ejecutar intake, clarificación y diseño approval.
- Decidir si usa Graphify Context Gate.
- Decidir si entra en SDD y qué subagentes usar.
- Controlar el ciclo SDD, delegando fases a subagentes.
- Ejecutar inline solo cuando no hay subagente disponible.
- Aplicar TDD, review y debugging.
- Invocar quality gates (Judgment Day, GPT-5.5).
- **NO llamar a gentle-orchestrator** (regla explícita actual).
- Hacer mem_save proactivo de decisiones, bugs, descubrimientos.
- Ejecutar mem_session_summary al cerrar sesión.

### ESTADO ACTUAL — Manager NO DEBE
- **NO** ser ejecutor universal de todo el trabajo.
- **NO** saltarse el design approval (salvo fast-track explícito).
- **NO** delegar a gentle-orchestrator (regla actual, podría cambiar en ADR-001).
- **NO** expandir scope sin aprobación.
- **NO** usar Graphify sin aprobación del usuario.
- **NO** cargar skills sin trigger claro.
- **NO** recuperar memoria sin objetivo.
- **NO** pasar outputs largos de subagentes sin resumir.
- **NO** decir "done" sin verificación.

### ESTADO ACTUAL — gentle-orchestrator DEBE
- Coordinar el pipeline SDD delegando fases.
- Mantener conversación thin (no inflar contexto).
- Delegar trabajo real a subagentes vía task/delegate.
- Leer 1-3 archivos inline solo para decidir.
- Delegate 4+ archivos, escritura multi-file, tests, tools externos.
- Sintetizar resultados de subagentes.
- NO ejecutar inline código de implementación.

### ESTADO ACTUAL — gentle-orchestrator NO DEBE
- **NO** competir como orquestador primario por defecto (pero actualmente es mode: primary).
- **NO** ejecutar inline trabajo de 4+ archivos.
- **NO** tener tools de glob, grep, skill (ya no las tiene).
- **NO** escribir implementación directamente.
- **NO** orquestar fuera del pipeline SDD.

---

### ARQUITECTURA OBJETIVO (propuesta ADR-001, pendiente de validación)

| Aspecto | Estado actual | Propuesta objetivo |
|---------|---------------|-------------------|
| **Orquestador primario** | 2 (Manager + gentle-orch) — ambos `mode: "primary"` | 1 (Manager como único primary) |
| **Rol de gentle-orchestrator** | Primary competidor | SDD Pipeline invocable explícitamente (no primary) |
| **Manager llama a gentle-orch?** | NO (prohibición explícita) | Sí, cuando el flujo SDD lo requiera |
| **Estado de decisión** | — | **PENDIENTE ADR-001 + validación runtime** |

### Subagentes SDD DEBEN
- Ejecutar su fase específica.
- NO delegar a nadie (executor boundary).
- Leer skills antes de trabajar.
- Hacer retrieval de artefactos previos (2-step: mem_search → mem_get_observation).
- Persistir artifacts vía mem_save con capture_prompt: false.
- Retornar envelope con status/summary/next.

### Subagentes SDD NO DEBEN
- **NO** delegar tareas a otros agentes.
- **NO** llamar task/delegate.
- **NO** expandir scope de la fase.
- **NO** modificar artefactos de fases anteriores sin coordinación.

## 3. Cuándo responder inline vs delegar

| Situación | Inline | Delegar | Quién decide |
|-----------|--------|---------|-------------|
| Pregunta simple, 1 respuesta | ✅ Sí | ❌ No | Manager |
| Lectura 1-3 archivos para entender | ✅ Sí | ❌ No | Manager/gentle |
| Lectura 4+ archivos | ❌ No | ✅ Sí (subagente explore) | Manager/gentle |
| Cambio 1 archivo, mecánico | ✅ Sí | ❌ No | Manager |
| Cambio multi-archivo con lógica | ❌ No | ✅ Sí (subagente SDD) | Manager/gentle |
| Tests | ❌ No | ✅ Sí (sdd-apply o sdd-verify) | Manager/gentle |
| Tools externas (bash complejo) | ❌ No | ✅ Sí | Manager/gentle |
| Diseño arquitectónico | ❌ No | ✅ Sí (sdd-design) | Manager |
| TDD | ✅ Sí (Manager) | ❌ No | Manager |
| Review | ✅ Sí (Manager o skills) | ⚠️ Judgment Day opcional | Manager |
| Debugging | ✅ Sí (Manager) | ⚠️ GPT-5.5 si existe | Manager |
| Memoria: save decision | ✅ Sí (Manager/subagente) | ❌ No | Manager |
| Memoria: search | ✅ Sí | ❌ No | Manager |
| MCP: consulta documentación | ✅ Sí | ❌ No | Manager |

## 4. Conflictos de responsabilidad detectados

### Conflicto 1: Dos orquestadores primarios
- Manager y gentle-orchestrator son ambos `mode: "primary"`.
- Manager tiene prohibido llamar a gentle-orchestrator.
- gentle-orchestrator no llama a Manager explícitamente.
- **Riesgo**: El runtime de OpenCode puede elegir cualquiera de los dos como default. No hay documentación de cómo se resuelve la ambigüedad.

### Conflicto 2: Manager vs gentle-orchestrator en SDD
- Ambos pueden llamar a los mismos subagentes SDD.
- Manager usa `task()` (sync), gentle-orchestrator usa `delegate` (async).
- Manager puede ejecutar inline si falta subagente; gentle-orchestrator nunca ejecuta inline.
- **Riesgo**: Si el usuario no sabe cuál está activo, el comportamiento SDD puede diferir.

### Conflicto 3: Ejecución inline de Manager
- El protocolo del Manager lista cuándo debe delegar y cuándo puede ejecutar inline.
- La decisión queda a criterio del modelo (clasificación Tiny/Small/Medium/Large).
- **Riesgo**: Manager puede subestimar la complejidad y ejecutar inline lo que debió delegar, inflando contexto.

### Conflicto 4: Duplicación de instrucciones de memoria
- Engram protocol aparece en: AGENTS.md (.config), AGENTS.md (.codex), engram.ts MEMORY_INSTRUCTIONS.
- **Riesgo**: Instrucciones redundantes o contradictorias, ~2,500 tokens duplicados.

### Conflicto 5: Skills cargadas por orquestador vs por executor
- Manager carga skills vía `skill()` tool.
- gentle-orchestrator carga skills vía skill registry + paths.
- Subagentes SDD cargan skills por trigger.
- **Riesgo**: Diferentes mecanismos de resolución de skills, posible inconsistencia.

### Conflicto 6: Engram usado por plugin vs por instrucciones manuales
- `engram.ts` inyecta instrucciones automáticamente.
- AGENTS.md da instrucciones manuales adicionales.
- **Riesgo**: El modelo recibe instrucciones de memoria por dos canales diferentes.

### Conflicto 7: Context index vs skill registry vs inventory
- `.atl/skill-registry.md` se llama "Skill Registry" pero funciona como context index (índice de skills).
- No existe `CONTEXT_INDEX.md` separado.
- `inventory/` contiene catálogo técnico de agentes, MCP, tools.
- **Riesgo**: Superposición de conceptos, confusión sobre qué archivo contiene qué información.

### Conflicto 8: Subagentes especializados duplicados
- `agent/frontend-specialist.md` (544 líneas) y `agents/frontend-specialist.md` (872 líneas) coexisten.
- Contenido diferente (544 vs 872 líneas).
- **Riesgo**: ¿Cuál es la definición activa? Posible desincronización.
