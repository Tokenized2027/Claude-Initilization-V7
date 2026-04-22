# Examples Gallery

Filled-in `CLAUDE.md` files for common beginner projects. Copy any folder into your own project, rename files as needed, and edit a few lines at the top.

| Folder | For when you are building | Stack |
|---|---|---|
| [`todo-app/`](todo-app/) | A small full-stack app with auth and a DB | Next.js + Postgres |
| [`landing-page/`](landing-page/) | A one-page marketing site | Plain HTML + Tailwind |
| [`nextjs-app/`](nextjs-app/) | A production Next.js app with TypeScript | Next.js 15 + TS + Tailwind |
| [`python-script/`](python-script/) | A single-file Python script that does a job | Python 3 + stdlib |
| [`fastapi-service/`](fastapi-service/) | A small HTTP API service | FastAPI + uv + Docker |
| [`telegram-bot/`](telegram-bot/) | A Telegram bot that replies to messages | Python + python-telegram-bot |

## How to use one

1. Copy the folder contents into your own project.

   ```bash
   cp examples/landing-page/CLAUDE.md ~/projects/my-site/CLAUDE.md
   cd ~/projects/my-site
   ```

2. Open `CLAUDE.md` and edit the **What this project is** and **Tech stack** sections. That is usually all you need.

3. Start Claude Code in that directory:

   ```bash
   claude
   ```

Claude reads `CLAUDE.md` automatically, so the rules you defined apply from the first message.

## Want to contribute your own

See [`CONTRIBUTING.md`](../CONTRIBUTING.md). The short version: strip anything personal, drop your `CLAUDE.md` into a new subfolder, add a two-line `README.md`, open a PR. Examples are the easiest and most useful contribution you can make.
