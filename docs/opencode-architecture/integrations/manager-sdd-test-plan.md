# Manager + SDD Test Plan

> **Estado:** ✅ TEST PLAN DESIGNED
> **Fecha:** 2026-06-17
> **Propósito:** Definir tests para validar que el Manager funciona como primary único, que los subagentes SDD son discoverables, que la delegación funciona correctamente y que no hay loops ni dependencias incorrectas.

---

## 1. Tests de Manager primary (A)

### A-T1: Manager responde por defecto

**Descripción:** El Manager debe ser el agente que responde cuando no se especifica otro agente.

**Verificación:** Enviar un prompt simple sin mencionar agentes. Verificar que Manager responde.

**Criterio:** Manager responde. Ningún otro agente primario responde.

**Comando sugerido:**
```
¿Cuál es la capital de Francia?
```

**Esperado:** Respuesta del Manager. No de gentle-orchestrator ni de otro agente.

### A-T2: Ningún subagente SDD compite como primary

**Descripción:** Los subagentes SDD deben estar configurados como `mode: subagent` y no responder por defecto.

**Verificación:** Inspeccionar `opencode.json` para verificar que todos los `sdd-*` tienen `mode: subagent`.

**Criterio:** 0 subagentes SDD con `mode: primary`. Todos tienen `mode: subagent`.

**Comando:**
```powershell
$config = Get-Content "$env:USERPROFILE\.config\opencode\opencode.json" -Raw | ConvertFrom-Json
$config.agents | Get-Member -MemberType NoteProperty | ForEach-Object {
    $agent = $config.agents.$($_.Name)
    if ($agent.mode -eq "primary") { Write-Host "PRIMARY: $($_.Name)" }
}
```

---

## 2. Tests de SDD discovery (B)

### B-T1: Todos los `sdd-*` esperados son discoverables

**Descripción:** Verificar que los 10 subagentes SDD existen en opencode.json y tienen SKILL.md.

**Esperados:** `sdd-init`, `sdd-explore`, `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, `sdd-archive`, `sdd-onboard`.

**Criterio:** Los 10 existen con `mode: subagent` y SKILL.md en disco.

**Comando:**
```powershell
$expected = @("sdd-init","sdd-explore","sdd-propose","sdd-spec","sdd-design","sdd-tasks","sdd-apply","sdd-verify","sdd-archive","sdd-onboard")
$config = Get-Content "$env:USERPROFILE\.config\opencode\opencode.json" -Raw | ConvertFrom-Json
$expected | ForEach-Object {
    $exists = $config.agents.$_ -ne $null
    Write-Host "$_ : $exists"
}
```

### B-T2: `sdd-init` está instalado correctamente

**Descripción:** Verificar que `sdd-init` tiene SKILL.md con contenido válido, frontmatter YAML, y está en opencode.json.

**Criterio:** SKILL.md existe, frontmatter válido, opencode.json lo registra.

### B-T3: `gentle-orchestrator` está como subagent

**Descripción:** Verificar que `gentle-orchestrator` tiene `mode: subagent`, no primary.

**Criterio:** `mode: subagent` en opencode.json.

### B-T4: Skills SDD no tienen `delegate` permission

**Descripción:** Los skills SDD deben tener tools explícitas (read, write, edit, bash) pero NO `task`, `delegate` ni `delegation_*`.

**Criterio:** Ningún `sdd-*` tiene `task: allow`.

---

## 3. Tests de delegación (C)

### C-T1: Tiny task no activa SDD

**Descripción:** Una pregunta simple como "¿qué hora es?" debe ser respondida directamente por el Manager, sin invocar subagentes SDD.

**Criterio:** Manager responde directo. Sin mensajes de "iniciando SDD" ni invocación a sdd-*.

### C-T2: Medium/Large task activa SDD

**Descripción:** Una tarea como "diseña una API REST para el módulo de usuarios" debe activar el pipeline SDD.

**Criterio:** Manager clasifica como Medium/Large y al menos inicia SDD init o explore.

### C-T3: Code task activa Ponytail

**Descripción:** Una tarea de implementación de código debe activar Ponytail Code Gate.

**Criterio:** La respuesta incluye referencia a simplificaciones de Ponytail o `ponytail: check`.

### C-T4: Non-code task no activa Ponytail

**Descripción:** Una tarea de documentación pura no debe activar Ponytail.

**Criterio:** La respuesta no menciona Ponytail.

### C-T5: Architecture task puede activar gentle-ai lens

**Descripción:** Una tarea de diseño arquitectónico cross-system debe poder usar gentle-ai alignment lens.

**Criterio:** La respuesta puede mencionar referencias a patrones de gentle-ai como evaluación.

### C-T6: gentle-ai runtime no se invoca

**Descripción:** En ninguna tarea debe invocarse el sistema externo gentle-ai como runtime. Ni tools, ni skills, ni MCP de gentle-ai.

**Criterio:** No hay referencias a gentle-ai como dependencia activa en la respuesta.

---

## 4. Tests de return envelope (D)

### D-T1: Subagente devuelve SUBAGENT_RESULT

**Descripción:** Cuando se invoca un subagente SDD, debe devolver un envelope estructurado.

**Criterio:** El output del subagente comienza con `## SUBAGENT_RESULT` o incluye los campos definidos.

### D-T2: Manager sintetiza final

**Descripción:** El Manager debe tomar el output del subagente y producir una respuesta coherente al usuario.

**Criterio:** El usuario ve una respuesta del Manager, no raw output del subagente.

### D-T3: Subagente no responde al usuario como cierre final

**Descripción:** El subagente no debe decir "listo" ni "completado" al usuario.

**Criterio:** En el output del subagente, no hay frases de cierre dirigidas al usuario.

---

## 5. Tests de loop prevention (E)

### E-T1: Manager no llama subagente que se llama a sí mismo

**Descripción:** Verificar que no hay configuraciones que permitan a un subagente invocarse a sí mismo.

**Criterio:** Ningún subagente tiene `task: allow` en opencode.json.

### E-T2: gentle-orchestrator no compite con Manager

**Descripción:** Verificar que gentle-orchestrator está en modo subagent y su prompt no permite actuar como primary.

**Criterio:** `mode: subagent` en opencode.json. Prompt incluye "You are the SDD Pipeline subagent, not a primary agent."

### E-T3: Manager puede invocar gentle-orchestrator

**Descripción:** Verificar que el Manager tiene permiso para invocar gentle-orchestrator (via task tool).

**Criterio:** Manager en opencode.json tiene `task: allow`.

---

## 6. Tests de Engram (F)

### F-T1: Manager decide cuándo consultar mem_context

**Descripción:** El Manager debe decidir activamente si consulta memoria. No debe consultar Engram automáticamente para toda tarea.

**Criterio:** En tareas simples sin necesidad de memoria, Manager no llama a mem_context.

### F-T2: Manager decide qué persistir

**Descripción:** El Manager debe decidir qué se guarda en Engram. Los subagentes pueden sugerir pero no persisten sin aprobación del Manager.

**Criterio:** No hay `mem_save` automático desde subagentes SDD sin decisión del Manager.

### F-T3: Subagente puede sugerir memoria pero no decide persistencia final

**Descripción:** En el return envelope, el subagente puede incluir sugerencias de memoria en `Findings`. El Manager revisa y decide.

**Criterio:** El envelope del subagente puede incluir sugerencias. Manager las revisa antes de persistir.

---

## 7. Resumen de tests

| ID | Tipo | Descripción | Prioridad |
|:--:|:----:|-------------|:---------:|
| A-T1 | Manager primary | Manager responde por defecto | 🔴 Alta |
| A-T2 | Manager primary | SDD subagents no compiten | 🔴 Alta |
| B-T1 | SDD discovery | Todos los sdd-* discoverables | 🔴 Alta |
| B-T2 | SDD discovery | sdd-init instalado correctamente | 🔴 Alta |
| B-T3 | SDD discovery | gentle-orchestrator como subagent | 🔴 Alta |
| B-T4 | SDD discovery | Skills SDD sin delegate | 🟡 Media |
| C-T1 | Delegación | Tiny no activa SDD | 🟡 Media |
| C-T2 | Delegación | Medium/Large activa SDD | 🔴 Alta |
| C-T3 | Delegación | Code task activa Ponytail | 🟡 Media |
| C-T4 | Delegación | Non-code no activa Ponytail | 🟡 Media |
| C-T5 | Delegación | Architecture puede usar gentle lens | 🟢 Baja |
| C-T6 | Delegación | gentle-ai runtime no se invoca | 🔴 Alta |
| D-T1 | Return envelope | Subagente devuelve SUBAGENT_RESULT | 🟡 Media |
| D-T2 | Return envelope | Manager sintetiza final | 🔴 Alta |
| D-T3 | Return envelope | Subagente no cierra al usuario | 🟡 Media |
| E-T1 | Loop prevention | No self-invoke de subagentes | 🔴 Alta |
| E-T2 | Loop prevention | gentle-orchestrator no compite | 🔴 Alta |
| E-T3 | Loop prevention | Manager puede invocar gentle-orch | 🟡 Media |
| F-T1 | Engram | Manager decide consulta | 🟡 Media |
| F-T2 | Engram | Manager decide persistencia | 🟡 Media |
| F-T3 | Engram | Subagente puede sugerir memoria | 🟢 Baja |

---

## 8. Tests existentes que ya cubren parte

| Gate del harness | Tests cubiertos |
|:----------------:|:---------------:|
| G7: gentle-ai Boundary (G-T1) | C-T6 |
| G4: Decision Boundaries | A-T2, B-T3 |
| G1: Artifact Integrity | B-T1, B-T2 |

---

*Fin de manager-sdd-test-plan.md*
