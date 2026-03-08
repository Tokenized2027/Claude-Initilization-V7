# Project Context: [PROJECT NAME]

> Copy this entire `_template/` folder, rename it to your project name, and fill in the files below.
> Delete this instruction block when done.

## Quick Setup

1. Copy: `cp -r project-contexts/_template project-contexts/your-project-name`
2. Fill in each file below (delete placeholder comments as you go)
3. Add a task→context mapping to `START_HERE.md` Section 3
4. If using the orchestrator: add task routes to `multi-agent-system/project_routes.json`

---

## Files in This Context

| File | Purpose | When to Load |
|------|---------|--------------|
| `00-master-index.md` | What's in each file, quick lookup | Always (tiny file) |
| `01-quick-reference.md` | Key facts, addresses, links, names | Most tasks |
| `02-working-guidelines.md` | Tone, approvals, workflow rules | Content, comms, BD |
| `03-technical.md` | Architecture, APIs, tech stack | Coding, debugging |

## Context Loading Matrix

| Task | Files to Load |
|------|---------------|
| **Content/Social** | `YOUR_WORKING_PROFILE.md` + `01-quick-reference.md` + `02-working-guidelines.md` |
| **Technical Work** | `YOUR_WORKING_PROFILE.md` + `01-quick-reference.md` + `03-technical.md` |
| **General/BD** | `YOUR_WORKING_PROFILE.md` + `01-quick-reference.md` + `02-working-guidelines.md` + `03-technical.md` |

Add or remove rows as needed for your project.
