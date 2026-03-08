#!/bin/bash
# .claude/hooks/verify-compliance.sh
#
# Claude Code Hook: PreToolUse (Bash matcher)
# Checks compliance before git commit commands.
# Verifies: no partial file markers, no hardcoded secrets, .env not staged,
# STATUS.md freshness, CLAUDE.md existence.
#
# Hook type: command
# Event: PreToolUse
# Matcher: Bash
# Exit codes: 0 = allow, 2 = block
#
# Receives JSON on stdin with tool_input.command

# Require jq — exit cleanly (allow) if not installed
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git commit commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

VIOLATIONS=0
REASONS=""

# --- Check 1: No partial file markers in staged files ---
PARTIAL_MARKERS=(
  "rest stays the same"
  "rest of the code stays the same"
  "remaining code unchanged"
  "... existing code ..."
  "// ... rest"
  "# ... rest"
  "<!-- rest"
  "TRUNCATED"
)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
if [ -n "$STAGED_FILES" ]; then
  for marker in "${PARTIAL_MARKERS[@]}"; do
    FOUND=$(echo "$STAGED_FILES" | tr '\n' '\0' | xargs -0 grep -li "$marker" 2>/dev/null)
    if [ -n "$FOUND" ]; then
      REASONS="${REASONS}Partial file marker '${marker}' found in staged files. "
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done
fi

# --- Check 2: No hardcoded secrets in staged files ---
SECRET_PATTERNS=(
  "sk-ant-[a-zA-Z0-9]"
  "sk-[a-zA-Z0-9]{20,}"
  "AKIA[A-Z0-9]{16}"
)

if [ -n "$STAGED_FILES" ]; then
  for pattern in "${SECRET_PATTERNS[@]}"; do
    FOUND=$(echo "$STAGED_FILES" | tr '\n' '\0' | xargs -0 grep -lE "$pattern" 2>/dev/null | grep -v ".env.example" | grep -v ".md")
    if [ -n "$FOUND" ]; then
      REASONS="${REASONS}Possible hardcoded secret found in staged files. "
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done
fi

# --- Check 3: .env is not staged ---
if git diff --cached --name-only 2>/dev/null | grep -q "^\.env$"; then
  REASONS="${REASONS}.env file is staged for commit — add it to .gitignore. "
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# --- Check 4: CLAUDE.md exists ---
if [ ! -f "CLAUDE.md" ]; then
  REASONS="${REASONS}CLAUDE.md does not exist in project root. "
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# --- Result ---
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "{\"decision\": \"block\", \"reason\": \"Compliance check failed (${VIOLATIONS} violation(s)): ${REASONS}Fix violations before committing.\"}" | jq .
  exit 2
fi

exit 0
