# Changelog

All notable changes to Visual Storytelling are documented here.

## [2.0.1] - 2026-08-15

### Fixed

- Make Mall publication retire obsolete standalone SVG and HTML delivery records
  atomically, with rollback and parity checks.

## [2.0.0] - 2026-08-15

### Changed

- Retained requirements, ingestion, preparation, narrative orchestration, and
  ASCII delivery as Visual Storytelling's owned pipeline.
- Moved chart selection and graphical delivery to
  `alex-act-illustrator-plugin`, making that dependency explicit for `svg` and
  `html` targets.
- Replaced legacy Edition and local-install metadata with current Mall-oriented
  contracts and an immutable release-tag publisher.

### Removed

- Retired the duplicate `visual-vocabulary`, SVG delivery, HTML delivery, and
  stale repository-local orchestrator from the active v2 surface.

### Fixed

- Added source-tag and retired-artifact checks so source-to-Mall publication
  cannot silently preserve the legacy bundle shape.
