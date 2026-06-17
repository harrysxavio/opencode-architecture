# Export Decision Package

**Fecha:** 2026-06-17  
**Propósito:** Recomendación ejecutiva sobre la creación del repositorio público `opencode-agent-runtime-kit`.

---

## Resumen ejecutivo

**¿Conviene crear un repo nuevo?** ✅ Sí, decididamente.

**¿Por qué?** El contenido actual del repo `opencode-architecture` está mezclado con documentación de proyecto, decisiones de arquitectura, riesgos específicos, y configuración runtime personal. Esto lo hace:
- **No compartible** sin sanitización (paths personales, datos de sesión, DB real).
- **Confuso** para un usuario nuevo (demasiado contexto de proyecto específico).
- **Difícil de mantener** como plantilla (mezcla código reusable con docs de proyecto).

Un repo nuevo con el **kit sanitizado** permite:
- Que cualquier usuario de OpenCode pueda adoptar agentes, skills y plugins.
- Separar la **documentación de arquitectura** (este repo) del **código reusable** (nuevo repo).
- Tener un punto de entrada claro: README + install script + ejemplos.

---

## Recomendación

### Nombre sugerido: `opencode-agent-runtime-kit`

Alternativas consideradas:

| Nombre | Voto | Razón |
|---|---|---|
| `opencode-agent-runtime-kit` | ✅ **Recomendado** | Describe exactamente qué es: kit de runtime para agentes OpenCode |
| `opencode-sdd-kit` | ❌ | Muy específico a SDD; omite memoria, plugins, etc. |
| `opencode-starter-pack` | ❌ | Genérico; suena a plantilla vacía |
| `opencode-toolkit` | ❌ | Demasiado genérico; no comunica el valor |
| `opencode-pipeline` | ❌ | Sugiere solo CI/CD |

### Qué incluir en v0.1

**Incluir obligatoriamente:**
- Manager agent como skill (`agents/manager/SKILL.md`)
- 20+ skills SDD y utilidades (`skills/`)
- Plugins Engram template (`plugins/`)
- Templates de configuración (`templates/`)
- Regression harness (`scripts/regression-harness.ps1`)
- Instalador (`scripts/install.ps1`)
- Validador (`scripts/validate-install.ps1`)
- Documentación completa (`docs/`)
- Tests de estructura y sanitización (`tests/`)
- README, LICENSE, SECURITY.md, CHANGELOG.md, .gitignore
- GitHub Actions CI (`.github/workflows/ci.yml`)

**Incluir opcionalmente (v0.2+):**
- Fixtures sintéticos (`fixtures/`)
- Tests de plugins
- Tests de instalación
- Ejemplos de quickstart
- Scripts de sanitización

### Qué dejar fuera

| Componente | Motivo |
|---|---|
| `~/.engram/engram.db` | Datos personales — no exportable nunca |
| `~/.config/opencode/opencode.json` real | Config runtime personal |
| Backups F4A-lite | Backups locales con paths absolutos |
| Logs de sesiones | Contienen prompts, decisiones, contexto personal |
| `.codex/memories_1.sqlite` | Legacy DB con datos personales |
| Documentos con referencias a proyectos específicos del usuario | No generalizables |

---

## Riesgos

| Riesgo | Severidad | Mitigación |
|---|---|---|
| Publicar datos personales por error | 🔴 Crítico | Sanitization checklist + CI checks + doble revisión |
| El kit no funciona en Linux/macOS | 🟡 Medio | Documentar dependencia de Windows; ofrecer versiones pwsh |
| Los plugins dejan de funcionar con actualización de OpenCode | 🟡 Medio | Versionar; mantener CHANGELOG; test con cada release |
| Bajo adoption por falta de difusión | 🟢 Bajo | README claro, quickstart, ejemplos de uso |
| Confusión entre este repo y el nuevo | 🟢 Bajo | README de cada repo explica la diferencia |

---

## Esfuerzo estimado

| Actividad | Horas | Quién |
|---|---|---|
| Sanitización de archivos existentes | 4-6 | Persona técnica con acceso al runtime |
| Creación de templates (plugins, config) | 3-4 | Persona técnica TypeScript |
| Creación de instalador/validador | 2-3 | Persona técnica PowerShell |
| Creación de tests | 2-3 | Persona técnica QA |
| README, docs, ejemplos | 3-4 | Persona técnica + no técnica para review |
| CI/CD setup | 1-2 | Persona técnica DevOps |
| Release management | 1 | Cualquier persona del equipo |

**Total:** 16-23 horas distribuidas en 4-5 días.

---

## Orden de trabajo recomendado

```
Semana 1:
  Lunes:   Fase 1 (selección) + Fase 2 (sanitización inicio)
  Martes:  Fase 2 (sanitización fin) + Fase 3 (normalización)
  Miércoles: Fase 4 (templates) + Fase 5 (instalador inicio)
  Jueves:  Fase 5 (instalador fin) + Fase 6 (validador) + Fase 7 (fixtures)
  Viernes: Fase 8 (CI) + Fase 9 (README) + Fase 10 (release)
```

---

## Criterios de "listo para publicar"

- [ ] Todos los archivos sanitizados (0 paths personales, 0 tokens, 0 emails reales)
- [ ] Todos los tests de estructura PASS
- [ ] Todos los tests de sanitización PASS
- [ ] README revisado por persona técnica y no técnica
- [ ] CI verde en GitHub Actions
- [ ] Instalador probado en entorno limpio
- [ ] Validador pasa después de instalación
- [ ] CHANGELOG.md completo
- [ ] SECURITY.md con política de reporting
- [ ] LICENSE incluido (MIT recomendado)
- [ ] `.gitignore` robusto
- [ ] Release v0.1.0 creado con release notes

---

## Veredicto final

**Crear `opencode-agent-runtime-kit` es la decisión correcta.** El contenido actual tiene alto valor reusable pero está mezclado con contexto personal. Separarlo en un repo dedicado:

- **Protege la privacidad** (datos personales no se publican).
- **Mejora la adoption** (README claro, instalador simple, ejemplos).
- **Facilita el mantenimiento** (código reusable separado de docs de proyecto).
- **Permite evolucionar** (nuevo repo puede tener su propio ciclo de releases).

**Próximo paso:** Ejecutar el migration plan comenzando con Fase 1 (selección de componentes) y Fase 2 (sanitización).
