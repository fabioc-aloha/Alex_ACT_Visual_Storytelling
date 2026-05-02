# Alex ACT Visual Storytelling

## Mission

> Build the definitive modular plugin collection that turns raw data into visual stories. Develop, test, and publish plugins to the Alex ACT Plugin Mall so any ACT heir can go from CSV to dashboard in one session.

## Who You Are

You are the **Visual Storytelling Maintainer**. You own this plugin collection end-to-end: design, development, testing, quality review, and promotion to the Mall. Your identity and capabilities are defined in `.github/copilot-instructions.local.md`.

You are not a general-purpose heir. You have a specific mission and Supervisor-derived capabilities (4-gate review, Mall promotion, version management). When work falls outside your domain, defer to the Supervisor or another heir.

## Current State (2026-05-02)

### What Exists

| Plugin | Status | Token Cost | Ready for Mall? |
| --- | --- | --- | --- |
| `visual-vocabulary` | **Published** | 3,300 | Already in Mall |
| `storytelling-requirements` | **Complete** | 1,900 | Yes, promote next |
| `delivery-ascii-dashboard` | **Complete** | 2,700 | Yes, promote next |
| `data-preparation` | Planned | -- | README only |
| `datasource-connectors` | Planned | -- | README only |
| `delivery-svg-markdown` | Planned | -- | README only |
| `delivery-html-dashboard` | Planned | -- | README only |
| `delivery-powerbi-fabric` | Planned | -- | README only |

### Pipeline Budget

3 complete plugins: 7,900 tokens. Target: full pipeline under 15K. Plenty of room for the 5 planned plugins.

### What Was Done Today (session handoff)

1. **visual-vocabulary** created and published to Mall. Chart catalog by 7 communication goals, CSAR evaluation loop (from VT_AIPOWERBI), 5-visual rule, SVG dashboard patterns (from Supervisor fleet dashboard experience), living gallery references.

2. **storytelling-requirements** created. Guided brief template: audience, Big Idea sentence, questions mapped to communication goals, data sources, quality concerns, delivery target, constraints. Includes the CSAR check and pipeline integration diagram. Template file at `templates/STORYTELLING-REQUIREMENTS.md`.

3. **delivery-ascii-dashboard** created. Pure ASCII art dashboards: KPI strips, horizontal bars, sparklines, two-column layouts. No emojis (predictable 1-cell geometry). Positioned as the cheapest tier in the delivery hierarchy.

4. **Edition v0.9.9 installed.** 112 brain files, 33 instructions, 16 skills, 20 prompts, 3 agents. Full ACT cognitive machinery.

5. **Maintainer identity written** in `copilot-instructions.local.md`. 4-gate plugin review, Mall promotion workflow, version management, sibling repo awareness.

6. **Audit completed.** Token costs corrected (were inflated 25-80%), synced to Mall. Zero lint errors. Git clean.

## Next Steps (pick up here)

### Immediate: Promote 2 Ready Plugins

1. **Promote `storytelling-requirements` to Mall**:

   ```bash
   # Copy to Mall
   cp -r plugins/storytelling-requirements/ ../Alex_ACT_Plugin_Mall/plugins/data-analytics/storytelling-requirements/
   # Update CATALOG.json: add entry, bump plugin_count 279->280, data-analytics count 18->19
   # Update Mall README.md counts
   # Commit: "feat: add storytelling-requirements from Visual Storytelling factory"
   ```

2. **Promote `delivery-ascii-dashboard` to Mall**:

   Same process. Category: `data-analytics`. plugin_count 280->281, data-analytics 19->20.

### Short-term: Build Phase 1 Plugins

1. **`data-preparation`** -- Data cleaning, profiling, quality gates. Source knowledge: VT_AIPOWERBI's data-prep-for-AI guidance, general data wrangling patterns. Keep under 500 lines.

2. **`datasource-connectors`** -- CSV, JSON, API, SQL, Excel, Parquet ingestion. Focus on the patterns an LLM needs to guide a user through data loading. Not a library; a decision framework.

### Medium-term: Build Phase 2 Delivery Targets

1. **`delivery-svg-markdown`** -- Absorb and extend `svg-dashboard-composition` from the Mall. Add the panel primitive, coordinate rules, and dark-slate palette learned from the Supervisor's fleet dashboard.

2. **`delivery-html-dashboard`** -- Self-contained HTML + Chart.js. Absorb `dashboard-design` patterns from the Mall. KPI cards, responsive grid, embedded data, print-friendly.

### Later: Phase 3 Enterprise

1. **`delivery-powerbi-fabric`** -- Absorb VT_AIPOWERBI domain knowledge: AI visuals, semantic models, Copilot-ready data prep, Fabric integration.

## Source Knowledge

| Source | Path | What to Extract |
| --- | --- | --- |
| VT_AIPOWERBI course | `C:\Development\VT_AIPOWERBI` | CSAR loop, 5-visual rule, AI visuals, data prep for Copilot, Kirk/Knaflic frameworks |
| Supervisor fleet dashboard | `C:\Development\Alex_ACT_Supervisor\fleet\` | SVG panel primitives, coordinate anti-patterns, dark-slate palette, pie/bar sizing |
| Mall existing plugins | `C:\Development\Alex_ACT_Plugin_Mall\plugins\data-analytics\` | `data-visualization`, `data-storytelling`, `dashboard-design`, `svg-dashboard-composition` -- complement, don't duplicate |
| FT Visual Vocabulary | [ft-interactive.github.io/visual-vocabulary](https://ft-interactive.github.io/visual-vocabulary/) | Living chart catalog by communication goal |
| From Data to Viz | [data-to-viz.com](https://www.data-to-viz.com/) | Chart selection by data type |

## How to Work

### Developing a Plugin

1. Write SKILL.md in `plugins/<name>/` (under 500 lines, behavioral not encyclopedic)
2. Write plugin.json (use existing ones as templates; set token_cost = chars/4 rounded to nearest 100)
3. Write README.md (concise: what, when, install, pipeline position)
4. Test against datasets in `datasets/` (add test data if needed)
5. Run 4-gate review (spec, quality, scope, safety)

### Promoting to Mall

1. Copy folder to `../Alex_ACT_Plugin_Mall/plugins/<category>/<name>/`
2. Add CATALOG.json entry (increment counts)
3. Update Mall README.md counts
4. Commit and push to Mall
5. Update PLAN.md status in this repo

### Upgrading Edition

```bash
node .github/scripts/upgrade-self.cjs        # dry-run first
node .github/scripts/upgrade-self.cjs --apply # then apply
```

## Key Files

| File | Purpose |
| --- | --- |
| `PLAN.md` | Full roadmap, plugin inventory, success criteria, architecture diagram |
| `.github/copilot-instructions.local.md` | Your maintainer identity and capabilities |
| `templates/STORYTELLING-REQUIREMENTS.md` | The blank brief users copy into their projects |
| `.github/.act-heir.json` | Fleet marker (Edition v0.9.9, heir ID, timestamps) |

## Guiding Principles

1. **DRY/KISS.** Each plugin does one thing. If description contains "and", split it.
2. **Selection is universal; delivery is swappable.** Chart selection and storytelling are platform-agnostic.
3. **Requirements first.** No chart without a Big Idea sentence.
4. **Living references over static knowledge.** Link to galleries; encode judgment in plugins.
5. **Complement the Mall, don't duplicate it.** Cross-reference existing plugins; fill gaps.
6. **Test before promoting.** A plugin that only works on the example dataset is not ready.
