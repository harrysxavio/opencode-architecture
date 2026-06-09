# ADR-001: Estrategia de Orquestador Primario

## Estado

**Aprobado** — Decisión estratégica del usuario documentada en Fase B0. Pendiente de validación runtime (Test 1) antes de cambios de configuración.

> ✅ **Decisión explícita del usuario (2026-06-09)**: Manager es el único primary. gentle-orchestrator no compite como primary. Sus bondades SDD se integran como pipeline controlado por Manager.

---

## Contexto

Actualmente existen **dos agentes orquestadores configurados como `mode: "primary"`** en `opencode.json`:

1. **gentle-orchestrator** (líneas 4-33): Coordinador SDD original de Gentle AI. Nunca ejecuta inline, delega todo a subagentes SDD vía task/delegate.
2. **Manager** (líneas 34-51): Orquestador global híbrido con protocolo completo (intake, diseño, SDD, review, debugging, GPT-5.5).

El Manager tiene una regla explícita que le **prohíbe** invocar a `gentle-orchestrator`. Sin embargo, ambos son primary, y no hay documentación visible de cómo OpenCode resuelve la ambigüedad cuando dos agentes tienen `mode: "primary"`.

**Riesgo identificado**: El sistema puede responder con el orquestador incorrecto dependiendo de la UI o mecanismos internos de resolución.

---

## Decisión estratégica

**Manager es el único agente primario de OpenCode.**

| Aspecto | Decisión |
|---------|----------|
| **Primary por defecto** | Manager |
| **Rol de gentle-orchestrator** | SDD Pipeline especializado, invocado por Manager cuando el flujo lo requiere |
| **Bondades de gentle-orch** | Integradas bajo control del Manager (thin orchestration, fases SDD, delegación controlada, return envelope) |
| **Arquitectura resultante** | Una sola, no un collage |

### Lo que NO queremos

- Dos orquestadores compitiendo como cerebros principales.
- Que gentle-orchestrator sea un primary alternativo que pueda tomar el control de forma ambigua.
- Un mix de arquitecturas donde no quede claro quién decide.
- Que la memoria se convierta en un acumulador de ruido.
- Contexto innecesario cargado por defecto.
- Instrucciones gigantescas imposibles de mantener.
- Subagentes recibiendo contexto completo cuando solo necesitan una parte.
- MCP/tools disponibles sin criterio.

---

## Evaluación de opciones para gentle-orchestrator

### Opción A — Absorber su lógica en Manager

Extraer los patrones útiles de gentle-orchestrator (thin orchestration, SDD phase delegation, return envelope, separation of concerns, async delegation, no ejecución inline) y migrarlos al prompt/política de Manager.

| Dimensión | Evaluación |
|-----------|-----------|
| **Pros** | Un solo agente. Sin dependencia externa. Control total. |
| **Contras** | Manager prompt se infla significativamente. Lógica SDD mezclada con routing. Rompe el principio de thin orchestrator. Manager se vuelve monolítico. Difícil de mantener y testear. |
| **Riesgo** | 🔴 ALTO — Manager pierde separación de responsabilidades. Cada nueva bondad de gentle que se absorbe incrementa el prompt. Se repite el problema que se quiere evitar. |
| **Tokens** | +~3,000–5,000 tokens extras al Manager para cubrir lógica SDD que gentle ya maneja. |

### Opción B — Convertirlo en SDD Pipeline invocable (RECOMENDADA)

Manager invoca gentle-orchestrator explícitamente como un pipeline SDD especializado cuando la clasificación del request determina que se necesita un cambio estructurado (Medium/Large). gentle-orchestrator ejecuta el pipeline SDD delegando a subagentes sdd-*, y retorna un envelope compacto al Manager para síntesis final.

| Dimensión | Evaluación |
|-----------|-----------|
| **Pros** | Manager mantiene su rol de router puro. gentle-orch preserva su especialización SDD. Separación clara de responsabilidades. Thin orchestrator pattern preservado. Pipeline SDD funciona independientemente. Bajo acoplamiento. |
| **Cons** | Manager necesita lógica para decidir cuándo invocar gentle-orch (ya la tiene: clasificación Medium/Large → SDD). Dos agentes que coordinar (pero es orquestación, no competencia). |
| **Riesgo** | 🟡 BAJO — Es el modelo más maduro. Preserva lo mejor de ambos mundos. El Manager ya tiene la clasificación; solo necesita cambiar "NO llamar a gentle-orch" por "LLAMAR a gentle-orch para SDD Medium/Large". |
| **Tokens** | Manager + gentle-orch NO se cargan simultáneamente (solo se invoca gentle-orch cuando es necesario). El contexto fijo del Manager se mantiene igual. |

### Opción C — Retirarlo como agente activo

Mantener la documentación de gentle-orchestrator como referencia/patrón, pero no como agente operativo. Manager reimplementa la orquestación SDD directamente.

| Dimensión | Evaluación |
|-----------|-----------|
| **Pros** | Simplificación máxima. Menos tokens fijos (no hay gentle-orch prompt). |
| **Cons** | Pérdida del pipeline SDD puro y probado. Manager debe reimplementar thin orchestration, fase delegation, return envelope — todo lo que gentle ya hace bien. Subagentes SDD pierden el coordinador especializado. |
| **Riesgo** | 🟡 MEDIO — Manager absorbe lógica SDD, se infla, y la calidad del pipeline SDD puede degradarse porque Manager no está especializado en SDD. |
| **Tokens** | Ahorro de ~12,000 tokens de gentle-orch AGENTS.md, pero Manager necesita +~5,000 para cubrir la lógica faltante. Ahorro neto ~7,000. |

---

## Decisión sobre gentle-orchestrator: Opción B ✅

**Manager invoca gentle-orchestrator como SDD Pipeline especializado para cambios estructurados Medium/Large.**

Esto significa:

1. **Manager** clasifica el request. Si es Medium/Large con cambio estructurado → invoca gentle-orchestrator.
2. **gentle-orchestrator** ejecuta el pipeline SDD delegando a subagentes sdd-*, nunca ejecuta inline.
3. **gentle-orchestrator** retorna un envelope compacto al Manager.
4. **Manager** sintetiza el resultado, aplica quality gates si corresponde, y responde al usuario.
5. **La regla "NO llamar a gentle-orchestrator" se REEMPLAZA** por "LLAMAR a gentle-orchestrator cuando el flujo lo requiera".

### Bondades de gentle-orchestrator que se preservan

| Bondad | Cómo se preserva |
|--------|-----------------|
| Flujo SDD completo | gentle-orch ejecuta explore → propose → spec → design → tasks → apply → verify → archive |
| Separación por fases | Cada fase es un subagente sdd-* independiente |
| Delegación controlada | gentle-orch delega a subagentes, nunca ejecuta inline |
| Subagentes ejecutores | sdd-* mantienen executor boundary |
| Retorno compacto | Envelope {status, phase, summary, evidence, decisions, risks} |
| Thin orchestrator | gentle-orch mantiene conversación thin, solo sintetiza |
| Disciplina de documentación | sdd-archive persiste delta specs |
| Validación por fases | Cada fase tiene gates de entrada/salida |
| Control de calidad | sdd-verify como gate interno del pipeline |
| Cambios grandes sin saturar contexto | Delegación async + retorno compacto |

---

## Implicaciones arquitectónicas

### Lo que cambia

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Primary** | Manager + gentle-orch (ambiguo) | Manager (único) |
| **Manager llama a gentle-orch?** | NO (prohibido) | SÍ (cuando el flujo lo requiere) |
| **Mode de gentle-orch** | `"primary"` | `"subagent"` o invocable vía task |
| **Carga de AGENTS.md** | Ambos cargados según primary | Solo Manager se carga por defecto. gentle-orch se carga al invocarse. |
| **Routing SDD** | Manager o gentle-orch (ambiguo) | Manager clasifica → gentle-orch ejecuta pipeline |
| **Responsabilidad de quality gates** | Manager | Manager (post-pipeline, sobre envelope) |

### Lo que NO cambia

- Subagentes sdd-* siguen siendo ejecutores por fase, sin delegación.
- El pipeline SDD sigue siendo el mismo (explore → archive).
- El return envelope de subagentes se mantiene.
- La prohibición de que subagentes deleguen sigue vigente.

---

## Consecuencias positivas

- **Arquitectura clara**: un solo primary, un pipeline SDD especializado, subagentes ejecutores.
- **Sin ambigüedad**: el usuario siempre sabe que Manager responde por defecto.
- **Preservación de inversión**: todo el pipeline SDD y skills de gentle se mantienen intactos.
- **Control de tokens**: Manager + gentle-orch no se cargan simultáneamente en el mismo contexto.
- **Escalabilidad**: Manager puede manejar requests no-SDD sin cargar lógica SDD.
- **Calidad SDD**: gentle-orch sigue siendo el experto en pipeline SDD, Manager no necesita reimplementarlo.

## Consecuencias negativas

- Manager necesita lógica de routing para decidir cuándo invocar gentle-orch (ya existe: clasificación Medium/Large).
- Latencia adicional en requests SDD (Manager clasifica → invoca gentle-orch → gentle-orch ejecuta pipeline → retorna → Manager sintetiza).
- Posible fricción si el usuario está acostumbrado a gentle-orch como default (solución: `@gentle-orchestrator` explícito si quiere bypass).

---

## Validación requerida

1. [ ] Test 1 — Verificar que Manager responde por defecto a request simple.
2. [ ] Test 5 — Verificar que gentle-orch se invoca correctamente para request SDD.
3. [ ] Verificar que Manager puede delegar SDD a gentle-orch sin pérdida de funcionalidad.
4. [ ] Verificar que @gentle-orchestrator explícito sigue funcionando.
5. [ ] Verificar que no hay loop de delegación (Manager → gentle-orch → Manager).

---

## Evidencia

- **Fuente**: Decisión explícita del usuario (2026-06-09).
- **Archivo**: `opencode.json` — agents.gentle-orchestrator (líneas 4-33), agents.manager (líneas 34-51).
- **Hallazgo B0**: Ambos con `"mode": "primary"`. Sin regla de resolución visible.
- **ID en Evidence Register**: E001, E002, E007, D001, D002
