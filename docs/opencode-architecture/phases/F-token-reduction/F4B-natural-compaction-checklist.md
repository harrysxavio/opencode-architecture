# F4B Natural Compaction Checklist

**Propósito:** Validar que una compactación natural de OpenCode produce un `RECENT_SESSION_PACK` conforme al contrato endurecido. Ejecutar solo cuando ocurra compactación real — no forzar.

**Estado del contrato:** ✅ Hardened v1  
**Marcadores obligatorios:** `RECENT_SESSION_PACK_VERSION: v1`, `F4B_COMPACTION_CONTRACT_ACTIVE: true`

---

## 1. Detección del evento

| Señal | Cómo detectarla |
|---|---|
| Compacted summary visible en sesión | El nuevo agente post-compaction arranca con un resumen estructurado |
| `engram-debug.log` marcador | Buscar `F4B RECENT_SESSION_PACK compaction hook entered` en `%USERPROFILE%\.config\opencode\engram-debug.log` |
| `RECENT_SESSION_PACK_log_hits` | Si `DEBUG_ENGRAM_PLUGIN=true`, buscar contador en log |
| `compacting_log_hits` | Si `DEBUG_ENGRAM_PLUGIN=true`, buscar contador en log |

Si no hay ninguna señal visible, la compactación no ocurrió o no usó el contrato → **PARTIAL**.

---

## 2. Campos obligatorios del summary

Cada campo debe estar presente textualmente:

| # | Campo | ¿Presente? | Notas |
|---|---|---|---|
| 1 | `RECENT_SESSION_PACK_VERSION` | `___` | Debe ser exactamente `v1` |
| 2 | `F4B_COMPACTION_CONTRACT_ACTIVE` | `___` | Debe ser exactamente `true` |
| 3 | `ACTIVE_PHASE` | `___` | Fase/proyecto actual |
| 4 | `LAST_VALIDATED_OUTCOME` | `___` | Último gate/test/resultado verificado |
| 5 | `CURRENT_OBJECTIVE` | `___` | Objetivo concreto, no roadmap amplio |
| 6 | `OPEN_DECISIONS` | `___` | Decisiones pendientes o aprobaciones necesarias |
| 7 | `OPEN_RISKS_AND_BLOCKERS` | `___` | Riesgos/blockers sin resolver |
| 8 | `RECENT_IDS_OR_ARTIFACTS` | `___` | IDs de observación, paths de docs, reportes, backups |
| 9 | `NEXT_STEP` | `___` | Próxima acción segura post-compaction |
| 10 | `REGRESSION_GATES` | `___` | Gates que deben seguir siendo true |
| 11 | `ROLLBACK_NOTE` | `___` | Nota de rollback o seguridad; `UNKNOWN` si no aplica |

**Criterio:** todos presentes → **PASS en contenido**. Si falta 1+ campo obligatorio → **PARTIAL** (ajustar contrato y re-validar).

---

## 3. Reglas de seguridad

| Regla | ¿Cumple? | Notas |
|---|---|---|
| No incluye secretos, API keys, tokens, `ghp_*`, `sk-*`, `AKIA*` | `___` | Revisar visualmente |
| No incluye credenciales ni valores parciales | `___` | Revisar visualmente |
| No incluye contenido `.env` o configuración sensible | `___` | Revisar visualmente |
| Proyecto scoped al actual (sin cross-project) | `___` | `project: opencode-architecture` u otro explícito |
| No referencia sesiones legacy ni `.codex/memories_1.sqlite` | `___` | Si referencia, es contaminación |
| No incluye datos personales ni confidenciales | `___` | Revisar visualmente |

**Criterio:** todo en ✅ → **PASS en seguridad**. Si hay 1+ secreto no redactado → **BLOCKED**.

---

## 4. Validación de contaminación cross-project

| Check | Resultado |
|---|---|
| `project` en el summary coincide con la sesión actual | `___` |
| No hay referencias a proyectos anteriores del usuario | `___` |
| No hay `session_project_mismatch` activo en el momento de compactación | `___` |
| No hay memorias legacy incluidas como estado activo | `___` |

**Criterio:** todo OK → **PASS**. Cualquier contaminación → **FAIL**.

---

## 5. Contadores DB

Capturar antes y después de la validación (no necesariamente antes/después de compactación — puede ser check post-facto):

```sql
-- Ejecutar vía Engram CLI o inspección directa:
SELECT 'observations_tot' AS metric, COUNT(*) AS val FROM observations
UNION ALL
SELECT 'user_prompts_tot', COUNT(*) FROM user_prompts
UNION ALL
SELECT 'sessions_tot', COUNT(*) FROM sessions
UNION ALL
SELECT 'memory_relations_tot', COUNT(*) FROM memory_relations;
```

| Tabla | Antes | Después | Notas |
|---|---|---|---|
| `observations` | `___` | `___` | Puede incrementar por session summary |
| `user_prompts` | `___` | `___` | No debe cambiar por compactación |
| `sessions` | `___` | `___` | No debe cambiar |
| `memory_relations` | `___` | `___` | Puede incrementar |

Nota: OpenCode puede guardar el resumen como observación durante la compactación. Ese incremento es esperado y aceptable.

---

## 6. Criterio final

| Estado | Definición |
|---|---|
| ✅ **PASS** | Summary presente, 11 campos obligatorios OK, secretos OK, no contaminación, proyecto correcto |
| ⚠️ **PARTIAL** | Summary presente pero faltan campos obligatorios (1-3 campos ausentes) o seguridad dudosa |
| ❌ **FAIL** | Contaminación cross-project confirmada, secretos expuestos, DB inconsistente |
| 🚫 **BLOCKED** | No hubo compactación o el summary no se puede validar |

**Si PASS:** F4B puede promoverse de PARTIAL a PASS oficial.  
**Si PARTIAL:** Ajustar contrato o revisar interacción con compactador de OpenCode.  
**Si FAIL/BLOCKED:** Restaurar backup y re-evaluar enfoque.

---

## 7. Referencias

- Contrato hardening: `F4B-contract-hardening.md`
- Validación anterior (sin compactación): `F4B-real-compaction-validation.md`
- Plugin runtime: `%USERPROFILE%\.config\opencode\plugins\engram.ts`
- Debug log: `%USERPROFILE%\.config\opencode\engram-debug.log`
- Backups:
  - `engram.ts.f4b-f4c-backup-20260617` (F4B/F4C original)
  - `engram.ts.f4b-hardening-backup-20260617` (post-hardening)
