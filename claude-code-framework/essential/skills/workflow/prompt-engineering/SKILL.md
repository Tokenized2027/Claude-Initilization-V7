---
name: prompt-engineering
description: Optimize prompts for Claude Code agents, API calls, and multi-agent orchestration. Use when writing system prompts, agent instructions, or refining LLM interactions. Triggers on "improve prompt", "write a prompt", "agent instructions", "system prompt", "prompt not working", "LLM output quality".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: workflow
  source: community-contributed
  license: MIT
---

# Prompt Engineering

Design prompts that produce reliable, high-quality output from Claude and other LLMs — especially for autonomous agent workflows.

## Why This Exists

Bad prompts produce inconsistent agent output, burn tokens, and require human intervention. Good prompts let your mini PC agents run autonomously with predictable results.

## Instructions

### Step 1: Define the Output Contract

Before writing any prompt, answer:

1. **What format?** (JSON, Markdown, code, plain text)
2. **What structure?** (sections, fields, length)
3. **What quality bar?** (production-ready, draft, outline)

Example:
> "I need a JSON object with fields: `title` (string, <60 chars), `description` (string, 1-3 sentences), `priority` (low|medium|high)"

### Step 2: Apply the Prompt Structure

Every effective prompt has these layers:

```
ROLE        → Who the AI is (expertise, constraints)
CONTEXT     → What it needs to know (background, data)
TASK        → What to do (specific, measurable)
FORMAT      → How to output (structure, examples)
GUARDRAILS  → What NOT to do (common failure modes)
```

**Template:**
```markdown
You are a [ROLE] with expertise in [DOMAIN].

## Context
[Background information the model needs]

## Task
[Specific, measurable instruction]

## Output Format
[Exact structure expected — include an example]

## Rules
- [Guardrail 1: what to avoid]
- [Guardrail 2: edge case handling]
- [Guardrail 3: quality requirement]
```

### Step 3: Add Examples (Few-Shot)

One good example beats 100 words of instruction.

```markdown
## Example

Input: "Build a user dashboard"
Output:
{
  "title": "User Analytics Dashboard",
  "components": ["stats-bar", "activity-chart", "recent-actions-table"],
  "data_sources": ["/api/users/stats", "/api/users/activity"],
  "priority": "high"
}
```

For complex tasks, provide 2-3 examples showing different edge cases.

### Step 4: Add Chain-of-Thought for Complex Tasks

For multi-step reasoning, explicitly request thinking:

```markdown
## Task
Analyze this API response and determine if the integration is healthy.

Think step by step:
1. Check if the status code is 2xx
2. Check if the response time is under 500ms
3. Check if required fields are present
4. Summarize health status
```

### Step 5: Optimize for Token Efficiency

For autonomous agents burning API credits:

- **Cut filler words:** "Please kindly" → just state the task
- **Use structured output:** JSON/YAML → easier to parse, fewer tokens to correct
- **Front-load critical info:** Put the most important context first
- **Set max_tokens appropriately:** Don't allocate 4096 when 500 suffices
- **Cache system prompts:** Use prompt caching for repeated agent instructions

## Patterns for Mini PC Agents

### Pattern: Agent System Prompt

```markdown
You are the [AGENT_NAME] agent in a multi-agent system.

## Your Role
[2-3 sentences on what you do]

## Memory Protocol
- Read project memory before starting any task
- Write decisions and patterns to memory after completing work
- Check for handoff notes from previous agents

## Task Workflow
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output Requirements
- Write complete files only — never partial snippets
- Include all imports
- Test before declaring done

## Handoff
When complete, write a handoff note with:
- What you built
- What's left for the next agent
- Any blockers or decisions deferred
```

### Pattern: Orchestrator Task Routing

```markdown
Given this task description, determine which agent should handle it.

Agents available:
- frontend-developer: UI, React, dashboards, components
- backend-developer: APIs, database, server logic
- system-architect: design decisions, tech stack, architecture
- devops-engineer: Docker, deployment, CI/CD, monitoring

Task: "{task_description}"

Respond with ONLY a JSON object:
{"agent": "agent-name", "reason": "one sentence", "subtasks": ["if applicable"]}
```

### Pattern: Quality Gate Prompt

```markdown
Review this code for production readiness. Check EACH of these:

1. Error handling: Are all error paths covered?
2. Types: Are TypeScript types complete (no `any`)?
3. Edge cases: What happens with empty data, null values, large inputs?
4. Security: Any hardcoded secrets, SQL injection, XSS vectors?
5. Performance: Any N+1 queries, unbounded loops, memory leaks?

For each check, respond:
- ✅ PASS: [brief note]
- ❌ FAIL: [what's wrong + fix]
```

## Common Prompt Failures and Fixes

| Failure | Cause | Fix |
|---------|-------|-----|
| Inconsistent output format | No format specification | Add explicit format + example |
| Hallucinated data | Insufficient context | Provide the actual data in the prompt |
| Too verbose | No length constraint | Add "Respond in under X words/lines" |
| Ignores instructions | Instructions buried at the end | Move critical rules to the top |
| Wrong code language | Ambiguous tech stack | Specify language + version explicitly |
| Agent goes off-task | Vague task description | Use the ROLE-CONTEXT-TASK-FORMAT structure |

## When to Use This Skill

✅ Use prompt-engineering when:
- Writing or updating agent system prompts
- Agent output quality is inconsistent
- Building new orchestrator routes
- Setting up LLM API calls in applications
- Reducing token costs on repetitive tasks

❌ Don't use prompt-engineering for:
- Debugging code (use systematic-debugging)
- Writing user-facing copy (use content skills)
- One-off questions to Claude (just ask)
