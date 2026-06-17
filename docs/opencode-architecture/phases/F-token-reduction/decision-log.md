# Decision Log — Fase F

**Propósito:** Registrar todas las decisiones tomadas durante la planificación e implementación de Fase F, con fundamento y alternativas consideradas.

---
## Decisiones de F2 (2026-06-16)

---

## D-F-001: 9.5k no es límite rígido

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | 9.5k es el objetivo operativo del modo Normal, no un límite rígido. El rango aceptable es 8.5k–12k. |
| **Contexto** | El usuario especificó explícitamente "No trates 9.5k como límite rígido universal." |
| **Alternativas** | Usar 9.5k como límite duro → rechazado porque forzaría truncamiento en tareas que naturalmente requieren más contexto. |
| **Fundamento** | La calidad del resultado es más importante que alcanzar un número exacto. El rango permite flexibilidad sin perder el objetivo de reducción. |
| **Impacto** | Budgets definidos como rangos, no como valores fijos. Modo Normal = 8.5k–12k. |

---

## D-F-002: Modo Normal como default

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El modo Normal (8.5k–12k) es el default del sistema. |
| **Contexto** | La mayoría de las tareas son de diseño, implementación o revisión estándar. El modo Simple es para excepciones (consultas rápidas). |
| **Alternativas** | Modo Simple como default → rechazado porque la mayoría de las tareas no son triviales. |
| **Fundamento** | El modo Normal cubre el 80% de los casos de uso sin necesidad de expansión. |
| **Impacto** | Budget por defecto: ~9.5k tokens. Expansión automática hasta 14k sin justificación. |

---

## D-F-003: Fallback dinámico permitido

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Se permite fallback dinámico: si el contexto es insuficiente, el sistema puede expandirse controladamente. |
| **Contexto** | No se debe forzar una respuesta con contexto insuficiente. |
| **Alternativas** | Fallback estático (siempre mismo tamaño) → rechazado porque no se adapta a la complejidad de la tarea. |
| **Fundamento** | Es mejor gastar más tokens en una respuesta correcta que ahorrar tokens en una respuesta incorrecta. |
| **Impacto** | Expansiones controladas con justificación mínima para >14k. Sin límite superior para >22k con justificación explícita. |

---

## D-F-004: No compresión agresiva inicial

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | La primera implementación no usará compresión agresiva (summarization, truncation). Se enfocará en mejor selección de contexto. |
| **Contexto** | El usuario especificó: "No quiero una compresión única y agresiva. Quiero una arquitectura donde el contexto se seleccione mejor." |
| **Alternativas** | Compresión tipo prompt compression → rechazado porque puede perder matices semánticos. |
| **Fundamento** | Seleccionar mejor el contexto existente es más seguro que comprimirlo agresivamente. La compresión se evaluará en Fase F+ si es necesaria. |
| **Impacto** | Foco en selector de memorias, context packs, y budgets en lugar de summarization agresiva. |

---

## D-F-005: Primero token audit

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Antes de cualquier cambio, se debe ejecutar F0 (Token Audit Baseline) para medir el consumo real. |
| **Contexto** | El baseline de ~40k es una estimación, no una medición. |
| **Alternativas** | Implementar cambios directamente y medir después → rechazado porque no sabríamos si realmente redujimos algo. |
| **Fundamento** | No se puede optimizar lo que no se mide. |
| **Impacto** | F0 es el primer paso obligatorio. Sin baseline, no hay implementación. |

---

## D-F-006: E6B y Suite F como gates obligatorios

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | E6B (Noise Gate) y Suite F (mem_context read-only) son gates obligatorios antes y después de cualquier cambio. |
| **Contexto** | Estas suites validan funcionalidad crítica del sistema. |
| **Alternativas** | Confiar en tests manuales post-cambio → rechazado porque es propenso a errores. |
| **Fundamento** | Si la reducción de tokens rompe la captura de prompts o la recuperación de contexto, el sistema deja de funcionar correctamente. |
| **Impacto** | Regression plan incluye E6B y Suite F como gates CI. No se puede promover sin PASS. |

---

## D-F-007: Sesión canonical exclusiva para Fase F

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Toda la implementación y validación de Fase F se hará en sesión canonical `opencode-architecture`. |
| **Contexto** | Demostrado en E6B que sesiones legacy causan `session_project_mismatch`. |
| **Alternativas** | Usar sesión actual (legacy) y migrar → rechazado por restricciones de no DB migration. |
| **Fundamento** | La sesión canonical garantiza que no hay falsos bloqueos por mismatch. |
| **Impacto** | Toda medición, test y validación debe hacerse desde sesión canonical. La sesión legacy solo se usa para referencia histórica. |

---

## D-F-008: Packs como estructura de contexto, no como archivos

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Los context packs son estructuras lógicas de contexto, no archivos físicos en disco. Se ensamblan en memoria según el modo. |
| **Contexto** | Crear archivos físicos por pack sería frágil y difícil de mantener. |
| **Alternativas** | Archivos markdown por pack → rechazado porque añade complejidad de sincronización. |
| **Fundamento** | Los packs son un concepto de organización del prompt, no de almacenamiento. La fuente de datos sigue siendo Engram + configuración. |
| **Impacto** | Los packs se documentan como diseños, no como implementaciones. La implementación concreta será en el pipeline de contexto. |

---

## D-F-009: Manager Protocol como KEEP_FIXED compactable (F1)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El Manager Protocol (28,471 chars) debe permanecer fijo en contexto base, pero compactado. Es la fuente más grande (20-28% del total). |
| **Contexto** | F1 determinó que el Manager Protocol es la fuente individual más grande. No puede moverse a bajo demanda porque contiene las reglas de orquestación. |
| **Alternativas** | Mover partes a retrieval → rechazado porque el Manager necesita las reglas de orquestación siempre disponibles. |
| **Fundamento** | Las secciones compactables son: Context Layer Definitions (referencias vs inline), Anti-Patterns, Fast-Track, Default Behavior. |
| **Impacto** | Manager Protocol post-compactación estimado: ~5,000–8,000 tokens (ahorro ~2k–6k). La compactación se hará en F2. |

---

## D-F-010: Session history como quick win #1 (F1)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El session history es el quick win más impactante (~3k–5k tokens de ahorro) y debe priorizarse. |
| **Contexto** | F1 analizó 5 quick wins. Session history compactado tiene el mayor ahorro individual. |
| **Alternativas** | Tool schemas bajo demanda (~2k–4k) → ahorro similar pero mayor complejidad. |
| **Fundamento** | Session history no requiere cambios en runtime ni plugin. Solo mejorar la gestión del historial de conversación. Mantener últimos 3 turns crudos + resumen estructurado. |
| **Impacto** | Se diseñará en F2, se implementará en F3 junto con el selector de memorias. |

---

## D-F-011: Design Skills Protocol a RETRIEVE_ON_DEMAND (F1)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | La sección Design Skills Integration Protocol de AGENTS.md (~4,500 chars, ~1,125 tokens) debe moverse a carga bajo demanda. |
| **Contexto** | F1 clasificó AGENTS.md en 3 sub-secciones. Design Skills solo es necesario para tareas frontend, que son minoría. |
| **Alternativas** | Mantenerlo fijo → rechazado porque son ~1,125 tokens que se cargan siempre pero se usan <20% del tiempo. |
| **Fundamento** | El Manager puede cargar este protocolo vía skill tool cuando la tarea involucra frontend. No necesita estar en el contexto base. |
| **Impacto** | Ahorro: ~1,125 tokens. Requiere modificar cómo se carga AGENTS.md (extraer la sección Design Skills a un skill invocable). |

---

## D-F-012: Tool schemas requieren investigación de runtime (F1)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Tool schemas bajo demanda es prioritario (~2k–4k ahorro) pero requiere verificar si OpenCode runtime soporta tool loading dinámico. |
| **Contexto** | F1 determinó que 16 tools se cargan siempre pero solo 3-5 se usan por turno. |
| **Alternativas** | Cargar todas (actual) → sobrecarga. Cargar solo core 6 + fase actual → requiere soporte runtime. |
| **Fundamento** | La viabilidad depende del runtime. Si OpenCode no soporta tool loading selectivo, este quick win debe postergarse. |
| **Impacto** | Se investigará en F2. Si no es viable, se descarta o se implementa a nivel de plugin. |

---

## D-F-013: Session summaries requieren dedup en retrieval, no eliminación (F1)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Las 119 session summaries (36% de observations) no deben eliminarse. La solución es deduplicación semántica en retrieval (F3). |
| **Contexto** | F1 detectó que el estado del proyecto se repite en README + session summaries + architecture memories. |
| **Alternativas** | Eliminar summaries antiguos → rechazado porque se pierde trazabilidad histórica. |
| **Fundamento** | En retrieval (mem_context), si 3 memorias dicen "E6B COMPLETE", solo incluir la de score más alto. El resto queda en DB para referencia histórica. |
| **Impacto** | Feature de F3 (mem_context Selector). Se implementará ranking + top-k + dedup semántico. |

---

## D-F-014: Context Packs expandidos con TOOLING, SKILLS y GENTLE_AI

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Agregar 3 nuevos context packs: TOOLING_PACK (tool schemas por fase), SKILLS_PACK (índice compacto de skills), GENTLE_AI_ALIGNMENT_PACK (alineación estratégica). |
| **Contexto** | F1 identificó que tool schemas (QW#2) y skills (QW#5) son fuentes optimizables. gentle-ai tiene referencias en 6 documentos. |
| **Alternativas** | Mantener solo los 8 packs originales → rechazado porque tool schemas y skills necesitan un diseño explícito de carga bajo demanda. |
| **Fundamento** | Cada nuevo pack resuelve un quick win específico. TOOLING_PACK → QW#2, SKILLS_PACK → QW#5, GENTLE_AI → alineación estratégica. |
| **Impacto** | 11 packs totales. Ensamblaje por modo actualizado con los 3 nuevos. |

---

## D-F-015: Tool schemas bajo demanda por fase SDD (no por runtime)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El modelo de carga de tool schemas será por decisión del Manager según la fase SDD (Opción C), no por plugin interceptor ni por runtime dinámico. |
| **Contexto** | La auditoría de tool schemas determinó que la Opción A (runtime dinámico) no está verificada, y la Opción B (plugin) tiene alto riesgo. |
| **Alternativas** | Opción A (runtime) → no verificada. Opción B (plugin) → alto riesgo. Opción C (Manager) → riesgo medio, lazy load como fallback. |
| **Fundamento** | El Manager conoce la fase SDD y el tipo de tarea, por lo que puede determinar qué tools necesita. Lazy load como fallback si la clasificación falla. |
| **Impacto** | Herramientas core (6) siempre cargadas. El resto según fase SDD. Lazy load si se necesita una tool no cargada. Pendiente aprobación para implementar en F3. |

---

## D-F-016: Session history compactado con 3+7+acumulativo

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El session history se compacta en 3 segmentos: últimos 3 turns crudos, turns 4–10 resumidos (1–2 líneas cada uno), turns 11+ resumen acumulativo (template estructurado). |
| **Contexto** | Session history es el quick win más impactante (~3k–5k tokens de ahorro). |
| **Alternativas** | Últimos 5 turns crudos → más tokens pero más precisión. Últimos 1 turn crudo → menos tokens pero riesgo de pérdida de continuidad. Todo resumido → máximo ahorro pero alto riesgo. |
| **Fundamento** | 3 turns crudos garantizan precisión inmediata para el contexto inmediato. Resumen estructurado (no generación libre) evita alucinaciones. |
| **Impacto** | Formato RECENT_SESSION_PACK definido. Se implementará en F3. |

---

## D-F-017: Manager Protocol compactado sin tocar secciones core

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Compactar solo 4 secciones del Manager Protocol: Context Layer Definitions (referencias vs inline), Anti-Patterns, Fast-Track Exceptions, Default Behavior. NO tocar las secciones core (Global Rule, Operating Model, SDD phases, fases 0-8). |
| **Contexto** | El Manager Protocol es la fuente más grande (~7k–14k tokens). Las secciones core son críticas para la orquestación. |
| **Alternativas** | Compactación más agresiva → mayor ahorro pero mayor riesgo de perder instrucciones críticas. No compactar → no hay ahorro en la fuente más grande. |
| **Fundamento** | Las 4 secciones identificadas son las que tienen contenido redundante o ejemplos extensos. Las secciones core no se tocan por seguridad. |
| **Impacto** | Ahorro estimado: ~1,200–2,300 tokens. **⚠️ Pendiente aprobación del usuario** — modificar opencode.json tiene riesgo alto. |

---

## D-F-018: Skills block con descripciones de 5–10 palabras

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El bloque `<available_skills>` usará descripciones de 5–10 trigger keywords en lugar de descripciones de 1–2 líneas. |
| **Contexto** | Las descripciones actuales (~1,040 tokens) son genéricas y no ayudan al matching del Manager. |
| **Alternativas** | Mantener descripciones actuales → ~1,040 tokens fijos. Eliminar descripciones → Manager perdería capacidad de matching. |
| **Fundamento** | El Manager puede invocar skills por nombre sin depender del bloque. Las trigger keywords son suficientes para identificar qué skill cargar. |
| **Impacto** | Ahorro: ~400–600 tokens. Se implementará en F3 editando el system prompt. |

---

## D-F-019: gentle-ai en alineación estratégica, no integración

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | gentle-ai se considera en alineación estratégica, no en integración técnica. NO crear dependencia funcional entre OpenCode y gentle-ai sin aprobación explícita. |
| **Contexto** | gentle-ai referenciado en 6 documentos del proyecto. No está en workspace local. Doc #17 (plan de transición) existe pero no está activo. |
| **Alternativas** | Integrar gentle-ai en Fase F → rechazado porque no hay autorización y gentle-ai no está en el workspace. Ignorar gentle-ai completamente → rechazado porque las referencias existen y deben auditarse. |
| **Fundamento** | La auditoría es informativa, no vinculante. Las decisiones de Fase F no deben crear dependencias. El patrón de reducción se diseñó para ser reusable. |
| **Impacto** | GENTLE_AI_ALIGNMENT_PACK diseñado. Política de alineación de 6 puntos. Sin cambios en gentle-ai. |

---

## D-F-020: F2 es diseño + auditoría, no implementación

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | F2 produce contratos, diseños y auditorías. No implementa cambios funcionales. La implementación se delega a F3–F6. |
| **Contexto** | El contrato inicial de Fase F establece que F0–F2 son diagnóstico y diseño. F3+ es implementación. |
| **Alternativas** | Implementar quick wins en F2 → rechazado porque los cambios en runtime (tool schemas, session history) requieren más validación. |
| **Fundamento** | Es más seguro diseñar primero y validar el diseño antes de implementar. Los 14 documentos de F2 son la especificación para F3–F6. |
| **Impacto** | Todos los cambios funcionales se implementarán en F3–F6 con feature flags y regression gates. |

---

## D-F-021: Regression plan extendido con gates F2

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Agregar 3 nuevos gates al regression plan: F2 Quick Wins Verification (QW2-T1 a QW2-T6), F2 Contract Compliance (C-T1 a C-T6), Full Artifact Audit (A-T1 a A-T15). |
| **Contexto** | F2 produce 6 nuevos documentos y actualiza 6 existentes. Es necesario verificar que todos sean consistentes antes de pasar a F3. |
| **Alternativas** | Confiar en revisión manual → más rápido pero menos riguroso. |
| **Fundamento** | 14 documentos de F2 deben ser consistentes entre sí y con F0/F1. Los gates automatizan la verificación. |
| **Impacto** | Regression plan pasa de 6 a 9 gates (52 tests total). |

---

## D-F-022: TOOLING_PACK como context pack separado

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El TOOLING_PACK es un context pack separado, no parte de L2 o L5. Tiene su propio presupuesto (800–1,200 tokens core, 1,500–2,500 expandido). |
| **Contexto** | F1 clasificó tool schemas como RETRIEVE_ON_DEMAND. La auditoría detalló 3 opciones de carga. |
| **Alternativas** | Tool schemas como parte de L2 (siempre presente) → no ahorra tokens. Tool schemas como parte de L5 (solo bajo demanda) → riesgo de no tener tools críticas. |
| **Fundamento** | Como pack separado, TOOLING_PACK puede ensamblarse según la fase SDD. En modo Normal incluye core 6; en Auditoría incluye todas. |
| **Impacto** | 11 packs totales. TOOLING_PACK activo desde modo Normal. |

---

## Resumen de decisiones

| # | Decisión | Fecha | Estado |
|:-:|----------|:-----:|:------:|
| D-F-001 | 9.5k no es límite rígido, es rango 8.5k–12k | 2026-06-16 | ✅ Aprobada |
| D-F-002 | Modo Normal como default | 2026-06-16 | ✅ Aprobada |
| D-F-003 | Fallback dinámico permitido | 2026-06-16 | ✅ Aprobada |
| D-F-004 | No compresión agresiva inicial | 2026-06-16 | ✅ Aprobada |
| D-F-005 | Primero token audit (F0) | 2026-06-16 | ✅ Aprobada |
| D-F-006 | E6B + Suite F como gates | 2026-06-16 | ✅ Aprobada |
| D-F-007 | Sesión canonical exclusiva | 2026-06-16 | ✅ Aprobada |
| D-F-008 | Packs como estructuras lógicas | 2026-06-16 | ✅ Aprobada |
| D-F-009 | Manager Protocol como KEEP_FIXED compactable | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-010 | Session history como quick win #1 | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-011 | Design Skills Protocol a RETRIEVE_ON_DEMAND | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-012 | Tool schemas requieren investigación runtime | 2026-06-16 | 🔶 Resuelta (F2) — Opción C |
| D-F-013 | Session summaries: dedup en retrieval, no eliminar | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-014 | Context Packs expandidos con 3 nuevos packs | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-015 | Tool schemas bajo demanda por fase SDD (Opción C) | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-016 | Session history compactado 3+7+acumulativo | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-017 | Manager Protocol compactado sin tocar core | 2026-06-16 | 🔶 Pendiente aprobación usuario |
| D-F-018 | Skills block con descripciones 5–10 palabras | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-019 | gentle-ai en alineación estratégica, no integración | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-020 | F2 es diseño + auditoría, no implementación | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-021 | Regression plan extendido con gates F2 | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-022 | TOOLING_PACK como context pack separado | 2026-06-16 | ✅ Aprobada (F2) |

## Decisiones de F2 Critical Review (2026-06-16)

---

## D-F-023: QW#3 (Manager Protocol compaction) baja prioridad

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | QW#3 (Manager Protocol compactado) pasa de "quick win" a "nice to have" de baja prioridad. No implementar sin aprobación explícita del usuario. |
| **Contexto** | La revisión crítica de F2 encontró que el ahorro estimado (~1,200–2,300 tokens) es modesto comparado con el riesgo de modificar opencode.json. El mismo ahorro se puede recuperar combinando QW#1 + QW#4 + QW#5 (~4k–7.6k tokens). |
| **Alternativas** | Implementar QW#3 igual → rechazado porque abre opencode.json a cambios no autorizados. |
| **Fundamento** | ROI bajo. Por cada token ahorrado, se asume riesgo alto. Mejor priorizar quick wins seguros y de mayor impacto. |
| **Impacto** | QW#3 queda como plan de contingencia. Budgets deben incluir escenario "sin compactación de Manager Protocol". |

---

## D-F-024: Escenario "sin compactación" añadido a budgets

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Añadir escenario "sin compactación de Manager Protocol" a los budgets. Modo Normal sin compactación: objetivo 10k–14k en lugar de 8.5k–12k. |
| **Contexto** | Los budgets de F2 asumían la compactación del Manager Protocol (~7k–14k → ~5k–8k). Sin ella, el modo Normal salta a ~10k–15k. Como QW#3 no se implementa sin aprobación, los budgets deben reflejar la realidad. |
| **Alternativas** | Forzar la compactación → rechazado porque requiere aprobación del usuario. Ignorar el escenario → rechazado porque da falsa seguridad. |
| **Fundamento** | Transparencia. Si el usuario no aprueba QW#3, los budgets deben ser realistas. |
| **Impacto** | Budget contract actualizado con columna "Sin compactación". |

---

## D-F-025: Verificar runtime API antes de F3

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Antes de iniciar F3, verificar si OpenCode runtime expone API para cargar tool schemas selectivamente (QW#2). Si no existe, QW#2 queda descartado. |
| **Contexto** | La revisión crítica encontró que ninguna de las 3 opciones de tool loading fue verificada contra el runtime real. La Opción C (Manager decide) requiere lógica de clasificación que no existe. |
| **Alternativas** | Asumir que la API existe → rechazado por riesgo alto de bloqueo en F3. No verificar → rechazado por falsa seguridad. |
| **Fundamento** | Sin verificación empírica, QW#2 puede ser una inversión perdida. |
| **Impacto** | F3 bloqueado hasta verificar. QW#2 condicional a resultado. |

---

## D-F-026: Regla R7 para decisiones explícitas en session compaction

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Añadir regla R7 al session history compaction: "Si un turno contiene una decisión explícita (marcadores: 'decido', 'no hagas', 'es mejor que', 'prefiero'), esa decisión debe preservarse textualmente en el resumen, no resumirse." |
| **Contexto** | La revisión crítica encontró que el resumen estructurado puede omitir condiciones de decisiones críticas. Por ejemplo, "No hagas X, haz Y con la condición Z" resumido como "Turno 6: User pidió Y" pierde "con la condición Z". |
| **Alternativas** | No añadir R7 → rechazado porque decisions con condiciones son comunes y críticas. Mantener más turns crudos → rechazado porque reduce el ahorro. |
| **Fundamento** | Preservar decisiones textualmente es más barato que mantener turns extra. Costo marginal: ~50–150 tokens por decisión preservada. |
| **Impacto** | Session history compaction spec actualizada con R7. Ahorro neto se reduce ligeramente. |

---

## D-F-027: Ahorro neto de session compaction documentado

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Documentar el ahorro neto de session history compaction como (ahorro bruto - costo de compactar). Costo estimado: ~200–500 tokens por actualización. En sesión de 20 turns con 4 compactaciones: ~800–2,000 tokens gastados. Ahorro neto: ~1k–4.2k. |
| **Contexto** | La auditoría de F2 no consideró que el Manager consume tokens al generar y mantener los resúmenes estructurados. |
| **Alternativas** | Ignorar el costo → rechazado porque sobreestima el beneficio. Usar template sin generación → el template mismo requiere que alguien lo llene. |
| **Fundamento** | El ahorro neto sigue siendo positivo (~1k–4.2k), lo que justifica la implementación. Pero el equipo debe saber el número real. |
| **Impacto** | Budget contract y spec de session compaction actualizados con ahorro neto. |

---

## D-F-028: Tests de calidad usan búsqueda semántica, no IDs fijos

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Los tests de calidad del regression plan (Q-T1 a Q-T5) deben usar búsqueda semántica en Engram en lugar de IDs fijos (#404, #427) para localizar observaciones de prueba. |
| **Contexto** | Los IDs de Engram pueden cambiar si la base se purga o reindexa, causando falsos negativos en los tests. |
| **Alternativas** | Usar snapshots de observaciones en archivos estáticos → también válido. Mantener IDs fijos + documentar que requieren mantenimiento → aceptable pero frágil. |
| **Fundamento** | Búsqueda semántica es más robusta a cambios de infraestructura. |
| **Impacto** | Regression plan actualizado. Tests de calidad más mantenibles. |

---

## D-F-029: F2 apto para F3

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | F2 es APTO PARA F3. 1 mejora requerida (escenario sin compactación), 1 condición (verificar runtime API), 3 mejoras recomendadas (R7, ahorro neto, ROI QW#3). |
| **Contexto** | La revisión crítica de F2 produjo 8 hallazgos (H1-H8) con 1 alta prioridad, 4 media, 3 baja. Ninguno es blocker absoluto. |
| **Alternativas** | Bloquear F3 hasta resolver todos los hallazgos → rechazado porque 1 alta y 4 medias son gestionables en paralelo. |
| **Fundamento** | F2 es diseño + auditoría, no implementación. Los hallazgos se resuelven en F3. F2 cumplió su objetivo. |
| **Impacto** | F3 puede comenzar. Implementation roadmap marcado F2 CRITICAL REVIEW COMPLETED. |

---

## D-F-030: F2 Critical Review como entrada de F3

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | F2-critical-review.md es la entrada oficial de F3. Los hallazgos H1-H8 guían las decisiones de F3. |
| **Contexto** | Sin esta decisión, F3 podría ignorar los hallazgos de la revisión crítica. |
| **Alternativas** | Usar los documentos de F2 directamente como entrada → riesgo de repetir errores identificados en la review. |
| **Fundamento** | La revisión crítica identificó gaps que F3 debe resolver. Usarla como entrada garantiza continuidad. |
| **Impacto** | F3 roadmap prioriza resolver los hallazgos de F2. |

---

| # | Decisión | Fecha | Estado |
|---|----------|:-----:|:------:|
| D-F-001 | 9.5k no es límite rígido, es rango 8.5k–12k | 2026-06-16 | ✅ Aprobada |
| D-F-002 | Modo Normal como default | 2026-06-16 | ✅ Aprobada |
| D-F-003 | Fallback dinámico permitido | 2026-06-16 | ✅ Aprobada |
| D-F-004 | No compresión agresiva inicial | 2026-06-16 | ✅ Aprobada |
| D-F-005 | Primero token audit (F0) | 2026-06-16 | ✅ Aprobada |
| D-F-006 | E6B + Suite F como gates | 2026-06-16 | ✅ Aprobada |
| D-F-007 | Sesión canonical exclusiva | 2026-06-16 | ✅ Aprobada |
| D-F-008 | Packs como estructuras lógicas | 2026-06-16 | ✅ Aprobada |
| D-F-009 | Manager Protocol como KEEP_FIXED compactable | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-010 | Session history como quick win #1 | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-011 | Design Skills Protocol a RETRIEVE_ON_DEMAND | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-012 | Tool schemas requieren investigación runtime | 2026-06-16 | 🔶 Resuelta (F2) — Opción C |
| D-F-013 | Session summaries: dedup en retrieval, no eliminar | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-014 | Context Packs expandidos con 3 nuevos packs | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-015 | Tool schemas bajo demanda por fase SDD (Opción C) | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-016 | Session history compactado 3+7+acumulativo | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-017 | Manager Protocol compactado sin tocar core | 2026-06-16 | 🔶 Pendiente aprobación usuario |
| D-F-018 | Skills block con descripciones 5–10 palabras | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-019 | gentle-ai en alineación estratégica, no integración | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-020 | F2 es diseño + auditoría, no implementación | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-021 | Regression plan extendido con gates F2 | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-022 | TOOLING_PACK como context pack separado | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-023 | QW#3 (Manager Protocol compaction) baja prioridad | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-024 | Escenario "sin compactación" añadido a budgets | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-025 | Verificar runtime API antes de F3 | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-026 | Regla R7 para decisiones explícitas | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-027 | Ahorro neto de session compaction documentado | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-028 | Tests calidad usan búsqueda semántica | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-029 | F2 apto para F3 | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-030 | F2 Critical Review como entrada de F3 | 2026-06-16 | ✅ Aprobada (CR) |

## D-F-033: F4B Session compaction design completed

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El diseño de F4B (Session History Compaction) se da por COMPLETED. Template RECENT_SESSION_PACK con 3 bloques (RAW+SUMMARY+ACCUMULATED) + regla R7 para decisiones explícitas + fallback para consultas sobre turns antiguos. |
| **Contexto** | F3 midió ahorro neto de ~7,070 tokens para sesión de 30 turns. |
| **Alternativas** | Formato 5+5+resto → más turns crudos pero menos ahorro. Formato 1+todo resumido → máximo ahorro pero alto riesgo de pérdida de contexto. |
| **Fundamento** | 3 turns crudos garantizan precisión inmediata. R7 preserva decisiones. Fallback protege contra pérdida de contexto histórico. |
| **Impacto** | Template listo en `recent-session-pack.template.md`. Pendiente aprobación para implementación en runtime. |

---

## D-F-034: F4C mem_context Selector design completed

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El diseño del mem_context Selector se da por COMPLETED. Algoritmo de 6 pasos (project match → score → dedup → top-K → fallback → explain) con 23 tests funcionales. |
| **Contexto** | F3 validó scoring 0.5/0.3/0.2 con 25 observaciones realistas. 1 ajuste (decay 0.05/día + floor para decisiones). |
| **Alternativas** | ML-based ranking → más preciso pero menos auditable y reversible. Sin selector → se pierde ~500-2,000 tokens/turno. |
| **Fundamento** | Reglas fijas son predecibles, auditables y reversibles. Pesos configurables permiten ajuste sin cambiar algoritmo. |
| **Impacto** | Scoring spec + 23 tests documentados en `F4C-selector-scoring-spec.md` y `F4C-selector-test-cases.md`. Pendiente aprobación para implementación. |

---

## D-F-035: F4 descompuesto en F4A-F4F

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | La fase F4 se descompone en 7 sub-fases: F4-0 (revalidación), F4A (Skills), F4B (Session), F4C (Selector), F4D (Runtime API), F4E (Manager Protocol v2), F4F (Roadmap Update). |
| **Contexto** | El roadmap original mostraba F4 como "Context Packs Design & Implementation", que no reflejaba el trabajo real de implementación de quick wins. |
| **Alternativas** | Mantener la descripción original de F4 → confunde con la realidad del trabajo. Fusionar F4 con F3 → se pierde visibilidad del progreso. |
| **Fundamento** | La descomposición en sub-fases pequeñas da visibilidad granular del progreso y permite aprobar/rechazar cada quick win individualmente. |
| **Impacto** | Implementation roadmap actualizado. Decision log actualizado con D-F-031 a D-F-035. |

---

## Decisiones de F4 (2026-06-16)

---

## D-F-031: Orden de implementación F4 confirmado

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | El orden Skills → Session → Selector se mantiene. Skills se implementa en Quick Track (sin esperar regression plan completo). |
| **Contexto** | F4-0 revalidó 5 alternativas de orden. Skills primero por ser el de menor riesgo, implementación inmediata y sin dependencias runtime. |
| **Alternativas** | Session primero (❌ mayor riesgo sin experiencia previa). Selector primero (❌ ahorro incierto). Paralelo (⚠️ complejidad innecesaria). Solo docs (❌ no avanza). |
| **Fundamento** | Skills es cambio puramente textual en system prompt — no requiere runtime, feature flag ni regresión extensiva. |
| **Impacto** | Skills se implementa en F4A. Session y Selector pasan por validación completa. |

---

## D-F-032: F4A Skills se implementa directamente (Quick Track)

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-16 |
| **Decisión** | Skills Selective Loading (QW#5) se implementa como cambio de descripciones en el bloque XML del system prompt. No requiere feature flag, no toca runtime. |
| **Contexto** | F3 midió ahorro real de ~1,184 tokens. Es cambio puramente textual. |
| **Alternativas** | No implementar → se pierde ~1,184 tokens. Esperar a F5 → riesgo bajo, no justifica demora. |
| **Fundamento** | Las descripciones de skills son solo informativas para el Manager. El Manager invoca skills por nombre, no por descripción. Cambiar descripciones no afecta funcionalidad. |
| **Impacto** | System prompt se reduce en ~1,184 tokens inmediatamente. |

---

## D-F-036: Prioridad F4 actualizada a F4B → F4C → F5/F6/F7

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | Se reemplaza el orden F4A → F4B → F4C por F4B → F4C → F5/F6/F7. |
| **Contexto** | F4D confirmó que F4A requiere tocar `opencode.json` o skills reales para ahorro neto, mientras F4B/F4C pueden implementarse por hooks existentes. |
| **Alternativas** | Mantener F4A primero → rechazado por requerir aprobación de config/global skills. |
| **Fundamento** | F4B tiene mejor ROI/riesgo; F4C es seguro como guidance; F4A queda decision-only. |
| **Impacto** | D-F-032 queda superada por esta decisión para implementación funcional. |

---

## D-F-037: F4B implementado como guidance-only en compaction hook

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | Implementar `RECENT_SESSION_PACK_COMPACTION_CONTEXT` en `experimental.session.compacting` de `engram.ts`. |
| **Contexto** | El hook ya existía y ya era usado por Engram; no se necesita modificar core runtime. |
| **Alternativas** | Reimplementar compactación → rechazado por riesgo. Solo documentar → menor impacto. |
| **Fundamento** | Guidance-only mantiene fallback actual y evita DB/schema/config migration. |
| **Impacto** | Requiere reiniciar OpenCode; compaction real debe validarse en runtime. |

---

## D-F-038: F4C implementado como Manager guidance, no Engram core

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | Implementar reglas compactas del selector en `experimental.chat.system.transform`, sin modificar `mem_context` ni Engram DB. |
| **Contexto** | F4C puede dar valor con bajo riesgo si el Manager rankea memorias recuperadas. |
| **Alternativas** | Modificar Engram Go → mayor enforcement pero mayor riesgo. Wrapper MCP → más complejo. |
| **Fundamento** | Guidance primero permite medir calidad antes de enforcement DB-level. |
| **Impacto** | Ahorro potencial ~500-2,000 tokens/turno; requiere disciplina del Manager. |

---

## D-F-039: F4A queda decision-only sin runtime/config changes

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | No implementar F4A funcional sin aprobación explícita para `opencode.json` o skills reales. |
| **Contexto** | `system.transform` agrega contenido pero no remueve el bloque original de skills. |
| **Fundamento** | Sin remover/compactar fuente original no hay ahorro neto confiable. |
| **Impacto** | F4A documentado en `F4A-skills-selective-loading-decision.md`. |

---

## D-F-040: QW#2 Tool Schema Loading queda prototype-only

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | No activar demand-loading de tool schemas en runtime; solo propuesta/prototipo aislado. |
| **Contexto** | `tool.definition` y `tool.execute.before` existen, pero pueden afectar tool-call accuracy. |
| **Fundamento** | Requiere pruebas de accuracy antes de rollout. |
| **Impacto** | Plan creado en `F4D-tool-schema-loading-prototype-plan.md`. |

---

## D-F-041: QW#3 Manager Protocol compaction sigue proposal-only

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | No aplicar compactación del Manager Protocol ni tocar `opencode.json`. |
| **Contexto** | Ahorro moderado con riesgo alto sobre reglas críticas. |
| **Fundamento** | F4B/F4C entregan mejor ROI/riesgo. |
| **Impacto** | Propuesta v2 creada sin cambios runtime/config. |

---

## D-F-042: F5/F6/F7 completan documentación, rebaseline y rollout plan

| Campo | Detalle |
|-------|---------|
| **Fecha** | 2026-06-17 |
| **Decisión** | Completar harness, regression run, rebaseline, rollout plan, executive package y README principal como parte del bloque autónomo. |
| **Contexto** | La implementación guidance-only necesita evidencia documental y gates. |
| **Fundamento** | Sin documentación y rollback, el cambio no es operable. |
| **Impacto** | README principal, DOCUMENTATION-INDEX y reportes F5/F6 actualizados. |

---

| # | Decisión | Fecha | Estado |
|---|----------|:-----:|:------:|
| D-F-001 | 9.5k no es límite rígido, es rango 8.5k–12k | 2026-06-16 | ✅ Aprobada |
| D-F-002 | Modo Normal como default | 2026-06-16 | ✅ Aprobada |
| D-F-003 | Fallback dinámico permitido | 2026-06-16 | ✅ Aprobada |
| D-F-004 | No compresión agresiva inicial | 2026-06-16 | ✅ Aprobada |
| D-F-005 | Primero token audit (F0) | 2026-06-16 | ✅ Aprobada |
| D-F-006 | E6B + Suite F como gates | 2026-06-16 | ✅ Aprobada |
| D-F-007 | Sesión canonical exclusiva | 2026-06-16 | ✅ Aprobada |
| D-F-008 | Packs como estructuras lógicas | 2026-06-16 | ✅ Aprobada |
| D-F-009 | Manager Protocol como KEEP_FIXED compactable | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-010 | Session history como quick win #1 | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-011 | Design Skills Protocol a RETRIEVE_ON_DEMAND | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-012 | Tool schemas requieren investigación runtime | 2026-06-16 | 🔶 Resuelta (F2) — Opción C |
| D-F-013 | Session summaries: dedup en retrieval, no eliminar | 2026-06-16 | ✅ Aprobada (F1) |
| D-F-014 | Context Packs expandidos con 3 nuevos packs | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-015 | Tool schemas bajo demanda por fase SDD (Opción C) | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-016 | Session history compactado 3+7+acumulativo | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-017 | Manager Protocol compactado sin tocar core | 2026-06-16 | 🔶 Pendiente aprobación usuario |
| D-F-018 | Skills block con descripciones 5–10 palabras | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-019 | gentle-ai en alineación estratégica, no integración | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-020 | F2 es diseño + auditoría, no implementación | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-021 | Regression plan extendido con gates F2 | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-022 | TOOLING_PACK como context pack separado | 2026-06-16 | ✅ Aprobada (F2) |
| D-F-023 | QW#3 (Manager Protocol compaction) baja prioridad | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-024 | Escenario "sin compactación" añadido a budgets | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-025 | Verificar runtime API antes de F3 | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-026 | Regla R7 para decisiones explícitas | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-027 | Ahorro neto de session compaction documentado | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-028 | Tests calidad usan búsqueda semántica | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-029 | F2 apto para F3 | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-030 | F2 Critical Review como entrada de F3 | 2026-06-16 | ✅ Aprobada (CR) |
| D-F-031 | Orden F4 confirmado: Skills → Session → Selector | 2026-06-16 | ✅ Aprobada (F4) |
| D-F-032 | F4A Skills Quick Track — implementación directa | 2026-06-16 | ✅ Aprobada (F4) |
| D-F-033 | F4B Session compaction design completed | 2026-06-16 | ✅ Diseño completado |
| D-F-034 | F4C mem_context Selector design completed | 2026-06-16 | ✅ Diseño completado |
| D-F-035 | F4 descompuesto en F4A-F4F | 2026-06-16 | ✅ Aprobada (F4) |
| D-F-036 | Prioridad F4 actualizada a F4B → F4C → F5/F6/F7 | 2026-06-17 | ✅ Aprobada |
| D-F-037 | F4B implementado como guidance-only en compaction hook | 2026-06-17 | ✅ Implementada |
| D-F-038 | F4C implementado como Manager guidance | 2026-06-17 | ✅ Implementada |
| D-F-039 | F4A queda decision-only | 2026-06-17 | ✅ No runtime |
| D-F-040 | QW#2 tool schema loading queda prototype-only | 2026-06-17 | ✅ No rollout |
| D-F-041 | QW#3 Manager Protocol compaction sigue proposal-only | 2026-06-17 | ✅ No config |
| D-F-042 | F5/F6/F7 documentación, rebaseline y rollout plan | 2026-06-17 | ✅ Ejecutada |

---

_Fin de decision-log.md — F4-F6 autonomous block updated. 42 decisiones registradas._
