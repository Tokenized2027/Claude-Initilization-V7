# Compatibility & Version Requirements

> **Last verified:** February 12, 2026

## Required Software

| Software | Minimum Version | Recommended | Notes |
|----------|----------------|-------------|-------|
| Ubuntu | 22.04 LTS | 24.04 LTS | Other Linux distros work but commands may differ |
| Node.js | 18 LTS | 22 LTS | Install via nvm, not apt |
| npm | 9.x | 10.x | Comes with Node.js |
| Docker Engine | 24.x | 27.x | NOT Docker Desktop — use the apt/official install |
| Docker Compose | v2.20+ | v2.30+ | Plugin version (`docker compose`, not `docker-compose`) |
| Python | 3.10+ | 3.11+ | For Python-based projects |
| Git | 2.30+ | 2.40+ | Usually pre-installed on Ubuntu |
| Claude Code CLI | Latest | Latest | `npm install -g @anthropic-ai/claude-code` |

## Claude Code CLI

Claude Code updates frequently. The framework's hooks and settings.json format may need adjustment when Claude Code ships breaking changes.

**Before configuring hooks on a new machine, always run:**

```bash
claude /help hooks
```

Check the official docs for the current format: https://docs.claude.com/en/docs/claude-code/hooks

The hook **scripts** (`.sh` files in this repo) are standard bash and will work regardless of Claude Code version. Only the `settings.json` trigger configuration may change between versions.

## Framework Defaults

The scaffolding scripts and templates assume these defaults:

| Setting | Default | Change In |
|---------|---------|-----------|
| Frontend framework | Next.js (App Router) | Agent prompts, create-project.sh |
| CSS framework | Tailwind CSS | Agent prompts |
| Language | TypeScript | Agent prompts, templates |
| Theme | Dark | Agent prompts |
| Package manager | npm/pnpm | create-project.sh |
| Database | PostgreSQL (infra), SQLite (small projects) | Infrastructure prompt |
| Git branch strategy | main → develop → feature/* | CLAUDE.md template, hooks |

To change a default, update it in the relevant agent prompt and/or template. The framework is not opinionated about your stack — these are just starting points.

## Known Compatibility Issues

| Issue | Affected Versions | Workaround |
|-------|-------------------|------------|
| `docker compose` vs `docker-compose` | Docker Compose v1 (hyphenated) | Install the v2 plugin: `sudo apt-get install docker-compose-plugin` |
| Node.js via apt is outdated | Ubuntu 22.04 ships Node 12 | Always install via nvm, never apt |
| `settings.json` hook format | Claude Code pre-2025 | Run `claude /help hooks` for current format |
| Tailwind v4 breaking changes | Tailwind 4.x vs 3.x | Check if your version needs `@tailwind` directives or `@import "tailwindcss"` |
| Next.js 15 `async` params | Next.js 15+ | Route params are now async — agent prompts account for this |

## Hardware Requirements

For the mini PC infrastructure setup:

| Use Case | Minimum | Recommended |
|----------|---------|-------------|
| Docker + databases + monitoring | 8GB RAM, 256GB SSD | 16GB RAM, 512GB SSD |
| Above + multiple projects | 16GB RAM, 512GB SSD | 32GB RAM, 1TB SSD |
| Above + local LLM inference | 32GB RAM, dedicated GPU | Not covered by this framework |

## Updating the Framework

When updating to a new version of this framework:

1. Check CHANGELOG.md for breaking changes
2. Back up your customized agent prompts and project briefs
3. Diff the new templates against your customized versions
4. Re-run `claude /help hooks` to verify hook format compatibility
5. Run `bash toolkit/test-scaffold.sh` to verify scripts work
