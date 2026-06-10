# ADR-003: Rol de gentle-orchestrator

> Estado Fase D: Completado. Prompt actualizado para declarar `gentle-orchestrator` como SDD Pipeline subagent, no primary. D4 validó invocación dry-run desde Manager con envelope compacto y sin loop.

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). gentle-orchestrator es SDD Pipeline especializado invocable por Manager. NO es primary.

> ✅ **Decisión**: Opción B (evaluada en ADR-001) — gentle-orchestrator como SDD Pipeline controlado por Manager. Sus bondades se preservan; su ambigüedad como primary se elimina.

---

## Contexto

`gentle-orchestrator` es el orquestador SDD original de Gentle AI. Su prompt (~12,000 tokens en AGENTS.md de .codex) lo define como coordinador que nunca ejecuta inline, delega todo a subagentes SDD, y mantiene conversación thin.

Antes de ADR-001, gentle-orchestrator era `mode: "primary"` junto con Manager, creando ambigüedad sobre cuál respondía por defecto. El Manager tenía prohibido llamar a gentle-orchestrator.

### Problemas resueltos

1. **Ambigüedad de primary**: gentle-orchestrator ya no compite como primary.
2. **Prohibición de llamada**: Manager ahora PUEDE y DEBE invocar gentle-orchestrator cuando el flujo SDD lo requiera.
3. **Subutilización**: gentle-orchestrator es experto en SDD pero solo se usaba si el runtime lo elegía como primary.

---

## Decisión

**gentle-orchestrator es un SDD Pipeline especializado, invocable explícitamente por Manager para cambios estructurados Medium/Large. NO es un orquestador primario.**

### Rol preciso

| Dimensión | Descripción |
|-----------|-------------|
| **Qué es** | Pipeline SDD especializado para cambios estructurados |
| **Qué NO es** | Orquestador primario, router general, ejecutor inline |
| **Quién lo invoca** | Manager, cuando clasifica un request como Medium/Large con cambio estructurado |
| **Cómo se invoca** | `task()` sync (default) o `@gentle-orchestrator` explícito |
| **Qué ejecuta** | Pipeline SDD completo: explore → propose → spec → design → tasks → apply → verify → archive |
| **Cómo ejecuta** | Delegando cada fase a subagentes sdd-* via task/delegate. Nunca inline. |
| **Qué retorna** | Envelope compacto: {status, phase, summary, evidence, decisions, risks, artifacts, next_action} |
| **Quién sintetiza** | Manager (recibe el envelope, lo integra en la respuesta final) |

### Bondades de gentle-orchestrator que se preservan

| Bondad | Mecanismo |
|--------|-----------|
| **Flujo SDD completo** | explore → propose → spec → design → tasks → apply → verify → archive |
| **Separación por fases** | Cada fase es un subagente sdd-* independiente con executor boundary |
| **Delegación controlada** | gentle-orch delega a subagentes, nunca ejecuta inline |
| **Retorno compacto** | Envelope estandarizado que permite al Manager sintetizar sin leer todo |
| **Thin orchestrator** | gentle-orch mantiene conversación mínima, solo coordina y sintetiza |
| **Disciplina de documentación** | sdd-archive persiste delta specs al cerrar el cambio |
| **Validación por fases** | Cada fase tiene gates: no se pasa a la siguiente sin completar la anterior |
| **Control de calidad** | sdd-verify como gate interno del pipeline antes de devolver al Manager |
| **Cambios grandes sin saturar contexto** | Delegación a subagentes + retorno compacto = contexto acotado |

### Lo que gentle-orchestrator DEBE hacer

1. Esperar invocación explícita de Manager (o `@gentle-orchestrator` del usuario).
2. Recibir contexto mínimo: objetivo del cambio, archivos afectados, restricciones.
3. Ejecutar pipeline SDD completo delegando fases a subagentes sdd-*.
4. NO ejecutar inline ninguna tarea de implementación.
5. Mantener conversación thin: solo sintetizar resultados de subagentes.
6. Retornar envelope compacto al Manager.
7. NO expandir scope del cambio sin coordinación con Manager.

### Lo que gentle-orchestrator NO DEBE hacer

| Anti-patrón | Razón |
|-------------|-------|
| **NO ser primary** | Ese rol es del Manager |
| **NO responder por defecto** | Solo cuando Manager lo invoca o el usuario usa @gentle-orchestrator |
| **NO ejecutar inline** | Esa es su regla fundamental |
| **NO delegar fuera del pipeline SDD** | No debe orquestar fuera de SDD |
| **NO expandir scope** | El scope lo define Manager en la invocación |
| **NO escribir memoria directamente** | Los subagentes pueden hacer mem_save con capture_prompt: false |

---

## Implicaciones de configuración

### Cambios necesarios en opencode.json

| Cambio | Antes | Después |
|--------|-------|---------|
| **mode** | `"primary"` | `"subagent"` |
| **Regla de Manager** | NO llamar a gentle-orch | SÍ llamar para SDD Medium/Large |
| **Visibilidad** | primary visible | subagent, posiblemente hidden |

### AGENTS.md

- El AGENTS.md de gentle-orchestrator (`.codex/AGENTS.md`, ~12,000 tokens) NO se carga por defecto.
- Solo se carga cuando Manager invoca a gentle-orchestrator.
- Esto ahorra ~12,000 tokens de contexto fijo en requests no-SDD.

---

## Consecuencias positivas

- **Pipeline SDD intacto**: gentle-orch sigue siendo el experto en SDD, no se pierde nada.
- **Sin ambigüedad**: Manager es primary, gentle-orch es pipeline.
- **Ahorro de tokens**: ~12,000 tokens de gentle-orch AGENTS.md no se cargan por defecto.
- **Preservación de inversión**: todo el pipeline SDD, skills y patrones de gentle se mantienen.
- **Flexibilidad**: el usuario puede invocar gentle-orch directamente con `@gentle-orchestrator` si quiere bypass.
- **Escalabilidad**: Manager puede manejar requests no-SDD sin cargar lógica SDD.

## Consecuencias negativas

- **Latencia adicional**: Manager clasifica → invoca gentle-orch → gentle-orch ejecuta pipeline → retorna → Manager sintetiza.
- **Dependencia de gentle-orch**: si gentle-orch falla, el pipeline SDD se interrumpe.
- **Manager necesita lógica de routing**: ya existe (clasificación Medium/Large → SDD), pero debe refinar la decisión de cuándo invocar gentle-orch vs ejecutar SDD directo.

---

## Validación requerida

1. [ ] Test 1 — Verificar que gentle-orch NO responde por defecto.
2. [ ] Test 5 — Verificar que Manager invoca gentle-orch para SDD Medium/Large.
3. [ ] Verificar que @gentle-orchestrator explícito sigue funcionando.
4. [ ] Verificar que gentle-orch retorna envelope compacto correctamente.
5. [ ] Verificar que no hay loop de delegación (Manager → gentle-orch → Manager → gentle-orch).

---

## Evidencia

- **Fuente**: Decisión explícita del usuario (2026-06-09). Opción B de ADR-001.
- **Archivo**: `opencode.json` (líneas 4-33), AGENTS.md (.codex).
- **ADR relacionado**: ADR-001 (primary strategy), ADR-002 (Manager role).
- **ID en Evidence Register**: E001, E004, E008, E009, D002.
