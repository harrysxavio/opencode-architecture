# GPT-5.5 Fallback Plan

> **Estado:** PLAN DEFINED  
> **Fecha:** 2026-06-17  
> **Scope:** documentación de fallback; no cambia runtime.

---

## 1. Decisión

GPT-5.5 es gate de calidad cuando está disponible, pero la arquitectura no debe depender de un único subagente OAuth para poder cerrar verificaciones básicas.

**Fallback:** si `@review-gpt55` o `@debug-gpt55` no existe o falla, Manager ejecuta review/debug inline con el mismo checklist y deja evidencia de la limitación.

---

## 2. Routing esperado

| Situación | Acción |
|---|---|
| `@review-gpt55` disponible | Delegar review final read-only. |
| `@review-gpt55` no disponible | Manager ejecuta review inline y marca `GPT-5.5 review: unavailable — inline fallback used`. |
| `@debug-gpt55` disponible y hay fallo | Delegar root-cause read-only o con permiso explícito para editar. |
| `@debug-gpt55` no disponible | Manager usa systematic debugging inline. |
| Judgment Day disponible y tarea large/riesgosa | Puede complementar review, no reemplaza tests. |

---

## 3. Checklist mínimo de review fallback

- Requisito original y scope.
- Diseño aprobado o waiver explícito.
- Diff real contra tareas.
- Seguridad/secrets/data loss.
- Edge cases y error handling.
- Tests/comandos ejecutados.
- Riesgos no verificados.
- Graphify assumptions, si aplica.
- Ponytail para code tasks, si aplica.

---

## 4. Checklist mínimo de debug fallback

1. Síntoma observable.
2. Comando o evidencia de reproducción.
3. Hipótesis ordenadas.
4. Evidencia que confirma/descarta.
5. Root cause.
6. Fix mínimo.
7. Verificación.
8. Riesgo de regresión.

---

## 5. Criterios de aceptación para repo nuevo

- [ ] Manager template contiene fallback explícito.
- [ ] Completion Contract distingue `GPT-5.5 review used`, `unavailable`, o `waived`.
- [ ] Si falla GPT-5.5, no se bloquean tareas tiny/small por dependencia externa.
- [ ] Large/high-risk requiere review fuerte: GPT-5.5, Judgment Day o inline con evidencia reforzada.

---

*Fin de GPT-5.5-FALLBACK-PLAN.md*
