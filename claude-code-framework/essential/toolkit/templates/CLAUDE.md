# CLAUDE.md Template — Project Boilerplate

> Copy this file into the root of every new project. Fill in the [PLACEHOLDERS].

---

## Project Info

- **Repo:** [GIT_REPO_URL]
- **Stack:** [e.g., Next.js / Python Flask / etc.]
- **Key docs:** See linked files below

## Linked Project Files

- PRD: `./docs/PRD.md`
- Tech Spec: `./docs/TECH_SPEC.md`
- Status: `./STATUS.md`

---

## Code Quality Rules

1. **Keep code clean.** No dead code, no commented-out blocks, no orphaned imports.
2. **When making changes:** If any code becomes "orphaned" (no longer called by anything), delete it immediately.
3. **DRY principle:** If a code snippet is used more than once, extract it into its own function or a shared utility file under `utils/`. Never duplicate logic.
4. **Temporary test files** go under `tmp/` which is gitignored. Never commit test scratch files.
5. **Every file must have a clear single responsibility.** If a file grows beyond ~300 lines, discuss splitting it.

## Logging & Debugging

6. **Every run must produce detailed logs.** Use structured logging with timestamps, function names, and input/output summaries. Save logs to `logs/` directory.
7. **Log levels matter:** Use DEBUG for data flow details, INFO for operations, WARNING for recoverable issues, ERROR for failures.

## Git Discipline

8. **Commit frequently.** After every completed unit of work (feature, fix, refactor), make a commit with a clear message.
9. **Never write directly to protected branches** (main, production). Always work on feature branches.
10. **Commit messages format:** `type(scope): description` — e.g., `feat(dashboard): add whale alert component`

## Self-Correction Protocol

11. **When I correct you on something substantive, add the correction to this file** under the "Learned Corrections" section below. This ensures the mistake is never repeated.
12. **After every code change, update `STATUS.md`** with what was changed, current state, and any new bugs or issues.

## Data & AI Work (CRITICAL)

13. **Never subsample or simplify data unless explicitly asked.** If analysis is requested on "the full dataset," run it on the FULL dataset. Do not silently take every Nth point to save time.
14. **Double-check numerical comparisons.** Verify what "higher is better" vs "lower is better" means for each metric before making claims.
15. **Follow instructions in this file literally.** If a procedure is documented here, do not deviate or improvise an alternative approach.

---

## Learned Corrections

<!-- Claude Code adds entries here when corrected on substantive issues -->

| Date | Correction |
|------|-----------|
| | |

---

## Project-Specific Rules

<!-- Add project-specific instructions below -->

