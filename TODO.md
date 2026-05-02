# TODO

Consolidated tracker for the Visual Storytelling plugin collection.

## Phase 1 -- Core Pipeline

- [x] `visual-vocabulary` -- Published to Mall (3,300 tokens)
- [x] `storytelling-requirements` -- Published to Mall (1,900 tokens)
- [x] `delivery-ascii-dashboard` -- Published to Mall (2,700 tokens)
- [x] `data-preparation` -- Complete, ready to promote (1,500 tokens)
- [ ] `datasource-connectors` -- Build SKILL.md + plugin.json covering:
  - [ ] CSV/TSV: encoding detection, delimiter inference, header handling
  - [ ] JSON/JSONL: path extraction, nested object flattening
  - [ ] REST API: pagination (offset, cursor, link-header), auth (API key, OAuth)
  - [ ] SQL: parameterized queries, connection string patterns, injection prevention
  - [ ] Excel: sheet selection, named ranges, header row detection
  - [ ] Parquet/Arrow: columnar format reading, schema inspection
  - [ ] Error handling: retries, timeouts, partial data, encoding fallbacks
- [ ] Promote `data-preparation` to Mall

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

- [ ] `delivery-svg-markdown` -- SVG panels in Markdown
- [ ] `delivery-html-dashboard` -- Self-contained HTML + Chart.js

## Phase 3 -- Enterprise

- [ ] `delivery-powerbi-fabric` -- Power BI / Microsoft Fabric

## Backlog

- [ ] `delivery-vega-lite`
- [ ] `delivery-observable`
- [ ] `delivery-slides`
- [ ] `delivery-pdf-report`
- [ ] `delivery-email-digest`

## Token Budget

| Metric | Value |
| --- | --- |
| Published | 7,900 (3 plugins) |
| Complete (unpromoted) | 1,500 (1 plugin) |
| Total committed | 9,400 |
| Budget | 15,000 |
| Headroom | 5,600 |
