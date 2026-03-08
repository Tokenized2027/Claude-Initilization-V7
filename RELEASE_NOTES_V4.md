# Claude V4.0.0 — Whisper Service + Cursor Workflow

**Release Date:** February 17, 2026
**Upgrade from v3.3.0:** Drop-in replacement. New `whisper-service/` directory added.

---

## What's New

### Whisper Shared Service (`whisper-service/`)

Speech-to-text is now a Docker container instead of running inside the Telegram bot process.

- **Flask API on port 9000** — `POST /transcribe` accepts any audio file, returns text + segments + timing
- **Supports**: English, Hebrew (`he`), auto-detect, translation to English
- **Pre-downloads model at build time** — container starts in seconds
- **Resource-limited**: 2GB RAM, 4 CPUs max — won't starve other services
- **Any app can use it**: Telegram bot, orchestrator agents, cron scripts, future web UIs

The Telegram bot was updated to call `http://127.0.0.1:9000/transcribe` instead of loading Whisper in-process, saving ~700MB RAM.

### Client-Side Setup (Cursor + Claude Code)

The infrastructure setup prompt now includes a complete guide for the client-side setup:

- **Cursor IDE** ($20/month) — VS Code fork with AI. Connect via Remote SSH, browse files on the mini PC, make inline AI-assisted edits with `Ctrl+K`
- **Claude Code CLI** — runs in Cursor's built-in terminal for big builds
- **Three interfaces documented**: Telegram (mobile), Claude Code (heavy lifting), Cursor (visual)

### Architecture After V4

```
Your Phone                Your Laptop
    │                         │
    │ Telegram                │ SSH (Cursor + Claude Code CLI)
    │                         │
    └──────────┬──────────────┘
               │
        Mini PC (Ubuntu, always-on)
               │
    ┌──────────┴──────────────────┐
    │  Orchestrator (port 8000)   │
    │  Telegram Bot (port 8787)   │
    │  Whisper Service (port 9000)│
    │  Docker containers          │
    │  PostgreSQL, Redis, Gitea   │
    └─────────────────────────────┘
```

---

## Files Changed from V3.3.0

```
Added:
  whisper-service/              — NEW: Shared speech-to-text Docker service
  whisper-service/app.py        — Flask API server
  whisper-service/Dockerfile    — Container with pre-downloaded Whisper model
  whisper-service/docker-compose.yml
  whisper-service/requirements.txt
  whisper-service/README.md
  RELEASE_NOTES_V4.md         — This file

Modified:
  VERSION                       — 4.0.0
  CHANGELOG.md                  — V4 entry
  START_HERE.md                 — Added whisper-service to structure, version bump
  telegram-bot/bot.py           — Uses Whisper API service instead of in-process model
  telegram-bot/requirements.txt — Removed openai-whisper dependency
  telegram-bot/.env.example     — WHISPER_API_URL replaces WHISPER_MODEL
  MINI_PC_SETUP_PROMPT.md       — Phase 4.5 Whisper deploy step, Client-Side Setup section
```
