# Session History Compaction Audit — F2

**Estado:** ✅ AUDIT COMPLETED (2026-06-16)  
**Propósito:** Auditar cómo se gestiona actualmente el session history, diseñar el modelo de compactación, y proponer el formato RECENT_SESSION_PACK para F3.

---

## Executive Summary

El session history es la fuente más impactante para quick win: **~5,000–8,000 tokens por sesión típica**. La compactación propuesta lo reduce a **~1,000–2,000 tokens** manteniendo los últimos 3 turns crudos para precisión inmediata.

**Decisión:** Implementar formato estructurado: últimos 3 turns crudos + turns 4–10 resumidos + turns 11+ resumen acumulativo. Diseñar para F3.

---

## 1. Estado actual

| Métrica | Valor |
|---------|:-----:|
| User prompts en DB | 312 registros (161,117 chars) |
| Session history en runtime | 10–30 turns por sesión típica |
| Chars por turno promedio | ~200–500 (prompt) + ~500–2,000 (response) |
| Tokens estimados por sesión | ~5,000–8,000 |
| En sesiones largas (+20 turns) | Puede superar 10,000 |

### Problemas identificados

1. **Sin diferenciación**: todos los turns se tratan igual, sin importar su antigüedad.
2. **Redundancia**: turns antiguos contienen decisiones que ya están en Engram como memorias.
3. **Crecimiento lineal**: el session history crece sin límite dentro de la sesión.
4. **Sin estructura de resumen**: no hay un mecanismo para compactar turns antiguos.

---

## 2. Modelo de compactación propuesto

### Estructura del session history compactado

```
┌─────────────────────────────────────────────────────────┐
│ ÚLTIMOS 3 TURNS (crudos, máxima precisión)              │
│ Turno N-2: [user prompt] → [assistant response]          │
│ Turno N-1: [user prompt] → [assistant response]          │
│ Turno N  : [user prompt] → [assistant response]          │
├─────────────────────────────────────────────────────────┤
│ TURNS 4–10 (resumen 1–2 líneas por turno)                │
│ Turno N-5: User pidió X → Se diseñó Y                    │
│ Turno N-6: User preguntó Z → Se respondió W              │
│ ...                                                      │
├─────────────────────────────────────────────────────────┤
│ TURNS 11+ (resumen acumulativo)                          │
│ El usuario trabajó en: A, B, C.                          │
│ Se implementaron: D, E.                                  │
│ Queda pendiente: F.                                      │
│ Decisiones clave: G, H.                                  │
└─────────────────────────────────────────────────────────┘
```

### Formato RECENT_SESSION_PACK

```
── Recent Session Pack ──────────────────────
┌ Últimos 3 turns ──────────────────────────┐
│ #1: [Prompt] → [Response resumen 1 línea] │
│ #2: [Prompt] → [Response resumen 1 línea] │
│ #3: [Prompt] → [Response resumen 1 línea] │
├── Turns 4–10 ──────────────────────────────┤
│ ● T4: User pidió {tema} → Se {acción}      │
│ ● T5: User preguntó {tema} → Se {respuesta}│
│ ● T6: Se acordó {decisión}                 │
│ (máx 7 líneas, 1–2 líneas cada turno)      │
├── Resumen acumulativo ──────────────────────┤
│ ● Áreas trabajadas: {lista}                 │
│ ● Implementado: {lista}                     │
│ ● Pendiente: {lista}                        │
│ ● Decisiones activas: {lista}               │
└──────────────────────────────────────────────┘
```

### Reglas de compactación

| Regla | Descripción |
|-------|-------------|
| R1 | Los últimos 3 turns SIEMPRE se mantienen crudos |
| R2 | Turns 4–10 se resumen en 1–2 líneas cada uno |
| R3 | Turns 11+ se reemplazan por resumen acumulativo |
| R4 | El resumen NO usa generación libre (template estructurado) |
| R5 | El resumen se actualiza cada 5 nuevos turns |
| R6 | Si la sesión tiene ≤ 3 turns, no hay compactación |

---

## 3. Especificación del resumen estructurado

### Campos del template de resumen por turno (4–10)

```
Turno {N}: {categoría} → {acción}
- Categoría: diseño | implementación | revisión | consulta | decisión | debugging
- Acción: verbo + objeto (máx 15 palabras)
```

### Campos del template de resumen acumulativo (11+)

```
─ Áreas trabajadas: {temas principales separados por coma}
─ Implementado: {cambios realizados}
─ Pendiente: {próximos pasos}
─ Decisiones activas: {decisiones vigentes}
─ Riesgos: {riesgos identificados}
```

### Ejemplo de resumen acumulativo

```
─ Áreas trabajadas: Fase F diseño, F2 budget contract, tool schemas audit
─ Implementado: F2 contract, context layers enhancement, 4 audit docs
─ Pendiente: Implementation roadmap v2, decision log update, executive summary
─ Decisiones activas: tool schemas bajo demanda (F3), session history compactado (F3)
─ Riesgos: runtime tool loading viabilidad no verificada
```

---

## 4. Estrategia de implementación (para F3)

### Opción A: Compactación en el Manager

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | El Manager mantiene el historial y lo compacta según las reglas |
| **Ventaja** | No requiere cambios en runtime ni plugin |
| **Desventaja** | Manager gasta tokens en mantener/compactar el historial |
| **Riesgo** | 🟢 Bajo — el Manager ya gestiona el contexto de la conversación |

### Opción B: Compactación vía plugin

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | Un plugin intercepta el session history antes de inyectarlo al prompt |
| **Ventaja** | Transparente para el Manager |
| **Desventaja** | Requiere desarrollo de plugin |
| **Riesgo** | 🟡 Medio — plugin puede romper pipeline |

### Opción C: Compactación por convención en el template

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | El template del system prompt define cómo debe presentarse el session history, sin código adicional |
| **Ventaja** | Simple, no requiere implementación |
| **Desventaja** | Menos flexible, depende del runtime |
| **Riesgo** | 🟢 Bajo — solo cambiar el prompt template |

### Recomendación

**Opción A para F3: Compactación en el Manager.** No requiere cambios en runtime. El Manager puede mantener el historial compactado siguiendo las reglas R1–R6. Si en el futuro se necesita más eficiencia, migrar a Opción B.

---

## 5. Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Resumen pierde detalle crítico | Baja | Medio | Últimos 3 turns crudos garantizan precisión inmediata |
| Resumen alucina información no dicha | Baja | Medio | Template estructurado (no generación libre). Solo hechos del historial |
| Mayor latencia por generación de resúmenes | Media | Bajo | Resumir asincrónicamente. Cachear resultado. Actualizar cada 5 turns |
| Manager no sigue el hilo con resumen vs history completo | Baja | Medio | Prueba QW1-T4: verificar que Manager mantiene coherencia |
| Cross-project leakage en resúmenes | Baja | Bajo | Resumen solo del proyecto canonical |

---

## 6. Pruebas recomendadas

| Test | Qué validaría | Método |
|:----:|---------------|--------|
| P1 | Resumen conserva decisiones clave del turno original | Comparar turnos originales vs resumen |
| P2 | Últimos 3 turns se mantienen intactos | Verificar contenido crudo |
| P3 | Turns 4–10 se reemplazan por resumen | Verificar formato resumido |
| P4 | Turns 11+ se reemplazan por resumen acumulativo | Verificar resumen acumulativo |
| P5 | Manager mantiene coherencia con resumen vs history completo | Tarea de prueba: "¿qué estábamos haciendo?" |
| P6 | Reducción de tokens verificable | Medir con tiktoken antes/después |

---

## 7. Integración con F2

| Componente | Alineación |
|------------|------------|
| L4 (Recent History) budget | 600–1,200 tokens en modo Normal |
| RECENT_SESSION_PACK | Formato definido en context-packs-design.md |
| QW#1 (Session history compactado) | Este documento es el diseño |
| Fase de implementación | F3 — junto con mem_context Selector |

---

## 8. Referencias

- F0: Baseline tokens → Session history (~5k–8k)
- F1: Context Inventory → Session history (#10, COMPACT_FIXED)
- F1: Quick Wins Analysis → QW#1 (Session history compactado)
- F2: Context Budget Contract → L4 budget
- F2: Context Packs Design → RECENT_SESSION_PACK

---

*Fin de session-history-compaction-audit.md — F2 COMPLETED. Diseño de compactación de session history para F3.*
