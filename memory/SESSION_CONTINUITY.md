# Session Continuity Protocol

How to pick up where you left off when a session ends mid-task.

## The Problem

You're in the middle of building a feature. The session times out, you lose connection, or you need to close your laptop. Tomorrow, Claude has zero memory of what you were doing.

Without a continuity protocol, you waste 10-15 minutes every time re-explaining context. With one, Claude is back on track in under 2 minutes.

## Required Artifacts

Every multi-step task should produce these as you work:

1. **Tracker file:** `docs/plans/<YYYY-MM-DD>-<slug>.md` — what's done, what's next
2. **Checkpoint commits:** `wip: <slug> <phase> - <state>` — progress saved in git
3. **Evidence:** file paths or command outputs referenced in the tracker

## Start Protocol

When beginning a multi-step task:

1. Create a tracker file with phases and status:

```markdown
# Feature: Add User Dashboard

## Status: in_progress
## Next Action: Build the chart component

| Phase | Status | Evidence |
|-------|--------|----------|
| Database schema | done | migrations/001_dashboard.sql |
| API endpoints | done | src/api/dashboard.ts |
| Chart component | in_progress | src/components/Chart.tsx |
| Integration tests | pending | |
```

2. Define exit criteria before coding
3. Mark phases `pending` before starting

## During Execution

1. Work on one phase at a time — mark it `in_progress`
2. When a phase completes, record the evidence path
3. Commit progress: `git commit -m "wip: dashboard charts - component built"`
4. If scope changes, add a note with why

## Interruption Protocol

When you need to stop mid-task:

1. Update the tracker: current status + exact next action
2. Add the exact command that should run first on resume
3. Commit partial progress:
   ```bash
   git add .
   git commit -m "wip: dashboard charts - styled but not connected to API"
   ```
4. Include in tracker:
   - Last known good state
   - Active blocker (if any)
   - What to verify before continuing

## Resumption Protocol

When picking up unfinished work, read in this order:

1. Latest `docs/plans/*.md` with `Status: in_progress`
2. `git log --oneline -n 20` for recent `wip:` commits
3. Evidence files referenced in the tracker
4. The "Next Action" field — run that first

Then:
1. Run the "first command on resume" from tracker
2. Verify the last phase before starting new work

## Cold Start Tax

Reserve the first 5-10 minutes of a resumed session for context recovery. This is mandatory overhead, not waste. The time you spend recovering context saves you from rebuilding something that was already half-done.

## Success Criteria

A session is resumable when a different person (or Claude) can continue within 5 minutes without guessing what you intended to do next.
