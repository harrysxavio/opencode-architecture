# E6B-D5 — Resolver session/project mismatch

> Diagnóstico y validación controlada para el error `session_project_mismatch` sin migrar DB ni mezclar proyectos.

**Estado:** ✅ D5B PASS — sesión limpia captura correctamente con `opencode-architecture`  
**Fecha:** 2026-06-16  
**Modo:** read-only + test en sesión limpia; sin migración

---

## Objetivo

Resolver de forma segura el bloqueo:

```text
session_project = arquitectura opencode
requested project = opencode-architecture
```

sin borrar datos, sin migrar proyectos a ciegas y sin reimplementar Noise Gate todavía.

---

## D5A — Diagnóstico read-only

### Conteo por project

| Entidad | `arquitectura opencode` | `opencode-architecture` | Nota |
|---------|------------------------:|-------------------------:|------|
| `sessions` | 11 | 7 | Ambos projects existen; legacy conserva sesiones antiguas |
| `user_prompts` | 26 | 1 | La captura histórica está mayormente en project legacy |
| `observations` | 2 | 24 | Las memorias gobernadas actuales están en project canónico |

### Session actual / legacy

| Campo | Valor |
|-------|-------|
| `sessionID length` | 30 |
| `sessionPrefix` | `ses_15` |
| `session_project` | `arquitectura opencode` |
| `requested_project` | `opencode-architecture` |
| `mismatch` | `true` |
| `created_at` | no se imprime ID completo; las sesiones `ses_15...` de esta carpeta son 2026-06-09 / 2026-06-10 02:37:24 como máximo |
| `probable origen` | sesión legacy creada antes de E4B / antes de canonicalizar `--project=opencode-architecture` |

Consulta read-only confirmó que las sesiones `ses_15...` asociadas a `ARQUITECTURA OPENCODE` están en:

```text
project = arquitectura opencode
```

### Comportamiento `/sessions`

D4 mostró:

```text
/sessions response ok=true status=201
/prompts response ok=false status=400 session_project_mismatch
```

Interpretación: `/sessions` se comporta como insert/idempotent/no-update para sesiones existentes. Aunque el plugin hace POST `/sessions` con `opencode-architecture`, la sesión existente conserva `arquitectura opencode`, y `/prompts` rechaza el write.

---

## D5A — Conclusión

La causa raíz queda cerrada como:

```text
La sesión actual es legacy y está asociada a arquitectura opencode.
El plugin actual usa el project canónico opencode-architecture.
Engram rechaza /prompts para evitar mezclar proyectos en una sesión existente.
```

Esto es correcto desde el punto de vista de integridad de datos.

---

## D5B — Test con sesión limpia

Completado.

Procedimiento:

1. Cerrar el chat/sesión actual de OpenCode.
2. Abrir una sesión nueva en el mismo repo `ARQUITECTURA OPENCODE`.
3. Confirmar que el plugin carga.
4. Medir baseline `user_prompts` / `observations`.
5. Enviar:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

6. Verificar si:
   - la nueva sesión se crea con `project = opencode-architecture`;
   - `/prompts` responde OK;
   - `user_prompts` aumenta +1.

### Resultado D5B

| Validación | Resultado | Evidencia |
|-----------|:---------:|----------|
| Nueva sesión creada con project canónico | ✅ PASS | sesión `ses_12...` en `opencode-architecture` |
| `/sessions` en sesión limpia | ✅ PASS | `status=201` |
| `/prompts` para `sesión nueva` | ✅ PASS | `status=201`, `contentLength=12` |
| `/prompts` para pregunta positiva | ✅ PASS | `status=201`, `contentLength=44` |
| `user_prompts` aumenta | ✅ PASS | `307 → 308` para pregunta positiva |
| Project del prompt positivo | ✅ PASS | `opencode-architecture` |

Prompt positivo validado:

```text
¿Qué rol cumple Engram en esta arquitectura?
```

DB read-only confirmó nuevo registro:

```text
created_at = 2026-06-16 15:09:44
length = 44
project = opencode-architecture
```

Logs seguros:

```text
chat.message entered ... partsCount=1
finalContent length | length=44
prompt capture attempted | length=44 sessionLen=30 sessionPrefix=ses_12 project=opencode-architecture
/prompts request | endpoint=/prompts sessionLen=30 sessionPrefix=ses_12 project=opencode-architecture contentLength=44
/prompts response | ok=true status=201 body=[omitted-ok]
prompt capture result | ok=true
```

---

## D5 — Conclusión final

D5 confirma que:

```text
El plugin funciona correctamente en sesión limpia con project canónico.
El bloqueo anterior estaba limitado a la sesión legacy asociada a arquitectura opencode.
```

No hace falta migrar DB para continuar con E6B en una sesión limpia.

---

## Decisiones pendientes

No migrar DB todavía.

Si D5B funciona:

- Causa cerrada: sesión anterior era legacy.
- Continuar con sesión limpia.
- No migrar `arquitectura opencode` todavía.
- GO para reimplementar Noise Gate en fase posterior, pero primero remover o reducir instrumentación temporal D3/D4.

Si D5B falla:

- Investigar project detection (`extractProjectName`, `ctx.directory`, git remote, cwd real).
- Proponer diff mínimo antes de tocar código.

---

## Qué NO se modificó

- No se tocó DB.
- No se migraron projects.
- No se borraron prompts/sessions/observations.
- No se tocó schema.
- No se reimplementó Noise Gate.
- No se ejecutaron E6B-T1..T7.
- No se tocó `background-agents.ts`.
- No se tocó `opencode.json`, `opencode.jsonc`, `config.toml`, `AGENTS.md`, MCP, skills, Manager ni gentle.
