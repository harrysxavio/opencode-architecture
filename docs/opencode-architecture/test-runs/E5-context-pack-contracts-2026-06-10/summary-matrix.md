# E5 — Summary Matrix

> Resultados de la fase E5.

## Contratos creados

| Contrato | Archivo | Estado |
|---|---|---|
| Context Pack Contract | E5A-context-pack-contract.md | Creado |
| Intake / Noise Cleaner | E5B-intake-noise-cleaner.md | Creado |
| Memory Retriever | E5C-memory-retriever-contract.md | Creado |
| Memory Writer | E5D-memory-writer-contract.md | Creado |
| Memory Validator | E5E-memory-validator-contract.md | Creado |
| Read Escalation Policy | E5F-read-escalation-policy.md | Creado |
| Memory Quality Metrics | E5G-memory-quality-metrics.md | Creado |

## Tests diseñados

| Test | Resultado esperado |
|---|---|
| E5-T1 — Tiny no context | Respuesta directa, sin memoria |
| E5-T2 — Memory needed | Max 3 items en Context Pack |
| E5-T3 — Docs needed | Doc citado como fuente |
| E5-T4 — Noisy mixed | Pide priorización |
| E5-T5 — Memory write decision | status: proposed |
| E5-T6 — Sensitive rejection | No mem_save |
| E5-T7 — Supersedes | topic_key upsert |

## Qué NO se modificó

- Plugin engram.ts
- AGENTS.md
- opencode.json / opencode.jsonc / config.toml
- MCP general
- Skills / subagentes / SDD
- Manager/gentle routing
- Bases de datos
- Memoria real
- Prompt capture
- Token optimization
- Hybrid Retrieval
- MCP memory server

## Go / No-Go

### GO para E6 si:
- Los contratos dejan claro cómo evitar ruido antes de tocar prompt capture
- Memory Writer/Validator define regla de no guardar prompts completos
- Hay criterio para distinguir prompt capture automático vs memoria gobernada

### NO-GO para Fase F si:
- Context Pack no está listo como base de reducción de contexto
- No hay métricas para medir calidad y tokens antes/después
