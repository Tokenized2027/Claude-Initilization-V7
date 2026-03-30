#!/bin/bash
# common.sh — Shared library for Claude Code hooks
# Provides input reading, JSON output helpers, and audit logging.
#
# Usage: source this file at the top of every hook script:
#   . "$HOME/.claude/hooks/lib/common.sh"

set -u

# --- Input Reading ---

read_tool_input() {
  if [ -n "${CLAUDE_TOOL_INPUT:-}" ]; then
    printf '%s' "$CLAUDE_TOOL_INPUT"
    return
  fi
  if [ -n "${CLAUDE_COMMAND:-}" ]; then
    printf '%s' "$CLAUDE_COMMAND"
    return
  fi
  cat
}

# --- JSON Helpers ---

json_escape() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

# --- Hook Response Emitters ---
# These output JSON that the Claude Code harness reads.

emit_allow() {
  printf '{}\n'
}

emit_warn() {
  local message escaped
  message="${1:-}"
  escaped="$(json_escape "$message")"
  printf '{"systemMessage":"%s"}\n' "$escaped"
}

emit_block() {
  local message escaped
  message="${1:-}"
  escaped="$(json_escape "$message")"
  printf '{"permissionDecision":"deny","systemMessage":"%s"}\n' "$escaped"
}

# --- Audit Logging ---

audit_dir() {
  printf '%s/.claude/audit' "$HOME"
}

ensure_audit_dir() {
  mkdir -p "$(audit_dir)"
}

log_audit_safe() {
  local hook decision reason tool_kind ts logfile cwd_name
  hook="${1:-unknown-hook}"
  decision="${2:-allow}"
  reason="${3:-unspecified}"
  tool_kind="${4:-unknown-tool}"
  ensure_audit_dir
  ts="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  logfile="$(audit_dir)/$(date '+%Y-%m-%d').jsonl"
  cwd_name="$(basename "${PWD:-unknown}")"
  printf '{"timestamp":"%s","hook":"%s","tool":"%s","decision":"%s","reason":"%s","cwd":"%s"}\n' \
    "$(json_escape "$ts")" \
    "$(json_escape "$hook")" \
    "$(json_escape "$tool_kind")" \
    "$(json_escape "$decision")" \
    "$(json_escape "$reason")" \
    "$(json_escape "$cwd_name")" >> "$logfile"
}

# --- Utility ---

_resolve_lib() {
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ] && [ -f "$CLAUDE_PROJECT_DIR/.claude/hooks/lib/common.sh" ]; then
    return 0
  fi
  return 0
}
