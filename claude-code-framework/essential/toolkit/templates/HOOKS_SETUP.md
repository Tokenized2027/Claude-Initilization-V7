# Claude Code Hooks — Setup Guide & Templates

> Hooks are shell scripts that Claude Code runs automatically before or after tool calls.
> They use the **real Claude Code hooks API** with JSON stdin/stdout and exit codes.
>
> **Official docs:** https://code.claude.com/docs/en/hooks

---

## How Claude Code Hooks Work

Hooks are configured in `settings.json` (project-level at `.claude/settings.json` or user-level at `~/.claude/settings.json`). Each hook has:

- **Event** — When it fires (`PreToolUse`, `PostToolUse`, `Stop`, etc.)
- **Matcher** — Which tools trigger it (regex on tool name: `Bash`, `Write|Edit`, etc.)
- **Command** — Shell command to run
- **Type** — `command` (shell script), `prompt` (Claude prompt), or `agent` (sub-agent)

### Hook Events

| Event | When It Fires | Common Use |
|-------|--------------|------------|
| `PreToolUse` | Before Claude uses a tool | Block dangerous commands, prevent file access |
| `PostToolUse` | After Claude uses a tool | Auto-format, log actions, validate output |
| `Stop` | When Claude finishes a response | Update STATUS.md, run final checks |
| `UserPromptSubmit` | When user sends a message | Inject context, validate input |
| `SessionStart` | When a Claude Code session begins | Load project context, check environment |

### Tool Names (Matchers)

| Matcher | What It Catches |
|---------|----------------|
| `Bash` | Terminal/shell commands |
| `Read` | File reads |
| `Write` | File creation |
| `Edit` | File edits |
| `Write\|Edit` | Any file modification |
| `Read\|Write\|Edit` | Any file operation |
| `Glob` | File search |
| `Grep` | Content search |
| `Task` | Subagent launches |

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Allow — proceed normally |
| `2` | Block — prevent the tool use, show reason to Claude |

### JSON Protocol

**Input (stdin):** Claude Code pipes JSON with the tool call details:
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push --force origin main"
  }
}
```

**Output (stdout):** When blocking (exit 2), output JSON with a reason:
```json
{
  "decision": "block",
  "reason": "Cannot force-push to main branch."
}
```

---

## Hook 1: Protected Branch Guard

**Event:** `PreToolUse` | **Matcher:** `Bash`
**Purpose:** Blocks git commits and pushes to protected branches.

```bash
#!/bin/bash
# .claude/hooks/protect-branches.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if ! echo "$COMMAND" | grep -qE '^\s*git\s+(commit|push)'; then
  exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
PROTECTED_BRANCHES=("main" "production" "master")

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" == "$branch" ]; then
    echo "{\"decision\": \"block\", \"reason\": \"Cannot commit/push to '$branch'. Create a feature branch first.\"}" | jq .
    exit 2
  fi
done
exit 0
```

---

## Hook 2: Dangerous Command Prevention

**Event:** `PreToolUse` | **Matcher:** `Bash`
**Purpose:** Blocks commands that could permanently delete code or data.

```bash
#!/bin/bash
# .claude/hooks/block-dangerous-commands.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

DANGEROUS_PATTERNS=(
  "rm -rf /" "rm -rf ~" "rm -rf \."
  "git push --force" "git push -f"
  "git clean -fdx" "git reset --hard HEAD~"
  "DROP TABLE" "DROP DATABASE" "TRUNCATE TABLE"
)

COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  PATTERN_LOWER=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
  if echo "$COMMAND_LOWER" | grep -qF "$PATTERN_LOWER"; then
    echo "{\"decision\": \"block\", \"reason\": \"Blocked dangerous command: '$pattern'. Run manually if needed.\"}" | jq .
    exit 2
  fi
done
exit 0
```

---

## Hook 3: Block .env File Access

**Event:** `PreToolUse` | **Matcher:** `Read|Edit|Write`
**Purpose:** Prevents Claude from reading or modifying .env files containing secrets.

```bash
#!/bin/bash
# .claude/hooks/block-env-reads.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')
FILENAME=$(basename "$FILE_PATH" 2>/dev/null)

if echo "$FILENAME" | grep -qE '^\.env$|^\.env\.local$|^\.env\.production$|^\.env\.development$'; then
  echo "{\"decision\": \"block\", \"reason\": \"Blocked access to '$FILENAME' — may contain secrets. Use .env.example for templates.\"}" | jq .
  exit 2
fi
exit 0
```

---

## Hook 4: Pre-Commit Compliance Check

**Event:** `PreToolUse` | **Matcher:** `Bash`
**Purpose:** Verifies compliance before git commit — checks for partial file markers, hardcoded secrets, staged .env, and missing CLAUDE.md.

```bash
#!/bin/bash
# .claude/hooks/verify-compliance.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

VIOLATIONS=0
REASONS=""
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

# Check for partial file markers
MARKERS=("rest stays the same" "remaining code unchanged" "... existing code ..." "TRUNCATED")
if [ -n "$STAGED_FILES" ]; then
  for marker in "${MARKERS[@]}"; do
    if echo "$STAGED_FILES" | xargs grep -li "$marker" 2>/dev/null; then
      REASONS="${REASONS}Partial file marker '${marker}' found. "
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done
fi

# Check for hardcoded secrets
if [ -n "$STAGED_FILES" ]; then
  if echo "$STAGED_FILES" | xargs grep -lE "sk-ant-|AKIA[A-Z0-9]{16}" 2>/dev/null | grep -v ".md" | grep -v ".env.example"; then
    REASONS="${REASONS}Possible hardcoded secret in staged files. "
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
fi

# Check .env not staged
if git diff --cached --name-only 2>/dev/null | grep -q "^\.env$"; then
  REASONS="${REASONS}.env is staged — add to .gitignore. "
  VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "{\"decision\": \"block\", \"reason\": \"${VIOLATIONS} violation(s): ${REASONS}\"}" | jq .
  exit 2
fi
exit 0
```

---

## Hook 5: Auto-Format After File Changes

**Event:** `PostToolUse` | **Matcher:** `Write|Edit`
**Purpose:** Runs Prettier, ESLint, or Black after Claude writes or edits files.

```bash
#!/bin/bash
# .claude/hooks/auto-format.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
EXT="${FILE_PATH##*.}"

# JavaScript/TypeScript
if echo "$EXT" | grep -qE '^(js|jsx|ts|tsx|css|json)$'; then
  if [ -f "package.json" ] && command -v npx &>/dev/null; then
    grep -q "prettier" package.json 2>/dev/null && npx prettier --write "$FILE_PATH" 2>/dev/null
  fi
fi

# Python
if [ "$EXT" = "py" ]; then
  command -v black &>/dev/null && black "$FILE_PATH" --quiet 2>/dev/null
fi

exit 0
```

---

## settings.json Configuration

Configure hooks in your `.claude/settings.json` using the real API format:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git push *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(npm install *)",
      "Bash(npm run *)",
      "Bash(npm test *)",
      "Bash(npx *)",
      "Bash(pip install *)",
      "Bash(python *)",
      "Bash(pytest *)",
      "Bash(docker compose *)",
      "Bash(docker build *)",
      "Bash(ls *)",
      "Bash(mkdir *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(git reset --hard *)",
      "Read(.env)",
      "Read(.env.local)",
      "Read(.env.production)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/protect-branches.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/block-dangerous-commands.sh"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/verify-compliance.sh"
          }
        ]
      },
      {
        "matcher": "Read|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block-env-reads.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/auto-format.sh"
          }
        ]
      }
    ]
  }
}
```

### Permission Syntax

Permissions use the `Tool(specifier)` format:

| Pattern | What It Allows/Denies |
|---------|----------------------|
| `Bash(git status)` | Exact command: `git status` |
| `Bash(git *)` | Any git command |
| `Bash(npm run *)` | Any npm run command |
| `Read(.env)` | Reading .env file |
| `Write(src/**)` | Writing any file under src/ |

### How Matchers Work

Matchers are **regex patterns** matched against tool names:

- `Bash` — matches only Bash tool
- `Write|Edit` — matches Write OR Edit
- `Read|Write|Edit` — matches any file operation
- `.*` — matches everything (use with caution)

---

## Setup Instructions

Copy the hooks to your project:

```bash
# Create hooks directory
mkdir -p .claude/hooks

# Copy all hook scripts
cp $CLAUDE_HOME/claude-code-framework/essential/toolkit/templates/hooks/*.sh .claude/hooks/

# Copy settings.json template
cp $CLAUDE_HOME/claude-code-framework/essential/toolkit/templates/settings.json .claude/settings.json

# Make hooks executable (Linux/Mac)
chmod +x .claude/hooks/*.sh
```

Or ask Claude Code:
```
Set up the hooks system for this project:
1. Create .claude/hooks/ directory
2. Copy the 5 hook scripts (protect-branches, block-dangerous-commands,
   block-env-reads, verify-compliance, auto-format)
3. Create .claude/settings.json with hooks config and allowed commands
4. Make all hook scripts executable
```

---

## Customizing Hooks

### Adding Your Own Hook

1. Create a script that reads JSON from stdin
2. Exit 0 to allow, exit 2 to block
3. Output JSON with `reason` when blocking
4. Add it to `settings.json` under the appropriate event and matcher

**Example: Block writes to specific directories**

```bash
#!/bin/bash
# .claude/hooks/protect-directories.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Block writes to config/ directory
if echo "$FILE_PATH" | grep -q "^config/"; then
  echo "{\"decision\": \"block\", \"reason\": \"Config directory is protected. Edit configs manually.\"}" | jq .
  exit 2
fi
exit 0
```

Add to settings.json:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/protect-directories.sh"
          }
        ]
      }
    ]
  }
}
```

### Using Prompt Hooks

Instead of shell scripts, you can use prompt hooks that tell Claude what to do:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Before finishing, verify: 1) STATUS.md is updated, 2) All files are complete (no partial markers), 3) Error handling is present in new code."
          }
        ]
      }
    ]
  }
}
```

---

## Troubleshooting

### Hook not firing
- Check the event name is correct (`PreToolUse`, not `pre-tool-use`)
- Check the matcher regex matches the tool name
- Verify the script is executable: `chmod +x .claude/hooks/your-hook.sh`
- Check `jq` is installed: `jq --version`

### Hook fires but doesn't block
- Verify exit code is `2` (not `1`) to block
- Check JSON output is valid: pipe through `jq .`
- Test your script manually: `echo '{"tool_name":"Bash","tool_input":{"command":"git push --force"}}' | bash .claude/hooks/your-hook.sh; echo "Exit: $?"`

### Hook blocks everything
- Check your matcher isn't too broad (avoid `.*` on PreToolUse)
- Ensure the script exits `0` for non-matching commands
- Test with a simple command to verify the filter logic
