# Ponytail Integration Test Plan

> **Estado:** ✅ DISEÑADO — No implementado
> **Fecha:** 2026-06-17
> **Propósito:** Tests para validar la integración de Ponytail en el Manager Protocol, una vez aprobada.

---

## Principios

1. **Read-only preferido:** Tests no modifican configuración runtime salvo para validar integración.
2. **Ejecutables post-integracion:** Verifican que la integración funciona correctamente.
3. **Regression-safe:** Fallan si cambios futuros rompen la integración.
4. **Portables:** PowerShell scripts compatibles con CI.

---

## Test PT-I1: Ponytail plugin path discoverable

**ID:** PT-I1
**Propósito:** Verificar que el plugin Ponytail está instalado en la ubicación esperada.
**Precondición:** Instalación completada.
**Pasos:**
1. Verificar que `.opencode/plugins/ponytail.mjs` existe en la ruta configurada.
2. Verificar que el archivo es un módulo JavaScript válido.

**Criterio de éxito:** Plugin existe y es válido.

---

## Test PT-I2: Ponytail skills discoverable

**ID:** PT-I2
**Propósito:** Verificar que los skills de Ponytail están disponibles.
**Precondición:** Instalación completada.
**Pasos:**
1. Verificar que `ponytail-review` skill existe en skills path.
2. Verificar que el skill tiene frontmatter YAML válido.
3. Verificar que la descripción incluye `Trigger:`.

**Criterio de éxito:** Skills de Ponytail instalados y válidos.

---

## Test PT-I3: Manager integration text existe solo si se aprueba

**ID:** PT-I3
**Propósito:** Verificar que el marker de integración en AGENTS.md existe solo después de aprobación.
**Precondición:** AGENTS.md accesible.
**Pasos:**
1. Buscar `<!-- opencode-architecture:ponytail-integration -->` en AGENTS.md.
2. Si existe y no hubo aprobación documentada → FAIL.
3. Si existe y hubo aprobación documentada → PASS.

**Criterio de éxito:** Marker presente solo con aprobación documentada.

---

## Test PT-I4: Ponytail code gate se activa para code tasks

**ID:** PT-I4
**Propósito:** Verificar que el code gate se activa cuando corresponde.
**Precondición:** Integración aprobada y documentada en AGENTS.md.
**Pasos:**
1. Simular code task (creación de archivo, modificación).
2. Verificar que el Manager activa Ponytail Gate.
3. Verificar que el Completion Contract incluye sección Ponytail.

**Criterio de éxito:** Code task → Ponytail activado.

**Comando (conceptual):**
```powershell
# Verify AGENTS.md contains Ponytail section
$agents = Get-Content "$env:USERPROFILE\.config\opencode\AGENTS.md" -Raw
if ($agents -match "Ponytail Code Gate") {
    Write-Host "PASS: Ponytail section present in AGENTS.md"
} else {
    throw "Ponytail section not found in AGENTS.md"
}
```

---

## Test PT-I5: Ponytail code gate se omite para non-code tasks

**ID:** PT-I5
**Propósito:** Verificar que el code gate se omite correctamente.
**Precondición:** Integración aprobada.
**Pasos:**
1. Simular non-code task (documentación, búsqueda, memoria).
2. Verificar que el Manager NO activa Ponytail.
3. Verificar que el Completion Contract NO incluye sección Ponytail (o dice "not applicable").

**Criterio de éxito:** Non-code task → Ponytail omitido.

---

## Test PT-I6: Completion Contract incluye sección Ponytail cuando aplica

**ID:** PT-I6
**Propósito:** Verificar que el Completion Contract se actualiza correctamente.
**Precondición:** Integración aprobada.
**Pasos:**
1. Completar una code task con Ponytail activado.
2. Verificar que el reporte final incluye:
   - Activation status
   - Mode
   - Simplifications list
   - Exceptions justified
   - Markers count

**Criterio de éxito:** Sección Ponytail completa en Completion Contract.

---

## Test PT-I7: No se eliminan seguridad/accesibilidad/validación

**ID:** PT-I7
**Propósito:** Verificar que las exclusiones de seguridad se respetan.
**Precondición:** Integración aprobada.
**Pasos:**
1. Identificar tareas que involucran trust boundaries, auth, accesibilidad.
2. Verificar que Ponytail no simplifica esas áreas.
3. Verificar que Code Review refuerza estas exclusiones.

**Criterio de éxito:** Exclusiones preservadas en todo momento.

---

## Test PT-I8: ponytail-review se propone en Code Review

**ID:** PT-I8
**Propósito:** Verificar que el Code Review del Manager incluye ponytail-review.
**Precondición:** Integración aprobada.
**Pasos:**
1. Revisar la sección de Code Review en AGENTS.md.
2. Verificar que menciona ponytail-review como opción.
3. Verificar que no reemplaza a Judgment Day ni GPT-5.5 review.

**Criterio de éxito:** ponytail-review es opcional y complementario.

---

## Test PT-I9: ponytail-audit solo en tareas Large o por solicitud

**ID:** PT-I9
**Propósito:** Verificar que la auditoría completa no es default.
**Precondición:** Integración aprobada.
**Pasos:**
1. Revisar reglas de activación en AGENTS.md.
2. Verificar que `ponytail-audit` se activa solo en Large tasks o por solicitud explícita.
3. Verificar que `ultra` mode no es default.

**Criterio de éxito:** Audit no es default. Ultra no es default.

---

## Test PT-I10: Modo default recomendado no es ultra

**ID:** PT-I10
**Propósito:** Verificar que el modo ultra no es el default.
**Precondición:** Integración aprobada.
**Pasos:**
1. Revisar reglas de activación.
2. Verificar que el modo default es `full` o `lite`, nunca `ultra`.

**Criterio de éxito:** Default mode ≠ ultra.

---

## Test PT-I11: El plan documenta costo/context tradeoff

**ID:** PT-I11
**Propósito:** Verificar que la documentación incluye análisis de costo de contexto.
**Precondición:** Documento de integración existe.
**Pasos:**
1. Verificar que la propuesta incluye sección de impacto en tokens.
2. Verificar que cuantifica el overhead (~200-400 tokens/turno).
3. Verificar que recomienda code-task only para mitigar.

**Criterio de éxito:** Tradeoff documentado.

---

## Test PT-I12: La integración es reversible

**ID:** PT-I12
**Propósito:** Verificar que la integración puede revertirse sin pérdida.
**Precondición:** Integración aprobada.
**Pasos:**
1. Verificar que existe rollback plan documentado.
2. Verificar que no hay dependencia irreversible (DB changes, data migration).
3. Verificar que revertir el marker en AGENTS.md restaura comportamiento anterior.

**Criterio de éxito:** Rollback documentado y posible.

---

## Matriz de cobertura

| Test | ID | Prioridad | Automatable | CI-ready |
|------|:--:|:---------:|:-----------:|:--------:|
| Plugin path discoverable | PT-I1 | 🟡 Media | ✅ Sí | ✅ Sí |
| Skills discoverable | PT-I2 | 🟡 Media | ✅ Sí | ✅ Sí |
| Integration text con aprobación | PT-I3 | 🔴 Alta | ✅ Sí | ✅ Sí |
| Code gate activo en code tasks | PT-I4 | 🔴 Alta | ⚠️ Parcial | ❌ Requiere simulacion |
| Code gate omitido en non-code | PT-I5 | 🔴 Alta | ⚠️ Parcial | ❌ Requiere simulacion |
| Completion Contract actualizado | PT-I6 | 🟡 Media | ⚠️ Parcial | ❌ Requiere simulacion |
| Exclusiones de seguridad | PT-I7 | 🔴 Alta | ⚠️ Parcial | ❌ Requiere revision |
| ponytail-review en Code Review | PT-I8 | 🟡 Media | ✅ Sí | ✅ Sí |
| ponytail-audit solo Large | PT-I9 | 🟡 Media | ✅ Sí | ✅ Sí |
| Default mode ≠ ultra | PT-I10 | 🟡 Media | ✅ Sí | ✅ Sí |
| Costo/context tradeoff | PT-I11 | 🟡 Media | ✅ Sí | ✅ Sí |
| Integración reversible | PT-I12 | 🔴 Alta | ✅ Sí | ✅ Sí |

---

*Fin de ponytail-integration-test-plan.md*
