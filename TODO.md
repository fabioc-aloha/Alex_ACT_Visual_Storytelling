# TODO

Consolidated tracker for the Visual Storytelling plugin collection.

## v2.0.0 -- Boundary Migration Complete

Visual Storytelling now owns requirements, ingestion, preparation, narrative
orchestration, and ASCII delivery. Illustrator owns chart selection and all
graphical delivery. The active bundle is 11,100 tokens across four components.

- [x] Retire `visual-vocabulary`, SVG delivery, and HTML delivery from the
  active bundle.
- [x] Require `alex-act-illustrator-plugin` for chart selection and graphical
  targets.
- [x] Replace legacy Edition and local-install claims in active manifests.
- [x] Publish from an immutable `v2.0.0` source tag and verify Mall parity.

## v1.0.1 -- Historical

All v1 plugins are shipped and tested. The pipeline covers brief-to-dashboard
across three delivery formats (ASCII, SVG, HTML).

### Core Pipeline (Phase 1)

- [x] `visual-vocabulary` -- Published to Mall (4,400 tokens)
- [x] `storytelling-requirements` -- Published to Mall (2,700 tokens)
- [x] `delivery-ascii-dashboard` -- Published to Mall (3,300 tokens)
- [x] `data-preparation` -- Published to Mall (2,300 tokens)
- [x] `datasource-connectors` -- Published to Mall (2,800 tokens)

### Delivery Targets (Phase 2)

- [x] `delivery-svg-markdown` -- SVG in Markdown via D3.js (4,400 tokens)
- [x] `delivery-html-dashboard` -- HTML + ECharts (4,900 tokens)

### Orchestrator

- [x] Pipeline agent (`.github/agents/local/visual-storytelling.agent.md`)
- [x] CSAR QA loop with brief evidence reporting
- [x] ASCII alignment gate (caller-side construction)
- [x] Clean-heir payload and fixture assembly
- [x] Live clean-heir agent invocation
  - [x] Use the plugin-qualified agent identity
  - [x] Initialize the disposable heir as a Git workspace
  - [x] Preserve bounded response diagnostics on postcondition failure
  - [x] Run at the validated 60-credit ceiling and require `dashboard.md` postconditions to pass

### Tests

- [x] Test dataset (`datasets/sales-sample.csv`)
- [x] ASCII test (`tests/sales-dashboard-ascii.md`)
- [x] SVG test (`tests/sales-dashboard-svg.md`) -- output verified
- [x] HTML test (`tests/sales-dashboard-html.md`) -- output verified
- [x] Markdown validator fixtures for independent tables and initialized Mermaid
- [x] Deterministic source-to-Mall assembly (36 paths, matching SHA-256 across two builds)
- [ ] Apply the new payload after source commit, immutable-ref preview, and separate Mall publication approval

### Token Budget (v1)

| Metric | Value |
| --- | --- |
| Plugins | 7 |
| Total tokens | 24,800 |

## Historical Enterprise Backlog

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
