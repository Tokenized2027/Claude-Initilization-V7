# Team Config: Feature Sprint

> 3 teammates. For adding a significant feature to an existing project.

## When to Use

- Adding a feature that spans frontend + backend + tests
- Project already has architecture, design system, and API patterns established
- Feature is large enough to benefit from parallel frontend/backend work

## Estimated Cost

3-5x a solo session.

## Config

Replace `[PLACEHOLDERS]` and paste into your Claude Code lead session:

```
Create an agent team to implement [FEATURE_NAME] for [PROJECT_NAME].

Read CLAUDE.md and STATUS.md for project context.

Spawn teammates:

1. Frontend Dev — implement the UI for [FEATURE_NAME].
   Owns: /app, /components, /lib, /types.
   Stack: Next.js App Router, TypeScript strict, Tailwind CSS.
   Follow the existing design system and component patterns in the project.
   Handle all states (loading, error, empty). Mobile-first, dark theme.
   [SPECIFIC UI REQUIREMENTS — e.g., "Build a dashboard page with a grid
   of alert cards. Each card shows token name, price, and 24h change.
   Add filtering by token and sorting by change percentage."]

2. Backend Dev — implement APIs for [FEATURE_NAME].
   Owns: /src/routes, /src/services, /src/models, /src/middleware.
   Follow existing API patterns and database schema conventions.
   Validate all inputs with Zod. Proper HTTP status codes. Structured logging.
   [SPECIFIC API REQUIREMENTS — e.g., "Create GET /api/alerts with pagination
   and filtering. Create POST /api/alerts/subscribe for push notifications.
   Store alert preferences in the existing users table."]

3. Tester — write integration tests after both devs complete.
   Owns: /tests directory.
   Test: happy paths, error handling, edge cases, input validation.
   Message devs with bug reports if issues found.

Rules:
- Frontend and Backend work in parallel on separate files
- Tester is blocked until both devs complete their tasks
- All teammates read CLAUDE.md before starting
- Commit frequently with descriptive messages
- Message each other if API contracts need clarification

Create 5-6 tasks per dev. Wait for all teammates to finish.
```

## Variations

**Without tester (faster, less thorough):**

Remove teammate 3. Have each dev write their own unit tests as part of implementation.

**With security review:**

Add before the tester:

```
3. Security Auditor — review all new code for vulnerabilities.
   Focus on input validation, auth, secrets, and dependency security.
   Must pass before tester starts.
```
