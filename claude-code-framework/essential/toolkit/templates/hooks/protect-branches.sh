#!/bin/bash
# .claude/hooks/protect-branches.sh
#
# Claude Code Hook: PreToolUse (Bash matcher)
# Prevents git commits and pushes to protected branches.
#
# Hook type: command
# Event: PreToolUse
# Matcher: Bash
# Exit codes: 0 = allow, 2 = block
#
# Receives JSON on stdin with tool_input.command
# Outputs JSON on stdout with reason when blocking

# Read the JSON input from Claude Code
# Require jq — exit cleanly (allow) if not installed
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

# Extract the command Claude is about to run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit and push commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+(commit|push)'; then
  exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ -z "$CURRENT_BRANCH" ]; then
  exit 0
fi

PROTECTED_BRANCHES=("main" "production" "master")

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" == "$branch" ]; then
    echo "{\"decision\": \"block\", \"reason\": \"Cannot commit/push directly to protected branch '$branch'. Create a feature branch first: git checkout -b feature/your-feature-name\"}" | jq .
    exit 2
  fi
done

exit 0
