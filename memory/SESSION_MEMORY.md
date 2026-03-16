# Session Memory — How to Maintain CLAUDE.md

CLAUDE.md is the institutional memory of your project. It is the first file Claude reads when starting a session, and it determines the quality of every interaction that follows.

## Why CLAUDE.md Matters

AI agents start every session with zero memory. They don't remember yesterday's conversation, last week's architecture decision, or the bug you spent three hours debugging. CLAUDE.md bridges this gap by giving Claude immediate context about:

- What this project is and does
- How things are structured
- What rules must be followed
- What the current state of work is
- What mistakes have been made before (so they're not repeated)

**A well-maintained CLAUDE.md** = Claude is productive within seconds.
**A neglected CLAUDE.md** = you spend 10 minutes re-explaining every session.

## Update Frequency

Update CLAUDE.md during or after every meaningful session. Updates don't need to be large — often a single line under "Current State" or "Known Issues" is enough. The key is consistency.

**Always update after:**
- Completing a feature
- Fixing a significant bug
- Changing architecture or infrastructure
- Adding new services or dependencies
- Discovering a gotcha or edge case

**Skip updates for:**
- Minor code tweaks
- Routine dependency updates
- Sessions where nothing structurally changed

## The 500-Line Rule

Keep CLAUDE.md under 500 lines. Dense and scannable, not exhaustive.

When a section grows too large, extract to a linked doc:

**Instead of:**
```markdown
## API Endpoints
[200 lines of endpoint documentation]
```

**Do this:**
```markdown
## API Reference
See `docs/api-reference.md` for full endpoint documentation.
Key endpoints: /auth/login, /api/v1/users, /api/v1/webhooks
```

## CLAUDE.md Structure Guide

```markdown
# Project Name — CLAUDE.md

## Project Identity
What this project is, who it's for, current stage (dev/staging/production).

## Critical Rules
Non-negotiable constraints. Always/Never rules.

## Architecture
High-level overview. Services, databases, integrations.
Keep it brief — link to detailed architecture docs.

## Tech Stack
Languages, frameworks, databases, versions.

## Environment
Key environment variables, ports, URLs. Names, not values.

## Current State
What's working, in progress, broken. Update every session.

## Recent Changes
Last 5-10 significant changes with dates. Rotate old ones out.

## Known Issues
Active bugs, workarounds, things to watch for.

## Common Mistakes
"Do X, not Y" format. Hard-won lessons from past sessions.

## What's Next
Upcoming work, priorities, open decisions.
```

## The Three Memory Tiers

Memory works best when organized by access frequency:

### Hot Memory (always loaded)
- `CLAUDE.md` — project rules and architecture
- `MEMORY.md` — cross-project context and preferences

These are the "constitution." Keep them small and dense.

### Warm Memory (loaded on demand)
- `pending.md` — transient state, blockers
- `patterns.md` — mistake log with hit tracking
- Topic files — deep reference on specific subjects

### Cold Memory (retrieved when relevant)
- `knowledge-base/` — institutional solutions, post-mortems
- Git history — the ultimate cold storage

**Key discipline:** When hot memory grows past its limit, extract details to warm or cold storage. Keep a one-line pointer. The cost of bloated hot memory is invisible — Claude still reads it, but key rules get diluted by noise.

## The Agent Quality Loop

After sessions with AI agents (automated pipelines, multi-step workflows):

1. **Review output** — Did it do what was intended?
2. **Check for drift** — Did it make wrong assumptions?
3. **Update CLAUDE.md** — Add new rules or corrections
4. **Recalibrate** — If agents consistently misunderstand, fix the instructions

This creates a feedback loop where every session makes future sessions better.

## Anti-Patterns

**Don't:**
- Let CLAUDE.md grow past 500 lines — agents skim bloated files
- Put detailed API docs in CLAUDE.md — link to them
- Leave outdated "Current State" entries — they actively mislead
- Write vague rules ("be careful with the database") — be specific
- Duplicate info from other docs — point to it

**Do:**
- Write rules in imperative mood ("Always X", "Never Y")
- Include concrete examples alongside abstract rules
- Date the "Current State" and "Recent Changes" sections
- Review CLAUDE.md at session start, not just at the end
