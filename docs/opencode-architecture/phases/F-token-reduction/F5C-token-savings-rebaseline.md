# F5C: Token Savings Rebaseline

**Estado:** ✅ COMPLETED  
**Fecha:** 2026-06-17

## Resumen

| Categoría | Ahorro | Estado |
|---|---:|---|
| F4B session compaction | ~7,070 tokens por sesión 30-turn | Implementado guidance-only; real tras restart+compaction |
| F4C selector guidance | ~500-2,000 tokens/turno potencial | Implementado guidance-only |
| F4A skills | ~400-1,184 tokens | Pendiente aprobación; no real |
| QW#2 tool schemas | ~2,000-4,000 tokens potencial | Prototipo/propuesta only |
| QW#3 manager protocol | ~1,200-2,300 tokens | Proposal only; no real |

## Ahorro real vs potencial

Real aplicado en runtime tras restart: F4B/F4C guidance. Real medible hoy sin compaction real: 0 tokens garantizados. Potencial conservador post-F4B/F4C: ~7,500 tokens por sesión larga + reducción por selección de memoria. Potencial adicional con aprobaciones futuras: +~3,600 a 7,400 tokens.

## Anti double-counting

Session compaction es acumulativa por sesión, selector es por recuperación de memoria/turno, y F4A/QW#2/QW#3 no se cuentan como ahorro real.
