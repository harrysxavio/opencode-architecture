# ADR-007: Estrategia de MCP / Tool Surface

## Estado

**Propuesto** — Se requiere Fase B-Security antes de implementar.

> ⚠️ **Fase B0**: Se confirmaron 8 procesos engram.exe activos y secretos expuestos en config.toml. No se debe tocar configuración MCP hasta rotar secretos. Mantener PROPUESTO.

## Contexto

Actualmente hay **9+ MCP servers configurados** entre tres archivos:

| Archivo | MCPs |
|---------|------|
| `opencode.json` | context7, engram, notebooklm-mcp, supabase |
| `opencode.jsonc` | engram (duplicado), playwright |
| `config.toml` | github, fastmcp-toolkit, context7 (duplicado), browserbase, node_repl, engram (duplicado), playwright (duplicado) |

**Problemas detectados**:
1. **Duplicación**: Engram en 3 configs, Playwright en 2-3, Context7 en 2.
2. **Siempre activos**: Los MCP están habilitados por defecto, agregando schemas al contexto del modelo (~4,000-10,000 tokens extra).
3. **Secretos expuestos**: GitHub token y Browserbase API key visibles en `config.toml`.
4. **Auth pendiente**: Supabase y NotebookLM requieren OAuth no configurado.

## Decisión

**MCP bajo demanda: activar servers solo cuando el request lo requiera, no por defecto.**

1. **Consolidar MCP duplicados**: una sola definición por MCP en el archivo apropiado.
2. **Mover secretos a variables de entorno**: GitHub PAT y Browserbase API key.
3. **Default**: solo tools nativas (read, write, edit, bash, glob, grep, skill). MCP desactivados al inicio.
4. **Activación por intención**: el Manager o un plugin debe activar el MCP cuando el request lo requiera.
5. **MCP con auth pendiente**: documentar como no operativos hasta configurar auth.

## Razón

1. Cada MCP agrega tool schemas al contexto del modelo, consumiendo tokens y aumentando la superficie de error.
2. La mayoría de los requests no necesitan MCP. Para requests simples, tener MCP disponibles es desperdicio.
3. Secretos en texto plano son un riesgo de seguridad.
4. MCP duplicados pueden causar conflictos o comportamientos inesperados.

## Alternativas evaluadas

| Alternativa | Pros | Contras |
|-------------|------|---------|
| **A: MCP bajo demanda** (esta decisión) | Ahorro de tokens, seguridad, claridad | Requiere lógica de activación, puede romper flujos existentes |
| **B: Mantener todos activos** | Sin cambios, todo disponible | ~10k tokens extra, secretos expuestos, MCP duplicados |
| **C: Deshabilitar MCP no esenciales** | Balance entre disponibilidad y eficiencia | Decidir cuáles son "esenciales" es arbitrario |

**Decisión: Alternativa A.**

## Consecuencias positivas

- Ahorro de ~5,000-10,000 tokens fijos por sesión.
- Eliminación de secretos expuestos.
- Menor superficie de error (menos MCP = menos fallos potenciales).
- Mayor claridad (cada MCP se activa con propósito).

## Consecuencias negativas

- Requests que necesitan MCP pueden tener latencia adicional al activarlo.
- Necesita lógica de activación (plugin o prompt del Manager).
- Posible ruptura de flujos existentes que dependen de MCP siempre disponibles.

## Evidencia

- **Archivos**: `opencode.json` (183-212), `opencode.jsonc` (3-21), `config.toml` (110-151)
- **Hallazgos**: MCP duplicados, secretos expuestos, schemas costosos
- **ID en Evidence Register**: E010, E011, E012, E035, E036, E037, E038, E039, R06, R11

## Validación requerida

1. [ ] Verificar que tools nativas son suficientes para requests Tiny y Small.
2. [ ] Verificar que MCP se activan correctamente bajo demanda.
3. [ ] Mover GitHub token y Browserbase API key a variables de entorno.
4. [ ] Verificar que no hay pérdida de funcionalidad para requests que necesitan MCP.
