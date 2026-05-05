# Complex ASCII Dashboard Builder - 5 visuals, side-by-side panels
# Width = 78 chars, programmatic construction with validation

$w = 78

function Row($c) { "| " + $c.PadRight(74) + " |" }
function Bdr($ch) { "+" + ($ch * 76) + "+" }
function DualRow([string]$l, [string]$r) { "| " + $l.PadRight(34) + " |  | " + $r.PadRight(34) + " |" }
function DualBdr($ch) { "+" + ($ch * 36) + "+  +" + ($ch * 36) + "+" }

$o = @()

# === TITLE ===
$o += Bdr("=")
$o += Row("  Q3 Reallocation: Move `$50K to North A for +`$18K Profit")
$o += Bdr("=")
$o += ""

# === VISUAL 1: KPI STRIP ===
$o += Bdr("-")
$o += Row("  REVENUE        |  MARGIN         |  UNITS")
$o += Row("  `$246.4K        |  `$73.9K (30%)   |  5,448")
$o += Row("  Jan-Jun total  |  Gross margin   |  6-mo volume")
$o += Bdr("-")
$o += ""

# === VISUAL 2: REVENUE TREND ===
$o += Bdr("-")
$o += Row("  REVENUE TREND (JAN-JUN 2024)")
$o += Bdr("-")
$o += Row("")

$mx = 44800
$ba = 30
$months = @(
    ,@("Jan", 36800)
    ,@("Feb", 39000)
    ,@("Mar", 42300)
    ,@("Apr", 40600)
    ,@("May", 44800)
    ,@("Jun", 42900)
)

foreach ($m in $months) {
    $lbl = $m[0].PadRight(3)
    $v = $m[1]
    $bl = [math]::Round(($v / $mx) * $ba)
    $bar = ("#" * $bl) + (" " * ($ba - $bl))
    $vl = "`$" + ("{0:N1}K" -f ($v / 1000))
    $o += Row("$lbl | $bar | $vl")
}

$o += Row("")
$o += Row("Trend: _/\__/\  Peak: May `$44.8K  Avg growth: +3.3% MoM")
$o += Bdr("-")
$o += ""

# === VISUALS 3+4: SIDE-BY-SIDE (Profit Ranking + Margin %) ===
$o += DualBdr("-")
$o += (DualRow "  SEGMENT PROFIT RANKING" "  MARGIN % BY SEGMENT")
$o += DualBdr("-")
$o += (DualRow "" "")

$leftItems = [System.Collections.ArrayList]@()
[void]$leftItems.Add(@("N.WdgA", 24990, "`$25.0K"))
[void]$leftItems.Add(@("S.WdgA", 19650, "`$19.7K"))
[void]$leftItems.Add(@("N.WdgB", 16740, "`$16.7K"))
[void]$leftItems.Add(@("S.WdgB", 12540, "`$12.5K"))

$rightItems = [System.Collections.ArrayList]@()
[void]$rightItems.Add(@("N.WdgA", 30, "30.0%"))
[void]$rightItems.Add(@("N.WdgB", 30, "30.0%"))
[void]$rightItems.Add(@("S.WdgA", 30, "30.0%"))
[void]$rightItems.Add(@("S.WdgB", 30, "30.0%"))

$lmx = 24990; $lba = 10
$rmx = 30; $rba = 10

for ($i = 0; $i -lt 4; $i++) {
    $li = $leftItems[$i]
    $ri = $rightItems[$i]
    $ll = $li[0].PadRight(6)
    $rl = $ri[0].PadRight(6)
    $lb = [math]::Round(($li[1] / $lmx) * $lba)
    $rb = [math]::Round(($ri[1] / $rmx) * $rba)
    $lbar = ("#" * $lb) + (" " * ($lba - $lb))
    $rbar = ("#" * $rb) + (" " * ($rba - $rb))
    $lcell = "$ll|$lbar| $($li[2])"
    $rcell = "$rl|$rbar| $($ri[2])"
    $o += (DualRow $lcell $rcell)
}

$o += (DualRow "" "")
$o += DualBdr("-")
$o += ""

# === VISUAL 5: REVENUE CONCENTRATION ===
$o += Bdr("-")
$o += Row("  REVENUE CONCENTRATION (SHARE OF TOTAL)")
$o += Bdr("-")
$o += Row("")

$cmx = 33.8
$cba = 40
$segments = @(
    ,@("N.WdgA", 33.8)
    ,@("S.WdgA", 26.6)
    ,@("N.WdgB", 22.6)
    ,@("S.WdgB", 17.0)
)

foreach ($s in $segments) {
    $lbl = $s[0].PadRight(6)
    $v = $s[1]
    $bl = [math]::Round(($v / $cmx) * $cba)
    $bar = ("#" * $bl) + (" " * ($cba - $bl))
    $pct = ("{0:N1}%" -f $v).PadLeft(6)
    $o += Row("$lbl | $bar | $pct")
}

$o += Row("")
$o += Bdr("-")
$o += ""

# === FOOTER ===
$o += Bdr("=")
$o += Row("APPROVE: Shift `$50K to North Widget A (+`$18K incremental profit).")
$o += Bdr("=")

# === VALIDATION ===
Write-Host "Validating ASCII alignment..." -ForegroundColor Cyan
$fails = $o | Where-Object { $_.Length -gt 0 -and $_.Length -ne 78 }

if ($fails) {
    Write-Host "FAILURES: $($fails.Count)" -ForegroundColor Red
    $fails | ForEach-Object { Write-Host "$($_.Length): $_" -ForegroundColor Red }
    exit 1
} else {
    Write-Host "ALL LINES OK (78 chars) - Total: $($o.Count) lines" -ForegroundColor Green
}

# === WRITE ===
$header = "# Sales Dashboard - Complex ASCII Test`n`n``````text"
$footer = "``````"
$markdown = $header + "`n" + ($o -join "`n") + "`n" + $footer
$markdown | Set-Content "c:\Development\Alex_ACT_Visual_Storytelling\tests\sales-dashboard-ascii-output.md" -Encoding utf8
Write-Host "Written to tests/sales-dashboard-ascii-output.md" -ForegroundColor Green
