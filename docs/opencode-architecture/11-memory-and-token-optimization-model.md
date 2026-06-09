# Memory and Token Optimization Model — Modelo de Capas

## 1. Modelo de capas de contexto

```mermaid
graph TB
    subgraph "Capa 1: System/Core (~3k tokens)"
        C1[Instrucciones base del runtime Codex<br/>NO EDITABLE por el usuario<br/>Fijo]
    end
    
    subgraph "Capa 2: Router Prompt (~4k tokens)"
        C2[Prompt del Manager reducido<br/>Solo: clasificación, routing,<br/>reglas de delegación,<br/>prohibiciones críticas<br/>SIN protocolo Engram inline<br/>SIN design skills protocol]
    end
    
    subgraph "Capa 3: Contexto Dinámico Recuperado (bajo demanda)"
        C3a[Memory Router: mem_context / mem_search]
        C3b[Document Retriever: Markdown docs]
        C3c[Available skills triggers solo]
    end
    
    subgraph "Capa 4: Memoria Persistente Engram"
        C4[Observaciones gobernadas<br/>Solo: decisiones, bugs, aprendizajes,<br/>preferencias, estado de proyecto<br/>SIN prompts completos<br/>SIN ruido exploratorio]
    end
    
    subgraph "Capa 5: Documentación Versionada"
        C5[Markdown en docs/<br/>ADRs, roadmap, test plans<br/>Fuente de verdad arquitectónica<br/>NO se inyecta automáticamente]
    end
    
    subgraph "Capa 6: Skills (Lazy-loaded)"
        C6[skill() tool<br/>Solo por trigger<br/>Carga SKILL.md completo<br/>Solo si hay match]
    end
    
    subgraph "Capa 7: MCP (Bajo Demanda)"
        C7[Tool/MCP Router<br/>Activar solo MCP necesario<br/>No cargar todos al inicio]
    end
    
    C1 --> C2
    C2 -.->|bajo demanda| C3a
    C2 -.->|bajo demanda| C3b
    C2 -.->|bajo demanda| C3c
    C3a -.->|recupera de| C4
    C3b -.->|lee| C5
    C3c -.->|carga| C6
    C2 -.->|activa| C7
```

## 2. Tabla de capas

| Capa | Qué contiene | Cuándo se carga | Cuándo no se carga | Riesgo | Regla de control |
|------|-------------|-----------------|-------------------|--------|-----------------|
| **1: System/Core** | Instrucciones base Codex | Siempre que inicia sesión | Nunca | Bajo: no editable | No tocar |
| **2: Router Prompt** | Prompt Manager reducido: clasificación, routing, prohibiciones | Cuando Manager es el agente activo | Si se usa otro agente como primary | Medio: perder funcionalidad si se reduce demasiado | No incluir protocolos extensos. Solo reglas de routing y prohibiciones |
| **3: Contexto Dinámico** | Memoria recuperada, docs, skills triggers, MCP activados | Bajo demanda según clasificación del request | Request Tiny sin necesidad de contexto externo | Bajo: se carga solo si es necesario | Antes de recuperar, responder: ¿Qué necesito? ¿Dónde buscar? ¿Query mínima? ¿Cuánto aceptar? |
| **4: Memoria Engram** | Observaciones gobernadas | mem_search con query específica | Request simple sin referencia a pasado | Medio: DB actualmente vacía, hay que poblarla primero | Solo guardar si cumple criterios de utilidad. No guardar prompts completos |
| **5: Documentación MD** | docs/, ADRs, DESIGN.md, roadmap | Document Retriever con intención específica | Request que no requiere contexto arquitectónico | Bajo: versionada, no se modifica sola | Leer solo secciones relevantes, no archivos completos |
| **6: Skills** | SKILL.md completo | skill() tool cuando hay trigger match | No hay match en available skills triggers | Medio: cargar skill incorrecta por trigger ambiguo | Verificar trigger antes de cargar. Cargar solo si match exacto |
| **7: MCP** | Tool schemas + ejecución | Tool/MCP Router activa solo MCP necesario | Request que solo necesita tools nativas | Alto: MCP incorrecto puede consumir tokens y tiempo | Activar solo MCP que el request claramente necesita |

## 3. Token Budget Target

| Tipo de request | Target actual | Target objetivo | Reducción |
|----------------|--------------|----------------|-----------|
| Tiny (simple) | ~18,500–22,000 | ~8,000-12,000 | ~50–60% |
| Small (1 archivo) | ~22,000–30,000 | ~15,000-20,000 | ~30–40% |
| Medium (multi-archivo) | ~35,000-60,000 | ~25,000-35,000 | ~30% |
| Large (arquitectura) | ~40,000-100,000+ | ~35,000-60,000 | ~20% |
| SDD completo | ~40,000-100,000+ | ~35,000-70,000 | ~15% |

## 4. Política de guardado de memoria

### 4.1 Formato recomendado para observaciones

```json
{
  "type": "decision | preference | project_state | technical_finding | reusable_pattern",
  "scope": "global | project | agent | skill | mcp",
  "topic_key": "architecture/opencode/optimization",
  "title": "Título corto y searchable",
  "summary": "Una línea: qué pasó, por qué, dónde",
  "evidence": "Archivo, función, línea",
  "valid_until": "2026-12-31 (opcional, para información con fecha de expiración)",
  "supersedes": "topic_key anterior (para marcar como reemplazo)",
  "sensitivity": "low | medium | high",
  "should_retrieve_when": ["términos que activarían retrieval de esta memoria"]
}
```

### 4.2 Criterios para guardar

| Criterio | ¿Guardar? | Ejemplo |
|----------|-----------|---------|
| Decisión arquitectónica | ✅ Sí | "Manager único primary" |
| Bug con root cause | ✅ Sí | "FTS5 no escapa special chars" |
| Preferencia del usuario | ✅ Sí | "Quiere respuestas cortas primero" |
| Estado de proyecto | ✅ Sí | "Arquitectura en fase documentación" |
| Patrón reusable | ✅ Sí | "Validación de IDs con regex" |
| Prompt completo del usuario | ❌ No | Ya está en sesiones/ |
| Log extenso | ❌ No | En disco o consola |
| Output de comando | ❌ No | Ejecutar de nuevo si es necesario |
| Hipótesis no validada | ❌ No | Aún no es conocimiento |
| Información sensible | ❌ No | Nunca |
| Artefacto SDD terminado | ⚠️ Sí (con capture_prompt: false) | En especificaciones cerradas |
| Resumen de sesión | ✅ Sí (mem_session_summary) | Obligatorio al cerrar |

### 4.3 Política de actualización e invalidación

| Situación | Acción |
|-----------|--------|
| Misma decisión, nuevo contexto | Usar mismo topic_key (upsert). Incluir "supersedes" si reemplaza una anterior. |
| Decisión anterior incorrecta | Guardar nueva con supersedes + explicación de por qué cambió. |
| Información con fecha de expiración | Incluir valid_until. No recuperar si expiró. |
| Preferencia del usuario que cambió | Guardar nueva preferencia con supersedes a la anterior. |
| Bug que ya no aplica | Marcar como superseded o no recuperar más. |

## 5. Política de recuperación de memoria

### 5.1 Auto-check antes de recuperar

Antes de cualquier `mem_search`, el agente debe responder mentalmente:

```
1. ¿Qué necesito saber específicamente?
2. ¿Dónde debería estar esta información?
   - ¿En Engram (memoria cross-session)?
   - ¿En documentación versionada (docs/)?
   - ¿En el código (código fuente)?
   - ¿En la configuración (config files)?
3. ¿Qué query mínima usar? (keyword + filtros)
4. ¿Cuánto contexto máximo puedo aceptar? (límite de results)
5. Si la respuesta no aporta, ¿la descartaré inmediatamente?
```

### 5.2 Prioridad de fuentes

| Necesito saber... | Fuente primaria | Fuente secundaria |
|------------------|-----------------|-------------------|
| Qué hicimos la sesión anterior | mem_context (rápido) | mem_search con fecha |
| Decisión sobre tecnología X | mem_search + mem_get_observation | ADR en docs/ |
| Cómo funciona una función | Código fuente (read) | — |
| Arquitectura del sistema | Documentación versionada (docs/) | — |
| Preferencia del usuario | mem_search scope: personal | Observaciones de sesiones previas |
| Bug conocido | mem_search type: bugfix | — |
| Último cambio en archivo | git log | mem_search con topic_key |

### 5.3 Límites de recuperación

| Situación | Límite |
|-----------|--------|
| mem_context (top-level) | Últimas 3-5 sesiones |
| mem_search sin filtro | Top 5 resultados |
| mem_search con filtro (type, scope) | Top 3 resultados |
| mem_get_observation | Completo (1 observación) |
| Lectura de documento | Solo secciones relevantes |

## 6. Estrategia de reducción de contexto fijo

| Paso | Acción | Ahorro estimado | Dependencia |
|------|--------|----------------|--------------|
| 1 | Consolidar instrucciones Engram: Markdown versionado = fuente de verdad (engram-instructions.md), plugin = mecanismo runtime, AGENTS.md = solo referencias | ~2,500 tokens | Fase E |
| 2 | Mover Design Skills Protocol a skill bajo demanda | ~1,500 tokens | Fase F |
| 3 | Reducir available skills a solo triggers relevantes del proyecto actual | ~1,500 tokens | Fase F |
| 4 | Compactar AGENTS.md (.config) removiendo secciones que viven en plugin | ~3,000 tokens | Fase E |
| 5 | Mover secciones extensas de AGENTS.md (.codex) a docs/ y cargar bajo demanda | ~5,000 tokens | Fase F |
| 6 | Activar MCP bajo demanda en lugar de schemas siempre visibles | ~5,000-10,000 tokens | Fase G |
| **Total** | | **~13,500-23,500 tokens** | |
