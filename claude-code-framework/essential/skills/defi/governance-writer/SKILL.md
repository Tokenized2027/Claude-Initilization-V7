---
name: governance-writer
description: Write DAO governance proposals, protocol updates, community posts, and technical documentation for DeFi protocols. Triggers on "governance proposal", "DAO vote", "protocol update", "community post", "SIP", "improvement proposal", "forum post".
metadata:
  author: Mastering Claude Code (custom for DeFi workflows)
  version: 1.0.0
  category: defi
  source: custom
---

# Governance Writer

Write clear, professional governance content for DAO protocols — proposals, updates, community posts, and technical summaries.

## Instructions

### Template 1: Governance Proposal (SIP/Improvement Proposal)

```markdown
# [SIP-XXX]: [Short Title]

## Summary
[2-3 sentences: What this proposal does and why it matters]

## Motivation
[Why is this change needed? What problem does it solve?]
- Current situation: [what's happening now]
- Problem: [what's broken or suboptimal]
- Impact: [who is affected and how]

## Specification
[Technical details of the proposed change]

### Parameters
| Parameter | Current Value | Proposed Value | Rationale |
|-----------|--------------|----------------|-----------|
| [param]   | [current]    | [proposed]     | [why]     |

### Implementation
[How this will be implemented — smart contract changes, parameter updates, etc.]

## Risks
- [Risk 1]: [mitigation]
- [Risk 2]: [mitigation]

## Timeline
- Discussion period: [dates]
- Voting period: [dates]
- Implementation: [dates]

## References
- [Link to relevant data/dashboard]
- [Link to prior discussions]
```

### Template 2: Protocol Update / Newsletter

```markdown
# [Protocol Name] Update — [Month Year]

## Key Metrics
- TVL: [amount] ([change]% from last month)
- Stakers: [count]
- APY: [rate]%

## What Happened This Month
[3-5 bullet points of the most important developments]

## Technical Updates
[Any protocol upgrades, smart contract changes, or infrastructure improvements]

## Governance Recap
- [Proposal X]: [outcome — Passed/Failed/Pending]
- [Proposal Y]: [outcome]

## What's Next
[2-3 things the community can look forward to]

## Get Involved
- [Link to forum]
- [Link to Discord]
- [Link to governance portal]
```

### Template 3: Community Forum Post

```markdown
## [Title — Clear and Specific]

**TL;DR:** [One sentence summary]

Hey everyone,

[Opening that frames the topic — 2-3 sentences]

### The Situation
[Current state with data to support your points]

### The Proposal / Question / Discussion Point
[What you're proposing or asking — be specific]

### Why This Matters
[Impact on token holders, operators, protocol health]

### Open Questions
1. [Question for community input]
2. [Question for community input]

Looking forward to the discussion.
```

## Writing Rules for Governance Content

1. **Lead with data:** Every claim should reference a number, metric, or on-chain fact
2. **Be neutral in proposals:** Present tradeoffs honestly, don't advocate
3. **Define jargon:** Not everyone knows what "slashing conditions" or "operator delegation" means
4. **Use simple sentences:** Governance content is read by non-native English speakers
5. **Include links:** Link to dashboards, contracts, and prior discussions
6. **State risks explicitly:** Never hide downsides — the community will find them

## Tone Guide

| Context | Tone |
|---------|------|
| Governance proposal | Formal, precise, data-backed |
| Protocol update | Professional, accessible, optimistic but honest |
| Forum discussion | Conversational, respectful, open to feedback |
| Technical documentation | Clear, structured, no ambiguity |
| Twitter/social threads | Concise, engaging, visual-friendly |

## When to Use This Skill

✅ Use governance-writer when:
- Drafting SIPs or governance proposals
- Writing monthly protocol updates
- Creating community forum posts
- Summarizing governance votes
- The content-creator agent needs protocol-specific templates

❌ Don't use for:
- Technical documentation for code (use technical-writer agent)
- Marketing copy (use SEO/content skills)
- Smart contract specs (use api-architect agent)
