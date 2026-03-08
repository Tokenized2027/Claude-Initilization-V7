# link-vault Project Rules

> **This is an EXAMPLE of a completed CLAUDE.md file for the "link-vault" tutorial project.**
> Use this as a reference when filling in your own project's CLAUDE.md.

**Project:** link-vault — A personal bookmark manager
**Created:** 2025-02-10
**Last Updated:** 2025-02-11

---

## Overview

link-vault is a personal bookmark manager built with Next.js, Flask, and PostgreSQL. Users can save links, tag them, search them, and organize them into collections. It's a single-user application running locally on Docker.

---

## Tech Stack

- **Frontend:** Next.js 14 (App Router), TypeScript, Tailwind CSS, shadcn/ui
- **Backend:** Python 3.11, Flask, SQLAlchemy, Flask-CORS
- **Database:** PostgreSQL 15
- **Deployment:** Docker Compose (local development)
- **Version Control:** Git, GitHub

---

## Project Structure

```
link-vault/
├── frontend/              Next.js app
│   ├── app/              App Router pages
│   ├── components/       React components
│   │   ├── ui/          shadcn/ui components
│   │   └── features/    Feature-specific components
│   ├── lib/             Utilities and API client
│   ├── types/           TypeScript types
│   └── public/          Static assets
│
├── backend/              Flask API
│   ├── api/             Route blueprints
│   ├── models/          SQLAlchemy models
│   ├── services/        Business logic
│   ├── utils/           Helper functions
│   └── migrations/      Alembic migrations
│
├── docker-compose.yml    Docker orchestration
├── CLAUDE.md            This file
├── STATUS.md            Current project state
├── PRD.md               Product requirements
└── README.md            Setup instructions
```

---

## Code Quality Rules

1. **Keep code clean.** No dead code, no commented-out blocks, no orphaned imports.
2. **When making changes:** If any code becomes "orphaned" (no longer called by anything), delete it immediately.
3. **DRY principle:** If a code snippet is used more than once, extract it into its own function or a shared utility file under `utils/`. Never duplicate logic.
4. **Temporary test files** go under `tmp/` which is gitignored. Never commit test scratch files.
5. **Every file must have a clear single responsibility.** If a file grows beyond ~300 lines, discuss splitting it.

---

## Logging & Debugging

6. **Every API request must be logged.** Use structured logging with timestamps, endpoint, method, status code, and response time.
7. **Log levels matter:** Use DEBUG for data flow details, INFO for operations, WARNING for recoverable issues, ERROR for failures.
8. **Backend logs go to:** `backend/logs/api.log`
9. **Console logs in frontend** are acceptable during development but must be removed before final commit.

---

## Git Discipline

10. **Commit frequently.** After every completed unit of work (feature, fix, refactor), make a commit with a clear message.
11. **Never write directly to protected branches** (main, production). Always work on feature branches.
12. **Commit messages format:** `type(scope): description`
    - Examples:
      - `feat(api): add bookmark creation endpoint`
      - `fix(ui): resolve tag dropdown not closing on select`
      - `refactor(db): extract bookmark query logic to service`

---

## Self-Correction Protocol

13. **When I correct you on something substantive, add the correction to this file** under the "Learned Corrections" section below. This ensures the mistake is never repeated.
14. **After every code change, update `STATUS.md`** with what was changed, current state, and any new bugs or issues.

---

## Data & Database Rules

15. **Never subsample or simplify data unless explicitly asked.** If analysis is requested on "all bookmarks," run it on ALL bookmarks.
16. **Database migrations:** Always create Alembic migration files. Never manually modify the database schema.
17. **Seed data:** Maintain `backend/seed.py` with example bookmarks for testing. Seed data should be runnable repeatedly (drop existing, recreate).

---

## API Standards

18. **All API responses must follow this format:**
    - Success: `{ "bookmarks": [...] }` or `{ "bookmark": {...} }`
    - Error: `{ "error": "message", "code": "ERROR_CODE" }`
19. **HTTP status codes:**
    - 200: Success
    - 201: Created
    - 400: Bad request (validation error)
    - 404: Not found
    - 500: Server error
20. **CORS:** Allow requests from `http://localhost:3000` in development.
21. **Every endpoint must have a working curl example in the backend README.**

---

## Frontend Standards

22. **Component structure:**
    - UI components (Button, Input, Card) live in `components/ui/`
    - Feature components (BookmarkCard, TagSelector) live in `components/features/`
    - Page components live in `app/[route]/page.tsx`
23. **TypeScript:** Strict types on all props, state, and API responses. No `any` types unless absolutely necessary.
24. **Styling:** Use Tailwind classes only. No custom CSS except for animations in Tailwind config.
25. **Dark mode:** All components must work in dark mode (default theme).

---

## Testing Requirements

26. **Manual testing protocol:** After every feature:
    1. Test happy path in browser
    2. Test error cases (invalid input, network failure)
    3. Test edge cases (empty state, very long titles)
    4. Check responsive behavior (mobile, tablet, desktop)
27. **Use Playwright MCP** for UI testing when available.

---

## Docker & Environment

28. **Environment variables:**
    - Frontend: `NEXT_PUBLIC_API_URL` (default: `http://localhost:5000`)
    - Backend: `DATABASE_URL`, `FLASK_ENV`, `SECRET_KEY`
    - All environment variables must be documented in `.env.example`
29. **Docker commands:**
    - Start: `docker compose up -d`
    - Stop: `docker compose down`
    - View logs: `docker compose logs -f api`
    - Run migrations: `docker compose exec api flask db upgrade`

---

## Feature-Specific Rules

30. **Bookmark URLs:**
    - Must be valid HTTP/HTTPS URLs
    - Must extract title and favicon on save
    - Must handle URLs without favicons gracefully

31. **Tags:**
    - Case-insensitive (stored lowercase)
    - No special characters except hyphen
    - Autocomplete from existing tags
    - Max 10 tags per bookmark

32. **Search:**
    - Search by title, URL, description, and tags
    - Case-insensitive
    - Results sorted by relevance (match in title > match in description > match in tags)

33. **Collections:**
    - Optional grouping of bookmarks
    - A bookmark can be in multiple collections
    - Collections can be nested (max depth: 2)

---

## Learned Corrections

| Date | Correction |
|------|-----------|
| 2025-02-10 | Tag validation was case-sensitive. Changed to lowercase before storing and comparing. |
| 2025-02-11 | Bookmark card was wrapping long URLs awkwardly. Added `truncate` class and tooltip on hover. |

---

## Project-Specific Notes

- **Favicon fetching:** Using `https://www.google.com/s2/favicons?domain={domain}&sz=32` as fallback if direct fetch fails.
- **URL validation:** Using Python's `validators` library, not regex.
- **Search algorithm:** Currently basic `LIKE` query. If performance degrades with >1000 bookmarks, consider full-text search (PostgreSQL `tsvector`).
- **Future considerations:** Multi-user support would require significant refactoring (add user_id to all tables, auth layer, etc.). Not in current scope.
