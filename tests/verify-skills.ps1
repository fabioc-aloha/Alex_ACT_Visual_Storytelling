[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

function Assert-SkillContains(
  [string]$RelativePath,
  [string]$Pattern,
  [string]$Label
) {
  $content = Get-Content (Join-Path $repoRoot $RelativePath) -Raw
  if ($content -notmatch $Pattern) {
    $failures.Add("$Label missing from ${RelativePath}: $Pattern")
  }
}

$requirementsSkill = 'plugins/storytelling-requirements/SKILL.md'
$preparationSkill = 'plugins/data-preparation/SKILL.md'
$connectorsSkill = 'plugins/datasource-connectors/SKILL.md'
$bundleSkill = 'plugins/visual-storytelling/SKILL.md'
$vocabularySkill = 'plugins/visual-vocabulary/SKILL.md'
$htmlSkill = 'plugins/delivery-html-dashboard/SKILL.md'
$svgSkill = 'plugins/delivery-svg-markdown/SKILL.md'

Assert-SkillContains $requirementsSkill 'Claim Computability Gate' 'Claim gate section'
Assert-SkillContains $requirementsSkill '(?s)Claim.*Required fields.*Formula.*Grain.*Status' 'Claim contract fields'
Assert-SkillContains $requirementsSkill '(?i)not computable.*evidence boundary' 'Missing-input fallback'

Assert-SkillContains $preparationSkill 'Metric Lineage Contract' 'Metric lineage section'
Assert-SkillContains $preparationSkill '(?s)Formula.*Source fields.*Grain.*Units.*Rounding.*Baseline' 'Metric lineage fields'
Assert-SkillContains $preparationSkill '(?i)per.*denominator.*source' 'Denominator requirement'

Assert-SkillContains $connectorsSkill 'Required Column Contract' 'Required-column section'
Assert-SkillContains $connectorsSkill '(?i)missing required columns' 'Required-column failure message'
Assert-SkillContains $connectorsSkill '(?i)before.*aggregation' 'Pre-aggregation schema gate'

Assert-SkillContains $bundleSkill 'Executable Example Contract' 'Example contract section'
Assert-SkillContains $bundleSkill '(?s)brief.*embedded data.*labels.*aria.*action' 'Cross-surface validation'
Assert-SkillContains $bundleSkill '(?i)mutation.*decision-bearing' 'Data-story mutation rule'
Assert-SkillContains $bundleSkill '(?i)Mitigated' 'Mitigated audit state'
Assert-SkillContains $bundleSkill '(?i)leave it unchecked' 'Unchecked mitigation rule'
Assert-SkillContains $bundleSkill '(?i)Resolved' 'Resolved audit state'

foreach ($skill in $requirementsSkill, $vocabularySkill, $bundleSkill) {
  Assert-SkillContains $skill 'CSAR always means.*Clarify.*Summarize.*Act.*Reflect' 'Canonical CSAR definition'
}

Assert-SkillContains $htmlSkill 'Runtime Render Gate' 'HTML runtime render section'
Assert-SkillContains $htmlSkill '(?s)390px.*scrollWidth.*clientWidth' 'Mobile overflow measurement'
Assert-SkillContains $htmlSkill '(?is)every chart.*category label' 'Per-chart label check'
Assert-SkillContains $htmlSkill '(?is)block.*CDN.*Charts unavailable' 'Blocked-resource fallback check'

Assert-SkillContains $svgSkill 'Prose-Fit Gate' 'SVG prose-fit section'
Assert-SkillContains $svgSkill '(?i)sentence-length.*document body' 'Move prose out of SVG'
Assert-SkillContains $svgSkill '(?is)render.*clipped.*overflow' 'Rendered clipping check'

$componentNames = @(
  'storytelling-requirements',
  'datasource-connectors',
  'data-preparation',
  'visual-vocabulary',
  'delivery-ascii-dashboard',
  'delivery-svg-markdown',
  'delivery-html-dashboard'
)
$bundleTokens = 0
foreach ($name in $componentNames) {
  $skillPath = Join-Path $repoRoot "plugins/$name/SKILL.md"
  $manifestPath = Join-Path $repoRoot "plugins/$name/plugin.json"
  $skillContent = (Get-Content $skillPath -Raw) -replace "`r`n", "`n"
  $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
  $expectedTokens = [int]([math]::Round((($skillContent.Length / 4) / 100)) * 100)
  if ($manifest.token_cost -ne $expectedTokens) {
    $failures.Add("$name token_cost expected $expectedTokens but found $($manifest.token_cost)")
  }
  $bundleTokens += $expectedTokens
}

$bundleManifest = Get-Content (Join-Path $repoRoot 'plugins/visual-storytelling/plugin.json') -Raw | ConvertFrom-Json
if ($bundleManifest.token_cost -ne $bundleTokens) {
  $failures.Add("visual-storytelling bundle token_cost expected $bundleTokens but found $($bundleManifest.token_cost)")
}

$formattedBundleTokens = $bundleTokens.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture)
foreach ($document in 'README.md', 'plugins/visual-storytelling/README.md', 'TODO.md') {
  Assert-SkillContains $document ([regex]::Escape($formattedBundleTokens)) 'Live bundle token total'
}

foreach ($skill in $requirementsSkill, $preparationSkill, $connectorsSkill, $bundleSkill, $vocabularySkill, $htmlSkill, $svgSkill) {
  Assert-SkillContains $skill 'currency: 2026-08-06' 'Current skill currency'
  Assert-SkillContains $skill 'lastReviewed: 2026-08-06' 'Current skill review date'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
  throw "Skill verification failed with $($failures.Count) finding(s)."
}

Write-Host 'PASS: reusable visual-storytelling safeguards are encoded in skills.' -ForegroundColor Green
