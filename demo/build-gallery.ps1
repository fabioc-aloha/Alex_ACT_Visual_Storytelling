# Builds the ASCII chart gallery in Markdown and standalone HTML from one source
# of truth, mirroring the seven communication goals in Illustrator's
# chart-vocabulary skill. Real figures come from datasets/sales-sample.csv;
# entries marked illustrative use shaped data because the sample has no such
# structure.

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$outRoot = $PSScriptRoot
$data = Import-Csv (Join-Path $repoRoot 'datasets/sales-sample.csv')

$MAXW = 78

function Bar([double]$value, [double]$max, [int]$width) {
    $filled = [math]::Round($value / $max * $width)
    if ($filled -lt 0) { $filled = 0 }
    if ($filled -gt $width) { $filled = $width }
    ('#' * $filled).PadRight($width, '.')
}
function Money([double]$v) { '$' + $v.ToString('N0') }

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
$totalRev = ($data | Measure-Object revenue -Sum).Sum
$avgMonth = ($byMonth | Measure-Object Revenue -Average).Average
$maxMonth = ($byMonth | Measure-Object Revenue -Maximum).Maximum

$entries = [System.Collections.Generic.List[object]]::new()
function Add-Entry($goal, $form, $best, $avoid, $source, $ascii) {
    $lower = { param($s) if ($s.Length -gt 0) { $s.Substring(0, 1).ToLower() + $s.Substring(1) } else { $s } }
    $entries.Add([pscustomobject]@{
            Goal = $goal; Form = $form; Best = (& $lower $best); Avoid = (& $lower $avoid); Source = $source; Ascii = $ascii
        })
}

# --- Comparison -------------------------------------------------------------
$maxProd = ($byProduct | Measure-Object Revenue -Maximum).Maximum
Add-Entry 'Comparison' 'Horizontal bar' 'Ranking items; long labels' 'More than 15 rows' 'real' (
    ($byProduct | ForEach-Object { $_.Name.PadRight(10) + (Bar $_.Revenue $maxProd 34) + ' ' + (Money $_.Revenue).PadLeft(9) }) -join "`n"
)

$dotMin = ($byMonth | Measure-Object Revenue -Minimum).Minimum
Add-Entry 'Comparison' 'Dot plot' 'Precise values in a tight range' 'Audience expects bars' 'real' (
    ($byMonth | ForEach-Object {
        $pos = [math]::Round(($_.Revenue - $dotMin) / ($maxMonth - $dotMin) * 32)
        $_.Label.PadRight(5) + ('-' * $pos) + 'o' + ('-' * (32 - $pos)) + ' ' + (Money $_.Revenue).PadLeft(9)
    }) -join "`n"
)

Add-Entry 'Comparison' 'Bullet chart' 'Actual against a target' 'No agreed benchmark' 'real' (
    ($byRegion | ForEach-Object {
        $target = 130000
        $pct = $_.Revenue / $target * 100
        $mark = [math]::Min(33, [math]::Round($_.Revenue / 160000 * 34))
        $track = ('#' * $mark).PadRight(34, '.')
        $track = $track.Substring(0, 27) + '|' + $track.Substring(28)
        $_.Name.PadRight(7) + $track + ' ' + ($pct.ToString('N0') + '%').PadLeft(5)
    }) -join "`n"
)

Add-Entry 'Comparison' 'Grouped bar' 'two or three series per category' 'more than three series' 'real' (
    ($byRegion | ForEach-Object {
        $reg = $_.Name
        $rows = $byProduct | ForEach-Object {
            $prod = $_.Name
            $v = ($data | Where-Object { $_.region -eq $reg -and $_.product -eq $prod } | Measure-Object revenue -Sum).Sum
            '  ' + $prod.PadRight(9) + (Bar $v $maxProd 30) + ' ' + (Money $v).PadLeft(9)
        }
        $reg + "`n" + ($rows -join "`n")
    }) -join "`n"
)

# --- Change Over Time -------------------------------------------------------
$spark = ''
for ($i = 1; $i -lt $byMonth.Count; $i++) {
    $d = $byMonth[$i].Revenue - $byMonth[$i - 1].Revenue
    $spark += if ($d -gt 0) { '/' } elseif ($d -lt 0) { '\' } else { '_' }
}
Add-Entry 'Change Over Time' 'Sparkline' 'Inline trend beside a KPI' 'Exact values matter more than shape' 'real' (
    'Revenue  ' + $spark + '   ' + (Money $byMonth[0].Revenue) + ' -> ' + (Money $byMonth[-1].Revenue) + "`n" +
    'Months   ' + (($byMonth | ForEach-Object { $_.Label.Substring(0, 1) }) -join '')
)

$rows = @()
for ($level = 5; $level -ge 1; $level--) {
    $line = '     '
    foreach ($m in $byMonth) {
        $h = [math]::Round($m.Revenue / $maxMonth * 5)
        $line += if ($h -ge $level) { ' ##   ' } else { '      ' }
    }
    $rows += $line.TrimEnd()
}
$rows += '     ' + (($byMonth | ForEach-Object { ' ' + $_.Label.Substring(0, 2) + '   ' }) -join '')
Add-Entry 'Change Over Time' 'Column trend' 'Discrete periods; magnitude visible' 'Many periods (use sparkline)' 'real' ($rows -join "`n")

$step = @()
foreach ($m in $byMonth) {
    $h = [math]::Round($m.Revenue / $maxMonth * 30)
    $step += $m.Label.PadRight(5) + ('_' * $h) + '|' + ' ' + (Money $m.Revenue).PadLeft(9)
}
Add-Entry 'Change Over Time' 'Step line' 'Values hold then jump' 'Smooth continuous change' 'real' ($step -join "`n")

Add-Entry 'Change Over Time' 'Small multiples' 'comparing trends across categories' 'fewer than four categories' 'real' (
    ($byRegion | ForEach-Object {
        $reg = $_.Name
        $series = $byMonth | ForEach-Object {
            $lbl = $_.Label
            ($data | Where-Object { $_.region -eq $reg -and ([datetime]$_.date).ToString('MMM') -eq $lbl } | Measure-Object revenue -Sum).Sum
        }
        $sp = ''
        for ($i = 1; $i -lt $series.Count; $i++) {
            $d = $series[$i] - $series[$i - 1]
            $sp += if ($d -gt 0) { '/' } elseif ($d -lt 0) { '\' } else { '_' }
        }
        $reg.PadRight(8) + $sp + '   ' + (Money ($series | Measure-Object -Sum).Sum).PadLeft(9)
    }) -join "`n"
)

# --- Proportion -------------------------------------------------------------
$seg = ''
foreach ($r in $byRegion) {
    $w = [math]::Round($r.Revenue / $totalRev * 60)
    $seg += if ($r -eq $byRegion[0]) { '#' * $w } else { '=' * $w }
}
Add-Entry 'Proportion' 'Stacked 100% bar' 'Two to four parts of a whole' 'Many small slices' 'real' (
    $seg.PadRight(60).Substring(0, 60) + "`n" +
    ($byRegion | ForEach-Object { $_.Name + ' ' + ($_.Revenue / $totalRev * 100).ToString('N1') + '%' }) -join '   '
)

Add-Entry 'Proportion' 'Percentage rows' 'Ranked shares needing exact values' 'Shares change over time' 'real' (
    ($byProduct | ForEach-Object {
        $pct = $_.Revenue / $totalRev * 100
        $_.Name.PadRight(10) + (Bar $pct 100 40) + ' ' + ($pct.ToString('N1') + '%').PadLeft(6)
    }) -join "`n"
)

$northCells = [math]::Round($byRegion[0].Revenue / $totalRev * 100)
$waffle = @()
for ($row = 0; $row -lt 5; $row++) {
    $line = ''
    for ($col = 0; $col -lt 20; $col++) {
        $idx = $row * 20 + $col
        $line += if ($idx -lt $northCells) { '#' } else { '.' }
    }
    $waffle += $line
}
Add-Entry 'Proportion' 'Waffle grid' 'Part of a whole as countable units' 'Precise decimals matter' 'real' (
    ($waffle -join "`n") + "`n" + ('# ' + $byRegion[0].Name + ' ' + $northCells + '%   . ' + $byRegion[1].Name + ' ' + (100 - $northCells) + '%')
)

# --- Distribution -----------------------------------------------------------
$rev = $data | ForEach-Object { [double]$_.revenue } | Sort-Object
$min = $rev[0]; $max = $rev[-1]
$buckets = @()
for ($i = 0; $i -lt 5; $i++) {
    $lo = $min + (($max - $min) / 5 * $i); $hi = $lo + (($max - $min) / 5)
    $c = @($rev | Where-Object { $_ -ge $lo -and ($_ -lt $hi -or ($i -eq 4 -and $_ -le $hi)) }).Count
    $buckets += [pscustomobject]@{ Lo = $lo; Count = $c }
}
$maxC = ($buckets | Measure-Object Count -Maximum).Maximum
Add-Entry 'Distribution' 'Histogram' 'Shape of a single variable' 'Fewer than 20 observations' 'real' (
    ($buckets | ForEach-Object { (Money $_.Lo).PadLeft(8) + '  ' + (Bar $_.Count $maxC 30) + ' n=' + $_.Count }) -join "`n"
)

$q1 = $rev[[math]::Floor($rev.Count * 0.25)]
$med = $rev[[math]::Floor($rev.Count * 0.5)]
$q3 = $rev[[math]::Floor($rev.Count * 0.75)]
function Pos([double]$v) { [math]::Round(($v - $min) / ($max - $min) * 44) }
$line = ''
for ($i = 0; $i -le 44; $i++) {
    $line += if ($i -eq (Pos $min) -or $i -eq (Pos $max)) { '|' }
    elseif ($i -eq (Pos $med)) { '+' }
    elseif ($i -eq (Pos $q1) -or $i -eq (Pos $q3)) { '[' }
    elseif ($i -gt (Pos $q1) -and $i -lt (Pos $q3)) { '=' }
    else { '-' }
}
Add-Entry 'Distribution' 'Box plot' 'Spread and outliers at a glance' 'Audience unfamiliar with quartiles' 'real' (
    $line + "`n" + ('min ' + (Money $min) + '   Q1 ' + (Money $q1) + '   med ' + (Money $med) + '   Q3 ' + (Money $q3) + '   max ' + (Money $max))
)

# --- Relationship -----------------------------------------------------------
$grid = @()
$uMin = ($data | Measure-Object units -Minimum).Minimum
$uMax = ($data | Measure-Object units -Maximum).Maximum
for ($row = 8; $row -ge 1; $row--) {
    $line = ''
    for ($col = 0; $col -lt 44; $col++) {
        $hit = $data | Where-Object {
            [math]::Round(([double]$_.units - $uMin) / ($uMax - $uMin) * 43) -eq $col -and
            [math]::Ceiling(([double]$_.revenue - $min) / ($max - $min) * 8) -eq $row
        }
        $line += if ($hit) { '*' } else { ' ' }
    }
    $grid += '|' + $line
}
$grid += '+' + ('-' * 44)
$grid += 'units ->                          revenue on y axis'
Add-Entry 'Relationship' 'Scatter plot' 'Correlation between two measures' 'More than a few hundred points' 'real' ($grid -join "`n")

$cells = @{}
foreach ($r in $data) {
    $k = $r.region + '|' + ([datetime]$r.date).ToString('MMM')
    if (-not $cells.ContainsKey($k)) { $cells[$k] = 0 }
    $cells[$k] += [double]$r.revenue
}
$cMax = ($cells.Values | Measure-Object -Maximum).Maximum
$cMin = ($cells.Values | Measure-Object -Minimum).Minimum
function Ramp([double]$v) {
    $t = ($v - $cMin) / ($cMax - $cMin)
    if ($t -ge 0.8) { '#####' } elseif ($t -ge 0.6) { '####.' } elseif ($t -ge 0.4) { '###..' } elseif ($t -ge 0.2) { '##...' } else { '#....' }
}
Add-Entry 'Relationship' 'Heatmap' 'Two categorical axes, one measure' 'Precise values needed' 'real' (
    ('        ' + (($byMonth | ForEach-Object { $_.Label.PadRight(6) }) -join '')) + "`n" +
    (($byRegion | ForEach-Object {
        $reg = $_.Name
        $reg.PadRight(8) + (($byMonth | ForEach-Object { (Ramp $cells[$reg + '|' + $_.Label]) + ' ' }) -join '')
    }) -join "`n")
)

# --- Flow and Process -------------------------------------------------------
$stages = @(
    [pscustomobject]@{ Name = 'Leads'; Value = 4000 }
    [pscustomobject]@{ Name = 'Qualified'; Value = 2400 }
    [pscustomobject]@{ Name = 'Proposal'; Value = 1100 }
    [pscustomobject]@{ Name = 'Won'; Value = 420 }
)
Add-Entry 'Flow and Process' 'Funnel' 'Stage-by-stage drop-off' 'Stages are not sequential' 'illustrative' (
    ($stages | ForEach-Object {
        $w = [math]::Round($_.Value / $stages[0].Value * 40)
        $pad = [math]::Floor((40 - $w) / 2)
        (' ' * $pad) + ('#' * $w) + '  ' + $_.Name.PadRight(10) + $_.Value.ToString('N0').PadLeft(6)
    }) -join "`n"
)

Add-Entry 'Flow and Process' 'Stage pipeline' 'Steps with hand-offs' 'Branching or looping flows' 'illustrative' (
    '[ Ingest ] -> [ Clean ] -> [ Select ] -> [ Render ] -> [ Verify ]' + "`n" +
    '    ok          ok           ok            ok           WARN'
)

# --- Deviation --------------------------------------------------------------
Add-Entry 'Deviation' 'Diverging bar' 'Above and below a reference' 'No meaningful midpoint' 'real' (
    ($byMonth | ForEach-Object {
        $d = $_.Revenue - $avgMonth
        $w = [math]::Round([math]::Abs($d) / $maxMonth * 24)
        if ($d -ge 0) { $_.Label.PadRight(5) + (' ' * 24) + '|' + ('#' * $w).PadRight(24) + ' +' + (Money ([math]::Abs($d))) }
        else { $_.Label.PadRight(5) + ('#' * $w).PadLeft(24) + '|' + (' ' * 24) + ' -' + (Money ([math]::Abs($d))) }
    }) -join "`n"
)

Add-Entry 'Deviation' 'Variance column' 'Actual against plan per period' 'No plan exists' 'real' (
    ($byMonth | ForEach-Object {
        $d = $_.Revenue - $avgMonth
        $flag = if ($d -ge 0) { '[OK]  ' } else { '[UNDER]' }
        $_.Label.PadRight(5) + (Money $_.Revenue).PadLeft(9) + '  vs avg ' + (Money $avgMonth).PadLeft(9) + '  ' + (('{0:+#,0;-#,0;0}' -f $d)).PadLeft(9) + '  ' + $flag
    }) -join "`n"
)

# --- render markdown --------------------------------------------------------
$goals = 'Comparison', 'Change Over Time', 'Proportion', 'Distribution', 'Relationship', 'Flow and Process', 'Deviation'
$md = [System.Collections.Generic.List[string]]::new()
$md.Add('# ASCII Chart Gallery')
$md.Add('')
$md.Add('An ASCII counterpart to a chart gallery. Every form below is organized by')
$md.Add('the same seven communication goals used by Illustrator''s `chart-vocabulary`')
$md.Add('skill, so the two compose: pick the goal there, render it here when the')
$md.Add('target is a terminal, a log file, a pull request, or a context window.')
$md.Add('')
$md.Add('Figures marked **real** are computed from [`datasets/sales-sample.csv`](../datasets/sales-sample.csv).')
$md.Add('Figures marked **illustrative** use shaped data because the sample has no')
$md.Add('funnel or process structure; the form is the point, not the numbers.')
$md.Add('')
$md.Add('Regenerate with `pwsh -NoProfile -File demo/build-gallery.ps1`.')
$md.Add('')
$md.Add('| Goal | Forms |')
$md.Add('| --- | --- |')
foreach ($g in $goals) {
    $forms = ($entries | Where-Object Goal -eq $g | ForEach-Object { $_.Form }) -join ', '
    $md.Add("| [$g](#" + ($g.ToLower() -replace ' ', '-') + ") | $forms |")
}
$md.Add('')
foreach ($g in $goals) {
    $md.Add("## $g")
    $md.Add('')
    foreach ($e in ($entries | Where-Object Goal -eq $g)) {
        $md.Add("### $($e.Form)")
        $md.Add('')
        $md.Add("Best when $($e.Best). Avoid when $($e.Avoid). Data: **$($e.Source)**.")
        $md.Add('')
        $md.Add('```text')
        foreach ($l in ($e.Ascii -split "`n")) { $md.Add($l) }
        $md.Add('```')
        $md.Add('')
    }
}
Set-Content -Path (Join-Path $outRoot 'GALLERY.md') -Value ($md -join "`n") -Encoding utf8

# --- render html ------------------------------------------------------------
function HtmlEscape([string]$s) { $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;') }
$html = [System.Collections.Generic.List[string]]::new()
$html.Add('<!DOCTYPE html>')
$html.Add('<html lang="en"><head><meta charset="utf-8">')
$html.Add('<meta name="viewport" content="width=device-width, initial-scale=1">')
$html.Add('<title>ASCII Chart Gallery</title>')
$html.Add('<style>')
$html.Add(':root{--bg:#0f172a;--card:#1e293b;--ink:#e2e8f0;--mute:#94a3b8;--accent:#10b981;--line:#334155}')
$html.Add('*{box-sizing:border-box}')
$html.Add('body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.6 -apple-system,Segoe UI,Roboto,sans-serif}')
$html.Add('header{padding:2.5rem 1.5rem 1.5rem;border-bottom:1px solid var(--line)}')
$html.Add('h1{margin:0 0 .5rem;font-size:1.9rem;color:#fff}')
$html.Add('header p{margin:.35rem 0;color:var(--mute);max-width:62ch}')
$html.Add('main{padding:1.5rem;max-width:1000px;margin:0 auto}')
$html.Add('nav{display:flex;flex-wrap:wrap;gap:.5rem;margin:1.25rem 0 2rem}')
$html.Add('nav a{padding:.35rem .8rem;border:1px solid var(--line);border-radius:999px;color:var(--ink);text-decoration:none;font-size:.85rem}')
$html.Add('nav a:hover{border-color:var(--accent);color:var(--accent)}')
$html.Add('h2{margin:2.5rem 0 1rem;font-size:1.3rem;color:var(--accent);border-bottom:1px solid var(--line);padding-bottom:.4rem}')
$html.Add('.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:1rem 1.25rem;margin:0 0 1.25rem}')
$html.Add('.card h3{margin:0 0 .35rem;font-size:1.05rem;color:#fff}')
$html.Add('.meta{margin:0 0 .75rem;color:var(--mute);font-size:.85rem}')
$html.Add('.tag{display:inline-block;padding:.05rem .5rem;border-radius:999px;font-size:.72rem;text-transform:uppercase;letter-spacing:.04em;margin-left:.4rem}')
$html.Add('.real{background:rgba(16,185,129,.15);color:var(--accent)}')
$html.Add('.illustrative{background:rgba(148,163,184,.15);color:var(--mute)}')
$html.Add('pre{margin:0;overflow-x:auto;background:#0b1220;border:1px solid var(--line);border-radius:8px;padding:.9rem;color:var(--ink);font:13px/1.35 ui-monospace,SFMono-Regular,Consolas,monospace}')
$html.Add('footer{padding:2rem 1.5rem;color:var(--mute);font-size:.85rem;border-top:1px solid var(--line);margin-top:2rem}')
$html.Add('</style></head><body>')
$html.Add('<header><h1>ASCII Chart Gallery</h1>')
$html.Add('<p>An ASCII counterpart to a chart gallery, organized by the same seven communication goals as Illustrator&#39;s <code>chart-vocabulary</code> skill.</p>')
$html.Add('<p>Render these when the target is a terminal, a log file, a pull request, or a context window, where no rendering engine is available.</p>')
$html.Add('</header><main>')
$html.Add('<nav>')
foreach ($g in $goals) { $html.Add('<a href="#' + ($g.ToLower() -replace ' ', '-') + '">' + $g + '</a>') }
$html.Add('</nav>')
foreach ($g in $goals) {
    $html.Add('<h2 id="' + ($g.ToLower() -replace ' ', '-') + '">' + $g + '</h2>')
    foreach ($e in ($entries | Where-Object Goal -eq $g)) {
        $html.Add('<div class="card">')
        $html.Add('<h3>' + (HtmlEscape $e.Form) + '<span class="tag ' + $e.Source + '">' + $e.Source + '</span></h3>')
        $html.Add('<p class="meta">Best when ' + (HtmlEscape $e.Best) + '. Avoid when ' + (HtmlEscape $e.Avoid) + '.</p>')
        $html.Add('<pre>' + (HtmlEscape $e.Ascii) + '</pre>')
        $html.Add('</div>')
    }
}
$html.Add('</main>')
$html.Add('<footer>Generated by <code>demo/build-gallery.ps1</code> from <code>datasets/sales-sample.csv</code>. Every figure is plain ASCII, no wider than 78 characters.</footer>')
$html.Add('</body></html>')
Set-Content -Path (Join-Path $outRoot 'gallery.html') -Value ($html -join "`n") -Encoding utf8

# --- validate ---------------------------------------------------------------
$failures = @()
foreach ($e in $entries) {
    foreach ($l in ($e.Ascii -split "`n")) {
        if ($l.Length -gt $MAXW) { $failures += "$($e.Form): line $($l.Length) chars exceeds $MAXW" }
        if ($l -match '[^\x20-\x7E]') { $failures += "$($e.Form): non-ASCII character" }
    }
}
Write-Host ("Entries: {0} across {1} goals" -f $entries.Count, $goals.Count)
foreach ($g in $goals) {
    Write-Host ("  {0,-18} {1}" -f $g, (($entries | Where-Object Goal -eq $g).Count))
}
if ($failures) {
    Write-Host ''
    Write-Host 'GALLERY FAILURES:' -ForegroundColor Red
    $failures | Select-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    exit 1
}
Write-Host ''
Write-Host "GALLERY.md and gallery.html written. All figures ASCII-only and <= $MAXW chars." -ForegroundColor Green
