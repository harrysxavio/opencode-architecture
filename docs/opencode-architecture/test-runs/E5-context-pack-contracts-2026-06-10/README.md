# E5 — Context Pack + Memory Writer/Validator Contracts

> **Duración:** 2026-06-10
> **Estado:** ▶️ En curso
> **Objetivo:** Diseñar contratos operativos que controlan qué contexto recibe el modelo, qué memoria se lee/escribe, qué se descarta como ruido y cómo se valida una decisión antes de guardarla.

## Archivos de la fase

| Documento | Descripción |
|---|---|
| [E5A-context-pack-contract.md](E5A-context-pack-contract.md) | Context Pack: estructura, reglas, budget |
| [E5B-intake-noise-cleaner.md](E5B-intake-noise-cleaner.md) | Clasificador de intención y detector de ruido |
| [E5C-memory-retriever-contract.md](E5C-memory-retriever-contract.md) | Cómo buscar y seleccionar memoria relevante |
| [E5D-memory-writer-contract.md](E5D-memory-writer-contract.md) | Cuándo y cómo guardar memoria |
| [E5E-memory-validator-contract.md](E5E-memory-validator-contract.md) | Validación antes de guardar decisiones críticas |
| [E5F-read-escalation-policy.md](E5F-read-escalation-policy.md) | Política progresiva de lectura |
| [E5G-memory-quality-metrics.md](E5G-memory-quality-metrics.md) | Métricas de calidad de memoria |
| [E5H-test-design.md](E5H-test-design.md) | Tests E5-T1 a T7 |
| [summary-matrix.md](summary-matrix.md) | Matriz resumen |

## Principio rector

> El modelo no debe ser una base de datos.
> El modelo debe recibir **contexto limpio, mínimo, trazable y validado**.
> La memoria debe funcionar como **biblioteca viva de decisiones, errores, criterios y estado útil**; no como basurero de prompts ni conversaciones completas.
