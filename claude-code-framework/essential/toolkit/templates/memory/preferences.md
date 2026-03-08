# User Preferences

> Coding style, tool preferences, and workflow preferences for this developer.

---

## Coding Style

### Formatting

- **Indentation:** 2 spaces (never tabs)
- **Quotes:** Single quotes for strings (unless JSON)
- **Semicolons:** Always use them
- **Line length:** Max 100 characters
- **Trailing commas:** Always in multiline (improves git diffs)

### Naming Conventions

- **Variables:** camelCase (`userId`, `isActive`)
- **Components:** PascalCase (`LoginForm`, `UserProfile`)
- **Files:** Match component name (`LoginForm.tsx`)
- **Constants:** UPPER_SNAKE_CASE (`API_BASE_URL`)
- **Private methods:** Prefix with underscore (`_validateInput`)

### Code Organization

- **Imports:** Group and sort (external, internal, types, styles)
- **File structure:** Types → Constants → Main code → Exports
- **Component structure:** Props → State → Effects → Handlers → Render

---

## TypeScript Preferences

### Type Definitions

- **Prefer:** `interface` over `type` for object shapes
- **Return types:** Always define on functions
- **Strict mode:** Use `strict: true` in tsconfig
- **No `any`:** Avoid unless absolutely necessary (with comment explaining why)
- **Type imports:** Use `import type { ... }` for type-only imports

### Example

```typescript
// Good
interface User {
  id: string
  email: string
  createdAt: Date
}

function getUser(id: string): Promise<User | null> {
  // implementation
}

// Avoid
type User = {  // Use interface instead
  id: string
  email: string
}

function getUser(id: string) {  // Missing return type
  // implementation
}
```

---

## Framework Preferences

### Frontend: Next.js

- **Version:** Next.js 15+ (App Router, not Pages Router)
- **Rendering:** Server Components by default, Client Components when needed
- **Styling:** Tailwind CSS (no CSS-in-JS)
- **State:** Zustand for global state, React hooks for local
- **Data fetching:** Server Components + Server Actions (not SWR/React Query)

### Backend: Python/Flask or TypeScript/Node

**If Python:**
- **Framework:** Flask (not Django for smaller projects)
- **ORM:** SQLAlchemy
- **Validation:** Pydantic
- **Testing:** pytest

**If TypeScript:**
- **Runtime:** Node.js with TypeScript
- **API:** Express or Next.js API routes
- **ORM:** Prisma
- **Validation:** Zod

### Database

- **Preference:** PostgreSQL (for relational data)
- **Migrations:** Always use migration files (Prisma or Alembic)
- **ORM:** Prisma (TypeScript) or SQLAlchemy (Python)

---

## Testing Preferences

### Framework

- **Test runner:** Vitest (not Jest — faster, better ESM support)
- **React testing:** Testing Library (not Enzyme)
- **E2E:** Playwright (not Cypress for new projects)

### Testing Philosophy

- **Prefer:** Integration tests over unit tests
- **Coverage target:** 80% for business logic, 60% overall
- **Test location:** Co-located (e.g., `Button.test.tsx` next to `Button.tsx`)
- **Test naming:** Describe behavior, not implementation

### Example

```typescript
// Good
test('user can login with valid credentials', async () => {
  // test implementation
})

// Avoid
test('handleSubmit function works', async () => {
  // testing implementation detail
})
```

---

## Git Workflow

### Commit Style

- **Format:** Conventional Commits (`feat:`, `fix:`, `refactor:`, etc.)
- **Subject line:** Max 50 characters, imperative mood
- **Body:** Explain why, not what (code shows what)
- **Frequency:** Commit after every working state (not mid-feature)

### Examples

```bash
# Good
git commit -m "feat: add password reset flow

Implements forgot password email sending with SendGrid.
Token expires after 1 hour for security."

# Avoid
git commit -m "stuff"
git commit -m "fixed things"
```

### Branch Naming

- **Feature:** `feature/user-auth`
- **Bug fix:** `fix/login-error`
- **Hotfix:** `hotfix/critical-bug`
- **Experimental:** `experiment/new-approach`

---

## Development Environment

### Editor

- **Primary:** VS Code
- **Theme:** [Your preferred theme]
- **Font:** [Your preferred font]
- **Extensions:**
  - ESLint
  - Prettier
  - Tailwind CSS IntelliSense
  - GitLens

### Terminal

- **Shell:** [bash | zsh | fish]
- **Multiplexer:** [tmux | screen | none]

---

## Deployment Preferences

### Platform Preferences

- **Frontend hosting:** Vercel (for Next.js), Netlify (for static)
- **Backend hosting:** Railway, Fly.io, or Render (not Heroku)
- **Database:** Supabase (PostgreSQL), PlanetScale (MySQL), or Railway
- **CDN:** Cloudflare

### Deployment Style

- **CI/CD:** GitHub Actions
- **Environment:** Preview deployments for every PR
- **Monitoring:** Sentry for errors, Vercel Analytics for performance

---

## Communication with Claude

### Detail Level

**Preference:** High detail

**What this means:**
- Explain why, not just what
- Include tradeoffs and alternatives considered
- Point out potential issues before I ask

### Explanations

**Preference:** Balanced

**What this means:**
- Concise for simple tasks (bug fixes, small features)
- Detailed for architecture decisions and complex features
- Always include reasoning for decisions

### Code Review

**Preference:** Proactive

**What this means:**
- Point out potential issues (performance, security, maintainability)
- Suggest improvements even if current code works
- Explain tradeoffs clearly

### Error Handling

**Preference:** Root cause analysis

**What this means:**
- Don't just fix symptoms
- Explain why error occurred
- Suggest prevention strategies

---

## Workflow Preferences

### Session Structure

**Typical day:**
- Morning: Review STATUS.md, plan day's work (30 min)
- Work sessions: 90-minute focused blocks
- Breaks: 15 minutes between sessions
- End of day: Update STATUS.md, commit work (15 min)

### Task Size

**Preference:** Small, shippable increments (Bead Method)

**What this means:**
- Break features into 15-45 minute beads
- Commit after each bead
- Always have working code

### Planning

**Preference:** Sprint-based (2-week sprints)

**What this means:**
- Sprint planning every 2 weeks
- Daily progress tracking
- Sprint retros for continuous improvement

---

## Learning Preferences

### Documentation

**When I need to learn something new:**
- Start with official docs (not tutorials)
- Try minimal example first
- Then explore patterns

### New Technologies

**Adoption criteria:**
- Must solve real problem (not just "shiny new thing")
- Mature enough (v1.0+, active community)
- Good TypeScript support (if TypeScript project)

---

## Priorities

**In order of importance:**

1. **Correctness** — Code must work correctly
2. **Security** — No vulnerabilities
3. **Maintainability** — Code I can understand in 6 months
4. **Performance** — Fast enough (not prematurely optimized)
5. **Developer experience** — Nice tooling, good DX

**Not priorities:**
- Clever code (prefer clear over clever)
- Perfect code (ship working code, iterate)
- Latest tech (use proven tech)

---

## Time Allocation Preferences

**Rough guidelines:**

- **80%** Implementation (writing code)
- **10%** Planning (PRD, tech spec, sprint planning)
- **10%** Documentation (README, comments, API docs)

**Not:**
- Over-documenting (code should be self-documenting)
- Over-planning (agile over waterfall)

---

## Communication Style Preferences

### With Claude

**Prefer:**
- Direct communication ("Do X" not "Could you maybe do X?")
- Concrete examples over abstract descriptions
- Code snippets over prose

**Avoid:**
- Overly formal language
- Hedging ("maybe", "perhaps", "possibly")
- Long preambles (get to the point)

---

## Customization Notes

**Update this file when:**
- You change your mind about a preference
- You discover a new pattern you like
- You adopt a new tool or framework
- Your priorities shift

**Review frequency:** Monthly

---

## Template: Add New Preference

```markdown
## [Category]

### [Preference Name]

**Preference:** [What you prefer]

**Why:** [Reasoning]

**Example:**
[Code or workflow example]

**Don't:**
[What to avoid]
```

---

**Last Updated:** [Date]
**Review Date:** [Next review date]
