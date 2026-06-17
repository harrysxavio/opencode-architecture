# Ponytail Post-Restart Validation

> **Estado:** ⚠️ PENDING — OpenCode no fue reiniciado después de la edición de AGENTS.md
> **Fecha:** 2026-06-17
> **Propósito:** Validar que Ponytail Code Gate funciona correctamente tras un restart de OpenCode. Documentar procedimiento y resultados.

---

## 1. Estado de restart

| Indicador | Valor |
|-----------|:-----:|
| AGENTS.md editado | 2026-06-17 ~14:27 |
| Backup creado | `backups/agents-md-ponytail-integration-20260617-142727/` |
| OpenCode restart post-edit | ❌ **No realizado** |
| Sesión actual | Misma sesión que la edición |

**La validación runtime queda PENDIENTE.** OpenCode carga AGENTS.md al iniciar. Sin restart, los cambios no están activos en la sesión actual.

---

## 2. Procedimiento de validación (para ejecutar post-restart)

### Paso 1: Verificar que la sección se carga

```powershell
Select-String -Path "$env:USERPROFILE\.config\opencode\AGENTS.md" -Pattern "opencode-architecture:ponytail-integration"
```

Esperado: línea 261 con el marker de apertura.

### Paso 2: Prompt A — code task

> "Diseña una implementación mínima para una función debounce en JavaScript y dime si aplica Ponytail."

**Esperado:**
- Manager clasifica como code task.
- Manager activa Ponytail Code Gate.
- Manager aplica escalera YAGNI/stdlib/native.
- El Completion Contract incluye sección Ponytail con:
  - Activation: applied (o similar)
  - Simplifications encontradas
  - Excepciones justificadas (si las hay)

**No esperado:**
- Manager responde sin mencionar Ponytail.
- Manager escribe 50 líneas sin simplificar.

### Paso 3: Prompt B — non-code

> "Resume el estado documental de Fase F."

**Esperado:**
- Manager clasifica como non-code (documentación/status).
- Manager NO activa Ponytail.
- Completion Contract NO incluye sección Ponytail.
- Respuesta directa, concisa, con el estado de Fase F.

**No esperado:**
- Manager fuerza Ponytail para una tarea de documentación.
- Manager pregunta "¿quieres simplificar esto?" en una tarea sin código.

---

## 3. Criterios de validación

| Criterio | Esperado | Real (post-restart) |
|----------|:--------:|:-------------------:|
| Code task → Ponytail applied | ✅ Sí | ⏳ Pendiente |
| Non-code task → Ponytail skipped | ✅ Sí | ⏳ Pendiente |
| Ponytail no over-triggers | ✅ Sí | ⏳ Pendiente |
| Ponytail no under-triggers | ✅ Sí | ⏳ Pendiente |
| Completion Contract incluye sección | ✅ Cuando code task | ⏳ Pendiente |
| No menciona gentle-ai en contexto Ponytail | ✅ Sí | ⏳ Pendiente |
| Manager sigue siendo primary | ✅ Sí | ⏳ Pendiente |

---

## 4. Resultados de validación (a completar post-restart)

| Prompt | Aplicó Ponytail | Observaciones | Requiere ajuste |
|--------|:---------------:|---------------|:---------------:|
| A — debounce | ⏳ Pendiente | — | ⏳ Pendiente |
| B — Fase F status | ⏳ Pendiente | — | ⏳ Pendiente |

---

## 5. Riesgos si no se valida

| Riesgo | Probabilidad | Impacto |
|--------|:-----------:|:-------:|
| Manager ignora Ponytail en code tasks | Baja | Medio — el guidance puede fallar sin plugin |
| Manager aplica Ponytail en non-code tasks | Baja | Bajo — overhead de contexto, no daño funcional |
| La sección conflictúa con otras instrucciones | Muy baja | Medio — AGENTS.md tiene 368 líneas, puede solaparse |
| El modelo no interpreta "code-task default" como se espera | Media | Medio — guidance sin enforcement |

---

## 6. Nota técnica

OpenCode carga AGENTS.md en el momento de iniciar la sesión. Los cambios realizados durante una sesión activa **no tienen efecto** hasta el próximo restart. Esto aplica tanto a la sección Ponytail como a cualquier otra modificación de AGENTS.md.

Para verificar el cambio sin restart, se puede inspeccionar el archivo:

```powershell
Get-Item "$env:USERPROFILE\.config\opencode\AGENTS.md" | Select-Object Length, LastWriteTime
Get-FileHash "$env:USERPROFILE\.config\opencode\AGENTS.md" -Algorithm SHA256
```

Y comparar con el SHA256 after registrado en el backup manifest:
`EABBDBD32396D737D49FB72CF0B6E2145F0B60595F74EEBC8048B410E3698FF3`

---

*Fin de ponytail-post-restart-validation.md*
