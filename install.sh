#!/usr/bin/env bash
# ==========================================================================
# Claude Code Initialization Kit — One-Line Installer
# --------------------------------------------------------------------------
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Tokenized2027/Claude-Initialization-V7/main/install.sh | bash
#
# Or clone first and run locally:
#   git clone https://github.com/Tokenized2027/Claude-Initialization-V7.git
#   cd Claude-Initialization-V7 && ./install.sh
#
# What this does:
#   1. Checks prerequisites (git, node, python3, claude CLI).
#   2. Clones the repo to $CLAUDE_HOME (default: ~/Claude) if not already present.
#   3. Copies dot-claude/settings.json to ~/.claude/settings.json (with backup).
#   4. Installs the session recall + safety hooks to ~/.claude/hooks/.
#   5. Seeds ~/.claude/projects/.../memory/MEMORY.md from the template.
#   6. Prints next steps.
#
# Supports: macOS, Linux, WSL. For native Windows PowerShell, see README.md.
#
# Environment variables (optional):
#   CLAUDE_HOME    — install location (default: $HOME/Claude)
#   SKIP_HOOKS     — set to 1 to skip hook install
#   SKIP_MEMORY    — set to 1 to skip memory bootstrap
#   NO_COLOR       — set to 1 to disable colored output
# ==========================================================================

set -euo pipefail

# --- Colors (auto-disabled on NO_COLOR or non-TTY) ---
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'; C_RESET=$'\033[0m'
else
  C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_RESET=""
fi

info()  { printf "%s==>%s %s\n" "$C_BLUE$C_BOLD" "$C_RESET" "$*"; }
ok()    { printf "%s OK%s %s\n" "$C_GREEN$C_BOLD" "$C_RESET" "$*"; }
warn()  { printf "%s!!%s  %s\n" "$C_YELLOW$C_BOLD" "$C_RESET" "$*"; }
fail()  { printf "%sXX%s  %s\n" "$C_RED$C_BOLD"   "$C_RESET" "$*" >&2; exit 1; }
note()  { printf "%s%s%s\n" "$C_DIM" "$*" "$C_RESET"; }

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/Claude}"
REPO_URL="https://github.com/Tokenized2027/Claude-Initialization-V7.git"

# --- 1. Platform detect ---
case "$(uname -s)" in
  Darwin*)  PLATFORM="macos" ;;
  Linux*)   PLATFORM="linux" ;;
  MINGW*|CYGWIN*|MSYS*) PLATFORM="windows-wsl" ;;
  *) fail "Unsupported platform: $(uname -s). See README.md for native Windows." ;;
esac
info "Platform detected: $PLATFORM"

# --- 2. Prereq check ---
MISSING=()
for cmd in git curl python3; do
  command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  warn "Missing prerequisites: ${MISSING[*]}"
  if [ "$PLATFORM" = "macos" ] && command -v brew >/dev/null 2>&1; then
    info "Install with: brew install ${MISSING[*]}"
  elif [ "$PLATFORM" = "linux" ]; then
    info "Install with: sudo apt-get install -y ${MISSING[*]}"
  fi
  fail "Install the missing tools first, then re-run."
fi

if ! command -v node >/dev/null 2>&1; then
  warn "node is not installed. Claude Code CLI needs Node 20 or newer."
  info "Install Node: https://nodejs.org  (or: brew install node / nvm install 20)"
fi

if ! command -v claude >/dev/null 2>&1; then
  warn "claude CLI not found."
  info "Install after Node: npm install -g @anthropic-ai/claude-code"
fi

# --- 3. Clone or use existing checkout ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
if [ -f "$SCRIPT_DIR/VERSION" ] && [ -d "$SCRIPT_DIR/hooks" ]; then
  # Running from inside a local clone.
  REPO_DIR="$SCRIPT_DIR"
  info "Using local checkout at $REPO_DIR"
else
  if [ -d "$CLAUDE_HOME/.git" ]; then
    info "Existing checkout at $CLAUDE_HOME (pulling latest)"
    git -C "$CLAUDE_HOME" pull --ff-only || warn "git pull failed; continuing with current state"
  else
    info "Cloning into $CLAUDE_HOME"
    git clone --depth 1 "$REPO_URL" "$CLAUDE_HOME"
  fi
  REPO_DIR="$CLAUDE_HOME"
fi
ok "Repo ready at $REPO_DIR"

# --- 4. settings.json (with backup) ---
SETTINGS_SRC="$REPO_DIR/dot-claude/settings.json"
SETTINGS_DST="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [ -f "$SETTINGS_SRC" ]; then
  if [ -f "$SETTINGS_DST" ]; then
    BACKUP="$SETTINGS_DST.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$SETTINGS_DST" "$BACKUP"
    note "Existing settings.json backed up to $BACKUP"
  fi
  cp "$SETTINGS_SRC" "$SETTINGS_DST"
  ok "settings.json installed"
else
  warn "No $SETTINGS_SRC found; skipping"
fi

# --- 5. Hooks ---
if [ "${SKIP_HOOKS:-0}" != "1" ] && [ -x "$REPO_DIR/hooks/install-hooks.sh" ]; then
  info "Installing hooks"
  "$REPO_DIR/hooks/install-hooks.sh"
  ok "Hooks installed"
else
  note "Skipping hooks (SKIP_HOOKS=1 or installer missing)"
fi

# --- 6. Memory bootstrap ---
if [ "${SKIP_MEMORY:-0}" != "1" ] && [ -f "$REPO_DIR/memory/MEMORY.md" ]; then
  # Claude Code stores per-project memory under ~/.claude/projects/<slug>/memory/.
  # Seed a default slug so the user has a working starting point.
  DEFAULT_SLUG="-home-$(whoami)"
  MEM_DIR="$HOME/.claude/projects/$DEFAULT_SLUG/memory"
  mkdir -p "$MEM_DIR"
  if [ ! -f "$MEM_DIR/MEMORY.md" ]; then
    cp "$REPO_DIR/memory/MEMORY.md" "$MEM_DIR/MEMORY.md"
    ok "Memory template seeded at $MEM_DIR/MEMORY.md"
  else
    note "Memory already exists at $MEM_DIR/MEMORY.md (leaving it alone)"
  fi
else
  note "Skipping memory bootstrap"
fi

# --- 7. CLAUDE_HOME env hint ---
SHELL_RC=""
case "${SHELL:-}" in
  */zsh)  SHELL_RC="$HOME/.zshrc" ;;
  */bash) SHELL_RC="$HOME/.bashrc" ;;
esac

if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ] && ! grep -q "CLAUDE_HOME" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# Added by Claude Initialization Kit installer" >> "$SHELL_RC"
  echo "export CLAUDE_HOME=\"$REPO_DIR\"" >> "$SHELL_RC"
  ok "CLAUDE_HOME exported in $SHELL_RC (open a new shell to pick it up)"
fi

# --- Done ---
cat <<EOF

${C_GREEN}${C_BOLD}Install complete.${C_RESET}

Next steps:
  1. ${C_BOLD}Open a new terminal${C_RESET} so CLAUDE_HOME is picked up.
  2. ${C_BOLD}Start your first project${C_RESET}:

       mkdir -p ~/projects/my-app && cd ~/projects/my-app && git init
       cp \$CLAUDE_HOME/examples/CLAUDE.md ./CLAUDE.md
       claude

  3. ${C_BOLD}Browse examples${C_RESET}:
       ls \$CLAUDE_HOME/examples/

  4. ${C_BOLD}Read what got installed${C_RESET}:
       \$CLAUDE_HOME/hooks/README.md
       \$CLAUDE_HOME/hooks/SAFETY.md

Docs: https://github.com/Tokenized2027/Claude-Initialization-V7
EOF
