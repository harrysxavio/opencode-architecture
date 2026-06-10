# E4B-3 — Post-Restart Validation

> Validaciones ejecutadas después de reiniciar OpenCode con la nueva configuración Engram.

---

## Smoke Test Accidental (E4B-post-restart-smoke-listo)

| Aspecto | Observación |
|---|---|
| Input | `listo` (ambiguo) |
| Manager respondió | ✅ Sí |
| `engram_mem_context` llamado | ✅ Sí |
| Engram accesible post-restart | ✅ Sí |
| Tokens observados | 42.652 totales, 40.192 caché lectura |
| ¿Cuenta como test formal? | ❌ No (input ambiguo) |

---

## E4B-T1 — Procesos Engram post-restart

### Procesos encontrados

| PID | Binario | Comando | Versión | Clasificación |
|---|---|---|---|---|
| 15260 | `C:\Users\harry\bin\engram.EXE` | `engram serve` | **1.15.13** | 🟡 Legacy — sesión anterior |
| 5816 | `C:\Users\harry\bin\engram.exe` | `mcp --tools=agent` | **1.15.13** | 🟡 Legacy — sesión anterior |
| 14512 | `C:\Users\harry\bin\engram.exe` | `mcp --tools=agent` | **1.15.13** | 🟡 Legacy — sesión anterior |
| **15404** | **`C:\Users\harry\AppData\Local\engram\bin\engram.exe`** | **`mcp --tools=agent`** | **✅ 1.16.1** | **✅ OpenCode MCP post-restart** |

### Resultado

✅ **OpenCode usa v1.16.1 post-restart.**  
⚠️ Quedan 3 procesos legacy v1.15.13 de la sesión anterior (padres ya inexistentes). No interfieren con OpenCode.  
✅ Ambos archivos de config (`opencode.json` + `opencode.jsonc`) apuntan al mismo binario v1.16.1 — no hay duplicación conflictiva.

---

## E4B-T2 — Doctor

### Comando ejecutado

```
engram doctor --json --project opencode-architecture
```

### Resultados

| Check | Resultado | Evidencia |
|---|---|---|
| `manual_session_name_project_mismatch` | ✅ OK | 5 sesiones evaluadas, sin mismatch |
| `session_project_directory_mismatch` | ✅ OK | 5 sesiones evaluadas, sin mismatch |
| `sqlite_lock_contention` | ✅ OK | WAL mode, timeout 5000ms, 0 busy |
| `sync_mutation_required_fields` | ✅ OK | 46 mutaciones evaluadas |

**Conclusión:** 4/4 checks OK. Sin drift. Sin errores. Sin warnings.

---

## E4B-T3 — mem_context

### Input (proyecto)

```
project: opencode-architecture
```

### Resultado

| Aspecto | Observación |
|---|---|
| ¿Recuperó contexto? | ✅ Sí |
| ¿Contexto relevante? | ✅ Sí — decisiones E4A, session summaries, descubrimientos Fase E |
| ¿Project source? | ✅ `explicit_override` |
| ¿Invéntó? | ❌ No |
| ¿Herramientas innecesarias? | ❌ No (solo `mem_context`) |
| ¿Ruido? | 🟢 Mínimo — memorias relevantes priorizadas |

---

## E4B-T4 — mem_save ficticio

### Memoria creada

```json
{
  "title": "TEST-E4B memory persistence probe",
  "type": "discovery",
  "scope": "project",
  "topic_key": "TEST-E4B-STABILIZATION/probe",
  "content": "**memory_type**: technical_finding\n**summary**: Memoria ficticia para validar persistencia post-E4B\n**status**: proposed\n**valid_until**: 2026-06-11\n**sensitivity**: low"
}
```

### Resultado

✅ Memoria guardada como id=400. Project source: `process_override`.

---

## E4B-T5 — mem_search

### Query

```
TEST-E4B-STABILIZATION probe
```

### Resultado

✅ Memoria id=400 recuperada con contenido completo.
✅ Project: `opencode-architecture`
✅ Source: `explicit_override`

---

## E4B-T6 — mem_session_summary

### Acción

`mem_session_summary` llamado con contenido controlado de prueba.

### Verificación

SQLite confirmó:

```sql
SELECT id, type, title FROM observations WHERE type='session_summary' ORDER BY id DESC LIMIT 1;
-- 401 | session_summary | Session summary: opencode-architecture
```

✅ **Guardado como `observations.type=session_summary`.** No en `sessions.summary`.

---

## E4B-T7 — No guardar ruido

### Input simulado

Ruido conversacional sin valor de memoria.

### Resultado

| Aspecto | Observación |
|---|---|
| ¿Manager llamó `mem_save`? | ❌ No |
| ¿user_prompts incrementó? | ❌ No (se mantiene en 302) |
| ¿Plugin capturó automáticamente? | No se detectó nuevo prompt en store |
| Conclusión | ✅ PASS — gobernado por Manager, no por defecto |
