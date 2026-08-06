[CmdletBinding()]
param(
    [switch]$Execute,
    [ValidateRange(30, 1000)]
    [int]$MaxAiCredits = 60
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$head = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Unable to resolve source HEAD' }
$root = Join-Path ([IO.Path]::GetTempPath()) "visual-storytelling-clean-heir-$PID"
$assembled = Join-Path $root 'assembled'
$heir = Join-Path $root 'heir'
$completed = $false
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
    & git -C $heir add -A
    & git -C $heir -c user.name='Visual Storytelling Test' -c user.email='test@example.invalid' commit --quiet -m fixture
    if ($LASTEXITCODE -ne 0) { throw 'Unable to commit clean-heir fixture' }
    & git -C $heir remote add origin https://github.com/fabioc-aloha/Alex_ACT_Visual_Storytelling.git
    if ($LASTEXITCODE -ne 0) { throw 'Unable to configure clean-heir origin' }
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
            --model claude-sonnet-5 --prompt $prompt --allow-all-tools --no-ask-user --max-ai-credits $MaxAiCredits `
            --disable-builtin-mcps --no-remote --no-remote-export --silent)
    if ($LASTEXITCODE -ne 0) { throw "Clean-heir Copilot invocation failed: $LASTEXITCODE" }
    $dashboard = Join-Path $heir 'dashboard.md'
    if (-not (Test-Path $dashboard)) {
        $diagnostic = (($response -join "`n").Trim())
        if ($diagnostic.Length -gt 1000) { $diagnostic = $diagnostic.Substring(0, 1000) }
        throw "Agent did not create dashboard.md. Response: $diagnostic"
    }
    $content = Get-Content $dashboard -Raw
    foreach ($claim in @(
            '246,400',
            '36,800', '39,000', '42,300', '40,600', '44,800', '42,900',
            '139,100', '107,300', '148,800', '97,600'
        )) {
        if ($content -notmatch [regex]::Escape($claim)) { throw "Dashboard is missing recomputed claim: $claim" }
    }
    if ($content -match '\$18K|marketing efficiency|2x the margin') {
        throw 'Dashboard contains an unsupported marketing-spend claim'
    }
    $completed = $true
    Write-Host 'PASS: clean-heir orchestrator generated a source-grounded ASCII dashboard.' -ForegroundColor Green
}
finally {
    if ($completed -or -not $Execute) {
        if (Test-Path $root) { Remove-Item $root -Recurse -Force }
    }
    elseif (Test-Path $root) {
        Write-Warning "Retained failed clean-heir fixture for diagnosis: $root"
    }
}
