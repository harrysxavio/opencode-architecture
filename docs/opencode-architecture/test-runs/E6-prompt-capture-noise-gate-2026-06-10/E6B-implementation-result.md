# E6B-safe — Implementation Result

> Noise Gate implementado en `engram.ts`. Pendiente de restart OpenCode + tests.

**Implementado el:** 2026-06-10
**Archivos modificados:** 1
**Archivos con backup:** 1 (`engram.ts.e6b-backup`)
**Archivos no tocados:** `opencode.jsonc`, `opencode.json`, `AGENTS.md`, DB, MCP, skills, subagentes

---

## Resumen de cambios

### Archivo: `C:\Users\harry\.config\opencode\plugins\engram.ts`

Se agregaron **~80 líneas** nuevas:

1. **`ALLOW_PROMPT_CAPTURE`** (constante, línea 219)
   - Tipo: `"all" | "classified" | "never"`
   - Valor inicial: `"classified"`
   - `"all"` → comportamiento legacy (solo filtro length > 10)
   - `"classified"` → Noise Gate con heurísticas activo
   - `"never"` → desactiva captura de user_prompts por completo

2. **`classifyPrompt()`** (función, líneas 239-288)
   - Clasifica cada prompt en 6 tipos:
     - `noise` → < 10 caracteres. No capturar.
     - `sensitive` → contiene patrones de credenciales literales. No capturar raw.
     - `confirmation` → afirmaciones/negaciones cortas (< 30 chars). No capturar.
     - `navigation` → comandos de exploración. No capturar.
     - `question` → preguntas con ¿? / qué / cómo / etc. Capturar.
     - `instruction` → default conservador. Capturar siempre.
   - Regla de diseño: "cuando hay duda, capturar."

3. **Noise Gate en hook `chat.message`** (líneas 443-463)
   - Modo `"never"` → return inmediato.
   - Modo `"classified"` → clasifica y decide si capturar.
   - Modo `"all"` → solo verifica length > 10 (legacy).
   - El body POST se mantiene exactamente igual: `{ session_id, content, project }`.

### Qué NO cambió

- ✅ Body POST `/prompts` → idéntico (sin campos extra)
- ✅ Schema DB `user_prompts` → sin alteración
- ✅ `observations` → sin tocar
- ✅ `mem_save` → sin tocar
- ✅ `mem_context` → sin tocar
- ✅ `opencode.jsonc` → sin tocar (constante interna en plugin)
- ✅ `AGENTS.md` → sin tocar
- ✅ MCP → sin tocar
- ✅ skills/subagentes → sin tocar

---

## Arquitectura del clasificador

```
Usuario escribe prompt
       │
       ▼
chat.message hook (engram.ts)
       │
       ├─ ALLOW_PROMPT_CAPTURE === "never"?  → return
       │
       ├─ ALLOW_PROMPT_CAPTURE === "classified"?
       │    │
       │    ▼
       │  classifyPrompt(finalContent)
       │    │
       │    ├─ R1: len < 10?             → noise, skip
       │    ├─ R2: literal credential?    → sensitive, skip
       │    ├─ R3: confirmation pattern?  → confirmation, skip
       │    ├─ R4: navigation pattern?    → navigation, skip
       │    ├─ R5: question pattern?      → question, CAPTURE
       │    └─ R6: default               → instruction, CAPTURE
       │
       ├─ ALLOW_PROMPT_CAPTURE === "all"?
       │    └─ len > 10? → CAPTURE (legacy)
       │
       ▼
   POST /prompts { session_id, content, project, ... }
```

---

## Patrones de sensibilidad (R2)

Se detectan y **no se capturan** prompts que contengan:

| Patrón | Ejemplo |
|--------|---------|
| `gh[opsur]_\w{10,}` | `ghp_TEST_FAKE_TOKEN_1234567890` |
| `OPENAI_API_KEY` | Cualquier prompt con esta cadena |
| `GITHUB_TOKEN` | Cualquier prompt con esta cadena |
| `ANTHROPIC_API_KEY` | Cualquier prompt con esta cadena |
| `Bearer\s+\S{20,}` | `Bearer sk-abc...` |
| `token\s*[:=]\s*\S{16,}` | `token=abc123...` |
| `contraseña\s*[:=]\s*\S{8,}` | `contraseña=misecreta` |
| `.env` + asignación | Contexto de credencial en .env |

**Decisión**: si contiene credencial literal → skip. Si solo menciona el concepto → capturar (cae en R5/R6).

---

## Rollback inmediato

| Escenario | Acción | Tiempo |
|-----------|--------|:------:|
| OpenCode no inicia | Restaurar `engram.ts.e6b-backup` | 1 min |
| Engram MCP no levanta | Restaurar backup + restart | 2 min |
| `mem_context` falla | Restaurar backup | 1 min |
| `mem_save` falla | Idem (no tocamos mem_save, debería funcionar) | - |
| Gate muy agresivo | Cambiar `ALLOW_PROMPT_CAPTURE` a `"all"` | 5 seg |
| Gate guarda secretos | Restaurar backup urgente | 1 min |

---

## Próximo paso

Reiniciar OpenCode para que el plugin se recargue y ejecutar tests E6B-T1 a T7.

*Documento creado pre-restart. Se actualizará con resultados post-ejecución.*
