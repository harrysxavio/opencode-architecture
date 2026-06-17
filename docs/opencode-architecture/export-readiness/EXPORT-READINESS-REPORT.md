# Export Readiness Report

**Fecha:** 2026-06-17  
**Propósito:** Determinar qué partes del sistema opencode-architecture son compartibles, cuáles deben sanitizarse, y qué puede convertirse en un repositorio público o plantilla reutilizable.

---

## 1. Partes compartibles

| Componente | ¿Exportable? | Formato sugerido | Notas |
|---|---|---|---|
| Manager agent instructions | ✅ Sí | Markdown + template | AGENTS.md, Manager Protocol, reglas de orquestación |
| SDD subagent skills (sdd-*) | ✅ Sí | SKILL.md files | Skills de fases SDD (explore, propose, spec, design, tasks, apply, verify, archive) |
| F4C Memory Selector guidance | ✅ Sí | Documentation + plugin template | Reglas de ranking/dedup/decay; plugin TypeScript como template |
| F4B Compaction contract | ✅ Sí | Documentation + plugin template | RECENT_SESSION_PACK contract; plugin TypeScript como template |
| Regression harness | ✅ Sí | PowerShell script | F-regression-harness.ps1 — read-only gates |
| Fase F documentation | ✅ Sí | Markdown docs | Arquitectura, decisiones, riesgos, roadmap |
| Skill registry | ✅ Sí | SKILL.md + script | skill-registry skill, indexación automática |
| Noise Gate rules | ✅ Sí | Documentation + plugin template | Filtros de prompts antes de persistir |
| Engram memory rules | ✅ Sí | Documentation | Protocolos de memoria persistente |
| Backup/rollback scripts | ✅ Sí | PowerShell scripts | Centralizados, sin paths personales |
| Context packs design docs | ✅ Sí | Markdown docs | Diseño de paquetes de contexto |

## 2. Partes NO compartibles

| Componente | Razón | Alternativa |
|---|---|---|
| `~/.engram/engram.db` | Base de datos real con memorias personales, decisiones, bugs | Excluir; crear fixtures sintéticos |
| `~/.config/opencode/opencode.json` | Config runtime personal con rutas, preferencias | Template anonimizado |
| `~/.config/opencode/plugins/engram.ts` | Plugin real con hooks activos, user path hardcoded | Template TypeScript sin paths personales |
| Backups F4A-lite (`~/.config/opencode/backups/`) | Backups locales con paths absolutos | Excluir; documentar cómo regenerar |
| Memorias Engram en DB | Contienen decisiones, bugs, datos personales | No exportar nunca |
| `.codex/memories_1.sqlite` | Legacy DB con datos personales | No exportar |
| Documentos con rutas OneDrive | Rutas personales locales | Sanitizar antes de publicar |
| Logs, `.bak`, archivos temporales | Contienen información del entorno local | Excluir vía `.gitignore` |

## 3. Lo que debe sanitizarse

| Elemento | Buscar | Reemplazar por |
|---|---|---|
| `C:\Users\harry\` | Cualquier path absoluto Windows | `$HOME` o `~` |
| `C:\Users\harry\OneDrive\Documentos\GitHub\` | Ruta personal de repos | `$PROJECT_ROOT` |
| `harry` (nombre de usuario) | En rutas, nombres de archivo, comentarios | `{username}` o descriptor genérico |
| Tokens/API keys | `ghp_*`, `sk-*`, `AKIA*` | `{redacted}` |
| Emails personales | `*@*.com` personales | `{email}` |
| DB paths locales | `.db`, `.sqlite` | Anonimizar o excluir |

## 4. Dependencias de entorno

| Dependencia | ¿Portable? | Notas |
|---|---|---|
| Windows / PowerShell 5.1 | ❌ No portable a Linux/macOS nativamente | PowerShell Core (pwsh) compatible mayormente; scripts requieren revisión |
| OpenCode | ✅ Sí | OpenCode es el runtime; el kit asume OpenCode instalado |
| Engram plugin API | ✅ Sí | `experimental.chat.system.transform` y `experimental.session.compacting` son hooks documentados |
| Node.js / TypeScript | ✅ Sí | Plugins Engram se escriben en TypeScript |
| Git | ✅ Sí | Estándar |
| MCP tools | ⚠️ Parcial | Dependen del ecosistema OpenCode; algunas son opcionales |

## 5. Lo que puede convertirse en template

| Componente | Template para |
|---|---|
| AGENTS.md | Cualquier proyecto OpenCode que use Manager + subagentes |
| Manager Protocol | Orquestación general de agentes |
| SDD skills | Pipeline de SDD reproducible |
| F4C selector guidance | Plugin Engram con ranking de memorias |
| F4B compaction contract | Plugin Engram con manejo de compactación |
| Regression harness | Tests de regresión read-only para cualquier fase |

## 6. Lo que puede convertirse en test fixture

| Componente | Fixture |
|---|---|
| SKILL.md sample | 2-3 skills sintéticas con frontmatter válido para pruebas |
| engram.ts plugin sample | Plugin mínimo con hooks para pruebas de sistema transform |
| Engram DB sample | SQLite vacío con schema correcto para pruebas de integración |
| opencode.json sample | Config mínima anonimizada para pruebas de estructura |

## 7. Lo que puede convertirse en instalador

| Componente | Instalador haría |
|---|---|
| Plugin setup | Copiar plugin template a `~/.config/opencode/plugins/` |
| Skill bootstrap | Crear estructura de SKILL.md con frontmatter válido |
| Harness bootstrap | Copiar script de harness al proyecto |
| Engram setup | Inicializar DB, configurar proyecto |

## 8. Lo que debe quedar como documentación solamente

| Componente | Por qué |
|---|---|
| Fase F closure report | Describe decisiones y resultados — no es código ejecutable |
| Decision log | Histórico de decisiones de arquitectura |
| Risk register | Catálogo de riesgos del proyecto específico |
| Backlog / Decision matrix | Pendientes del proyecto específico |
| Roadmap | Plan de evolución — contexto del proyecto |
| Context packs design | Documentación de diseño, no implementación |
| Test strategy | Guía, no tests ejecutables directamente |

---

## Resumen ejecutivo

**Compartible:** ~80% del contenido puede publicarse como documentación, templates y scripts sanitizados.  
**No compartible:** ~20% incluye DB real, config personal, backups locales y paths personales.  
**Esfuerzo estimado de sanitización:** 2-4 horas incluyendo revisión manual y creación de templates.  
**Riesgo principal:** Publicar rutas personales, nombres de usuario o metadata del entorno local.
