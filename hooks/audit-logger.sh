#!/bin/bash
# audit-logger.sh — Post-tool hook for all tool calls
# Logs every tool invocation to a daily JSONL audit file at ~/.claude/audit/.
# Useful for reviewing what Claude did during a session.
#
# Install: add to settings.json under hooks.*.post (for every tool you want to audit)
# Requires: lib/common.sh

set -euo pipefail

. "$HOME/.claude/hooks/lib/common.sh"

tool_kind="${CLAUDE_TOOL_NAME:-unknown}"
hook_name="${CLAUDE_HOOK_NAME:-audit-logger}"
decision="${CLAUDE_PERMISSION_DECISION:-observe}"
reason="post_tool_use"

log_audit_safe "$hook_name" "$decision" "$reason" "$tool_kind"
emit_allow
