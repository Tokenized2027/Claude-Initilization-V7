#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════
# Claude Multi-Agent System — Uninstaller
# Removes services, configs, and optionally memory data.
# ═══════════════════════════════════════════════════════════════════════

INSTALL_DIR="${CLAUDE_INSTALL_DIR:-$HOME/claude-multi-agent}"
MEMORY_DIR="${CLAUDE_MEMORY_DIR:-$HOME/claude-memory}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Claude Multi-Agent System Uninstaller"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Stop and remove systemd service
if command -v systemctl >/dev/null 2>&1; then
    if systemctl is-active --quiet claude-orchestrator 2>/dev/null; then
        echo -e "${YELLOW}Stopping orchestrator service...${NC}"
        sudo systemctl stop claude-orchestrator
    fi
    if [ -f /etc/systemd/system/claude-orchestrator.service ]; then
        echo -e "${YELLOW}Removing systemd service...${NC}"
        sudo systemctl disable claude-orchestrator 2>/dev/null || true
        sudo rm -f /etc/systemd/system/claude-orchestrator.service
        sudo systemctl daemon-reload
        echo -e "${GREEN}[✓]${NC} Systemd service removed"
    fi
fi

# Remove install directory
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Removing installation: $INSTALL_DIR${NC}"
    rm -rf "$INSTALL_DIR"
    echo -e "${GREEN}[✓]${NC} Installation removed"
fi

# Remove MCP config entries (keep file, remove our servers)
MCP_CONFIG="$HOME/.claude/mcp.json"
if [ -f "$MCP_CONFIG" ]; then
    echo -e "${YELLOW}Note: MCP config at $MCP_CONFIG may still reference removed servers.${NC}"
    echo "  Edit it manually if needed: nano $MCP_CONFIG"
fi

# Ask about memory data
echo ""
read -p "Delete memory data at $MEMORY_DIR? (y/N): " DELETE_MEMORY
if [[ "$DELETE_MEMORY" =~ ^[Yy]$ ]]; then
    rm -rf "$MEMORY_DIR"
    echo -e "${GREEN}[✓]${NC} Memory data deleted"
else
    echo -e "${GREEN}[✓]${NC} Memory data preserved at $MEMORY_DIR"
fi

echo ""
echo -e "${GREEN}Uninstall complete.${NC}"
echo ""
