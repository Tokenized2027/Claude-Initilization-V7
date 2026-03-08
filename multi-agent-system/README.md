# Claude Multi-Agent System

Autonomous AI development system with shared persistent memory, auto-context loading, and agent coordination. Deploy on your mini PC for zero-intervention task execution.

---

## What This Is

Submit a task → agents coordinate autonomously → get results.

```bash
# Submit (include your API key)
curl -X POST http://your-server:8000/route \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" \
  -d '{"task": "Build analytics dashboard", "project": "my-app"}'

# Agents coordinate: frontend builds UI → hands to backend → backend builds API → hands back → done

# Check result
curl -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" http://localhost:8000/status/my-app
```

**Your involvement:** Submit the task. Agents make reasonable defaults and store assumptions as memories for your review. Fully autonomous.

---

## Components

| Component | Status | Location |
|-----------|--------|----------|
| Memory MCP Server | ✅ Complete | `mcp-servers/memory-server/` |
| Context Router MCP Server | ✅ Complete | `mcp-servers/context-router/` |
| Orchestrator Service | ✅ Complete | `orchestrator/` |
| Agent Templates (10) | ✅ Complete | `agent-templates/` |
| Deployment Scripts | ✅ Complete | `deployment/` |
| Test Suite | ✅ Complete | `tests/` |
| Documentation | ✅ Complete | `docs/` |

---

## Quick Start

### When Mini PC Arrives

```bash
# 1. Transfer files to mini PC
scp -r multi-agent-system/ user@your-server:~/

# 2. Run installer (installs to ~/claude-multi-agent/)
ssh user@your-server "bash ~/multi-agent-system/deployment/install.sh"

# 3. Generate API key and add credentials
ssh user@your-server "python3 -c \"import secrets; print(secrets.token_urlsafe(32))\""
# Copy that output, then:
ssh user@your-server "nano ~/claude-multi-agent/orchestrator/.env"
# Set ANTHROPIC_API_KEY and ORCHESTRATOR_API_KEY

# 4. Start
ssh user@your-server "sudo systemctl start claude-orchestrator"

# 5. Test
ssh user@your-server "bash ~/claude-multi-agent/tests/test-system.sh"

# 6. Submit first task (replace YOUR_KEY with ORCHESTRATOR_API_KEY from step 3)
curl -X POST http://your-server:8000/route \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_KEY" \
  -d '{"task": "Hello world dashboard", "project": "test"}'
```

**Full guide:** `docs/DEPLOYMENT_GUIDE.md`

---

## Architecture

```
┌─────────────────────────────────────────────┐
│              Mini PC (Always-On)            │
│                                              │
│  MCP Servers                                │
│  ├── Memory Server (shared persistent state)│
│  └── Context Router (auto-loads right docs) │
│                                              │
│  Orchestrator (port 8000)                   │
│  └── Routes tasks → spawns agents           │
│      └── Manages handoffs between agents    │
│                                              │
│  Memory Storage (~/claude-memory/)          │
│  ├── projects/[name]/                       │
│  │   ├── _state.json                        │
│  │   ├── memories/*.json                    │
│  │   └── handoffs/*.json                    │
│  └── shared/                                │
│                                              │
└──────┬──────────┬──────────┬────────────────┘
       ↓          ↓          ↓
   Frontend   Backend    Content
   Agent      Agent      Agent
```

---

## File Structure

```
multi-agent-system/
├── README.md                        ← You are here
├── BUILD_STATUS.md                  ← Build progress
├── QUICKSTART.md                    ← Quick reference
│
├── mcp-servers/
│   ├── memory-server/               ← Shared persistent memory
│   │   ├── src/index.ts            (700+ lines)
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── README.md
│   │
│   └── context-router/              ← Auto-context loading
│       ├── src/index.ts            (400+ lines)
│       ├── package.json
│       └── tsconfig.json
│
├── orchestrator/                    ← Task routing & coordination
│   ├── orchestrator.py             (350+ lines, FastAPI)
│   ├── requirements.txt
│   └── .env.example
│
├── agent-templates/                 ← 10 memory-aware agents
│   ├── _memory-protocol.md         ← Shared protocol
│   ├── frontend-developer.md
│   ├── backend-developer.md
│   ├── system-architect.md
│   ├── product-manager.md
│   ├── content-creator.md
│   ├── designer.md
│   ├── api-architect.md
│   ├── security-auditor.md
│   ├── system-tester.md
│   └── devops-engineer.md
│
├── deployment/                      ← Setup automation
│   ├── install.sh                  ← One-command installer
│   └── uninstall.sh                ← Clean removal
│
├── tests/                           ← Verification
│   ├── test-system.sh              ← Full system test
│   └── test-orchestrator-api.sh    ← API endpoint tests
│
└── docs/                            ← Documentation
    ├── DEPLOYMENT_GUIDE.md         ← Step-by-step setup
    └── MINI_PC_REQUIREMENTS.md     ← Hardware/software needs
```

---

## Key Features

### Budget Controls (NEW in v1.2.0)
Per-project and daily spend limits prevent runaway API costs.
Orchestrator blocks agent spawns when limits are hit.
Check with `GET /spend`, reset with `POST /spend/reset-project/{name}`.

### Weighted Keyword Routing (NEW in v1.2.0)
Domain-specific terms like "docker" or "slurp" carry more weight than generic
terms like "fix" or "broken", preventing misroutes on ambiguous tasks.

### Autonomous Agent Mode (NEW in v1.2.0)
Agents run in non-interactive `--print` mode. They make reasonable defaults
and store assumptions as `decision` memories for your review — no blocking
on unanswerable questions.

### Crash-Safe Handoffs (NEW in v1.2.0)
Handoffs are auto-accepted on read (status: pending → accepted) instead of
being deleted. If an agent crashes, the handoff stays on disk for recovery.

### API Key Authentication
All endpoints require `X-API-Key` header. Prevents unauthorized access
and protects your Anthropic credits from anyone on your network.

### Handoff Depth Limiting
Auto-handoff chains are capped at a configurable depth (default: 5).
Prevents infinite agent loops that would burn credits endlessly.

### Task State Persistence
Running task state is saved to disk. If the orchestrator restarts,
you can see what was running and what completed.

### Shared Persistent Memory
All agents read/write to the same memory system:
- Decisions persist across sessions
- Agent outputs available to all
- Project state tracked automatically
- History searchable

### Auto-Context Loading
Right documentation loaded automatically:
- Detects "tweet" -> loads project social context
- Detects "dashboard" -> loads YOUR_WORKING_PROFILE
- Detects "proposal" -> loads governance context
- 17 task types mapped to context files

### Agent Coordination
Agents hand work to each other:
- Frontend builds UI → hands to Backend for API
- Backend completes → hands back to Frontend
- Orchestrator manages the flow automatically
- Auto-handoff only continues on agent success

### Your Working Preferences Built In
Every agent follows YOUR_WORKING_PROFILE.md:
- Autonomous mode: makes defaults, stores assumptions
- Delivers complete files (never snippets)
- Fixes errors with minimal explanation

---

## API Reference

### POST /route
Submit a task for agent execution. Budget is checked before spawning.

```json
{
  "task": "Build analytics dashboard",
  "project": "my-app",
  "auto_handoff": true,
  "working_dir": "~/projects/my-app"
}
```

### GET /status/{project}
Get project state (includes total spend).

### GET /projects
List all projects (includes spend per project).

### GET /tasks
List running/completed/failed tasks.

### GET /handoffs/{project}
List handoffs for a project (all statuses: pending, accepted, completed).

### POST /handoffs/{project}/retry/{handoff_id}
Reset a stuck "accepted" handoff back to "pending" for retry.

### GET /memories/{project}
List recent memories.

### GET /spend
Get current spend tracking summary (daily + per-project).

### POST /spend/reset-project/{project}
Reset spend counter for a project (e.g. after increasing budget).

### GET /health
System health check (includes daily spend + budget info).

---

## Documentation

| Doc | Purpose |
|-----|---------|
| `docs/DEPLOYMENT_GUIDE.md` | Full step-by-step setup |
| `docs/MINI_PC_REQUIREMENTS.md` | Hardware/software needs |
| `docs/RUNBOOK.md` | ⭐ Daily operations & troubleshooting |
| `docs/COST_ANALYSIS.md` | Cost tracking template |
| `mcp-servers/memory-server/README.md` | Memory system API |
| `QUICKSTART.md` | Quick reference |
| `BUILD_STATUS.md` | Build completion status |

---

## Estimated Costs

| Usage Level | Monthly Cost |
|-------------|-------------|
| Light (5-10 tasks/day) | $30-50 |
| Medium (10-25 tasks/day) | $50-100 |
| Heavy (25+ tasks/day) | $100-200 |

---

## Ready to Deploy

Everything is built and tested. When your mini PC arrives:

1. Transfer files
2. Run `install.sh`
3. Add API key
4. Start orchestrator
5. Submit your first task

**15 minutes from unboxing to autonomous AI team.**
