#!/bin/bash
# Sprint Planner v4.4
# Automates sprint planning, tracking, and retrospectives

set -euo pipefail

DOCS_DIR="docs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_info() { echo -e "${YELLOW}ℹ${NC} $1"; }
log_step() { echo -e "${BLUE}▸${NC} $1"; }

# Check if in project
check_project() {
    if [ ! -d "$DOCS_DIR" ]; then
        log_error "No docs/ directory found. Run from project root."
        exit 1
    fi
}

# Get next sprint number
get_next_sprint() {
    LAST_SPRINT=$(ls "$DOCS_DIR"/SPRINT_*.md 2>/dev/null | sed 's/.*SPRINT_\([0-9]*\).md/\1/' | sort -n | tail -1)
    echo $((LAST_SPRINT + 1))
}

# Get velocity from last 3 sprints
get_velocity() {
    claude <<EOF
Read the last 3 sprint files in docs/SPRINT_*.md

Calculate average velocity:
1. For each sprint, find "Completed Points"
2. Calculate average
3. Output just the number

If no sprints found, output: 15
EOF
}

# Plan new sprint
plan_sprint() {
    check_project

    log_step "Starting Sprint Planning..."

    SPRINT_NUM=$(get_next_sprint)
    SPRINT_FILE="$DOCS_DIR/SPRINT_$SPRINT_NUM.md"

    log_info "Planning Sprint $SPRINT_NUM"

    # Check if backlog exists
    if [ ! -f "$DOCS_DIR/BACKLOG.md" ]; then
        log_error "No BACKLOG.md found. Create backlog first."
        exit 1
    fi

    # Get velocity
    log_step "Calculating velocity..."
    VELOCITY=$(get_velocity)
    log_info "Average velocity: $VELOCITY points"

    # Interactive planning with Claude
    claude <<EOF
Sprint Planning for Sprint $SPRINT_NUM

1. Read docs/BACKLOG.md
2. Review last 3 sprints to understand velocity (average: $VELOCITY points)
3. Ask user to select stories from backlog until ~$VELOCITY points
4. For each selected story:
   - Break down into tasks
   - Estimate each task
   - Identify dependencies
5. Ask user for sprint goal (one sentence)
6. Create docs/SPRINT_$SPRINT_NUM.md using the template
7. Use TaskCreate() to create all tasks
8. Set up task dependencies with TaskUpdate()

Generate sprint plan and save to docs/SPRINT_$SPRINT_NUM.md
EOF

    log_success "Sprint $SPRINT_NUM planned"
    log_info "Sprint plan saved to $SPRINT_FILE"
}

# Update sprint progress
update_progress() {
    check_project

    # Find current sprint
    CURRENT_SPRINT=$(ls "$DOCS_DIR"/SPRINT_*.md 2>/dev/null | grep -v "COMPLETED" | tail -1)

    if [ -z "$CURRENT_SPRINT" ]; then
        log_error "No active sprint found"
        exit 1
    fi

    log_step "Updating sprint progress..."

    claude <<EOF
Update current sprint progress:

1. Run TaskList() to get current task status
2. Calculate:
   - Points completed
   - Points remaining
   - Completion percentage
   - Days elapsed vs days remaining
3. Update $CURRENT_SPRINT:
   - Daily progress section for today
   - Burndown chart
   - Points remaining
   - Status (on track / behind / ahead)
4. Save updated file

Provide summary of current sprint status.
EOF

    log_success "Sprint progress updated"
}

# Sprint review
review_sprint() {
    check_project

    # Find current sprint
    CURRENT_SPRINT=$(ls "$DOCS_DIR"/SPRINT_*.md 2>/dev/null | grep -v "COMPLETED" | tail -1)

    if [ -z "$CURRENT_SPRINT" ]; then
        log_error "No active sprint found"
        exit 1
    fi

    log_step "Conducting sprint review..."

    claude <<EOF
Sprint Review:

1. Read $CURRENT_SPRINT
2. Run TaskList() to see completed vs incomplete tasks
3. For each story:
   - Check if acceptance criteria met
   - Mark as ACCEPTED or REJECTED
   - If rejected, note why
4. Calculate metrics:
   - Completion rate
   - Velocity (points completed)
   - Stories completed vs committed
5. Update sprint review section in $CURRENT_SPRINT
6. Ask user for demo notes and stakeholder feedback
7. Save updated file

Provide sprint review summary.
EOF

    log_success "Sprint review completed"
}

# Sprint retrospective
retro_sprint() {
    check_project

    # Find current sprint
    CURRENT_SPRINT=$(ls "$DOCS_DIR"/SPRINT_*.md 2>/dev/null | grep -v "COMPLETED" | tail -1)

    if [ -z "$CURRENT_SPRINT" ]; then
        log_error "No active sprint found"
        exit 1
    fi

    SPRINT_NUM=$(echo "$CURRENT_SPRINT" | sed 's/.*SPRINT_\([0-9]*\).md/\1/')
    RETRO_FILE="$DOCS_DIR/RETROSPECTIVE_$SPRINT_NUM.md"

    log_step "Conducting sprint retrospective..."

    claude <<EOF
Sprint Retrospective for Sprint $SPRINT_NUM:

1. Read $CURRENT_SPRINT for sprint results
2. Ask user three retro questions:
   - What went well? (celebrate successes)
   - What went poorly? (identify problems)
   - What to improve? (create action items)
3. Analyze patterns:
   - Estimation accuracy
   - Velocity trends
   - Blockers encountered
4. Create action items for next sprint (specific, actionable)
5. Update .claude/memory/ with:
   - Patterns learned
   - Decisions made
   - Velocity history
6. Create $RETRO_FILE using template
7. Provide retro summary

Generate retrospective document.
EOF

    # Mark sprint as complete
    mv "$CURRENT_SPRINT" "${CURRENT_SPRINT%.md}_COMPLETED.md"

    log_success "Retrospective completed"
    log_info "Retrospective saved to $RETRO_FILE"
    log_info "Sprint marked as completed"
}

# Create backlog from scratch
create_backlog() {
    check_project

    if [ -f "$DOCS_DIR/BACKLOG.md" ]; then
        read -p "BACKLOG.md exists. Overwrite? (y/N): " confirm
        if [ "$confirm" != "y" ]; then
            log_info "Cancelled"
            exit 0
        fi
    fi

    log_step "Creating product backlog..."

    claude <<EOF
Create Product Backlog:

1. Ask user about their project goals and features needed
2. For each feature mentioned:
   - Create user story ("As a... I want... so that...")
   - Define acceptance criteria
   - Estimate story points (1, 2, 3, 5, 8, 13)
   - Assign priority (High/Medium/Low)
3. Organize stories by priority
4. Create docs/BACKLOG.md using template
5. Save backlog

Generate backlog from user input.
EOF

    log_success "Backlog created at $DOCS_DIR/BACKLOG.md"
}

# Show sprint status
show_status() {
    check_project

    # Find current sprint
    CURRENT_SPRINT=$(ls "$DOCS_DIR"/SPRINT_*.md 2>/dev/null | grep -v "COMPLETED" | tail -1)

    if [ -z "$CURRENT_SPRINT" ]; then
        log_info "No active sprint"
        exit 0
    fi

    log_step "Current Sprint Status..."

    claude <<EOF
Show current sprint status:

1. Read $CURRENT_SPRINT
2. Run TaskList()
3. Display:
   - Sprint number and goal
   - Days elapsed / remaining
   - Points completed / committed
   - Completion percentage
   - Tasks status summary
   - On track status
   - Blockers (if any)

Provide concise status summary.
EOF
}

# Main command dispatcher
case "${1:-help}" in
    plan|start)
        plan_sprint
        ;;
    update)
        update_progress
        ;;
    review)
        review_sprint
        ;;
    retro)
        retro_sprint
        ;;
    status)
        show_status
        ;;
    backlog)
        create_backlog
        ;;
    help|*)
        cat <<EOF
Sprint Planner v4.4

Usage: ./sprint-planner.sh [command]

Commands:
  plan (or start)    Plan new sprint
  update             Update current sprint progress
  review             Conduct sprint review
  retro              Conduct sprint retrospective
  status             Show current sprint status
  backlog            Create/update product backlog
  help               Show this help

Typical Sprint Workflow:
  1. ./sprint-planner.sh backlog      (one-time setup)
  2. ./sprint-planner.sh plan         (start new sprint)
  3. ./sprint-planner.sh update       (daily progress)
  4. ./sprint-planner.sh review       (end of sprint)
  5. ./sprint-planner.sh retro        (after review)
  6. Repeat steps 2-5 for next sprint

Examples:
  ./sprint-planner.sh plan
  ./sprint-planner.sh update
  ./sprint-planner.sh status

See: guides/SPRINT_MANAGEMENT.md for full documentation
EOF
        ;;
esac
