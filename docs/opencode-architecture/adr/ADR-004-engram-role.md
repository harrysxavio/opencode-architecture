# ADR-004: Rol de Engram

## Estado

**Propuesto** — Pendiente de diagnóstico. Prioridad alta.

> ⚠️ **Fase B0**: Validación P2 confirmó que `memories_1.sqlite` NO tiene tabla `observations` — el schema es de pipeline interno. La DB tiene 40KB pero no contiene memoria semántica. La gobernanza de Engram no es viable hasta que el pipeline de guardado sea reparado.

## Contexto

Engram es el sistema de memoria persistente del ecosistema. Actualmente:

- **Configurado** en 3 lugares: `opencode.json`, `opencode.jsonc`, `config.toml`.
- **Plugin** `engram.ts` (19,136 líneas) que inyecta instrucciones de memoria, captura prompts, gestiona sesiones.
- **MCP server** que expone tools: `mem_save`, `mem_search`, `mem_context`, `mem_session_summary`.
- **Protocolo definido** en 3 fuentes: AGENTS.md (.config), AGENTS.md (.codex), engram.ts MEMORY_INSTRUCTIONS.

**Problemas detectados**:
1. `memories_1.sqlite` reportado con 4KB sin observaciones (E018).
2. Protocolo Engram duplicado en 3 fuentes (E020).
3. Prompt capture guarda prompts completos sin filtro (E021).
4. Session close protocol sin evidencia de ejecución (E022).
5. No hay criterios claros de qué guardar y qué no.

## Decisión

**Engram debe ser memoria persistente gobernada, con reglas claras de guardado, recuperación e invalidación.**

### Modelo de fuente de verdad (corrección C8)
- **Markdown versionado (engram-instructions.md, ADRs, docs/)** = fuente de verdad humana para razonamiento arquitectónico y decisiones de diseño.
- **Plugin engram.ts** = mecanismo runtime mínimo para inyectar instrucciones operativas al modelo.
- **AGENTS.md** = solo instrucciones operativas mínimas, SIN protocolo Engram inline.
- No enterrar razonamiento arquitectónico solo en plugin .ts. Mantenerlo en Markdown versionado.

### Acciones concretas
1. **Consolidar fuente de instrucciones**: Markdown versionado (engram-instructions.md) como fuente de verdad. Plugin engram.ts como mecanismo runtime. Remover duplicados de AGENTS.md.
2. **Solo datos útiles**: guardar decisiones, bugs, descubrimientos, preferencias. NO guardar prompts completos, logs, ruido.
3. **Filtro de guardado**: implementar en engram.ts para no capturar automáticamente prompts completos.
4. **Política de invalidación**: soportar `supersedes` y `valid_until`.
5. **Reparar pipeline de persistencia**: diagnosticar por qué la DB está vacía (no tiene tabla observations).
6. **Session close protocol obligatorio**: verificar que mem_session_summary se ejecute siempre.

## Razón

1. La memoria cross-session es crítica para la continuidad del trabajo.
2. Una DB vacía significa que toda la inversión en el sistema de memoria no produce valor.
3. Guardar ruido contamina el retrieval semántico.
3. Instrucciones duplicadas consumen tokens y pueden confundir al modelo.
5. Sin invalidación, la memoria se vuelve obsoleta pero sigue retrievable.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: Memoria gobernada** (esta decisión) | Datos útiles, retrieval preciso, tokens optimizados | Requiere implementar filtros y política |
| **B: Mantener estado actual** | Sin cambios | DB vacía, ruido potencial, tokens desperdiciados |
| **C: Deshabilitar Engram** | Simplificación, ahorro de tokens | Pérdida de memoria cross-session |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Memoria cross-session funcional.
- Retrieval más preciso (menos ruido).
- Ahorro de tokens (instrucciones desduplicadas).
- Datos de mayor calidad.

## Consecuencias negativas

- Esfuerzo de implementación (diagnóstico + filtros + política).
- Riesgo de perder datos si la migración no se hace correctamente.
- Cambio en el plugin engram.ts (requiere pruebas).

## Evidencia

- **Archivos**: `memories_1.sqlite` (4KB), `engram.ts`, `AGENTS.md (.config):72-166`, `AGENTS.md (.codex):355-449`
- **Hallazgos**: DB vacía, protocolo triplicado, prompt capture sin filtro
- **ID en Evidence Register**: E016, E017, E018, E019, E020, E021, E022, E023, C003, C004

## Validación requerida

1. [ ] Diagnosticar por qué la DB está vacía.
2. [ ] Ejecutar `mem_save("test")` y verificar persistencia en SQLite.
3. [ ] Desduplicar instrucciones Engram.
4. [ ] Implementar filtro de guardado en engram.ts.
5. [ ] Verificar que `mem_session_summary` funciona.
