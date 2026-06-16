# Implementation Roadmap — Fase F

**Propósito:** Definir la secuencia de implementación de Fase F, desde la auditoría inicial hasta el rollout controlado. Cada fase tiene criterios de entrada, salida y aprobación.

---

## Secuencia general

```
F0 ─► F1 ─► F2 ─► F3 ─► F4 ─► F5 ─► F6
         ║      ║      ║      ║      ║
         ▼      ▼      ▼      ▼      ▼
     Context  Budget  Selector  Packs  Regression
     Inventory Contract Design   Design Plan + Rollout
```

Cada fase requiere aprobación antes de pasar a la siguiente.

---

## F0 — Token Audit Baseline

**Estado:** 📋 PLANIFICADO  
**Dependencias:** Ninguna  
**Requiere aprobación:** No (es diagnóstico)

### Objetivo
Medir el baseline real de tokens del contexto actual, documentar de dónde vienen los ~40k y clasificar fuentes.

### Tareas
1. Medir tokens del system prompt actual con tiktoken.
2. Desglosar por sección (protocol, skills, tools, etc.).
3. Clasificar fuentes como fijo/dinámico/duplicado.
4. Identificar quick wins prioritarios.
5. Documentar en `baseline-tokens.md`.

### Criterios de salida
- [ ] Baseline medido y documentado.
- [ ] Fuentes clasificadas.
- [ ] Quick wins identificados.

### Tiempo estimado
1–2 sesiones de análisis.

---

## F1 — Context Inventory

**Estado:** 📋 PLANIFICADO  
**Dependencias:** F0 completada  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Inventariar todas las fuentes de contexto del sistema, identificar críticas, redundantes y clasificarlas por riesgo y utilidad.

### Tareas
1. Listar todas las fuentes de contexto que entran al prompt.
2. Para cada fuente: prioridad, riesgo si falta, riesgo si sobra.
3. Identificar fuentes redundantes (misma info desde 2+ lugares).
4. Clasificar: siempre necesaria / normalmente necesaria / bajo demanda.
5. Documentar en `context-inventory.md`.

### Criterios de salida
- [ ] Inventario completo documentado.
- [ ] Fuentes clasificadas por prioridad.
- [ ] Redundancias identificadas.

### Tiempo estimado
1 sesión de análisis.

---

## F2 — Context Budget Contract

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F0 + F1 completadas  
**Requiere aprobación:** Sí (Manager + usuario)

### Objetivo
Definir el presupuesto de tokens por capa y por modo, con reglas de expansión.

### Tareas
1. Refinar budgets de `context-budget-contract.md` con datos reales de F0.
2. Definir reglas de expansión automática vs justificada.
3. Definir qué capas son obligatorias vs opcionales.
4. Obtener aprobación de budgets y modos.

### Criterios de salida
- [ ] Budgets validados con datos F0.
- [ ] Modos de operación aprobados.
- [ ] Reglas de expansión definidas.

### Tiempo estimado
1 sesión de diseño + aprobación.

---

## F3 — mem_context Selector Design & Implementation

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F2 aprobada  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Diseñar e implementar el selector de memorias con ranking, filtro, deduplicación y top-k.

### Tareas
1. Implementar pipeline de selección (ranking, score, filtro).
2. Implementar deduplicación semántica.
3. Implementar top-k por modo.
4. Implementar fallback L5.
5. Test unitarios del selector.
6. Integrar con `mem_context` o reemplazar su uso.

### Criterios de salida
- [ ] Selector implementado y testeado.
- [ ] Ranking funciona con datos reales de Engram.
- [ ] Deduplicación no elimina observaciones únicas.
- [ ] Top-k respeta el modo actual.

### Tiempo estimado
2–3 sesiones de implementación + tests.

---

## F4 — Context Packs Design & Implementation

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F3 implementada  
**Requiere aprobación:** Sí (Manager + usuario)

### Objetivo
Diseñar e implementar los context packs como unidades intercambiables de contexto.

### Tareas
1. Implementar formato de cada pack.
2. Implementar ensamblaje por modo.
3. Integrar con el pipeline de contexto del Manager.
4. Test de integración: cada modo produce los packs correctos.

### Criterios de salida
- [ ] Packs implementados para todos los modos.
- [ ] Ensamblaje correcto verificado.
- [ ] Budgets por pack respetados.

### Tiempo estimado
2–3 sesiones de implementación + tests.

---

## F5 — Regression Plan Execution

**Estado:** 📋 DISEÑADO (este documento)  
**Dependencias:** F3 + F4 implementadas  
**Requiere aprobación:** Sí (Manager)

### Objetivo
Ejecutar el regression plan completo para verificar que nada se rompió.

### Tareas
1. Ejecutar E6B (T1-T7).
2. Ejecutar Suite F (F1-F6).
3. Ejecutar Token Budget tests (B1-B6).
4. Ejecutar Quality tests (Q1-Q5).
5. Ejecutar Security tests (S1-S3).
6. Ejecutar Regression E2E.

### Criterios de salida
- [ ] Todos los gates PASS.
- [ ] Sin regresiones.
- [ ] Documentación de resultados.

### Tiempo estimado
2–3 sesiones de validación.

---

## F6 — Rollout Controlado

**Estado:** 📋 PLANIFICADO  
**Dependencias:** F5 todos PASS  
**Requiere aprobación:** Sí (Manager + usuario explícito)

### Objetivo
Implementar los cambios en producción (entorno real de OpenCode).

### Tareas
1. Feature flag para desactivar reducción si es necesario.
2. Implementación incremental:
   - Día 1: Solo modo Normal (default).
   - Día 3: Habilitar modo Simple.
   - Día 5: Habilitar modo Arquitectura.
   - Día 7: Habilitar expansión controlada.
3. Monitoreo de KPIs.
4. Rollback plan listo.

### Criterios de salida
- [ ] Feature flag implementado.
- [ ] Rollout progresivo completado.
- [ ] Monitoreo activo.
- [ ] Sin incidentes.

### Tiempo estimado
1 semana con rollout progresivo.

---

## Resumen de fases

| Fase | Nombre | Estado | Aprobación | Depende de |
|:----:|--------|:------:|:----------:|:----------:|
| F0 | Token Audit Baseline | 📋 Planificado | No aplica | Ninguna |
| F1 | Context Inventory | 📋 Planificado | Manager | F0 |
| F2 | Context Budget Contract | 📋 Diseñado | Manager + Usuario | F0 + F1 |
| F3 | mem_context Selector | 📋 Diseñado | Manager | F2 |
| F4 | Context Packs | 📋 Diseñado | Manager + Usuario | F3 |
| F5 | Regression Plan | 📋 Diseñado | Manager | F3 + F4 |
| F6 | Rollout Controlado | 📋 Planificado | Manager + Usuario | F5 |

## Reglas de aprobación

- **Manager**: puede aprobar fases técnicas (F1, F3, F5).
- **Manager + Usuario**: requiere aprobación del usuario para cambios que afectan presupuesto, packs o rollout (F2, F4, F6).
- **Sin aprobación**: no avanzar a la siguiente fase.

## Rollback

Si en cualquier fase posterior a F3 se detecta:

1. Degradación de calidad del agente.
2. Violación de budgets.
3. Regresiones en E6B o Suite F.
4. Exposición de secretos.
5. Mezcla cross-project no controlada.

**Acción inmediata:**
1. Desactivar feature flag (F6) o revertir cambio.
2. Volver al estado pre-F3 (contexto completo).
3. Documentar hallazgo.
4. Re-planificar con la lección aprendida.

---

_Fin de implementation-roadmap.md_
