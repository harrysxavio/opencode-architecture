# Fase F — Matriz de Decisiones Ejecutivas

**Propósito:** Resumir todas las decisiones pendientes de Fase F en una matriz ejecutiva para aprobación del usuario.

**Fecha:** 2026-06-17

---

## Matriz

| Decisión | Recomendación | Ahorro esperado | Riesgo | Reversibilidad | ¿Requiere aprobación? | ¿Bloqueante? | Próximo paso |
|---|---|---|---|---|---|---|---|
| **F4B — validar compactación natural** | ✅ Esperar evento natural | ~7,070 tokens/sesión | Bajo — fallback Engram intacto | Sí — restaurar backup | ❌ No (ya instalado) | ❌ No — pero no promo a PASS sin evidencia | Ejecutar sesión canonical larga hasta compaction |
| **F4C — usar guidance activo** | ✅ Ya está runtime-validado | ~500–2,000 tokens/turno pot. | Bajo — solo guidance Manager | Sí — remover `system.transform` | ❌ No (ya activo) | ❌ No | Evaluar si se necesita enforcement DB-level después de data real |
| **F4A-lite** (ya implementado) | ✅ RUNTIME PASS — activo | 3,532 chars (~883-1,177 tokens) | Bajo — solo `description:` compactada, bodies intactos | Sí — backups centralizados con manifest | ❌ No (ya implementado) | ❌ No | Ninguno — F4A-lite completo |
| **F4A-full** (carga selectiva funcional) | ⏸️ Esperar aprobación | ~400–1,184 tokens adicionales | Medio — puede causar falsos negativos en skill matching | Sí — restaurar descripciones originales | ✅ Sí — requiere tocar config de skills | ❌ No | Revisar `F4A-skills-selective-loading-decision.md` y aprobar/rechazar |
| **QW#2 — Tool Schema Loading** | ⏸️ Mantener prototype-only | ~2,000–4,000 tokens | Alto — puede reducir tool-call accuracy | Sí — no toca runtime actual | ✅ Sí — requiere implementación en runtime | ❌ No | Aprobar pasar de prototype a pruebas de accuracy, o descartar |
| **QW#3 — Manager Protocol Compaction** | ⏸️ Mantener proposal-only | ~1,200–2,300 tokens | Alto — modifica `opencode.json` | Sí — backup antes del cambio | ✅ Sí — requiere aprobación explícita | ❌ No — ROI más bajo | Aprobar/rechazar propuesta en `F4E-manager-protocol-compaction-decision.md` |
| **Editar `opencode.json` (cualquier propósito)** | ⛔ No sin aprobación | Depende | Alto — config crítica del runtime | Sí — backup | ✅ Sí — siempre | ❌ No — pero no hacerlo sin aprobación | Solicitar aprobación con propósito y diff claro |
| **Fase G — Hybrid Retrieval** | 🔮 Diferir | Por definir | Bajo — es diseño conceptual | N/A — no hay implementación | ❌ No ahora | ❌ No | Evaluar después de cerrar Fase F |
| **gentle-ai integración** | 🔮 Mantener solo alineación estratégica | N/A | Bajo si no hay integración | N/A | ❌ No ahora | ❌ No | Mantener patrón estratégico sin integración |

---

## Prioridad recomendada

1. **Ya activo**: F4A-lite (3,532 chars ~883-1,177 tokens) + F4C guidance — runtime-validados y funcionando.
2. **Lo más valioso ahora**: esperar compactación natural (F4B) — no requiere cambios, solo observación.
3. **Próximo candidato con mejor ROI**: F4A-full (~400-1,184 tokens adicionales, riesgo medio). Requiere aprobación.
4. **Evaluar después**: QW#2 (~2k-4k tokens, riesgo alto) y QW#3 (~1.2k-2.3k tokens, riesgo alto).
5. **Futuro**: Fase G, gentle-ai, enforcement DB-level.

---

## Notas ejecutivas

- **No hay decisiones urgentes.** Todos los ítems pueden esperar sin degradación del sistema actual.
- **F4C ya está dando valor** como guidance activo desde el restart.
- **F4B no debe promoverse a PASS** sin evidencia de compactación real — forzarlo sería falso positivo.
- **QW#3 tiene el peor ROI/riesgo** de todos los candidatos — considerar descartarlo definitivamente.
