
# ASCII Dashboard Builder - Sales Data
# Width = 78 chars, with programmatic validation

$w = 78

# Helper functions
function Row($c) {
    "| " + $c.PadRight(74) + " |"
}

function Bdr($ch) {
    "+" + ($ch * 76) + "+"
}

function CenterText($text, $width) {
    $padding = [Math]::Max(0, ($width - $text.Length) / 2)
    return (" " * [int]$padding) + $text
}

# Build dashboard
$out = @()

# === TITLE ===
$out += Bdr("=")
$titleText = CenterText("Sales Dashboard - Regional Analysis", 74)
$out += Row($titleText)
$out += Bdr("=")
$out += ""

# === VISUAL 1: MONTHLY REVENUE TREND ===
$out += Row("Monthly Revenue Trend (Jan-Jun)")
$out += Bdr("-")

# Data: Jan=$36.8k, Feb=$39.0k, Mar=$42.3k, Apr=$40.6k, May=$44.8k, Jun=$42.9k
$months = @(
    @{ name = "January  "; value = 36800 }
    @{ name = "February "; value = 39000 }
    @{ name = "March    "; value = 42300 }
    @{ name = "April    "; value = 40600 }
    @{ name = "May      "; value = 44800 }
    @{ name = "June     "; value = 42900 }
)

$maxMonth = 44800
$barArea = 35

foreach ($m in $months) {
    $barLen = [Math]::Round(($m.value / $maxMonth) * $barArea)
    $bar = "#" * $barLen
    $empty = "." * ($barArea - $barLen)
    $pct = [Math]::Round(($m.value / 246400) * 100, 0)
    $content = "$($m.name) | $bar$empty | $pct%"
    $out += Row($content)
}

$out += Bdr("-")
$out += ""

# === VISUAL 2: REGIONAL COMPARISON ===
$out += Row("Revenue by Region")
$out += Bdr("-")

$regions = @(
    @{ name = "North      "; value = 139100; pct = 56.5 }
    @{ name = "South      "; value = 107300; pct = 43.5 }
)

$maxRegion = 139100
$barArea2 = 38

foreach ($r in $regions) {
    $barLen = [Math]::Round(($r.value / $maxRegion) * $barArea2)
    $bar = "#" * $barLen
    $empty = "." * ($barArea2 - $barLen)
    $content = "$($r.name) | $bar$empty | $($r.pct)%"
    $out += Row($content)
}

$out += Bdr("-")
$out += ""

# === VISUAL 3: PRODUCT SPLIT ===
$out += Row("Revenue by Product")
$out += Bdr("-")

$products = @(
    @{ name = "Widget A  "; value = 148800; pct = 60.4 }
    @{ name = "Widget B  "; value = 97600;  pct = 39.6 }
)

$maxProduct = 148800
$barArea3 = 38

foreach ($p in $products) {
    $barLen = [Math]::Round(($p.value / $maxProduct) * $barArea3)
    $bar = "#" * $barLen
    $empty = "." * ($barArea3 - $barLen)
    $content = "$($p.name) | $bar$empty | $($p.pct)%"
    $out += Row($content)
}

$out += Bdr("-")
$out += ""

# === FOOTER ===
$footerText = "Total Revenue: $246,400 | Recommendation: Shift Q3 budget to Widget A in North"
$out += Row($footerText)
$out += Bdr("=")

# === VALIDATION ===
Write-Host "Validating ASCII alignment..."
$fails = $out | Where-Object { $_.Length -gt 0 -and $_.Length -ne 78 }

if ($fails) {
    Write-Host "FAILURES DETECTED:" -ForegroundColor Red
    $fails | ForEach-Object {
        Write-Host "$($_.Length): $_" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "ALL OK - All lines are exactly 78 characters" -ForegroundColor Green
}

# === WRITE TO FILE ===
$header = "# Sales Dashboard - ASCII`n`n``````text"
$footer = "``````"
$markdown = $header + "`n" + ($out -join "`n") + "`n" + $footer

$markdown | Set-Content "c:\Development\Alex_ACT_Visual_Storytelling\tests\sales-dashboard-ascii-output.md" -Encoding utf8
Write-Host "Written to: c:\Development\Alex_ACT_Visual_Storytelling\tests\sales-dashboard-ascii-output.md" -ForegroundColor Green

# === SECONDARY VERIFICATION ===
Write-Host "`nRunning secondary verification..."
$lines = Get-Content "c:\Development\Alex_ACT_Visual_Storytelling\tests\sales-dashboard-ascii-output.md"
$inBlock = $false
$bad = @()

foreach ($l in $lines) {
    if ($l -match '^\x60\x60\x60text') { $inBlock = $true; continue }
    if ($l -match '^\x60\x60\x60$' -and $inBlock) { break }
    if ($inBlock -and $l.Length -gt 0 -and $l.Length -ne 78) { $bad += "$($l.Length): $l" }
}

if ($bad.Count -eq 0) {
    Write-Host "ALL LINES OK (78 chars)" -ForegroundColor Green
} else {
    Write-Host "VERIFICATION FAILED:" -ForegroundColor Red
    $bad | ForEach-Object { Write-Host $_ -ForegroundColor Red }
}
