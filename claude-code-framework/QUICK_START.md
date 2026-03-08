# Quick Start Guide — Get Building in 30 Minutes

> **Goal:** Go from zero to your first AI-assisted project in 30 minutes. This guide covers the absolute minimum setup to start building.
>
> **Who this is for:** You've downloaded the framework and want to start immediately, not read 100 pages of documentation.
>
> **Last Updated:** February 12, 2026

---

## Prerequisites

Before starting, you need:

1. **Claude Pro subscription** ($20/month) — For Claude Projects
2. **Anthropic API key** — Get from console.anthropic.com
3. **Basic terminal access** — Can open Terminal (Mac) or Command Prompt (Windows)

**Optional but recommended:**
- Claude Code CLI installed (for direct coding assistance)
- Git installed (for version control)
- VS Code or similar editor

**New to all of this?** Start with `essential/guides/DAY_ZERO.md` for plain-English explanations of everything.

---

## 30-Minute Setup

### Step 1: Set Up One Agent (5 minutes)

You don't need all 10 agents to start. Begin with one developer agent depending on your project type:
- **Frontend work?** Use Frontend Developer
- **Backend/API work?** Use Backend Developer
- **Full-stack solo?** Start with Backend Developer (covers both)

**Note:** Most daily work uses just 1-2 agents. The full 10-agent pipeline is for building new systems from scratch.

**Creating your first agent:**

1. Go to claude.ai
2. Click "Projects" → "Create Project"
3. Name it "Frontend Developer" (or "Backend Developer")
4. In **Custom Instructions**, paste:
   ```
   [Copy contents of essential/agents/01-shared-context.md]

   [Copy contents of essential/agents/07-frontend-developer.md]
   (or essential/agents/08-backend-developer.md for backend)
   ```
5. Click "Save"

**Done!** You now have one working agent.

### Step 2: Create Your Project Brief (10 minutes)

The project brief tells your agent about your specific project. Copy `essential/agents/02-project-brief-template.md` and fill it out:

```markdown
# PROJECT BRIEF — [Your Project Name]

## Active Projects
**Project:** [Name]
**Type:** [Next.js / Python / Docker / Other]
**Location:** /path/to/your/project
**Status:** [Just started / In progress / Debugging]

## Tech Stack
**Frontend:** [e.g., Next.js 15, React 19, Tailwind 4]
**Backend:** [e.g., Flask, PostgreSQL]
**Other:** [e.g., Docker, Redis]

## Current Focus
What you're working on right now:
- [ ] Task 1
- [ ] Task 2

## File Structure
```
project/
├── src/
├── docs/
└── package.json
```

## Recent Changes
- [Date]: Started project
```

Save this as `~/ai-dev-team/project-briefs/my-project.md`

### Step 3: Scaffold Your First Project (10 minutes)

Use the toolkit scripts to create a properly structured project:

```bash
# Make script executable
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Create project interactively
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Follow prompts:
# - Project name: my-dashboard
# - Type: nextjs
# - Path: ~/projects
```

**What this creates:**
- Complete Next.js project with TypeScript + Tailwind
- CLAUDE.md with coding rules
- STATUS.md for tracking state
- docs/PRD.md and docs/TECH_SPEC.md templates
- Git initialized with main + develop branches
- .claude/hooks/ with automated safeguards

### Step 4: Enable Skills (Optional — 5 minutes)

**New in v4.0:** Skills handle quick tasks (Docker errors, git mistakes, deployments) without opening agent Projects.

**Recommended starter skills (choose 3-5):**
- docker-debugger — Fix port conflicts, container errors
- git-recovery — Undo commits, recover deleted files
- vercel-deployer — Deploy to Vercel
- next-api-scaffold — Create API routes quickly
- build-error-fixer — Fix compilation errors

**To enable:**
1. Navigate to `skills/` directory in the framework
2. Zip each skill folder: 
   ```bash
   cd skills/emergency/docker-debugger
   zip -r docker-debugger.zip .
   cd ../../..
   ```
3. Upload to Claude.ai: Settings → Capabilities → Skills → Upload Skill
4. Toggle skill ON

**See `essential/guides/SKILLS.md` for complete guide.**

**When to use:** Skills auto-trigger when you mention their keywords. Say "Docker error" and docker-debugger loads automatically. No agent needed.

### Step 5: Have Your First Conversation (5 minutes)

1. Open your agent's Claude Project
2. Paste your project brief at the start
3. Ask the agent to help:

```
[Paste project brief]

I've just scaffolded a new Next.js dashboard project. 
Let's create the PRD — ask me at least 10 questions before writing anything.
```

The agent will interview you about your project and help create a proper PRD.

---

## What You've Accomplished

After 30 minutes:

✅ One working agent (Frontend or Backend Developer)
✅ A project brief for your work
✅ A properly scaffolded project with all standard files
✅ Your first AI-assisted conversation

---

## Next Steps (Pick Your Path)

### Path A: Start Building Immediately

**If you're ready to code:**

1. Follow the agent's PRD questions
2. Review and refine the PRD
3. Ask agent to create TECH_SPEC.md
4. Start building your first feature

**Time:** 2-4 hours to your first working feature

### Path B: Learn the Full System

**If you want to understand everything:**

1. Read `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — How it all fits together
2. Follow `essential/guides/FIRST_PROJECT.md` — Guided 2-hour tutorial
3. Set up your agents using `essential/agents/README.md` (start with 4-5 core agents, expand to 10 for full pipeline)
4. Review `essential/guides/PITFALLS.md` — Common mistakes to avoid

**Time:** 4-6 hours to full system mastery

### Path C: Optimize Costs First

**If you're cost-conscious:**

1. Read `advanced/guides/PROMPT_CACHING.md` — Save 90% on API costs
2. Review `essential/guides/COSTS.md` — Understand monthly expenses
3. Set spending limits at console.anthropic.com
4. Then start building

**Time:** 1 hour to understand and implement savings

---

## Common First-Time Questions

**Q: Do I need all 10 agents?**
A: No. Start with 1-2 developer agents (Frontend and/or Backend). Most daily coding uses just these core agents. Add others as projects grow: Designer for UI-heavy work, Security Auditor for DeFi/sensitive apps, DevOps for deployment automation. The full 10-agent pipeline is for building complete systems from scratch.

**Q: When should I use the Designer agent?**
A: For user-facing applications where visual consistency matters. Skip it for internal tools, APIs, or quick prototypes.

**Q: What if I already have a project?**
A: Use `essential/toolkit/adopt-project.sh` instead of `create-project.sh`. It adds the framework without overwriting your files.

**Q: Where do I paste the project brief?**
A: At the start of every new conversation with any agent. Think of it as saying "here's what we're working on."

**Q: Can I use this without Claude Code CLI?**
A: Yes. The agent Projects work standalone. Claude Code CLI is optional but powerful for direct code execution.

**Q: How much does this cost?**
A: Claude Pro: $20/month (flat). API usage: $20-100/month depending on how much you build. See `essential/guides/COSTS.md` for details.

**Q: I'm not a developer. Will this work for me?**
A: Yes! Start with `essential/guides/DAY_ZERO.md` to learn terminal basics, then follow this quick start. The agents write all the code.

---

## Troubleshooting Your First Hour

**Problem: "Agent isn't following the project brief"**
- Solution: Make sure you pasted the brief at the START of the conversation, before your first question.

**Problem: "Agent is asking for files I don't have"**
- Solution: You're in HANDOFF MODE by accident. Just say "I want to work directly, no handoff" and proceed.

**Problem: "I don't know what to ask the agent"**
- Solution: Start with: "Let's create a PRD for [your project idea]. Ask me questions to understand what I'm building."

**Problem: "The scaffolding script failed"**
- Solution: Check you have write permissions in the target directory. Try: `mkdir ~/projects && chmod +x create-project.sh`

**Problem: "I'm overwhelmed by all the guides"**
- Solution: Ignore everything except this Quick Start for now. Build something. Read guides when you hit problems.

---

## Your 30-Day Roadmap

**Week 1: Build your first feature**
- Days 1-2: Setup (this guide)
- Days 3-5: Create PRD and TECH_SPEC
- Days 6-7: Build first feature with agent

**Week 2: Expand capabilities**
- Add second agent if needed (Backend if you started Frontend, or vice versa)
- Set up Project Knowledge (upload key docs)
- Implement prompt caching for cost savings

**Week 3: Polish workflow**
- Add specialized agents as needed (Designer, System Tester, Security Auditor)
- Follow FIRST_PROJECT.md tutorial end-to-end
- Review and adopt best practices from ARCHITECTURE_BLUEPRINT.md

**Week 4: Advanced features**
- Implement batch processing for evaluations
- Set up mini PC for dedicated dev environment (optional)
- Create custom hooks for your workflow

**By Day 30:** You'll have a complete AI-assisted development workflow with 2-4 core agents for daily work (expandable to 10 for full system builds), cost-optimized API usage, and 2-3 working projects.

---

## Essential Commands Cheatsheet

```bash
# Create new project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# Add framework to existing project
cd /path/to/project && $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh

# Make scripts executable
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/*.sh

# Check Claude Code installation
claude --version

# Start Claude Code in project
cd /path/to/project && claude

# Set API key
export ANTHROPIC_API_KEY=your_key_here

# One-shot command
claude "fix the typo in line 42 of app/page.tsx"
```

---

## Get Help

**Read first:**
- Specific error? → `essential/guides/TROUBLESHOOTING.md`
- Don't understand a term? → `essential/guides/DAY_ZERO.md`
- Cost questions? → `essential/guides/COSTS.md`

**Still stuck?**
- Check API limits: console.anthropic.com/settings/limits
- Review agent setup: `essential/agents/README.md`
- Look for similar issues: `essential/guides/PITFALLS.md`

---

## Remember

**You don't need to understand everything to start.** 

The framework is designed so you can:
1. Set up one agent (5 min)
2. Scaffold a project (10 min)
3. Start building (immediately)

Everything else — the full 10-agent pipeline, advanced optimization, mini PC setup — you can learn as you go.

**Start simple. Build something. Expand when needed.**

---

## What's Next?

After your first successful project:

- [ ] Read `essential/guides/FIRST_PROJECT.md` — Comprehensive tutorial
- [ ] Set up remaining agents from `essential/agents/README.md`
- [ ] Implement cost optimization (`advanced/guides/PROMPT_CACHING.md`)
- [ ] Upload docs to Project Knowledge (`advanced/guides/RAG_PROJECT_KNOWLEDGE.md`)
- [ ] Review `advanced/guides/ARCHITECTURE_BLUEPRINT.md` for best practices
- [ ] Consider setting up mini PC (`advanced/infrastructure/SETUP_START.md`)

**Most important:** Keep building. The best way to learn this system is by using it.
