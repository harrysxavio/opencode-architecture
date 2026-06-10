# Token Cost Map — Mapa de Costo de Tokens

## 1. Advertencia

Esta sección presenta **estimaciones** basadas en la suma de fuentes de contexto conocidas. No se realizó medición directa en runtime. Los valores son aproximaciones para identificar oportunidades de optimización.

## 2. Tokens fijos por sesión — Estimación no validada

> ⚠️ **Corrección Fase B0**: Las cifras siguientes son estimaciones basadas en suma de fuentes conocidas. NO hay medición runtime. La estimación de ~29,000 asume ambos AGENTS.md simultáneos, lo cual es incorrecto — solo UN agente por sesión. Rango conservador: **~18,500–22,000 tokens**.

Se inyectan siempre, independientemente del request.

| Fuente de tokens | Tipo | Se inyecta siempre | Se inyecta bajo demanda | Estimación (tokens) | Evidencia | Riesgo | Recomendación |
|-----------------|------|-------------------|------------------------|---------------------|-----------|--------|---------------|
| System prompt base | System | ✅ Sí | ❌ No | ~3,000 | Inferido por composición típica de Codex | Bajo | Mantener |
| AGENTS.md (.codex/ — gentle-orch) | Agent prompt | ✅ Sí (cuando gentle-orch activo) | ❌ No | ~12,000 | Archivo: 449 líneas | 🔴 Alto | Reducir: mover a skills/documentos |
| AGENTS.md (.config/opencode — Manager) | Agent prompt | ✅ Sí (cuando Manager activo) | ❌ No | ~7,000 | Archivo: 259 líneas | 🟡 Medio | Reducir: mover Engram protocol a plugin |
| Available skills list | System | ✅ Sí | ❌ No | ~3,000 | 48 skills en registry | 🟡 Medio | Solo cargar triggers relevantes |
| Engram MEMORY_INSTRUCTIONS | System | ✅ Sí (plugin inyecta) | ❌ No | ~2,500 | engram.ts líneas 64-141 | 🟡 Medio | Desduplicar con AGENTS.md |
| Background-agents delegation rules | System | ✅ Sí (plugin inyecta) | ❌ No | ~1,000 | background-agents.ts 1425-1430 | Bajo | Mantener |
| Design skills protocol | System | ✅ Sí | ❌ No | ~1,500 | AGENTS.md líneas 168-259 | Bajo | Mover a skill bajo demanda si no es frontend |
| Tool schemas nativas | System | ✅ Sí | ❌ No | ~2,000 | read, write, edit, bash, glob, grep, skill, task | Bajo | Mantener |
| MCP tool schemas | System | ✅ Sí (si MCP activo) | ❌ No | ~4,000-10,000 | 9+ MCP servers | 🔴 Alto | Reducir superficie default; activar bajo demanda |
| **Rango conservador** | | | | **~18,500–22,000** | | 🔴 **ALTO** | |
| **Estimación conflictiva anterior** | | | | **~29,000–38,000** | | 🔴 **CONFLICTO** | Requiere medición runtime |

## 3. Tokens variables por request

| Fuente de tokens | Tipo | Se inyecta siempre | Se inyecta bajo demanda | Estimación | Evidencia | Riesgo | Recomendación |
|-----------------|------|-------------------|------------------------|-------------|-----------|--------|---------------|
| Input del usuario | Variable | ✅ Sí | ❌ No | ~50-5,000 | Por request | Bajo | N/A |
| Skill content cargado | Variable | ❌ No | ✅ Sí (trigger) | ~2,000-10,000 | SKILL.md típico: 140-250 líneas | 🟡 Medio | Solo cargar si trigger claro |
| Documentos leídos | Variable | ❌ No | ✅ Sí (read tool) | ~500-50,000+ | Por archivo | 🟡 Medio | Leer solo necesario |
| Output de subagentes | Variable | ❌ No | ✅ Sí (task return) | ~1,000-20,000+ | Envelope SDD típico | 🟡 Medio | Pasar resúmenes, no outputs completos |
| Memoria recuperada | Variable | ❌ No | ✅ Sí (mem_search) | ~500-5,000+ | Observaciones Engram | 🟡 Medio | Query precisa, límite de resultados |
| Output del modelo (respuesta) | Variable | ❌ No | ✅ Sí | ~100-10,000+ | Por respuesta | Bajo | N/A |
| Multi-turn conversation history | Variable | ✅ Sí (historial) | ❌ No | ~2,000-50,000+ | Por duración de sesión | 🔴 Alto | Compactar periódicamente |

## 4. Tokens por tools/MCP

| Tool/MCP | Tokens por schemas | Frecuencia típica | Costo acumulado |
|----------|-------------------|-------------------|----------------|
| read | Incluido en nativas | Alta | Bajo-medio |
| write | Incluido en nativas | Media | Bajo |
| edit | Incluido en nativas | Media | Bajo |
| bash | Incluido en nativas | Media | Bajo-medio (output) |
| glob | Incluido en nativas | Baja | Muy bajo |
| grep | Incluido en nativas | Media | Bajo |
| skill | Incluido en nativas | Baja | Medio (carga SKILL.md) |
| task | Incluido en nativas | Media | Alto (output subagente) |
| Engram MCP (mem_save/search/etc) | ~500-1,000 | Media | Bajo |
| Context7 MCP | ~500-1,000 | Baja | Bajo |
| NotebookLM MCP | ~1,000-2,000 | Baja | Medio |
| Playwright MCP | ~2,000-4,000 | Baja | Medio |
| Supabase MCP | ~500-1,000 | Muy baja | Bajo |
| GitHub MCP | ~500-1,000 | Baja | Bajo |
| Browserbase MCP | ~2,000-4,000 | Muy baja | Medio |
| node_repl MCP | ~500-1,000 | Muy baja | Bajo |
| fastmcp-toolkit | ~500-1,000 | Muy baja | Bajo |

## 5. Token Budget Propuesto

### Definición de rangos por tipo de request

| Tipo de request | Token budget estimado | Tokens fijos (INFERIDO) ⚠️ | Tokens variables | Notas |
|----------------|----------------------|---------------------------|-----------------|-------|
| Simple (Tiny) | ~20,000-27,000 | ~18,500–22,000 | ~1,000-5,000 | Sin skills, sin MCP, sin memoria |
| Con memoria | ~22,000-32,000 | ~18,500–22,000 | ~3,000-10,000 | mem_context + mem_search |
| Con documento | ~22,000-42,000+ | ~18,500–22,000 | ~3,000-20,000+ | read + análisis |
| Con SDD parcial | ~24,000-52,000 | ~18,500–22,000 | ~5,000-30,000 | 1-3 fases SDD |
| Con SDD completo | ~29,000-92,000+ | ~18,500–22,000 | ~10,000-70,000+ | 8 fases + subagentes |
| Con MCP | ~24,000-47,000 | ~18,500–22,000 | ~5,000-25,000 | MCP tool schemas + consultas |
| Multiagente | ~39,000-142,000+ | ~18,500–22,000 | ~20,000-120,000+ | Delegaciones + outputs |

> ⚠️ **Corrección Fase B0/B1**: La columna "Tokens fijos" fue corregida de ~29,000 a ~18,500–22,000 porque ~29,000 asumía que ambos AGENTS.md (Manager + gentle-orchestrator) se cargan simultáneamente, lo cual es INCORRECTO — solo el agente activo carga su AGENTS.md. Pendiente de medición real con Test 8.

### Reglas de control

| Regla | Descripción | Prioridad |
|-------|-------------|-----------|
| R1 | No cargar skills si no hay trigger claro | 🔴 Alta |
| R2 | No leer inventory completo salvo auditoría | 🟡 Media |
| R3 | No inyectar AGENTS.md duplicados (desduplicar protocolo Engram) | 🔴 Alta |
| R4 | No recuperar memoria sin objetivo (query específica) | 🟡 Media |
| R5 | No usar MCP si basta lectura local (ej: docs internos vs Context7) | 🟡 Media |
| R6 | No delegar si la tarea es Tiny | 🟢 Baja |
| R7 | No pasar outputs largos al Manager; pasar resúmenes estructurados | 🟡 Media |
| R8 | No guardar prompts completos como memoria útil (solo si necesario) | 🟡 Media |
| R9 | No usar Graphify hasta tener caso claro y aprobación | 🟢 Baja |
| R10 | No usar SDD completo para cambios Tiny/Small | 🟡 Media |
| R11 | Activar MCP solo cuando el request lo requiera | 🔴 Alta |
| R12 | Compactar historial multi-turn periódicamente | 🟡 Media |

## 6. Estimación de overhead mínimo — No validada

> ⚠️ **Corrección Fase B0**: Cálculo revisado. El total de ~20,550 es más realista que ~29,000 porque NO asume ambos AGENTS.md simultáneos. Pendiente de medición runtime (Test 8).

Para un request simple como "Hola" con Manager:

| Componente | Tokens (estimado) | Notas |
|-----------|--------|-------|
| System prompt base | ~3,000 | Código engine fijo |
| AGENTS.md Manager | ~7,000 | 259 líneas |
| Available skills | ~3,000 | 48 skills |
| Engram MEMORY_INSTRUCTIONS | ~2,500 | Plugin injection |
| Background-agents rules | ~1,000 | Plugin injection |
| Design skills protocol | ~1,500 | 90 líneas de protocolo frontend |
| Tool schemas (sin MCP) | ~2,000 | read, write, edit, bash, etc. |
| Historial (fresh) | ~500 | Saludo inicial |
| Input del usuario | ~50 | "Hola" |
| **Rango estimado** | **~18,500–22,000** | Sin MCP, sin skills, sin memoria. NO ambos AGENTS.md |
| **Con MCP activos** | **~24,000–34,000** | Depende de cuántos MCP tengan schemas |

## 7. Oportunidades principales de optimización

| Oportunidad | Ahorro estimado | Esfuerzo | Riesgo |
|-------------|----------------|----------|--------|
| Desduplicar protocolo Engram (2 AGENTS.md + plugin) | ~2,500 tokens fijos | Bajo | Bajo |
| Mover Design Skills Protocol a skill bajo demanda | ~1,500 tokens fijos | Bajo | Bajo (solo afecta requests no-frontend) |
| Reducir available skills a solo triggers relevantes al proyecto | ~1,500 tokens fijos | Medio | Bajo |
| Activar MCP bajo demanda en lugar de siempre | ~5,000-10,000 tokens fijos | Alto | Medio (hay que implementar gating) |
| Mover secciones de AGENTS.md a docs versionados (leer bajo demanda) | ~5,000-8,000 tokens fijos | Medio | Bajo |
| Compactar historial multi-turn agresivamente | ~5,000-50,000+ por request largo | Bajo | Bajo |
| **Total optimizable** | **~15,000-23,000 tokens fijos** | | |
