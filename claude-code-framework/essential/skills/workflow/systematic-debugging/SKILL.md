---
name: systematic-debugging
description: Methodical debugging using reproducible steps, instrumentation, and root-cause analysis. Use when something is broken and you don't know why. Triggers on "bug", "broken", "not working", "error", "fails intermittently", "regression", "unexpected behavior".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: workflow
  source: community-contributed
  license: MIT
---

# Systematic Debugging

Debug methodically, not randomly. Every bug has a root cause — find it through structured investigation, not guessing.

## Why This Exists

Random debugging ("let me try changing this...") wastes hours. Agents especially burn through tokens and context windows guessing. This skill enforces a reproducible investigation flow.

## Instructions

### Step 1: Reproduce the Bug

Before touching any code:

```bash
# Capture the exact error
# Run the failing command/test and save full output
[COMMAND] 2>&1 | tee /tmp/debug-output.txt
```

**Checklist:**
- Can you trigger the bug on demand? (Yes → proceed. No → add logging first)
- What is the EXACT error message? (Copy it verbatim)
- When did it last work? (Check git log for recent changes)
- Does it fail in all environments or just one?

**If the bug is intermittent:**
```bash
# Run the operation N times and count failures
for i in $(seq 1 20); do [COMMAND] && echo "PASS" || echo "FAIL"; done
```

### Step 2: Isolate the Scope

Narrow down WHERE the bug lives. Work from outside in:

1. **Network layer:** Is the request reaching the server?
   ```bash
   curl -v [ENDPOINT] 2>&1 | head -30
   ```

2. **Application layer:** Is the right code path executing?
   ```bash
   # Add temporary logging at entry points
   console.log('[DEBUG] handler reached', { params, timestamp: Date.now() })
   ```

3. **Data layer:** Is the data what you expect?
   ```bash
   # Query the database directly
   docker exec -it [DB_CONTAINER] psql -U [USER] -d [DB] -c "SELECT * FROM [TABLE] WHERE [CONDITION] LIMIT 5;"
   ```

4. **Dependency layer:** Did an external service change?
   ```bash
   # Check dependency versions
   npm ls [PACKAGE]
   pip show [PACKAGE]
   ```

### Step 3: Form a Hypothesis

Write ONE sentence: "I believe the bug is caused by [X] because [evidence]."

**Good hypothesis:** "The API returns 500 because the database query times out when the results exceed 1000 rows — the error only occurs on the /analytics endpoint with date ranges > 30 days."

**Bad hypothesis:** "Something is wrong with the database."

### Step 4: Test the Hypothesis

Design a test that proves or disproves your hypothesis. The test should:
- Change exactly ONE thing
- Have a clear pass/fail outcome
- Be reversible

```bash
# Example: Test if the timeout is the issue
# Temporarily increase timeout to 60s
# If the bug disappears → hypothesis confirmed
# If the bug persists → hypothesis disproven, return to Step 2
```

### Step 5: Fix and Verify

1. Write the minimal fix (change as few lines as possible)
2. Run the reproduction steps from Step 1
3. Verify the fix doesn't break other tests:
   ```bash
   npm test        # or pytest, etc.
   ```
4. If in autonomous mode, write a regression test before committing

### Step 6: Document the Root Cause

Write a brief for the memory system:

```markdown
## Bug Report: [Short Description]
- **Symptom:** [What the user/system saw]
- **Root Cause:** [Why it happened]
- **Fix:** [What was changed]
- **Prevention:** [How to avoid this class of bug]
- **Files Changed:** [List]
```

## Common Debugging Patterns

### Pattern: "It works locally but not in Docker"

```bash
# Check environment variables
docker exec [CONTAINER] env | sort > /tmp/docker-env.txt
env | sort > /tmp/local-env.txt
diff /tmp/local-env.txt /tmp/docker-env.txt

# Check file permissions
docker exec [CONTAINER] ls -la /app/

# Check DNS resolution
docker exec [CONTAINER] nslookup [SERVICE_NAME]
```

### Pattern: "It was working yesterday"

```bash
# Find what changed
git log --oneline --since="yesterday" --all
git diff HEAD~5 --stat

# Binary search for the breaking commit
git bisect start
git bisect bad HEAD
git bisect good [LAST_KNOWN_GOOD_COMMIT]
# Run test at each step
```

### Pattern: "The API returns wrong data"

```bash
# Trace the data flow
# 1. Check what the client sends
curl -X POST [URL] -d '[PAYLOAD]' -v 2>&1

# 2. Check what the server receives (add request logging)
# 3. Check what the database returns (query directly)
# 4. Check what the server sends back (response logging)
# 5. Check what the client receives (browser devtools / curl output)
```

### Pattern: "Memory leak / performance degradation"

```bash
# For Node.js
node --inspect [SCRIPT]
# Then connect Chrome DevTools to chrome://inspect

# For Python
python -m cProfile -s cumtime [SCRIPT]

# For Docker containers
docker stats [CONTAINER]
```

## Autonomous Mode Behavior

When invoked by the orchestrator:

1. Capture full error output to a file
2. Check git log for recent changes (likely culprit)
3. Add structured logging to narrow scope
4. Form hypothesis, test it, fix or iterate
5. Write regression test
6. Commit with message: `fix: [description] — root cause: [cause]`
7. Write bug report to project memory
8. Remove temporary debug logging before final commit

## When to Use This Skill

✅ Use systematic-debugging when:
- Something broke and you don't know why
- A test is failing
- Behavior changed unexpectedly
- Performance degraded
- Errors appear in logs

❌ Don't use systematic-debugging for:
- Known issues with known fixes (just fix them)
- Docker-specific problems (use docker-debugger)
- Git problems (use git-recovery)
- Build failures (use build-error-fixer)

## Quick Reference

| Step | Action | Output |
|------|--------|--------|
| 1. Reproduce | Trigger the bug on demand | Exact error + reproduction steps |
| 2. Isolate | Narrow to layer + component | "Bug is in [X]" |
| 3. Hypothesize | One sentence theory | "Caused by [X] because [Y]" |
| 4. Test | Change one thing | Confirmed or disproven |
| 5. Fix | Minimal change | Working code + passing tests |
| 6. Document | Root cause report | Memory entry for prevention |
