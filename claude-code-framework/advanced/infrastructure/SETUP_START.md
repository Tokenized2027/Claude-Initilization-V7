# Mini PC Setup — Master Prompt

> **Paste this single prompt into Claude Code on your new mini PC. It orchestrates the entire setup automatically.**

---

## The Prompt

```
You are helping me set up a dedicated Linux mini PC as my always-on development server. This will be done in 6 phases (Phase 0-5), and the instructions for each phase are stored as separate files on this machine.

## How This Works

The phase files are located at:
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-0-preflight.md
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-1-foundation.md
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-2-devenv.md
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-3-monitoring.md
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-4-automation.md
  $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-5-recovery.md

## Your Rules

1. I will handle all sudo commands myself — you propose the exact command, I execute
2. Read ONE phase file at a time. Execute it fully. Wait for my confirmation before reading the next.
3. After each step, tell me how to VERIFY it worked (command to run, URL to visit, expected output)
4. If a step fails, give me a diagnostic command first — don't guess at fixes
5. Use Docker for everything possible to keep the host system clean
6. All secrets go in .env files — never hardcode anything
7. Every config file you produce must be COMPLETE — never say "rest stays the same"
8. If you need to see an existing file before modifying it, ask me to paste it
9. Commit after every completed phase: git add -A && git commit -m "phase X: description"
10. When exposing Docker container ports, ALWAYS bind to 127.0.0.1 — never 0.0.0.0

## Auto-Continuation Protocol

After completing each phase and receiving my confirmation:
1. Update STATUS.md with what was done
2. Git commit
3. Tell me: "Phase X complete. Ready for Phase Y. Say 'go' to continue or tell me if you want to adjust anything."
4. When I say 'go', read the next phase file with: cat $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-Y-name.md
5. Execute that phase
6. Repeat until all 6 phases are done

## Start Now

Read the first phase file:
cat $CLAUDE_HOME/claude-code-framework/advanced/infrastructure/phases/phase-0-preflight.md

Then execute it. STOP after Phase 0 and wait for my confirmation before proceeding.
```

---

## What Happens

1. You paste the prompt above into Claude Code
2. Claude Code reads Phase 0 from disk and runs it
3. You verify and say "go"
4. Claude Code automatically reads Phase 1, executes it, waits for confirmation
5. Repeat through Phase 5
6. Done — you never paste another prompt

The full combined reference is still available in `MINI_PC_SETUP_PROMPT.md` if you want to read ahead or troubleshoot.
