# My App — Claude Instructions

> Claude reads this file automatically at the start of every session.
> Put project-specific rules, context, and conventions here.

## What This Project Is

[1-2 sentences: what does this app do, who is it for]

Example: "A personal finance tracker built with Next.js. Users log expenses, see monthly breakdowns, and set budgets."

## Tech Stack

- **Frontend:** [e.g., Next.js 15, React 19, TypeScript, Tailwind CSS]
- **Backend:** [e.g., API routes, PostgreSQL, Drizzle ORM]
- **Auth:** [e.g., NextAuth.js, Clerk, or none yet]
- **Hosting:** [e.g., Vercel, Railway, not deployed yet]

## Project Structure

```
src/
  app/           → Pages (Next.js App Router)
  components/    → React components
  lib/           → Utilities, helpers, DB client
  types/         → TypeScript types
```

## Rules for Claude

### Always
- Ask clarifying questions before building anything ambiguous
- Provide complete files — never partial snippets
- Propose git commits but wait for approval before running them
- Use TypeScript strict mode
- Handle errors at system boundaries (user input, API calls)

### Never
- Commit without explicit approval
- Add features beyond what was asked
- Use `any` type — find the correct type or create one
- Commit .env files or secrets
- Over-engineer — keep it simple

## Common Commands

```bash
npm run dev        # Start dev server
npm run build      # Production build
npm run typecheck  # Type checking
```

## Current Status

[What's working, what's in progress, what's broken — update this as you go]

- [x] Project scaffolded
- [ ] Auth working
- [ ] Database connected
- [ ] First feature built
