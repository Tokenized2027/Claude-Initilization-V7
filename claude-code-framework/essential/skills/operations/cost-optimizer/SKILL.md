---
name: cost-optimizer
description: Monitor and reduce costs for Claude API, cloud infrastructure, and multi-agent operations. Use when costs are rising, before scaling agents, or for monthly cost reviews. Triggers on "costs too high", "API spending", "token usage", "optimize costs", "budget", "reduce spend".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: operations
  source: community-contributed
  license: MIT
---

# Cost Optimizer

Track, analyze, and reduce costs for your AI agent infrastructure — Claude API, cloud services, and mini PC operations.

## Why This Exists

Running 15 autonomous agents burns through API credits fast. Without visibility and controls, you can blow through hundreds of dollars in a day on bad prompts or stuck agents.

## Instructions

### Step 1: Measure Current Costs

Before optimizing, know what you're spending.

**Claude API cost check:**
```bash
# Check recent API usage (if using Anthropic API directly)
# Estimated cost per model:
# Claude Sonnet 4.5: $3/M input, $15/M output
# Claude Haiku 4.5: $0.80/M input, $4/M output

# Count tokens in recent agent logs
grep -rn "tokens_used" ~/claude-multi-agent/logs/ | \
  awk -F'tokens_used:' '{sum+=$2} END {print "Total tokens:", sum}'
```

**Docker resource check:**
```bash
# See what's eating resources on the mini PC
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Step 2: Apply the Cost Hierarchy

Optimize in this order (biggest savings first):

#### 1. Use the Right Model for the Task

| Task Type | Model | Est. Cost/1K tasks |
|-----------|-------|-------------------|
| Routing/classification | Haiku | $0.05 |
| Code generation | Sonnet | $1.50 |
| Architecture decisions | Opus | $5.00 |
| Simple formatting | Haiku | $0.02 |

**Rule:** Default to Haiku for everything. Escalate to Sonnet only for code gen. Use Opus only for complex architecture/planning.

#### 2. Enable Prompt Caching

System prompts for agents are repeated on every call. Cache them:

```python
# In orchestrator.py — use prompt caching for agent system prompts
response = client.messages.create(
    model="claude-sonnet-4-5-20250514",
    max_tokens=4096,
    system=[
        {
            "type": "text",
            "text": AGENT_SYSTEM_PROMPT,  # Long system prompt
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=messages
)
# Cached input tokens cost 90% less
```

#### 3. Reduce Context Window Size

Each agent call includes context. Trim it:

- **Memory:** Only load relevant project memories, not all memories
- **File contents:** Pass file summaries, not entire files (unless editing)
- **History:** Truncate conversation history to last 5-10 messages
- **Code:** Send only the function/module being worked on, not the whole file

#### 4. Set Token Limits

```python
# In orchestrator.py
MAX_TOKENS_BY_TASK = {
    "routing": 200,
    "code_review": 1000,
    "code_generation": 4000,
    "architecture": 2000,
    "formatting": 500,
}
```

#### 5. Add Circuit Breakers

Stop runaway agents:

```python
# Per-agent daily budget (in estimated USD)
AGENT_DAILY_BUDGET = {
    "frontend-developer": 5.00,
    "backend-developer": 5.00,
    "system-architect": 3.00,
    "system-tester": 2.00,
    "devops-engineer": 2.00,
}

# Per-task iteration limit
MAX_ITERATIONS_PER_TASK = 10  # If agent needs >10 LLM calls, flag for human review
```

### Step 3: Monthly Cost Review Checklist

Run this on the 1st of every month:

```markdown
## Monthly Cost Review — [Month Year]

### API Costs
- Total API spend: $___
- Breakdown by agent: [list]
- Highest-cost task: [describe]
- Tokens wasted on failed/retried tasks: ___

### Infrastructure Costs
- Mini PC electricity: ~$___ (est. 40W × 24h × 30d)
- Domain/DNS: $___
- Any cloud services: $___

### Optimization Actions
- [ ] Review top 5 most expensive tasks — can any use Haiku?
- [ ] Check for stuck/looping agents in logs
- [ ] Verify prompt caching is active
- [ ] Review context window sizes
- [ ] Update token limits if needed

### Budget vs Actual
- Budget: $___/month
- Actual: $___/month
- Variance: ___
```

## Quick Wins

| Action | Savings | Effort |
|--------|---------|--------|
| Switch routing to Haiku | 80-90% on routing calls | Low |
| Enable prompt caching | 60-90% on system prompts | Low |
| Set max_tokens per task type | 20-40% on over-generation | Low |
| Add iteration circuit breakers | Prevents runaway costs | Medium |
| Trim context to relevant files only | 30-50% on input tokens | Medium |

## When to Use This Skill

✅ Use cost-optimizer when:
- Monthly costs exceed budget
- Scaling from 2 to 15 agents
- Before deploying new agent workflows
- Monthly review cycle

❌ Don't use for:
- One-off development tasks
- Debugging agent behavior (use systematic-debugging)
- Infrastructure issues (use docker-debugger or devops agent)
