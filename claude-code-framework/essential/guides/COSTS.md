# Cost Guide — What This Setup Actually Costs

> A realistic breakdown of costs so there are no surprises. Updated February 2026.

---

## One-Time Costs

| Item | Cost | Notes |
|------|------|-------|
| Mini PC (budget) | $130-220 | Intel N100, 16GB RAM — works but tight |
| Mini PC (recommended) | $350-480 | AMD Ryzen 7, 32GB RAM — comfortable headroom |
| Ethernet cable | $5-15 | If your mini PC isn't near your router |
| USB keyboard (temporary) | $0-15 | Only needed for initial setup, then headless |

**Total one-time:** $135-500 depending on hardware choice.

---

## Monthly Recurring Costs

| Item | Cost | Required? | Notes |
|------|------|-----------|-------|
| Electricity | $1-3/month | Yes | N100: ~8W idle. Ryzen 7: ~15W idle. Practically free |
| Claude Pro subscription | $20/month | Yes | For the 5 agent Claude Projects on claude.ai |
| Claude API credits | $20-100/month | Yes | For Claude Code CLI. Depends on how much you build |
| LLM API provider | Varies | Optional | If your project needs LLM inference beyond Claude Code |
| Tailscale | Free | Yes | Free tier covers personal use (up to 100 devices) |
| Internet | Already paying | Yes | Your existing home internet |
| Domain name | $10-15/year (~$1/mo) | Optional | Only if you want a custom domain for your services |

### Typical Monthly Total

| Usage Level | Claude API (Without Caching) | With Prompt Caching | Total Monthly |
|-------------|------------------------------|---------------------|---------------|
| Light (a few hours/week) | ~$20 | ~$5 | ~$27 |
| Regular (most weekdays) | ~$50 | ~$10 | ~$32 |
| Heavy (building daily) | ~$100+ | ~$20+ | ~$42+ |

**Prompt caching** can reduce your API costs by 70-90% by reusing agent prompts, project briefs, and large files. See `advanced/guides/PROMPT_CACHING.md` for implementation details.

---

## Claude API Cost Breakdown

Claude Code uses your Anthropic API credits. Here's what typical tasks cost:

| Task Type | Typical Cost | Examples |
|-----------|-------------|---------|
| Quick fixes | $0.05-0.20 | Fix a typo, update a config, small edits |
| Simple features | $0.20-1.00 | Add a component, write a script, set up a hook |
| Medium features | $1.00-3.00 | New page, API endpoint, database migration |
| Complex features | $3.00-10.00 | Full feature with frontend + backend + tests |
| Architecture/planning | $1.00-5.00 | PRD creation, tech spec, system design |
| Debugging sessions | $0.50-5.00 | Depends on complexity — simple bugs are cheap, deep debugging is expensive |
| Long unfocused sessions | $5.00-20.00+ | Avoid these — context gets bloated, Claude gets confused, and you pay for the confusion |

### How to Control API Costs

1. **Set a monthly spending limit** at console.anthropic.com → Settings → Spending Limits
2. **Use prompt caching** — Save 90% on repeated context (agent prompts, project briefs, large files). See `advanced/guides/PROMPT_CACHING.md` for implementation
3. **Use one-shot commands for simple tasks:** `claude "fix the typo in app/page.tsx line 42"` — cheaper than interactive sessions
4. **Keep conversations focused.** Long rambling sessions cost more AND produce worse results. Start fresh conversations often
5. **Use the agent Claude Projects** (Pro subscription, flat $20/mo) for planning and discussion. Use Claude Code CLI (API, pay-per-use) only for actual code execution
6. **STATUS.md saves money.** When you start a session with "Read STATUS.md" instead of re-explaining everything, you save tokens
7. **Kill zombie sessions.** If Claude Code is going in circles, stop it — you're paying for every confused iteration

### Monitoring Your Spend

Check your usage at: **console.anthropic.com → Usage**

This shows daily and monthly totals, broken down by model. If you're consistently over budget, you're probably having too many long conversations. Shorter, focused sessions are both cheaper and more effective.

---

## LLM API Costs (If Your Project Needs One)

If your project calls an external LLM API (OpenAI, Anthropic, Groq, Together AI, etc.), you'll have additional costs beyond Claude Code. These vary by provider, model, and usage volume.

**Common pricing models:**
- **Pay-per-token:** Most providers charge per input/output token (e.g., OpenAI, Anthropic API)
- **Subscription:** Some offer monthly plans with usage caps
- **Self-hosted:** Run open-source models locally (requires GPU hardware — different budget category)

**Cost control tips:**
- Start with the cheapest model that meets your quality needs
- Cache API responses where possible
- Use smaller/faster models for simple tasks, larger models only when needed
- Monitor usage daily when starting out

---

## Cost Comparison: This Setup vs. Alternatives

| Approach | Monthly Cost | Pros | Cons |
|----------|-------------|------|------|
| **This setup (mini PC)** | $42-122 | Full control, always-on, own your data, one-time hardware cost | You manage the server |
| Cloud VPS (DigitalOcean/Hetzner) | $24-96/mo + API costs | No hardware, easy scaling | Recurring forever, data on someone else's server |
| Replit / GitHub Codespaces | $20-40/mo + API costs | Zero setup | Limited control, can't run 24/7 services cheaply |
| MacBook-only (no server) | API costs only | Simplest | Not always-on, can't run infrastructure 24/7 |

The mini PC pays for itself within 3-6 months compared to cloud VPS, and you have full physical control of your data and infrastructure.

---

## When to Upgrade

Signs you need better hardware:

| Symptom | Likely Cause | Solution |
|---------|-------------|----------|
| Containers get OOM-killed regularly | Not enough RAM | Upgrade to 32GB machine |
| Everything feels sluggish | CPU bottleneck | Move from N100 to Ryzen 7 |
| "No space left on device" frequently | Disk full | Add external SSD or upgrade to 1TB |
| Want to run local LLMs alongside cloud APIs | Need GPU | This is a different category — look into machines with dedicated GPUs |
