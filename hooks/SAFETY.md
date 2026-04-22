# Hook Safety Reference

Hooks in this repo execute shell commands with your user permissions on every Claude Code session event. That is a lot of trust. This page lists what each hook does, what it reads, what it writes, and whether it ever makes a network call. Read it before you install.

> If any of these hooks do something different on your machine than what is listed here, that is a bug. Open an issue.

## At a glance

| Hook | Fires on | Reads | Writes | Network | Blocks Claude? |
|---|---|---|---|---|---|
| `session-recall.py` | SessionStart | `~/.claude/projects/*.jsonl` | Nothing (stdout only) | None | No |
| `block-dangerous-commands.sh` | PreToolUse (Bash) | The command Claude is about to run | Appends to `~/.claude/audit/YYYY-MM-DD.jsonl` | None | Yes, on destructive patterns |
| `protect-files.sh` | PreToolUse (Edit, Write) | The target file path | Nothing | None | Warns only, does not block |
| `pii-scan-precommit.sh` | PreToolUse (Bash, git commit only) | Your staged diff | Nothing | None | Yes, on secret or PII match |
| `audit-logger.sh` | PostToolUse (any tool) | Tool name + decision | Appends to `~/.claude/audit/YYYY-MM-DD.jsonl` | None | No |

Every hook follows the same rule: **fail open on its own errors** (exit 0, let Claude keep going) but **fail closed on the thing it is watching for** (emit `block` when it finds a forbidden pattern).

## Hook by hook

### session-recall.py

| | |
|---|---|
| Trigger | `SessionStart` (new session, resume, `/clear`, `/compact`) |
| Source file | `hooks/session-recall.py` |
| Installed to | `~/.claude/hooks/session-recall.py` |
| Runtime | Python 3.9+, stdlib only |
| Reads | `~/.claude/projects/<slug>/*.jsonl` (your Claude Code session history) |
| Writes | Nothing. Prints JSON to stdout. |
| Network | None. |
| Blast radius | Low. Worst case it crashes and Claude starts with no recall context. |
| Controls | `CLAUDE_RECALL_HOURS`, `CLAUDE_RECALL_MAX_SESSIONS`, `CLAUDE_RECALL_MAX_CHARS`, `TZ`, `CLAUDE_SESSION_RECALL_DIR` |

What it actually injects: a short bullet list of your last sessions with the last user message and last assistant action. That content gets sent to Anthropic as part of Claude's context on the next turn. If your prior sessions contain secrets, this hook will replay them. Do not paste secrets into Claude chats.

### block-dangerous-commands.sh

| | |
|---|---|
| Trigger | `PreToolUse` for `Bash` |
| Source file | `hooks/block-dangerous-commands.sh` |
| Reads | The exact bash command Claude is about to run |
| Writes | Appends decisions to `~/.claude/audit/YYYY-MM-DD.jsonl` |
| Network | None. |
| Blast radius | Medium. A bad regex here could block a legitimate command. The hook is pure grep, no execution of the target command. |

Blocks (exits the tool call with `"permissionDecision": "deny"`):

- `rm -rf /`
- `git reset --hard`
- `DROP TABLE`, `DROP DATABASE`
- `format C:`, `diskpart`, `del /s`
- Direct `git push origin main` or `git push main`

Warns but allows (user confirms in the UI):

- `git push --force`, `git push -f`

Customize in `hooks/block-dangerous-commands.sh`. The patterns are plain grep regexes.

### protect-files.sh

| | |
|---|---|
| Trigger | `PreToolUse` for `Edit`, `Write` |
| Source file | `hooks/protect-files.sh` |
| Reads | `$CLAUDE_FILE_PATH` environment variable |
| Writes | Nothing |
| Network | None. |
| Blast radius | Very low. Warns only. |

Warns when the target path matches `*.env`, `*.env.production`, `*.env.local`, `*.env.staging`, `*credentials*`, `*secret*`. It does **not** stop the edit. It prints a reminder so you can pause. If you want it to actually block, change `emit_warn` to `emit_block` in the file.

### pii-scan-precommit.sh

| | |
|---|---|
| Trigger | `PreToolUse` for `Bash` where the command contains `git commit` |
| Source file | `hooks/pii-scan-precommit.sh` |
| Reads | Your staged diff (`git diff --staged`) |
| Writes | Nothing |
| Network | None. |
| Blast radius | Medium. A false positive here blocks the commit. You can always bypass with a direct `git commit` from outside the Claude session, but the whole point is to catch what you did not notice. |

The shipped patterns are **placeholders**. They do not know what counts as sensitive for you. Before you rely on this hook:

1. Open `hooks/pii-scan-precommit.sh`.
2. Replace the `BANNED_PATTERNS` block with patterns that match your own names, emails, phone numbers, client names, internal IPs, and API key prefixes.
3. Test it with a deliberate fake secret in a staged file.

If you skip this step, the hook is mostly symbolic.

### audit-logger.sh

| | |
|---|---|
| Trigger | `PostToolUse` for any tool you wire it up to |
| Source file | `hooks/audit-logger.sh` |
| Reads | Tool name and permission decision from environment variables |
| Writes | Appends one JSON line per tool call to `~/.claude/audit/YYYY-MM-DD.jsonl` |
| Network | None. |
| Blast radius | Low. Worst case the audit file fails to write (disk full) and you lose a trail entry. |

Retention is **forever** unless you rotate the directory yourself. Typical entry size is 200-500 bytes. Add a cron if you care:

```bash
# Keep the last 60 days of audit logs
find ~/.claude/audit -name '*.jsonl' -mtime +60 -delete
```

## What the installer does

`hooks/install-hooks.sh` runs when you execute the one-line installer or when you run it yourself. It:

1. Creates `~/.claude/hooks/` if missing.
2. Copies every `*.sh` and `*.py` hook plus the `lib/` folder into that directory.
3. Makes them executable.
4. If `~/.claude/settings.json` does not exist, writes a default one with all hooks wired up.
5. If `~/.claude/settings.json` already exists, **does not touch it**. You must add hook entries yourself. See `hooks/README.md` for the JSON snippets.

## Uninstall

```bash
# Remove the hook scripts
rm -rf ~/.claude/hooks/

# Remove the hook entries from settings.json by hand, or replace the file:
mv ~/.claude/settings.json ~/.claude/settings.json.backup
```

After that Claude Code runs with no hooks.

## Writing your own hook

If you add a hook, write it so a skeptical reader can trust it in 30 seconds:

- One job per hook.
- Stdlib and shell utilities only. No curl, no pip installs.
- Fail open on its own bugs. `exit 0` on error.
- Fail closed on the pattern it watches. `emit_block` when matched.
- Add a row to the table at the top of this file.
- No secrets in source.
- No network calls without a loud comment explaining why.
