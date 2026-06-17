# Manager Extension Decision Package

> **Estado:** ✅ COMPLETED — Pendiente de aprobación ejecutiva
> **Fecha:** 2026-06-17
> **Propósito:** Recomendación ejecutiva final sobre gentle-ai y Ponytail en la arquitectura OpenCode, como paso previo al repo `proyecto-opencode-mem`.

---

## Parte 1: gentle-ai

### Recomendación

**Mantener gentle-ai como alignment-only.** No integrar en runtime. No incluir en perfil `full`. No como dependencia del Manager.

### Alternativas consideradas

| Alternativa | Veredicto | Razón |
|-------------|:---------:|-------|
| **A: alignment-only** (mantener actual) | ✅ **RECOMENDADO** | Sin riesgo, sin overhead, sin dependencia externa |
| **B: Integración runtime parcial** (skill opcional) | ❌ No | Crea dependencia sin beneficio claro. gentle-ai no aporta funcionalidad que OpenCode no tenga |
| **C: gentle-ai como subagente SDD** | ❌ No | Ya se decidió que Manager controla SDD. gentle-orchestrator ya es subagente pero no se usa |
| **D: Absorber patrones de gentle-ai** | ✅ Ya hecho | Manager ya implementa SDD pipeline, clasificación, quality gates |

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Se crea dependencia inadvertida | Baja | Medio | Tests GA-B1 a GA-B6 |
| Se reactiva plan de transición sin considerar Fase F | Baja | Medio | Este documento + gentle-ai-alignment.md |
| gentle-ai cambia y rompe compatibilidad | Baja | Bajo | Sin integración, no hay compatibilidad que romper |

### Decisión requerida

¿Se mantiene gentle-ai como **alignment-only** sin runtime?

- [ ] Sí (recomendado)
- [ ] No, integrar como: _________

### Próxima acción

Si se aprueba:
- Mantener tests GA-B1 a GA-B7 en regression harness
- No modificar política de alineación
- Continuar con `proyecto-opencode-mem` sin gentle-ai runtime

Si no se aprueba:
- Documentar nueva decisión en decision-log.md
- Crear ADR para integración gentle-ai
- Definir contrato, adapter y tests

---

## Parte 2: Ponytail

### Recomendación

**Implementar Ponytail como Code Gate (Opción B/C)**, integrado en AGENTS.md como fase opcional entre SDD Design y SDD Tasks, activo solo para code tasks. No always-on. No ultra default.

### Alternativas consideradas

| Opción | Descripción | Veredicto | Riesgo |
|--------|-------------|:---------:|:------:|
| **A: Plugin-only** | Ponytail plugin influye por system.transform, Manager no lo menciona | ❌ No recomendada | Bajo riesgo, baja gobernanza. El plugin ya influye sin que Manager sepa |
| **B: AGENTS.md lite integration** (RECOMENDADA) | Manager sabe cuándo usar Ponytail. Code tasks only | ✅ **RECOMENDADA** | Bajo/medio — la más balanceada |
| **C: Code Gate full** | Gate formal entre Design y Tasks. `ponytail: check` por tarea | ⚠️ Alternativa viable | Medio — más estructura, más overhead |
| **D: Always-on global** | Ponytail activo para todo | ❌ No recomendada | Alto — contradice Fase F, infla contexto |
| **E: Ultra manual** | Solo bajo solicitud explícita | ⚠️ Válida como complemento | Bajo — pero no aprovecha el valor en code tasks |

**Recomendación específica: Opción B (lite integration)** con posibilidad de escalar a Opción C si se demuestra valor.

### Decisión base evaluada: ¿Ponytail debe ser "code-task default", no "global always-on"?

| Criterio | ¿Cumple? | Explicación |
|----------|:--------:|-------------|
| Activo cuando crea/modifica/revisa código | ✅ Sí | Code task → Ponytail activado |
| No activo para preguntas conceptuales | ✅ Sí | Non-code task → sin Ponytail |
| No activo para memoria/Engram sin código | ✅ Sí | Memoria sin código → sin Ponytail |
| No activo para documentación pura | ✅ Sí | Docs sin código → sin Ponytail |
| No elimina validación, seguridad, accesibilidad | ✅ Sí | Exclusiones explícitas documentadas |
| Ofrece auditoría post-implementación en tareas Large | ✅ Sí | ponytail-audit opcional en Large |

**Validación:** El criterio recomendado es correcto. Ponytail debe ser "code-task default".

### Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:-----------:|:-------:|------------|
| Overhead de contexto en code tasks | Media | Bajo | ~200-400 tokens/turno. Aceptable si reduce over-engineering |
| Falsos negativos en código crítico | Baja | Alto | Exclusiones explícitas + Code Review + Completion Contract |
| Code task mal clasificada | Baja | Bajo | Manager ya clasifica Tiny/Small/Medium/Large |
| Ponytail cambia upstream | Baja | Medio | Integration es documental, no plugin. Fácil de actualizar |
| Conflicto con Fase F | Baja | Medio | Code-gate solo, no always-on. No contradice reducción de tokens |

### Decisión requerida

¿Se implementa Ponytail Code Gate (Opción B/C) en AGENTS.md?

- [ ] Sí, como lite integration (Opción B — recomendada)
- [ ] Sí, como Code Gate full (Opción C)
- [ ] Sí, pero solo como auditoría post-implementación
- [ ] No, mantener sin integración

### Próxima acción

Si se aprueba (Opción B):
1. Aplicar marker `<!-- opencode-architecture:ponytail-integration -->` en AGENTS.md
2. Agregar reglas de activación (code-task vs non-code)
3. Agregar Completion Contract section
4. Documentar en Manager Protocol
5. Ejecutar tests PT-I3 a PT-I12

Si no se aprueba:
- Mantener propuesta documentada para referencia futura
- No implementar cambios runtime

---

## Parte 3: Tabla ejecutiva

| Integración | Recomendación | Estado sugerido | Riesgo | ¿Implementar ahora? |
|-------------|---------------|-----------------|:------:|:-------------------:|
| **gentle-ai** | alignment-only, sin runtime | ✅ Mantener actual | 🟢 Bajo | ❌ No |
| **Ponytail** | Code Gate (Opción B) entre SDD Design y SDD Tasks | ⏸️ Propuesta pendiente | 🟡 Medio | ⏸️ Pendiente de aprobación |
| **Manager Protocol update** | Agregar sección Ponytail + Completion Contract | ⏸️ Propuesta | 🟢 Bajo | ⏸️ Pendiente de aprobación |
| **gentle-ai boundary tests** | Agregar GA-B1 a GA-B7 al regression harness | ✅ Diseñado | 🟢 Bajo | ✅ Sí (no tocan runtime) |
| **Ponytail integration tests** | PT-I1 a PT-I12 | ✅ Diseñado | 🟢 Bajo | ⏸️ Pendiente de aprobación |
| **Perfiles exportables** | full=no gentle-ai, gentle-alignment=opcional, ponytail-code-gate=opcional | ✅ Plan listo | 🟢 Bajo | ✅ Sí (documentación) |

---

## Parte 4: Senior Challenge

> Antes del veredicto final, cuestionar cada dimensión.

### Desde usuario: ¿Esto ayuda a tener el mismo OpenCode en cualquier computador?

**gentle-ai:** No. Mantenerlo alignment-only no afecta la portabilidad. No es un componente que deba instalarse.

**Ponytail:** Sí, si se implementa como documentación en AGENTS.md (no como plugin). Un AGENTS.md con reglas de activación es portable. Un plugin `.mjs` requiere instalación adicional.

**Decisión:** La propuesta de integración de Ponytail es documental, no requiere plugin. Esto maximiza portabilidad.

### Desde arquitectura: ¿Estamos mezclando sistemas que deberían seguir separados?

**gentle-ai:** Ya están separados. La auditoría confirma que no hay mezcla.

**Ponytail:** Potencial riesgo si se integra como plugin. La propuesta lo mantiene separado: Manager define reglas de activación, Ponytail es un gate controlado, no un sustituto.

**Decisión:** Mantener sistemas separados. Ponytail como gate, no como reemplazo.

### Desde seguridad: ¿Hay riesgo de publicar rutas, secretos o DB?

**Esta auditoría:** No toca runtime. No expone secretos. No modifica DB. No modifica AGENTS.md real.

**gentle-ai:** Sin riesgo — no hay datos de gentle-ai en el repo que puedan exponerse.

**Ponytail:** Sin riesgo — la propuesta es documental, no incluye plugins ni configuraciones reales.

### Desde tokens: ¿Ponytail always-on aumenta contexto innecesario?

**Sí.** Por eso la recomendación es **code-task default**, no always-on. La propuesta explicita:
- ~200-400 tokens/turno solo en code tasks
- Zero overhead en non-code tasks
- El usuario puede elegir `off` en cualquier momento

### Desde calidad: ¿Ponytail puede eliminar demasiado?

**Riesgo reconocido.** Mitigado por:
1. Exclusiones explícitas (8 protecciones que nunca se simplifican)
2. Code Review + ponytail-review verifican que no se eliminó lo incorrecto
3. Completion Contract registra todas las simplificaciones
4. El mode `lite` limita el alcance

### Desde mantenimiento: ¿Será fácil explicar esto en el repo nuevo?

**Sí.** La documentación está diseñada para ser auto-contenida:
- `integrations/README.md` da la vista general
- Cada integración tiene su propio documento de auditoría
- La propuesta de Ponytail incluye diff conceptual y flujo Mermaid
- El plan de exportación define exactamente qué va a cada perfil

### Desde futuro repo: ¿Qué perfil instala qué?

| Perfil | ¿Qué instala en runtime? |
|--------|--------------------------|
| `core` | Manager Protocol + Engram + Noise Gate |
| `full` | core + SDD subagents + Design Skills + harness |
| `gentle-alignment` | ❌ Nada runtime — solo documentación |
| `ponytail-code-gate` | ❌ Nada runtime por ahora — solo documentación. Si se aprueba: guidance en AGENTS.md |
| `ultra` | full + guidance de Ponytail |

### Desde Manager: ¿El Manager queda más claro o más cargado?

**Más claro.** La integración de Ponytail está definida como un gate opcional, no como modificación del flujo principal. El Manager:
- Sigue clasificando tareas (Tiny/Small/Medium/Large)
- Decide si activar Ponytail según si es code-task
- Controla el gate, no es controlado por él
- El Completion Contract se enriquece sin volverse complejo

---

## Veredicto final

| Dimensión | Estado |
|-----------|--------|
| gentle-ai boundary | ✅ Documentado y validado |
| Ponytail audit | ✅ Documentado |
| Propuesta Ponytail | ✅ Creada pero no aplicada |
| Tests gentle-ai | ✅ Diseñados (GA-B1 a GA-B7) |
| Tests Ponytail | ✅ Diseñados (PT-I1 a PT-I12) |
| Export plan | ✅ Actualizado |
| Decisión ejecutiva | ✅ Creada |
| Runtime changes | ❌ No realizados |
| AGENTS.md real modificado | ❌ No |
| opencode.json real modificado | ❌ No |
| DB/schema changes | ❌ No |
| gentle-ai changes | ❌ No |
| Ponytail changes | ❌ No |

**MANAGER EXTENSIONS AUDIT PASS**

### Próximos pasos

1. **Aprobación del usuario** para implementar Ponytail en AGENTS.md
2. **Implementación del marker** `<!-- opencode-architecture:ponytail-integration -->` en AGENTS.md (solo si se aprueba)
3. **Agregar tests GA-B1 a GA-B7** al regression harness existente
4. **Continuar con `proyecto-opencode-mem`** usando el plan de exportación
5. **No integrar gentle-ai runtime** — mantener alignment-only

---

*Fin de manager-extension-decision-package.md*
