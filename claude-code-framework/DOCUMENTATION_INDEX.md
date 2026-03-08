# Documentation Index — Find What You Need

> **Quick navigation for all guides, references, and documentation in this framework.**
>
> **Last Updated:** February 12, 2026

---

## Start Here — Choose Your Path

**Never coded before?** → Start with **`essential/guides/DAY_ZERO.md`** (1 hour)
**Want to build something today?** → Jump to **`QUICK_START.md`** (30 min)
**Want to understand the system?** → Read **`README.md`** (5 min)

| Document | When to Read | Time Required |
|----------|-------------|---------------|
| **`README.md`** | Overview of framework and features | 5 min |
| **`QUICK_START.md`** | Ready to build, need minimal setup | 30 min |
| **`essential/guides/DAY_ZERO.md`** | New to terminals, SSH, Docker, git | 1 hour |

---

## Core Guides (Read in Order)

### Getting Started

1. **`QUICK_START.md`** — 30-minute setup to your first working agent
2. **`V4.4_CHEAT_SHEET.md`** — ⭐ NEW v4.4: 10-minute memory system setup
3. **`essential/guides/DAY_ZERO.md`** — Plain-English intro to terminals, SSH, Docker, git (for beginners)
4. **`essential/guides/FIRST_PROJECT.md`** — 2-hour guided tutorial building a real app

### v4.4 New Features (Start Here!)

4. **`essential/guides/MEMORY_SYSTEM.md`** — ⭐ NEW: Persistent context across sessions (90% faster starts)
5. **`essential/guides/SPRINT_MANAGEMENT.md`** — ⭐ NEW: 2-week sprint cycles with velocity tracking
6. **`essential/guides/TASK_INTEGRATION.md`** — ⭐ NEW: Use Claude Code's native task tools
7. **`essential/guides/BEAD_METHOD.md`** — ⭐ NEW: Micro-task decomposition (15-45 min beads)

### Cost Optimization

8. **`essential/guides/COSTS.md`** — Complete cost breakdown (hardware, API, monthly expenses)
9. **`advanced/guides/PROMPT_CACHING.md`** — Save 90% on API costs with caching
10. **`advanced/guides/BATCH_PROCESSING.md`** — Process thousands of requests at 50% cost

### Core Workflow

11. **`advanced/guides/ARCHITECTURE_BLUEPRINT.md`** — Standard project structure and workflows (1 hour)
12. **`essential/guides/PROJECT_INIT_WORKFLOW.md`** — Step-by-step new project initialization (30 min)
13. **`advanced/guides/RAG_PROJECT_KNOWLEDGE.md`** — Upload docs for automatic agent context (30 min)

### Troubleshooting

10. **`essential/guides/TROUBLESHOOTING.md`** — Common errors and quick fixes (15 min)
11. **`essential/guides/PITFALLS.md`** — Known Claude Code failure modes and workarounds (15 min)

### Advanced Features

12. **`advanced/guides/TEAM_MODE.md`** — Automated multi-agent orchestration (45 min)
13. **`advanced/guides/MCP_SETUP.md`** — MCP server configuration (30 min)
14. **`advanced/guides/INTEGRATIONS.md`** — Supabase, Vercel, Railway setup guides (45 min)
15. **`essential/guides/DAILY_WORKFLOW.md`** — Day-to-day development workflow (30 min)
16. **`essential/guides/GIT_FOR_VIBE_CODERS.md`** — Git basics for non-developers (45 min)
17. **`advanced/guides/EMERGENCY_RECOVERY.md`** — Technical emergency recovery (20 min)
18. **`essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md`** — Disaster recovery for non-devs (30 min)
19. **`advanced/guides/AUTOMATION_QUICK_WINS.md`** — 10 automation improvements (1 hour)

---

## Agent System (10 Agents + 2 Context Files)

| Document | Purpose |
|----------|---------|
| **`essential/agents/README.md`** | Setup instructions for the 10-agent tier-based system |
| **`essential/agents/01-shared-context.md`** | Core rules used by ALL agents (not an agent itself) |
| **`essential/agents/02-project-brief-template.md`** | Template to fill out per project (not an agent itself) |
| **`essential/agents/03-system-architect.md`** | Tier 1 Agent: Design technical blueprints |
| **`essential/agents/04-product-manager.md`** | Tier 1 Agent: Translate architecture into tasks |
| **`essential/agents/05-designer.md`** | Tier 2 Agent: Create design systems and component specs |
| **`essential/agents/06-api-architect.md`** | Tier 2 Agent: API contracts and data schemas |
| **`essential/agents/07-frontend-developer.md`** | Tier 3 Agent: Build UI and client-side logic |
| **`essential/agents/08-backend-developer.md`** | Tier 3 Agent: Build APIs and server-side logic |
| **`essential/agents/09-security-auditor.md`** | Tier 4 Agent: Security review and vulnerability scanning |
| **`essential/agents/10-system-tester.md`** | Tier 4 Agent: Integration tests and bug reports |
| **`essential/agents/11-devops-engineer.md`** | Tier 5 Agent: Docker, CI/CD, deployment |
| **`essential/agents/12-technical-writer.md`** | Tier 6 Agent: API docs and user guides (async) |

---

## Toolkit & Scripts

| Document | Purpose |
|----------|---------|
| **`essential/toolkit/README.md`** | Overview of all scripts and tools |
| **`essential/toolkit/create-project.sh`** | Scaffold new projects from scratch |
| **`essential/toolkit/adopt-project.sh`** | Add framework to existing projects |
| **`essential/toolkit/test-scaffold.sh`** | Test suite for scaffolding scripts |
| **`essential/toolkit/claude-cached-api.js`** | Node.js wrapper with prompt caching |
| **`essential/toolkit/claude_cached_api.py`** | Python wrapper with prompt caching |
| **`essential/toolkit/claude-cached.sh`** | Bash wrapper for quick cached API calls |

### Templates

| Template | Used By | Purpose |
|----------|---------|---------|
| **`essential/toolkit/templates/CLAUDE.md`** | create-project.sh | Rules for Claude Code |
| **`essential/toolkit/templates/STATUS.md`** | create-project.sh | Project state tracker |
| **`essential/toolkit/templates/PRD.md`** | create-project.sh | Product Requirements |
| **`essential/toolkit/templates/TECH_SPEC.md`** | create-project.sh | Technical Specification |
| **`essential/toolkit/templates/HOOKS_SETUP.md`** | adopt-project.sh | Hook configuration reference |

---

## Infrastructure Setup

| Document | When to Use |
|----------|------------|
| **`infrastructure/README.md`** | Overview of mini PC setup |
| **`infrastructure/SETUP_START.md`** | **START HERE** — Master prompt for automated setup |
| **`infrastructure/MINI_PC_SETUP_PROMPT.md`** | Full reference (read-only, not for pasting) |
| **`infrastructure/phases/phase-0-preflight.md`** | Pre-flight system assessment |
| **`infrastructure/phases/phase-1-foundation.md`** | Core system hardening + SSH |
| **`infrastructure/phases/phase-2-devenv.md`** | Docker, databases, git server |
| **`infrastructure/phases/phase-3-monitoring.md`** | Observability and metrics |
| **`infrastructure/phases/phase-4-automation.md`** | Backup, update scripts |
| **`infrastructure/phases/phase-5-recovery.md`** | Disaster recovery procedures |

---

## Reference Documentation

| Document | What It Contains | Time |
|----------|-----------------|------|
| **`QUICK_REFERENCE.md`** | ⭐ One-page cheat sheet — Print and use daily | 5 min |
| **`CHANGELOG.md`** | Version history and what changed | 10 min |
| **`COMPATIBILITY.md`** | Version requirements and known issues | 5 min |
| **`UPGRADING_V4.2_TO_V4.3.md`** | Migration guide from v4.2 to v4.3 | 15 min |
| **`FIXES_APPLIED.md`** | Record of documentation fixes (v4.3) | 10 min |
| **`DEEP_VERIFICATION_REPORT.md`** | Comprehensive accuracy verification | 5 min |
| **`LICENSE`** | MIT License terms | 2 min |

---

---

## Quick Access (New in v4.3)

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **`QUICK_REFERENCE.md`** | ⭐ One-page cheat sheet | Keep open while coding |
| **`UPGRADING_V4.2_TO_V4.3.md`** | Migration guide | Upgrading from v4.2 |
| **`FIXES_APPLIED.md`** | Documentation fixes log | Understanding what changed |
| **`DEEP_VERIFICATION_REPORT.md`** | Quality verification | Checking documentation accuracy |

---

## By Use Case

### "I'm brand new to coding"
1. Start: `essential/guides/DAY_ZERO.md` (1 hour)
2. Then: `QUICK_START.md` (30 min)
3. Print: `QUICK_REFERENCE.md` (keep visible)
4. Then: `essential/guides/FIRST_PROJECT.md` (2 hours)
5. Reference: `essential/guides/TROUBLESHOOTING.md` when stuck

### "I want to build a project today"
1. Read: `QUICK_START.md` (30 min)
2. Print: `QUICK_REFERENCE.md` (keep visible)
3. Run: `essential/toolkit/create-project.sh`
4. Reference: `advanced/guides/ARCHITECTURE_BLUEPRINT.md` (as needed)
5. Setup: 1-2 agents from `essential/agents/README.md`

### "I'm worried about costs"
1. Read: `essential/guides/COSTS.md`
2. Implement: `advanced/guides/PROMPT_CACHING.md`
3. Consider: `advanced/guides/BATCH_PROCESSING.md` for bulk tasks
4. Monitor: console.anthropic.com/usage

### "I have an existing project"
1. Use: `essential/toolkit/adopt-project.sh`
2. Read: `advanced/guides/RAG_PROJECT_KNOWLEDGE.md`
3. Reference: `essential/agents/02-project-brief-template.md`
4. Follow: `essential/guides/PROJECT_INIT_WORKFLOW.md`

### "I want the full multi-agent system"
1. Read: `essential/agents/README.md`
2. Follow: `advanced/guides/ARCHITECTURE_BLUEPRINT.md` Section 2
3. Create: 10 Claude Projects (one per agent) with agent prompts
4. Customize: `essential/agents/02-project-brief-template.md` per project
5. Note: For daily work, most users only need 4-5 core agents

### "I want a dedicated dev server"
1. Read: `infrastructure/README.md`
2. Get hardware (see `essential/guides/COSTS.md`)
3. Follow: `infrastructure/SETUP_START.md` (paste ONE prompt)
4. Reference: `infrastructure/MINI_PC_SETUP_PROMPT.md` if stuck

### "I'm upgrading from v4.2"
1. Read: `UPGRADING_V4.2_TO_V4.3.md` (15 min)
2. Follow: Migration checklist in that guide
3. Verify: Test hooks, MCP, permissions
4. Reference: `QUICK_REFERENCE.md` for new workflows

### "I'm debugging an issue"
1. Check: `QUICK_REFERENCE.md` (emergency recovery section)
2. Check: `essential/guides/TROUBLESHOOTING.md`
3. Review: `essential/guides/PITFALLS.md`
4. Search: This index for relevant docs
5. Still stuck? Re-read `advanced/guides/ARCHITECTURE_BLUEPRINT.md`

---

## By Topic

### Project Structure
- `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — Standard folder layout
- `essential/guides/PROJECT_INIT_WORKFLOW.md` — Setup process
- `essential/toolkit/templates/` — File templates

### Cost Management
- `essential/guides/COSTS.md` — Complete breakdown
- `advanced/guides/PROMPT_CACHING.md` — 90% savings
- `advanced/guides/BATCH_PROCESSING.md` — 50% savings on bulk

### Agent Workflows
- `essential/agents/README.md` — Setup and usage
- `essential/agents/01-shared-context.md` — Core rules
- `advanced/guides/ARCHITECTURE_BLUEPRINT.md` Section 2 — Agent system

### API Features
- `advanced/guides/PROMPT_CACHING.md` — Reduce token costs
- `advanced/guides/BATCH_PROCESSING.md` — Async bulk processing
- `advanced/guides/RAG_PROJECT_KNOWLEDGE.md` — Auto-context retrieval

### Infrastructure
- `infrastructure/SETUP_START.md` — Automated mini PC setup
- `essential/guides/DAY_ZERO.md` — Basics (SSH, Docker, git)
- `essential/guides/TROUBLESHOOTING.md` — Common issues

### Development Workflow
- `essential/guides/FIRST_PROJECT.md` — Learn by building
- `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — Best practices
- `essential/guides/PITFALLS.md` — Avoid common mistakes

---

## Quick Command Reference

```bash
# Setup
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/*.sh

# New project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Existing project
cd /project && $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh

# Test scaffolding
$CLAUDE_HOME/claude-code-framework/essential/toolkit/test-scaffold.sh

# Claude Code CLI
claude                          # Interactive
claude "one-shot command"       # Single task

# Cached API (cost savings)
node essential/toolkit/claude-cached-api.js "prompt" --agent frontend
python essential/toolkit/claude_cached_api.py "prompt" --agent backend
./essential/toolkit/claude-cached.sh "prompt" backend
```

---

## Reading Order Recommendations

### Beginner Path (6-8 hours)
1. `essential/guides/DAY_ZERO.md` (1 hour)
2. `QUICK_START.md` (30 min)
3. `essential/guides/FIRST_PROJECT.md` (2 hours)
4. `advanced/guides/ARCHITECTURE_BLUEPRINT.md` (1 hour)
5. `essential/guides/COSTS.md` (30 min)
6. `advanced/guides/PROMPT_CACHING.md` (1 hour)
7. Build your own project (ongoing)

### Experienced Dev Path (3-4 hours)
1. `README.md` (5 min)
2. `QUICK_START.md` (15 min to skim)
3. `advanced/guides/ARCHITECTURE_BLUEPRINT.md` (45 min)
4. `essential/agents/README.md` (30 min)
5. `advanced/guides/PROMPT_CACHING.md` (30 min)
6. `advanced/guides/BATCH_PROCESSING.md` (30 min)
7. Build your own project (ongoing)

### Cost-Conscious Path (2-3 hours)
1. `essential/guides/COSTS.md` (30 min)
2. `advanced/guides/PROMPT_CACHING.md` (1 hour)
3. `advanced/guides/BATCH_PROCESSING.md` (1 hour)
4. `QUICK_START.md` (30 min)
5. Implement optimizations in your projects

---

## Document Status

| Status | Meaning |
|--------|---------|
| ⭐ | Start here (beginner-friendly) |
| 📊 | Contains cost/pricing info |
| 🔧 | Hands-on tutorial or script |
| 📖 | Reference documentation |
| ⚠️ | Troubleshooting/error handling |

### Tagged Documents

- ⭐ `QUICK_REFERENCE.md` **NEW** — Print this!
- ⭐ `QUICK_START.md`
- ⭐ `essential/guides/DAY_ZERO.md`
- 🔧 `essential/guides/FIRST_PROJECT.md`
- 📊 `essential/guides/COSTS.md`
- 📊 `advanced/guides/PROMPT_CACHING.md`
- 📊 `advanced/guides/BATCH_PROCESSING.md`
- 📖 `advanced/guides/ARCHITECTURE_BLUEPRINT.md`
- 📖 `advanced/guides/RAG_PROJECT_KNOWLEDGE.md`
- 📖 `UPGRADING_V4.2_TO_V4.3.md` **NEW**
- ⚠️ `essential/guides/TROUBLESHOOTING.md`
- ⚠️ `essential/guides/PITFALLS.md`
- ⚠️ `essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md`
- 🔧 `essential/toolkit/create-project.sh`
- 🔧 `essential/toolkit/adopt-project.sh`
- 🔧 `advanced/guides/AUTOMATION_QUICK_WINS.md`
- 📖 `essential/agents/README.md`
- 🔧 `infrastructure/SETUP_START.md`

---

**Can't find what you need?**

1. Use your editor's search (Cmd+F / Ctrl+F) to search within files
2. Check `essential/guides/TROUBLESHOOTING.md` for common issues
3. Review `advanced/guides/ARCHITECTURE_BLUEPRINT.md` Section 9 for quick reference
4. Look at `CHANGELOG.md` to see recent additions

**Still stuck?** You might be the first person to encounter this. Document it and contribute back!
