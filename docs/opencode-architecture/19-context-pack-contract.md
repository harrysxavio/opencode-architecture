# 19 — Context Pack Contract

> Contrato formal del paquete mínimo de contexto que el Manager construye antes de responder o delegar.

**Creado en:** Fase E5 (2026-06-10)
**Estado:** Documento de diseño (no implementado en runtime)

## Propósito

Definir la estructura y reglas del Context Pack, el mecanismo por el cual el Manager construye contexto limpio, mínimo y trazable antes de responder o delegar.

## Contenido

El detalle completo del contrato vive en:

```
test-runs/E5-context-pack-contracts-2026-06-10/E5A-context-pack-contract.md
```

### Resumen

| Request type | Context Pack | Token budget |
|---|---|---|
| tiny | No | 0 |
| small | Opcional | Minimo |
| memory | Si | 3.000 / 3 memorias |
| docs | Si | 3.000 / 3 secciones |
| mcp | Si | Minimo + intencion exacta |
| sdd | Si | 5.000 max |
| noisy/mixed | Si (previa limpieza) | 3.000 |
| ambiguous | Si (preguntar primero) | Minimo |

## Dependencias

- Sirve como base para Fase F (token reduction)
- Requiere Intake/Noise Cleaner (E5B) para clasificar antes de construir contexto
