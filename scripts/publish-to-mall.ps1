[CmdletBinding()]
param(
    [string]$MallRoot = (Join-Path (Split-Path -Parent $PSScriptRoot) '..\Alex_ACT_Plugin_Mall'),
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^v\d+\.\d+\.\d+$')]
    [string]$Ref,
    [string]$OutputRoot,
    [switch]$AssembleOnly,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
if ($Apply -and ($AssembleOnly -or $OutputRoot)) {
    throw '-Apply cannot be combined with -AssembleOnly or -OutputRoot'
}
$components = @(
    @{ Name = 'storytelling-requirements'; Category = 'data-analytics'; Standalone = $true },
    @{ Name = 'datasource-connectors'; Category = 'data-analytics'; Standalone = $true },
    @{ Name = 'data-preparation'; Category = 'data-analytics'; Standalone = $true },
    @{ Name = 'delivery-ascii-dashboard'; Category = 'data-analytics'; Standalone = $true }
)
$managedRelativeRoots = @(
    $components | Where-Object Standalone | ForEach-Object { "plugins/$($_.Category)/$($_.Name)" }
) + 'plugins/data-analytics/visual-storytelling'
$retiredRelativeRoots = @(
    'plugins/data-analytics/delivery-html-dashboard',
    'plugins/media-graphics/delivery-svg-markdown'
)
$controlledRelativeRoots = @($managedRelativeRoots) + @($retiredRelativeRoots)

if (-not $AssembleOnly) {
    $resolvedRef = (& git -C $repoRoot rev-parse "$Ref^{commit}").Trim()
    if ($LASTEXITCODE -ne 0) {
        throw 'Ref must resolve to a source tag'
    }
    $head = (& git -C $repoRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $head -ne $resolvedRef) {
        throw 'Ref must equal the source repository HEAD'
    }
    $dirty = @(& git -C $repoRoot status --porcelain --untracked-files=all)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect source worktree state' }
    if ($dirty.Count -gt 0) { throw 'Source worktree must be clean before preview or apply' }
}

function Read-Json([string]$Path) {
    Get-Content $Path -Raw | ConvertFrom-Json -AsHashtable
}

function Write-Json([string]$Path, $Value) {
    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $json = $Value | ConvertTo-Json -Depth 30
    [IO.File]::WriteAllText($Path, "$json`n", [Text.UTF8Encoding]::new($false))
}

function Plugin-Manifest($source) {
    [ordered]@{
        name        = $source.name
        version     = $source.version
        description = $source.description
        keywords    = @($source.keywords)
        category    = $source.category
        author      = $source.author
    }
}

function Mall-Metadata($source) {
    $metadata = [ordered]@{
        upstream         = [ordered]@{
            repo = 'https://github.com/fabioc-aloha/Alex_ACT_Visual_Storytelling'
            ref  = $Ref
        }
        engines          = @($source.engines)
        shape            = $source.shape
        tier             = $source.tier
        token_cost       = $source.token_cost
    }
    foreach ($key in @('bundle', 'components', 'artifacts', 'install_paths')) {
        if ($source.ContainsKey($key)) { $metadata[$key] = $source[$key] }
    }
    if ($source.bundle) {
        $metadata.migration = [ordered]@{
            strategy = 'vendor-components'
            reason   = 'ASCII delivery is bundled; graphical delivery requires Illustrator.'
        }
    }
    $metadata
}

$temporaryAssembly = $Apply -or -not $OutputRoot
$outputRoot = if ($OutputRoot) { $OutputRoot } else { Join-Path ([IO.Path]::GetTempPath()) "visual-storytelling-publish-$PID" }
if ($Apply) {
    if (-not (Test-Path (Join-Path $MallRoot '.git'))) { throw "Mall clone not found: $MallRoot" }
}
if (Test-Path $outputRoot) { Remove-Item $outputRoot -Recurse -Force }
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null

foreach ($component in $components) {
    $sourceRoot = Join-Path $repoRoot "plugins/$($component.Name)"
    $source = Read-Json (Join-Path $sourceRoot 'plugin.json')
    if (-not $component.Standalone) { continue }
    $target = Join-Path $outputRoot "plugins/$($component.Category)/$($component.Name)"
    New-Item -ItemType Directory -Path (Join-Path $target "skills/$($component.Name)") -Force | Out-Null
    Copy-Item (Join-Path $sourceRoot 'SKILL.md') (Join-Path $target "skills/$($component.Name)/SKILL.md") -Force
    Copy-Item (Join-Path $sourceRoot 'README.md') (Join-Path $target 'README.md') -Force
    Write-Json (Join-Path $target 'plugin.json') (Plugin-Manifest $source)
    Write-Json (Join-Path $target '.mall-metadata.json') (Mall-Metadata $source)
}

$bundleSourceRoot = Join-Path $repoRoot 'plugins/visual-storytelling'
$bundleSource = Read-Json (Join-Path $bundleSourceRoot 'plugin.json')
$bundleTarget = Join-Path $outputRoot 'plugins/data-analytics/visual-storytelling'
New-Item -ItemType Directory -Path (Join-Path $bundleTarget 'agents') -Force | Out-Null
Copy-Item (Join-Path $bundleSourceRoot 'README.md') (Join-Path $bundleTarget 'README.md') -Force
Copy-Item (Join-Path $bundleSourceRoot 'visual-storytelling.agent.md') (Join-Path $bundleTarget 'agents/visual-storytelling.agent.md') -Force
Write-Json (Join-Path $bundleTarget 'plugin.json') (Plugin-Manifest $bundleSource)
Write-Json (Join-Path $bundleTarget '.mall-metadata.json') (Mall-Metadata $bundleSource)

foreach ($component in $components) {
    $skillTarget = Join-Path $bundleTarget "skills/$($component.Name)/SKILL.md"
    New-Item -ItemType Directory -Path (Split-Path -Parent $skillTarget) -Force | Out-Null
    Copy-Item (Join-Path $repoRoot "plugins/$($component.Name)/SKILL.md") $skillTarget -Force
}
$wrapper = Get-Content (Join-Path $bundleSourceRoot 'SKILL.md') -Raw
$wrapper = $wrapper -replace 'plugins/([^/]+)/SKILL\.md', 'skills/$1/SKILL.md'
$wrapper = $wrapper -replace '\.github/skills/local/([^/]+)/SKILL\.md', 'skills/$1/SKILL.md'
$wrapperTarget = Join-Path $bundleTarget 'skills/visual-storytelling/SKILL.md'
New-Item -ItemType Directory -Path (Split-Path -Parent $wrapperTarget) -Force | Out-Null
[IO.File]::WriteAllText($wrapperTarget, $wrapper, [Text.UTF8Encoding]::new($false))

if ($Apply) {
    $backupRoot = Join-Path ([IO.Path]::GetTempPath()) "visual-storytelling-backup-$PID"
    if (Test-Path $backupRoot) { Remove-Item $backupRoot -Recurse -Force }
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    try {
        foreach ($relativeRoot in $controlledRelativeRoots) {
            $target = Join-Path $MallRoot $relativeRoot
            if (Test-Path $target) {
                $backup = Join-Path $backupRoot $relativeRoot
                New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
                Copy-Item $target $backup -Recurse
            }
        }
        foreach ($relativeRoot in $managedRelativeRoots) {
            $target = Join-Path $MallRoot $relativeRoot
            $staged = Join-Path $outputRoot $relativeRoot
            if (-not (Test-Path $staged)) { throw "Staged payload missing: $relativeRoot" }
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
            New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
            Copy-Item $staged $target -Recurse
        }
        foreach ($relativeRoot in $retiredRelativeRoots) {
            $target = Join-Path $MallRoot $relativeRoot
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
        }
    }
    catch {
        foreach ($relativeRoot in $controlledRelativeRoots) {
            $target = Join-Path $MallRoot $relativeRoot
            $backup = Join-Path $backupRoot $relativeRoot
            if (Test-Path $target) { Remove-Item $target -Recurse -Force }
            if (Test-Path $backup) {
                New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
                Copy-Item $backup $target -Recurse
            }
        }
        throw
    }
    finally {
        if (Test-Path $backupRoot) { Remove-Item $backupRoot -Recurse -Force }
        if ($temporaryAssembly -and (Test-Path $outputRoot)) { Remove-Item $outputRoot -Recurse -Force }
    }
    Write-Host "Applied Visual Storytelling payloads to $MallRoot"
    exit 0
}

if ($AssembleOnly) {
    Write-Host "PASS: assembled Visual Storytelling payloads at $outputRoot" -ForegroundColor Green
    exit 0
}

$differences = [System.Collections.Generic.List[string]]::new()
Get-ChildItem $outputRoot -File -Recurse | ForEach-Object {
    $relative = [IO.Path]::GetRelativePath($outputRoot, $_.FullName)
    $actual = Join-Path $MallRoot $relative
    if (-not (Test-Path $actual)) { $differences.Add("missing: $relative"); return }
    if ($_.Extension -eq '.json') {
        $expectedJson = (Get-Content $_.FullName -Raw | ConvertFrom-Json) | ConvertTo-Json -Depth 30 -Compress
        $actualJson = (Get-Content $actual -Raw | ConvertFrom-Json) | ConvertTo-Json -Depth 30 -Compress
        if ($expectedJson -ne $actualJson) { $differences.Add("json drift: $relative") }
    }
    else {
        $expectedText = (Get-Content $_.FullName -Raw) -replace "`r`n", "`n"
        $actualText = (Get-Content $actual -Raw) -replace "`r`n", "`n"
        if ($expectedText -ne $actualText) { $differences.Add("content drift: $relative") }
    }
}
foreach ($relativeRoot in $managedRelativeRoots) {
    $actualRoot = Join-Path $MallRoot $relativeRoot
    if (-not (Test-Path $actualRoot)) { continue }
    Get-ChildItem $actualRoot -File -Recurse | ForEach-Object {
        $relative = [IO.Path]::GetRelativePath($MallRoot, $_.FullName)
        if (-not (Test-Path (Join-Path $outputRoot $relative))) {
            $differences.Add("unexpected: $relative")
        }
    }
}
foreach ($relativeRoot in $retiredRelativeRoots) {
    if (Test-Path (Join-Path $MallRoot $relativeRoot)) {
        $differences.Add("retired path remains: $relativeRoot")
    }
}
if ($temporaryAssembly -and (Test-Path $outputRoot)) { Remove-Item $outputRoot -Recurse -Force }
if ($differences.Count) {
    $differences | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    throw "$($differences.Count) payload difference(s) found"
}
Write-Host 'PASS: clean source assembly reproduces the current Mall payloads.' -ForegroundColor Green
