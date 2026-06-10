# E6B-D3 — Hook / Export Diagnostic

> Diagnóstico mínimo para confirmar contrato de export y ejecución del hook `chat.message` en el plugin OpenCode de Engram.

**Estado:** ❌ NO-GO — hook ejecuta y extrae contenido, pero POST `/prompts` responde HTTP 400  
**Fecha:** 2026-06-10  
**Archivo modificado:** `C:\Users\harry\.config\opencode\plugins\engram.ts`

---

## Objetivo

Confirmar si el plugin carga realmente, si `chat.message` entra, si el payload tiene la forma esperada, si se extrae contenido con longitud útil y si el POST `/prompts` se intenta.

Esta fase **NO** reimplementa Noise Gate.

---

## Evidencia de contrato local

El paquete local `@opencode-ai/plugin` define:

```ts
export type Plugin = (input: PluginInput, options?: PluginOptions) => Promise<Hooks>

"chat.message"?: (input: {
  sessionID: string
  agent?: string
  model?: { providerID: string; modelID: string }
  messageID?: string
  variant?: string
}, output: {
  message: UserMessage
  parts: Part[]
}) => Promise<void>
```

Hallazgo local adicional: otros plugins globales (`model-variants.ts`, `background-agents.ts`) tienen `export default ...`. Por compatibilidad, D3 agrega `export default Engram` manteniendo `export const Engram`.

---

## Backup pre-D3

Backup creado:

```text
C:\Users\harry\.config\opencode\plugins\engram.ts.e6b-d3-backup
```

Estado pre-D3:

| Métrica | Valor |
|---------|-------|
| Tamaño | 17,981 bytes |
| Fecha modificación | `2026-06-10 13:46:48` |
| SHA256 | `E78495AE223E07AF8A9D636167ECA38C016A89F6A1396F62AA147941E0E0E6C2` |

---

## Diff diagnóstico aplicado

### Export compatible

Se agregó:

```ts
export default Engram
```

Se mantiene:

```ts
export const Engram: Plugin = async (ctx) => { ... }
```

### Instrumentación temporal segura

Se agregó escritura a:

```text
C:\Users\harry\.config\opencode\plugins\engram-debug.log
```

Formato:

```text
timestamp | event | metadata no sensible
```

Eventos esperados:

- `module.loaded`
- `loaded`
- `chat.message entered`
- `finalContent length`
- `prompt capture attempted`
- `prompt capture http.response`
- `prompt capture http.error`
- `prompt capture result`
- `prompt capture skipped`

No se registra contenido del prompt. Solo claves, conteos, booleanos, longitudes y status HTTP.

### Shape defensivo del hook

Se cambió la extracción para no fallar si `output.parts` o `output.message` cambian de forma:

```ts
const parts = Array.isArray(output?.parts) ? output.parts : []
const summary = (output?.message as any)?.summary
```

---

## Validaciones pre-restart

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| Backup D3 creado | ✅ PASS | `engram.ts.e6b-d3-backup` |
| `export default Engram` agregado | ✅ PASS | línea final del plugin |
| Instrumentación sin prompt content | ✅ PASS | solo eventos/counts/length/status; no valores de texto |
| Noise Gate no reimplementado | ✅ PASS | no existe `ALLOW_PROMPT_CAPTURE` ni `classifyPrompt()` |
| TypeScript/sintaxis | ⚠️ LIMITADO | `tsc` sigue fallando por falta de `@types/node`, no por el diagnóstico |

Estado post-patch:

| Métrica | Valor |
|---------|-------|
| Tamaño | 19,711 bytes |
| Fecha modificación | `2026-06-10 14:02:45` |
| SHA256 | `2DFC2DE3DC7F5152BACA87AAA405F5992CFE84EF4CF9D8FB63DED720CE052525` |
| Entradas diff vs backup D3 | 55 |
| Líneas post-D3 | 499 |

---

## Resultado post-restart

Después de reiniciar OpenCode se observó:

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| `module.loaded` aparece | ✅ PASS | `engram-debug.log` línea 1 |
| `loaded` aparece | ✅ PASS | múltiples contextos cargados, incluido `opencode-architecture` |
| `chat.message entered` aparece | ✅ PASS | líneas 16 y 19 |
| `output.parts` existe | ✅ PASS | `partsCount=1` |
| Input corto se saltea | ✅ PASS | `reiniciado` produjo `finalContent length=10` y `too_short` |
| Pregunta útil extrae contenido | ✅ PASS | `finalContent length=44` |
| POST `/prompts` se intenta | ✅ PASS | `prompt capture attempted` |
| POST `/prompts` responde OK | ❌ FAIL | `prompt capture http.response | ok=false status=400` |
| `user_prompts` aumenta con pregunta útil | ❌ FAIL | 303 → 303 |

Input positivo usado:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

Conteo posterior:

```text
user_prompts: 303 → 303
observations: 303
```

Último `user_prompt` no corresponde a la pregunta positiva: quedó un registro previo de otro proyecto (`retail-masivo-oc`, length 323). La pregunta positiva no se persistió.

---

## Diagnóstico

D3 descarta:

- plugin no cargado;
- export contract roto;
- hook `chat.message` no disparado;
- payload sin `parts`;
- extracción de contenido en cero.

D3 identifica la falla en:

```text
POST /prompts → HTTP 400
```

La causa exacta del 400 aún no se confirmó porque la instrumentación D3 solo registró status HTTP, no body de error.

Hipótesis más probables:

1. `ensureSession(sessionId)` no crea/valida sesión correctamente antes de `/prompts`.
2. El endpoint `/prompts` de Engram v1.16.1 espera contrato diferente al `{ session_id, content, project }` actual.
3. `project` derivado por instancia plugin puede no coincidir con el project MCP explícito.
4. El servidor HTTP Engram que atiende `7437` no es el esperado o no coincide con el esquema actual.

---

## Próximo paso propuesto

No seguir parcheando sin aprobación.

Subfase sugerida: **E6B-D4 — `/prompts` HTTP contract diagnostic**, read-only/minimal instrumentation:

- Loguear status de `ensureSession` (`/sessions`) sin contenido sensible.
- Loguear status y body de error sanitizado de `/prompts` si HTTP 400.
- Confirmar server `/health` y versión si endpoint existe.
- No guardar prompt content.
- No reimplementar Noise Gate todavía.

---

## Plan anterior reemplazado

El plan anterior era:

1. Reiniciar OpenCode.
2. Revisar logs de OpenCode y `engram-debug.log`.
3. Medir baseline `user_prompts` / `observations`.
4. Pedir input positivo:

1. Reiniciar OpenCode.
2. Revisar logs de OpenCode y `engram-debug.log`.
3. Medir baseline `user_prompts` / `observations`.
4. Pedir input positivo:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

5. Medir si `user_prompts` aumenta.

Ese plan fue ejecutado con resultado NO-GO por HTTP 400.

---

## Interpretación esperada

| Caso | Señal | Interpretación |
|------|-------|----------------|
| A | no aparece `module.loaded` / `loaded` | plugin no carga realmente |
| B | aparece `loaded`, no `chat.message entered` | plugin carga, hook no dispara |
| C | `chat.message entered`, `finalContent length=0` | extraction/payload shape incorrecto |
| D | `finalContent length>10`, POST intenta, DB no cambia | ✅ Resultado actual: revisar HTTP `/prompts` / server / endpoint |
| E | DB aumenta | GO para D4 Noise Gate sobre plugin funcionando |

---

## Qué NO se modificó

- No se reimplementó Noise Gate.
- No se tocó DB.
- No se tocó `opencode.json` / `opencode.jsonc`.
- No se tocó `config.toml`.
- No se tocó `AGENTS.md`.
- No se tocó `background-agents.ts`.
- No se tocó MCP surface, skills, Manager ni gentle.
