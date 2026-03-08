# Project Initialization Workflow

> Complete sequence for starting a new project with Claude Code
>
> **Last Updated:** February 12, 2026

---

## Phase 0: Pre-Work (Before Writing Any Code)

### Step 1: Create Project Skeleton

Prompt to CC:
```
Create the following project structure:
- CLAUDE.md (copy from template — I'll provide it)
- .claude/hooks/ (with all 4 hook scripts: branch protection, safe commands, auto-format, code review)
- .claude/settings.json (with hooks config, allowed commands, and Playwright MCP)
- docs/ directory
- tmp/ directory (gitignored)
- logs/ directory (gitignored)
- .gitignore (include tmp/, logs/, .env, node_modules/, __pycache__/, etc.)

Initialize git repo, create main branch, then create a develop branch to work on.
Search the internet for current best practices on Claude Code hooks and settings before creating them.
```

### Step 2: Create PRD (Product Requirements Document)

Use CC Teams with 5 roles, or use this prompt:
```
I need you to create a PRD (Product Requirements Document) for this project.

Before writing anything, ask me at least 10 questions about:
- The business problem we're solving
- Who the users are
- What success looks like
- Any technical constraints
- Timeline and priorities

After I answer, create a comprehensive PRD that includes:
1. Background & Context
2. Problem Statement
3. Product Vision
4. User Stories (with acceptance criteria)
5. Feature Roadmap (phased: MVP → V2 → Future)
6. Technical Requirements (high-level)
7. Success Metrics (measurable KPIs)
8. Out of Scope (what we're NOT building)
9. Open Questions / Decisions Needed

Save as docs/PRD.md

This is an iterative process — I'll review and we'll refine together before moving on.
```

### Step 3: Create Tech Spec

After PRD is approved:
```
Based on the approved PRD (docs/PRD.md), create a Technical Specification document.

Before writing, ask me clarifying questions about:
- Preferred tech stack and why
- Hosting/deployment preferences
- External services and APIs we'll use
- Performance requirements
- Security requirements

The Tech Spec should include:
1. System Architecture Overview
2. Component Breakdown (every major module)
3. Data Model / Schema Design
4. API Design (endpoints, request/response shapes)
5. Integration Points (external APIs, services)
6. File/Folder Structure (exact paths)
7. Environment Variables needed
8. Authentication & Authorization approach
9. Error Handling Strategy
10. Testing Strategy
11. Deployment Architecture
12. Technical Risks & Mitigations

Save as docs/TECH_SPEC.md

Again — iterative. I'll review before we proceed.
```

### Step 4: Create Status File

```
Create STATUS.md in the project root with this structure:

# Project Status — [PROJECT_NAME]

## Last Updated: [DATE]

## Current Phase: Phase 0 — Setup Complete

## Project Structure
[Full file tree]

## What's Done
- [x] Project skeleton created
- [x] CLAUDE.md configured
- [x] Hooks set up
- [x] PRD approved
- [x] Tech Spec approved

## What's Next
- [ ] [First task from Phase 1]

## Active Bugs / Issues
None yet.

## Key Decisions Made
- [List architectural and product decisions with brief rationale]

## Environment Status
| Service | Status | Notes |
|---------|--------|-------|
| | | |

---

Update this file after EVERY code change. This is mandatory — see CLAUDE.md.
Add links to PRD.md, TECH_SPEC.md, and STATUS.md in CLAUDE.md.
```

---

## Phase 1: Start Building

### CC Teams Prompt (5 Roles)

If using Claude Code Teams for PRD/Tech Spec generation:
```
We're going to create project documentation using a team discussion format.
You will simulate 5 roles and have them discuss and iterate:

1. **CEO** — Focuses on business value, market fit, ROI, and strategic alignment
2. **Product Manager** — Focuses on user stories, feature prioritization, roadmap, success metrics
3. **Frontend Developer** — Focuses on UI/UX, component architecture, responsive design, performance
4. **Backend Developer** — Focuses on API design, data models, infrastructure, security, scalability
5. **AI/ML Engineer** — Focuses on model selection, data pipelines, prompt engineering, cost optimization

Process:
- Start with my project description
- Each role asks 2-3 targeted questions from their perspective
- I answer
- The team discusses and produces the document
- I review and request changes
- Iterate until approved

Let's start. Here's what I want to build: [DESCRIPTION]
```

---

## Ongoing Work Prompts

### Session Start (Resuming Work)
```
Read STATUS.md, CLAUDE.md, and the docs/ folder to understand where we left off.
Tell me:
1. What was the last thing we completed
2. What's the next task
3. Any open bugs or blockers

Then proceed with the next task unless I redirect you.
```

### Mid-Session Checkpoint
```
Before continuing:
1. Update STATUS.md with everything we've done this session
2. Make a git commit with a clear message
3. Run the code review hook
4. Tell me what's next
```

### End of Session
```
End of session wrap-up:
1. Update STATUS.md with current state
2. Commit all work with descriptive messages
3. List any open bugs or issues we haven't addressed
4. Summarize what we accomplished today
5. State what the next session should start with
```

---

## Key Principles (from the workflow)

1. **Playwright MCP is mandatory** for any web app — it saves hours of debugging
2. **Detailed logs on every run** — without them, debugging is nearly impossible
3. **Commit early, commit often** — don't get carried away making changes without checkpoints
4. **Review both PRD and Tech Spec personally** before approving — the iterative process matters
5. **Status.md is the most important file** — without it, session continuity breaks down
6. **CC makes silent assumptions** — especially with data work, always verify it did what you asked
7. **CC ignores its own CLAUDE.md sometimes** — periodically check it's following the rules
8. **Numbers confuse CC** — double-check any numerical analysis, comparisons, or metrics
