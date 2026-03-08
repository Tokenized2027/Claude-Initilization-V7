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

# 4. Copy settings to Claude's config directory
mkdir -p ~/.claude
cp dot-claude/settings.json ~/.claude/settings.json

# 5. Set up persistent memory (optional but recommended)
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp memory/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
# Edit with your info

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
├── examples/                        ← CLAUDE.md examples
│   ├── CLAUDE.md                    ← Blank template for any project
│   └── todo-app/CLAUDE.md           ← Filled-in example
│
├── memory/                          ← Persistent memory template
│   └── MEMORY.md                    ← Template: what Claude remembers across sessions
│
├── dot-claude/                      ← Claude Code settings
│   └── settings.json                ← Sane defaults for tool permissions
│
├── claude-code-framework/           ← Core framework
│   ├── QUICK_START.md               ← 30-minute setup guide
│   ├── DAILY_REFERENCE.md           ← Command cheatsheet
│   ├── essential/
│   │   ├── agents/                  ← 13 AI agent templates
│   │   ├── guides/                  ← 10 how-to guides
│   │   ├── skills/                  ← 28 automation skills
│   │   └── toolkit/                 ← Setup scripts + templates
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

### CLAUDE.md
A file in your project root that Claude reads automatically at the start of every session. It tells Claude your project's rules, tech stack, structure, and conventions. **This is the single highest-leverage file in Claude Code.** See `examples/` for templates.

### Persistent Memory
Claude can remember things across sessions using memory files stored in `~/.claude/projects/`. Seed it with the template in `memory/MEMORY.md` and update it as you work.

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
| Recover from git disasters | `claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md` |
| Fix something that broke | `claude-code-framework/essential/guides/TROUBLESHOOTING.md` |
| Save money on API costs | `claude-code-framework/advanced/guides/PROMPT_CACHING.md` |
| Set up a mini PC / server | `claude-code-framework/advanced/infrastructure/README.md` |
| Deploy multi-agent system | `multi-agent-system/docs/DEPLOYMENT_GUIDE.md` |

## Requirements

- **macOS** (setup script is Mac-specific; framework files work on any OS)
- **Claude subscription** (Pro or Max) or Anthropic API key
- **Terminal basics** (cd, ls, git — see `DAY_ZERO.md` if new)

## License

MIT
