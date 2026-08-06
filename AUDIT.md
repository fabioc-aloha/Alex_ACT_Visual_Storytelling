# Project Audit

**Date**: 2026-08-06 \
**Branch**: `main` at `12ea204` \
**Audience**: Visual Storytelling maintainers and release approvers \
**Scope**: Project plugins, bundle/orchestrator, test data and outputs, release
documentation, and repository health tooling \
**Release boundary**: **Blocked for promotion from this source repo, v1
re-release, or claims of verified end-to-end operation until all six Release
Gate items pass their stated completion tests. This does not assert that the
currently installed Mall bundle is nonfunctional.**

## Executive Summary

The plugin collection has clear module boundaries and its three committed
delivery examples render. However, the examples are not reliable evidence of
analytical correctness or end-to-end operation:

- Flagship outputs contain a wrong unit total and recommendations that cannot be
  derived from the dataset.
- The available builders hardcode values and validate geometry, not the source
  data or orchestration path.
- The repository no longer reproduces the Copilot-native bundle currently
  published in the local Plugin Mall clone.
- The HTML and SVG examples each fail a stated visual acceptance criterion.

No Critical security or data-loss finding was identified within the checks
performed. Three High and four Medium findings jointly block clearance under
the Release Gate below.

The worktree already contained changes to `.vscode/settings.json` and an
untracked `.vscode/markdown-light.css` before this audit. They were not modified
or assessed as project defects.

## Findings

### High 1 - The benchmark data story is materially incorrect

The source CSV contains only `date`, `region`, `product`, `revenue`, `units`,
and `cost` ([datasets/sales-sample.csv](datasets/sales-sample.csv#L1)). Direct
aggregation produced these source result versus committed claim comparisons:

- Revenue: `$246,400` versus `$246,400`.
- Gross margin: `$73,920` versus `$73,920`.
- Units: **4,928** versus **5,448**.
- Jan-to-Jun revenue growth: `16.6%` versus `16.6%` labeled "vs prior
  period."
- Strongest segment Jan-to-peak growth: the CSV yields North Widget B at
  `22.9%`; the committed brief instead names North Widget A at `20.9%`, whose
  reproducible value is `20.8%`.

The wrong unit total is repeated in the HTML brief
([tests/sales-dashboard-html.md](tests/sales-dashboard-html.md#L53)), SVG brief
([tests/sales-dashboard-svg.md](tests/sales-dashboard-svg.md#L51)), HTML output
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L274-L276)),
SVG output
([tests/sales-dashboard-svg-output.md](tests/sales-dashboard-svg-output.md#L25)),
ASCII output
([tests/sales-dashboard-ascii-output.md](tests/sales-dashboard-ascii-output.md#L10)),
and the HTML skill example
([plugins/delivery-html-dashboard/SKILL.md](plugins/delivery-html-dashboard/SKILL.md#L539)).

More seriously, the HTML brief claims "2x the margin per marketing dollar" and
an `$18K` incremental return
([tests/sales-dashboard-html.md](tests/sales-dashboard-html.md#L19-L21)), but the
CSV has no marketing-spend field. Every segment has the same 30% gross-margin
rate. The HTML output invents a `marginEfficiency` series
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L321-L324))
and presents the unsupported result as a recommendation
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L298-L301)).
The ASCII output repeats the unsupported `$50K`/`$18K` decision
([tests/sales-dashboard-ascii-output.md](tests/sales-dashboard-ascii-output.md#L51)).

**Impact**: The flagship artifacts demonstrate confident analytical
fabrication. A technically polished dashboard can drive a decision the source
data does not support.

**Required action**: Recompute all fixtures from the CSV, remove unsupported
marketing-efficiency and incremental-profit claims, and add assertions for
units, growth definitions, segment ranking, and every decision-bearing number.
The Visual Storytelling maintainer owns this action. Completion means the
evidence command in the appendix and the regenerated artifacts agree on every
metric, with no claim requiring a field absent from the CSV.

### High 2 - The test process can pass an incorrect dashboard

The complex ASCII builder hardcodes the monthly data and all headline claims
([templates/build-ascii-dashboard.ps1](templates/build-ascii-dashboard.ps1#L15-L35));
it never reads the CSV. The simpler builder also hardcodes month, region, and
product aggregates
([templates/build-ascii-dashboard-simple.ps1](templates/build-ascii-dashboard-simple.ps1#L36-L95)).
Both write to one workstation-specific absolute path
([templates/build-ascii-dashboard.ps1](templates/build-ascii-dashboard.ps1#L146),
[templates/build-ascii-dashboard-simple.ps1](templates/build-ascii-dashboard-simple.ps1#L130-L131)).

The committed verification record claims that all data matches the source
([tests/DASHBOARD_VERIFICATION.txt](tests/DASHBOARD_VERIFICATION.txt#L10-L16)),
yet the unit total and decision claims are wrong. Its reproducible check covers
only 78-character alignment. There is no executable orchestrator test, no
data-to-output assertion suite, and no CI workflow. This conflicts with the
statement that all v1 plugins are shipped and tested
([TODO.md](TODO.md#L4-L8)).

**Impact**: A regression or fabricated claim can pass every current project
gate. The committed outputs are snapshots, not evidence that the advertised
brief-to-dashboard pipeline works.

**Required action**: Add one executable harness that reads the CSV, derives the
brief aggregates, invokes or simulates each pipeline boundary, regenerates all
three outputs, and fails on semantic as well as structural mismatches. Make
output paths repository-relative. The Visual Storytelling maintainer owns this
action. Completion means a clean-clone command exits nonzero after an intentional
unit-total mutation and exits zero against the corrected fixtures.

### High 3 - The factory does not reproduce the local Mall bundle snapshot

The repository calls itself the plugin factory and defines promotion as copying
a finished plugin to the Mall
([.github/copilot-instructions.local.md](.github/copilot-instructions.local.md#L13-L48),
[PLAN.md](PLAN.md#L264-L268)). That workflow is obsolete for the current
Copilot-native layout observed in the local `fabioc-aloha/Alex_Skill_Mall`
clone at commit `81405a07bfaf317364469e37104d445b432b0db3`. The compared
`plugins/data-analytics/visual-storytelling` subtree had no local changes:

- The local Mall clone vendors all seven skills inside the bundle and ships a
  normalized manifest plus a different orchestrator.
- SHA-256 comparison found all seven source `SKILL.md` files byte-different from
  their published bundle copies.
- This repository still carries legacy `components`, `artifacts`, and
  `install_paths` metadata
  ([plugins/visual-storytelling/plugin.json](plugins/visual-storytelling/plugin.json#L27-L46)).
- The local orchestrator loads `plugins/<name>/SKILL.md`
  ([.github/agents/local/visual-storytelling.agent.md](.github/agents/local/visual-storytelling.agent.md#L56)),
  marks implemented modules as Planned, and permits unsupported `powerbi`
  delivery
  ([.github/agents/local/visual-storytelling.agent.md](.github/agents/local/visual-storytelling.agent.md#L22),
  [.github/agents/local/visual-storytelling.agent.md](.github/agents/local/visual-storytelling.agent.md#L167-L173)).

**Impact**: A maintainer cannot determine whether this repo or the Mall is the
source of truth, and following the documented promotion process will not
reproduce the current storefront payload.

**Required action**: Choose one canonical source. Prefer generating the
Copilot-native Mall bundle from this repo, with a deterministic vendoring step
and equality check. Import the published orchestrator changes or explicitly
retire the local version, then replace copy-based promotion instructions. The
Visual Storytelling and Mall maintainers jointly own the source-of-truth
decision. Completion means the documented build from a clean source checkout
produces the expected Mall subtree with no unexplained file or hash differences.

### Medium 1 - Rendered examples fail their own visual criteria

The HTML dashboard was opened at `file://` in the integrated browser. At a
desktop viewport it loaded ECharts, rendered four canvases, produced no page or
request errors, and switched themes correctly. At a 390px viewport, its content
width expanded to 576px against a 375px client width, clipping the charts and
requiring horizontal scrolling. The source grid starts with a 400px minimum
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L156));
the mobile media query changes the column count but does not set
`min-width: 0` on grid items
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L190-L192)).
This fails the brief's responsive criterion.

The SVG is valid XML, has `xmlns` and `viewBox`, contains no forbidden elements,
and uses a minimum 11px font. In the rendered image, both sentence-length risk
readouts are clipped at the right edge
([tests/sales-dashboard-svg-output.md](tests/sales-dashboard-svg-output.md#L117-L119)).
This fails the brief's readability criterion.

**Required action**: Add `min-width: 0` and responsive chart geometry to the
HTML template. Wrap, shorten, or reposition SVG prose and verify both artifacts
at desktop and mobile sizes before accepting snapshots. The Visual Storytelling
maintainer owns this action. Completion means no horizontal overflow at 390px
and no clipped SVG text at its 800px viewBox.

### Medium 2 - Project state documentation contradicts the release state

[README.md](README.md#L5-L34) and [TODO.md](TODO.md#L4-L41) describe v1.0.0 as
complete at 20,400 tokens. In contrast:

- [ACT.md](ACT.md#L28-L39) says SVG and HTML are not started.
- [PLAN.md](PLAN.md#L221-L228) marks those plugins Planned and still specifies
  Chart.js rather than ECharts.
- [PLAN.md](PLAN.md#L275-L279) says only three of five Phase 1 plugins are
  published, the pipeline is not end-to-end tested, and the collection is
  9,400 tokens.
- The maintainer contract still caps the complete pipeline at 15,000 tokens
  ([.github/copilot-instructions.local.md](.github/copilot-instructions.local.md#L124)),
  while the release declares 20,400.

**Impact**: Planning, implementation, and release documents produce different
answers about supported libraries, readiness, and constraints.

**Required action**: Designate one live status source, convert historical
documents to clearly dated records, and either revise or enforce the 15K budget.
The Visual Storytelling maintainer owns this action. Completion means README,
TODO, PLAN, ACT, and the local orchestrator report one consistent support and
budget state.

### Medium 3 - The HTML artifact executes a mutable third-party script

The committed dashboard loads `https://cdn.jsdelivr.net/npm/echarts@6/...`
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L8)).
The major-only version can change without a repository diff. The tag has no
Subresource Integrity hash or `crossorigin` attribute, and the committed output
does not include the fallback described by the skill. The page rendered during
this audit only because the CDN was reachable.

**Impact**: The artifact is not fully self-contained, is unavailable offline,
and executes a dependency whose exact bytes are not pinned by the repository.

**Required action**: Pin an exact ECharts version and integrity hash, or vendor
the runtime for true standalone delivery. Make CDN failure visible to the user
instead of leaving empty chart containers. The delivery plugin maintainer owns
this action. Completion means the artifact either renders offline or fails with
a visible message, and remote script bytes are immutable and integrity-checked.

### Medium 4 - The repository Markdown gate is not trustworthy

The custom validator matched every table row in a document into one flat array
and compared adjacent rows even when they belong to different tables
([.github/muscles/markdown-lint.cjs](.github/muscles/markdown-lint.cjs#L86-L87)).
It reported errors in 47 of 110 Markdown files, including structurally valid
root documents. It also rejects a Mermaid block when an init directive precedes
the diagram type because it treats the first `%%` line as the type
([.github/muscles/markdown-lint.cjs](.github/muscles/markdown-lint.cjs#L126)).

No independent `markdownlint` or `markdownlint-cli2` executable is installed,
so the claimed Markdown lint state could not be cross-validated locally.

**Impact**: The project cannot use its own validator as a meaningful release
gate; real errors are buried among systematic false positives.

**Required action**: Parse tables by contiguous block, skip Mermaid comments and
init directives before detecting type, and add focused tests for multiple tables
and initialized Mermaid diagrams. The inherited Edition tooling maintainer owns
this action. Completion means the two regression fixtures pass while a genuinely
malformed table and Mermaid block still fail.

### Low 1 - The inherited Edition health check is stale

`heir-doctor` reported no layout errors but warned that Edition v1.2.0 was last
synced 92 days ago. This does not invalidate the v1 plugins, but inherited tools
and documentation may lag current Edition behavior.

## What Passed

| Check | Result |
| --- | --- |
| JSON parsing | 16 of 16 JSON files valid |
| VS Code diagnostics | No errors reported |
| PowerShell syntax | Both ASCII builders parse with zero syntax errors |
| ASCII geometry | 44 nonblank dashboard lines; all exactly 78 characters |
| SVG structure | Valid XML, correct namespace/viewBox, no script/style/foreignObject, minimum font 11px |
| HTML desktop render | Four canvases, ECharts loaded, no runtime/request errors, theme toggle works |
| Plugin publication | All seven components plus bundle found in the local Mall clone |
| Heir layout | Zero errors; one stale-sync warning |

## Release Gate

Status: **Blocked**.

Resolve in this order:

1. Correct the benchmark data and remove unsupported decision claims.
2. Build an executable, data-coupled end-to-end test and regenerate all outputs.
3. Reconcile this factory with the Copilot-native published bundle.
4. Fix mobile HTML overflow and clipped SVG prose, then re-run visual checks.
5. Consolidate project status documentation and dependency policy.
6. Repair the Markdown validator and add regression fixtures.

## Evidence Appendix

### CSV calculations

The load-bearing arithmetic is:

- Total units: `sum(units) = 4,928`.
- Total margin: `sum(revenue - cost) = $73,920`.
- Jan-to-Jun growth: `(42,900 / 36,800) - 1 = 16.6%`.
- North Widget A Jan-to-peak: `(15,100 / 12,500) - 1 = 20.8%`.
- North Widget B Jan-to-peak: `(10,200 / 8,300) - 1 = 22.9%`.
- South Widget A Jan-to-peak: `(12,000 / 9,800) - 1 = 22.4%`.
- South Widget B Jan-to-peak: `(7,500 / 6,200) - 1 = 21.0%`.
- Marketing efficiency: not computable because the CSV has no spend field.

This PowerShell reproduces the principal totals from the repository root:

```powershell
$rows = Import-Csv 'datasets/sales-sample.csv'
$revenue = ($rows | Measure-Object revenue -Sum).Sum
$cost = ($rows | Measure-Object cost -Sum).Sum
$units = ($rows | Measure-Object units -Sum).Sum
$monthly = $rows | Group-Object date | ForEach-Object {
  [pscustomobject]@{
    Date = $_.Name
    Revenue = [double](($_.Group | Measure-Object revenue -Sum).Sum)
  }
} | Sort-Object Date
$segments = $rows | Group-Object region,product | ForEach-Object {
  $ordered = $_.Group | Sort-Object date
  $start = [double]$ordered[0].revenue
  $peak = [double](($ordered | Measure-Object revenue -Maximum).Maximum)
  [pscustomobject]@{
    Segment = $_.Name
    JanToPeakPct = [math]::Round((($peak / $start) - 1) * 100, 1)
  }
}
[pscustomobject]@{
  Revenue = $revenue
  Margin = $revenue - $cost
  Units = $units
  JanToJunPct = [math]::Round(
    (($monthly[-1].Revenue / $monthly[0].Revenue) - 1) * 100,
    1
  )
}
$segments | Sort-Object JanToPeakPct -Descending
```

### Local Mall comparison

The SHA-256 prefixes below compare this repo's source skill with the skill
vendored in the adjacent local clone `../Alex_ACT_Plugin_Mall`, subtree
`plugins/data-analytics/visual-storytelling`, at `81405a0`:

- `storytelling-requirements`: `02ee59531eaa` -> `b73212104c59`.
- `datasource-connectors`: `5f2af5b3ae4c` -> `26de71646c68`.
- `data-preparation`: `2a68d629f1bf` -> `57d94515c5a8`.
- `visual-vocabulary`: `d777e1c18251` -> `b0909d595e23`.
- `delivery-ascii-dashboard`: `01ea079f8df6` -> `c7bdf6aef6c2`.
- `delivery-svg-markdown`: `24bd9acac3eb` -> `686ab2491b8c`.
- `delivery-html-dashboard`: `acf078b7a56a` -> `33e4a76df61c`.
- Orchestrator agent: `8a387862a8dd` -> `410edd326601`.

These hashes prove divergence from that local snapshot, not freshness against
the remote Mall default branch. A fresh remote comparison remains an explicit
limitation.

This PowerShell reproduces the skill hashes from the repository root:

```powershell
$names = @(
  'storytelling-requirements',
  'datasource-connectors',
  'data-preparation',
  'visual-vocabulary',
  'delivery-ascii-dashboard',
  'delivery-svg-markdown',
  'delivery-html-dashboard'
)
$mall = '../Alex_ACT_Plugin_Mall/plugins/data-analytics/visual-storytelling'
$expectedMallCommit = '81405a07bfaf317364469e37104d445b432b0db3'
$actualMallCommit = git -C '../Alex_ACT_Plugin_Mall' rev-parse HEAD
if ($actualMallCommit -ne $expectedMallCommit) {
  throw "Expected Mall $expectedMallCommit; found $actualMallCommit"
}
git -C '../Alex_ACT_Plugin_Mall' status --short -- `
  'plugins/data-analytics/visual-storytelling'
foreach ($name in $names) {
  $source = "plugins/$name/SKILL.md"
  $vendored = "$mall/skills/$name/SKILL.md"
  [pscustomobject]@{
    Component = $name
    SourceSha = (Get-FileHash $source).Hash.Substring(0, 12)
    MallSha = (Get-FileHash $vendored).Hash.Substring(0, 12)
  }
}
```

## Method and Limitations

The audit used direct source review, CSV aggregation, JSON parsing, PowerShell
AST parsing, repository diagnostics, character-width validation, local Mall
comparison, and browser rendering at desktop and mobile widths.

The output-writing builders were parsed but not executed, preserving the user's
existing files. HTML was verified from `file://`; it embeds data inline, so no
sibling-file origin behavior is involved, but ECharts still depends on the
external CDN. Mall publication was checked against the local Mall clone, not a
fresh remote checkout. External links and actual installation into a clean heir
were not exercised.
