# F2 Critical Review — Readiness for F3

**Estado:** ✅ CRITICAL REVIEW COMPLETED  
**Fecha:** 2026-06-16  
**Propósito:** Auditar críticamente los 14 documentos de F2 antes de autorizar F3, identificar gaps, supuestos débiles, riesgos subestimados y quick wins mal priorizados.

---

## Executive Summary

**Veredicto: F2 es APTO PARA F3 con 3 observaciones y 1 mejora obligatoria.**

F2 es sólido en general. Los budgets, capas, packs y contratos están bien fundamentados. Pero la revisión crítica detectó:

- **1 gap real**: el ahorro del Manager Protocol compactado se asume en los budgets de F2 pero la compactación no se implementó (requiere aprobación). Sin esa compactación, el modo Normal queda en ~11k–15k, rozando el límite superior.
- **2 riesgos subestimados**: (a) la viabilidad real del tool loading dinámico depende de APIs de runtime que no se verificaron; (b) el session compaction consume tokens en el acto de compactar, reduciendo el ahorro neto.
- **3 quick wins** reevaluados: QW#1 sigue siendo el más impactante; QW#3 (Manager Protocol) tiene peor ROI de lo estimado; QW#5 (skills) es el más seguro pero el más pequeño.

---

## 1. Challenge al F2 Context Budget Contract

### 1.1 ¿El budget de tokens es realista?

| Modo | Budget F2 | Realidad si Manager Protocol no se compacta | Diferencia |
|:----:|:---------:|:-------------------------------------------:|:----------:|
| Simple | 6k–8.5k | ~7k–10k (Manager Protocol sin compactar ~3k–4k → ~4k–5k) | ⚠️ Roza límite |
| Normal | 8.5k–12k | ~10k–15k (Manager Protocol sin compactar ~7k–14k → aporta ~5k extra) | ⚠️ **Excede** |
| Arquitectura | 12k–16k | ~15k–20k | ⚠️ Excede |
| Auditoría | 16k–22k | ~20k–28k | ⚠️ Excede |

**Hallazgo:** Los budgets de F2 **asumen la compactación del Manager Protocol** (de ~7k–14k a ~5k–8k). Si el usuario no la aprueba, el modo Normal sube considerablemente.

**Recomendación:** Añadir un escenario "sin compactación de Manager Protocol" a los budgets como fallback realista. Modo Normal sin compactación: objetivo 10k–14k en lugar de 8.5k–12k.

### 1.2 ¿Hay quick wins sobreestimados?

**QW#3 (Dedup Manager/AGENTS.md, ~300–550 tokens):**
- El ahorro real es de ~200–400 tokens (no los 550 del extremo superior).
- El riesgo de modificar `opencode.json` es alto.
- **ROI reevaluado:** peor de lo estimado. Cada token ahorrado cuesta más riesgo que QW#1 o QW#5.

**QW#4 (Memorias Rankeadas + Top-K, ~500–2k tokens):**
- El rango es muy amplio (1,500 tokens de diferencia).
- Depende de la calidad del scoring semántico, que no se ha probado con datos reales.
- **ROI reevaluado:** correcto pero el piso (500 tokens) puede ser el resultado real si el scoring no es preciso.

### 1.3 ¿Hay riesgos subestimados?

| Riesgo | En F2 | Reevaluación |
|--------|:-----:|:-------------|
| Tool loading no soportado por runtime | 🟡 Medio | 🔴 **Alto**. No se verificó la API de OpenCode. Sin esa API, el QW#2 no es implementable. |
| Session compaction consume tokens | 🟢 Bajo | 🟡 **Medio**. El Manager gasta tokens en mantener el resumen. El ahorro neto es ~3k–5k menos el costo de compactar (~200–500 tokens por actualización). |
| Manager Protocol compactación pierde regla | 🟡 Medio | 🟡 **Medio**. Confirmado. El ROI modesto (~1.2k–2.3k) no justifica el riesgo sin aprobación explícita. |

---

## 2. Challenge a Tool Schema Demand-Loading Audit

### 2.1 ¿Tool schemas bajo demanda es realmente viable?

**No verificado.** La auditoría presenta 3 opciones:
- Opción A (runtime dinámico): no se verificó si OpenCode lo soporta.
- Opción B (plugin): riesgo alto.
- Opción C (Manager decide): requiere lógica de clasificación que no existe.

**Problema real:** Las 3 opciones dependen de que OpenCode exponga una API para cargar tool schemas selectivamente. **Esto no se verificó en F2.** Si la API no existe, QW#2 no es implementable sin cambios en OpenCode.

**Recomendación:** Antes de F3, verificar con OpenCode CLI o documentación si existe `opencode tool:load <name>` o equivalente. Si no existe, QW#2 queda como idea no implementable.

### 2.2 ¿La clasificación por fase SDD es correcta?

| Fase SDD | Tools propuestas | ¿Alguna puede faltar? |
|:---------|:-----------------|:----------------------|
| SDD Explore | core + task, delegate | ⚠️ Puede necesitar `webfetch` si investiga APIs externas |
| SDD Apply | core + task, skill, todowrite | ⚠️ Puede necesitar `bash` con más flags |
| SDD Verify | core + bash, task | ✅ OK |

**Hallazgo:** La clasificación es un buen punto de partida pero puede generar falsos negativos (tool no disponible cuando se necesita). El lazy load fallback es crítico.

---

## 3. Challenge a Session History Compaction Audit

### 3.1 ¿Session compaction puede perder decisiones críticas?

**Riesgo real pero mitigado.** Los últimos 3 turns crudos garantizan que la decisión más reciente está disponible. Pero si una decisión crítica ocurrió en el turno 6 de 20, y ese turno se resume a 1 línea, el resumen puede omitir matices.

**Caso concreto:** Si en el turno 6 el usuario dijo "No hagas X, haz Y con la condición Z", el resumen "Turno 6: User pidió Y" pierde "con la condición Z".

**Recomendación:** Añadir regla R7: "Si un turno contiene una decisión explícita (marcadores: 'decido', 'no hagas', 'es mejor que', 'prefiero'), esa decisión debe preservarse textualmente en el resumen, no resumirse."

### 3.2 ¿Quién genera los resúmenes?

**Gap detectado en F2:** La auditoría propone templates pero no dice quién los llena. Opciones:
- **Manager** (Opción A): consume tokens al generar resúmenes. El ahorro neto disminuye.
- **Runtime** (Opción B/C): requiere cambios en OpenCode.

**Impacto en ahorro neto:** Si Manager compacta, gasta ~200–500 tokens por actualización. En una sesión de 20 turns con 4 compactaciones, eso son ~800–2,000 tokens gastados en compactar. Ahorro neto: ~3k–5k - ~800–2k = ~1k–4.2k.

**Recomendación:** Documentar explícitamente que la Opción A (Manager compacta) consume tokens y calcular el ahorro neto realista.

---

## 4. Challenge a Manager Protocol Compaction Audit

### 4.1 ¿El ahorro justifica el riesgo?

| Aspecto | Valor |
|---------|:------|
| Ahorro estimado | ~1,200–2,300 tokens |
| Riesgo | Modificar opencode.json (archivo crítico de configuración) |
| Dependencias | Aprobación explícita del usuario |
| Alternativa | No compactar y asumir budgets más amplios |

**ROI:** Bajo. Por cada 1 token ahorrado, se asume un riesgo alto de modificar la configuración core del sistema.

**Recomendación:** **Mantener como propuesta pero NO priorizar.** QW#3 pasa de quick win a "nice to have". El ahorro se puede recuperar combinando QW#1 + QW#4 + QW#5 (~4k–7.6k tokens) sin tocar el protocolo.

### 4.2 ¿El ahorro estimado es realista?

Las secciones "compactables" suman 6,200 chars (~1,550–3,100 tokens). El ahorro estimado de 1,200–2,300 tokens representa una compactación del 40–74% de esas secciones. ¿Es realista?

Caso: Anti-Patterns (1,600 chars → 800 chars = 50% reducción). Sí, es factible.
Caso: Context Layer Definitions (3,000 chars → 1,500 chars = 50% reducción). Sí, reemplazando descripciones inline con referencias.

**Veredicto:** El ahorro es realista pero el riesgo no lo justifica como prioridad.

---

## 5. Challenge a Skills Selective Loading Audit

### 5.1 ¿Skills selectivos es realmente seguro?

**Sí, es el quick win más seguro.** Cambiar descripciones de 1–2 líneas a 5–10 palabras no afecta la funcionalidad del skill. El Manager invoca skills por nombre, no por descripción.

### 5.2 ¿El ahorro (~400–600 tokens) justifica el esfuerzo?

**Sí, para ser el primer quick win implementado.** Es bajo riesgo, bajo esfuerzo, y da ~500 tokens de ahorro inmediato. Además, demuestra que la Fase F produce resultados reales.

### 5.3 ¿Filtrar por proyecto es viable?

**No, sin soporte de runtime.** La propuesta de filtrar skills por proyecto activo es correcta conceptualmente pero requiere que OpenCode soporte skills condicionales. Sin esa API, mantener el bloque completo compactado.

---

## 6. Challenge a gentle-ai Alignment

### 6.1 ¿La relación con gentle-ai quedó como arquitectura reusable o superficial?

**Arquitectura reusable pero superficial.** El diseño de capas, packs y modos es reusable conceptualmente. Pero no hay:
- Un documento que especifique cómo gentle-ai adoptaría estos patrones.
- Una interfaz o contrato entre sistemas.
- Métricas de cómo se mediría la compatibilidad.

**Recomendación:** Profundizar en TASK 8. Crear un plan de evaluación futura que especifique qué patrones son transferibles y bajo qué condiciones.

### 6.2 ¿Hay riesgo de forzar una relación artificial?

**Sí, si se menciona gentle-ai en cada documento sin necesidad.** Hasta ahora, gentle-ai aparece solo donde es relevante. Mantener esa disciplina.

---

## 7. Challenge a Regression Plan

### 7.1 ¿Las pruebas detectan degradación real o solo checklist?

**Riesgo de falsa seguridad.** Los 9 gates y 52 tests son exhaustivos en cobertura pero:
- **Q-T1 a Q-T5** (Quality): dependen de que existan las observaciones específicas en Engram (#404, #427). Si se purgan o renumeran, los tests fallan sin que haya degradación real.
- **B-T1 a B-T6** (Budget): miden tokens pero no miden calidad de respuesta. Es posible pasar todos los budget tests y tener respuestas de baja calidad.

**Recomendación:** Añadir test de "calidad subjetiva": comparar respuesta del sistema con contexto completo vs contexto reducido para 3 tareas representativas. Documentar la diferencia.

### 7.2 ¿El harness es ejecutable?

No. Los tests están documentados como especificaciones pero no hay scripts ni automatización. Para F3, se necesita al menos un script read-only que ejecute los tests automáticamente.

---

## 8. Challenge a Risk Register

### 8.1 ¿Riesgos subestimados?

| ID | Riesgo | Probabilidad en F2 | Reevaluación |
|:--:|--------|:-------------------:|:-------------|
| F-R14 | Tool loading no soportado | Media | 🔴 **Alta**. Sin runtime API, QW#2 muere. |
| F-R15 | Session history pierde continuidad | Baja | 🟡 **Media**. El resumen puede omitir condiciones de decisiones críticas. |
| F-R19 | Quick wins no implementados | Media | 🟡 **Media**. Especialmente QW#3 (Manager Protocol) que requiere aprobación. |

### 8.2 ¿Qué riesgo falta?

**Falta F-R21: Dependencia de runtime para validación.** Sin acceso al runtime de OpenCode, no se puede verificar si tool loading dinámico, skills selectivos, o session compaction son implementables. Este riesgo no está documentado.

---

## 9. Resumen de hallazgos

| # | Hallazgo | Severidad | Acción |
|:-:|----------|:---------:|--------|
| H1 | Budgets asumen compactación de Manager Protocol que no se implementó | 🟡 Alta | Añadir escenario "sin compactación" a budgets |
| H2 | Tool loading dinámico requiere runtime API no verificada | 🟡 Alta | Verificar antes de F3; si no existe, descartar QW#2 |
| H3 | Session compaction consume tokens al compactar (ahorro neto menor) | 🟡 Media | Documentar ahorro neto realista |
| H4 | QW#3 (Manager Protocol) tiene peor ROI de lo estimado | 🟡 Media | Pasar de quick win a "nice to have" |
| H5 | Falta regla R7 para preservar decisiones explícitas en resumen | 🟡 Media | Añadir R7 al session compaction |
| H6 | Tests de calidad dependen de IDs de Engram que pueden cambiar | 🟢 Baja | Usar búsqueda semántica en lugar de IDs fijos |
| H7 | No hay script de ejecución para regression plan | 🟢 Media | Crear harness básico en F3 |
| H8 | gentle-ai alignment es correcto pero superficial | 🟢 Baja | Profundizar en TASK 8 |

---

## 10. Veredicto: F2 ready for F3?

| Dimensión | Estado |
|:----------|:------:|
| **Budgets** | ✅ Aprobado con observación (añadir escenario sin compactación) |
| **Quick wins** | ✅ Aprobado con 1 mejora (ROI de QW#3 reevaluado) |
| **Capas y packs** | ✅ Aprobado |
| **Selector de memorias** | ✅ Aprobado |
| **Tool schemas** | ⚠️ Condicional (verificar runtime API antes de F3) |
| **Session compaction** | ✅ Aprobado con mejora (añadir R7, ahorro neto) |
| **Manager Protocol** | ✅ Aprobado como propuesta (no implementar sin aprobación) |
| **Skills selectivos** | ✅ Aprobado — primer candidato para implementación |
| **gentle-ai alignment** | ✅ Aprobado — profundizar en TASK 8 |
| **Regression plan** | ✅ Aprobado — crear harness ejecutable en F3 |
| **Risk register** | ✅ Aprobado con añadidos |
| **Decision log** | ✅ Aprobado |

**Veredicto final: ✅ F2 APTO PARA F3.**
- 1 mejora requerida: añadir escenario "sin compactación" a budgets.
- 1 condición: verificar runtime API antes de F3D.
- 3 mejoras recomendadas: R7, ahorro neto, ROI QW#3.

---

## 11. Documentos afectados

| Documento | Acción |
|-----------|:------:|
| `F2-critical-review.md` | ✅ Creado — este documento |
| `risk-register.md` | Pendiente: añadir F-R21 (dependencia runtime) |
| `decision-log.md` | Pendiente: registrar hallazgos H1-H8 |
| `implementation-roadmap.md` | Pendiente: marcar F2 review COMPLETED |

---

*Fin de F2-critical-review.md — Revisión crítica de F2 completada. Veredicto: APTO para F3 con observaciones.*
