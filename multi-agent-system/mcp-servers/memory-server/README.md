# Claude Memory MCP Server

Persistent shared memory system for multi-agent Claude deployments.

## Features

- **Persistent Memory**: Store and recall memories across all agents and sessions
- **Project State**: Track project status, agents involved, current phase
- **Agent Handoffs**: Coordinate work between agents autonomously
- **Full-Text Search**: Find specific information across all memories
- **Resource Access**: Expose project states as MCP resources

## Installation

```bash
cd memory-server
npm install
npm run build
```

## Configuration

Add to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "claude-memory": {
      "command": "node",
      "args": ["/absolute/path/to/memory-server/dist/index.js"],
      "env": {
        "CLAUDE_MEMORY_DIR": "/home/user/claude-memory"
      }
    }
  }
}
```

## Tools

### store_memory
Store a memory for later recall.

**Parameters:**
- `agent` (string, required): Agent name
- `type` (string, required): Memory type (decision, output, context, error, solution, question, answer)
- `content` (object, required): Memory content
- `project` (string, optional): Project name
- `tags` (array, optional): Tags for categorization

**Example:**
```json
{
  "agent": "frontend-developer",
  "type": "decision",
  "content": {
    "decision": "Using Recharts for data visualization",
    "reason": "Lightweight, React-native, good documentation"
  },
  "project": "my-app",
  "tags": ["architecture", "dependencies"]
}
```

### recall_memory
Recall previous memories with filters.

**Parameters:**
- `agent` (string, optional): Filter by agent
- `type` (string, optional): Filter by type
- `project` (string, optional): Filter by project
- `tags` (array, optional): Filter by tags
- `limit` (number, optional): Max results (default: 10, max: 100)

**Returns:** Array of matching memories, most recent first.

### get_project_state
Get current state of a project.

**Parameters:**
- `project` (string, required): Project name

**Returns:** ProjectState object with status, agents, timestamps, metadata.

### update_project_state
Update project state.

**Parameters:**
- `project` (string, required): Project name
- `status` (string, optional): Project status
- `currentPhase` (string, optional): Current phase/milestone
- `metadata` (object, optional): Additional metadata to merge

### list_projects
List all projects with their states.

**Parameters:**
- `status` (string, optional): Filter by status

**Returns:** Array of ProjectState objects, most recently updated first.

### get_agent_handoff
Check for pending handoff from another agent.

**Parameters:**
- `toAgent` (string, required): Current agent
- `project` (string, required): Project name
- `fromAgent` (string, optional): Filter by source agent

**Returns:** Pending handoff if exists, or "No pending handoffs found."

### create_agent_handoff
Hand off work to another agent.

**Parameters:**
- `fromAgent` (string, required): Current agent
- `toAgent` (string, required): Target agent
- `project` (string, required): Project name
- `context` (object, required): Context to pass
- `task` (string, required): Task for target agent

**Example:**
```json
{
  "fromAgent": "frontend-developer",
  "toAgent": "backend-developer",
  "project": "my-app",
  "context": {
    "completed": "Dashboard UI built",
    "needs": "API endpoint for project price history",
    "specs": {
      "endpoint": "/api/price-data",
      "params": "timeframe=7d",
      "format": "JSON array of {timestamp, price}"
    }
  },
  "task": "Create API endpoint for project price history per specs in context"
}
```

### complete_handoff
Mark handoff as completed.

**Parameters:**
- `handoffId` (string, required): Handoff ID

### search_memories
Full-text search across memories.

**Parameters:**
- `query` (string, required): Search query
- `project` (string, optional): Limit to project
- `limit` (number, optional): Max results (default: 10)

## Memory Storage Structure

```
$CLAUDE_MEMORY_DIR/
├── projects/
│   ├── project-name/
│   │   ├── _state.json          # Project state
│   │   ├── memories/            # Project-specific memories
│   │   │   ├── <id>.json
│   │   │   └── ...
│   │   └── handoffs/            # Agent handoffs
│   │       ├── <id>.json
│   │       └── ...
│   └── ...
├── agents/                      # Agent-specific data (future)
└── shared/                      # Shared memories (no project)
    ├── <id>.json
    └── ...
```

## Agent Usage Pattern

At session start:
```typescript
// 1. Check for handoffs
const handoff = await get_agent_handoff({
  toAgent: "frontend-developer",
  project: "my-app"
});

// 2. Recall recent memories
const memories = await recall_memory({
  agent: "frontend-developer",
  project: "my-app",
  limit: 5
});

// 3. Load project state
const state = await get_project_state({
  project: "my-app"
});
```

During work:
```typescript
// Store decisions
await store_memory({
  agent: "frontend-developer",
  type: "decision",
  content: { /* decision details */ },
  project: "my-app"
});

// Store outputs
await store_memory({
  agent: "frontend-developer",
  type: "output",
  content: { /* what was built */ },
  project: "my-app"
});
```

At completion:
```typescript
// Update project state
await update_project_state({
  project: "my-app",
  status: "in-progress",
  currentPhase: "API integration"
});

// Create handoff if needed
await create_agent_handoff({
  fromAgent: "frontend-developer",
  toAgent: "backend-developer",
  project: "my-app",
  context: { /* context */ },
  task: "Task description"
});
```

## Development

```bash
# Watch mode for development
npm run dev

# Build for production
npm run build

# Run
npm start
```

## Testing

See `../../tests/memory-server.test.ts` for test suite.

## License

MIT
