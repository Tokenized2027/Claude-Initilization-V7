# Telegram Bot — Claude Instructions

> Claude reads this file automatically at the start of every session.

## What this project is

`[One sentence: what does this bot do.]`

Example: "A bot that lets me forward a link to it and saves the article as plain text for later reading."

## Stack

- Python 3.11+
- `python-telegram-bot` v21+
- Runs on `[a VPS / a Raspberry Pi / a mini PC / Docker]`
- `[Storage: JSON file / SQLite / Postgres]`

## File layout

```
bot.py              entry point, registers handlers
handlers/
  start.py          /start + /help
  message.py        free text messages
  commands.py       other slash commands
config.py           env var loading (BOT_TOKEN, allowed chat ids)
storage.py          read/write user data
tests/
```

## Rules for Claude

### Always

- Access the bot token from `BOT_TOKEN` env var. Never hardcode.
- Maintain an **allowlist** of chat IDs. Reject messages from any chat not on it.
- Use `async` handlers. Telegram is I/O bound.
- Reply quickly: if a handler does slow work, send "working..." first, then edit the message when done.
- Handle exceptions inside each handler. A crash in one handler must not take the bot down.
- Log every received update at INFO with chat id but never with personal content.

### Never

- Print the bot token, chat ids of real users, or full message contents to logs or stdout.
- Accept commands from anyone not on the allowlist, even if they send `/start`.
- Store message contents on disk unless the feature requires it. If it does, document the retention period.
- Commit `.env` or any file that contains the token.

## Deployment

- Runs as a systemd service or a Docker container, not `python bot.py &` in a terminal.
- Auto restarts on crash.
- Logs to journald or the container log driver, not a growing file on disk.

## Environment variables

`.env.example`:

```
BOT_TOKEN=123456:replace-me
ALLOWED_CHAT_IDS=11111111,22222222
```

## Checklist before shipping

- [ ] Token never appears in logs or in source.
- [ ] Only allowlisted chat ids can trigger commands.
- [ ] Bot survives a kill signal and restarts cleanly.
- [ ] `/help` lists every command.
- [ ] Unknown command gets a friendly "not a command I know" reply.
