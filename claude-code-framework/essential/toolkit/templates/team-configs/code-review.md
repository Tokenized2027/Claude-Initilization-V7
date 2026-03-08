# Team Config: Code Review

> 3 reviewers in parallel. For thorough multi-lens review.

## When to Use

- Reviewing a PR or completed feature before merging
- Pre-deployment audit of critical code
- Periodic quality check on the codebase
- Any code that handles money, auth, or user data

## Estimated Cost

3-4x a solo session. Worth it for critical code paths.

## Config

Replace `[PLACEHOLDERS]` and paste into your Claude Code lead session:

```
Create an agent team to review [WHAT_TO_REVIEW — e.g., "all changes on
the feature/auth branch", "the /src/services/ directory", "PR #42"].

Read CLAUDE.md for project standards.

Spawn 3 review teammates:

1. Security Reviewer — focus on:
   - Authentication and authorization logic
   - Input validation and sanitization (SQL injection, XSS, CSRF)
   - Secrets management (no hardcoded keys, .env in .gitignore)
   - Dependency vulnerabilities (run npm audit)
   - CORS configuration and rate limiting
   - OWASP top 10 vulnerabilities
   Rate each finding: critical / high / medium / low.
   Include file:line references and fix suggestions with code examples.

2. Performance Reviewer — focus on:
   - N+1 database queries
   - Unnecessary re-renders in React components
   - Missing pagination on list endpoints
   - Bundle size and code splitting opportunities
   - Caching opportunities (API responses, computed values)
   - Database indexing on frequently queried fields
   - Memory leaks (event listeners, intervals not cleaned up)
   Rate each finding: critical / high / medium / low.
   Include file:line references and fix suggestions.

3. Quality Reviewer — focus on:
   - Test coverage (are critical paths tested?)
   - Error handling (loading, error, empty states on every component?)
   - TypeScript strictness (any "any" types? missing types?)
   - Accessibility (semantic HTML, ARIA labels, keyboard nav)
   - Code quality (DRY, single responsibility, file size)
   - Adherence to CLAUDE.md rules and project conventions
   Rate each finding: critical / high / medium / low.
   Include file:line references and fix suggestions.

After all reviewers finish:
- Have them challenge each other's findings (are any false positives?)
- Synthesize into a single review report with:
  - Executive summary (1 paragraph)
  - Critical issues (must fix before merge)
  - High priority (should fix before merge)
  - Medium/low (can fix later)
  - Overall assessment: APPROVE / REQUEST CHANGES / BLOCK
```

## Variations

**DeFi/Blockchain project — add a fourth reviewer:**

```
4. Blockchain Reviewer — focus on:
   - Smart contract interaction safety (re-entrancy, gas limits)
   - Slippage protection on trades/swaps
   - Private key handling (never in frontend, never logged)
   - RPC response validation
   - Chain ID verification
   - Address checksum validation
```
