# v4.4 Examples — Filled-Out Templates

> **Real-world examples showing what properly filled v4.4 files look like**

---

## Purpose

These are **realistic, complete examples** of v4.4 memory files, sprint documents, and bead chains from an actual project (TaskFlow - a task management app).

Use these as references when creating your own v4.4 files.

---

## Memory System Examples

### Location: `examples/memory/`

#### decisions.json
**Example of:** 8 architectural decisions from a real project

Shows:
- How to structure decision entries
- Different decision categories (architecture, tech, design, process)
- Rationale and alternatives considered
- Impact on project
- Active vs deprecated status

**Real decisions from TaskFlow:**
- PostgreSQL vs MongoDB choice
- Next.js App Router adoption
- Tailwind + shadcn/ui selection
- Sprint management adoption
- JWT authentication approach
- Deployment strategy

**Use this when:** Creating your first decisions.json or adding new decisions

---

#### patterns.md
**Example of:** 28 learned patterns from actual development

Shows:
- Bug patterns (recurring issues and solutions)
- Solution patterns (repeatable approaches)
- Performance patterns (optimizations)
- Architecture patterns (structure decisions)
- Anti-patterns (things to avoid)

**Real patterns from TaskFlow:**
- Database connection pooling in Next.js
- CORS configuration
- TypeScript best practices
- API error handling
- Form validation with Zod
- Testing patterns
- Git workflow

**Use this when:** You encounter the same bug 2-3 times, or discover a repeatable solution

---

#### preferences.md
**Example of:** Complete coding style and workflow preferences

Shows:
- Coding style (indentation, naming, comments)
- Framework preferences (Next.js, TypeScript, etc.)
- Testing preferences (coverage targets, structure)
- Git workflow
- Communication preferences with Claude
- Development workflow (daily routine)

**Real preferences from TaskFlow:**
- 2-space indentation, single quotes, semicolons always
- Next.js 15 App Router, Server Components default
- Vitest for testing, 80%+ coverage target
- Bead method with 8-12 commits/day
- Complete files only (no snippets)

**Use this when:** Setting up memory system for first time, or updating your preferences

---

#### project-context.json
**Example of:** Current project state snapshot

Shows:
- Project metadata (name, version, phase)
- Tech stack details
- Sprint information (current sprint, velocity, points)
- Current work (active story, task, bead, commit)
- Architecture overview
- Database schema
- Deployment setup
- Known issues
- Metrics

**Real context from TaskFlow:**
- v0.3.0, alpha phase
- Next.js 15 + Prisma + PostgreSQL
- Sprint 3, velocity 20 points
- Working on real-time WebSocket feature
- 12,500 lines of code, 287 commits

**Use this when:** Starting sessions (load this context), ending sessions (update this context)

---

#### session-history.json
**Example of:** 10 sessions of development work

Shows:
- Session structure (date, duration, goal)
- What was accomplished
- Issues encountered and resolutions
- Decisions made
- Patterns learned
- Next steps
- Sprint progress
- Commit list
- Time breakdown

**Real sessions from TaskFlow:**
- Session 1: Project initialization
- Session 4: Complete user authentication
- Session 6: Profile customization feature
- Session 9: Task commenting with mentions
- Session 10: WebSocket server setup

**Use this when:** Understanding session-history format, seeing how to summarize work

---

## Sprint Examples

### Location: `examples/sprints/`

#### SPRINT_03.md
**Example of:** Active sprint in progress (Day 3 of 10)

Shows:
- Sprint header (dates, goal, velocity)
- Story breakdown with acceptance criteria
- Daily task board
- Burndown chart (actual vs planned)
- Risks and mitigation strategies
- Dependencies
- Testing plan
- Definition of done
- Metrics (code, quality, team health)
- Daily standup notes

**Real sprint from TaskFlow:**
- Sprint 3: Real-time features
- 20 points committed
- 4 stories (2 complete, 1 in progress, 1 pending)
- Day 3: Ahead of schedule
- Using bead method (9-11 commits/day)

**Use this when:** Planning your first sprint, or tracking sprint progress

---

#### BEAD_CHAIN_realtime_tasks.md
**Example of:** Feature decomposed into 18 beads

Shows:
- Bead list with estimates and actuals
- Three phases (server, client, integration)
- Detailed acceptance criteria per bead
- Velocity tracking (estimated vs actual)
- Lessons learned
- Commit history (1 commit per bead)
- Next session plan

**Real bead chain from TaskFlow:**
- Feature: Real-time task updates with WebSockets
- 18 beads total, 9 complete
- Phase 1 complete (server setup) — 98% estimation accuracy
- Each bead 15-45 min
- Each bead resulted in working code
- Clear progression toward feature completion

**Use this when:** Decomposing a complex feature, understanding bead method execution

---

## How to Use These Examples

### For First-Time Setup

1. **Copy structure, not content:**
   ```bash
   # Don't copy content verbatim
   # Copy the structure and fill with YOUR project data

   # Example:
   cp examples/memory/decisions.json .claude/memory/
   # Then edit with YOUR decisions
   ```

2. **Use as templates:**
   - See what fields are available
   - Understand the format
   - See realistic values
   - Then create your own

3. **Reference during work:**
   - Keep `examples/` directory open
   - Check format when creating new entries
   - Compare your files to examples

---

### For Learning

**To understand memory system:**
1. Read `decisions.json` — See how to structure decisions
2. Read `patterns.md` — See pattern categories
3. Read `preferences.md` — See comprehensive preferences
4. Read `project-context.json` — See current state tracking
5. Read `session-history.json` — See session summarization

**To understand sprint management:**
1. Read `SPRINT_03.md` — See complete sprint in action
2. Read `BEAD_CHAIN_realtime_tasks.md` — See bead decomposition

**To understand integration:**
- Session history references sprints
- Sprints reference bead chains
- Bead chains create commits
- Commits tracked in session history
- All fed by memory system

---

## Differences from Templates

### Templates (in `essential/toolkit/templates/`)
- **Empty structures**
- Meant to be copied and filled out
- Minimal example values
- Focus: Quick start

### Examples (here in `examples/`)
- **Realistic, complete data**
- Based on real project
- Full context and history
- Focus: Deep understanding

**Use templates to start, examples to learn.**

---

## Example Project: TaskFlow

All examples come from **TaskFlow**, a team collaboration and task management platform.

**Tech stack:**
- Frontend: Next.js 15 (App Router), React 19, Tailwind CSS, shadcn/ui
- Backend: Next.js API Routes, Prisma, PostgreSQL
- Real-time: Socket.io
- Auth: JWT with httpOnly cookies
- Hosting: Vercel (frontend), Railway (PostgreSQL)

**Development stage:** v0.3.0 alpha, Sprint 3

**Team:** Solo developer using v4.4 systems

**Velocity:** 20 points/sprint (stable over 3 sprints)

**Key features built:**
- User authentication
- Task CRUD
- Project management
- Task commenting with @mentions
- Real-time updates (in progress)

---

## Learning Path

**Beginner:**
1. Start with `preferences.md` — Understand coding preferences
2. Read `SPRINT_03.md` — See sprint structure
3. Read `BEAD_CHAIN_realtime_tasks.md` — See bead method

**Intermediate:**
4. Read `decisions.json` — See decision tracking
5. Read `patterns.md` — See pattern categories
6. Read `project-context.json` — See state tracking

**Advanced:**
7. Read `session-history.json` — See session flow
8. Trace integration: session → sprint → beads → commits
9. Compare examples to your own project

---

## Adapting to Your Project

### Different Tech Stack?

**These examples use Next.js, but patterns apply to any stack:**
- Decisions: Same format, different technologies
- Patterns: Similar bugs in any framework
- Preferences: Adjust to your language/framework
- Sprint management: Technology-agnostic
- Bead method: Works with any language

### Different Team Size?

**Examples are solo dev, but scale to teams:**
- Memory: Share via git or cloud storage
- Sprints: Add team member assignments
- Beads: Assign to different developers
- Session history: One per team member

### Different Domain?

**Examples are web app, but apply to any domain:**
- Mobile app: Same sprint/bead structure
- API/backend: Same patterns apply
- Data science: Beads = notebook cells
- DevOps: Beads = infrastructure changes

**The systems adapt to your context.**

---

## Quick Reference

| File | Purpose | When to Check |
|------|---------|---------------|
| `decisions.json` | Decision format | Adding architectural decision |
| `patterns.md` | Pattern categories | Documenting learned pattern |
| `preferences.md` | Comprehensive prefs | Setting up memory first time |
| `project-context.json` | Current state | Starting/ending sessions |
| `session-history.json` | Session format | Summarizing work |
| `SPRINT_03.md` | Sprint structure | Planning or tracking sprint |
| `BEAD_CHAIN_realtime_tasks.md` | Bead decomposition | Breaking down complex feature |

---

## Validation

**These examples pass validation:**
```bash
# If you copy these to a project
cp -r examples/memory/* .claude/memory/
cp -r examples/sprints/* docs/

# They will pass
./essential/toolkit/validate-v4.4.sh
```

All JSON is valid, all formats correct, all patterns followed.

---

## Contributing

Found these examples helpful? Consider contributing your own:

1. **Different tech stack** (Python, Rust, mobile, etc.)
2. **Different domain** (data science, DevOps, game dev)
3. **Team examples** (not solo dev)
4. **Longer sprints** (showing velocity over 10+ sprints)

Share what works for your context!

---

**Examples last updated:** 2026-02-12
**Based on:** TaskFlow v0.3.0, Sprint 3, Day 3

**These are real, working examples. Use them to learn the v4.4 systems deeply.**
