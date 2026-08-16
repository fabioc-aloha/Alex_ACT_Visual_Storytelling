# Alex ACT Visual Storytelling

![Alex ACT Visual Storytelling](assets/banner.svg)

Plugin collection that turns raw data into visual stories. Load the plugins,
point at a dataset, pick a delivery format, get a dashboard.

**v2.0.0** -- four Visual Storytelling components plus an orchestrator agent.
It owns the brief, ingestion, preparation, narrative workflow, and ASCII
delivery. Install `alex-act-illustrator-plugin` for chart selection and
graphical delivery. This README is the live support source; [TODO.md](TODO.md)
tracks work, while PLAN.md and ACT.md are historical.

## Pipeline

| Step | Plugin | What It Does |
| --- | --- | --- |
| 1. Brief | `storytelling-requirements` | Guided intake: audience, Big Idea, questions, data sources, delivery target |
| 2. Ingest | `datasource-connectors` | Load data from CSV, JSON, API, SQL, Excel, Parquet |
| 3. Clean | `data-preparation` | Profile, clean, aggregate, pivot, quality-check the data |
| 4. Select | Illustrator `chart-vocabulary` | Pick the right chart types for the story |
| 5. Render | ASCII or Illustrator | Output portable text locally or graphical artifacts through Illustrator |

Install only what you need. A project doing SVG dashboards skips the HTML plugin.

## Plugins

| Plugin | Tokens | Category | Description |
| --- | --- | --- | --- |
| `storytelling-requirements` | 2,700 | data-analytics | Structured brief template and intake workflow |
| `data-preparation` | 2,300 | data-analytics | Data profiling, cleaning, aggregation patterns |
| `datasource-connectors` | 2,800 | data-analytics | CSV, JSON, API, SQL, Excel, Parquet connectors |
| `delivery-ascii-dashboard` | 3,300 | data-analytics | Pure ASCII dashboards for terminals and plain text |

**Total**: 11,100 tokens across 4 components. Graphical output is supplied by
Illustrator rather than a duplicate bundled renderer.

## Orchestrator Agent

The `visual-storytelling` bundle agent runs the full pipeline: reads a brief,
plans which modules to invoke, delegates to each step, and runs a CSAR QA loop
on the output.

```text
@visual-storytelling Show me sales trends from datasets/sales-sample.csv as an HTML dashboard
```

## License

MIT
