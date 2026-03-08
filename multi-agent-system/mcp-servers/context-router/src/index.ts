#!/usr/bin/env node

/**
 * Claude Context Router MCP Server
 *
 * Auto-detects task types and loads appropriate context files.
 * Eliminates manual file loading — agents always get the right docs.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import fs from "fs/promises";
import path from "path";

// Configurable paths via environment variables
const CLAUDE_DIR = process.env.CLAUDE_RESOURCES_DIR || path.join(process.env.HOME || "/tmp", "Desktop/Claude");
const CONTEXT_DIR = path.join(CLAUDE_DIR, "project-contexts");
const PROFILE_PATH = path.join(CLAUDE_DIR, "YOUR_WORKING_PROFILE.md");
const WORKFLOW_PATH = path.join(CLAUDE_DIR, "YOUR_PROJECT_WORKFLOW.md");

interface ContextMapping {
  taskType: string;
  label: string;
  keywords: string[];
  files: string[];
  agent: string;
}

const CONTEXT_MAPPINGS: ContextMapping[] = [
  // --- Project content tasks ---
  {
    taskType: "project-social",
    label: "Project Social Media",
    keywords: ["tweet", "twitter", "social", "post", "thread", "announcement", "x.com"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "02-working-guidelines.md"),
      WORKFLOW_PATH,
    ],
    agent: "content-creator",
  },
  {
    taskType: "project-support",
    label: "Project Technical Support",
    keywords: ["support", "help", "user question", "troubleshoot", "how do i", "stuck", "error"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "03-protocol-technical.md"),
      path.join(CONTEXT_DIR, "project", "05-user-guides-faq.md"),
    ],
    agent: "support-specialist",
  },
  {
    taskType: "project-governance",
    label: "Project Governance / Governance",
    keywords: ["proposal", "governance", "vote", "snapshot", "dao", "council"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "04-protocol-governance.md"),
      WORKFLOW_PATH,
    ],
    agent: "governance-specialist",
  },
  {
    taskType: "project-partnership",
    label: "Project Partnership / BD",
    keywords: ["partnership", "integration", "business development", "bd", "outreach", "deal"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "02-working-guidelines.md"),
      path.join(CONTEXT_DIR, "project", "03-protocol-technical.md"),
      WORKFLOW_PATH,
    ],
    agent: "bd-specialist",
  },
  {
    taskType: "project-content",
    label: "Project Long-form Content",
    keywords: ["blog", "article", "documentation", "guide", "write up", "explainer", "long-form"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "02-working-guidelines.md"),
      path.join(CONTEXT_DIR, "project", "03-protocol-technical.md"),
      WORKFLOW_PATH,
    ],
    agent: "content-creator",
  },
  {
    taskType: "project-analytics",
    label: "Project Analytics / Data",
    keywords: ["analytics", "metrics", "tvl", "apy", "data", "monitor", "report", "stats"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "01-quick-reference.md"),
      path.join(CONTEXT_DIR, "project", "03-protocol-technical.md"),
      path.join(CONTEXT_DIR, "project", "06-reference-appendices.md"),
    ],
    agent: "frontend-developer",
  },
  {
    taskType: "project-lookup",
    label: "Project Quick Lookup",
    keywords: ["address", "contract", "link", "glossary", "term", "competitor"],
    files: [
      path.join(CONTEXT_DIR, "project", "06-reference-appendices.md"),
    ],
    agent: "generalist",
  },

  // --- Coding tasks ---
  {
    taskType: "coding-dashboard",
    label: "Build Dashboard / UI",
    keywords: ["dashboard", "chart", "visualization", "ui", "interface", "component", "page", "layout"],
    files: [PROFILE_PATH],
    agent: "frontend-developer",
  },
  {
    taskType: "coding-api",
    label: "Build API / Backend",
    keywords: ["api", "endpoint", "backend", "server", "route", "database", "query"],
    files: [PROFILE_PATH],
    agent: "backend-developer",
  },
  {
    taskType: "coding-web3",
    label: "Web3 Integration",
    keywords: ["web3", "contract", "wallet", "ethers", "viem", "wagmi", "staking", "defi", "erc20", "token"],
    files: [
      PROFILE_PATH,
      path.join(CONTEXT_DIR, "project", "03-protocol-technical.md"),
    ],
    agent: "backend-developer",
  },
  {
    taskType: "coding-devops",
    label: "Docker / Deployment",
    keywords: ["docker", "deploy", "vercel", "ci", "cd", "pipeline", "container", "nginx"],
    files: [PROFILE_PATH],
    agent: "devops-engineer",
  },
  {
    taskType: "coding-debug",
    label: "Debugging / Fix",
    keywords: ["bug", "fix", "error", "crash", "broken", "not working", "debug", "failing"],
    files: [PROFILE_PATH],
    agent: "frontend-developer",
  },
  {
    taskType: "coding-test",
    label: "Testing",
    keywords: ["test", "spec", "jest", "playwright", "e2e", "unit test", "integration test"],
    files: [PROFILE_PATH],
    agent: "system-tester",
  },
  {
    taskType: "coding-security",
    label: "Security Review",
    keywords: ["security", "audit", "vulnerability", "injection", "xss", "auth"],
    files: [PROFILE_PATH],
    agent: "security-auditor",
  },
  {
    taskType: "coding-prototype",
    label: "Quick Prototype / POC",
    keywords: ["prototype", "poc", "proof of concept", "experiment", "quick", "try", "test idea"],
    files: [PROFILE_PATH],
    agent: "frontend-developer",
  },

  // --- Architecture / Planning ---
  {
    taskType: "planning-architecture",
    label: "Architecture / System Design",
    keywords: ["architecture", "design", "plan", "structure", "system", "scalable", "schema"],
    files: [PROFILE_PATH],
    agent: "system-architect",
  },
  {
    taskType: "planning-prd",
    label: "Product Requirements",
    keywords: ["prd", "requirements", "feature", "scope", "roadmap", "milestone", "spec"],
    files: [PROFILE_PATH],
    agent: "product-manager",
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

    this.setupToolHandlers();
  }

  private detectTaskType(input: string): ContextMapping {
    const lower = input.toLowerCase();

    // Score each mapping by keyword matches
    let bestMatch: ContextMapping | null = null;
    let bestScore = 0;

    for (const mapping of CONTEXT_MAPPINGS) {
      let score = 0;
      for (const keyword of mapping.keywords) {
        if (lower.includes(keyword)) {
          // Longer keyword matches are more specific → higher score
          score += keyword.length;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = mapping;
      }
    }

    // Fallback to general coding
    if (!bestMatch || bestScore === 0) {
      return {
        taskType: "general",
        label: "General Task",
        keywords: [],
        files: [PROFILE_PATH],
        agent: "generalist",
      };
    }

    return bestMatch;
  }

  private async loadFile(filePath: string): Promise<{ path: string; content: string; loaded: boolean }> {
    try {
      const content = await fs.readFile(filePath, "utf-8");
      return { path: filePath, content, loaded: true };
    } catch {
      return { path: filePath, content: "", loaded: false };
    }
  }

  private async loadContextFiles(files: string[]): Promise<string> {
    const results = await Promise.all(files.map((f) => this.loadFile(f)));

    const sections: string[] = [];
    const missing: string[] = [];

    for (const result of results) {
      const basename = path.basename(result.path);
      if (result.loaded) {
        sections.push(`\n\n--- BEGIN: ${basename} ---\n\n${result.content}\n\n--- END: ${basename} ---`);
      } else {
        missing.push(basename);
      }
    }

    let output = sections.join("\n");

    if (missing.length > 0) {
      output += `\n\n--- WARNING: Missing files: ${missing.join(", ")} ---`;
    }

    return output;
  }

  private setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "auto_load_context",
            description:
              "Automatically detect the task type from a description and load all relevant context files. " +
              "Returns the combined context plus the recommended agent to handle the task. " +
              "Use this at the START of every task to ensure correct context is loaded.",
            inputSchema: {
              type: "object",
              properties: {
                task: {
                  type: "string",
                  description: "Task description or user request to analyze",
                },
              },
              required: ["task"],
            },
          },
          {
            name: "load_specific_context",
            description:
              "Load context files for a specific, known task type. " +
              "Use when you already know the task category.",
            inputSchema: {
              type: "object",
              properties: {
                taskType: {
                  type: "string",
                  description: "Task type to load context for",
                  enum: CONTEXT_MAPPINGS.map((m) => m.taskType),
                },
              },
              required: ["taskType"],
            },
          },
          {
            name: "list_context_types",
            description:
              "List all available context types and their keywords. " +
              "Useful for understanding what task types are supported.",
            inputSchema: {
              type: "object",
              properties: {},
            },
          },
          {
            name: "load_working_profile",
            description:
              "Load the user's working profile (YOUR_WORKING_PROFILE.md). " +
              "Contains communication preferences, tech stack, code delivery rules. " +
              "Should be loaded at the start of EVERY agent session.",
            inputSchema: {
              type: "object",
              properties: {},
            },
          },
          {
            name: "load_project_context",
            description:
              "Load specific Project context files by number (01-06). " +
              "Use when you need specific protocol documentation.",
            inputSchema: {
              type: "object",
              properties: {
                files: {
                  type: "array",
                  items: {
                    type: "string",
                    enum: [
                      "00-master-index",
                      "01-quick-reference",
                      "02-working-guidelines",
                      "03-protocol-technical",
                      "04-protocol-governance",
                      "05-user-guides-faq",
                      "06-reference-appendices",
                    ],
                  },
                  description: "Which Project context files to load",
                },
              },
              required: ["files"],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "auto_load_context":
            return await this.autoLoadContext(args);
          case "load_specific_context":
            return await this.loadSpecificContext(args);
          case "list_context_types":
            return await this.listContextTypes();
          case "load_working_profile":
            return await this.loadWorkingProfile();
          case "load_project_context":
            return await this.loadProjectContext(args);
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        const msg = error instanceof Error ? error.message : String(error);
        return {
          content: [{ type: "text", text: `Error: ${msg}` }],
          isError: true,
        };
      }
    });
  }

  private async autoLoadContext(args: any) {
    const { task } = args;
    const mapping = this.detectTaskType(task);
    const context = await this.loadContextFiles(mapping.files);

    return {
      content: [
        {
          type: "text",
          text: [
            `TASK ANALYSIS`,
            `═══════════════`,
            `Detected Type: ${mapping.label} (${mapping.taskType})`,
            `Recommended Agent: ${mapping.agent}`,
            `Files Loaded: ${mapping.files.map((f) => path.basename(f)).join(", ")}`,
            ``,
            `LOADED CONTEXT`,
            `═══════════════`,
            context,
          ].join("\n"),
        },
      ],
    };
  }

  private async loadSpecificContext(args: any) {
    const { taskType } = args;
    const mapping = CONTEXT_MAPPINGS.find((m) => m.taskType === taskType);

    if (!mapping) {
      throw new Error(`Unknown task type: ${taskType}. Use list_context_types to see available types.`);
    }

    const context = await this.loadContextFiles(mapping.files);

    return {
      content: [
        {
          type: "text",
          text: [
            `Context loaded for: ${mapping.label}`,
            `Recommended agent: ${mapping.agent}`,
            ``,
            context,
          ].join("\n"),
        },
      ],
    };
  }

  private async listContextTypes() {
    const types = CONTEXT_MAPPINGS.map((m) => ({
      taskType: m.taskType,
      label: m.label,
      keywords: m.keywords,
      agent: m.agent,
      fileCount: m.files.length,
    }));

    return {
      content: [
        {
          type: "text",
          text: `Available context types:\n\n${JSON.stringify(types, null, 2)}`,
        },
      ],
    };
  }

  private async loadWorkingProfile() {
    const result = await this.loadFile(PROFILE_PATH);

    if (!result.loaded) {
      return {
        content: [
          {
            type: "text",
            text: `Working profile not found at ${PROFILE_PATH}. Create YOUR_WORKING_PROFILE.md in your Claude resources directory.`,
          },
        ],
      };
    }

    return {
      content: [
        {
          type: "text",
          text: result.content,
        },
      ],
    };
  }

  private async loadProjectContext(args: any) {
    const { files } = args;

    const filePaths = files.map((f: string) =>
      path.join(CONTEXT_DIR, "project", `${f}.md`)
    );

    const context = await this.loadContextFiles(filePaths);

    return {
      content: [
        {
          type: "text",
          text: [
            `Project context loaded:`,
            `Files: ${files.join(", ")}`,
            ``,
            context,
          ].join("\n"),
        },
      ],
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Claude Context Router MCP Server running on stdio");
  }
}

const router = new ContextRouter();
router.run().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
