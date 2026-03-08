#!/bin/bash
# Validate v4.4 Setup
# Checks if all v4.4 systems are properly configured

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check_pass() { echo -e "${GREEN}✓${NC} $1"; ((PASS++)); }
check_fail() { echo -e "${RED}✗${NC} $1"; ((FAIL++)); }
check_warn() { echo -e "${YELLOW}⚠${NC} $1"; ((WARN++)); }
section() { echo -e "\n${BLUE}▸${NC} $1"; }

section "Validating v4.4 Setup"

# Check if in project root
if [ ! -d ".claude" ]; then
    check_fail "Not in a Claude Code project (no .claude directory)"
    echo ""
    echo "Run this from your project root directory"
    exit 1
fi

## 1. Memory System
section "1. Memory System"

if [ -d ".claude/memory" ]; then
    check_pass "Memory directory exists"

    # Check each memory file
    if [ -f ".claude/memory/decisions.json" ]; then
        check_pass "decisions.json exists"
        if jq empty .claude/memory/decisions.json 2>/dev/null; then
            check_pass "decisions.json is valid JSON"
        else
            check_fail "decisions.json is invalid JSON"
        fi
    else
        check_warn "decisions.json not found (will be created on first use)"
    fi

    if [ -f ".claude/memory/patterns.md" ]; then
        check_pass "patterns.md exists"
    else
        check_warn "patterns.md not found (will be created on first use)"
    fi

    if [ -f ".claude/memory/preferences.md" ]; then
        check_pass "preferences.md exists"
        if [ -s ".claude/memory/preferences.md" ]; then
            check_pass "preferences.md is configured (not empty)"
        else
            check_warn "preferences.md is empty (should configure your preferences)"
        fi
    else
        check_fail "preferences.md not found (create from template)"
    fi

    if [ -f ".claude/memory/project-context.json" ]; then
        check_pass "project-context.json exists"
    else
        check_warn "project-context.json not found (will be created on first session)"
    fi

    if [ -f ".claude/memory/session-history.json" ]; then
        check_pass "session-history.json exists"
    else
        check_warn "session-history.json not found (will be created on first session)"
    fi

    if [ -d ".claude/memory/cross-project" ]; then
        check_pass "cross-project directory exists"
    else
        check_warn "cross-project directory not found (optional)"
    fi
else
    check_fail "Memory directory not found (.claude/memory)"
    echo "  Run: mkdir -p .claude/memory"
fi

## 2. Sprint Management
section "2. Sprint Management"

if [ -d "docs" ]; then
    check_pass "docs/ directory exists"

    if [ -f "docs/BACKLOG.md" ]; then
        check_pass "BACKLOG.md exists"
    else
        check_warn "BACKLOG.md not found (create with: sprint-planner.sh backlog)"
    fi

    SPRINTS=$(ls docs/SPRINT_*.md 2>/dev/null | wc -l)
    if [ "$SPRINTS" -gt 0 ]; then
        check_pass "Sprint files found ($SPRINTS sprints)"
    else
        check_warn "No sprint files yet (start with: sprint-planner.sh plan)"
    fi

    RETROS=$(ls docs/RETROSPECTIVE_*.md 2>/dev/null | wc -l)
    if [ "$RETROS" -gt 0 ]; then
        check_pass "Retrospective files found ($RETROS retros)"
    else
        check_warn "No retrospectives yet (normal for first sprint)"
    fi
else
    check_warn "docs/ directory not found (create when starting sprints)"
fi

## 3. Scripts
section "3. Automation Scripts"

if [ -f "toolkit/memory-manager.sh" ] || [ -f ".claude/memory-manager.sh" ] || [ -f "../toolkit/memory-manager.sh" ]; then
    check_pass "memory-manager.sh found"
else
    check_warn "memory-manager.sh not found (copy from toolkit/)"
fi

if [ -f "toolkit/sprint-planner.sh" ] || [ -f ".claude/sprint-planner.sh" ] || [ -f "../toolkit/sprint-planner.sh" ]; then
    check_pass "sprint-planner.sh found"
else
    check_warn "sprint-planner.sh not found (copy from toolkit/)"
fi

## 4. Templates
section "4. Templates Available"

TEMPLATE_COUNT=0
if [ -f "toolkit/templates/SPRINT.md" ] || [ -f "../toolkit/templates/SPRINT.md" ]; then
    ((TEMPLATE_COUNT++))
fi
if [ -f "toolkit/templates/BACKLOG.md" ] || [ -f "../toolkit/templates/BACKLOG.md" ]; then
    ((TEMPLATE_COUNT++))
fi
if [ -f "toolkit/templates/RETROSPECTIVE.md" ] || [ -f "../toolkit/templates/RETROSPECTIVE.md" ]; then
    ((TEMPLATE_COUNT++))
fi
if [ -f "toolkit/templates/BEAD_CHAIN.md" ] || [ -f "../toolkit/templates/BEAD_CHAIN.md" ]; then
    ((TEMPLATE_COUNT++))
fi

if [ $TEMPLATE_COUNT -eq 4 ]; then
    check_pass "All v4.4 templates available"
elif [ $TEMPLATE_COUNT -gt 0 ]; then
    check_warn "Some templates found ($TEMPLATE_COUNT/4)"
else
    check_warn "Templates not found (ensure claude-code-framework toolkit is accessible)"
fi

## 5. Git
section "5. Git Repository"

if [ -d ".git" ]; then
    check_pass "Git repository initialized"

    BRANCH=$(git branch --show-current 2>/dev/null || echo "")
    if [ -n "$BRANCH" ]; then
        check_pass "Current branch: $BRANCH"
    fi

    COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [ "$COMMITS" -gt 0 ]; then
        check_pass "Commits: $COMMITS"
    else
        check_warn "No commits yet"
    fi
else
    check_warn "Not a git repository (run: git init)"
fi

## 6. Claude Code CLI
section "6. Claude Code CLI"

if command -v claude &> /dev/null; then
    check_pass "Claude Code CLI installed"
    VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo "  Version: $VERSION"
else
    check_fail "Claude Code CLI not found"
    echo "  Install from: https://docs.anthropic.com/claude/docs/claude-code"
fi

## Summary
section "Validation Summary"

TOTAL=$((PASS + FAIL + WARN))
echo ""
echo "Results:"
echo -e "  ${GREEN}✓ Passed:${NC} $PASS"
echo -e "  ${RED}✗ Failed:${NC} $FAIL"
echo -e "  ${YELLOW}⚠ Warnings:${NC} $WARN"
echo "  ─────────────"
echo "  Total checks: $TOTAL"
echo ""

if [ $FAIL -eq 0 ] && [ $WARN -eq 0 ]; then
    echo -e "${GREEN}✓ Perfect!${NC} Your v4.4 setup is complete."
    echo ""
    echo "Ready to use:"
    echo "  - Memory system: ./toolkit/memory-manager.sh start"
    echo "  - Sprint planning: ./toolkit/sprint-planner.sh plan"
    echo "  - Task integration: Use TaskCreate/Update/List in sessions"
    echo "  - Bead method: Create BEAD_CHAIN.md for features"
    exit 0
elif [ $FAIL -eq 0 ]; then
    echo -e "${YELLOW}⚠ Good!${NC} Setup is functional with some optional items missing."
    echo ""
    echo "To complete setup:"
    [ $WARN -gt 0 ] && echo "  - Review warnings above"
    echo "  - See guides/V4.4_QUICK_START.md for quick setup"
    echo "  - See UPGRADING_V4.3_TO_V4.4.md for full migration"
    exit 0
else
    echo -e "${RED}✗ Issues found.${NC} v4.4 setup incomplete."
    echo ""
    echo "Critical fixes needed:"
    [ ! -d ".claude/memory" ] && echo "  1. Create memory directory: mkdir -p .claude/memory"
    [ ! -f ".claude/memory/preferences.md" ] && echo "  2. Copy memory templates from toolkit/templates/memory/"
    [ ! command -v claude ] && echo "  3. Install Claude Code CLI"
    echo ""
    echo "See guides/V4.4_QUICK_START.md for step-by-step setup"
    exit 1
fi
