[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$root = Join-Path ([IO.Path]::GetTempPath()) "visual-storytelling-publisher-$PID"
$source = Join-Path $root 'source'
$mall = Join-Path $root 'mall'

function Invoke-Publisher([string[]]$Arguments) {
  $publisher = Join-Path $source 'scripts/publish-to-mall.ps1'
  $output = @(& pwsh -NoProfile -File $publisher @Arguments 2>&1)
  [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output -join "`n") }
}

try {
  New-Item -ItemType Directory -Path (Join-Path $source 'scripts') -Force | Out-Null
  New-Item -ItemType Directory -Path $mall -Force | Out-Null
  Copy-Item (Join-Path $repoRoot 'plugins') $source -Recurse
  Copy-Item (Join-Path $repoRoot 'scripts/publish-to-mall.ps1') (Join-Path $source 'scripts')

  & git -C $source init --quiet
  & git -C $source add -A
  & git -C $source -c user.name='Visual Storytelling Test' -c user.email='test@example.invalid' commit --quiet -m fixture
  if ($LASTEXITCODE -ne 0) { throw 'Unable to commit source fixture' }
  $head = (& git -C $source rev-parse HEAD).Trim()

  & git -C $mall init --quiet
  $stale = Join-Path $mall 'plugins/data-analytics/visual-storytelling/skills/stale/SKILL.md'
  New-Item -ItemType Directory -Path (Split-Path -Parent $stale) -Force | Out-Null
  Set-Content $stale '# stale'

  $apply = Invoke-Publisher @('-MallRoot', $mall, '-Ref', $head, '-Apply')
  if ($apply.ExitCode -ne 0) { throw "Apply failed: $($apply.Output)" }
  if (Test-Path $stale) { throw 'Apply retained a stale payload file' }
  if (-not (Test-Path (Join-Path $mall 'plugins/data-analytics/visual-storytelling/agents/visual-storytelling.agent.md'))) {
    throw 'Apply omitted the installable agent'
  }
  $wrapper = Get-Content (Join-Path $mall 'plugins/data-analytics/visual-storytelling/skills/visual-storytelling/SKILL.md') -Raw
  if ($wrapper -notmatch 'skills/storytelling-requirements/SKILL\.md') {
    throw 'Apply omitted bundle-local component paths'
  }
  if ($wrapper -match '\.github/skills/local/|plugins/[^/]+/SKILL\.md') {
    throw 'Apply retained source-layout component paths'
  }

  New-Item -ItemType Directory -Path (Split-Path -Parent $stale) -Force | Out-Null
  Set-Content $stale '# stale'
  $preview = Invoke-Publisher @('-MallRoot', $mall, '-Ref', $head)
  if ($preview.ExitCode -eq 0 -or $preview.Output -notmatch 'unexpected:') {
    throw 'Preview did not fail on an unexpected payload file'
  }
  Remove-Item (Split-Path -Parent (Split-Path -Parent $stale)) -Recurse -Force

  $wrongRef = '0' * 40
  $invalid = Invoke-Publisher @('-MallRoot', $mall, '-Ref', $wrongRef)
  if ($invalid.ExitCode -eq 0 -or $invalid.Output -notmatch 'exact source commit') {
    throw 'Publisher accepted an unrelated source ref'
  }

  Add-Content (Join-Path $source 'plugins/visual-storytelling/README.md') 'dirty'
  $dirty = Invoke-Publisher @('-MallRoot', $mall, '-Ref', $head)
  if ($dirty.ExitCode -eq 0 -or $dirty.Output -notmatch 'worktree must be clean') {
    throw 'Publisher accepted dirty source content'
  }

  Write-Host 'PASS: publisher pins clean provenance and replaces managed payload roots.' -ForegroundColor Green
}
finally {
  if (Test-Path $root) { Remove-Item $root -Recurse -Force }
}