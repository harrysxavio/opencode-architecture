# Proposal: Tool Schema Demand Loading Plugin

**Estado:** Proposal only — no runtime rollout

## Intent

Reducir tokens de schemas de herramientas enviando full schema solo para tools relevantes a la fase actual.

## Scope

- Plugin aislado usando `tool.definition` y `tool.execute.before`.
- Catálogo declarativo de tools core/fase.
- Tests sintéticos.

## Out of scope

- Cambiar permisos.
- Cambiar `opencode.json`.
- Modificar core OpenCode.
- Activar rollout automático.

## Rollback

No instalar/activar el plugin. Si se activa en pruebas, remover archivo del directorio de plugins y reiniciar OpenCode.

## Acceptance Criteria

No afecta tools core, no reduce accuracy en fixtures, fallback claro, sin secretos ni cambios de permisos.
