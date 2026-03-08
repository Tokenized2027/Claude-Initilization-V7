# Claude Code Framework

Complete framework for AI-powered "vibe coding" — project scaffolding, agent team prompts, workflow guides, automation skills, and templates. Built from months of production experience.

**Version:** 4.4 (Reorganized February 2026)
**Status:** Production Ready
**Your Setup:** Optimized for non-developer vibe coders

---

## 🎯 What This Framework Does

Transforms Claude Code from a coding assistant into a **complete development team**:

- ✅ **10 specialized AI agents** - PM, Architect, Designer, Frontend, Backend, Security, Tester, DevOps, API Architect, Tech Writer
- ✅ **15 automation skills** - Emergency fixes, scaffolding, deployment, quality checks
- ✅ **Project scaffolding** - Create production-ready projects in minutes
- ✅ **Workflow guides** - Daily development, git, troubleshooting, costs
- ✅ **Memory system** - Persistent context across sessions (90% faster starts)
- ✅ **Sprint management** - 2-week cycles with velocity tracking

---

## 🚀 Quick Start (30 Minutes)

### 1. Read the Quick Start Guide
```bash
cat $CLAUDE_HOME/claude-code-framework/QUICK_START.md
```

This covers:
- Setting up your first agent (5 min)
- Creating a project brief (10 min)
- Scaffolding a project (10 min)
- Your first conversation (5 min)

### 2. Create Your First Project
```bash
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh
```

### 3. Start Building
```bash
cd your-new-project
claude
```

**That's it.** You're now vibe coding with AI.

---

## 📁 Framework Structure

This framework is organized by frequency of use:

### Essential (Daily Use)
**Location:** `essential/`

**agents/** - AI agent templates
- 10 specialized agents (PM, Architect, Designer, etc.)
- Shared context file
- Project brief template

**guides/** - How-to documentation
- `FIRST_PROJECT.md` - Guided 2-hour tutorial
- `DAILY_WORKFLOW.md` - Day-to-day development
- `PITFALLS.md` - Common mistakes to avoid
- `GIT_FOR_VIBE_CODERS.md` - Git basics in plain English
- `DAY_ZERO.md` - Complete beginner's guide
- `TROUBLESHOOTING.md` - When things break
- `EMERGENCY_RECOVERY_VIBE_CODER.md` - Disaster recovery
- `PROJECT_INIT_WORKFLOW.md` - Initialize new projects
- `COSTS.md` - What this costs monthly
- `SKILLS.md` - Automation skills guide

**skills/** - Task automation
- `emergency/` - Docker errors, git recovery, build fixes, env validation, dependencies
- `scaffolding/` - API routes, components, auth, migrations, tests
- `deployment/` - Vercel, Docker Compose, GitHub Actions
- `quality/` - Security scanning, accessibility checks

**toolkit/** - Setup scripts
- `create-project.sh` - Scaffold new projects
- `adopt-project.sh` - Add framework to existing projects
- `memory-manager.sh` - Memory system automation
- `sprint-planner.sh` - Sprint management
- `templates/` - Source templates

### Advanced (Occasional Use)
**Location:** `advanced/`

**guides/** - Advanced topics
- `ARCHITECTURE_BLUEPRINT.md` - System architecture patterns
- `BATCH_PROCESSING.md` - Batch API operations
- `MCP_SETUP.md` - MCP server configuration
- `PROMPT_CACHING.md` - Save 90% on API costs
- `RAG_PROJECT_KNOWLEDGE.md` - Project knowledge management
- `AUTOMATION_QUICK_WINS.md` - 10 automation improvements
- `TEAM_MODE.md` - Multi-agent automation
- `INTEGRATIONS.md` - Supabase, Vercel, Railway
- `EMERGENCY_RECOVERY.md` - Full disaster recovery

**infrastructure/** - Dedicated dev server setup
- Mini PC setup and configuration
- Phased deployment guides

**examples/** - Reference implementations
- link-vault - Example project
- memory - Memory system examples
- sprints - Sprint planning examples

### Archive (Reference)
**Location:** `archive/`

**release-notes/** - Version history
- V3.0, V3.1, V4.0, V4.1 release notes

**migration-guides/** - Upgrade guides
- V4.1 → V4.2 → V4.3 → V4.4 migration
- Delivery summaries

**dev-artifacts/** - Development docs
- Completion summaries
- Verification reports
- Compatibility notes
- Fix logs

**docs/** - Research and analysis
**skills-cli/** - CLI skill versions

---

## 🎓 Learning Path

### Complete Beginner
**You're new to coding, terminal, git, etc.**

1. Start: `essential/guides/DAY_ZERO.md` (1 hour)
2. Then: `QUICK_START.md` (30 min)
3. Follow: `essential/guides/FIRST_PROJECT.md` (2 hours)
4. Reference: `essential/guides/GIT_FOR_VIBE_CODERS.md` (as needed)

**Total time:** 4-5 hours to working project

### Experienced Vibe Coder
**You know the basics, want to optimize**

1. Start: `QUICK_START.md` (30 min)
2. Scan: `DAILY_REFERENCE.md` (10 min)
3. Review: `essential/guides/PITFALLS.md` (20 min)
4. Optimize: `advanced/guides/PROMPT_CACHING.md` (30 min)

**Total time:** 90 minutes to optimized workflow

### Advanced Developer
**You want the full system**

1. Architecture: `advanced/guides/ARCHITECTURE_BLUEPRINT.md` (1 hour)
2. Team Mode: `advanced/guides/TEAM_MODE.md` (45 min)
3. Memory System: `essential/guides/MEMORY_SYSTEM.md` (30 min)
4. Sprints: `essential/guides/SPRINT_MANAGEMENT.md` (45 min)
5. Infrastructure: `advanced/infrastructure/README.md` (2 hours)

**Total time:** 5 hours to master the system

---

## 🤖 Agent Architecture

### Tier-Based Parallel System (33% Faster)

```
claude-code-framework/
├── essential/                 # Daily-use files
│   ├── agents/                # AI Development Team — 10 agent prompts + 2 context files + README
│   ├── guides/                # Reference docs: beginner guide, pitfalls, architecture, workflows
│   │   ├── DAY_ZERO.md            # Start here if new — plain-English setup guide
│   │   ├── FIRST_PROJECT.md       # Guided tutorial: build your first app with the framework
│   │   ├── MEMORY_SYSTEM.md       # [v4.4] Persistent memory across sessions
│   │   ├── SPRINT_MANAGEMENT.md   # [v4.4] 2-week sprint cycles with velocity tracking
│   │   ├── TASK_INTEGRATION.md    # [v4.4] Use Claude Code's native task tools
│   │   ├── BEAD_METHOD.md         # [v4.4] Micro-task decomposition (15-45 min beads)
│   │   ├── SKILLS.md              # Complete skills integration guide
│   │   ├── DAILY_WORKFLOW.md      # Day-to-day development workflow
│   │   ├── GIT_FOR_VIBE_CODERS.md    # Git basics for non-developers
│   │   ├── TROUBLESHOOTING.md     # Common errors and quick fixes
│   │   ├── COSTS.md               # What this setup actually costs
│   │   ├── PITFALLS.md            # Known Claude Code failure modes
│   │   ├── EMERGENCY_RECOVERY_VIBE_CODER.md  # Disaster recovery scenarios
│   │   └── PROJECT_INIT_WORKFLOW.md   # Step-by-step project initialization
│   ├── skills/                # 28 task-specific automation skills (V2.5)
│   │   ├── emergency/         # 5 skills: Docker errors, git recovery, build fixes, env validation, dependencies
│   │   ├── scaffolding/       # 5 skills: API routes, components, auth, migrations, tests
│   │   ├── deployment/        # 3 skills: Vercel, Docker Compose, GitHub Actions
│   │   └── quality/           # 2 skills: Security scanning, accessibility checks
│   └── toolkit/               # Project scaffolding scripts
│       ├── create-project.sh      # Scaffold a new project from scratch
│       ├── adopt-project.sh       # Retrofit the framework into an existing project
│       ├── memory-manager.sh      # Memory system automation (v4.4)
│       ├── sprint-planner.sh      # Sprint management automation (v4.4)
│       ├── test-scaffold.sh       # Test suite for the scaffolding scripts
│       └── templates/             # Source templates (used by the scripts)
├── advanced/                  # Occasional-use files
│   ├── guides/                # Advanced topics
│   │   ├── ARCHITECTURE_BLUEPRINT.md  # Standard project structure and workflows
│   │   ├── TEAM_MODE.md           # Team Mode guide (automated multi-agent)
│   │   ├── MCP_SETUP.md           # MCP server configuration guide
│   │   ├── INTEGRATIONS.md        # Supabase, Vercel, Railway integration guides
│   │   ├── PROMPT_CACHING.md      # Save 90% on API costs
│   │   ├── BATCH_PROCESSING.md    # Batch API operations
│   │   ├── RAG_PROJECT_KNOWLEDGE.md   # Project knowledge management
│   │   ├── AUTOMATION_QUICK_WINS.md   # 10 automation improvements
│   │   └── EMERGENCY_RECOVERY.md      # Full disaster recovery
│   ├── infrastructure/        # Mini PC setup prompt for a dedicated dev server
│   │   ├── SETUP_START.md     # Paste this ONE prompt — auto-continues through all phases
│   │   └── phases/            # 6 phase files read from disk by Claude Code
│   └── examples/              # Reference implementations
├── archive/                   # Historical reference (release notes, migration guides)
└── README.md                  # You're reading it
```

---

## Quick Start

### New to Coding / Vibe Coding?

**Start with `essential/guides/DAY_ZERO.md`** — it explains SSH, Docker, git, terminal commands, and how all the pieces fit together in plain English. Read it before anything else.

### 1. Set Up the AI Agent Team (One-Time)

Your AI development team is **10 specialized agents** organized in a **tier-based parallel architecture** (33% faster than sequential).

```
TIER 1: Architect + PM                          (2 agents)
TIER 2: Designer + API Architect (Parallel)     (2 agents)
TIER 3: Frontend + Backend (Parallel)           (2 agents)
TIER 4: Security → Tester (Security First)      (2 agents)
TIER 5: DevOps                                  (1 agent)
TIER 6: Technical Writer (Async)                (1 agent)
                                        TOTAL: 10 agents
```

1. Read `essential/agents/README.md` for complete tier-based workflow
2. Create 10 Claude Projects (one per agent) — but you don't need all 10 immediately
3. For each project's system prompt, paste the shared context (`01-shared-context.md`) followed by that agent's prompt file
4. Fill out `02-project-brief-template.md` for your current project

**For daily coding:** Use 1-2 developer agents (Frontend and/or Backend). **For new system builds:** Use full 10-agent pipeline.

**Most daily work** (bug fixes, features, refactoring) goes directly to 1-2 developer agents. The full 10-agent pipeline is for building complete new systems from scratch.

### 2. Scaffold a New Project

```bash
# One-time setup
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Create a project (interactive)
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Or non-interactive
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh --name my-app --type nextjs --path ~/projects
```

This creates a fully configured project with: CLAUDE.md, STATUS.md, PRD/Tech Spec templates, Claude Code hooks, .gitignore, framework-specific boilerplate, and git initialized with main + develop branches.

**Project types:** `nextjs` | `python` | `docker` | `minimal`

### 3. Adopt an Existing Project

Already have a project? Retrofit the framework without overwriting anything:

```bash
cd /path/to/your/existing/project
bash $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh
```

This scans your project, detects the framework, and adds only what's missing (CLAUDE.md, STATUS.md, hooks, templates, etc.).

### 4. Enable Skills (v4.0+)

**Two formats available:**

**Web Skills (claude.ai):** Upload to Skills feature
- docker-debugger (fix port conflicts, container errors)
- git-recovery (undo commits, recover files)
- vercel-deployer (deploy to Vercel)

**To install web skills:**
1. Zip each skill folder: `cd skills/emergency/docker-debugger && zip -r docker-debugger.zip .`
2. Upload to Claude.ai: Settings → Capabilities → Skills → Upload Skill
3. Toggle skill ON

**CLI Skills (Claude Code) — New in v4.1:**
- All skills available as standalone markdown files
- Copy to your project: `cp -r skills-cli ~/my-project/docs/skills/`
- Reference in CLAUDE.md or read directly in terminal

**See `essential/guides/SKILLS.md` for complete guide and `essential/skills/README.md` for CLI usage.**

### 5. Build Your First Project

Follow the guided tutorial in `essential/guides/FIRST_PROJECT.md` — it walks you through building a link bookmarker app using every piece of the framework. Takes about 2 hours and teaches the full workflow by doing, not reading.

### 6. Start Building

Open Claude Code in your project and say:

```
Read STATUS.md and CLAUDE.md. Let's create the PRD —
ask me at least 10 questions before writing anything.
```

Then follow the workflow: PRD → Tech Spec → Phase 1 development.

---

## The Framework at a Glance

### Mandatory Project Files

Every project gets these files, no exceptions:

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Rules for Claude Code — code quality, git discipline, logging, self-correction |
| `STATUS.md` | Single source of truth for project state — updated after every change |
| `docs/PRD.md` | Product Requirements Document — what you're building and why |
| `docs/TECH_SPEC.md` | Technical Specification — how you're building it |
| `.env.example` | All environment variables documented (no real values) |
| `.claude/hooks/` | Automated safeguards: branch protection, dangerous command blocking, code review |

### Key Principles

1. **STATUS.md is the most important file.** Without it, session continuity breaks down. Update it after every change.
2. **Iterate on PRD and Tech Spec.** Have Claude ask you questions before writing. Review drafts. Don't single-pass these.
3. **Commit frequently.** After every completed unit of work. Don't let Claude Code drift without checkpoints.
4. **Never trust Claude Code with numbers.** Always verify data analysis, comparisons, and metrics yourself.
5. **Claude Code ignores its own CLAUDE.md sometimes.** Periodically audit whether it's following the rules.
6. **Detailed logs on every run.** Without structured logging, debugging is nearly impossible.

See `essential/guides/PITFALLS.md` for the complete list of known issues and workarounds.

---

## Folder Details

### `essential/toolkit/` — Project Scaffolding

Two scripts that create or retrofit projects with the standard framework.

| Script | When to Use |
|--------|------------|
| `create-project.sh` | Starting a brand new project |
| `adopt-project.sh` | Adding the framework to an existing project (never overwrites) |

Both scripts look for templates in `essential/toolkit/templates/`. If templates aren't found, they fall back to built-in defaults.

### `essential/agents/` — AI Development Team

10 specialized agents organized in a **tier-based parallel architecture**. 33% faster than sequential workflows:

| Tier | Agent | Role | When to Use |
|------|-------|------|------------|
| **1** | System Architect | Technical blueprint, architecture decisions | New systems from scratch, major architectural changes |
| **1** | Product Manager | Requirements breakdown, task planning | After architect defines structure, before implementation |
| **2** | Designer | Design systems, component specs, UI/UX | User-facing apps where visual consistency matters |
| **2** | API Architect | API contracts, data schemas, endpoint design | All projects with APIs or backend services |
| **3** | Frontend Developer | UI implementation, components, client logic | **Daily use** — Frontend work, React/Vue/Next.js |
| **3** | Backend Developer | API routes, business logic, data handling | **Daily use** — Server work, APIs, databases |
| **4** | Security Auditor | Security review, vulnerability scanning | DeFi apps, auth systems, production deployments |
| **4** | System Tester | Integration tests, test suites, bug reports | After features complete, before deployment |
| **5** | DevOps Engineer | Docker, CI/CD, deployment automation | Setting up infra, production deployment |
| **6** | Technical Writer | API docs, user guides, README files | Documentation-heavy projects (async, low priority) |

**Key Insight:** Tier 2 and Tier 3 agents work in **parallel** (Designer + API Architect, then Frontend + Backend), reducing total time by 33%.

**Daily workflow:** Most developers only use Frontend and/or Backend agents (Tier 3). Use full pipeline when building new systems.

See `essential/agents/README.md` for complete tier-based workflow.

### `essential/guides/` and `advanced/guides/` — Reference Documentation

| Guide | What It Covers |
|-------|---------------|
| `DAY_ZERO.md` | **Start here if you're new.** Plain-English setup guide, terminal basics, how the pieces fit together |
| `FIRST_PROJECT.md` | **Do this second.** Guided 2-hour tutorial — build a real app using the full workflow |
| `PROMPT_CACHING.md` | **Save 90% on API costs.** How to implement prompt caching for agent prompts and large files |
| `BATCH_PROCESSING.md` | **Process thousands of requests at 50% cost.** Asynchronous batch API for large-scale tasks |
| `RAG_PROJECT_KNOWLEDGE.md` | **Give agents persistent context.** Upload docs once, auto-retrieved in every conversation |
| `PITFALLS.md` | Known Claude Code failure modes and how to prevent them |
| `ARCHITECTURE_BLUEPRINT.md` | Standard project structure, agent setup, mandatory files, workflows |
| `PROJECT_INIT_WORKFLOW.md` | Step-by-step process for starting a new project with Claude Code |
| `TROUBLESHOOTING.md` | Common errors and quick fixes — check here before debugging |
| `COSTS.md` | Realistic cost breakdown for hardware, API credits, and monthly expenses |
| `TEAM_MODE.md` | **v4.2** Team Mode — automated multi-agent orchestration |
| `SKILLS.md` | Complete skills integration guide — when to use skills vs agents |
| `MCP_SETUP.md` | **v4.3** MCP server configuration (Playwright, Postgres, GitHub) |
| `INTEGRATIONS.md` | **v4.3** Quick-start guides for Supabase, Vercel, Railway |
| `DAILY_WORKFLOW.md` | Day-to-day development workflow with Claude Code |
| `GIT_FOR_VIBE_CODERS.md` | Git basics in plain English |
| `EMERGENCY_RECOVERY.md` | Technical emergency recovery reference |
| `EMERGENCY_RECOVERY_VIBE_CODER.md` | Disaster recovery for non-developers |
| `AUTOMATION_QUICK_WINS.md` | 10 automation improvements, ~60 min/day saved |

Also at the repo root: `COMPATIBILITY.md` — version requirements, known issues, and update instructions.

### `infrastructure/` — Mini PC Dev Server

A complete setup prompt for bootstrapping a dedicated Linux mini PC as an always-on dev server. Covers: system hardening, Tailscale remote access, Docker, PostgreSQL, Redis, Gitea, monitoring, and automation.

**How it works:** You paste ONE master prompt from `infrastructure/SETUP_START.md` into Claude Code. It reads Phase 0 from disk, executes it, then asks "say 'go' to continue." You say go, it reads the next phase file automatically. No more copy-pasting 700 lines — Claude Code self-orchestrates through all 6 phases.

The phases are split into separate files in `infrastructure/phases/` so Claude Code's context window stays focused on one phase at a time.

The full combined reference is still available in `MINI_PC_SETUP_PROMPT.md` for reading ahead or troubleshooting.

---

## What's New in v4.1

### Solo Coder Mode

New consolidated template for solo developers: `essential/toolkit/templates/CLAUDE-SOLO.md`

**What it replaces:** The 10-agent pipeline (which was designed for teams)

**What it includes:**
- Complete code quality standards (frontend + backend)
- Git workflow and commit discipline
- Self-correction protocol
- Emergency recovery reference
- Stack-specific rules (Next.js, TypeScript, Tailwind)

**When to use:** You're building alone with Claude Code CLI.

**Migration:** `cp essential/toolkit/templates/CLAUDE-SOLO.md ~/my-project/CLAUDE.md`

### Enhanced Emergency Recovery

New guide: `essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md`

**New sections:**
- The Nuclear Option (immediate "go back to working state" commands)
- Disaster Recovery Scenarios (Claude broke everything, production is broken, database corrupted, etc.)
- Prevention guide (never get here again)
- Last Resort procedures (complete project reset)
- Emergency reference card (printable)

**Target user:** Non-technical builders who need hand-holding through recovery.

### CLI-Compatible Skills (Archived)

The original 15 skills are also available in CLI-friendly format: `archive/skills-cli/`
> **Note:** The current skill system uses `essential/skills/` (28 skills, V2.5). The CLI format below is archived for reference.

**Usage options:**
- Copy to project: `cp -r skills-cli ~/my-project/docs/skills/`
- Reference in CLAUDE.md
- Single emergency playbook: `cat skills-cli/SKILL-*.md > EMERGENCY_PLAYBOOK.md`

**Key difference:** Standalone markdown files, no metadata, optimized for terminal reading.

### Automation Quick Wins

New guide: `advanced/guides/AUTOMATION_QUICK_WINS.md`

**10 immediate improvements:**
1. Auto-update STATUS.md on commits
2. Claude Code session starter with context
3. Pre-commit verification (TypeScript/ESLint)
4. Smart project scaffolding
5. Deployment status monitor
6. Automatic changelog generation
7. Environment variable validator
8. Claude Code context optimizer
9. Backup before risky operations
10. Smart test running (changed files only)

**Time savings:** ~60 min/day → 5 hours/week

**See CHANGELOG.md for complete version history.**

---

## What's New in v4.2

### Team Mode

Optional automated multi-agent orchestration: `advanced/guides/TEAM_MODE.md`

**What it adds:** Claude Code agent teams that spawn multiple agents working in parallel — automated handoffs, shared context, parallel execution.

**Team configurations available:**
- Full Build — Complete 6-tier pipeline
- Feature Sprint — Focused feature development
- Code Review — Multi-perspective review
- Debug Investigation — Parallel debugging

**When to use:** Complex builds where you want agents to coordinate automatically instead of manual switching.

**Setup:** Copy `essential/toolkit/templates/team-configs/` to your project.

---

## What's New in v4.3

### Critical Fixes — Real Claude Code APIs

v4.3 rewrites three core configurations from non-functional placeholder formats to **real, working Claude Code APIs**:

**Hooks (CRITICAL FIX):** Replaced fake event names (`pre-commit`, `post-save`) with real `PreToolUse`/`PostToolUse` events, JSON stdin/stdout protocol, and proper exit codes. 5 production-ready hook scripts.

**settings.json (CRITICAL FIX):** Replaced plain-string permissions with real `Tool(specifier)` syntax (`Bash(git status)`, `Read(.env)`).

**MCP Configuration (CRITICAL FIX):** Replaced invented `"mcps"` key in settings.json with real `.mcp.json` file using `mcpServers` format and `claude mcp add` CLI commands.

### Native Subagents

All 10 agents now available as `.claude/agents/*.md` files with YAML frontmatter. Claude Code spawns them natively — no more copy-pasting into Claude Projects.

**Setup:** `cp essential/toolkit/templates/claude-agents/*.md .claude/agents/`

### Native Skills

All 28 skills available as `.claude/skills/*/SKILL.md` files with YAML frontmatter. Claude Code auto-loads and triggers them based on your task — no manual invocation needed.

**Setup:** `cp -r essential/skills/* ~/.claude/skills/`

### Stack-Specific Templates

New CLAUDE-SOLO variants for non-JavaScript stacks:
- `CLAUDE-SOLO-PYTHON.md` — Flask, SQLAlchemy, pytest
- `CLAUDE-SOLO-VUE.md` — Nuxt 3, Pinia, Composition API

### Integration Guides

Quick-start guides for common services: `advanced/guides/INTEGRATIONS.md`
- **Supabase** — Auth, database, real-time
- **Vercel** — Deploy, env vars, custom domains
- **Railway** — Database hosting, Docker deploy

**See CHANGELOG.md for complete v4.3 changelog.**

---

## Tips for Sharing

If you're sharing this toolkit with others:

1. **Start them with `essential/guides/DAY_ZERO.md`** — it's the bridge between "I have a computer" and "I'm ready to build"
2. The `essential/agents/` prompts reference "the user" generically — they work for anyone
3. The `02-project-brief-template.md` needs to be filled out per person/project
4. The `01-shared-context.md` describes a vibe coder profile — adjust if the user is a developer
5. The infrastructure prompt includes a sample user profile — customize the "About Me" section for your own projects
6. Point them to `essential/guides/TROUBLESHOOTING.md` when things inevitably break
7. Share `essential/guides/COSTS.md` so they know what to budget
