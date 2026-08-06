[CmdletBinding()]
param(
    [string]$DataPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'datasets/sales-sample.csv'),
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'tests/sales-dashboard-ascii-output.md')
)

$ErrorActionPreference = 'Stop'
$culture = [System.Globalization.CultureInfo]::InvariantCulture
$rows = Import-Csv $DataPath

if ($rows.Count -eq 0) {
    throw "No rows found in $DataPath"
}

$requiredColumns = 'date', 'region', 'product', 'revenue', 'units', 'cost'
$actualColumns = @($rows[0].PSObject.Properties.Name)
$missingColumns = $requiredColumns | Where-Object { $_ -notin $actualColumns }
if ($missingColumns) {
    throw "CSV missing required columns: $($missingColumns -join ', ')"
}

function New-Row([string]$Content) {
    if ($Content.Length -gt 74) {
        throw "ASCII row exceeds 74 content characters: $Content"
    }
    return '| ' + $Content.PadRight(74) + ' |'
}

function New-Border([string]$Character) {
    return '+' + ($Character * 76) + '+'
}

function Format-CurrencyK([double]$Value) {
    return '$' + ($Value / 1000).ToString('N1', $culture) + 'K'
}

function Add-BarRows(
    [System.Collections.Generic.List[string]]$Output,
    [object[]]$Items,
    [int]$BarWidth
) {
    $maximum = [double](($Items | Measure-Object Value -Maximum).Maximum)
    foreach ($item in $Items) {
        $barLength = [math]::Round(([double]$item.Value / $maximum) * $BarWidth)
        $bar = ('#' * $barLength) + ('.' * ($BarWidth - $barLength))
        $share = ([double]$item.Value / $totalRevenue) * 100
        $label = ([string]$item.Label).PadRight(10)
        $value = Format-CurrencyK $item.Value
        $Output.Add((New-Row "$label | $bar | $value | $($share.ToString('N1', $culture))%"))
    }
}

$totalRevenue = [int](($rows | Measure-Object revenue -Sum).Sum)
$totalCost = [int](($rows | Measure-Object cost -Sum).Sum)
$totalMargin = $totalRevenue - $totalCost
$totalUnits = [int](($rows | Measure-Object units -Sum).Sum)
$marginRate = ($totalMargin / $totalRevenue) * 100

$monthly = $rows | Group-Object date | Sort-Object { [datetime]$_.Name } | ForEach-Object {
    [pscustomobject]@{
        Label = ([datetime]$_.Name).ToString('MMM', $culture)
        Value = [int](($_.Group | Measure-Object revenue -Sum).Sum)
    }
}

$regions = $rows | Group-Object region | ForEach-Object {
    [pscustomobject]@{
        Label = $_.Name
        Value = [int](($_.Group | Measure-Object revenue -Sum).Sum)
    }
} | Sort-Object Value -Descending

$products = $rows | Group-Object product | ForEach-Object {
    [pscustomobject]@{
        Label = $_.Name
        Value = [int](($_.Group | Measure-Object revenue -Sum).Sum)
    }
} | Sort-Object Value -Descending

$output = [System.Collections.Generic.List[string]]::new()
$output.Add((New-Border '='))
$output.Add((New-Row 'Sales evidence: leaders are clear; budget impact needs spend data'))
$output.Add((New-Border '='))
$output.Add('')
$output.Add((New-Row "Revenue $(Format-CurrencyK $totalRevenue) | Margin $(Format-CurrencyK $totalMargin) ($($marginRate.ToString('N1', $culture))%) | Units $($totalUnits.ToString('N0', $culture))"))
$output.Add('')

$output.Add((New-Border '-'))
$output.Add((New-Row 'Monthly Revenue Trend'))
$output.Add((New-Border '-'))
Add-BarRows $output $monthly 30
$output.Add((New-Border '-'))
$output.Add('')

$output.Add((New-Border '-'))
$output.Add((New-Row 'Revenue by Region'))
$output.Add((New-Border '-'))
Add-BarRows $output $regions 30
$output.Add((New-Border '-'))
$output.Add('')

$output.Add((New-Border '-'))
$output.Add((New-Row 'Revenue by Product'))
$output.Add((New-Border '-'))
Add-BarRows $output $products 30
$output.Add((New-Border '-'))
$output.Add('')

$output.Add((New-Border '='))
$output.Add((New-Row 'Decision boundary: add campaign-spend data before reallocating budget'))
$output.Add((New-Border '='))

$invalidLines = $output | Where-Object { $_.Length -gt 0 -and $_.Length -ne 78 }
if ($invalidLines) {
    throw "ASCII alignment failed: $($invalidLines -join '; ')"
}

$markdown = "# Sales Dashboard - ASCII`n`n``````text`n" + ($output -join "`n") + "`n```````n"
$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    [System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
}
[System.IO.File]::WriteAllText(
    $OutputPath,
    $markdown,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "PASS: wrote CSV-driven ASCII dashboard to $OutputPath" -ForegroundColor Green
