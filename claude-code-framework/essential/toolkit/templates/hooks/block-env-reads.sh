#!/bin/bash
# .claude/hooks/block-env-reads.sh
#
# Claude Code Hook: PreToolUse (Read|Edit|Write matcher)
# Prevents Claude from reading or modifying .env files containing secrets.
#
# Hook type: command
# Event: PreToolUse
# Matcher: Read|Edit|Write
# Exit codes: 0 = allow, 2 = block
#
# Receives JSON on stdin with tool_input.file_path

# Require jq — exit cleanly (allow) if not installed
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)

# Extract the file path from the tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Get just the filename
FILENAME=$(basename "$FILE_PATH")

# Block .env files (but allow .env.example and .env.template)
if echo "$FILENAME" | grep -qE '^\.env$|^\.env\.local$|^\.env\.production$|^\.env\.development$'; then
  echo "{\"decision\": \"block\", \"reason\": \"Blocked access to '$FILENAME' — this file may contain secrets. Use .env.example for templates.\"}" | jq .
  exit 2
fi

exit 0
