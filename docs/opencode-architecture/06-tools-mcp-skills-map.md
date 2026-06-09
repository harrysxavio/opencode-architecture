# Tools, MCP & Skills Map

## 1. Tools nativas disponibles por agente

| Agente | Tools permitidas | Restricciones | Notas |
|--------|-----------------|---------------|-------|
| **Manager** | read, write, edit, bash, glob, grep, skill, task, todowrite | bash: ask, edit: ask | Full tool surface |
| **gentle-orchestrator** | bash, delegate, delegation_list, delegation_read, edit, read, write | Sin glob/grep/skill/task directa | No tiene skill() ni glob |
| **sdd-apply/archive/design/etc** | bash, edit, read, write | Sin task/delegate | Executor boundary |
| **frontend-specialist** | read, grep, glob, list, skill, edit, bash, lsp | edit: ask, bash: solo npm/pnpm/yarn | Frontend específico |
| **release-security-gate** | read, glob, grep, list, skill, todowrite, edit, webfetch, bash | edit: ask, usa gpt-5.5 | Security gate |
| **bigquery-data-quality** | read, grep, glob, list, skill, bash | edit: deny, bash: ask | Solo lectura |
| **sql-cleaning-agent** | read, grep, glob, list, skill, bash | edit: deny, bash: ask | Solo lectura |
| **data-memory-curator** | read, grep, glob, list, skill, bash | edit: deny, bash: ask | Solo lectura |

## 2. MCP Servers configurados

### Configurados en opencode.json

| MCP | Tipo | URL/Comando | Auth requerida | Estado | Riesgo |
|-----|------|-------------|---------------|--------|--------|
| **context7** | remote | `https://mcp.context7.com/mcp` | No | ✅ Conectado | Bajo: documentación librerías |
| **engram** | local | `engram mcp --tools=agent` | No | ✅ Conectado | 🔴 DB 4KB vacía |
| **notebooklm-mcp** | local | `uvx --from notebooklm-mcp-cli notebooklm-mcp` | Sí (OAuth) | ⚠️ Necesita auth | Medio: depende de sesión Google |
| **supabase** | remote | `https://mcp.supabase.com/mcp` | Sí (OAuth) | ⚠️ Needs auth según inventory | Medio: no operativo sin auth |
| **playwright** | local | `npx -y @playwright/mcp@latest` | No | ✅ Conectado (opencode.jsonc) | 🟡 Medio: ~2-4k tokens schemas |

### Configurados en opencode.jsonc

| MCP | Tipo | URL/Comando | Auth requerida | Estado | Riesgo |
|-----|------|-------------|---------------|--------|--------|
| **engram** (duplicado) | local | `C:\Users\harry\bin\engram.exe mcp --tools=agent` | No | ✅ Conectado | Bajo: misma funcionalidad, path diferente |
| **playwright** | local | `npx -y @playwright/mcp@latest` | No | ✅ Conectado | Mismo que en config.toml? |

### Configurados en .codex/config.toml

| MCP | Comando | Estado | Riesgo |
|-----|---------|--------|--------|
| **github** | remote via API GitHub Copilot | ⚠️ Bearer token en config | 🔴 ALTO: token visible en config.toml línea 112 |
| **fastmcp-toolkit** | `python.exe fastmcp_toolkit_server.py` | ✅ Conectado | Bajo: proyecto Linkedin |
| **context7** | `npx -y --package=@upstash/context7-mcp@2.2.5 -- context7-mcp` | ✅ Conectado | Bajo (duplicado vs opencode.json) |
| **browserbase** | remote con API key en URL | ⚠️ API key visible en URL | 🔴 ALTO: API key hardcodeada en URL línea 126 |
| **node_repl** | `node_repl.exe` | ✅ Conectado | Medio: ejecuta node |
| **engram** | `engram mcp --tools=agent` | ✅ Conectado | Bajo (duplicado) |
| **playwright** | `npx @playwright/mcp@latest` | ✅ Conectado | Bajo (tercera instancia) |

### Resumen MCP

| Total MCP configurados | 9+ (varias instancias duplicadas) |
|------------------------|----------------------------------|
| MCP únicos | Engram, Context7, NotebookLM, Supabase, Playwright, GitHub, fastmcp-toolkit, Browserbase, node_repl |
| MCP con problemas de seguridad | 2 (token GitHub en config.toml, API key Browserbase en URL) |
| MCP con auth pendiente | 2 (NotebookLM, Supabase) |
| MCP duplicados entre configs | Engram (3x), Playwright (3x), Context7 (2x) |

## 3. Skills instaladas

### Skills SDD (10 total: 8 core + 2 auxiliares)

> ⚠️ **Corrección Fase B0**: El pipeline SDD tiene 8 fases core (explore, propose, spec, design, tasks, apply, verify, archive) + 2 auxiliares (init, onboard). Total = 10. No confundir "8 fases core" con "8 subagentes".

| Skill | Tipo | Propósito | Líneas |
|-------|------|-----------|--------|
| sdd-apply | Core | Implementar cambios | 228 |
| sdd-archive | Core | Archivar cambios | 157 |
| sdd-design | Core | Diseño técnico | 176 |
| sdd-explore | Core | Exploración | 140 |
| sdd-propose | Core | Propuesta de cambio | 181 |
| sdd-spec | Core | Especificaciones | 236 |
| sdd-tasks | Core | Planificación tareas | 246 |
| sdd-verify | Core | Verificación | 70 |
| sdd-init | Auxiliar | Bootstrap SDD | 68 |
| sdd-onboard | Auxiliar | Onboarding SDD | — |

### Skills compartidas SDD

| Skill | Ruta | Propósito | Líneas |
|-------|------|-----------|--------|
| sdd-phase-common | `~/.codex/skills/_shared/sdd-phase-common.md` | Protocolo común fases SDD | 109 |
| persistence-contract | `~/.config/opencode/skills/_shared/persistence-contract.md` | Contrato persistencia SDD | 158 |
| engram-convention | `~/.config/opencode/skills/_shared/engram-convention.md` | Convención naming/upsert Engram | 136 |
| openspec-convention | `~/.config/opencode/skills/_shared/openspec-convention.md` | Convención archivos openspec/ | 103 |
| skill-resolver | `~/.codex/skills/_shared/skill-resolver.md` | Resolución skills para delegación | 72 |

### Skills especializadas (disponibles en skill-registry)

| Categoría | Skills |
|-----------|--------|
| Frontend/Design | frontend-design, canvas-design, design-md, web-design-guidelines |
| BigQuery/Data | bigquery-table-cleaning, sandbox-data-loader, sql-learning, data-memory-governance |
| Git/PR | branch-pr, chained-pr, issue-creation, work-unit-commits |
| Calidad | judgment-day, deploy-security-gate, cognitive-doc-design |
| Utilidades | flow-diagram, engram-agent, skill-creator, skill-improver, skill-registry |
| Testing | go-testing |
| Visual | graphify, hatch-pet |
| Documentación | comment-writer |

### Skills sistema (Codex .system/)

| Skill | Ruta | Propósito |
|-------|------|-----------|
| imagegen | `~/.codex/skills/.system/imagegen/SKILL.md` | Generación de imágenes |
| openai-docs | `~/.codex/skills/.system/openai-docs/SKILL.md` | Documentación OpenAI |
| plugin-creator | `~/.codex/skills/.system/plugin-creator/SKILL.md` | Crear plugins |
| skill-installer | `~/.codex/skills/.system/skill-installer/SKILL.md` | Instalar skills |

### Skills duplicadas o con problemas

| Skill | Problema | Detalle |
|-------|----------|---------|
| frontend-design | Dos ubicaciones | En opencode/skills y .agents/skills (Tools) |
| graphify | Sin uso | Skill instalada, sin graphify-out/ en ningún proyecto |
| Superpowers | No existe como SKILL.md | Referenciado en Manager prompt pero es plugin OpenAI, no skill local |
| review-gpt55 | No existe como agente | Referenciado en Manager prompt pero no configurado |
| debug-gpt55 | No existe como agente | Referenciado en Manager prompt pero no configurado |

### Skills no categorizadas en skill-registry vs skills instaladas

El skill-registry lista **48 skills**. Las skills instaladas en filesystem son **~27 en opencode + ~11 en codex + .system/**.

**Diferencia**: No todas las skills instaladas aparecen en el registry, y viceversa. Posible desincronización.

## 4. Plugins

| Plugin | Archivo | Líneas | Propósito | Riesgo |
|--------|---------|--------|-----------|--------|
| **engram.ts** | `~/.config/opencode/plugins/engram.ts` | ~19,136 | Memoria persistente, prompt capture, system injection, compaction | 🔴 Alto: tamaño masivo, inyecta contexto |
| **background-agents.ts** | `~/.config/opencode/plugins/background-agents.ts` | ~49,010 | Delegación async, persistOutput, notifyParent | 🔴 Alto: tamaño masivo, escribe fuera de undo |
| **model-variants.ts** | `~/.config/opencode/plugins/model-variants.ts` | — | Variantes de modelo para gentle-ai | 🟢 Bajo |
| Plugins OpenAI | vía config.toml | — | superpowers, documents, spreadsheets, browser, Chrome, etc. | 🟡 Medio: +15 plugins, cada uno puede inyectar contexto |

## 5. Estrategia recomendada de tool surface

| Principio | Descripción | Prioridad |
|-----------|-------------|-----------|
| **Tool surface mínimo por defecto** | Solo tools básicas: read, write, edit, bash, glob, grep, skill | 🔴 Alta |
| **MCP activados solo por necesidad** | No cargar todos los MCP al inicio. Activar bajo demanda según el request. | 🔴 Alta |
| **Separar herramientas de lectura, escritura y ejecución** | Clarificar en permisos qué herramientas son para cada propósito | 🟡 Media |
| **Gating para herramientas peligrosas** | bash: ask para destructivos, edit: ask, write en zonas protegidas | 🟡 Media |
| **Confirmación para cambios destructivos** | git push, git rebase, git reset requieren confirmación | 🟢 Baja (ya implementado) |
| **Observabilidad de llamadas** | Registrar qué tool se usó, quién, cuándo y por qué | 🔴 Alta |
| **Registro de razón de uso de cada tool** | El agente debe justificar por qué usa cada tool | 🟡 Media |

### Propuesta de surface por default

```yaml
Default tools (siempre activas):
  - read
  - write (con confirmación en paths críticos)
  - edit (con confirmación)
  - bash (con gating por comando)
  - glob
  - grep
  - skill

Bajo demanda (activar por trigger):
  - MCP: Engram (cuando se necesita memoria)
  - MCP: Context7 (cuando se necesita documentación externa)
  - MCP: NotebookLM (solo investigación profunda)
  - MCP: Playwright (solo testing visual / browser)
  - MCP: Supabase (solo operaciones DB)
  - task (solo SDD o delegación compleja)
  - delegate (solo procesos async largos)
```
