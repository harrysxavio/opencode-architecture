# Agent Responsibility Map — Mapa de Responsabilidades

> ✅ **Decisión estratégica (2026-06-09)**: Manager único primary. gentle-orchestrator como SDD Pipeline. Ver ADRs 001-009.

> Estado Fase D: Completado. `gentle-orchestrator.mode = subagent`, prompts actualizados, JSON válido y D4 post-restart PASSED.

## 0. Estado de las decisiones estratégicas

| Decisión | Estado | ADR |
|----------|--------|-----|
| Manager único primary | ✅ Aprobado | ADR-001 |
| Manager como router, no ejecutor | ✅ Aprobado | ADR-002 |
| gentle-orchestrator como SDD Pipeline invocable | ✅ Aprobado | ADR-003 |
| Manager SÍ invoca gentle-orch para SDD | ✅ Aprobado | ADR-001 |
| Regla "NO llamar a gentle-orch" reemplazada | ✅ Aprobado | ADR-001 |
| review-gpt55 / debug-gpt55 no se implementan | ✅ Aprobado | ADR-008 |
| data-memory-curator evaluar evolución | ✅ Aprobado | ADR-004 |

| Actor | Responsabilidad actual | Responsabilidad objetivo (post-ADRs) | Puede delegar | Puede escribir memoria | Puede usar MCP | Riesgo actual |
|-------|----------------------|--------------------------------------|---------------|----------------------|----------------|---------------|
| **Manager** | Orquestador global: intake, diseño, SDD, review, debugging, GPT-5.5 gate | **Único primary**. Router + clasificador + controlador de memoria + sintetizador. Invoca gentle-orch para SDD. | ✅ Sí (gentle-orch + subagentes SDD + especializados) | ✅ sí (proactivo, con gobernanza) | ✅ sí (bajo demanda) | 🟡 MEDIO: prompt ~7k, riesgo de clasificación incorrecta |
| **gentle-orchestrator** | Coordinador SDD, nunca ejecuta inline | **SDD Pipeline especializado**. NO primary. Invocado por Manager para cambios estructurados Medium/Large. | ✅ Sí (solo subagentes SDD vía task/delegate) | ⚠️ Solo por subagentes | ⚠️ Limitado por tools | 🟢 BAJO: ya no compite como primary |
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

### ARQUITECTURA OBJETIVO — Manager DEBE
- Ser el **único primary**. Responder por defecto a todos los requests.
- Clasificar requests como Tiny/Small/Medium/Large/NeedsMemory/NeedsDocs/NeedsTool/NeedsSpecialist/NeedsSDD.
- Ejecutar intake, clarificación y diseño approval para Medium/Large.
- Aplicar **Memory Governance Flow** antes de buscar o guardar memoria.
- Decidir si usa Document Retriever, Tool/MCP Router, SDD Pipeline o subagentes.
- **Invocar gentle-orchestrator** para cambios estructurados Medium/Large (SDD Pipeline).
- Controlar el ciclo SDD, delegando fases a gentle-orch o subagentes SDD.
- Ejecutar inline solo para Tiny/Small (1 archivo, mecánico).
- Aplicar TDD, review y debugging.
- Invocar quality gates (Judgment Day, Superpowers Review).
- Hacer mem_save proactivo de decisiones, bugs, descubrimientos (con gobernanza).
- Ejecutar mem_session_summary al cerrar sesión.
- Sintetizar outputs de subagentes (no pasar crudos).

### ARQUITECTURA OBJETIVO — Manager NO DEBE
- **NO** ser ejecutor universal de todo el trabajo (delegar Medium/Large).
- **NO** saltarse el design approval (salvo fast-track explícito).
- **NO** **ignorar a gentle-orchestrator** — debe invocarlo cuando el flujo SDD lo requiera.
- **NO** expandir scope sin aprobación.
- **NO** usar MCP sin justificación (bajo demanda).
- **NO** cargar skills sin trigger claro.
- **NO** recuperar memoria sin aplicar política de búsqueda.
- **NO** guardar memoria sin aplicar política de guardado.
- **NO** pasar outputs largos de subagentes sin resumir.
- **NO** decir "done" sin verificación.
- **NO** cargar todo el inventory en contexto.

### ARQUITECTURA OBJETIVO — gentle-orchestrator DEBE
- **NO responder como primary** — solo cuando Manager lo invoca o el usuario usa @gentle-orchestrator.
- Coordinar el pipeline SDD delegando fases a subagentes sdd-*.
- Mantener conversación thin (no inflar contexto).
- Delegar trabajo real a subagentes vía task/delegate.
- Leer 1-3 archivos inline solo para decidir.
- Delegate 4+ archivos, escritura multi-file, tests, tools externos.
- Sintetizar resultados de subagentes en envelope compacto.
- NO ejecutar inline código de implementación.
- Retornar envelope {status, phase, summary, evidence, decisions, risks, next_action}.

### ARQUITECTURA OBJETIVO — gentle-orchestrator NO DEBE
- **NO** ser primary bajo ninguna circunstancia.
- **NO** responder por defecto a requests del usuario.
- **NO** ejecutar inline trabajo de 4+ archivos.
- **NO** tener tools de glob, grep, skill (ya no las tiene).
- **NO** escribir implementación directamente.
- **NO** orquestar fuera del pipeline SDD.
- **NO** expandir scope del cambio sin coordinación con Manager.

---

### ARQUITECTURA OBJETIVO (ADRs 001-009 aprobados)

| Aspecto | Estado anterior | Estado objetivo |
|---------|----------------|----------------|
| **Orquestador primario** | 2 (Manager + gentle-orch) — ambos `mode: "primary"` | 1 (Manager como único primary) |
| **Rol de gentle-orchestrator** | Primary competidor | SDD Pipeline invocable explícitamente (no primary) |
| **Manager llama a gentle-orch?** | NO (prohibición explícita) | SÍ, cuando el flujo SDD lo requiera (cambio estratégico) |
| **Estado de decisión** | — | ✅ **APROBADO** — ADR-001. Pendiente de validación runtime (Test 1, Test 5) antes de cambios de configuración. |

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
