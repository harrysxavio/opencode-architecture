# Subagent Return Envelope — Standard Contract

> **Estado:** ✅ ENVELOPE DEFINED
> **Fecha:** 2026-06-17
> **Propósito:** Definir el formato estándar de retorno que todos los subagentes SDD deben usar al devolver resultados al Manager.

---

## 1. Formato estándar

```markdown
## SUBAGENT_RESULT

- Subagent: [nombre del subagente, ej: sdd-explore]
- Phase: [fase ejecutada, ej: explore]
- Request id: [identificador único de la solicitud, generado por Manager]
- Input summary: [resumen de lo que se pidió]
- Actions taken: [lista de acciones realizadas]
- Files inspected: [archivos leídos]
- Files changed: [archivos modificados, si aplica]
- Findings: [hallazgos principales]
- Decisions needed: [decisiones que el Manager debe tomar]
- Risks: [riesgos detectados]
- Tests run: [tests ejecutados, si aplica]
- Confidence: [alta / media / baja — qué tan seguro está el subagente de sus resultados]
- Next recommended step: [qué fase sugiere continuar]
```

---

## 2. Ejemplo concreto

```markdown
## SUBAGENT_RESULT

- Subagent: sdd-explore
- Phase: explore
- Request id: req-auth-refactor-001
- Input summary: Explorar módulo de autenticación para refactor. Analizar JWT, sesiones, middleware actual.
- Actions taken:
  - Leído: src/auth/middleware.ts, src/auth/jwt.ts, src/auth/session.ts
  - Buscado: dependencias de jsonwebtoken, express-session
  - Verificado: tests existentes en src/auth/__tests__/
- Files inspected:
  - src/auth/middleware.ts (45 líneas)
  - src/auth/jwt.ts (120 líneas)
  - src/auth/session.ts (80 líneas)
  - src/auth/__tests__/auth.test.ts (200 líneas)
  - package.json (dependencias)
- Files changed: none (read-only phase)
- Findings:
  - JWT implementado con jsonwebtoken v9, algoritmo HS256
  - Sesiones con express-session, store en memoria
  - Middleware de autenticación mezcla lógica de JWT y sesiones
  - 3 tests existentes, cobertura ~40%
  - No hay refresh token rotation
  - No hay rate limiting en login
- Decisions needed:
  - ¿Migrar a solo JWT (eliminar sesiones)?
  - ¿Implementar refresh token rotation?
  - ¿Mantener compatibilidad con sesiones existentes?
- Risks:
  - Migrar a solo JWT rompe sesiones existentes (usuarios logueados pierden sesión)
  - Sin refresh rotation, JWT de larga duración es riesgo de seguridad
- Tests run: npm test src/auth/__tests__/auth.test.ts — 3/3 pass
- Confidence: alta
- Next recommended step: sdd-propose
```

---

## 3. Reglas del envelope

| Regla | Descripción |
|-------|-------------|
| **No cerrar tarea** | El subagente no debe decir "done" ni "completado" al usuario. Solo devuelve el envelope al Manager. |
| **No responder al usuario** | El subagente no habla directamente al usuario. Nunca. |
| **Manager decide** | Si el subagente encuentra un bloqueo, lo reporta en `Decisions needed`. El Manager decide cómo proceder. |
| **Preguntas al usuario** | Si el subagente necesita clarificación, las devuelve en `Decisions needed` como preguntas. El Manager pregunta al usuario. |
| **Engram suggestion** | Si el subagente cree que algo merece memoria, lo sugiere en `Findings`. El Manager decide si persiste. |
| **Confianza explícita** | Si el subagente tiene baja confianza, el Manager debe verificar antes de continuar. |

---

## 4. Estados de retorno

| Estado | Significado | Acción del Manager |
|--------|-------------|--------------------|
| **success** | Fase completada sin problemas | Avanzar a siguiente fase |
| **blocked** | El subagente no puede continuar | Revisar `Decisions needed`. Puede requerir intervención del usuario. |
| **partial** | Fase completada parcialmente | Manager decide si es suficiente o si repetir |
| **failed** | La fase no pudo ejecutarse | Manager investiga causa, puede intentar otra estrategia |

---

## 5. Campos obligatorios vs opcionales

| Campo | ¿Obligatorio? | Notas |
|-------|:-------------:|-------|
| Subagent | ✅ Sí | Siempre |
| Phase | ✅ Sí | Siempre |
| Request id | ✅ Sí | Manager lo genera y lo pasa |
| Input summary | ✅ Sí | Para trazabilidad |
| Actions taken | ✅ Sí | Mínimo 1 acción |
| Files inspected | ⚠️ Si aplica | Omitir si no se inspeccionaron archivos |
| Files changed | ⚠️ Si aplica | Solo para fases que modifican archivos |
| Findings | ✅ Sí | Puede ser "None" |
| Decisions needed | ✅ Sí | Puede ser "None" |
| Risks | ✅ Sí | Puede ser "None" |
| Tests run | ⚠️ Si aplica | Solo si se ejecutaron tests |
| Confidence | ✅ Sí | alta / media / baja |
| Next recommended step | ✅ Sí | Siempre sugerir |

---

## 6. Versión compacta (para subagentes sin output detallado)

```markdown
## SUBAGENT_RESULT

- Subagent: [nombre]
- Phase: [fase]
- Status: success | blocked | partial | failed
- Summary: [2-3 líneas máximo]
- Decisions needed: [lista o "none"]
- Next: [fase sugerida]
```

---

## 7. Anti-patrones del envelope

| Anti-patrón | Problema | Corrección |
|-------------|----------|------------|
| Subagente dice "done" al usuario | El usuario espera cierre, pero Manager no sintetizó | Devolver envelope al Manager |
| Subagente guarda en Engram sin consultar | Manager pierde control de la memoria | Subagente sugiere, Manager guarda |
| Subagente toma decisiones sin reportarlas | El Manager no sabe qué pasó | Siempre reportar en `Decisions needed` |
| Subagente devuelve 50 páginas de resultados | Manager no puede sintetizar eficientemente | Mantener envelope compacto. Detalles en archivos separados |
| Subagente oculta errores | Manager confía en datos incorrectos | Reportar siempre `Confidence` real |

---

*Fin de subagent-return-envelope.md*
