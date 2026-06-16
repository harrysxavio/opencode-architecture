# E6B-D4 — `/prompts` HTTP Contract Diagnostic

> Diagnóstico temporal y seguro para aislar por qué `chat.message` llega a POST `/prompts`, pero Engram responde HTTP 400.

**Estado:** ❌ NO-GO — `/prompts` falla por `session_project_mismatch`  
**Fecha:** 2026-06-10  
**Archivo modificado:** `C:\Users\harry\.config\opencode\plugins\engram.ts`

---

## Objetivo

Validar en orden:

1. Si `ensureSession()` se ejecuta antes de `/prompts`.
2. Si POST `/sessions` responde OK o falla.
3. Si `sessionID` está presente y con longitud esperada.
4. Si `project` enviado a `/sessions` y `/prompts` coincide.
5. Si `/prompts` falla por contrato HTTP en Engram v1.16.1.
6. Si `engramFetch` ocultaba body de error.

---

## Backup pre-D4

Backup creado:

```text
C:\Users\harry\.config\opencode\plugins\engram.ts.e6b-d4-backup
```

Estado pre-D4:

| Métrica | Valor |
|---------|-------|
| Tamaño | 19,711 bytes |
| Fecha modificación | `2026-06-10 14:02:45` |
| SHA256 | `2DFC2DE3DC7F5152BACA87AAA405F5992CFE84EF4CF9D8FB63DED720CE052525` |

---

## Instrumentación aplicada

Se extendió `engramFetch()` para endpoints:

- `/sessions`
- `/prompts`

Logs seguros agregados:

```text
/sessions request endpoint=/sessions sessionLen=N sessionPrefix=abcdef project=... directoryBase=...
/sessions response ok=true|false status=N body=[omitted-ok]|<sanitized>
/prompts request endpoint=/prompts sessionLen=N sessionPrefix=abcdef project=... contentLength=N
/prompts response ok=true|false status=N body=[omitted-ok]|<sanitized>
ensureSession start sessionLen=N sessionPrefix=abcdef project=...
ensureSession result ok=true|false markedKnownBeforeSuccess=true
```

No se registra contenido del prompt.

### Sanitización

`sanitizeDebugBody()`:

- remueve `<private>...</private>`;
- reemplaza campos `content` por `[REDACTED]`;
- redacted parcial para `session_id` / `id`;
- trunca body a 300 caracteres.

### Punto crítico instrumentado

Se confirmó por código que `knownSessions.add(sessionId)` ocurre antes de confirmar éxito HTTP de `/sessions`.

D4 **no cambia esa lógica**; solo agrega:

```text
markedKnownBeforeSuccess=true
```

para poder confirmar si esto contribuye al HTTP 400.

---

## Validaciones pre-restart

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| Backup D4 creado | ✅ PASS | `engram.ts.e6b-d4-backup` |
| Noise Gate no agregado | ✅ PASS | no existe `ALLOW_PROMPT_CAPTURE` ni `classifyPrompt()` |
| No prompt content en logs | ✅ PASS | solo `contentLength`, no texto |
| Status/body sanitizado agregado | ✅ PASS | `/sessions response`, `/prompts response` |
| TypeScript/sintaxis | ⚠️ LIMITADO | `tsc` sigue fallando por falta de `@types/node` |

Estado post-patch:

| Métrica | Valor |
|---------|-------|
| Tamaño | 21,717 bytes |
| Fecha modificación | `2026-06-10 14:54:01` |
| SHA256 | `9D1F0407B4C58788D751258E24186E0214ACF85376AC448A685B9A3FC64B7645` |
| Entradas diff vs backup D4 | 61 |
| Líneas post-D4 | 546 |

---

## Resultado post-restart

Después de reiniciar OpenCode se midió baseline:

| Métrica | Valor |
|---------|------:|
| `user_prompts` | 305 |
| `observations` | 305 |
| último `user_prompt.project` | `retail-masivo-oc` |

Input positivo usado:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

Resultado:

```text
user_prompts: 305 → 305
```

### Logs seguros D4

`engram-debug.log` reportó:

```text
ensureSession start | sessionLen=30 sessionPrefix=ses_15 project=opencode-architecture
/sessions request | endpoint=/sessions sessionLen=30 sessionPrefix=ses_15 project=opencode-architecture directoryBase=ARQUITECTURA OPENCODE
/sessions response | ok=true status=201 body=[omitted-ok]
ensureSession result | ok=true markedKnownBeforeSuccess=true
chat.message entered | hasSessionID=true ... partsCount=1
finalContent length | length=44
prompt capture attempted | length=44 sessionLen=30 sessionPrefix=ses_15 project=opencode-architecture
/prompts request | endpoint=/prompts sessionLen=30 sessionPrefix=ses_15 project=opencode-architecture contentLength=44
/prompts response | ok=false status=400 body={"code":"session_project_mismatch","error":"session project does not match requested project","project":"opencode-architecture","session_project":"arquitectura opencode"}
```

### DB evidence

Consulta read-only a `sessions` confirmó sesiones `ses_15...` en la misma carpeta con:

```text
project = arquitectura opencode
directory = C:\Users\harry\OneDrive\Documentos\GitHub\ARQUITECTURA OPENCODE
```

---

## Diagnóstico

D4 confirma H4:

```text
project de la sesión y project del prompt no coinciden
```

El hook actual usa:

```text
project = opencode-architecture
```

pero la sesión existente para el mismo `sessionID` está registrada como:

```text
session_project = arquitectura opencode
```

Engram rechaza correctamente el write para evitar mezclar prompts en una sesión de otro proyecto:

```text
HTTP 400 session_project_mismatch
```

Esto explica por qué:

- plugin carga;
- hook entra;
- contenido se extrae;
- POST se intenta;
- DB no aumenta.

---

## Diff mínimo propuesto para D5

No aplicar todavía sin aprobación.

Opción recomendada: **resolver mismatch antes de POST `/prompts`**.

Posibles enfoques:

### Opción A — Reconciliar sesión existente al project actual

Antes de guardar prompt, si `/prompts` responde `session_project_mismatch`, llamar endpoint de migración o crear mecanismo equivalente para mover esa sesión/proyecto al project canónico.

Riesgo: puede alterar histórico si la sesión realmente pertenecía a otro proyecto.

### Opción B — Usar el `session_project` devuelto por Engram para ese prompt

Si `/prompts` devuelve `session_project`, reintentar con ese project.

Riesgo: mantiene drift histórico (`arquitectura opencode`) y no cumple E4B canonicalización.

### Opción C — Nueva sesión para project canónico

Si hay mismatch, no persistir prompt en esa sesión y registrar diagnóstico; pedir nueva sesión limpia para validar captura con `opencode-architecture`.

Riesgo: no arregla sesiones existentes, pero es el más seguro para no mezclar proyectos.

### Opción D — Cambiar `knownSessions.add()` después de éxito real + detectar mismatch

Mover `knownSessions.add(sessionId)` después de confirmar `/sessions` OK y, si `/prompts` devuelve `session_project_mismatch`, remover `knownSessions` para permitir recuperación.

Riesgo: no corrige por sí solo una sesión ya existente con otro project.

### Recomendación

Para D5, hacer **diagnóstico/fix seguro de project drift**:

1. No reintentar con `session_project` automáticamente.
2. Detectar `session_project_mismatch` explícitamente.
3. No marcar sesión como válida si hay mismatch.
4. Probar en una sesión limpia o con migración controlada aprobada.

---

## Plan anterior reemplazado

El plan anterior era:

1. Reiniciar OpenCode.
2. Medir baseline `user_prompts` / `observations`.
3. Pedir input positivo:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

4. Leer `engram-debug.log`.
5. Identificar:
   - status `/sessions`;
   - status `/prompts`;
   - body de error sanitizado;
   - `sessionLen`;
   - `project` usado;
   - si `knownSessions` fue marcado antes de éxito real.

Ese plan se ejecutó y aisló `session_project_mismatch`.

---

## Criterios de interpretación

| Caso | Señal | Decisión |
|------|-------|----------|
| A | `/sessions` falla | Proponer D5 para crear sesión correctamente antes de prompt |
| B | `/sessions` OK, `/prompts` falla por session/project | ✅ Resultado actual: proponer diff mínimo de project/session consistency |
| C | `/prompts` falla por contrato | Comparar body esperado en Engram v1.16.1 |
| D | `/prompts` falla por content vacío | No aplica si `contentLength > 10`; corregir extraction en D5 si ocurre |
| E | `/prompts` responde OK y DB aumenta | GO para reimplementar Noise Gate en una fase posterior |

---

## Qué NO se modificó

- No se reimplementó Noise Gate.
- No se tocó schema.
- No se limpió DB.
- No se modificaron prompts históricos.
- No se tocó `opencode.json` / `opencode.jsonc`.
- No se tocó `config.toml`.
- No se tocó `AGENTS.md`.
- No se tocó `background-agents.ts`.
- No se tocó MCP, skills, Manager ni gentle.
