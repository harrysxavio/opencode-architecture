# Risk Register — Fase F

**Propósito:** Documentar riesgos específicos de la Fase F de reducción de tokens, su probabilidad, impacto y mitigaciones.

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

**P = Probabilidad (●○○ baja, ●●○ media, ●●● alta)**  
**I = Impacto (🟢 bajo, 🟡 medio, 🔴 alto, 🔴 crítico)**  
**S = Severidad compuesta**

---

_Fin de risk-register.md_
