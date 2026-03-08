#!/bin/bash
# test-scaffold.sh — Smoke tests for create-project.sh and adopt-project.sh
#
# Creates temp projects, runs the scripts, and verifies the output structure.
# Run from the repo root: bash toolkit/test-scaffold.sh
#
# Exit codes: 0 = all tests pass, 1 = failures

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_DIR=$(mktemp -d)
PASS=0
FAIL=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

cleanup() {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

log_pass() {
  echo -e "  ${GREEN}✅ PASS${NC}: $1"
  PASS=$((PASS + 1))
}

log_fail() {
  echo -e "  ${RED}❌ FAIL${NC}: $1"
  FAIL=$((FAIL + 1))
}

assert_file_exists() {
  if [ -f "$1" ]; then
    log_pass "$2"
  else
    log_fail "$2 — file not found: $1"
  fi
}

assert_dir_exists() {
  if [ -d "$1" ]; then
    log_pass "$2"
  else
    log_fail "$2 — directory not found: $1"
  fi
}

assert_file_contains() {
  if grep -q "$2" "$1" 2>/dev/null; then
    log_pass "$3"
  else
    log_fail "$3 — pattern '$2' not found in $1"
  fi
}

assert_file_not_empty() {
  if [ -s "$1" ]; then
    log_pass "$2"
  else
    log_fail "$2 — file is empty: $1"
  fi
}

# =============================================
# Test 1: Shellcheck (if available)
# =============================================
echo ""
echo "━━━ Test Suite: Script Quality ━━━"

if command -v shellcheck &> /dev/null; then
  if shellcheck -S warning "$SCRIPT_DIR/create-project.sh" 2>/dev/null; then
    log_pass "create-project.sh passes shellcheck"
  else
    log_fail "create-project.sh has shellcheck warnings"
  fi
  if shellcheck -S warning "$SCRIPT_DIR/adopt-project.sh" 2>/dev/null; then
    log_pass "adopt-project.sh passes shellcheck"
  else
    log_fail "adopt-project.sh has shellcheck warnings"
  fi
else
  echo -e "  ${YELLOW}⏭️  SKIP${NC}: shellcheck not installed (install with: sudo apt install shellcheck)"
fi

# =============================================
# Test 2: create-project.sh — Next.js project
# =============================================
echo ""
echo "━━━ Test Suite: create-project.sh (Next.js) ━━━"

PROJECT_DIR="$TEST_DIR/test-nextjs-project"

# Run the script non-interactively by pre-filling inputs
# The script uses 'read' so we pipe answers
echo -e "test-nextjs-project\n$TEST_DIR\nnextjs\ny\ny\n" | bash "$SCRIPT_DIR/create-project.sh" 2>/dev/null || true

if [ -d "$PROJECT_DIR" ]; then
  log_pass "Project directory created"

  # Check mandatory files
  assert_file_exists "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md exists"
  assert_file_exists "$PROJECT_DIR/STATUS.md" "STATUS.md exists"
  assert_file_exists "$PROJECT_DIR/.gitignore" ".gitignore exists"
  assert_file_exists "$PROJECT_DIR/README.md" "README.md exists"

  # Check mandatory directories
  assert_dir_exists "$PROJECT_DIR/docs" "docs/ directory exists"
  assert_dir_exists "$PROJECT_DIR/logs" "logs/ directory exists"
  assert_dir_exists "$PROJECT_DIR/tmp" "tmp/ directory exists"

  # Check CLAUDE.md has content
  assert_file_not_empty "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md is not empty"

  # Check .gitignore has essential entries
  assert_file_contains "$PROJECT_DIR/.gitignore" ".env" ".gitignore includes .env"
  assert_file_contains "$PROJECT_DIR/.gitignore" "node_modules" ".gitignore includes node_modules"
  assert_file_contains "$PROJECT_DIR/.gitignore" "tmp/" ".gitignore includes tmp/"

  # Check git was initialized
  if [ -d "$PROJECT_DIR/.git" ]; then
    log_pass "Git repo initialized"
  else
    log_fail "Git repo not initialized"
  fi
else
  log_fail "Project directory not created — script may require interactive input"
  echo -e "  ${YELLOW}NOTE${NC}: create-project.sh may not support piped input. Test manually."
fi

# =============================================
# Test 3: Template files are valid
# =============================================
echo ""
echo "━━━ Test Suite: Template Integrity ━━━"

TEMPLATES_DIR="$SCRIPT_DIR/templates"

assert_file_exists "$TEMPLATES_DIR/CLAUDE.md" "CLAUDE.md template exists"
assert_file_exists "$TEMPLATES_DIR/STATUS.md" "STATUS.md template exists"
assert_file_exists "$TEMPLATES_DIR/PRD.md" "PRD.md template exists"
assert_file_exists "$TEMPLATES_DIR/TECH_SPEC.md" "TECH_SPEC.md template exists"
assert_file_exists "$TEMPLATES_DIR/HOOKS_SETUP.md" "HOOKS_SETUP.md template exists"

# Check templates have placeholder markers (proves they're templates, not filled-in files)
assert_file_contains "$TEMPLATES_DIR/CLAUDE.md" "Project-Specific Rules" "CLAUDE.md has customization section"
assert_file_contains "$TEMPLATES_DIR/STATUS.md" "Current Phase" "STATUS.md has phase tracking"
assert_file_contains "$TEMPLATES_DIR/PRD.md" "Problem Statement" "PRD.md has required sections"
assert_file_contains "$TEMPLATES_DIR/TECH_SPEC.md" "Architecture" "TECH_SPEC.md has architecture section"

# =============================================
# Test 4: Hook scripts are valid bash
# =============================================
echo ""
echo "━━━ Test Suite: Hook Scripts ━━━"

HOOKS_DIR="$TEMPLATES_DIR/hooks"
if [ -d "$HOOKS_DIR" ]; then
  for hook in "$HOOKS_DIR"/*.sh; do
    if [ -f "$hook" ]; then
      HOOK_NAME=$(basename "$hook")
      if bash -n "$hook" 2>/dev/null; then
        log_pass "$HOOK_NAME is valid bash"
      else
        log_fail "$HOOK_NAME has bash syntax errors"
      fi
    fi
  done
else
  echo -e "  ${YELLOW}⏭️  SKIP${NC}: No hooks directory found at $HOOKS_DIR"
fi

# =============================================
# Test 5: Agent prompts are complete
# =============================================
echo ""
echo "━━━ Test Suite: Agent Prompts ━━━"

AGENTS_DIR="$REPO_ROOT/agents"

assert_file_exists "$AGENTS_DIR/01-shared-context.md" "Shared context exists"
assert_file_exists "$AGENTS_DIR/02-project-brief-template.md" "Project brief template exists"
assert_file_exists "$AGENTS_DIR/03-system-architect.md" "System Architect prompt exists"
assert_file_exists "$AGENTS_DIR/04-product-manager.md" "Product Manager prompt exists"
assert_file_exists "$AGENTS_DIR/05-frontend-developer.md" "Frontend Developer prompt exists"
assert_file_exists "$AGENTS_DIR/06-backend-developer.md" "Backend Developer prompt exists"
assert_file_exists "$AGENTS_DIR/07-system-tester.md" "System Tester prompt exists"

# Check shared context has critical rules
assert_file_contains "$AGENTS_DIR/01-shared-context.md" "COMPLETE" "Shared context mentions complete files rule"
assert_file_contains "$AGENTS_DIR/01-shared-context.md" "HANDOFF" "Shared context mentions handoff protocol"

# =============================================
# Test 6: No personal information leaked (white-label check)
# =============================================
echo ""
echo "━━━ Test Suite: White-Label Cleanliness ━━━"

PERSONAL_PATTERNS=(
  # Add patterns here that should NOT appear in a clean white-label repo.
  # Example: your personal username, project names, server hostnames, etc.
  # "my-personal-hostname"
  # "my-username@example.com"
)

CLEAN=true
for pattern in "${PERSONAL_PATTERNS[@]}"; do
  FOUND=$(grep -rli "$pattern" "$REPO_ROOT" --include="*.md" --include="*.sh" 2>/dev/null | grep -v "test-scaffold.sh" | head -3)
  if [ -n "$FOUND" ]; then
    log_fail "Personal info pattern '$pattern' found in: $(echo $FOUND | tr '\n' ' ')"
    CLEAN=false
  fi
done
if [ "$CLEAN" = true ]; then
  log_pass "No personal information patterns found"
fi

# =============================================
# Summary
# =============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS + FAIL))
echo "Results: ${PASS}/${TOTAL} passed, ${FAIL} failed"

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
fi
