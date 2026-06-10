# D4 — Post-change Tests

## Estado

COMPLETED

## Motivo

OpenCode fue reiniciado y todos los tests D4 fueron ejecutados.

## Tests pendientes en sesión nueva

| Test | Input | Resultado esperado | Estado |
|---|---|---|---|
| D-T1 | `Dime 1 frase.` | Manager directo, sin gentle/SDD/memoria/MCP/skills/subagentes | PASSED |
| D-T5-read-only | Diseño de log Manager read-only | Manager clasifica y puede proponer/invocar gentle sin violar reglas | PASSED |
| D-T5-pipeline-dry-run | Dry-run `TEST-D-SDD-ROUTING` | Envelope compacto, sin loop, sin escritura funcional | PASSED |
| D-T3 | Rol objetivo de gentle-orchestrator en docs | Usa Markdown; gentle = SDD Pipeline invocable | PASSED |

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

## D-T5-read-only — SDD routing

### Input exacto

```text
Diseña un cambio pequeño para registrar decisiones del Manager en un archivo de log. Modo read-only: no modifiques archivos, no escribas código, no cambies configuración. Solo ejecuta el flujo de decisión y documenta qué ruta tomarías.
```

### Resultado observado

Manager clasificó el request como Small/Medium estructurado. En modo read-only, puede proponer ruta SDD sin violar reglas y sin ejecutar implementación. El bloqueo anterior “MUST NOT invoke gentle-orchestrator” ya no apareció.

### Validación

| Métrica | Resultado | Estado |
|---|---|---|
| Manager clasifica | Sí: Small/Medium estructurado | VALIDADO |
| Puede proponer gentle-orchestrator | Sí | VALIDADO |
| Regla conflictiva antigua aparece | No | VALIDADO |
| Escritura funcional | No | VALIDADO |
| Código/config modificados | No | VALIDADO |
| Loop | No | VALIDADO |

### Estado

PASSED

## D-T5-pipeline-dry-run — gentle-orchestrator SDD Pipeline

### Input exacto

```text
Ejecuta un dry-run del pipeline SDD para un cambio ficticio llamado TEST-D-SDD-ROUTING. No modifiques archivos reales. No escribas código. Devuelve solo el envelope compacto con fases esperadas, riesgos y próxima acción.
```

### Output observado

```json
{
  "status": "success",
  "pipeline": "sdd",
  "phase_summary": {
    "explore": "dry-run simulated; no artifacts written",
    "propose": "dry-run simulated; no artifacts written",
    "spec": "dry-run simulated; no artifacts written",
    "design": "dry-run simulated; no artifacts written",
    "tasks": "dry-run simulated; no artifacts written",
    "apply": "skipped by constraint: no code or file changes",
    "verify": "dry-run simulated; no tests executed",
    "archive": "skipped by constraint: no artifact writes"
  },
  "decisions": [
    "Simulated SDD routing for fictitious change TEST-D-SDD-ROUTING without delegation or writes"
  ],
  "risks": [],
  "artifacts": [],
  "next_recommended_action": "Dry-run complete; no further action"
}
```

### Validación

| Métrica | Resultado | Estado |
|---|---|---|
| Manager invoca gentle-orchestrator | Sí, vía subagent task | VALIDADO |
| gentle responde como primary | No | VALIDADO |
| Envelope compacto | Sí | VALIDADO |
| sdd-* ejecuta cambios reales | No | VALIDADO |
| Escritura funcional | No | VALIDADO |
| MCP innecesario | No | VALIDADO |
| Memoria innecesaria | No | VALIDADO |
| Loop Manager → gentle → Manager | No | VALIDADO |

### Estado

PASSED

## D-T3 — Docs

### Input exacto

```text
Busca en la documentación de arquitectura cuál es el rol objetivo de gentle-orchestrator.
```

### Resultado observado

Manager usó Markdown docs (`10-target-architecture.md`, `ADR-003-gentle-orchestrator-role.md`, `17-manager-gentle-transition-plan.md`) y respondió que `gentle-orchestrator` es un SDD Pipeline invocable por Manager, no primary ni router general.

### Validación

| Métrica | Resultado | Estado |
|---|---|---|
| Usa Markdown docs | Sí | VALIDADO |
| Responde rol objetivo | Sí: SDD Pipeline invocable | VALIDADO |
| MCP externo | No | VALIDADO |
| Memoria innecesaria | No | VALIDADO |
| SDD | No | VALIDADO |
| Subagentes | No | VALIDADO |

### Estado

PASSED

## Criterio para cerrar D4

D4 queda completado: D-T1, D-T5-read-only, D-T5-pipeline-dry-run y D-T3 pasaron. No hubo loop ni escritura funcional.
