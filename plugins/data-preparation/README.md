# data-preparation

Data cleaning, profiling, quality checks, aggregation, and pivot/unpivot guidance.

**Status**: Planned (Phase 1)

## Scope

- Data profiling checklist (types, nulls, cardinality, distributions)
- Cleaning recipes (deduplication, type coercion, null handling, outlier treatment)
- Aggregation patterns (group-by, rolling windows, percentiles)
- Pivot/unpivot guidance for reshaping data for visualization
- Quality gates (assertions that must pass before visualization)

## Pipeline Position

Fires after `datasource-connectors`, before `visual-vocabulary`.
