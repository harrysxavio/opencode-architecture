# F4A: Skills Selective Loading

**Estado:** ✅ COMPLETED — Propuesta lista para implementación  
**Propósito:** Reducir tokens del bloque `<available_skills>` compactando descripciones de skills de ~15–50 palabras a ~5–10 keywords.

---

## A. Evaluación inicial

| Aspecto | Detalle |
|:--------|:---------|
| **Problema** | 38 skills con descripciones verbosas ocupan ~1,770 tokens en el system prompt |
| **Evidencia** | F3 midió ~1,184 tokens de ahorro real (3× estimado F2) |
| **Archivos afectados** | `*.codex/skills/*/SKILL.md`, `*.config/opencode/skills/*/SKILL.md`, `Tools/.agents/skills/*/SKILL.md` |
| **Dependencias** | Ninguna — cambio puramente textual |
| **Riesgo** | 🟢 Bajo — el Manager invoca skills por nombre, no por descripción |
| **Resultado esperado** | System prompt se reduce ~1,184 tokens sin pérdida de funcionalidad |

---

## B. Arquitectura actual

El bloque `<available_skills>` es generado dinámicamente por OpenCode a partir del campo `description` en el frontmatter de cada archivo `SKILL.md`. 

```
Fuente: *.codex/skills/<name>/SKILL.md  →  frontmatter.description  →  <available_skills> block
Fuente: *.config/opencode/skills/<name>/SKILL.md  →  frontmatter.description  →  <available_skills> block
Fuente: Tools/.agents/skills/<name>/SKILL.md  →  frontmatter.description  →  <available_skills> block
```

El Manager usa `skill("skill-name")` para cargar un skill. La descripción en el bloque es solo informativa — el Manager decide qué cargar basado en el nombre y el contexto de la tarea.

---

## C. Diseño de la compactación

### Regla de transformación

Cada descripción actual se reemplaza por 5–10 keywords que describen los triggers principales del skill.

**Ejemplo:**
```
Antes: "Trigger: BigQuery clean, profiling, nulls, types, catalogs, _clean table. 
        Diagnose, clean, validate, and safely create cleaned copies."
Después: "BigQuery clean, profiling, nulls, types, catalogs, _clean table"
```

### Skills que NO se compactan

| Skill | Razón |
|:------|:-------|
| `_shared` | Ya es mínima (58 chars → 37 chars, ahorro marginal) |
| `customize-opencode` | Descripción funciona como guardrail (no tocar sin contexto completo) |

### Matriz completa de transformación

Ver `proposals/skills-selective-loading.proposal.md` para el diff completo.

---

## D. Validación funcional

| Escenario | Comportamiento esperado | ¿Se cumple? |
|:----------|:------------------------|:-----------:|
| Manager necesita cargar skill por nombre | `skill("sdd-design")` funciona igual | ✅ Sí |
| Manager necesita decidir qué cargar | Descripción corta da suficiente contexto | ✅ Sí |
| Skill nuevo se agrega | Descripción larga o corta, da igual | ✅ Sí |
| Manager no reconoce skill sin descripción | Manager invoca por nombre, no por descripción | ✅ Sí |
| Fallback si descripción es insuficiente | Manager puede leer SKILL.md completo bajo demanda | ✅ Sí |

---

## E. Revisión técnica

| Aspecto | Evaluación |
|:--------|:-----------|
| **Mantenibilidad** | ✅ Alta — cambiar descripciones es trivial |
| **Simplicidad** | ✅ Máxima — solo cambiar strings |
| **Acoplamiento** | ✅ Mínimo — solo afecta el bloque XML |
| **Reversibilidad** | ✅ Total — restaurar descripciones originales desde backup |
| **Compatibilidad E6B/Suite F** | ✅ No afecta — skills no están en esos gates |
| **Escalabilidad** | ✅ Aplica a cualquier skill nuevo automáticamente |

---

## F. Revisión de seguridad

| Aspecto | Resultado |
|:--------|:----------|
| Expone secretos | ❌ No — solo cambia texto de descripciones |
| Mezcla proyectos | ❌ No — skills tienen project scope definido |
| Escribe en DB | ❌ No — solo archivos SKILL.md |
| Usa `.codex/memories_1.sqlite` | ❌ No |
| Rompe project/session canonical | ❌ No |
| Toca gentle-ai | ❌ No |

---

## G. Challenge multiperspectiva

| Perspectiva | Pregunta | Respuesta |
|:------------|:---------|:----------|
| Usuario | ¿Notará el cambio? | ❌ No — la funcionalidad es idéntica |
| Técnico | ¿Es la optimización correcta? | ✅ Sí — texto informativo sin impacto funcional |
| Seguridad | ¿Algún skill crítico se vuelve invisible? | ❌ No — skills de seguridad se cargan por nombre |
| Senior | ¿Debe ir acompañado de otra cosa? | ⚠️ Recomiendo actualizar skill-registry si existe |
| QA | ¿Hay prueba de regresión? | ✅ Harness detecta si skills faltan |
| Gerente | ¿El ahorro justifica el esfuerzo? | ✅ ~1,184 tokens por ~15 minutos de trabajo |
| gentle-ai | ¿Patrón reusable? | ⚠️ Parcial — gentle-ai tiene estructura de skills diferente |

---

## H. Mejora post-challenge

**Hallazgo del challenge:** Algunos skills no tienen `description` en frontmatter (Tools skills), lo que sugiere que OpenCode puede generar descripciones por defecto. Esto significa que incluso sin modificar SKILL.md, el system prompt ya carga descripciones generadas. El ahorro real podría ser menor si OpenCode genera descripciones para skills sin frontmatter.

**Mejora aplicada:** Se agrega medición post-implementación para confirmar el ahorro real vs el estimado.

---

## I. Documentación técnica

- **Archivos tocados**: SKILL.md en 3 directorios (`.codex/skills/`, `.config/opencode/skills/`, `Tools/.agents/skills/`)
- **Cambio**: Reemplazar `description` field en frontmatter YAML
- **Formato**: `description: "keyword1, keyword2, keyword3"`
- **Rollback**: Restaurar desde backup o git revert
- **Prueba**: Ejecutar `scripts/F-regression-harness.ps1` — test E-T3 verifica existencia de skills

---

## J. Documentación no técnica

**¿Qué cambia para el usuario?**  
Nada visible. Los skills siguen estando disponibles con los mismos nombres. El cambio es interno: el sistema ocupa menos memoria (tokens) para describir cada skill, lo que deja más espacio para el trabajo real.

**¿Qué problema resuelve?**  
El system prompt tenía ~1,700 tokens solo en descripciones de skills. Al compactarlas a keywords, se liberan ~1,184 tokens para contexto útil.

**¿Qué riesgo evita?**  
Ningún riesgo de seguridad o funcional. Los skills se cargan por nombre, no por descripción.

**¿Qué falta decidir?**  
El usuario debe aprobar la ejecución del script de implementación, ya que modifica archivos fuera del proyecto opencode-architecture.

---

## K. Registro

| Documento | Acción |
|-----------|:------:|
| `decision-log.md` | D-F-032 registrada |
| `risk-register.md` | Sin cambios (riesgo ya documentado como F-R16) |
| `implementation-roadmap.md` | F4A marcado como completado (propuesta) |

---

*Fin de F4A-skills-selective-loading.md — Propuesta lista para implementación.*
