<#
Read-only assurance checks for Manager + SDD runtime readiness.

This script validates local OpenCode config and SDD skill inventory without
modifying runtime, DBs, memories, prompts, or user config.
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "$env:USERPROFILE\.config\opencode\opencode.json",
    [string]$ConfigSkillsDir = "$env:USERPROFILE\.config\opencode\skills",
    [string]$CodexSkillsDir = "$env:USERPROFILE\.codex\skills"
)

$ErrorActionPreference = 'Stop'
$Pass = 0
$Warn = 0
$Fail = 0
$Rows = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Id,
        [string]$Name,
        [ValidateSet('PASS','WARN','FAIL')][string]$Status,
        [string]$Evidence
    )

    if ($Status -eq 'PASS') { $script:Pass++ }
    elseif ($Status -eq 'WARN') { $script:Warn++ }
    else { $script:Fail++ }

    $script:Rows.Add([pscustomobject]@{
        Id = $Id
        Name = $Name
        Status = $Status
        Evidence = $Evidence
    }) | Out-Null
}

function Get-PropValue {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -eq $prop) { return $null }
    return $prop.Value
}

function Get-AgentMap {
    param([object]$Config)
    $agent = Get-PropValue -Object $Config -Name 'agent'
    if ($null -ne $agent) { return $agent }
    $agents = Get-PropValue -Object $Config -Name 'agents'
    if ($null -ne $agents) { return $agents }
    return $null
}

Write-Host 'Manager/SDD assurance - read-only' -ForegroundColor Cyan
Write-Host "Config: $ConfigPath"
Write-Host "Config skills: $ConfigSkillsDir"
Write-Host "Codex skills: $CodexSkillsDir"
Write-Host ''

$config = $null
$agents = $null

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Add-Check 'CFG-0' 'OpenCode config exists' 'FAIL' "Missing: $ConfigPath"
} else {
    $raw = Get-Content -LiteralPath $ConfigPath -Raw
    $config = $raw | ConvertFrom-Json
    $agents = Get-AgentMap -Config $config
    Add-Check 'CFG-0' 'OpenCode config exists' 'PASS' $ConfigPath

    if ($raw -match 'C:\\Users\\harry') {
        Add-Check 'PORT-1' 'Config contains absolute local paths' 'WARN' 'Expected in current runtime; must be templated before export.'
    } else {
        Add-Check 'PORT-1' 'Config contains absolute local paths' 'PASS' 'No local username path found.'
    }
}

if ($null -eq $agents) {
    Add-Check 'CFG-1' 'Agent map exists' 'FAIL' 'Neither agent nor agents block found.'
} else {
    Add-Check 'CFG-1' 'Agent map exists' 'PASS' 'Agent map discovered.'

    $manager = Get-PropValue -Object $agents -Name 'manager'
    if ($null -eq $manager) {
        Add-Check 'MGR-1' 'Manager agent exists' 'FAIL' 'manager missing.'
    } elseif ($manager.mode -eq 'primary') {
        Add-Check 'MGR-1' 'Manager agent is primary' 'PASS' 'manager.mode = primary.'
    } else {
        Add-Check 'MGR-1' 'Manager agent is primary' 'FAIL' "manager.mode = $($manager.mode)"
    }

    $primaryAgents = @($agents.PSObject.Properties | Where-Object { $_.Value.mode -eq 'primary' } | ForEach-Object { $_.Name })
    if ($primaryAgents.Count -eq 1 -and $primaryAgents[0] -eq 'manager') {
        Add-Check 'MGR-2' 'Manager is unique primary' 'PASS' 'Only manager has mode primary.'
    } else {
        Add-Check 'MGR-2' 'Manager is unique primary' 'FAIL' ("Primary agents: " + ($primaryAgents -join ', '))
    }

    $gentle = Get-PropValue -Object $agents -Name 'gentle-orchestrator'
    if ($null -eq $gentle) {
        Add-Check 'GENTLE-1' 'gentle-orchestrator exists' 'WARN' 'Not found in config.'
    } elseif ($gentle.mode -eq 'subagent') {
        Add-Check 'GENTLE-1' 'gentle-orchestrator is subagent' 'PASS' 'gentle-orchestrator.mode = subagent.'
    } else {
        Add-Check 'GENTLE-1' 'gentle-orchestrator is subagent' 'FAIL' "gentle-orchestrator.mode = $($gentle.mode)"
    }

    $sddNames = @('sdd-init','sdd-explore','sdd-propose','sdd-spec','sdd-design','sdd-tasks','sdd-apply','sdd-verify','sdd-archive','sdd-onboard')
    foreach ($name in $sddNames) {
        $agent = Get-PropValue -Object $agents -Name $name
        if ($null -eq $agent) {
            Add-Check "SDD-$name" "$name configured" 'FAIL' 'Missing from agent map.'
        } elseif ($agent.mode -eq 'subagent') {
            Add-Check "SDD-$name" "$name configured as subagent" 'PASS' "$name.mode = subagent."
        } else {
            Add-Check "SDD-$name" "$name configured as subagent" 'FAIL' "$name.mode = $($agent.mode)"
        }
    }
}

$requiredSkills = @('sdd-init','sdd-explore','sdd-propose','sdd-spec','sdd-design','sdd-tasks','sdd-apply','sdd-verify','sdd-archive','sdd-onboard')
foreach ($skill in $requiredSkills) {
    $configSkillPath = Join-Path -Path $ConfigSkillsDir -ChildPath (Join-Path -Path $skill -ChildPath 'SKILL.md')
    $codexSkillPath = Join-Path -Path $CodexSkillsDir -ChildPath (Join-Path -Path $skill -ChildPath 'SKILL.md')
    $existsConfig = Test-Path -LiteralPath $configSkillPath
    $existsCodex = Test-Path -LiteralPath $codexSkillPath

    if ($existsConfig -and $existsCodex) {
        Add-Check "SKILL-$skill" "$skill skill exists in both stores" 'PASS' 'config + codex skill found.'
    } elseif ($existsConfig -or $existsCodex) {
        Add-Check "SKILL-$skill" "$skill skill exists" 'WARN' 'Only one skill store has this skill.'
    } else {
        Add-Check "SKILL-$skill" "$skill skill exists" 'FAIL' 'Missing from both skill stores.'
    }
}

$allSkillFiles = @()
foreach ($dir in @($ConfigSkillsDir, $CodexSkillsDir)) {
    if (Test-Path -LiteralPath $dir) {
        $allSkillFiles += Get-ChildItem -LiteralPath $dir -Recurse -Filter 'SKILL.md' |
            Where-Object { $_.Directory.Name -like 'sdd-*' }
    }
}

if ($allSkillFiles.Count -eq 0) {
    Add-Check 'ENV-1' 'SDD skill files discoverable' 'FAIL' 'No SDD SKILL.md files found.'
} else {
    Add-Check 'ENV-1' 'SDD skill files discoverable' 'PASS' "$($allSkillFiles.Count) SDD skill files found."
    $withEnvelope = @($allSkillFiles | Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match 'SUBAGENT_RESULT' })
    if ($withEnvelope.Count -eq $allSkillFiles.Count) {
        Add-Check 'ENV-2' 'SDD skills include SUBAGENT_RESULT' 'PASS' 'All SDD skill files contain the marker.'
    } elseif ($withEnvelope.Count -gt 0) {
        Add-Check 'ENV-2' 'SDD skills include SUBAGENT_RESULT' 'WARN' "$($withEnvelope.Count)/$($allSkillFiles.Count) contain marker."
    } else {
        Add-Check 'ENV-2' 'SDD skills include SUBAGENT_RESULT' 'WARN' '0 files contain marker; template implementation plan required.'
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$reportDocs = @(
    'docs\opencode-architecture\export-readiness\PRE-RUNTIME-KIT-READINESS-GATE.md',
    'docs\opencode-architecture\export-readiness\PORTABILITY-MAP.md',
    'docs\opencode-architecture\export-readiness\OPENCODE-CONFIG-TEMPLATE-SPEC.md',
    'docs\opencode-architecture\integrations\SDD-RETURN-ENVELOPE-IMPLEMENTATION-PLAN.md',
    'docs\opencode-architecture\integrations\GPT-5.5-FALLBACK-PLAN.md',
    'docs\opencode-architecture\integrations\MANAGER-TINY-AMBIGUITY-GUARD.md'
)

foreach ($doc in $reportDocs) {
    $full = Join-Path -Path $repoRoot -ChildPath $doc
    if (Test-Path -LiteralPath $full) {
        Add-Check "DOC-$doc" 'Required readiness doc exists' 'PASS' $doc
    } else {
        Add-Check "DOC-$doc" 'Required readiness doc exists' 'FAIL' "Missing: $doc"
    }
}

Write-Host ''
$Rows | Format-Table -AutoSize
Write-Host ''
Write-Host "Summary: PASS=$Pass WARN=$Warn FAIL=$Fail"

if ($Fail -gt 0) {
    Write-Host 'Result: FAIL' -ForegroundColor Red
    exit 1
}

if ($Warn -gt 0) {
    Write-Host 'Result: PASS WITH WARNINGS' -ForegroundColor Yellow
    exit 0
}

Write-Host 'Result: PASS' -ForegroundColor Green
exit 0
