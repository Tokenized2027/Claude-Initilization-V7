---
name: client-onboarding
description: Structured onboarding workflow for new automation clients. Covers discovery, requirements gathering, project scoping, and kickoff for small business clients. Triggers on "new client", "onboarding", "discovery call", "project scope", "client intake", "kickoff".
metadata:
  author: Mastering Claude Code (custom for automation business)
  version: 1.0.0
  category: business
  source: custom
---

# Client Onboarding

Structured workflow for onboarding new clients to your automation services — from first contact to project kickoff.

## Instructions

### Phase 1: Discovery (Before Contract)

Use this questionnaire in the initial meeting:

```markdown
## Client Discovery Form

### Business Basics
- Company name:
- Industry:
- Team size:
- Current tech stack (if any):
- Monthly budget range for automation:

### Pain Points (Rank 1-5 by urgency)
- [ ] Manual data entry / copy-paste workflows
- [ ] Order processing takes too long
- [ ] No visibility into business metrics
- [ ] Customer communication is inconsistent
- [ ] Inventory / stock tracking is manual
- [ ] Invoicing / billing is time-consuming
- [ ] Other: ___

### Current Workflow
- What's the #1 task that wastes the most time? ___
- How many hours/week does it take? ___
- Who does it? ___
- What tools do they use today? (Excel, email, paper, etc.) ___

### Success Criteria
- What does "done" look like for you? ___
- How will you know this was worth the investment? ___
```

### Phase 2: Scope and Proposal

Generate a project scope from the discovery data:

```markdown
## Project Proposal: [Client Name] — [Project Title]

### Executive Summary
[2-3 sentences: What we're building and the expected ROI]

### Current State
[Describe their current painful workflow in their own words]

### Proposed Solution
[What we'll automate and how — keep it non-technical]

### Deliverables
1. [Deliverable 1] — [brief description]
2. [Deliverable 2] — [brief description]
3. [Deliverable 3] — [brief description]

### Timeline
| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Setup & Configuration | Week 1 | Environment ready |
| Core Automation | Week 2-3 | Main workflow live |
| Testing & Training | Week 4 | Client trained, bugs fixed |
| Handoff & Support | Week 5 | Documentation + 30-day support |

### Investment
- Setup fee: $___
- Monthly maintenance: $___/month (optional)
- Includes: [what's covered]

### What's NOT Included
- [Explicitly list exclusions to prevent scope creep]

### Next Steps
1. Sign proposal
2. Schedule kickoff call
3. Share access credentials securely
```

### Phase 3: Kickoff

After contract signed, run this checklist:

```markdown
## Project Kickoff Checklist — [Client Name]

### Access & Credentials
- [ ] Client shared credentials via secure method (1Password, Bitwarden)
- [ ] API keys obtained for: [list services]
- [ ] Test/staging environment access confirmed
- [ ] Client's primary contact confirmed: [name, email, phone]

### Technical Setup
- [ ] Project repo created
- [ ] CLAUDE.md configured with client context
- [ ] Environment variables set in .env
- [ ] Docker container running locally
- [ ] First test automation passing

### Communication
- [ ] Weekly check-in scheduled: [day/time]
- [ ] Communication channel established: [Telegram/WhatsApp/Slack]
- [ ] Client knows how to report issues
- [ ] Emergency contact defined for critical failures

### Documentation
- [ ] Client's current workflow documented (as-is)
- [ ] Target workflow documented (to-be)
- [ ] Decision log started
```

### Phase 4: Handoff

```markdown
## Project Handoff — [Client Name]

### What Was Built
[Plain-language summary of what the automation does]

### How to Use It
[Step-by-step for the client's team — assume zero technical knowledge]

### What to Do If Something Breaks
1. Check [dashboard/status page] first
2. If the issue is [X], do [Y]
3. For anything else, contact: [your support channel]

### Maintenance Schedule
- Automated: [what runs on its own]
- Monthly review: [what you check monthly]
- Client responsibility: [what they need to do]

### Support Terms
- [30 days included support]
- [Response time: within X hours on business days]
- [After support period: monthly retainer option]
```

## Pricing Framework for Small Businesses

| Project Type | Typical Scope | Price Range |
|-------------|--------------|-------------|
| Simple automation (1 workflow) | Data sync, email automation | $500-1,500 |
| Dashboard + reporting | Metrics dashboard, automated reports | $1,500-3,000 |
| Full workflow automation | Multi-step process, integrations | $3,000-7,000 |
| Ongoing management | Monthly monitoring + improvements | $200-500/month |

**Pricing rules:**
- Always quote fixed price, not hourly (you're using AI — hours are irrelevant)
- Include a revision round in the price
- Maintenance retainer is where recurring revenue comes from
- Never discount more than 15% — underpricing kills the business

## When to Use This Skill

✅ Use client-onboarding when:
- New client inquiry comes in
- Need to scope a project
- Running a discovery call
- Preparing a proposal
- Handing off a completed project

❌ Don't use for:
- Existing client feature requests (use brainstorming)
- Technical implementation (use development skills)
- Internal projects (no client onboarding needed)
