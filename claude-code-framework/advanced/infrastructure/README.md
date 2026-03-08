# Infrastructure — Mini PC Dev Server Setup

## How to Use

1. **Open `SETUP_START.md`** — copy the master prompt inside it
2. **Paste it into Claude Code** on your new mini PC
3. **Say "go"** after each phase completes
4. That's it — Claude Code reads each phase file from disk automatically

## File Structure

```
infrastructure/
├── SETUP_START.md              # ⭐ The ONE prompt you paste — orchestrates everything
├── MINI_PC_SETUP_PROMPT.md     # Full combined reference (for reading ahead)
├── README.md                   # You're reading this
└── phases/                     # Individual phase files (read by Claude Code from disk)
    ├── phase-0-preflight.md    # System assessment
    ├── phase-1-foundation.md   # SSH, firewall, Tailscale, Docker, core services
    ├── phase-2-devenv.md       # Node.js, Claude Code CLI, project structure
    ├── phase-3-monitoring.md   # Dozzle, Uptime Kuma, cAdvisor
    ├── phase-4-automation.md   # Git workflow, cron jobs, resource limits
    └── phase-5-recovery.md     # Documentation and recovery procedures
```

## Why Split Into Phases?

The original single prompt was 700+ lines. Claude Code's context window would start forgetting Phase 1 decisions by Phase 4. Splitting into separate files that Claude Code reads from disk means:

- Each phase gets full context window attention
- You can restart from any phase if something fails
- You can customize individual phases without touching the rest
- Claude Code confirms each phase before moving on

## Customization

Before running, edit **Phase 0** (`phases/phase-0-preflight.md`) to fill in:
- Your name, timezone, and technical background
- Your current project description
- Any specific requirements

Everything else adapts based on what Phase 0 discovers about your hardware and OS.
