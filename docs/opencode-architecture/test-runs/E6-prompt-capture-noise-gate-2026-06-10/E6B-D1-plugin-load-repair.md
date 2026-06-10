# E6B-D1 — Plugin Load Repair

> Reparación controlada para restaurar la carga del plugin OpenCode de Engram antes de ejecutar E6B-T1..T7.

**Estado:** ❌ NO-GO — plugin oficial no carga post-restart  
**Fecha:** 2026-06-10  
**Modo:** reparación controlada con backups y rollback

---

## Objetivo

Confirmar si el plugin oficial de Engram para OpenCode carga y si el hook `chat.message` vuelve a persistir prompts útiles en `user_prompts`.

E6B-D0 confirmó que:

- Engram MCP funciona.
- `mem_context` funciona.
- El archivo activo contenía Noise Gate.
- Una pregunta útil no aumentó `user_prompts`.
- Por lo tanto, el problema está en carga/runtime/hook del plugin OpenCode, no en Engram MCP.

---

## Backups creados

Backup local timestamp:

```text
C:\Users\harry\AppData\Local\Temp\opencode\E6B-D1-backups\20260610-130511
```

| Archivo | Estado backup |
|---------|---------------|
| `C:\Users\harry\.config\opencode\plugins\engram.ts` | ✅ respaldado |
| `C:\Users\harry\.config\opencode\opencode.json` | ✅ respaldado |
| `C:\Users\harry\.config\opencode\opencode.jsonc` | ✅ respaldado |
| `C:\Users\harry\.config\opencode\tui.json` | ✅ respaldado |
| `C:\Users\harry\.config\opencode\tui.jsonc` | N/A — no existía |

No se imprimió contenido sensible en el reporte.

---

## Binario Engram usado

Comando explícito:

```powershell
& "C:\Users\harry\AppData\Local\engram\bin\engram.exe" --version
```

Resultado:

```text
engram 1.16.1
```

No se usó `engram` por PATH para la reparación, porque PATH resuelve a v1.15.13.

---

## Setup oficial OpenCode

Comando intentado primero:

```powershell
& "C:\Users\harry\AppData\Local\engram\bin\engram.exe" setup opencode --help
```

Resultado observado:

```text
✓ Installed opencode plugin (3 files)
  → C:\Users\harry\.config\opencode\plugins

Next steps:
  1. Restart OpenCode — plugin + MCP server are ready
  2. The plugin auto-starts the Engram HTTP server when needed

Also enabled: opencode-subagent-statusline in tui.json — sub-agent activity in the sidebar/footer.
```

Interpretación: `setup opencode --help` no mostró ayuda/dry-run; ejecutó setup real. Esto fue seguro porque los backups ya existían.

---

## Cambios detectados post-setup

| Archivo | Cambió | Detalle |
|---------|:------:|---------|
| `plugins/engram.ts` | ✅ Sí | Reemplazado por plugin oficial Engram v1.16.1; Noise Gate removido temporalmente |
| `opencode.json` | ❌ No | Sin cambios vs backup D1 |
| `opencode.jsonc` | ❌ No | Sin cambios vs backup D1 |
| `tui.json` | ❌ No | Sin cambios vs backup D1 |
| `tui.jsonc` | N/A | No existía |

Resumen diff no sensible:

| Archivo | Líneas backup | Líneas actual | Entradas diff |
|---------|--------------:|--------------:|--------------:|
| `engram.ts` | 561 | 449 | 174 |
| `opencode.json` | 236 | 236 | 0 |
| `opencode.jsonc` | 31 | 31 | 0 |
| `tui.json` | 8 | 8 | 0 |

---

## Estabilización E4B

Se verificó que `opencode.json` y `opencode.jsonc` mantienen:

```json
"command": [
  "C:\\Users\\harry\\AppData\\Local\\engram\\bin\\engram.exe",
  "mcp",
  "--tools=agent",
  "--project=opencode-architecture"
]
```

No fue necesario reaplicar E4B.

---

## Estado del plugin oficial instalado

El plugin oficial actual contiene el hook:

```text
chat.message
```

Y ya no contiene:

```text
ALLOW_PROMPT_CAPTURE
classifyPrompt
Noise Gate
```

Esto es intencional para separar problemas:

1. Primero validar plugin loading / hook oficial.
2. Después reimplementar Noise Gate si el hook oficial funciona.

### Riesgo técnico detectado

El plugin oficial instalado contiene referencias a `Bun`:

```text
Bun.which("engram")
Bun.spawnSync(...)
Bun.spawn(...)
Bun.file(...)
```

Los logs recientes de OpenCode ya muestran errores `Bun is not defined` para otro plugin global (`background-agents.ts`). Por lo tanto, existe riesgo alto de que el plugin oficial de Engram también falle al cargar en el runtime actual si OpenCode no provee `Bun`.

Este riesgo todavía requiere confirmación post-restart mediante logs y test positivo.

---

## Estado de `background-agents.ts`

Hallazgo read-only:

- `background-agents.ts` está en la misma carpeta global de plugins.
- Logs recientes reportan: `Bun is not defined failed to load plugin`.
- No se desactivó ni renombró.

Pendiente confirmar si un fallo en `background-agents.ts` aborta todo el plugin loader o si OpenCode aísla cada plugin.

---

## Resultado post-restart

Después de reiniciar OpenCode se midió baseline:

| Métrica | Valor |
|---------|------:|
| `user_prompts` | 302 |
| `observations` | 303 |
| último `user_prompt.created_at` | `2026-06-10 14:00:40` |
| último `user_prompt.project` | `opencode-architecture` |

Logs recientes (`C:\Users\harry\.local\share\opencode\log\2026-06-10T170944.log`) confirmaron fallo de carga:

```text
service=plugin path=file:///C:/Users/harry/.config/opencode/plugins/engram.ts error=Bun is not defined failed to load plugin
service=plugin path=file:///C:/Users/harry/.config/opencode/plugins/background-agents.ts error=Bun is not defined failed to load plugin
```

Interpretación:

- El plugin oficial de Engram sí es descubierto por OpenCode.
- El loader intenta cargar `engram.ts`.
- Falla antes de registrar hooks por dependencia runtime a `Bun`.
- Por eso `chat.message` no puede capturar prompts.

No se pidió el input positivo porque el plugin no llegó a cargar.

---

## Próximo paso recomendado

NO-GO para E6B-T1..T7.

Proponer reparación mínima Node-compatible en `plugins/engram.ts`:

- Reemplazar `Bun.which("engram")` por resolución explícita/constante al binario `C:\Users\harry\AppData\Local\engram\bin\engram.exe`.
- Reemplazar `Bun.spawnSync` por `execFileSync` o `spawnSync` de `node:child_process`.
- Reemplazar `Bun.spawn` por `spawn` de `node:child_process`.
- Reemplazar `Bun.file(...).exists()` por `existsSync` de `node:fs`.
- Mantener `chat.message` oficial sin Noise Gate hasta confirmar captura.
- No tocar schema DB ni MCP config.

Después de esa reparación:

1. Reiniciar OpenCode.
2. Confirmar logs sin error `engram.ts`.
3. Medir baseline.
4. Pedir input positivo.
5. Validar que `user_prompts` aumenta +1.

---

## Plan anterior reemplazado

El plan anterior era:

Reiniciar OpenCode para cargar el plugin oficial recién instalado.

Después del restart:

1. Medir baseline de `user_prompts` y `observations`.
2. Enviar input positivo:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

3. Medir si `user_prompts` aumenta +1 y si `project = opencode-architecture`.

---

Este plan queda bloqueado hasta reparar `Bun is not defined` en el plugin de Engram.

---

## Criterios de decisión

| Resultado post-restart | Decisión |
|------------------------|----------|
| Pregunta útil aumenta `user_prompts` | GO para reimplementar Noise Gate sobre plugin oficial actual |
| Pregunta útil no aumenta `user_prompts` | NO-GO para E6B; diagnosticar plugin discovery/runtime |
| Logs muestran `Bun is not defined` en `engram.ts` | Proponer diff mínimo Node-compatible antes de reintentar |
| Logs muestran fallo en `background-agents.ts` y Engram no carga | Proponer desactivación temporal controlada de `background-agents.ts` con rollback |

---

## Qué NO se modificó

- No se tocó `config.toml` de Codex.
- No se tocó la DB Engram.
- No se limpiaron prompts.
- No se mataron procesos.
- No se ejecutaron E6B-T1..T7.
- No se reimplementó Noise Gate todavía.
- No se desactivó `background-agents.ts`.
