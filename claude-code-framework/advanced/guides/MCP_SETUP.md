# MCP (Model Context Protocol) Setup

MCP servers extend Claude Code's capabilities by connecting it to external tools and services. The most important for vibe coders is Playwright MCP, which enables browser automation for testing web apps.

---

## Table of Contents

1. [What is MCP?](#what-is-mcp)
2. [Configuration Format](#configuration-format)
3. [Installing Playwright MCP](#installing-playwright-mcp)
4. [Other Useful MCP Servers](#other-useful-mcp-servers)
5. [Using Playwright MCP](#using-playwright-mcp)
6. [Troubleshooting](#troubleshooting)

---

## What is MCP?

**MCP (Model Context Protocol)** is a standardized way for Claude Code to interact with external tools and services.

- **Without MCP:** Claude can write code, but can't test if a web page actually works
- **With MCP:** Claude can open a browser, click buttons, fill forms, and verify the page works correctly

MCP servers run alongside Claude Code and provide tools Claude can call.

---

## Configuration Format

MCP servers are configured in `.mcp.json` files:

- **Project scope:** `.mcp.json` in your project root (shared with team via git)
- **User scope:** `~/.claude.json` (your personal global config)

### .mcp.json Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["@package-org/server-name"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Using the CLI to Add Servers

The fastest way to add MCP servers:

```bash
# Add Playwright (browser automation)
claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright

# Add Postgres (database access)
claude mcp add postgres -- npx @modelcontextprotocol/server-postgres

# Add GitHub (repo management)
claude mcp add github -- npx @modelcontextprotocol/server-github

# Add with environment variables
claude mcp add postgres -e DATABASE_URL=postgresql://user:pass@localhost:5432/db -- npx @modelcontextprotocol/server-postgres

# Add to user scope (global, all projects)
claude mcp add -s user playwright -- npx @anthropic-ai/mcp-server-playwright

# List configured servers
claude mcp list

# Remove a server
claude mcp remove playwright
```

### Scopes

| Scope | File | Shared | Use When |
|-------|------|--------|----------|
| Project | `.mcp.json` | Yes (commit to git) | Team-shared servers |
| User | `~/.claude.json` | No | Personal/global servers |
| Local | `.claude/.mcp.local.json` | No (gitignored) | Project-specific personal config |

---

## Installing Playwright MCP

**Playwright MCP is non-negotiable for any project with a web UI.** Without it, you're flying blind on UI bugs.

### Step 1: Add via CLI

```bash
claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright
```

This creates/updates `.mcp.json` in your project root:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

### Step 2: Verify

```bash
claude mcp list
# Should show: playwright - npx @anthropic-ai/mcp-server-playwright
```

### Step 3: Test

In a Claude Code session:
```
Use Playwright to navigate to google.com and take a screenshot
```

If that works, you're ready.

---

## Other Useful MCP Servers

### Postgres MCP
**What:** Query and manage PostgreSQL databases directly from Claude Code.

```bash
claude mcp add postgres -e DATABASE_URL=postgresql://user:pass@localhost:5432/mydb -- npx @modelcontextprotocol/server-postgres
```

**Use cases:** "Show me the last 10 users", "Create a backup of the users table"

### GitHub MCP
**What:** Read/write GitHub repos, create issues, review PRs.

```bash
claude mcp add github -e GITHUB_TOKEN=${GITHUB_TOKEN} -- npx @modelcontextprotocol/server-github
```

**Use cases:** "Create a GitHub issue for this bug", "List open PRs"

### Fetch MCP
**What:** Make HTTP requests to external APIs.

```bash
claude mcp add fetch -- npx @modelcontextprotocol/server-fetch
```

**Use cases:** "Test this API endpoint", "Fetch data from the Stripe API"

### Filesystem MCP
**What:** Enhanced file operations (built into Claude Code by default, rarely needed separately).

### Full Stack Example

For a typical Next.js + Postgres project, your `.mcp.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-server-playwright"]
    },
    "postgres": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb"
      }
    }
  }
}
```

---

## Using Playwright MCP

### Basic Usage

When building UI features, ask Claude to test them:

```
User: "Build a login form with email and password fields"
Claude: [builds the form]
User: "Now test it with Playwright — open the page, fill in the form, verify submit works"
Claude: [opens browser, tests form, reports results]
```

### What Claude Can Do with Playwright

| Category | Actions |
|----------|---------|
| **Navigation** | Open URLs, click links/buttons, navigate back/forward |
| **Forms** | Fill inputs, select dropdowns, check boxes, submit |
| **Verification** | Check elements exist, verify text, confirm visibility |
| **Debugging** | Take screenshots, inspect HTML, check console errors |

### Example Commands

**Test a login form:**
```
Use Playwright to navigate to http://localhost:3000/login, fill email with
'test@example.com', fill password with 'password123', click login button,
verify we're redirected to /dashboard, take a screenshot.
```

**Test responsive design:**
```
Use Playwright to test the homepage at mobile (375px), tablet (768px), and
desktop (1920px) widths. Take screenshots at each size.
```

---

## Troubleshooting

### "Playwright not found"

```bash
# The CLI auto-installs via npx, but if issues:
npm install -g @anthropic-ai/mcp-server-playwright
npx playwright install  # Downloads browser binaries
```

### "Browser not found"

```bash
npx playwright install chromium
```

### Claude doesn't use Playwright

- Be explicit: "Use Playwright to test..."
- Make sure your app is running: `npm run dev`
- Check MCP is configured: `claude mcp list`

### .mcp.json format error

```bash
# Validate JSON
python3 -m json.tool .mcp.json
```

Common mistakes: trailing commas, missing quotes, unmatched braces.

---

## Quick Start Checklist

- [ ] Run: `claude mcp add playwright -- npx @anthropic-ai/mcp-server-playwright`
- [ ] Verify: `claude mcp list`
- [ ] Test: Ask Claude to "Use Playwright to navigate to google.com and take a screenshot"
- [ ] (Optional) Add Postgres: `claude mcp add postgres -e DATABASE_URL=... -- npx @modelcontextprotocol/server-postgres`
- [ ] Commit `.mcp.json` to git (so teammates get the same config)
