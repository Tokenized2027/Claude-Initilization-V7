# Upgrading from v4.3 to v4.4

> **Upgrade time:** 30-60 minutes
> **Compatibility:** 100% backward compatible
> **Recommended approach:** Incremental adoption over 2-4 weeks

---

## What's New in v4.4

**Four major additions:**

1. **Memory System** — Persistent context across sessions
2. **Sprint Management** — Complete 2-week sprint methodology
3. **Task Integration** — Use Claude Code's native task tools
4. **Bead Method** — Micro-task decomposition technique

**Plus:**
- Scrum Master agent (13th agent)
- Memory automation scripts
- Sprint automation scripts
- Comprehensive templates

---

## Backward Compatibility

✅ **You can keep using v4.4 exactly like v4.3**

All v4.4 features are **opt-in additions**:
- If you don't set up memory → works like v4.3
- If you don't use sprints → works like v4.3
- If you don't use task tools → works like v4.3

**Nothing breaks. Everything is additive.**

---

## Migration Options

### Option A: Gradual (Recommended)

Adopt features incrementally over 4 weeks:

**Week 1: Memory System**
- Set up memory directory
- Start using memory-manager.sh
- Learn: Auto-context loading

**Week 2: Sprint Planning**
- Create backlog
- Plan first sprint
- Learn: Structured iteration

**Week 3: Task Tools**
- Use TaskCreate in daily work
- Set up dependencies
- Learn: Structured tracking

**Week 4: Full Integration**
- Add Bead Method
- Use Scrum Master agent
- Learn: Complete workflow

**Time:** 1-2 hours per week
**Risk:** Low

---

### Option B: All at Once

Adopt everything immediately:

**Day 1: Setup (2 hours)**
1. Set up memory system
2. Create product backlog
3. Plan Sprint 1
4. Configure all templates

**Day 2-14: First Sprint**
- Use memory-manager start/end
- Daily sprint updates
- Create tasks with TaskCreate
- Track progress

**Day 14: Review & Retro**
- Sprint review
- Retrospective
- Capture learnings

**Time:** 2-4 hours setup + ongoing
**Risk:** Medium (learning curve)

---

### Option C: Memory Only

Just adopt memory system (biggest ROI):

**Setup:**
1. Run `mkdir -p .claude/memory`
2. Copy memory templates
3. Use memory-manager.sh

**Benefit:** 90% faster session starts
**Time:** 5 minutes setup
**Risk:** None

---

## Step-by-Step Migration

### Step 1: Update Framework Files

```bash
# If you have existing v4.3 project
cd /path/to/your/project

# Backup current setup
cp -r .claude .claude-backup-v4.3

# Copy new v4.4 files
# (Either download v4.4 or use git)
```

**New files in v4.4:**
- `guides/MEMORY_SYSTEM.md`
- `guides/SPRINT_MANAGEMENT.md`
- `guides/TASK_INTEGRATION.md`
- `guides/BEAD_METHOD.md`
- `agents/13-scrum-master.md`
- `toolkit/memory-manager.sh`
- `toolkit/sprint-planner.sh`
- `toolkit/templates/SPRINT.md`
- `toolkit/templates/BACKLOG.md`
- `toolkit/templates/RETROSPECTIVE.md`
- `toolkit/templates/BEAD_CHAIN.md`
- `toolkit/templates/memory/*.{json,md}`

---

### Step 2: Set Up Memory System

```bash
cd /path/to/your/project

# Create memory directory
mkdir -p .claude/memory/cross-project

# Copy memory templates
cp ~/mastering-claude-code/toolkit/templates/memory/* .claude/memory/

# Make memory manager executable
chmod +x ~/mastering-claude-code/toolkit/memory-manager.sh

# Initialize memory (optional - creates empty files)
~/mastering-claude-code/toolkit/memory-manager.sh init
```

**Configure preferences:**

Edit `.claude/memory/preferences.md` with your coding style, tool preferences, workflow preferences.

**First memory-enabled session:**

```bash
# Start session with memory
~/mastering-claude-code/toolkit/memory-manager.sh start

# Work as normal

# End session (saves memory)
~/mastering-claude-code/toolkit/memory-manager.sh end
```

---

### Step 3: Set Up Sprint Management (Optional)

**Create product backlog:**

```bash
cd /path/to/your/project

# Make sprint planner executable
chmod +x ~/mastering-claude-code/toolkit/sprint-planner.sh

# Create backlog
~/mastering-claude-code/toolkit/sprint-planner.sh backlog
```

**Plan first sprint:**

```bash
# Plan Sprint 1
~/mastering-claude-code/toolkit/sprint-planner.sh plan

# This creates docs/SPRINT_01.md and sets up tasks
```

**Daily workflow:**

```bash
# Update progress daily
~/mastering-claude-code/toolkit/sprint-planner.sh update

# Check status anytime
~/mastering-claude-code/toolkit/sprint-planner.sh status
```

**End of sprint:**

```bash
# Sprint review
~/mastering-claude-code/toolkit/sprint-planner.sh review

# Sprint retrospective
~/mastering-claude-code/toolkit/sprint-planner.sh retro

# This creates docs/RETROSPECTIVE_01.md
```

---

### Step 4: Adopt Task Integration (Optional)

**In your daily Claude Code sessions:**

Instead of markdown checklists:
```markdown
## To Do
- [ ] Task 1
- [ ] Task 2
```

Use native task tools:
```javascript
// Create tasks
TaskCreate({
  subject: "Implement login endpoint",
  description: "POST /api/login with JWT",
  activeForm: "Implementing login",
  metadata: { sprint: "1", points: 2 }
})

// Update status
TaskUpdate({ taskId: "1", status: "in_progress" })

// View all tasks
TaskList()
```

**Benefits:**
- Structured dependencies
- Better tracking
- Automated burndown

---

### Step 5: Try Bead Method (Optional)

**For your next feature:**

Instead of:
```markdown
Feature: User Authentication (8 hours)
- Build everything
- Test everything
- Commit at end
```

Use bead chain:
```markdown
Bead 1: User model (15 min) → commit
Bead 2: Password hashing (20 min) → commit
Bead 3: Register endpoint (25 min) → commit
...
```

**Create bead chain:**

```bash
# Copy template
cp ~/mastering-claude-code/toolkit/templates/BEAD_CHAIN.md docs/BEAD_CHAIN_AUTH.md

# Edit with your feature's beads

# Execute one bead at a time
```

---

### Step 6: Use Scrum Master Agent (Optional)

**Create Claude Project:**

1. In Claude.ai, create project: "Scrum Master"
2. Paste `agents/01-shared-context.md` + `agents/13-scrum-master.md`
3. Upload your project's `BACKLOG.md`

**Use for:**
- Sprint planning
- Story decomposition
- Retrospective facilitation
- Velocity analysis

---

## Verification Checklist

After migration, verify:

### Memory System
- [ ] `.claude/memory/` directory exists
- [ ] Memory templates present
- [ ] `memory-manager.sh` works
- [ ] Can start/end sessions with memory

### Sprint Management (if adopted)
- [ ] `docs/BACKLOG.md` exists
- [ ] `docs/SPRINT_01.md` created
- [ ] `sprint-planner.sh` works
- [ ] Can update sprint progress

### Task Integration (if adopted)
- [ ] Can use `TaskCreate()`
- [ ] Can use `TaskUpdate()`
- [ ] `TaskList()` shows tasks
- [ ] Tasks linked to sprint

### Bead Method (if adopted)
- [ ] Bead chain template available
- [ ] Can decompose features
- [ ] Committing after each bead

---

## Troubleshooting

### Issue: memory-manager.sh not found

**Solution:**
```bash
# Check location
ls ~/mastering-claude-code/toolkit/memory-manager.sh

# Make executable
chmod +x ~/mastering-claude-code/toolkit/memory-manager.sh

# Use full path or add to PATH
```

### Issue: Scripts don't work on Windows

**Solution:**
```bash
# Use Git Bash or WSL
# Or use Claude Code directly instead of scripts

# Manual memory loading in Claude Code:
cat .claude/memory/preferences.md
cat .claude/memory/patterns.md
# Continue work
```

### Issue: Task tools not working

**Solution:**
```javascript
// Make sure you're in Claude Code CLI (not Claude.ai web)
claude

// In Claude Code session:
TaskList()
// Should return task list or empty array
```

### Issue: Sprint planning feels overwhelming

**Solution:**
- Start with just memory system (Week 1)
- Add sprints when comfortable (Week 2-3)
- Sprints are a tool, not a requirement
- Use what helps, skip what doesn't

---

## What to Keep from v4.3

**All of these still work:**

✅ 10-agent tier-based system
✅ Skills (15 task-specific skills)
✅ Native subagents & skills
✅ MCP integration
✅ Hooks system
✅ Team Mode (optional)
✅ All existing templates

**v4.4 adds to these, doesn't replace them.**

---

## Common Questions

### Q: Do I have to use sprints?

**A:** No. Sprints are optional. You can use just the memory system or just the task tools.

### Q: Can I use v4.4 with existing projects?

**A:** Yes. Just copy the new files and start using them. No migration of existing work needed.

### Q: Will this slow me down?

**A:** Short term (Week 1): Slight learning curve
Long term: 10-20% faster due to better organization and less context switching

### Q: What if I don't like it?

**A:** Just stop using it. All v4.3 workflows still work. Delete `.claude/memory` if you want.

### Q: Do I need all 13 agents now?

**A:** No. Most daily work still uses 1-2 developer agents. Scrum Master is optional for planning.

### Q: What's the minimum viable adoption?

**A:** Just memory system:
```bash
mkdir -p .claude/memory
~/mastering-claude-code/toolkit/memory-manager.sh init
~/mastering-claude-code/toolkit/memory-manager.sh start
```

---

## Recommended Learning Path

### Week 1: Memory System

**Read:** `guides/MEMORY_SYSTEM.md` (30 min)

**Do:**
- Set up memory directory
- Configure preferences
- Use memory-manager start/end for one week
- Observe: Session starts become instant

### Week 2: Sprint Management

**Read:** `guides/SPRINT_MANAGEMENT.md` (30 min)

**Do:**
- Create backlog
- Plan 2-week sprint
- Daily progress tracking
- Experience: Structured iteration

### Week 3: Task Integration

**Read:** `guides/TASK_INTEGRATION.md` (20 min)

**Do:**
- Use TaskCreate for sprint tasks
- Set dependencies with TaskUpdate
- Track with TaskList
- Experience: Better visibility

### Week 4: Bead Method

**Read:** `guides/BEAD_METHOD.md` (20 min)

**Do:**
- Decompose one feature into beads
- Execute beads (15-45 min each)
- Commit after each bead
- Experience: Continuous integration

### Week 5: Full Integration

**Combine everything:**
- Memory-powered sessions
- Sprint-based planning
- Task-tracked execution
- Bead-level implementation

**Result:** Professional-grade workflow, sustainable velocity.

---

## Success Metrics

You'll know v4.4 is working when:

✅ Session starts take <1 minute (vs 10 minutes)
✅ You commit multiple times per day (vs once per feature)
✅ You know your velocity (X points/sprint)
✅ Scope creep is eliminated (sprint commitment locked)
✅ Retrospectives identify improvements
✅ Patterns are documented in memory
✅ You ship predictably every 2 weeks

---

## Rollback Plan

If you want to go back to v4.3:

```bash
# Restore v4.3 backup
rm -rf .claude
mv .claude-backup-v4.3 .claude

# Keep using framework as before
```

**Note:** Memory and sprint files are in separate directories, so they won't interfere with v4.3 workflow.

---

## Getting Help

**Documentation:**
- Memory: `guides/MEMORY_SYSTEM.md`
- Sprints: `guides/SPRINT_MANAGEMENT.md`
- Tasks: `guides/TASK_INTEGRATION.md`
- Beads: `guides/BEAD_METHOD.md`

**Quick reference:**
- `QUICK_REFERENCE.md` (updated for v4.4)
- `DOCUMENTATION_INDEX.md` (updated with new guides)

**Scripts help:**
```bash
./memory-manager.sh help
./sprint-planner.sh help
```

---

## Summary

**v4.4 adds project management layer to v4.3's development tools.**

**Minimum adoption:** Memory system (5 min setup, instant ROI)
**Full adoption:** Memory + Sprints + Tasks + Beads (4 weeks, compound improvements)

**Choose your own pace. Everything is optional. Nothing breaks.**

**Next:** Start with `guides/MEMORY_SYSTEM.md` and try one memory-enabled session.
