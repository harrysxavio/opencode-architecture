# Pre-Runtime-Kit Gap Analysis

> **Estado:** ✅ GAPS IDENTIFIED
> **Fecha:** 2026-06-17
> **Propósito:** Identificar gaps entre el estado actual del runtime OpenCode y lo que se necesita para exportar/instalar `proyecto-opencode-mem` como runtime kit completo.

---

## 1. Gaps detectados

### G1: sdd-init no tiene modo standalone

**Descripción:** `sdd-init` existe como skill/subagente pero no está diseñado para ejecutarse en un runtime limpio sin contexto previo.

**Impacto:** Al instalar en runtime nuevo, `sdd-init` podría no tener SDD_INIT_PACKET o configuración inicial.

**Severidad:** 🟡 Media

**Mitigación documentada:** Manager ejecuta `sdd-init` inline si es necesario. En el nuevo repo, `sdd-init` debe incluir plantillas de SDD_INIT_PACKET.

---

### G2: Config de subagentes no es portable directamente

**Descripción:** `opencode.json` del runtime actual tiene paths absolutos (`C:\Users\harry\.codex\skills\...`) que no funcionan en otro entorno.

**Impacto:** Al instalar en otro equipo, los paths de los skills SDD fallan.

**Severidad:** 🔴 Alta

**Mitigación documentada:** Se exporta como `opencode.example.json` con paths relativos. El usuario debe adaptar paths al instalar.

---

### G3: Ponytail skills no están en runtime (solo en repo checkout)

**Descripción:** `ponytail-review`, `ponytail-audit`, `ponytail-debt` skills existen en `C:\Users\harry\OneDrive\Documentos\GitHub\ponytail\.opencode\skills\` pero no en `C:\Users\harry\.config\opencode\skills\`.

**Impacto:** No disponibles para el Manager en el runtime actual. Si se necesitan para auditoría post-implementación, no se pueden usar sin instalación manual.

**Severidad:** 🟢 Baja

**Nota:** No se necesita en el flujo actual. Guidance en AGENTS.md + markers `ponytail:` es suficiente.

---

### G4: Ponytail plugin no está instalado

**Descripción:** `ponytail.mjs` existe en repo pero no copiado a `C:\Users\harry\.config\opencode\plugins\` ni referenciado en `opencode.json`.

**Impacto:** No hay ejecución automática de Ponytail. Solo guidance manual del Manager.

**Severidad:** 🟢 Baja

**Mitigación:** Guidance en AGENTS.md + markers `ponytail:` son el mecanismo previsto. El plugin es opcional y no necesario.

---

### G5: gentle-orchestrator config no tiene file de skill/subagente

**Descripción:** En `opencode.json`, `gentle-orchestrator` tiene `mode: subagent` y `hidden: true` pero no se encontró un archivo SKILL.md en `C:\Users\harry\.codex\skills\` ni en `C:\Users\harry\.config\opencode\skills\`. Su prompt está inline en opencode.json.

**Impacto:** Si se requiere modificar el prompt de `gentle-orchestrator`, se debe editar opencode.json directamente (con cuidado).

**Severidad:** 🟡 Media

**Nota:** Es aceptable tener el prompt inline en opencode.json. Muchos subagentes lo hacen.

---

### G6: No hay script de install/validate para SDD agents

**Descripción:** No existe un script `install.ps1` o `validate-install.ps1` que automatice la instalación de los subagentes SDD en un runtime nuevo.

**Impacto:** La instalación es manual. Propenso a errores.

**Severidad:** 🟡 Media

**Mitigación:** La exportación incluye templates y documentación. Pero sería ideal tener scripts.

---

### G7: No hay versionamiento de skills SDD

**Descripción:** Los skills SDD tienen `version` en frontmatter pero no hay un mecanismo central para trackear qué versiones están instaladas vs disponibles.

**Impacto:** Dificulta actualizaciones y auditoría de versiones.

**Severidad:** 🟢 Baja

**Nota:** El `skill-registry` de OpenCode está disponible y podría usarse para esto, pero no está integrado con SDD agents.

---

### G8: Tests de Manager + SDD no están automatizados

**Descripción:** manager-sdd-test-plan.md define 21 tests pero ninguno está automatizado como script ejecutable.

**Impacto:** Verificar que las decisiones arquitectónicas se mantienen requiere ejecución manual.

**Severidad:** 🟡 Media

**Mitigación:** Los tests más críticos (A-T1, A-T2, B-T1, B-T3, C-T6, E-T1, E-T2) podrían automatizarse como parte del regression harness.

---

### G9: sdd-init puede requerir gentle-ai alignment

**Descripción:** El SKILL.md de sdd-init (version 3.0) menciona gentle-ai en algunas secciones, lo que podría crear dependencia conceptual durante la inicialización.

**Impacto:** Si se interpreta como dependencia obligatoria, el pipeline se complica innecesariamente.

**Severidad:** 🟡 Media

**Verificación:** Realizada en Task 3 (gentle-sdd-boundary.md). Se concluyó que sdd-init puede operar sin gentle-ai.

---

### G10: Return envelope no está implementado en subagentes

**Descripción:** El formato `## SUBAGENT_RESULT` está definido (Task 8) pero los subagentes SDD actualmente no lo implementan. Devuelven free text.

**Impacto:** Manager debe parsear output no estructurado.

**Severidad:** 🟡 Media

**Mitigación:** Documentar la expectativa en cada SKILL.md de los subagentes SDD. No requiere cambio de código, solo cambio de prompt.

---

## 2. Tabla de gaps

| ID | Gap | Severidad | Requiere cambio runtime | Mitigación |
|:--:|-----|:---------:|:-----------------------:|------------|
| G1 | sdd-init no tiene modo standalone | 🟡 Media | Sí | Manager ejecuta inline |
| G2 | Config no portable (paths absolutos) | 🔴 Alta | Sí | Template opencode.example.json |
| G3 | Ponytail skills no en runtime | 🟢 Baja | No | Guidance suficiente |
| G4 | Ponytail plugin no instalado | 🟢 Baja | No | Guidance suficiente |
| G5 | gentle-orchestrator sin SKILL.md file | 🟡 Media | No | Prompt inline aceptable |
| G6 | No install/validate scripts | 🟡 Media | Sí | Crear scripts post-export |
| G7 | Skills SDD sin versionamiento central | 🟢 Baja | No | skill-registry disponible |
| G8 | Tests Manager+SDD no automatizados | 🟡 Media | Sí | Automatizar en harness |
| G9 | sdd-init puede requerir gentle-ai | 🟡 Media | No | Ya verificado (Task 3) |
| G10 | Return envelope no implementado | 🟡 Media | No | Documentar en skills |

---

## 3. Gaps que requieren acción post-closure

| Gap | Acción requerida | Cuándo |
|:---:|------------------|--------|
| G1 | Agregar plantillas SDD_INIT_PACKET a sdd-init | En proyecto-opencode-mem |
| G2 | Usar template opencode.example.json en install | En proyecto-opencode-mem |
| G6 | Crear install.ps1 y validate-install.ps1 | En proyecto-opencode-mem |
| G8 | Automatizar tests críticos en harness | Después de closure |
| G10 | Actualizar prompts de subagentes SDD | Después de closure |

---

## 4. Gaps documentados como aceptables

| Gap | Fundamento |
|:---:|------------|
| G3 | Ponytail skills no son necesarios para el flujo básico |
| G4 | Ponytail plugin no aporta sobre el guidance |
| G5 | Prompt inline es aceptable y común en OpenCode |
| G7 | skill-registry existe pero no es obligatorio activarlo |
| G9 | Ya verificado que sdd-init no requiere gentle-ai |

---

## 5. Resumen

| Métrica | Valor |
|---------|:-----:|
| Gaps totales | 10 |
| Alta severidad | 1 (G2: paths absolutos) |
| Media severidad | 6 (G1, G5, G6, G8, G9, G10) |
| Baja severidad | 3 (G3, G4, G7) |
| Requieren acción (post-closure) | 5 (G1, G2, G6, G8, G10) |
| Aceptables sin acción | 5 (G3, G4, G5, G7, G9) |

---

## 6. Recomendación

1. **Antes de avanzar a proyecto-opencode-mem:** Resolver G2 (crear template de configuración portable)
2. **En proyecto-opencode-mem:** Resolver G1, G6 (plantillas, scripts)
3. **Después de closure:** Resolver G8, G10 (tests automatizados, prompts de subagentes)
4. **Aceptar:** G3, G4, G5, G7, G9 como gaps documentados sin acción requerida

---

*Fin de pre-runtime-kit-gap-analysis.md*
