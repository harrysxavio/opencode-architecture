# Risk Register — Fase F

**Estado:** ✅ UPDATED WITH F2 RISKS  
**Propósito:** Documentar riesgos específicos de la Fase F de reducción de tokens, su probabilidad, impacto y mitigaciones.

> Este documento fue actualizado con 8 nuevos riesgos de F2 (quick wins, contract, gentle-ai alignment) y 4 riesgos adicionales de F2 Critical Review (dependencia runtime, session compaction cost, budgets asumidos, IDs de Engram).

---

## Resumen

| # | Riesgo | Probabilidad | Impacto | Severidad | Estado |
|:-:|--------|:------------:|:-------:|:---------:|:------:|
| F-R01 | Pérdida de contexto crítico por reducción excesiva | Media | 🔴 Alto | 🔴 Crítico | Mitigación propuesta |
| F-R02 | Reducción excesiva que degrada calidad del agente | Media | 🟡 Medio | 🟡 Alto | Mitigación propuesta |
| F-R03 | Mezcla cross-project por filtro inadecuado | Baja | 🔴 Alto | 🟡 Alto | Mitigado en selector |
| F-R04 | `session_project_mismatch` en reducción | Baja | 🔴 Alto | 🟡 Alto | Mitigado: sesión canonical |
| F-R05 | Exposición de secretos en contexto reducido | Baja | 🔴 Crítico | 🔴 Crítico | Mitigado: filtro E6B |
| F-R06 | Degradación del Manager por contexto insuficiente | Media | 🟡 Medio | 🟡 Alto | Mitigación propuesta |
| F-R07 | Compaction peligrosa de memorias | Media | 🟡 Medio | 🟡 Alto | Evitar compaction agresiva |
| F-R08 | Dependencia excesiva de búsqueda bajo demanda | Media | 🟢 Bajo | 🟢 Medio | Fallback definido |
| F-R09 | Baseline de tokens incorrecto | Media | 🟡 Medio | 🟡 Alto | Metodología F0 |
| F-R10 | E6B o Suite F dejan de pasar por cambios | Baja | 🔴 Alto | 🔴 Crítico | Regression plan obligatorio |
| F-R11 | Falsos negativos en selector de memorias | Media | 🟢 Bajo | 🟢 Medio | Fallback L5 definido |
| F-R12 | Inflado de tokens por packs mal diseñados | Media | 🟡 Medio | 🟡 Medio | Budget contract |
| F-R25 | Hooks `experimental.*` cambian en futuras versiones | Media | 🟡 Medio | 🟡 Alto | Backup + rollback + restart requerido |
| F-R26 | F4B guidance ignorado por compactor | Media | 🟡 Medio | 🟡 Medio | Fallback Engram existente intacto |
| F-R27 | F4C selector guidance no enforcea DB-level | Media | 🟡 Medio | 🟡 Medio | Explainability + future Engram enforcement si se valida |
| F-R28 | F4A aplicado sin aprobación de config/skills | Baja | 🔴 Alto | 🔴 Crítico | Decision-only; harness boundary |
| F-R29 | QW#2 tool schema loading reduce tool-call accuracy | Media | 🔴 Alto | 🔴 Crítico | Prototype-only antes de rollout |
| F-R30 | README/docs contradicen estado real | Media | 🟡 Medio | 🟡 Alto | DOCUMENTATION-INDEX + harness docs gate |

---

## Riesgos F4-F6 añadidos (2026-06-17)

### F-R25: Hooks `experimental.*` cambian en futuras versiones

Mitigación: mantener backup de `engram.ts`, documentar rollback y validar tras cada upgrade de OpenCode.

### F-R26: F4B guidance ignorado por compactor

Mitigación: mantener instrucción Engram `FIRST ACTION REQUIRED` intacta y validar primer compacted summary real tras restart.

### F-R27: F4C selector guidance no enforcea DB-level

Mitigación: exigir explainability al Manager y considerar enforcement en Engram core solo después de pruebas.

### F-R28: F4A aplicado sin aprobación de config/skills

Mitigación: F4A queda decision-only y el harness valida el boundary.

### F-R29: QW#2 reduce tool-call accuracy

Mitigación: mantener prototype-only y medir accuracy antes de rollout.

### F-R30: README/docs contradicen estado real

Mitigación: README principal, README Fase F y DOCUMENTATION-INDEX actualizados; harness verifica Mermaid/status básico.

---

## F-R01: Pérdida de contexto crítico por reducción excesiva

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Al reducir contexto, se elimina información que el agente necesita para tomar decisiones correctas. |
| **Probabilidad** | Media |
| **Impacto** | 🔴 Alto — decisiones incorrectas, regresiones no detectadas |
| **Severidad** | 🔴 Crítico |

**Síntomas:**
- El agente ignora restricciones activas.
- El agente repite errores ya resueltos.
- Decisiones previas no se reflejan en el output.

**Mitigación:**
1. L0 y L1 nunca se reducen (core rules + identity siempre presentes).
2. Modos de expansión permiten recuperar contexto perdido.
3. Fallback L5 para búsqueda adicional.
4. Regression plan post-implementación.
5. Monitoreo de "contexto insuficiente" como KPI.

**Contingencia:** Revertir a modo sin reducción y expandir gradualmente.

---

## F-R02: Reducción excesiva que degrada calidad del agente

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El agente produce respuestas de menor calidad por falta de contexto. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Alto |

**Síntomas:**
- Respuestas genéricas.
- Falta de especificidad del proyecto.
- Necesidad de múltiples iteraciones para lograr calidad.

**Mitigación:**
1. Modo Normal como default con ~9.5k tokens — suficiente para tareas estándar.
2. Expansión automática a 14k sin justificación.
3. KPIs de calidad de respuesta post-implementación.

---

## F-R03: Mezcla cross-project por filtro inadecuado

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El sistema incluye contexto de proyectos legacy (arquitectura-ia, etc.). |
| **Probabilidad** | Baja |
| **Impacto** | 🔴 Alto — contexto incorrecto, decisiones contaminadas |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. `--project=opencode-architecture` siempre explícito en búsquedas.
2. Filtro post-búsqueda: solo results con project match exacto.
3. Legacy sessions excluidas salvo mención explícita.

---

## F-R04: session_project_mismatch en el contexto reducido

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El sistema opera en sesión legacy con `session_project` distinto del canónico. |
| **Probabilidad** | Baja (con mitigación) |
| **Impacto** | 🔴 Alto — prompts no se capturan, contexto cruzado |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. Siempre verificar `mem_current_project` al inicio de sesión.
2. Si mismatch detectado, advertir y recomendar sesión canonical.
3. Noise Gate ya maneja el mismatch con logging sanitizado.

---

## F-R05: Exposición de secretos en contexto reducido

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Memorias con secretos se incluyen en el contexto. |
| **Probabilidad** | Baja |
| **Impacto** | 🔴 Crítico — exposición de credenciales |
| **Severidad** | 🔴 Crítico |

**Mitigación:**
1. E6B-T5 validó filtro de `ghp_` (PASS).
2. Selector de memorias excluye contenido con patrones sensibles.
3. Noise Gate bloquea antes de POST.
4. Auditoría periódica de contenido sensible en Engram.

---

## F-R06: Degradación del Manager por contexto insuficiente

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El Manager (orquestador) no tiene suficiente contexto para decidir. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. L0 y L1 garantizan reglas + identidad.
2. L2 garantiza estado activo.
3. El Manager tiene prioridad en el reparto de tokens.
4. Expansión automática para tareas de orquestación.

---

## F-R07: Compaction peligrosa de memorias

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Al compactar sesiones o memorias, se pierden decisiones críticas. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. Nunca compactar observaciones tipo `architecture` o `decision`.
2. Solo compactar `session_summary` después de N sesiones.
3. Backup antes de cualquier compaction.
4. Política de retención por tipo de memoria.

---

## F-R08: Dependencia excesiva de búsqueda bajo demanda

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El sistema depende tanto de L5 que cada tarea requiere búsqueda adicional. |
| **Probabilidad** | Media |
| **Impacto** | 🟢 Bajo |
| **Severidad** | 🟢 Medio |

**Mitigación:**
1. L3 con top-k suficiente para la mayoría de tareas.
2. L5 solo como expansión, no como reemplazo.
3. KPI: tasa de búsquedas adicionales por sesión.

---

## F-R09: Baseline de tokens incorrecto

| Campo | Detalle |
|-------|---------|
| **Riesgo** | La medición de ~40k es incorrecta o no representativa. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. Metodología F0 con medición real usando tiktoken.
2. Medir en 3 tipos de tarea (simple, normal, arquitectura).
3. Documentar el comando de medición para reproducibilidad.

---

## F-R10: E6B o Suite F dejan de pasar por cambios

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los cambios de Fase F rompen las validaciones existentes. |
| **Probabilidad** | Baja |
| **Impacto** | 🔴 Alto |
| **Severidad** | 🔴 Crítico |

**Mitigación:**
1. Regression plan obligatorio (ver `regression-plan.md`).
2. E6B y Suite F como gates CI antes de rollout.
3. Feature flag para desactivar reducción si es necesario.

---

## F-R11: Falsos negativos en selector de memorias

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El selector excluye memorias que sí eran relevantes (score < threshold). |
| **Probabilidad** | Media |
| **Impacto** | 🟢 Bajo |
| **Severidad** | 🟢 Medio |

**Mitigación:**
1. Threshold mínimo de score configurable.
2. Fallback L5 para búsqueda adicional.
3. Si contexto insuficiente, expandir y bajar threshold.

---

## F-R12: Inflado de tokens por packs mal diseñados

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los context packs, en lugar de reducir, inflan tokens por diseño verboso. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Budget contract estricto por pack.
2. Cada pack tiene rango de tokens definido.
3. Revisión periódica del tamaño real de cada pack.

---

---

## F-R13: Compactación de Manager Protocol pierde regla crítica

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Al compactar el Manager Protocol (28,471 chars → ~19k), se elimina o modifica una regla de orquestación importante. |
| **Probabilidad** | Baja |
| **Impacto** | 🔴 Alto — Manager pierde instrucciones de orquestación |
| **Severidad** | 🔴 Alto |

**Mitigación:**
1. Diff texto completo antes/después revisado por Manager.
2. E6B + Suite F como gates post-cambio.
3. Las secciones core (Global Rule, Operating Model, SDD phases) NO se tocan.
4. Prueba P1: Manager behavior no cambia.

---

## F-R14: Tool loading dinámico no soportado por runtime

| Campo | Detalle |
|-------|---------|
| **Riesgo** | OpenCode runtime no permite cargar tool schemas selectivamente, bloqueando QW#2. |
| **Probabilidad** | Alta — no se verificó la API de runtime en F2 |
| **Impacto** | 🔴 Alto — bloquea implementación de QW#2 |
| **Severidad** | 🔴 Alto |

**Mitigación:**
1. Verificar existencia de API con OpenCode CLI o documentación antes de F3.
2. Si no existe: QW#2 queda como idea no implementable; no invertir tiempo.
3. Opción C (carga por decisión del Manager) requiere lógica de clasificación que no existe aún.
4. Si no es posible, mantener herramientas core 6 + cargar todo como ahora (sin ahorro).

---

## F-R15: Session history compactado pierde continuidad

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El resumen estructurado del session history omite detalles que el Manager necesita para mantener coherencia. Además, el acto de compactar consume tokens (~200–500 por actualización), reduciendo el ahorro neto. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Últimos 3 turns siempre crudos (garantía de precisión inmediata).
2. Template estructurado (no generación libre).
3. Prueba QW1-T4: Manager mantiene coherencia con resumen vs history completo.
4. Añadir regla R7: decisiones explícitas (marcadores: "decido", "no hagas", "es mejor que", "prefiero") se preservan textualmente.
5. Documentar ahorro neto (ahorro bruto - costo de compactar).

---

## F-R16: Skills selectivos causan falsos negativos en matching

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Descripciones cortas de skills no permiten al Manager identificar cuándo cargar un skill. |
| **Probabilidad** | Baja |
| **Impacto** | 🟢 Bajo |
| **Severidad** | 🟢 Bajo |

**Mitigación:**
1. Manager puede invocar skill por nombre sin depender del bloque.
2. Las descripciones cortas usan trigger keywords precisos.
3. Prueba P2: No hay falsos negativos en skill matching.

---

## F-R17: Dependencia OpenCode ↔ gentle-ai no autorizada

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Durante la auditoría de gentle-ai alignment, se crea inadvertidamente una dependencia entre OpenCode y gentle-ai. |
| **Probabilidad** | Baja |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. gentle-ai solo se audita, no se integra ni modifica.
2. Política explícita: "no crear dependencia OpenCode ↔ gentle-ai sin aprobación".
3. Documento de alineación (`gentle-ai-alignment.md`) registra la decisión.

---

## F-R18: F2 contract tiene budgets inconsistentes entre documentos

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los budgets definidos en F2-context-budget-contract.md no coinciden con context-layers-design.md o context-packs-design.md. |
| **Probabilidad** | Baja |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Verificación cruzada: Test C-T1 a C-T6 del regression plan.
2. Un solo documento fuente (F2-context-budget-contract.md).
3. Los otros documentos referencian a F2 como fuente.

---

## F-R19: Quick wins diseñados en F2 no se implementan en F3

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los 5 quick wins diseñados en F2 quedan como documentos sin implementar por falta de tiempo, prioridad o recursos. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Cada quick win tiene fase de implementación asignada (F2 o F3).
2. Implementation roadmap documenta la secuencia.
3. Si un quick win no se implementa, registrar en decision-log y actualizar budgets.

---

## F-R20: Manager protocol compaction requiere cambios en opencode.json sin aprobación

| Campo | Detalle |
|-------|---------|
| **Riesgo** | La compactación del Manager Protocol requiere modificar `opencode.json`, lo cual puede tener consecuencias imprevistas. |
| **Probabilidad** | Baja |
| **Impacto** | 🔴 Alto |
| **Severidad** | 🟡 Alto |

**Mitigación:**
1. Este documento es solo la propuesta de diseño.
2. **No implementar sin aprobación explícita del usuario.**
3. Si se aprueba: diff antes/después, test E6B + Suite F, feature flag.

---

## F-R21: Runtime OpenCode no expone API para tool loading selectivo

| Campo | Detalle |
|-------|---------|
| **Riesgo** | OpenCode runtime no expone una API que permita cargar tool schemas selectivamente, lo cual bloquea la implementación de QW#2 (Tool Schema Demand-Loading). |
| **Probabilidad** | Alta |
| **Impacto** | 🔴 Alto |
| **Severidad** | 🔴 Alto |

**Mitigación:**
1. Verificar existencia de API con OpenCode CLI (`opencode tool:load --help`) o documentación antes de invertir en QW#2.
2. Si no existe, QW#2 queda descartado y el ahorro de 2k–4k se debe recuperar de otros quick wins.
3. Registrar la decisión en decision-log.

---

## F-R22: Session compaction consume más tokens de los que ahorra al resumir

| Campo | Detalle |
|-------|---------|
| **Riesgo** | El Manager gasta tokens en generar y mantener el resumen estructurado del session history, reduciendo el ahorro neto respecto al bruto estimado (~3k–5k bruto → potencialmente ~1k–4.2k neto). |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Documentar ahorro neto realista (bruto - costo de compactación).
2. Si el ahorro neto es <1k, reevaluar si la complejidad vale la pena.
3. Medir en cada iteración el costo real de compactación.

---

## F-R23: Budgets asumen compactación de Manager Protocol que no se implementó

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los budgets definidos en F2-context-budget-contract.md asumen la compactación del Manager Protocol (de ~7k–14k a ~5k–8k). Sin esa compactación, especialmente el modo Normal salta de 8.5k–12k a ~10k–15k, superando el límite. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Añadir escenario "sin compactación de Manager Protocol" a los budgets.
2. Modo Normal sin compactación: objetivo 10k–14k en lugar de 8.5k–12k.
3. Ajustar expectativas en la implementación roadmap.

---

## F-R24: Tests de calidad dependen de IDs de Engram que pueden cambiar

| Campo | Detalle |
|-------|---------|
| **Riesgo** | Los tests Q-T1 a Q-T5 del regression plan dependen de IDs específicos de Engram (#404, #427). Si se purgan o renumeran, los tests fallan sin degradación real. |
| **Probabilidad** | Media |
| **Impacto** | 🟡 Medio |
| **Severidad** | 🟡 Medio |

**Mitigación:**
1. Usar búsqueda semántica en lugar de IDs fijos para localizar observaciones de prueba.
2. O mantener snapshots de las observaciones de prueba en archivos estáticos.
3. Documentar que estos tests requieren mantenimiento si Engram se purga.

---

## Matriz de severidad

| # | Riesgo | P | I | S |
|:-:|--------|:-:|:-:|:-:|
| F-R01 | Pérdida de contexto crítico | ●●○ | 🔴 | 🔴 |
| F-R02 | Degradación de calidad | ●●○ | 🟡 | 🟡 |
| F-R03 | Mezcla cross-project | ●○○ | 🔴 | 🟡 |
| F-R04 | session_project_mismatch | ●○○ | 🔴 | 🟡 |
| F-R05 | Exposición de secretos | ●○○ | 🔴 | 🔴 |
| F-R06 | Manager degradado | ●●○ | 🟡 | 🟡 |
| F-R07 | Compaction peligrosa | ●●○ | 🟡 | 🟡 |
| F-R08 | Dependencia L5 | ●●○ | 🟢 | 🟢 |
| F-R09 | Baseline incorrecto | ●●○ | 🟡 | 🟡 |
| F-R10 | E6B/Suite F rotos | ●○○ | 🔴 | 🔴 |
| F-R11 | Falsos negativos selector | ●●○ | 🟢 | 🟢 |
| F-R12 | Packs inflados | ●●○ | 🟡 | 🟡 |
| F-R13 | Manager Protocol compactación pierde regla | ●○○ | 🔴 | 🔴 |
| F-R14 | Tool loading no soportado | ●●○ | 🟡 | 🟡 |
| F-R15 | Session history pierde continuidad | ●○○ | 🟡 | 🟡 |
| F-R16 | Skills falsos negativos | ●○○ | 🟢 | 🟢 |
| F-R17 | Dependencia gentle-ai no autorizada | ●○○ | 🟡 | 🟡 |
| F-R18 | Budgets inconsistentes entre docs | ●○○ | 🟡 | 🟡 |
| F-R19 | Quick wins no implementados | ●●○ | 🟡 | 🟡 |
| F-R20 | opencode.json cambiado sin aprobación | ●○○ | 🔴 | 🟡 |
| F-R21 | Runtime OpenCode no expone API para tool loading selectivo | ●●● | 🔴 | 🔴 |
| F-R22 | Session compaction consume más tokens de los que ahorra al resumir | ●●○ | 🟡 | 🟡 |
| F-R23 | Budgets asumen compactación de Manager Protocol que no se implementó | ●●○ | 🟡 | 🟡 |
| F-R24 | Tests de calidad dependen de IDs de Engram que pueden cambiar | ●●○ | 🟡 | 🟡 |

**P = Probabilidad (●○○ baja, ●●○ media, ●●● alta)**  
**I = Impacto (🟢 bajo, 🟡 medio, 🔴 alto, 🔴 crítico)**  
**S = Severidad compuesta**

---

_Fin de risk-register.md_
