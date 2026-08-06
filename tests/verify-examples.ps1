[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot 'datasets/sales-sample.csv'
$failures = [System.Collections.Generic.List[string]]::new()

function Add-Failure([string]$Message) {
  $failures.Add($Message)
}

function Assert-Equal($Expected, $Actual, [string]$Label) {
  if ($Expected -ne $Actual) {
    Add-Failure "$Label expected '$Expected' but found '$Actual'"
  }
}

function Assert-Contains([string]$Content, [string]$Pattern, [string]$Label) {
  if ($Content -notmatch $Pattern) {
    Add-Failure "$Label is missing pattern: $Pattern"
  }
}

function Assert-NotContains([string]$Content, [string]$Pattern, [string]$Label) {
  if ($Content -match $Pattern) {
    Add-Failure "$Label contains forbidden pattern: $Pattern"
  }
}

$rows = Import-Csv $dataPath
$requiredColumns = 'date', 'region', 'product', 'revenue', 'units', 'cost'
$actualColumns = @($rows[0].PSObject.Properties.Name)
Assert-Equal 24 $rows.Count 'CSV row count'
foreach ($column in $requiredColumns) {
  Assert-Contains ($actualColumns -join ',') "(?i)(^|,)$([regex]::Escape($column))(,|$)" "CSV column '$column'"
}

$totalRevenue = [int](($rows | Measure-Object revenue -Sum).Sum)
$totalCost = [int](($rows | Measure-Object cost -Sum).Sum)
$totalMargin = $totalRevenue - $totalCost
$totalUnits = [int](($rows | Measure-Object units -Sum).Sum)
$unitText = $totalUnits.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture)

$monthly = $rows | Group-Object date | ForEach-Object {
  [pscustomobject]@{
    Date    = [datetime]$_.Name
    Revenue = [int](($_.Group | Measure-Object revenue -Sum).Sum)
  }
} | Sort-Object Date

$segmentGrowth = $rows | Group-Object region, product | ForEach-Object {
  $ordered = $_.Group | Sort-Object { [datetime]$_.date }
  $startRevenue = [double]$ordered[0].revenue
  $peakRevenue = [double](($ordered | Measure-Object revenue -Maximum).Maximum)
  [pscustomobject]@{
    Segment = ($_.Name -replace ', ', ' ')
    Revenue = [int](($ordered | Measure-Object revenue -Sum).Sum)
    Margin  = [int](($ordered | ForEach-Object { [int]$_.revenue - [int]$_.cost } | Measure-Object -Sum).Sum)
    Growth  = [math]::Round((($peakRevenue / $startRevenue) - 1) * 100, 1)
  }
} | Sort-Object Growth -Descending

foreach ($segment in $segmentGrowth) {
  $segment | Add-Member -NotePropertyName Share -NotePropertyValue ([math]::Round(($segment.Revenue / $totalRevenue) * 100, 1))
}

$janToJunGrowth = [math]::Round(
  (($monthly[-1].Revenue / $monthly[0].Revenue) - 1) * 100,
  1
)

Assert-Equal 246400 $totalRevenue 'CSV total revenue'
Assert-Equal 73920 $totalMargin 'CSV total margin'
Assert-Equal 4928 $totalUnits 'CSV total units'
Assert-Equal 16.6 $janToJunGrowth 'CSV Jan-to-Jun growth'
Assert-Equal 'North Widget B' $segmentGrowth[0].Segment 'Fastest-growing segment'
Assert-Equal 22.9 $segmentGrowth[0].Growth 'Fastest segment Jan-to-peak growth'

$examplePaths = @(
  'tests/sales-dashboard-ascii.md',
  'tests/sales-dashboard-ascii-output.md',
  'tests/sales-dashboard-svg.md',
  'tests/sales-dashboard-svg-output.md',
  'tests/sales-dashboard-html.md',
  'tests/sales-dashboard-html-output.html'
)
$exampleContent = @{}

foreach ($relativePath in $examplePaths) {
  $fullPath = Join-Path $repoRoot $relativePath
  $content = Get-Content $fullPath -Raw
  $exampleContent[$relativePath] = $content
  Assert-NotContains $content '(?i)margin per marketing dollar|marginEfficiency|\$18K|\$50K|strongest revenue growth|current growth leader' $relativePath
}

foreach ($relativePath in @(
    'tests/sales-dashboard-ascii-output.md',
    'tests/sales-dashboard-svg.md',
    'tests/sales-dashboard-svg-output.md',
    'tests/sales-dashboard-html.md',
    'tests/sales-dashboard-html-output.html'
  )) {
  Assert-Contains $exampleContent[$relativePath] ([regex]::Escape($unitText)) "$relativePath unit total"
  Assert-NotContains $exampleContent[$relativePath] '5,448|5448' "$relativePath stale unit total"
}

$asciiOutput = $exampleContent['tests/sales-dashboard-ascii-output.md']
foreach ($heading in 'Monthly Revenue Trend', 'Revenue by Region', 'Revenue by Product') {
  Assert-Contains $asciiOutput ([regex]::Escape($heading)) "ASCII visual '$heading'"
}

$asciiLines = $asciiOutput -split "`r?`n"
$fenceStart = [Array]::IndexOf($asciiLines, '```text') + 1
$fenceEnd = [Array]::IndexOf($asciiLines, '```', $fenceStart)
if ($fenceStart -le 0 -or $fenceEnd -lt $fenceStart) {
  Add-Failure 'ASCII output does not contain a complete text fence'
}
else {
  foreach ($line in $asciiLines[$fenceStart..($fenceEnd - 1)]) {
    if ($line.Length -gt 0 -and $line.Length -ne 78) {
      Add-Failure "ASCII line width is $($line.Length), expected 78: $line"
    }
  }
}

$builderPath = Join-Path $repoRoot 'templates/build-ascii-dashboard.ps1'
$builderContent = Get-Content $builderPath -Raw
Assert-Contains $builderContent 'Import-Csv' 'ASCII builder data ingestion'
Assert-Contains $builderContent '\$PSScriptRoot' 'ASCII builder repository-relative paths'
Assert-Contains $builderContent 'DataPath' 'ASCII builder DataPath parameter'
Assert-Contains $builderContent 'OutputPath' 'ASCII builder OutputPath parameter'
Assert-NotContains $builderContent '(?i)c:\\Development\\Alex_ACT_Visual_Storytelling' 'ASCII builder absolute paths'

$simpleBuilderPath = Join-Path $repoRoot 'templates/build-ascii-dashboard-simple.ps1'
if (Test-Path $simpleBuilderPath) {
  Add-Failure 'Duplicate simple ASCII builder still exists'
}

if ($builderContent -match 'DataPath' -and $builderContent -match 'OutputPath') {
  $temporaryOutput = Join-Path ([System.IO.Path]::GetTempPath()) 'sales-dashboard-ascii-audit.md'
  try {
    & $builderPath -DataPath $dataPath -OutputPath $temporaryOutput
    if ($LASTEXITCODE -ne 0) {
      Add-Failure "ASCII builder exited with code $LASTEXITCODE"
    }
    elseif ((Get-Content $temporaryOutput -Raw) -ne $asciiOutput) {
      Add-Failure 'ASCII committed output does not match a fresh CSV-driven build'
    }
  }
  finally {
    Remove-Item $temporaryOutput -Force -ErrorAction SilentlyContinue
  }
}

$malformedDataPath = Join-Path ([System.IO.Path]::GetTempPath()) 'sales-dashboard-missing-cost.csv'
$malformedOutputPath = Join-Path ([System.IO.Path]::GetTempPath()) 'sales-dashboard-malformed.md'
$schemaFailure = $null
try {
  [System.IO.File]::WriteAllText(
    $malformedDataPath,
    "date,region,product,revenue,units`n2024-01-01,North,Widget A,12500,250`n",
    [System.Text.UTF8Encoding]::new($false)
  )
  try {
    & $builderPath -DataPath $malformedDataPath -OutputPath $malformedOutputPath
  }
  catch {
    $schemaFailure = $_.Exception.Message
  }
}
finally {
  Remove-Item $malformedDataPath, $malformedOutputPath -Force -ErrorAction SilentlyContinue
}
if ($schemaFailure -notmatch 'CSV missing required columns: cost') {
  Add-Failure "ASCII builder schema guard returned unexpected result: $schemaFailure"
}

$htmlOutput = $exampleContent['tests/sales-dashboard-html-output.html']
Assert-Contains $htmlOutput 'echarts@6\.1\.0/dist/echarts\.min\.js' 'HTML exact ECharts version'
Assert-Contains $htmlOutput 'sha384-C2iskrW/uPW46KzOjrvJIQo4YkV8lkD\+QS0CrDN18IIPIpT/g2USu8bTP3nvmIAD' 'HTML ECharts integrity'
Assert-Contains $htmlOutput 'crossorigin="anonymous"' 'HTML ECharts CORS mode'
Assert-Contains $htmlOutput 'min-width:\s*0' 'HTML responsive grid item'
Assert-Contains $htmlOutput 'segmentGrowth' 'HTML segment growth data'
Assert-Contains $htmlOutput 'North Widget B' 'HTML fastest-growth finding'
Assert-Contains $htmlOutput '22\.9' 'HTML fastest-growth value'
Assert-Contains $htmlOutput 'Add campaign-spend data before reallocating budget' 'HTML evidence boundary'
Assert-Contains $htmlOutput 'Charts unavailable' 'HTML visible CDN failure state'
Assert-Contains $htmlOutput "(?s)function buildSegmentGrowthOption.*?yAxis:\s*\{.*?type:\s*'category'.*?inverse:\s*true.*?xAxis:\s*\{.*?type:\s*'value'" 'HTML mobile-readable horizontal growth chart'

$htmlSkill = Get-Content (Join-Path $repoRoot 'plugins/delivery-html-dashboard/SKILL.md') -Raw
$htmlReadme = Get-Content (Join-Path $repoRoot 'plugins/delivery-html-dashboard/README.md') -Raw
foreach ($source in @(
    @{ Label = 'HTML skill'; Content = $htmlSkill },
    @{ Label = 'HTML README'; Content = $htmlReadme }
  )) {
  Assert-Contains $source.Content 'echarts@6\.1\.0/dist/echarts\.min\.js' "$($source.Label) exact ECharts version"
  Assert-Contains $source.Content 'sha384-C2iskrW/uPW46KzOjrvJIQo4YkV8lkD\+QS0CrDN18IIPIpT/g2USu8bTP3nvmIAD' "$($source.Label) ECharts integrity"
  Assert-NotContains $source.Content 'echarts@6/dist/echarts\.min\.js' "$($source.Label) mutable ECharts major URL"
}
Assert-Contains $htmlSkill 'totalUnits:\s*4928' 'HTML skill correct unit example'
Assert-NotContains $htmlSkill 'totalUnits:\s*5448' 'HTML skill stale unit example'

$htmlBrief = $exampleContent['tests/sales-dashboard-html.md']
$svgBrief = $exampleContent['tests/sales-dashboard-svg.md']
$svgOutput = $exampleContent['tests/sales-dashboard-svg-output.md']
foreach ($segment in $segmentGrowth) {
  $abbreviation = $segment.Segment -replace '^North ', 'N. ' -replace '^South ', 'S. '
  $revenueComma = $segment.Revenue.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture)
  $marginComma = $segment.Margin.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture)
  $revenueK = ($segment.Revenue / 1000).ToString('N1', [System.Globalization.CultureInfo]::InvariantCulture)
  $share = $segment.Share.ToString('N1', [System.Globalization.CultureInfo]::InvariantCulture)
  $growth = $segment.Growth.ToString('N1', [System.Globalization.CultureInfo]::InvariantCulture)
  $revenueCurrency = [regex]::Escape('$' + $revenueComma)
  $marginCurrency = [regex]::Escape('$' + $marginComma)
  $revenueKCurrency = [regex]::Escape('$' + $revenueK + 'K')

  Assert-Contains $htmlBrief "(?s)$([regex]::Escape($segment.Segment)).*?$revenueCurrency.*?$marginCurrency.*?$growth%" "HTML brief metrics for $($segment.Segment)"
  Assert-Contains $svgBrief "(?s)$([regex]::Escape($segment.Segment)).*?$revenueCurrency.*?$share%" "SVG brief share for $($segment.Segment)"
  Assert-Contains $svgBrief "(?s)$([regex]::Escape($segment.Segment)).*?$growth%" "SVG brief growth for $($segment.Segment)"
  Assert-Contains $htmlOutput "(?s)name:\s*'$([regex]::Escape($abbreviation))'.*?revenue:\s*$($segment.Revenue).*?margin:\s*$($segment.Margin)" "HTML data for $abbreviation"
  Assert-Contains $htmlOutput "(?s)name:\s*'$([regex]::Escape($segment.Segment))'.*?value:\s*$growth" "HTML growth for $($segment.Segment)"
  Assert-Contains $svgOutput "$([regex]::Escape($abbreviation))\s+$share%\s+\($revenueKCurrency" "SVG share for $abbreviation"
  Assert-Contains $svgOutput "(?s)$([regex]::Escape($abbreviation)).*?$growth%" "SVG growth for $abbreviation"
}

$svgMarkup = [regex]::Match($svgOutput, '<svg[\s\S]*?</svg>').Value
if ([string]::IsNullOrWhiteSpace($svgMarkup)) {
  Add-Failure 'SVG output has no inline SVG element'
}
else {
  try {
    $null = [xml]$svgMarkup
  }
  catch {
    Add-Failure "SVG XML is invalid: $($_.Exception.Message)"
  }
}
Assert-Contains $svgOutput 'North Widget B grows fastest' 'SVG truthful growth title'
Assert-Contains $svgOutput 'Add campaign-spend data before reallocating budget' 'SVG evidence boundary'
Assert-NotContains $svgOutput '<(style|script|foreignObject)\b' 'SVG forbidden elements'

$verificationRecord = Get-Content (Join-Path $repoRoot 'tests/DASHBOARD_VERIFICATION.txt') -Raw
Assert-Contains $verificationRecord 'tests/verify-examples\.ps1' 'Verification record command'
Assert-Contains $verificationRecord '4,928' 'Verification record unit total'
Assert-Contains $verificationRecord 'ECharts 6\.1\.0' 'Verification record dependency version'
Assert-Contains $verificationRecord '390px' 'Verification record mobile viewport'
Assert-Contains $verificationRecord 'no clipped text' 'Verification record SVG result'
Assert-Contains $verificationRecord 'missing-cost schema case' 'Verification record schema guard'
Assert-Contains $verificationRecord '22\.6% -> 22\.7%' 'Verification record SVG mutation'
Assert-NotContains $verificationRecord '(?i)5,448|margin per marketing dollar|\$18K' 'Verification record stale claims'

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
  throw "Example verification failed with $($failures.Count) finding(s)."
}

Write-Host 'PASS: all sales examples match the CSV and delivery contracts.' -ForegroundColor Green
