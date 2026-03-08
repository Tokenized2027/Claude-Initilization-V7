# Multi-Agent Memory & Coordination Architecture

**Goal:** Autonomous agents that share memory, fetch right context, and coordinate without your interference

**Status:** Buildable with your mini PC setup

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Mini PC (Orchestrator)              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Shared Memory System (MCP Server)          │  │
│  │  - Project state                                      │  │
│  │  - Agent conversations history                        │  │
│  │  - Decision logs                                      │  │
│  │  - Context mappings                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↕                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │      Context Router (MCP Server)                     │  │
│  │  - Task type detection                                │  │
│  │  - Auto-load relevant docs                            │  │
│  │  - Fetch YOUR_WORKING_PROFILE.md                      │  │
│  │  - Load project-specific context                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↕                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │     Agent Coordination Layer (Custom Service)        │  │
│  │  - Route tasks to appropriate agents                  │  │
│  │  - Pass context between agents                        │  │
│  │  - Aggregate agent outputs                            │  │
│  │  - Handle dependencies                                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────┬───────────────────┬───────────────┬──────┘
                   ↓                   ↓               ↓
         ┌─────────────┐     ┌─────────────┐  ┌─────────────┐
         │  Agent 1    │     │  Agent 2    │  │  Agent N    │
         │ (Frontend)  │     │ (Backend)   │  │  (Content)  │
         └─────────────┘     └─────────────┘  └─────────────┘
              ↕                     ↕                  ↕
         All agents read/write to shared memory
         All agents use context router for docs
```

---

## Component 1: Shared Memory System (MCP Server)

### Purpose
Persistent memory accessible by all agents, all sessions, all time.

### Implementation

**Create MCP Memory Server:**
```typescript
// ~/.claude/mcp-servers/memory-server/index.ts

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fs from "fs/promises";
import path from "path";

const MEMORY_DIR = "~/claude-memory";
const PROJECTS_DIR = path.join(MEMORY_DIR, "projects");
const AGENTS_DIR = path.join(MEMORY_DIR, "agents");
const SHARED_DIR = path.join(MEMORY_DIR, "shared");

interface Memory {
  timestamp: string;
  agent: string;
  type: string;
  content: any;
  project?: string;
}

class MemoryServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "claude-memory",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
        },
      }
    );

    this.setupTools();
    this.setupResources();
  }

  private setupTools() {
    // Tool: Store memory
    this.server.setRequestHandler("tools/call", async (request) => {
      if (request.params.name === "store_memory") {
        const { agent, type, content, project } = request.params.arguments;

        const memory: Memory = {
          timestamp: new Date().toISOString(),
          agent,
          type,
          content,
          project,
        };

        const filename = `${Date.now()}-${agent}-${type}.json`;
        const dir = project ? path.join(PROJECTS_DIR, project) : SHARED_DIR;

        await fs.mkdir(dir, { recursive: true });
        await fs.writeFile(
          path.join(dir, filename),
          JSON.stringify(memory, null, 2)
        );

        return {
          content: [
            {
              type: "text",
              text: `Memory stored: ${filename}`,
            },
          ],
        };
      }

      // Tool: Recall memory
      if (request.params.name === "recall_memory") {
        const { agent, type, project, limit = 10 } = request.params.arguments;

        const dir = project ? path.join(PROJECTS_DIR, project) : SHARED_DIR;

        try {
          const files = await fs.readdir(dir);
          const memories: Memory[] = [];

          for (const file of files) {
            if (agent && !file.includes(agent)) continue;
            if (type && !file.includes(type)) continue;

            const content = await fs.readFile(path.join(dir, file), "utf-8");
            memories.push(JSON.parse(content));
          }

          // Sort by timestamp, most recent first
          memories.sort((a, b) =>
            new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
          );

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(memories.slice(0, limit), null, 2),
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: "No memories found",
              },
            ],
          };
        }
      }

      // Tool: Get current project state
      if (request.params.name === "get_project_state") {
        const { project } = request.params.arguments;

        const stateFile = path.join(PROJECTS_DIR, project, "_state.json");

        try {
          const content = await fs.readFile(stateFile, "utf-8");
          return {
            content: [
              {
                type: "text",
                text: content,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: JSON.stringify({
                  project,
                  status: "new",
                  agents: [],
                  lastUpdated: new Date().toISOString(),
                }),
              },
            ],
          };
        }
      }

      // Tool: Update project state
      if (request.params.name === "update_project_state") {
        const { project, state } = request.params.arguments;

        const stateFile = path.join(PROJECTS_DIR, project, "_state.json");
        await fs.mkdir(path.join(PROJECTS_DIR, project), { recursive: true });

        await fs.writeFile(
          stateFile,
          JSON.stringify({
            ...state,
            lastUpdated: new Date().toISOString(),
          }, null, 2)
        );

        return {
          content: [
            {
              type: "text",
              text: `Project state updated: ${project}`,
            },
          ],
        };
      }

      // Tool: Get agent handoff
      if (request.params.name === "get_agent_handoff") {
        const { fromAgent, toAgent, project } = request.params.arguments;

        const handoffDir = path.join(PROJECTS_DIR, project, "handoffs");
        const handoffFile = path.join(handoffDir, `${fromAgent}-to-${toAgent}.json`);

        try {
          const content = await fs.readFile(handoffFile, "utf-8");
          const handoff = JSON.parse(content);

          // Auto-accept: mark as "accepted" (NOT deleted).
          // If the agent crashes, the handoff stays on disk for recovery.
          handoff.status = "accepted";
          await fs.writeFile(handoffFile, JSON.stringify(handoff, null, 2));

          return {
            content: [
              {
                type: "text",
                text: content,
              },
            ],
          };
        } catch (error) {
          return {
            content: [
              {
                type: "text",
                text: "No handoff waiting",
              },
            ],
          };
        }
      }

      // Tool: Create agent handoff
      if (request.params.name === "create_agent_handoff") {
        const { fromAgent, toAgent, project, context, task } = request.params.arguments;

        const handoff = {
          from: fromAgent,
          to: toAgent,
          timestamp: new Date().toISOString(),
          context,
          task,
          project,
        };

        const handoffDir = path.join(PROJECTS_DIR, project, "handoffs");
        await fs.mkdir(handoffDir, { recursive: true });

        const handoffFile = path.join(handoffDir, `${fromAgent}-to-${toAgent}.json`);
        await fs.writeFile(handoffFile, JSON.stringify(handoff, null, 2));

        return {
          content: [
            {
              type: "text",
              text: `Handoff created: ${fromAgent} → ${toAgent}`,
            },
          ],
        };
      }
    });

    // List available tools
    this.server.setRequestHandler("tools/list", async () => {
      return {
        tools: [
          {
            name: "store_memory",
            description: "Store a memory for later recall",
            inputSchema: {
              type: "object",
              properties: {
                agent: { type: "string", description: "Agent name" },
                type: { type: "string", description: "Memory type (decision, context, output, etc.)" },
                content: { type: "object", description: "Memory content" },
                project: { type: "string", description: "Project name (optional)" },
              },
              required: ["agent", "type", "content"],
            },
          },
          {
            name: "recall_memory",
            description: "Recall previous memories",
            inputSchema: {
              type: "object",
              properties: {
                agent: { type: "string", description: "Filter by agent (optional)" },
                type: { type: "string", description: "Filter by type (optional)" },
                project: { type: "string", description: "Filter by project (optional)" },
                limit: { type: "number", description: "Max results (default 10)" },
              },
            },
          },
          {
            name: "get_project_state",
            description: "Get current state of a project",
            inputSchema: {
              type: "object",
              properties: {
                project: { type: "string", description: "Project name" },
              },
              required: ["project"],
            },
          },
          {
            name: "update_project_state",
            description: "Update project state",
            inputSchema: {
              type: "object",
              properties: {
                project: { type: "string", description: "Project name" },
                state: { type: "object", description: "State to store" },
              },
              required: ["project", "state"],
            },
          },
          {
            name: "get_agent_handoff",
            description: "Check for handoff from another agent",
            inputSchema: {
              type: "object",
              properties: {
                fromAgent: { type: "string", description: "Agent handing off" },
                toAgent: { type: "string", description: "Current agent" },
                project: { type: "string", description: "Project name" },
              },
              required: ["fromAgent", "toAgent", "project"],
            },
          },
          {
            name: "create_agent_handoff",
            description: "Hand off work to another agent",
            inputSchema: {
              type: "object",
              properties: {
                fromAgent: { type: "string", description: "Current agent" },
                toAgent: { type: "string", description: "Target agent" },
                project: { type: "string", description: "Project name" },
                context: { type: "object", description: "Context to pass" },
                task: { type: "string", description: "Task for next agent" },
              },
              required: ["fromAgent", "toAgent", "project", "context", "task"],
            },
          },
        ],
      };
    });
  }

  private setupResources() {
    // Provide access to memory files as resources
    this.server.setRequestHandler("resources/list", async () => {
      const resources = [];

      // List all project memories
      try {
        const projects = await fs.readdir(PROJECTS_DIR);
        for (const project of projects) {
          resources.push({
            uri: `memory://project/${project}`,
            name: `Project: ${project}`,
            mimeType: "application/json",
          });
        }
      } catch {}

      return { resources };
    });

    this.server.setRequestHandler("resources/read", async (request) => {
      const uri = request.params.uri;

      if (uri.startsWith("memory://project/")) {
        const project = uri.replace("memory://project/", "");
        const stateFile = path.join(PROJECTS_DIR, project, "_state.json");

        try {
          const content = await fs.readFile(stateFile, "utf-8");
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: content,
              },
            ],
          };
        } catch {
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify({ project, status: "new" }),
              },
            ],
          };
        }
      }
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new MemoryServer();
server.run().catch(console.error);
```

**Install and Configure:**
```bash
# On your mini PC
cd ~/.claude/mcp-servers
mkdir memory-server
cd memory-server

# Copy the code above to index.ts
npm init -y
npm install @modelcontextprotocol/sdk

# Build
npx tsc

# Add to ~/.claude/mcp.json
```

**MCP Configuration:**
```json
{
  "mcpServers": {
    "claude-memory": {
      "command": "node",
      "args": ["~/.claude/mcp-servers/memory-server/dist/index.js"]
    }
  }
}
```

---

## Component 2: Context Router (MCP Server)

### Purpose
Automatically fetch and load the right documentation based on task type.

### Implementation

```typescript
// ~/.claude/mcp-servers/context-router/index.ts

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fs from "fs/promises";
import path from "path";

const CONTEXT_DIR = "~/Desktop/Claude/project-contexts";
const PROFILE_PATH = "~/Desktop/Claude/YOUR_WORKING_PROFILE.md";
const WORKFLOW_PATH = "~/Desktop/Claude/PROJECT_WORKFLOW.md";

interface ContextMapping {
  taskType: string;
  keywords: string[];
  files: string[];
}

const CONTEXT_MAPPINGS: ContextMapping[] = [
  {
    taskType: "project-tweet",
    keywords: ["tweet", "social", "twitter", "post", "announcement"],
    files: [
      PROFILE_PATH,
      `${CONTEXT_DIR}/project/01-quick-reference.md`,
      `${CONTEXT_DIR}/project/02-working-guidelines.md`,
      WORKFLOW_PATH,
    ],
  },
  {
    taskType: "project-support",
    keywords: ["support", "help", "question", "user", "troubleshoot"],
    files: [
      PROFILE_PATH,
      `${CONTEXT_DIR}/project/01-quick-reference.md`,
      `${CONTEXT_DIR}/project/03-protocol-technical.md`,
      `${CONTEXT_DIR}/project/05-user-guides-faq.md`,
    ],
  },
  {
    taskType: "project-governance",
    keywords: ["governance", "proposal", "governance", "vote"],
    files: [
      PROFILE_PATH,
      `${CONTEXT_DIR}/project/01-quick-reference.md`,
      `${CONTEXT_DIR}/project/04-protocol-governance.md`,
      WORKFLOW_PATH,
    ],
  },
  {
    taskType: "project-bd",
    keywords: ["partnership", "integration", "bd", "business development"],
    files: [
      PROFILE_PATH,
      `${CONTEXT_DIR}/project/01-quick-reference.md`,
      `${CONTEXT_DIR}/project/02-working-guidelines.md`,
      `${CONTEXT_DIR}/project/03-protocol-technical.md`,
      WORKFLOW_PATH,
    ],
  },
  {
    taskType: "project-analytics",
    keywords: ["dashboard", "analytics", "metrics", "chart", "data"],
    files: [
      PROFILE_PATH,
      `${CONTEXT_DIR}/project/01-quick-reference.md`,
      `${CONTEXT_DIR}/project/03-protocol-technical.md`,
    ],
  },
  {
    taskType: "coding-general",
    keywords: ["build", "code", "implement", "create", "add"],
    files: [
      PROFILE_PATH,
    ],
  },
];

class ContextRouter {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: "context-router",
        version: "1.0.0",
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupTools();
  }

  private detectTaskType(input: string): string {
    const lowerInput = input.toLowerCase();

    for (const mapping of CONTEXT_MAPPINGS) {
      for (const keyword of mapping.keywords) {
        if (lowerInput.includes(keyword)) {
          return mapping.taskType;
        }
      }
    }

    return "coding-general";
  }

  private async loadContextFiles(taskType: string): Promise<string> {
    const mapping = CONTEXT_MAPPINGS.find(m => m.taskType === taskType);
    if (!mapping) {
      return "No context found";
    }

    const contexts: string[] = [];

    for (const filePath of mapping.files) {
      try {
        const content = await fs.readFile(filePath, "utf-8");
        contexts.push(`\n\n--- ${path.basename(filePath)} ---\n\n${content}`);
      } catch (error) {
        contexts.push(`\n\n--- ${path.basename(filePath)} (not found) ---\n`);
      }
    }

    return contexts.join("\n");
  }

  private setupTools() {
    this.server.setRequestHandler("tools/call", async (request) => {
      if (request.params.name === "auto_load_context") {
        const { task } = request.params.arguments;

        const taskType = this.detectTaskType(task);
        const context = await this.loadContextFiles(taskType);

        return {
          content: [
            {
              type: "text",
              text: `Detected task type: ${taskType}\n\nLoaded context:\n${context}`,
            },
          ],
        };
      }

      if (request.params.name === "load_specific_context") {
        const { contextType } = request.params.arguments;
        const context = await this.loadContextFiles(contextType);

        return {
          content: [
            {
              type: "text",
              text: context,
            },
          ],
        };
      }
    });

    this.server.setRequestHandler("tools/list", async () => {
      return {
        tools: [
          {
            name: "auto_load_context",
            description: "Automatically detect task type and load relevant context",
            inputSchema: {
              type: "object",
              properties: {
                task: { type: "string", description: "Task description" },
              },
              required: ["task"],
            },
          },
          {
            name: "load_specific_context",
            description: "Load specific context type",
            inputSchema: {
              type: "object",
              properties: {
                contextType: {
                  type: "string",
                  enum: CONTEXT_MAPPINGS.map(m => m.taskType),
                  description: "Context type to load"
                },
              },
              required: ["contextType"],
            },
          },
        ],
      };
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const router = new ContextRouter();
router.run().catch(console.error);
```

---

## Component 3: Agent Orchestration Service

### Purpose
Coordinate multiple agents working on the same project.

```python
# ~/claude-orchestrator/orchestrator.py

import asyncio
import json
import subprocess
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

class AgentOrchestrator:
    def __init__(self, memory_dir: Path):
        self.memory_dir = memory_dir
        self.projects_dir = memory_dir / "projects"
        self.agents_dir = memory_dir / "agents"

    async def route_task(self, task: str, project: str) -> Dict:
        """Route task to appropriate agent(s)"""

        # Detect task type
        task_type = self.detect_task_type(task)

        # Get agent for task type
        agent = self.get_agent_for_task(task_type)

        # Load project state
        state = self.load_project_state(project)

        # Load context for agent
        context = self.load_context_for_agent(agent, task_type)

        # Spawn agent
        result = await self.spawn_agent(
            agent=agent,
            task=task,
            project=project,
            context=context,
            state=state
        )

        # Update project state
        self.update_project_state(project, result)

        # Check if handoff needed
        if result.get("handoff"):
            next_agent = result["handoff"]["to"]
            next_task = result["handoff"]["task"]

            # Create handoff
            self.create_handoff(
                from_agent=agent,
                to_agent=next_agent,
                project=project,
                context=result["handoff"]["context"],
                task=next_task
            )

            # Notify or auto-spawn next agent
            if self.config.get("auto_handoff", False):
                await self.route_task(next_task, project)

        return result

    def detect_task_type(self, task: str) -> str:
        """Detect what type of task this is"""
        task_lower = task.lower()

        if any(kw in task_lower for kw in ["tweet", "social", "post"]):
            return "content-social"
        elif any(kw in task_lower for kw in ["dashboard", "analytics", "chart"]):
            return "coding-frontend"
        elif any(kw in task_lower for kw in ["api", "backend", "database"]):
            return "coding-backend"
        elif any(kw in task_lower for kw in ["governance", "proposal", "governance"]):
            return "content-governance"
        elif any(kw in task_lower for kw in ["support", "help", "question"]):
            return "content-support"
        else:
            return "general"

    def get_agent_for_task(self, task_type: str) -> str:
        """Map task type to agent"""
        mapping = {
            "content-social": "content-creator",
            "content-governance": "governance-specialist",
            "content-support": "support-specialist",
            "coding-frontend": "frontend-developer",
            "coding-backend": "backend-developer",
            "general": "generalist",
        }
        return mapping.get(task_type, "generalist")

    def load_context_for_agent(self, agent: str, task_type: str) -> str:
        """Load relevant context files"""
        # Call context router MCP server
        # Return combined context
        pass

    async def spawn_agent(
        self,
        agent: str,
        task: str,
        project: str,
        context: str,
        state: Dict
    ) -> Dict:
        """Spawn Claude agent with context"""

        # Create agent prompt
        prompt = f"""
{context}

PROJECT STATE:
{json.dumps(state, indent=2)}

YOUR TASK:
{task}

Use the memory MCP tools to:
1. Check for any handoffs to you: get_agent_handoff
2. Recall relevant memories: recall_memory
3. Complete your task
4. Store your work: store_memory
5. Update project state: update_project_state
6. If you need another agent, create handoff: create_agent_handoff
"""

        # Spawn Claude Code process
        result = await self.run_claude_code(prompt, project)

        return result

    async def run_claude_code(self, prompt: str, project: str) -> Dict:
        """Run Claude Code CLI with prompt"""

        process = await asyncio.create_subprocess_exec(
            "claude",
            "--project", project,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate(prompt.encode())

        return {
            "output": stdout.decode(),
            "error": stderr.decode() if stderr else None,
            "exit_code": process.returncode
        }

    def load_project_state(self, project: str) -> Dict:
        """Load current project state"""
        state_file = self.projects_dir / project / "_state.json"
        if state_file.exists():
            return json.loads(state_file.read_text())
        return {"project": project, "status": "new", "agents": []}

    def update_project_state(self, project: str, result: Dict):
        """Update project state with agent result"""
        state_file = self.projects_dir / project / "_state.json"
        state_file.parent.mkdir(parents=True, exist_ok=True)

        state = self.load_project_state(project)
        state["last_updated"] = datetime.now().isoformat()
        state["last_result"] = result

        state_file.write_text(json.dumps(state, indent=2))

    def create_handoff(
        self,
        from_agent: str,
        to_agent: str,
        project: str,
        context: Dict,
        task: str
    ):
        """Create handoff file for next agent"""
        handoff_dir = self.projects_dir / project / "handoffs"
        handoff_dir.mkdir(parents=True, exist_ok=True)

        handoff = {
            "from": from_agent,
            "to": to_agent,
            "timestamp": datetime.now().isoformat(),
            "context": context,
            "task": task,
            "project": project
        }

        handoff_file = handoff_dir / f"{from_agent}-to-{to_agent}.json"
        handoff_file.write_text(json.dumps(handoff, indent=2))

# API Server
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
orchestrator = AgentOrchestrator(Path("~/claude-memory"))

class TaskRequest(BaseModel):
    task: str
    project: str
    auto_handoff: bool = True

@app.post("/route")
async def route_task(request: TaskRequest):
    result = await orchestrator.route_task(request.task, request.project)
    return result

@app.get("/status/{project}")
async def get_status(project: str):
    state = orchestrator.load_project_state(project)
    return state

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

---

## Component 4: Agent Session Templates

### Update each agent's CLAUDE.md to use memory/coordination

```markdown
# Agent: Frontend Developer

## Memory Protocol

**At session start:**
1. Check for handoffs: `get_agent_handoff(fromAgent='*', toAgent='frontend-developer', project='<project>')`
2. Recall recent memories: `recall_memory(agent='frontend-developer', project='<project>', limit=5)`
3. Load project state: `get_project_state(project='<project>')`
4. Auto-load context: `auto_load_context(task='<task>')`

**During work:**
1. Store decisions: `store_memory(agent='frontend-developer', type='decision', content={...}, project='<project>')`
2. Store outputs: `store_memory(agent='frontend-developer', type='output', content={...}, project='<project>')`

**At completion:**
1. Update project state: `update_project_state(project='<project>', state={...})`
2. If backend work needed: `create_agent_handoff(fromAgent='frontend-developer', toAgent='backend-developer', project='<project>', context={...}, task='...')`

## Your Role
[Standard frontend developer instructions...]
[Include YOUR_WORKING_PROFILE preferences...]
```

---

## How It Works End-to-End

### Scenario: "Build project price dashboard"

1. **You submit task to orchestrator:**
   ```bash
   curl -X POST http://localhost:8000/route \
     -H "Content-Type: application/json" \
     -d '{"task": "Build project price dashboard", "project": "my-app", "auto_handoff": true}'
   ```

2. **Orchestrator detects:**
   - Task type: `coding-frontend`
   - Agent needed: `frontend-developer`
   - Context needed: YOUR_WORKING_PROFILE + technical docs

3. **Orchestrator spawns Frontend agent:**
   - Loads YOUR_WORKING_PROFILE.md
   - Loads project state (empty if new)
   - Passes task with context

4. **Frontend agent:**
   - Checks for handoffs (none yet)
   - Recalls memories (finds none, new project)
   - Auto-loads context
   - Makes reasonable defaults for unclear requirements (stores assumptions as memories)
   - Builds dashboard UI
   - Stores decision: "Using Recharts for charts"
   - Realizes needs API endpoint
   - Creates handoff to backend-developer:
     ```json
     {
       "task": "Create API endpoint for project price history",
       "context": {
         "timeframe": "7 days",
         "update_frequency": "5min cache",
         "data_source": "CoinGecko"
       }
     }
     ```
   - Updates project state
   - Completes

5. **Orchestrator detects handoff:**
   - Auto-spawns Backend agent (because auto_handoff=true)

6. **Backend agent:**
   - Checks for handoffs (finds one from frontend!)
   - Recalls memories (sees frontend's decisions)
   - Loads context
   - Reads handoff: needs project price API
   - Builds API endpoint
   - Stores output: API spec
   - Updates project state
   - Creates handoff back to frontend: "API ready at /api/price-data"

7. **Frontend agent (resumed):**
   - Gets handoff from backend
   - Integrates API into dashboard
   - Tests integration
   - Stores completion: "Dashboard complete"
   - Updates project state: "DONE"

8. **You check status:**
   ```bash
   curl http://localhost:8000/status/my-app
   ```
   ```json
   {
     "project": "my-app",
     "status": "complete",
     "agents": ["frontend-developer", "backend-developer"],
     "last_updated": "2026-02-14T15:30:00Z",
     "outputs": [...]
   }
   ```

**All of this happened WITHOUT your interference.** Agents coordinated autonomously.

---

## Setup Instructions

### 1. Install MCP Servers on Mini PC

```bash
# SSH to mini PC
ssh user@your-server

# Create MCP servers directory
mkdir -p ~/.claude/mcp-servers

# Install memory server
cd ~/.claude/mcp-servers
git clone https://github.com/your-repo/claude-memory-server memory-server
cd memory-server
npm install
npm run build

# Install context router
cd ~/.claude/mcp-servers
git clone https://github.com/your-repo/claude-context-router context-router
cd context-router
npm install
npm run build

# Configure MCP
nano ~/.claude/mcp.json
```

```json
{
  "mcpServers": {
    "claude-memory": {
      "command": "node",
      "args": ["~/.claude/mcp-servers/memory-server/dist/index.js"]
    },
    "context-router": {
      "command": "node",
      "args": ["~/.claude/mcp-servers/context-router/dist/index.js"]
    }
  }
}
```

### 2. Install Orchestrator

```bash
# Create orchestrator directory
mkdir -p ~/claude-orchestrator
cd ~/claude-orchestrator

# Copy orchestrator.py (from above)
# Install dependencies
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn anthropic

# Create systemd service
sudo nano /etc/systemd/system/claude-orchestrator.service
```

```ini
[Unit]
Description=Claude Agent Orchestrator
After=network.target

[Service]
Type=simple
User=user
WorkingDirectory=~/claude-orchestrator
ExecStart=~/claude-orchestrator/venv/bin/python orchestrator.py
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl enable claude-orchestrator
sudo systemctl start claude-orchestrator
```

### 3. Update Agent Templates

For each agent in `$CLAUDE_HOME/claude-code-framework/essential/agents/`:

1. Add memory protocol section
2. Add MCP tool usage instructions
3. Add handoff creation guidelines

### 4. Test the System

```bash
# Submit a test task
curl -X POST http://your-server:8000/route \
  -H "Content-Type: application/json" \
  -d '{
    "task": "Create a simple dashboard showing project price",
    "project": "test-project",
    "auto_handoff": true
  }'

# Check status
curl http://your-server:8000/status/test-project

# View memories
curl http://your-server:8000/memories/test-project
```

---

## Benefits of This Architecture

### ✅ Autonomous Operation
- Submit task once, agents coordinate until completion
- No manual handoffs between agents
- Automatic context loading
- Persistent memory across sessions

### ✅ Shared Memory
- All agents see project state
- Decisions logged and accessible
- Context preserved between handoffs
- History available for future reference

### ✅ Smart Context Loading
- Agents auto-load YOUR_WORKING_PROFILE
- Task-specific docs loaded automatically
- No manual file uploads needed
- Always has right context

### ✅ Coordination Without You
- Agents pass work between each other
- Frontend ↔ Backend collaboration
- Parallel work when possible
- Sequential when dependencies exist

---

## Limitations & Considerations

### Current Limitations

**Rate Limits:**
- Still subject to Anthropic API rate limits
- Can't spawn unlimited concurrent agents

**No Native MCP Support in Claude Projects:**
- This works with Claude Code CLI
- Claude Projects (web) don't support MCP yet
- Need to use CLI-based agents

**Requires Mini PC Always-On:**
- Orchestrator needs to run 24/7
- MCP servers need to be accessible
- Network connectivity required

### Workarounds

**For Claude Projects:**
Create a "Loader Agent" that:
1. Uses Claude Code CLI with MCP
2. Fetches context and memories
3. Formats them for Claude Projects
4. You paste into Projects manually

**For Rate Limits:**
- Implement queuing in orchestrator
- Stagger agent spawns
- Use exponential backoff

---

## What You Get

With this architecture on your mini PC:

✅ **Persistent memory** - All agents share memory across all sessions
✅ **Auto-context loading** - Right docs loaded automatically
✅ **Agent coordination** - Autonomous handoffs between agents
✅ **No interference needed** - Submit task, get result
✅ **Full state tracking** - See what every agent did
✅ **Decision history** - Why choices were made
✅ **Scalable** - Add more agents easily

**This is production-grade multi-agent AI.**

---

## Want Me to Build This?

I can create:
1. Complete MCP servers (memory + context router)
2. Orchestrator service with API
3. Updated agent templates
4. Setup scripts for mini PC
5. Testing suite
6. Documentation

Say "build it" and I'll create the full system ready to deploy.
