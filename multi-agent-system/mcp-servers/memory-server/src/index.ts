#!/usr/bin/env node

/**
 * Claude Memory MCP Server
 *
 * Provides persistent shared memory for multi-agent Claude systems.
 * All agents can store/recall memories, manage project state, and coordinate via handoffs.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Memory directories - will be created on first run
const MEMORY_ROOT = process.env.CLAUDE_MEMORY_DIR || path.join(process.env.HOME || "/tmp", "claude-memory");
const PROJECTS_DIR = path.join(MEMORY_ROOT, "projects");
const AGENTS_DIR = path.join(MEMORY_ROOT, "agents");
const SHARED_DIR = path.join(MEMORY_ROOT, "shared");

interface Memory {
  id: string;
  timestamp: string;
  agent: string;
  type: string;
  content: any;
  project?: string;
  tags?: string[];
}

interface ProjectState {
  project: string;
  status: string;
  agents: string[];
  created: string;
  lastUpdated: string;
  currentPhase?: string;
  metadata?: Record<string, any>;
}

interface Handoff {
  id: string;
  from: string;
  to: string;
  timestamp: string;
  context: Record<string, any>;
  task: string;
  project: string;
  status: "pending" | "accepted" | "completed";
}

class MemoryServer {
  private server: Server;
  private fileLocks: Map<string, Promise<void>> = new Map();

  constructor() {
    this.server = new Server(
      {
        name: "claude-memory",
        version: "3.1.0",
      },
      {
        capabilities: {
          tools: {},
          resources: {},
        },
      }
    );

    this.setupToolHandlers();
    this.setupResourceHandlers();
  }

  private async ensureDirectories() {
    await fs.mkdir(PROJECTS_DIR, { recursive: true });
    await fs.mkdir(AGENTS_DIR, { recursive: true });
    await fs.mkdir(SHARED_DIR, { recursive: true });
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Simple file-level lock. Serializes writes to the same file path so
   * two concurrent agents can't corrupt a shared JSON file (e.g. _state.json).
   */
  private async withFileLock<T>(filePath: string, fn: () => Promise<T>): Promise<T> {
    const prev = this.fileLocks.get(filePath) ?? Promise.resolve();
    let release: () => void;
    const next = new Promise<void>((resolve) => { release = resolve; });
    this.fileLocks.set(filePath, next);

    await prev; // wait for previous operation on this file to finish
    try {
      return await fn();
    } finally {
      release!();
      // Clean up the map entry if nothing else is queued
      if (this.fileLocks.get(filePath) === next) {
        this.fileLocks.delete(filePath);
      }
    }
  }

  private setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "store_memory",
            description: "Store a memory for later recall. Use this to save decisions, outputs, context, or any information that should persist.",
            inputSchema: {
              type: "object",
              properties: {
                agent: {
                  type: "string",
                  description: "Agent name storing the memory (e.g., 'frontend-developer')",
                },
                type: {
                  type: "string",
                  description: "Memory type (decision, output, context, error, solution, question, answer)",
                },
                content: {
                  type: "object",
                  description: "Memory content - any structured data",
                },
                project: {
                  type: "string",
                  description: "Project name (optional, stores in shared memory if omitted)",
                },
                tags: {
                  type: "array",
                  items: { type: "string" },
                  description: "Tags for categorization (optional)",
                },
              },
              required: ["agent", "type", "content"],
            },
          },
          {
            name: "recall_memory",
            description: "Recall previous memories. Filter by agent, type, project, or tags. Returns most recent memories first.",
            inputSchema: {
              type: "object",
              properties: {
                agent: {
                  type: "string",
                  description: "Filter by agent name (optional)",
                },
                type: {
                  type: "string",
                  description: "Filter by memory type (optional)",
                },
                project: {
                  type: "string",
                  description: "Filter by project (optional)",
                },
                tags: {
                  type: "array",
                  items: { type: "string" },
                  description: "Filter by tags (optional)",
                },
                limit: {
                  type: "number",
                  description: "Maximum memories to return (default: 10, max: 100)",
                  default: 10,
                },
              },
            },
          },
          {
            name: "get_project_state",
            description: "Get current state of a project including status, agents involved, and metadata.",
            inputSchema: {
              type: "object",
              properties: {
                project: {
                  type: "string",
                  description: "Project name",
                },
              },
              required: ["project"],
            },
          },
          {
            name: "update_project_state",
            description: "Update project state. Merges provided state with existing state.",
            inputSchema: {
              type: "object",
              properties: {
                project: {
                  type: "string",
                  description: "Project name",
                },
                status: {
                  type: "string",
                  description: "Project status (new, planning, in-progress, blocked, review, completed, archived)",
                },
                currentPhase: {
                  type: "string",
                  description: "Current phase/milestone",
                },
                metadata: {
                  type: "object",
                  description: "Additional metadata to merge",
                },
              },
              required: ["project"],
            },
          },
          {
            name: "list_projects",
            description: "List all projects with their current status.",
            inputSchema: {
              type: "object",
              properties: {
                status: {
                  type: "string",
                  description: "Filter by status (optional)",
                },
              },
            },
          },
          {
            name: "get_agent_handoff",
            description: "Check for pending handoff from another agent. Returns handoff details if one exists.",
            inputSchema: {
              type: "object",
              properties: {
                toAgent: {
                  type: "string",
                  description: "Current agent checking for handoffs",
                },
                project: {
                  type: "string",
                  description: "Project name",
                },
                fromAgent: {
                  type: "string",
                  description: "Filter by specific source agent (optional)",
                },
              },
              required: ["toAgent", "project"],
            },
          },
          {
            name: "create_agent_handoff",
            description: "Hand off work to another agent. Creates a pending handoff that the target agent can retrieve.",
            inputSchema: {
              type: "object",
              properties: {
                fromAgent: {
                  type: "string",
                  description: "Current agent creating handoff",
                },
                toAgent: {
                  type: "string",
                  description: "Target agent to receive handoff",
                },
                project: {
                  type: "string",
                  description: "Project name",
                },
                context: {
                  type: "object",
                  description: "Context to pass (decisions made, work completed, etc.)",
                },
                task: {
                  type: "string",
                  description: "Task description for target agent",
                },
              },
              required: ["fromAgent", "toAgent", "project", "context", "task"],
            },
          },
          {
            name: "complete_handoff",
            description: "Mark a handoff as completed after accepting and processing it.",
            inputSchema: {
              type: "object",
              properties: {
                handoffId: {
                  type: "string",
                  description: "Handoff ID to complete",
                },
              },
              required: ["handoffId"],
            },
          },
          {
            name: "search_memories",
            description: "Full-text search across memory content. Useful for finding specific information.",
            inputSchema: {
              type: "object",
              properties: {
                query: {
                  type: "string",
                  description: "Search query",
                },
                project: {
                  type: "string",
                  description: "Limit search to project (optional)",
                },
                limit: {
                  type: "number",
                  description: "Maximum results (default: 10)",
                  default: 10,
                },
              },
              required: ["query"],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      await this.ensureDirectories();

      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "store_memory":
            return await this.storeMemory(args);
          case "recall_memory":
            return await this.recallMemory(args);
          case "get_project_state":
            return await this.getProjectState(args);
          case "update_project_state":
            return await this.updateProjectState(args);
          case "list_projects":
            return await this.listProjects(args);
          case "get_agent_handoff":
            return await this.getAgentHandoff(args);
          case "create_agent_handoff":
            return await this.createAgentHandoff(args);
          case "complete_handoff":
            return await this.completeHandoff(args);
          case "search_memories":
            return await this.searchMemories(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        return {
          content: [
            {
              type: "text",
              text: `Error: ${errorMessage}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  private async storeMemory(args: any) {
    const { agent, type, content, project, tags = [] } = args;

    const memory: Memory = {
      id: this.generateId(),
      timestamp: new Date().toISOString(),
      agent,
      type,
      content,
      project,
      tags,
    };

    const dir = project ? path.join(PROJECTS_DIR, project, "memories") : SHARED_DIR;
    await fs.mkdir(dir, { recursive: true });

    const filename = `${memory.id}.json`;
    await fs.writeFile(path.join(dir, filename), JSON.stringify(memory, null, 2));

    // Also update project state to track agent involvement
    if (project) {
      await this.trackAgentInProject(project, agent);
    }

    return {
      content: [
        {
          type: "text",
          text: `Memory stored successfully.\nID: ${memory.id}\nLocation: ${project || "shared"}/${filename}`,
        },
      ],
    };
  }

  private async recallMemory(args: any) {
    const { agent, type, project, tags = [], limit = 10 } = args;
    const maxLimit = Math.min(limit, 100);

    const dirs: string[] = [];
    if (project) {
      dirs.push(path.join(PROJECTS_DIR, project, "memories"));
    } else {
      // Search all projects + shared
      try {
        const projects = await fs.readdir(PROJECTS_DIR);
        for (const proj of projects) {
          dirs.push(path.join(PROJECTS_DIR, proj, "memories"));
        }
      } catch {}
      dirs.push(SHARED_DIR);
    }

    const memories: Memory[] = [];

    for (const dir of dirs) {
      try {
        const files = await fs.readdir(dir);
        for (const file of files) {
          if (!file.endsWith(".json")) continue;

          const content = await fs.readFile(path.join(dir, file), "utf-8");
          const memory: Memory = JSON.parse(content);

          // Apply filters
          if (agent && memory.agent !== agent) continue;
          if (type && memory.type !== type) continue;
          if (tags.length > 0 && !tags.some((t: string) => memory.tags?.includes(t))) continue;

          memories.push(memory);
        }
      } catch {}
    }

    // Sort by timestamp descending
    memories.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

    const results = memories.slice(0, maxLimit);

    return {
      content: [
        {
          type: "text",
          text: results.length > 0
            ? `Found ${results.length} memories:\n\n${JSON.stringify(results, null, 2)}`
            : "No memories found matching criteria.",
        },
      ],
    };
  }

  private async getProjectState(args: any) {
    const { project } = args;

    const stateFile = path.join(PROJECTS_DIR, project, "_state.json");

    try {
      const content = await fs.readFile(stateFile, "utf-8");
      const state: ProjectState = JSON.parse(content);

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(state, null, 2),
          },
        ],
      };
    } catch {
      // Return default state for new project
      const defaultState: ProjectState = {
        project,
        status: "new",
        agents: [],
        created: new Date().toISOString(),
        lastUpdated: new Date().toISOString(),
      };

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(defaultState, null, 2),
          },
        ],
      };
    }
  }

  private async updateProjectState(args: any) {
    const { project, status, currentPhase, metadata } = args;

    await fs.mkdir(path.join(PROJECTS_DIR, project), { recursive: true });

    const stateFile = path.join(PROJECTS_DIR, project, "_state.json");

    return await this.withFileLock(stateFile, async () => {
      let state: ProjectState;
      try {
        const content = await fs.readFile(stateFile, "utf-8");
        state = JSON.parse(content);
      } catch {
        state = {
          project,
          status: "new",
          agents: [],
          created: new Date().toISOString(),
          lastUpdated: new Date().toISOString(),
        };
      }

      // Merge updates
      if (status) state.status = status;
      if (currentPhase) state.currentPhase = currentPhase;
      if (metadata) {
        state.metadata = { ...state.metadata, ...metadata };
      }
      state.lastUpdated = new Date().toISOString();

      await fs.writeFile(stateFile, JSON.stringify(state, null, 2));

      return {
        content: [
          {
            type: "text",
            text: `Project state updated successfully.\n\n${JSON.stringify(state, null, 2)}`,
          },
        ],
      };
    });
  }

  private async trackAgentInProject(project: string, agent: string) {
    const stateFile = path.join(PROJECTS_DIR, project, "_state.json");

    await this.withFileLock(stateFile, async () => {
      let state: ProjectState;
      try {
        const content = await fs.readFile(stateFile, "utf-8");
        state = JSON.parse(content);
      } catch {
        state = {
          project,
          status: "new",
          agents: [],
          created: new Date().toISOString(),
          lastUpdated: new Date().toISOString(),
        };
      }

      if (!state.agents.includes(agent)) {
        state.agents.push(agent);
        state.lastUpdated = new Date().toISOString();
        await fs.writeFile(stateFile, JSON.stringify(state, null, 2));
      }
    });
  }

  private async listProjects(args: any) {
    const { status } = args;

    try {
      const projects = await fs.readdir(PROJECTS_DIR);
      const projectStates: ProjectState[] = [];

      for (const project of projects) {
        const stateFile = path.join(PROJECTS_DIR, project, "_state.json");
        try {
          const content = await fs.readFile(stateFile, "utf-8");
          const state: ProjectState = JSON.parse(content);

          if (!status || state.status === status) {
            projectStates.push(state);
          }
        } catch {}
      }

      // Sort by lastUpdated descending
      projectStates.sort((a, b) =>
        new Date(b.lastUpdated).getTime() - new Date(a.lastUpdated).getTime()
      );

      return {
        content: [
          {
            type: "text",
            text: projectStates.length > 0
              ? `Found ${projectStates.length} projects:\n\n${JSON.stringify(projectStates, null, 2)}`
              : "No projects found.",
          },
        ],
      };
    } catch {
      return {
        content: [
          {
            type: "text",
            text: "No projects found.",
          },
        ],
      };
    }
  }

  private async getAgentHandoff(args: any) {
    const { toAgent, project, fromAgent } = args;

    const handoffDir = path.join(PROJECTS_DIR, project, "handoffs");

    try {
      const files = await fs.readdir(handoffDir);
      const handoffs: Handoff[] = [];

      for (const file of files) {
        if (!file.endsWith(".json")) continue;

        const content = await fs.readFile(path.join(handoffDir, file), "utf-8");
        const handoff: Handoff = JSON.parse(content);

        if (handoff.to === toAgent && handoff.status === "pending") {
          if (!fromAgent || handoff.from === fromAgent) {
            handoffs.push(handoff);
          }
        }
      }

      if (handoffs.length > 0) {
        // Sort by timestamp, oldest first
        handoffs.sort((a, b) =>
          new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
        );

        const handoff = handoffs[0]; // Return oldest pending handoff

        // Auto-accept: mark as "accepted" so it won't be returned again.
        // If the receiving agent crashes, the handoff stays on disk in
        // "accepted" state instead of being deleted. A retry or manual
        // recovery can find it.  Use complete_handoff when truly done.
        const handoffFile = path.join(handoffDir, `${handoff.id}.json`);
        await this.withFileLock(handoffFile, async () => {
          handoff.status = "accepted";
          await fs.writeFile(handoffFile, JSON.stringify(handoff, null, 2));
        });

        return {
          content: [
            {
              type: "text",
              text: `Found handoff from ${handoff.from} (auto-accepted):\n\n${JSON.stringify(handoff, null, 2)}`,
            },
          ],
        };
      }

      return {
        content: [
          {
            type: "text",
            text: "No pending handoffs found.",
          },
        ],
      };
    } catch {
      return {
        content: [
          {
            type: "text",
            text: "No pending handoffs found.",
          },
        ],
      };
    }
  }

  private async createAgentHandoff(args: any) {
    const { fromAgent, toAgent, project, context, task } = args;

    const handoff: Handoff = {
      id: this.generateId(),
      from: fromAgent,
      to: toAgent,
      timestamp: new Date().toISOString(),
      context,
      task,
      project,
      status: "pending",
    };

    const handoffDir = path.join(PROJECTS_DIR, project, "handoffs");
    await fs.mkdir(handoffDir, { recursive: true });

    const filename = `${handoff.id}.json`;
    await fs.writeFile(path.join(handoffDir, filename), JSON.stringify(handoff, null, 2));

    return {
      content: [
        {
          type: "text",
          text: `Handoff created successfully.\nFrom: ${fromAgent}\nTo: ${toAgent}\nID: ${handoff.id}\nTask: ${task}`,
        },
      ],
    };
  }

  private async completeHandoff(args: any) {
    const { handoffId } = args;

    // Search all projects for this handoff
    const projects = await fs.readdir(PROJECTS_DIR);

    for (const project of projects) {
      const handoffDir = path.join(PROJECTS_DIR, project, "handoffs");
      try {
        const files = await fs.readdir(handoffDir);
        for (const file of files) {
          if (file.startsWith(handoffId)) {
            const handoffFile = path.join(handoffDir, file);
            const content = await fs.readFile(handoffFile, "utf-8");
            const handoff: Handoff = JSON.parse(content);

            handoff.status = "completed";
            await fs.writeFile(handoffFile, JSON.stringify(handoff, null, 2));

            return {
              content: [
                {
                  type: "text",
                  text: `Handoff ${handoffId} marked as completed.`,
                },
              ],
            };
          }
        }
      } catch {}
    }

    return {
      content: [
        {
          type: "text",
          text: `Handoff ${handoffId} not found.`,
        },
      ],
    };
  }

  private async searchMemories(args: any) {
    const { query, project, limit = 10 } = args;
    const maxLimit = Math.min(limit, 100);

    const dirs: string[] = [];
    if (project) {
      dirs.push(path.join(PROJECTS_DIR, project, "memories"));
    } else {
      try {
        const projects = await fs.readdir(PROJECTS_DIR);
        for (const proj of projects) {
          dirs.push(path.join(PROJECTS_DIR, proj, "memories"));
        }
      } catch {}
      dirs.push(SHARED_DIR);
    }

    const memories: Memory[] = [];
    const lowerQuery = query.toLowerCase();

    for (const dir of dirs) {
      try {
        const files = await fs.readdir(dir);
        for (const file of files) {
          if (!file.endsWith(".json")) continue;

          const content = await fs.readFile(path.join(dir, file), "utf-8");
          const memory: Memory = JSON.parse(content);

          // Simple text search in content
          const contentStr = JSON.stringify(memory.content).toLowerCase();
          if (contentStr.includes(lowerQuery)) {
            memories.push(memory);
          }
        }
      } catch {}
    }

    // Sort by timestamp descending
    memories.sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());

    const results = memories.slice(0, maxLimit);

    return {
      content: [
        {
          type: "text",
          text: results.length > 0
            ? `Found ${results.length} memories matching "${query}":\n\n${JSON.stringify(results, null, 2)}`
            : `No memories found matching "${query}".`,
        },
      ],
    };
  }

  private setupResourceHandlers() {
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      await this.ensureDirectories();

      const resources = [];

      // List all projects as resources
      try {
        const projects = await fs.readdir(PROJECTS_DIR);
        for (const project of projects) {
          resources.push({
            uri: `memory://project/${project}`,
            name: `Project: ${project}`,
            mimeType: "application/json",
            description: `State and memories for project ${project}`,
          });
        }
      } catch {}

      return { resources };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
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
          const defaultState = {
            project,
            status: "new",
            agents: [],
            created: new Date().toISOString(),
            lastUpdated: new Date().toISOString(),
          };

          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(defaultState, null, 2),
              },
            ],
          };
        }
      }

      throw new Error(`Unknown resource URI: ${uri}`);
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);

    console.error("Claude Memory MCP Server running on stdio");
  }
}

const server = new MemoryServer();
server.run().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
