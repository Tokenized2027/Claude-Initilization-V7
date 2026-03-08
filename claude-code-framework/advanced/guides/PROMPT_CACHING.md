# Prompt Caching — Save 90% on API Costs

> **TL;DR:** Anthropic's Prompt Caching can reduce your Claude API costs by 90% when using repeated context like agent prompts, project briefs, and large files. This guide shows you exactly how to implement it.
>
> **Last Updated:** February 12, 2026

---

## What Is Prompt Caching?

Prompt caching lets you reuse large chunks of context across multiple API calls **without paying for the repeated tokens every time**. Instead of paying full price for the same 5,000-token agent prompt in every conversation, you pay once to cache it, then only 10% of the cost to retrieve it.

### The Numbers

| Cost Type | Price per 1M tokens |
|-----------|-------------------|
| Regular input tokens | $3.00 |
| **Cache write** (first time) | $3.75 |
| **Cache read** (subsequent uses) | **$0.30** |

**90% savings** on repeated content after the first cache write.

### Real Example: Agent Conversation Costs

You're talking to your Frontend Developer agent with a 3,000-token system prompt (shared context + agent prompt):

**Without caching:**
- Every message: 3,000 tokens × $3.00/1M = **$0.009 per message**
- 50 messages in a session: **$0.45**

**With caching:**
- First message: 3,000 tokens × $3.75/1M = **$0.01125** (cache write)
- Next 49 messages: 3,000 tokens × $0.30/1M = **$0.0009 per message** = **$0.044**
- Total for 50 messages: **$0.055**

**Savings:** $0.45 → $0.055 = **88% reduction**

---

## How Caching Works

1. You mark parts of your prompt with `"cache_control": {"type": "ephemeral"}`
2. Anthropic caches that content for **5 minutes** of inactivity
3. Subsequent requests with the same cached content pay reduced rates
4. Cache refreshes automatically on each use (5-minute timer resets)

### Cache Lifecycle

```
Message 1: Cache MISS → Full price + cache write
Message 2 (within 5 min): Cache HIT → 90% discount
Message 3 (within 5 min): Cache HIT → 90% discount
[6 minutes pass with no requests]
Message 4: Cache MISS → Full price + cache write again
```

### What Can Be Cached

✅ **Perfect for caching:**
- Agent system prompts (3,000-5,000 tokens, repeated every message)
- Project briefs (2,000-3,000 tokens, pasted every conversation)
- Large documentation files (code, specs, logs)
- Reference materials (style guides, API docs)
- Long conversation history (if you're continuing a thread)

❌ **Don't cache:**
- User messages (they change every time)
- Short content (<1,000 tokens — not worth the cache overhead)
- Rapidly changing data

---

## Implementation Examples

### 1. Caching Agent System Prompts

This is your **highest-ROI use case** because every agent conversation starts with the same long system prompt.

**Current setup** (no caching):
```javascript
// In your Claude Projects or API calls
const systemPrompt = `
${sharedContext}  // 2,000 tokens
${agentSpecificPrompt}  // 1,500 tokens
`;

const response = await anthropic.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1024,
  system: systemPrompt,  // Pays full price every message
  messages: [
    { role: "user", content: userMessage }
  ]
});
```

**With caching** (90% savings after first message):
```javascript
const response = await anthropic.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1024,
  system: [
    {
      type: "text",
      text: sharedContext  // 2,000 tokens
    },
    {
      type: "text",
      text: agentSpecificPrompt,  // 1,500 tokens
      cache_control: { type: "ephemeral" }  // ← Cache everything up to here
    }
  ],
  messages: [
    { role: "user", content: userMessage }
  ]
});
```

**Result:** 3,500 tokens cached. First message: full price. Every subsequent message in the next 5 minutes: 90% discount on those 3,500 tokens.

---

### 2. Caching Project Briefs

Your project brief gets pasted at the start of every new conversation. Cache it!

**Setup:**
```javascript
const response = await anthropic.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1024,
  system: [
    {
      type: "text",
      text: sharedContext
    },
    {
      type: "text",
      text: agentPrompt,
      cache_control: { type: "ephemeral" }
    }
  ],
  messages: [
    {
      role: "user",
      content: [
        {
          type: "text",
          text: projectBrief,  // Your 2,000-token project brief
          cache_control: { type: "ephemeral" }  // ← Cache the brief
        },
        {
          type: "text",
          text: "Let's add a new component for user profiles."
        }
      ]
    }
  ]
});
```

**Result:** Both system prompt AND project brief are cached. Total cached: ~5,500 tokens. 90% savings on every message.

---

### 3. Caching Large Files (Code, Docs, Logs)

When you're asking Claude Code to analyze or modify large files, cache them.

**Example: Debugging with a large log file**
```javascript
const logContents = fs.readFileSync('logs/app.log', 'utf-8');  // 10,000 tokens

const response = await anthropic.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1024,
  system: [
    {
      type: "text",
      text: systemPrompt
    },
    {
      type: "text",
      text: `Here is the full application log:

${logContents}`,
      cache_control: { type: "ephemeral" }  // ← Cache the log
    }
  ],
  messages: [
    {
      role: "user",
      content: "Find all errors related to database connections."
    }
  ]
});
```

**Follow-up questions:** "What about Redis errors?" "Show me the timeline of failures." — Each subsequent question pays only 10% to read that 10,000-token log again.

---

### 4. Multi-Cache Strategy (Advanced)

You can cache **multiple sections** by placing cache markers at different points. Anthropic caches everything from the start up to each marker.

**Example: System prompt + project brief + large codebase**
```javascript
const response = await anthropic.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 1024,
  system: [
    {
      type: "text",
      text: sharedContext + agentPrompt,  // 3,500 tokens
      cache_control: { type: "ephemeral" }  // Cache marker 1
    }
  ],
  messages: [
    {
      role: "user",
      content: [
        {
          type: "text",
          text: projectBrief,  // 2,000 tokens
          cache_control: { type: "ephemeral" }  // Cache marker 2
        },
        {
          type: "text",
          text: codebaseSnapshot,  // 15,000 tokens
          cache_control: { type: "ephemeral" }  // Cache marker 3
        },
        {
          type: "text",
          text: "Refactor the authentication flow to use JWT tokens."
        }
      ]
    }
  ]
});
```

**Total cached:** 20,500 tokens across three cache segments. If any of these change (e.g., you update the project brief), only the changed section gets re-cached. The others stay cached.

---

## Integration with Your Workflow

### For Claude Projects (claude.ai)

Claude Projects **don't expose direct API access**, but you can still benefit from caching by structuring your prompts optimally:

1. **System Prompt:** Already cached automatically by Claude Projects
2. **Project Knowledge:** Files uploaded to the project are cached
3. **Opening Message:** Start every conversation with the same project brief structure — Claude's backend will likely cache it

**Pro tip:** Keep your project brief as a dedicated file in Project Knowledge. Reference it by name rather than pasting it every time.

---

### For Claude Code CLI

Claude Code uses the Anthropic API directly, so you control caching.

**Current limitation:** Claude Code CLI doesn't expose cache control flags directly (as of February 2026). You'd need to:

1. Use the API directly for cached contexts
2. Build a wrapper script that handles caching
3. Wait for Claude Code to add native caching support

**Workaround for now:**
```bash
# Create a wrapper script that calls the API with caching
#!/bin/bash
# claude-cached.sh

SYSTEM_PROMPT=$(cat $CLAUDE_HOME/claude-code-framework/essential/agents/01-shared-context.md)
AGENT_PROMPT=$(cat $CLAUDE_HOME/claude-code-framework/essential/agents/05-designer.md)

curl https://api.anthropic.com/v1/messages \
  -H "content-type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4-6",
    "max_tokens": 4096,
    "system": [
      {
        "type": "text",
        "text": "'"$SYSTEM_PROMPT"'"
      },
      {
        "type": "text",
        "text": "'"$AGENT_PROMPT"'",
        "cache_control": {"type": "ephemeral"}
      }
    ],
    "messages": [
      {
        "role": "user",
        "content": "'"$1"'"
      }
    ]
  }'
```

Use it: `./claude-cached.sh "Add a user profile component"`

---

### For Custom Applications

If you're building apps that call Claude's API (like your analytics dashboard), caching is straightforward:

```typescript
// utils/claude-client.ts
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

export async function callClaudeWithCache(
  userMessage: string,
  cachedContext?: string
) {
  const systemBlocks = [
    {
      type: "text" as const,
      text: "You are a helpful AI assistant."
    }
  ];

  if (cachedContext) {
    systemBlocks.push({
      type: "text" as const,
      text: cachedContext,
      cache_control: { type: "ephemeral" as const }
    });
  }

  const response = await client.messages.create({
    model: "claude-opus-4-6",
    max_tokens: 1024,
    system: systemBlocks,
    messages: [
      { role: "user", content: userMessage }
    ]
  });

  return response.content[0].text;
}
```

Usage:
```typescript
const largeContext = fs.readFileSync('docs/protocol-spec.md', 'utf-8');

// First call: cache write
const response1 = await callClaudeWithCache(
  "Summarize the staking mechanism",
  largeContext
);

// Second call (within 5 min): cache read (90% cheaper)
const response2 = await callClaudeWithCache(
  "What are the unstaking penalties?",
  largeContext
);
```

---

## Cost Impact Analysis

### Before Caching (Typical Month)

| Activity | Messages/Month | Tokens/Message | Cost |
|----------|---------------|----------------|------|
| Agent conversations | 200 | 5,000 (prompt) + 500 (user) | $3.30 |
| Claude Code sessions | 100 | 3,000 (context) + 1,000 (user) | $1.20 |
| Debugging with logs | 50 | 15,000 (logs) + 500 (user) | $2.33 |
| **Total** | 350 | — | **$6.83** |

### After Caching (Same Usage)

| Activity | Cache Write | Cache Reads | Cost |
|----------|-------------|-------------|------|
| Agent conversations | 1 × $0.019 | 199 × $0.002 | $0.42 |
| Claude Code sessions | 1 × $0.011 | 99 × $0.001 | $0.11 |
| Debugging with logs | 1 × $0.058 | 49 × $0.006 | $0.35 |
| **Total** | — | — | **$0.88** |

**Monthly savings:** $6.83 → $0.88 = **87% reduction**

**Yearly savings:** $82 → $11 = **$71/year** on just these activities

Scale this to heavy usage (1,000 messages/month) and you're saving **$500-800/year**.

---

## Best Practices

### ✅ Do This

1. **Cache your agent system prompts** — highest ROI, every conversation benefits
2. **Cache project briefs** when starting conversations — saves 2,000-3,000 tokens per session
3. **Cache large reference files** (docs, specs, codebases) when analyzing or debugging
4. **Structure prompts with cache markers** at logical boundaries (system → brief → files)
5. **Keep cached content stable** — changing it invalidates the cache

### ❌ Don't Do This

1. **Don't cache user messages** — they're unique every time
2. **Don't cache small snippets** (<1,000 tokens) — overhead outweighs benefits
3. **Don't cache rapidly changing data** — defeats the purpose
4. **Don't assume caching works forever** — it expires after 5 minutes of inactivity

---

## Monitoring Cache Performance

Track your cache hit rate in the Anthropic API response:

```javascript
const response = await client.messages.create({...});

console.log(response.usage);
// {
//   input_tokens: 500,
//   cache_creation_input_tokens: 3500,  // Tokens written to cache (first time)
//   cache_read_input_tokens: 0,         // Tokens read from cache (this call)
//   output_tokens: 150
// }
```

**Second request:**
```javascript
// {
//   input_tokens: 500,
//   cache_creation_input_tokens: 0,     // No new cache writes
//   cache_read_input_tokens: 3500,      // 3,500 tokens read from cache!
//   output_tokens: 150
// }
```

---

## Future-Proofing

As of February 2026, prompt caching is available on:
- Claude Opus 4.6
- Claude Sonnet 4.5
- Claude Haiku 4.5

If you're using older models, upgrade to benefit from caching.

**When Claude Code CLI adds native caching support:** Update your workflow to use it instead of the wrapper script.

---

## Quick Start Checklist

- [ ] Identify your highest-token-count prompts (agent prompts, project briefs, large files)
- [ ] Add `cache_control: { type: "ephemeral" }` markers at the end of stable content blocks
- [ ] Monitor cache hit rates in API responses
- [ ] Calculate your savings after one week
- [ ] Adjust cache boundaries if you see invalidations (content changing too often)

**Expected outcome:** 70-90% reduction in API costs for workflows with repeated context.

---

## See Also

- `essential/guides/COSTS.md` — Overall cost breakdown
- `advanced/guides/ARCHITECTURE_BLUEPRINT.md` — Agent setup and workflows
- Anthropic Docs: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
