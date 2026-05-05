# Alex ACT Visual Storytelling

Plugin collection that turns raw data into visual stories. Load the plugins,
point at a dataset, pick a delivery format, get a dashboard.

**v1.0.0** -- 7 plugins, 3 delivery formats (ASCII, SVG, HTML), orchestrator agent.

## Pipeline

| Step | Plugin | What It Does |
| --- | --- | --- |
| 1. Brief | `storytelling-requirements` | Guided intake: audience, Big Idea, questions, data sources, delivery target |
| 2. Ingest | `datasource-connectors` | Load data from CSV, JSON, API, SQL, Excel, Parquet |
| 3. Clean | `data-preparation` | Profile, clean, aggregate, pivot, quality-check the data |
| 4. Select | `visual-vocabulary` | Pick the right chart types for the story you want to tell |
| 5. Render | `delivery-*` | Output to ASCII, SVG/Markdown, or HTML dashboard |

Install only what you need. A project doing SVG dashboards skips the HTML plugin.

## Plugins

| Plugin | Tokens | Category | Description |
| --- | --- | --- | --- |
| `visual-vocabulary` | 3,300 | data-analytics | Chart catalog by communication goal, CSAR evaluation loop |
| `storytelling-requirements` | 1,900 | data-analytics | Structured brief template and intake workflow |
| `data-preparation` | 1,500 | data-analytics | Data profiling, cleaning, aggregation patterns |
| `datasource-connectors` | 2,000 | data-analytics | CSV, JSON, API, SQL, Excel, Parquet connectors |
| `delivery-ascii-dashboard` | 2,700 | data-analytics | Pure ASCII dashboards for terminals and plain text |
| `delivery-svg-markdown` | 4,200 | media-graphics | Static SVG panels embeddable in GitHub Markdown |
| `delivery-html-dashboard` | 4,800 | data-analytics | Interactive HTML dashboards with Apache ECharts |

**Total**: 20,400 tokens across 7 plugins.

## Orchestrator Agent

The `visual-storytelling` agent (`.github/agents/local/visual-storytelling.agent.md`)
runs the full pipeline: reads a brief, plans which modules to invoke, delegates
to each step, and runs a CSAR QA loop on the output.

```text
@visual-storytelling Show me sales trends from datasets/sales-sample.csv as an HTML dashboard
```

## License

MIT
