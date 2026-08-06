[CmdletBinding()]
param(
    [switch]$Execute,
    [ValidateRange(30, 1000)]
    [int]$MaxAiCredits = 30
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$head = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Unable to resolve source HEAD' }
$root = Join-Path ([IO.Path]::GetTempPath()) "visual-storytelling-clean-heir-$PID"
$assembled = Join-Path $root 'assembled'
$heir = Join-Path $root 'heir'
New-Item -ItemType Directory -Path $heir -Force | Out-Null
& git -C $heir init --quiet
if ($LASTEXITCODE -ne 0) { throw 'Unable to initialize clean-heir Git workspace' }

try {
    & (Join-Path $repoRoot 'scripts/publish-to-mall.ps1') -Ref $head -OutputRoot $assembled -AssembleOnly
    if ($LASTEXITCODE -ne 0) { throw 'Payload assembly failed' }
    $plugin = Join-Path $assembled 'plugins/data-analytics/visual-storytelling'
    foreach ($required in @(
            'plugin.json',
            'agents/visual-storytelling.agent.md',
            'skills/visual-storytelling/SKILL.md',
            'skills/storytelling-requirements/SKILL.md',
            'skills/datasource-connectors/SKILL.md',
            'skills/data-preparation/SKILL.md',
            'skills/visual-vocabulary/SKILL.md',
            'skills/delivery-ascii-dashboard/SKILL.md',
            'skills/delivery-svg-markdown/SKILL.md',
            'skills/delivery-html-dashboard/SKILL.md'
        )) {
        if (-not (Test-Path (Join-Path $plugin $required))) { throw "Missing assembled artifact: $required" }
    }

    Copy-Item (Join-Path $repoRoot 'datasets/sales-sample.csv') $heir
    Copy-Item (Join-Path $repoRoot 'tests/sales-dashboard-ascii.md') (Join-Path $heir 'brief.md')
    if (-not $Execute) {
        Write-Host 'PASS: clean-heir payload and fixture assembly complete. Re-run with -Execute for the bounded model invocation.' -ForegroundColor Green
        exit 0
    }

    $prompt = @'
Use the visual-storytelling agent pipeline with brief.md and sales-sample.csv.
Generate an ASCII dashboard at dashboard.md. Recompute every metric from the CSV,
respect the evidence boundary, and report the output path plus CSAR evidence.
'@
    $response = @(& copilot -C $heir --plugin-dir $plugin --agent visual-storytelling:visual-storytelling `
            --prompt $prompt --allow-all-tools --no-ask-user --max-ai-credits $MaxAiCredits `
            --no-remote --no-remote-export --silent)
    if ($LASTEXITCODE -ne 0) { throw "Clean-heir Copilot invocation failed: $LASTEXITCODE" }
    $dashboard = Join-Path $heir 'dashboard.md'
    if (-not (Test-Path $dashboard)) {
        $diagnostic = (($response -join "`n").Trim())
        if ($diagnostic.Length -gt 1000) { $diagnostic = $diagnostic.Substring(0, 1000) }
        throw "Agent did not create dashboard.md. Response: $diagnostic"
    }
    $content = Get-Content $dashboard -Raw
    foreach ($claim in @('246,400', '73,920', '4,928')) {
        if ($content -notmatch [regex]::Escape($claim)) { throw "Dashboard is missing recomputed claim: $claim" }
    }
    if ($content -match '\$18K|marketing efficiency|2x the margin') {
        throw 'Dashboard contains an unsupported marketing-spend claim'
    }
    Write-Host 'PASS: clean-heir orchestrator generated a source-grounded ASCII dashboard.' -ForegroundColor Green
}
finally {
    if (Test-Path $root) { Remove-Item $root -Recurse -Force }
}
