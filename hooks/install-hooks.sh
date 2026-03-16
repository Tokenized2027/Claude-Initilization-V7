#!/bin/bash
# ============================================
# Claude Code Hooks — Installer
# Copies hooks to ~/.claude/hooks/ and updates
# your settings.json with hook configuration.
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "========================================"
echo "  Claude Code Hooks — Installer"
echo "========================================"
echo ""

# 1. Create hooks directory
mkdir -p "$HOOKS_DIR"
echo "  Created $HOOKS_DIR"

# 2. Copy session-recall.py
cp "$SCRIPT_DIR/session-recall.py" "$HOOKS_DIR/session-recall.py"
chmod +x "$HOOKS_DIR/session-recall.py"
echo "  Installed session-recall.py"

# 3. Check Python 3.9+ is available
if command -v python3 &> /dev/null; then
  PY_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
  echo "  Python $PY_VERSION detected"
else
  echo "  WARNING: python3 not found. Session recall hook requires Python 3.9+"
fi

# 4. Update settings.json with hook configuration
echo ""

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "  No settings.json found at $SETTINGS_FILE"
  echo "  Creating one with hook configuration..."
  cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npx *)",
      "Bash(node *)",
      "Bash(git *)",
      "Bash(ls *)",
      "Bash(mkdir *)",
      "Bash(cat *)",
      "Bash(which *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ],
    "deny": []
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"startup hook success: $(echo \"📍 $(pwd) | branch: $(git branch --show-current 2>/dev/null || echo 'not a git repo')\")\"",
            "statusMessage": "Checking workspace..."
          }
        ]
      },
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/session-recall.py",
            "statusMessage": "Loading recent session context..."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"CWD: $(pwd) | Branch: $(git branch --show-current 2>/dev/null || echo 'n/a')\"",
            "statusMessage": "Tracking workspace..."
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  echo "  Created $SETTINGS_FILE with hooks"
else
  echo "  settings.json already exists at $SETTINGS_FILE"
  echo ""
  echo "  To add hooks manually, add these to your settings.json:"
  echo ""
  echo '  "hooks": {'
  echo '    "SessionStart": ['
  echo '      {'
  echo '        "hooks": [{'
  echo '          "type": "command",'
  echo '          "command": "echo \"startup hook success: $(echo \"📍 $(pwd) | branch: $(git branch --show-current 2>/dev/null || echo '"'"'not a git repo'"'"')\")\"",'
  echo '          "statusMessage": "Checking workspace..."'
  echo '        }]'
  echo '      },'
  echo '      {'
  echo '        "hooks": [{'
  echo '          "type": "command",'
  echo '          "command": "python3 ~/.claude/hooks/session-recall.py",'
  echo '          "statusMessage": "Loading recent session context..."'
  echo '        }]'
  echo '      }'
  echo '    ],'
  echo '    "PostToolUse": [{'
  echo '      "matcher": "Bash",'
  echo '      "hooks": [{'
  echo '        "type": "command",'
  echo '        "command": "echo \"CWD: $(pwd) | Branch: $(git branch --show-current 2>/dev/null || echo '"'"'n/a'"'"')\"" '
  echo '      }]'
  echo '    }]'
  echo '  }'
  echo ""
fi

echo ""
echo "========================================"
echo "  Hooks installed!"
echo "========================================"
echo ""
echo "What was installed:"
echo "  1. Session Recall    — loads last 48h of session summaries at startup"
echo "  2. Workspace Announce — shows current directory and git branch at startup"
echo "  3. CWD Tracker       — prints directory after every terminal command"
echo ""
echo "Configure via environment variables (add to ~/.zshrc or ~/.bashrc):"
echo "  export TZ=\"America/New_York\"          # Timezone for timestamps"
echo "  export CLAUDE_RECALL_HOURS=48          # How far back to scan"
echo "  export CLAUDE_RECALL_MAX_SESSIONS=5    # Max sessions to show"
echo "  export CLAUDE_RECALL_MAX_CHARS=2000    # Context budget"
echo ""
echo "To test session recall:"
echo "  echo '{}' | python3 ~/.claude/hooks/session-recall.py"
echo ""
echo "Start a new Claude Code session to see hooks in action."
