# Claude V3.3.0 — Telegram Remote Control

**Release Date:** February 16, 2026
**Upgrade from v3.2.0:** Drop-in replacement + new `telegram-bot/` directory.

---

## Why V3.3

V3.2 had the right architecture but three configuration issues and a missing capability:

1. **Orchestrator bound to 0.0.0.0** — exposed the API on all interfaces despite the infrastructure setup prompt explicitly saying "bind to 127.0.0.1." Now defaults to `127.0.0.1`.

2. **Resources dir wrong for Linux** — `.env.example` defaulted to `$HOME/Desktop/Claude`. The mini PC runs Linux where the deployment guide says `~/Claude/`. Now defaults to `$HOME/Claude`.

3. **Telegram webhook format broken** — `FAILURE_WEBHOOK_URL` comment showed a Telegram API URL format, but `notify_failure()` sends a generic JSON body that Telegram's `sendMessage` endpoint doesn't accept. Fixed by routing through the new Telegram bot webhook.

4. **No remote control** — submitting tasks required SSH + curl. Now there's a Telegram bot.

---

## What's New

### Telegram Command Bot (`telegram-bot/`)

Full remote control of the mini PC via Telegram messages:

- **17 commands:** system health, Docker management, task submission, shell commands, backup triggers, budget tracking
- **12-hour password sessions** with brute-force lockout (5 attempts → 5 min lock)
- **Webhook server** (port 8787, localhost only) receives push notifications from the orchestrator and any local script
- **Proactive alerts** for agent failures, task completions, and disk space warnings
- **Stealth mode** — silently ignores unauthorized Telegram users

### Orchestrator Changes

- Default bind: `0.0.0.0` → `127.0.0.1`
- Default resources dir: `~/Desktop/Claude` → `~/Claude`
- `FAILURE_WEBHOOK_URL` now defaults to `http://127.0.0.1:8787/webhook` (Telegram bot)
- Added `_notify_task_completion()` — pushes task complete/fail to Telegram webhook
- Version: `3.3.0`

### Infrastructure Setup Prompt

- Phase 3: Telegram chat ID placeholder added
- **New Phase 4.5:** Telegram Command Bot setup between Phase 4 (Automation) and Phase 5 (Recovery)
- Master `.env` template updated with all Telegram bot variables
- Recovery docs updated with Telegram bot in service startup order
- "What You'll Have" checklist includes Telegram bot

---

## Files Changed from V3.2.0

```
Added:
  telegram-bot/                         — NEW: Telegram command bot
  telegram-bot/bot.py                   — Bot code + webhook server
  telegram-bot/requirements.txt         — python-telegram-bot + dotenv
  telegram-bot/.env.example             — Configuration template
  telegram-bot/generate-password-hash.py — Password setup helper
  telegram-bot/install.sh               — One-command installer
  telegram-bot/telegram-bot.service     — systemd unit file
  telegram-bot/disk-check-webhook.sh    — Webhook-based disk alert script
  telegram-bot/WEBHOOK_SETUP.md         — Wiring guide for notifications
  RELEASE_NOTES_V3.3.md                 — This file

Modified:
  VERSION                               — 3.3.0
  START_HERE.md                         — Added telegram-bot to structure + status
  orchestrator/orchestrator.py          — bind 127.0.0.1, ~/Claude, task notifications, v3.3.0
  orchestrator/.env.example             — bind, resources dir, webhook URL defaults
  multi-agent-system/docs/DEPLOYMENT_GUIDE.md  — Telegram as remote access, security notes
  multi-agent-system/BUILD_STATUS.md    — v3.3.0
  mcp-servers/memory-server/package.json — v3.3.0
  claude-code-framework/advanced/infrastructure/MINI_PC_SETUP_PROMPT.md — Phase 4.5, .env vars, chat ID
  claude-code-framework/advanced/infrastructure/phases/phase-3-monitoring.md — chat ID filled in
  claude-code-framework/advanced/infrastructure/phases/phase-4-automation.md — references Phase 4.5
```

---

## Upgrade Guide

**From v3.2.0 → v3.3.0:**

1. Extract `Claude-V3.3.zip`
2. Copy your existing `orchestrator/.env` values to the new `.env.example` format
3. Update `ORCHESTRATOR_HOST=127.0.0.1` in your `.env`
4. Update `CLAUDE_RESOURCES_DIR=$HOME/Claude` in your `.env`
5. Set up the Telegram bot (Phase 4.5 in the setup prompt)
6. Set `FAILURE_WEBHOOK_URL=http://127.0.0.1:8787/webhook` in orchestrator `.env`

**Breaking changes:** 
- Orchestrator now binds to `127.0.0.1` by default instead of `0.0.0.0`. If you need LAN access without Tailscale, set `ORCHESTRATOR_HOST=0.0.0.0` explicitly.

---

## Architecture After V3.3

```
Your Phone (Telegram)
       │
       ▼
Telegram Bot (systemd, port 8787 webhook)
       │
       ├── /health, /task, /spend → Orchestrator API (port 8000)
       ├── /system, /docker, /sh  → Direct shell commands
       └── /backup, /restart      → Infrastructure management
       
Orchestrator ──POST /webhook──► Telegram Bot ──► Your Phone
Disk check   ──POST /webhook/alert──► Telegram Bot ──► Your Phone
Any script   ──POST /webhook/alert──► Telegram Bot ──► Your Phone
```
