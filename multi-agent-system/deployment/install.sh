#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# Claude Multi-Agent System — One-Command Installer
# Run this on your mini PC to set up everything.
# ═══════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPT_DIR")"
MEMORY_DIR="${CLAUDE_MEMORY_DIR:-$HOME/claude-memory}"
INSTALL_DIR="${CLAUDE_INSTALL_DIR:-$HOME/claude-multi-agent}"
RESOURCES_DIR="${CLAUDE_RESOURCES_DIR:-$HOME/Claude}"
LOG_FILE="/tmp/claude-multi-agent-install.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; echo "[$(date)] $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; echo "[$(date)] WARN: $1" >> "$LOG_FILE"; }
fail() { echo -e "${RED}[✗]${NC} $1"; echo "[$(date)] FAIL: $1" >> "$LOG_FILE"; exit 1; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Claude Multi-Agent System Installer"
echo "  Installing to: $INSTALL_DIR"
echo "  Memory dir:    $MEMORY_DIR"
echo "  Resources dir: $RESOURCES_DIR"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Install log: $LOG_FILE"
echo ""

# ── Step 1: Check Prerequisites ───────────────────────────────────────

info "Checking prerequisites..."

command -v node >/dev/null 2>&1 || fail "Node.js not found. Install: https://nodejs.org/"
command -v npm >/dev/null 2>&1 || fail "npm not found. Install with Node.js."
command -v python3 >/dev/null 2>&1 || fail "Python 3 not found. Install: https://python.org/"
command -v pip3 >/dev/null 2>&1 && PIP=pip3 || PIP=pip
command -v jq >/dev/null 2>&1 || { warn "jq not found. Claude Code hooks need it. Install: sudo apt install jq"; }
command -v claude >/dev/null 2>&1 || warn "Claude CLI not found. Install: npm install -g @anthropic-ai/claude-code"

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    fail "Node.js 18+ required. Current: $(node -v)"
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(sys.version_info.minor)')
if [ "$PYTHON_VERSION" -lt 10 ]; then
    fail "Python 3.10+ required. Current: $(python3 --version)"
fi

log "Prerequisites satisfied (Node $(node -v), Python $(python3 --version))"

# Check resources directory
if [ ! -d "$RESOURCES_DIR" ]; then
    warn "Resources directory not found: $RESOURCES_DIR"
    warn "Context router needs YOUR_WORKING_PROFILE.md and project-contexts/ here."
    warn "Set CLAUDE_RESOURCES_DIR env var or copy files to $RESOURCES_DIR"
fi

# ── Step 2: Create Directories ────────────────────────────────────────

info "Creating directories..."

mkdir -p "$INSTALL_DIR"
mkdir -p "$MEMORY_DIR/projects"
mkdir -p "$MEMORY_DIR/agents"
mkdir -p "$MEMORY_DIR/shared"

log "Directories created"

# ── Step 3: Copy System Files ─────────────────────────────────────────

info "Copying system files..."

cp -r "$SYSTEM_DIR/mcp-servers" "$INSTALL_DIR/"
cp -r "$SYSTEM_DIR/orchestrator" "$INSTALL_DIR/"
cp -r "$SYSTEM_DIR/agent-templates" "$INSTALL_DIR/"
cp -r "$SYSTEM_DIR/tests" "$INSTALL_DIR/" 2>/dev/null || true
cp -r "$SYSTEM_DIR/docs" "$INSTALL_DIR/" 2>/dev/null || true

# project_routes.json lives inside orchestrator/ (single source of truth).
# Verify it was copied with the directory.
if [ -f "$INSTALL_DIR/orchestrator/project_routes.json" ]; then
    log "project_routes.json present in orchestrator directory"
else
    warn "project_routes.json missing from orchestrator/ — task routing will use defaults only"
fi

log "System files copied to $INSTALL_DIR"

# ── Step 4: Install Memory MCP Server ─────────────────────────────────

info "Installing Memory MCP Server..."

cd "$INSTALL_DIR/mcp-servers/memory-server"
npm install >> "$LOG_FILE" 2>&1
npm run build >> "$LOG_FILE" 2>&1

log "Memory MCP Server installed and built"

# ── Step 5: Install Context Router MCP Server ─────────────────────────

info "Installing Context Router MCP Server..."

cd "$INSTALL_DIR/mcp-servers/context-router"
npm install >> "$LOG_FILE" 2>&1
npm run build >> "$LOG_FILE" 2>&1

log "Context Router MCP Server installed and built"

# ── Step 6: Install Orchestrator ──────────────────────────────────────

info "Installing Orchestrator..."

cd "$INSTALL_DIR/orchestrator"
python3 -m venv venv >> "$LOG_FILE" 2>&1
source venv/bin/activate
pip install -r requirements.txt >> "$LOG_FILE" 2>&1
deactivate

if [ ! -f "$INSTALL_DIR/orchestrator/.env" ]; then
    cp "$INSTALL_DIR/orchestrator/.env.example" "$INSTALL_DIR/orchestrator/.env"

    # Auto-generate a random orchestrator API key
    GENERATED_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    sed -i "s/CHANGE_ME_GENERATE_A_RANDOM_KEY/$GENERATED_KEY/" "$INSTALL_DIR/orchestrator/.env"

    warn "Created .env from template"
    warn "ORCHESTRATOR_API_KEY auto-generated: $GENERATED_KEY"
    warn "SAVE THIS KEY — you need it for all API requests (X-API-Key header)"
    warn "Still need to add: ANTHROPIC_API_KEY in $INSTALL_DIR/orchestrator/.env"
fi

log "Orchestrator installed"

# ── Step 7: Configure MCP ─────────────────────────────────────────────

info "Configuring MCP servers..."

MCP_CONFIG="$HOME/.claude/mcp.json"
mkdir -p "$HOME/.claude"

# ── Step 7a: Install Skills Globally ──────────────────────────────────

info "Installing skills to ~/.claude/skills/..."

SKILLS_SOURCE="$RESOURCES_DIR/claude-code-framework/essential/skills"
SKILLS_DEST="$HOME/.claude/skills"

if [ -d "$SKILLS_SOURCE" ]; then
    mkdir -p "$SKILLS_DEST"
    # Copy all skill category directories (skip README and scripts)
    for category_dir in "$SKILLS_SOURCE"/*/; do
        if [ -d "$category_dir" ]; then
            cp -r "$category_dir" "$SKILLS_DEST/"
        fi
    done
    SKILL_COUNT=$(find "$SKILLS_DEST" -name "SKILL.md" 2>/dev/null | wc -l)
    log "Installed $SKILL_COUNT skills to $SKILLS_DEST"
else
    warn "Skills source not found: $SKILLS_SOURCE"
    warn "Skills won't auto-load. Copy manually: cp -r <skills-dir>/* ~/.claude/skills/"
fi

MEMORY_SERVER_PATH="$INSTALL_DIR/mcp-servers/memory-server/dist/index.js"
CONTEXT_ROUTER_PATH="$INSTALL_DIR/mcp-servers/context-router/dist/index.js"

# Build the MCP config
cat > "$MCP_CONFIG" << MCPEOF
{
  "mcpServers": {
    "claude-memory": {
      "command": "node",
      "args": ["$MEMORY_SERVER_PATH"],
      "env": {
        "CLAUDE_MEMORY_DIR": "$MEMORY_DIR"
      }
    },
    "context-router": {
      "command": "node",
      "args": ["$CONTEXT_ROUTER_PATH"],
      "env": {
        "CLAUDE_RESOURCES_DIR": "$RESOURCES_DIR"
      }
    }
  }
}
MCPEOF

log "MCP configuration written to $MCP_CONFIG"

# ── Step 8: Create Systemd Services ──────────────────────────────────

info "Setting up systemd services..."

if command -v systemctl >/dev/null 2>&1; then

    sudo tee /etc/systemd/system/claude-orchestrator.service > /dev/null << SVCEOF
[Unit]
Description=Claude Agent Orchestrator
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$INSTALL_DIR/orchestrator
ExecStart=$INSTALL_DIR/orchestrator/venv/bin/python orchestrator.py
Restart=always
RestartSec=5
Environment=CLAUDE_MEMORY_DIR=$MEMORY_DIR
Environment=CLAUDE_RESOURCES_DIR=$RESOURCES_DIR

[Install]
WantedBy=multi-user.target
SVCEOF

    sudo systemctl daemon-reload
    sudo systemctl enable claude-orchestrator
    log "Systemd service created and enabled"
    warn "Start with: sudo systemctl start claude-orchestrator"
else
    warn "systemd not available — you'll need to run the orchestrator manually"
    info "Manual start: cd $INSTALL_DIR/orchestrator && source venv/bin/activate && python orchestrator.py"
fi

# ── Step 9: Verify Installation ──────────────────────────────────────

info "Verifying installation..."

ERRORS=0

[ -f "$MEMORY_SERVER_PATH" ] && log "Memory server binary: OK" || { warn "Memory server binary missing"; ERRORS=$((ERRORS+1)); }
[ -f "$CONTEXT_ROUTER_PATH" ] && log "Context router binary: OK" || { warn "Context router binary missing"; ERRORS=$((ERRORS+1)); }
[ -f "$INSTALL_DIR/orchestrator/venv/bin/python" ] && log "Orchestrator venv: OK" || { warn "Orchestrator venv missing"; ERRORS=$((ERRORS+1)); }
[ -f "$INSTALL_DIR/orchestrator/project_routes.json" ] && log "Task routing config: OK" || { warn "project_routes.json missing in orchestrator/ — routing will use defaults!"; ERRORS=$((ERRORS+1)); }
[ -f "$MCP_CONFIG" ] && log "MCP config: OK" || { warn "MCP config missing"; ERRORS=$((ERRORS+1)); }
[ -d "$MEMORY_DIR/projects" ] && log "Memory directory: OK" || { warn "Memory directory missing"; ERRORS=$((ERRORS+1)); }

SKILL_COUNT=$(find "$HOME/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l)
[ "$SKILL_COUNT" -ge 28 ] && log "Skills installed: $SKILL_COUNT skills" || { warn "Skills: only $SKILL_COUNT found (expected 28). Check ~/.claude/skills/"; ERRORS=$((ERRORS+1)); }

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "═══════════════════════════════════════════════════════════"
    echo -e "  ${GREEN}Installation Complete!${NC}"
    echo "═══════════════════════════════════════════════════════════"
else
    echo "═══════════════════════════════════════════════════════════"
    echo -e "  ${YELLOW}Installation completed with $ERRORS warnings${NC}"
    echo "═══════════════════════════════════════════════════════════"
fi

echo ""
echo "Next steps:"
echo ""
echo "  1. Add your Anthropic API key:"
echo "     nano $INSTALL_DIR/orchestrator/.env"
echo "     (Set ANTHROPIC_API_KEY — the ORCHESTRATOR_API_KEY was auto-generated)"
echo ""
echo "  2. Start the orchestrator:"
echo "     sudo systemctl start claude-orchestrator"
echo "     — or —"
echo "     cd $INSTALL_DIR/orchestrator && source venv/bin/activate && python orchestrator.py"
echo ""
echo "  3. Test the system:"
echo "     bash $INSTALL_DIR/tests/test-system.sh"
echo ""
echo "  4. Submit your first task (use your ORCHESTRATOR_API_KEY from .env):"
echo "     curl -X POST http://localhost:8000/route \\"
echo "       -H 'Content-Type: application/json' \\"
echo "       -H 'X-API-Key: YOUR_ORCHESTRATOR_KEY' \\"
echo "       -d '{\"task\": \"Build hello world dashboard\", \"project\": \"test\"}'"
echo ""
echo "  5. Check health:"
echo "     curl http://localhost:8000/health"
echo ""
echo "Install log: $LOG_FILE"
echo ""
