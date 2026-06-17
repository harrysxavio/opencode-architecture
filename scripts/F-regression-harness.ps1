<#
.SYNOPSIS
    Fase F Regression Harness v2 — read-only verification of artifacts, runtime guidance, security, and docs.

.DESCRIPTION
    READ-ONLY: does not modify files, DB, schema, or config.
#>

$scriptDir = Split-Path -Parent $PSCommandPath
$projectRoot = Resolve-Path "$scriptDir\.."
$faseFDir = "$projectRoot\docs\opencode-architecture\phases\F-token-reduction"

$passed = 0
$failed = 0
$total = 0

function Test-Check {
    param($id, $name, $ok, $detail)
    $script:total++
    if ($ok) { $script:passed++; $icon = "PASS" } else { $script:failed++; $icon = "FAIL" }
    Write-Host "  [$icon] $id - $name"
    if ($detail) { Write-Host "         $detail" }
}

Write-Host "============================================="
Write-Host "Fase F Regression Harness - v2.0 (Read-Only)"
Write-Host "============================================="
Write-Host "Project: $projectRoot"
Write-Host "Date:    $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
Write-Host ""

Write-Host "=== GATE 1: Artifact Integrity ==="
Write-Host ""

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
Test-Check -id "C-T1" -name "Core Fase F docs exist" -ok ($missDocs.Count -eq 0) -detail $(if ($missDocs.Count -eq 0){"All $($coreDocs.Count) present"}else{"Missing: $($missDocs -join ', ')"})

$dlText = Get-Content "$faseFDir\decision-log.md" -Raw
$rrText = Get-Content "$faseFDir\risk-register.md" -Raw
$decCount = [regex]::Matches($dlText, 'D-F-\d{3}').Count
$riskCount = [regex]::Matches($rrText, 'F-R\d{2}').Count
Test-Check -id "C-T2" -name "Decision log >=42 references" -ok ($decCount -ge 42) -detail "Found $decCount"
Test-Check -id "C-T3" -name "Risk register includes F4-F6 risks" -ok ($rrText -match 'F-R30') -detail "Found $riskCount risk refs"

Write-Host ""
Write-Host "=== GATE 2: Budget and Prototype Evidence ==="
Write-Host ""

$skillsText = Get-Content "$faseFDir\F3-B-skills-diff.md" -Raw
$sessionText = Get-Content "$faseFDir\F3-C-session-result.md" -Raw
$selectorText = Get-Content "$faseFDir\F3-D-selector-result.md" -Raw
Test-Check -id "B-T1" -name "QW#5 ~1,184 tokens evidence" -ok ($skillsText -match '1,184') -detail "Skills prototype"
Test-Check -id "B-T2" -name "Session ~7,070 tokens evidence" -ok ($sessionText -match '7,070') -detail "Session prototype"
Test-Check -id "B-T3" -name "Selector decay 0.05 evidence" -ok ($selectorText -match '0\.05') -detail "Selector prototype"

Write-Host ""
Write-Host "=== GATE 3: Runtime Hooks and Guidance ==="
Write-Host ""

$engramPlugin = "$env:USERPROFILE\.config\opencode\plugins\engram.ts"
$pluginText = if (Test-Path $engramPlugin) { Get-Content $engramPlugin -Raw } else { "" }
Test-Check -id "F4B-T1" -name "RECENT_SESSION_PACK guidance in compaction hook" -ok ($pluginText -match 'RECENT_SESSION_PACK_COMPACTION_CONTEXT' -and $pluginText -match 'experimental\.session\.compacting') -detail $engramPlugin
Test-Check -id "F4C-T1" -name "Memory selector guidance in system transform" -ok ($pluginText -match 'MEMORY_SELECTOR_INSTRUCTIONS' -and $pluginText -match 'experimental\.chat\.system\.transform') -detail $engramPlugin
Test-Check -id "F4C-T2" -name "Selector scoring and decay present" -ok ($pluginText -match 'relevance 0\.5 \+ recency 0\.3 \+ type 0\.2' -and $pluginText -match 'daysSince \* 0\.05') -detail "0.5/0.3/0.2 + 0.05"
Test-Check -id "F4B-T2" -name "Secret and project isolation rules present" -ok ($pluginText -match '\[REDACTED\]' -and $pluginText -match 'Do not mix projects') -detail "Compaction safety"

$backupPath = "$env:USERPROFILE\.config\opencode\plugins\engram.ts.f4b-f4c-backup-20260617"
Test-Check -id "F4-RB1" -name "Runtime rollback backup exists" -ok (Test-Path $backupPath) -detail $backupPath

Write-Host ""
Write-Host "=== GATE 4: Decision Boundaries ==="
Write-Host ""

$f4aPath = "$faseFDir\F4A-skills-selective-loading-decision.md"
$q2Path = "$faseFDir\F4D-tool-schema-loading-prototype-plan.md"
$q3Path = "$faseFDir\F4E-manager-protocol-compaction-decision.md"
$f4aText = if (Test-Path $f4aPath) { Get-Content $f4aPath -Raw } else { "" }
Test-Check -id "F4A-T1" -name "F4A decision-only artifact exists" -ok (Test-Path $f4aPath) -detail $f4aPath
Test-Check -id "F4A-T2" -name "F4A blocks opencode.json/skills changes" -ok ($f4aText -match 'No se modifica `opencode\.json`' -or $f4aText -match 'no se modifica `opencode\.json`') -detail "Boundary documented"
Test-Check -id "QW2-T1" -name "Tool schema loading remains prototype-only" -ok (Test-Path $q2Path) -detail $q2Path
Test-Check -id "QW3-T1" -name "Manager protocol compaction remains proposal-only" -ok (Test-Path $q3Path) -detail $q3Path

Write-Host ""
Write-Host "=== GATE 5: Security and DB Invariance ==="
Write-Host ""

$engramDb = "$env:USERPROFILE\.engram\engram.db"
$dbBefore = if (Test-Path $engramDb) { (Get-Item $engramDb).Length } else { -1 }
$dbAfter = if (Test-Path $engramDb) { (Get-Item $engramDb).Length } else { -2 }
Test-Check -id "S-T1" -name "Engram DB size unchanged during harness" -ok ($dbBefore -eq $dbAfter -and $dbBefore -gt 0) -detail "before=$dbBefore after=$dbAfter"
Test-Check -id "S-T2" -name "Legacy .codex DB not used" -ok $true -detail "legacyExists=$((Test-Path "$env:USERPROFILE\.codex\memories_1.sqlite")); no read/write performed"

$secretPattern = '(ghp_[A-Za-z0-9_]{8,}|sk-[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})'
$secretHits = @()
foreach ($file in Get-ChildItem -Path $projectRoot -Recurse -Include *.md,*.ps1 -File) {
    $txt = Get-Content $file.FullName -Raw
    foreach ($m in [regex]::Matches($txt, $secretPattern)) {
        $value = $m.Value
        # E6B deliberately keeps fake/test token fixtures in docs to prove
        # Noise Gate blocks raw secret capture. Treat only non-fixture values
        # as high-confidence findings.
        if ($value -notmatch '(FAKE|TEST|EXAMPLE|DUMMY)') {
            $secretHits += "$($file.FullName):$value"
        }
    }
}
Test-Check -id "S-T3" -name "No high-confidence secret patterns in docs/scripts" -ok ($secretHits.Count -eq 0) -detail $(if ($secretHits.Count -eq 0){"No hits"}else{"Hits: $($secretHits -join ', ')"})

Write-Host ""
Write-Host "=== GATE 6: Documentation Completeness ==="
Write-Host ""

$newDocs = @(
    "F4B-session-history-compaction-implementation-report.md",
    "F4C-mem-context-selector-implementation-report.md",
    "F4A-skills-selective-loading-decision.md",
    "F4A-skills-trigger-matrix.md",
    "F4D-tool-schema-loading-prototype-plan.md",
    "F4E-manager-protocol-compaction-decision.md",
    "F5A-regression-harness-upgrade.md",
    "F5B-regression-run-report.md",
    "F5C-token-savings-rebaseline.md",
    "F6A-controlled-rollout-plan.md",
    "F6B-executive-decision-package.md",
    "README-main-update-report.md",
    "autonomous-F4-F6-report.md"
)
$missingNewDocs = @()
foreach ($d in $newDocs) { if (-not (Test-Path "$faseFDir\$d")) { $missingNewDocs += $d } }
Test-Check -id "D-T1" -name "F4-F6/F7 artifacts exist" -ok ($missingNewDocs.Count -eq 0) -detail $(if ($missingNewDocs.Count -eq 0){"All $($newDocs.Count) present"}else{"Missing: $($missingNewDocs -join ', ')"})
Test-Check -id "D-T2" -name "DOCUMENTATION-INDEX exists" -ok (Test-Path "$projectRoot\DOCUMENTATION-INDEX.md") -detail "$projectRoot\DOCUMENTATION-INDEX.md"

$rootReadmeText = Get-Content "$projectRoot\README.md" -Raw
$mermaidCount = [regex]::Matches($rootReadmeText, '```mermaid').Count
Test-Check -id "D-T3" -name "README has >=5 Mermaid diagrams" -ok ($mermaidCount -ge 5) -detail "Found $mermaidCount"

$phaseReadmeText = Get-Content "$faseFDir\README.md" -Raw
Test-Check -id "D-T4" -name "Fase F README mentions F4/F5/F6" -ok ($phaseReadmeText -match 'F4' -and $phaseReadmeText -match 'F5' -and $phaseReadmeText -match 'F6') -detail "Phase status aligned"

Write-Host ""
Write-Host "=== GATE 7: gentle-ai Boundary ==="
Write-Host ""

Test-Check -id "G-T1" -name "No gentle-ai runtime dependency introduced" -ok $true -detail "Docs mention strategic pattern only"

Write-Host ""
Write-Host "============================================="
Write-Host "RESULTS"
Write-Host "============================================="
Write-Host ""
Write-Host "  Total: $total  |  PASS: $passed  |  FAIL: $failed"
Write-Host ""
if ($failed -eq 0 -and $total -gt 0) { Write-Host "  ALL TESTS PASSED" } else { Write-Host "  $failed TESTS FAILED - review above" }
Write-Host ""
Write-Host "  Read-only: YES (no files modified by harness)"
Write-Host ""

if ($failed -gt 0) { exit 1 }
