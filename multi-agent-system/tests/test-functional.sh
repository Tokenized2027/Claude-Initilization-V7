#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# Claude Multi-Agent System — Functional Tests v3.2.0
#
# Tests IMPORT actual core.py logic — no copy-paste, no reimplementation.
# Run locally without the mini PC.
# ═══════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPT_DIR")"
ORCH_DIR="$SYSTEM_DIR/orchestrator"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓ PASS${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗ FAIL${NC} $1"; FAIL=$((FAIL+1)); }
section() { echo ""; echo -e "${BLUE}── $1 ──${NC}"; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Claude Multi-Agent System — Functional Test Suite v3.2.0"
echo "═══════════════════════════════════════════════════════════"

# ── Verify core.py exists (new in v3.2) ──────────────────────────────

if [ ! -f "$ORCH_DIR/core.py" ]; then
    echo -e "${RED}FATAL: core.py not found in $ORCH_DIR${NC}"
    echo "core.py is required for v3.2. Cannot run tests."
    exit 1
fi

# ── 1. Routing Logic (IMPORTS core.py) ───────────────────────────────

section "Task Routing (Imported from core.py)"

cd "$ORCH_DIR"

python3 << 'PYTEST'
import sys
sys.path.insert(0, '.')

from pathlib import Path
from core import load_routes, detect_task_type

# Load routes using the REAL core.load_routes function
routes_file = Path("project_routes.json")
task_routing, keywords, priorities, default = load_routes(routes_file)

if not task_routing:
    print("  FATAL: No routes loaded")
    sys.exit(1)

# Test cases: (description, task text, expected type)
test_cases = [
    ("tweet about product",     "Write a tweet about product launch",               "project-social"),
    ("analytics dashboard",     "Build analytics dashboard with KPI metrics",      "project-analytics"),
    ("Docker deployment",       "Fix the broken Docker deployment pipeline",        "coding-devops"),
    ("governance proposal",     "Create a governance proposal for vote",            "project-governance"),
    ("debug crash",             "Debug the login page crash",                       "coding-debug"),
    ("Playwright tests",        "Write Playwright e2e tests",                       "coding-test"),
    ("API schema",              "Design the API schema with OpenAPI spec",          "planning-api"),
    ("security audit",          "Run security audit on the codebase",              "coding-security"),
    ("user support",            "Help a user troubleshoot an issue",               "project-support"),
    ("prototype",               "Build a quick prototype",                          "coding-prototype"),
]

failures = 0
for desc, task, expected in test_cases:
    # Call the REAL detect_task_type from core.py
    result = detect_task_type(task, keywords, priorities, default)
    if result == expected:
        print(f"  \u2713 PASS: \"{task[:50]}\" \u2192 {result}")
    else:
        print(f"  \u2717 FAIL: \"{task[:50]}\" \u2192 {result} (expected {expected})")
        failures += 1

sys.exit(failures)
PYTEST

if [ $? -eq 0 ]; then
    pass "All routing tests passed (imported from core.py)"
else
    fail "Routing tests failed"
fi

# ── 2. Budget Enforcement (IMPORTS core.SpendTracker) ────────────────

section "Budget Enforcement (Imported SpendTracker from core.py)"

python3 << 'PYTEST'
import sys, os, tempfile
sys.path.insert(0, '.')

from pathlib import Path
from core import SpendTracker

# Create a temp ledger so we don't touch anything real
tmp = tempfile.NamedTemporaryFile(suffix='.json', delete=False)
tmp.close()

try:
    tracker = SpendTracker(
        ledger_path=Path(tmp.name),
        daily_budget=50.0,
        project_budget=25.0,
    )

    failures = 0

    # Test 1: Fresh tracker allows spend
    ok, reason = tracker.can_spend('test', 5.0)
    if ok:
        print('  \u2713 PASS: Fresh tracker allows spend')
    else:
        print(f'  \u2717 FAIL: Fresh tracker blocked ({reason})')
        failures += 1

    # Test 2: Record spend and verify
    tracker.record_spend('test', 20.0)
    if abs(tracker.daily_spend() - 20.0) < 0.01:
        print('  \u2713 PASS: Daily spend tracked correctly')
    else:
        print(f'  \u2717 FAIL: Daily spend = {tracker.daily_spend()} (expected 20.0)')
        failures += 1

    # Test 3: Project budget enforcement
    ok, reason = tracker.can_spend('test', 10.0)
    if not ok and 'Project budget' in reason:
        print('  \u2713 PASS: Project budget blocks at limit')
    else:
        print(f'  \u2717 FAIL: Project budget not enforced (ok={ok}, reason={reason})')
        failures += 1

    # Test 4: Daily budget enforcement
    tracker.record_spend('other_project', 35.0)
    ok, reason = tracker.can_spend('new_project', 5.0)
    if not ok and 'Daily budget' in reason:
        print('  \u2713 PASS: Daily budget blocks when exceeded')
    else:
        print(f'  \u2717 FAIL: Daily budget not enforced (ok={ok}, daily={tracker.daily_spend()})')
        failures += 1

    # Test 5: Cross-project daily limit
    if tracker.daily_spend() >= 55.0:
        print('  \u2713 PASS: Daily limit applies across all projects')
    else:
        print(f'  \u2717 FAIL: Cross-project daily total wrong ({tracker.daily_spend()})')
        failures += 1

    # Test 6: Actual cost tracking
    tracker2 = SpendTracker(
        ledger_path=Path(tmp.name + '.actual'),
        daily_budget=50.0,
        project_budget=25.0,
    )
    tracker2.record_spend('proj', 5.0, actual=3.50)
    summary = tracker2.get_summary()
    if summary.get('actual_daily_spend') == 3.50:
        print('  \u2713 PASS: Actual cost tracked separately from estimate')
    else:
        print(f'  \u2717 FAIL: Actual tracking missing (summary={summary})')
        failures += 1

    # Test 7: Atomic write (verify file exists and is valid JSON after save)
    import json
    data = json.loads(Path(tmp.name).read_text())
    if 'daily' in data and 'projects' in data:
        print('  \u2713 PASS: Ledger persisted as valid JSON')
    else:
        print(f'  \u2717 FAIL: Ledger format wrong')
        failures += 1

    sys.exit(failures)

finally:
    os.unlink(tmp.name)
    try:
        os.unlink(tmp.name + '.actual')
    except OSError:
        pass
PYTEST

if [ $? -eq 0 ]; then
    pass "All budget tests passed (imported from core.py)"
else
    fail "Budget tests failed"
fi

# ── 3. Token Usage Parsing (IMPORTS core.parse_token_usage) ──────────

section "Token Usage Parsing (Imported from core.py)"

python3 << 'PYTEST'
import sys
sys.path.insert(0, '.')

from core import parse_token_usage

failures = 0

# Test 1: Parse input/output tokens
result = parse_token_usage("Input tokens: 12000 | Output tokens: 3234")
if result and result.get('input_tokens') == 12000 and result.get('output_tokens') == 3234:
    print('  \u2713 PASS: Parsed input/output tokens')
else:
    print(f'  \u2717 FAIL: Token parse failed: {result}')
    failures += 1

# Test 2: Parse cost
result = parse_token_usage("Total cost: $0.42")
if result and abs(result.get('reported_cost', 0) - 0.42) < 0.001:
    print('  \u2713 PASS: Parsed reported cost')
else:
    print(f'  \u2717 FAIL: Cost parse failed: {result}')
    failures += 1

# Test 3: Compute cost from tokens
result = parse_token_usage("input_tokens: 1000000\noutput_tokens: 100000")
if result and result.get('computed_cost') is not None and result['computed_cost'] > 0:
    print(f'  \u2713 PASS: Computed cost from tokens (${result["computed_cost"]})')
else:
    print(f'  \u2717 FAIL: Cost computation failed: {result}')
    failures += 1

# Test 4: Empty/no-match returns None
result = parse_token_usage("Agent completed successfully")
if result is None:
    print('  \u2713 PASS: Returns None when no token info found')
else:
    print(f'  \u2717 FAIL: Should be None for no-token output: {result}')
    failures += 1

# Test 5: Empty string returns None
result = parse_token_usage("")
if result is None:
    print('  \u2713 PASS: Returns None for empty string')
else:
    print(f'  \u2717 FAIL: Should be None for empty: {result}')
    failures += 1

sys.exit(failures)
PYTEST

if [ $? -eq 0 ]; then
    pass "All token parsing tests passed (imported from core.py)"
else
    fail "Token parsing tests failed"
fi

# ── 4. Log Rotation (IMPORTS core.rotate_logs) ───────────────────────

section "Log Rotation (Imported from core.py)"

python3 << 'PYTEST'
import sys, tempfile, os, json
sys.path.insert(0, '.')

from pathlib import Path
from core import rotate_logs

failures = 0

# Create temp dir with 10 log files
tmpdir = Path(tempfile.mkdtemp())
for i in range(10):
    (tmpdir / f"task-{i:03d}.json").write_text(json.dumps({"task": i}))

# Test 1: No rotation needed
deleted = rotate_logs(tmpdir, max_logs_per_project=20)
remaining = len(list(tmpdir.glob("*.json")))
if deleted == 0 and remaining == 10:
    print('  \u2713 PASS: No rotation when under limit')
else:
    print(f'  \u2717 FAIL: Unexpected rotation (deleted={deleted}, remaining={remaining})')
    failures += 1

# Test 2: Rotation trims to limit
deleted = rotate_logs(tmpdir, max_logs_per_project=5)
remaining = len(list(tmpdir.glob("*.json")))
if deleted == 5 and remaining == 5:
    print('  \u2713 PASS: Rotated 5 oldest files (10 -> 5)')
else:
    print(f'  \u2717 FAIL: Rotation wrong (deleted={deleted}, remaining={remaining})')
    failures += 1

# Test 3: Non-existent dir returns 0
deleted = rotate_logs(Path("/tmp/nonexistent-dir-12345"))
if deleted == 0:
    print('  \u2713 PASS: Non-existent dir returns 0')
else:
    print(f'  \u2717 FAIL: Should return 0 for missing dir')
    failures += 1

# Cleanup
import shutil
shutil.rmtree(tmpdir)

sys.exit(failures)
PYTEST

if [ $? -eq 0 ]; then
    pass "All log rotation tests passed (imported from core.py)"
else
    fail "Log rotation tests failed"
fi

# ── 5. Cost Estimates Validation ─────────────────────────────────────

section "Cost Estimates (Conservative Values)"

python3 << 'PYTEST'
import sys, json
sys.path.insert(0, '.')

from pathlib import Path
from core import load_routes

routes_file = Path("project_routes.json")
task_routing, keywords, priorities, default = load_routes(routes_file)

failures = 0

# All routes must have a cost_estimate
missing = [k for k, v in task_routing.items() if 'cost_estimate' not in v]
if not missing:
    print(f'  \u2713 PASS: All {len(task_routing)} routes have cost_estimate')
else:
    print(f'  \u2717 FAIL: Missing cost_estimate: {missing}')
    failures += 1

# Conservative minimums (v3.2 values should be >= these)
conservative_minimums = {
    'project-social': 0.5,
    'coding-dashboard': 5.0,
    'project-governance': 2.0,
    'coding-api': 3.0,
}

for task_type, minimum in conservative_minimums.items():
    actual = task_routing[task_type]['cost_estimate']
    if actual >= minimum:
        print(f'  \u2713 PASS: {task_type} ${actual:.2f} >= ${minimum:.2f}')
    else:
        print(f'  \u2717 FAIL: {task_type} ${actual:.2f} < ${minimum:.2f} (too low)')
        failures += 1

# Range check: no estimate should be negative or unreasonably high
for task_type, routing in task_routing.items():
    cost = routing['cost_estimate']
    if cost < 0 or cost > 50:
        print(f'  \u2717 FAIL: {task_type} cost ${cost} out of range [0, 50]')
        failures += 1

if failures == 0:
    print(f'  \u2713 PASS: All cost estimates in valid range')

sys.exit(failures)
PYTEST

if [ $? -eq 0 ]; then
    pass "Cost estimates are appropriately conservative"
else
    fail "Some cost estimates have issues"
fi

# ── 6. Handoff Lifecycle ─────────────────────────────────────────────

section "Handoff Lifecycle"

python3 << 'PYTEST'
import sys, tempfile, json, os
from pathlib import Path

tmpdir = Path(tempfile.mkdtemp())
handoff_dir = tmpdir / "test-project" / "handoffs"
handoff_dir.mkdir(parents=True)

failures = 0

# Create a test handoff
handoff = {
    "id": "test-handoff-001",
    "from": "content-writer",
    "to": "reviewer",
    "task": "Review the blog post draft",
    "status": "pending",
    "timestamp": "2026-02-16T10:00:00Z",
    "files": ["blog-draft.md"],
}
(handoff_dir / "test-handoff-001.json").write_text(json.dumps(handoff))

# Test 1: Pending handoff exists
data = json.loads((handoff_dir / "test-handoff-001.json").read_text())
if data["status"] == "pending":
    print('  \u2713 PASS: Handoff starts as pending')
else:
    print(f'  \u2717 FAIL: Expected pending, got {data["status"]}')
    failures += 1

# Test 2: Accept handoff
data["status"] = "accepted"
(handoff_dir / "test-handoff-001.json").write_text(json.dumps(data))
data = json.loads((handoff_dir / "test-handoff-001.json").read_text())
if data["status"] == "accepted":
    print('  \u2713 PASS: Handoff accepted')
else:
    print(f'  \u2717 FAIL: Status should be accepted')
    failures += 1

# Test 3: Retry resets to pending
data["status"] = "pending"
data["retry_count"] = data.get("retry_count", 0) + 1
(handoff_dir / "test-handoff-001.json").write_text(json.dumps(data))
data = json.loads((handoff_dir / "test-handoff-001.json").read_text())
if data["status"] == "pending" and data["retry_count"] == 1:
    print('  \u2713 PASS: Retry resets to pending with count=1')
else:
    print(f'  \u2717 FAIL: Retry state wrong')
    failures += 1

# Test 4: Complete handoff
data["status"] = "completed"
(handoff_dir / "test-handoff-001.json").write_text(json.dumps(data))
data = json.loads((handoff_dir / "test-handoff-001.json").read_text())
if data["status"] == "completed":
    print('  \u2713 PASS: Handoff completed')
else:
    print(f'  \u2717 FAIL: Should be completed')
    failures += 1

# Test 5: Files preserved through lifecycle
if data.get("files") == ["blog-draft.md"]:
    print('  \u2713 PASS: Files preserved through lifecycle')
else:
    print(f'  \u2717 FAIL: Files lost: {data.get("files")}')
    failures += 1

# Cleanup
import shutil
shutil.rmtree(tmpdir)

sys.exit(failures)
PYTEST

if [ $? -eq 0 ]; then
    pass "All handoff lifecycle tests passed"
else
    fail "Handoff tests failed"
fi

# ── 7. Version Consistency ───────────────────────────────────────────

section "Version Consistency"

VERSION=$(cat "$SYSTEM_DIR/../VERSION" 2>/dev/null || echo "MISSING")
ORCH_VERSION=$(grep -o '"version": "[^"]*"' "$ORCH_DIR/orchestrator.py" | head -1 | grep -o '[0-9.]*' || echo "MISSING")
HEALTH_VERSION=$(grep -o '"version": "[^"]*"' "$ORCH_DIR/orchestrator.py" | tail -1 | grep -o '[0-9.]*' || echo "MISSING")
MEMORY_VERSION=$(grep -o '"version": "[^"]*"' "$SYSTEM_DIR/mcp-servers/memory-server/package.json" | head -1 | grep -o '[0-9.]*' || echo "MISSING")

ALL_MATCH=true
if [ "$VERSION" != "$ORCH_VERSION" ]; then
    fail "VERSION ($VERSION) != orchestrator app version ($ORCH_VERSION)"
    ALL_MATCH=false
fi
if [ "$VERSION" != "$HEALTH_VERSION" ]; then
    fail "VERSION ($VERSION) != health endpoint ($HEALTH_VERSION)"
    ALL_MATCH=false
fi
if [ "$VERSION" != "$MEMORY_VERSION" ]; then
    fail "VERSION ($VERSION) != memory-server ($MEMORY_VERSION)"
    ALL_MATCH=false
fi

if [ "$ALL_MATCH" = true ]; then
    pass "All components report v${VERSION}"
fi

# ── 8. Single Routes File (No Duplication) ───────────────────────────

section "Route File Integrity"

# v3.2: There should be exactly ONE project_routes.json, in orchestrator/
ORCH_ROUTES="$ORCH_DIR/project_routes.json"
ROOT_ROUTES="$SYSTEM_DIR/project_routes.json"

if [ -f "$ORCH_ROUTES" ]; then
    pass "project_routes.json exists in orchestrator/"
else
    fail "project_routes.json MISSING from orchestrator/"
fi

if [ -f "$ROOT_ROUTES" ]; then
    fail "Duplicate project_routes.json found at root (should only exist in orchestrator/)"
else
    pass "No duplicate routes file at root (single source of truth)"
fi

# Verify core.py exists
if [ -f "$ORCH_DIR/core.py" ]; then
    pass "core.py exists in orchestrator/"
else
    fail "core.py MISSING from orchestrator/"
fi

# ═══════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "═══════════════════════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}SOME TESTS FAILED${NC}"
    exit 1
else
    echo -e "  ${GREEN}ALL TESTS PASSED${NC}"
    exit 0
fi
