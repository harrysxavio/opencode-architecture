# F4D: Tool Schema Loading Prototype Plan

**Estado:** ✅ PROTOTYPE ONLY — no rollout  
**Fecha:** 2026-06-17

## Objetivo

Diseñar un plugin aislado para probar demand-loading de tool schemas con `tool.definition` y `tool.execute.before`, sin activarlo en runtime productivo.

## Diseño propuesto

1. Plugin nuevo: `tool-schema-demand-loading.prototype.ts`.
2. Catálogo core siempre completo: `read`, `glob`, `grep`, `bash`, `todowrite`, `skill`.
3. Catálogo expandido por fase: SDD, frontend, docs, BigQuery, release.
4. `tool.definition` compacta herramientas no relevantes.
5. `tool.execute.before` registra intento de uso fuera de set y permite fallback.
6. No cambia permisos ni `opencode.json`.

## Pruebas sintéticas

Core tool full schema; rare tool compact schema; tool llamada fuera de fase fallback registrado; agent docs con docs tools full; ninguna credencial en schemas.

## Challenge

El patrón puede ahorrar tokens, pero no debe afectar tool-call accuracy. Requiere fixtures antes de rollout. No crear dependencia con gentle-ai.

## Recomendación

Mantener como prototipo aislado hasta completar pruebas de accuracy.
