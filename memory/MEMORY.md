# Personal Context for Claude

> Claude reads this file at the start of every session. It persists across conversations.
> **Hard limit: 200 lines.** Lines beyond 200 are truncated and never seen by Claude.
> Keep this as a concise index — move details into topic files and link to them.
>
> Location: `~/.claude/projects/<your-project>/memory/MEMORY.md`

## About Me

- **Name:** [Your name]
- **Role:** [e.g., "Vibe coder — I direct AI to build, I don't write code manually"]
- **Location/Timezone:** [e.g., "US East / America/New_York"]
- **What I'm building:** [1-2 sentences about your main focus]

## How I Work

- [e.g., "Start coding immediately — don't ask 10 questions first"]
- [e.g., "I prefer simple solutions over clever ones"]
- [e.g., "Always commit with conventional commit messages"]
- [e.g., "Push back if I'm overcomplicating something"]
- [e.g., "Questions are questions — don't take action on a '?' message"]

## My Projects

| Project | Path | Status |
|---------|------|--------|
| [Main project] | ~/projects/[name] | Active |
| [Side project] | ~/projects/[name] | Paused |

## Tech Preferences

- [e.g., "TypeScript for everything"]
- [e.g., "Tailwind CSS, not styled-components"]
- [e.g., "PostgreSQL, not MongoDB"]
- [e.g., "Vercel for deployment"]

## Infrastructure

- **Dev machine:** [e.g., "MacBook Pro M2" or "Linux server via SSH"]
- **Production:** [e.g., "Vercel" or "AWS EC2" or "Not deployed yet"]
- **Database:** [e.g., "PostgreSQL on Railway"]

## Key People

> If you collaborate with others, note context:
>
> - **[Name]** — [role], [how to reach them]

## Feedback & Rules

> When Claude makes a mistake or you correct its behavior, save the rule here.
> These prevent the same mistake from happening again across sessions.
> For detailed pattern tracking, see `memory/patterns.md`.
>
> - [e.g., "Never use `any` type — always find or create the correct type"]
> - [e.g., "Always run typecheck before committing"]
> - [e.g., "Don't add features beyond what I asked for"]

## Transient Context

> See `memory/pending.md` for time-sensitive items (blockers, in-progress work).
> See `memory/patterns.md` for universal rules from past mistakes.
