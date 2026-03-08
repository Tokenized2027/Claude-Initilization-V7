# Team Config: Debug Investigation

> 3 investigators in parallel. For bugs with unclear root cause.

## When to Use

- Bug has multiple plausible explanations
- Single-agent debugging hit a dead end
- Production issue that needs fast parallel investigation
- Intermittent bug that's hard to reproduce

## Estimated Cost

3-5x a solo session. Worth it when the bug is blocking and time matters.

## Config

Replace `[PLACEHOLDERS]` and paste into your Claude Code lead session:

```
Create an agent team to investigate this bug:

[PASTE THE FULL ERROR MESSAGE OR BUG DESCRIPTION HERE.
Include: what should happen, what actually happens, when it started,
any recent changes that might be related.]

Read CLAUDE.md and STATUS.md for project context.

Spawn 3 investigation teammates, each testing a different hypothesis:

1. Hypothesis A — [FIRST THEORY]
   Example: "The API response format changed after the last backend
   deploy, causing the frontend to fail when parsing the response."
   Investigate by: reading the relevant API route, checking recent
   commits to the endpoint, comparing response shape to frontend types.

2. Hypothesis B — [SECOND THEORY]
   Example: "There's a race condition in the state management where
   stale data renders before the fresh API response arrives."
   Investigate by: reading the component's useEffect and state logic,
   checking for missing dependency arrays, looking for async ordering issues.

3. Hypothesis C — [THIRD THEORY]
   Example: "An environment variable is missing or misconfigured in
   production, causing a null reference when the config is loaded."
   Investigate by: checking .env.example vs actual env usage, searching
   for process.env references, checking deployment config.

Each investigator should:
- Read all relevant files for their hypothesis
- Run diagnostic commands if helpful
- Rate their confidence: confirmed / likely / unlikely / disproven
- Actively try to disprove the other hypotheses
- Message other teammates with evidence they find

After investigation:
- Have teammates debate findings (which hypothesis has the most evidence?)
- If a root cause is confirmed, have that investigator propose a fix
- If no clear root cause, synthesize what was learned and suggest
  next steps for further debugging
```

## Tips for Writing Hypotheses

Good hypotheses are:
- **Specific** — "The JWT token expires before the refresh logic triggers" not "auth is broken"
- **Testable** — each hypothesis should point to specific files or behaviors to check
- **Independent** — each hypothesis should lead to different code paths to investigate

If you're not sure what the hypotheses are, use this prompt instead:

```
Create an agent team to investigate this bug:

[PASTE ERROR/DESCRIPTION]

Read CLAUDE.md and STATUS.md for context.

Before spawning investigators, analyze the error and propose 3 likely
hypotheses. Then spawn a teammate for each one.

Have them investigate in parallel, challenge each other's findings,
and converge on the root cause.
```
