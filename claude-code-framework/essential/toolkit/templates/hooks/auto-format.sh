#!/bin/bash
# .claude/hooks/auto-format.sh
#
# Claude Code Hook: PostToolUse (Write|Edit matcher)
# Runs project formatters after Claude writes or edits files.
#
# Hook type: command
# Event: PostToolUse
# Matcher: Write|Edit
# Exit codes: 0 = success (always — formatters should not block)
#
# Receives JSON on stdin with tool_input.file_path

# Require jq — exit cleanly (allow) if not installed
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# JavaScript/TypeScript — run Prettier if available
if echo "$EXT" | grep -qE '^(js|jsx|ts|tsx|css|json)$'; then
  if [ -f "package.json" ] && command -v npx &> /dev/null; then
    if grep -q "prettier" package.json 2>/dev/null; then
      npx prettier --write "$FILE_PATH" 2>/dev/null
    fi
  fi
fi

# Python — run Black if available
if [ "$EXT" = "py" ]; then
  if command -v black &> /dev/null; then
    black "$FILE_PATH" --quiet 2>/dev/null
  fi
fi

exit 0
