---
name: safe-push
description: >-
  Commit and push code safely with all quality gates. Use when the user says
  "push", "push this", "commit and push", "ship this code", "push it up",
  "get this on the branch", or when code changes are ready to go to remote.
  Encodes PII scan, typecheck, test, lint, and branch safety.
version: 1.0.0
---

# Safe Push Skill

Push code with all quality gates. Follow every step.

## Live Context (auto-injected)
- Branch: !`git branch --show-current 2>/dev/null`
- Dirty files: !`git status --porcelain 2>/dev/null | head -10`
- Last commit: !`git log --oneline -1 2>/dev/null`
- CI status: !`gh pr checks 2>/dev/null | head -5 || echo "no PR"`

## Step 0: Check Concurrent Sessions

If multiple sessions may be running, create your own branch or use a worktree.
NEVER edit on a shared branch.

## Step 1: PII Scan (MANDATORY)

Grep changed files for banned patterns. BLOCK the commit if ANY match.

Customize the patterns below for your project:

```bash
git diff --cached --name-only | xargs grep -nE \
  '[YOUR_EMAIL]@[YOUR_DOMAIN]|@gmail\.com|[YOUR_PHONE_PATTERN]|[YOUR_NAME_PATTERN]|ANTHROPIC_API_KEY=|OPENAI_API_KEY=' \
  2>/dev/null
```

If matches found: remove the PII, use `info@[YOUR_DOMAIN]` for contacts, use `[REDACTED]` for IDs.

## Step 2: Typecheck

```bash
# Adjust for your project's typecheck command
npm run typecheck   # or: pnpm typecheck, yarn tsc --noEmit
```

Run FULL project typecheck, not just the changed files. Shared type changes can break other modules.

## Step 3: Test

```bash
# Adjust for your project's test command
npm test   # or: pnpm test, yarn test
```

Run the full test suite.

## Step 4: Lint (if configured)

```bash
# Adjust for your project's lint command
npm run lint   # or: pnpm lint, yarn lint
```

## Step 5: Commit

Conventional commit format:
```bash
git commit -m "$(cat <<'EOF'
feat: description of what changed

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

Prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`

## Step 6: Push

```bash
git push -u origin <branch-name>
```

NEVER push to `main`. Always use a feature branch.

## Step 7: Verify

```bash
gh pr checks <PR_NUMBER>  # If PR exists
```

Or confirm the push succeeded:
```bash
git log origin/<branch>..HEAD  # Should be empty after push
```

## What NOT to Do

- NEVER push to main
- NEVER skip the PII scan
- NEVER typecheck only the changed file (must be full project)
- NEVER commit .env, credentials, or secret files
- NEVER use --no-verify to skip pre-commit hooks
