# E6-T7: Rollback and Recovery Plan

**Objetivo:** Verificar que el diseño define un plan de rollback claro y accionable.

## Verificación

### Escenario 1: Noise Gate rompe continuidad de sesión
- **Síntoma:** El usuario nota que el asistente "no recuerda" lo que hizo antes.
- **Rollback:** Cambiar `allow_prompt_capture` de `"classified"` a `"all"` en `opencode.jsonc`.
- **Tiempo:** 10 segundos. No requiere restart de OpenCode (recarga config).
- **Verificación:** Enviar un mensaje, esperar 2 segundos, consultar DB: `SELECT COUNT(*) FROM user_prompts WHERE session_id = ?`.

### Escenario 2: Falsos negativos — prompts importantes no se capturan
- **Síntoma:** El asistente no recupera contexto de sesiones anteriores.
- **Mitigación:** Las `observations` (mem_save del Manager) siguen funcionando. Session summaries también.
- **Rollback:** Mismo que Escenario 1 + revisar patrones heurísticos.
- **Afinación:** Agregar patrones a `custom_patterns` en config sin modificar plugin.

### Escenario 3: Error en el plugin (crash en hook)
- **Síntoma:** OpenCode no responde o errores en consola.
- **Rollback:** Revertir cambios en `engram.ts` vía git: `git checkout -- plugins/engram.ts`.
- **Verificación:** Restart OpenCode.

### Escenario 4: Error en schema migration (opcional, solo Fase 2)
- **Síntoma:** Error en POST /prompts por columnas faltantes.
- **Rollback:** No migrar. El plugin envía solo campos que la tabla soporta. La Fase 1 no requiere migración.
- **Mitigación:** El POST es backward-compatible: si la columna no existe, Engram HTTP API ignora el campo extra.

## Resultado: ✅ PASS — Rollback definido para todos los escenarios

### Matriz de Decisión

| ¿Qué pasó? | Acción | Tiempo | Riesgo |
|-----------|--------|:-----:|:------:|
| Ruido sigue entrando | Afinar heurísticas | 1 hora | Bajo |
| Contexto perdido | Switch a "all" | 10 seg | Mínimo |
| Plugin crashea | git revert | 2 min | Mínimo |
| Schema error | No migrar (Fase 1 solo) | 0 | Nulo |
