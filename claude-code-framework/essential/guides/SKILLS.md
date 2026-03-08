# Skills Integration Guide
## Adding Anthropic Skills to Your Framework

**Framework:** Mastering Claude Code v3.1  
**Purpose:** Complement your agent system with task-specific Skills  
**Target Audience:** Vibe coders using your framework

---

## Why Add Skills to Your Framework?

Your agent system (System Architect, Frontend Dev, Backend Dev, etc.) is excellent for **complex, multi-phase work**. But vibe coders also need help with **quick, repeatable tasks** that don't justify opening an agent, pasting a project brief, and coordinating handoffs.

**Skills fill this gap.**

### What Skills Add

✅ **Auto-triggering** - Say "fix this Docker error" and the docker-debugger skill loads automatically  
✅ **Low overhead** - No project brief needed, no agent selection, just ask  
✅ **Quick tasks** - Deploy to Vercel, create API route, check accessibility  
✅ **Composable** - Multiple skills can work together in one conversation  
✅ **Portable** - Same skills work in Claude.ai, Claude Code, and API

### What Skills DON'T Replace

❌ Your tier-based agent architecture  
❌ Your handoff protocol  
❌ Your project briefs and STATUS.md tracking  
❌ Complex multi-phase workflows  
❌ Strategic decision-making

**Think of it this way:** Agents are your development team. Skills are your tools in the toolbox.

---

## The Hybrid Model

```
┌─────────────────────────────────────────────┐
│  AGENTS (Strategic, Multi-Phase)            │
│  • Build complete features                  │
│  • Coordinate across roles                  │
│  • Require project context                  │
│  • Take hours to complete                   │
│                                              │
│  Use when: Building new features,           │
│  major refactors, architectural decisions   │
└─────────────────────────────────────────────┘
                     +
┌─────────────────────────────────────────────┐
│  SKILLS (Tactical, Single-Task)             │
│  • Fix common issues                        │
│  • Scaffold code                            │
│  • Deploy to platforms                      │
│  • Run quick checks                         │
│                                              │
│  Use when: Quick fixes, debugging,          │
│  deployment, scaffolding, validation        │
└─────────────────────────────────────────────┘
```

---

## Recommended Skills for Your Framework

These **28 skills** cover quick tasks vibe coders encounter. The original 15 handle emergency fixes, scaffolding, deployment, and quality. The 13 added in V2.5 cover workflow planning, development patterns, operations, DeFi, and business.

> See `essential/skills/README.md` for the complete list with descriptions.

### Category 1: Emergency Fixes (5 skills)
**When:** Something broke, need immediate fix

1. **docker-debugger**
   - Trigger: "Docker error", "container won't start", "port already in use"
   - Fixes: Port conflicts, image issues, network problems, volume errors

2. **git-recovery**
   - Trigger: "undo commit", "recover file", "reset branch", "git error"
   - Fixes: Undoes commits, recovers deleted files, resolves conflicts

3. **build-error-fixer**
   - Trigger: "build failed", "compilation error", "webpack error"
   - Fixes: Missing dependencies, syntax errors, config issues

4. **env-validator**
   - Trigger: "check .env", "environment variables", "missing config"
   - Fixes: Missing vars, incorrect values, security issues

5. **dependency-resolver**
   - Trigger: "npm install failed", "dependency conflict", "version mismatch"
   - Fixes: Peer dependency issues, version conflicts, lock file problems

### Category 2: Quick Scaffolding (5 skills)
**When:** Need to add something standard

6. **next-api-scaffold**
   - Trigger: "create API route", "add endpoint", "new Next.js route"
   - Creates: API route with error handling, validation, types

7. **react-component-scaffold**
   - Trigger: "create component", "new component", "add React component"
   - Creates: Component with TypeScript, props, example usage

8. **auth-middleware-setup**
   - Trigger: "add authentication", "protect route", "add auth"
   - Creates: Auth middleware, protected routes, token validation

9. **database-migration**
   - Trigger: "create migration", "alter table", "add column"
   - Creates: Migration file with up/down, schema changes

10. **test-scaffold**
    - Trigger: "add tests", "create test", "test this component"
    - Creates: Test file with setup, basic tests, mocks

### Category 3: Deployment (3 skills)
**When:** Ready to deploy

11. **vercel-deployer**
    - Trigger: "deploy to Vercel", "push to production", "Vercel deployment"
    - Does: Connects repo, configures env vars, deploys

12. **docker-compose-generator**
    - Trigger: "create docker-compose", "containerize this", "Docker setup"
    - Creates: docker-compose.yml with all services configured

13. **github-actions-setup**
    - Trigger: "add CI/CD", "GitHub Actions", "automate deployment"
    - Creates: Workflow files for test, build, deploy

### Category 4: Code Quality (2 skills)
**When:** Need quick check before committing

14. **security-scanner**
    - Trigger: "check security", "scan for vulnerabilities", "security review"
    - Checks: Hardcoded secrets, SQL injection, XSS, dependency CVEs

15. **accessibility-checker**
    - Trigger: "check accessibility", "a11y", "WCAG compliance"
    - Checks: Semantic HTML, ARIA labels, contrast ratios, keyboard nav

---

## Setup Instructions

### For Claude.ai Users

**Step 1: Get the Skills**

Download the skills pack from your framework repo:
```bash
cd $CLAUDE_HOME/claude-code-framework
git pull  # Get latest with skills
cd skills/
ls  # See all available skills
```

**Step 2: Upload to Claude.ai**

For each skill:
1. Zip the skill folder: `cd docker-debugger && zip -r docker-debugger.zip . && cd ..`
2. Open Claude.ai → Settings → Capabilities → Skills
3. Click "Upload Skill"
4. Select the .zip file
5. Toggle the skill ON

**Step 3: Test the Skill**

Open a new conversation and say:
```
I'm getting "Error: EADDRINUSE: address already in use" when 
running my Docker container
```

The docker-debugger skill should auto-trigger and provide a fix.

---

### For Claude Code Users

**Step 1: Get the Skills**

```bash
cd $CLAUDE_HOME/claude-code-framework
git pull  # Get latest with skills
```

**Step 2: Enable in Claude Code**

Skills are loaded from `~/.claude/skills/` by default.

Copy skills to your Claude Code directory:
```bash
mkdir -p ~/.claude/skills
cp -r $CLAUDE_HOME/claude-code-framework/essential/skills/* ~/.claude/skills/
```

**Step 3: Verify Installation**

```bash
ls ~/.claude/skills/
# Should show: docker-debugger, git-recovery, etc.
```

Skills will auto-load when you start Claude Code.

**Step 4: Test a Skill**

In any project:
```bash
cd ~/projects/my-app
claude "My Docker container says port 3000 is already in use"
```

The docker-debugger skill should activate automatically.

---

## When to Use Skills vs. Agents

### Use a Skill When:

✅ Quick fix needed (< 5 minutes)  
✅ Well-defined problem with known solution  
✅ No project context required  
✅ Single-task focused  
✅ Common/repeatable issue

**Examples:**
- "Fix this Docker port conflict"
- "Deploy this to Vercel"
- "Create a new API route for /users"
- "Check this component for accessibility issues"
- "Generate a migration to add email column"

---

### Use an Agent When:

✅ Complex feature (> 30 minutes)  
✅ Requires discovery questions  
✅ Needs project context (PRD, tech spec, design system)  
✅ Multi-phase workflow  
✅ Novel problem

**Examples:**
- "Build user authentication feature" → Use Frontend + Backend Agents
- "Create the PRD for this feature" → Use Product Manager Agent
- "Design the component library" → Use Designer Agent
- "Set up CI/CD pipeline" → Use DevOps Engineer Agent
- "Review security of the payment flow" → Use Security Auditor Agent

---

### Combined Example: Building a Feature

**Scenario:** Building a new dashboard feature

1. **Start with Product Manager Agent** (Agent)
   - Generate PRD with requirements, user stories
   - Takes 20-30 minutes

2. **Switch to System Architect Agent** (Agent)
   - Create technical blueprint
   - Takes 15-20 minutes

3. **Switch to API Architect Agent** (Agent)
   - Define API contracts
   - Takes 20-30 minutes

4. **Switch to Frontend Developer Agent** (Agent)
   - Start building UI components
   - Agent asks for design specs

5. **[Docker error occurs]** (Skill auto-triggers)
   - docker-debugger skill: "Port 3000 already in use"
   - Provides fix: `lsof -ti:3000 | xargs kill -9`
   - Takes 30 seconds

6. **Continue with Frontend Agent** (Agent)
   - Finish UI implementation

7. **"Deploy to Vercel"** (Skill auto-triggers)
   - vercel-deployer skill handles deployment
   - Takes 2 minutes

8. **Switch to Backend Developer Agent** (Agent)
   - Build API endpoints
   - Takes 1-2 hours

9. **"Add a database migration"** (Skill auto-triggers)
   - database-migration skill creates migration file
   - Takes 1 minute

10. **Continue with Backend Agent** (Agent)
    - Complete API implementation

**Pattern:** Agents drive the feature build. Skills handle interruptions and quick tasks without breaking flow.

---

## Creating Your Own Skills

### Using skill-creator

The skill-creator skill (built by Anthropic) helps you build new skills:

**In Claude.ai:**
```
Use skill-creator to help me build a skill for [your use case]
```

**Example session:**
```
User: Use skill-creator to help me build a skill for deploying 
Next.js apps to Railway

skill-creator: Great! Let's build a railway-deployer skill. 
I'll ask you a few questions:

1. What triggers should activate this skill?
2. What are the steps in the deployment workflow?
3. Are there any prerequisites? (Railway CLI, account, etc.)
4. What should the output look like?

[Continues with interactive workflow]
```

skill-creator will:
- Generate properly formatted SKILL.md with YAML frontmatter
- Suggest trigger phrases
- Create workflow structure
- Validate the skill
- Suggest test cases

### Manual Skill Creation

**Minimal skill structure:**

```
your-skill-name/
└── SKILL.md
```

**SKILL.md template:**

```markdown
---
name: your-skill-name
description: What it does. Use when user asks to [specific triggers].
---

# Your Skill Name

## Instructions

### Step 1: [First Step]
Clear explanation of what happens.

Example:
\`\`\`bash
command --flag value
\`\`\`

Expected output: [what success looks like]

### Step 2: [Second Step]
[Continue pattern]

## Examples

**Example 1: [common scenario]**

User says: "Deploy to Vercel"

Actions:
1. Check for vercel.json
2. Run vercel --prod
3. Output deployment URL

## Troubleshooting

**Error: [common error]**
Cause: [why it happens]
Solution: [how to fix]
```

### YAML Frontmatter Rules

**Required fields:**
```yaml
---
name: skill-name-in-kebab-case
description: What it does and when to use it. Must include trigger phrases.
---
```

**Critical rules:**
- `name` must be kebab-case (no spaces, no capitals)
- `description` must include WHAT and WHEN
- No XML angle brackets (< or >) anywhere
- Must be exactly `SKILL.md` (case-sensitive)

**Good description examples:**
```yaml
description: Fixes Docker container errors including port conflicts, 
image issues, and network problems. Use when user sees Docker errors, 
mentions "container won't start", "port in use", or "Docker failing".
```

```yaml
description: Scaffolds Next.js API routes with TypeScript, error handling, 
and validation. Use when user says "create API route", "add endpoint", 
"new Next.js route", or references /api/ paths.
```

**Bad description examples:**
```yaml
description: Helps with Docker
# Too vague - what specifically? when?

description: Advanced container orchestration and microservices deployment
# Too technical - missing user trigger phrases

description: Creates routes
# Missing context - what kind of routes? when to use?
```

---

## Testing Your Skills

### Triggering Test

Verify the skill loads at the right times:

**Should trigger:**
```
✅ "My Docker container won't start"
✅ "Getting port 3000 already in use error"
✅ "Docker says the port is taken"
```

**Should NOT trigger:**
```
❌ "What's the weather in San Francisco?"
❌ "Help me write a blog post"
❌ "Create a spreadsheet"
```

### Functional Test

Verify the skill produces correct output:

**Test case:**
```
Given: User has Docker container with port conflict
When: User says "port 3000 already in use"
Then: 
  - Skill identifies the issue
  - Provides `lsof -ti:3000 | xargs kill -9`
  - Explains what the command does
  - Offers alternative solutions
```

### Performance Test

Compare with and without the skill:

**Without skill:**
- User explains error
- Claude suggests generic debugging
- 5-10 back-and-forth messages
- User might fix wrong issue

**With skill:**
- Skill auto-triggers
- Provides exact fix in 1 response
- Explains root cause
- No wasted messages

---

## Distributing Skills

### For Your Framework Users

**Option 1: Include in Framework (Recommended)**

Add skills directory to your framework:
```
claude-code-framework/
├── essential/
│   ├── agents/
│   ├── guides/
│   ├── skills/          ← Skills directory
│   │   ├── docker-debugger/
│   │   ├── git-recovery/
│   │   ├── vercel-deployer/
│   │   └── ... (15 total)
│   └── toolkit/
└── advanced/
```

Users get skills automatically when they download your framework.

**Option 2: Separate Skills Pack**

Create a separate repo: `claude-code-framework-skills`
- Users download separately
- Easier to update skills independently
- Users can pick and choose

**Option 3: Individual Skill Releases**

Distribute skills one at a time:
- GitHub releases with .zip files
- Documentation with installation instructions
- "Install the docker-debugger skill for your framework"

---

### Documentation Updates Needed

Add to your existing guides:

**1. Update README.md**
```markdown
## What's In This Repo

- `essential/agents/` — 10 AI agents for complex workflows
- `essential/skills/` — 28 task-specific skills for quick fixes and patterns
- `essential/guides/` — Complete documentation
- ...
```

**2. Update QUICK_START.md**
```markdown
## Step 4: Enable Skills (Optional)

Skills complement your agents for quick tasks:
1. Download skills pack
2. Upload to Claude.ai Settings → Skills
3. Enable the skills you want

Recommended skills for beginners:
- docker-debugger
- git-recovery
- vercel-deployer
```

**3. Create SKILLS.md guide**

New guide explaining:
- What skills are and how they differ from agents
- When to use each
- How to install
- List of all available skills
- How to create custom skills

**4. Update DAILY_WORKFLOW.md**
```markdown
## Quick Task Decision Tree

Ask yourself:
- Is this a quick fix? → Check if a skill can handle it
- Is this a new feature? → Use agent workflow
- Is this a deployment? → Use deployment skill
- Is this debugging? → Try relevant skill first
```

---

## Skill Directory Structure

Recommended organization in your framework:

```
skills/
├── README.md                    # Overview, installation guide
├── emergency/                   # Quick fixes
│   ├── docker-debugger/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── docker-errors.md
│   ├── git-recovery/
│   ├── build-error-fixer/
│   ├── env-validator/
│   └── dependency-resolver/
│
├── scaffolding/                 # Code generation
│   ├── next-api-scaffold/
│   ├── react-component-scaffold/
│   ├── auth-middleware-setup/
│   ├── database-migration/
│   └── test-scaffold/
│
├── deployment/                  # Deploy to platforms
│   ├── vercel-deployer/
│   ├── docker-compose-generator/
│   └── github-actions-setup/
│
└── quality/                     # Code checks
    ├── security-scanner/
    └── accessibility-checker/
```

---

## Migration Path for Existing Users

### If You're on v3.1 (Current)

**Minimal upgrade (1 hour):**
1. Pull latest framework with skills: `git pull`
2. Upload 3-5 essential skills to Claude.ai
3. Test with common scenarios
4. Read SKILLS.md guide

**Full upgrade (3-4 hours):**
1. Pull latest framework
2. Upload all 28 skills (or copy to `~/.claude/skills/`)
3. Configure skill triggers for your workflow
4. Create 1-2 custom skills for your specific needs
5. Update your project briefs to mention available skills

### If You're Building a New Project

Skills are already included. Just:
1. Enable skills during setup
2. Test a few common scenarios
3. Refer to SKILLS.md when needed

---

## Common Patterns

### Pattern 1: Agent → Skill → Agent

Building a feature when something breaks:

```
[Frontend Agent working on dashboard]
→ Docker error occurs
→ docker-debugger skill auto-triggers
→ Issue fixed
→ Resume Frontend Agent work
```

### Pattern 2: Multiple Skills in One Session

Quick scaffolding workflow:

```
User: "Create a new API route for users, add auth, and set up tests"
→ next-api-scaffold skill creates route
→ auth-middleware-setup skill adds protection
→ test-scaffold skill generates test file
→ All in one conversation
```

### Pattern 3: Skill as Agent Prerequisite

Before starting complex work:

```
User: "I want to add a new feature"
→ env-validator skill: "Your .env is missing DATABASE_URL"
→ User fixes .env
→ Now safe to use Backend Agent
```

---

## Troubleshooting

### Skill Won't Upload

**Error: "Could not find SKILL.md"**
- File must be named exactly `SKILL.md` (case-sensitive)
- Must be in root of skill folder

**Error: "Invalid frontmatter"**
- Check YAML formatting (--- delimiters, no XML brackets)
- Validate with: `python3 -c "import yaml; yaml.safe_load(open('SKILL.md').read().split('---')[1])"`

### Skill Doesn't Trigger

**Problem:** Skill never loads automatically

**Fix:** Improve description triggers
```yaml
# Too vague
description: Helps with Docker

# Better
description: Fixes Docker container errors including port conflicts. 
Use when user mentions "Docker error", "container won't start", or 
"port already in use".
```

### Skill Triggers Too Often

**Problem:** Skill loads for unrelated queries

**Fix:** Add negative triggers
```yaml
description: Deploys Next.js apps to Vercel. Use when user says 
"deploy to Vercel" or "push to production". Do NOT use for other 
platforms like Railway, Heroku, or AWS.
```

### Skill + Agent Conflict

**Problem:** Skill and agent both try to handle the same task

**Fix:** Make skill scope narrower
- Skill: Quick, well-defined tasks
- Agent: Complex, requires context

Example:
- ❌ Skill: "Build authentication feature" (too broad)
- ✅ Skill: "Add auth middleware to this route" (specific)
- ✅ Agent: "Design and implement complete auth system" (complex)

---

## Skill Maintenance

### Updating Skills

When you improve a skill:
1. Update SKILL.md in your framework repo
2. Version the skill in frontmatter:
   ```yaml
   metadata:
     version: 1.1.0
   ```
3. Document changes in skill's README
4. Tell users to re-upload to Claude.ai

### Deprecating Skills

If a skill becomes obsolete:
1. Mark deprecated in description:
   ```yaml
   description: [DEPRECATED - Use new-skill-name instead] ...
   ```
2. Keep skill available for 1-2 versions
3. Document migration path
4. Remove in major version update

---

## Best Practices

### Skill Design
- One skill = one workflow
- Keep under 1,000 lines
- Include 3-5 examples
- Add troubleshooting section
- Test trigger phrases

### Skill Naming
- Use kebab-case
- Be specific (vercel-deployer, not just deployer)
- Avoid generic names (setup, helper, tool)

### Skill Documentation
- Write for beginners
- Include screenshots/examples
- Document prerequisites
- Link to external docs

### Skill Testing
- Test obvious triggers
- Test paraphrased requests
- Verify doesn't over-trigger
- Measure time savings

---

## Next Steps

1. **Review compatibility analysis** - Understand agents vs. skills tradeoffs
2. **Choose 3-5 skills to start** - docker-debugger, git-recovery, vercel-deployer recommended
3. **Install and test** - Upload to Claude.ai, try in real scenarios
4. **Create custom skills** - Use skill-creator for your specific workflows
5. **Update documentation** - Add skills section to your guides
6. **Collect feedback** - Ask users which skills are most valuable

---

## Resources

**Anthropic Documentation:**
- [Skills Guide](https://docs.anthropic.com/claude/docs/skills) (PDF you uploaded)
- [Skills Best Practices](https://docs.anthropic.com/claude/docs/skills-best-practices)
- [Creating Skills](https://www.anthropic.com/news/agent-skills)

**Your Framework:**
- Compatibility Analysis: `SKILLS-COMPATIBILITY-ANALYSIS.md`
- Skills directory: `skills/`
- Example skills: `skills/docker-debugger/`, `skills/git-recovery/`

**Tools:**
- skill-creator skill (built into Claude.ai)
- skill-validator (coming soon)

---

## Summary

**Skills complement your agents.**

- **Keep agents** for complex, multi-phase work requiring context and coordination
- **Add skills** for quick, repeatable tasks that don't need full agent orchestration
- **Use both** for optimal workflow: agents drive features, skills handle interruptions

**Your framework just got more powerful.**

Start with 3-5 essential skills. Add more as you identify common patterns. Create custom skills for your specific workflows. The combination of agents + skills gives vibe coders the best of both worlds: strategic agents for complex builds, tactical skills for quick wins.
