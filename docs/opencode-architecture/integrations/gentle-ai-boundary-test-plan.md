# gentle-ai Boundary Test Plan

> **Estado:** ✅ DISEÑADO — No implementado
> **Fecha:** 2026-06-17
> **Propósito:** Tests para verificar que gentle-ai se mantiene como alignment-only y no hay integración accidental en el runtime de OpenCode.

---

## Principios

1. **Read-only:** Los tests no modifican archivos ni configuración.
2. **No invasivos:** No requieren gentle-ai instalado.
3. **Deterministas:** Mismo resultado siempre.
4. **Ejecutables en CI:** PowerShell, sin dependencias externas.
5. **Gate de regresión:** Fallar si aparece integración accidental.

---

## Test GA-B1: Manager no requiere gentle-ai

**ID:** GA-B1
**Propósito:** Verificar que el Manager puede operar sin gentle-ai instalado.
**Precondición:** Sesión OpenCode activa.
**Pasos:**
1. Verificar que no hay `gentle-ai` en agentes de `opencode.json`.
2. Verificar que no hay `gentle-orchestrator` como primary en `opencode.json`.
3. Verificar que el Manager responde sin gentle-ai (functional check).

**Criterio de éxito:** No hay agente gentle-ai en runtime. Manager funciona sin gentle-ai.

**Comando:**
```powershell
$config = Get-Content "$env:USERPROFILE\.config\opencode\opencode.json" | ConvertFrom-Json
$agents = $config.agents.PSObject.Properties.Name
if ($agents -match "gentle") { throw "Found gentle agent in opencode.json" }
Write-Host "PASS: No gentle agent in opencode.json"
```

---

## Test GA-B2: Perfil full no incluye gentle-ai runtime

**ID:** GA-B2
**Propósito:** Verificar que el perfil `full` del futuro repo no incluye gentle-ai como dependencia runtime.
**Precondición:** Archivo de definición de perfiles existe.
**Pasos:**
1. Verificar que `full` profile no referencia gentle-ai.
2. Verificar que ningún archivo en `scripts/install.ps1` referencia gentle-ai.
3. Verificar que ningún template de plugin referencia gentle-ai.

**Criterio de éxito:** Perfil full es 100% OpenCode-nativo, sin gentle-ai.

---

## Test GA-B3: gentle-ai solo aparece en docs/alignment

**ID:** GA-B3
**Propósito:** Verificar que gentle-ai solo se referencia en documentación de alineación, no en código runtime.
**Precondición:** Repositorio opencode-architecture clonado.
**Pasos:**
1. Grep por "gentle-ai" en archivos `.ts` — debe ser 0.
2. Grep por "gentle-ai" en `*.json` — debe ser 0 (excepto ejemplos sanitizados).
3. Grep por "gentle-ai" en `AGENTS.md` — debe ser 0.
4. Grep por "gentle-ai" en `*.ps1` — debe ser 0 (excepto comentarios).
5. Grep por "gentle-ai" en `SKILL.md` — debe ser 0.

**Criterio de éxito:** gentle-ai solo aparece en `docs/` markdown files.

**Comando:**
```powershell
$codeMatches = Select-String -Path "*.ts","*.json","*.ps1" -Pattern "gentle-ai" -SimpleMatch -ErrorAction SilentlyContinue
if ($codeMatches) { throw "gentle-ai found in runtime files" }
Write-Host "PASS: gentle-ai only in docs/"
```

---

## Test GA-B4: No hay tool gentle-ai obligatoria

**ID:** GA-B4
**Propósito:** Verificar que no hay tool schemas de gentle-ai en el runtime.
**Precondición:** opencode.jsonc o opencode.json cargado.
**Pasos:**
1. Verificar que `gentle-ai` no está en `mcp` servers.
2. Verificar que ningún comando del sistema referencia gentle-ai.
3. Verificar que no hay plugin gentle-ai en `~/.config/opencode/plugins/`.

**Criterio de éxito:** No hay tools MCP de gentle-ai, no hay plugins de gentle-ai.

---

## Test GA-B5: No hay subagente gentle-ai obligatorio

**ID:** GA-B5
**Propósito:** Verificar que no hay subagente gentle-ai en la configuración runtime.
**Precondición:** opencode.json legible.
**Pasos:**
1. Listar agentes en opencode.json.
2. Verificar que ninguno se llama `gentle-*` o `gentle-orchestrator` con `mode: primary`.
3. `gentle-orchestrator` puede existir como subagent, pero no debe ser primary.

**Criterio de éxito:** gentle-orchestrator no es primary. No hay gentle-ai como agente.

**Comando:**
```powershell
$agents = Get-Content "$env:USERPROFILE\.config\opencode\opencode.json" | ConvertFrom-Json
foreach ($name in $agents.agents.PSObject.Properties.Name) {
    if ($name -match "gentle") {
        $mode = $agents.agents.$name.mode
        if ($mode -eq "primary") { throw "gentle agent '$name' is primary" }
        Write-Host "INFO: gentle agent '$name' mode=$mode (acceptable if subagent)"
    }
}
```

---

## Test GA-B6: No hay dependencia OpenCode ↔ gentle-ai

**ID:** GA-B6
**Propósito:** Verificar que no hay imports, requires, o referencias a gentle-ai en plugins.
**Precondición:** Plugin engram.ts existe.
**Pasos:**
1. Grep en `engram.ts` por "gentle-ai" o "gentle" — debe ser 0.
2. Grep en `background-agents.ts` por "gentle-ai" — debe ser 0.
3. Verificar que ningún script npm/package.json referencia gentle-ai.

**Criterio de éxito:** Cero referencias a gentle-ai en plugins y scripts runtime.

---

## Test GA-B7: Integración futura requiere decision record

**ID:** GA-B7
**Propósito:** Verificar que cualquier integración futura con gentle-ai está precedida por un decision record aprobado.
**Precondición:** Repositorio accesible.
**Pasos:**
1. Si existe integración gentle-ai en runtime, verificar que hay un decision record en `decision-log.md`.
2. El decision record debe incluir: riesgo, alternativas, tests, rollback, aprobación.
3. Sin decision record, la integración se considera accidental y debe revertirse.

**Criterio de éxito:** Toda integración gentle-ai runtime está respaldada por un decision record.

---

## Matriz de cobertura

| Test | ID | Prioridad | Automatable | CI-ready |
|------|:--:|:---------:|:-----------:|:--------:|
| Manager no requiere gentle-ai | GA-B1 | 🔴 Alta | ✅ Sí | ✅ Sí |
| Perfil full no incluye gentle-ai | GA-B2 | 🔴 Alta | ✅ Sí | ✅ Sí |
| gentle-ai solo en docs/alignment | GA-B3 | 🔴 Alta | ✅ Sí | ✅ Sí |
| No hay tool gentle-ai obligatoria | GA-B4 | 🟡 Media | ✅ Sí | ✅ Sí |
| No hay subagente gentle-ai obligatorio | GA-B5 | 🟡 Media | ✅ Sí | ✅ Sí |
| No hay dependencia OpenCode ↔ gentle-ai | GA-B6 | 🔴 Alta | ✅ Sí | ✅ Sí |
| Integración futura requiere decision record | GA-B7 | 🟡 Media | ⚠️ Parcial | ⚠️ Parcial |

---

*Fin de gentle-ai-boundary-test-plan.md*
