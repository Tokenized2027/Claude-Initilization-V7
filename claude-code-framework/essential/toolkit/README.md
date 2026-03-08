# Toolkit — Project Scaffolding Scripts

Two scripts for setting up projects with the standard AI Dev framework.

## Scripts

### Project Scaffolding

#### `create-project.sh` — New Projects

Scaffolds a new project from scratch with all standard files, hooks, and framework boilerplate.

```bash
# Interactive
./create-project.sh

# Non-interactive
./create-project.sh --name my-app --type nextjs --path ~/projects
```

**Project types:**

| Type | What You Get |
|------|-------------|
| `nextjs` | Next.js 15 + React 19 + TypeScript + Tailwind 4 |
| `python` | Python + Flask + Docker |
| `docker` | Docker Compose multi-service template |
| `minimal` | Just the standard files, no framework setup |

#### `adopt-project.sh` — Existing Projects

Retrofits the framework into an existing project. **Never overwrites existing files** — only adds what's missing.

```bash
cd /path/to/existing/project
bash $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh

# Or specify path
bash $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh --path /path/to/project
```

Auto-detects project type (Next.js, Python, Docker) and adjusts accordingly.

---

### Prompt Caching Tools (NEW)

**Save 70-90% on API costs** by caching agent prompts, project briefs, and large files. See `advanced/guides/PROMPT_CACHING.md` for the full guide.

#### `claude-cached-api.js` — Node.js API Wrapper

Call Claude's API with automatic prompt caching.

```bash
# Install dependencies
npm install @anthropic-ai/sdk

# Usage
node claude-cached-api.js "Create a user profile component"
node claude-cached-api.js "Debug API" --agent backend
node claude-cached-api.js "Review code" --agent tester --no-brief
```

**Options:**
- `--agent <type>` — Use agent prompt: architect, pm, frontend, backend, tester
- `--no-brief` — Skip project brief caching
- `--model <model>` — Claude model (default: claude-opus-4-6)
- `--max <tokens>` — Max output tokens (default: 4096)

#### `claude_cached_api.py` — Python API Wrapper

Python version of the cached API wrapper.

```bash
# Install dependencies
pip install anthropic

# Usage
python claude_cached_api.py "Create a user profile component"
python claude_cached_api.py "Debug API" --agent backend
python claude_cached_api.py "Review code" --agent tester --no-brief
```

#### `claude-cached.sh` — Bash Quick Wrapper

Simple bash script for one-off cached API calls.

```bash
# Make executable
chmod +x claude-cached.sh

# Usage
./claude-cached.sh "Your prompt here"
./claude-cached.sh "Debug API errors" backend
```

**Requirements:** `jq` for JSON parsing

**Cost impact:** A 50-message conversation costs $0.45 without caching, $0.055 with caching (88% reduction).

## Templates

The `templates/` folder contains source templates that the scripts use. You can also use these templates directly:

| Template | Purpose |
|----------|---------|
| `CLAUDE.md` | Rules for Claude Code — paste into project root |
| `STATUS.md` | Project state tracker template |
| `PRD.md` | Product Requirements Document template |
| `TECH_SPEC.md` | Technical Specification template |
| `HOOKS_SETUP.md` | Guide for setting up Claude Code hooks |

## Setup

```bash
# Make scripts executable (one time)
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh
chmod +x $CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh

# Optional: add aliases
echo 'alias newproject="$CLAUDE_HOME/claude-code-framework/essential/toolkit/create-project.sh"' >> ~/.bashrc
echo 'alias adoptproject="$CLAUDE_HOME/claude-code-framework/essential/toolkit/adopt-project.sh"' >> ~/.bashrc
source ~/.bashrc
```
