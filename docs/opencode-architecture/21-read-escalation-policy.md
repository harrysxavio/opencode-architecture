# 21 — Read Escalation Policy

> Política progresiva de lectura para minimizar tokens de contexto.

**Creado en:** Fase E5 (2026-06-10)
**Estado:** Documento de diseño (no implementado en runtime)

## Propósito

Establecer cuánto leer según la necesidad, evitando leer archivos completos cuando una sección alcanza.

## Contenido

El detalle completo vive en:

```
test-runs/E5-context-pack-contracts-2026-06-10/E5F-read-escalation-policy.md
```

### Niveles

| Nivel | Accion | Max recursos |
|---|---|---|
| 1 — Tiny | Sin memoria ni docs | 0 |
| 2 — Small | Contexto mínimo | mem_context |
| 3 — Memory | mem_search con query | 3 resultados |
| 4 — Docs | Seccion especifica | 3 secciones |
| 5 — File | Seccion de archivo | 2 archivos |
| 6 — Full-file | Archivo completo | 1 archivo |
| 7 — Audit | Multiples archivos | Solo pedido explicito |

## Criterio de stop

Evidencia suficiente → dejar de leer.
