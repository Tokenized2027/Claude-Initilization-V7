# Team Mode — Automated Multi-Agent Orchestration

> **Optional mode.** Use Claude Code's experimental agent teams feature to run your 10-agent pipeline with real parallelism and automated handoffs — all from a single terminal session.
>
> **Status:** Experimental (requires opt-in). All other modes (Solo, Direct, Full Pipeline) remain unchanged and are unaffected.
>
> **Last Updated:** February 12, 2026

---

## Table of Contents

1. [What Is Team Mode](#1-what-is-team-mode)
2. [When to Use Team Mode](#2-when-to-use-team-mode)
3. [Prerequisites](#3-prerequisites)
4. [Operating Modes Comparison](#4-operating-modes-comparison)
5. [Agent-to-Teammate Mapping](#5-agent-to-teammate-mapping)
6. [Team Configurations](#6-team-configurations)
7. [Spawn Prompts](#7-spawn-prompts)
8. [Workflow Walkthroughs](#8-workflow-walkthroughs)
9. [Controlling Your Team](#9-controlling-your-team)
10. [Cost Considerations](#10-cost-considerations)
11. [Best Practices](#11-best-practices)
12. [Limitations & Troubleshooting](#12-limitations--troubleshooting)
13. [Quick Reference](#13-quick-reference)

---

## 1. What Is Team Mode

Team Mode maps your existing 10-agent tier architecture onto Claude Code's native agent teams feature. Instead of manually copying handoff briefs between Claude Project conversations, a **lead session** spawns **teammates** that communicate directly through a shared mailbox and task list.

```
BEFORE (Manual Pipeline):
  You → open Architect project → paste brief → copy handoff
  You → open PM project → paste handoff → copy handoff
  You → open Designer project → paste handoff → ...repeat for every agent

AFTER (Team Mode):
  You → tell the lead what to build → lead spawns teammates → they coordinate automatically
  You → monitor progress, steer when needed → lead synthesizes results
```

**What stays the same:**
- The 10 agent roles and their responsibilities
- The tier-based execution order
- Quality gates (security before testing)
- All CLAUDE.md rules and project conventions

**What changes:**
- Handoffs happen through native messaging, not copy-paste
- Tiers 2 and 3 run in true parallel (not manual tab-switching)
- A shared task list tracks progress with dependency resolution
- You interact from one terminal instead of 10 browser tabs

---

## 2. When to Use Team Mode

### Good Fit

| Scenario | Why Team Mode Helps |
|----------|-------------------|
| **Building a new system from scratch** | Full pipeline with real parallelism saves hours |
| **Cross-layer feature** (frontend + backend + tests) | Teammates work in parallel on separate file sets |
| **Code review with multiple lenses** | Security, performance, and coverage reviewers run simultaneously |
| **Debugging with competing hypotheses** | Teammates test different theories and challenge each other |
| **Large refactoring across modules** | Each teammate owns a different module |

### Poor Fit

| Scenario | Use Instead |
|----------|-------------|
| **Quick bug fix** | Solo Mode or Direct Mode |
| **Single-file change** | Solo Mode |
| **Sequential task with lots of dependencies** | Direct Mode (one agent) |
| **Tight budget / cost-sensitive** | Solo Mode (team mode uses 3-10x tokens) |
| **Routine daily work** | Direct Mode (90% of tasks) |

### Decision Tree

```
Is this a new system or major feature?
  ├── No → Use Solo Mode or Direct Mode
  └── Yes
        ├── Can work be parallelized across 2+ independent streams?
        │     ├── No → Use Full Pipeline (manual) or Direct Mode
        │     └── Yes
        │           ├── Budget allows 3-10x token usage?
        │           │     ├── No → Use Full Pipeline (manual)
        │           │     └── Yes → USE TEAM MODE
        │           └──
        └──
```

---

## 3. Prerequisites

### Enable Agent Teams

Agent teams are disabled by default. Enable with one of these methods:

**Option A: Settings file (recommended — persists across sessions)**

Add to `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Option B: Environment variable (per-session)**

```bash
# Bash/Zsh
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude

# PowerShell
$env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
claude
```

### Display Mode

Team Mode supports two display modes:

| Mode | How It Works | Requirements |
|------|-------------|-------------|
| **In-process** (default) | All teammates run in your terminal. Use Shift+Up/Down to switch. | Any terminal |
| **Split panes** | Each teammate gets its own pane. | tmux or iTerm2 (macOS) |

Set display mode in `~/.claude/settings.json`:
```json
{
  "teammateMode": "in-process"
}
```

Or per-session:
```bash
claude --teammate-mode in-process
```

> **Windows note:** Split-pane mode is not supported on Windows Terminal. Use in-process mode — it works fully. Navigate teammates with Shift+Up/Down.

### Project Setup

Team mode works with your existing project structure. Make sure you have:

- `CLAUDE.md` in project root (solo template or standard — both work)
- `STATUS.md` for project state
- `docs/PRD.md` and `docs/TECH_SPEC.md` (for full-build scenarios)

Teammates automatically read `CLAUDE.md` from the working directory, so all your project rules apply to every teammate.

---

## 4. Operating Modes Comparison

Your blueprint now has **four operating modes**. Choose based on the task:

| Mode | Sessions | Orchestration | Parallelism | Token Cost | Best For |
|------|---------|---------------|-------------|-----------|----------|
| **Solo Mode** | 1 | None | None | Lowest | Quick tasks, small features, bug fixes |
| **Direct Mode** | 1 | None (you → one agent) | None | Low | 90% of daily work |
| **Full Pipeline** | 10 (manual) | You copy-paste handoff briefs | Manual (open multiple tabs) | Medium | Building new systems when cost matters |
| **Team Mode** | 1 lead + N teammates | Automated (shared task list + mailbox) | Real (teammates work simultaneously) | Highest (3-10x) | Building new systems with real parallelism |

**Key distinction:** Full Pipeline and Team Mode both use the same 10 agents. The difference is orchestration — manual copy-paste vs. automated coordination.

---

## 5. Agent-to-Teammate Mapping

Your 10-agent tier architecture maps directly to team roles:

```
┌────────────────────────────────────────────────────────────────────┐
│ TEAM LEAD (your main Claude Code session)                          │
│ - Creates the team, spawns teammates, coordinates work             │
│ - Synthesizes results, reports back to you                        │
│ - Can enter "delegate mode" (Shift+Tab) to never implement itself │
└───────────────┬────────────────────────────────────────────────────┘
                │ spawns
                ▼
┌────────────────────────────────────────────────────────────────────┐
│ TIER 1 TEAMMATES (sequential — architect before PM)               │
│                                                                     │
│  🏗️ Architect Teammate                                              │
│  - Plans technical blueprint                                        │
│  - Require plan approval before proceeding                         │
│  - Messages PM teammate when done                                  │
│                                                                     │
│  📋 PM Teammate                                                     │
│  - Breaks architect's plan into tasks                               │
│  - Creates task list for implementation teammates                  │
│  - Blocked until Architect finishes                                │
└───────────────┬────────────────────────────────────────────────────┘
                │ tasks unblock
                ▼
┌────────────────────────────────────────────────────────────────────┐
│ TIER 2 TEAMMATES (parallel — work simultaneously)                 │
│                                                                     │
│  🎨 Designer Teammate          🔌 API Architect Teammate           │
│  - UI/UX specs, component      - Endpoint contracts,               │
│    system, design tokens          schemas, auth patterns           │
│  - Messages API Architect      - Messages Designer about           │
│    about component needs          data shapes                      │
│  - Both produce design          - Both contribute to               │
│    contract together              design contract                  │
└───────────────┬────────────────────────────────────────────────────┘
                │ design contract complete
                ▼
┌────────────────────────────────────────────────────────────────────┐
│ TIER 3 TEAMMATES (parallel — separate file ownership)             │
│                                                                     │
│  ⚛️ Frontend Teammate           ⚙️ Backend Teammate                 │
│  - Implements UI from design   - Implements APIs from              │
│    specs, consumes APIs           contracts, database models       │
│  - Owns: /app, /components,   - Owns: /src/routes,                │
│    /lib/api, /types              /src/services, /src/models        │
│  - Messages Backend about      - Messages Frontend about           │
│    API contract questions         endpoint changes                 │
└───────────────┬────────────────────────────────────────────────────┘
                │ implementation complete
                ▼
┌────────────────────────────────────────────────────────────────────┐
│ TIER 4 TEAMMATES (sequential — security before testing)           │
│                                                                     │
│  🔒 Security Auditor Teammate                                      │
│  - Reviews all code for vulnerabilities                            │
│  - Messages devs if fixes needed                                   │
│  - Must PASS before Tester begins                                 │
│                                                                     │
│  🧪 System Tester Teammate                                         │
│  - Integration + E2E tests                                         │
│  - Blocked until Security passes                                   │
│  - Messages devs with bug reports                                  │
└───────────────┬────────────────────────────────────────────────────┘
                │ tests pass
                ▼
┌────────────────────────────────────────────────────────────────────┐
│ TIER 5 TEAMMATE                                                    │
│                                                                     │
│  🚀 DevOps Teammate                                                │
│  - Docker, CI/CD, deployment config                                │
│  - Blocked until Tester passes                                     │
└────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────┐
│ TIER 6 TEAMMATE (async — runs throughout all tiers)               │
│                                                                     │
│  📚 Technical Writer Teammate                                      │
│  - Documents as features complete                                  │
│  - API docs, README, user guides                                   │
│  - No blocking dependencies — works continuously                  │
└────────────────────────────────────────────────────────────────────┘
```

### File Ownership Rules (Prevents Conflicts)

Two teammates editing the same file causes overwrites. Assign clear ownership:

| Teammate | Owns These Files/Directories |
|----------|------------------------------|
| Architect | `docs/TECH_SPEC.md`, `docs/ARCHITECTURE.md` |
| PM | `docs/PRD.md`, `STATUS.md` (task breakdown only) |
| Designer | `docs/DESIGN_SYSTEM.md`, `docs/COMPONENT_SPECS.md` |
| API Architect | `docs/API_CONTRACTS.md`, `types/api.ts` |
| Frontend | `/app`, `/components`, `/lib`, `/public`, `tailwind.config.*` |
| Backend | `/src/routes`, `/src/services`, `/src/models`, `/src/middleware` |
| Security Auditor | `docs/SECURITY_AUDIT_REPORT.md` |
| System Tester | `/tests`, `docs/TEST_REPORT.md` |
| DevOps | `Dockerfile`, `docker-compose.yml`, `.github/workflows/`, `vercel.json` |
| Technical Writer | `README.md`, `docs/USER_GUIDE.md`, `docs/API_DOCS.md` |

---

## 6. Team Configurations

Pre-built configurations for common scenarios. Copy-paste the spawn prompt to your lead session.

### Config 1: Full Build (All Tiers)

Use when building a new system from scratch. Spawns the full pipeline.

```
Create an agent team to build [PROJECT_NAME].

Read CLAUDE.md, STATUS.md, and docs/PRD.md for project context.

Spawn teammates for a full build pipeline:

1. Architect — design the technical blueprint. Require plan approval
   before proceeding. Read docs/PRD.md and docs/TECH_SPEC.md.

2. Frontend Dev — implement the UI. Owns /app, /components, /lib, /types,
   and /public. Uses Next.js App Router, TypeScript strict, Tailwind CSS.
   Wait for design contract before starting.

3. Backend Dev — implement APIs and data layer. Owns /src/routes,
   /src/services, /src/models, and /src/middleware. Wait for API contracts
   before starting.

4. Security Auditor — review all code for vulnerabilities after
   implementation completes. Must pass before testing.

5. Tester — write and run integration tests after security passes.
   Owns /tests directory.

6. Technical Writer — document features as they complete. Runs throughout.
   Owns README.md and docs/ (except PRD, TECH_SPEC, and audit reports).

Rules for all teammates:
- Read CLAUDE.md before starting work
- Never edit files owned by another teammate
- Commit after every completed unit of work
- Update STATUS.md only through the lead

Coordinate work through the shared task list.
Wait for all teammates to finish before synthesizing results.
Use delegate mode — do not implement anything yourself.
```

### Config 2: Feature Sprint (Tiers 2-4)

Use for adding a significant feature to an existing project. Skips architecture (already done).

```
Create an agent team to implement [FEATURE_NAME].

Read CLAUDE.md and STATUS.md for project context.

Spawn teammates:

1. Frontend Dev — implement the UI for [FEATURE_NAME]. Owns /app, /components,
   /lib. Follow the existing design system and component patterns.

2. Backend Dev — implement APIs for [FEATURE_NAME]. Owns /src/routes,
   /src/services, /src/models. Follow existing API patterns.

3. Tester — write integration tests after devs finish. Owns /tests.

Rules:
- Frontend and Backend work in parallel on separate files
- Tester is blocked until both devs complete
- All teammates read CLAUDE.md first
- Commit frequently with descriptive messages

Wait for all teammates to finish before reporting results.
```

### Config 3: Code Review (Tier 4 Parallel)

Use for thorough review of a PR or completed feature. Multiple reviewers run simultaneously.

```
Create an agent team to review [PR/FEATURE/BRANCH].

Spawn 3 review teammates:

1. Security Reviewer — focus on authentication, input validation, secrets
   management, OWASP top 10, and dependency vulnerabilities.

2. Performance Reviewer — focus on N+1 queries, unnecessary re-renders,
   bundle size, caching opportunities, and database indexing.

3. Quality Reviewer — focus on test coverage, error handling, TypeScript
   strictness, accessibility, and adherence to CLAUDE.md rules.

Each reviewer should:
- Read CLAUDE.md for project standards
- Review all changed files
- Report findings with severity (critical/high/medium/low)
- Include specific file:line references
- Provide fix suggestions with code examples

Have reviewers challenge each other's findings.
Synthesize all findings into a single review report.
```

### Config 4: Debug Investigation

Use when a bug has unclear root cause. Teammates test different hypotheses in parallel.

```
Create an agent team to investigate [BUG_DESCRIPTION].

Read CLAUDE.md and STATUS.md for context.

Spawn investigation teammates:

1. Hypothesis A: [Description of first theory, e.g., "API response
   format changed causing frontend parse error"]

2. Hypothesis B: [Description of second theory, e.g., "Race condition
   in state management causing stale data render"]

3. Hypothesis C: [Description of third theory, e.g., "Environment
   variable missing in production causing null reference"]

Each investigator should:
- Test their hypothesis by reading relevant code and running diagnostics
- Actively try to disprove the other hypotheses
- Message other teammates with evidence for/against theories
- Report findings with confidence level (confirmed/likely/unlikely/disproven)

Synthesize findings. If a root cause is confirmed, have the relevant
investigator propose and implement a fix.
```

---

## 7. Spawn Prompts

Individual spawn prompts for each agent role. Use these when you need specific teammates rather than a full configuration.

### Architect Teammate

```
Spawn an architect teammate with this prompt:

"You are the System Architect. Design the technical blueprint for
[WHAT_TO_BUILD]. Read CLAUDE.md, docs/PRD.md, and docs/TECH_SPEC.md.
Produce: system overview, component diagram, data flow, tech stack
decisions, file structure, integration points, and environment
requirements. Flag risks and scope into phases. Require plan approval
before any teammate acts on your blueprint."
```

### PM Teammate

```
Spawn a PM teammate with this prompt:

"You are the Product Manager. Read the architect's blueprint and break
it into implementation tasks. Each task should be self-contained,
assignable to one teammate, and produce a clear deliverable. Create
5-6 tasks per implementation teammate. Set task dependencies so
parallel work is maximized and sequential gates (security before
testing) are enforced."
```

### Frontend Teammate

```
Spawn a frontend teammate with this prompt:

"You are the Frontend Developer. Implement UI for [FEATURE/PROJECT]
using Next.js App Router, TypeScript strict, and Tailwind CSS.
You own: /app, /components, /lib, /types, /public. Read CLAUDE.md for
project rules. Handle all states (loading, error, empty). Mobile-first,
dark theme by default. Never edit backend files. Message the backend
teammate if you need API changes. Commit after every completed component."
```

### Backend Teammate

```
Spawn a backend teammate with this prompt:

"You are the Backend Developer. Implement APIs and data layer for
[FEATURE/PROJECT]. You own: /src/routes, /src/services, /src/models,
/src/middleware. Read CLAUDE.md for project rules. Validate all inputs
with Zod. Use proper HTTP status codes. Add structured logging.
Never edit frontend files. Message the frontend teammate if API
contracts change. Commit after every completed endpoint."
```

### Security Auditor Teammate

```
Spawn a security auditor teammate with this prompt:

"You are the Security Auditor. Review all code for vulnerabilities.
Run npm audit. Check for: hardcoded secrets, SQL injection, XSS, CSRF,
broken auth, insecure CORS, missing rate limits. Use the full security
checklist from the blueprint. Produce a security audit report at
docs/SECURITY_AUDIT_REPORT.md. If critical or high issues found,
message the relevant developer teammate with required fixes. Do not
mark your task complete until all critical issues are resolved."
```

### Tester Teammate

```
Spawn a tester teammate with this prompt:

"You are the System Tester. Write and run integration and E2E tests.
You own the /tests directory. Wait until security audit passes before
starting. Test: happy paths, error handling, edge cases, responsive
behavior, and accessibility. Produce a test report at docs/TEST_REPORT.md.
If bugs found, message the relevant developer teammate with reproduction
steps. Re-test after fixes."
```

### DevOps Teammate

```
Spawn a devops teammate with this prompt:

"You are the DevOps Engineer. Set up deployment infrastructure for
[PROJECT]. You own: Dockerfile, docker-compose.yml, .github/workflows/,
and deployment configs. Configure: Docker build, CI/CD pipeline, environment
variable management, health checks, and monitoring. Wait until tests
pass before finalizing deployment config."
```

### Technical Writer Teammate

```
Spawn a technical writer teammate with this prompt:

"You are the Technical Writer. Document features as teammates complete
them. You own: README.md, docs/USER_GUIDE.md, docs/API_DOCS.md.
Monitor the shared task list and document completed work. Include:
setup instructions, API reference, user guide, and architecture notes.
Run throughout the entire build — do not wait for all work to finish."
```

---

## 8. Workflow Walkthroughs

### Full Build Walkthrough

Step-by-step for building a new system using Team Mode.

**Step 1: Prepare your project**

```bash
# Create project with standard structure
mkdir my-project && cd my-project
cp $CLAUDE_HOME/claude-code-framework/essential/toolkit/templates/CLAUDE-SOLO.md CLAUDE.md
# Fill in placeholders in CLAUDE.md
# Create docs/PRD.md and docs/TECH_SPEC.md (iterate with Claude first)
```

**Step 2: Start Claude Code and create the team**

```bash
# Ensure agent teams are enabled
claude
```

Paste the Full Build config from [Section 6](#config-1-full-build-all-tiers) with your project details filled in.

**Step 3: Lead creates the team**

The lead will:
1. Read your project files
2. Spawn teammates
3. Create a shared task list
4. Enter delegate mode (coordinates only, doesn't implement)

**Step 4: Tier 1 executes (Architect → PM)**

- Architect teammate reads PRD and Tech Spec, produces blueprint
- Architect sends plan approval request to lead
- You review and approve (or reject with feedback)
- PM teammate receives blueprint, creates implementation tasks

**Step 5: Tiers 2 + 3 execute in parallel**

- Frontend and Backend teammates claim tasks and work simultaneously
- They message each other about API contract questions
- Technical Writer teammate documents completed features throughout
- You monitor with Shift+Up/Down, steer if needed

**Step 6: Tier 4 executes (Security → Tester)**

- Security Auditor reviews all code after devs finish
- If issues found, messages devs with required fixes
- After security passes, Tester runs integration tests
- If bugs found, messages devs, then re-tests

**Step 7: Tier 5 executes (DevOps)**

- DevOps configures deployment after tests pass

**Step 8: Clean up**

```
Ask all teammates to shut down, then clean up the team.
```

The lead synthesizes everything into a final status update.

### Feature Sprint Walkthrough

For adding a feature to an existing project.

**Step 1:** Start Claude Code in your project directory.

**Step 2:** Paste the Feature Sprint config with your feature details.

**Step 3:** Frontend and Backend work in parallel. Monitor progress.

**Step 4:** Tester runs tests after devs finish.

**Step 5:** Clean up the team.

Total time with team mode: typically 40-60% faster than sequential for features that span frontend + backend + tests.

---

## 9. Controlling Your Team

### Navigate Teammates (In-Process Mode)

| Action | Keys |
|--------|------|
| Select next teammate | Shift+Down |
| Select previous teammate | Shift+Up |
| View teammate's session | Enter (on selected teammate) |
| Send message to teammate | Type and press Enter |
| Go back from teammate view | Escape |
| Toggle task list | Ctrl+T |
| Enter delegate mode | Shift+Tab |

### Delegate Mode

Prevents the lead from implementing tasks itself. The lead can only:
- Spawn and shut down teammates
- Send messages
- Manage the shared task list
- Synthesize results

**Enable:** Press Shift+Tab after creating a team.

**Recommended for:** Full Build and Feature Sprint configs where you want pure orchestration.

### Plan Approval

When a teammate has `require plan approval`:
1. Teammate works in read-only plan mode
2. Teammate sends plan to lead for review
3. Lead approves → teammate implements
4. Lead rejects with feedback → teammate revises

Influence approval criteria in your spawn prompt:
```
Require plan approval. Only approve plans that:
- Include test coverage for all new endpoints
- Do not modify existing database schema
- Follow the existing file structure patterns
```

### Direct Messaging

You can message any teammate directly without going through the lead:

1. Shift+Up/Down to select the teammate
2. Type your message and press Enter

Use this to:
- Give additional context
- Redirect an approach that isn't working
- Ask follow-up questions about their progress
- Provide a file they need to see

### Shutting Down

Always shut down through the lead:

```
Ask the [teammate name] to shut down.
```

When all work is done:

```
Shut down all teammates, then clean up the team.
```

> **Important:** Never let teammates run cleanup. Always use the lead.

---

## 10. Cost Considerations

Team Mode uses significantly more tokens than other modes. Plan accordingly.

### Token Usage Estimates

| Configuration | Teammates | Estimated Token Multiplier | Rough Cost vs Solo |
|--------------|-----------|--------------------------|-------------------|
| Full Build | 6-8 | 5-10x | $5-50 per session |
| Feature Sprint | 3 | 3-5x | $3-15 per session |
| Code Review | 3 | 3-4x | $2-10 per session |
| Debug Investigation | 3 | 3-5x | $2-10 per session |

### Cost Optimization Tips

1. **Right-size your team.** Don't spawn 8 teammates for a 3-file feature. Use Feature Sprint (3 teammates) instead of Full Build (8).

2. **Specify models per teammate.** Use Sonnet for routine implementation, Opus for architecture and security:
   ```
   Spawn the architect teammate using Opus.
   Spawn implementation teammates using Sonnet.
   ```

3. **Keep sessions focused.** Short team sessions (1-2 hours) are more cost-effective than long ones. Context windows fill up, and costs grow.

4. **Start with review tasks.** Code review and debug investigation configs are cheaper and lower-risk than full builds. Good for learning the workflow.

5. **Monitor and steer early.** Redirect teammates that are going off-track before they waste tokens on the wrong approach.

6. **Combine with prompt caching.** If all teammates read the same CLAUDE.md, cached prompts reduce per-teammate costs. See `advanced/guides/PROMPT_CACHING.md`.

---

## 11. Best Practices

### Give Teammates Enough Context

Teammates load CLAUDE.md automatically but don't inherit the lead's conversation history. Include task-specific details in spawn prompts:

```
# ❌ Too vague
Spawn a frontend teammate.

# ✅ Specific enough
Spawn a frontend teammate with this prompt: "Implement the dashboard page
at /app/dashboard/page.tsx. The design shows a grid of whale alert cards
with real-time price data. Use the existing WhaleCard component in
/components/ui/WhaleCard.tsx. Consume GET /api/alerts from the backend.
Read CLAUDE.md for all project rules."
```

### Size Tasks Appropriately

The lead breaks work into tasks and assigns them to teammates.

- **Too small:** "Add a className to the div" — coordination overhead exceeds benefit
- **Too large:** "Build the entire frontend" — teammate works too long without check-ins
- **Right size:** "Implement the dashboard page with alert cards, filtering, and pagination" — clear deliverable, self-contained

Ask the lead to create 5-6 tasks per implementation teammate.

### Enforce File Ownership

Two teammates editing the same file causes overwrites. Always specify in spawn prompts which files/directories each teammate owns. See the [file ownership table](#file-ownership-rules-prevents-conflicts).

### Monitor and Steer

Check in every 10-15 minutes:
- Shift+Up/Down through teammates to see progress
- Ctrl+T to view the shared task list
- Message teammates that seem stuck or off-track
- Tell the lead to reassign work if someone finishes early

### Wait for Teammates

Sometimes the lead starts implementing instead of waiting:

```
Wait for your teammates to complete their tasks before proceeding.
Do not implement anything yourself.
```

Or preemptively enable delegate mode (Shift+Tab).

### Start Small

If you're new to team mode:

1. First use: **Code Review** config (read-only, low risk)
2. Second use: **Debug Investigation** (exploratory, no code changes)
3. Third use: **Feature Sprint** (3 teammates, scoped work)
4. Then: **Full Build** (full pipeline, highest complexity)

---

## 12. Limitations & Troubleshooting

### Current Limitations

Agent teams are experimental. Be aware of:

| Limitation | Impact | Workaround |
|-----------|--------|-----------|
| No session resumption for in-process teammates | After resuming, lead may message dead teammates | Tell lead to spawn new teammates |
| Task status can lag | Teammates forget to mark tasks complete | Manually update or tell lead to nudge |
| Shutdown can be slow | Teammates finish current operation first | Be patient, or message them to wrap up |
| One team per session | Can't run multiple teams simultaneously | Clean up before starting a new team |
| No nested teams | Teammates can't spawn their own teams | Keep orchestration at the lead level |
| Lead is fixed | Can't promote a teammate to lead | Plan your lead role before starting |
| Permissions set at spawn | All teammates share lead's permission mode | Change individual modes after spawning |
| Split panes not on Windows | Can't use tmux display mode | Use in-process mode (Shift+Up/Down) |

### Troubleshooting

**Teammates not appearing:**
- Press Shift+Down to cycle through active teammates
- Verify the feature is enabled: check `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings
- Check if the task was complex enough — Claude may decide a team isn't needed

**Too many permission prompts:**
- Pre-approve common operations in your permission settings before spawning
- Or use `--dangerously-skip-permissions` if you trust the workflow (use with caution)

**Teammates stopping on errors:**
- Select the stopped teammate with Shift+Up/Down
- Give them additional instructions
- Or spawn a replacement: `Spawn a new frontend teammate to continue where the previous one left off.`

**Lead implementing instead of delegating:**
- Enter delegate mode: Shift+Tab
- Or message: `Do not implement anything yourself. Wait for teammates.`

**File conflicts between teammates:**
- Always specify file ownership in spawn prompts
- If it happens: one teammate should own the fix, the other should stop editing that file

**Orphaned tmux sessions (macOS/Linux):**
```bash
tmux ls
tmux kill-session -t <session-name>
```

---

## 13. Quick Reference

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
               TEAM MODE ESSENTIALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ENABLE:
  settings.json → "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"

START A TEAM:
  claude → paste a team config from advanced/guides/TEAM_MODE.md

NAVIGATE:
  Shift+Up/Down  → select teammate
  Enter          → view teammate session
  Escape         → exit teammate view
  Ctrl+T         → toggle task list
  Shift+Tab      → toggle delegate mode

CONFIGS (copy from Section 6):
  Full Build       → 6-8 teammates, all tiers
  Feature Sprint   → 3 teammates, tiers 2-4
  Code Review      → 3 reviewers, parallel
  Debug            → 3 investigators, parallel

COST:
  Full Build: 5-10x solo cost
  Feature Sprint: 3-5x solo cost
  Review/Debug: 3-4x solo cost

FILE OWNERSHIP:
  Frontend → /app, /components, /lib, /types
  Backend  → /src/routes, /services, /models
  Tester   → /tests
  DevOps   → Dockerfile, docker-compose, CI/CD
  Writer   → README.md, docs/

SHUT DOWN:
  "Ask [teammate] to shut down"
  "Clean up the team" (after all teammates stopped)

GOLDEN RULES:
  1. Always specify file ownership in spawn prompts
  2. Use delegate mode for pure orchestration
  3. Monitor every 10-15 minutes
  4. Start with review tasks before full builds
  5. Clean up through the lead, never teammates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Related Resources

- **Solo Mode:** `essential/toolkit/templates/CLAUDE-SOLO.md`
- **Agent Prompts (manual pipeline):** `essential/agents/` directory
- **Architecture Blueprint:** `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — Section 10
- **Cost Management:** `essential/guides/COSTS.md`, `advanced/guides/PROMPT_CACHING.md`
- **Emergency Recovery:** `essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md`
- **Official Docs:** Claude Code agent teams documentation
