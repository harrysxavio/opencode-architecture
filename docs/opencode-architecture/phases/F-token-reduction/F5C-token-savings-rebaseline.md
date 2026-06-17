# F5C Token Savings Rebaseline

**Fecha:** 2026-06-17 11:09  
**Estado:** ✅ actualizado con F4A-lite real

## Ahorro real F4A-lite

| Métrica | Valor |
|---|---:|
| Caracteres antes | 6360 |
| Caracteres después | 2828 |
| Ahorro real | 3532 chars |
| Ahorro conservador | ~883 tokens |
| Ahorro esperado | ~1177 tokens |

## Separación por iniciativa

| Iniciativa | Estado | Ahorro |
|---|---|---:|
| F4A-lite skills compact descriptions | ✅ Implementado | 3532 chars (~883-1177 tokens) |
| F4B RECENT_SESSION_PACK | ⚠️ PARTIAL | Potencial ~7,070 tokens por sesión 30-turn; pendiente compactación natural real |
| F4C memory selector guidance | ✅ Activo | Guidance activo; ahorro depende de selección efectiva |
| QW#2 tool schema loading | 🧪 Prototype-only | Pendiente, no runtime activo |
| QW#3 Manager Protocol compaction | ⏸️ Proposal-only | Pendiente/propuesta |

## Advertencias

- El ahorro en tokens es estimado por ratio chars/token.
- OpenCode debe reiniciarse para observar el nuevo <available_skills>.
- F4B no se promueve a PASS hasta evidencia real de compactación natural.
