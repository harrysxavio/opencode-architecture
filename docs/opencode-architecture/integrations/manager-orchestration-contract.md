# Manager Orchestration Contract

> **Estado:** ✅ CONTRACT DEFINED
> **Fecha:** 2026-06-17
> **Propósito:** Definir el rol del Manager como orquestador único, qué debe hacer, qué NO debe hacer, y qué delega a quién.

---

## 1. El Manager es

| Rol | Descripción |
|-----|-------------|
| **Primary único** | El agente que responde por defecto. No hay otro primary compitiendo. |
| **Intake owner** | Recibe y entiende el pedido del usuario. Pregunta si falta contexto. |
| **Classifier** | Clasifica la tarea: Tiny, Small, Medium, Large. Code o non-code. Arquitectura o implementación. |
| **Router** | Decide si ejecuta directo o delega. Decide a quién delegar. |
| **Delegator** | Delega fases a subagentes SDD, tools MCP, skills o lentes de evaluación. |
| **Context governor** | Decide qué contexto cargar: Engram memory, Graphify, skills, contexto de proyecto. |
| **Memory coordinator** | Decide qué se guarda en Engram y qué no. Subagentes pueden sugerir, Manager decide. |
| **Quality gate owner** | Ejecuta los quality gates: review, debugging, GPT-5.5 final gate. |
| **Final synthesizer** | Toma los resultados de subagentes y tools, y produce la respuesta final al usuario. |

---

## 2. El Manager NO es

| No es | Por qué |
|-------|---------|
| **Monolito que hace todo** | Si el Manager ejecuta todas las fases, se infla y pierde el beneficio de los subagentes especializados |
| **Ejecutor de todas las fases** | Para tareas Medium/Large, debe delegar explore, propose, spec, design, tasks, apply, verify, archive |
| **Reemplazo de todos los subagentes** | Cada subagente SDD tiene su especialidad. Manager coordina, no reemplaza |
| **Copia de gentle-orchestrator** | Manager es el jefe de proyecto. gentle-orchestrator es un coordinador de pipeline SDD invocable |
| **Runtime wrapper de gentle-ai** | Manager no depende de gentle-ai externo. Usa patrones, no runtime |
| **Único decisor técnico** | En tareas grandes, los subagentes proponen, el Manager decide. El usuario tiene la última palabra |
| **Filtro de todo el output** | El Manager no re-escribe lo que hacen los subagentes. Sintetiza, no re-procesa |

---

## 3. Tabla de responsabilidades

| Responsabilidad | Manager hace | Manager no hace | Delegado a |
|----------------|:------------:|:---------------:|------------|
| **Intake** | Recibe, clarifica, resume | No implementa sin intake | — |
| **Clasificación** | Tiny/Small/Medium/Large + code/non-code | No salta clasificación | — |
| **Recuperación de memoria** | Decide si buscar | No adivina contexto | `mem_context` (Engram MCP) |
| **Persistencia de memoria** | Decide qué guardar | No guarda todo | Noise Gate + Engram (`mem_save`) |
| **SDD Init** | Decide si iniciar SDD. Invoca a sdd-init | No implementa SDD init manual si sdd-init existe | `sdd-init` (si existe) |
| **SDD Explore** | Inicia fase, recibe findings | No ejecuta explore manual | `sdd-explore` |
| **SDD Propose** | Recibe opciones, decide | No escribe propuesta manual | `sdd-propose` |
| **SDD Spec** | Revisa spec, aprueba | No escribe spec manual | `sdd-spec` |
| **SDD Design** | Revisa diseño, aprueba | No diseña manual | `sdd-design` |
| **Code minimization** | Activa Ponytail si code task | No aplica Ponytail a non-code | Ponytail Code Gate |
| **SDD Tasks** | Revisa tareas, ordena | No descompone manual | `sdd-tasks` |
| **SDD Apply** | Monitorea progreso | No implementa manual | `sdd-apply` |
| **SDD Verify** | Recibe resultados, decide | No verifica manual | `sdd-verify` |
| **SDD Archive** | Archiva decisiones | No archiva manual | `sdd-archive` |
| **Code Review** | Revisa calidad general | No re-escribe código | Code Review phase + Ponytail review |
| **Debugging** | Inicia debugging, coordina | No debuggea manual si hay subagente | `@debug-gpt55` o debugging phase |
| **GPT-5.5 final gate** | Ejecuta quality gate final | No salta quality gates | GPT-5.5 review |
| **Senior challenge** | Aplica lente cross-system | No omite en decisiones grandes | gentle-ai alignment lens |
| **Final answer** | Sintetiza todo y responde | No copia textual output de subagentes | — |

---

## 4. Flujo de decisión del Manager

```mermaid
flowchart TD
    U[User request] --> M[Manager intake]
    M --> C{Classify}
    
    C -->|Tiny| A[Answer directly]
    C -->|Small code| B[Direct tools/skills + quick review]
    C -->|Medium/Large| D[Start SDD pipeline]
    C -->|Architecture| E[Apply gentle-ai alignment lens]
    C -->|Code impl/review| F[Apply Ponytail if code task]
    C -->|Memory needed| G[mem_context]
    
    D --> H{sdd-init exists?}
    H -->|Yes| I[Delegate to sdd-init]
    H -->|No| J[Manager minimal init]
    
    I --> K[sdd-explore/propose/spec/design]
    J --> K
    
    K --> L{Code task?}
    L -->|Yes| F
    L -->|No| M[Continue SDD]
    
    F --> N[sdd-tasks/apply/verify/archive]
    M --> N
    
    N --> O[Manager final synthesis]
    O --> P[Quality gates]
    P --> Q[Final answer]
```

---

## 5. Principios de orquestación

| Principio | Explicación |
|-----------|-------------|
| **Thin orchestrator** | El Manager no hace el trabajo de los subagentes. Los coordina. |
| **Subagentes son herramientas, no decisiones** | Los subagentes proponen, el Manager dispone. |
| **El Manager siempre sintetiza** | El usuario recibe la respuesta del Manager, no de los subagentes. |
| **No loop** | Manager puede llamar subagentes. Subagentes NO llaman a Manager. Subagentes NO se llaman entre sí. |
| **Clasificación ante todo** | Tiny → directo. Medium/Large → SDD. Code → Ponytail. Arquitectura → gentle lens. |
| **Contexto justo** | Manager no carga todo el contexto siempre. Decide qué cargar según la tarea. |
| **El usuario decide al final** | Manager propone, el usuario aprueba. Especialmente en diseño, implementación y cambios runtime. |

---

## 6. Anti-patrones de orquestación

| Anti-patrón | Por qué evitarlo | Alternativa correcta |
|-------------|------------------|----------------------|
| Manager hace SDD init manual cuando sdd-init existe | Duplica esfuerzo, pierde estructura | Delegar a `sdd-init` |
| Manager escribe todo el código | Se vuelve monolítico, sin especialización | Delegar a `sdd-apply` |
| Manager no clasifica y aplica SDD a todo | Overhead en tareas simples | Clasificar Tiny/Small/Medium/Large |
| Manager aplica Ponytail a documentación | Overhead de tokens sin beneficio | Clasificar code vs non-code |
| Manager ignora a subagentes y hace todo | Se infla, pierde calidad | Confiar en subagentes especializados |
| Manager deja que subagentes respondan al usuario | El usuario pierde el hilo | Manager siempre sintetiza |

---

*Fin de manager-orchestration-contract.md*
