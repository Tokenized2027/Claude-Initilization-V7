# Next.js App — Claude Instructions

> Claude reads this file automatically at the start of every session.

## What this project is

`[One sentence: what does this app do, and for whom.]`

Example: "A bookmark manager. Users save URLs with tags, search across them, and share collections."

## Stack

- Next.js 15 with the App Router
- React 19
- TypeScript strict mode (no `any`, no implicit `any`)
- Tailwind CSS
- `[Database: PostgreSQL + Drizzle / SQLite + Prisma / none yet]`
- `[Auth: NextAuth.js / Clerk / none yet]`
- `[Hosting: Vercel / Railway / Cloudflare / local only]`

## File layout

```
app/
  (marketing)/      marketing pages, route group
  (app)/            authenticated app pages
  api/              route handlers
components/
  ui/               primitives (Button, Input, Dialog)
  features/         feature specific components
lib/
  db/               database client + queries
  auth/             auth helpers
  utils/            small pure helpers
types/              shared TypeScript types
```

## Rules for Claude

### Always

- Ask clarifying questions before building anything ambiguous.
- Provide complete files. Never partial snippets or "rest stays the same".
- Use server components by default. Add `"use client"` only when you need interactivity or a browser API.
- Use `async` server components for data fetching. Keep fetch logic close to where data is used.
- Validate user input at the boundary with `zod`. Trust internal data.
- Use strict TypeScript. If the type is tricky, write it in `types/` and import it.
- Suggest a conventional commit message when a change is logically complete. Wait for approval before running git.

### Never

- Commit without explicit approval.
- Use `any` or `@ts-ignore`. Find the correct type or ask.
- Add a new dependency without stating what it does and why an in repo version will not work.
- Commit `.env`, `.env.local`, or any file containing secrets.
- Over-engineer. If three lines work, do not abstract into a helper.

## Environment variables

Secrets live in `.env.local` (gitignored). Non secrets that ship to the client live in `.env.example` with placeholder values. Every new env var gets an entry in `.env.example`.

## Common commands

```bash
npm run dev         # Start dev server on :3000
npm run build       # Production build
npm run start       # Production server
npm run typecheck   # tsc --noEmit
npm run lint        # ESLint
npm run test        # Vitest (if configured)
```

## Checklist before shipping a feature

- [ ] `npm run typecheck` passes.
- [ ] `npm run build` passes.
- [ ] New env vars added to `.env.example`.
- [ ] No `console.log` left in client code.
- [ ] Tested on mobile width (360px).
- [ ] Empty states and loading states covered.
