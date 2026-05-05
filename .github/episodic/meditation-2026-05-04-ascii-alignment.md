# Meditation: ASCII Alignment and SA Trust Boundaries

**Date**: 2026-05-04
**Session focus**: Hardening the ASCII dashboard delivery pipeline
**Duration**: Extended (multi-hour, iterative problem solving)

## What We Accomplished

- Fixed misaligned ASCII dashboard (lines at 77-81 chars, target 78)
- Added Module 5 (Alignment QA Loop) to `plugins/delivery-ascii-dashboard/SKILL.md`
- Updated orchestrator agent with ASCII Alignment Gate
- Discovered fundamental limitation: SAs cannot self-validate character alignment
- Established working architecture: SA returns structured JSON, caller renders programmatically
- Built `build-complex-dashboard.ps1` as reference implementation
- Passed complex 5-visual test (KPI strip, trend, side-by-side panels, concentration bars)

## Patterns Extracted

1. **Character-counting is not an LLM capability** -- persisted to repo memory. Three attempts with increasingly explicit instructions all failed. Not a prompt engineering problem.

2. **Split analytical vs mechanical work** -- the SA excels at chart selection, data aggregation, layout decisions, storytelling. The caller excels at pixel-perfect rendering via script. Let each do what they're good at.

3. **Validation gates belong to the caller** -- self-reported QA from a subagent is not trustworthy for mechanical properties (alignment, encoding, file integrity). The caller must verify.

## Lessons Learned

| Lesson | Evidence | Implication |
| --- | --- | --- |
| SAs lie about validation | Agent said "ALL LINES OK" while producing 80-char lines | Never trust SA self-report for mechanical checks |
| SAs may not have tool access | Agent said "terminal tools weren't available" despite tools being listed | Subagent tool availability is environment-dependent |
| PadRight() is the fix | Every script-generated dashboard passed on first run | Construction functions prevent alignment bugs at source |
| 78 vs 80 is the #1 confusion | Agent defaulted to 80 in all three attempts | The skill must explicitly warn "78, NOT 80" (done) |
| PowerShell arrays need care | Nested arrays and function call syntax caused failures | Use ArrayList or comma-prefix; space-separated calls |

## Architectural Decision

**ADR: ASCII rendering is a caller responsibility, not a subagent responsibility.**

- Context: SAs produce misaligned output 100% of the time for character-counted formats
- Decision: SA returns structured data (JSON plan); caller renders via padded script
- Consequences: More code in the caller session, but guaranteed-correct output
- Status: Implemented and tested

## Open Questions

- Can the SA reliably use `run_in_terminal` in other environments? (May be VS Code agent limitation)
- Should we formalize the JSON schema for dashboard plans as a contract?
- Would a muscle script (`.github/muscles/build-ascii-dashboard.cjs`) be better than ad-hoc PowerShell?

## Session Handoff

### State

- **Completed**: Phase 1 (all plugins, orchestrator, end-to-end test passing)
- **In progress**: ASCII alignment hardening (done this session)
- **Next action**: Phase 2 planning (SVG/HTML delivery plugins)

### Context to reload

- `plugins/delivery-ascii-dashboard/SKILL.md` -- Module 5 has the QA rules
- `.github/agents/visual-storytelling.agent.md` -- ASCII Alignment Gate section
- `build-complex-dashboard.ps1` -- reference implementation of programmatic construction
- `tests/sales-dashboard-ascii-output.md` -- verified 5-visual complex output
- `TODO.md` -- Phase 1 complete, Phase 2 next
