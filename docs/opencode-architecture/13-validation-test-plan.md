# Validation Test Plan — Plan de Pruebas de Validación

> Diseño de pruebas para validar el flujo real del sistema. No se ejecutan todavía (salvo comandos read-only).

## Test 1 — Request Simple (Tiny)

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

## Test 5 — Request SDD

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Diseña un cambio pequeño para registrar decisiones del Manager en un archivo de log." |
| **Objetivo** | Validar si entra o no en SDD y por qué |
| **Resultado esperado** | Manager clasifica como Small → intake + diseño + aprobación → SDD parcial (explore + propose + design) |
| **Componentes que deberían activarse** | Manager, SDD pipeline o subagentes SDD, Engram para artefactos |
| **Componentes que NO deberían activarse** | MCP, skills no relacionadas, Graphify |
| **Evidencia a capturar** | Clasificación del Manager, fases SDD ejecutadas, artefactos generados |

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

## Test 8 — Token Baseline

| Aspecto | Detalle |
|---------|---------|
| **Input** | "Dime 1 frase." |
| **Objetivo** | Medir overhead mínimo de contexto fijo |
| **Resultado esperado** | Respuesta de 1 frase. Permite medir tokens de sistema + input + output |
| **Componentes que deberían activarse** | Manager mínimo |
| **Componentes que NO deberían activarse** | Memoria, skills, MCP, subagentes |
| **Evidencia a capturar** | Tokens de sistema (si medible), tokens de input, tokens de output, tiempo |

### Criterios de aprobación
- [ ] Respuesta de exactamente 1 frase (o menos)
- [ ] Sin llamadas a herramientas
- [ ] Tiempo de respuesta < 5 segundos

---

## Resumen de pruebas

| Test | Input | Resultado esperado | Componentes activos | Componentes NO activos | Evidencia |
|------|-------|-------------------|--------------------|----------------------|-----------|
| T1: Simple | "Hola, explícame qué puedes hacer" | Respuesta directa sin memoria/skills/MCP | Manager | Engram, skills, MCP, subagentes | Tool calls, tokens, tiempo |
| T2: Memoria | "Continúa con la arquitectura..." | Recuperación de contexto previo | Manager, Memory Router | Skills no relacionadas, MCP | Query, resultados |
| T3: Documento | "Busca en docs cuál es rol de Engram" | Lectura de docs versionados | Manager, Document Retriever | MCP externo, subagentes | Archivos leídos |
| T4: MCP | "Consulta Zod con Context7" | Uso de MCP Context7 | Manager, Tool Router, Context7 | Subagentes, skills no relacionadas | Llamada MCP |
| T5: SDD | "Diseña cambio para log de decisiones" | SDD parcial con artefactos | Manager, SDD pipeline/subagentes | MCP, Graphify | Fases SDD, artefactos |
| T6: Ruidoso | Mensaje multi-tema | Separación y priorización | Manager (clasificación) | Ninguno específico | Estructura de respuesta |
| T7: Contradicción | "Cambia decisión: gentle NO primary" | Actualización de memoria con supersedes | Manager, Engram | Subagentes, MCP | Search + save + supersedes |
| T8: Baseline | "Dime 1 frase" | Overhead mínimo medible | Manager mínimo | Todo lo demás | Tokens, tiempo |

## Prioridad de ejecución

| Prioridad | Test | Razón |
|-----------|------|--------|
| P1 | T8 (Baseline) | Establece métrica de referencia |
| P1 | T1 (Simple) | Valida comportamiento base |
| P1 | T4 (MCP) | Valida tool routing crítico |
| P2 | T2 (Memoria) | Valida memoria cross-session |
| P2 | T5 (SDD) | Valida pipeline SDD |
| P3 | T3 (Documento) | Valida retrieval de docs |
| P3 | T6 (Ruidoso) | Valida clasificación |
| P3 | T7 (Contradicción) | Valida gobernanza de memoria |
