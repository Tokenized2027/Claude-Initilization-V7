# Claude Code Initialization Kit

Build software with AI. No coding experience required.

You clone this repo, follow the setup, and walk away with a fully configured Claude Code environment: persistent memory across sessions, specialized AI agents, automation skills, and optionally a 24/7 autonomous agent system you control from your phone.

**Free. Open source. No workshop needed.**

> **[מדריך בעברית](README.he.md)** | Hebrew guide available

## What You Need

### Hardware

| Item | Details |
|------|---------|
| Computer | Mac, Windows, or Linux. 16GB RAM minimum. |
| Phone (optional) | For Telegram remote control. Any phone works. |

### Accounts and Licenses

| Item | Cost | Notes |
|------|------|-------|
| **Claude Code** | $20/mo (Pro) or $100/mo (Max) | Your AI coding partner. Get it at [claude.ai](https://claude.ai) |
| **GitHub account** | Free | For cloning this repo and managing projects. [github.com](https://github.com) |
| **OpenAI API Key** (optional) | ~$5-10/mo | For voice transcription (Whisper). [platform.openai.com](https://platform.openai.com) |
| **Google Cloud project** (optional) | Free | For calendar/email integrations. [console.cloud.google.com](https://console.cloud.google.com) |

### Total Monthly Cost

| Setup | Cost |
|-------|------|
| Basic (Claude Pro only) | ~$20/month |
| Full (Claude Max + OpenAI + VPS) | ~$120/month |

## Setup (10 Minutes)

### Mac

```bash
# 1. Clone
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git ~/Desktop/Claude
cd ~/Desktop/Claude

# 2. Run setup (installs Homebrew, Node.js, Git, Claude Code CLI)
chmod +x setup-mac.sh && ./setup-mac.sh

# 3. Set CLAUDE_HOME so you can reference this folder from anywhere
echo 'export CLAUDE_HOME="$HOME/Desktop/Claude"' >> ~/.zshrc && source ~/.zshrc

# 4. Install hooks + settings (gives Claude memory across sessions)
mkdir -p ~/.claude
cp dot-claude/settings.json ~/.claude/settings.json
chmod +x hooks/install-hooks.sh && ./hooks/install-hooks.sh

# 5. Set up persistent memory
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp memory/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
```

### Windows

```powershell
# 1. Install prerequisites (if you don't have them)
# Node.js v20+: https://nodejs.org
# Git: https://git-scm.com/download/win
# Claude Code CLI: npm install -g @anthropic-ai/claude-code

# 2. Clone
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git %USERPROFILE%\Desktop\Claude
cd %USERPROFILE%\Desktop\Claude

# 3. Copy settings
mkdir %USERPROFILE%\.claude 2>nul
copy dot-claude\settings.json %USERPROFILE%\.claude\settings.json

# 4. Set up persistent memory
mkdir %USERPROFILE%\.claude\projects 2>nul
copy memory\MEMORY.md %USERPROFILE%\.claude\projects\memory\MEMORY.md
```

### Linux

```bash
# 1. Install prerequisites
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs git
npm install -g @anthropic-ai/claude-code

# 2. Clone
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git ~/Claude
cd ~/Claude

# 3. Same as Mac steps 3-5
```

### Start Your First Project

```bash
mkdir -p ~/projects/my-app && cd ~/projects/my-app && git init
cp $CLAUDE_HOME/examples/CLAUDE.md ./CLAUDE.md    # copy the template
# Edit CLAUDE.md with your project details, then:
claude
```

That's it. You're running.

## What You Get

### The Essentials (use these from day one)

| Component | What It Does |
|-----------|-------------|
| **Session Recall Hook** | Claude automatically remembers your last 48 hours of work when you start a new session. No re-explaining. |
| **CLAUDE.md Templates** | Drop a CLAUDE.md file in any project to tell Claude your rules, stack, and conventions. It reads this automatically. |
| **Three-Tier Memory** | Hot (always loaded), Warm (on demand), Cold (git history). Keeps Claude's context organized without hitting limits. |
| **YOUR_WORKING_PROFILE.md** | A template defining how Claude should communicate with you, deliver code, handle errors. Fill it once, use everywhere. |

### The Framework (use when you're comfortable)

| Component | What It Does |
|-----------|-------------|
| **13 Agent Templates** | Specialized roles: Frontend Dev, Backend Dev, Security Auditor, Product Manager, and more. Give Claude expert behavior for specific tasks. |
| **28 Automation Skills** | Repeatable tasks: git recovery, Docker debugging, build error fixing, API scaffolding, security scanning, SEO audits. |
| **Safety Hooks** | Branch protection, dangerous command blocking, secret detection, auto-formatting. Prevents costly mistakes. |
| **Project Templates** | CLAUDE.md, PRD, Sprint, Status, Tech Spec templates. Start any project with structure. |

### The Autonomous System (advanced, optional)

| Component | What It Does |
|-----------|-------------|
| **Multi-Agent Orchestrator** | FastAPI server that routes tasks to specialized agents. Submit a task, agents coordinate, you get results. |
| **Telegram Bot** | Control everything from your phone. Voice commands, push notifications, slash commands. |
| **Whisper Service** | Speech-to-text in a Docker container. Send voice messages, get text back. |
| **Mini PC Infrastructure** | Full guide to set up a dedicated always-on server running your AI agent system 24/7. |

## How It All Fits Together

```
You (laptop/phone)
    |
    +-- claude (CLI)           -> Direct coding with Claude Code + memory + hooks
    |
    +-- Telegram Bot (phone)   -> Voice/text commands -> Orchestrator -> Agents
    |
    +-- Cursor IDE (laptop)    -> Visual editing, connected to your server via SSH
            |
            +-- Mini PC / VPS (always-on server)
                    +-- Orchestrator (routes tasks)
                    +-- 14 Agent Templates (do the work)
                    +-- MCP Servers (memory + context)
                    +-- Whisper (voice-to-text)
```

## Guides

| I want to... | Read this |
|---|---|
| **Learn terminal basics** | `claude-code-framework/essential/guides/DAY_ZERO.md` |
| **Build my first project** | `claude-code-framework/essential/guides/FIRST_PROJECT.md` |
| **Understand daily workflow** | `claude-code-framework/essential/guides/DAILY_WORKFLOW.md` |
| **Set up hooks (session memory)** | `hooks/README.md` |
| **Understand the memory system** | `memory/guidelines.md` |
| **Learn Git as a non-coder** | `claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md` |
| **Avoid common mistakes** | `claude-code-framework/essential/guides/PITFALLS.md` |
| **Fix something that broke** | `claude-code-framework/essential/guides/TROUBLESHOOTING.md` |
| **Save money on API costs** | `claude-code-framework/advanced/guides/PROMPT_CACHING.md` |
| **Set up a 24/7 server** | `claude-code-framework/advanced/infrastructure/README.md` |
| **Deploy the agent system** | `multi-agent-system/docs/DEPLOYMENT_GUIDE.md` |

## Folder Structure

```
+-- setup-mac.sh                    <- One-command Mac setup
+-- YOUR_WORKING_PROFILE.md         <- Template: how Claude should work with you
+-- hooks/                          <- Session recall + safety hooks
+-- memory/                         <- Three-tier memory system + templates
+-- examples/                       <- CLAUDE.md templates (blank + filled)
+-- dot-claude/                     <- Claude Code settings.json
+-- claude-code-framework/
|   +-- essential/
|   |   +-- agents/                 <- 13 agent role templates
|   |   +-- guides/                 <- 10 how-to guides
|   |   +-- skills/                 <- 28 automation skills
|   |   +-- toolkit/                <- Scripts + project templates
|   +-- advanced/
|       +-- guides/                 <- Caching, MCP, team mode, architecture
|       +-- infrastructure/         <- Mini PC / server setup (6 phases)
+-- multi-agent-system/             <- Autonomous orchestrator + 14 agents + MCP servers
+-- telegram-bot/                   <- Phone remote control
+-- whisper-service/                <- Speech-to-text Docker container
+-- project-contexts/               <- Per-project documentation templates
+-- templates/                      <- Docker + boilerplate
```

## FAQ

**Do I need to know how to code?**
No. Basic comfort with a terminal helps (cd, ls, copy-paste commands), but that's it. The `DAY_ZERO.md` guide covers everything you need.

**What's a CLAUDE.md file?**
A file you put in your project root that Claude reads automatically at the start of every session. It tells Claude your project's rules, tech stack, and conventions. It's the single highest-leverage file in Claude Code.

**What are hooks?**
Scripts that run automatically at specific moments (session start, before/after tool use, session end). The session recall hook is the most impactful: it injects summaries of your last 48 hours so Claude knows what you were doing without you re-explaining.

**Mac only?**
The setup script is Mac-specific, but all the framework files (CLAUDE.md templates, agents, skills, memory system, hooks) work on any OS. Windows and Linux users just install the prerequisites manually.

**How much does it cost to run monthly?**
Claude Pro ($20) is the minimum. Claude Max ($100) + OpenAI API (~$10) + VPS (~$15) for the full autonomous setup runs about $120/month.

**What's the difference between agents and skills?**
Agents are role prompts that change how Claude behaves (think: "you are a security auditor"). Skills are step-by-step task automations (think: "recover my git repo"). Agents shape thinking, skills shape doing.

## Checklist

- [ ] Computer with 16GB+ RAM
- [ ] Claude Pro or Max subscription (active)
- [ ] Node.js v20+ installed
- [ ] Git installed
- [ ] GitHub account
- [ ] Claude Code CLI installed (`npm install -g @anthropic-ai/claude-code`)
- [ ] This repo cloned
- [ ] Settings copied to `~/.claude/`
- [ ] Hooks installed
- [ ] MEMORY.md set up with your info
- [ ] CLAUDE.md added to your first project
- [ ] OpenAI API Key (optional, for voice)
- [ ] Google Cloud project (optional, for calendar/email)
- [ ] Telegram bot created (optional, for phone control)

## License

MIT
