# User Preferences

> My coding style, frameworks, and workflow preferences
> Updated: 2026-02-12

---

## Coding Style

### Indentation & Formatting
- **Indentation:** 2 spaces (never tabs)
- **Line length:** 100 characters max
- **Quotes:** Single quotes for strings, double for JSX attributes
- **Semicolons:** Always use semicolons
- **Trailing commas:** Always (helps with diffs)

### TypeScript
- **Strict mode:** Enabled (`strict: true` in tsconfig.json)
- **Type annotations:** Explicit for function parameters and returns, inferred for variables
- **`any` type:** Never use (use `unknown` if necessary)
- **Enums:** Prefer string literal unions over enums
  ```typescript
  // ✓ Preferred
  type Role = 'admin' | 'user' | 'guest'

  // ✗ Avoid
  enum Role { Admin, User, Guest }
  ```

### Naming Conventions
- **Variables/functions:** camelCase (`getUserData`, `isLoading`)
- **Types/interfaces:** PascalCase (`UserData`, `ApiResponse`)
- **Constants:** UPPER_SNAKE_CASE (`MAX_RETRIES`, `API_BASE_URL`)
- **Components:** PascalCase (`LoginForm`, `UserCard`)
- **Files:** Match export name (`LoginForm.tsx`, `user-api.ts`)

### Comments
- **Avoid obvious comments** — Code should be self-documenting
- **Use comments for WHY, not WHAT**
  ```typescript
  // ✓ Good
  // Retry 3 times because external API is flaky under load
  const MAX_RETRIES = 3

  // ✗ Bad
  // Set max retries to 3
  const MAX_RETRIES = 3
  ```
- **JSDoc for public APIs only** (not for internal functions)

---

## Framework Preferences

### Frontend

**Framework:** Next.js 15 (App Router)

**Key Preferences:**
- Use Server Components by default
- Mark Client Components explicitly with `'use client'`
- Server Actions for mutations (not API routes)
- Route handlers (app/api) only for external APIs or webhooks

**Component Structure:**
```typescript
// Server Component (default)
async function UserPage({ params }: { params: { id: string } }) {
  const user = await prisma.user.findUnique({ where: { id: params.id } })
  return <UserProfile user={user} />
}

// Client Component (interactive)
'use client'
export function UserProfile({ user }: { user: User }) {
  const [isEditing, setIsEditing] = useState(false)
  return ...
}
```

**UI Library:** shadcn/ui + Tailwind CSS
- Copy components from shadcn (don't install as dependency)
- Customize in `components/ui/`
- Use Tailwind utilities for all styling
- No CSS-in-JS, no styled-components

---

### Backend

**Framework:** Next.js API Routes + Server Actions

**Database:** PostgreSQL + Prisma ORM
- Always use Prisma for database access
- Never write raw SQL (unless complex query requires it)
- Migrations in version control
- Seed data for development

**API Design:**
- RESTful where appropriate
- Server Actions for form submissions and mutations
- tRPC for type-safe API if complexity increases

---

### Testing

**Unit/Integration:** Vitest
- Test files colocated: `LoginForm.tsx` → `LoginForm.test.tsx`
- Test behavior, not implementation
- Aim for 80%+ coverage on critical paths

**E2E:** Playwright
- Test happy paths and critical flows
- Run in CI before deploy
- Use fixtures for test data

---

## Git Workflow

### Branching Strategy
- **main:** Production-ready code (protected)
- **Feature branches:** Short-lived, merge via PR
- **Naming:** `feature/add-user-auth`, `fix/login-bug`, `refactor/api-layer`

### Commit Discipline
- **Bead method:** Commit after each bead (15-45 min)
- **Message format:** Conventional commits
  ```
  feat: Add user authentication

  - JWT token generation
  - Login endpoint
  - Auth middleware

  Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
  ```
- **Frequency:** 8-12 commits/day expected

### Pull Requests
- **Self-review before requesting** (see patterns.md checklist)
- **Description:** What, why, testing notes
- **Size:** Keep PRs small (< 400 lines diff when possible)

---

## Testing Preferences

### Test Coverage
- **Critical paths:** 100% (auth, payments, data mutations)
- **Business logic:** 90%+
- **UI components:** 70%+ (focus on interactive components)
- **Utils/helpers:** 100%

### Test Structure
```typescript
describe('ComponentName', () => {
  it('does expected behavior when condition', () => {
    // Arrange
    const props = { ... }

    // Act
    render(<Component {...props} />)
    fireEvent.click(screen.getByRole('button'))

    // Assert
    expect(screen.getByText('Expected result')).toBeInTheDocument()
  })
})
```

### Mocking
- **Mock external APIs:** Always (don't hit real APIs in tests)
- **Mock database:** Use in-memory SQLite for Prisma tests
- **Mock heavy dependencies:** Yes (auth providers, payment processors)
- **Mock simple utils:** No (test the real implementation)

---

## Communication with Claude

### Detail Level
- **High-level questions:** Brief answers with links to docs
- **Implementation questions:** Detailed answers with code examples
- **Debugging:** Full error messages, relevant code context

### Explanation Style
- **For architecture decisions:** Detailed reasoning, trade-offs, alternatives
- **For simple tasks:** Concise, just the code
- **For complex refactors:** Step-by-step plan first, then implementation

### Code Completeness
- **Always provide complete files** — Never partial snippets or "rest stays the same"
- If file is >500 lines, provide full context of what changes
- Include all imports at top of file

### Error Handling
- When things break:
  1. Read the full error message
  2. Identify root cause (not symptoms)
  3. Provide complete fixed file
  4. Explain what went wrong in one sentence

---

## Development Workflow

### Daily Routine

**Morning:**
```bash
./essential/toolkit/memory-manager.sh start  # Load context
git pull origin main               # Sync with team
npm test                           # Verify everything works
```

**During Day:**
- Execute beads (15-45 min each)
- Commit after each bead
- Update task status
- Take breaks between beads

**Afternoon:**
```bash
./essential/toolkit/sprint-planner.sh update  # Update sprint progress
```

**Evening:**
```bash
npm test                           # Final test run
git push origin feature-branch     # Push day's work
./essential/toolkit/memory-manager.sh end    # Save context
```

---

### Sprint Workflow

**Sprint Planning (Day 0):**
- Review backlog
- Calculate velocity (last 3 sprints avg)
- Select stories
- Break into tasks
- Decompose into beads
- Commit sprint plan

**Daily Execution:**
- Morning: Load memory, check tasks
- Work: Execute beads, commit frequently
- Afternoon: Update progress
- Evening: Save memory

**Sprint End (Day 10):**
- Review completed work
- Run retrospective
- Update memory with learnings
- Plan next sprint

---

## Tool Preferences

### Editor
- **IDE:** VS Code
- **Extensions:**
  - Prisma
  - Tailwind CSS IntelliSense
  - ESLint
  - Prettier
  - GitLens

### Terminal
- **Shell:** Bash (Git Bash on Windows)
- **Multiplexer:** tmux (optional)

### API Testing
- **Tool:** Thunder Client (VS Code extension) or curl
- **No Postman** — Keep it simple

---

## Environment Variables

### Naming Convention
```bash
# Development
DATABASE_URL="postgresql://..."
NEXT_PUBLIC_API_URL="http://localhost:3000"

# Production
DATABASE_URL="postgresql://..."
NEXT_PUBLIC_API_URL="https://api.production.com"
```

### Management
- **Local:** `.env.local` (gitignored)
- **Staging:** Vercel dashboard
- **Production:** Vercel dashboard
- **Never commit:** `.env` files to git

---

## Performance Preferences

### Page Load
- **Target:** < 2s first contentful paint
- **Lighthouse score:** 90+ on all metrics
- **Images:** Always use Next.js Image component
- **Fonts:** Self-host, preload

### Database
- **Query time:** < 100ms average
- **Use indexes:** For all foreign keys and frequently queried fields
- **Avoid N+1:** Use Prisma include/select

### Bundle Size
- **Target:** < 200 KB initial bundle
- **Dynamic imports:** For heavy components
- **Tree shaking:** Verify with bundle analyzer

---

## Security Preferences

### Authentication
- **Tokens:** JWT in httpOnly cookies
- **Passwords:** bcrypt with 10 rounds
- **Session duration:** 15 min access token, 7 day refresh token
- **Rotation:** Refresh token rotation on use

### Data Validation
- **Client-side:** zod schemas
- **Server-side:** Same zod schemas
- **Never trust client data:** Always validate on server

### API Security
- **Rate limiting:** 100 requests/min per IP
- **CORS:** Strict origin checking in production
- **Secrets:** Environment variables only, never hardcoded

---

## Deployment Preferences

### CI/CD
- **Platform:** GitHub Actions
- **Pipeline:**
  1. Lint (ESLint)
  2. Type check (tsc)
  3. Unit tests (Vitest)
  4. E2E tests (Playwright)
  5. Build
  6. Deploy (Vercel for frontend, Railway for backend)

### Environments
- **Development:** Local machine
- **Staging:** Auto-deploy from `main` branch
- **Production:** Manual promotion from staging

### Monitoring
- **Errors:** Sentry
- **Analytics:** Vercel Analytics
- **Uptime:** UptimeRobot
- **Logs:** Vercel logs + Railway logs

---

## Cost Preferences

### Priority: Keep costs low

**Current monthly budget:** $50/month total

**Breakdown:**
- Claude API: ~$20/month (main expense)
- Vercel: Free tier
- Railway: ~$10/month (PostgreSQL)
- Misc (domains, etc.): ~$5/month
- Buffer: ~$15/month

**Optimizations:**
- Use prompt caching (90% savings on repetitive context)
- Use batch API for non-urgent tasks (50% savings)
- Minimize image assets (free CDN is generous but has limits)

---

## Learning Preferences

### Documentation
- **First choice:** Official docs (Next.js, Prisma, etc.)
- **Second choice:** GitHub issues for specific problems
- **Third choice:** Stack Overflow
- **Avoid:** Random blog posts (often outdated)

### When Stuck
1. Read error message completely
2. Check official docs
3. Search GitHub issues
4. Ask Claude with full context
5. Rubber duck debugging

---

## Collaboration Preferences

*(Currently solo dev, but preparing for team)*

### Code Review
- Review own code before requesting review
- Respond to review feedback within 24 hours
- Be kind and constructive in reviews

### Communication
- **Async-first:** Use GitHub comments, PR descriptions
- **Sync when needed:** Complex architectural discussions
- **Documentation:** Keep README, CLAUDE.md, STATUS.md up to date

---

**These preferences evolve. Review monthly during sprint retrospectives.**

**Last updated:** 2026-02-12
**Next review:** 2026-03-12
