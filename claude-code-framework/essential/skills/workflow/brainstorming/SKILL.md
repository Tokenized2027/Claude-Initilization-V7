---
name: brainstorming
description: Structured ideation and design review before any creative or constructive work. Use before building features, components, architecture, dashboards, or automation workflows. Triggers on "plan this", "design this", "brainstorm", "think through", "what should we build", "how should I approach".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: workflow
  source: community-contributed
  license: MIT
---

# Brainstorming

Structured one-question-at-a-time ideation that turns vague ideas into validated designs before implementation begins.

## Why This Exists

Jumping straight to code is the #1 cause of rework. This skill forces clarity before a single line is written. For autonomous agents on the mini PC, this prevents wasted API tokens and dead-end builds.

## Instructions

### Step 1: Capture the Raw Idea

Ask exactly ONE question at a time. Wait for an answer before asking the next. Never front-load five questions.

**Opening question (always start here):**
> "What problem are you trying to solve, and who has that problem?"

If the task came from the orchestrator (autonomous mode), extract the problem from the task description and state your understanding before proceeding.

### Step 2: Define Constraints (ask one at a time)

Work through these in order. Skip any already answered:

1. **Users:** Who uses this? (end users, other agents, API consumers, yourself)
2. **Scale:** How many users/requests/records? (ballpark is fine)
3. **Stack:** What tech is already in play? (check project memory first)
4. **Time:** What's the deadline or sprint scope?
5. **Dependencies:** What external services, APIs, or data sources are needed?
6. **Non-goals:** What are we explicitly NOT building?

### Step 3: Generate Options

Produce exactly 3 approaches. For each:

- **Name:** 2-3 word label (e.g., "Monolith First", "API-Led", "Event-Driven")
- **How it works:** 2-3 sentences max
- **Pros:** 2-3 bullets
- **Cons:** 2-3 bullets
- **Effort:** Low / Medium / High
- **Risk:** Low / Medium / High

### Step 4: Recommend and Justify

Pick one approach. State why in 2 sentences. Reference the constraints from Step 2.

### Step 5: Output the Design Brief

Produce a structured brief the next agent (architect, developer, etc.) can act on:

```markdown
## Design Brief: [Feature Name]

### Problem
[1-2 sentences]

### Solution (Chosen Approach)
[Name]: [2-3 sentences]

### Scope
- IN: [what we're building]
- OUT: [what we're not building]

### Technical Decisions
- Stack: [tech choices]
- Data: [storage/API needs]
- Auth: [if applicable]

### Acceptance Criteria
1. [Testable criterion]
2. [Testable criterion]
3. [Testable criterion]

### Handoff To
[Next agent: system-architect | frontend-developer | backend-developer]
```

## Autonomous Mode Behavior

When invoked by the orchestrator without a human in the loop:

1. Extract the problem statement from the task payload
2. Check project memory for existing constraints and decisions
3. Skip interactive questions — use available context
4. Generate the 3 options and auto-select based on: lowest risk first, then lowest effort
5. Write the design brief to the project's `docs/` directory
6. Hand off to the next agent via memory protocol

## When to Use This Skill

✅ Use brainstorming when:
- Starting any new feature, dashboard, or automation
- The task description is vague ("build a thing for X")
- Multiple approaches seem viable
- You're about to spend >1 hour of agent time on something

❌ Don't use brainstorming for:
- Bug fixes (use systematic-debugging)
- Routine scaffolding (use scaffolding skills)
- Tasks with a clear, single implementation path
- Emergency fixes (use emergency skills)

## Quick Reference

| Phase | Output | Time |
|-------|--------|------|
| Capture | Problem statement | 1 min |
| Constraints | 6 constraint answers | 2-3 min |
| Options | 3 approaches compared | 3-5 min |
| Recommend | Chosen approach + why | 1 min |
| Brief | Structured handoff doc | 2 min |
