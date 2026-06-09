# 16 — Memory Governance Policy

> Creado en Fase B0 (2026-06-09). Define la política de gobernanza de memoria para la arquitectura OpenCode.

---

## 1. Principios de memoria

1. **La memoria es una biblioteca, no un basurero.** Solo guardar lo que será útil en futuras sesiones.
2. **No todo merece ser recordado.** El ruido degrada la calidad del retrieval semántico.
3. **Cada memoria tiene un propósito.** Si no se puede articular para qué servirá en el futuro, no guardar.
4. **Las decisiones viven en Markdown, los resúmenes viven en Engram.** Engram indexa, no reemplaza.
5. **La memoria tiene ciclo de vida.** Se crea, se usa, se actualiza, se invalida.
6. **Menos es más.** Una memoria bien escrita vale más que 20 memorias ruidosas.
7. **La memoria no es código.** No guardar código fuente, solo decisiones sobre el código.

---

## 2. Qué guardar

| Tipo | ¿Guardar? | Ejemplo |
|------|-----------|---------|
| **Decisiones arquitectónicas** | ✅ Siempre | "Manager único primary. gentle-orch como SDD Pipeline." |
| **Preferencias del usuario** | ✅ Siempre | "Usar Biome en lugar de ESLint + Prettier." |
| **Hallazgos técnicos** | ✅ Siempre | "FTS5 trata caracteres especiales como operadores." |
| **Patrones reutilizables** | ✅ Siempre | "Patrón async delegator para procesos largos." |
| **Estado de proyecto** | ✅ Siempre | "Fase B0 completada. Pendiente B-Security." |
| **Bugs corregidos** | ✅ Siempre | "Fixed N+1 query en UserList: agregar eager loading." |
| **Resúmenes de sesión** | ✅ Siempre | "Goal: auditar documentos. Discoveries: DB vacía, secretos expuestos." |
| **Configuraciones descubiertas** | ✅ Cuando son no obvias | "context7 requiere model=gpt-4o-mini para consultas rápidas." |
| **Reglas de negocio inferidas** | ✅ Cuando aplican al proyecto | "Los pedidos con monto > $10,000 requieren aprobación gerencial." |

---

## 3. Qué NO guardar

| Tipo | ¿Guardar? | Alternativa |
|------|-----------|-------------|
| **Prompts completos del usuario** | ❌ Nunca | Resumir solo si contiene una decisión explícita |
| **Logs extensos** | ❌ Nunca | Dejar en archivos de log del sistema |
| **Exploraciones irrelevantes** | ❌ Nunca | Descartar completamente |
| **Ruido conversacional** | ❌ Nunca | "Gracias", "ok", "dale" — no guardar |
| **Documentación que vive en Markdown** | ❌ Nunca | Leer de Markdown cuando se necesite. Engram solo indexa. |
| **Secretos, tokens, API keys** | ❌ NUNCA | Variables de entorno (.env). Si se detectan, reportar. |
| **Outputs extensos de subagentes** | ❌ Nunca | Solo guardar decisiones que el subagente haya generado |
| **Código fuente** | ❌ Nunca | El código está en el repositorio, no en la memoria |
| **Errores transitorios** | ❌ No | Solo si revelan un patrón o bug recurrente |
| **Resultados de compilación/tests** | ❌ No | Solo si revelan un problema de arquitectura |
| **Discusiones sin conclusión** | ❌ No | No guardar hasta que haya una decisión |
| **Múltiples versiones de lo mismo** | ❌ No | Actualizar la existente con topic_key |

---

## 4. Dónde guardar

### Matriz de destino

| Información | Destino primario | Destino secundario |
|-------------|-----------------|-------------------|
| Decisión arquitectónica global | ADR (docs/adr/) | Engram global (resumen) |
| Decisión arquitectónica del proyecto | ADR (docs/adr/) | Engram project (resumen) |
| Preferencia del usuario | Engram personal | — |
| Hallazgo técnico del proyecto | Engram project | Evidence register (docs/) |
| Patrón reusable | Engram global | Skill (si es repetitivo) |
| Estado de proyecto | Engram project | docs/ (si es significativo) |
| Bug fix | Engram project | — |
| Resumen de sesión | Engram project | — |
| Regla de negocio | Engram project | docs/ (si es permanente) |
| Configuración descubierta | Engram project | .opencode/ (si es permanente) |

### Reglas de destino

- Si la información **cambia con frecuencia** → Engram
- Si la información **es permanente y no cambia** → Markdown docs
- Si la información **es una decisión formal** → ADR + resumen en Engram
- Si la información **es personal del usuario** → Engram personal (scope: personal)

---

## 5. Cómo buscar memoria

### Política de búsqueda (obligatoria antes de mem_search)

1. **¿La respuesta requiere contexto previo?**
   - Sí → continuar
   - No → responder sin buscar

2. **¿Ese contexto debería estar en memoria persistente, documentos, ADRs, skill registry o inventory?**
   - Decisiones rápidas → Engram
   - Documentación formal → Markdown docs
   - Skills disponibles → Skill registry
   - Catálogo técnico → Inventory

3. **¿Cuál es la query mínima?**
   - Máximo 5-10 palabras
   - Enfocada en el concepto, no en la pregunta completa

4. **¿Cuántos resultados máximo se aceptan?**
   - Default: 3
   - Máximo: 5 (más que eso es ruido)

5. **¿Qué evidencia necesito?**
   - Especificar si necesito archivos, líneas, decisiones, o contexto general

6. **¿Qué debo descartar como ruido?**
   - Memorias con status: deprecated
   - Memorias con valid_until vencido
   - Memorias no relacionadas semánticamente

### Orden de búsqueda

```
1. Engram mem_context (contexto de sesiones recientes — rápido, barato)
2. Engram mem_search (búsqueda semántica — si mem_context no alcanza)
3. Markdown docs/ (si la información es documentación formal)
4. ADRs (si es una decisión arquitectónica)
5. Skill registry (si necesito saber qué skills existen)
6. Inventory (si necesito un catálogo técnico)
```

---

## 6. Cómo guardar memoria

### Política de guardado (obligatoria antes de mem_save)

1. **¿Esto será útil en futuras sesiones?**
   - Sí → continuar
   - No → NO guardar

2. **¿Es una decisión, preferencia, hallazgo, patrón o estado de proyecto?**
   - Decisión → guardar con type: decision
   - Preferencia → guardar con type: preference
   - Hallazgo → guardar con type: discovery
   - Patrón → guardar con type: pattern
   - Estado → guardar con type: manual (session summary)

3. **¿Ya existe una memoria parecida?**
   - Hacer mem_search primero con palabras clave
   - Si existe → actualizar con topic_key (no crear duplicado)

4. **¿Debo actualizar una memoria existente en vez de crear otra?**
   - Sí, si es el mismo tema → usar topic_key
   - No, si es un tema diferente → crear nueva

5. **¿Contradice algo anterior?**
   - Sí → incluir `supersedes` con el ID de la memoria anterior
   - La memoria anterior quedará como deprecated automáticamente

6. **¿Debe tener fecha de expiración?**
   - Sí, si es temporal (ej: "estamos probando X library")
   - No, si es permanente (ej: "Manager es único primary")

7. **¿Es sensible?**
   - Sí → NO guardar en Engram. Guardar en Markdown con acceso restringido.
   - No → guardar normalmente

8. **¿Pertenece a Engram o a Markdown?**
   - Ver matriz de destino (sección 4)

9. **¿Se puede resumir en menos de 150 palabras?**
   - Sí → guardar
   - No → resumir más. Si no se puede resumir, probablemente es documentación, no memoria.

10. **¿Qué trigger futuro debería recuperarla?**
    - Definir 2-5 palabras clave que un futuro Manager usaría

---

## 7. Formato de memoria (Engram)

### Formato estándar para mem_save

```json
{
  "memory_type": "decision | preference | project_state | technical_finding | reusable_pattern | architecture_rule",
  "scope": "global | opencode | project | agent | skill | mcp",
  "topic_key": "tema/estable",
  "title": "Título corto y searchable",
  "summary": "Máximo 150 palabras",
  "evidence": ["ruta/al/archivo.md"],
  "retrieval_triggers": ["trigger1", "trigger2"],
  "supersedes": [],
  "valid_until": null,
  "sensitivity": "low | medium | high",
  "status": "proposed | approved | deprecated"
}
```

### Equivalente en texto plano (cuando no se puede usar JSON)

```markdown
**memory_type**: decision
**title**: Manager as unique primary orchestrator
**summary**: Manager debe ser el único agente primary. Gentle-orchestrator no debe competir como primary.
**evidence**: docs/opencode-architecture/adr/ADR-001-...
**triggers**: Manager, gentle-orchestrator, primary, SDD pipeline
**supersedes**: []
**status**: approved
```

### Reglas del formato

- **title**: Máximo 80 caracteres. Debe ser searchable.
- **summary**: Máximo 150 palabras. Si no se puede resumir en 150, probablemente no es una buena memoria.
- **evidence**: Siempre referenciar archivos concretos. Si no hay evidencia documental, no guardar como type: decision.
- **retrieval_triggers**: Palabras clave que un futuro Manager usaría para encontrar esta memoria.
- **supersedes**: IDs de memorias que esta reemplaza. La memoria anterior se marca como deprecated.
- **valid_until**: Fecha ISO 8601. null = no expira.
- **sensitivity**: low = seguro para cualquier contexto. medium = preguntar antes de compartir. high = no guardar.
- **status**: proposed = no aprobado. approved = decisión final. deprecated = reemplazada o inválida.

---

## 8. Ciclo de vida de la memoria

```
CREACIÓN
  └── ¿Es guardable? (política de guardado)
        ├── No → Descartar
        └── Sí → ¿Ya existe?
              ├── Sí → Actualizar con topic_key
              └── No → Crear nueva con triggers

RECUPERACIÓN
  └── ¿Coincide trigger? (mem_search)
        ├── Sí → ¿Sigue siendo válida?
        │     ├── Sí → Usar
        │     └── No → Invalidar (valid_until, supersedes)
        └── No → Búsqueda semántica más amplia

ACTUALIZACIÓN
  └── ¿Cambió la decisión?
        ├── Totalmente → Crear nueva con supersedes a la anterior
        └── Parcialmente → Actualizar existente (topic_key)

INVALIDACIÓN
  └── ¿Expirada? (valid_until)
        ├── Sí → Marcar deprecated automáticamente
        └── No → ¿Reemplazada? (supersedes)
              ├── Sí → Marcar deprecated
              └── No → ¿Ya no aplica? → Marcar deprecated manualmente
```

---

## 9. Cómo evitar duplicados

1. **Siempre buscar antes de guardar**: mem_search con topic_key potencial.
2. **Usar topic_key**: mismo topic_key = misma memoria (upsert automático).
3. **Si no estás seguro del topic_key**: usar `mem_suggest_topic_key` antes de guardar.
4. **Si encuentras un duplicado**: actualizar el existente, no crear otro.
5. **Si dos memorias se contradicen**: mem_compare con verdict y marcar una como supersedes.

---

## 10. Cómo controlar sensibilidad

| Nivel | ¿Qué significa? | ¿Qué hacer? |
|-------|----------------|-------------|
| **low** | Información pública del proyecto | Guardar normalmente |
| **medium** | Podría ser sensible en otro contexto | Preguntar al usuario antes de compartir. No incluir en búsquedas automáticas. |
| **high** | Credenciales, datos personales, secretos | NO guardar en Engram. Usar .env o gestor de secretos. Si se detecta, reportar inmediatamente. |

---

## 11. Cómo relacionar memoria con ADRs

| Situación | Relación |
|-----------|----------|
| ADR aprobado | Crear memoria en Engram con type: decision y evidence apuntando al ADR |
| ADR actualizado | Actualizar memoria existente con topic_key |
| ADR deprecated | Marcar memoria como deprecated |
| Decisión sin ADR | Memoria type: decision pero sin ADR (decisión rápida en docs/decisions/) |

### Formato

```markdown
**title**: ADR-001: Manager as unique primary
**type**: decision
**evidence**: docs/opencode-architecture/adr/ADR-001-primary-orchestrator-strategy.md
**summary**: Manager debe ser el único primary. gentle-orch es SDD Pipeline.
**status**: approved
```

---

## 12. Cómo relacionar memoria con docs versionados

| Situación | Relación |
|-----------|----------|
| Documento de arquitectura creado | Guardar referencia en Engram (evidence: ruta) |
| Documento actualizado | Actualizar referencia en Engram (no guardar el contenido completo) |
| Documento eliminado | Marcar memoria relacionada como deprecated |

**Regla**: Engram NO almacena contenido de documentos. Almacena referencias y resúmenes. El contenido completo vive en Markdown versionado.

---

## 13. Cómo medir calidad de recuperación

### Métricas

| Métrica | Qué mide | Cómo se calcula | Objetivo |
|---------|----------|-----------------|----------|
| **Precision@3** | De los primeros 3 resultados, cuántos son relevantes | Relevantes / 3 | > 80% |
| **Recall** | De las memorias relevantes existentes, cuántas se recuperaron | Recuperadas relevantes / Total relevantes | > 70% |
| **Signal/Noise ratio** | Ratio de memorias útiles vs ruido recuperado | Útiles / (Útiles + Ruido) | > 60% |
| **Time-to-first-result** | Velocidad de retrieval | Tiempo hasta primer resultado | < 1s |

---

## 14. Resumen ejecutivo para el Manager (formato comprimido)

```
MEMORY GOVERNANCE — QUICK REFERENCE

GUARDAR: decisiones, preferencias, hallazgos, patrones, estado, bugs, session summaries
NO GUARDAR: prompts, logs, ruido, docs (referencias sí), secretos, código, errores transitorios

BUSCAR:
  1. mem_context (sesiones recientes)
  2. mem_search (semántica)
  3. Markdown docs
  4. ADRs
  5. Skill registry
  6. Inventory

FORMATO: {type, scope, topic_key, title, summary≤150w, evidence, triggers, supersedes, valid_until, sensitivity, status}
CICLO: crear → usar → actualizar → invalidar
DUPLICADOS: buscar antes de guardar, usar topic_key
SENSIBILIDAD: low=ok, medium=preguntar, high=no guardar
```

---

## ADRs relacionados

- ADR-004 (Engram role), ADR-002 (Manager role), ADR-006 (token budget).
