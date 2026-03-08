# Quick Reference Card — Mastering Claude Code

> **One-page cheat sheet — Print this or keep it open while building**
>
> **Version:** 4.3 | **Last Updated:** February 12, 2026

---

## 🚀 Getting Started (5 Commands)

```bash
# 1. Create new project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# 2. Or adopt existing project
cd /my-project && $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh

# 3. Start Claude Code
claude

# 4. Install MCP (browser testing)
claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright

# 5. First conversation
# Say: "Read CLAUDE.md and STATUS.md. Let's create the PRD."
```

---

## 📁 Essential Files

| File | Purpose | Update Frequency |
|------|---------|------------------|
| `CLAUDE.md` | Rules for Claude Code | Once at project start |
| `STATUS.md` | Current project state | After every change |
| `docs/PRD.md` | What you're building | Refine during planning |
| `docs/TECH_SPEC.md` | How you're building it | Refine during planning |
| `.env.example` | Environment variables template | When adding new vars |
| `.claude/hooks/` | Automated safeguards | Set up once, forget |

---

## 🤖 Agent Selection Flowchart

```
What are you doing today?

├─ 🐛 Bug fix / small feature
│  └─ Use: Frontend Developer (1 agent)
│           or Backend Developer (1 agent)
│
├─ 🎨 New UI feature
│  └─ Use: Frontend + Designer (2 agents)
│
├─ 🔌 New API endpoint
│  └─ Use: Backend + API Architect (2 agents)
│
├─ 🏗️  Building new system from scratch
│  └─ Use: Full 10-agent pipeline
│     TIER 1: Architect + PM
│     TIER 2: Designer + API Architect (parallel)
│     TIER 3: Frontend + Backend (parallel)
│     TIER 4: Security + Tester
│     TIER 5: DevOps
│     TIER 6: Tech Writer
│
└─ 🔒 DeFi / Security-sensitive app
   └─ Add: Security Auditor (to any workflow)
```

**Daily work: 1-2 agents**
**New system builds: All 10 agents**

---

## 🛠️  Essential Commands

### Claude Code CLI
```bash
claude                          # Start interactive session
claude "fix typo in line 42"    # One-shot command
claude --version                # Check version
```

### Project Scaffolding
```bash
# Create new project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh \
  --name my-app --type nextjs --path ~/projects

# Add framework to existing project
$CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh
```

### MCP Servers
```bash
claude mcp add <name> -- <command>    # Add server
claude mcp list                       # List configured
claude mcp remove <name>              # Remove server
```

### Git Workflow
```bash
git checkout develop              # Work on develop branch
git add .                        # Stage changes
git commit -m "descriptive msg"  # Commit (hooks run here)
git push origin develop          # Push to remote
```

### Docker
```bash
docker compose up -d             # Start services
docker compose logs <service>    # View logs
docker compose down              # Stop everything
docker system prune -af          # Clean up space
```

---

## 📊 File Structure (Standard)

```
my-project/
├── .claude/
│   ├── agents/              # Native subagents (optional)
│   ├── skills/              # Native skills (optional)
│   ├── hooks/               # Automation scripts
│   └── settings.json        # Permissions & hooks config
├── .mcp.json                # MCP servers configuration
├── docs/
│   ├── PRD.md              # Product requirements
│   ├── TECH_SPEC.md        # Technical spec
│   └── API_DOCS.md         # API documentation
├── CLAUDE.md               # Rules for Claude Code
├── STATUS.md               # Current project state
├── .env                    # Environment variables (gitignored!)
├── .env.example            # Env template (committed)
├── .gitignore              # Git ignore rules
└── [framework files]       # Next.js, Flask, etc.
```

---

## 🎯 Common Workflows

### Workflow 1: Bug Fix
```
1. Update STATUS.md (what's broken)
2. Tell Claude: "Fix [bug description]"
3. Claude reads STATUS, fixes bug, writes tests
4. Review changes
5. Commit: git add . && git commit -m "fix: [description]"
6. Update STATUS.md (bug fixed)
```

### Workflow 2: New Feature
```
1. Update STATUS.md (what we're adding)
2. Tell Claude: "Create PRD for [feature]"
3. Review PRD, refine
4. Tell Claude: "Create Tech Spec"
5. Review Tech Spec
6. Tell Claude: "Implement Phase 1"
7. Commit after each working state
8. Update STATUS.md (progress tracking)
```

### Workflow 3: Full System Build
```
1. Run create-project.sh
2. Tier 1: System Architect → PRD & architecture
3. Tier 1: Product Manager → Break into tasks
4. Tier 2: Designer + API Architect (parallel)
5. Tier 3: Frontend + Backend (parallel)
6. Tier 4: Security Auditor → Review
7. Tier 4: System Tester → Test suite
8. Tier 5: DevOps → Deploy
9. Tier 6: Tech Writer → Docs (async)
```

---

## ⚠️  Golden Rules

1. **STATUS.md is king** — Update after every change
2. **Commit frequently** — After every working state
3. **Never trust Claude with numbers** — Always verify calculations
4. **Read CLAUDE.md periodically** — Claude forgets its own rules
5. **One feature at a time** — Don't let Claude drift
6. **Test before committing** — Hooks can't save you from everything
7. **Detailed logs always** — You'll need them when debugging

---

## 🔑 Environment Variables

```bash
# Development (.env)
DATABASE_URL=postgresql://localhost/mydb
NEXT_PUBLIC_API_URL=http://localhost:3000
ANTHROPIC_API_KEY=sk-ant-...

# Production (Vercel)
vercel env add DATABASE_URL production
vercel env add NEXT_PUBLIC_API_URL production
```

**Never commit `.env`** — Always commit `.env.example`

---

## 📚 Where to Look When Stuck

| Problem | Read This |
|---------|-----------|
| Specific error | `essential/guides/TROUBLESHOOTING.md` |
| Claude misbehaving | `essential/guides/PITFALLS.md` |
| Cost too high | `advanced/guides/PROMPT_CACHING.md` |
| Need full context | `advanced/guides/ARCHITECTURE_BLUEPRINT.md` |
| Starting fresh project | `essential/guides/FIRST_PROJECT.md` (2hr tutorial) |
| Complete beginner | `essential/guides/DAY_ZERO.md` |
| Agent selection | This card's flowchart ↑ |
| Hooks not working | `UPGRADING_V4.2_TO_V4.3.md` |
| MCP configuration | `advanced/guides/MCP_SETUP.md` |
| Service integration | `advanced/guides/INTEGRATIONS.md` |

---

## 🚨 Emergency Recovery

```bash
# Everything broke — go back to last working commit
git log --oneline -10              # Find last working commit
git reset --hard <commit-hash>     # NUCLEAR: resets everything
npm run dev                        # Verify it works

# Lost uncommitted work — check reflog
git reflog                         # Show all HEAD movements
git checkout <reflog-hash>         # Recover lost commit

# Database corrupted
# 1. Check docker logs: docker compose logs postgres
# 2. Restore from backup (you DO have backups, right?)
# 3. Nuclear: docker compose down -v && docker compose up -d

# Claude went rogue — kill the session
# Just close terminal, nothing is committed yet
# Review changes in git status, reset what's bad
```

---

## 🎓 Skill Levels

### Beginner (Week 1)
- [ ] Created first project with scaffolding
- [ ] Set up 1-2 agents (Frontend/Backend)
- [ ] Built first feature with Claude
- [ ] Committed and pushed to GitHub

### Intermediate (Month 1)
- [ ] Using 4-5 agents regularly
- [ ] Hooks configured and working
- [ ] MCP Playwright testing UI
- [ ] Deployed to Vercel/Railway

### Advanced (Month 3)
- [ ] Full 10-agent pipeline on demand
- [ ] Custom hooks for your workflow
- [ ] Multiple projects running
- [ ] Contributing back to framework

---

## 💰 Cost Optimization

```bash
# Use prompt caching (save 90%)
# See: advanced/guides/PROMPT_CACHING.md

# Set spending limits
# console.anthropic.com → Settings → Spending limits

# Use Haiku for simple tasks
# (Framework uses Sonnet by default for quality)
```

**Typical monthly cost:** $20 Claude Pro + $20-100 API = $40-120/month

---

## 🔗 Quick Links

- **Anthropic Console:** console.anthropic.com
- **Claude Code Docs:** docs.claude.com/en/docs/claude-code
- **This Framework:** DOCUMENTATION_INDEX.md (full nav)
- **Changelog:** CHANGELOG.md (version history)
- **Compatibility:** COMPATIBILITY.md (requirements)

---

## 📞 Getting Help

1. **Check this card first** ↑
2. **Search TROUBLESHOOTING.md**
3. **Read full guide for your issue** (see table above)
4. **Check CHANGELOG** for recent changes
5. **Still stuck?** Create detailed issue with:
   - What you tried
   - Error messages (full text)
   - Contents of STATUS.md
   - Claude Code version

---

## ✅ Pre-Flight Checklist (New Project)

```bash
# Day 1: Setup
[ ] Run create-project.sh or adopt-project.sh
[ ] Configure CLAUDE.md (copy from templates)
[ ] Set up hooks: cp essential/toolkit/templates/hooks/*.sh .claude/hooks/
[ ] Add MCP Playwright: claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright
[ ] Create .env.example with all needed vars
[ ] Initialize git: git init && git checkout -b develop

# Day 2: Planning
[ ] Create project brief (essential/agents/02-project-brief-template.md)
[ ] Set up 1-2 core agents (Frontend/Backend)
[ ] Create PRD with Claude
[ ] Review and refine PRD
[ ] Create Tech Spec with Claude

# Day 3+: Building
[ ] Implement Phase 1
[ ] Commit frequently
[ ] Update STATUS.md after every session
[ ] Add more agents as needed
[ ] Test before merging to main
```

---

## 🎯 Success Metrics

You're doing it right if:
- ✅ STATUS.md is updated after every session
- ✅ Commits happen multiple times per day
- ✅ Claude follows CLAUDE.md rules (mostly)
- ✅ Hooks catch dangerous operations
- ✅ Tests pass before deploying
- ✅ Features ship regularly

You need to adjust if:
- ❌ STATUS.md is weeks out of date
- ❌ Going days without commits
- ❌ Claude ignoring CLAUDE.md
- ❌ Frequently reverting commits
- ❌ Production breaks after deploys

---

**Print this card and keep it visible while coding.**
**Bookmark it in your browser for instant reference.**

**Questions? Start with `DOCUMENTATION_INDEX.md` for full navigation.**
