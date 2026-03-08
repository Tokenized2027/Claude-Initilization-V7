# Phase 2: Development Environment

> Read STATUS.md first to confirm Phase 1 is complete and all services are running.

## 2.1 Node.js & Development Tools

- Install Node.js LTS via nvm (not apt)
- Install global tools: pnpm, typescript, ts-node
- Set up Python 3.11+ with python3-venv
- Install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- Add shell aliases to ~/.bashrc:
  ```bash
  # Docker shortcuts
  alias dps='docker compose ps'
  alias dlogs='docker compose logs -f'
  alias dre='docker compose restart'
  alias ddown='docker compose down'
  alias dup='docker compose up -d'

  # Git shortcuts
  alias gst='git status'
  alias glog='git log --oneline -20'
  alias gd='git diff'

  # Quick navigation
  alias proj='cd ~/projects'
  alias infra='cd ~/projects/infrastructure'
  # Add your own project aliases here:
  # alias myapp='cd ~/projects/my-app'
  ```
- Source the updated bashrc: `source ~/.bashrc`
- Verification: `node -v`, `pnpm -v`, `python3 --version`, `claude --version` all work. Type `dps` and confirm it runs docker compose ps.

## 2.2 Project Structure

Create this directory layout and initialize git repos:

```
~/projects/
├── my-app/                   # Your main project (customize name)
│   ├── src/
│   ├── CLAUDE.md
│   ├── STATUS.md
│   ├── docs/
│   │   ├── PRD.md
│   │   └── TECH_SPEC.md
│   └── .env
├── infrastructure/           # Core services (from Phase 1)
│   ├── docker-compose.yml
│   ├── backups/
│   ├── .env
│   └── STATUS.md
└── experiments/              # Quick prototypes and tests
```

Each project should have CLAUDE.md and STATUS.md from the framework templates.

## 2.3 LLM API — Connectivity Test (Optional)

> Skip this section if your project doesn't need an external LLM API.

Create a minimal test script at ~/projects/my-app/llm-test.ts (or .py) that:
1. Reads LLM_API_KEY and LLM_BASE_URL from environment
2. Makes a single API call with a simple test prompt
3. Logs: model used, response text, token counts
4. Exits with success/failure code

Run the test script and confirm it works.

---

Update STATUS.md with dev environment status.

Git commit: `git add -A && git commit -m "phase 2: dev environment and tooling"`

**STOP HERE.** Wait for confirmation before proceeding to Phase 3.
