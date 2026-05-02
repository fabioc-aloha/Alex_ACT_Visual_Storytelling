# delivery-svg-markdown

SVG dashboard composition for Markdown and GitHub.

**Status**: Planned (Phase 2)

## Scope

- Panel primitives (card, KPI, chart container) with shared coordinate system
- ViewBox math and fragment stacking
- Dark-slate and light-theme palettes
- Pie, bar, line, and area chart SVG generation
- Text wrapping, vertical centering, responsive scaling
- Banner integration (pastel or dark-slate headers)
- Footer stats row with mixed-weight tspan
- GitHub Markdown embedding patterns

Will absorb and extend `svg-dashboard-composition` from the Mall.

## Pipeline Position

Final step. Fires after `visual-vocabulary` selects chart types.
