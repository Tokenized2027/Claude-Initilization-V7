#!/bin/bash
# pii-scan-precommit.sh — Pre-tool hook for git commit commands
# Scans the staged diff for PII and secrets before allowing a commit.
# Blocks the commit if personal emails, phone numbers, names, API keys,
# internal IDs, or other sensitive patterns are found.
#
# CUSTOMIZATION: Replace the placeholder patterns below with your own
# banned patterns (team emails, internal IPs, API key prefixes, etc.)
#
# Install: add to settings.json under hooks.Bash.pre
# Requires: lib/common.sh

set -euo pipefail

. "$HOME/.claude/hooks/lib/common.sh"

tool_input="$(read_tool_input)"

case "$tool_input" in
  *"git commit"*)
    ;;
  *)
    emit_allow
    exit 0
    ;;
esac

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  emit_allow
  exit 0
fi

diff_output="$(git diff --cached -p --no-color --unified=0 2>/dev/null || true)"
if [ -z "$diff_output" ]; then
  emit_allow
  exit 0
fi

_pii_scan_script="$(cat <<'SCANEOF'
current_file=""
while IFS= read -r line; do
  case "$line" in
    "+++ b/"*)
      current_file="${line#+++ b/}"
      continue
      ;;
    +*)
      case "$line" in
        "+++"*)
          continue
          ;;
      esac
      stripped="${line#+}"
      # Skip lines over 1000 chars (base64, minified JS, etc.)
      if [ "${#stripped}" -gt 1000 ]; then
        continue
      fi
      # --- Personal email patterns ---
      # Add your team's personal email addresses here
      if printf '%s\n' "$stripped" | grep -qiE '[YOUR_EMAIL_HERE]@[YOUR_DOMAIN]\.com|[A-Za-z0-9._%+-]+@gmail\.com\b|[A-Za-z0-9._%+-]+@yahoo\.com\b|[A-Za-z0-9._%+-]+@hotmail\.com\b'; then
        printf 'personal_email|%s\n' "$current_file"
        exit 0
      fi
      # --- Phone number patterns ---
      # Add your team's phone numbers here (use exact matches)
      if printf '%s\n' "$stripped" | grep -qE '[YOUR_PHONE_PATTERN_HERE]'; then
        printf 'personal_phone|%s\n' "$current_file"
        exit 0
      fi
      # --- Team member names ---
      # Add names that should never appear in committed code
      if printf '%s\n' "$stripped" | grep -qE '[YOUR_NAME_PATTERN_HERE]'; then
        printf 'founder_name|%s\n' "$current_file"
        exit 0
      fi
      # --- Internal service IDs ---
      # Add Telegram IDs, Slack IDs, internal account numbers, etc.
      if printf '%s\n' "$stripped" | grep -qE '[YOUR_INTERNAL_ID_PATTERN_HERE]'; then
        printf 'internal_id|%s\n' "$current_file"
        exit 0
      fi
      # --- Internal IPs ---
      # Add VPN IPs, Tailscale IPs, internal network ranges
      if printf '%s\n' "$stripped" | grep -qE '[YOUR_INTERNAL_IP_PATTERN_HERE]'; then
        printf 'internal_ip|%s\n' "$current_file"
        exit 0
      fi
      # --- Personal handles ---
      # Add GitHub usernames, social media handles, etc.
      if printf '%s\n' "$stripped" | grep -q '[YOUR_HANDLE_PATTERN_HERE]'; then
        printf 'personal_handle|%s\n' "$current_file"
        exit 0
      fi
      # --- API Keys ---
      # Generic patterns for common API key formats
      if printf '%s\n' "$stripped" | grep -qE 'ANTHROPIC_API_KEY=sk-|OPENAI_API_KEY=sk-|AWS_SECRET_ACCESS_KEY='; then
        printf 'api_key|%s\n' "$current_file"
        exit 0
      fi
      ;;
  esac
done
SCANEOF
)"
match_result="$(printf '%s\n' "$diff_output" | bash -c "$_pii_scan_script")"

if [ -n "$match_result" ]; then
  category="${match_result%%|*}"
  file_path="${match_result#*|}"
  log_audit_safe "pii-scan-precommit" "deny" "$category" "Bash"
  emit_block "Blocked git commit: staged diff contains banned ${category} in ${file_path}."
  exit 0
fi

emit_allow
