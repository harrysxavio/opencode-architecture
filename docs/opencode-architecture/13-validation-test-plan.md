# Validation Test Plan — Plan de Pruebas de Validación

> Diseño de pruebas para validar el flujo real del sistema.
>
> **Estado en Fase B1:**
> - T1 (Primary real): ✅ **VALIDADO** — Manager responde por defecto (observación directa durante B1). Pendiente ejecución con input exacto para reporte completo.
> - T8 (Token baseline): ⚠️ **PREPARADO** — Reporte y metodología listos. Pendiente ejecución con input exacto "Dime 1 frase".
> - T5 (SDD routing): ✅ **EJECUTADO** — Routing diseñado documentado en baseline T5.
>
> Tests T2-T7 permanecen sin ejecutar (Fase C).

## Test 1 — Request Simple (Tiny) — ✅ RESULTADO DISPONIBLE

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Hola, explícame qué puedes hacer." |
| **Objetivo** | Validar que no se active memoria, SDD, MCP ni subagentes innecesarios |
| **Resultado esperado** | Respuesta directa del Manager. Sin llamadas a mem_search/save, sin skills cargadas, sin MCP, sin subagentes |
| **Componentes que deberían activarse** | Manager (routing), tools nativas básicas |
| **Componentes que NO deberían activarse** | Engram (mem_search), skills, SDD pipeline, MCP servers, subagentes especializados |
| **Evidencia a capturar** | Tool calls registradas, tokens totales, tiempo de respuesta |

### Criterios de aprobación
- [ ] Respuesta recibida en < 10 segundos
- [ ] Ninguna llamada a `mem_search` o `mem_save`
- [ ] Ninguna llamada a `skill()` tool
- [ ] Ninguna llamada MCP
- [ ] Tokens totales < 30,000 (o medición baseline)

### Resultado B1
- ✅ **Agente que responde: Manager** — VALIDADO por observación directa durante Fase B1.
- ⚠️ Ejecución con input exacto ("Hola, explícame en una frase qué puedes hacer") pendiente.
- 📋 Ver baseline completo en `baselines/T1-primary-baseline.md`.

---

## Test 2 — Request con Memoria Útil

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Continúa con la arquitectura OpenCode que estábamos revisando." |
| **Objetivo** | Validar recuperación precisa de memoria/documentos |
| **Resultado esperado** | Manager llama a `mem_context` o `mem_search` para recuperar contexto de sesiones previas |
| **Componentes que deberían activarse** | Manager, Memory Router (mem_context/mem_search), lectura de docs si es necesario |
| **Componentes que NO deberían activarse** | Skills no relacionadas, MCP innecesarios, subagentes |
| **Evidencia a capturar** | Query de mem_search, resultados obtenidos, tiempo |

### Precondición
- Sesión previa con trabajo sobre arquitectura OpenCode
- `mem_session_summary` ejecutado exitosamente al cerrar esa sesión

### Criterios de aprobación
- [ ] `mem_context` o `mem_search` llamado con query relevante
- [ ] Resultados relevantes recuperados
- [ ] Respuesta coherente con el trabajo previo

---

## Test 3 — Request con Documento

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Busca en la documentación de arquitectura actual cuál es el rol de Engram." |
| **Objetivo** | Validar uso de docs versionados antes de memoria difusa |
| **Resultado esperado** | Manager lee `docs/opencode-architecture/` en lugar de (o antes de) buscar en memoria Engram |
| **Componentes que deberían activarse** | Manager, Document Retriever (read tool), lectura de archivos .md |
| **Componentes que NO deberían activarse** | MCP Context7 (no es doc externa), subagentes, SDD |
| **Evidencia a capturar** | Archivos leídos, orden de lectura, contenido recuperado |

### Criterios de aprobación
- [ ] `read` tool llamado sobre archivos en `docs/opencode-architecture/`
- [ ] Respuesta cita la fuente documental
- [ ] No se usó MCP para buscar documentación externa

---

## Test 4 — Request con MCP

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Consulta documentación actualizada de la librería Zod usando Context7." |
| **Objetivo** | Validar tool routing a MCP |
| **Resultado esperado** | Manager usa Context7 MCP para obtener documentación actualizada de Zod |
| **Componentes que deberían activarse** | Manager, Tool/MCP Router, Context7 MCP |
| **Componentes que NO deberían activarse** | Subagentes SDD, skills no relacionadas, memoria Engram |
| **Evidencia a capturar** | Llamada a Context7, resultado, tiempo de respuesta |

### Criterios de aprobación
- [ ] Context7 MCP invocado
- [ ] Documentación de Zod devuelta
- [ ] Respuesta incluye información actualizada

---

## Test 5 — Request SDD — ✅ DISEÑO DOCUMENTADO

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Diseña un cambio pequeño para registrar decisiones del Manager en un archivo de log." |
| **Objetivo** | Validar si entra o no en SDD y por qué |
| **Resultado esperado** | Manager clasifica como Small/Medium → decide inline vs SDD según riesgo y archivos afectados |
| **Componentes que deberían activarse** | Manager, SDD pipeline o inline execution |
| **Componentes que NO deberían activarse** | MCP, skills no relacionadas, Graphify |
| **Evidencia a capturar** | Clasificación del Manager, fases SDD ejecutadas o decisión de inline |

### Resultado B1
- ✅ **Routing SDD diseñado y documentado** en `baselines/T5-sdd-routing-baseline.md`.
- Manager clasifica, decide inline vs SDD Pipeline, invoca gentle-orch cuando corresponde (ADR-003).
- ⚠️ Pendiente ejecución end-to-end con cambio real (Fase C).

### Criterios de aprobación
- [ ] Manager clasifica como Small o Medium
- [ ] Fases SDD ejecutadas secuencialmente
- [ ] Artefactos SDD persistidos (Engram o filesystem)

---

## Test 6 — Request Ruidoso

| Aspecto | Detalle |
|---------|---------|
| **Input** | Un mensaje largo con varias ideas mezcladas (pregunta de código + feature request + bug report + pregunta sobre arquitectura) |
| **Objetivo** | Validar limpieza, clasificación y priorización |
| **Resultado esperado** | Manager separa los temas, clasifica cada uno, propone orden de atención o pide clarificación |
| **Componentes que deberían activarse** | Manager (clasificación), posiblemente subagentes SDD para la feature, posiblemente docs para la pregunta de arquitectura |
| **Componentes que NO deberían activarse** | Ninguno específicamente prohibido, pero debe priorizar |
| **Evidencia a capturar** | Cómo separa los temas, qué orden propone, si pide clarificación |

### Criterios de aprobación
- [ ] Manager identifica múltiples temas en el input
- [ ] Propone orden o pide clarificación
- [ ] No intenta resolver todo en una sola respuesta sin estructura

---

## Test 7 — Contradicción de Memoria

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Cambia la decisión anterior: ahora quiero que gentle-orchestrator NO sea primary." |
| **Objetivo** | Validar actualización/invalidation de memoria |
| **Resultado esperado** | Manager guarda nueva decisión como preferencia del usuario, marcando la anterior como superseded |
| **Componentes que deberían activarse** | Manager, Engram (mem_save con supersedes), posiblemente mem_search para encontrar la decisión anterior |
| **Componentes que NO deberían activarse** | Subagentes SDD, MCP, skills |
| **Evidencia a capturar** | Query de búsqueda de decisión anterior, save con supersedes, confirmación |

### Precondición
- Decisión anterior guardada en Engram sobre el rol de gentle-orchestrator

### Criterios de aprobación
- [ ] Busca la decisión anterior en Engram
- [ ] Guarda nueva decisión referenciando la anterior
- [ ] Confirma el cambio al usuario

---

## Test 8 — Token Baseline — ⚠️ PREPARADO

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Dime 1 frase." |
| **Objetivo** | Medir overhead mínimo de contexto fijo |
| **Resultado esperado** | Respuesta de 1 frase. Permite medir tokens de sistema + input + output |
| **Componentes que deberían activarse** | Manager mínimo |
| **Componentes que NO deberían activarse** | Memoria, skills, MCP, subagentes |
| **Evidencia a capturar** | Tokens de sistema (si medible), tokens de input, tokens de output, tiempo |

### Estado B1
- ⚠️ **Metodología y reporte preparados** en `baselines/T8-token-baseline.md`.
- Pendiente ejecución con input exacto "Dime 1 frase" — requiere sesión limpia o request aislado.
- Estimación actual (INFERIDA): ~18,500–22,000 tokens fijos.

### Criterios de aprobación
- [ ] Respuesta de exactamente 1 frase (o menos)
- [ ] Sin llamadas a herramientas
- [ ] Tiempo de respuesta < 5 segundos

---

## Resumen de pruebas — Estado Fase B1

| Test | Input | Estado | Resultado | Reporte |
|------|-------|--------|-----------|---------|
| T1: Primary real | "Hola, explícame qué puedes hacer" | ✅ **VALIDADO** | Manager responde por defecto | `baselines/T1-primary-baseline.md` |
| T5: SDD routing | Pregunta sobre routing read-only | ✅ **EJECUTADO** | Routing SDD diseñado y documentado | `baselines/T5-sdd-routing-baseline.md` |
| T8: Token baseline | "Dime 1 frase" | ⚠️ **PREPARADO** | Metodología lista, pendiente input exacto | `baselines/T8-token-baseline.md` |
| T2: Memoria | "Continúa con la arquitectura..." | ⏳ Pendiente (Fase C) | — | — |
| T3: Documento | "Busca en docs cuál es rol de Engram" | ⏳ Pendiente (Fase C) | — | — |
| T4: MCP | "Consulta Zod con Context7" | ⏳ Pendiente (Fase C) | — | — |
| T6: Ruidoso | Mensaje multi-tema | ⏳ Pendiente (Fase C) | — | — |
| T7: Contradicción | "Cambia decisión: gentle NO primary" | ⏳ Pendiente (Fase C) | — | — |

## Prioridad de ejecución actualizada

| Prioridad | Test | Estado | Siguiente acción |
|-----------|------|--------|-----------------|
| P1 | T8 (Baseline) | ⚠️ Preparado | Usuario envía "Dime 1 frase" |
| P1 | T1 (Primary) | ✅ Validado | Ejecutar con input exacto para reporte completo |
| P1 | T4 (MCP) | ⏳ Pendiente | Fase C |
| P2 | T2 (Memoria) | ⏳ Pendiente | Fase C |
| P2 | T5 (SDD) | ✅ Diseñado | Ejecutar end-to-end con cambio real en Fase C |
| P3 | T3 (Documento) | ⏳ Pendiente | Fase C |
| P3 | T6 (Ruidoso) | ⏳ Pendiente | Fase C |
| P3 | T7 (Contradicción) | ⏳ Pendiente | Fase C |
