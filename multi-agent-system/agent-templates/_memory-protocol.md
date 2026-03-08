# Memory Protocol (Include in every agent)

This protocol uses tools from two MCP servers. Each tool below is tagged with its source.

## At Session Start — ALWAYS Do These Steps

1. **Load your working profile** *(Context Router)*:
   ```
   load_working_profile()
   ```
   This contains the user's communication preferences. Follow them exactly.

2. **Check for handoffs to you** *(Memory Server)*:
   ```
   get_agent_handoff(toAgent="YOUR_AGENT_NAME", project="PROJECT_NAME")
   ```
   If a handoff exists, read it carefully — another agent is passing work to you.
   **Note:** Handoffs are auto-accepted on read (status changes from "pending" to "accepted").
   This prevents double-processing. Call `complete_handoff` when you finish the work.

3. **Recall recent project memories** *(Memory Server)*:
   ```
   recall_memory(project="PROJECT_NAME", limit=10)
   ```
   Understand what has been decided and built so far.

4. **Load project state** *(Memory Server)*:
   ```
   get_project_state(project="PROJECT_NAME")
   ```
   Know the current status, phase, and which agents have been involved.

## During Work

5. **Store decisions as you make them** *(Memory Server)*:
   ```
   store_memory(
     agent="YOUR_AGENT_NAME",
     type="decision",
     content={"decision": "...", "reason": "..."},
     project="PROJECT_NAME"
   )
   ```

6. **Store outputs when you complete work** *(Memory Server)*:
   ```
   store_memory(
     agent="YOUR_AGENT_NAME",
     type="output",
     content={"files_changed": [...], "summary": "..."},
     project="PROJECT_NAME"
   )
   ```

7. **Store errors/solutions for future agents** *(Memory Server)*:
   ```
   store_memory(
     agent="YOUR_AGENT_NAME",
     type="solution",
     content={"problem": "...", "solution": "...", "context": "..."},
     project="PROJECT_NAME"
   )
   ```

## At Completion

8. **Update project state** *(Memory Server)*:
   ```
   update_project_state(
     project="PROJECT_NAME",
     status="in-progress",
     currentPhase="...",
     metadata={"last_agent": "YOUR_AGENT_NAME", "completed": "..."}
   )
   ```

9. **Create handoff if another agent needs to continue** *(Memory Server)*:
   ```
   create_agent_handoff(
     fromAgent="YOUR_AGENT_NAME",
     toAgent="NEXT_AGENT",
     project="PROJECT_NAME",
     context={"completed": "...", "decisions": [...], "files": [...]},
     task="What the next agent should do"
   )
   ```

10. **If your work is the final step, mark project complete** *(Memory Server)*:
    ```
    update_project_state(project="PROJECT_NAME", status="completed")
    ```

## Tool Reference by MCP Server

### Memory Server Tools

| Tool | Purpose |
|------|---------|
| `store_memory` | Save a decision, output, error, solution, or context to project memory |
| `recall_memory` | Retrieve recent memories for a project |
| `get_project_state` | Load current project status, phase, and metadata |
| `update_project_state` | Update project status, phase, or metadata |
| `list_projects` | List all known projects |
| `get_agent_handoff` | Check for pending handoffs addressed to you |
| `create_agent_handoff` | Create a handoff to pass work to another agent |
| `complete_handoff` | Mark a handoff as completed |
| `search_memories` | Search across memories by keyword or filter |

### Context Router Tools

| Tool | Purpose |
|------|---------|
| `auto_load_context` | Detect task type from a description and load all relevant context files |
| `load_working_profile` | Load the user's working profile (communication prefs, code rules) |
| `load_specific_context` | Load context files for a known task type |
| `list_context_types` | List all available task types and their keywords |
| `load_project_context` | Load specific project context files by number (01-06) |

## Memory Types Reference

| Type | When to Use |
|------|------------|
| `decision` | Architecture choices, library selection, approach decisions |
| `output` | What you built, files changed, features completed |
| `context` | Background information for future agents |
| `error` | Errors encountered and how you resolved them |
| `solution` | Reusable solutions to common problems |
| `question` | Questions asked to the user and their answers |
| `answer` | Important answers received from the user |

## Handoff Targets

| Agent | When to Hand Off |
|-------|-----------------|
| `frontend-developer` | UI work, components, client-side logic |
| `backend-developer` | API routes, business logic, database |
| `system-architect` | Major architecture decisions |
| `product-manager` | Requirements clarification, scope |
| `content-creator` | Social posts, blog articles, long-form content |
| `designer` | UI/UX design, visual consistency |
| `api-architect` | API contracts, data schemas |
| `security-auditor` | Security review before deployment |
| `system-tester` | Testing after features complete |
| `devops-engineer` | Deployment, infrastructure |
| `support-specialist` | User support, troubleshooting |
| `governance-specialist` | Governance proposals, proposal drafts, DAO process |
| `bd-specialist` | Partnerships, integrations, business development |
| `generalist` | General tasks that don't fit a specific role |

## User Working Preferences (Critical)

**Always follow these from YOUR_WORKING_PROFILE.md:**
- **Autonomous mode (--print):** Make reasonable defaults, store assumptions as `decision` memories. If truly blocked, create handoff to `product-manager` with options.
- **Interactive mode:** Ask clarifying questions BEFORE starting any task
- Provide COMPLETE files only — never partial snippets
- Propose git commits but WAIT for approval (interactive mode only)
- Fix errors immediately with minimal explanation
- Brief Web3 context (intermediate level — skip DeFi basics)
