#!/bin/bash
# block-dangerous-commands.sh — Pre-tool hook for Bash commands
# Blocks destructive commands, direct pushes to main, force pushes,
# data exfiltration (uploads, netcat, cloud storage), credential theft,
# and unauthorized system manipulation.
#
# Install: add to settings.json under hooks.Bash.pre
# Requires: lib/common.sh

set -euo pipefail

. "$HOME/.claude/hooks/lib/common.sh"

tool_input="$(read_tool_input)"
current_branch="$(git branch --show-current 2>/dev/null || true)"

# --- DESTRUCTIVE COMMANDS ---

if printf '%s\n' "$tool_input" | grep -qE 'rm -rf /|git reset --hard|DROP TABLE|DROP DATABASE|format [A-Z]:|diskpart|del /[sS]'; then
  log_audit_safe "block-dangerous-commands" "deny" "destructive_command" "Bash"
  emit_block "Blocked: potentially destructive command detected."
  exit 0
fi

# --- GIT SAFETY ---

if printf '%s\n' "$tool_input" | grep -qE 'git push([^[:alnum:]]|.* )origin[[:space:]]+main\b|git push[[:space:]]+main\b'; then
  suggestion="Create a PR branch instead."
  if [ -n "$current_branch" ] && [ "$current_branch" != "main" ]; then
    suggestion="Use git push origin $current_branch instead."
  fi
  log_audit_safe "block-dangerous-commands" "deny" "push_main" "Bash"
  emit_block "Blocked direct push to main. ${suggestion}"
  exit 0
fi

if printf '%s\n' "$tool_input" | grep -qE 'git push.*--force|git push.*-f'; then
  log_audit_safe "block-dangerous-commands" "warn" "force_push" "Bash"
  emit_warn "Force push detected. Confirm branch and PR context before continuing."
  exit 0
fi

# --- DATA EXFILTRATION: BULK ARCHIVE CREATION ---
# Block tar/zip/7z of broad directory trees (root, home, user dirs, entire drives)

if printf '%s\n' "$tool_input" | grep -qiE '(tar |tar\.exe |zip |7z |rar |gzip ).*(\/[[:space:]]|\/\*|\/home|\/root|\/etc|\/var|C:\\|C:/|D:\\|D:/|G:\\|G:/|%USERPROFILE%|%HOMEPATH%|\$HOME[^/]|~/)'; then
  log_audit_safe "block-dangerous-commands" "deny" "bulk_archive" "Bash"
  emit_block "Blocked: bulk archive of broad directory tree. This looks like data exfiltration. Confirm scope with the user."
  exit 0
fi

# Block archiving the entire current workspace root
if printf '%s\n' "$tool_input" | grep -qiE '(tar |zip |7z ).*(czf|cf |create|a )[[:space:]]+\S+[[:space:]]+\.$'; then
  log_audit_safe "block-dangerous-commands" "deny" "archive_workspace_root" "Bash"
  emit_block "Blocked: archiving entire workspace root. Specify which subdirectory."
  exit 0
fi

# --- DATA EXFILTRATION: OUTBOUND DATA TRANSFER ---
# Block curl/wget/nc/ncat/socat/python uploading files or piping data out

if printf '%s\n' "$tool_input" | grep -qiE 'curl .*(--upload-file|-T |-d @|--data-binary @|-F .*=@)'; then
  log_audit_safe "block-dangerous-commands" "deny" "curl_upload" "Bash"
  emit_block "Blocked: curl file upload detected. This could exfiltrate data. Ask the user first."
  exit 0
fi

if printf '%s\n' "$tool_input" | grep -qiE 'curl .* -X (POST|PUT) '; then
  # Allow localhost/127.0.0.1 for local dev
  if ! printf '%s\n' "$tool_input" | grep -qiE 'curl .*(localhost|127\.0\.0\.1|0\.0\.0\.0)'; then
    log_audit_safe "block-dangerous-commands" "deny" "curl_post_external" "Bash"
    emit_block "Blocked: curl POST/PUT to external host. Could exfiltrate data. Ask the user first."
    exit 0
  fi
fi

if printf '%s\n' "$tool_input" | grep -qiE 'wget .*(--post-file|--post-data|--method=PUT)'; then
  log_audit_safe "block-dangerous-commands" "deny" "wget_upload" "Bash"
  emit_block "Blocked: wget upload detected. Ask the user first."
  exit 0
fi

# Block netcat/socat/ncat outbound (common exfil tools)
if printf '%s\n' "$tool_input" | grep -qiE '\b(nc|ncat|socat|netcat)\b'; then
  log_audit_safe "block-dangerous-commands" "deny" "netcat" "Bash"
  emit_block "Blocked: netcat/socat usage. These are common exfiltration tools."
  exit 0
fi

# Block scp/rsync/sftp outbound transfers
if printf '%s\n' "$tool_input" | grep -qiE '\b(scp|rsync|sftp)\b.*@'; then
  log_audit_safe "block-dangerous-commands" "deny" "remote_copy" "Bash"
  emit_block "Blocked: remote file copy (scp/rsync/sftp). Ask the user first."
  exit 0
fi

# Block aws s3 cp/sync/mv (S3 exfiltration)
if printf '%s\n' "$tool_input" | grep -qiE 'aws s3 (cp|sync|mv|put-object)'; then
  log_audit_safe "block-dangerous-commands" "deny" "s3_upload" "Bash"
  emit_block "Blocked: AWS S3 upload detected. Ask the user first."
  exit 0
fi

# Block gsutil/gcloud storage (GCP exfiltration)
if printf '%s\n' "$tool_input" | grep -qiE '(gsutil|gcloud storage) (cp|rsync|mv)'; then
  log_audit_safe "block-dangerous-commands" "deny" "gcs_upload" "Bash"
  emit_block "Blocked: GCP storage upload detected. Ask the user first."
  exit 0
fi

# Block az storage blob upload (Azure exfiltration)
if printf '%s\n' "$tool_input" | grep -qiE 'az storage blob upload'; then
  log_audit_safe "block-dangerous-commands" "deny" "azure_upload" "Bash"
  emit_block "Blocked: Azure blob upload detected. Ask the user first."
  exit 0
fi

# Block piping file content to DNS/HTTP (base64 exfil)
if printf '%s\n' "$tool_input" | grep -qiE 'base64.*\|.*(curl|wget|nc|dig|nslookup|host )'; then
  log_audit_safe "block-dangerous-commands" "deny" "base64_exfil" "Bash"
  emit_block "Blocked: base64 piped to network tool. Classic data exfiltration pattern."
  exit 0
fi

# Block DNS exfiltration (dig/nslookup with encoded data)
if printf '%s\n' "$tool_input" | grep -qiE '\|.*(dig|nslookup|host )[[:space:]]'; then
  log_audit_safe "block-dangerous-commands" "deny" "dns_exfil" "Bash"
  emit_block "Blocked: data piped to DNS lookup. Classic DNS exfiltration pattern."
  exit 0
fi

# Block python/node/ruby one-liners that open sockets or HTTP
if printf '%s\n' "$tool_input" | grep -qiE 'python3? -c .*(socket|http\.client|urllib|requests\.(post|put))'; then
  log_audit_safe "block-dangerous-commands" "deny" "python_exfil" "Bash"
  emit_block "Blocked: Python inline network socket/HTTP. Could exfiltrate data."
  exit 0
fi

if printf '%s\n' "$tool_input" | grep -qiE 'node -e .*(http\.request|https\.request|fetch\(|axios)'; then
  log_audit_safe "block-dangerous-commands" "deny" "node_exfil" "Bash"
  emit_block "Blocked: Node.js inline HTTP request. Could exfiltrate data."
  exit 0
fi

# --- CREDENTIAL THEFT ---
# Block reading common credential stores

if printf '%s\n' "$tool_input" | grep -qiE '(cat|type|less|more|head|tail|bat) .*(\.ssh/|\.aws/credentials|\.gnupg|\.npmrc|\.netrc|\.docker/config|\.kube/config)'; then
  log_audit_safe "block-dangerous-commands" "deny" "credential_read" "Bash"
  emit_block "Blocked: reading credential/key file. These should not be accessed by Claude."
  exit 0
fi

# --- PROCESS/SYSTEM MANIPULATION ---

if printf '%s\n' "$tool_input" | grep -qiE '(useradd|usermod|passwd|adduser|visudo|chmod 777|icacls .*/grant.*Everyone)'; then
  log_audit_safe "block-dangerous-commands" "deny" "user_manipulation" "Bash"
  emit_block "Blocked: user/permission manipulation. Ask the user first."
  exit 0
fi

if printf '%s\n' "$tool_input" | grep -qiE '(crontab -|schtasks /create|at [0-9])'; then
  log_audit_safe "block-dangerous-commands" "deny" "scheduled_task" "Bash"
  emit_block "Blocked: creating scheduled task/crontab. Ask the user first."
  exit 0
fi

emit_allow
