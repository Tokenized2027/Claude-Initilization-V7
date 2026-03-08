# Todo App — Claude Instructions

## What This Is

A simple full-stack todo app. Next.js frontend, SQLite database via Drizzle ORM. No auth — single user. Built as a learning project for Claude Code workflow.

## Tech Stack

- **Frontend:** Next.js 15, React 19, TypeScript, Tailwind CSS
- **Database:** SQLite + Drizzle ORM
- **Hosting:** Not deployed yet (local dev only)

## Project Structure

```
src/
  app/
    page.tsx              → Main todo list page
    api/todos/route.ts    → CRUD API for todos
  components/
    TodoList.tsx           → List component
    TodoItem.tsx           → Single todo with checkbox + delete
    AddTodoForm.tsx        → Input form
  lib/
    db.ts                  → Drizzle client
    schema.ts              → Database schema (todos table)
  types/
    index.ts               → Todo type definition
drizzle.config.ts          → Drizzle config
```

## Rules

- Complete files only — no snippets
- Conventional commits: `feat:`, `fix:`, `chore:`
- Ask before adding dependencies
- Keep it simple — this is a learning project

## Commands

```bash
npm run dev              # Start dev server (port 3000)
npm run db:push          # Push schema to SQLite
npm run db:studio        # Open Drizzle Studio (DB browser)
```

## Status

- [x] Project scaffolded with Next.js
- [x] Database schema (todos: id, text, completed, createdAt)
- [x] CRUD API routes
- [x] TodoList + TodoItem components
- [x] Add/toggle/delete working
- [ ] Filter by status (all/active/completed)
- [ ] Due dates
