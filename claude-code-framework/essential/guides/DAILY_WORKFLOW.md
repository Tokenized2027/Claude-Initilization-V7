# Daily Workflow & Conversation Management

This guide covers the practical, day-to-day mechanics of working with Claude Code: when to start new conversations, how to maintain context, and how to structure your sessions for maximum effectiveness.

---

## Table of Contents

1. [Conversation Lifecycle](#conversation-lifecycle)
2. [When to Start a New Conversation](#when-to-start-a-new-conversation)
3. [Context Management Strategies](#context-management-strategies)
4. [Claude Code CLI vs. Claude Projects](#claude-code-cli-vs-claude-projects)
5. [Daily Work Patterns](#daily-work-patterns)
6. [Continuation Briefs](#continuation-briefs)
7. [Multi-Session Work](#multi-session-work)
8. [Common Mistakes](#common-mistakes)

---

## Conversation Lifecycle

Every Claude conversation has a context window (~200K tokens). Once that fills up, the oldest messages get dropped. Understanding this lifecycle prevents loss of important context.

**Typical conversation arc:**
1. **Initialization (0-10 messages):** Load project context, agent prompts, current task
2. **Active work (10-50 messages):** Implement features, fix bugs, iterate on code
3. **Context saturation (50-100 messages):** Window fills, oldest context starts dropping
4. **Degradation (100+ messages):** Agent "forgets" early project details, makes mistakes

**Signs a conversation is getting stale:**
- Claude asks about things you already discussed
- Claude violates CLAUDE.md rules you set early in the conversation
- Claude rewrites code that was working fine
- Response quality degrades (more generic, less project-specific)
- STATUS.md updates become vague

**What to do:** Start a fresh conversation with a continuation brief (see below).

---

## When to Start a New Conversation

### ✅ **Always start fresh for:**

1. **New major features** — Each feature gets its own conversation
   - Example: "Build user authentication" → new conversation
   - Why: Clean slate, focused context, easier to review later

2. **After extended breaks** — If you haven't worked on the project in 24+ hours
   - Example: Monday morning after weekend break
   - Why: Fresh start, updated mental model

3. **When switching work types** — Going from coding to documentation or infrastructure
   - Example: Finished API work, now setting up Docker
   - Why: Different agent, different mindset

4. **When context is saturated** — 50+ message exchanges in current conversation
   - Why: Prevent degradation, maintain quality

5. **When debugging gets circular** — Same bug, multiple failed attempts
   - Example: 5+ messages trying to fix the same error
   - Why: Fresh perspective often solves stuck problems

6. **When agent is "forgetting"** — Claude violates rules or asks about known context
   - Why: Context window is full, need to reload

### ⚠️ **Consider continuing for:**

1. **Small iterations** — Tweaking styling, fixing typos, minor refactors
2. **Follow-up questions** — Clarifications within same task
3. **Quick bug fixes** — Single-issue debugging with clear error

### ❌ **Don't start fresh for:**

1. **Every tiny change** — "Change button color to blue" doesn't need new conversation
2. **Questions about current code** — Stay in conversation where that code was written

---

## Context Management Strategies

### Strategy 1: Project Brief Every Time (Recommended for Beginners)

**Pattern:**
```
Every conversation starts with:
1. Agent prompt (from essential/agents/ folder)
2. Project brief (CLAUDE.md + STATUS.md + PRD)
3. Your task
```

**Pros:**
- Agent always has full project context
- Consistent behavior across conversations
- Easy to remember

**Cons:**
- Slightly slower start (20-30 seconds to process)
- Uses more tokens (but prompt caching makes this ~90% free)

**When to use:** All the time until you're very comfortable with the system.

---

### Strategy 2: Continuation Briefs for Long Work

**Pattern:**
```
Day 1 conversation: Load full context, build feature X
Day 2 conversation: Load continuation brief, add to feature X
```

A continuation brief is a mini-document you create at end of a session:

```markdown
# Continuation Brief — 2025-02-11

## What Was Done
- Built user authentication API (Flask)
- Created /register and /login endpoints
- Set up JWT token generation
- Added password hashing with bcrypt

## Current State
- Backend works, tested with curl
- Frontend login form exists but doesn't connect yet
- Need to wire frontend to backend API

## Next Steps
1. Create API client in frontend (lib/api.ts)
2. Connect LoginForm to POST /api/login
3. Store JWT in localStorage
4. Add auth middleware to protected routes

## Files Changed
- backend/api/auth.py
- backend/models/user.py
- frontend/components/LoginForm.tsx

## Known Issues
- Login endpoint returns 500 on duplicate email (should be 400)
- Password validation not implemented yet
```

**How to create one:**

At end of a session, ask Claude:
> "Create a continuation brief for the next session. Include what was built, current state, next steps, and files changed."

Save the output as `continuation-brief-YYYY-MM-DD.md` in your project root.

**How to use one:**

Start next session with:
> "Here is the continuation brief from last session: [paste brief]. Continue from where we left off."

**When to use:** Multi-day features, complex implementations, team handoffs.

---

### Strategy 3: Minimal Context for Focused Tasks

**Pattern:**
```
Conversation starts with:
1. Agent prompt
2. Specific file or component context
3. Your task
```

**Example:**
> "Here is the current LoginForm.tsx component. Add form validation for email format and password length."

**Pros:**
- Fastest start
- Agent stays hyper-focused
- Best for small, isolated changes

**Cons:**
- Agent doesn't know broader project context
- Can make decisions that conflict with project standards

**When to use:** Bug fixes, isolated component work, quick experiments.

---

## Claude Code CLI vs. Claude Projects

You have two ways to work with Claude Code. Understanding when to use each maximizes effectiveness.

### Claude Code CLI (Terminal)

**What it is:** Terminal command `claude` that starts an interactive session.

**Pros:**
- Fast startup
- Direct file access in current directory
- Great for focused, single-task work
- Auto-commits to git
- Can run shell commands directly

**Cons:**
- No persistent project memory
- Must manually load context each session
- One conversation at a time

**When to use:**
- Bug fixes
- Feature implementation within single session
- Infrastructure tasks (Docker, deployments)
- Quick experiments

**Typical workflow:**
```bash
cd ~/projects/my-app
claude
# In Claude Code session:
paste agent prompt → paste CLAUDE.md → "Build login form"
# Work, commit, done
exit
```

---

### Claude Projects (Web/Mobile)

**What it is:** The claude.ai web interface or Claude mobile app, with Projects feature enabled.

**Pros:**
- Persistent project knowledge across conversations
- Can upload files (CLAUDE.md, STATUS.md, dependencies)
- Better for long-term project work
- Can switch between multiple projects
- Conversation history accessible from any device

**Cons:**
- No direct file system access (must copy/paste code)
- No shell command execution
- Manual git commits
- Slightly slower for rapid iteration

**When to use:**
- Multi-day features
- Projects you return to frequently
- When you need conversation history
- Planning and architecture discussions
- Remote work (mobile/tablet)

**Typical workflow:**
```
1. Create Claude Project called "MyApp"
2. Upload CLAUDE.md, STATUS.md, PRD
3. Have conversations over days/weeks
4. Claude remembers project context automatically
5. Copy code from Claude → paste into editor → git commit manually
```

---

### Decision Matrix

| Task Type | Duration | CLI or Projects? |
|-----------|----------|------------------|
| Bug fix | 5-30 min | CLI |
| Feature (single session) | 1-4 hours | CLI |
| Feature (multi-session) | Days | Projects |
| Architecture planning | Any | Projects |
| Infrastructure setup | 1-4 hours | CLI |
| Code review | Any | Either |
| Documentation | Any | Projects |
| Experiments | <1 hour | CLI |

---

## Daily Work Patterns

### Pattern 1: Morning Start (Fresh Day)

```
1. Open terminal, cd to project
2. Check STATUS.md for current state
3. Start Claude Code CLI: `claude`
4. Paste agent prompt + CLAUDE.md
5. Review STATUS.md with Claude, plan the day
6. Work on 1-2 focused tasks
7. Update STATUS.md before ending session
8. Git commit
```

**Time:** 4-6 hours of focused work

**Result:** 1-2 completed features or major bug fixes

---

### Pattern 2: Continuation Work (Multi-Day Feature)

```
Day 1:
1. Start new conversation
2. Load full project context
3. Build feature foundation
4. Create continuation brief
5. Git commit

Day 2:
1. Start new conversation
2. Load continuation brief
3. Continue building feature
4. Update continuation brief
5. Git commit

Day 3:
1. Start new conversation
2. Load continuation brief
3. Finish feature, test, polish
4. Update STATUS.md
5. Git commit
```

---

### Pattern 3: Bug Fixing Sprint

```
For each bug:
1. New conversation
2. Load minimal context (agent + bug description)
3. Fix bug
4. Git commit
5. Next bug
```

**Why separate conversations:** Each bug is independent, clean slate prevents confusion.

---

### Pattern 4: Exploratory/Experimental

```
1. Start Claude Projects conversation
2. No formal context loading
3. "I want to experiment with [technology/approach]"
4. Rapid back-and-forth
5. If successful → start formal CLI session to implement for real
```

**Why Projects:** Easier to have free-form discussions, save history for later reference.

---

## Continuation Briefs

Continuation briefs are the key to multi-session work. Think of them as "save points" for your project state.

### What to Include

**1. What Was Done** (2-3 sentences)
- Concrete accomplishments from last session
- Not "worked on auth" but "built login/register endpoints with JWT"

**2. Current State** (bulleted list)
- What works
- What's stubbed/incomplete
- What's broken

**3. Next Steps** (ordered list)
- Specific, actionable tasks
- Start with verbs: "Create", "Wire up", "Fix", "Test"

**4. Files Changed** (list)
- Every file touched, with full path
- Helps Claude understand scope

**5. Known Issues** (optional)
- Bugs discovered but not fixed
- Edge cases not handled
- Technical debt incurred

### Templates

**For feature work:**
```markdown
# Continuation Brief — [Date]

## What Was Done
[2-3 sentences]

## Current State
- ✅ Working: [list]
- ⚠️ Stubbed: [list]
- ❌ Broken: [list]

## Next Steps
1. [verb] [noun]
2. [verb] [noun]
3. [verb] [noun]

## Files Changed
- path/to/file1.ts
- path/to/file2.py

## Known Issues
- [issue 1]
- [issue 2]
```

**For bug fixing:**
```markdown
# Bug Fix Brief — [Date]

## Bug Description
[What's wrong, how to reproduce]

## Investigation So Far
[What you've tried, what didn't work]

## Suspected Cause
[Your hypothesis]

## Files Involved
- path/to/file1
- path/to/file2

## Next Debug Steps
1. [step]
2. [step]
```

---

## Multi-Session Work

Long features spanning multiple sessions require careful handoff between conversations.

### Day 1: Foundation
- Load full project context
- Build core functionality
- Get to "works in isolation"
- Create detailed continuation brief

### Day 2-N: Iteration
- Load continuation brief
- Add features incrementally
- Keep STATUS.md updated
- Update continuation brief daily

### Final Session: Polish
- Load continuation brief
- Integration testing
- Edge case handling
- Documentation
- Final STATUS.md update

**Key principle:** Each session should end with a working, committable state. No half-finished features.

---

## Common Mistakes

### ❌ Mistake 1: Never Starting Fresh
**Problem:** One 200-message conversation for entire project
**Impact:** Agent loses context, quality degrades, frustration builds
**Fix:** Start new conversation every 50 messages or major feature

---

### ❌ Mistake 2: Starting Fresh Too Often
**Problem:** New conversation for every tiny change
**Impact:** Waste time reloading context, lose flow
**Fix:** Group related small changes in one conversation

---

### ❌ Mistake 3: Not Using Continuation Briefs
**Problem:** Start Day 2 with "continue from yesterday"
**Impact:** Agent doesn't know what "yesterday" was, makes wrong assumptions
**Fix:** Always create continuation brief at end of session

---

### ❌ Mistake 4: Vague Task Descriptions
**Problem:** "Fix the app" or "Make it better"
**Impact:** Agent makes random changes, you waste time
**Fix:** Specific tasks: "Fix login form validation for email format"

---

### ❌ Mistake 5: Ignoring STATUS.md
**Problem:** Never update STATUS.md, always paste full context
**Impact:** Waste tokens, slower starts, agent confused about current state
**Fix:** Update STATUS.md after every session, paste it instead of full context

---

### ❌ Mistake 6: Mixing Work Types in One Conversation
**Problem:** Build API, then switch to frontend, then DevOps, all in one chat
**Impact:** Agent confused, mistakes increase
**Fix:** One conversation = one work type

---

### ❌ Mistake 7: Not Reading Agent Responses Fully
**Problem:** Skim Claude's response, miss important details
**Impact:** Bugs slip through, agent makes assumptions you didn't catch
**Fix:** Read every response fully before saying "continue" or "looks good"

---

## Summary

**For most vibe coders, this pattern works best:**

1. **Start each work session with a fresh conversation**
2. **Load agent prompt + CLAUDE.md at minimum**
3. **For multi-day work, create continuation briefs**
4. **Use CLI for implementation, Projects for planning**
5. **Update STATUS.md after every session**
6. **Start new conversation after 50 messages or major task completion**

**Remember:** Context management is a skill. It gets easier with practice. When in doubt, start fresh—it's better to reload context than fight a degraded conversation.
