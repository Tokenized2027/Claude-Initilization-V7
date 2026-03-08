# START HERE - Your Claude Resources Hub

**Version:** V4.1 — Mac Ready
**Your Setup:** Non-developer vibe coder | macOS

---

## First Time? Do This Now (10 minutes)

### 1. Run the setup script
```bash
chmod +x setup-mac.sh
./setup-mac.sh
```
This installs Homebrew, Node.js, Git, and Claude Code CLI.

### 2. Copy settings to Claude's config
```bash
mkdir -p ~/.claude
cp dot-claude/settings.json ~/.claude/settings.json
```

### 3. Set up persistent memory
```bash
# Claude auto-creates this path when you first run it, but you can seed it:
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp memory/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
# Then edit it with your info
```

### 4. Add a CLAUDE.md to your first project
```bash
mkdir -p ~/projects/my-app && cd ~/projects/my-app
git init
cp $CLAUDE_HOME/examples/CLAUDE.md ./CLAUDE.md
# Edit CLAUDE.md with your project details, then:
claude
```

**See also:** `examples/todo-app/CLAUDE.md` for a filled-in example.

---

## Set Your CLAUDE_HOME Path

Throughout this system, `$CLAUDE_HOME` refers to wherever you put this folder. Set it once:

```bash
# Add to your shell profile (~/.zshrc)
export CLAUDE_HOME="$HOME/Desktop/Claude"
```

If you move this folder, just update that one line.

---

## What Do You Want to Do Today?

### 1. Daily Coding Work
**You have an active project and need to build/fix something**

```bash
# Navigate to your project
cd ~/projects/my-app

# Start Claude Code
claude

# Or one-shot command
claude "fix the bug in app.tsx line 42"
```

**Most-used resources:**
- `claude-code-framework/DAILY_REFERENCE.md` - Quick command cheatsheet
- `claude-code-framework/essential/guides/PITFALLS.md` - Avoid common mistakes
- `claude-code-framework/essential/guides/TROUBLESHOOTING.md` - When things break

---

### 2. Start New Project
**You want to build something from scratch**

```bash
# Use the scaffolding toolkit
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Follow the prompts to create:
# - Next.js app
# - Python Flask/FastAPI
# - Generic project
```

**Step-by-step guide:**
1. Read: `claude-code-framework/QUICK_START.md` (30 minutes)
2. Follow: `claude-code-framework/essential/guides/FIRST_PROJECT.md` (2 hours)
3. Reference: `claude-code-framework/essential/agents/README.md` (set up 1-2 agents)

---

### 3. Work on a Project
**Content, support, coding, or other work for any project**

**How this works:** Each project has its own context folder in `project-contexts/`. Load only the files relevant to your current task.

**To add a new project:** Copy `project-contexts/_template/` -> rename to your project -> fill in the files -> add a task table below.

---

#### [Your Project Name]

**Complete workflow guide:** Create one using the template in `project-contexts/_template/`

| Task | Files to Load |
|------|---------------|
| **Social Content** | `YOUR_WORKING_PROFILE.md`<br>`project-contexts/your-project/01-quick-reference.md`<br>`project-contexts/your-project/02-working-guidelines.md` |
| **Technical Work** | `YOUR_WORKING_PROFILE.md`<br>`project-contexts/your-project/01-quick-reference.md`<br>`project-contexts/your-project/03-technical.md` |
| **Documentation** | `YOUR_WORKING_PROFILE.md`<br>`project-contexts/your-project/01-quick-reference.md`<br>`project-contexts/your-project/03-technical.md` |

#### [Your Next Project]

> Copy `project-contexts/_template/`, fill it in, then add a task table here following the same pattern above.

**Quick references:**
- Adding a new project: `project-contexts/_template/README.md`

---

### 4. Emergency Recovery
**Something broke and you need to fix it NOW**

**For Multi-Agent System Issues:**
```bash
# Comprehensive troubleshooting guide
# See: multi-agent-system/docs/RUNBOOK.md

# Quick checks:
curl http://your-server:8000/health
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend
sudo systemctl status claude-orchestrator
```

**Common emergencies:**

```bash
# Git recovery
claude "I accidentally deleted my changes, recover them"
# Reference: claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md

# Docker issues
# Reference: templates/docker/README.md - Troubleshooting section

# Build errors
# Reference: claude-code-framework/essential/guides/TROUBLESHOOTING.md

# Full emergency guide
# Read: claude-code-framework/essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md
```

---

### 5. Learn the System
**You want to understand how everything works**

**Progressive learning path:**

**Day 1 (30 min):**
- Read: `claude-code-framework/QUICK_START.md`
- Set up: One agent (Frontend or Backend Developer)
- Try: Create a simple project

**Week 1 (2-3 hours total):**
- Follow: `claude-code-framework/essential/guides/FIRST_PROJECT.md`
- Learn: `claude-code-framework/essential/guides/DAY_ZERO.md` (if new to terminal/git)
- Reference: `claude-code-framework/essential/guides/DAILY_WORKFLOW.md`

**Week 2-4 (as needed):**
- Master: `claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md`
- Optimize: `claude-code-framework/advanced/guides/PROMPT_CACHING.md` (save 90% on API costs)
- Explore: `claude-code-framework/essential/guides/SKILLS.md` (automation)

**Advanced (optional):**
- Architecture: `claude-code-framework/advanced/guides/ARCHITECTURE_BLUEPRINT.md`
- Team Mode: `claude-code-framework/advanced/guides/TEAM_MODE.md`
- Infrastructure: `claude-code-framework/advanced/infrastructure/README.md`

---

### 6. Multi-Agent System (Mini PC)
**You want to submit tasks to your autonomous AI team**

```bash
# Submit a task (include your API key)
curl -X POST http://your-server:8000/route \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" \
  -d '{"task": "Build analytics dashboard", "project": "my-app"}'

# Check status
curl -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" http://your-server:8000/status/my-app

# View all running tasks
curl -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" http://your-server:8000/tasks
```

**Setup guide:** `multi-agent-system/docs/DEPLOYMENT_GUIDE.md`
**Quick reference:** `multi-agent-system/QUICKSTART.md`
**Architecture:** `multi-agent-system/README.md`

**What it does:** Submit a task -> agents coordinate autonomously (frontend -> backend -> testing) -> get results. 14 specialized agents with shared persistent memory.

---

### 7. Use Templates
**You need boilerplate for common patterns**

**Available templates:**
- **Docker:** `templates/docker/` - Production-ready containerization

**How to use:**
```bash
# Copy template to your project
cp -r templates/docker/python-web/* ~/projects/my-app/

# Customize for your needs
# See README.md in each template folder
```

---

## Folder Structure Overview

```
<CLAUDE_HOME>/
├── START_HERE.md                    <- YOU ARE HERE
├── README.md                        <- Detailed navigation guide
│
├── claude-code-framework/           <- Your vibe coding system
│   ├── QUICK_START.md              <- 30-minute setup
│   ├── DAILY_REFERENCE.md          <- Quick commands cheatsheet
│   ├── essential/                  <- Daily-use files
│   │   ├── agents/                 <- AI agent templates
│   │   ├── guides/                 <- How-to guides
│   │   ├── skills/                 <- 28 automation skills (V2.5)
│   │   └── toolkit/                <- Setup scripts
│   ├── advanced/                   <- Advanced features
│   └── archive/                    <- Reference materials
│
├── multi-agent-system/             <- Autonomous AI team (mini PC)
│   ├── orchestrator/              <- Task routing & coordination
│   ├── project_routes.json        <- Task routing config (edit this to add projects)
│   ├── mcp-servers/               <- Memory + context MCP servers
│   ├── agent-templates/           <- 14 specialized agents
│   └── deployment/                <- install.sh for mini PC
│
├── telegram-bot/                   <- Remote control via Telegram
│   ├── bot.py                     <- Command bot + webhook server
│   ├── install.sh                 <- One-command installer
│   └── WEBHOOK_SETUP.md          <- Wiring guide for notifications
│
├── whisper-service/                <- Shared speech-to-text (Docker)
│   ├── app.py                     <- Flask API server
│   ├── Dockerfile                 <- Container with Whisper model
│   └── docker-compose.yml        <- Ready to deploy
│
├── project-contexts/               <- Project-specific docs
│   └── _template/                 <- Copy this to start a new project
│
└── templates/                      <- Reusable boilerplate
    └── docker/                    <- Docker configs
```

---

## Essential Commands

```bash
# Start Claude Code in current directory
claude

# One-shot command
claude "create a new React component called Header"

# Create new project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Quick reference
cat $CLAUDE_HOME/claude-code-framework/DAILY_REFERENCE.md

# Check Claude Code version
claude --version

# Set API key (if needed)
export ANTHROPIC_API_KEY=your_key_here
```

---

## Your Learning Path

**Complete beginner?**
-> Start: `claude-code-framework/essential/guides/DAY_ZERO.md`

**Know basics, want to build?**
-> Start: `claude-code-framework/QUICK_START.md`

**Ready for first real project?**
-> Start: `claude-code-framework/essential/guides/FIRST_PROJECT.md`

**Want to optimize workflow?**
-> Start: `claude-code-framework/DAILY_REFERENCE.md`

**Building complex systems?**
-> Start: `claude-code-framework/advanced/guides/ARCHITECTURE_BLUEPRINT.md`

---

## Most Important Files (Bookmark These)

1. **This file** - `START_HERE.md` - Decision tree
2. **Your profile** - `YOUR_WORKING_PROFILE.md` - How Claude should work with you
3. **Changelog** - `CHANGELOG.md` - What's new in v3.0
4. **Operations runbook** - `multi-agent-system/docs/RUNBOOK.md` - Daily ops & troubleshooting
5. **Daily work** - `claude-code-framework/DAILY_REFERENCE.md` - Commands
6. **Troubleshooting** - `claude-code-framework/essential/guides/TROUBLESHOOTING.md` - Fixes
7. **Quick start** - `claude-code-framework/QUICK_START.md` - 30-min setup

---

## Pro Tips

### For Your Workflow (Non-Developer Vibe Coder)

1. **Start simple:** Use 1 agent (Frontend or Backend Developer), not all 10
2. **Complete files only:** Never accept partial snippets - demand full files
3. **Read errors fully:** Don't skip error messages - they tell you what's wrong
4. **Git early, git often:** Commit working code before trying new things
5. **Use START_HERE.md:** Come back here when you forget what to do

### Cost Optimization

- Enable prompt caching (see `claude-code-framework/advanced/guides/PROMPT_CACHING.md`)
- Start with Haiku for simple tasks, use Sonnet for complex work
- Use Claude Projects for documentation (free), Claude Code for coding (API cost)

---

## When You're Stuck

1. **Check this file** - Are you using the right resources?
2. **Read the error** - What exactly is failing?
3. **Check troubleshooting** - `claude-code-framework/essential/guides/TROUBLESHOOTING.md`
4. **Ask Claude** - Describe the problem in plain English
5. **Emergency guide** - `claude-code-framework/essential/guides/EMERGENCY_RECOVERY_VIBE_CODER.md`

---

## Quick Status Check

**Your current setup (V4):**
- Claude Code framework organized
- Project context system ready
- Docker templates available
- Global CLAUDE.md configured
- Templates for common patterns
- Multi-agent system with budget controls (production ready)
- Telegram command bot for remote control from phone
- Proactive push notifications (agent failures, task completions, disk alerts)
- Operational runbook for troubleshooting
- Cost analysis framework included

**Next recommended actions:**
1. Bookmark this file
2. Read `CHANGELOG.md` for v3.0 improvements
3. Review `multi-agent-system/docs/RUNBOOK.md` for operations
4. Set up one agent (Frontend or Backend)
5. Deploy multi-agent system to mini PC (when arrives)

---

## Common Workflows

### Quick Social Post
```bash
# 1. Open Claude Project, load context files:
- YOUR_WORKING_PROFILE.md
- project-contexts/your-project/01-quick-reference.md
- project-contexts/your-project/02-working-guidelines.md

# 2. Claude will ask you:
- Target audience?
- Key message?
- Tone?
- Specific points to include?

# 3. Review draft, iterate, ship
```

### Fix Bug in Existing Project
```bash
cd ~/projects/my-app
claude "Read the error in STATUS.md and fix the authentication bug"
```

### Start New Dashboard
```bash
# 1. Create project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# 2. Follow prompts
# 3. Reference: claude-code-framework/essential/guides/FIRST_PROJECT.md
```

---

**Remember:** This is YOUR system. Customize it, break it, rebuild it. That's how you learn.

**Questions?** Start with the file that matches your goal above, then work through the guides.

**Let's build.**
