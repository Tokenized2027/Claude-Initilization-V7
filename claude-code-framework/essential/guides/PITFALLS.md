# Claude Code — Known Pitfalls & Watchouts
# Extracted from 2+ months of production experience

---

## 🔴 Critical: Data & AI Work

These are the highest-risk behaviors. If your project involves data analysis, ML/DL, simulations, or numerical work:

1. **Silent Data Subsampling** — CC will take shortcuts to reduce runtime without telling you. Example: you ask for analysis on a full dataset, it silently processes every 10th data point. **Always verify** the data scope in the code it writes.

2. **Numerical Confusion** — CC frequently gets confused about:
   - Which metric is "higher is better" vs "lower is better"
   - Relative comparisons (what's larger, what's significant)
   - Threshold interpretations
   - **Always double-check numerical claims yourself.**

3. **CLAUDE.md Doesn't Mean Compliance** — Having instructions in CLAUDE.md is necessary but not sufficient. CC sometimes ignores documented procedures entirely. **Periodically audit** whether it's actually following the rules.

---

## 🟡 Important: Code Quality

4. **Drift Without Commits** — When on a roll, CC makes many changes rapidly without stopping. Then something breaks and rolling back is painful. **Enforce frequent commits** — after every completed unit of work.

5. **Orphaned Code Accumulation** — CC creates new implementations without cleaning up the old ones. Explicitly instruct it to delete orphaned code and verify it does.

6. **Partial Fixes** — When debugging, CC sometimes applies a surface-level fix without addressing the root cause. Insist on root cause analysis.

7. **Sub-Agent Review Is Essential** — The automated code review hook (separate agent reviewing changes before commit) catches a huge number of issues. Don't skip it.

---

## 🟢 Workflow Tips

8. **Playwright MCP for Web Apps** — Non-negotiable for any project with a web UI. Saves hours of manual debugging by letting CC inspect and interact with the running app.

9. **Verbose Logging** — Require detailed structured logs on every run. Without them, CC struggles to debug. With them, it's very effective.

10. **Status.md Is The Single Source of Truth** — Without this file, starting new sessions is chaotic, handoffs are impossible, and you lose track of progress. Update it religiously.

11. **Iterative PRD/Tech Spec Process** — Having CC ask you questions before generating docs (and reviewing the output yourself before approving) produces dramatically better results than single-pass generation.

12. **5-Role Team Simulation** — Using CC Teams with CEO/PM/Frontend/Backend/AI roles for PRD and Tech Spec generation produces noticeably better results than a single-agent approach.

---

## Summary: The Trust Spectrum

| Category | Trust Level | Verification Needed |
|----------|-----------|-------------------|
| Scaffolding / boilerplate | High | Light review |
| UI / frontend code | Medium-High | Visual check + Playwright |
| API / backend logic | Medium | Code review hook + manual check |
| Data analysis / numbers | Low | Always verify manually |
| ML/DL model work | Very Low | Deep manual verification |
| Following CLAUDE.md rules | Medium | Periodic audits |
