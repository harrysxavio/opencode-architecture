# New Repo Migration Plan

**Fecha:** 2026-06-17  
**Repo destino:** `opencode-agent-runtime-kit`  
**Origen:** `opencode-architecture` (este repo) + runtime local (`~/.config/opencode/`, `~/.codex/`, etc.)

---

## Fases

### Fase 1: Selección de componentes (Día 1)

**Objetivo:** Identificar qué archivos se copian, cuáles se transforman y cuáles se excluyen.

**Actividades:**
1. Usar `RUNTIME-EXPORT-INVENTORY.md` como guía.
2. Marcar cada componente como:
   - **Copy direct**: skills sin modificar (37 skills)
   - **Transform**: plugins, scripts, templates (requieren sanitización)
   - **Exclude**: DB real, config personal, backups
3. Crear `MIGRATION-MANIFEST.csv` con cada archivo, su estado y acción.

**Criterio de éxito:** Manifiesto completo con todos los componentes categorizados.

### Fase 2: Sanitización (Día 1-2)

**Objetivo:** Remover paths personales, tokens, emails y datos sensibles de todos los archivos.

**Actividades:**
1. Ejecutar `SANITIZATION-CHECKLIST.md` comandos de detección.
2. Reemplazar sistemáticamente:
   - `C:\Users\harry\` → `~`
   - `C:\Users\harry\OneDrive\Documentos\GitHub\` → `$PROJECT_ROOT`
   - `harry` (username) → `{username}` o `user`
   - Emails → `user@example.com`
3. Verificar que no quedan tokens con `check-secrets.ps1`.
4. Verificar que no quedan paths personales con `check-paths.ps1`.

**Criterio de éxito:** Todos los checks de sanitización dan 0 resultados.

### Fase 3: Normalización de rutas (Día 2)

**Objetivo:** Hacer que todos los scripts y plugins usen rutas relativas o configurables.

**Actividades:**
1. Reemplazar `$env:USERPROFILE` por path relativo en scripts.
2. Reemplazar paths absolutos en plugins TypeScript por `path.join(os.homedir(), ...)`.
3. Crear variables de entorno o archivo de configuración para paths customizables.
4. Documentar en README cómo configurar rutas.

**Ejemplo de normalización:**
```powershell
# Antes (personal):
$engramPlugin = "$env:USERPROFILE\.config\opencode\plugins\engram.ts"

# Después (portable):
$opencodeConfigRoot = if ($env:OPENCODE_CONFIG) { $env:OPENCODE_CONFIG } else { "$HOME\.config\opencode" }
$engramPlugin = "$opencodeConfigRoot\plugins\engram.ts"
```

**Criterio de éxito:** No hay paths absolutos de Windows en scripts ni plugins.

### Fase 4: Creación de templates (Día 2)

**Objetivo:** Crear versiones template de plugins, configs y AGENTS.md.

**Actividades:**
1. Extraer `engram.ts` real → `plugins/engram.template.ts`
2. Crear `plugins/selector.template.ts` (F4C guidance)
3. Crear `plugins/compaction.template.ts` (F4B contract)
4. Crear `plugins/noise-gate.template.ts`
5. Crear `templates/opencode.example.json` (anonimizado)
6. Crear `templates/AGENTS.example.md`
7. Crear `templates/SKILL.example.md`

**Criterio de éxito:** Todos los templates compilan (TypeScript) y tienen placeholders documentados.

### Fase 5: Creación de instalador (Día 2-3)

**Objetivo:** Script `install.ps1` que copia skills, plugins y templates al runtime OpenCode.

**Actividades:**
1. `install.ps1` copia:
   - `skills/*` → `~/.config/opencode/skills/` y `~/.codex/skills/`
   - `plugins/*.template.ts` → `~/.config/opencode/plugins/` (renombrando a `.ts`)
   - `templates/opencode.example.json` como referencia (no sobreescribe)
2. Soporte para `-DryRun` (solo mostrar qué se copiaría).
3. Soporte para `-Force` (sobreescribir archivos existentes).
4. Soporte para `-Components skills,plugins` (seleccionar qué instalar).

**Criterio de éxito:** `install.ps1 -DryRun` reporta correctamente los archivos a copiar.

### Fase 6: Creación de validador (Día 3)

**Objetivo:** Script `validate-install.ps1` que verifica que la instalación fue exitosa.

**Actividades:**
1. Verificar que skills existen en destino.
2. Verificar que plugins existen en destino.
3. Verificar que frontmatter de skills es válido.
4. Verificar que plugins compilan.
5. Reportar componentes faltantes o corruptos.

**Criterio de éxito:** `validate-install.ps1` pasa después de `install.ps1`.

### Fase 7: Fixtures (Día 3)

**Objetivo:** Crear fixtures sintéticos para tests.

**Actividades:**
1. `fixtures/sample-engram.db` — SQLite vacío con schema Engram.
2. `fixtures/sample-skill.md` — SKILL.md sintético válido.
3. `fixtures/sample-opencode.json` — Config de prueba.
4. `fixtures/sample-plugin.ts` — Plugin mínimo.

**Criterio de éxito:** Todos los fixtures existen y son válidos.

### Fase 8: CI (Día 3)

**Objetivo:** GitHub Actions workflow que ejecuta todos los tests.

**Actividades:**
1. Crear `.github/workflows/ci.yml`.
2. Configurar trigger: push a main + PR.
3. Jobs: structure, frontmatter, sanitization, plugin compilation, harness.
4. Asegurar que corre en `windows-latest`.

**Criterio de éxito:** CI pasa en el primer push al nuevo repo.

### Fase 9: README público (Día 3-4)

**Objetivo:** README.md que explica el proyecto para audiencias técnicas y no técnicas.

**Actividades:**
1. Escribir descripción en lenguaje simple (no técnicos).
2. Escribir descripción técnica detallada.
3. Incluir diagrama Mermaid de arquitectura.
4. Incluir badges (CI, license, version).
5. Incluir quick start (3 pasos).
6. Incluir ejemplos de uso.
7. Incluir sección de contribución.

**Criterio de éxito:** README revisado y aprobado por al menos una persona no técnica.

### Fase 10: Release v0.1 (Día 4)

**Objetivo:** Tag v0.1.0 con CHANGELOG, release notes y artifact publicado.

**Actividades:**
1. Crear CHANGELOG.md con cambios desde origen.
2. Crear SECURITY.md con política de seguridad.
3. Tag `v0.1.0`.
4. GitHub Release con release notes.
5. Publicar en GitHub Marketplace (opcional).

**Criterio de éxito:** Release v0.1.0 creado con CHANGELOG y release notes.

---

## Timeline estimado

| Fase | Días | Dependencias | Riesgo |
|---|---|---|---|
| 1. Selección | 1 | Ninguna | 🟢 Bajo |
| 2. Sanitización | 1-2 | Fase 1 | 🟡 Medio — puede omitirse algún path |
| 3. Normalización | 1 | Fase 2 | 🟡 Medio — scripts pueden tener edge cases |
| 4. Templates | 1 | Fase 2 | 🟢 Bajo |
| 5. Instalador | 1-2 | Fase 3, 4 | 🟡 Medio — paths relativos |
| 6. Validador | 1 | Fase 5 | 🟢 Bajo |
| 7. Fixtures | 1 | Ninguna | 🟢 Bajo |
| 8. CI | 1 | Fase 7 | 🟡 Medio — PowerShell en GitHub Actions |
| 9. README | 1 | Ninguna | 🟢 Bajo |
| 10. Release | 1 | Fases 1-9 | 🟢 Bajo |

**Total estimado:** 4-5 días calendario, ~16-24 horas hombre.

---

## Riesgos y mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Se omite un path personal en sanitización | Media | 🔴 Alto | CI debe fallar si hay paths personales; doble revisión manual |
| Plugin TypeScript no compila en CI | Baja | 🟡 Medio | Probar compilación local antes de push |
| PowerShell scripts no son compatibles con PowerShell Core | Media | 🟡 Medio | Documentar que se requiere PowerShell 5.1+; ofrecer versiones pwsh |
| README no es claro para audiencia no técnica | Media | 🟡 Medio | Revisión por persona no técnica antes de release |
| Se incluye archivo sensible por error | Baja | 🔴 Crítico | `.gitignore` robusto + sanitization checks en CI + doble revisión |
