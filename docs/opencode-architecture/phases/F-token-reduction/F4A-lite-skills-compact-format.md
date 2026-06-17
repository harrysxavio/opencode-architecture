# F4A-lite Compact Description Format

**Estado:** ✅ aplicado  
**Formato:** Trigger: <keywords>. <one-line purpose>.

## Reglas

- Mantener keywords reales que activan la skill.
- Mantener la intención principal.
- Evitar ejemplos largos y advertencias extensas.
- Target general: 60-100 caracteres.
- Permitir 100-140 caracteres para BigQuery, SQL, frontend, data governance o deploy/security.
- No sacrificar activación por ahorrar 10 caracteres.

## Ejemplo

Antes:

`yaml
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when...
`

Después:

`yaml
description: "Trigger: UI, pages, components, design polish. Build distinctive frontend interfaces."
`

## Criterios de aceptación

- Ninguna descripción queda vacía.
- Todas las descripciones compactas incluyen Trigger:.
- El cuerpo del skill queda byte-equivalent a nivel semántico/hash de body.
- OpenCode debe reiniciarse para cargar el índice actualizado.
