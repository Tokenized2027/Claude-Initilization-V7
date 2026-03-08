# 🏗️ Master Project Architecture Blueprint
## Your Standard Setup for Every New Project

> **Purpose:** This is your single reference for how every project should be structured, what files go where, and what processes to follow. Bookmark this. Use it every time.
>
> **Last Updated:** February 12, 2026
>
> **Note:** This guide references the `claude-code-framework/` repository. Agent prompts are in `essential/agents/`, templates in `essential/toolkit/templates/`, and scripts in `essential/toolkit/`.

---

## Table of Contents

1. [The Standard Folder Structure](#1-the-standard-folder-structure)
2. [AI Agent System Setup](#2-ai-agent-system-setup)
3. [Mandatory Files — Every Project](#3-mandatory-files--every-project)
4. [Project Initialization Checklist](#4-project-initialization-checklist)
5. [Workflow Processes](#5-workflow-processes)
6. [Claude Code Configuration](#6-claude-code-configuration)
7. [Git Discipline](#7-git-discipline)
8. [Session Management](#8-session-management)
9. [Quick Reference Card](#9-quick-reference-card)
10. [Team Mode (Optional)](#10-team-mode-optional)

---

## 1. The Standard Folder Structure

Every project you create — whether it's a Next.js dashboard, a Python backend, or a Docker multi-service system — should follow this skeleton. Not every project will use every folder, but the scaffolding stays consistent so you always know where to find things.

```
project-root/
│
├── .claude/                        # Claude Code configuration
│   ├── hooks/                      # Automated hook scripts (PreToolUse/PostToolUse)
│   │   ├── protect-branches.sh     # Blocks commits to main/production
│   │   ├── block-dangerous-commands.sh  # Blocks rm -rf, force push, DROP TABLE
│   │   ├── block-env-reads.sh      # Prevents reading .env files
│   │   ├── verify-compliance.sh    # Pre-commit compliance checks
│   │   └── auto-format.sh          # Auto-formats after file writes
│   ├── agents/                     # Native subagent definitions (optional)
│   │   ├── system-architect.md     # Architecture design agent
│   │   ├── frontend-developer.md   # UI implementation agent
│   │   └── ...                     # Other agents as needed
│   ├── skills/                     # Native skill definitions (optional)
│   │   ├── docker-debugger/SKILL.md
│   │   ├── git-recovery/SKILL.md
│   │   └── ...                     # Other skills as needed
│   └── settings.json               # Permissions, hooks config
│
├── .mcp.json                       # MCP server configuration (Playwright, Postgres, etc.)
│
├── docs/                           # Project documentation (lives with the code)
│   ├── PRD.md                      # Product Requirements Document
│   └── TECH_SPEC.md                # Technical Specification
│
├── src/                            # All source code (or app/ for Next.js)
│   ├── components/                 # UI components (frontend projects)
│   ├── services/                   # Business logic / API integrations
│   ├── utils/                      # Shared helper functions (DRY principle)
│   ├── types/                      # TypeScript type definitions
│   └── config/                     # App configuration, constants
│
├── tests/                          # Test files (mirrors src/ structure)
│
├── logs/                           # Runtime logs (gitignored)
│
├── tmp/                            # Scratch/temp files (gitignored)
│
├── CLAUDE.md                       # Claude Code rules & project instructions
├── STATUS.md                       # Single source of truth for project state
├── .env.example                    # Template of all required env vars
├── .env                            # Actual env vars (gitignored, never committed)
├── .gitignore                      # Standard ignores
├── README.md                       # Public-facing project description
└── package.json / requirements.txt # Dependencies
```

### Folder Rules

| Folder | Rule |
|--------|------|
| `.claude/` | Never edit manually after initial setup — let Claude Code manage it |
| `docs/` | Only PRD.md and TECH_SPEC.md. These are living documents — update them |
| `src/` or `app/` | All code goes here. No code files in the project root |
| `utils/` | Any function used in 2+ places gets extracted here |
| `tests/` | Mirror the src/ structure (e.g., `tests/services/api.test.ts`) |
| `logs/` | Always gitignored. Structured logs with timestamps |
| `tmp/` | Always gitignored. For scratch experiments, never committed |

### Framework-Specific Variations

**Next.js Projects:**
```
project-root/
├── app/                    # Next.js App Router (replaces src/)
│   ├── layout.tsx
│   ├── page.tsx
│   ├── globals.css
│   └── api/                # API routes
│       └── [endpoint]/
│           └── route.ts
├── components/             # React components (outside app/ for cleanliness)
├── lib/                    # Utility functions, API clients
├── types/                  # TypeScript interfaces
├── public/                 # Static assets
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── [standard files above]
```

**Python/Flask Projects:**
```
project-root/
├── src/
│   ├── app.py              # Flask app factory
│   ├── routes/             # Blueprint route files
│   ├── services/           # Business logic
│   ├── models/             # Data models
│   └── utils/              # Helpers
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── requirements.txt
└── [standard files above]
```

**Docker Multi-Service Projects**:
```
project-root/
├── services/
│   ├── service-a/
│   │   ├── Dockerfile
│   │   ├── src/
│   │   └── requirements.txt
│   └── service-b/
│       ├── Dockerfile
│       ├── src/
│       └── requirements.txt
├── docker-compose.yml      # Root-level compose
├── .env.example
└── [standard files above]
```

---

## 2. AI Agent System Setup

Your AI development team consists of **10 specialized agents** organized in a **tier-based parallel architecture** (33% faster than sequential).

### Tier-Based Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ TIER 1: DISCOVERY & PLANNING (Sequential)                   │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  System Architect → Product Manager                          │
│  (Technical blueprint)  (Requirements & task breakdown)      │
│                                                               │
└────────────────────┬────────────────────────────────────────┘
                     ↓ HANDOFF BRIEFS
┌─────────────────────────────────────────────────────────────┐
│ TIER 2: DESIGN & CONTRACTS (Parallel)                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌─────────────────────┐       │
│  │ Designer         │ ←──────→│ API Architect       │       │
│  │ (UI/UX, mockups) │         │ (Endpoints, schemas)│       │
│  └──────────────────┘         └─────────────────────┘       │
│         │                              │                     │
│         └──────────┬───────────────────┘                     │
│                    ↓                                          │
│            Design Contract                                    │
│         (Component specs + API contracts)                    │
│                                                               │
└────────────────────┬────────────────────────────────────────┘
                     ↓ HANDOFF BRIEFS
┌─────────────────────────────────────────────────────────────┐
│ TIER 3: PARALLEL IMPLEMENTATION                              │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────┐    ┌──────────────────────┐       │
│  │ Frontend Developer   │◄──►│ Backend Developer    │       │
│  │ - Implements design  │    │ - Implements APIs    │       │
│  │ - Component library  │    │ - Database models    │       │
│  │ - State management   │    │ - Business logic     │       │
│  └──────────────────────┘    └──────────────────────┘       │
│           │                            │                     │
│           └────────────┬───────────────┘                     │
│                        ↓                                      │
│                 Integration Point                             │
│                                                               │
└────────────────────────┬────────────────────────────────────┘
                         ↓ HANDOFF BRIEFS
┌─────────────────────────────────────────────────────────────┐
│ TIER 4: QUALITY ASSURANCE (Sequential - Security First)     │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Security Auditor → System Tester                            │
│  (Code review,      (Integration tests,                      │
│   vulnerabilities,  E2E tests,                               │
│   best practices)   bug reports)                             │
│                                                               │
│         ↓ PASS                    ↓ FAIL                     │
│         ↓                          ↓                          │
│    Continue                   Back to Dev                     │
│                              (with specific fixes)            │
│                                                               │
└────────────────────────┬────────────────────────────────────┘
                         ↓ HANDOFF BRIEF
┌─────────────────────────────────────────────────────────────┐
│ TIER 5: DEPLOYMENT                                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  DevOps Engineer                                             │
│  - Docker configuration                                      │
│  - Environment setup                                          │
│  - CI/CD pipelines                                            │
│  - Deployment verification                                    │
│  - Monitoring setup                                           │
│                                                               │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ TIER 6: DOCUMENTATION (Async - Runs Throughout)             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Technical Writer                                            │
│  - Can run in parallel at any tier                           │
│  - Documents as features complete                            │
│  - API docs, README, user guides                             │
│  - Always-current documentation                              │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Why Tier-Based is Better

**Time Savings:**
```
Sequential (v2.5): 18 hours (3h × 6 agents)
Tier-Based (v3.0): 12 hours (parallel work)
Savings: 33% faster
```

**Key Advantages:**
- ✅ Parallel work streams (Designer + API Architect, Frontend + Backend)
- ✅ Clear contracts eliminate integration bugs
- ✅ Security first (audit before testing)
- ✅ Continuous documentation (not rushed at end)
- ✅ Feedback loops to specific agents

### Enhancing Agents with RAG (Project Knowledge)

Upload documentation to Claude Projects for automatic retrieval:

**What to upload per agent:**

| Agent | Upload to Project Knowledge |
|-------|----------------------------|
| **System Architect** | Architecture patterns, best practices docs, design templates |
| **Product Manager** | PRD templates, user story formats, project planning guides |
| **Designer** | Brand guidelines, design inspiration, component examples, style guides |
| **API Architect** | API design patterns, schema examples, integration docs |
| **Frontend Developer** | Component library docs, UI patterns, style guides, Tailwind docs |
| **Backend Developer** | API patterns, database schemas, service architecture docs |
| **Security Auditor** | Security checklists, vulnerability databases, audit templates |
| **System Tester** | Test patterns, QA checklists, common bug scenarios |
| **DevOps Engineer** | Infrastructure patterns, Docker templates, CI/CD examples |
| **Technical Writer** | Documentation templates, style guides, writing standards |

**Benefits:**
- Agents remember project patterns without re-pasting
- Consistent adherence to established conventions
- Reduced token usage (docs retrieved, not pasted)
- See `advanced/guides/RAG_PROJECT_KNOWLEDGE.md` for setup

### Where Agent Prompts Live

You need **two things** for agent prompts: a storage location and Claude Projects.

**Storage Location** — keep all prompt files together in one folder on your computer:

```
~/ai-dev-team/                        # Your local machine
├── 00-README.md                      # How to use the system
├── 01-shared-context.md              # Shared identity + rules (goes in ALL agents)
├── 02-project-brief-template.md      # Fill out per project, paste every conversation
├── 03-system-architect.md            # Agent 1 (Tier 1)
├── 04-product-manager.md             # Agent 2 (Tier 1)
├── 05-designer.md                    # Agent 3 (Tier 2)
├── 06-api-architect.md               # Agent 4 (Tier 2) ← NEW
├── 07-frontend-developer.md          # Agent 5 (Tier 3)
├── 08-backend-developer.md           # Agent 6 (Tier 3)
├── 09-security-auditor.md            # Agent 7 (Tier 4) ← NEW
├── 10-system-tester.md               # Agent 8 (Tier 4)
├── 11-devops-engineer.md             # Agent 9 (Tier 5) ← NEW
└── 12-technical-writer.md            # Agent 10 (Tier 6) ← NEW
```

**Claude Projects** — create 10 separate Claude Projects (one per agent):

| Claude Project Name | System Prompt Contents (paste in order) |
|--------------------|-----------------------------------------|
| 🏗️ System Architect | `01-shared-context.md` + `03-system-architect.md` |
| 📋 Product Manager | `01-shared-context.md` + `04-product-manager.md` |
| 🎨 Designer | `01-shared-context.md` + `05-designer.md` |
| 🔌 API Architect | `01-shared-context.md` + `06-api-architect.md` |
| ⚛️ Frontend Developer | `01-shared-context.md` + `07-frontend-developer.md` |
| ⚙️ Backend Developer | `01-shared-context.md` + `08-backend-developer.md` |
| 🔒 Security Auditor | `01-shared-context.md` + `09-security-auditor.md` |
| 🧪 System Tester | `01-shared-context.md` + `10-system-tester.md` |
| 🚀 DevOps Engineer | `01-shared-context.md` + `11-devops-engineer.md` |
| 📚 Technical Writer | `01-shared-context.md` + `12-technical-writer.md` |

**Key rule:** The `01-shared-context.md` content goes FIRST in every project's system prompt. The agent-specific file goes SECOND. This ensures consistent behavior across all agents.

**💡 Cost Optimization:** These agent prompts are 3,000-5,000 tokens each and get repeated in every conversation. Implement prompt caching to save 90% on API costs. See `advanced/guides/PROMPT_CACHING.md` for details.

### The Project Brief — Your Conversation Starter

The `02-project-brief-template.md` is NOT a system prompt. It's a living document you paste at the START of every new conversation with any agent.

```
Every new conversation = Project Brief + [optional Handoff Brief] + Your request
```

Keep one project brief per active project. Update it whenever something significant changes (new API added, folder restructured, dependency changed). This is your single source of truth that prevents agents from making outdated assumptions.

### When to Use Which Agent

| Situation | Go To |
|-----------|-------|
| Brand new project or major new system | System Architect → full pipeline |
| User-facing feature with UI/UX needs | Designer → Frontend → Tester |
| New feature (medium complexity) | Product Manager → developers → tester |
| Small feature or bug fix | Directly to Frontend or Backend Developer |
| Something's broken, not sure why | System Tester (for diagnosis) or relevant Developer |
| Need visual design system | Designer (outputs specs for Frontend) |
| UI/styling change | Frontend Developer directly |
| API or data issue | Backend Developer directly |
| Need to verify before deploy | System Tester |

**90% of your work** will be Direct Mode — going straight to a developer agent. The full pipeline is only for building something new from scratch.

---

## 3. Mandatory Files — Every Project

These files must exist in every project. No exceptions.

### 3.1 CLAUDE.md

**Location:** Project root (`/CLAUDE.md`)
**Purpose:** Tells Claude Code how to behave in this specific project. This is the rules file.

What it must contain:
- Project info (repo URL, stack, key docs links)
- Links to PRD.md, TECH_SPEC.md, STATUS.md
- Code quality rules (no dead code, DRY, file size limits)
- Logging requirements (structured, with levels)
- Git discipline (commit frequency, branch rules, message format)
- Self-correction protocol (Claude adds learned corrections here)
- Data/AI work safeguards (no silent subsampling, verify numbers)
- Project-specific rules section (custom per project)

**Template:** Use the `CLAUDE_MD_TEMPLATE.md` file provided. Copy it, fill in the placeholders.

### 3.2 STATUS.md

**Location:** Project root (`/STATUS.md`)
**Purpose:** The single most important file for session continuity. Without it, every new Claude Code session starts from zero.

What it must contain:
- Current phase and active branch
- Full project file tree (updated after structural changes)
- Completed work (with dates)
- In-progress tasks
- Active bugs/issues
- Key decisions made
- Environment/integration status
- Session log (what happened each session)

**Rule:** STATUS.md gets updated after EVERY code change. This is non-negotiable. Put it in CLAUDE.md as a mandatory instruction.

**Template:** Use the `STATUS_MD_TEMPLATE.md` file provided.

### 3.3 docs/PRD.md

**Location:** `/docs/PRD.md`
**Purpose:** What you're building and why. Written before any code.

**Process:** Don't write this in one pass. Use the iterative approach:
1. Tell Claude Code what you want to build
2. Let it ask you 10+ questions
3. Review the first draft
4. Iterate until you're satisfied
5. Only then approve and move to Tech Spec

**Template:** Use `PRD_TEMPLATE.md`.

### 3.4 docs/TECH_SPEC.md

**Location:** `/docs/TECH_SPEC.md`
**Purpose:** How you're building it. Written after PRD is approved.

**Process:** Same iterative approach — Claude asks questions, you answer, review drafts together.

**Template:** Use `TECH_SPEC_TEMPLATE.md`.

### 3.5 .env.example

**Location:** Project root (`/.env.example`)
**Purpose:** Documents every environment variable the project needs, without containing real values.

```bash
# .env.example — Copy to .env and fill in real values

# API Keys
NEXT_PUBLIC_ALCHEMY_API_KEY=your_alchemy_key_here
ETHERSCAN_API_KEY=your_etherscan_key_here

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# External Services
OPENAI_API_KEY=your_openai_key_here
```

**Rule:** Every time a new env var is added to `.env`, it must also be added to `.env.example` with a description.

### 3.6 .gitignore

**Location:** Project root
**Must include at minimum:**

```gitignore
# Environment
.env
.env.local
.env.*.local

# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
.venv/

# Project-specific
tmp/
logs/
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Build
.next/
dist/
build/
*.egg-info/
```

---

## 4. Project Initialization Checklist

Run through this every time you start a new project. Copy-paste the prompts.

### Phase 0: Skeleton (5 minutes)

**Step 1 — Create the project and standard structure:**

Prompt to Claude Code:
```
Create a new project with this structure:
- CLAUDE.md (I'll provide the template)
- STATUS.md (I'll provide the template)
- .claude/hooks/ directory with all 4 hook scripts (branch protection, safe commands, auto-format, code review)
- .claude/settings.json with hooks config, allowed commands, and Playwright MCP
- docs/ directory (empty for now)
- tmp/ directory (gitignored)
- logs/ directory (gitignored)
- .gitignore with standard ignores
- .env.example (empty template)
- README.md with project name and one-line description

Initialize git repo, create main branch, then create a develop branch.
Search the internet for current Claude Code hooks best practices before creating them.
```

**Step 2 — Paste your CLAUDE.md template and customize it.**

**Step 3 — Paste your STATUS.md template and fill in initial state.**

### Phase 0.5: Documentation (30-60 minutes)

**Step 4 — Create PRD:**

```
I need you to create a PRD for this project. Before writing anything,
ask me at least 10 questions about the business problem, users, success
criteria, technical constraints, and priorities. This is iterative —
we'll go back and forth until it's right. Save as docs/PRD.md
```

Review. Iterate. Approve.

**Step 5 — Create Tech Spec:**

```
Based on the approved PRD (docs/PRD.md), create a Technical Specification.
Ask me clarifying questions about stack preferences, hosting, external APIs,
performance, and security before writing. Save as docs/TECH_SPEC.md
```

Review. Iterate. Approve.

**Step 6 — Update STATUS.md:**

```
Update STATUS.md: Phase 0 complete. PRD and Tech Spec approved.
List the first tasks from Phase 1 under "What's Next".
Add all key decisions to the decisions table.
Link PRD and Tech Spec in CLAUDE.md.
Commit everything with message "chore(setup): project skeleton, PRD, tech spec"
```

### Phase 1: Build (ongoing)

Now you're ready to start coding. Use the session management processes in Section 8 below.

---

## 5. Workflow Processes

### Operating Modes Overview

Your blueprint supports **four operating modes**. Choose based on the task:

| Mode | Sessions | Orchestration | Parallelism | Token Cost | Best For |
|------|---------|---------------|-------------|-----------|----------|
| **Solo Mode** | 1 | None | None | Lowest | Quick tasks, small features, bug fixes |
| **Direct Mode** | 1 | None (you → one agent) | None | Low | 90% of daily work |
| **Full Pipeline** | 10 (manual) | You copy-paste handoff briefs | Manual (multiple tabs) | Medium | Building new systems when cost matters |
| **Team Mode** | 1 lead + N teammates | Automated (shared task list + mailbox) | Real (teammates work simultaneously) | Highest (3-10x) | Building new systems with real parallelism |

> **Team Mode** is optional and experimental. See [Section 10](#10-team-mode-optional) for full setup and usage. All other modes are unaffected.

### 5.1 The Full Pipeline (New System)

```
You (idea) → System Architect → Product Manager → Frontend Dev → Backend Dev → System Tester → Deploy
```

At each step:
1. Open the agent's Claude Project
2. Paste the **Project Brief** first
3. Paste the **Handoff Brief** from the previous agent
4. Let the agent do its work
5. Copy the agent's **Handoff Brief** for the next step

### 5.2 Direct Mode (Most Common — 90% of work)

```
You (task/bug) → Relevant Developer Agent → System Tester (optional) → Deploy
```

1. Open the relevant developer's Claude Project
2. Paste the **Project Brief**
3. Describe what you need or paste the error
4. The agent asks 2-3 questions, then builds

### 5.3 Bug Fix Flow

```
You (error message) → Developer Agent → fix → verify
```

1. Copy the **full error message** (not a summary)
2. Paste it to the relevant developer agent with the project brief
3. The agent will ask to see the affected file(s)
4. Paste the actual files
5. Receive complete fixed file(s)

### 5.4 PRD/Tech Spec Review (CC Teams 5-Role Simulation)

For complex projects, use the 5-role team discussion approach:

```
We're going to create project documentation using a team discussion.
Simulate 5 roles: CEO (business value), PM (user stories), Frontend Dev
(UI/UX), Backend Dev (APIs/infra), AI/ML Engineer (model/data).

Each role asks 2-3 questions. I answer. Team discusses and produces
the document. I review. We iterate until approved.

Here's what I want to build: [YOUR DESCRIPTION]
```

---

## 6. Claude Code Configuration

### 6.1 Hooks (Automated Safeguards)

Every project gets 5 hooks in `.claude/hooks/`. Hooks use the **real Claude Code hooks API** — they receive JSON on stdin, exit 0 to allow, exit 2 to block.

| Hook | Event | Matcher | What It Does |
|------|-------|---------|-------------|
| `protect-branches.sh` | `PreToolUse` | `Bash` | Blocks git commits/pushes to main/production branches |
| `block-dangerous-commands.sh` | `PreToolUse` | `Bash` | Blocks rm -rf, force push, DROP TABLE |
| `block-env-reads.sh` | `PreToolUse` | `Read\|Edit\|Write` | Prevents Claude from accessing .env files |
| `verify-compliance.sh` | `PreToolUse` | `Bash` | Checks for partial file markers and secrets before git commit |
| `auto-format.sh` | `PostToolUse` | `Write\|Edit` | Runs Prettier/ESLint/Black after file changes |

**How hooks work:** Each hook receives a JSON payload on stdin with `tool_name` and `tool_input`. The script inspects the payload, decides whether to allow or block, and exits with code 0 (allow) or 2 (block). When blocking, output JSON with a `reason` field.

See `essential/toolkit/templates/HOOKS_SETUP.md` for complete guide and `essential/toolkit/templates/hooks/` for all scripts.

### 6.2 settings.json

Configuration lives in `.claude/settings.json`. Uses `Tool(specifier)` permission syntax and event-based hooks.

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)", "Bash(git add *)", "Bash(git commit *)",
      "Bash(git push *)", "Bash(npm install *)", "Bash(npm run *)",
      "Bash(npm test *)", "Bash(npx *)", "Bash(pip install *)",
      "Bash(python *)", "Bash(pytest *)", "Bash(docker compose *)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(git push --force *)", "Bash(git reset --hard *)",
      "Read(.env)", "Read(.env.local)", "Read(.env.production)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/protect-branches.sh" },
          { "type": "command", "command": "bash .claude/hooks/block-dangerous-commands.sh" },
          { "type": "command", "command": "bash .claude/hooks/verify-compliance.sh" }
        ]
      },
      {
        "matcher": "Read|Edit|Write",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/block-env-reads.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash .claude/hooks/auto-format.sh" }
        ]
      }
    ]
  }
}
```

Template: `essential/toolkit/templates/settings.json`

### 6.3 MCP (Model Context Protocol)

MCP servers are configured in `.mcp.json` (project root) using the `claude mcp add` command:

```bash
# Add Playwright (browser automation) — non-negotiable for web UI projects
claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright

# Add Postgres (direct database access)
claude mcp add postgres -e DATABASE_URL=postgresql://... -- npx @modelcontextprotocol/server-postgres

# List configured servers
claude mcp list
```

This creates `.mcp.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

**Playwright MCP is non-negotiable for any project with a web UI.** Without it, you're doing all UI debugging manually. See `advanced/guides/MCP_SETUP.md` for full setup.

### 6.4 Native Subagents and Skills

**Subagents** (`.claude/agents/*.md`) — Specialized AI agents that Claude Code can spawn for complex tasks:
```bash
cp essential/toolkit/templates/claude-agents/*.md .claude/agents/
```

**Skills** (`.claude/skills/*/SKILL.md`) — 28 quick, reusable task templates:
```bash
cp -r essential/skills/* ~/.claude/skills/
```

See `essential/skills/README.md` for the complete list and descriptions.

### 6.4 Claude Code CLI — Current Best Practices (Feb 2026)

#### Installation

```bash
npm install -g @anthropic-ai/claude-code
```

Your Anthropic API key is required on first run. Get it from console.anthropic.com → API Keys.

#### Key Commands

| Command | What It Does |
|---------|-------------|
| `claude` | Start an interactive session in the current directory |
| `claude "do something"` | One-shot command — runs and exits (cheaper for simple tasks) |
| `claude --resume` | Resume the last conversation |
| `claude --continue` | Continue in the same session |
| `/help` | Show available commands inside a session |
| `/help hooks` | Show current hooks configuration format |

#### Context Management

Claude Code reads files on demand — it doesn't load your entire project into memory. This means:

- It can work on large projects without running out of context
- But it may forget things from earlier in long conversations
- **STATUS.md solves this:** "Read STATUS.md" brings Claude back up to speed instantly
- Start fresh conversations often — short focused sessions beat long meandering ones

#### Cost Awareness

Claude Code uses your API credits (pay-per-use, separate from your $20/mo Pro subscription). Rough costs per task:

| Task | Typical Cost |
|------|-------------|
| Quick fixes, config edits | $0.05-0.20 |
| New component or script | $0.20-1.00 |
| Full feature (frontend + backend) | $1.00-10.00 |
| Architecture / planning session | $1.00-5.00 |
| Long unfocused session (avoid these) | $5.00-20.00+ |

**Cost controls:**
1. Set a monthly limit at console.anthropic.com → Spending Limits
2. **Implement prompt caching** — saves 70-90% on agent prompts and project briefs (see `advanced/guides/PROMPT_CACHING.md`)
3. **Use batch processing for bulk tasks** — 50% off for asynchronous requests (see `advanced/guides/BATCH_PROCESSING.md`)
4. Use one-shot commands for simple tasks: `claude "fix the typo in line 42"`
5. Keep conversations focused — shorter is cheaper AND better
6. Use Claude Projects (Pro sub) for planning/discussion, CLI (API) for execution

**Savings stack:**
- Batch processing: 50% off all tokens
- Prompt caching: 90% off repeated context
- **Combined:** Up to 95% total savings on bulk operations with shared context

**Prompt caching impact:** A 50-message conversation costs $0.45 without caching, $0.055 with caching (88% reduction).

**Batch processing impact:** 1,000 requests costs $15.00 standard, $7.50 batched (50% reduction).

See `essential/guides/COSTS.md` for the full cost breakdown, `advanced/guides/PROMPT_CACHING.md` for caching, and `advanced/guides/BATCH_PROCESSING.md` for batch implementation.

#### MCP Servers (Model Context Protocol)

MCPs extend Claude Code's capabilities by connecting it to external tools and services.

| MCP | What It Does | When to Set Up |
|-----|-------------|----------------|
| Playwright | Browser automation — Claude can interact with your web app | Any project with a web UI |
| Filesystem | Enhanced file operations | Built-in |

MCP configuration lives in:
- `~/.claude/settings.json` — global (applies to all projects)
- `.claude/settings.json` — per-project (overrides global)

#### First Session in a New Project

After running `claude` in a new project directory for the first time:

```
Read CLAUDE.md and STATUS.md. Confirm you understand the project
rules and current state. Then tell me what you see.
```

This ensures Claude Code has absorbed your project's rules before writing any code.

---

## 7. Git Discipline

### Branch Strategy

```
main (or production)  ← Protected. Never commit directly.
  └── develop         ← Your working branch for active development
       └── feature/*  ← Feature branches for significant new work
       └── fix/*      ← Bug fix branches
```

### Commit Rules

| Rule | Why |
|------|-----|
| Commit after every completed unit of work | Prevents painful rollbacks |
| Never commit to main directly | Hooks block this, but internalize it |
| Clear commit messages | Future you needs to understand what changed |
| Format: `type(scope): description` | Consistent, searchable history |

### Commit Message Types

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring (no behavior change) |
| `docs` | Documentation changes |
| `chore` | Setup, config, maintenance |
| `style` | Formatting, no logic change |
| `test` | Adding or updating tests |

**Examples:**
```
feat(dashboard): add whale alert component
fix(api): handle CoinGecko rate limit errors
refactor(utils): extract shared formatting helpers
docs(readme): update deployment instructions
chore(setup): configure Docker Compose health checks
```

---

## 8. Session Management

### Starting a Session (Resuming Work)

Prompt to Claude Code:
```
Read STATUS.md, CLAUDE.md, and docs/ to understand where we left off.
Tell me: (1) last thing completed, (2) next task, (3) any open bugs.
Then proceed with the next task unless I redirect you.
```

### Mid-Session Checkpoint

Every 30-45 minutes or after completing a feature:
```
Checkpoint:
1. Update STATUS.md with everything we've done
2. Commit all work with descriptive messages
3. Run code review hook
4. Tell me what's next
```

### End of Session

```
End of session:
1. Update STATUS.md with current state
2. Commit all work with descriptive messages
3. List any open bugs or issues
4. Summarize what we accomplished
5. State what the next session should start with
```

### When a Conversation Gets Long (15+ messages)

Ask the agent for a Continuation Brief:
```
This conversation is getting long. Give me a CONTINUATION BRIEF so I
can start a fresh conversation without losing context.
```

Then: new conversation → paste Project Brief + Continuation Brief + any active files.

---

## 9. Quick Reference Card

### File Locations at a Glance

| File | Location | Purpose |
|------|----------|---------|
| CLAUDE.md | `/CLAUDE.md` | Rules for Claude Code |
| STATUS.md | `/STATUS.md` | Project state (update after every change) |
| PRD.md | `/docs/PRD.md` | What we're building and why |
| TECH_SPEC.md | `/docs/TECH_SPEC.md` | How we're building it |
| .env.example | `/.env.example` | Env var documentation |
| .env | `/.env` | Real env vars (gitignored) |
| Hook scripts | `/.claude/hooks/` | Automated safeguards |
| Settings | `/.claude/settings.json` | Claude Code configuration |
| Agent prompts | `~/ai-dev-team/` | Local machine, NOT in project |
| Project brief | `~/ai-dev-team/` | Updated per project, pasted per conversation |

### Trust Spectrum (What to Verify)

| What Claude Code Produces | Trust Level | What You Do |
|---------------------------|-------------|-------------|
| Project scaffolding / boilerplate | High ✅ | Light review |
| UI / frontend code | Medium-High | Visual check + Playwright |
| API / backend logic | Medium | Code review hook + spot check |
| Data analysis / numbers | Low ⚠️ | Always verify manually |
| Following its own CLAUDE.md | Medium ⚠️ | Periodic audits |

### Common Pitfalls to Watch For

1. **Claude silently subsamples data** — Always verify it processed the full dataset
2. **Claude gets numbers wrong** — Double-check all numerical claims
3. **Claude drifts without commits** — Enforce checkpoints every 30 min
4. **Claude leaves orphaned code** — Explicitly ask it to clean up old implementations
5. **Claude ignores CLAUDE.md** — Periodically audit compliance
6. **Claude gives partial files** — Your rule says COMPLETE files only; enforce this

---

## 10. Team Mode (Optional)

> **Experimental feature.** Requires opt-in. All other modes continue to work unchanged.

Team Mode uses Claude Code's native agent teams to automate the orchestration that you currently do manually in the Full Pipeline. Instead of copying handoff briefs between 10 Claude Project conversations, a single lead session spawns teammates that communicate through a shared mailbox and task list.

### Why Add Team Mode?

The tier-based architecture in [Section 2](#2-ai-agent-system-setup) shows parallel work streams (Designer + API Architect, Frontend + Backend). In the Full Pipeline, this parallelism is manual — you open multiple browser tabs and switch between them. Team Mode makes it real and automated.

| What Changes | Full Pipeline (Manual) | Team Mode (Automated) |
|-------------|----------------------|---------------------|
| Handoffs | Copy-paste briefs between conversations | Native mailbox messaging |
| Parallel tiers | Open multiple tabs, switch manually | Teammates work simultaneously |
| Task tracking | Mental tracking or STATUS.md | Shared task list with dependencies |
| Interface | 10 Claude Project browser tabs | One terminal with Shift+Up/Down |
| Quality gates | You enforce "security before testing" | Task dependencies enforce it |

### Quick Start

**1. Enable the feature:**

Add to `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**2. Start Claude Code in your project:**
```bash
claude
```

**3. Paste a team configuration.**

Four pre-built configs are available for common scenarios:

| Config | Teammates | Use When |
|--------|-----------|----------|
| **Full Build** | 6-8 (all tiers) | New system from scratch |
| **Feature Sprint** | 3 (frontend + backend + tester) | Adding a significant feature |
| **Code Review** | 3 (security + performance + quality) | Thorough multi-lens review |
| **Debug Investigation** | 3 (competing hypotheses) | Unclear root cause |

**4. Monitor and steer.**

| Action | Keys |
|--------|------|
| Select teammate | Shift+Up/Down |
| View teammate session | Enter |
| Exit teammate view | Escape |
| Toggle task list | Ctrl+T |
| Delegate mode (lead coordinates only) | Shift+Tab |

**5. Clean up when done.**

```
Ask all teammates to shut down, then clean up the team.
```

### Agent-to-Teammate Mapping

Your 10 agents map directly to team roles with clear file ownership:

| Agent Role | Tier | Owns | Blocked By |
|-----------|------|------|-----------|
| System Architect | 1 | `docs/TECH_SPEC.md`, `docs/ARCHITECTURE.md` | — |
| Product Manager | 1 | `docs/PRD.md`, task breakdown | Architect |
| Designer | 2 | `docs/DESIGN_SYSTEM.md`, `docs/COMPONENT_SPECS.md` | PM |
| API Architect | 2 | `docs/API_CONTRACTS.md`, `types/api.ts` | PM |
| Frontend Dev | 3 | `/app`, `/components`, `/lib`, `/types` | Designer + API Architect |
| Backend Dev | 3 | `/src/routes`, `/src/services`, `/src/models` | API Architect |
| Security Auditor | 4 | `docs/SECURITY_AUDIT_REPORT.md` | Frontend + Backend |
| System Tester | 4 | `/tests`, `docs/TEST_REPORT.md` | Security Auditor |
| DevOps Engineer | 5 | `Dockerfile`, CI/CD configs | Tester |
| Technical Writer | 6 | `README.md`, `docs/USER_GUIDE.md` | — (runs throughout) |

### Cost Awareness

Team Mode uses 3-10x more tokens than Solo or Direct mode. Each teammate is a full Claude Code session.

| Config | Estimated Cost Multiplier |
|--------|--------------------------|
| Full Build | 5-10x solo |
| Feature Sprint | 3-5x solo |
| Code Review | 3-4x solo |
| Debug Investigation | 3-5x solo |

**Cost tips:** Use Sonnet for implementation teammates and Opus for architecture/security. Keep sessions short. Start with review tasks to learn the workflow before running full builds.

### Limitations

- **Experimental** — the feature may change. All other modes are unaffected.
- **No session resumption** for in-process teammates
- **Windows** — split-pane mode not supported; use in-process mode (works fully)
- **One team per session** — clean up before starting a new team
- **Higher token cost** — 3-10x depending on configuration

### Full Guide

See **`advanced/guides/TEAM_MODE.md`** for:
- Complete team configurations (copy-paste ready)
- Individual spawn prompts for each agent role
- Step-by-step workflow walkthroughs
- Best practices and troubleshooting
- Quick reference card

---

## Appendix A: Template Files Quick Reference

Keep these templates on your local machine. Copy them when starting new projects.

| Template File | Use When |
|--------------|----------|
| `CLAUDE_MD_TEMPLATE.md` | Starting any new project |
| `STATUS_MD_TEMPLATE.md` | Starting any new project |
| `PRD_TEMPLATE.md` | Creating requirements for a new project |
| `TECH_SPEC_TEMPLATE.md` | Creating technical spec after PRD is approved |
| `HOOKS_SETUP_TEMPLATE.md` | Setting up Claude Code hooks (reference for hook scripts) |
| `PROJECT_INIT_WORKFLOW.md` | Step-by-step project initialization (reference) |
| `CC_PITFALLS_AND_WATCHOUTS.md` | Periodic review to stay sharp |

### Recommended Local File Organization

```
~/ai-dev-team/
├── agents/                          # Agent prompt files
│   ├── 00-README.md
│   ├── 01-shared-context.md
│   ├── 02-project-brief-template.md
│   ├── 03-system-architect.md
│   ├── 04-product-manager.md
│   ├── 05-frontend-developer.md
│   ├── 06-backend-developer.md
│   └── 07-system-tester.md
│
├── templates/                       # Project templates (copy into new projects)
│   ├── CLAUDE_MD_TEMPLATE.md
│   ├── STATUS_MD_TEMPLATE.md
│   ├── PRD_TEMPLATE.md
│   ├── TECH_SPEC_TEMPLATE.md
│   └── HOOKS_SETUP_TEMPLATE.md
│
├── references/                      # Read-only reference docs
│   ├── PROJECT_INIT_WORKFLOW.md
│   └── CC_PITFALLS_AND_WATCHOUTS.md
│
└── project-briefs/                  # One brief per active project
    ├── my-dashboard-brief.md
    ├── my-backend-brief.md
    └── my-side-project-brief.md
```

---

## Appendix B: The 10 Commandments

1. **STATUS.md is sacred.** Update it after every change. Without it, you're lost.
2. **CLAUDE.md is law.** If it's in CLAUDE.md, Claude Code must follow it. Audit periodically.
3. **Never commit to main.** Always work on develop or feature branches.
4. **Complete files only.** Never accept partial code. Never.
5. **Paste real files.** Agents need actual code, not descriptions of code.
6. **Commit early, commit often.** After every completed unit of work.
7. **Iterate on docs.** PRD and Tech Spec are conversations, not one-shot outputs.
8. **Verify numbers.** Claude gets numerical analysis wrong frequently.
9. **One project brief, one place.** Don't scatter project details across agent prompts.
10. **Direct Mode is default.** Full pipeline is only for new systems.
