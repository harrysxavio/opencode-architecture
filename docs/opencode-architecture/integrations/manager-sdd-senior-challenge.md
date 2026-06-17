# Manager + SDD Senior Challenge

> **Estado:** ✅ CHALLENGE COMPLETED
> **Fecha:** 2026-06-17
> **Propósito:** Adversarial review en modo "senior engineer" — desafiar críticamente cada decisión arquitectónica del Manager + SDD pipeline para encontrar puntos débiles antes de considerar la fase completa.

---

## 1. Challenge 1: ¿Manager único? ¿Y si falla?

**Premisa:** Manager es el único primary orchestrator. Todo pasa por él.

**Ataque:** Single point of failure. Si el Manager tiene un bug de juicio, todo el pipeline sufre. No hay fallback ni peer review automático.

**Defensa:**
- Manager no es monolítico — delega ejecución a subagentes. Si el juicio del Manager es erróneo, un subagente especializado (sdd-verify, sdd-archive) detecta inconsistencias.
- Los quality gates (review, GPT-5.5, senior challenge) son puntos de validación obligatorios. El Manager no puede saltarlos en Medium/Large tasks.
- La memoria en Engram es cross-session — si el Manager comete un error en una sesión, la próxima sesión tiene el contexto.

**Jurado:** ⚠️ **DEBILIDAD PARCIAL.** Manager debería tener un "segundo par de ojos" automático para decisiones de clasificación (Tiny vs Medium). Propuesta: agregar una validación cruzada mínima donde, si Manager clasifica como Tiny pero el input es ambiguo, pregunte al usuario antes de saltar el pipeline.

**Acción:** Agregar regla: "Si la clasificación Tiny tiene >0.3 de ambigüedad, Manager pregunta al usuario antes de omitir SDD."

---

## 2. Challenge 2: Demasiada flexibilidad

**Premisa:** Manager puede saltar fases, usar subagentes o ejecutar inline, cambiar el orden del pipeline.

**Ataque:** Demasiada flexibilidad -> inconsistencias entre sesiones. Un Manager hoy podría saltar explore y el Manager de mañana no. El usuario recibe experiencias distintas.

**Defensa:**
- Las reglas de clasificación (Tiny/Small/Medium/Large) son fijas. Manager no las modifica.
- Para Medium/Large, los quality gates son obligatorios. Manager no puede saltarlos sin documentar el riesgo.
- El propósito de la flexibilidad es adaptarse al contexto: si ya se exploró en la sesión anterior (memoria en Engram), no tiene sentido re-explorar.

**Jurado:** ✅ **ACEPTABLE.** La flexibilidad con reglas fijas es un buen balance. La memoria en Engram previene la degradación cross-session.

---

## 3. Challenge 3: Documentos duplicados con el runtime

**Premisa:** Los documentos (estos .md) describen cómo debería funcionar el Manager + SDD pipeline.

**Ataque:** Los documentos pueden divergir del runtime real (opencode.json, AGENTS.md, skills). Si se actualiza opencode.json pero no los docs, hay mentira documental.

**Defensa:**
- Algunos documentos son observacionales (basados en runtime audit directo). Esos no pueden divergir.
- Los documentos de especificación (como este) definen el target, no el estado actual.
- El regression harness (Task 16) verifica consistencia entre documentos y runtime.

**Jurado:** ✅ **ACEPTABLE** con condición: el regression harness debe incluir tests de consistencia doc↔runtime para que la divergencia sea detectable automáticamente.

---

## 4. Challenge 4: Ponytail sin plugin no es enforceable

**Premisa:** Ponytail Code Gate es "guidance-only" en AGENTS.md.

**Ataque:** Sin plugin runtime, Ponytail depende completamente de que el Manager se acuerde de aplicarlo. No hay enforcement automático. El guidance en AGENTS.md es texto muerto si el Manager no lo lee activamente.

**Defensa:**
- Manager sí lo lee — AGENTS.md es su prompt principal. El marker `opencode-architecture:ponytail-integration` está al inicio.
- Los markers `ponytail:` en SDD Tasks son checklist obligatorio.
- Para code tasks, el Manager tiene reglas explícitas en su prompt: "Apply Ponytail when the task involves: creating code, modifying code, refactoring code..."
- La sección de SDD Tasks ya incluye `ponytail: check` como campo obligatorio.

**Jurado:** ✅ **ACEPTABLE.** El guidance en AGENTS.md + markers en SDD Tasks + reglas explícitas en prompt del Manager es suficientemente enforceable para el caso de uso. Si en el futuro se necesita enforcement automático, se instala el plugin.

---

## 5. Challenge 5: gentle-ai alignment es demasiado abstracto

**Premisa:** gentle-ai alignment lens asegura que la arquitectura no diverge de pronósticos 2026 y visión 2028.

**Ataque:** Los pronósticos 2026 y visión 2028 son documentos aspiracionales. Alinear contra ellos no es técnicamente verificable. Es filosofía, no ingeniería.

**Defensa:**
- La alineación es opcional (perfil `gentle-alignment`), no bloqueante.
- Se usa para decisiones arquitectónicas Large (cross-system, multi-agente) donde tener una lente futura es valioso para evitar caminos que no escalan en la dirección de gentle-ai.
- No hay "pasar" o "no pasar" el alignment lens — solo señalar riesgos de divergencia.

**Jurado:** ✅ **ACEPTABLE** con nota: si gentle-ai alignment se vuelve obligatorio en el futuro, necesitará criterios concretos y verificables. Por ahora, como opcional, es adecuado.

---

## 6. Challenge 6: Return envelope no verificado

**Premisa:** El return envelope (`## SUBAGENT_RESULT`) está definido pero ningún subagente lo implementa actualmente.

**Ataque:** Es un contrato no enforceable. Los subagentes SDD devuelven free text. El Manager tiene que parsear output no estructurado.

**Defensa:**
- Gap documentado en pre-runtime-kit-gap-analysis.md (G10).
- La implementación requiere solo cambio de prompt en los SKILL.md de los subagentes, no cambio de código.
- Manager puede parsear free text mientras tanto — no es ideal pero es funcional.

**Jurado:** ⚠️ **DEBILIDAD.** El gap G10 debe resolverse antes de marcar la fase como completa. Propuesta: actualizar los prompts de los subagentes SDD con la plantilla del return envelope como parte de la exportación a proyecto-opencode-mem.

**Acción:** Agregar al plan de exportación: "Actualizar prompts de subagentes SDD para incluir formato SUBAGENT_RESULT."

---

## 7. Challenge 7: Manager vs sdd-init — ¿quién inicializa?

**Premisa:** Manager orquesta el pipeline. sdd-init es el entry point SDD.

**Ataque:** ¿Quién decide si usar sdd-init? ¿Manager siempre lo invoca? ¿O Manager puede arrancar SDD sin init? Si es ambos, ¿cuándo se usa uno vs el otro?

**Defensa:**
- Manager decide según el contexto:
  - **Si el proyecto ya tiene SDD_INIT_PACKET** (sesión anterior) → Manager salta sdd-init, usa el packet existente.
  - **Si es la primera vez** o el proyecto necesita re-inicialización → Manager invoca sdd-init.
  - **Si sdd-init no está instalado** → Manager ejecuta init inline.

**Jurado:** ✅ **ACEPTABLE.** La decisión está claramente tipificada. Manager tiene reglas para cada caso.

---

## 8. Challenge 8: 21 tests manuales

**Premisa:** manager-sdd-test-plan.md define 21 tests pero todos son manuales.

**Ataque:** Tests manuales no se ejecutan. Después de dos semanas, nadie corre 21 tests manuales. El plan muere.

**Defensa:**
- Los tests más críticos (A-T1, A-T2, B-T1, B-T3, C-T6, E-T1, E-T2) pueden automatizarse con scripts PowerShell que inspeccionen opencode.json y el filesystem.
- Algunos tests (C-T1 a C-T5) requieren interacción con el LLM y son inherentemente manuales.
- El regression harness (Task 16) ya automatiza parte de la verificación de estado.

**Jurado:** ⚠️ **DEBILIDAD.** Propuesta: priorizar automatización de los 7 tests críticos como scripts ejecutables en el regression harness. Documentar los tests manuales restantes como "verificación periódica opcional."

**Acción:** Agregar scripts para tests A-T1, A-T2, B-T1, B-T3, C-T6, E-T1, E-T2 al harness.

---

## 9. Challenge 9: ¿Y si no hay GPT-5.5?

**Premisa:** El Manager usa GPT-5.5 quality gates (review, debugging).

**Ataque:** GPT-5.5 es un modelo específico. Si no está disponible (cambio de proveedor, fin de soporte, restricciones de costo), el quality gate no funciona. No hay alternativa definida.

**Defensa:**
- El Manager puede ejecutar los quality gates inline (su propio juicio).
- Judgment Day (skill) es una alternativa documentada.
- La regla dice: "If a quality gate subagent does not exist, Manager performs that phase inline."

**Jurado:** ⚠️ **DEBILIDAD PARCIAL.** La defensa existe pero no está documentada como plan de contingencia explícito. Propuesta: documentar en el quality gate: "Si GPT-5.5 no está disponible, Manager ejecuta review inline. Si Judgment Day está disponible, usarlo como alternativa preferida."

**Acción:** Agregar nota de contingencia a la sección de quality gates en el Manager prompt (AGENTS.md) o en un documento de referencia.

---

## 10. Veredicto final

| Challenge | Veredicto | Requiere acción |
|:---------:|:---------:|:---------------:|
| C1: Manager único (SPOF) | ⚠️ Parcial | Sí — regla para clasificación Tiny ambigua |
| C2: Demasiada flexibilidad | ✅ Aceptable | No |
| C3: Documentos vs runtime | ✅ Aceptable | No (harness cubre) |
| C4: Ponytail sin plugin | ✅ Aceptable | No |
| C5: gentle-ai abstracto | ✅ Aceptable | No |
| C6: Return envelope no implementado | ⚠️ Parcial | Sí — actualizar prompts SDD |
| C7: Manager vs sdd-init | ✅ Aceptable | No |
| C8: Tests manuales | ⚠️ Parcial | Sí — automatizar 7 tests |
| C9: GPT-5.5 no disponible | ⚠️ Parcial | Sí — agregar contingencia |

---

## 11. Decisiones del challenge

1. **Agregar regla de ambigüedad**: Si clasificación Tiny tiene >0.3 de ambigüedad, Manager pregunta al usuario antes de omitir SDD.
2. **Actualizar prompts SDD**: Incluir formato SUBAGENT_RESULT en los prompts de subagentes SDD como parte de exportación.
3. **Automatizar 7 tests críticos**: A-T1, A-T2, B-T1, B-T3, C-T6, E-T1, E-T2 como scripts en harness.
4. **Agregar contingencia GPT-5.5**: Documentar plan de respaldo para quality gates sin GPT-5.5.

**Estado del challenge: PASS CON WARNINGS.** Las 4 acciones pendientes no bloquean el cierre de esta fase pero deben completarse antes o durante la exportación a proyecto-opencode-mem.

---

*Fin de manager-sdd-senior-challenge.md*
