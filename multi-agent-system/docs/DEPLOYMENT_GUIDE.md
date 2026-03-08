# Deployment Guide — Multi-Agent System

**When:** Run this when your mini PC arrives.
**Time:** 15-20 minutes total.
**Result:** Fully autonomous multi-agent AI system.

---

## Prerequisites

### Hardware
- Mini PC with Linux (Ubuntu 22.04+ recommended)
- 16GB RAM minimum (32GB preferred)
- 256GB+ SSD
- Stable internet connection

### Software (Install on Mini PC)
```bash
# Node.js 18+ (use nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20

# Python 3.10+
sudo apt update && sudo apt install -y python3 python3-pip python3-venv

# Git
sudo apt install -y git

# Claude Code CLI
npm install -g @anthropic-ai/claude-code
```

### Accounts & Keys
- Anthropic API key (from console.anthropic.com)
- SSH access to mini PC (Tailscale recommended)

---

## Installation

### Step 1: Transfer Files to Mini PC (5 min)

```bash
# From your Windows machine, SCP the folder:
scp -r "$CLAUDE_HOME/multi-agent-system" user@your-server:~/

# Or git clone if you've pushed to a repo:
ssh user@your-server
git clone <your-repo> ~/multi-agent-system
```

### Step 2: Transfer Claude Resources (2 min)

The context router needs your profile and project context files. On Linux, these go to `~/Claude/` by default (not `$CLAUDE_HOME/`).

```bash
# Create the resources directory on the mini PC
ssh user@your-server "mkdir -p ~/Claude"

# Transfer context files
scp -r "$CLAUDE_HOME/project-contexts" user@your-server:~/Claude/
scp "$CLAUDE_HOME/YOUR_WORKING_PROFILE.md" user@your-server:~/Claude/
scp "$CLAUDE_HOME/YOUR_PROJECT_WORKFLOW.md" user@your-server:~/Claude/
```

> **Custom path?** Set `CLAUDE_RESOURCES_DIR` before running install.sh:
> ```bash
> export CLAUDE_RESOURCES_DIR=/path/to/your/claude/resources
> ```

### Step 3: Install Skills Globally (1 min)

Skills auto-load into every Claude Code session (including spawned sub-agents). Copy them to the global skills directory:

```bash
ssh user@your-server
mkdir -p ~/.claude/skills
cp -r ~/Claude/claude-code-framework/essential/skills/* ~/.claude/skills/
```

Verification: `ls ~/.claude/skills/` shows 9 directories (workflow, development, operations, defi, business, emergency, scaffolding, deployment, quality). Run `find ~/.claude/skills -name "SKILL.md" | wc -l` — should return 28.

> **Why this matters:** When Claude Code starts a session (or spawns a sub-agent), it reads all SKILL.md files from `~/.claude/skills/`. The `description` field in each skill contains trigger phrases. Claude Code automatically activates matching skills based on what you ask — you never need to say "use the debugging skill." You just say "this API is broken" and systematic-debugging kicks in.

### Step 4: Run Installer (5 min)

```bash
ssh user@your-server
cd ~/multi-agent-system                 # source location from Step 1
chmod +x deployment/install.sh
bash deployment/install.sh              # installs to ~/claude-multi-agent/
```

The installer:
- Checks prerequisites (Node, Python, Claude CLI)
- Creates memory directories
- Installs and builds MCP servers
- Sets up Python virtual environment for orchestrator
- Configures MCP in `~/.claude/mcp.json`
- Creates systemd service for orchestrator
- Verifies installation

### Step 5: Configure API Key (1 min)

```bash
nano ~/claude-multi-agent/orchestrator/.env
# Set: ANTHROPIC_API_KEY=sk-ant-api03-YOUR_REAL_KEY_HERE
```

### Step 6: Start the System (1 min)

```bash
# Start orchestrator
sudo systemctl start claude-orchestrator

# Verify it's running
curl http://localhost:8000/health
```

### Step 7: Run Tests (2 min)

```bash
bash ~/claude-multi-agent/tests/test-system.sh
```

All tests should pass. Warnings are OK (they indicate optional features).

---

## Verify Everything Works

### Quick Smoke Test

```bash
# Health check
curl http://localhost:8000/health

# Submit a simple task
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d '{"task": "Create a simple hello world page", "project": "smoke-test"}'

# Check status
curl http://localhost:8000/status/smoke-test

# View running tasks
curl http://localhost:8000/tasks
```

### Full API Test

```bash
bash ~/claude-multi-agent/tests/test-orchestrator-api.sh
```

### Memory System Test

```bash
# Start Claude Code with MCP servers active
claude

# In Claude Code, try:
# "Use store_memory to save a test memory"
# "Use recall_memory to get it back"
# "Use get_project_state for project test"
```

---

## Daily Usage

### Submit Tasks

```bash
# Dashboard task
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d '{"task": "Build project price dashboard with 7-day chart", "project": "my-app"}'

# Content task
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d '{"task": "Draft tweet about new product APY increase", "project": "project-content"}'

# API task
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d '{"task": "Create API endpoint for project price history", "project": "my-app"}'
```

### Check Status

```bash
# Project status
curl http://localhost:8000/status/my-app

# All projects
curl http://localhost:8000/projects

# Running tasks
curl http://localhost:8000/tasks

# Handoffs for a project
curl http://localhost:8000/handoffs/my-app

# Recent memories
curl http://localhost:8000/memories/my-app
```

### Monitor Logs

```bash
# Orchestrator logs
sudo journalctl -u claude-orchestrator -f

# Agent execution logs
ls ~/claude-memory/projects/my-app/logs/
cat ~/claude-memory/projects/my-app/logs/latest.json
```

---

## Using Claude Code with MCP

When you open Claude Code on the mini PC, the MCP servers are automatically available:

```bash
cd /path/to/project
claude
```

Claude Code now has access to:

**Memory tools:**
- `store_memory` — Save decisions, outputs, context
- `recall_memory` — Retrieve past memories
- `get_project_state` — Check project status
- `update_project_state` — Update project status
- `search_memories` — Search across all memories
- `create_agent_handoff` — Pass work to another agent
- `get_agent_handoff` — Check for pending work

**Context tools:**
- `auto_load_context` — Auto-detect task type and load docs
- `load_working_profile` — Load YOUR_WORKING_PROFILE.md
- `load_project_context` — Load specific Project files
- `list_context_types` — See all available context types

---

## Remote Access (From Anywhere)

### Option 1: Telegram Bot (Recommended)

Message your bot on Telegram from any device — phone, tablet, laptop:

```
/health          → orchestrator health check
/task my-app Build price dashboard → submit task
/system          → CPU, RAM, disk status
/docker          → container status
/sh uptime       → run any shell command
```

Setup: See `telegram-bot/WEBHOOK_SETUP.md` and Phase 4.5 of the infrastructure setup.

### Option 2: SSH + curl

```bash
# From your Windows machine
ssh user@your-server "curl -s http://localhost:8000/health"

# Submit task remotely
ssh user@your-server 'curl -s -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d "{\"task\": \"Build dashboard\", \"project\": \"my-project\"}"'
```

### Option 2: Tailscale Direct Access

If Tailscale is set up:

```bash
# Direct from Windows
curl http://your-server:8000/health
curl -X POST http://your-server:8000/route -H "Content-Type: application/json" -d '{"task": "...", "project": "..."}'
```

### Option 3: Create a Shortcut Script

```bash
# Save as ~/submit-task.sh on mini PC
#!/bin/bash
curl -X POST http://localhost:8000/route \
  -H "Content-Type: application/json" \
  -d "{\"task\": \"$1\", \"project\": \"$2\"}"

# Usage:
# bash submit-task.sh "Build project dashboard" "my-app"
```

---

## Troubleshooting

### Orchestrator Won't Start

```bash
# Check logs
sudo journalctl -u claude-orchestrator --no-pager -n 50

# Common fixes:
# 1. Missing .env
cp ~/claude-multi-agent/orchestrator/.env.example ~/claude-multi-agent/orchestrator/.env
nano ~/claude-multi-agent/orchestrator/.env

# 2. Port in use
lsof -i :8000
kill -9 <PID>

# 3. Python venv issues
cd ~/claude-multi-agent/orchestrator
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### MCP Servers Not Working

```bash
# Check MCP config
cat ~/.claude/mcp.json

# Test memory server directly
node ~/claude-multi-agent/mcp-servers/memory-server/dist/index.js

# Rebuild
cd ~/claude-multi-agent/mcp-servers/memory-server
npm run build
```

### Agent Spawning Fails

```bash
# Check Claude CLI
claude --version

# Check API key
echo $ANTHROPIC_API_KEY

# Test Claude directly
echo "Say hello" | claude --print

# Check agent template exists
ls ~/claude-multi-agent/agent-templates/
```

### Memory Not Persisting

```bash
# Check directory permissions
ls -la ~/claude-memory/
ls -la ~/claude-memory/projects/

# Check disk space
df -h

# Manual test: write and read
echo '{"test": true}' > ~/claude-memory/shared/test.json
cat ~/claude-memory/shared/test.json
rm ~/claude-memory/shared/test.json
```

---

## Maintenance

### Backup Memory

```bash
# Backup all memory data
tar -czf ~/claude-memory-backup-$(date +%Y%m%d).tar.gz ~/claude-memory/

# Restore
tar -xzf ~/claude-memory-backup-YYYYMMDD.tar.gz -C ~/
```

### Update the System

```bash
# Pull latest source code
cd ~/multi-agent-system
git pull

# Re-run installer (updates ~/claude-multi-agent/ from source)
bash deployment/install.sh
```

### Clean Old Data

```bash
# Remove completed project data older than 30 days
find ~/claude-memory/projects/*/logs -type f -mtime +30 -delete

# Remove old handoffs
find ~/claude-memory/projects/*/handoffs -type f -mtime +7 -delete
```

### Monitor Resources

```bash
# Check memory usage
free -h

# Check disk usage
du -sh ~/claude-memory/

# Check orchestrator process
systemctl status claude-orchestrator
```

---

## Architecture Reference

```
Mini PC
├── ~/claude-multi-agent/            (Installation)
│   ├── mcp-servers/
│   │   ├── memory-server/          (Persistent memory)
│   │   └── context-router/         (Auto-context loading)
│   ├── orchestrator/               (Task routing & coordination)
│   ├── agent-templates/            (14 agent prompts + memory protocol)
│   └── tests/                      (Verification scripts)
│
├── ~/claude-memory/                 (Persistent data)
│   ├── projects/
│   │   └── <project-name>/
│   │       ├── _state.json         (Project status)
│   │       ├── memories/           (Agent memories)
│   │       ├── handoffs/           (Agent coordination)
│   │       └── logs/               (Execution logs)
│   ├── agents/                     (Agent-specific data)
│   └── shared/                     (Cross-project memories)
│
├── ~/Claude/                        (Context files — configurable via CLAUDE_RESOURCES_DIR)
│   ├── YOUR_WORKING_PROFILE.md
│   ├── YOUR_PROJECT_WORKFLOW.md
│   └── project-contexts/
│       └── project/
│
└── ~/.claude/                       (Claude Code config)
    ├── mcp.json                     (MCP server config)
    └── skills/                      (28 auto-loaded skills)
        ├── workflow/                (brainstorming, debugging, prompting)
        ├── development/             (react, typescript, api patterns)
        ├── operations/              (cost control, observability)
        ├── defi/                    (analytics, governance writing)
        ├── business/                (SEO, Stripe, client onboarding)
        ├── emergency/               (docker, git, build, env, deps)
        ├── scaffolding/             (API, component, auth, DB, test)
        ├── deployment/              (Vercel, Docker Compose, GH Actions)
        └── quality/                 (security, accessibility)
```

---

## What Happens When You Submit a Task

1. **POST /route** → Orchestrator receives task
2. **Task Detection** → Keywords matched to task type
3. **Agent Selection** → Task type mapped to agent
4. **Context Loading** → Auto-load relevant docs via MCP
5. **Agent Spawn** → Claude CLI process with full context + 28 skills auto-loaded from ~/.claude/skills/
6. **Skill Matching** → Claude Code activates relevant skills based on task (e.g. react-patterns for UI work, systematic-debugging for errors)
7. **Execution** → Agent works, stores memories, checks handoffs
8. **Handoff** → If needed, creates handoff to next agent
9. **Auto-Route** → Orchestrator detects handoff, spawns next agent
10. **Completion** → Project state updated, results stored
11. **GET /status** → You check the result

**Total user interaction:** Answer clarifying questions once. Everything else is autonomous.

---

## Security Notes

- API key stored in `.env` file (not committed to git)
- Orchestrator listens on 127.0.0.1 by default — accessible via Tailscale only
- Telegram bot requires 12-hour password sessions for command access
- Push notifications (agent failures, disk alerts) bypass auth for timely delivery
- Memory data is stored as plain JSON files — encrypt if storing sensitive data
- Agent processes run with your user permissions — not root
- MCP servers run via stdio, not network — no exposed ports

---

## Cost Considerations

Each agent spawn = one Claude API call. Typical costs:

| Task Type | Agents Spawned | Estimated Cost |
|-----------|---------------|----------------|
| Simple bug fix | 1 | $0.05-0.15 |
| New feature | 2-3 | $0.20-0.50 |
| Full dashboard | 3-5 | $0.50-1.50 |
| Content creation | 1 | $0.03-0.10 |
| Full system build | 5-10 | $1.00-3.00 |

**Monthly estimate:** $30-100 depending on usage volume.

---

## Next Steps After Deployment

1. **Test with a real task** — Submit something you need built
2. **Review agent outputs** — Check quality and adjust templates
3. **Tune context mappings** — Add keywords for your common tasks
4. **Set up monitoring** — Add uptime checks, log rotation
5. **Create shortcuts** — Bash aliases for common submissions
6. **Backup schedule** — Cron job for memory backup

---

**Your autonomous AI development team is ready.** Submit a task and let the agents work. 🚀
