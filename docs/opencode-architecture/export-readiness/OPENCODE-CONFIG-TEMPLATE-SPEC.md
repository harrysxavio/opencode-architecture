# OpenCode Config Template Spec

> **Fase:** Pre-Runtime Kit Readiness Gate  
> **Fecha:** 2026-06-17  
> **Estado:** TEMPLATE SPEC DEFINED  
> **Salida futura:** `templates/opencode.example.jsonc`

---

## 1. Objetivo

Definir cómo debe verse la configuración portable para `proyecto-opencode-mem` sin copiar `opencode.json` real ni paths personales.

---

## 2. Archivo futuro

| Archivo | Propósito | Se copia al runtime automáticamente |
|---|---|---:|
| `templates/opencode.example.jsonc` | Ejemplo editable y documentado | ❌ No |
| `templates/opencode.minimal.example.jsonc` | Config mínima | ❌ No |
| `templates/opencode.full.example.jsonc` | Config full con Manager + SDD + Engram templates | ❌ No |

El usuario copia manualmente o usa `install.ps1 -DryRun` / `install.ps1 -Apply` cuando exista.

---

## 3. Variables requeridas

| Variable | Default sugerido | Uso |
|---|---|---|
| `${OPENCODE_CONFIG_DIR}` | `${HOME}/.config/opencode` | Config principal, AGENTS, plugins. |
| `${OPENCODE_SKILLS_DIR}` | `${OPENCODE_CONFIG_DIR}/skills` | Skills OpenCode. |
| `${OPENCODE_CODEX_SKILLS_DIR}` | `${HOME}/.codex/skills` | Compatibilidad con skills Codex. |
| `${OPENCODE_PLUGINS_DIR}` | `${OPENCODE_CONFIG_DIR}/plugins` | Plugins. |
| `${ENGRAM_BIN}` | configurable | Binario Engram. |
| `${ENGRAM_PROJECT}` | `opencode-architecture` o proyecto usuario | Proyecto Engram. |

---

## 4. Estructura esperada de `opencode.example.jsonc`

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "manager": {
      "mode": "primary",
      "description": "Global Manager agent",
      "permission": {
        "read": "allow",
        "glob": "allow",
        "grep": "allow",
        "task": "allow",
        "skill": "allow",
        "bash": "ask",
        "edit": "ask"
      }
    },
    "gentle-orchestrator": {
      "mode": "subagent",
      "hidden": true,
      "permission": {
        "task": {
          "*": "deny",
          "sdd-init": "allow",
          "sdd-explore": "allow",
          "sdd-propose": "allow",
          "sdd-spec": "allow",
          "sdd-design": "allow",
          "sdd-tasks": "allow",
          "sdd-apply": "allow",
          "sdd-verify": "allow",
          "sdd-archive": "allow",
          "sdd-onboard": "allow"
        }
      }
    },
    "sdd-init": { "mode": "subagent", "hidden": true },
    "sdd-explore": { "mode": "subagent", "hidden": true },
    "sdd-propose": { "mode": "subagent", "hidden": true },
    "sdd-spec": { "mode": "subagent", "hidden": true },
    "sdd-design": { "mode": "subagent", "hidden": true },
    "sdd-tasks": { "mode": "subagent", "hidden": true },
    "sdd-apply": { "mode": "subagent", "hidden": true },
    "sdd-verify": { "mode": "subagent", "hidden": true },
    "sdd-archive": { "mode": "subagent", "hidden": true },
    "sdd-onboard": { "mode": "subagent", "hidden": true }
  },
  "mcp": {
    "engram": {
      "type": "local",
      "command": ["${ENGRAM_BIN}", "mcp", "--tools=agent", "--project=${ENGRAM_PROJECT}"]
    }
  }
}
```

---

## 5. Perfiles

| Perfil | Incluye | No incluye |
|---|---|---|
| `minimal` | README/docs, no runtime config | Engram, SDD, plugins |
| `agents` | Manager template | DB real, personal config |
| `sdd` | 10 SDD subagents + config snippets | gentle-ai runtime |
| `memory-enabled` | Engram/Noise/F4C templates | DB real |
| `ponytail-code-gate` | AGENTS guidance | Ponytail plugin default |
| `gentle-alignment` | Docs/patterns only | Runtime |
| `full` | Manager + SDD + Engram templates + Ponytail guidance + harness | gentle-ai runtime, DB real, personal paths |

---

## 6. Qué NO se copia

- `~/.config/opencode/opencode.json` real.
- `~/.config/opencode/AGENTS.md` real.
- `~/.engram/engram.db`.
- `.codex/memories_1.sqlite`.
- Plugins reales con paths personales.
- Backups locales.
- Logs de sesión.
- Ponytail plugin/skills por default.
- gentle-ai runtime.

---

## 7. Validación esperada

`validate-install.ps1` futuro debe verificar:

1. No hay `C:\Users\harry` ni `OneDrive`.
2. No hay DB real ni `.sqlite` no fixture.
3. Todos los `sdd-*` están presentes en templates.
4. Todos los `sdd-*` tienen `mode: subagent`.
5. Manager es único `mode: primary`.
6. `gentle-orchestrator` no es primary.
7. `full` no incluye gentle-ai runtime.
8. Ponytail plugin no se instala salvo flag explícito futuro.

---

*Fin de OPENCODE-CONFIG-TEMPLATE-SPEC.md*
