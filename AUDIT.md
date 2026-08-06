# Project Audit

**Date**: 2026-08-06 \
**Remediation update**: 2026-08-06 \
**Branch baseline**: `main` at `bc445a2`; remediation is currently uncommitted \
**Audience**: Visual Storytelling maintainers and release approvers \
**Scope**: Project plugins, bundle/orchestrator, test data and outputs, release
documentation, and repository health tooling \
**Release boundary**: **Blocked for promotion from this source repo, v1
re-release, or claims of verified end-to-end operation until all seven Release
Gate items pass their stated completion tests. This does not assert that the
currently installed Mall bundle is nonfunctional.**

## Executive Summary

The plugin collection has clear module boundaries and its three committed
delivery examples render. The original audit identified three High and four
Medium findings. Example remediation has now resolved data correctness, visual
acceptance, and HTML dependency integrity:

- [x] CSV-derived values and evidence boundaries now agree across all examples.
- [x] HTML desktop/mobile and SVG rendered acceptance checks pass.
- [x] ECharts is exact-version and integrity pinned with visible load failure.
- [ ] Full clean-heir orchestration, automated source-to-Mall publishing,
  project-state docs, and the inherited Markdown validator remain open.

No Critical security or data-loss finding was identified within the checks
performed. Release clearance remains blocked by the unchecked Release Gate
items below.

The worktree already contained changes to `.vscode/settings.json` and an
untracked `.vscode/markdown-light.css` before this audit. They were not modified
or assessed as project defects.

## Findings

### High 1 - The benchmark data story is materially incorrect

**Status**: [x] Resolved on 2026-08-06.

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

**Resolution evidence**: All briefs and outputs now report 4,928 units, identify
North Widget B as the fastest-growing segment at 22.9%, and state that campaign
spend is required before estimating budget impact. `tests/verify-examples.ps1`
derives the contract from the CSV and passes. A `4,928 -> 4,929` mutation was
caught by two assertions; an SVG `22.6% -> 22.7%` share mutation was also
caught. Both files were restored bit-identically.

### High 2 - The test process can pass an incorrect dashboard

**Status**: [ ] Mitigated for examples; clean-heir orchestrator regeneration
remains open.

At audit time, both ASCII builders hardcoded data and wrote to one workstation
path. They have been consolidated into one CSV-driven, parameterized,
repository-relative builder. The committed ASCII output must match a fresh
temporary generation byte-for-byte. `tests/verify-examples.ps1` now validates
all briefs and outputs against CSV-derived metrics, source-template safeguards,
ASCII geometry, HTML bindings, SVG structure, required CSV columns, and the
verification record.

**Remaining impact**: The contract does not invoke the orchestrator in a clean
heir or regenerate HTML/SVG through pipeline delegation, so the advertised
one-invocation integration remains unproven.

**Required action**: Add a clean-heir harness that invokes the orchestrator and
regenerates all three formats through their pipeline boundaries. Completion
means the clean-heir run exits zero and its outputs pass
`tests/verify-examples.ps1` without manual edits.

### High 3 - The factory does not reproduce the local Mall bundle snapshot

**Status**: [ ] Mitigated; the 1.0.1 payload is synchronized, but deterministic
publishing from a clean checkout remains open.

The repository calls itself the plugin factory and defines promotion as copying
a finished plugin to the Mall
([.github/copilot-instructions.local.md](.github/copilot-instructions.local.md#L13-L48),
[PLAN.md](PLAN.md#L264-L268)). That workflow is obsolete for the current
Copilot-native layout observed in the local `fabioc-aloha/Alex_Skill_Mall`
clone at commit `81405a07bfaf317364469e37104d445b432b0db3`. The compared
`plugins/data-analytics/visual-storytelling` subtree had no local changes. That
original comparison found:

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

**Remediation evidence**: `tests/verify-plugin.ps1` now proves source and Mall
versions, token metadata, all component skill hashes, plugin-local wrapper
paths, and installable-agent safeguards. It passes for visual-storytelling
1.0.1 across the self-contained bundle and six standalone Mall plugins. Mall
payload validation, 46 Mall tests, and catalog validation also pass.

**Remaining impact**: The synchronization was performed as a controlled
vendoring operation, but the repository still lacks one documented command that
assembles the Mall-native wrapper/agent and bundled skills from a clean source
checkout.

**Required action**: Make this repository the declared source and encode the
verified synchronization as one deterministic publish command. Completion means
a clean checkout produces the same validated Mall subtree and
`tests/verify-plugin.ps1` passes without manual copy steps.

### Medium 1 - Rendered examples fail their own visual criteria

**Status**: [x] Resolved on 2026-08-06.

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

**Resolution evidence**: HTML now renders four canvases with zero console/page/
request errors. Desktop has no overflow; at a 390px viewport, page and client
width both measured 375px and all four growth labels remained visible. The SVG
rendered at its 800px viewBox with all evidence text visible and unclipped.

### Medium 2 - Project state documentation contradicts the release state

**Status**: [ ] Open.

[README.md](README.md#L5-L34) and [TODO.md](TODO.md#L4-L41) describe v1.0.1 as
complete at 24,800 tokens. In contrast:

- [ACT.md](ACT.md#L28-L39) says SVG and HTML are not started.
- [PLAN.md](PLAN.md#L221-L228) marks those plugins Planned and still specifies
  Chart.js rather than ECharts.
- [PLAN.md](PLAN.md#L275-L279) says only three of five Phase 1 plugins are
  published, the pipeline is not end-to-end tested, and the collection is
  9,400 tokens.
- The maintainer contract still caps the complete pipeline at 15,000 tokens
  ([.github/copilot-instructions.local.md](.github/copilot-instructions.local.md#L124)),
  while the release declares 24,800.

**Impact**: Planning, implementation, and release documents produce different
answers about supported libraries, readiness, and constraints.

**Required action**: Designate one live status source, convert historical
documents to clearly dated records, and either revise or enforce the 15K budget.
The Visual Storytelling maintainer owns this action. Completion means README,
TODO, PLAN, ACT, and the local orchestrator report one consistent support and
budget state.

### Medium 3 - The HTML artifact executes a mutable third-party script

**Status**: [x] Resolved on 2026-08-06.

The committed dashboard loads `https://cdn.jsdelivr.net/npm/echarts@6/...`
([tests/sales-dashboard-html-output.html](tests/sales-dashboard-html-output.html#L8)).
The major-only version can change without a repository diff. The tag has no
Subresource Integrity hash or `crossorigin` attribute, and the committed output
does not include the fallback described by the skill. The page rendered during
this audit only because the CDN was reachable.

**Impact**: The artifact is not fully self-contained, is unavailable offline,
and executes a dependency whose exact bytes are not pinned by the repository.

**Resolution evidence**: The output, plugin skill, and README now pin ECharts
6.1.0 with SHA-384 integrity and `crossorigin="anonymous"`. If loading fails,
each chart panel displays a visible "Charts unavailable" message. Browser
verification loaded the exact 6.1.0 resource and reported zero errors; a
blocked-resource probe displayed the fallback in all four panels.

### Medium 4 - The repository Markdown gate is not trustworthy

**Status**: [ ] Open.

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

**Status**: [ ] Informational.

`heir-doctor` reported no layout errors but warned that Edition v1.2.0 was last
synced 92 days ago. This does not invalidate the v1 plugins, but inherited tools
and documentation may lag current Edition behavior.

## What Passed

| Check | Result |
| --- | --- |
| JSON parsing | 16 of 16 JSON files valid |
| VS Code diagnostics | No errors reported |
| PowerShell syntax | Builder and three verification scripts parse with zero syntax errors |
| ASCII geometry | Every nonblank dashboard line is exactly 78 characters |
| SVG structure | Valid XML, correct namespace/viewBox, no script/style/foreignObject, minimum font 11px |
| HTML desktop render | Four canvases, ECharts loaded, no runtime/request errors, theme toggle works |
| HTML mobile render | No overflow at 390px; all growth labels visible |
| Example data contract | PASS against CSV-derived totals, growth, evidence boundaries, and source guidance |
| Mutation tests | Unit, SVG share, and skill-contract defects caught; sources restored bit-identically |
| Plugin publication | visual-storytelling 1.0.1 synchronized; Mall payload/tests/catalog pass |
| Heir layout | Zero errors; one stale-sync warning |

## Release Gate

Status: **Blocked**.

Resolve in this order:

1. [x] Correct the benchmark data and remove unsupported decision claims.
2. [ ] Run the orchestrator in a clean heir and regenerate all three formats.
3. [ ] Automate the verified source-to-Mall 1.0.1 publishing workflow.
4. [x] Fix mobile HTML overflow and clipped SVG prose; re-run visual checks.
5. [ ] Consolidate project status documentation and token-budget policy.
6. [x] Pin HTML dependencies and expose resource-load failure.
7. [ ] Repair the Markdown validator and add regression fixtures.

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

The original `81405a0` comparison proved that every bundled component differed.
After remediation, this command validates current source/Mall equality,
versions, metadata, wrapper paths, and agent safeguards:

```powershell
& ./tests/verify-plugin.ps1
```

Result: `PASS: visual-storytelling 1.0.1 is synchronized to the Mall bundle and
standalone plugins.` This proves the current adjacent working trees agree; it
does not yet prove a clean-checkout publishing command. Generated marketplace
and normalized catalog records currently expose all seven installable payloads
at 1.0.1, and those generated records pass Mall validation. Immutable source
provenance remains open until the Mall changes are committed and the catalog is
regenerated from that committed state.

## Method and Limitations

The audit used direct source review, CSV aggregation, JSON parsing, PowerShell
AST parsing, repository diagnostics, character-width validation, local Mall
comparison, and browser rendering at desktop and mobile widths.

The CSV-driven ASCII builder was executed against both the committed output and
a temporary output. HTML was verified from `file://`; it embeds data inline, so
no sibling-file origin behavior is involved, but ECharts still depends on the
integrity-pinned external CDN. Mall publication was checked against the local
Mall clone, not a fresh remote checkout. The updated Mall payload and generated
catalog are uncommitted, so immutable provenance is not final. External links
and actual installation into a clean heir were not exercised.
