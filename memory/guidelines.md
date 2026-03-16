# Memory System Guidelines

## How AI Memory Works

Claude Code has a persistent memory directory at `~/.claude/projects/<project>/memory/`. Its contents persist across conversations — this is how Claude "remembers" you and your projects.

This document defines what to store, how to organize it, and what to avoid.

## The Three-Tier Memory Architecture

Not all memory is equal. Organize by access frequency:

### Hot Memory (always loaded at session start)

- **CLAUDE.md** — project rules, architecture, patterns. Claude reads this every single session.
- **MEMORY.md** — cross-project context, preferences, people. Hard limit: 200 lines.

These are the "constitution" — always in context, always enforced. Keep them dense and scannable.

### Warm Memory (loaded on demand)

- **pending.md** — transient state, current focus, blockers. Pruned ruthlessly.
- **patterns.md** — mistake log with hit tracking. Prune entries not hit in 60 days.
- **Topic files** (`debugging.md`, `architecture.md`, etc.) — deep reference on specific subjects.

Claude reads these when relevant, not every session. Use for details that would bloat hot memory.

### Cold Memory (retrieved when relevant)

- **knowledge-base/** — institutional solutions, patterns, post-mortems.
- **Git history** — the ultimate cold storage. `git log` and `git blame` are always available.
- **docs/** — project documentation, ADRs, specs.

## File Structure

```
memory/
├── MEMORY.md          # Concise index (under 200 lines) — always loaded
├── patterns.md        # Universal rules from past mistakes
├── pending.md         # Transient context — time-sensitive items
└── [topic].md         # Detailed notes on specific topics
```

## MEMORY.md Rules

- **Always loaded** into Claude's system prompt at the start of every conversation
- **Hard limit: 200 lines** — lines beyond 200 are truncated and never seen
- Keep it as a **concise index** that links to detailed topic files
- Organize semantically by topic, not chronologically
- Update or remove entries that become wrong or outdated
- No duplicates of what's in CLAUDE.md — don't repeat project rules here

## What to Save

### Always Save

- **Stable patterns** confirmed across multiple interactions (not one-off observations)
- **Key architectural decisions** and the reasoning behind them
- **Important file paths** and project structure notes
- **Your preferences** for workflow, tools, and communication style
- **Solutions to recurring problems** and debugging insights
- **Explicit requests** — when you say "always do X" or "never do Y", save it immediately

### Save After Confirmation (seen in 2+ sessions)

- Technical patterns and conventions
- Infrastructure details (ports, URLs, service locations)
- Team conventions and communication protocols

## What NOT to Save

- **Session-specific context** — current task details, in-progress work, temporary state (use pending.md)
- **Incomplete information** — verify against project docs before writing
- **Duplicates of CLAUDE.md** — don't repeat what's already in the project's CLAUDE.md
- **Speculative conclusions** from reading a single file
- **Sensitive data** — never store actual passwords, API keys, or tokens in memory files
- **Code patterns derivable from the code** — reading the codebase is always fresher than reading notes about it

## patterns.md Format

Each entry tracks a mistake and the rule that prevents it:

```markdown
## Rule: [Short descriptive title]

**When:** [Context — when does this rule apply?]

**Mistake:** [What went wrong — specific, dated if possible]

**Rule:** [The actionable rule to follow going forward]
```

When a pattern prevents a mistake, annotate it with `(last hit: YYYY-MM-DD)`. Prune entries not hit in 60 days — they are either internalized or irrelevant.

## pending.md Format

Transient context that changes frequently. This is for what the **next session** needs, not a historical log.

```markdown
# Transient Context — Changes Frequently

## Blocking
- [Item] — [what it blocks]

## In Progress
- [Item] — [current status]

## Not Blocking
- [Item] — [status]
```

**Pruning rules:**
- Target: under 60 lines (warn at 80)
- Remove completed items immediately
- Remove items older than 2 weeks
- Historical items belong in git commits, not pending.md

## Cross-Project vs Project-Specific Memory

| Belongs in MEMORY.md (global) | Belongs in CLAUDE.md (per-project) |
|-------------------------------|-------------------------------------|
| Communication preferences | Architecture decisions |
| General coding conventions | Tech stack choices |
| Infrastructure shared across projects | Current state and known issues |
| People and their roles | Project-specific common mistakes |
| Tool/workflow preferences | Quality gates and commands |

## Maintenance

- **Review monthly** — remove outdated entries
- **After major refactors** — update all file paths and architecture notes
- **When rules conflict** — the more recent, more specific rule wins
- **When corrected** — update memory immediately (don't wait for next session)
- **When MEMORY.md hits 200 lines** — extract detail into topic files, keep pointers

## The Compound Effect

Every session adds a small refinement — a new rule, a corrected assumption, a documented pattern. After weeks and months of consistent updates, you have a project memory that makes AI collaboration dramatically more effective than starting from scratch each time.

The real value isn't any single entry. It's the accumulated knowledge that compounds session over session.
