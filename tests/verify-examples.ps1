[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $repoRoot 'datasets/sales-sample.csv'
$sourcePath = Join-Path $repoRoot 'tests/sales-dashboard-ascii.md'
$outputPath = Join-Path $repoRoot 'tests/sales-dashboard-ascii-output.md'
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

$rows = Import-Csv $dataPath
$requiredColumns = 'date', 'region', 'product', 'revenue', 'units', 'cost'
$columns = @($rows[0].PSObject.Properties.Name)
Assert-Equal 24 $rows.Count 'CSV row count'
foreach ($column in $requiredColumns) {
  if ($columns -notcontains $column) {
    Add-Failure "CSV is missing required column: $column"
  }
}

$totalRevenue = [int](($rows | Measure-Object revenue -Sum).Sum)
$totalCost = [int](($rows | Measure-Object cost -Sum).Sum)
$totalMargin = $totalRevenue - $totalCost
$totalUnits = [int](($rows | Measure-Object units -Sum).Sum)
$monthly = $rows | Group-Object date | ForEach-Object {
  [pscustomobject]@{
    Date = [datetime]$_.Name
    Revenue = [int](($_.Group | Measure-Object revenue -Sum).Sum)
  }
} | Sort-Object Date
$janToJunGrowth = [math]::Round((($monthly[-1].Revenue / $monthly[0].Revenue) - 1) * 100, 1)

Assert-Equal 246400 $totalRevenue 'CSV total revenue'
Assert-Equal 73920 $totalMargin 'CSV total margin'
Assert-Equal 4928 $totalUnits 'CSV total units'
Assert-Equal 16.6 $janToJunGrowth 'CSV Jan-to-Jun growth'

$source = Get-Content $sourcePath -Raw
$output = Get-Content $outputPath -Raw
foreach ($content in @($source, $output)) {
  if ($content -match '(?i)margin per marketing dollar|marginEfficiency|\$18K|\$50K') {
    Add-Failure 'ASCII example retains a superseded decision claim'
  }
}

foreach ($heading in 'Monthly Revenue Trend', 'Revenue by Region', 'Revenue by Product') {
  Assert-Contains $output ([regex]::Escape($heading)) "ASCII visual '$heading'"
}
Assert-Contains $output ([regex]::Escape($totalUnits.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture))) 'ASCII unit total'

$lines = $output -split "`r?`n"
$fenceStart = [Array]::IndexOf($lines, '```text') + 1
$fenceEnd = [Array]::IndexOf($lines, '```', $fenceStart)
if ($fenceStart -le 0 -or $fenceEnd -lt $fenceStart) {
  Add-Failure 'ASCII output does not contain a complete text fence'
}
else {
  foreach ($line in $lines[$fenceStart..($fenceEnd - 1)]) {
    if ($line.Length -gt 0 -and $line.Length -ne 78) {
      Add-Failure "ASCII line width is $($line.Length), expected 78: $line"
    }
  }
}

$builderPath = Join-Path $repoRoot 'templates/build-ascii-dashboard.ps1'
$temporaryOutput = Join-Path ([System.IO.Path]::GetTempPath()) 'sales-dashboard-ascii-v2-audit.md'
try {
  & $builderPath -DataPath $dataPath -OutputPath $temporaryOutput
  if ((Get-Content $temporaryOutput -Raw) -ne $output) {
    Add-Failure 'Committed ASCII output does not match a fresh CSV-driven build'
  }
}
finally {
  Remove-Item $temporaryOutput -Force -ErrorAction SilentlyContinue
}

$malformedDataPath = Join-Path ([System.IO.Path]::GetTempPath()) 'sales-dashboard-missing-cost.csv'
try {
  [System.IO.File]::WriteAllText(
    $malformedDataPath,
    "date,region,product,revenue,units`n2024-01-01,North,Widget A,12500,250`n",
    [System.Text.UTF8Encoding]::new($false)
  )
  try {
    & $builderPath -DataPath $malformedDataPath -OutputPath $temporaryOutput
    Add-Failure 'ASCII builder accepted data without the cost column'
  }
  catch {
    Assert-Contains $_.Exception.Message 'CSV missing required columns: cost' 'ASCII builder schema guard'
  }
}
finally {
  Remove-Item $malformedDataPath, $temporaryOutput -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
  throw "ASCII example verification failed with $($failures.Count) finding(s)."
}

Write-Host 'PASS: the retained ASCII example matches its source data and delivery contract.' -ForegroundColor Green
