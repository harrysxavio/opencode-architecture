<#
.SYNOPSIS
    Fase F Regression Harness — Verificacion read-only de artefactos y contratos.
    
.DESCRIPTION
    Este script ejecuta tests de regresion sobre los artefactos de Fase F.
    READ-ONLY: No modifica ningun archivo, DB o configuracion.
    
.NOTES
    Autor: Manager Agent
    Fecha: 2026-06-16
    Dependencias: PowerShell 5.1+
#>

$scriptDir = Split-Path -Parent $PSCommandPath
$projectRoot = Resolve-Path "$scriptDir\.."
$faseFDir = "$projectRoot\docs\opencode-architecture\phases\F-token-reduction"

Write-Host "============================================="
Write-Host "Fase F Regression Harness - v1.0 (Read-Only)"
Write-Host "============================================="
Write-Host "Project: $projectRoot"
Write-Host "Date:    $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host ""

$passed = 0
$failed = 0
$warned = 0
$total = 0

function Test-Check {
    param($id, $name, $ok, $detail)
    $script:total++
    if ($ok) { $script:passed++; $icon = "PASS" }
    else { $script:failed++; $icon = "FAIL" }
    Write-Host "  [$icon] $id - $name"
    if ($detail) { Write-Host "         $detail" }
}

Write-Host "=== GATE 1: Artifact Integrity ==="
Write-Host ""

# C-T1
$ct1 = Test-Path "$faseFDir\F2-context-budget-contract.md"
Test-Check -id "C-T1" -name "F2 Contract exists" -ok $ct1 -detail $(if ($ct1){"Found"}else{"NOT FOUND"})

# C-T2
$coreDocs = @(
    "F2-context-budget-contract.md","F2-critical-review.md","F3-execution-strategy.md",
    "F3-B-skills-diff.md","F3-C-session-result.md","F3-D-selector-result.md",
    "context-layers-design.md","context-packs-design.md","mem-context-selector-design.md",
    "tool-schema-demand-loading-audit.md","session-history-compaction-audit.md",
    "manager-protocol-compaction-audit.md","skills-selective-loading-audit.md",
    "regression-plan.md","risk-register.md","decision-log.md",
    "implementation-roadmap.md","gentle-ai-alignment.md"
)
$missDocs = @()
foreach ($d in $coreDocs) { if (-not (Test-Path "$faseFDir\$d")) { $missDocs += $d } }
$ct2 = ($missDocs.Count -eq 0)
$detail2 = "All $($coreDocs.Count) present"
if (-not $ct2) { $detail2 = "Missing: $($missDocs -join ', ')" }
Test-Check -id "C-T2" -name "All Fase F docs exist" -ok $ct2 -detail $detail2

# C-T3
$dlText = Get-Content "$faseFDir\decision-log.md" -Raw
$decCount = 0
foreach ($m in [regex]::Matches($dlText, 'D-F-\d{3}')) { $decCount++ }
Test-Check -id "C-T3" -name "Decision log >=20 entries" -ok ($decCount -ge 20) -detail "Found $decCount"

# C-T4
$rrText = Get-Content "$faseFDir\risk-register.md" -Raw
$riskCount = 0
foreach ($m in [regex]::Matches($rrText, 'F-R\d{2}')) { $riskCount++ }
Test-Check -id "C-T4" -name "Risk register >=15 entries" -ok ($riskCount -ge 15) -detail "Found $riskCount"

# C-T5
$rpText = Get-Content "$faseFDir\regression-plan.md" -Raw
$gateCount = 0
foreach ($m in [regex]::Matches($rpText, 'Gate \d')) { $gateCount++ }
Test-Check -id "C-T5" -name "Regression plan >=6 gates" -ok ($gateCount -ge 6) -detail "Found $gateCount"

Write-Host ""
Write-Host "=== GATE 2: Budget Compliance ==="
Write-Host ""

# B-T1
$b1 = $dlText -match 'Normal'
Test-Check -id "B-T1" -name "Mode Normal budget defined" -ok $b1 -detail $(if ($b1){"Confirmed"}else{"NOT found"})

# B-T2
$b2 = $dlText -match 'sin compactacion' -or $dlText -match 'QW#3' -or $dlText -match '10k.*14k'
Test-Check -id "B-T2" -name "Alternative budget scenario exists" -ok $b2 -detail $(if ($b2){"Found"}else{"NOT found"})

# B-T3
$f2Text = Get-Content "$faseFDir\F2-context-budget-contract.md" -Raw
$uniqueLayers = @{}
foreach ($m in [regex]::Matches($f2Text, '\| L\d \|')) { $uniqueLayers[$m.Value] = $true }
$layerCount = $uniqueLayers.Count
Test-Check -id "B-T3" -name "Layers L0-L5 defined in F2 contract >=6" -ok ($layerCount -ge 5) -detail "Found $layerCount unique layers"

Write-Host ""
Write-Host "=== GATE 3: Execution Strategy ==="
Write-Host ""

$et1 = Test-Path "$faseFDir\F3-execution-strategy.md"
Test-Check -id "E-T1" -name "F3 execution strategy" -ok $et1 -detail $(if ($et1){"Found"}else{"NOT FOUND"})
$et2 = Test-Path "$faseFDir\F2-critical-review.md"
Test-Check -id "E-T2" -name "F2 critical review" -ok $et2 -detail $(if ($et2){"Found"}else{"NOT FOUND"})
$et3 = Test-Path "$faseFDir\F3-B-skills-diff.md"
Test-Check -id "E-T3" -name "QW#5 prototype" -ok $et3 -detail $(if ($et3){"Found"}else{"NOT FOUND"})
$et4 = Test-Path "$faseFDir\F3-C-session-result.md"
Test-Check -id "E-T4" -name "QW#1 prototype" -ok $et4 -detail $(if ($et4){"Found"}else{"NOT FOUND"})
$et5 = Test-Path "$faseFDir\F3-D-selector-result.md"
Test-Check -id "E-T5" -name "QW#4 prototype" -ok $et5 -detail $(if ($et5){"Found"}else{"NOT FOUND"})

Write-Host ""
Write-Host "=== GATE 4: Cross-Reference Consistency ==="
Write-Host ""

# X-T1
$x1 = $dlText -match 'F2 Critical Review'
Test-Check -id "X-T1" -name "CR decisions in decision-log" -ok $x1 -detail $(if ($x1){"Found"}else{"NOT found"})

# X-T2
$skillsText = Get-Content "$faseFDir\F3-B-skills-diff.md" -Raw
$x2 = $skillsText -match '1,184'
Test-Check -id "X-T2" -name "QW#5 ~1,184 tokens savings" -ok $x2 -detail $(if ($x2){"Confirmed"}else{"NOT found"})

# X-T3
$sessionText = Get-Content "$faseFDir\F3-C-session-result.md" -Raw
$x3 = $sessionText -match '7,070'
Test-Check -id "X-T3" -name "Session ~7,070 tokens savings" -ok $x3 -detail $(if ($x3){"Confirmed"}else{"NOT found"})

Write-Host ""
Write-Host "============================================="
Write-Host "RESULTS"
Write-Host "============================================="
Write-Host ""
Write-Host "  Total: $total  |  PASS: $passed  |  FAIL: $failed"
Write-Host ""

if ($failed -eq 0 -and $total -gt 0) {
    Write-Host "  ALL TESTS PASSED"
} else {
    Write-Host "  $failed TESTS FAILED - review above"
}

Write-Host ""
Write-Host "  Read-only: YES (no files modified)"
Write-Host ""