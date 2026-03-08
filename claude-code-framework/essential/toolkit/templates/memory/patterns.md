# Learned Patterns

> Patterns discovered during development that should be remembered and reused.

---

## Bug Patterns

### Docker Port Conflicts

**Pattern:** Docker says port in use but `docker ps` shows nothing

**Root cause:** Previous container wasn't fully cleaned up

**Solution:** `docker compose down -v && docker compose up -d`

**Frequency:** Common (happened 3+ times)

**Prevention:** Always use `docker compose down` not Ctrl+C

**Related files:** `docker-compose.yml`

**Projects:** [List projects where this occurred]

---

### TypeScript "any" Creep

**Pattern:** API responses typed as `any`, spreads through codebase

**Root cause:** Skipping type definition when tired or rushed

**Solution:** Create proper interface in `types/api.ts` immediately

**Prevention:** ESLint rule `@typescript-eslint/no-explicit-any`

**Related files:** `types/`, API route files

**Projects:** [List projects]

---

## Solution Patterns

### Authentication Flow (JWT + Cookie)

**Pattern:** JWT stored in httpOnly cookie + access token in memory

**Why this works:** XSS protection + CSRF protection

**Implementation:**
- JWT in httpOnly cookie (secure from XSS)
- CSRF token in separate cookie
- Access token in memory (cleared on page refresh)

**Reference implementation:** `lib/auth.ts`, `middleware/auth.ts`

**Projects:** [List projects using this pattern]

**Tradeoffs:**
- Pros: Security, works with SSR
- Cons: Requires server-side session for refresh

---

### Form Validation (Zod)

**Pattern:** Schema-based validation with Zod

**Why this works:** Type-safe, reusable, clear error messages

**Implementation:**
```typescript
// types/validation.ts
export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
})

// In component
const result = loginSchema.safeParse(formData)
```

**Reference implementation:** `types/validation.ts`

**Projects:** [List projects]

---

## Performance Patterns

### Database Query Optimization

**Pattern:** N+1 queries causing slow page loads

**Root cause:** Fetching related data in loops instead of joins

**Solution:** Use `include` or `select` in Prisma queries

**Example:**
```typescript
// Bad: N+1 queries
const users = await prisma.user.findMany()
for (const user of users) {
  const posts = await prisma.post.findMany({ where: { userId: user.id } })
}

// Good: Single query with join
const users = await prisma.user.findMany({
  include: { posts: true }
})
```

**Projects:** [List projects]

---

## API Design Patterns

### Error Response Format

**Pattern:** Consistent error response structure

**Format:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly message",
    "details": { "field": "email", "reason": "Invalid format" }
  }
}
```

**Why this works:** Frontend can handle errors consistently

**Implementation:** Error middleware in API routes

**Projects:** [List projects]

---

## Testing Patterns

### Integration Test Structure

**Pattern:** AAA pattern (Arrange, Act, Assert)

**Implementation:**
```typescript
test('user can login with valid credentials', async () => {
  // Arrange
  const user = await createTestUser()

  // Act
  const response = await request(app)
    .post('/api/login')
    .send({ email: user.email, password: 'password' })

  // Assert
  expect(response.status).toBe(200)
  expect(response.body).toHaveProperty('token')
})
```

**Projects:** [List projects]

---

## Deployment Patterns

### Environment Variables

**Pattern:** Tiered environment variable validation

**Implementation:**
1. `.env.example` — Template with all vars
2. `.env` — Local development (gitignored)
3. `.env.production` — Production vars (deployed separately)
4. `lib/env.ts` — Runtime validation with Zod

**Projects:** [List projects]

---

## Anti-Patterns (What NOT to do)

### Don't: Hardcode Configuration

**What not to do:** `const API_URL = "http://localhost:3000"`

**Why it's bad:** Breaks in production, not configurable

**Do instead:** `const API_URL = process.env.NEXT_PUBLIC_API_URL`

**Caught in:** [List projects where this was a problem]

---

### Don't: Skip Migration Files

**What not to do:** Manually edit database schema without migration

**Why it's bad:** Can't reproduce in other environments, team out of sync

**Do instead:** Always generate migration: `prisma migrate dev`

**Caught in:** [List projects]

---

## Cross-Project Learnings

These patterns have been validated across multiple projects.

### Pattern: Feature Flags

**Validated in:** Project A, Project B, Project C

**Pattern:** Boolean flags in environment variables to enable/disable features

**Implementation:**
```typescript
const FEATURE_FLAGS = {
  newUI: process.env.ENABLE_NEW_UI === 'true',
  socialLogin: process.env.ENABLE_SOCIAL_LOGIN === 'true'
}
```

**Why it works:** Safe deployment, gradual rollout, easy rollback

---

## Template: Add New Pattern

```markdown
### [Pattern Name]

**Pattern:** [Description of what happens]

**Root cause:** [Why it happens]

**Solution:** [How to fix or what to do]

**Frequency:** [How often encountered]

**Prevention:** [How to avoid in future]

**Related files:** [File paths]

**Projects:** [Where this occurred]
```

---

**Last Updated:** [Date]
**Total Patterns:** [Count]
