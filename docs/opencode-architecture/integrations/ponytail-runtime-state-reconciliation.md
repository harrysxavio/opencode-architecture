# Ponytail Runtime State Reconciliation

> **Estado:** ✅ RECONCILIATION COMPLETE
> **Fecha:** 2026-06-17
> **Propósito:** Reconciliar el estado real de Ponytail en el runtime de OpenCode: qué está instalado, qué es documental, qué falta.

---

## 1. ¿Ponytail Code Gate está en AGENTS.md?

**Sí.** Insertado en `~/.config/opencode/AGENTS.md`, líneas 261-368.

| Indicador | Resultado |
|-----------|:---------:|
| Marker `<!-- opencode-architecture:ponytail-integration -->` | ✅ Una vez (línea 261) |
| Cierre `<!-- /opcode-architecture:ponytail-integration -->` | ✅ Una vez (línea 368) |
| Contenido | 108 líneas, 8 subsecciones |
| SHA256 before | `C8F900DC3F3CEAF2A12918814D881FAEE2A9F5C591BD162A45EABCE167FF717C` |
| SHA256 after | `EABBDBD32396D737D49FB72CF0B6E2145F0B60595F74EEBC8048B410E3698FF3` |
| Backup | `backups/agents-md-ponytail-integration-20260617-142727/` |
| Backup manifest | Incluye before/after hash + timestamp |

---

## 2. ¿Ponytail plugin está realmente instalado?

**No.** El plugin NO está instalado en el runtime de OpenCode.

| Check | Resultado |
|-------|:---------:|
| `~/.config/opencode/plugins/ponytail.mjs` | ❌ No existe |
| Ponytail en `opencode.json` | ❌ No referenciado |
| Ponytail en MCP servers | ❌ No existe |
| Plugin en `~/.config/opencode/` recursivo | ❌ No existe |

El plugin SÍ existe en el checkout del repo Ponytail en `C:\Users\harry\OneDrive\Documentos\GitHub\ponytail\.opencode\plugins\ponytail.mjs`, pero **no está copiado/instalado en el runtime de OpenCode**.

---

## 3. ¿Los skills de Ponytail son discoverables?

**No.** No hay skills de Ponytail instalados en ninguna ruta de skills de OpenCode.

| Skill | En repo Ponytail | Instalado en OpenCode |
|-------|:----------------:|:---------------------:|
| `ponytail` (command) | `.opencode/command/ponytail.md` | ❌ No |
| `ponytail-review` | `.opencode/command/ponytail-review.md` | ❌ No |
| `ponytail-audit` | `.opencode/command/ponytail-audit.md` | ❌ No |
| `ponytail-debt` | `.opencode/command/ponytail-debt.md` | ❌ No |
| `ponytail-help` | `.opencode/command/ponytail-help.md` | ❌ No |

**Nota:** Estos son command skills (formato `.opencode/command/`), no skills estándar (SKILL.md). OpenCode los trataría como comandos si estuvieran en la ruta de comandos.

---

## 4. ¿Qué significa "integración documental" vs "plugin operativo"?

| Tipo | Descripción | Estado |
|------|-------------|:------:|
| **Documental** | Reglas y guías en AGENTS.md que el Manager debe seguir. No require plugin, no require skills. Funciona por instrucciones al modelo. | ✅ **ACTIVO** |
| **Plugin operativo** | Código `.mjs` que se ejecuta en cada turno (system.transform). Inyecta reglas automáticamente sin depender de que el modelo las recuerde. | ❌ **NO ACTIVO** |
| **Command skills** | Skills que el usuario o Manager pueden invocar como `/ponytail-review`. Requiere estar en la ruta de comandos. | ❌ **NO INSTALADOS** |

**La integración actual es 100% documental.** El Manager tiene instrucciones en AGENTS.md para aplicar Ponytail cuando clasifica una tarea como code task. No hay enforcement automático via plugin.

---

## 5. ¿La integración actual depende del plugin o solo de AGENTS.md?

**Solo de AGENTS.md.** La integración es puramente instruccional:

- Manager lee las reglas desde AGENTS.md (instrucciones en el system prompt)
- Manager decide cuándo aplicar (code task classification)
- Manager registra simplificaciones en el Completion Contract
- NO hay plugin que inyecte reglas automáticamente
- NO hay skills que asistan en review/audit

**Limitación:** Sin plugin, el enforcement depende de que el modelo cumpla las instrucciones. Un plugin haría el enforcement automático (system.transform) sin depender de la voluntad del modelo.

---

## 6. ¿Qué falta para que Ponytail quede completamente operativo?

| Componente | Estado | Prioridad | Notas |
|------------|:------:|:---------:|-------|
| Reglas en AGENTS.md (code-task default) | ✅ Hecho | — | Funcional como guidance |
| Plugin `ponytail.mjs` instalado | ❌ Falta | Baja | Opcional. Añade enforcement automático |
| Command skills (`ponytail-review`, etc.) | ❌ Falta | Baja | Opcional. Añaden revisión estructurada |
| Tests PT-I1 a PT-I12 en harness | ❌ Falta | Media | Ver `ponytail-integration-test-plan.md` |
| Tests GA-B1 a GA-B7 en harness | ❌ Falta | Media | Ver `gentle-ai-boundary-test-plan.md` |
| Post-restart validation | ❌ Pendiente | Media | Verificar comportamiento real tras restart |

**Conclusión:** La integración documental está completa. Plugin y skills son mejoras opcionales, no requisitos.

---

## 7. ¿Qué debe exportarse al repo nuevo?

| Componente | ¿Exportar? | Formato |
|------------|:----------:|---------|
| Reglas de activación (AGENTS.md) | ✅ Sí | Template en AGENTS.example.md |
| Reglas de exclusión (Never simplify away) | ✅ Sí | Template en AGENTS.example.md |
| Completion Contract section | ✅ Sí | Template en AGENTS.example.md |
| `ponytail.mjs` plugin | ❌ No (opcional) | Documentar cómo instalarlo |
| Command skills | ❌ No (opcional) | Documentar cómo copiarlos |
| Tests PT-I1 a PT-I12 | ✅ Sí | Como test plan documentado |
| Este reconciliation report | ✅ Sí | Como documentación de referencia |

---

## 8. Tabla resumen

| Dimensión | Estado |
|-----------|:------:|
| AGENTS.md integration | ✅ Completa (108 líneas) |
| Plugin instalado | ❌ No — existe en repo Ponytail pero no en runtime |
| Skills instalados | ❌ No — existen en repo Ponytail pero no en runtime |
| Tipo de integración | Documental (guidance-only) |
| Enforcement | Instruccional (depende del modelo) |
| Post-restart validated | ❌ Pendiente |
| Tests en harness | ❌ Pendiente (PT-I, GA-B) |
| Exportable | ✅ Sí (reglas en template) |

---

*Fin de ponytail-runtime-state-reconciliation.md*
