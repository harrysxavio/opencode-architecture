# D4 — Post-change Tests

## Estado

PARTIAL_IN_PROGRESS

## Motivo

OpenCode fue reiniciado y D-T1 ya fue ejecutado en sesión limpia. Faltan D-T5-read-only, D-T5-pipeline-dry-run y D-T3.

## Tests pendientes en sesión nueva

| Test | Input | Resultado esperado | Estado |
|---|---|---|---|
| D-T1 | `Dime 1 frase.` | Manager directo, sin gentle/SDD/memoria/MCP/skills/subagentes | PASSED |
| D-T5-read-only | Diseño de log Manager read-only | Manager clasifica y puede proponer/invocar gentle sin violar reglas | PENDING |
| D-T5-pipeline-dry-run | Dry-run `TEST-D-SDD-ROUTING` | Envelope compacto, sin loop, sin escritura funcional | PENDING |
| D-T3 | Rol objetivo de gentle-orchestrator en docs | Usa Markdown; gentle = SDD Pipeline invocable | PENDING |

## D-T1 — Tiny request

### Input exacto

```text
Dime 1 frase.
```

### Output observado

```text
Una frase: **"La arquitectura no es lo que construís, es lo que protegés cuando todo cambia."**
```

### Evidencia runtime

| Métrica | Valor | Estado |
|---|---:|---|
| Agente | manager | VALIDADO |
| Modo | manager | VALIDADO |
| Modelo | deepseek-v4-flash-free | VALIDADO |
| Provider | opencode | VALIDADO |
| Tiempo visible aproximado | ~2s | VALIDADO por usuario |
| Tiempo por timestamps runtime | ~7.4s | VALIDADO por metadata |
| Input tokens | 40,017 | VALIDADO |
| Output tokens | 27 | VALIDADO |
| Reasoning tokens | 47 | VALIDADO |
| Total tokens | 40,091 | VALIDADO |
| Cache read/write | 0 / 0 | VALIDADO |
| Tools visibles | 0 | VALIDADO |
| MCP visibles | 0 | VALIDADO |
| Memoria visible | No | VALIDADO |
| Skills visibles | 0 | VALIDADO |
| Subagentes visibles | 0 | VALIDADO |
| ¿Apareció gentle-orchestrator? | No | VALIDADO |

### Estado

PASSED

### Conclusión

Manager sigue respondiendo requests Tiny de forma directa después de D3. `gentle-orchestrator` no compite como primary en este flujo. No hubo tools, MCP, memoria, skills, subagentes ni SDD.

### Riesgo nuevo

Aunque el routing Tiny es sano, el input real reportado por runtime fue **40,017 tokens**, muy por encima de la estimación preliminar de ~18,500–22,000. Esto no bloquea D4, pero sí convierte Fase F en una investigación prioritaria después de E/D cierre.

## Criterio para cerrar D4

D4 queda incompleto hasta ejecutar D-T5-read-only, D-T5-pipeline-dry-run y D-T3 en sesión nueva/post-restart.
