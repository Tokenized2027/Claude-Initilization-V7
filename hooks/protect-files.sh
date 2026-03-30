#!/bin/bash
# protect-files.sh — Pre-tool hook for file edit/write operations
# Warns when editing environment files or credential files to prevent
# accidental secret exposure.
#
# Install: add to settings.json under hooks.Edit.pre and hooks.Write.pre
# Requires: lib/common.sh

set -euo pipefail

. "$HOME/.claude/hooks/lib/common.sh"

file_path="${CLAUDE_FILE_PATH:-}"

case "$file_path" in
  *.env|*.env.production|*.env.local|*.env.staging)
    emit_warn "Editing an environment file. Make sure no secrets are being committed."
    ;;
  *credentials*|*secret*)
    emit_warn "This file may contain credentials. Proceed carefully."
    ;;
  *)
    emit_allow
    ;;
esac
