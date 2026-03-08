#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# Orchestrator API Test Suite
# Run while orchestrator is running: http://localhost:8000
#
# Usage:
#   ./test-orchestrator-api.sh                    # uses ORCHESTRATOR_API_KEY env var
#   ORCHESTRATOR_API_KEY=mykey ./test-orchestrator-api.sh
#   ./test-orchestrator-api.sh --key mykey
# ═══════════════════════════════════════════════════════════════════════

BASE="http://localhost:8000"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'
PASS=0
FAIL=0

# Parse --key argument
while [[ $# -gt 0 ]]; do
    case $1 in
        --key) ORCHESTRATOR_API_KEY="$2"; shift 2 ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
    esac
done

# Build auth header if key is set
AUTH_HEADER=""
if [ -n "${ORCHESTRATOR_API_KEY:-}" ]; then
    AUTH_HEADER="-H \"X-API-Key: $ORCHESTRATOR_API_KEY\""
    echo -e "${YELLOW}Using API key authentication${NC}"
else
    echo -e "${YELLOW}WARNING: No ORCHESTRATOR_API_KEY set. Tests may fail with 401.${NC}"
    echo -e "${YELLOW}Set it with: export ORCHESTRATOR_API_KEY=your_key${NC}"
fi

# Helper: curl with optional auth
authed_curl() {
    if [ -n "${ORCHESTRATOR_API_KEY:-}" ]; then
        curl -s -o /dev/null -w "%{http_code}" -H "X-API-Key: $ORCHESTRATOR_API_KEY" "$@"
    else
        curl -s -o /dev/null -w "%{http_code}" "$@"
    fi
}

check() {
    local desc="$1"
    local code="$2"
    local expected="$3"

    if [ "$code" = "$expected" ]; then
        echo -e "  ${GREEN}PASS${NC} $desc (HTTP $code)"
        PASS=$((PASS+1))
    else
        echo -e "  ${RED}FAIL${NC} $desc (expected $expected, got $code)"
        FAIL=$((FAIL+1))
    fi
}

echo ""
echo "── Orchestrator API Tests ──"
echo ""

# Health check (no auth needed)
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/health")
check "GET /health" "$CODE" "200"

# Test auth rejection (if key is configured)
if [ -n "${ORCHESTRATOR_API_KEY:-}" ]; then
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/projects")
    check "GET /projects without key → 401" "$CODE" "401"
fi

# List projects (empty is fine)
CODE=$(authed_curl "$BASE/projects")
check "GET /projects" "$CODE" "200"

# List running tasks
CODE=$(authed_curl "$BASE/tasks")
check "GET /tasks" "$CODE" "200"

# Get status for nonexistent project (should still work — returns default)
CODE=$(authed_curl "$BASE/status/nonexistent-project")
check "GET /status/nonexistent" "$CODE" "200"

# Get handoffs for nonexistent project
CODE=$(authed_curl "$BASE/handoffs/nonexistent-project")
check "GET /handoffs/nonexistent" "$CODE" "200"

# Submit a task (dry run — this will try to spawn claude, which may or may not work)
if [ -n "${ORCHESTRATOR_API_KEY:-}" ]; then
    CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/route" \
        -H "Content-Type: application/json" \
        -H "X-API-Key: $ORCHESTRATOR_API_KEY" \
        -d '{"task": "Test task - build hello world", "project": "api-test"}')
else
    CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE/route" \
        -H "Content-Type: application/json" \
        -d '{"task": "Test task - build hello world", "project": "api-test"}')
fi
check "POST /route" "$CODE" "200"

# Check task was created
sleep 1
CODE=$(authed_curl "$BASE/tasks")
check "GET /tasks (after route)" "$CODE" "200"

# Get project status (should exist now)
CODE=$(authed_curl "$BASE/status/api-test")
check "GET /status/api-test" "$CODE" "200"

echo ""
echo "── Results: $PASS passed, $FAIL failed ──"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
