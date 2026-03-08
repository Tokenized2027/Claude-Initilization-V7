# Skills Directory

This directory contains **28 task-specific skills** that complement your agent system for quick, repeatable workflows.

> **V2.5 Update:** Added 13 new skills across 5 new categories (workflow, development, operations, defi, business). Skills adapted from community contributions + custom skills for project-specific and automation business workflows.

## Why Skills?

Your agents (System Architect, Frontend Developer, etc.) are designed for complex, multi-phase work. Skills handle the quick tasks that don't need full agent orchestration:

- **Agents:** Build complete features (hours)
- **Skills:** Fix errors, scaffold code, deploy, brainstorm, debug (minutes)

## Installation

### For Claude Code / Mini PC Agents

```bash
# Copy skills to Claude Code directory
mkdir -p ~/.claude/skills
cp -r skills/* ~/.claude/skills/
```

Skills will auto-load when you start Claude Code. For mini PC autonomous agents, skills are loaded by the orchestrator when the agent's task matches a skill trigger.

### For Claude.ai

1. Zip each skill folder:
   ```bash
   cd skills/emergency/docker-debugger
   zip -r docker-debugger.zip .
   ```

2. Upload to Claude.ai:
   - Settings → Capabilities → Skills
   - Click "Upload Skill"
   - Select the .zip file
   - Toggle skill ON

3. Repeat for skills you want

## Available Skills (28)

### Workflow (3) — NEW in V2.5

**Before you build, think first:**

1. **brainstorming** - Structured ideation → 3 options → design brief → handoff
2. **systematic-debugging** - Reproduce → isolate → hypothesize → test → fix → document
3. **prompt-engineering** - Optimize agent prompts, orchestrator routing, and LLM API calls

### Development (3) — NEW in V2.5

**Production-grade code patterns:**

4. **react-patterns** - Dashboard components, data viz, Server/Client Component architecture
5. **typescript-hardening** - Eliminate `any`, enforce strict typing, Zod validation at boundaries
6. **api-design** - REST API templates with consistent envelopes, error handling, validation

### Operations (2) — NEW in V2.5

**Keep the mini PC running and costs under control:**

7. **cost-optimizer** - Track API spend, set agent budgets, circuit breakers, monthly review
8. **observability-setup** - Health checks, structured logging, Telegram alerts, cron monitoring

### DeFi (2) — NEW in V2.5

**Protocol-specific skills for DeFi/Web3 work:**

9. **defi-analytics** - On-chain data fetching, APY/TVL calculations, DeFi Llama integration
10. **governance-writer** - DAO proposals, protocol updates, community posts, forum templates

### Business (3) — NEW in V2.5

**For the automation company and client projects:**

11. **seo-audit** - Technical SEO audit (meta tags, Core Web Vitals, crawlability, structured data)
12. **stripe-integration** - Checkout, subscriptions, webhooks, customer portal
13. **client-onboarding** - Discovery → scope → proposal → kickoff → handoff workflow

### Emergency Fixes (5)

**When something broke and you need it fixed now:**

14. **docker-debugger** - Port conflicts, container errors, image issues
15. **git-recovery** - Undo commits, recover deleted files, fix common mistakes
16. **build-error-fixer** - Missing dependencies, compilation errors
17. **env-validator** - Check .env files for missing/incorrect variables
18. **dependency-resolver** - Fix npm/yarn conflicts, peer dependencies

### Quick Scaffolding (5)

**When you need to add something standard:**

19. **next-api-scaffold** - Create API routes with validation
20. **react-component-scaffold** - Generate components with TypeScript
21. **auth-middleware-setup** - Add authentication to routes
22. **database-migration** - Create migration files
23. **test-scaffold** - Generate test files

### Deployment (3)

**When you're ready to deploy:**

24. **vercel-deployer** - Deploy to Vercel
25. **docker-compose-generator** - Create docker-compose.yml
26. **github-actions-setup** - Add CI/CD workflows

### Code Quality (2)

**Quick checks before committing:**

27. **security-scanner** - Check for vulnerabilities
28. **accessibility-checker** - Validate WCAG compliance

## When to Use Skills vs. Agents

### Use a Skill:
- ✅ Quick fix (< 5 minutes)
- ✅ Well-defined problem
- ✅ No project context needed
- ✅ Single task

Examples: "Fix Docker port conflict", "Create API route", "Deploy to Vercel"

### Use an Agent:
- ✅ Complex feature (> 30 minutes)
- ✅ Requires discovery
- ✅ Needs project context
- ✅ Multi-phase work

Examples: "Build authentication feature", "Design component library", "Create PRD"

## How They Work Together

Skills and agents complement each other:

```
Building feature with Frontend Agent
  → Docker error occurs
  → docker-debugger skill auto-fixes
  → Resume agent work
  → "Deploy to Vercel"
  → vercel-deployer skill handles it
```

**Pattern:** Agents drive features. Skills handle interruptions and quick tasks.

## Creating Custom Skills

Use the skill-creator skill (built by Anthropic):

```
Use skill-creator to help me build a skill for [your workflow]
```

Or manually create:

```
my-skill/
└── SKILL.md
```

With YAML frontmatter:

```yaml
---
name: my-skill-name
description: What it does. Use when user says [triggers].
---

# My Skill

Instructions go here...
```

See `SKILLS-INTEGRATION-GUIDE.md` in the main documentation for complete guide.

## Testing Skills

### Test Triggering

Say the trigger phrase and verify the skill loads:

```
# Should trigger docker-debugger
"My Docker container won't start - port 3000 is already in use"

# Should trigger git-recovery
"I need to undo my last commit"

# Should trigger vercel-deployer
"Deploy this to Vercel"
```

### Test Output

Verify the skill provides the right fix:
- Check commands are correct
- Verify explanations are clear
- Ensure troubleshooting covers edge cases

## Troubleshooting

**Skill won't upload:**
- File must be exactly `SKILL.md` (case-sensitive)
- Folder name must be kebab-case
- No XML brackets (< >) in frontmatter

**Skill doesn't trigger:**
- Add more trigger phrases to description
- Be specific about when to use it
- Test with paraphrased requests

**Skill triggers too often:**
- Add negative triggers (what NOT to use it for)
- Be more specific about scope
- Clarify boundaries with other skills

## Resources

**Documentation:**
- `essential/guides/SKILLS.md` - Complete integration guide
- `docs/research/SKILLS-COMPATIBILITY-ANALYSIS.md` - Agents vs. Skills comparison
- Anthropic Skills Guide - See PDF in resources

**Support:**
- Framework: GitHub issues
- Skills API: Anthropic documentation
- skill-creator: Built into Claude.ai

---

**Remember:** Skills don't replace your agents. They complement them for quick, tactical wins while agents handle strategic, complex work.
