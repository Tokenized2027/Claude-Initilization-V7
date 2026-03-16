# Claude Code Initialization Kit (V7)

A complete starter framework for building software with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's CLI for AI-assisted development.

Designed for **vibe coders**: people who build through AI, not by writing code manually.

## Quick Start (Mac)

```bash
# 1. Clone this repo
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git ~/Desktop/Claude
cd ~/Desktop/Claude

# 2. Run the setup script (installs Homebrew, Node.js, Git, Claude Code CLI)
chmod +x setup-mac.sh
./setup-mac.sh

# 3. Set CLAUDE_HOME in your shell profile
echo 'export CLAUDE_HOME="$HOME/Desktop/Claude"' >> ~/.zshrc
source ~/.zshrc

# 4. Copy settings + install hooks (gives Claude memory across sessions)
mkdir -p ~/.claude
cp dot-claude/settings.json ~/.claude/settings.json
chmod +x hooks/install-hooks.sh
./hooks/install-hooks.sh

# 5. Set up persistent memory
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp memory/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
# Edit MEMORY.md with your info — this is how Claude remembers you

# 6. Start your first project
mkdir -p ~/projects/my-app && cd ~/projects/my-app && git init
cp $CLAUDE_HOME/examples/CLAUDE.md ./CLAUDE.md
claude
```

## What's Inside

```
├── setup-mac.sh                     ← One-command Mac setup
├── START_HERE.md                    ← Decision tree — what to do today
├── YOUR_WORKING_PROFILE.md          ← Template: how Claude should work with you
│
├── hooks/                           ← ⭐ NEW: Automatic context injection
│   ├── session-recall.py            ← Memory across sessions (the killer hook)
│   ├── install-hooks.sh             ← One-command hook installer
│   └── README.md                    ← How hooks work + how to build your own
│
├── memory/                          ← ⭐ UPGRADED: Three-tier memory system
│   ├── MEMORY.md                    ← Template: what Claude remembers (200-line index)
│   ├── guidelines.md                ← What to save, what to skip, how to organize
│   ├── patterns.md.template         ← Mistake tracking with hit dates
│   ├── pending.md.template          ← Transient state (blockers, in-progress)
│   ├── SESSION_MEMORY.md            ← Guide: maintaining CLAUDE.md over time
│   └── SESSION_CONTINUITY.md        ← Guide: resume mid-task across sessions
│
├── examples/                        ← CLAUDE.md examples
│   ├── CLAUDE.md                    ← Blank template for any project
│   └── todo-app/CLAUDE.md           ← Filled-in example
│
├── dot-claude/                      ← Claude Code settings
│   └── settings.json                ← Permissions + hook configuration
│
├── claude-code-framework/           ← Core framework
│   ├── QUICK_START.md               ← 30-minute setup guide
│   ├── DAILY_REFERENCE.md           ← Command cheatsheet
│   ├── essential/
│   │   ├── agents/                  ← 13 AI agent templates
│   │   ├── guides/                  ← 10 how-to guides
│   │   ├── skills/                  ← 28 automation skills
│   │   └── toolkit/                 ← Setup scripts + templates + safety hooks
│   └── advanced/
│       ├── guides/                  ← Architecture, caching, MCP, team mode
│       └── infrastructure/          ← Mini PC / server setup
│
├── multi-agent-system/              ← Autonomous AI agent orchestration
│   ├── orchestrator/                ← FastAPI task router
│   ├── agent-templates/             ← 15 specialized agents
│   ├── mcp-servers/                 ← Memory + context servers
│   └── deployment/                  ← One-command installer
│
├── telegram-bot/                    ← Mobile remote control for Claude
├── whisper-service/                 ← Speech-to-text API (Docker)
├── project-contexts/                ← Project documentation templates
└── templates/                       ← Docker + boilerplate templates
```

## Key Concepts

### Hooks — Give Claude Memory Across Sessions

The `hooks/` directory contains the single most impactful upgrade you can make to Claude Code. When you start a session, the **session recall hook** automatically injects summaries of your last 48 hours of work:

```
Recent sessions:
- Mar 14 04:37 | fix auth middleware for API routes | last action: PR is open
- Mar 14 02:15 | debug Docker port conflict | last action: Fixed, runs on port 3001
- Mar 13 22:30 | add price chart to dashboard | last action: Committed
```

Claude instantly knows what you were doing yesterday. No re-explaining. See `hooks/README.md` for setup and configuration.

### Three-Tier Memory System

Not all memory is equal. This kit organizes it by access frequency:

| Tier | What | Access |
|------|------|--------|
| **Hot** | `CLAUDE.md` + `MEMORY.md` | Every session, automatically |
| **Warm** | `patterns.md` + `pending.md` + topic files | On demand, when relevant |
| **Cold** | `knowledge-base/` + git history | Retrieved when needed |

**Hot memory** is always loaded — keep it dense and under its line limit. When it grows, extract details to warm storage and leave a pointer. See `memory/guidelines.md` for the full system.

### CLAUDE.md

A file in your project root that Claude reads automatically at the start of every session. It tells Claude your project's rules, tech stack, structure, and conventions. **This is the single highest-leverage file in Claude Code.**

The key to a good CLAUDE.md is maintenance — update it after every meaningful session. See `memory/SESSION_MEMORY.md` for the maintenance guide and `examples/` for templates.

### Agents

Predefined role prompts (frontend developer, backend developer, security auditor, etc.) that give Claude specialized behavior for different tasks. See `claude-code-framework/essential/agents/`.

### Skills

Reusable task automations — git recovery, Docker debugging, build error fixing, API scaffolding, and more. See `claude-code-framework/essential/skills/`.

## Guides

| I want to... | Read this |
|---|---|
| Get started from zero | `claude-code-framework/essential/guides/DAY_ZERO.md` |
| Build my first project | `claude-code-framework/essential/guides/FIRST_PROJECT.md` |
| Learn daily workflow | `claude-code-framework/essential/guides/DAILY_WORKFLOW.md` |
| Set up hooks (session memory) | `hooks/README.md` |
| Understand the memory system | `memory/guidelines.md` |
| Maintain CLAUDE.md over time | `memory/SESSION_MEMORY.md` |
| Resume work across sessions | `memory/SESSION_CONTINUITY.md` |
| Recover from git disasters | `claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md` |
| Fix something that broke | `claude-code-framework/essential/guides/TROUBLESHOOTING.md` |
| Save money on API costs | `claude-code-framework/advanced/guides/PROMPT_CACHING.md` |
| Set up a mini PC / server | `claude-code-framework/advanced/infrastructure/README.md` |
| Deploy multi-agent system | `multi-agent-system/docs/DEPLOYMENT_GUIDE.md` |

## Requirements

- **macOS** (setup script is Mac-specific; framework files work on any OS)
- **Python 3.9+** (for session recall hook — stdlib only, no pip install needed)
- **Claude subscription** (Pro or Max) or Anthropic API key
- **Terminal basics** (cd, ls, git — see `DAY_ZERO.md` if new)

## License

MIT
