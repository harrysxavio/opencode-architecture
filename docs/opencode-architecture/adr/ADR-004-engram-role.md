# ADR-004: Rol de Engram

## Estado

**Aprobado** — Decisión estratégica del usuario (2026-06-09). Engram debe ser memoria gobernada, no basurero de prompts.

> ⚠️ **Pendiente de diagnóstico técnico**: Fase B0 confirmó que `memories_1.sqlite` NO tiene tabla `observations`. La gobernanza no es viable hasta reparar el pipeline de persistencia. Esto NO invalida la decisión estratégica.

---

## Contexto

Engram es el sistema de memoria persistente del ecosistema. Actualmente:

- **Configurado** en 3 lugares: `opencode.json`, `opencode.jsonc`, `config.toml`.
- **Plugin** `engram.ts` (19,136 líneas) que inyecta instrucciones de memoria, captura prompts, gestiona sesiones.
- **MCP server** que expone tools: `mem_save`, `mem_search`, `mem_context`, `mem_session_summary`, etc.
- **8 procesos engram.exe activos** simultáneamente (confirmado en Fase B0).

### Problemas detectados (Fase B0)

1. **`memories_1.sqlite` no tiene tabla `observations`**: su schema es de pipeline interno (`_sqlx_migrations`, `stage1_outputs`, `jobs`). La DB tiene 40KB pero no contiene memoria semántica.
2. **8 instancias de engram.exe** — duplicación por triple configuración MCP.
3. **Protocolo Engram triplicado**: AGENTS.md (.config), AGENTS.md (.codex), engram.ts MEMORY_INSTRUCTIONS.
4. **Prompt capture sin filtro**: guarda prompts completos sin distinguir entre útiles y ruido.
5. **Session summaries sin evidencia**: `session_index.jsonl` (57 entradas) no contiene "summary".
6. **Memories/ vacío**: solo archivos placeholder, `rollout_summaries/` vacío.
7. **Sin política de qué guardar**: todo se captura, nada se filtra.

---

## Decisión estratégica

**Engram es memoria persistente gobernada, no un basurero de prompts. Markdown versionado es la fuente de verdad arquitectónica. Engram almacena decisiones, descubrimientos y estado útil.**

### Principios de memoria

1. **La memoria debe funcionar como una biblioteca estructurada**, no como un historial de conversación.
2. **No todo merece ser recordado** — el ruido degrada la calidad del retrieval.
3. **Engram no reemplaza a los documentos** — Markdown versionado es la fuente de verdad para arquitectura, ADRs, roadmaps.
4. **Las decisiones se guardan, los prompts se olvidan** — a menos que el prompt contenga una decisión explícita.
5. **Cada memoria debe ser retrievable por intención futura** — triggers explícitos.
6. **La memoria tiene ciclo de vida** — se actualiza, se invalida, se archiva.

---

## Modelo de capas de memoria

| Capa | Qué contiene | Fuente de verdad | Cuándo se consulta | Quién escribe |
|------|-------------|-----------------|-------------------|--------------|
| **Capa 1: Core Instructions** | Instrucciones mínimas del sistema. Prompt del Manager, reglas de routing. | AGENTS.md | Siempre (inyectado al inicio) | Desarrollador |
| **Capa 2: Manager Routing Policy** | Reglas de clasificación: responder directo, buscar memoria, leer docs, delegar, SDD. | AGENTS.md + Manager prompt | Siempre | Arquitecto |
| **Capa 3: Markdown versionado** | Arquitectura, ADRs, roadmap, decisiones, diseño, test plans, convenciones. | `docs/opencode-architecture/` | Bajo demanda (Document Retriever) | Arquitecto + Manager |
| **Capa 4: Engram gobernado** | Decisiones resumidas, preferencias, hallazgos, estado de proyecto, aprendizajes técnicos, resúmenes de sesión. | Plugin engram.ts + SQLite | Bajo demanda (Memory Router) | Manager + subagentes |
| **Capa 5: Skill Registry** | Índice de capacidades: qué skill existe, trigger, ruta, scope. | `.atl/skill-registry.md` | Bajo demanda (cuando se necesita un skill) | skill-registry refresh |
| **Capa 6: Inventory** | Catálogo técnico generado: agentes, MCP, skills, plugins. | `inventory/` | Consulta humana ocasional | Script generate-static-inventory.mjs |
| **Capa 7: MCP/Tools** | Herramientas bajo demanda, activadas por intención. | Config MCP | Solo cuando el Manager lo justifica | Manager |

---

## Qué guardar en Engram

| Tipo | ¿Guardar? | Formato | Trigger de recuperación |
|------|-----------|---------|------------------------|
| **Decisiones arquitectónicas** | ✅ Sí | Resumen estructurado (What/Why/Where/Learned) | Cambio de arquitectura, nueva feature |
| **Preferencias del usuario** | ✅ Sí | Preferencia clara y concisa | Inicio de proyecto, cambio de contexto |
| **Hallazgos técnicos** | ✅ Sí | Problema + causa raíz + solución | Error similar, comportamiento inesperado |
| **Patrones reutilizables** | ✅ Sí | Patrón + cuándo usarlo + ejemplo | Tarea que coincide con el patrón |
| **Estado de proyecto** | ✅ Sí | Resumen de sesión (mem_session_summary) | Inicio de nueva sesión |
| **Bugs corregidos** | ✅ Sí | Síntoma + causa + fix + archivos afectados | Error similar, regression |
| **Resúmenes de sesión** | ✅ Sí | Goal/Instructions/Discoveries/Accomplished/Next Steps | Inicio de sesión, retoma de tarea |
| **Configuraciones descubiertas** | ✅ Sí | Config + propósito + archivo | Setup de entorno similar |

## Qué NO guardar en Engram

| Tipo | ¿Guardar? | Alternativa |
|------|-----------|-------------|
| **Prompts completos del usuario** | ❌ No | Resumir solo si contiene decisión |
| **Logs extensos** | ❌ No | Dejar en archivos de log |
| **Exploraciones irrelevantes** | ❌ No | Descartar |
| **Ruido conversacional** | ❌ No | Descartar |
| **Documentación que vive en Markdown** | ❌ No | Leer de Markdown cuando se necesite |
| **Secretos, tokens, API keys** | ❌ No | Variables de entorno |
| **Outputs extensos de subagentes** | ❌ No | Solo resumen si contiene decisión |
| **Código fuente** | ❌ No | El código está en el repositorio |
| **Errores transitorios** | ❌ No | Solo si revelan un patrón o bug recurrente |

---

## Formato de memoria (Engram)

Toda entrada en Engram debe seguir esta estructura:

```json
{
  "memory_type": "decision | preference | project_state | technical_finding | reusable_pattern | architecture_rule",
  "scope": "global | opencode | project | agent | skill | mcp",
  "topic_key": "opencode/architecture/manager-primary",
  "title": "Manager as unique primary orchestrator",
  "summary": "Resumen de 1-2 oraciones. Máximo 150 palabras.",
  "evidence": ["ruta/al/archivo.md", "ruta/al/otro.md"],
  "retrieval_triggers": ["trigger1", "trigger2"],
  "supersedes": [],
  "valid_until": null,
  "sensitivity": "low | medium | high",
  "status": "proposed | approved | deprecated"
}
```

### Reglas del formato

- **summary**: Máximo 150 palabras. Si no se puede resumir en 150, probablemente no es una buena memoria.
- **evidence**: Siempre referenciar archivos. Si no hay evidencia documental, no guardar como "decision" sino como "discovery".
- **retrieval_triggers**: Palabras clave que un futuro Manager usaría para encontrar esta memoria.
- **supersedes**: IDs de memorias que esta reemplaza (para invalidación).
- **valid_until**: Fecha de expiración. `null` = no expira.
- **sensitivity**: `low` = ok para cualquier contexto. `medium` = preguntar antes de compartir. `high` = no guardar.
- **status**: `proposed` = no aprobado aún. `approved` = decisión final. `deprecated` = reemplazada.

---

## Ciclo de vida de la memoria

```
Creación
    → ¿Es guardable? → No → Descartar
    → Sí → ¿Ya existe? → Sí → Actualizar (topic_key)
    → No → Guardar con triggers
    ↓
Recuperación
    → ¿Coincide trigger? → Sí → Retrieve
    → No → Buscar semántica
    ↓
Uso
    → ¿Sigue siendo válida? → Sí → Usar
    → No → Invalidar (valid_until, supersedes)
    ↓
Actualización
    → ¿Cambió la decisión? → Crear nueva con supersedes a la anterior
    → ¿Se refinó? → Actualizar existente (topic_key)
    ↓
Invalidación
    → ¿Expirada? → Marcar deprecated
    → ¿Reemplazada? → Marcar superseded
    → ¿Ya no aplica? → Marcar deprecated
```

---

## Dónde vive cada tipo de información

| Información | Debe vivir en |
|-------------|--------------|
| Decisión arquitectónica aprobada | ADR (Markdown) + resumen en Engram |
| Decisión arquitectónica propuesta | ADR (Markdown) |
| Preferencia del usuario | Engram |
| Hallazgo técnico | Engram + evidencia register |
| Diseño de feature | SDD artifacts (Markdown) |
| Test plan | docs/ + ADRs |
| Bug fix | Engram (causa + fix) |
| Estado de sesión | Engram (mem_session_summary) |
| Skill index | skill-registry.md |
| Catálogo de agents/MCP/tools | inventory/ |
| Código fuente | El repositorio |
| Config | opencode.json + variables de entorno |

---

## Acciones concretas (posteriores a B-Security)

1. **Reparar pipeline de persistencia**: diagnosticar por qué la DB no tiene tabla observations.
2. **Consolidar fuente de instrucciones**: Markdown versionado como fuente de verdad, plugin como mecanismo runtime, remover duplicados de AGENTS.md.
3. **Implementar filtro de guardado**: no capturar prompts completos automáticamente.
4. **Implementar política de invalidación**: soportar `supersedes` y `valid_until` en mem_save.
5. **Verificar mem_session_summary**: que se ejecute y persista correctamente.
6. **Reducir instancias Engram**: consolidar a 1 configuración MCP.

---

## Consecuencias positivas

- Memoria cross-session funcional con datos de calidad.
- Retrieval más preciso (menos ruido = mejores resultados).
- Ahorro de tokens (instrucciones desduplicadas, ~2,500 tokens).
- Ciclo de vida de memoria claro: crear, usar, actualizar, invalidar.
- Separación clara: Engram para decisiones, Markdown para arquitectura.

## Consecuencias negativas

- Esfuerzo de implementación (diagnóstico + filtros + política).
- Riesgo de perder datos si la migración no se hace correctamente.
- Cambio en el plugin engram.ts (requiere pruebas).
- Hasta reparar el pipeline, Engram sigue sin producir memoria útil.

---

## Validación requerida

1. [ ] Diagnosticar por qué la DB no tiene tabla observations.
2. [ ] Ejecutar `mem_save("test")` y verificar persistencia en SQLite.
3. [ ] Desduplicar instrucciones Engram de AGENTS.md.
4. [ ] Implementar filtro de guardado (no guardar prompts completos).
5. [ ] Verificar que `mem_session_summary` funciona y persiste.
6. [ ] Verificar retrieval con triggers.

---

## Evidencia

- **Fase B0**: memories_1.sqlite (40KB, sin tabla observations). 8 procesos engram.exe. session_index.jsonl sin summaries.
- **Archivos**: `memories_1.sqlite`, `engram.ts`, `AGENTS.md (.config):72-166`, `AGENTS.md (.codex):355-449`.
- **ADR relacionados**: ADR-002 (Manager role — memory controller), ADR-006 (token budget).
- **ID en Evidence Register**: E016, E017, E018, E019, E020, E021, E022, E023, E052, E053, E054, E060.
