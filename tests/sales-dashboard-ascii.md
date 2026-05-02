# Test: Sales Dashboard (ASCII delivery)

## Purpose

Validate that the published plugins can produce a working ASCII dashboard from
`datasets/sales-sample.csv` using a filled-out requirements brief.

## Filled Brief

| Field | Answer |
| --- | --- |
| **Primary audience** | Regional sales managers |
| **Audience expertise** | Manager |
| **Time budget** | 2 minutes |
| **Decision this supports** | Allocate Q3 marketing budget by region and product |
| **Consumption format** | Screen (terminal) |

**Big Idea**: Regional managers should shift Q3 budget toward Widget A in North
because it shows the strongest revenue growth trend and highest margin.

### Questions

| # | Question | Communication Goal | Priority |
| --- | --- | --- | --- |
| 1 | How is revenue trending by month? | Change Over Time | Must-have |
| 2 | How does North vs South revenue compare? | Comparison | Must-have |
| 3 | What is the revenue split by product? | Proportion | Should-have |

### Data Source

| Source | Format | Location |
| --- | --- | --- |
| sales-sample | CSV | `datasets/sales-sample.csv` |

### Delivery Target

| Field | Answer |
| --- | --- |
| **Output format** | ASCII dashboard |
| **Visual budget** | 3 visuals (one per question) |

## Expected Outcome

The orchestrator should produce an ASCII dashboard with:

1. A sparkline or horizontal bar trend showing monthly revenue (Jan-Jun)
2. A side-by-side comparison of North vs South totals
3. A proportion breakdown of Widget A vs Widget B

All rendered using `delivery-ascii-dashboard` patterns: KPI strip, horizontal
bars, predictable monospace geometry, no emoji.

## Pass Criteria

- All 3 must-have/should-have questions answered with a visual
- Big Idea sentence appears as dashboard title
- Numbers match the CSV data
- Output fits in 80-column terminal width
