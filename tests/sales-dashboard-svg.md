# Test: Sales Dashboard (SVG delivery)

## Purpose

Validate that `delivery-svg-markdown` can produce a working SVG dashboard from
`datasets/sales-sample.csv` using a filled-out requirements brief. The output
should be GitHub-compatible (no JS, no external CSS, inline styles only).

## Filled Brief

| Field | Answer |
| --- | --- |
| **Primary audience** | VP of Sales reviewing quarterly performance |
| **Audience expertise** | Executive |
| **Time budget** | 60 seconds |
| **Decision this supports** | Identify segment leaders and whether current data supports Q3 budget reallocation |
| **Consumption format** | Screen (GitHub README / VS Code preview) |

**Big Idea**: North Widget B has the fastest Jan-to-peak growth (22.9%) while
North Widget A has the largest revenue share (33.8%); campaign-spend and
response data are still required before reallocating Q3 marketing budget.

### Questions

| # | Question | Communication Goal | Priority |
| --- | --- | --- | --- |
| 1 | What are the headline metrics? | Summary (KPI) | Must-have |
| 2 | How is revenue trending month-over-month? | Change Over Time | Must-have |
| 3 | Which region + product segment grows fastest? | Ranking | Must-have |
| 4 | What is the revenue concentration risk? | Proportion | Should-have |

### Data Source

| Source | Format | Location |
| --- | --- | --- |
| sales-sample | CSV | `datasets/sales-sample.csv` |

### Delivery Target

| Field | Answer |
| --- | --- |
| **Output format** | SVG embedded in Markdown |
| **Visual budget** | 4 visuals (one per question) |
| **Theme** | Dark-slate |
| **Layout** | KPI strip (row 1) + line chart (row 2) + two-column bars (row 3) |
| **Max width** | 800px |
| **Output file** | `tests/sales-dashboard-svg-output.md` |

### Pre-aggregated Data

Monthly totals: Jan=$36,800, Feb=$39,000, Mar=$42,300, Apr=$40,600, May=$44,800, Jun=$42,900.
Total revenue: $246,400. Total margin: $73,920 (30.0%). Total units: 4,928.

Segment breakdown:

| Segment | Revenue | Share |
| --- | --- | --- |
| North Widget A | $83,300 | 33.8% |
| South Widget A | $65,500 | 26.6% |
| North Widget B | $55,800 | 22.6% |
| South Widget B | $41,800 | 17.0% |

Jan-to-peak segment growth:

| Segment | Growth |
| --- | ---: |
| North Widget B | 22.9% |
| South Widget A | 22.4% |
| South Widget B | 21.0% |
| North Widget A | 20.8% |

## Expected Output

A Markdown file containing an inline `<svg>` element with:

1. A KPI strip (3-4 cards: Revenue, Margin, Units, Growth)
2. A line chart showing 6-month revenue trend
3. A horizontal bar chart showing Jan-to-peak segment growth ranking
4. A pie/donut or bar showing concentration (share of total)

All in the dark-slate color palette, with `viewBox="0 0 800 {height}"`,
inline styles only, and `xmlns="http://www.w3.org/2000/svg"`.

## Validation Criteria

| Check | Pass criteria |
| --- | --- |
| GitHub-safe | No `<style>`, `<script>`, or `<foreignObject>` elements |
| Has xmlns | `xmlns="http://www.w3.org/2000/svg"` present |
| Has viewBox | `viewBox` attribute on root `<svg>` |
| Text readable | All `font-size` values >= 11 |
| Data correct | KPI, share, and growth values match pre-aggregated data |
| Color palette | Uses dark-slate hex codes from SKILL.md |
| File renders | VS Code Markdown preview shows the chart |
