#!/bin/bash
# Memory Manager v4.4
# Manages persistent memory across Claude Code sessions

set -euo pipefail

MEMORY_DIR=".claude/memory"
GLOBAL_MEMORY="$HOME/.claude/global-memory"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_info() { echo -e "${YELLOW}ℹ${NC} $1"; }

# Check if in project root
check_project() {
    if [ ! -d ".claude" ]; then
        log_error "Not in a Claude Code project root. Run from project directory."
        exit 1
    fi
}

# Initialize memory structure
init_memory() {
    log_info "Initializing memory system..."

    mkdir -p "$MEMORY_DIR/cross-project"

    # Copy templates if they don't exist
    if [ ! -f "$MEMORY_DIR/decisions.json" ]; then
        # Look for templates in the framework toolkit
        TEMPLATE_DIRS=(
            "$HOME/Desktop/Claude/claude-code-framework/essential/toolkit/templates/memory"
            "$HOME/Claude/claude-code-framework/essential/toolkit/templates/memory"
        )
        FOUND_TEMPLATES=""
        for tdir in "${TEMPLATE_DIRS[@]}"; do
            if [ -d "$tdir" ]; then
                FOUND_TEMPLATES="$tdir"
                break
            fi
        done

        if [ -n "$FOUND_TEMPLATES" ]; then
            cp "$FOUND_TEMPLATES"/*.json "$MEMORY_DIR/" 2>/dev/null || true
            cp "$FOUND_TEMPLATES"/*.md "$MEMORY_DIR/" 2>/dev/null || true
            log_success "Memory templates installed from $FOUND_TEMPLATES"
        else
            # Create minimal templates
            echo '{"decisions": []}' > "$MEMORY_DIR/decisions.json"
            echo '{"sessions": []}' > "$MEMORY_DIR/session-history.json"
            echo '{}' > "$MEMORY_DIR/project-context.json"
            touch "$MEMORY_DIR/patterns.md"
            touch "$MEMORY_DIR/preferences.md"
            log_success "Memory structure created"
        fi
    else
        log_info "Memory already initialized"
    fi
}

# Start session: Load memory into context
start_session() {
    check_project
    init_memory

    log_info "Starting Claude Code session with memory..."

    # Generate context prompt
    cat > /tmp/session-start.txt <<EOF
# Session Start Context

Loading memory for this project...

## Preferences
$(cat "$MEMORY_DIR/preferences.md" 2>/dev/null || echo "No preferences set")

## Recent Decisions (last 5)
$(jq -r '.decisions[-5:] | .[] | "- [\(.date)] \(.decision)"' "$MEMORY_DIR/decisions.json" 2>/dev/null || echo "No decisions recorded")

## Known Patterns
$(head -50 "$MEMORY_DIR/patterns.md" 2>/dev/null || echo "No patterns recorded")

## Current Project State
$(cat "$MEMORY_DIR/project-context.json" 2>/dev/null || echo "{}")

## Last Session
$(jq -r '.sessions[-1] | "Goal: \(.goal)\nAccomplished: \(.accomplished | join(", "))\nNext: \(.next_session_focus)"' "$MEMORY_DIR/session-history.json" 2>/dev/null || echo "No previous session")

Ready to start work. Memory loaded.
EOF

    log_success "Memory context generated"
    log_info "Starting Claude Code..."

    # Launch Claude Code with context
    claude < /tmp/session-start.txt
}

# End session: Save memory
end_session() {
    check_project

    log_info "Ending session and saving memory..."

    claude <<EOF
Session ending. Please:

1. Summarize what we accomplished today
2. Update .claude/memory/project-context.json with current project state
3. Add any new patterns learned to .claude/memory/patterns.md
4. Note any decisions made in .claude/memory/decisions.json
5. Create session summary in .claude/memory/session-history.json
6. List next steps for next session

Save all updates to memory files.
EOF

    log_success "Session summary saved"
}

# Add decision manually
add_decision() {
    check_project

    echo "Add Decision to Memory"
    echo "====================="
    read -p "Category [architecture/tech/design/process]: " category
    read -p "Decision: " decision
    read -p "Rationale: " rationale
    read -p "Alternatives considered (comma-separated): " alternatives
    read -p "Impact: " impact
    read -p "Related files (comma-separated): " files

    claude <<EOF
Add this decision to .claude/memory/decisions.json:

Category: $category
Decision: $decision
Rationale: $rationale
Alternatives: $alternatives
Impact: $impact
Related files: $files
Date: $(date +%Y-%m-%d)
Status: active

Generate unique decision ID and append to decisions array.
EOF

    log_success "Decision added to memory"
}

# Show decisions
show_decisions() {
    check_project

    log_info "Decisions from memory:"
    jq -r '.decisions | .[] | "\n[\(.id)] \(.date) - \(.category)\n  Decision: \(.decision)\n  Rationale: \(.rationale)\n  Status: \(.status)"' "$MEMORY_DIR/decisions.json"
}

# Show patterns
show_patterns() {
    check_project

    log_info "Patterns from memory:"
    cat "$MEMORY_DIR/patterns.md"
}

# Sync to global memory
sync_global() {
    check_project

    log_info "Syncing patterns to global memory..."

    mkdir -p "$GLOBAL_MEMORY"

    # Extract patterns by category
    claude <<EOF
Read .claude/memory/patterns.md

Extract patterns and sync to global memory:
- React/Next.js patterns → $GLOBAL_MEMORY/react-patterns.md
- API/Backend patterns → $GLOBAL_MEMORY/api-patterns.md
- Database patterns → $GLOBAL_MEMORY/database-patterns.md
- Testing patterns → $GLOBAL_MEMORY/testing-patterns.md
- Common bugs → $GLOBAL_MEMORY/common-bugs.md

Append (don't overwrite) to preserve patterns from other projects.
EOF

    log_success "Synced to global memory at $GLOBAL_MEMORY"
}

# Import from global memory
import_global() {
    check_project

    log_info "Importing from global memory..."

    if [ -d "$GLOBAL_MEMORY" ]; then
        cp "$GLOBAL_MEMORY"/*.md "$MEMORY_DIR/cross-project/" 2>/dev/null || true
        log_success "Imported global patterns to .claude/memory/cross-project/"
    else
        log_error "Global memory not found at $GLOBAL_MEMORY"
    fi
}

# Backup memory
backup_memory() {
    check_project

    BACKUP_DIR=".claude/memory-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$MEMORY_DIR"/* "$BACKUP_DIR/"

    log_success "Memory backed up to $BACKUP_DIR"
}

# Clean old sessions (keep last 3 months)
clean_old() {
    check_project

    log_info "Cleaning old session history..."

    claude <<EOF
Read .claude/memory/session-history.json

Keep only sessions from last 90 days.
Remove older sessions to keep file manageable.
Update session-history.json.
EOF

    log_success "Old sessions cleaned"
}

# Show statistics
show_stats() {
    check_project

    log_info "Memory Statistics"
    echo "================="

    DECISIONS=$(jq '.decisions | length' "$MEMORY_DIR/decisions.json" 2>/dev/null || echo "0")
    SESSIONS=$(jq '.sessions | length' "$MEMORY_DIR/session-history.json" 2>/dev/null || echo "0")
    MEMORY_SIZE=$(du -sh "$MEMORY_DIR" | cut -f1)

    echo "Decisions: $DECISIONS"
    echo "Sessions recorded: $SESSIONS"
    echo "Memory size: $MEMORY_SIZE"

    log_success "Stats displayed"
}

# Main command dispatcher
case "${1:-help}" in
    start)
        start_session
        ;;
    end)
        end_session
        ;;
    init)
        init_memory
        ;;
    add-decision)
        add_decision
        ;;
    show-decisions)
        show_decisions
        ;;
    show-patterns)
        show_patterns
        ;;
    sync)
        sync_global
        ;;
    import)
        import_global
        ;;
    backup)
        backup_memory
        ;;
    clean)
        clean_old
        ;;
    stats)
        show_stats
        ;;
    help|*)
        cat <<EOF
Memory Manager v4.4

Usage: ./memory-manager.sh [command]

Commands:
  start              Start session with memory loaded
  end                End session and save memory
  init               Initialize memory structure
  add-decision       Manually add decision
  show-decisions     Display all decisions
  show-patterns      Display all patterns
  sync               Sync patterns to global memory
  import             Import from global memory
  backup             Backup all memory files
  clean              Clean old session history
  stats              Show memory statistics
  help               Show this help

Examples:
  ./memory-manager.sh start
  ./memory-manager.sh end
  ./memory-manager.sh add-decision
  ./memory-manager.sh sync

See: guides/MEMORY_SYSTEM.md for full documentation
EOF
        ;;
esac
