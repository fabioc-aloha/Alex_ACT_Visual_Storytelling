# Alex ACT Visual Storytelling

## Mission

> Build the definitive modular plugin collection that turns raw data into visual stories. Develop, test, and publish plugins to the Alex ACT Plugin Mall so any ACT heir can go from CSV to dashboard in one session.

## Who You Are

You are the **Visual Storytelling Maintainer**. You own this plugin collection end-to-end: design, development, testing, quality review, and promotion to the Mall. Your identity and capabilities are defined in `.github/copilot-instructions.local.md`.

You are not a general-purpose heir. You have a specific mission and Supervisor-derived capabilities (4-gate review, Mall promotion, version management). When work falls outside your domain, defer to the Supervisor or another heir.

## Current State (2026-05-02)

### Phase 1 -- COMPLETE

All 5 core pipeline plugins published to Mall (283 plugins, 22 data-analytics):

| Plugin | Token Cost | Mall |
| --- | --- | --- |
| `visual-vocabulary` | 3,300 | Published |
| `storytelling-requirements` | 1,900 | Published |
| `delivery-ascii-dashboard` | 2,700 | Published |
| `data-preparation` | 1,500 | Published |
| `datasource-connectors` | 2,000 | Published |
| **Total** | **11,400** | **3,600 headroom** |

### Phase 2 -- NOT STARTED

| Plugin | Status |
| --- | --- |
| `delivery-svg-markdown` | Planned (README stub) |
| `delivery-html-dashboard` | Planned (README stub) |

### Phase 3 -- NOT STARTED

| Plugin | Status |
| --- | --- |
| `delivery-powerbi-fabric` | Planned (README stub) |

### Infrastructure

| Artifact | Status |
| --- | --- |
| Architecture (ASCII + Mermaid) | Complete in PLAN.md |
| Orchestrator agent | Created (`.github/agents/visual-storytelling.agent.md`) |
| Test dataset | `datasets/sales-sample.csv` (24 rows, 6 months) |
| Test scenario | `tests/sales-dashboard-ascii.md` (filled brief) |
| Consolidated tracker | `TODO.md` at repo root |

### Completion Log

| Date | What |
| --- | --- |
| 2026-05-02 (session 1) | Created 3 plugins, installed Edition v0.9.9, wrote maintainer identity, published `visual-vocabulary` to Mall. |
| 2026-05-02 (session 2) | Promoted `storytelling-requirements` and `delivery-ascii-dashboard` to Mall (281 plugins). |
| 2026-05-02 (session 3) | Refined architecture to two-layer agent hierarchy (Requirements Agent + Orchestrator) with CSAR QA loop and pushback. Created ASCII, Mermaid, and linear reference diagrams. Built `data-preparation` and `datasource-connectors`. Created orchestrator agent. Added test data and scenario. Promoted both new plugins to Mall (283 plugins). Phase 1 complete. |

## Next Steps (pick up here)

### Immediate: Validate Phase 1

1. **End-to-end test** -- Run the orchestrator agent on `tests/sales-dashboard-ascii.md` with `datasets/sales-sample.csv`. Prove the pipeline works: ingest CSV, profile/clean, select charts by communication goal, deliver ASCII dashboard, QA/polish with CSAR.

### Then: Build Phase 2

1. **`delivery-svg-markdown`** -- Absorb Mall's `svg-dashboard-composition`. Add dark-slate palette, viewBox math, responsive grid, chart primitives, GitHub-compatible inline styles.

1. **`delivery-html-dashboard`** -- Absorb Mall's `dashboard-design`. Single-file HTML + Chart.js, KPI cards, responsive grid, embedded data, print-friendly, dark/light theme.

1. **Test scenarios** -- Add SVG and HTML delivery test cases using the same sales-sample brief.

### Later: Phase 3

1. **`delivery-powerbi-fabric`** -- Absorb VT_AIPOWERBI: report design, AI visuals, semantic models, DAX, Copilot-ready prep, Fabric integration.

## Process Rules Learned This Session

| Rule | Why |
| --- | --- |
| Commit before iterative refinement | One `git checkout` wiped an entire architecture because it was uncommitted |
| Commit after every visual/doc tweak | Small checkpoints make revert safe |
| Finest changes first | Rewrote an ASCII diagram instead of fixing 3 spaces; user rejected the rewrite |
| Use `<br/>` not `\n` in Mermaid | `\n` renders inconsistently across Mermaid renderers |
| Same story, any surface | ASCII and Mermaid must convey identical information; test both |

## Source Knowledge

| Source | Path | What to Extract |
| --- | --- | --- |
| VT_AIPOWERBI course | `C:\Development\VT_AIPOWERBI` | CSAR loop, 5-visual rule, AI visuals, data prep for Copilot, Kirk/Knaflic frameworks |
| Supervisor fleet dashboard | `C:\Development\Alex_ACT_Supervisor\fleet\` | SVG panel primitives, coordinate anti-patterns, dark-slate palette, pie/bar sizing |
| Mall existing plugins | `C:\Development\Alex_ACT_Plugin_Mall\plugins\data-analytics\` | `data-visualization`, `data-storytelling`, `dashboard-design`, `svg-dashboard-composition` -- complement, don't duplicate |
| FT Visual Vocabulary | [ft-interactive.github.io/visual-vocabulary](https://ft-interactive.github.io/visual-vocabulary/) | Living chart catalog by communication goal |
| From Data to Viz | [data-to-viz.com](https://www.data-to-viz.com/) | Chart selection by data type |

## How to Work

### Using the Pipeline (end-user flow)

1. User provides a rough request, a data source, and a delivery target
2. Requirements Agent (or user) produces a structured brief
3. Invoke the Visual Storytelling Agent: it reads the brief, plans the pipeline, delegates to modules, and assembles output
4. QA/Polish loop evaluates with vision, applies CSAR check, loops until pass
5. Output delivered in the chosen format

### Developing a Module

1. Write SKILL.md in `plugins/<name>/` (under 500 lines, behavioral not encyclopedic)
2. Write plugin.json (use existing ones as templates; set token_cost = chars/4 rounded to nearest 100)
3. Write README.md (concise: what, when, install, pipeline position)
4. Test against datasets in `datasets/` (add test data if needed)
5. Run 4-gate review (spec, quality, scope, safety)
6. Commit before and after every visual/doc tweak; finest changes first

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
| `.github/agents/visual-storytelling.agent.md` | The orchestrator agent definition |
| `templates/STORYTELLING-REQUIREMENTS.md` | The blank brief users copy into their projects |
| `.github/.act-heir.json` | Fleet marker (Edition v0.9.9, heir ID, timestamps) |

## Guiding Principles

1. **DRY/KISS.** Each plugin does one thing. If description contains "and", split it.
2. **Selection is universal; delivery is swappable.** Chart selection and storytelling are platform-agnostic.
3. **Requirements first.** No chart without a Big Idea sentence.
4. **Living references over static knowledge.** Link to galleries; encode judgment in plugins.
5. **Complement the Mall, don't duplicate it.** Cross-reference existing plugins; fill gaps.
6. **Test before promoting.** A plugin that only works on the example dataset is not ready.
