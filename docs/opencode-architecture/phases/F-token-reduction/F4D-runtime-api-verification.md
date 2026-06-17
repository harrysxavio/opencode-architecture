# F4D: Runtime API Verification

**Estado:** ✅ COMPLETED — Auditoría read-only completada  
**Propósito:** Verificar si OpenCode runtime expone APIs para cargar tool schemas selectivamente y otras optimizaciones de contexto.

---

## A. Metodología

| Item | Detalle |
|:-----|:---------|
| **Runtime** | OpenCode.exe (Electron app) — `C:\Users\harry\AppData\Local\Programs\OpenCode\OpenCode.exe` |
| **SDK** | `@opencode-ai/plugin` (v2?) en `C:\Users\harry\.config\opencode\node_modules\@opencode-ai\plugin` |
| **Plugins activos** | `engram.ts`, `background-agents.ts`, `model-variants.ts` |
| **Acceso** | Read-only — no se modificó ningún archivo |
| **Fuentes** | TypeScript definitions (`dist/index.d.ts`, `dist/tool.d.ts`), código fuente de plugins |

---

## B. Plugin API — Hooks disponibles

El plugin SDK expone estos hooks en `Hooks`:

| Hook | Input | Output | Propósito |
|:-----|:------|:-------|:----------|
| `tool` | — | `Record<string, ToolDefinition>` | Registrar herramientas del plugin |
| `event` | `Event` | — | Escuchar todos los eventos del sistema |
| `config` | `Config` | — | Modificar configuración |
| `"chat.message"` | `sessionID, agent, model` | — | Interceptar mensajes entrantes |
| `"chat.params"` | `sessionID, agent, model` | `temperature, topP, topK, maxOutputTokens` | Modificar parámetros LLM |
| `"chat.headers"` | `sessionID, agent, model` | `headers` | Modificar headers HTTP |
| `"permission.ask"` | `Permission` | `"ask" | "deny" | "allow"` | Controlar permisos |
| `"tool.execute.before"` | `tool, sessionID, callID` | `args` | Interceptar antes de ejecutar tool |
| `"tool.execute.after"` | `tool, sessionID, callID, args` | `title, output, metadata` | Interceptar después de ejecutar tool |
| **`"tool.definition"`** | `toolID` | `description, parameters` | **Modificar definición de tool antes de enviar al LLM** |
| **`"experimental.chat.system.transform"`** | `sessionID, model` | `system: string[]` | **Modificar system prompt antes de enviar al LLM** |
| **`"experimental.session.compacting"`** | `sessionID` | `context: string[], prompt?: string` | **Personalizar compactación de sesión** |
| `"experimental.compaction.autocontinue"` | `sessionID, agent, model` | `enabled: boolean` | Controlar auto-continuación post-compactación |
| `"experimental.chat.messages.transform"` | — | `messages[]` | Transformar mensajes |
| `"experimental.text.complete"` | `sessionID, messageID` | `text: string` | Completar texto |
| `"shell.env"` | `cwd, sessionID` | `env` | Modificar variables de entorno |

---

## C. Verificación de cada Quick Win

### QW#2 (Tool Schema Demand-Loading) → ✅ VIABLE

**Hook clave:** `"tool.definition"`

**Evidencia:**
```typescript
"tool.definition"?: (input: {
    toolID: string;
}, output: {
    description: string;
    parameters: any;
}) => Promise<void>;
```

Este hook se ejecuta ANTES de que la definición de cada tool se envíe al LLM. Permite:
- Devolver descripciones completas solo para herramientas necesarias en la fase actual
- Devolver descripciones mínimas (1 línea) para herramientas no relevantes
- El `parameters: any` permite incluir/omitir schemas JSON completos

**Validación adicional:** El hook `"tool.execute.before"` permite interceptar llamadas a tools con descripción mínima y cargar la definición completa si es necesario (lazy load).

**Conclusión:** No se necesita modificar el runtime de OpenCode. Se implementa como plugin TypeScript nuevo.

### QW#1 / F4B (Session History Compaction) → ✅ YA IMPLEMENTADO (parcial)

**Hook clave:** `"experimental.session.compacting"`

**Evidencia:** El plugin `engram.ts` YA USA este hook:
```typescript
"experimental.session.compacting": async (input, output) => {
  // ...  (ver engram.ts línea 430-469)
}
```

El hook actual ya:
1. Persiste memoria automáticamente en compactación
2. Inyecta contexto de sesiones previas
3. Agrega instrucción para guardar session_summary

**Lo que falta:** El hook actual no implementa RECENT_SESSION_PACK (3+7+acumulativo+R7). La implementación de F4B requeriría extender este hook con la lógica del template.

**Conclusión:** El mecanismo ya existe en producción. Solo hay que extenderlo.

### QW#5 / F4A (Skills Selective Loading) → ⚠️ VIABLE PARCIALMENTE

**Hook clave:** `"experimental.chat.system.transform"`

**Evidencia:** El plugin `engram.ts` YA USA este hook:
```typescript
"experimental.chat.system.transform": async (_input, output) => {
  if (output.system.length > 0) {
    output.system[output.system.length - 1] += "\n\n" + MEMORY_INSTRUCTIONS
  } else {
    output.system.push(MEMORY_INSTRUCTIONS)
  }
}
```

**Limitación:** Este hook **agrega** contenido al system prompt, pero no **remueve** el bloque `<available_skills>` que viene de `opencode.json`. Para removerlo, habría que modificar la fuente (opencode.json) o que el runtime permita filtrar el system prompt.

**Opción viable:** Usar `"experimental.chat.system.transform"` para agregar un SKILLS_PACK contextual (skills relevantes a la fase actual) sobreescribiendo el mensaje del sistema. Pero el bloque original seguiría presente.

**Alternativa híbrida:** 
1. Reducir las descripciones en `opencode.json` a triggers mínimos (D-F-018)
2. Usar el hook para agregar descripciones completas solo de skills relevantes en la fase actual
3. El bloque base tiene triggers, el hook agrega profundidad contextual

**Conclusión:** La reducción de descripciones necesita modificar opencode.json, pero el hook permite carga contextual adicional.

### QW#4 / F4C (mem_context Selector) → ✅ VIABLE VÍA ENGRAM

**Mecanismo:** El selector opera a nivel de Engram MCP, no a nivel de plugin de OpenCode.

**Evidencia:** `mem_context` es un tool MCP servido por Engram (`engram.exe mcp --tools=agent`). El pipeline de recuperación de contexto se puede modificar en:
1. El lado de Engram (modificando el Go binary) — mayor impacto
2. El lado del plugin (hook `"experimental.chat.system.transform"` que inyecta instrucciones al Manager para que filtre/rankeé memorias) — menor impacto
3. Un wrapper plugin que intercepte `mem_search`/`mem_context` via `"tool.execute.before"` y pos-procese resultados — medio impacto

**Conclusión:** La implementación es viable por múltiples vías. La Opción 2 (instrucciones al Manager) es la más segura y no requiere modificar Engram.

---

## D. Resumen de viabilidad

| Quick Win | Hook/MCP | Estado | Acción requerida |
|:----------|:---------|:------:|:-----------------|
| QW#1 — Session Compaction (F4B) | `experimental.session.compacting` | ✅ Mecanismo existe | Extender lógica con RECENT_SESSION_PACK |
| QW#2 — Tool Schema Demand-Loading | `tool.definition` + `tool.execute.before` | ✅ Mecanismo existe | Crear plugin nuevo |
| QW#4 — mem_context Selector (F4C) | Engram MCP + `experimental.chat.system.transform` | ✅ Múltiples vías | Elegir enfoque e implementar |
| QW#5 — Skills Block (F4A) | `opencode.json` + `experimental.chat.system.transform` | ⚠️ Parcial | Requiere modificar opencode.json PARA remover, hook PARA cargar contextual |

---

## E. Recomendaciones

1. **QW#2 (Tool Schema Demand-Loading):** Implementar como plugin TypeScript nuevo usando `"tool.definition"` hook. No requiere modificar runtime.

2. **F4B (Session Compaction):** Extender `engram.ts` para que su hook `"experimental.session.compacting"` use el template RECENT_SESSION_PACK. Esto agrega ~200 líneas al plugin existente.

3. **F4C (Selector):** Implementar vía instrucciones al Manager inyectadas por `"experimental.chat.system.transform"`. El Manager recibe reglas de scoring y filtra resultados de `mem_context` él mismo. Cero cambios en Engram.

4. **F4A (Skills):** Implementación híbrida: descripciones compactas en opencode.json + hook carga skills relevantes por fase. Requiere aprobación para modificar opencode.json.

---

## F. Riesgos identificados

| Riesgo | Severidad | Mitigación |
|:-------|:---------:|:-----------|
| `"experimental.*"` hooks pueden cambiar en futuras versiones | 🟡 Media | Monitorear changelog de OpenCode. Tener fallback sin hook. |
| Plugin nuevo puede conflictuar con background-agents.ts | 🟢 Baja | Namespace de herramientas único. Probar en aislamiento. |
| Modificar engram.ts puede romper E6B | 🔴 Alta | Regression harness existente (16/16) + E6B como gate obligatorio. |
| `tool.definition` hook no expone contexto de fase SDD | 🟡 Media | Usar `"tool.execute.before"` para detectar qué tools se llaman y ajustar próximas definiciones. |
| Modificar opencode.json tiene riesgo de corrupción | 🟡 Media | Backup automático + validación de schema post-cambio. |

---

## G. Documentación complementaria

Para referencia completa de la plugin API, ver:
- `C:\Users\harry\.config\opencode\node_modules\@opencode-ai\plugin\dist\index.d.ts` — Definiciones de hooks
- `C:\Users\harry\.config\opencode\node_modules\@opencode-ai\plugin\dist\tool.d.ts` — ToolDefinition, ToolContext
- `C:\Users\harry\.config\opencode\plugins\engram.ts` — Implementación de referencia (624 líneas)
- `C:\Users\harry\.config\opencode\plugins\background-agents.ts` — Implementación de tools con `tool()` SDK

---

*Fin de F4D-runtime-api-verification.md — Auditoría completada. 4/4 quick wins verificados como viables.*
