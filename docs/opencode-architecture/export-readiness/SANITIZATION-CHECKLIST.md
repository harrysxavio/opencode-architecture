# Sanitization Checklist

**Fecha:** 2026-06-17  
**Propósito:** Checklist y comandos para sanitizar el repositorio antes de publicar en un repo nuevo compartible.

---

## Reglas de exclusión

Antes de empezar, asegurar que `.gitignore` incluya:

```gitignore
# Databases
*.db
*.sqlite
*.sqlite3

# Backups
*.bak
*.backup
backups/

# Environment
.env
.env.local
.env.*.local

# Logs
*.log
logs/

# Binaries
*.zip
*.exe
*.dll
*.bin
*.pdb

# OS
.DS_Store
Thumbs.db

# Node
node_modules/

# Personal config
personal/
private/

# IDE
.idea/
.vscode/
*.swp
*.swo

# Engram memories (never share)
.engram/
.codex/memories_*.sqlite

# OpenCode local runtime
.config/opencode/opencode.json
.config/opencode/backups/
```

---

## Comandos de detección

### 1. Buscar rutas Windows personales

```powershell
# Buscar C:\Users\harry\ en todos los archivos
Select-String -Path "*.md","*.ps1","*.ts","*.json","*.jsonc" -Pattern "C:\\Users\\harry\\" -Recurse

# Buscar OneDrive en rutas
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "OneDrive" -Recurse

# Buscar cualquier C:\Users\ en archivos no binarios
Select-String -Path *.* -Pattern "C:\\Users\\" -Recurse -Exclude "*.db","*.sqlite","*.zip","*.bak"
```

### 2. Buscar tokens y secretos

```powershell
# GitHub tokens
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "ghp_[A-Za-z0-9_]{8,}" -Recurse

# OpenAI/API keys
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "sk-[A-Za-z0-9]{20,}" -Recurse

# AWS keys
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "AKIA[0-9A-Z]{16}" -Recurse

# Generic secrets (high entropy)
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "(?i)(api.?key|secret|token|password)\s*[:=]\s*['""][A-Za-z0-9_\-]{16,}" -Recurse
```

### 3. Buscar emails

```powershell
# Emails en archivos
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" -Recurse
```

### 4. Buscar archivos no deseados

```powershell
# Databases
Get-ChildItem -Recurse -Include "*.db","*.sqlite","*.sqlite3" | Select-Object FullName

# Backups
Get-ChildItem -Recurse -Include "*.bak","*.backup" | Select-Object FullName

# Logs
Get-ChildItem -Recurse -Include "*.log" | Select-Object FullName

# Binaries
Get-ChildItem -Recurse -Include "*.zip","*.exe","*.dll" | Select-Object FullName

# Environment files
Get-ChildItem -Recurse -Include ".env*" | Select-Object FullName
```

### 5. Buscar nombres de usuario personales

```powershell
# Nombre de usuario actual
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]
Select-String -Path "*.md","*.ps1","*.ts","*.json" -Pattern $username -Recurse
```

### 6. Buscar dominios privados

```powershell
# Dominios personales
Select-String -Path "*.md","*.ps1","*.ts" -Pattern "@(gmail\.com|outlook\.com|hotmail\.com|yahoo\.com|protonmail\.com|icloud\.com)" -Recurse
```

### 7. Buscar paths absolutos en scripts

```powershell
# Paths Windows absolutos en scripts
Select-String -Path "*.ps1","*.ts" -Pattern "[A-Za-z]:\\" -Recurse
```

---

## Checklist de sanitización por archivo

### Documentos Markdown

- [ ] Reemplazar `C:\Users\harry\` por `~` o `$HOME`
- [ ] Reemplazar `C:\Users\harry\OneDrive\Documentos\GitHub\` por `$PROJECT_ROOT`
- [ ] Reemplazar `harry` (nombre de usuario) por `{username}` o descriptor genérico
- [ ] Reemplazar emails personales por `{email}` o `user@example.com`
- [ ] Verificar que no hay tokens/API keys en ejemplos de código
- [ ] Verificar que no hay paths de DB real (`~/.engram/engram.db`, `~/.codex/memories_1.sqlite`)
- [ ] Verificar que no hay rutas de backups locales (`~/.config/opencode/backups/`)

### Scripts PowerShell

- [ ] Reemplazar `$env:USERPROFILE` por path relativo o variable configurable
- [ ] Reemplazar paths absolutos (`C:\Users\...`) por `$PSScriptRoot` o `Resolve-Path`
- [ ] Verificar que no hay tokens hardcodeados
- [ ] Verificar que no hay credenciales
- [ ] Documentar pre-requisitos (PowerShell 5.1+, PowerShell Core opcional)

### Plugins TypeScript

- [ ] Reemplazar paths personales por `path.join(os.homedir(), ...)`
- [ ] Reemplazar `C:\Users\harry\` por `process.env.HOME || process.env.USERPROFILE`
- [ ] Verificar que no hay tokens
- [ ] Verificar que no hay config de proyecto específico
- [ ] Usar placeholders como `{PROJECT_ROOT}`, `{USERNAME}`
- [ ] Comentar qué hooks son obligatorios y cuáles opcionales

### Skills (SKILL.md)

- [ ] Verificar que no hay paths personales en instrucciones
- [ ] Verificar que no hay tokens en ejemplos
- [ ] Verificar que el frontmatter YAML es válido
- [ ] Verificar que la descripción usa formato compacto (`Trigger:`)
- [ ] Verificar que no hay referencias a archivos específicos del usuario

### Templates JSON/JSONC

- [ ] Reemplazar paths personales por placeholders
- [ ] Verificar que no hay tokens/API keys
- [ ] Verificar que el schema es válido
- [ ] Documentar qué campos debe personalizar el usuario

---

## Post-sanitización: verificación automática

Después de sanitizar, ejecutar:

```powershell
# 1. Check de secretos — debe dar 0 resultados
$secrets = Select-String -Path *.md,*.ps1,*.ts -Pattern "ghp_|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}" -Recurse
"Secretos encontrados: $($secrets.Count)"

# 2. Check de paths personales — debe dar 0 resultados  
$paths = Select-String -Path *.md,*.ps1,*.ts -Pattern "C:\\Users\\harry\\|OneDrive" -Recurse
"Paths personales: $($paths.Count)"

# 3. Check de emails — debe dar 0 resultados (o solo user@example.com)
$emails = Select-String -Path *.md,*.ps1,*.ts -Pattern "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" -Recurse
$realEmails = $emails | Where-Object { $_ -notmatch "example\.com|user@|test@" }
"Emails reales: $($realEmails.Count)"

# 4. Check de archivos binarios/DB
$binaries = Get-ChildItem -Recurse -Include "*.db","*.sqlite","*.bak","*.zip","*.exe","*.dll","*.log" | Select-Object FullName
"Archivos no deseados: $($binaries.Count)"

# 5. Check de nombres de usuario
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[1]
$userHits = Select-String -Path *.md,*.ps1,*.ts -Pattern $user -Recurse
"Referencias a '$user': $($userHits.Count)"
```

**Criterio de aceptación:** Todos los checks deben dar 0 resultados antes de publicar.

---

## Excepciones documentadas

| Archivo | Contenido permitido | Razón |
|---|---|---|
| `docs/.../decision-log.md` | Paths de proyecto (no personales) | Referencias técnicas necesarias |
| `docs/.../risk-register.md` | Paths de proyecto (no personales) | Contexto de riesgos |
| `tests/.../secret-file.md` | Token falso `ghp_fake_test_token_12345` | Fixture para test que debe detectarlo |
| `scripts/sanitize/check-secrets.ps1` | Patrones de regex | Son patrones de búsqueda, no tokens reales |
