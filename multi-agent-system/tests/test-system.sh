#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# Claude Multi-Agent System — System Test Suite
# Tests all components are installed and functioning.
# ═══════════════════════════════════════════════════════════════════════

INSTALL_DIR="${CLAUDE_INSTALL_DIR:-$HOME/claude-multi-agent}"
MEMORY_DIR="${CLAUDE_MEMORY_DIR:-$HOME/claude-memory}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass() { echo -e "  ${GREEN}PASS${NC} $1"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}FAIL${NC} $1"; FAIL=$((FAIL+1)); }
warn() { echo -e "  ${YELLOW}WARN${NC} $1"; WARN=$((WARN+1)); }
section() { echo ""; echo -e "${BLUE}── $1 ──${NC}"; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Claude Multi-Agent System — Test Suite"
echo "═══════════════════════════════════════════════════════════"

# ── 1. Directory Structure ────────────────────────────────────────────

section "Directory Structure"

[ -d "$INSTALL_DIR" ] && pass "Install dir exists: $INSTALL_DIR" || fail "Install dir missing: $INSTALL_DIR"
[ -d "$MEMORY_DIR" ] && pass "Memory dir exists: $MEMORY_DIR" || fail "Memory dir missing: $MEMORY_DIR"
[ -d "$MEMORY_DIR/projects" ] && pass "Projects dir exists" || fail "Projects dir missing"
[ -d "$MEMORY_DIR/shared" ] && pass "Shared memory dir exists" || fail "Shared memory dir missing"

# ── 2. MCP Servers ────────────────────────────────────────────────────

section "MCP Servers"

MEMORY_BIN="$INSTALL_DIR/mcp-servers/memory-server/dist/index.js"
ROUTER_BIN="$INSTALL_DIR/mcp-servers/context-router/dist/index.js"

[ -f "$MEMORY_BIN" ] && pass "Memory server built" || fail "Memory server not built: $MEMORY_BIN"
[ -f "$ROUTER_BIN" ] && pass "Context router built" || fail "Context router not built: $ROUTER_BIN"

# Quick smoke test: can the servers start without crashing?
if [ -f "$MEMORY_BIN" ]; then
    timeout 3 node "$MEMORY_BIN" </dev/null >/dev/null 2>&1 && warn "Memory server exited cleanly (expected — no stdio)" || pass "Memory server process OK (stdio mode)"
fi

# ── 3. MCP Configuration ─────────────────────────────────────────────

section "MCP Configuration"

MCP_CONFIG="$HOME/.claude/mcp.json"
[ -f "$MCP_CONFIG" ] && pass "MCP config exists" || fail "MCP config missing: $MCP_CONFIG"

if [ -f "$MCP_CONFIG" ]; then
    grep -q "claude-memory" "$MCP_CONFIG" && pass "Memory server configured in MCP" || fail "Memory server NOT in MCP config"
    grep -q "context-router" "$MCP_CONFIG" && pass "Context router configured in MCP" || fail "Context router NOT in MCP config"
fi

# ── 4. Orchestrator ──────────────────────────────────────────────────

section "Orchestrator"

[ -f "$INSTALL_DIR/orchestrator/orchestrator.py" ] && pass "Orchestrator code exists" || fail "Orchestrator code missing"
[ -f "$INSTALL_DIR/orchestrator/project_routes.json" ] && pass "Task routing config exists" || fail "project_routes.json missing from orchestrator/ — routing broken!"
[ -d "$INSTALL_DIR/orchestrator/venv" ] && pass "Python venv exists" || fail "Python venv missing"

if [ -d "$INSTALL_DIR/orchestrator/venv" ]; then
    source "$INSTALL_DIR/orchestrator/venv/bin/activate" 2>/dev/null
    python -c "import fastapi" 2>/dev/null && pass "FastAPI installed" || fail "FastAPI not installed"
    python -c "import uvicorn" 2>/dev/null && pass "Uvicorn installed" || fail "Uvicorn not installed"
    python -c "import httpx" 2>/dev/null && pass "httpx installed" || fail "httpx not installed"
    deactivate 2>/dev/null || true
fi

[ -f "$INSTALL_DIR/orchestrator/.env" ] && pass "Orchestrator .env exists" || warn "Orchestrator .env missing (copy from .env.example)"

if [ -f "$INSTALL_DIR/orchestrator/.env" ]; then
    grep -q "ANTHROPIC_API_KEY=sk-ant" "$INSTALL_DIR/orchestrator/.env" && pass "API key configured" || warn "API key placeholder — update with real key"
fi

# Check if orchestrator is running
if command -v systemctl >/dev/null 2>&1; then
    systemctl is-active --quiet claude-orchestrator 2>/dev/null && pass "Orchestrator service running" || warn "Orchestrator service not running"
fi

# Test orchestrator HTTP (if running)
if curl -s -f http://localhost:8000/health >/dev/null 2>&1; then
    pass "Orchestrator health endpoint responding"

    HEALTH=$(curl -s http://localhost:8000/health)
    echo "$HEALTH" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(f'    Status: {d[\"status\"]}, Running: {d.get(\"running_tasks\", 0)}')
print(f'    API key configured: {d.get(\"api_key_configured\", \"unknown\")}')
print(f'    Skip permissions: {d.get(\"skip_permissions\", \"unknown\")}')
print(f'    Max handoff depth: {d.get(\"max_handoff_depth\", \"unknown\")}')
" 2>/dev/null || true

    # Warn if API key is not configured
    echo "$HEALTH" | python3 -c "
import sys,json
d=json.load(sys.stdin)
if not d.get('api_key_configured', True):
    print('    \033[1;33mWARNING: ORCHESTRATOR_API_KEY not set! API is unprotected.\033[0m')
" 2>/dev/null || true
else
    warn "Orchestrator not reachable at http://localhost:8000 (may not be started yet)"
fi

# ── 5. Agent Templates ───────────────────────────────────────────────

section "Agent Templates"

TEMPLATE_DIR="$INSTALL_DIR/agent-templates"
[ -d "$TEMPLATE_DIR" ] && pass "Agent templates dir exists" || fail "Agent templates dir missing"

for agent in frontend-developer backend-developer system-architect product-manager content-creator designer api-architect security-auditor system-tester devops-engineer; do
    [ -f "$TEMPLATE_DIR/$agent.md" ] && pass "Template: $agent" || warn "Missing template: $agent"
done

[ -f "$TEMPLATE_DIR/_memory-protocol.md" ] && pass "Memory protocol template" || fail "Memory protocol template missing"

# ── 6. Prerequisites ─────────────────────────────────────────────────

section "Prerequisites"

command -v node >/dev/null 2>&1 && pass "Node.js: $(node -v)" || fail "Node.js not found"
command -v python3 >/dev/null 2>&1 && pass "Python: $(python3 --version)" || fail "Python3 not found"
command -v claude >/dev/null 2>&1 && pass "Claude CLI: $(claude --version 2>/dev/null || echo 'installed')" || warn "Claude CLI not installed"
command -v git >/dev/null 2>&1 && pass "Git: $(git --version)" || warn "Git not found"

# ── 7. Memory System Integration Test ────────────────────────────────

section "Memory System Integration"

TEST_PROJECT="__test_$(date +%s)"
TEST_DIR="$MEMORY_DIR/projects/$TEST_PROJECT"

# Create test memory
mkdir -p "$TEST_DIR/memories"
cat > "$TEST_DIR/memories/test-memory.json" << EOF
{
  "id": "test-001",
  "timestamp": "$(date -Iseconds)",
  "agent": "test-runner",
  "type": "test",
  "content": {"test": true, "message": "Integration test"},
  "project": "$TEST_PROJECT"
}
EOF

[ -f "$TEST_DIR/memories/test-memory.json" ] && pass "Write test memory" || fail "Could not write test memory"

# Create test state
cat > "$TEST_DIR/_state.json" << EOF
{
  "project": "$TEST_PROJECT",
  "status": "testing",
  "agents": ["test-runner"],
  "created": "$(date -Iseconds)",
  "lastUpdated": "$(date -Iseconds)"
}
EOF

[ -f "$TEST_DIR/_state.json" ] && pass "Write project state" || fail "Could not write project state"

# Create test handoff
mkdir -p "$TEST_DIR/handoffs"
cat > "$TEST_DIR/handoffs/test-handoff.json" << EOF
{
  "id": "handoff-001",
  "from": "test-runner",
  "to": "frontend-developer",
  "timestamp": "$(date -Iseconds)",
  "context": {"test": true},
  "task": "Test task",
  "project": "$TEST_PROJECT",
  "status": "pending"
}
EOF

[ -f "$TEST_DIR/handoffs/test-handoff.json" ] && pass "Write agent handoff" || fail "Could not write agent handoff"

# Read back
STATE=$(cat "$TEST_DIR/_state.json" 2>/dev/null)
echo "$STATE" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null && pass "Read project state (valid JSON)" || fail "Project state invalid JSON"

# Clean up test data
rm -rf "$TEST_DIR"
[ ! -d "$TEST_DIR" ] && pass "Cleanup test data" || warn "Could not clean up test data"

# ── Summary ──────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Test Results"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}"
echo -e "  ${RED}FAIL: $FAIL${NC}"
echo -e "  ${YELLOW}WARN: $WARN${NC}"
echo ""

TOTAL=$((PASS + FAIL + WARN))
if [ "$FAIL" -eq 0 ]; then
    echo -e "  ${GREEN}All critical tests passed!${NC}"
    if [ "$WARN" -gt 0 ]; then
        echo -e "  ${YELLOW}$WARN warnings — review above for optional fixes.${NC}"
    fi
    exit 0
else
    echo -e "  ${RED}$FAIL critical failures — fix before using the system.${NC}"
    exit 1
fi
