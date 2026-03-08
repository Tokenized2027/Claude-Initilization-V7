#!/bin/bash
# Interactive Demo of v4.4 Features
# Shows all four systems in action

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

section() { echo -e "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}\n"; }
info() { echo -e "${YELLOW}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
pause() {
    echo ""
    read -p "Press Enter to continue..."
    echo ""
}

clear
cat <<'EOF'
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║      v4.4 Interactive Demo                           ║
║      Sprint Management + Memory System               ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝

This demo will walk you through all four v4.4 systems:
  1. Memory System
  2. Sprint Management
  3. Task Integration
  4. Bead Method

Duration: ~10 minutes
EOF

pause

## 1. Memory System
section "1. Memory System Demo"

cat <<'EOF'
The Memory System provides persistent context across sessions.

Key files:
  .claude/memory/decisions.json    - Architectural decisions
  .claude/memory/patterns.md       - Learned patterns
  .claude/memory/preferences.md    - Your coding style
  .claude/memory/project-context.json - Current project state
  .claude/memory/session-history.json - Session tracking
EOF

info "Example: Adding a decision"

cat <<'EOF'

Decision capture:
  Category: architecture
  Decision: Use PostgreSQL instead of MongoDB
  Rationale: Need complex queries and ACID compliance
  Date: 2026-02-12
  Status: active

Saved to: decisions.json
EOF

success "Decisions are auto-recalled in every session"

pause

info "Example: Pattern learning"

cat <<'EOF'

Pattern discovered:
  Problem: Docker port conflicts
  Solution: docker compose down -v && docker compose up -d
  Frequency: 3+ times
  Prevention: Always use 'docker compose down'

Saved to: patterns.md
EOF

success "Patterns prevent repeated mistakes"

pause

info "Example: Session memory"

cat <<'EOF'

Last session summary:
  Goal: Implement user authentication
  Accomplished:
    - Created /register and /login endpoints
    - Added JWT token generation
    - Wrote integration tests
  Next: Connect frontend to backend API

Saved to: session-history.json
EOF

success "Perfect continuity between sessions"

pause

## 2. Sprint Management
section "2. Sprint Management Demo"

cat <<'EOF'
Sprint Management provides 2-week cycles with velocity tracking.

Sprint workflow:
  Day 0:  Sprint Planning   (2 hours)
  Days 1-10: Execution      (daily 5-min updates)
  Day 10: Review            (1 hour)
  Day 10: Retrospective     (1 hour)
EOF

info "Example: Sprint planning"

cat <<'EOF'

Velocity calculation:
  Sprint 4: 22 points completed
  Sprint 5: 18 points completed
  Sprint 6: 21 points completed
  Average: 20 points/sprint

Sprint 7 capacity: 20 points

Stories selected:
  - User authentication (8 points)
  - User profile page (5 points)
  - Password reset flow (5 points)
  Total: 18 points ✓

Sprint goal: "User can manage their account"
EOF

success "Data-driven planning with realistic capacity"

pause

info "Example: Daily burndown"

cat <<'EOF'

Sprint 7 Progress (Day 5):

Points remaining: 10 / 18 (44% left)
Expected: 9 points (50% left)
Status: Slightly ahead ✓

Burndown:
  Day 0:  18 points
  Day 1:  18 points (planning)
  Day 2:  15 points
  Day 3:  13 points
  Day 4:  11 points
  Day 5:  10 points ← current

On track for 100% completion
EOF

success "Clear visibility of progress"

pause

info "Example: Retrospective"

cat <<'EOF'

Sprint 7 Retrospective:

What went well:
  ✓ Auth implementation clean and secure
  ✓ Memory system saved 10 min/session
  ✓ All acceptance criteria met

What went poorly:
  ✗ Email integration took 2x estimate
  ✗ Password reset rushed at end

Action items for Sprint 8:
  1. Add 2x buffer for external API tasks
  2. Research email providers before sprint
  3. Keep using memory system (working great)

Velocity: 18 points (on target)
EOF

success "Continuous improvement every sprint"

pause

## 3. Task Integration
section "3. Task Integration Demo"

cat <<'EOF'
Task Integration uses Claude Code's native task tools.

Native tools:
  TaskCreate()  - Create structured tasks
  TaskUpdate()  - Update status, dependencies
  TaskList()    - View all tasks
  TaskGet()     - Get task details
EOF

info "Example: Creating tasks with dependencies"

cat <<'EOF'

TaskCreate({
  subject: "Create User model",
  description: "Prisma schema with email, password fields",
  metadata: { sprint: "7", points: 1 }
})
→ Task 1 created

TaskCreate({
  subject: "Implement register endpoint",
  description: "POST /api/register with validation",
  metadata: { sprint: "7", points: 2 }
})
→ Task 2 created

TaskUpdate({
  taskId: "2",
  addBlockedBy: ["1"]  // Task 2 depends on Task 1
})
→ Dependency set

TaskList()
→ Shows:
  Task 1: Create User model (available)
  Task 2: Implement register endpoint (blocked by Task 1)
EOF

success "Dependencies prevent wasted work"

pause

info "Example: Task status flow"

cat <<'EOF'

Working on Task 1:
  TaskUpdate({ taskId: "1", status: "in_progress" })

Completed Task 1:
  TaskUpdate({ taskId: "1", status: "completed" })
  → Task 2 automatically unblocked!

TaskList() now shows:
  Task 1: ✓ completed
  Task 2: Available to start (no longer blocked)
EOF

success "Automatic dependency resolution"

pause

## 4. Bead Method
section "4. Bead Method Demo"

cat <<'EOF'
Bead Method breaks features into 15-45 minute increments.

Bead characteristics:
  - Takes 15-45 minutes
  - Results in working code
  - One commit per bead
  - Incrementally valuable
EOF

info "Example: Feature decomposition"

cat <<'EOF'

Feature: User Authentication (8 hours traditional)

Bead chain:
  Bead 1: Create User model (15 min) → commit
  Bead 2: Add password hashing function (20 min) → commit
  Bead 3: POST /register endpoint stub (20 min) → commit
  Bead 4: Add email validation (15 min) → commit
  Bead 5: Add password validation (15 min) → commit
  Bead 6: POST /login endpoint stub (20 min) → commit
  Bead 7: JWT token generation (30 min) → commit
  Bead 8: Token validation (25 min) → commit
  Bead 9: Auth middleware (30 min) → commit
  Bead 10: Integration test (30 min) → commit
  Bead 11: Error handling (20 min) → commit

Total: 12 beads, ~4 hours, 12 commits

Benefits:
  ✓ Always working code (can stop anytime)
  ✓ Continuous integration
  ✓ Visible progress (9/12 beads done)
  ✓ Low sunk cost (easy to pivot)
EOF

success "Reduced stress, better flow"

pause

## Integration
section "How They Work Together"

cat <<'EOF'

Complete v4.4 workflow:

Week 1 (Sprint Planning):
  1. Sprint planning → Create stories
  2. Break stories → Create tasks (TaskCreate)
  3. Decompose tasks → Create bead chains
  4. Commit sprint plan

Week 2 (Execution):
  Daily:
    - memory-manager.sh start (load context)
    - Execute beads (15-45 min increments)
    - Update tasks (TaskUpdate)
    - Commit after each bead
    - sprint-planner.sh update (track progress)
    - memory-manager.sh end (save context)

Week 2 End (Review & Retro):
  - Sprint review (demo, accept stories)
  - Retrospective (what worked/didn't)
  - Learnings → Memory system
  - Velocity → Next sprint planning

Result:
  ✓ Predictable delivery
  ✓ Continuous improvement
  ✓ Perfect session continuity
  ✓ Always working code
EOF

success "Professional-grade workflow for solo developers"

pause

## Next Steps
section "Next Steps"

cat <<'EOF'
You've seen all four v4.4 systems!

To get started:

1. Memory System (10 min)
   Read: guides/V4.4_QUICK_START.md
   Setup: mkdir -p .claude/memory

2. Sprint Management (2 hours)
   Read: guides/SPRINT_MANAGEMENT.md
   Start: ./sprint-planner.sh backlog

3. Task Integration (ongoing)
   Read: guides/TASK_INTEGRATION.md
   Use: TaskCreate() in sessions

4. Bead Method (ongoing)
   Read: guides/BEAD_METHOD.md
   Apply: Break features into beads

Validation:
  Run: ./validate-v4.4.sh
  Check: Everything is set up correctly

Full documentation:
  Overview: V4.4_RELEASE_SUMMARY.md
  Migration: UPGRADING_V4.3_TO_V4.4.md
  Index: DOCUMENTATION_INDEX.md
EOF

echo ""
success "Demo complete! Ready to build with v4.4."
echo ""
