#!/bin/bash
# .claude/hooks/block-dangerous-commands.sh
#
# Claude Code Hook: PreToolUse (Bash matcher)
# Blocks commands that could permanently delete code or data.
#
# Hook type: command
# Event: PreToolUse
# Matcher: Bash
# Exit codes: 0 = allow, 2 = block
#
# Receives JSON on stdin with tool_input.command
# Outputs JSON on stdout with reason when blocking

# Require jq — exit cleanly (allow) if not installed
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Dangerous patterns — each triggers a block
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf ."
  "git push --force"
  "git push -f"
  "git clean -fdx"
  "git reset --hard HEAD~"
  "git reset --hard origin"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
)

COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  PATTERN_LOWER=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
  if echo "$COMMAND_LOWER" | grep -qF "$PATTERN_LOWER"; then
    echo "{\"decision\": \"block\", \"reason\": \"Blocked dangerous command matching pattern: '$pattern'. If you really need this, run it manually outside Claude Code.\"}" | jq .
    exit 2
  fi
done

exit 0
