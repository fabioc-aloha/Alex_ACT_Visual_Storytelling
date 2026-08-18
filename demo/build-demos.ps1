# Regenerates every ASCII demo from datasets/sales-sample.csv, then asserts the
# 78-character geometry the delivery-ascii-dashboard skill requires.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$outRoot = $PSScriptRoot
$data = Import-Csv (Join-Path $repoRoot 'datasets/sales-sample.csv')

$W = 78          # total line width
$INNER = 74      # full-width content between "| " and " |"
$HALF = 34       # side-by-side content between "| " and " |"

function FullBorder { '+' + ('-' * ($W - 2)) + '+' }
function FullRule { '+' + ('=' * ($W - 2)) + '+' }
function FullLine([string]$text) {
    if ($text.Length -gt $INNER) { throw "Content exceeds $INNER chars: $text" }
    '| ' + $text.PadRight($INNER) + ' |'
}
function Centered([string]$text) {
    $pad = [math]::Max(0, [int](($INNER - $text.Length) / 2))
    FullLine ((' ' * $pad) + $text)
}
function PairBorder { '+' + ('-' * ($HALF + 2)) + '+' + '  ' + '+' + ('-' * ($HALF + 2)) + '+' }
function PairLine([string]$left, [string]$right) {
    '| ' + $left.PadRight($HALF) + ' |' + '  ' + '| ' + $right.PadRight($HALF) + ' |'
}
function Money([double]$v) { '$' + $v.ToString('N0') }

# --- aggregates -------------------------------------------------------------
$totalRev = ($data | Measure-Object revenue -Sum).Sum
$totalUnits = ($data | Measure-Object units -Sum).Sum
$totalCost = ($data | Measure-Object cost -Sum).Sum
$margin = $totalRev - $totalCost
$marginPct = $margin / $totalRev * 100
$avgPrice = $totalRev / $totalUnits

$byRegion = $data | Group-Object region | ForEach-Object {
    [pscustomobject]@{ Name = $_.Name; Revenue = ($_.Group | Measure-Object revenue -Sum).Sum }
} | Sort-Object Revenue -Descending

$byProduct = $data | Group-Object product | ForEach-Object {
    [pscustomobject]@{ Name = $_.Name; Revenue = ($_.Group | Measure-Object revenue -Sum).Sum }
} | Sort-Object Revenue -Descending

$byMonth = $data | Group-Object date | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{
        Label   = ([datetime]$_.Name).ToString('MMM')
        Revenue = ($_.Group | Measure-Object revenue -Sum).Sum
        Units   = ($_.Group | Measure-Object units -Sum).Sum
    }
}

$peak = $byMonth | Sort-Object Revenue -Descending | Select-Object -First 1
$first = $byMonth[0]
$last = $byMonth[-1]
$growth = ($last.Revenue - $first.Revenue) / $first.Revenue * 100
$momPct = ($last.Revenue - $byMonth[-2].Revenue) / $byMonth[-2].Revenue * 100

function Bar([double]$value, [double]$max, [int]$width) {
    $filled = [math]::Round($value / $max * $width)
    ('#' * $filled).PadRight($width, '.')
}

$files = @{}

# --- 01 KPI strip -----------------------------------------------------------
$card = '+' + ('-' * 16) + '+'
$kpiBorder = ($card, $card, $card, $card) -join '  '
function KpiRow([string[]]$cells) {
    ($cells | ForEach-Object { '| ' + $_.PadRight(14) + ' |' }) -join '  '
}
$files['01-kpi-strip.txt'] = @(
    'KPI STRIP  --  H1 2024 sales'
    ''
    $kpiBorder
    KpiRow @('    REVENUE   ', '     UNITS    ', '    MARGIN    ', '  AVG PRICE   ')
    KpiRow @(('  ' + (Money $totalRev)).PadRight(14), ('    ' + $totalUnits.ToString('N0')).PadRight(14), ('   ' + $marginPct.ToString('N1') + '%').PadRight(14), ('    ' + (Money $avgPrice)).PadRight(14))
    KpiRow @('   6 months   ', '   6 months   ', ('  ' + (Money $margin)).PadRight(14), '   per unit   ')
    $kpiBorder
) -join "`n"

# --- 02 horizontal bars -----------------------------------------------------
$maxProd = ($byProduct | Measure-Object Revenue -Maximum).Maximum
$lines = @((FullBorder), (Centered 'REVENUE BY PRODUCT'), (FullRule))
foreach ($p in $byProduct) {
    $pct = $p.Revenue / $totalRev * 100
    $lines += FullLine ($p.Name.PadRight(10) + ' ' + (Bar $p.Revenue $maxProd 40) + ' ' + (Money $p.Revenue).PadLeft(10) + ' ' + ($pct.ToString('N1') + '%').PadLeft(6))
}
$lines += FullRule
$maxReg = ($byRegion | Measure-Object Revenue -Maximum).Maximum
$lines += Centered 'REVENUE BY REGION'
$lines += FullRule
foreach ($r in $byRegion) {
    $pct = $r.Revenue / $totalRev * 100
    $lines += FullLine ($r.Name.PadRight(10) + ' ' + (Bar $r.Revenue $maxReg 40) + ' ' + (Money $r.Revenue).PadLeft(10) + ' ' + ($pct.ToString('N1') + '%').PadLeft(6))
}
$lines += FullBorder
$files['02-horizontal-bar.txt'] = ($lines -join "`n")

# --- 03 sparkline row -------------------------------------------------------
$spark = ''
for ($i = 1; $i -lt $byMonth.Count; $i++) {
    $delta = $byMonth[$i].Revenue - $byMonth[$i - 1].Revenue
    $spark += if ($delta -gt 0) { '/' } elseif ($delta -lt 0) { '\' } else { '_' }
}
$monthLabels = ($byMonth | ForEach-Object { $_.Label.PadLeft(6) }) -join ''
$monthValues = ($byMonth | ForEach-Object { ([math]::Round($_.Revenue / 1000)).ToString() + 'k' } | ForEach-Object { $_.PadLeft(6) }) -join ''
$files['03-sparkline-row.txt'] = @(
    FullBorder
    Centered 'MONTHLY REVENUE TREND'
    FullRule
    FullLine ('Shape  ' + $spark + '   (' + $byMonth.Count + ' months, ' + $spark.Length + ' transitions)')
    FullLine ''
    FullLine ('Month ' + $monthLabels)
    FullLine ('Value ' + $monthValues)
    FullRule
    FullLine ('Peak ' + $peak.Label + ' at ' + (Money $peak.Revenue) + '   Jan-to-Jun ' + $growth.ToString('N1') + '%   MoM ' + $momPct.ToString('N1') + '%')
    FullBorder
) -join "`n"

# --- 04 two-column ----------------------------------------------------------
$files['04-two-column.txt'] = @(
    PairBorder
    PairLine '            BY REGION' '           BY PRODUCT'
    PairBorder
    (PairLine ($byRegion[0].Name.PadRight(8) + (Money $byRegion[0].Revenue).PadLeft(12)) ($byProduct[0].Name.PadRight(10) + (Money $byProduct[0].Revenue).PadLeft(10)))
    (PairLine ($byRegion[1].Name.PadRight(8) + (Money $byRegion[1].Revenue).PadLeft(12)) ($byProduct[1].Name.PadRight(10) + (Money $byProduct[1].Revenue).PadLeft(10)))
    PairLine '' ''
    (PairLine ('Split    ' + ($byRegion[0].Revenue / $totalRev * 100).ToString('N0') + '/' + ($byRegion[1].Revenue / $totalRev * 100).ToString('N0')) ('Split      ' + ($byProduct[0].Revenue / $totalRev * 100).ToString('N0') + '/' + ($byProduct[1].Revenue / $totalRev * 100).ToString('N0')))
    PairBorder
) -join "`n"

# --- 05 full dashboard ------------------------------------------------------
$lines = @(
    FullBorder
    Centered 'H1 2024 SALES DASHBOARD'
    Centered 'source: datasets/sales-sample.csv  --  24 rows'
    FullRule
    FullLine ('REVENUE ' + (Money $totalRev).PadRight(12) + 'UNITS ' + $totalUnits.ToString('N0').PadRight(10) + 'MARGIN ' + $marginPct.ToString('N1') + '%')
    FullRule
    Centered 'MONTHLY REVENUE'
    FullLine ''
)
$maxMonth = ($byMonth | Measure-Object Revenue -Maximum).Maximum
foreach ($m in $byMonth) {
    $flag = if ($m.Revenue -eq $peak.Revenue) { ' <-- peak' } else { '' }
    $lines += FullLine ($m.Label.PadRight(5) + (Bar $m.Revenue $maxMonth 40) + ' ' + (Money $m.Revenue).PadLeft(9) + $flag)
}
$lines += @(
    FullRule
    FullLine ('Trend ' + $spark + '   Jan-to-Jun ' + $growth.ToString('N1') + '%   latest MoM ' + $momPct.ToString('N1') + '%')
    FullRule
    FullLine 'ACTION  June dipped after the May peak. Confirm whether the drop is'
    FullLine '        seasonal before adjusting Q3 targets.'
    FullBorder
)
$files['05-full-dashboard.txt'] = ($lines -join "`n")

# --- 06 distribution --------------------------------------------------------
$revenues = $data | ForEach-Object { [double]$_.revenue }
$min = ($revenues | Measure-Object -Minimum).Minimum
$max = ($revenues | Measure-Object -Maximum).Maximum
$bucketCount = 5
$size = ($max - $min) / $bucketCount
$buckets = @()
for ($i = 0; $i -lt $bucketCount; $i++) {
    $lo = $min + ($size * $i)
    $hi = $lo + $size
    $count = @($revenues | Where-Object { $_ -ge $lo -and ($_ -lt $hi -or ($i -eq $bucketCount - 1 -and $_ -le $hi)) }).Count
    $buckets += [pscustomobject]@{ Label = (Money $lo) + '-' + (Money $hi); Count = $count }
}
$maxCount = ($buckets | Measure-Object Count -Maximum).Maximum
$lines = @((FullBorder), (Centered 'REVENUE DISTRIBUTION PER TRANSACTION'), (FullRule))
foreach ($b in $buckets) {
    $lines += FullLine ($b.Label.PadRight(22) + (Bar $b.Count $maxCount 38) + ' ' + ('n=' + $b.Count).PadLeft(6))
}
$lines += FullRule
$lines += FullLine ('n=' + $revenues.Count + '  min ' + (Money $min) + '  max ' + (Money $max) + '  bucket width ' + (Money $size))
$lines += FullBorder
$files['06-distribution.txt'] = ($lines -join "`n")

# --- 07 progress gauges -----------------------------------------------------
$targets = @(
    [pscustomobject]@{ Name = 'Revenue'; Actual = $totalRev; Target = 260000 }
    [pscustomobject]@{ Name = 'Units'; Actual = $totalUnits; Target = 4800 }
    [pscustomobject]@{ Name = 'Margin %'; Actual = [math]::Round($marginPct, 1); Target = 32 }
)
$lines = @((FullBorder), (Centered 'TARGET ATTAINMENT'), (FullRule))
foreach ($t in $targets) {
    $pct = $t.Actual / $t.Target * 100
    $status = if ($pct -ge 100) { '[OK]' } elseif ($pct -ge 90) { '[WARN]' } else { '[RISK]' }
    $capped = [math]::Min(100, $pct)
    $lines += FullLine ($t.Name.PadRight(10) + (Bar $capped 100 34) + ' ' + ($pct.ToString('N0') + '%').PadLeft(5) + ' ' + $status.PadLeft(7) + ' ')
}
$lines += FullRule
$lines += FullLine 'Legend  [OK] at or above target   [WARN] 90-99%   [RISK] below 90%'
$lines += FullBorder
$files['07-progress-gauges.txt'] = ($lines -join "`n")

# --- 08 heatmap -------------------------------------------------------------
$cells = @{}
foreach ($row in $data) {
    $key = $row.region + '|' + ([datetime]$row.date).ToString('MMM')
    if (-not $cells.ContainsKey($key)) { $cells[$key] = 0 }
    $cells[$key] += [double]$row.revenue
}
$cellMax = ($cells.Values | Measure-Object -Maximum).Maximum
$cellMin = ($cells.Values | Measure-Object -Minimum).Minimum
function Density([double]$v) {
    $ratio = ($v - $cellMin) / ($cellMax - $cellMin)
    if ($ratio -ge 0.80) { '#####' } elseif ($ratio -ge 0.60) { '####.' } elseif ($ratio -ge 0.40) { '###..' } elseif ($ratio -ge 0.20) { '##...' } else { '#....' }
}
$header = 'Region  ' + (($byMonth | ForEach-Object { $_.Label.PadRight(6) }) -join '')
$lines = @((FullBorder), (Centered 'REVENUE HEATMAP  --  REGION x MONTH'), (FullRule), (FullLine $header), (FullLine ''))
foreach ($r in $byRegion) {
    $row = $r.Name.PadRight(8)
    foreach ($m in $byMonth) { $row += (Density $cells[$r.Name + '|' + $m.Label]) + ' ' }
    $lines += FullLine $row
}
$lines += FullRule
$lines += FullLine ('Scale  #.... low ' + (Money $cellMin) + '   ##### high ' + (Money $cellMax))
$lines += FullBorder
$files['08-heatmap.txt'] = ($lines -join "`n")

# --- write + validate -------------------------------------------------------
foreach ($name in $files.Keys) {
    Set-Content -Path (Join-Path $outRoot $name) -Value $files[$name] -Encoding utf8 -NoNewline
}

$failures = @()
foreach ($name in ($files.Keys | Sort-Object)) {
    $lineNo = 0
    foreach ($line in ($files[$name] -split "`n")) {
        $lineNo++
        if ($line.Length -gt $W) { $failures += "$name line ${lineNo}: $($line.Length) chars (max $W)" }
        if ($line -match '^\+[-=]+\+$' -and $line.Length -ne $W) { $failures += "$name line ${lineNo}: border is $($line.Length), must be $W" }
        if ($line -match '[^\x20-\x7E]') { $failures += "$name line ${lineNo}: non-ASCII character" }
    }
    $widths = ($files[$name] -split "`n" | ForEach-Object { $_.Length } | Sort-Object -Unique -Descending | Select-Object -First 1)
    Write-Host ("{0,-26} lines {1,3}   max width {2,3}" -f $name, ($files[$name] -split "`n").Count, $widths)
}

if ($failures) {
    Write-Host ''
    Write-Host 'GEOMETRY FAILURES:' -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
Write-Host ''
Write-Host "All $($files.Count) demos pass: <= $W chars, ASCII only, borders exact." -ForegroundColor Green
