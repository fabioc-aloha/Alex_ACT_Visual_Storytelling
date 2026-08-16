[CmdletBinding()]
param(
  [string]$MallRoot = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'Alex_ACT_Plugin_Mall')
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()
$expectedVersion = '2.0.1'

function Add-Failure([string]$Message) {
  $failures.Add($Message)
}

function Read-Json([string]$Path) {
  return Get-Content $Path -Raw | ConvertFrom-Json
}

function Assert-Equal($Expected, $Actual, [string]$Label) {
  if ($Expected -ne $Actual) {
    Add-Failure "$Label expected '$Expected' but found '$Actual'"
  }
}

function Assert-Match([string]$Content, [string]$Pattern, [string]$Label) {
  if ($Content -notmatch $Pattern) {
    Add-Failure "$Label is missing pattern: $Pattern"
  }
}

if (-not (Test-Path (Join-Path $MallRoot '.git'))) {
  throw "Mall clone not found: $MallRoot"
}

$components = @(
  [pscustomobject]@{ Name = 'storytelling-requirements'; Category = 'data-analytics'; Standalone = $true },
  [pscustomobject]@{ Name = 'datasource-connectors'; Category = 'data-analytics'; Standalone = $true },
  [pscustomobject]@{ Name = 'data-preparation'; Category = 'data-analytics'; Standalone = $true },
  [pscustomobject]@{ Name = 'delivery-ascii-dashboard'; Category = 'data-analytics'; Standalone = $true }
)

$bundleRoot = Join-Path $MallRoot 'plugins/data-analytics/visual-storytelling'
$expectedBundleTokens = 0

foreach ($component in $components) {
  $sourceRoot = Join-Path $repoRoot "plugins/$($component.Name)"
  $sourceManifest = Read-Json (Join-Path $sourceRoot 'plugin.json')
  $sourceSkill = Join-Path $sourceRoot 'SKILL.md'
  $sourceContent = (Get-Content $sourceSkill -Raw) -replace "`r`n", "`n"
  $expectedTokens = [int]([math]::Round((($sourceContent.Length / 4) / 100)) * 100)
  $expectedBundleTokens += $expectedTokens

  Assert-Equal $expectedVersion $sourceManifest.version "$($component.Name) source version"
  Assert-Equal $expectedTokens $sourceManifest.token_cost "$($component.Name) source token cost"
  if ($sourceManifest.PSObject.Properties.Name -contains 'requires_edition') {
    Add-Failure "$($component.Name) source manifest retains legacy requires_edition"
  }
  if ($sourceManifest.PSObject.Properties.Name -contains 'install_paths') {
    Add-Failure "$($component.Name) source manifest retains legacy install_paths"
  }

  $bundledSkill = Join-Path $bundleRoot "skills/$($component.Name)/SKILL.md"
  if (-not (Test-Path $bundledSkill)) {
    Add-Failure "Bundled skill missing: $bundledSkill"
  }
  else {
    Assert-Equal (Get-FileHash $sourceSkill).Hash (Get-FileHash $bundledSkill).Hash "$($component.Name) bundled skill hash"
  }

  if ($component.Standalone) {
    $standaloneRoot = Join-Path $MallRoot "plugins/$($component.Category)/$($component.Name)"
    $standaloneManifest = Read-Json (Join-Path $standaloneRoot 'plugin.json')
    $standaloneMetadata = Read-Json (Join-Path $standaloneRoot '.mall-metadata.json')
    $standaloneSkill = Join-Path $standaloneRoot "skills/$($component.Name)/SKILL.md"
    Assert-Equal $expectedVersion $standaloneManifest.version "$($component.Name) Mall version"
    Assert-Equal $expectedTokens $standaloneMetadata.token_cost "$($component.Name) Mall token cost"
    Assert-Equal (Get-FileHash $sourceSkill).Hash (Get-FileHash $standaloneSkill).Hash "$($component.Name) standalone skill hash"
  }
}

$sourceBundleManifest = Read-Json (Join-Path $repoRoot 'plugins/visual-storytelling/plugin.json')
$mallBundleManifest = Read-Json (Join-Path $bundleRoot 'plugin.json')
$mallBundleMetadata = Read-Json (Join-Path $bundleRoot '.mall-metadata.json')
Assert-Equal $expectedVersion $sourceBundleManifest.version 'Source bundle version'
Assert-Equal $expectedVersion $mallBundleManifest.version 'Mall bundle version'
Assert-Equal $expectedBundleTokens $sourceBundleManifest.token_cost 'Source bundle token cost'
Assert-Equal $expectedBundleTokens $mallBundleMetadata.token_cost 'Mall bundle token cost'
Assert-Equal 'v2.0.1' $mallBundleMetadata.upstream.ref 'Mall bundle source tag'
if ($sourceBundleManifest.PSObject.Properties.Name -contains 'requires_edition') {
  Add-Failure 'Source bundle manifest retains legacy requires_edition'
}
if ($sourceBundleManifest.PSObject.Properties.Name -contains 'install_paths') {
  Add-Failure 'Source bundle manifest retains legacy install_paths'
}

$wrapper = Get-Content (Join-Path $bundleRoot 'skills/visual-storytelling/SKILL.md') -Raw
Assert-Match $wrapper 'Executable Example Contract' 'Bundle executable example guidance'
Assert-Match $wrapper 'CSAR always means.*Clarify.*Summarize.*Act.*Reflect' 'Bundle canonical CSAR'
Assert-Match $wrapper 'alex-act-illustrator-plugin' 'Bundle Illustrator dependency'
Assert-Match $wrapper 'chart-vocabulary' 'Bundle Illustrator chart selection'

$agent = Get-Content (Join-Path $bundleRoot 'agents/visual-storytelling.agent.md') -Raw
Assert-Match $agent 'CSAR.*Clarify.*Summarize.*Act.*Reflect' 'Installable agent canonical CSAR'
Assert-Match $agent '(?i)evidence boundary' 'Installable agent evidence boundary'
Assert-Match $agent '(?i)metric lineage' 'Installable agent metric lineage'
Assert-Match $agent 'chart-vocabulary' 'Installable agent Illustrator chart selection'
Assert-Match $agent 'alex-act-illustrator-plugin' 'Installable agent Illustrator dependency'
$sourceAgent = Get-Content (Join-Path $repoRoot 'plugins/visual-storytelling/visual-storytelling.agent.md') -Raw
Assert-Match $sourceAgent '(?m)^model: "claude-sonnet-5"\r?$' 'Source agent scalar model policy'
Assert-Match $sourceAgent 'chart-vocabulary' 'Source agent Illustrator chart selection'
Assert-Match $sourceAgent 'alex-act-illustrator-plugin' 'Source agent Illustrator dependency'

$staleLocalAgent = Join-Path $repoRoot '.github/agents/local/visual-storytelling.agent.md'
if (Test-Path $staleLocalAgent) {
  Add-Failure 'Stale repository-local orchestrator remains beside the shipped agent'
}

foreach ($retiredPath in @(
    'plugins/visual-vocabulary',
    'plugins/delivery-svg-markdown',
    'plugins/delivery-html-dashboard'
  )) {
  if (Test-Path (Join-Path $repoRoot $retiredPath)) {
    Add-Failure "Retired Visual Storytelling path remains active: $retiredPath"
  }
}

foreach ($retiredMallPath in @(
    'plugins/data-analytics/delivery-html-dashboard',
    'plugins/media-graphics/delivery-svg-markdown'
  )) {
  if (Test-Path (Join-Path $MallRoot $retiredMallPath)) {
    Add-Failure "Retired Mall path remains published: $retiredMallPath"
  }
}

$cleanHeir = Get-Content (Join-Path $repoRoot 'tests/clean-heir.ps1') -Raw
Assert-Match $cleanHeir '--agent visual-storytelling:visual-storytelling' 'Clean-heir plugin-qualified agent identity'
Assert-Match $cleanHeir 'describe --exact-match --tags HEAD' 'Clean-heir immutable release tag'
Assert-Match $cleanHeir 'git -C \$heir init --quiet' 'Clean-heir Git workspace initialization'
Assert-Match $cleanHeir 'commit --quiet -m fixture' 'Clean-heir committed fixture'
Assert-Match $cleanHeir 'remote add origin https://github\.com/fabioc-aloha/Alex_ACT_Visual_Storytelling\.git' 'Clean-heir public origin'
Assert-Match $cleanHeir '--disable-builtin-mcps' 'Clean-heir built-in MCP isolation'
Assert-Match $cleanHeir '--model claude-sonnet-5' 'Clean-heir explicit model selection'
Assert-Match $cleanHeir '\[int\]\$MaxAiCredits = 60' 'Clean-heir evidence-based credit ceiling'
Assert-Match $cleanHeir "'139,100'.*'107,300'.*'148,800'.*'97,600'" 'Clean-heir brief-aligned comparison claims'
Assert-Match $cleanHeir 'Retained failed clean-heir fixture for diagnosis' 'Clean-heir failure artifact retention'
Assert-Match $cleanHeir 'Response: \$diagnostic' 'Clean-heir bounded response diagnostics'

$publisher = Get-Content (Join-Path $repoRoot 'scripts/publish-to-mall.ps1') -Raw
Assert-Match $publisher 'Ref must equal the source repository HEAD' 'Publisher immutable source identity'
Assert-Match $publisher "ValidatePattern\('\^v\\d\+\\.\\d\+\\.\\d\+\$'\)" 'Publisher semantic release tag'
Assert-Match $publisher 'Ref must resolve to a source tag' 'Publisher source tag validation'
Assert-Match $publisher 'Source worktree must be clean' 'Publisher clean source requirement'
Assert-Match $publisher 'Remove-Item \$target -Recurse -Force' 'Publisher stale payload replacement'
Assert-Match $publisher 'unexpected: \$relative' 'Publisher unexpected-file comparison'
Assert-Match $publisher 'Staged payload missing' 'Publisher complete staging requirement'
Assert-Match $publisher 'visual-storytelling-backup' 'Publisher rollback staging'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
  throw "Plugin verification failed with $($failures.Count) finding(s)."
}

Write-Host "PASS: visual-storytelling $expectedVersion is synchronized to the Mall bundle and standalone plugins." -ForegroundColor Green
