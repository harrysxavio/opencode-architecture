# Portability Map

> **Fase:** Pre-Runtime Kit Readiness Gate  
> **Fecha:** 2026-06-17  
> **Estado:** PORTABILITY PLAN DEFINED  
> **Importante:** Este documento no modifica runtime. Define cómo transformar paths en templates.

---

## 1. Regla base

Nunca copiar paths personales al repo nuevo. Todo path runtime debe convertirse a variable, placeholder o ruta relativa documentada.

---

## 2. Mapa de transformación

| Actual | Template | Motivo |
|---|---|---|
| `C:\Users\harry\.codex\skills\...` | `${OPENCODE_CODEX_SKILLS_DIR}/...` | Portable para skills de usuario/codex. |
| `C:\Users\harry\.config\opencode\skills\...` | `${OPENCODE_SKILLS_DIR}/...` | Portable para skills OpenCode runtime. |
| `C:\Users\harry\.config\opencode\plugins\...` | `${OPENCODE_PLUGINS_DIR}/...` | Portable para plugins. |
| `C:\Users\harry\.config\opencode\AGENTS.md` | `${OPENCODE_CONFIG_DIR}/AGENTS.md` | Template, no copiar real. |
| `C:\Users\harry\.config\opencode\opencode.json` | `${OPENCODE_CONFIG_DIR}/opencode.json` | Solo referencia local; repo nuevo usa `opencode.example.jsonc`. |
| `C:\Users\harry\.engram\engram.db` | `${ENGRAM_DB_PATH}` | No copiar DB real; solo documentar ubicación configurable. |
| `C:\Users\harry\.codex\memories_1.sqlite` | `EXCLUDED_LEGACY_MEMORY_DB` | Nunca copiar legacy DB. |
| `C:\Users\harry\OneDrive\Documentos\GitHub\opencode-architecture` | `${SOURCE_REPO_ROOT}` | Repo origen documental. |
| `C:\Users\harry\OneDrive\Documentos\GitHub\ponytail` | `${OPTIONAL_PONYTAIL_REPO}` | Ponytail externo opcional, no dependencia default. |
| `C:\Users\harry\AppData\Local\engram\bin\engram.exe` | `${ENGRAM_BIN}` | Binario local configurable. |
| `C:\Users\harry\.config\opencode\inventory\...` | `${OPENCODE_CONFIG_DIR}/inventory/...` | Utilidad local, no requerida por kit core. |

---

## 3. Dónde aparecen

| Tipo de path | Dónde aparece hoy | Tratamiento |
|---|---|---|
| Skills SDD `.codex` | `opencode.json`, inventarios, docs | Convertir a `${OPENCODE_CODEX_SKILLS_DIR}` o copiar skill sanitizado a `skills/`. |
| Skills SDD `.config` | `opencode.json`, inventarios, docs | Convertir a `${OPENCODE_SKILLS_DIR}`. |
| AGENTS.md real | Docs de Ponytail y export | Exportar solo sección sanitizada en `templates/AGENTS.example.md`. |
| opencode.json real | Runtime audit y config | No copiar; generar `opencode.example.jsonc`. |
| Engram DB | README/docs/harness | Excluir DB; usar `${ENGRAM_DB_PATH}` solo en docs. |
| Plugins | Harness y docs | Exportar templates, no plugins reales con paths personales. |
| OneDrive/project root | Docs y scripts | Convertir a `${PROJECT_ROOT}` o paths relativos. |
| User profile / username | Docs y scripts | Convertir a `${HOME}` / `${USERPROFILE}` / `{username}` según contexto. |

---

## 4. Placeholders recomendados

| Placeholder | Significado | Ejemplo |
|---|---|---|
| `${HOME}` | Carpeta home del usuario | `${HOME}/.config/opencode` |
| `${USERPROFILE}` | Home Windows | `${USERPROFILE}\.config\opencode` |
| `${PROJECT_ROOT}` | Raíz del repo nuevo | `${PROJECT_ROOT}/skills/sdd-init/SKILL.md` |
| `${SOURCE_REPO_ROOT}` | Repo origen `opencode-architecture` | Solo docs/migración |
| `${OPENCODE_CONFIG_DIR}` | Config OpenCode | `${HOME}/.config/opencode` |
| `${OPENCODE_SKILLS_DIR}` | Skills OpenCode | `${OPENCODE_CONFIG_DIR}/skills` |
| `${OPENCODE_CODEX_SKILLS_DIR}` | Skills Codex compat | `${HOME}/.codex/skills` |
| `${OPENCODE_PLUGINS_DIR}` | Plugins OpenCode | `${OPENCODE_CONFIG_DIR}/plugins` |
| `${ENGRAM_BIN}` | Binario Engram | configurable |
| `${ENGRAM_DB_PATH}` | DB Engram local | configurable; nunca incluida |
| `${OPTIONAL_PONYTAIL_REPO}` | Checkout opcional Ponytail | no requerido por `full` |

---

## 5. Regla de sanitización

Antes de crear `proyecto-opencode-mem`, cualquier archivo candidato debe fallar si contiene:

- `C:\Users\harry`
- `OneDrive\Documentos\GitHub`
- `.engram\engram.db`
- `.codex\memories_1.sqlite`
- tokens `ghp_`, `sk-`, `AKIA`
- emails personales no `example.com`
- `.env`, `.db`, `.sqlite`, `.bak`, `.log` reales

---

## 6. Destino en `proyecto-opencode-mem`

| Origen conceptual | Destino |
|---|---|
| SDD skills | `skills/sdd-*/SKILL.md` |
| Manager template | `agents/manager/SKILL.md` y `templates/AGENTS.example.md` |
| OpenCode config | `templates/opencode.example.jsonc` |
| Engram plugin | `plugins/engram.template.ts` |
| Noise Gate | `plugins/noise-gate.template.ts` o sección dentro de Engram template |
| F4B/F4C docs | `docs/memory/` o `docs/token-optimization/` |
| Ponytail guidance | `docs/integrations/ponytail-code-gate.md` + optional `templates/AGENTS.example.md` section |
| gentle-ai alignment docs | `docs/alignment/` |
| Assurance scripts | `scripts/` y `tests/assurance/` |

---

*Fin de PORTABILITY-MAP.md*
