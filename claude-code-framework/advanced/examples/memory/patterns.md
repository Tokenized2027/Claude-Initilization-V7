# Patterns — Project Learnings

> Recurring problems, solutions, and best practices discovered during development

---

## Bug Patterns

### Database Connection Pooling

**Problem:** "Too many connections" error in development
**Frequency:** 3 times (2026-01-20, 2026-01-28, 2026-02-05)
**Root Cause:** Prisma creates new connection on every hot reload in Next.js dev mode
**Solution:**
```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = global as unknown as { prisma: PrismaClient }

export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: ['query'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```
**Prevention:** Always use singleton pattern for Prisma client in Next.js

---

### CORS Errors in Development

**Problem:** API calls from localhost:3000 to localhost:3001 blocked
**Frequency:** 2 times (2026-01-16, 2026-02-01)
**Root Cause:** Forgot to configure CORS middleware in API routes
**Solution:**
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  if (process.env.NODE_ENV === 'development') {
    response.headers.set('Access-Control-Allow-Origin', '*')
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
  }

  return response
}
```
**Prevention:** Add CORS config to API route boilerplate

---

### TypeScript "Cannot find module" After Adding Dependency

**Problem:** Import works in VSCode but fails at build
**Frequency:** 4 times (various dates)
**Root Cause:** Dependency installed in wrong package.json (monorepo), or types missing
**Solution:**
```bash
# Always install in correct workspace
npm install --workspace=apps/web <package>

# If types missing
npm install --save-dev @types/<package>

# If still broken, clear cache
rm -rf .next node_modules
npm install
```
**Prevention:** Check which package.json before npm install

---

### JWT Token Expiration Not Handled

**Problem:** User logged out unexpectedly after 15 minutes
**Frequency:** 1 time (caught in testing, 2026-02-06)
**Root Cause:** No refresh token rotation logic
**Solution:**
```typescript
// middleware.ts
export async function middleware(request: NextRequest) {
  const token = request.cookies.get('accessToken')

  if (!token || isTokenExpiringSoon(token)) {
    // Refresh token logic
    const refreshed = await refreshAccessToken(request)
    if (!refreshed) {
      return NextResponse.redirect(new URL('/login', request.url))
    }
  }

  return NextResponse.next()
}
```
**Prevention:** Always implement refresh token rotation with auth

---

## Solution Patterns

### API Route Error Handling

**Pattern:** Consistent error response format
**Usage:** Every API route
**Implementation:**
```typescript
// lib/api-error.ts
export class APIError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code?: string
  ) {
    super(message)
  }
}

// app/api/route.ts
export async function POST(request: Request) {
  try {
    // ... logic
  } catch (error) {
    if (error instanceof APIError) {
      return NextResponse.json(
        { error: error.message, code: error.code },
        { status: error.statusCode }
      )
    }

    console.error('Unhandled error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

---

### Form Validation with Zod

**Pattern:** Shared schema for client + server validation
**Usage:** All forms
**Implementation:**
```typescript
// schemas/user.ts
import { z } from 'zod'

export const userSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Password must be 8+ characters'),
})

export type UserInput = z.infer<typeof userSchema>

// Client component
const { errors } = userSchema.safeParse(formData)

// API route
const result = userSchema.parse(await request.json())
```

---

### Database Migration Workflow

**Pattern:** Never edit existing migrations, always create new
**Usage:** All schema changes
**Steps:**
```bash
# 1. Edit schema.prisma
# 2. Create migration
npx prisma migrate dev --name add_user_role

# 3. Review generated SQL in migrations/
# 4. Test migration
npx prisma migrate reset  # Dev only
npm run dev

# 5. Commit migration files
git add prisma/migrations/
git commit -m "Add user role column"
```
**Never:** Edit existing migration files (breaks production)

---

### Component Testing Pattern

**Pattern:** Test behavior, not implementation
**Usage:** All components with logic
**Implementation:**
```typescript
// components/LoginForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('submits form with valid credentials', async () => {
    const onSubmit = vi.fn()
    render(<LoginForm onSubmit={onSubmit} />)

    fireEvent.change(screen.getByLabelText('Email'), {
      target: { value: 'user@example.com' }
    })
    fireEvent.change(screen.getByLabelText('Password'), {
      target: { value: 'password123' }
    })
    fireEvent.click(screen.getByRole('button', { name: 'Login' }))

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'password123'
      })
    })
  })
})
```

---

## Performance Patterns

### Image Optimization

**Pattern:** Always use Next.js Image component with proper sizing
**Impact:** 60% faster page loads on image-heavy pages
**Implementation:**
```typescript
import Image from 'next/image'

// ✓ Good
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority  // For above-fold images
/>

// ✗ Bad
<img src="/hero.jpg" />  // No optimization
```

---

### Data Fetching

**Pattern:** Server Components for data fetching, minimize client-side fetching
**Impact:** 40% faster initial page load, better SEO
**Implementation:**
```typescript
// app/users/page.tsx (Server Component)
async function UsersPage() {
  const users = await prisma.user.findMany()  // Server-side, fast

  return <UserList users={users} />
}

// components/UserList.tsx (Client Component)
'use client'
export function UserList({ users }: { users: User[] }) {
  // Just renders, no fetching
  return users.map(user => <UserCard key={user.id} user={user} />)
}
```

---

### Avoid N+1 Queries

**Pattern:** Use Prisma include/select to eager load relations
**Impact:** 10x faster on list pages
**Implementation:**
```typescript
// ✗ Bad (N+1 query)
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { userId: user.id } })
}

// ✓ Good (1 query)
const users = await prisma.user.findMany({
  include: { posts: true }
})
```

---

## Architecture Patterns

### Feature-Based Folder Structure

**Pattern:** Group by feature, not by type
**Rationale:** Easier to find related files, better for scaling
**Structure:**
```
app/
  auth/
    login/
      page.tsx
      LoginForm.tsx
      actions.ts
      schemas.ts
    register/
      page.tsx
      RegisterForm.tsx
  dashboard/
    page.tsx
    DashboardStats.tsx
    actions.ts
```

Instead of:
```
components/
  LoginForm.tsx
  RegisterForm.tsx
  DashboardStats.tsx
actions/
  auth.ts
  dashboard.ts
```

---

### Server Actions Pattern

**Pattern:** Colocate actions with features, use revalidatePath
**Implementation:**
```typescript
// app/posts/actions.ts
'use server'
import { revalidatePath } from 'next/cache'

export async function createPost(data: CreatePostInput) {
  const post = await prisma.post.create({ data })

  revalidatePath('/posts')  // Refresh posts page
  return post
}

// app/posts/CreatePostForm.tsx
'use client'
import { createPost } from './actions'

export function CreatePostForm() {
  async function handleSubmit(formData: FormData) {
    await createPost({
      title: formData.get('title') as string,
      content: formData.get('content') as string,
    })
  }

  return <form action={handleSubmit}>...</form>
}
```

---

## Sprint Learnings

### Sprint 1 (Jan 15-26)

**Learnings:**
- First sprint with v4.4 systems
- Memory system saved ~10 min/session (5 sessions = 50 min total)
- Velocity: 18 points (conservative first sprint)
- Bead method reduced stress significantly

**Patterns Discovered:**
- Authentication tasks always take longer than estimated (2x buffer)
- Testing beads should be separate from implementation beads
- UI styling beads are fast (15-20 min), backend beads longer (30-40 min)

---

### Sprint 2 (Jan 29 - Feb 9)

**Learnings:**
- Velocity improved to 22 points (estimation improving)
- Database schema changes require migration bead + data migration bead
- Integration with external APIs (Stripe) took 3x estimate

**Patterns Discovered:**
- External API integration pattern:
  1. Bead 1: API client setup (30 min)
  2. Bead 2: Mock responses for testing (20 min)
  3. Bead 3: Actual integration (45 min)
  4. Bead 4: Error handling (30 min)
  5. Bead 5: Integration tests (40 min)

---

## Team Workflow Patterns

### Code Review

**Pattern:** Self-review before requesting review
**Checklist:**
- [ ] All tests passing
- [ ] No console.logs or debugger statements
- [ ] Types correct (no `any`)
- [ ] Error handling present
- [ ] Performance considered (no obvious N+1 queries)
- [ ] Accessibility checked (semantic HTML, ARIA labels)

---

### Git Commit Messages

**Pattern:** Follow conventional commits
**Format:**
```
<type>: <brief description>

<detailed explanation if needed>
<list of changes>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types:**
- `feat:` — New feature (bead completes feature)
- `fix:` — Bug fix
- `refactor:` — Code restructure (no behavior change)
- `test:` — Add/update tests
- `docs:` — Documentation only
- `chore:` — Dependencies, config, etc.

---

## Anti-Patterns (Avoid These)

### ❌ Committing Broken Code

**Never commit code that:**
- Doesn't compile/build
- Has failing tests
- Breaks existing functionality
- Has obvious errors

**If you must stop mid-work:**
- Revert to last working state
- Or: Create WIP commit, push to feature branch (not main)

---

### ❌ Skipping Tests for "Simple" Changes

**Reality:** "Simple" changes often have edge cases
**Rule:** If it has logic, it has tests
**Exceptions:** Pure presentational components (no logic)

---

### ❌ Not Using TypeScript Properly

**Bad:**
```typescript
const user: any = await fetchUser()  // Defeats the purpose
```

**Good:**
```typescript
type User = {
  id: string
  email: string
  role: 'admin' | 'user'
}

const user = await fetchUser()  // Type inferred
```

---

### ❌ Scope Creep Mid-Sprint

**Symptom:** "While I'm here, let me also..."
**Impact:** Velocity becomes unpredictable
**Solution:** Add to backlog, prioritize in next sprint

---

## Decision-Making Patterns

### When to Abstract

**Don't abstract until:**
- Pattern repeats 3+ times
- Abstraction is obvious and simple
- Abstraction reduces complexity (not just lines of code)

**Example:**
- First use: Inline code
- Second use: Copy-paste (acknowledge duplication)
- Third use: Extract to shared utility

---

### When to Optimize

**Don't optimize until:**
- Measurable performance problem exists
- Problem affects user experience
- Solution is clear and testable

**Process:**
1. Measure (profiler, lighthouse, etc.)
2. Identify bottleneck
3. Optimize
4. Measure again (verify improvement)

---

## Tool-Specific Patterns

### Prisma Best Practices

**Pattern:** Use transactions for multi-step operations
```typescript
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData })
  await tx.profile.create({ data: { userId: user.id, ...profileData } })
  return user
})
```

**Pattern:** Use connection pooling in production
```typescript
// Different pool sizes for different environments
const poolSize = process.env.NODE_ENV === 'production' ? 10 : 2
```

---

### Tailwind Best Practices

**Pattern:** Extract repeated utility combinations to components
```typescript
// ✗ Bad (repeated everywhere)
<button className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">

// ✓ Good (extracted to component)
<Button variant="primary">Click me</Button>
```

---

## Continuous Improvement

**Review this file:**
- After each retrospective
- When encountering repeated issues
- Monthly for cleanup

**Archive patterns:**
- Move obsolete patterns to ARCHIVE section
- Keep file under 50KB for fast loading
- Focus on actionable, current patterns

---

**Last Updated:** 2026-02-12
**Total Patterns:** 28
**Next Review:** 2026-03-12
