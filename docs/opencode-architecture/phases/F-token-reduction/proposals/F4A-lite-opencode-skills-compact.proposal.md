# Proposal — F4A-lite OpenCode Skills Compact Descriptions

**Fecha:** 2026-06-17  
**Estado:** ✅ aprobado e implementado

## Intent

Reducir tokens del bloque <available_skills> compactando únicamente el campo description: del frontmatter de los SKILL.md fuente reales.

## Scope

- Modificar solo description:.
- Mantener nombre, metadata, rutas y cuerpo completo.
- Mantener todas las skills existentes.
- Backup centralizado fuera de carpetas escaneadas.

## Out of scope

- No opencode.json.
- No gentle-ai.
- No DB/schema.
- No QW#2/QW#3.
- No .system skills.

## Success criteria

- Canary 5 skills PASS.
- Lote completo PASS.
- Harness PASS.
- Manifest + rollback documentados.
- Ahorro real medido.

## Resultado

| Métrica | Valor |
|---|---:|
| Skills modificadas | 36 |
| Chars antes | 6360 |
| Chars después | 2828 |
| Ahorro real | 3532 chars |
