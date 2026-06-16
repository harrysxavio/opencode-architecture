# Decision Log — Fase F

**Propósito:** Registrar todas las decisiones tomadas durante la planificación e implementación de Fase F, con fundamento y alternativas consideradas.

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
| D-F-012 | Tool schemas requieren investigación runtime | 2026-06-16 | 🔶 Pendiente investigación |
| D-F-013 | Session summaries: dedup en retrieval, no eliminar | 2026-06-16 | ✅ Aprobada (F1) |

---

_Fin de decision-log.md_
