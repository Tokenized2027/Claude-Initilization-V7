# Bead Chain: [Feature Name]

> **Sprint:** Sprint XX
> **Story:** [Story Name] (X points)
> **Total Estimate:** X hours / Y beads
> **Status:** Planning | In Progress | Completed

---

## Feature Overview

**Goal:** [What this feature accomplishes in one sentence]

**User Value:** [Why this matters to users]

**Acceptance Criteria:**
- [ ] User can [action 1]
- [ ] System handles [edge case]
- [ ] Tests verify [behavior]

---

## Bead Chain Overview

**Total Beads:** YY
**Estimated Time:** X hours (Y beads × avg 25 min/bead)
**Expected Completion:** [Date]

**Chain Type:** Linear | Parallel | Fan-Out

**Dependency Graph:**
```
[Visualize bead dependencies if complex]

Example:
Bead 1 → Bead 2 → Bead 3 → Bead 5
              ↓
            Bead 4 → Bead 5
```

---

## Bead 1: [Bead Name] (Xm)

**Status:** ⏸️ Not Started | 🔄 In Progress | ✅ Done

**Outcome:** [What will work after this bead is complete]

**Tasks:**
- [ ] Specific task 1
- [ ] Specific task 2
- [ ] Specific task 3

**Acceptance:**
- [ ] Code works (tested manually or with test)
- [ ] Tests pass
- [ ] Committable (no broken state)

**Files to modify:**
- `path/to/file1.ts`
- `path/to/file2.ts`

**Implementation notes:**
[Any specific technical notes or gotchas]

**Commit message:**
```
feat: [brief description of this bead]
```

**Blockers:**
- None | [Description of what blocks this bead]

**Dependencies:**
- Requires: [Previous bead numbers, if any]
- Blocks: [Next bead numbers that depend on this]

**Time estimate:** Xm
**Actual time:** [Fill after completion]

---

## Bead 2: [Bead Name] (Xm)

[Same structure as Bead 1]

---

## Bead 3: [Bead Name] (Xm)

[Same structure as Bead 1]

---

[Repeat for all beads]

---

## Progress Tracking

### Current Status

**Current Bead:** Bead X / Y

**Progress:** ▓▓▓▓▓░░░░░ XX%

**Beads Completed:** X / Y

**Time Spent:** Xh Ym

**Time Remaining:** ~Xh Ym

**On Track:** ✅ Yes | ⚠️ Slightly Behind | ❌ Behind Schedule

---

### Completed Beads

| Bead | Name | Est. | Actual | Commit | Notes |
|------|------|------|--------|--------|-------|
| 1 | [Name] | 15m | 18m | abc123 | [Any notes] |
| 2 | [Name] | 20m | 20m | def456 | [Any notes] |
| 3 | [Name] | 25m | 30m | ghi789 | [Any notes] |

**Average bead time:** XXm (vs XXm estimated)

**Variance:** [Analysis of why faster/slower]

---

### Remaining Beads

| Bead | Name | Est. | Status | Blockers |
|------|------|------|--------|----------|
| 4 | [Name] | 20m | 🔄 In Progress | None |
| 5 | [Name] | 15m | ⏸️ Waiting | Bead 4 |
| 6 | [Name] | 30m | ⏸️ Waiting | Bead 5 |

---

## Velocity Tracking

**Beads per hour:** X beads

**Beads per day:** X beads (based on [hours/day])

**Projected completion:** [Date]

**Burndown:**
```
Beads Remaining
    15 |●
    14 | ●
    12 |  ●
    10 |   ●
     8 |    ●● ← Current
     6 |
     4 |
     2 |
     0 |
       +──────────────
       D0 D1 D2 D3 D4
```

---

## Learnings & Adjustments

### Estimation Accuracy

**Beads that took longer:**
- Bead X: [Name] — Est: Xm, Actual: Ym
  - Reason: [Why it took longer]
  - Learning: [What to remember for future estimates]

**Beads that were faster:**
- Bead Y: [Name] — Est: Xm, Actual: Ym
  - Reason: [Why it was faster]

### Mid-Chain Adjustments

**Beads added:**
- Bead Xa: [Name] (Xm) — Inserted between Bead X and Y
  - Reason: [Why added]

**Beads removed:**
- Original Bead Z — Reason: [Why not needed]

**Beads combined:**
- Bead A + Bead B = Bead AB — Reason: [Why combined]

---

## Parallel Tracks

*Use this section if beads are executed in parallel (e.g., frontend + backend)*

### Track A: Backend

**Owner:** Backend Developer

**Beads:**
- Bead 1: API endpoint (20m) — ✅ Done
- Bead 2: Validation (15m) — 🔄 In Progress
- Bead 3: Database integration (30m) — ⏸️ Waiting

**Progress:** 1/3 beads

---

### Track B: Frontend

**Owner:** Frontend Developer

**Beads:**
- Bead 4: Component shell (15m) — ✅ Done
- Bead 5: Form inputs (20m) — ⏸️ Waiting
- Bead 6: Styling (25m) — ⏸️ Waiting

**Progress:** 1/3 beads

---

### Integration Point

**Bead 7:** Wire frontend to backend (20m)

**Dependencies:** All Track A and Track B beads complete

**Status:** ⏸️ Blocked

---

## Quality Checks

### Per-Bead Checklist

After each bead, verify:
- [ ] Code compiles/runs without errors
- [ ] Relevant tests pass (unit or integration)
- [ ] No console errors or warnings
- [ ] Follows project code style
- [ ] Can be committed in working state

### End-of-Chain Checklist

After all beads complete:
- [ ] All acceptance criteria met
- [ ] Full integration test passes
- [ ] No regressions (existing features still work)
- [ ] Documentation updated (if applicable)
- [ ] Story marked as "Done" in sprint

---

## Risk Log

Track risks identified during bead execution.

### Risk 1: [Risk Description]

**Probability:** High | Medium | Low

**Impact:** High | Medium | Low

**Affects Beads:** [Bead numbers]

**Mitigation:** [What you'll do about it]

**Status:** Open | Mitigated | Realized

---

## Session Log

Track when work was done (useful for retrospectives).

### [Date] — Session 1

**Time:** Xh Ym

**Beads Completed:** Bead 1, Bead 2

**Issues Encountered:**
- [Issue 1 and resolution]

**Energy Level:** High | Medium | Low

**Notes:**
- [Any notes about the session]

---

### [Date] — Session 2

[Same structure]

---

## Integration Points

**API Contracts:** [Link to API documentation if backend/frontend integration]

**Data Models:** [Link to schema definitions]

**Shared Types:** [Link to TypeScript interfaces or data structures]

**External Dependencies:**
- [Library/Service 1]: Version X.Y.Z
- [Library/Service 2]: Version X.Y.Z

---

## Testing Strategy

### Per-Bead Testing

Each bead should include:
- Manual test: [How to verify it works]
- Automated test: [Unit or integration test added]

### Integration Testing

After all beads complete:
- [ ] End-to-end test: [Test scenario]
- [ ] Edge case test: [Edge case 1]
- [ ] Edge case test: [Edge case 2]

---

## Rollback Plan

If a bead fails or causes issues:

**Immediate rollback:**
```bash
git log --oneline -5
git revert [commit-hash]
```

**Alternative approach:**
[If this bead chain fails, what's plan B?]

---

## Related Documents

- Sprint Plan: `docs/SPRINT_XX.md`
- Story Card: [Link or reference to story]
- Tech Spec: `docs/TECH_SPEC.md`
- API Docs: `docs/API_DOCS.md`

---

## Memory Integration

### Patterns Learned

**Add to memory after completion:**

Pattern: [Pattern name]
- Context: [When this pattern applies]
- Solution: [What worked]
- Files: [Where implemented]

### Decisions Made

**Add to memory:**

Decision: [Decision made during bead execution]
- Rationale: [Why]
- Alternatives: [What else was considered]
- Impact: [Effect on codebase]

---

## Completion Summary

*Fill this out when all beads are done*

**Completed Date:** [Date]

**Total Time:** Xh Ym

**Estimated vs Actual:** Est: Xh, Actual: Yh (variance: +/- Zh)

**Beads Completed:** Y / Y (100%)

**Commits:** XX

**Tests Added:** XX

**Files Modified:** XX

**Lines Changed:** +XXX / -YYY

**Blockers Encountered:** X

**Learnings:**
1. [Learning 1]
2. [Learning 2]
3. [Learning 3]

**Success Criteria Met:** ✅ Yes | ❌ No

**Story Accepted:** ✅ Yes | ❌ No | ⏸️ Pending Review

**Added to Portfolio:** ✅ Yes | ⏸️ To be added

---

**Template Version:** v4.4
**Last Updated:** [Date]
