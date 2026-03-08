# Team Config Templates

Pre-built team configurations for Claude Code agent teams. Copy-paste the config into your lead session to spawn a coordinated team.

## Prerequisites

Enable agent teams in `~/.claude/settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

## Available Configs

| File | Teammates | Use When |
|------|-----------|----------|
| `full-build.md` | 6-8 | New system from scratch |
| `feature-sprint.md` | 3 | Adding a significant feature |
| `code-review.md` | 3 | Multi-lens review of a PR or feature |
| `debug-investigation.md` | 3 | Bug with unclear root cause |

## Usage

1. Start Claude Code in your project: `claude`
2. Open the config file for your scenario
3. Replace `[PLACEHOLDERS]` with your project details
4. Paste the entire config into your Claude Code session
5. Monitor teammates with Shift+Up/Down, task list with Ctrl+T

## Full Guide

See `advanced/guides/TEAM_MODE.md` for walkthroughs, spawn prompts, best practices, and troubleshooting.
