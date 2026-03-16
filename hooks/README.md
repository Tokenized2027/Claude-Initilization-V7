# Claude Code Hooks

Hooks are shell commands that run automatically in response to Claude Code events. They are the most underrated feature in Claude Code — they let you inject context, enforce safety rules, and track state without lifting a finger.

## What's Here

```
hooks/
├── README.md              ← You are here
├── session-recall.py      ← Memory across sessions (the killer hook)
└── install-hooks.sh       ← One-command installer
```

## Quick Install

```bash
# From the repo root:
chmod +x hooks/install-hooks.sh
./hooks/install-hooks.sh
```

This copies `session-recall.py` to `~/.claude/hooks/` and sets up your `~/.claude/settings.json` with all three hooks configured.

## The Three Hooks

### 1. Session Recall (SessionStart) — The Killer Feature

**What it does:** At the start of every session, scans your last 48 hours of Claude Code conversations and injects one-line summaries into Claude's context. Claude instantly knows what you were working on yesterday without you having to explain.

**What Claude sees:**
```
Recent sessions:
- Mar 14 04:37 | fix auth middleware for API routes | last action: PR is open at https://github.com/...
- Mar 14 02:15 | debug Docker port conflict | last action: Fixed — container now runs on port 3001
- Mar 13 22:30 | add price chart to dashboard | last action: Committed feat: add 7-day price chart
```

**How it works:**
1. Reads `~/.claude/projects/<slug>/*.jsonl` (Claude's session history files)
2. Extracts the last user message and last assistant action from each recent session
3. Formats as a timestamped bullet list
4. Returns via Claude's hook protocol — injected as a system reminder

**Configuration (environment variables):**

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | `UTC` | Timezone for timestamps |
| `CLAUDE_RECALL_HOURS` | `48` | How far back to scan |
| `CLAUDE_RECALL_MAX_SESSIONS` | `5` | Max sessions to show |
| `CLAUDE_RECALL_MAX_CHARS` | `2000` | Total context budget |
| `CLAUDE_SESSION_RECALL_DIR` | auto-detected | Override session directory |

**Requirements:** Python 3.9+ (stdlib only, no pip install needed).

### 2. Workspace Announce (SessionStart)

**What it does:** Prints your current directory and git branch at the start of every session. A simple breadcrumb so Claude knows where it landed.

**What Claude sees:**
```
📍 /home/you/projects/my-app | branch: feat/add-dashboard
```

### 3. CWD Tracker (PostToolUse)

**What it does:** After every terminal command, prints the current directory and git branch. Prevents accidental drift when Claude `cd`s around during long sessions.

**What Claude sees (after every Bash call):**
```
CWD: /home/you/projects/my-app | Branch: feat/add-dashboard
```

## How Hooks Work

Hooks are configured in `~/.claude/settings.json` under the `"hooks"` key. They respond to four events:

| Event | When It Fires | Common Use |
|-------|--------------|------------|
| `SessionStart` | New session, resume, /clear, /compact | Load context, announce workspace |
| `PreToolUse` | Before any tool call | Block dangerous commands, validate |
| `PostToolUse` | After any tool call | Track state, format code |
| `Stop` | When Claude finishes a response | Notifications, logging |

### Hook Configuration Format

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [{
          "type": "command",
          "command": "python3 ~/.claude/hooks/session-recall.py",
          "statusMessage": "Loading recent session context..."
        }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "echo \"CWD: $(pwd)\""
        }]
      }
    ]
  }
}
```

**Key fields:**
- `type` — always `"command"`
- `command` — the shell command to run
- `matcher` — (optional) regex to filter which tools trigger the hook
- `statusMessage` — (optional) shown in the UI while the hook runs

### Hook Output Protocol

Hooks communicate with Claude via JSON on stdout:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "This text is injected into Claude's context"
  }
}
```

- **Exit code 0** — success, output is used
- **Exit code 2** — block the action (for `PreToolUse` hooks)
- **Non-zero** — Claude is notified of the failure

## Building Your Own Hooks

Hooks are just shell commands. They can be:
- A one-liner: `echo "$(date)"`
- A shell script: `bash ~/.claude/hooks/my-hook.sh`
- A Python script: `python3 ~/.claude/hooks/my-hook.py`
- Any executable: `~/.claude/hooks/my-binary`

**For PreToolUse hooks:** Read JSON from stdin (contains `tool_input` with the command about to run), decide whether to allow or block.

**Example — block `rm -rf /`:**
```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/'; then
  echo '{"decision": "block", "reason": "Blocked: rm -rf /"}'
  exit 2
fi
exit 0
```

## Combining with Safety Hooks

This repo also includes safety hooks in `claude-code-framework/essential/toolkit/templates/hooks/`:
- `protect-branches.sh` — prevents commits to main/production
- `block-dangerous-commands.sh` — blocks `rm -rf`, `git push --force`, etc.
- `block-env-reads.sh` — prevents reading .env files
- `verify-compliance.sh` — checks for hardcoded secrets before commits
- `auto-format.sh` — runs formatters after file writes

These are **PreToolUse** and **PostToolUse** hooks. They stack with the SessionStart hooks from this directory. See `claude-code-framework/essential/toolkit/templates/settings.json` for a full configuration example with all hooks combined.
