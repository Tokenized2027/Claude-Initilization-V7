# Your First Project — A Guided Walkthrough

> **Time:** ~2 hours  
> **What you'll build:** A simple link bookmarker with tags — a personal URL saver  
> **What you'll learn:** The complete workflow from idea → PRD → Tech Spec → scaffold → build → deploy  
> **Prerequisites:** Mini PC set up (or any machine with Claude Code installed), Node.js, git

This tutorial uses every piece of the framework for real. By the end, you'll have a working app AND muscle memory for the workflow.

---

## Step 1: Scaffold the Project (5 minutes)

Open a terminal on your dev machine and run:

```bash
cd ~/projects
# If you have the toolkit scripts:
bash $CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh

# When prompted:
#   Project name: link-vault
#   Framework: nextjs
#   Features: select hooks, all templates
```

If you don't have the scripts set up yet, create it manually:

```bash
mkdir -p ~/projects/link-vault
cd ~/projects/link-vault
git init
mkdir -p app components lib types docs .claude/hooks logs tmp
touch .env .env.example .gitignore CLAUDE.md STATUS.md README.md
```

Copy the CLAUDE.md and STATUS.md templates from `essential/toolkit/templates/` into your project root.

**Verify:** `ls` shows the project structure. `git status` shows untracked files.

---

## Step 2: Write the PRD (20 minutes)

Start Claude Code in your project:

```bash
cd ~/projects/link-vault
claude
```

Paste this prompt:

```
Read CLAUDE.md. Then help me create a PRD for this project.

The idea: A personal link bookmarker. I save URLs with a title, optional 
description, and tags. I can search and filter by tag. That's it — dead simple.

Before writing anything, ask me at least 8 questions about what I want. 
This is iterative — we go back and forth until the PRD is right. 
Save as docs/PRD.md
```

Claude Code will ask you questions like:
- Do you need user authentication? → **No, single user, no login**
- Where should links be stored? → **SQLite file (simplest possible)**
- Do you want to import/export? → **Not in v1, maybe later**
- Mobile-responsive? → **Yes, I'll use it on my phone**

Answer honestly. When it produces a draft, read it. Ask for changes. Approve when satisfied.

**Verify:** `cat docs/PRD.md` shows a complete PRD. It should have user stories, acceptance criteria, and an MVP definition.

---

## Step 3: Write the Tech Spec (15 minutes)

Same Claude Code session (or start fresh — if fresh, say "Read CLAUDE.md and docs/PRD.md"):

```
Based on the approved PRD, create a Technical Specification.
Ask me clarifying questions about stack preferences before writing.
Save as docs/TECH_SPEC.md
```

When it asks about stack:
- **Framework:** Next.js with App Router
- **Database:** SQLite via better-sqlite3 (no Docker needed for this)
- **Styling:** Tailwind CSS, dark theme
- **Deployment:** Run locally on the mini PC for now

Review the tech spec. Make sure the API endpoints and data model look right.

**Verify:** `cat docs/TECH_SPEC.md` shows architecture, API design, data model, and file structure.

---

## Step 4: Update STATUS.md (2 minutes)

```
Update STATUS.md:
- Phase 0 complete (PRD and Tech Spec approved)
- List the Phase 1 tasks from the Tech Spec
- Add key decisions to the decisions table
- Link PRD and Tech Spec in CLAUDE.md
- Commit everything: git add -A && git commit -m "chore(setup): PRD and tech spec approved"
```

**This is the habit you're building:** STATUS.md gets updated after every milestone.

---

## Step 5: Build the Backend (30 minutes)

If using the agent system, open your **Backend Developer** Claude Project and paste the project brief + the tech spec. Otherwise, continue in Claude Code:

```
Read CLAUDE.md, STATUS.md, and docs/TECH_SPEC.md.

Build the backend for link-vault:
1. SQLite database setup with the schema from the tech spec
2. API routes for: create link, get all links, search/filter by tag, delete link
3. Input validation on all endpoints

Give me complete files. Start with terminal commands, then code, then verification.
After each file, commit.
```

Let Claude Code build. After each API route, verify:

```
Give me curl commands to test each endpoint.
```

Run them. Confirm they work. If something fails, paste the error back.

**Verify:** You can create, list, search, and delete links via curl.

---

## Step 6: Build the Frontend (30 minutes)

If using agents, open **Frontend Developer** with the project brief + backend handoff. Otherwise, continue:

```
Read STATUS.md. The backend API is working.

Build the frontend:
1. Main page showing all saved links (newest first)
2. "Add Link" form (URL, title, description, tags)
3. Tag filter sidebar or tag pills
4. Search bar that searches titles and descriptions
5. Delete button on each link
6. Dark theme, mobile-responsive

Use the API routes we just built. Handle loading, error, and empty states.
Complete files only. Commit after each component.
```

**Verify:** Open `http://localhost:3000` (or your Tailscale URL). Add a few links. Search. Filter by tag. Delete one. Resize to mobile width.

---

## Step 7: Test (10 minutes)

If using the agent system, open **System Tester**. Otherwise:

```
Read STATUS.md. Run through a complete test of the app:

1. Add 5 different links with various tags
2. Verify they all appear on the main page
3. Search for a specific title — does it filter correctly?
4. Click a tag — does it filter correctly?
5. Delete a link — does it disappear?
6. Try adding a link with no URL — does validation work?
7. Try adding a link with a very long title — does the UI handle it?
8. Check mobile view — is everything readable and tappable?

Report what works and what's broken.
```

Fix any bugs. Commit after each fix.

---

## Step 8: End-of-Session Wrap-Up (5 minutes)

```
End of session:
1. Update STATUS.md with current state — what works, what's left
2. Commit all work
3. List any open bugs
4. Give me a CONTINUATION BRIEF in case I come back later
```

**Verify:** `cat STATUS.md` shows a complete picture. `git log --oneline` shows a clean commit history.

---

## What You Just Practiced

| Framework Concept | Where You Used It |
|-------------------|-------------------|
| CLAUDE.md as rules file | Claude Code read it at every session start |
| STATUS.md as source of truth | Updated after every milestone |
| PRD → Tech Spec → Build flow | Steps 2-6 |
| Iterative doc creation | Claude asked questions, you reviewed drafts |
| Complete files only | Every file Claude produced was copy-pasteable |
| Commit after every unit | Multiple commits throughout |
| Error → paste → fix cycle | Step 7 (testing and bug fixes) |
| Continuation brief | Step 8 (session handoff) |
| Agent pipeline (optional) | Backend Dev → Frontend Dev → Tester |

---

## Common Issues During This Tutorial

| Problem | Fix |
|---------|-----|
| Claude Code produces partial files | Remind it: "The rule is COMPLETE files only. Give me the entire file." |
| SQLite "database locked" errors | Make sure only one process accesses the DB. Restart the dev server. |
| Tailwind classes not working | Run `npx tailwindcss init` and check `tailwind.config.ts` includes your content paths |
| API returns 500 with no detail | Add `console.error(error)` in your API route catch blocks and check terminal output |
| Claude Code forgets the project rules | Say: "Re-read CLAUDE.md and confirm you're following all rules." |

---

## Next Steps

You've built a real (simple) app using the full framework. Now:

1. **Add a feature** using Direct Mode — go straight to the relevant developer agent
2. **Try the full pipeline** on a more complex project — start with System Architect
3. **Deploy it properly** — add a Dockerfile, put it in Docker Compose, set up the webhook auto-deploy from Phase 4
4. **Read `essential/guides/PITFALLS.md`** — now that you've used Claude Code, the pitfalls will make more sense
