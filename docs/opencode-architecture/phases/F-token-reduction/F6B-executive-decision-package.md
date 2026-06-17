# F6B: Executive Decision Package

**Estado:** ✅ READY

## Qué quedó implementado

- F4B: instrucciones `RECENT_SESSION_PACK` en compaction hook.
- F4C: instrucciones de selector de memorias en system transform.

## Qué quedó propuesto

- F4A Skills selective loading.
- QW#2 Tool schema demand-loading plugin.
- QW#3 Manager Protocol compaction.

## Ahorro real/potencial

| Tipo | Ahorro |
|---|---:|
| Real tras restart y uso | F4B/F4C guidance; medición pendiente runtime |
| Conservador esperado | ~7,500 tokens en sesiones largas |
| Potencial adicional | ~3,600-7,400 tokens con aprobaciones futuras |

## Riesgos restantes

Hooks `experimental.*` pueden cambiar; F4C es guidance, no enforcement DB-level; F4B requiere compaction real para validar output final.

## Requiere aprobación

Tocar `opencode.json`, editar skills reales, activar QW#2 en runtime o compactar Manager Protocol.

## Recomendación senior

Mantener F4B/F4C, reiniciar OpenCode, ejecutar una sesión canonical de prueba y no promover F4A/QW#2/QW#3 hasta tener aprobación explícita.
