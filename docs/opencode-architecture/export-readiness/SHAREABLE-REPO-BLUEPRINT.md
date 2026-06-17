# Shareable Repo Blueprint — `opencode-agent-runtime-kit`

**Fecha:** 2026-06-17  
**Propósito:** Diseñar la estructura del repositorio público que contendrá el kit de runtime de OpenCode: agentes, skills, plugins, documentación, templates y scripts sanitizados.  
**Nombre sugerido:** `opencode-agent-runtime-kit`

---

## Estructura recomendada

```
opencode-agent-runtime-kit/
├── README.md                   # Presentación del proyecto (técnica + no técnica)
├── LICENSE                     # MIT o Apache 2.0
├── SECURITY.md                 # Política de seguridad y reporting
├── CHANGELOG.md                # Historial de versiones
├── .gitignore                  # Excluye .db, .sqlite, .bak, .env, logs, backups
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions: lint, test, sanitization check
│
├── docs/
│   ├── README.md               # Índice de documentación
│   ├── ARCHITECTURE.md         # Descripción general de la arquitectura
│   ├── MANAGER-PROTOCOL.md     # Manager Global Orchestration Protocol
│   ├── SDD-PIPELINE.md         # Gentle-AI-style SDD pipeline
│   ├── MEMORY-RULES.md         # Reglas de memoria persistente Engram
│   ├── MEMORY-SELECTOR.md      # F4C Memory Context Selector guidance
│   ├── COMPACTION-CONTRACT.md  # F4B RECENT_SESSION_PACK contract
│   ├── NOISE-GATE.md           # Filtros de prompts antes de persistir
│   ├── EXPORT-STRATEGY.md      # Cómo exportar/sanitizar desde un repo existente
│   └── phases/
│       └── F-token-reduction/   # Documentación de Fase F (sanitizada)
│
├── templates/
│   ├── AGENTS.example.md       # Ejemplo de AGENTS.md con Manager + subagentes
│   ├── opencode.example.json   # Config OpenCode de ejemplo (anonimizada)
│   ├── SKILL.example.md        # SKILL.md template con frontmatter válido
│   └── opencode.example.jsonc  # Config alternativa (JSONC)
│
├── plugins/
│   ├── README.md               # Cómo usar los plugins
│   ├── engram.template.ts      # Plugin Engram base con hooks preparados
│   ├── selector.template.ts    # Plugin F4C Memory Selector guidance
│   ├── compaction.template.ts  # Plugin F4B Compaction contract
│   └── noise-gate.template.ts  # Plugin Noise Gate filters
│
├── skills/
│   ├── README.md               # Cómo instalar/desplegar skills
│   ├── sdd-explore/SKILL.md
│   ├── sdd-propose/SKILL.md
│   ├── sdd-spec/SKILL.md
│   ├── sdd-design/SKILL.md
│   ├── sdd-tasks/SKILL.md
│   ├── sdd-apply/SKILL.md
│   ├── sdd-verify/SKILL.md
│   ├── sdd-archive/SKILL.md
│   ├── sdd-onboard/SKILL.md
│   ├── sdd-init/SKILL.md
│   ├── engram-agent/SKILL.md
│   ├── judgment-day/SKILL.md
│   ├── skill-creator/SKILL.md
│   ├── skill-improver/SKILL.md
│   ├── skill-registry/SKILL.md
│   ├── cognitive-doc-design/SKILL.md
│   ├── work-unit-commits/SKILL.md
│   ├── branch-pr/SKILL.md
│   ├── chained-pr/SKILL.md
│   ├── comment-writer/SKILL.md
│   ├── issue-creation/SKILL.md
│   ├── flow-diagram/SKILL.md
│   ├── go-testing/SKILL.md
│   └── hatch-pet/SKILL.md
│
├── agents/
│   ├── README.md               # Cómo configurar agentes
│   └── manager/
│       ├── SKILL.md            # Manager agent como skill
│       └── examples/           # Ejemplos de sesiones Manager
│
├── tests/
│   ├── README.md               # Cómo ejecutar los tests
│   ├── structure/              # Tests de estructura de directorios
│   │   └── test-directory-structure.ps1
│   ├── skills/                 # Tests de frontmatter de skills
│   │   ├── test-skill-frontmatter.ps1
│   │   └── fixtures/
│   │       ├── valid-skill.md
│   │       └── invalid-skill.md
│   ├── sanitization/           # Tests de detección de secretos
│   │   ├── test-no-secrets.ps1
│   │   └── fixtures/
│   │       ├── clean-file.md
│   │       └── secret-file.md (para test que detecta y falla)
│   ├── plugins/                # Tests de plugins TypeScript
│   │   └── test-plugin-compile.ps1
│   ├── harness/                # Tests de regression harness
│   │   └── test-harness-run.ps1
│   └── installation/           # Tests de instalación dry-run
│       └── test-dry-install.ps1
│
├── scripts/
│   ├── README.md               # Cómo usar los scripts
│   ├── regression-harness.ps1  # Regression harness read-only
│   ├── install.ps1             # Instalador (copia skills, plugins, templates)
│   ├── validate-install.ps1    # Validación post-instalación
│   ├── rollback.ps1            # Rollback a estado anterior
│   └── sanitize/
│       ├── check-paths.ps1     # Busca paths personales
│       ├── check-secrets.ps1   # Busca secretos/tokens
│       └── check-email.ps1     # Busca emails personales
│
├── examples/
│   ├── README.md               # Ejemplos de uso
│   ├── quickstart/             # Quickstart: 5 minutos para tener el kit funcionando
│   │   ├── README.md
│   │   └── quickstart.ps1
│   ├── manager-session.md      # Ejemplo de sesión Manager real
│   ├── sdd-pipeline-demo.md    # Ejemplo de pipeline SDD completo
│   └── memory-flow-demo.md     # Ejemplo de flujo de memoria Engram
│
└── fixtures/
    ├── README.md               # Fixtures sintéticos para tests
    ├── sample-engram.db        # SQLite vacío con schema correcto
    ├── sample-skill.md         # SKILL.md sintético válido
    └── sample-opencode.json    # Config OpenCode de prueba
```

---

## Descripción de cada carpeta

### `/README.md` — Presentación

**Propósito:** Explicar qué es el kit, para quién es, qué problema resuelve.

**Debe incluir:**
- Descripción en lenguaje simple (no técnicos): "Este kit te ayuda a configurar un asistente de código inteligente que recuerda lo que hiciste antes, organiza tareas complejas y revisa la calidad automáticamente."
- Descripción técnica: "OpenCode Agent Runtime Kit provee agentes, skills, plugins y documentación para construir pipelines de SDD (Spec-Driven Development) con memoria persistente, reducción inteligente de tokens y gates de calidad."
- Ejemplo visual: diagrama Mermaid de la arquitectura general
- Badges: CI status, license, version
- Quick start: 3 comandos para empezar

**NO debe incluir:**
- Paths personales (C:\Users\harry\, OneDrive, etc.)
- Nombres de usuario reales
- Configuraciones específicas de proyecto

### `/docs/` — Documentación

**Propósito:** Toda la documentación de arquitectura, diseño, decisiones y guías.

**Debe incluir:**
- `ARCHITECTURE.md`: Visión general con diagramas Mermaid
- `MANAGER-PROTOCOL.md`: Protocolo de orquestación (sin paths personales)
- `SDD-PIPELINE.md`: Explicación de Spec-Driven Development
- `MEMORY-RULES.md`: Cómo usar memoria persistente
- Guías de exportación y migration
- Ejemplos sanitizados

**NO debe contener:**
- Paths personales
- Referencias a bases de datos reales
- Logs de sesiones personales

### `/plugins/` — Plugins TypeScript

**Propósito:** Plugins OpenCode (Engram) listos para copiar a `~/.config/opencode/plugins/`.

**Cada plugin template debe:**
- Usar `{USERNAME}` y `{PROJECT_ROOT}` como placeholders
- Tener comentarios explicando qué hace cada hook
- Incluir instrucciones de configuración en el README
- Poder compilarse con TypeScript estándar (`tsc`)

**NO debe contener:**
- Paths reales
- Tokens
- Configuración de proyecto específico

### `/skills/` — SKILL.md files

**Propósito:** Skills listas para copiar a `~/.config/opencode/skills/`, `~/.codex/skills/` o rutas similares.

**Cada skill debe:**
- Tener frontmatter YAML válido
- Descripción con formato `Trigger:` compacto
- Instrucciones claras y autocontenidas
- Sin paths personales

**NO debe contener:**
- Paths personales en ejemplos
- Tokens/API keys
- Referencias a archivos específicos del usuario

### `/agents/` — Definiciones de agentes

**Propósito:** Agentes OpenCode configurados como skills con instrucciones de orquestación.

**Debe incluir:**
- Manager agent como skill reutilizable
- Ejemplos de configuración y uso
- Skills de subagentes SDD

### `/tests/` — Tests y validación

**Propósito:** Tests de estructura, sanitización, plugins y harness que verifican la integridad del kit.

**Cobertura mínima:**
- Tests de estructura de directorios
- Tests de frontmatter YAML de skills
- Tests de detección de secretos/paths personales
- Tests de compilación de plugins TypeScript
- Tests de ejecución del harness
- Tests de instalación dry-run

### `/scripts/` — Scripts de utilidad

**Propósito:** Scripts para instalar, validar, hacer rollback, y sanitizar.

**Deben ser:**
- PowerShell (con compatibilidad PowerShell Core donde sea posible)
- Usar paths relativos
- No depender de paths personales
- Documentar pre-requisitos

### `/examples/` — Ejemplos de uso

**Propósito:** Demostrar cómo se usa el kit en situaciones reales.

**Quickstart:** Guía de 5 minutos para tener el kit funcionando. Incluye:
1. Clonar el repo
2. Ejecutar install.ps1
3. Verificar con validate-install.ps1
4. Probar con un ejemplo simple

### `/fixtures/` — Fixtures sintéticos

**Propósito:** Archivos de prueba que no contienen datos reales.

- `sample-engram.db`: SQLite vacío con schema de Engram
- `sample-skill.md`: SKILL.md con frontmatter válido para tests
- `sample-opencode.json`: Config OpenCode anonimizada

---

## Criterios de calidad para release v0.1

- [ ] README.md explica el proyecto para audiencia técnica y no técnica
- [ ] README.md incluye diagrama Mermaid de arquitectura
- [ ] README.md incluye quick start de 3 pasos
- [ ] Todos los paths personales sanitizados
- [ ] Ningún token/secret en el repo
- [ ] Todos los skills tienen frontmatter YAML válido
- [ ] Todos los plugins TypeScript compilan sin errores
- [ ] Tests de estructura pasan
- [ ] Tests de sanitización pasan (no detectan secretos)
- [ ] Harness de regresión ejecutable y documentado
- [ ] Script de instalación funcional (dry-run validado)
- [ ] `.gitignore` excluye `.db`, `.sqlite`, `.bak`, `.env`, logs, `node_modules/`
- [ ] `LICENSE` incluido (MIT recomendado)
- [ ] `SECURITY.md` incluido
