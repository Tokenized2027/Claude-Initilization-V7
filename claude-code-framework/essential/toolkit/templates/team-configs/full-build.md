# Team Config: Full Build

> All tiers. 6-8 teammates. For building a new system from scratch.

## When to Use

- Brand new project with PRD and Tech Spec approved
- Major new system that spans frontend, backend, tests, and deployment
- You want full automated orchestration of the entire pipeline

## Estimated Cost

5-10x a solo session. Best for projects where the time savings justify the token cost.

## Config

Replace `[PLACEHOLDERS]` and paste into your Claude Code lead session:

```
Create an agent team to build [PROJECT_NAME].

Read CLAUDE.md, STATUS.md, and docs/PRD.md for project context.

Spawn teammates for a full build pipeline:

1. Architect — design the technical blueprint. Require plan approval
   before proceeding. Read docs/PRD.md and docs/TECH_SPEC.md. Produce:
   system overview, component diagram, data flow, tech stack decisions,
   file structure, and integration points.

2. Frontend Dev — implement the UI. Owns /app, /components, /lib, /types,
   and /public. Uses Next.js App Router, TypeScript strict, Tailwind CSS.
   Handle all states (loading, error, empty). Mobile-first, dark theme.
   Wait for architect's approved plan before starting.

3. Backend Dev — implement APIs and data layer. Owns /src/routes,
   /src/services, /src/models, and /src/middleware. Validate all inputs
   with Zod. Use proper HTTP status codes. Structured logging.
   Wait for architect's approved plan before starting.

4. Security Auditor — review all code for vulnerabilities after both
   devs complete. Run npm audit. Check OWASP top 10. Produce audit
   report at docs/SECURITY_AUDIT_REPORT.md. Must pass before testing.

5. Tester — write and run integration + E2E tests after security passes.
   Owns /tests directory. Test happy paths, error handling, edge cases.
   Produce test report at docs/TEST_REPORT.md.

6. Technical Writer — document features as they complete. Runs throughout.
   Owns README.md and docs/ (except PRD, TECH_SPEC, and audit reports).
   Include setup instructions, API reference, and architecture notes.

Rules for all teammates:
- Read CLAUDE.md before starting any work
- Never edit files owned by another teammate
- Commit after every completed unit of work
- Message the relevant teammate if you need something from their domain

Coordinate work through the shared task list.
Create 5-6 tasks per implementation teammate.
Wait for all teammates to finish before synthesizing results.
Use delegate mode — do not implement anything yourself.
```

## Optional Additions

**Add Designer + API Architect (Tier 2) for larger projects:**

Add these between Architect and the devs:

```
2b. Designer — create UI/UX specs and component system from architect's
    blueprint. Produce design tokens, component specs, and page layouts
    in docs/DESIGN_SYSTEM.md. Work in parallel with API Architect.

2c. API Architect — define all endpoints, request/response schemas, and
    auth patterns from architect's blueprint. Produce API contracts in
    docs/API_CONTRACTS.md. Work in parallel with Designer.

Frontend Dev waits for Designer's specs. Backend Dev waits for API contracts.
```

**Add DevOps (Tier 5) for deployment config:**

```
7. DevOps — configure Docker, CI/CD pipeline, and deployment after tests
   pass. Owns Dockerfile, docker-compose.yml, .github/workflows/, and
   deployment configs. Set up health checks and monitoring.
```
