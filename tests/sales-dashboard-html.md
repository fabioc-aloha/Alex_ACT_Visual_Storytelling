# Test: Sales Dashboard (HTML delivery)

## Purpose

Validate that `delivery-html-dashboard` can produce a working interactive HTML
dashboard from `datasets/sales-sample.csv` using ECharts. The output should be
a single `.html` file that opens in any browser with no build step.

## Filled Brief

| Field | Answer |
| --- | --- |
| **Primary audience** | Sales leadership (VP + Directors) |
| **Audience expertise** | Executive |
| **Time budget** | 90 seconds (interactive exploration available) |
| **Decision this supports** | Identify segment leaders and the additional evidence needed for Q3 budget allocation |
| **Consumption format** | Browser (shared via Slack/email link) |

**Big Idea**: North Widget B has the fastest Jan-to-peak growth (22.9%) while
North Widget A has the largest revenue share (33.8%); campaign-spend and
response data are required before estimating budget impact.

### Questions

| # | Question | Communication Goal | Priority |
| --- | --- | --- | --- |
| 1 | What are the headline KPIs? | Summary | Must-have |
| 2 | How is revenue trending month-over-month? | Change Over Time | Must-have |
| 3 | Which segments are most profitable? | Ranking | Must-have |
| 4 | What is the revenue concentration? | Proportion | Should-have |
| 5 | How does Jan-to-peak growth compare across segments? | Comparison | Nice-to-have |

### Data Source

| Source | Format | Location |
| --- | --- | --- |
| sales-sample | CSV | `datasets/sales-sample.csv` |

### Delivery Target

| Field | Answer |
| --- | --- |
| **Output format** | Self-contained HTML (ECharts) |
| **Visual budget** | 5 visuals (one per question) |
| **Theme** | Dark (with toggle to light) |
| **Layout** | KPI strip + line chart (full) + two-column (bar + donut) + full bar |
| **Interactivity** | Tooltips, legend toggle, data zoom on trend chart |
| **Output file** | `tests/sales-dashboard-html-output.html` |

### Pre-aggregated Data

Monthly totals: Jan=$36,800, Feb=$39,000, Mar=$42,300, Apr=$40,600, May=$44,800, Jun=$42,900.
Total revenue: $246,400. Total margin: $73,920 (30.0%). Total units: 4,928.

Segment breakdown:

| Segment | Revenue | Margin | Margin% | Jan-to-peak growth |
| --- | --- | --- | --- | --- |
| North Widget A | $83,300 | $24,990 | 30.0% | 20.8% |
| South Widget A | $65,500 | $19,650 | 30.0% | 22.4% |
| North Widget B | $55,800 | $16,740 | 30.0% | 22.9% |
| South Widget B | $41,800 | $12,540 | 30.0% | 21.0% |

## Expected Output

A single `.html` file containing:

1. Exact ECharts 6.1.0 CDN script with SHA-384 integrity
2. KPI strip (4 cards: Revenue, Margin, Units, Growth)
3. Line chart with area fill showing 6-month trend (with data zoom)
4. Horizontal bar chart showing segment ranking by revenue
5. Donut chart showing revenue concentration (share of total)
6. Bar chart comparing Jan-to-peak growth by segment
7. Dark/light theme toggle button
8. Responsive CSS Grid layout
9. Connected tooltips across charts

## Validation Criteria

| Check | Pass criteria |
| --- | --- |
| Single file | Only one `.html` file, no external resources besides the integrity-pinned CDN |
| Opens clean | No console errors in browser DevTools |
| Charts render | All 5 visuals visible on page load |
| Tooltips work | Hover shows formatted values |
| Theme toggle | Button switches dark/light, charts update colors |
| Responsive | Resize to 768px width; grid reflows to single column |
| Print clean | Ctrl+P shows readable layout |
| Accessible | `aria` config present in ECharts options |
| Data correct | KPI, tooltip, share, margin, and growth values match pre-aggregated data above |
| Connected | Hovering one chart highlights same category in others |
