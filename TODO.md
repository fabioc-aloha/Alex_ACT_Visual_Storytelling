# TODO

Consolidated tracker for the Visual Storytelling plugin collection.

## Phase 1 -- Core Pipeline

- [x] `visual-vocabulary` -- Published to Mall (3,300 tokens)
- [x] `storytelling-requirements` -- Published to Mall (1,900 tokens)
- [x] `delivery-ascii-dashboard` -- Published to Mall (2,700 tokens)
- [x] `data-preparation` -- Published to Mall (1,500 tokens)
- [x] `datasource-connectors` -- Published to Mall (2,000 tokens)
  - [x] CSV/TSV: encoding detection, delimiter inference, header handling
  - [x] JSON/JSONL: path extraction, nested object flattening
  - [x] REST API: pagination (offset, cursor, link-header), auth (API key, OAuth)
  - [x] SQL: parameterized queries, connection string patterns, injection prevention
  - [x] Excel: sheet selection, named ranges, header row detection
  - [x] Parquet/Arrow: columnar format reading, schema inspection
  - [x] Error handling: retries, timeouts, partial data, encoding fallbacks
- [x] Promote `data-preparation` to Mall

## Orchestrator

- [x] Define architecture (ASCII + Mermaid diagrams in PLAN.md)
- [x] Create orchestrator agent (`.github/agents/visual-storytelling.agent.md`)
- [ ] End-to-end test: run orchestrator on `tests/sales-dashboard-ascii.md`

## Test Infrastructure

- [x] Add test dataset (`datasets/sales-sample.csv`)
- [x] Write test scenario (`tests/sales-dashboard-ascii.md`)
- [ ] Add SVG delivery test scenario
- [ ] Add HTML delivery test scenario

## Phase 2 -- Delivery Targets

- [ ] `delivery-svg-markdown` -- SVG panels in Markdown (category: media-graphics)
  - [ ] Absorb and extend Mall's `svg-dashboard-composition` (panel primitive, coordinate system)
  - [ ] Dark-slate palette from Supervisor fleet dashboard
  - [ ] viewBox math: auto-sizing panels to content
  - [ ] Responsive grid: 1-column, 2-column, 3-column layouts
  - [ ] Chart primitives: bar, line, pie/donut, KPI strip, sparkline
  - [ ] Text rendering: title, subtitle, axis labels, data labels
  - [ ] GitHub-compatible: no external CSS, no JS, inline styles only
  - [ ] Export: single `.svg` file or embedded in `.md`
- [ ] `delivery-html-dashboard` -- Self-contained HTML + Chart.js (category: data-analytics)
  - [ ] Absorb and extend Mall's `dashboard-design` (inverted pyramid, KPI cards, filter arch)
  - [ ] Single-file HTML: no build step, no external dependencies
  - [ ] Chart.js integration: bar, line, pie, doughnut, scatter, radar
  - [ ] KPI cards: number, delta, sparkline, conditional color
  - [ ] Responsive grid: CSS Grid, mobile-friendly breakpoints
  - [ ] Embedded data: JSON in `<script>` tag, no external fetch
  - [ ] Print-friendly: `@media print` stylesheet
  - [ ] Theme: light and dark mode toggle
  - [ ] Interactivity: tooltips, legend toggle (no drill-through)
- [ ] Add SVG delivery test scenario
- [ ] Add HTML delivery test scenario

## Phase 3 -- Enterprise

- [ ] `delivery-powerbi-fabric` -- Power BI / Microsoft Fabric (category: data-analytics)
  - [ ] Absorb VT_AIPOWERBI course knowledge: CSAR loop applied to PBI, 5-visual rule
  - [ ] Report design patterns: page layout, navigation, bookmarks
  - [ ] AI visuals: smart narrative, Q&A visual, decomposition tree, anomaly detection
  - [ ] Semantic model guidance: star schema, relationships, measures vs columns
  - [ ] DAX patterns: time intelligence, CALCULATE context, iterator vs aggregator
  - [ ] Copilot-ready data prep: clean column names, proper types, descriptions
  - [ ] Fabric integration: lakehouse, dataflow gen2, pipeline orchestration
  - [ ] Row-level security (RLS) patterns
  - [ ] Performance: import vs DirectQuery decision framework, aggregations
  - [ ] Deployment: workspace, app, embedded, paginated reports

## Backlog

- [ ] `delivery-vega-lite` -- Declarative Vega-Lite JSON spec for web embedding
- [ ] `delivery-observable` -- Observable Framework notebook output
- [ ] `delivery-slides` -- Marp/PPTX presentation output with data charts
- [ ] `delivery-pdf-report` -- PDF report generation via pandoc/weasyprint
- [ ] `delivery-email-digest` -- Email-friendly HTML digest with inline charts

## Token Budget

| Metric | Value |
| --- | --- |
| Published | 11,400 (5 plugins) |
| Complete (unpromoted) | 0 |
| Total committed | 11,400 |
| Budget | 15,000 |
| Headroom | 3,600 |
