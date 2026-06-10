# E6B-D2 — Node-compatible Plugin Patch

> Patch mínimo para que el plugin oficial de Engram cargue en el runtime OpenCode actual sin depender de `Bun.*`.

**Estado:** ❌ NO-GO — patch removió error `Bun` en Engram, pero `chat.message` no capturó prompt útil  
**Fecha:** 2026-06-10  
**Archivo modificado:** `C:\Users\harry\.config\opencode\plugins\engram.ts`

---

## Objetivo

Hacer que el plugin oficial `engram.ts` cargue correctamente en OpenCode reemplazando dependencias de `Bun.*` por APIs Node equivalentes.

Esta fase **NO** reimplementa Noise Gate. Primero se valida que el plugin oficial carga y que `chat.message` vuelve a capturar prompts útiles.

---

## Backup pre-patch

Backup creado:

```text
C:\Users\harry\.config\opencode\plugins\engram.ts.e6b-d2-backup
```

Estado pre-patch:

| Métrica | Valor |
|---------|-------|
| Tamaño | 17,858 bytes |
| Fecha modificación | `2026-06-10 13:05:30` |
| SHA256 | `94D5FB7BB0AD17142FEB5E00C884C51C2C416A45E091DD2D47620A7D6D039118` |

---

## Diff conceptual aplicado

### Imports agregados

```ts
import { spawn, spawnSync } from "node:child_process"
import { existsSync } from "node:fs"
```

### `ENGRAM_BIN`

Se removió resolución por `Bun.which("engram")` y se fijó ruta local v1.16.1 como fallback:

```ts
const ENGRAM_BIN = process.env.ENGRAM_BIN ?? "C:\\Users\\harry\\AppData\\Local\\engram\\bin\\engram.exe"
```

Motivo: evitar drift hacia PATH, que resuelve a Engram v1.15.13.

### `Bun.spawnSync` → `spawnSync`

Reemplazado en:

- `git -C <directory> remote get-url origin`
- `git -C <directory> rev-parse --show-toplevel`

Usa:

```ts
spawnSync("git", [...], { encoding: "utf8" })
```

### `Bun.spawn` → `spawn`

Reemplazado en:

- arranque de `engram serve`
- `engram sync --import`

Usa:

```ts
const child = spawn(ENGRAM_BIN, ["serve"], {
  stdio: "ignore",
  detached: true,
  windowsHide: true,
})
child.unref()
```

### `Bun.file(...).exists()` → `existsSync`

Reemplazado en detección de:

```text
.engram/manifest.json
```

---

## Validaciones pre-restart

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| Backup creado | ✅ PASS | `engram.ts.e6b-d2-backup` con mismo hash pre-patch |
| `Bun.*` removido de `engram.ts` | ✅ PASS | grep no encontró `Bun.` ni `Bun` |
| Noise Gate no reimplementado | ✅ PASS | no se agregó `ALLOW_PROMPT_CAPTURE` ni `classifyPrompt()` |
| Scope respetado | ✅ PASS | solo se modificó `plugins/engram.ts` |
| TypeScript/sintaxis | ⚠️ LIMITADO | `tsc` parseó, pero falló por falta de `@types/node` (`node:child_process`, `node:fs`, `process`) |

Estado post-patch:

| Métrica | Valor |
|---------|-------|
| Tamaño | 17,981 bytes |
| Fecha modificación | `2026-06-10 13:46:48` |
| SHA256 | `E78495AE223E07AF8A9D636167ECA38C016A89F6A1396F62AA147941E0E0E6C2` |
| Entradas diff vs backup D2 | 41 |
| Líneas pre-patch | 449 |
| Líneas post-patch | 456 |

---

## Resultado post-restart

Después de reiniciar OpenCode se observó:

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| `engram.ts` sin `Bun is not defined` | ✅ PASS | log nuevo `2026-06-10T175421.log` no muestra error de `engram.ts` |
| `background-agents.ts` sin `Bun is not defined` | ❌ FAIL | sigue fallando como riesgo separado |
| Baseline `user_prompts` | 302 | antes del input positivo |
| Baseline `observations` | 303 | antes del input positivo |
| Pregunta útil aumenta `user_prompts` | ❌ FAIL | después del input positivo, `user_prompts` siguió en 302 |
| Último `user_prompt` | sin cambios | `2026-06-10 14:00:40`, length 13, project `opencode-architecture` |

Input positivo usado:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

Resultado:

```text
user_prompts: 302 → 302
```

Interpretación:

- D2 solucionó el fallo visible `Bun is not defined` para `engram.ts`.
- OpenCode ya no reporta error de carga para `engram.ts` en el log nuevo.
- Pero `chat.message` no confirmó captura.
- No hay nueva sesión real registrada en `sessions` para esta conversación post-restart.
- Por lo tanto, sigue bloqueado ejecutar E6B-T1..T7.

---

## Próximo diagnóstico propuesto

NO seguir parchando sin aprobación.

Hipótesis a investigar en una siguiente subfase:

1. El plugin carga pero los hooks no se registran por forma de export (`export const Engram` vs `export default`).
2. El hook `chat.message` cambió de contrato/API o no se dispara en este runtime.
3. `output.parts` ya no contiene el texto esperado y el hook falla silenciosamente.
4. `background-agents.ts` no bloquea el loader completo, pero puede estar ensuciando el diagnóstico.
5. El plugin se descubre pero no se activa para la sesión actual/reanudada.

Diff mínimo candidato para próxima aprobación:

- Confirmar contrato de export del plugin y, si corresponde, agregar `export default Engram` sin cambiar lógica.
- Opcionalmente agregar instrumentación temporal mínima no sensible para probar si `chat.message` se ejecuta.

---

## Plan anterior reemplazado

El plan anterior era:

Después de reiniciar OpenCode:

1. Revisar logs recientes.
2. Confirmar que **no** aparece:

```text
engram.ts error=Bun is not defined failed to load plugin
```

3. Medir baseline:

```text
COUNT user_prompts
COUNT observations
último user_prompt.created_at
project
```

4. Pedir input positivo:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

5. Confirmar si `user_prompts` aumenta +1 con `project = opencode-architecture` y `length > 10`.

---

Ese plan quedó ejecutado con resultado NO-GO.

---

## Criterios de decisión

| Resultado | Decisión |
|-----------|----------|
| Plugin carga y pregunta útil aumenta `user_prompts` | GO para E6B-D3: reimplementar Noise Gate sobre plugin Node-compatible |
| Plugin carga pero pregunta útil no aumenta | ❌ Resultado actual: NO-GO; investigar hook `chat.message` / API plugin |
| Plugin sigue fallando por `Bun is not defined` | NO-GO: revisar cache/plugin reload o fuente alternativa |
| `background-agents.ts` sigue fallando | Documentar riesgo separado; no mezclar salvo que bloquee Engram |

---

## Qué NO se modificó

- No se tocó `background-agents.ts`.
- No se tocó `opencode.json`.
- No se tocó `opencode.jsonc`.
- No se tocó `config.toml`.
- No se tocó `AGENTS.md`.
- No se tocó DB Engram.
- No se limpiaron prompts.
- No se implementó Noise Gate.
- No se modificó schema.
