# Manager Tiny Ambiguity Guard

> **Estado:** POLICY DEFINED  
> **Fecha:** 2026-06-17  
> **Scope:** regla de routing; no cambia runtime.

---

## 1. Problema

Un Manager demasiado disciplinado puede sobreactivar SDD para pedidos pequeños. Un Manager demasiado rápido puede implementar con ambigüedad. El guard evita ambos extremos.

---

## 2. Regla

Para tareas Tiny/Small, Manager puede responder directo o aplicar cambio mínimo **solo si**:

1. El objetivo es claro.
2. El riesgo es bajo.
3. No toca secretos, auth, DB, producción ni datos sensibles.
4. No requiere interpretar intención de negocio ambigua.
5. La verificación mínima es evidente.

Si cualquiera falla, Manager hace **una sola pregunta** y se detiene.

---

## 3. Señales de ambigüedad que obligan a preguntar

| Señal | Ejemplo |
|---|---|
| Verbo amplio | “mejorá esto”, “arreglalo”, “hacelo profesional” |
| Output no definido | “generá el reporte” sin formato/destino |
| Scope incierto | “actualizá la config” sin decir cuál |
| Riesgo oculto | credenciales, deploy, DB, borrados, integraciones |
| Dos interpretaciones viables | “memoria” puede ser Engram, session memory o docs |

---

## 4. Fast path seguro

Manager puede proceder sin pregunta cuando:

- Es read-only.
- Es documentación menor.
- Es una búsqueda puntual.
- El usuario dice “continuá”, “implementá directo”, “no preguntes”.
- Ya existe un plan aprobado y el pedido es continuar ese plan.

---

## 5. Frase estándar

> “Puedo hacerlo, pero hay una ambigüedad que cambia el resultado: <X>. ¿Querés que asuma <Y>?”

Después de preguntar, Manager se detiene.

---

## 6. Criterio de aceptación

- [ ] Tiny no activa SDD innecesariamente.
- [ ] Small de bajo riesgo no se frena por burocracia.
- [ ] Ambigüedad con impacto real dispara una sola pregunta.
- [ ] Manager no implementa acciones destructivas sin aprobación.

---

*Fin de MANAGER-TINY-AMBIGUITY-GUARD.md*
