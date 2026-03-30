# Typed Memory System for Claude Code

Claude Code supports a persistent memory system that survives across sessions. This document explains how to structure memories by type so Claude builds a useful, organized knowledge base over time.

## How It Works

Claude Code stores memories in `~/.claude/` (global) and `.claude/` (per-project). The primary file is `MEMORY.md`, which Claude reads at session start and writes to when corrected or when important context emerges.

The key insight: unstructured memory becomes noise. Typed categories keep it navigable.

## Memory Types

### 1. User Preferences (`feedback_*`)

Corrections to Claude's behavior. When the user says "don't do X" or "always do Y", write it here FIRST, then adjust behavior.

Examples:
- `feedback_typecheck_before_push.md` : Always run typecheck before pushing code
- `feedback_no_grey_text.md` : Never use grey text in UI output
- `feedback_mobile_first.md` : Design for mobile viewport first

**Trigger:** User corrects Claude. Write to memory BEFORE responding.

### 2. Project Context (`project_*`)

Facts about the project that Claude needs across sessions: architecture decisions, team agreements, current sprint goals.

Examples:
- `project_auth_strategy.md` : Using JWT with PIN login, no passwords
- `project_deploy_targets.md` : Staging on port 3001, production on 443
- `project_current_sprint.md` : Sprint 12, shipping notification system

**Trigger:** After significant architecture decisions or when context would be lost between sessions.

### 3. Infrastructure (`infra_*`)

Server details, CI/CD setup, environment specifics that Claude needs for operational tasks.

Examples:
- `infra_ci_runners.md` : Self-hosted GitHub Actions runners on Docker
- `infra_database.md` : PostgreSQL on AWS RDS, connection via env var
- `infra_deploy_pipeline.md` : deploy.yml workflow, manual trigger only

**Trigger:** After setting up or changing infrastructure.

### 4. Reference (`reference_*`)

Reusable information: command cheat sheets, API patterns, naming conventions.

Examples:
- `reference_git_conventions.md` : Conventional commits, branch naming
- `reference_api_patterns.md` : Standard error response shape
- `reference_env_vars.md` : Required environment variables per service

**Trigger:** When a pattern is used 3+ times or documented for the team.

### 5. Cross-project Patterns (`cross_project_*`)

Patterns that apply across multiple repositories. Prevents re-learning the same lesson in each project.

Examples:
- `cross_project_docker_patterns.md` : Standard Dockerfile structure
- `cross_project_testing.md` : Always mock external services in tests

**Trigger:** When a pattern proves useful in 2+ projects.

## File Structure

```
~/.claude/
  MEMORY.md              # Index file with categorized links
  memory/
    feedback_*.md        # User corrections and preferences
    project_*.md         # Project-specific context
    infra_*.md           # Infrastructure details
    reference_*.md       # Reusable reference material
    cross_project_*.md   # Multi-repo patterns
```

## MEMORY.md Index Format

The index file uses sections to group memory entries:

```markdown
# MEMORY

## Routing: Check These First
- [Typecheck before push](feedback_typecheck_before_push.md) : short description
- [Deploy targets](infra_deploy_targets.md) : staging vs production

## Infrastructure
- [CI runners](infra_ci_runners.md) : self-hosted Docker runners
- [Database](infra_database.md) : PostgreSQL on AWS RDS

## Project Context
- [Auth strategy](project_auth_strategy.md) : JWT + PIN login
- [Current sprint](project_current_sprint.md) : Sprint 12

## References
- [Git conventions](reference_git_conventions.md) : branch naming, commits
```

## Rules

1. **Write-Ahead Logging (WAL):** When corrected, write to memory FIRST, then respond. This ensures the correction persists even if the session ends.

2. **One fact per file.** Each memory file should cover one concept. Keep them short (5-15 lines).

3. **Index stays current.** Every memory file must have an entry in MEMORY.md. Orphan files get lost.

4. **Prune regularly.** Mark outdated entries. Delete memories that no longer apply (e.g., old infrastructure that was replaced).

5. **No secrets in memory.** Never store API keys, passwords, tokens, or connection strings. Reference where to find them instead ("see .env on production server").

## Session Start Protocol

At the beginning of each session:
1. Read `MEMORY.md` index
2. Read any `feedback_*` entries in the "Routing: Check These First" section
3. Read project-specific entries relevant to the current task
4. Check for stale entries that should be pruned

## Template: New Memory Entry

```markdown
# [Title]

**Created:** [date]
**Type:** feedback | project | infra | reference | cross_project

[1-3 sentences describing the fact, rule, or pattern.]

## Context
[Why this matters. What went wrong before, or what decision was made.]
```
