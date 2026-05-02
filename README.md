# Alex ACT Visual Storytelling

Plugin factory for data-driven visual storytelling. Develops, tests, and publishes modular plugins to the [Alex ACT Plugin Mall](https://github.com/fabioc-aloha/Alex_ACT_Plugin_Mall).

## What This Is

A collection of plugins that turn raw data into visual stories. Think "Power BI for AI agents": instead of opening a BI tool, a heir loads the right plugins and produces SVG dashboards, HTML reports, or Markdown narratives directly from data.

The pipeline:

| Step | Plugin | What It Does |
| --- | --- | --- |
| 1. Brief | `storytelling-requirements` | Guided intake: audience, Big Idea, questions, data sources, delivery target |
| 2. Ingest | `datasource-connectors` | Load data from CSV, JSON, API, SQL, Excel, Parquet |
| 3. Clean | `data-preparation` | Profile, clean, aggregate, pivot, quality-check the data |
| 4. Select | `visual-vocabulary` | Pick the right chart types for the story you want to tell |
| 5. Render | `delivery-*` | Output to ASCII, SVG/Markdown, HTML dashboard, Power BI, or other targets |

Install only what you need. A project doing SVG dashboards skips the Power BI plugin; a Fabric project skips SVG.

## Plugin Status

| Plugin | Status | Mall |
| --- | --- | --- |
| `visual-vocabulary` | Published | [data-analytics/visual-vocabulary](https://github.com/fabioc-aloha/Alex_Skill_Mall/tree/main/plugins/data-analytics/visual-vocabulary) |
| `storytelling-requirements` | In Progress | -- |
| `delivery-ascii-dashboard` | In Progress | -- |
| `data-preparation` | Planned | -- |
| `datasource-connectors` | Planned | -- |
| `delivery-svg-markdown` | Planned | -- |
| `delivery-html-dashboard` | Planned | -- |
| `delivery-powerbi-fabric` | Planned | -- |

## Quick Start

```bash
# Clone this repo
git clone https://github.com/fabioc-aloha/Alex_ACT_Visual_Storytelling.git

# Install a published plugin into your project
cp -r plugins/visual-vocabulary/ /your/project/.github/skills/local/visual-vocabulary/
```

## Design Principles

- **DRY/KISS modular collection.** Each plugin does one thing.
- **Selection is universal; delivery is swappable.** Chart selection and storytelling are platform-agnostic. Delivery plugins are platform-specific.
- **Requirements document is the input.** Every project starts with a structured brief.
- **Publish to the Mall, develop here.** This repo is the factory; the Mall is the storefront.
- **Living references over static knowledge.** Link to galleries; encode judgment in plugins.

## Complementary Mall Plugins

These existing Mall plugins work alongside (not overlap with) this collection:

| Mall Plugin | Role |
| --- | --- |
| `data-storytelling` | Narrative arc (three-act, Knaflic/Duarte). Feeds FROM the requirements brief. |
| `data-visualization` | Chart design (color, annotation, decluttering). Fires AFTER chart selection. |
| `dashboard-design` | Layout patterns (inverted pyramid, KPI cards). Fires AFTER chart selection. |
| `chart-interpretation` | Reading existing charts. The inverse of `visual-vocabulary`. |

## Project Plan

See [PLAN.md](PLAN.md) for the full development roadmap, success criteria, and backlog.

## License

MIT
