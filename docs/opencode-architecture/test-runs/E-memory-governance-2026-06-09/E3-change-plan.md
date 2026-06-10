# E3 — Minimal Change Plan Proposal

Estado: **propuesta, no implementada**.

## Objetivo

Reducir ambigüedad y ruido sin refactor amplio: una fuente runtime clara, una política de memoria gobernada y pruebas reproducibles.

## Cambios propuestos

### Opción A — Configuración/binario

Unificar Engram para que OpenCode use explícitamente un solo binario actualizado.

Diff conceptual:

```diff
// opencode.json
"engram": {
-  "command": ["engram", "mcp", "--tools=agent"],
+  "command": ["C:\\Users\\harry\\AppData\\Local\\engram\\bin\\engram.exe", "mcp", "--tools=agent"],
   "type": "local"
}
```

Y decidir si `opencode.jsonc` debe quedar como archivo no activo/documental o remover su MCP duplicado en una fase aprobada.

### Opción B — Instrucciones

Consolidar política:

- `docs/opencode-architecture/16-memory-governance-policy.md`: fuente humana/arquitectónica.
- `~/.codex/engram-instructions.md`: fuente runtime concisa.
- `AGENTS.md`: regla mínima y referencia, no protocolo completo.
- `plugins/engram.ts`: mecanismo técnico, no fuente larga de política.

### Opción C — Plugin

No tocar todavía salvo aprobación explícita. Si se toca, hacerlo solo para:

- No inyectar protocolo largo duplicado si ya viene de AGENTS/runtime.
- Añadir gate de prompt capture/noise.
- Mantener strip de `<private>`.

### Opción D — Filtro de guardado

Gate recomendado antes de `mem_save`/prompt capture:

- No guardar prompts completos salvo necesidad explícita.
- No guardar ruido conversacional.
- No guardar outputs largos de subagentes.
- No guardar secretos.
- No duplicar docs/ADR; guardar solo resumen recuperable + puntero.
- Usar `topic_key` obligatorio para temas evolutivos.

### Opción E — Temporalidad/test data

Engram no expone `valid_until/status/supersedes` como parámetros de `mem_save`. Alternativas:

- Guardar metadata en `content`.
- Usar `mem_update` para marcar deprecated.
- Usar `memory_relations` cuando hay dos observaciones reales que relacionar.
- Crear convención `status: deprecated` en contenido hasta que exista soporte nativo.

## Archivos a tocar si se aprueba E4

| Archivo | Motivo | Riesgo |
|---|---|---|
| `C:\Users\harry\.config\opencode\opencode.json` | Fijar binario Engram único/actualizado o ajustar MCP | Medio: requiere restart OpenCode |
| `C:\Users\harry\.config\opencode\opencode.jsonc` | Eliminar/neutralizar duplicado si se confirma merge | Medio: puede afectar MCP si sí se mergea |
| `C:\Users\harry\.codex\engram-instructions.md` | Hacer runtime policy más concisa/gobernada | Bajo/medio |
| `C:\Users\harry\.config\opencode\AGENTS.md` | Reducir duplicación a regla mínima | Medio: afecta contexto global |
| `C:\Users\harry\.config\opencode\plugins\engram.ts` | Solo si se aprueba gate de prompt capture/inyección | Medio/alto: plugin runtime |
| `docs/opencode-architecture/*` | Actualizar arquitectura/documentación | Bajo |

## Rollback

- Guardar backup antes de tocar config/plugin.
- Revertir cambios con `git diff`/backup local.
- Reiniciar OpenCode después de revertir.
- Validar `opencode.json` con Node JSON parse.

## Tests post-cambio

1. `opencode.json OK` con Node.
2. Listar procesos Engram: esperar 1 `serve` + 1 MCP por runtime activo, no múltiples duplicadas.
3. `engram doctor --json --project opencode-architecture`.
4. `mem_search` del probe E.
5. `mem_save` ficticio nuevo con topic_key test.
6. `mem_session_summary` ficticio y DB verification.
7. Test Tiny: no `mem_save` para ruido.

## Recomendación

**GO para E4 con alcance mínimo A+B+docs.**

No tocar plugin todavía salvo que el usuario apruebe explícitamente un segundo paso de prompt-capture gate.
