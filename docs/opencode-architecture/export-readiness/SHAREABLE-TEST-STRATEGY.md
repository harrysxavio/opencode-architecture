# Shareable Test Strategy — `opencode-agent-runtime-kit`

**Fecha:** 2026-06-17  
**Propósito:** Diseñar la estrategia de tests para el repositorio público `opencode-agent-runtime-kit`.

---

## Principios

1. **Read-only優先**: Los tests no deben modificar archivos del repo ni del sistema.
2. **Portable**: Scripts PowerShell con compatibilidad PowerShell Core (pwsh) donde sea posible.
3. **Rápido**: La suite completa debe ejecutarse en < 60 segundos.
4. **CI-ready**: Cada test debe poder ejecutarse en GitHub Actions sin intervención manual.
5. **Determinista**: Mismo resultado siempre en el mismo entorno.

---

## Categorías de tests

### 1. Tests de estructura (`tests/structure/`)

Verifican que la estructura de directorios y archivos del repo es correcta.

**Test 1: Directory structure completeness**
```powershell
# Verificar que existen todas las carpetas requeridas
$required = @('docs','templates','plugins','skills','agents','tests','scripts','examples','fixtures')
foreach ($dir in $required) {
    Test-Path $dir  # debe ser true
}
```

**Test 2: Required files exist**
```powershell
# Verificar archivos obligatorios en raíz
$required = @('README.md','LICENSE','SECURITY.md','CHANGELOG.md','.gitignore')
foreach ($file in $required) {
    Test-Path $file  # debe ser true
}
```

**Test 3: No forbidden files**
```powershell
# Verificar que NO hay archivos prohibidos
$forbidden = @('*.db','*.sqlite','*.bak','*.env','*.log','*.zip','node_modules/')
# Cualquier match = FAIL
```

### 2. Tests de frontmatter de skills (`tests/skills/`)

Verifican que todos los SKILL.md tienen frontmatter YAML válido.

**Test 4: All skills have valid YAML frontmatter**
```powershell
# Para cada skill en skills/
# Verificar: empieza con ---, termina con ---, tiene name, description, location
```

**Test 5: All skills have Trigger: in description**
```powershell
# description debe empezar con "Trigger:" (formato compacto F4A-lite)
```

**Test 6: No skills have empty descriptions**
```powershell
# description no debe estar vacía
```

**Test 7: Skill names are unique**
```powershell
# No debe haber dos skills con el mismo name
```

**Test 8: Skill file names match name field**
```powershell
# El directorio que contiene SKILL.md debe coincidir con name en frontmatter
```

### 3. Tests de sanitización (`tests/sanitization/`)

Verifican que no hay secretos, paths personales o datos sensibles.

**Test 9: No personal Windows paths**
```powershell
# Patrones prohibidos:
# C:\Users\*
# OneDrive
# \Users\harry\
```

**Test 10: No secrets/tokens**
```powershell
# Patrones prohibidos:
# ghp_* (GitHub tokens)
# sk-* (API keys)
# AKIA* (AWS keys)
# Excepción: archivos en tests/fixtures/ con tokens marcados como FAKE/TEST
```

**Test 11: No personal emails**
```powershell
# Patrones prohibidos (excepto @example.com)
```

**Test 12: No absolute paths in scripts**
```powershell
# PowerShell scripts no deben tener [A-Z]:\ paths absolutos
```

### 4. Tests de plugins TypeScript (`tests/plugins/`)

Verifican que los plugins compilan y tienen estructura correcta.

**Test 13: All plugins compile with TypeScript**
```bash
# Para cada plugin template en plugins/
# npx tsc --noEmit plugins/*.template.ts
```

**Test 14: Plugin templates have correct structure**
```powershell
# Verificar que cada plugin .template.ts exporta una función configure()
```

**Test 15: Plugin templates have no personal paths**
```powershell
# No debe haber C:\Users\ en ningún .ts file
```

### 5. Tests de harness (`tests/harness/`)

Verifican que el harness de regresión se ejecuta correctamente.

**Test 16: Regression harness executes without errors**
```powershell
# Ejecutar scripts/regression-harness.ps1 contra el repo mismo
# Debe pasar sin FAIL
```

### 6. Tests de instalación (`tests/installation/`)

Verifican que el instalador funciona correctamente (en modo dry-run).

**Test 17: Dry-run installation reports correct file count**
```powershell
# scripts/install.ps1 -DryRun debe reportar cuántos archivos copiaría
```

**Test 18: Validate installation detects missing components**
```powershell
# scripts/validate-install.ps1 debe detectar si faltan skills/plugins
```

### 7. Tests de golden files

Verifican que archivos de salida esperados coinciden con los reales.

**Test 19: Plugin output matches expected structure**
```
fixtures/expected-plugin-output.ts  (golden file)
```

---

## Fixtures sintéticos

Crear en `tests/fixtures/`:

| Fixture | Propósito |
|---|---|
| `valid-skill.md` | SKILL.md con frontmatter correcto para test de validación |
| `invalid-skill.md` | SKILL.md con frontmatter roto para test que debe fallar |
| `clean-file.md` | Archivo sin secretos para test de sanitización |
| `secret-file.md` | Archivo con token FAKE para test que debe detectarlo |
| `sample-engram.db` | SQLite vacío con schema Engram (sin datos personales) |
| `sample-opencode.json` | Config OpenCode de prueba anonimizada |
| `sample-plugin.ts` | Plugin TypeScript mínimo para test de compilación |

---

## CI sugerido (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup PowerShell
        run: |
          $psversion = $PSVersionTable.PSVersion
          Write-Host "PowerShell $psversion"
      
      - name: Structure tests
        run: tests/structure/test-directory-structure.ps1
      
      - name: Skill frontmatter tests
        run: tests/skills/test-skill-frontmatter.ps1
      
      - name: Sanitization tests
        run: tests/sanitization/test-no-secrets.ps1
      
      - name: Plugin compilation
        run: tests/plugins/test-plugin-compile.ps1
        shell: pwsh
      
      - name: Regression harness
        run: scripts/regression-harness.ps1
      
      - name: Installation dry-run
        run: scripts/install.ps1 -DryRun
```

---

## Cobertura esperada

| Categoría | Tests | Prioridad |
|---|---|---|
| Structure | 3 (completeness, required, forbidden) | 🔴 Alta |
| Skill frontmatter | 5 (valid YAML, Trigger, not empty, unique, naming) | 🔴 Alta |
| Sanitization | 4 (paths, secrets, emails, absolute) | 🔴 Alta |
| Plugin compilation | 3 (compile, structure, no paths) | 🟡 Media |
| Regression harness | 1 (executes) | 🟡 Media |
| Installation | 2 (dry-run, validation) | 🟢 Baja (v0.2) |
| Golden files | 1 (output match) | 🟢 Baja (v0.2) |

**Total estimado:** 19 tests  
**v0.1 target:** 13 tests (alta prioridad)  
**v0.2 target:** +6 tests (media/baja prioridad)

---

## Estrategia de ejecución

1. **Pre-commit hook**: Ejecutar tests de estructura + sanitización (rápidos, ~5s)
2. **CI (push/PR)**: Todos los tests (~30s)
3. **Pre-release**: Suite completa + validación manual de sanitización (~60s)
4. **Post-install**: validate-install.ps1 (verifica que la instalación fue exitosa)
