# Claude V3.2.0 — Single Source of Truth

**Release Date:** February 16, 2026
**Upgrade from v3.1.x:** Drop-in replacement. Run `bash tests/test-functional.sh` to verify.

---

## Why V3.2

V3.1.1 shipped with three bugs that shared a common cause: code duplication.

1. **Route file desync (critical):** `project_routes.json` existed in two places. V3.1.1 updated the root copy with conservative cost estimates but left the orchestrator copy (the one actually read at runtime) at v3.1.0 values. All 19 routes were desynced. Same class of bug that v3.1.0 was supposed to fix.

2. **Tests that lied:** The changelog claimed "tests now import actual orchestrator code." The test file contained `"""EXACT copy of orchestrator detect_task_type logic"""` and `# We'll implement a test version that matches the real one`. Both SpendTracker and detect_task_type were reimplemented inside the test. The orchestrator couldn't be imported because module-level side effects (FastAPI, load_dotenv, directory creation) run on import.

3. **Stale version in health endpoint:** `/health` reported `"version": "3.1.0"` even in the v3.1.1 release.

V3.2 fixes all three by eliminating the duplication rather than trying to keep copies in sync.

---

## What Changed

### New file: `orchestrator/core.py`

Side-effect-free module containing all testable logic:

- `SpendTracker` — budget tracking with atomic writes and actual cost support
- `load_routes()` — parses `project_routes.json`
- `detect_task_type()` — keyword-weighted routing (pure function, takes args instead of globals)
- `parse_token_usage()` — extracts token counts and costs from Claude CLI stderr
- `rotate_logs()` — removes oldest log files when a project exceeds the limit

Both `orchestrator.py` and `test-functional.sh` import from `core.py`. No reimplementation.

### Single `project_routes.json`

One file, in `orchestrator/`. The root-level duplicate is gone. `install.sh` verifies presence instead of copying. A new test (`Route File Integrity`) fails if a duplicate reappears.

### Actual token usage tracking

Previously, the spend ledger recorded the pre-set estimate before the agent ran. A tweet estimated at $0.75 got recorded as $0.75 regardless of actual usage.

Now, `spawn_claude_agent()` parses Claude CLI stderr for token counts. When available, actual cost is recorded alongside the estimate. The `/spend` endpoint reports both:

```json
{
  "daily_spend_today": 12.50,
  "actual_daily_spend": 10.80,
  "actual_vs_estimated_ratio": 0.864
}
```

Budget enforcement still uses estimates (conservative, known before the agent runs). Actuals provide the feedback loop for tuning estimates with real data.

### Atomic ledger writes

`SpendTracker._save()` now writes to a temp file in the same directory, then calls `os.replace()` (atomic on POSIX). Previously, `write_text()` directly to the ledger file could leave it truncated or empty on power loss.

### Log rotation

`rotate_logs()` removes oldest log files when a project exceeds `MAX_LOGS_PER_PROJECT` (default: 200). Runs after each agent task. Configurable in `.env`.

---

## Test Suite

10 groups, all importing from `core.py`, all passing:

```
── Task Routing (Imported from core.py) ──
  10 routing scenarios                               ✓
── Budget Enforcement (Imported SpendTracker) ──
  7 tests (incl. actual cost tracking, persistence)  ✓
── Token Usage Parsing (Imported from core.py) ──
  5 tests (parse, compute, edge cases)               ✓
── Log Rotation (Imported from core.py) ──
  3 tests (no-op, trim, missing dir)                 ✓
── Cost Estimates (Conservative Values) ──
  6 tests (presence, minimums, range)                ✓
── Handoff Lifecycle ──
  5 tests (pending→accepted→retry→completed)         ✓
── Version Consistency ──
  All components report v3.2.0                       ✓
── Route File Integrity ──
  Single file, no duplicate, core.py present         ✓

Results: 10 passed, 0 failed
```

---

## Files Changed from V3.1.1

```
Added:
  orchestrator/core.py              — extracted core logic (no side effects)

Removed:
  multi-agent-system/project_routes.json  — duplicate eliminated
  RELEASE_NOTES_V3.1.1.md                — replaced by this file
  tests/test-functional.sh.v3.1           — old test backup

Modified:
  VERSION                                 — 3.2.0
  CHANGELOG.md                            — v3.2.0 entry
  orchestrator/orchestrator.py            — imports from core.py, token parsing, log rotation
  orchestrator/project_routes.json        — now the only copy (conservative estimates)
  orchestrator/.env.example               — added MAX_LOGS_PER_PROJECT
  mcp-servers/memory-server/package.json  — version 3.2.0
  deployment/install.sh                   — verify routes instead of copy
  tests/test-functional.sh                — rewritten, imports core.py
  tests/test-system.sh                    — updated error message
  docs/RUNBOOK.md                         — v3.2, actual cost fields
  docs/COST_ANALYSIS.md                   — note about v3.2 actual tracking
  BUILD_STATUS.md                         — version 3.2.0
```

---

## Upgrade Guide

**From v3.1.x → v3.2.0:**

1. Extract `Claude-V3.2.zip`
2. If you had manual edits to `multi-agent-system/project_routes.json` (the root copy), move them to `orchestrator/project_routes.json` — that's now the only file
3. Add `MAX_LOGS_PER_PROJECT=200` to `.env` (optional, has a sensible default)
4. Run `bash tests/test-functional.sh` → should see 10/10
5. Deploy as normal

**Breaking changes:** None. All API endpoints, .env variables, and agent behavior are unchanged.

---

## Week 1 With Actual Cost Data

With v3.2's token parsing, the Week 1 workflow changes from guesswork to measurement:

**Day 1-3:** Run tasks normally. Check `/spend` — if `actual_vs_estimated_ratio` appears, the feedback loop is working.

**Day 4-7:** Review the ratio. If it's consistently around 0.7 (estimates 30% too high), tune `project_routes.json` costs down. If it's above 1.0 (estimates too low), bump them up.

**Week 2:** Estimates should now be within ~15% of actuals. Increase budgets based on observed patterns, not guesses.

If `actual_daily_spend` never appears, Claude CLI may not be outputting token data to stderr in your version. The system degrades gracefully — estimated-only tracking continues to work exactly as in v3.1.x.
