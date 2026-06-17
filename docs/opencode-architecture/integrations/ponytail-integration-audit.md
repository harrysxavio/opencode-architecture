# Ponytail Integration Audit

> **Estado:** ✅ AUDIT COMPLETED — Pendiente de decisión
> **Fecha:** 2026-06-17
> **Propósito:** Auditar Ponytail como posible extensión del Manager de OpenCode, evaluar riesgos, modos de integración, y alineación con Fase F.

---

## 1. ¿Qué es Ponytail?

Ponytail es un **sistema de reglas y plugin** que modifica el comportamiento de agentes de IA para reducir over-engineering en generación de código. Su filosofía es "el mejor código es el que nunca escribiste".

**Origen:** DietrichGebert/ponytail — ~30.5k stars, MIT license
**Versión actual:** v4.7.0 (junio 2026)

### Filosofía central

```
1. Does this need to exist?   → no: skip it (YAGNI)
2. Stdlib does it?            → use it
3. Native platform feature?   → use it
4. Installed dependency?      → use it
5. One line?                  → one line
6. Only then: the minimum that works
```

**No simplifica:** trust-boundary validation, data-loss handling, security, accessibility.

---

## 2. ¿Qué problema resuelve?

Ponytail resuelve el problema de **sobre-ingeniería en código generado por IA**. Los agentes tienden a:

- Crear abstracciones innecesarias
- Instalar dependencias cuando el stdlib basta
- Escribir 50 líneas donde 1 línea funciona
- Añadir boilerplate no solicitado
- Proponer frameworks para problemas simples

Ponytail aplica una escalera YAGNI antes de escribir código, reduciendo líneas 80-94% según sus benchmarks.

---

## 3. ¿Cómo funciona su escalera?

| Rung | Pregunta | Acción si True |
|:----:|----------|----------------|
| 1 | ¿Esto necesita existir? | No crearlo (YAGNI) |
| 2 | ¿Stdlib lo hace? | Usar stdlib |
| 3 | ¿Plataforma nativa lo cubre? | Usar feature nativa |
| 4 | ¿Dependencia ya instalada lo resuelve? | Usar dependencia existente |
| 5 | ¿Se puede hacer en una línea? | Una línea |
| 6 | Default: el mínimo que funciona | Implementar |

Cada shortcut se marca con `ponytail:` comentario nombrando su upgrade path.

---

## 4. ¿Qué instala o inyecta en OpenCode?

Según el repo público, Ponytail ofrece para OpenCode:

| Componente | Descripción | ¿Existe localmente? |
|------------|-------------|:-------------------:|
| `.opencode/plugins/ponytail.mjs` | Plugin que inyecta reglas cada turno + modes lite/full/ultra/off | ❌ No instalado |
| `AGENTS.md` (del repo) | Reglas YAGNI/stdlib siempre activas si se usa el AGENTS.md del repo | ❌ No aplica |
| `skills/` | Skills: ponytail-review, ponytail-audit, ponytail-debt, ponytail-help | ❌ No instalados |
| `hooks/` | Lifecycle hooks para sistema transform | ❌ No instalados |

### Hallazgo crítico: **Ponytail NO está instalado localmente**

| Check | Resultado |
|-------|:---------:|
| Plugin `ponytail.mjs` en `~/.config/opencode/plugins/` | ❌ No existe |
| Skills Ponytail en `~/.codex/skills/` | ❌ No existen |
| Skills Ponytail en `~/.config/opencode/skills/` | ❌ No existen |
| Referencia en `~/.config/opencode/opencode.json` | ❌ No existe |
| Referencia en `~/.config/opencode/AGENTS.md` | ❌ No existe |
| Archivos Ponytail en `~/.config/opencode/` recursivo | ❌ No existen |
| Checkout del repo Ponytail | ❌ No existe |
| Comando `ponytail` disponible | ❌ No |

**Conclusión:** Ponytail no influye actualmente en el runtime de OpenCode. No hay plugin activo, skills instalados, ni reglas en AGENTS.md.

---

## 5. ¿Qué comandos ofrece?

| Comando | Función | ¿Disponible sin plugin? |
|---------|---------|:-----------------------:|
| `/ponytail [lite\|full\|ultra\|off]` | Setear intensidad | ❌ Requiere plugin |
| `/ponytail-review` | Revisar diff por over-engineering | ⚠️ Como skill sin plugin |
| `/ponytail-audit` | Auditar repo completo | ⚠️ Como skill sin plugin |
| `/ponytail-debt` | Harvest `ponytail:` shortcuts diferidos | ⚠️ Como skill sin plugin |
| `/ponytail-help` | Referencia rápida | ⚠️ Como skill sin plugin |

---

## 6. ¿Qué modes tiene?

| Mode | Efecto | Contexto adicional |
|:----:|--------|:------------------:|
| `lite` | Reglas YAGNI ligeras | Mínimo |
| `full` | Escalera completa + reglas de simplificación | Moderado |
| `ultra` | Escalera + aggressivo sobre código legacy | Alto |
| `off` | Sin reglas Ponytail | 0 |

Modo default: `full` (configurable vía `PONYTAIL_DEFAULT_MODE` env var o `~/.config/ponytail/config.json`).

---

## 7. ¿Qué evidencia existe de que ya está instalado localmente?

**Ninguna.** Todos los checks dan negativo.

---

## 8. ¿Qué falta para que el Manager lo use formalmente?

| Requisito | Estado |
|-----------|--------|
| Integración documentada en Manager Protocol | ❌ No existe |
| Reglas de activación definidas | ⏸️ Propuesta en `ponytail-manager-integration-proposal.md` |
| Reglas de exclusión definidas | ⏸️ Propuesta |
| Aprobación del usuario | ❌ Pendiente |
| Instalación de plugin/skills | ❌ No realizada |
| Tests de integración | ❌ Diseñados en `ponytail-integration-test-plan.md` |
| Completion Contract actualizado | ⏸️ Propuesta |
| Rollback plan | ⏸️ Propuesta |

---

## 9. ¿Qué riesgos tiene hacerlo always-on?

| Riesgo | Probabilidad | Impacto | Descripción |
|--------|:-----------:|:-------:|-------------|
| Contexto inflado innecesariamente | 🟡 Media | 🟡 Medio | Las reglas de Ponytail se re-inyectan cada turno. En tareas no-code es overhead puro. |
| Simplificación excesiva en validación | 🟢 Baja | 🔴 Alto | Ponytail declara no simplificar trust boundaries, pero un model puede interpretar "minimum code" como "minimum validation". |
| Falsos negativos en código crítico | 🟢 Baja | 🔴 Alto | Seguridad, accesibilidad, data-loss handling declarados como no-simplificables, pero depende del modelo. |
| Overhead en tareas conceptuales | 🔴 Alta | 🟢 Bajo | Para preguntas de arquitectura, documentación o memoria, Ponytail no aporta valor pero consume tokens. |
| Conflicto con Fase F | 🟡 Media | 🟡 Medio | Ponytail full re-inyecta reglas cada turno, aumentando tokens. Contradice el objetivo de reducción. |
| Dependencia externa no controlada | 🟡 Media | 🟡 Medio | Ponytail evoluciona independientemente. Cambios en su ruleset pueden afectar comportamiento. |

---

## 10. ¿Qué riesgo tiene hacerlo solo code-task?

| Riesgo | Probabilidad | Impacto | Descripción |
|--------|:-----------:|:-------:|-------------|
| Code task mal clasificada | 🟢 Baja | 🟢 Bajo | Una tarea de código clasificada como no-code perdería simplificación. El Manager sigue aplicando review. |
| Overhead en tareas code pequeñas | 🟡 Media | 🟢 Bajo | Tiny tasks no pasarían por Ponytail según la propuesta. |
| Complejidad de implementación | 🟢 Baja | 🟡 Medio | Requiere lógica de clasificación en Manager. Ya existe (Tiny/Small/Medium/Large). |
| Reglas de exclusión olvidadas | 🟢 Baja | 🟡 Medio | Si se agrega un nuevo tipo de tarea y no se actualizan las exclusiones. |

**Veredicto:** El riesgo de code-task es significativamente menor que always-on.

---

## 11. ¿Qué diferencias hay entre los modos de integración?

| Dimensión | Plugin activo | Skill invocable | Manager gate formal | Audit post-impl |
|-----------|:-------------:|:---------------:|:-------------------:|:---------------:|
| ¿Requiere instalación? | ✅ Sí (plugin .mjs) | ✅ Sí (skills) | ❌ No (solo doc) | ❌ No |
| ¿Afecta runtime siempre? | ✅ Sí | ❌ Solo al invocar | ❌ Solo cuando Manager decide | ❌ Solo al final |
| ¿Consume tokens siempre? | ✅ Sí (~200-400/turno) | ❌ Solo al invocar | ❌ Solo cuando se activa | ❌ Solo en Large |
| ¿Overrideable por usuario? | ⚠️ `/ponytail off` | ✅ No invocar | ✅ Manager decide | ✅ No solicitar |
| ¿Riesgo de over-simplificar? | 🟡 Medio | 🟢 Bajo | 🟢 Bajo | 🟢 Bajo |
| ¿Compatibilidad Fase F? | 🟡 Media | ✅ Alta | ✅ Alta | ✅ Alta |
| ¿Requiere tests? | ✅ Sí | ✅ Sí | ✅ Sí | ✅ Sí |

---

## 12. ¿Qué no debe simplificar nunca?

| Protección | ¿Ponytail lo excluye? | ¿Manager debe reforzarlo? |
|------------|:---------------------:|:-------------------------:|
| Trust boundary validation | ✅ Sí (declarado) | ✅ Sí — en Code Review y Completion |
| Security checks | ✅ Sí (declarado) | ✅ Sí — en todas las fases |
| Accessibility | ✅ Sí (declarado) | ✅ Sí — en frontend tasks |
| Data loss handling | ✅ Sí (declarado) | ✅ Sí — en Apply y Verify |
| Error handling crítico | ❌ No explícito | ✅ Sí — en Design y Verify |
| Trazabilidad/logging requerido | ❌ No explícito | ✅ Sí — en Tasks y Apply |
| Tests requeridos por proyecto | ❌ No explícito | ✅ Sí — en Verify |
| Contratos públicos definidos | ❌ No explícito | ✅ Sí — en Design |

⚠️ **Riesgo:** Ponytail solo declara 4 exclusiones explícitas. Manager debe reforzar las otras.

---

## 13. ¿Cómo se alinea con Fase F?

| Dimensión Fase F | Alineación con Ponytail |
|------------------|------------------------|
| **Token reduction** | ⚠️ Ponytail reduce líneas de código (output), no contexto (input). Su ruleset se re-inyecta cada turno, añadiendo ~200-400 tokens. El balance neto depende del modelo y la tarea. |
| **F4A-lite** | ✅ No hay conflicto. Skills compactas no se ven afectadas. |
| **F4B Compaction** | ✅ No hay conflicto. Ponytail no interactúa con compactación. |
| **F4C Selector** | ✅ No hay conflicto. Ponytail no afecta selección de memorias. |
| **Context Packs** | ⚠️ Ponytail como regla siempre activa en code tasks añadiría un pack L5 opcional. |
| **Budget por modo** | ⚠️ Ponytail en modo full añade ~200-400 tokens/turno. En tareas code, justificado. En tareas no-code, es desperdicio. |

**Conclusión:** Ponytail alineado con Fase F **solo como code-task gate**. Como always-on, contradice la reducción de tokens.

---

## 14. Sección crítica: Por qué Ponytail no debe ser global para todo tipo de tarea

### Argumento 1: Contexto innecesario

Ponytail re-inyecta su ruleset cada turno (~200-400 tokens). En una sesión de 20 turns de documentación/arquitectura/memoria, eso son ~4,000-8,000 tokens desperdiciados. En una sesión de código, esos mismos tokens tienen valor porque evitan over-engineering.

### Argumento 2: No aporta valor en tareas conceptuales

Para preguntas como "¿cuál es la arquitectura actual?", "¿qué decidimos sobre X?", "buscá en Engram decisiones sobre Y", la escalera YAGNI/stdlib no aplica. No hay código que simplificar.

### Argumento 3: Puede interferir con análisis

En tareas de análisis o debugging, la mentalidad "minimum code" puede llevar a conclusiones prematuras o a ignorar edge cases que requieren código explícito.

### Argumento 4: Conflicto con el propósito de Fase F

La Fase F busca reducir tokens de contexto. Ponytail always-on añade tokens. Aunque el ahorro en código generado pueda compensar, el costo de contexto es inmediato y el beneficio es futuro y variable.

### Argumento 5: Mantenimiento de exclusiones

Ponytail declara 4 exclusiones explícitas. Manager necesitaría declarar más (tests, contratos, trazabilidad). Cada nueva exclusión es un punto de fallo si no se mantiene sincronizada.

### Veredicto

**Ponytail code-task gate (Opción B/C) es la integración correcta.** No always-on global (Opción D). No ultra default (Opción E).

---

*Fin de ponytail-integration-audit.md*
