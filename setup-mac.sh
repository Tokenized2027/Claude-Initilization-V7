#!/bin/bash
# ============================================
# Claude Code — Mac Setup Script
# Run this once on a fresh Mac to get started
# ============================================

set -e

echo "========================================"
echo "  Claude Code — Mac Setup"
echo "========================================"
echo ""

# 1. Homebrew
if ! command -v brew &> /dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add to PATH (Apple Silicon vs Intel)
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  echo "  ✓ Homebrew installed"
else
  echo "  ✓ Homebrew already installed"
fi

# 2. Git
if ! command -v git &> /dev/null; then
  echo "→ Installing Git..."
  brew install git
  echo "  ✓ Git installed"
else
  echo "  ✓ Git already installed ($(git --version))"
fi

# 3. Node.js (via nvm)
if ! command -v node &> /dev/null; then
  echo "→ Installing Node.js via nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  echo "  ✓ Node.js installed ($(node --version))"
else
  echo "  ✓ Node.js already installed ($(node --version))"
fi

# 4. Claude Code CLI
if ! command -v claude &> /dev/null; then
  echo "→ Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code
  echo "  ✓ Claude Code installed"
else
  echo "  ✓ Claude Code already installed ($(claude --version 2>/dev/null || echo 'installed'))"
fi

# 5. Useful extras
echo "→ Installing useful tools..."
brew install jq ripgrep || true
echo "  ✓ jq + ripgrep installed"

# 6. Create project directory
mkdir -p ~/projects
echo "  ✓ ~/projects directory ready"

# 7. Git config reminder
echo ""
echo "========================================"
echo "  Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo ""
echo "  1. Set your git identity (if not already done):"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your@email.com\""
echo ""
echo "  2. Log in to Claude:"
echo "     claude"
echo "     (Follow the prompts to authenticate)"
echo ""
echo "  3. Start your first project:"
echo "     mkdir ~/projects/my-app && cd ~/projects/my-app"
echo "     git init"
echo "     claude"
echo ""
echo "  4. Read START_HERE.md in this folder for guides and resources."
echo ""
