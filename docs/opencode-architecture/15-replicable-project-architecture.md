# 15 — Replicable Project Architecture

> Creado en Fase B0 (2026-06-09). Describe cómo la arquitectura OpenCode se adapta a cualquier proyecto.

---

## 1. Principio

Esta arquitectura está diseñada para ser **replicable y adaptable por proyecto**. No es un template rígido — es un conjunto de patrones, políticas y decisiones que cada proyecto puede adoptar según su escala, complejidad y necesidades de memoria.

---

## 2. Estructura de proyecto recomendada

```
project-root/
├── .opencode/                        # Configuración del proyecto para OpenCode
│   ├── project.md                    # Metadata del proyecto (nombre, descripción, stack)
│   ├── memory-policy.md              # Política de memoria específica del proyecto
│   ├── agent-routing.md              # Reglas de routing del Manager para este proyecto
│   ├── mcp-policy.md                 # Qué MCPs están disponibles y cuándo usarlos
│   └── skill-policy.md               # Qué skills aplican a este proyecto
│
├── docs/                             # Documentación versionada
│   ├── architecture/                 # Documentos de arquitectura
│   │   ├── 00-executive-summary.md
│   │   ├── 01-current-state.md
│   │   ├── 02-architecture.md
│   │   └── ...
│   ├── adr/                          # Architecture Decision Records
│   │   ├── ADR-001-*.md
│   │   └── ...
│   ├── decisions/                    # Decisiones rápidas (no requieren ADR completo)
│   ├── tests/                        # Planes y resultados de tests de flujo
│   │   ├── T1-baseline.md
│   │   └── ...
│   └── runbooks/                     # Procedimientos operativos
│
├── src/                              # Código fuente (lenguaje del proyecto)
├── tests/                            # Tests del proyecto
├── .atl/                             # Atlos/Skills (auto-generado)
├── inventory/                        # Catálogo técnico generado
│
├── opencode.json                     # Configuración OpenCode (agentes, MCP)
├── opencode.jsonc                    # Override de configuración (opcional)
├── config.toml                       # Configuración MCP externa (sin secretos)
├── .env                              # Variables de entorno (SECRETOS AQUÍ)
├── .gitignore
└── README.md
```

---

## 3. Documentación mínima que necesita cada proyecto

| Documento | Obligatorio | Propósito | Quién lo mantiene |
|-----------|-------------|-----------|-------------------|
| `opencode.json` | ✅ Sí | Agentes (Manager como primary), MCP, skills | Arquitecto |
| `README.md` | ✅ Sí | Qué hace el proyecto, cómo empezar | Dev lead |
| `.opencode/project.md` | ✅ Sí | Metadata para el Manager sobre el proyecto | Arquitecto |
| `.opencode/memory-policy.md` | ✅ Sí | Qué merece recordarse de este proyecto | Arquitecto |
| `docs/adr/ADR-001-*.md` | ✅ Sí | Decisión arquitectónica del primary | Arquitecto |
| `.env` | ✅ Sí | Secretos y configuración sensible | Dev lead |
| `docs/architecture/` | ⚠️ Recomendado | Arquitectura específica del proyecto | Arquitecto |
| `docs/tests/` | ⚠️ Recomendado | Tests de flujo y baselines | QA / Arquitecto |
| `.opencode/agent-routing.md` | 🔶 Si el proyecto tiene necesidades especiales de routing | Arquitecto |
| `.opencode/mcp-policy.md` | 🔶 Si el proyecto usa MCPs específicos | Arquitecto |
| `.opencode/skill-policy.md` | 🔶 Si el proyecto necesita skills específicos | Arquitecto |

---

## 4. Qué memoria debe ser global vs proyecto

### Memoria global (Engram scope: global)

- Decisiones arquitectónicas que aplican a todos los proyectos (Manager único primary, gentle-orch como SDD Pipeline).
- Preferencias del usuario sobre cómo trabaja.
- Patrones de código reutilizables entre proyectos.
- Configuración de herramientas globales (OpenCode, Engram).

### Memoria por proyecto (Engram scope: project)

- Decisiones específicas del proyecto (stack, librerías, convenciones).
- Estado del proyecto (qué se hizo, qué falta).
- Bugs encontrados y corregidos en el proyecto.
- Hallazgos técnicos específicos del dominio.
- Resúmenes de sesión del proyecto.

### Dónde vive cada tipo

| Información | Debe vivir en |
|-------------|--------------|
| Decisión arquitectónica aprobada (global) | ADR + Engram global |
| Decisión arquitectónica aprobada (proyecto) | ADR + Engram project |
| Preferencia del usuario | Engram personal |
| Hallazgo técnico del proyecto | Engram project |
| Diseño de feature | SDD artifacts + docs/ |
| Test plan | docs/tests/ |
| Bug fix | Engram project (causa + fix) |
| Estado de sesión | Engram project (mem_session_summary) |
| Skill index | skill-registry.md (.atl/) |
| Catálogo agents/MCP/tools | inventory/ |
| Código fuente | El repositorio |
| Secretos | .env (NUNCA en Engram, NUNCA en docs) |

---

## 5. Cómo se inicializa un proyecto nuevo

### Paso 1: Crear estructura base

```bash
mkdir -p .opencode docs/architecture docs/adr docs/decisions docs/tests docs/runbooks
touch .opencode/project.md .opencode/memory-policy.md
```

### Paso 2: Configurar Manager como primary

En `opencode.json`:

```json
{
  "agents": {
    "manager": {
      "mode": "primary",
      "description": "Manager orquestador principal",
      "file": ".agents/skills/manager/SKILL.md"
    }
  }
}
```

### Paso 3: Definir metadata del proyecto

En `.opencode/project.md`:

```markdown
# Project Metadata

## name
Nombre del proyecto

## description
Qué hace el proyecto

## stack
- Lenguaje: TypeScript
- Framework: Next.js
- Base de datos: PostgreSQL
- Infra: Vercel

## memory_policy
Ver .opencode/memory-policy.md
```

### Paso 4: Definir política de memoria

En `.opencode/memory-policy.md`:

```markdown
# Memory Policy

## Save triggers
- Decisiones de arquitectura
- Bugs con causa raíz identificada
- Preferencias del usuario sobre el proyecto
- Patrones de código establecidos

## Ignore triggers
- Prompts de prueba
- Exploraciones que no produjeron decisiones
- Errores transitorios sin causa raíz
```

### Paso 5: Configurar .env

```
# SECRETOS — NUNCA committear
GITHUB_TOKEN=ghp_...
BROWSERBASE_API_KEY=...
# Configuración no sensible
OPENCODE_MODEL=gpt-5.5
```

### Paso 6: Primer ADR

Crear `docs/adr/ADR-001-primary-orchestrator.md` con la decisión de que Manager es primary.

### Paso 7: Verificar con tests de flujo

Ejecutar T1 (simple) y T8 (baseline) para tener métricas iniciales.

---

## 6. Cómo el Manager decide qué contexto cargar

El Manager aplica esta jerarquía:

```
1. ¿El proyecto tiene .opencode/project.md?
   → Sí: cargar metadata (nombre, descripción, stack)
   → No: inferir del directorio

2. ¿El request es Tiny?
   → No cargar más contexto. Responder con metadata mínima.

3. ¿El request necesita memoria?
   → Aplicar Memory Governance Flow:
     a. Buscar en Engram (scope: project + global)
     b. Si no encuentra, buscar en docs/architecture/
     c. Si no encuentra, buscar en ADRs

4. ¿El request necesita documentación?
   → Document Retriever: leer docs/architecture/ o docs/adr/

5. ¿El request necesita un subagente?
   → Verificar skill-registry.md para skills disponibles
   → Delegar a subagente con contexto mínimo

6. ¿El request necesita MCP?
   → Verificar .opencode/mcp-policy.md para MCPs disponibles
   → Activar MCP solo si justificado
```

### Qué NO se carga automáticamente

- `inventory/` completo
- Todos los ADRs
- Toda la documentación de arquitectura
- Skill registry completo
- Todos los MCP disponibles
- Memorias no relevantes al request

---

## 7. Cómo se evita cargar documentación completa

| Técnica | Cómo funciona | Ahorro estimado |
|---------|---------------|-----------------|
| **Metadata mínima** | Solo cargar .opencode/project.md (nombre, stack) | ~500 tokens |
| **Búsqueda semántica** | mem_search con query específica, no leer todo Engram | ~1,000+ tokens |
| **Document Retriever** | Leer solo secciones relevantes de docs/ | ~3,000+ tokens |
| **Skill bajo demanda** | No listar todas las skills, solo triggers relevantes | ~1,500 tokens |
| **MCP bajo demanda** | No cargar schemas de MCP no usados | ~4,000–10,000 tokens |
| **Envelope compacto** | Subagentes no retornan todo su contexto | ~2,000+ tokens |
| **Síntesis obligatoria** | Manager resume outputs de subagentes | ~1,000+ tokens |

---

## 8. Cómo se registra una decisión

### Decisión rápida (no requiere ADR)

```markdown
# docs/decisions/2026-06-09-usar-zustand.md

## Decisión
Usar Zustand para estado global en lugar de Redux.

## Razón
Proyecto pequeño, Zustand tiene menos boilerplate, suficiente para el alcance.

## Alternativas consideradas
- Redux Toolkit: mucho boilerplate para este tamaño
- Context API: suficiente pero sin devtools

## Fecha
2026-06-09
```

### Decisión arquitectónica (requiere ADR)

Usar template de ADR estándar (ver ADRs existentes en `docs/adr/`).

Toda decisión arquitectónica DEBE:
1. Tener un ADR en `docs/adr/`
2. Tener un resumen en Engram (mem_save con topic_key)
3. Referenciar el ADR como evidencia

---

## 9. Cómo se invalidan recuerdos viejos

| Situación | Método |
|-----------|--------|
| Decisión reemplazada | Nueva memoria con `supersedes: [id_anterior]`. Anterior marcada como `status: deprecated`. |
| Decisión expirada | `valid_until` en la memoria. Manager verifica antes de usar. |
| Contexto obsoleto | mem_session_summary puede marcar información como desactualizada. |
| Bug corregido | Memoria del bug marcada como `status: deprecated` cuando se confirma el fix. |
| Preferencia cambiada | Nueva memoria con `supersedes: [id_anterior]`. |

---

## 10. Cómo se mide el uso de tokens

### Test 8: Baseline

El proyecto DEBE ejecutar Test 8 al inicio y después de cada cambio significativo:

```json
{
  "test_id": "T8",
  "input": "Decime 1 frase",
  "tokens_used": 18500,
  "execution_time_ms": 2500,
  "date": "2026-06-09"
}
```

### Métricas continuas

Si hay observabilidad implementada (ADR-009), capturar por request:
- `tokens_consumidos`
- `tokens_en_contexto_fijo`
- `tokens_en_memoria_recuperada`
- `tokens_en_output`

### Objetivos por tipo de proyecto

| Tipo de proyecto | Contexto fijo objetivo | Contexto máximo por request |
|-----------------|----------------------|---------------------------|
| Proyecto pequeño (1-5 archivos) | ~5,000–8,000 | ~15,000 |
| Proyecto mediano (10-50 archivos) | ~8,000–12,000 | ~25,000 |
| Proyecto grande (50+ archivos) | ~10,000–15,000 | ~40,000 |
| Proyecto con muchos MCP | +5,000–10,000 por MCP activo | Variable |

---

## 11. Checklist de inicialización de proyecto

- [ ] `.opencode/project.md` creado con metadata
- [ ] `.opencode/memory-policy.md` creado con triggers de guardado
- [ ] `opencode.json` con Manager como primary
- [ ] `.env` creado con secretos (excluido de git)
- [ ] `docs/adr/ADR-001-primary-orchestrator.md` creado
- [ ] `docs/tests/T8-baseline.md` con medición inicial
- [ ] `docs/tests/T1-simple.md` con validación de respuesta
- [ ] `README.md` actualizado con enlaces a docs/
- [ ] `.gitignore` incluye `.env`, `inventory/` si aplica

---

## ADRs relacionados

- ADR-001 (primary strategy), ADR-002 (Manager role), ADR-004 (memoria), ADR-005 (skill registry), ADR-006 (tokens), ADR-008 (delegación), ADR-009 (observabilidad).
