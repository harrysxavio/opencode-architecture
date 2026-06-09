# ADR-002: Rol del Manager

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). Manager único primary, router principal, decisor, sintetizador.

> ✅ **Refrendado por ADR-001**: Manager es el único primary. gentle-orchestrator es SDD Pipeline invocable.

---

## Contexto

El Manager es el orquestador global. Su prompt actual (~7,000 tokens) define un protocolo completo. Con la decisión de ADR-001 (Manager único primary), su rol se expande para incluir routing explícito, control de memoria, y síntesis de resultados de subagentes y pipelines.

### Problemas que resuelve este ADR

1. **Manager puede hacer demasiado inline** — necesita límites claros de cuándo delegar vs ejecutar.
2. **Manager no tenía control de memoria explícito** — el protocolo Engram estaba en AGENTS.md, no como capacidad del Manager.
3. **Manager no clasificaba por tipo de memoria** — no distinguía entre memoria Engram, docs, ADRs, skill registry, inventory.
4. **Manager no tenía política de MCP bajo demanda** — los MCP estaban siempre disponibles o no.

---

## Decisión

**Manager es router principal, clasificador de intención, decisor de contexto, controlador de memoria, controlador de delegación, sintetizador final, y responsable de quality gates.**

### Responsabilidades objetivo

| Responsabilidad | Descripción |
|----------------|-------------|
| **Único primary** | Responde por defecto a todos los requests |
| **Router principal** | Clasifica cada request en la categoría correcta |
| **Clasificador de intención** | Decide si es Tiny, Small, Medium, Large, documentación, frontend, etc. |
| **Decisor de contexto** | Decide qué contexto recuperar (memoria, docs, skills, MCP) |
| **Controlador de memoria** | Aplica política de búsqueda y guardado de memoria antes de actuar |
| **Controlador de delegación** | Decide qué delegar, a quién, y con qué contexto mínimo |
| **Sintetizador final** | Compacta resultados de subagentes/pipelines en respuesta final |
| **Quality gates** | Aplica TDD, review, Judgment Day, debugging según corresponda |
| **Gobernanza de memoria** | Decide qué guardar, qué ignorar, qué invalidar después de cada sesión |

### Lo que Manager NO debe hacer

| Anti-patrón | Razón |
|-------------|-------|
| **NO ser ejecutor universal** | Delegar implementación compleja a subagentes |
| **NO contener todo el conocimiento** | Usar Document Retriever para docs, no inline |
| **NO duplicar gentle-orchestrator** | Invocarlo como pipeline SDD cuando corresponda |
| **NO consumir memoria sin objetivo** | Aplicar política de búsqueda antes de mem_search |
| **NO leer todo inventory** | Solo consultar paths específicos |
| **NO invocar MCP indiscriminadamente** | Solo activar MCP cuando el request lo justifique |
| **NO escribir memoria sin gobernanza** | Aplicar política de guardado antes de mem_save |
| **NO pasar outputs crudos de subagentes** | Siempre sintetizar antes de responder |

---

## Flujo de request del Manager

```
User Request
    ↓
OpenCode Runtime (agente primario = Manager)
    ↓
MANAGER — Clasificación de intención
    ├── Tiny → respuesta directa (sin memoria, sin MCP, sin SDD)
    ├── Small → lectura mínima / acción directa controlada
    ├── Needs Memory → aplicar Memory Governance Flow
    │       └── ¿Necesita memoria? → buscar Engram | docs | ADRs | skill registry
    ├── Needs Docs → Document Retriever (leer Markdown versionado)
    ├── Needs Tool → Tool/MCP Router (activar MCP bajo demanda)
    ├── Needs Specialist → Subagente especializado (frontend, seguridad, BQ)
    └── Needs Structured Change → SDD Pipeline (invocar gentle-orchestrator)
            └── gentle-orch → sdd-* executors → envelope compacto
    ↓
Manager sintetiza resultados
    ↓
Quality Gate si aplica (TDD, Review, Judgment Day, GPT-5.5)
    ↓
Respuesta final al usuario
    ↓
Memory Save Decision (¿Esto merece guardarse en Engram?)
```

---

## Flujo de decisión de memoria (obligatorio)

### Antes de buscar memoria

El Manager DEBE responder internamente:

1. ¿La respuesta requiere contexto previo?
2. ¿Ese contexto debería estar en **memoria persistente** (Engram), **documentos** (Markdown), **ADRs**, **skill registry** o **inventory**?
3. ¿Cuál es la query mínima para buscar?
4. ¿Cuántos resultados máximo se aceptan? (default: 3)
5. ¿Qué evidencia necesito?
6. ¿Qué debo descartar como ruido?

### Antes de guardar memoria

El Manager DEBE responder internamente:

1. ¿Esto será útil en futuras sesiones?
2. ¿Es una decisión, preferencia, hallazgo, patrón o estado de proyecto?
3. ¿Ya existe una memoria parecida? → buscar primero
4. ¿Debo actualizar una memoria existente en vez de crear otra? → usar topic_key
5. ¿Contradice algo anterior? → marcar como supersedes
6. ¿Debe tener fecha de expiración?
7. ¿Es sensible? → no guardar o marcar como sensitive
8. ¿Pertenece a Engram o a Markdown?
9. ¿Se puede resumir en menos de 150 palabras?
10. ¿Qué trigger futuro debería recuperarla?

---

## Clasificación de requests

| Tipo | Criterio | Acción del Manager |
|------|----------|-------------------|
| **Tiny** | Una respuesta clara. Sin archivos. Sin ambigüedad. Sin riesgo. | Responder directo. Sin memoria. Sin skills. Sin MCP. Sin SDD. |
| **Small** | Un archivo. Baja ambigüedad. Bajo riesgo. | Leer documentación si aplica. Aplicar cambio. Verificar. Sin SDD completo. |
| **Medium** | Múltiples archivos. Lógica de negocio. API. Data. Tests. | Memory Router. Document Retriever. SDD Pipeline (gentle-orch). Review. |
| **Large** | Arquitectura. Agentes. MCP. APIs. Producción. Auth. DB. | Memory Router completo. Document Retriever completo. SDD Pipeline completo. Quality Gates obligatorios. GPT-5.5 final. |
| **Documentación** | Solo lectura/consulta de docs | Document Retriever. Respuesta con fuentes. |
| **Frontend** | UI, componentes, diseño visual | Frontend Design Gate → frontend-specialist |
| **Auditoría** | Inventario, análisis, diagnóstico | Regenerar inventory si necesario. Leer docs. Análisis. |

---

## Reglas de delegación

| Situación | ¿Delega? | ¿A quién? | Mecanismo |
|-----------|----------|-----------|-----------|
| Tiny | No | — | Inline |
| Small (1 archivo, mecánico) | No | — | Inline |
| Medium (2-5 archivos, lógica) | Sí | Subagente SDD (sdd-apply) | task() sync |
| Large (5+ archivos, arquitectura) | Sí | gentle-orchestrator (SDD Pipeline) | task() sync |
| Frontend | Sí | frontend-specialist | task() sync |
| Seguridad (predeploy) | Sí | release-security-gate | task() sync |
| BigQuery | Sí | bigquery-data-quality | task() sync |
| Lectura 4+ archivos | Sí | explore subagent | task() sync |
| Proceso async largo (>5 min) | Sí | background-agents | delegate() async |

---

## Consecuencias positivas

- Manager más rápido en respuestas Tiny/Small (sin overhead de memoria/MCP/SDD).
- Menos tokens consumidos por el Manager en requests simples.
- Arquitectura clara: Manager decide, subagentes ejecutan.
- Memoria gobernada: solo datos útiles, retrieval preciso.
- MCP bajo demanda: menos tokens de schema, menos superficie de error.

## Consecuencias negativas

- Manager debe clasificar correctamente (riesgo de clasificación incorrecta).
- Dependencia de subagentes disponibles (si no existen, Manager no puede delegar).
- Mayor latencia en delegación (task/subagent overhead).
- Manager debe mantener política de memoria explícita (overhead cognitivo).

---

## Validación requerida

1. [ ] Test 1 — Verificar que Manager responde Tiny sin overhead.
2. [ ] Test 5 — Verificar que Manager invoca gentle-orch para SDD Medium/Large.
3. [ ] Verificar que Manager aplica política de memoria antes de buscar/guardar.
4. [ ] Verificar que Manager no ejecuta inline lo que debe delegar.
5. [ ] Verificar que Manager sintetiza outputs de subagentes.

---

## Evidencia

- **Fuente**: Decisión explícita del usuario (2026-06-09).
- **Archivo**: Manager prompt (opencode.json línea 49).
- **ADR relacionado**: ADR-001 (primary strategy), ADR-003 (gentle-orch role), ADR-004 (Engram role).
- **ID en Evidence Register**: E005, E008, E009, D001, D002.
