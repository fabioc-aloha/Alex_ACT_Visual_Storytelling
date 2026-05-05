# TODO

Consolidated tracker for the Visual Storytelling plugin collection.

## v1.0.0 -- Complete

All v1 plugins are shipped and tested. The pipeline covers brief-to-dashboard
across three delivery formats (ASCII, SVG, HTML).

### Core Pipeline (Phase 1)

- [x] `visual-vocabulary` -- Published to Mall (3,300 tokens)
- [x] `storytelling-requirements` -- Published to Mall (1,900 tokens)
- [x] `delivery-ascii-dashboard` -- Published to Mall (2,700 tokens)
- [x] `data-preparation` -- Published to Mall (1,500 tokens)
- [x] `datasource-connectors` -- Published to Mall (2,000 tokens)

### Delivery Targets (Phase 2)

- [x] `delivery-svg-markdown` -- SVG in Markdown via D3.js (4,200 tokens)
- [x] `delivery-html-dashboard` -- HTML + ECharts (4,800 tokens)

### Orchestrator

- [x] Pipeline agent (`.github/agents/local/visual-storytelling.agent.md`)
- [x] CSAR QA loop with brief evidence reporting
- [x] ASCII alignment gate (caller-side construction)

### Tests

- [x] Test dataset (`datasets/sales-sample.csv`)
- [x] ASCII test (`tests/sales-dashboard-ascii.md`)
- [x] SVG test (`tests/sales-dashboard-svg.md`) -- output verified
- [x] HTML test (`tests/sales-dashboard-html.md`) -- output verified

### Token Budget (v1)

| Metric | Value |
| --- | --- |
| Plugins | 7 |
| Total tokens | 20,400 |

## v2.0.0 -- Enterprise (planned)

- [ ] `delivery-powerbi-fabric` -- Power BI / Microsoft Fabric
  - [ ] CSAR loop applied to PBI, 5-visual rule
  - [ ] Report design patterns: page layout, navigation, bookmarks
  - [ ] AI visuals: smart narrative, Q&A visual, decomposition tree
  - [ ] Semantic model: star schema, relationships, measures vs columns
  - [ ] DAX patterns: time intelligence, CALCULATE context
  - [ ] Copilot-ready data prep
  - [ ] Fabric integration: lakehouse, dataflow gen2, pipelines
  - [ ] Row-level security (RLS) patterns
  - [ ] Performance: import vs DirectQuery, aggregations
  - [ ] Deployment: workspace, app, embedded, paginated reports

## Backlog

- [ ] `delivery-vega-lite` -- Declarative Vega-Lite JSON spec
- [ ] `delivery-observable` -- Observable Framework notebook
- [ ] `delivery-slides` -- Marp/PPTX presentation
- [ ] `delivery-pdf-report` -- PDF via pandoc/weasyprint
- [ ] `delivery-email-digest` -- Email-friendly HTML digest
