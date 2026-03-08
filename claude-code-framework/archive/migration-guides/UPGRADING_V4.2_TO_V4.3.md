# Upgrading from v4.2 to v4.3

> **Migration guide for existing v4.2 users**
>
> **Last Updated:** February 12, 2026

---

## Overview

v4.3 is a **critical update** that fixes broken hooks, settings, and MCP configurations. The old formats never actually worked — v4.3 replaces them with real, functional Claude Code APIs.

**TL;DR:**
- ⚠️ **Breaking change:** Hooks format completely rewritten (old format was non-functional)
- ⚠️ **Breaking change:** `settings.json` permissions syntax changed
- ⚠️ **Breaking change:** MCP configuration moved from `settings.json` to `.mcp.json`
- ✅ **Backward compatible:** All v4.2 features (Team Mode, Solo Mode, Full Pipeline) unchanged
- ✅ **New:** Native subagents, native skills, stack-specific templates, integration guides

---

## Do You Need to Upgrade?

### Upgrade Immediately If:
- ✅ You're using hooks (they don't work in v4.2)
- ✅ You're using MCP servers (config was non-functional)
- ✅ You're using custom `settings.json` permissions

### Can Wait If:
- You're only using Claude Projects (web interface)
- You're not using hooks or MCP
- You're happy with current workflow and nothing is broken

### Don't Upgrade If:
- You've heavily customized v4.2 templates and don't want to redo work
- You're mid-project and risk aversion is high

---

## Breaking Changes

### 1. Hooks System (CRITICAL)

**What changed:**
- Old fake event names (`pre-commit`, `post-save`) → Real API events (`PreToolUse`, `PostToolUse`)
- Plain bash scripts → JSON stdin/stdout protocol
- No exit code handling → Exit codes (0=allow, 2=block)

**Old format (v4.2) — BROKEN:**
```json
{
  "hooks": {
    "pre-commit": "./protect-branches.sh"
  }
}
```

**New format (v4.3) — WORKING:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "match": "Bash",
        "command": ".claude/hooks/protect-branches.sh"
      }
    ]
  }
}
```

**Migration steps:**
1. Copy new hook scripts from `toolkit/templates/hooks/`
2. Update `.claude/settings.json` with new format
3. Test: Try committing to `main` branch (should block)

---

### 2. settings.json Permissions

**What changed:**
- Plain strings → `Tool(specifier)` syntax
- No structure → `allow`/`deny` lists

**Old format (v4.2) — BROKEN:**
```json
{
  "allowedCommands": ["git status", "npm install"]
}
```

**New format (v4.3) — WORKING:**
```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git add *)",
      "Bash(npm install)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(.env)"
    ]
  }
}
```

**Migration steps:**
1. Read `.claude/settings.json`
2. Replace with new template from `toolkit/templates/settings.json`
3. Add your custom permissions using `Tool(specifier)` syntax

---

### 3. MCP Configuration

**What changed:**
- Fake `"mcps"` key in settings.json → Real `.mcp.json` file
- Invented format → Official `mcpServers` format

**Old format (v4.2) — BROKEN:**
```json
// settings.json
{
  "mcps": {
    "playwright": {
      "enabled": true
    }
  }
}
```

**New format (v4.3) — WORKING:**
```json
// .mcp.json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

**Migration steps:**
1. Remove `"mcps"` section from `.claude/settings.json`
2. Run: `claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright`
3. Verify: `claude mcp list`

---

## New Features (Optional)

### 1. Native Subagents

**What:** All 10 agents now available as `.claude/agents/*.md` files

**Benefits:**
- Claude Code spawns them natively (no Claude Projects needed)
- Just: `claude spawn agent:frontend-developer`

**Setup:**
```bash
cp -r toolkit/templates/claude-agents/* .claude/agents/
```

**Usage:**
```bash
# From your project directory
claude
> spawn agent:frontend-developer
```

---

### 2. Native Skills

**What:** All 15 skills as `.claude/skills/*/SKILL.md` with YAML frontmatter

**Benefits:**
- Invoke with `/skill-name` in Claude Code
- No manual upload to Claude.ai

**Setup:**
```bash
cp -r toolkit/templates/claude-skills/* .claude/skills/
```

**Usage:**
```bash
claude
> /docker-debugger
```

---

### 3. Stack-Specific Templates

**New templates:**
- `CLAUDE-SOLO-PYTHON.md` — Flask, SQLAlchemy, pytest
- `CLAUDE-SOLO-VUE.md` — Nuxt 3, Pinia, Composition API

**Usage:**
```bash
# Python project
cp toolkit/templates/CLAUDE-SOLO-PYTHON.md ~/my-flask-app/CLAUDE.md

# Vue project
cp toolkit/templates/CLAUDE-SOLO-VUE.md ~/my-nuxt-app/CLAUDE.md
```

---

### 4. Integration Guides

**New file:** `guides/INTEGRATIONS.md`

**Quick-start guides for:**
- Supabase (managed Postgres + Auth)
- Vercel (frontend hosting)
- Railway (backend hosting)

---

## Migration Checklist

### Step 1: Backup Current Setup
```bash
cp .claude/settings.json .claude/settings.json.v4.2.backup
cp -r .claude/hooks .claude/hooks.v4.2.backup
```

### Step 2: Update Hooks
```bash
# Copy new hook scripts
cp toolkit/templates/hooks/*.sh .claude/hooks/

# Make executable
chmod +x .claude/hooks/*.sh

# Update settings.json with new hook format
# See "Breaking Changes > Hooks System" above
```

### Step 3: Update settings.json
```bash
# Replace with new template
cp toolkit/templates/settings.json .claude/settings.json

# Or manually update permissions to Tool(specifier) syntax
```

### Step 4: Migrate MCP Config
```bash
# Remove "mcps" from settings.json

# Add servers using CLI
claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright

# Verify
claude mcp list
```

### Step 5: Test
```bash
# Test hooks
git add test.txt
git commit -m "test on main"  # Should block if on main branch

# Test MCP
claude
> Use Playwright to open example.com

# Test permissions
# Try reading .env file (should block if deny rule configured)
```

### Step 6: Optional — Add Native Features
```bash
# Add native agents
cp -r toolkit/templates/claude-agents/* .claude/agents/

# Add native skills
cp -r toolkit/templates/claude-skills/* .claude/skills/
```

---

## Troubleshooting

### "Hooks aren't working"

**Diagnosis:**
```bash
# Check hook format
cat .claude/settings.json | grep -A 10 hooks

# Verify hook scripts exist and are executable
ls -la .claude/hooks/
```

**Fix:**
- Ensure using `PreToolUse`/`PostToolUse` events (not old fake names)
- Verify hook scripts are executable: `chmod +x .claude/hooks/*.sh`
- Check JSON syntax is valid: `cat .claude/settings.json | jq .`

---

### "MCP servers not showing up"

**Diagnosis:**
```bash
claude mcp list
```

**Fix:**
- Ensure `.mcp.json` exists in project root or `~/.claude.json` for global
- Remove old `"mcps"` key from `settings.json`
- Re-add servers: `claude mcp add <name> -- <command>`

---

### "Permissions not working as expected"

**Diagnosis:**
```bash
# Check current settings
cat .claude/settings.json | grep -A 20 permissions
```

**Fix:**
- Use `Tool(specifier)` format: `"Bash(git status)"` not `"git status"`
- Remember `allow` vs `deny` lists — deny takes precedence
- Use matchers like `Bash(git *)` for patterns

---

## Rollback (If Needed)

If v4.3 causes issues and you need to revert:

```bash
# Restore v4.2 backups
cp .claude/settings.json.v4.2.backup .claude/settings.json
cp -r .claude/hooks.v4.2.backup/* .claude/hooks/

# Remove v4.3 features
rm .mcp.json
rm -rf .claude/agents
rm -rf .claude/skills
```

**Note:** v4.2 hooks didn't work, so rollback only makes sense if you weren't using hooks.

---

## FAQ

**Q: Do I have to migrate?**
A: Only if you use hooks, MCP, or custom permissions. Otherwise it's optional.

**Q: Will my v4.2 projects break?**
A: No — unless you were using hooks/MCP (which didn't work anyway).

**Q: Can I keep using Claude Projects (web)?**
A: Yes — the web-based Claude Projects workflow is unchanged.

**Q: What if I don't use hooks at all?**
A: Then the only breaking change for you is MCP config (if you use MCP).

**Q: Should I switch to native agents/skills?**
A: Optional — they're more convenient, but web Claude Projects still work.

**Q: How long does migration take?**
A: 15-30 minutes for a complete migration with testing.

---

## Getting Help

**Migration issues?**
1. Check `TROUBLESHOOTING.md`
2. Review this guide's troubleshooting section
3. Verify against `DEEP_VERIFICATION_REPORT.md`

**Still stuck?**
1. Check `guides/ARCHITECTURE_BLUEPRINT.md` Section 6 (Hooks & MCP)
2. Read `toolkit/templates/HOOKS_SETUP.md` for detailed hook reference
3. Read `guides/MCP_SETUP.md` for MCP configuration details

---

## What's Next After Upgrading?

Once migrated:

1. **Test everything** — Hooks, MCP, permissions
2. **Try native agents** — Faster than web Claude Projects
3. **Explore new integrations** — Read `guides/INTEGRATIONS.md`
4. **Use stack templates** — If building Python/Vue projects

---

## Summary

| Change | Status | Action Required |
|--------|--------|-----------------|
| Hooks format | ⚠️ Breaking | Update `.claude/settings.json` and hook scripts |
| Permissions syntax | ⚠️ Breaking | Change to `Tool(specifier)` format |
| MCP configuration | ⚠️ Breaking | Move to `.mcp.json` file |
| Team Mode | ✅ Unchanged | No action needed |
| Solo Mode | ✅ Unchanged | No action needed |
| Agent prompts | ✅ Unchanged | No action needed |
| Native agents | ✅ New feature | Optional — copy to `.claude/agents/` |
| Native skills | ✅ New feature | Optional — copy to `.claude/skills/` |
| Stack templates | ✅ New feature | Optional — use for Python/Vue |
| Integration guides | ✅ New feature | Reference when needed |

---

**Migration complete?** Welcome to v4.3 — now with working hooks, MCP, and native agents! 🎉
