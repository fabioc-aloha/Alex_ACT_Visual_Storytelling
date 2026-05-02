# datasource-connectors

Ingestion patterns for CSV, JSON, REST API, SQL, Excel, and Parquet.

**Status**: Planned (Phase 1)

## Scope

- CSV/TSV parsing with encoding detection, delimiter inference, header row handling
- JSON/JSONL ingestion with path extraction and flattening
- REST API pagination patterns (offset, cursor, link-header)
- SQL query templates with parameterized queries (no injection)
- Excel workbook reading with sheet selection and range extraction
- Parquet/Arrow columnar format reading
- Authentication patterns (API key, OAuth, connection string)
- Error handling and retry patterns

## Pipeline Position

Fires after `storytelling-requirements`, before `data-preparation`.
