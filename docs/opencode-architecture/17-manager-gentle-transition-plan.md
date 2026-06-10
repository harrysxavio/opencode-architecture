# 17 — Manager / gentle-orchestrator Transition Plan

> Creado en Fase B0 (2026-06-09). Describe la transición de la arquitectura actual (2 primaries ambiguos) a la arquitectura objetivo (Manager único primary, gentle-orch como SDD Pipeline).

> Actualización Fase D (2026-06-09): D completada. `gentle-orchestrator` pasó a `mode: "subagent"`; prompt Manager permite invocarlo solo como SDD Pipeline bajo guardrails; prompt gentle declara rol SDD Pipeline subagent. D4 post-restart pasó: Manager Tiny directo, gentle invocable como subagent en dry-run SDD, sin loop.

---

## 1. Estado actual

| Aspecto | Estado |
|---------|--------|
| **Orquestador primario** | 2 (Manager + gentle-orchestrator) — ambos `mode: "primary"` |
| **Regla Manager** | NO llamar a gentle-orchestrator |
| **Contexto fijo** | ~18,500–22,000 tokens (estimado) |
| **Ambigüedad** | No se sabe cuál agente responde por defecto |
| **Secretos** | 2 expuestos (GitHub PAT, Browserbase API key) |
| **Engram** | DB sin tabla observations (memoria no funcional) |

## 2. Estado objetivo (post-transición)

| Aspecto | Estado |
|---------|--------|
| **Orquestador primario** | 1 (Manager) — explícito, sin ambigüedad |
| **Regla Manager** | SÍ llamar a gentle-orchestrator cuando el flujo SDD lo requiera |
| **Contexto fijo** | ~8,500–9,500 tokens (objetivo) |
| **Ambigüedad** | Resuelta: Manager siempre responde por defecto |
| **Secretos** | 0 — variables de entorno |
| **Engram** | Memoria gobernada funcional |

---

## 3. Evaluación de opciones para gentle-orchestrator

### Opción A — Absorber su lógica en Manager

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | Extraer patrones útiles de gentle-orch (thin orchestration, SDD phase delegation, return envelope) y migrarlos al prompt/política de Manager. |
| **Pros** | Un solo agente. Sin dependencia externa. Control total. |
| **Contras** | Manager prompt se infla. Lógica SDD mezclada con routing. Manager se vuelve monolítico. Difícil de mantener. |
| **Riesgo** | 🔴 ALTO — Manager pierde separación de responsabilidades. Cada bondad de gentle que se absorbe incrementa el prompt. Se repite el problema que se quiere evitar. |
| **Tokens** | +~3,000–5,000 tokens extras al Manager |
| **Veredicto** | ❌ **No recomendada.** Crea un monolito que contradice el principio de thin orchestrator. |

### Opción B — SDD Pipeline invocable (RECOMENDADA)

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | Manager invoca gentle-orchestrator explícitamente como pipeline SDD especializado para cambios estructurados Medium/Large. |
| **Pros** | Manager mantiene su rol de router. gentle-orch preserva su especialización SDD. Separación clara. Thin orchestrator pattern preservado. Bajo acoplamiento. Pipeline SDD funciona independientemente. |
| **Cons** | Manager necesita lógica para decidir cuándo invocar gentle-orch (ya existe: clasificación Medium/Large → SDD). Dos agentes que coordinar. |
| **Riesgo** | 🟡 BAJO — Modelo más maduro. Preserva lo mejor de ambos mundos. La regla cambia de "NO llamar" a "SÍ llamar cuando corresponda". |
| **Tokens** | Manager + gentle-orch NO se cargan simultáneamente. Contexto fijo del Manager se mantiene igual. |
| **Veredicto** | ✅ **RECOMENDADA.** Es la opción que el usuario prefirió estratégicamente y la que mejor preserva las bondades de gentle-orch. |

### Opción C — Retirarlo como agente activo

| Aspecto | Detalle |
|---------|---------|
| **Descripción** | Mantener documentación de gentle-orch como referencia/patrón, pero no como agente operativo. Manager reimplementa la orquestación SDD. |
| **Pros** | Simplificación máxima. Menos tokens fijos. |
| **Cons** | Pérdida del pipeline SDD probado. Manager debe reimplementar thin orchestration, fase delegation, return envelope. Subagentes SDD pierden coordinador especializado. |
| **Riesgo** | 🟡 MEDIO — Manager absorbe lógica SDD, se infla, calidad del pipeline puede degradarse. |
| **Tokens** | Ahorro de ~12,000 tokens de gentle-orch AGENTS.md, pero Manager necesita +~5,000 para cubrir lógica faltante. Ahorro neto ~7,000. |
| **Veredicto** | ⚠️ **No recomendada ahora.** Podría reconsiderarse en el futuro si gentle-orch demuestra ser más costoso de mantener que el ahorro que genera. |

---

## 4. Plan de transición por fases

### Fase B-Security (INMEDIATO — antes de cualquier cambio)

| Paso | Acción | Comando/Archivo | Riesgo |
|------|--------|-----------------|--------|
| 1 | Rotar GitHub PAT | GitHub → Settings → Tokens | 🔴 Alto |
| 2 | Rotar Browserbase API key | Browserbase dashboard | 🔴 Alto |
| 3 | Mover secretos a .env | Crear .env con GITHUB_TOKEN, BROWSERBASE_API_KEY | 🟡 Medio |
| 4 | Actualizar config.toml | Líneas 112, 126: usar ${GITHUB_TOKEN} y ${BROWSERBASE_API_KEY} | 🟡 Medio |
| 5 | Verificar que .env está en .gitignore | .gitignore | 🟢 Bajo |
| 6 | Verificar que no hay secretos en historial Git | git log --all -p | grep -i "ghp_\|browserbase" | 🟡 Medio |
| **Duración estimada** | **1-2 horas** | | |

### Fase B0 — COMPLETADA

| Paso | Acción | Estado |
|------|--------|--------|
| 1 | Leer 25 documentos + 9 ADRs | ✅ Completo |
| 2 | Corregir contradicciones C1-C8 | ✅ Completo |
| 3 | Ejecutar validaciones P1-P7 | ✅ Completo |
| 4 | Documentar hallazgos en evidence register | ✅ Completo |
| 5 | Actualizar roadmap, risk register, ADRs | ✅ Completo |
| 6 | Documentar decisiones estratégicas (ADRs 001-009) | ✅ Completo |
| 7 | Crear documentos nuevos (15, 16, 17) | ✅ Completo |

### Fase B1 — Validación y medición

| Paso | Acción | Dependencia | Prioridad |
|------|--------|-------------|-----------|
| 1 | Test 8: Baseline de tokens | B-Security | 🔴 P0 |
| 2 | Test 1: Validar Manager primary | B-Security | 🔴 P1 |
| 3 | Test 5: Validar SDD Pipeline (Manager → gentle-orch → sdd-*) | B0 completada | 🟡 P1 |
| 4 | Implementar logging mínimo (request_id, tokens, tiempo) | B-Security | 🟡 P1 |
| 5 | Tests 2, 3, 4, 6, 7 | Logging funcionando | 🟢 P2 |

### Fase C — Tests de flujo

| Paso | Acción | Dependencia |
|------|--------|-------------|
| 1 | Automatizar T1 y T8 como scripts | B1 |
| 2 | Automatizar T5 (SDD pipeline) | T1, T8 |
| 3 | Automatizar tests restantes | T5 |
| 4 | Documentar resultados como baseline | Todos los tests |

### Fase D — Consolidar MCP y skills

| Paso | Acción | Dependencia |
|------|--------|-------------|
| 1 | Consolidar MCP duplicados (Engram, Playwright, Context7) | B-Security |
| 2 | Mover Design Skills Protocol a skill bajo demanda | — |
| 3 | Resolver duplicación frontend-specialist (agent/ vs agents/) | — |
| 4 | Reducir available skills a solo relevantes | — |

### Fase E — Reparar memoria Engram

| Paso | Acción | Dependencia |
|------|--------|-------------|
| 1 | Diagnosticar por qué la DB no tiene tabla observations | — |
| 2 | Reparar pipeline de persistencia | Diagnóstico |
| 3 | Desduplicar instrucciones Engram de AGENTS.md | — |
| 4 | Implementar filtro de guardado (no guardar prompts completos) | Pipeline reparado |
| 5 | Verificar mem_session_summary | Pipeline reparado |

### Fase F — Optimizar tokens

| Paso | Acción | Dependencia |
|------|--------|-------------|
| 1 | Compactar AGENTS.md (remover secciones movibles) | ADR-001, ADR-004 |
| 2 | Implementar MCP bajo demanda | B-Security |
| 3 | Medir después de cada optimización | Test 8 |

### Fase G — Consolidar configuración

| Paso | Acción | Dependencia |
|------|--------|-------------|
| 1 | Cambiar gentle-orch mode de primary a subagent | Test 1, Test 5 pasan |
| 2 | Eliminar engram de configs duplicadas (opencode.jsonc, config.toml) | Fase E |
| 3 | Consolidar opencode.json + .jsonc en un solo archivo | — |
| 4 | Documentar configuración final | Todo lo anterior |

---

## 5. Mapa de decisiones por fase

| Fase | Decisiones | ADRs impactados |
|------|-----------|-----------------|
| **B-Security** | Rotar secretos. Mover a env vars. | ADR-007 |
| **B0** | Manager único primary. gentle-orch SDD Pipeline. Memoria gobernada. | ADR-001 al 009 |
| **B1** | Baseline de tokens. Validación primary. Logging mínimo. | ADR-006, ADR-009 |
| **C** | Tests automatizados. Baseline documentado. | ADR-009 |
| **D** | MCP consolidados. Skills bajo demanda. frontend-specialist resuelto. | ADR-005, ADR-007 |
| **E** | Engram funcional. Instrucciones desduplicadas. Filtro de guardado. | ADR-004 |
| **F** | Contexto fijo reducido a ~8,500-9,500 tokens. | ADR-006 |
| **G** | Configuración consolidada. gentle-orch mode: subagent. | ADR-001, ADR-003 |

---

## 6. Criterios de Go / No-Go entre fases

### De B-Security a B1

**GO si:**
- Secretos rotados y movidos a .env ✅
- .gitignore actualizado ✅
- No hay secretos en historial Git ✅

**NO-GO si:**
- Queda algún secreto expuesto ❌

### De B1 a C

**GO si:**
- Test 8 pasa (baseline medido) ✅
- Test 1 pasa (Manager responde por defecto) ✅
- Logging mínimo funcionando ✅

**NO-GO si:**
- No se puede medir baseline ❌
- Manager no es el primary real ❌

### De C a D

**GO si:**
- Tests T1, T5, T8 pasan consistentemente ✅
- Baseline documentado ✅

**NO-GO si:**
- Tests fallan ❌
- Baseline inconsistente ❌

### De D a E

**GO si:**
- MCP consolidados y funcionando ✅
- Skills bajo demanda funcionando ✅

**NO-GO si:**
- MCP duplicados siguen causando problemas ❌

### De E a F

**GO si:**
- Engram escribe y recupera correctamente ✅
- session summaries funcionan ✅

**NO-GO si:**
- DB sigue sin observations ❌

### De F a G

**GO si:**
- Contexto fijo medido en ~8,500-9,500 tokens ✅
- Token reduction validado con Test 8 ✅

**NO-GO si:**
- No se alcanza la reducción objetivo ❌

### De G a final

**GO si:**
- gentle-orch es subagent ✅
- Configuración consolidada ✅
- Todos los tests pasan ✅
- Engram funcional y gobernado ✅
- Tokens dentro del objetivo ✅

---

## 7. Diagrama de transición

```
ACTUAL: 2 primaries ambiguos
    │
    ▼
B-Security ─── Rotar secretos, .env, .gitignore
    │
    ▼
B0 ─────────── Decisiones estratégicas, ADRs 001-009, documentos nuevos ✅
    │
    ▼
B1 ─────────── Test 8 (baseline), Test 1 (primary), logging mínimo
    │
    ▼
C ──────────── Tests automatizados, baseline documentado
    │
    ▼
D ──────────── MCP consolidados, skills bajo demanda, frontend-specialist resuelto
    │
    ▼
E ──────────── Engram funcional, instrucciones desduplicadas, filtro de guardado
    │
    ▼
F ──────────── Contexto fijo ~8,500-9,500 tokens, optimizaciones implementadas
    │
    ▼
G ──────────── Configuración consolidada, gentle-orch como subagent
    │
    ▼
OBJETIVO: Manager único primary, gentle-orch SDD Pipeline, memoria gobernada
```

---

## 8. Riesgos de la transición

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Manager no responde por defecto después del cambio | Media | 🔴 Alto | Test 1 antes y después de cada cambio de config |
| gentle-orch como subagent no funciona como SDD Pipeline | Baja | 🟡 Medio | Test 5 antes y después del cambio de mode |
| Pérdida de funcionalidad SDD durante la transición | Baja | 🔴 Alto | Mantener gentle-orch como primary hasta que Test 5 pase |
| Romper flujos existentes al cambiar config MCP | Media | 🟡 Medio | Hacer cambios uno por uno, testear cada uno |
| Engram no reparable | Baja | 🟡 Medio | Usar Markdown como mecanismo temporal de memoria |
| Usuario acostumbrado a gentle-orch como default | Alta | 🟢 Bajo | Documentar que @gentle-orchestrator sigue funcionando |

---

## ADRs relacionados

- ADR-001 (primary strategy), ADR-002 (Manager role), ADR-003 (gentle-orch role), ADR-007 (MCP), ADR-009 (observabilidad).
