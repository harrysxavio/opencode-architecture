# 22 — Memory Quality Metrics

> Métricas para medir la calidad de las operaciones de memoria.

**Creado en:** Fase E5 (2026-06-10)
**Estado:** Documento de diseño (no implementado en runtime)

## Propósito

Establecer métricas mínimas para evaluar la calidad de las operaciones de memoria: lectura, escritura y construcción de contexto.

## Contenido

El detalle completo vive en:

```
test-runs/E5-context-pack-contracts-2026-06-10/E5G-memory-quality-metrics.md
```

### Campos mínimos (14)

| Grupo | Campos |
|---|---|
| Lectura | memory_query, memory_results_count, memory_used_count, memory_discarded_count, memory_relevance, memory_noise_detected |
| Escritura | memory_write_decision, memory_write_reason, memory_sensitivity, memory_state, memory_duplicate_topic_key |
| Contexto | context_pack_tokens_estimated, docs_sections_read, full_files_read |
