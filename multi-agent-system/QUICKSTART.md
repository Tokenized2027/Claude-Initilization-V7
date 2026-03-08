# Multi-Agent System - Quick Start

**Status:** All components complete. Ready for mini PC deployment.

---

## What You're Getting

A complete autonomous multi-agent AI system with:
- **Shared persistent memory** across all agents/sessions
- **Auto-context loading** based on task type
- **Agent coordination** without your intervention
- **Full state tracking** of all project work

---

## Components

| Component | Status | Location |
|-----------|--------|----------|
| Memory MCP Server | Complete | `mcp-servers/memory-server/` |
| Context Router MCP Server | Complete | `mcp-servers/context-router/` |
| Orchestrator Service | Complete | `orchestrator/` |
| Agent Templates (10) | Complete | `agent-templates/` |
| Deployment Scripts | Complete | `deployment/` |
| Test Suite | Complete | `tests/` |
| Documentation | Complete | `docs/` |

---

## When Mini PC Arrives

```bash
# 1. Transfer source folder to mini PC
scp -r multi-agent-system/ user@your-server:~/

# 2. Run installer (installs to ~/claude-multi-agent/)
ssh user@your-server "bash ~/multi-agent-system/deployment/install.sh"

# 3. Generate orchestrator API key
ssh user@your-server "python3 -c \"import secrets; print(secrets.token_urlsafe(32))\""

# 4. Configure (add ANTHROPIC_API_KEY + ORCHESTRATOR_API_KEY from step 3)
ssh user@your-server "nano ~/claude-multi-agent/orchestrator/.env"

# 5. Start
ssh user@your-server "sudo systemctl start claude-orchestrator"

# 6. Test
ssh user@your-server "bash ~/claude-multi-agent/tests/test-system.sh"
```

---

## How It Will Work

### Submit Task
```bash
# All requests require X-API-Key header
curl -X POST http://your-server:8000/route \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_ORCHESTRATOR_KEY" \
  -d '{
    "task": "Build analytics dashboard",
    "project": "my-app"
  }'
```

### System Executes Autonomously
1. Detects task type → frontend work
2. Auto-loads YOUR_WORKING_PROFILE + technical context
3. Spawns frontend agent
4. Agent checks memory, asks YOU questions
5. You answer once
6. Agent builds UI, stores decision in memory
7. Agent realizes needs API, creates handoff
8. Backend agent auto-spawns, reads handoff
9. Backend builds API, stores in memory
10. Backend hands back to frontend
11. Frontend integrates API, completes
12. Project state updated: DONE

### Check Status
```bash
curl http://your-server:8000/status/my-app
# "Complete: Dashboard deployed with API"
```

**Your intervention:** Answered questions once. Rest was autonomous.

---

## Memory System Example

Every agent can:

```typescript
// Check for work from other agents
await get_agent_handoff({
  toAgent: "frontend-developer",
  project: "my-app"
});

// See what others decided
await recall_memory({
  project: "my-app",
  type: "decision"
});

// Store your work
await store_memory({
  agent: "frontend-developer",
  type: "output",
  content: { built: "Dashboard UI" },
  project: "my-app"
});

// Pass work to another agent
await create_agent_handoff({
  fromAgent: "frontend-developer",
  toAgent: "backend-developer",
  project: "my-app",
  context: { needs: "API endpoint" },
  task: "Build API for price data"
});
```

---

## File Structure

```
multi-agent-system/                     (source/dev folder)
├── README.md
├── BUILD_STATUS.md
├── QUICKSTART.md                       (this file)
│
├── mcp-servers/
│   ├── memory-server/                  (shared persistent memory)
│   │   ├── src/index.ts
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── README.md
│   │
│   └── context-router/                 (auto-context loading)
│       ├── src/index.ts
│       ├── package.json
│       └── tsconfig.json
│
├── orchestrator/                       (task routing & coordination)
│   ├── orchestrator.py
│   ├── requirements.txt
│   └── .env.example
│
├── agent-templates/                    (10 memory-aware agents)
│   ├── _memory-protocol.md
│   └── [10 agent templates]
│
├── deployment/                         (setup automation)
│   ├── install.sh
│   └── uninstall.sh
│
├── tests/                              (verification)
│   ├── test-system.sh
│   └── test-orchestrator-api.sh
│
└── docs/                               (documentation)
    ├── DEPLOYMENT_GUIDE.md
    └── MINI_PC_REQUIREMENTS.md
```

After `install.sh` runs, the system is installed to `~/claude-multi-agent/` on the mini PC.

---

## Test Memory Server Locally

```bash
cd mcp-servers/memory-server
npm install
npm run build

# Add to your ~/.claude/mcp.json:
{
  "mcpServers": {
    "claude-memory": {
      "command": "node",
      "args": ["<CLAUDE_HOME>/multi-agent-system/mcp-servers/memory-server/dist/index.js"],
      "env": {
        "CLAUDE_MEMORY_DIR": "~/claude-memory"
      }
    }
  }
}

# Test in Claude Code:
claude
# Try: store_memory, recall_memory tools
```

---

## Quick Reference

**"When can I deploy?"** -- When mini PC arrives (15min setup)
**"Can I test locally?"** -- Yes, memory server works now
**"Will it really be autonomous?"** -- Yes, submit task, get result, zero intervention
**"How much will this cost?"** -- Just API costs for Claude calls

---

**Full guide:** `docs/DEPLOYMENT_GUIDE.md`
