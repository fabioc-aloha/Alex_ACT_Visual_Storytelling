# ASCII Delivery Demos

Eight worked examples of the `delivery-ascii-dashboard` skill, generated from
real data and validated against the skill's own geometry contract.

Every figure here is computed from [`datasets/sales-sample.csv`](../datasets/sales-sample.csv)
(24 rows, H1 2024). No number is hand-written, so the demos cannot drift from
the data they claim to describe.

## The gallery

[`GALLERY.md`](GALLERY.md) and [`gallery.html`](gallery.html) catalog 19 ASCII
chart forms organized by the same seven communication goals used by
Illustrator's `chart-vocabulary` skill: Comparison, Change Over Time,
Proportion, Distribution, Relationship, Flow and Process, and Deviation.

The two galleries compose rather than compete. Pick the communication goal in
`chart-vocabulary`, then render it here when the target is a terminal, a log
file, a pull request, or a context window with no rendering engine available.

Each entry carries a best-when and avoid-when pair, matching the catalog format
the Illustrator skill uses. Entries tagged **real** are computed from the
sample dataset. Entries tagged **illustrative** use shaped data because the
sample contains no funnel or process structure, so the form is the point rather
than the numbers.

```powershell
pwsh -NoProfile -File demo/build-gallery.ps1
```

Both outputs come from one source of truth in the script, so the Markdown and
HTML versions cannot disagree. The HTML is self-contained with no external CSS,
fonts, or scripts, so it opens straight from `file://`.

## The demos

| File | Pattern | Shows |
| --- | --- | --- |
| [`01-kpi-strip.txt`](01-kpi-strip.txt) | KPI strip | Four metric cards in one 78-char row |
| [`02-horizontal-bar.txt`](02-horizontal-bar.txt) | Horizontal bars | Ranked comparison with `#`/`.` fill, two stacked sections |
| [`03-sparkline-row.txt`](03-sparkline-row.txt) | Sparkline | Trend shape with `/`, `\`, `_` plus aligned month labels |
| [`04-two-column.txt`](04-two-column.txt) | Two-column | Side-by-side cards sharing the 2-char gap |
| [`05-full-dashboard.txt`](05-full-dashboard.txt) | Full dashboard | Header, KPI row, bar panel, trend, action footer |
| [`06-distribution.txt`](06-distribution.txt) | Histogram | Five equal-width buckets with counts |
| [`07-progress-gauges.txt`](07-progress-gauges.txt) | Gauges | Attainment against target with `[OK]`, `[WARN]`, `[RISK]` |
| [`08-heatmap.txt`](08-heatmap.txt) | Heatmap | Region by month density using a five-step ASCII ramp |

## Regenerate

```powershell
pwsh -NoProfile -File demo/build-demos.ps1
```

The script recomputes every aggregate from the CSV, rewrites all eight files,
and then validates them. It exits non-zero if any check fails, so a broken
demo cannot pass silently.

## What is validated

| Check | Rule |
| --- | --- |
| Line width | No line exceeds 78 characters |
| Border width | Every `+---+` and `+===+` rule is exactly 78 |
| Character set | Printable ASCII only, so no emoji and no box-drawing Unicode |

These are the constraints from the skill's Module 1 and Module 5. The width is
78 rather than 80 because the 1-character margin on each side of an 80-column
terminal leaves 78 for content.

## Why this matters

Alignment is the failure mode that makes ASCII output look amateur, and it is
invisible until the text lands in a terminal of a specific width. Computing
widths before drawing, then asserting them afterward, is cheaper than eyeballing
output and catches the error class by construction.

The same property makes these demos useful as regression fixtures: change the
dataset, rerun, and any layout assumption that no longer holds fails loudly.

## Reading the figures

Numbers are right-aligned and labels left-aligned so columns stay scannable.
Bars are sorted by value except where the axis is time, which stays in
chronological order. Status is carried by letters rather than color, so the
output survives a log file or a context window with no styling.
