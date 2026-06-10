# 20 — Memory Writer / Validator Contract

> Contratos para decidir cuándo y cómo guardar memoria, y cómo validar decisiones antes de persistirlas.

**Creado en:** Fase E5 (2026-06-10)
**Estado:** Documento de diseño (no implementado en runtime)

## Propósito

Definir reglas claras para:

1. **Memory Writer**: qué se guarda, qué no, con qué formato.
2. **Memory Validator**: cómo validar decisiones críticas antes de guardarlas.

## Contenido

El detalle completo vive en:

```
test-runs/E5-context-pack-contracts-2026-06-10/E5D-memory-writer-contract.md
test-runs/E5-context-pack-contracts-2026-06-10/E5E-memory-validator-contract.md
```

### Resumen Memory Writer

| Tipo | Guardar? | Estado inicial |
|---|---|---|
| decision | Si | proposed |
| preference | Si | approved |
| project_state | Si | approved |
| technical_finding | Si | proposed |
| reusable_pattern | Si | proposed |
| architecture_rule | Si | approved |
| session_summary | Si | approved |
| bug_root_cause | Si | resolved |
| prompts completos | No | - |
| ruido | No | - |
| secretos | No | - |
| hipotesis no validadas | No | - |

### Resumen Memory Validator

Estados: proposed -> approved -> deprecated | rejected | resolved

Reglas clave:
- Hipotesis sin validar: proposed, no approved
- Decision sin evidencia: no guardar
- Secreto detectado: rechazar, marcar high sensitivity
- Contradiccion con memoria previa: evaluar supersede
