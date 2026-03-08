# Changelog — Claude Resources

All notable changes to the Claude Resources framework and multi-agent system.

---

## [4.0.0] — 2026-02-17

### Added
- **Whisper shared service** (`whisper-service/`) — Docker container running speech-to-text on port 9000, usable by any app on the mini PC
- **Client-Side Setup guide** — Cursor IDE + Claude Code CLI workflow documented in infrastructure setup prompt
- **Three interfaces documented** — Telegram (mobile/voice), Claude Code CLI (big builds), Cursor (visual browsing/tweaks)

### Changed
- Telegram bot now calls Whisper API service instead of loading model in-process (saves ~700MB RAM in bot)
- Whisper dependency removed from bot requirements (lives in Docker container now)
- Bot `.env.example` uses `WHISPER_API_URL` instead of `WHISPER_MODEL`

---

## [3.3.0] — 2026-02-16

### Added
- **Telegram Command Bot** — remote control mini PC from phone via 17 commands
- **Webhook server** (port 8787) for proactive push notifications
- **12-hour password sessions** with brute-force lockout for Telegram security
- **Task completion notifications** — orchestrator pushes to Telegram on task complete/fail
- **disk-check-webhook.sh** — routes disk alerts through Telegram bot
- **Phase 4.5** in infrastructure setup prompt for Telegram bot installation
- **generate-password-hash.py** — helper for secure password setup

### Fixed
- Orchestrator default bind changed from `0.0.0.0` to `127.0.0.1` (security)
- Resources dir default changed from `~/Desktop/Claude` to `~/Claude` (Linux compatibility)
- `FAILURE_WEBHOOK_URL` now routes through Telegram bot webhook (was broken with raw Telegram API)
- Telegram chat ID placeholder added across all config templates

### Changed
- Deployment guide: Telegram bot is now primary remote access method
- Recovery docs: service startup order includes Telegram bot
- Security notes updated to reflect 127.0.0.1 default and Telegram auth model

---

## [3.2.0] - 2026-02-16 — Single Source of Truth

### Architecture — core.py extraction
- **New file: `orchestrator/core.py`** — Side-effect-free module containing `SpendTracker`, `load_routes`, `detect_task_type`, `parse_token_usage`, and `rotate_logs`
- Both `orchestrator.py` and the test suite import from `core.py` — no more copy-pasted logic
- `core.py` can be imported without triggering FastAPI startup, `load_dotenv()`, or directory creation
- `orchestrator.py` is now a thin FastAPI wrapper around core logic

### Fixed — Route File Desync (critical, same class of bug as v3.1.0)
- **v3.1.1 had two copies of `project_routes.json`** — root copy had conservative estimates, orchestrator copy still had v3.1.0 values
- All 19 routes were desynced: orchestrator read old costs at runtime
- **v3.2.0: Single file in `orchestrator/`** — eliminated the root copy entirely
- `install.sh` updated: no longer copies routes (verifies presence instead)
- New test: `Route File Integrity` checks no duplicate exists

### Fixed — Tests that claimed to import but didn't
- v3.1.1 tests said "imports actual orchestrator code" but contained:
  - Line 79: `"""EXACT copy of orchestrator detect_task_type logic"""`
  - Line 150: `# We'll implement a test version that matches the real one`
- v3.2.0 tests genuinely `from core import SpendTracker, load_routes, detect_task_type`
- No reimplementation anywhere in test suite

### Fixed — Version strings
- Health endpoint reported "3.1.0" instead of "3.1.1" in v3.1.1
- All v3.2.0 components now report 3.2.0: VERSION, orchestrator app, health endpoint, memory-server

### Added — Actual Token Usage Tracking
- `parse_token_usage()` parses Claude CLI stderr for input/output tokens and reported cost
- `spawn_claude_agent()` returns `token_usage` dict alongside output
- `SpendTracker.record_spend()` accepts optional `actual` parameter
- `/spend` endpoint now shows `actual_daily_spend` and `actual_vs_estimated_ratio` when data available
- Task logs include token usage data for post-run analysis
- Cost drift logged: `Cost for 'coding-dashboard': estimated=$7.50, actual=$6.80 (-9%)`

### Added — Atomic Ledger Writes
- Spend ledger now writes to temp file then `os.replace()` (atomic on POSIX)
- Prevents ledger corruption from power loss, kill -9, or disk-full mid-write
- Previous behavior: direct `write_text()` could leave truncated/empty file

### Added — Log Rotation
- `rotate_logs()` removes oldest log files when project exceeds `MAX_LOGS_PER_PROJECT` (default: 200)
- Runs automatically after each agent task completes
- Prevents disk fill on mini PC during extended autonomous operation
- Configurable via `MAX_LOGS_PER_PROJECT` in `.env`

### Improved — Test Suite
- 10 test groups (up from 5 in v3.1.1), all importing from `core.py`
- New tests: token parsing, log rotation, route file integrity, actual cost tracking
- No SyntaxWarnings (fixed escaped dollar signs from v3.1.1)
- Every test verifiable: `bash tests/test-functional.sh` → 10/10 passing

### Changed — SpendTracker takes budget limits as constructor args
- Previously read global `DAILY_BUDGET_USD` / `PROJECT_BUDGET_USD` constants
- Now accepts `daily_budget` and `project_budget` parameters
- Makes unit testing possible without env var manipulation

---

## [3.1.1] - 2026-02-16 — Conservative Cost Estimates + Test Refactoring

### Changed - Cost Estimates
- **Conservative safety margin** — All cost estimates increased 1.5-2x to prevent premature budget exhaustion
  - Tweets: $0.50 → $0.75
  - Dashboards: $5.00 → $7.50
  - Governance proposals: $1.50 -> $2.50
  - API development: $3.50 → $5.50
  - Full list in `project_routes.json`
- Better to overestimate and have budget left over than underestimate and hit limits early
- After Week 1 with real data, tune down to actual observed costs

### Improved - Test Quality
- **Functional tests refactored** — Now imports actual orchestrator code instead of copy-pasting logic
- Tests validate the real routing/budget/handoff code (not a separate reimplementation)
- Prevents test logic from drifting away from production code
- Test coverage expanded to validate conservative cost estimates

### Fixed - Memory Server Version
- Updated package.json version from 1.0.0 → 3.1.1 (was missed in v3.1.0)
- All components now report 3.1.1: VERSION file, orchestrator, memory server

### Why v3.1.1
After v3.1.0 review, two optimization opportunities identified:
1. Cost estimates too optimistic (risk of budget surprises)
2. Tests copy-pasted code (risk of logic drift)

v3.1.1 addresses both for a more confident first deployment.

---

## [3.1.0] - 2026-02-16 — Deployment Fixes + Functional Tests

### Fixed - Deployment-Breaking Bug
- **project_routes.json not deployed** — The install script never copied the routing config into the orchestrator directory. All tasks silently fell through to the default `coding-prototype` agent. Fixed: install.sh now copies it, and a copy is also kept in `orchestrator/` directly.

### Fixed - Version Mismatch
- VERSION file, orchestrator, and memory server now all report **3.1.0** (were 3.0.0, 1.2.0, and 1.1.0 respectively)

### Fixed - RUNBOOK Emergency Procedure
- "Runaway costs" section told you to stop the orchestrator *then* curl it for spend data. Fixed: check spend first, read ledger from disk if already stopped.

### Fixed - Daily Budget Timezone
- `SpendTracker` now uses UTC consistently (was using local time, but RUNBOOK claimed "resets at midnight UTC")

### Added - Per-Task Cost Estimates
- Each route in `project_routes.json` now has a `cost_estimate` field (e.g. tweets=$0.50, dashboards=$5.00)
- Budget checks use task-specific estimates instead of flat $2.50 for everything
- `ESTIMATED_COST_PER_AGENT_RUN` in `.env` is now the fallback for unknown task types

### Added - Handoff Retry Endpoint
- `POST /handoffs/{project}/retry/{handoff_id}` — Resets stuck "accepted" handoffs back to "pending"
- Tracks retry count and timestamp for debugging
- Documented in RUNBOOK troubleshooting section

### Added - Graceful Shutdown
- SIGTERM/SIGINT handlers let running agents finish before exit
- `systemctl stop` no longer kills agents mid-task

### Added - Functional Test Suite
- `tests/test-functional.sh` — Tests actual logic, not just "files exist"
- 22 assertions across: routing (10 task types), budget enforcement (5 scenarios), handoff lifecycle (5 states), cost estimates, version consistency
- Runs locally without the mini PC

### Removed
- Fake user testimonials from RELEASE_NOTES (system hasn't been deployed yet)

---

## [3.0.0] - 2026-02-15 — Production Ready

### Added - Operational Documentation
- **RUNBOOK.md** - Complete operational guide for daily system management
  - Health monitoring procedures
  - Troubleshooting common issues
  - Maintenance tasks and schedules
  - Emergency recovery procedures
  - Configuration reference
  
- **COST_ANALYSIS.md** - Framework for tracking and optimizing costs
  - Cost per task type tracking template
  - Daily/weekly spend pattern analysis
  - Project-level cost breakdown
  - Budget recommendation calculator
  - Cost optimization opportunities
  
- **Enhanced DEPLOYMENT_GUIDE** - Added budget configuration section
  - Conservative starting values explained
  - Monitoring and adjustment procedures
  - Phased rollout recommendations

### Production Hardening (from v1.2.0)
- **Budget Enforcement System**
  - Daily spend limit (`DAILY_BUDGET_USD`)
  - Per-project spend limit (`PROJECT_BUDGET_USD`)
  - Persistent spend ledger survives restarts
  - Blocks new tasks when budget exceeded
  
- **Spend Tracking & Visibility**
  - `GET /spend` - Current spend summary
  - `POST /spend/reset-project/{name}` - Manual reset capability
  - Spend included in project status
  - Daily spend shown in health check
  
- **API Key Authentication**
  - Required `X-API-Key` header on all sensitive endpoints
  - Generated with: `python3 -c "import secrets; print(secrets.token_urlsafe(32))"`
  - Warning logged if not configured
  
- **Failure Handling & Recovery**
  - Webhook notifications for agent failures
  - State updates on timeout/crash
  - Task state persisted to disk
  - Auto-handoff only continues on success
  
- **Configurable Limits**
  - Agent timeout (default 30min, was 10min)
  - Handoff depth limit (default 5)
  - Concurrent agent limit (default 3)
  - All tunable via .env

### Changed
- Version numbering: v2.5 → v3.0 (production release)
- Default budgets: More conservative starting values recommended
- Documentation structure: Operational docs separated from deployment
- Status: "Ready for testing" → "Production ready"

### Documentation Improvements
- Comprehensive troubleshooting section in RUNBOOK.md
- Budget configuration best practices
- Phased rollout strategy (Week 1 → Week 2 → Month 2+)
- Cost optimization strategies

---

## [2.5.0] - 2026-02-14 — Skills Expansion

### Added - Skills Framework
- **28 automation skills** (up from 15)
  - 13 new skills across 5 new categories
  - Skills adapted from community contributions
  
- **New Skill Categories:**
  - **workflow/** — brainstorming, debugging, prompt engineering
  - **development/** — React patterns, TypeScript hardening, API design
  - **operations/** — cost optimizer, observability setup
  - **defi/** — governance writer, analytics
  - **business/** — SEO audit, Stripe integration, client onboarding

### Changed - Organization
- Folder structure reorganized by frequency of use
  - `essential/` for daily-use files
  - `advanced/` for less common features
  - `archive/` for historical versions
- Removed version number from folder name (`v4.4` → no version)
- Consolidated development artifacts

### Added - Project Contexts
- **Project context files** split by task type
  - 01-quick-reference.md (key info, rules)
  - 02-working-guidelines.md (workflow, approvals)
  - 03-technical.md (architecture)
  - Template system for adding new projects
- Task-specific loading strategy documented

---

## [2.0.0] - 2026-02-13 — Multi-Agent System

### Added - Multi-Agent Infrastructure
- **Memory MCP Server** (700+ lines TypeScript)
  - Persistent memory storage across sessions
  - Project state management
  - Agent handoff system
  - Full-text memory search
  
- **Context Router MCP Server** (400+ lines TypeScript)
  - Auto-detection of task types (17 patterns)
  - Automatic context file loading
  - YOUR_WORKING_PROFILE integration
  
- **Orchestrator Service** (640 lines Python/FastAPI)
  - Task routing API
  - Agent spawning logic
  - Handoff management
  - Status tracking
  
- **10 Enhanced Agent Templates**
  - Memory protocol integration
  - Auto-context loading instructions
  - Handoff creation guidelines
  - YOUR_WORKING_PROFILE preferences

### Added - Deployment Automation
- **install.sh** - One-command installer for mini PC
- **uninstall.sh** - Clean removal
- **test-system.sh** - Full system verification
- **test-orchestrator-api.sh** - API endpoint tests

### Added - Documentation
- Multi-agent architecture documentation
- Memory system API reference
- Agent coordination workflows
- Example handoff scenarios

---

## [1.2.0] - 2026-02-15 — Critical Fixes

### Added - Budget Controls
- SpendTracker class for budget enforcement
- Spend ledger with daily and project limits
- API endpoints for spend monitoring
- Budget check before agent spawn

### Fixed - Production Issues
- **Timeout:** Increased from 10min to 30min configurable
- **Routing:** Weighted keywords prevent misroutes
- **Autonomous mode:** Agents make defaults instead of asking questions
- **Handoffs:** Crash-safe (pending → accepted, not deleted)
- **State:** Updates on failure, not just success
- **Concurrency:** File-level locking prevents corruption

### Security
- API key authentication added
- Unauthenticated access blocked
- Warning if API key not set

---

## [1.1.0] - 2026-02-14 — Initial Multi-Agent Build

### Added - Core Components
- Memory server implementation
- Context router implementation
- Basic orchestrator (without budget controls)
- Agent templates with memory protocol
- Deployment scripts

### Known Issues (Fixed in v1.2.0)
- No budget enforcement
- 10min timeout too short
- Agents try to ask questions in --print mode
- Handoffs deleted on read (crash-unsafe)

---

## [1.0.0] - 2026-02-13 — Foundation

### Added - Claude Code Framework
- **10 specialized AI agents**
  - System Architect
  - Product Manager
  - Designer
  - API Architect
  - Frontend Developer
  - Backend Developer
  - Security Auditor
  - System Tester
  - DevOps Engineer
  - Technical Writer
  
- **15 automation skills** (original set)
  - Emergency: git recovery, dependency resolver, env validator, docker debugger, build error fixer
  - Scaffolding: Next.js API, React component, test scaffold, database migration, auth middleware
  - Deployment: Vercel deployer, GitHub Actions, docker-compose generator
  - Quality: security scanner, accessibility checker

### Added - Templates
- Docker templates (python-web)
- Project scaffolding
- Memory management
- Sprint planning

### Added - Guides
- THE_COMPLETE_VIBE_CODER_GUIDE.md
- DAY_ZERO.md (complete beginner)
- FIRST_PROJECT.md (guided tutorial)
- DAILY_WORKFLOW.md
- GIT_FOR_VIBE_CODERS.md
- EMERGENCY_RECOVERY_VIBE_CODER.md
- TROUBLESHOOTING.md
- PITFALLS.md
- COSTS.md

### Added - Your Working Profile
- YOUR_WORKING_PROFILE.md - Personalized agent behavior
  - Communication style preferences
  - Code delivery rules (complete files only)
  - Task workflow expectations
  - Error handling approach
  - Git workflow protocol
  - Technology stack preferences

---

## Version History Summary

| Version | Date | Focus | Status |
|---------|------|-------|--------|
| 3.1.1 | 2026-02-16 | Conservative cost estimates + test refactoring | ✅ Complete |
| 3.1.0 | 2026-02-16 | Deployment fixes + functional tests | ✅ Complete |
| 3.0.0 | 2026-02-15 | Production hardening + ops docs | ✅ Complete |
| 2.5.0 | 2026-02-14 | Skills expansion | ✅ Complete |
| 2.0.0 | 2026-02-13 | Multi-agent system | ✅ Complete |
| 1.2.0 | 2026-02-15 | Critical fixes (budget, security) | ✅ Complete |
| 1.1.0 | 2026-02-14 | Initial multi-agent build | ⚠️ Superseded |
| 1.0.0 | 2026-02-13 | Foundation framework | ✅ Complete |

---

## Upgrade Path

### From v2.5 to v3.0
1. All files compatible, no breaking changes
2. New operational docs added (optional but recommended)
3. Enhanced budget controls from v1.2.0 included
4. Review RUNBOOK.md and COST_ANALYSIS.md
5. Set conservative .env values for deployment

### From v1.x to v3.0
1. Multi-agent system completely redesigned
2. Budget controls added (critical)
3. API authentication required (breaking change)
4. Review all .env settings
5. Test locally before deploying

---

## Breaking Changes

### v3.0.0
- None (fully backward compatible with v2.5)

### v2.0.0
- Multi-agent orchestrator requires new deployment
- MCP servers need separate installation
- API key authentication required

### v1.2.0
- API key authentication now required (was optional)
- ORCHESTRATOR_API_KEY must be set in .env

---

## Deprecations

### Removed in v3.0
- None

### Removed in v2.5
- Old skills-cli format (moved to essential/skills/)
- Versioned folder names (mastering-claude-code-v4.4 → claude-code-framework)

---

## Roadmap

### Planned for v3.1 (Future)
- [ ] Task-specific cost estimation (vs flat $2.50)
- [ ] Advanced cost prediction based on task description
- [ ] Agent performance metrics (speed, quality)
- [ ] Multi-model support (Opus for complex, Haiku for simple)

### Planned for v4.0 (Future)
- [ ] Web dashboard for monitoring
- [ ] Real-time cost tracking visualization
- [ ] Agent marketplace (community-contributed agents)
- [ ] Advanced analytics and reporting

---

## Migration Guides

See `claude-code-framework/archive/migration-guides/` for:
- UPGRADING_V4.2_TO_V4.3.md
- UPGRADING_V4.3_TO_V4.4.md
- V4.4_MIGRATION_CHECKLIST.md

---

**Current Stable Version:** 3.1.1  
**Status:** Production ready  
**Last Updated:** February 15, 2026
