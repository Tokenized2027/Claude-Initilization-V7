#!/bin/bash
# ============================================================
# AI Dev Toolkit — Adopt Existing Project
# Retrofits the standard framework into an existing project.
# NEVER overwrites existing files — only adds what's missing.
#
# Usage:
#   cd /path/to/your/existing/project
#   bash ~/ai-dev-toolkit/adopt-project.sh
#
# Or specify the path:
#   bash ~/ai-dev-toolkit/adopt-project.sh --path /path/to/project
# ============================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)

# Parse arguments
PROJECT_DIR=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --path) PROJECT_DIR="$2"; shift 2 ;;
    *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
  esac
done

# Default to current directory
if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR="$(pwd)"
fi

# Verify it's an actual project (has at least some files)
if [ ! "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]; then
  echo -e "${RED}Error: '${PROJECT_DIR}' is empty. Use create-project.sh for new projects.${NC}"
  exit 1
fi

# Get project name from folder
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🔧  AI Dev Toolkit — Adopt Project      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Project:${NC}  ${PROJECT_NAME}"
echo -e "${BOLD}Location:${NC} ${PROJECT_DIR}"
echo ""

# ============================================================
# Helper: create file only if it doesn't exist
# ============================================================
safe_create() {
  local filepath="$1"
  local description="$2"

  if [ -f "$filepath" ]; then
    echo -e "  ⏭️  ${description} — ${YELLOW}already exists, skipping${NC}"
    return 1
  else
    echo -e "  ✅ ${description} — ${GREEN}created${NC}"
    return 0
  fi
}

safe_mkdir() {
  local dirpath="$1"
  local description="$2"

  if [ -d "$dirpath" ]; then
    echo -e "  ⏭️  ${description} — ${YELLOW}already exists${NC}"
  else
    mkdir -p "$dirpath"
    echo -e "  ✅ ${description} — ${GREEN}created${NC}"
  fi
}

# Track what we added
ADDED=()
SKIPPED=()

# ============================================================
# Auto-detect project type
# ============================================================
echo -e "${BLUE}🔍 Detecting project type...${NC}"

DETECTED_TYPE="unknown"
if [ -f "$PROJECT_DIR/package.json" ] && grep -q "next" "$PROJECT_DIR/package.json" 2>/dev/null; then
  DETECTED_TYPE="nextjs"
  echo -e "  Detected: ${BOLD}Next.js${NC}"
elif [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
  DETECTED_TYPE="python"
  echo -e "  Detected: ${BOLD}Python${NC}"
elif [ -f "$PROJECT_DIR/docker-compose.yml" ] || [ -f "$PROJECT_DIR/docker-compose.yaml" ]; then
  DETECTED_TYPE="docker"
  echo -e "  Detected: ${BOLD}Docker${NC}"
else
  echo -e "  Detected: ${BOLD}Unknown / Generic${NC}"
fi

echo ""

# ============================================================
# Scan what already exists
# ============================================================
echo -e "${BLUE}📋 Scanning existing project...${NC}"

HAS_GIT=false
HAS_CLAUDE_MD=false
HAS_STATUS_MD=false
HAS_PRD=false
HAS_TECH_SPEC=false
HAS_HOOKS=false
HAS_GITIGNORE=false
HAS_ENV_EXAMPLE=false

[ -d "$PROJECT_DIR/.git" ] && HAS_GIT=true && echo -e "  ✅ Git repo found"
[ -f "$PROJECT_DIR/CLAUDE.md" ] && HAS_CLAUDE_MD=true && echo -e "  ✅ CLAUDE.md found"
[ -f "$PROJECT_DIR/STATUS.md" ] && HAS_STATUS_MD=true && echo -e "  ✅ STATUS.md found"
[ -f "$PROJECT_DIR/docs/PRD.md" ] && HAS_PRD=true && echo -e "  ✅ docs/PRD.md found"
[ -f "$PROJECT_DIR/docs/TECH_SPEC.md" ] && HAS_TECH_SPEC=true && echo -e "  ✅ docs/TECH_SPEC.md found"
[ -d "$PROJECT_DIR/.claude/hooks" ] && HAS_HOOKS=true && echo -e "  ✅ .claude/hooks/ found"
[ -f "$PROJECT_DIR/.gitignore" ] && HAS_GITIGNORE=true && echo -e "  ✅ .gitignore found"
[ -f "$PROJECT_DIR/.env.example" ] && HAS_ENV_EXAMPLE=true && echo -e "  ✅ .env.example found"

echo ""

# ============================================================
# Create missing directories
# ============================================================
echo -e "${YELLOW}📁 Checking directories...${NC}"

safe_mkdir "$PROJECT_DIR/.claude/hooks" ".claude/hooks/"
safe_mkdir "$PROJECT_DIR/docs" "docs/"
safe_mkdir "$PROJECT_DIR/logs" "logs/"
safe_mkdir "$PROJECT_DIR/tmp" "tmp/"

echo ""

# ============================================================
# Create missing standard files
# ============================================================
echo -e "${YELLOW}📄 Adding missing standard files...${NC}"

# --- CLAUDE.md ---
if safe_create "$PROJECT_DIR/CLAUDE.md" "CLAUDE.md"; then
  cat > "$PROJECT_DIR/CLAUDE.md" << CLAUDEEOF
# CLAUDE.md — Project Rules

## Project Info

- **Repo:** TODO: add repo URL
- **Stack:** ${DETECTED_TYPE}
- **Key docs:** See linked files below

## Linked Project Files

- PRD: \`./docs/PRD.md\`
- Tech Spec: \`./docs/TECH_SPEC.md\`
- Status: \`./STATUS.md\`

---

## Code Quality Rules

1. **Keep code clean.** No dead code, no commented-out blocks, no orphaned imports.
2. **When making changes:** If any code becomes "orphaned" (no longer called by anything), delete it immediately.
3. **DRY principle:** If a code snippet is used more than once, extract it into its own function or a shared utility file under \`utils/\`. Never duplicate logic.
4. **Temporary test files** go under \`tmp/\` which is gitignored. Never commit test scratch files.
5. **Every file must have a clear single responsibility.** If a file grows beyond ~300 lines, discuss splitting it.

## Logging & Debugging

6. **Every run must produce detailed logs.** Use structured logging with timestamps, function names, and input/output summaries. Save logs to \`logs/\` directory.
7. **Log levels matter:** Use DEBUG for data flow details, INFO for operations, WARNING for recoverable issues, ERROR for failures.

## Git Discipline

8. **Commit frequently.** After every completed unit of work (feature, fix, refactor), make a commit with a clear message.
9. **Never write directly to protected branches** (main, production). Always work on feature branches.
10. **Commit messages format:** \`type(scope): description\` — e.g., \`feat(dashboard): add whale alert component\`

## Self-Correction Protocol

11. **When I correct you on something substantive, add the correction to this file** under the "Learned Corrections" section below. This ensures the mistake is never repeated.
12. **After every code change, update \`STATUS.md\`** with what was changed, current state, and any new bugs or issues.

## Data & AI Work (CRITICAL)

13. **Never subsample or simplify data unless explicitly asked.** If analysis is requested on "the full dataset," run it on the FULL dataset. Do not silently take every Nth point to save time.
14. **Double-check numerical comparisons.** Verify what "higher is better" vs "lower is better" means for each metric before making claims.
15. **Follow instructions in this file literally.** If a procedure is documented here, do not deviate or improvise an alternative approach.

---

## Learned Corrections

| Date | Correction |
|------|-----------|
| | |

---

## Project-Specific Rules

<!-- Add project-specific instructions below -->

CLAUDEEOF
  ADDED+=("CLAUDE.md")
fi

# --- STATUS.md ---
if safe_create "$PROJECT_DIR/STATUS.md" "STATUS.md"; then
  # Try to capture current file tree for the status file
  CURRENT_TREE=$(cd "$PROJECT_DIR" && find . -type f \
    -not -path './.git/*' \
    -not -path './node_modules/*' \
    -not -path './__pycache__/*' \
    -not -path './venv/*' \
    -not -path './.venv/*' \
    -not -path './.next/*' \
    -not -path './dist/*' \
    -not -path './build/*' \
    -not -path './logs/*' \
    -not -path './tmp/*' \
    2>/dev/null | sort | head -60)

  cat > "$PROJECT_DIR/STATUS.md" << STATUSEOF
# Project Status — ${PROJECT_NAME}

> **Last Updated:** ${TODAY}
> **Current Phase:** Adopted into AI Dev Toolkit framework
> **Active Branch:** $(cd "$PROJECT_DIR" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

---

## Project Structure

\`\`\`
${CURRENT_TREE}
\`\`\`

## What Each Module Does

| Path | Purpose |
|------|---------|
| TODO | Fill in for your key files/folders |

---

## Completed Work

- [x] Adopted AI Dev Toolkit framework — ${TODAY}

## In Progress

- [ ] Review and customize CLAUDE.md for this project
- [ ] Create or update docs/PRD.md
- [ ] Create or update docs/TECH_SPEC.md

## Not Yet Started

- [ ] TODO: Add your tasks here

---

## Active Bugs / Issues

| # | Description | Severity | Found | Status |
|---|-------------|----------|-------|--------|
| — | None documented yet | — | — | — |

## Key Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| Adopted AI Dev Toolkit | Standardize project structure and workflows | ${TODAY} |

## Environment / Integration Status

| Service | Status | Notes |
|---------|--------|-------|
| Git | $([ "$HAS_GIT" = true ] && echo "✅ Working" || echo "❌ Not initialized") | |
| Hooks | ✅ Configured | 4 standard hooks |

## Test Status

- **Total tests:** TODO
- **Passing:** TODO
- **Failing:** TODO
- **Last run:** TODO

---

## Session Log

### ${TODAY} — Adopted AI Dev Toolkit
**What we did:**
- Added standard framework files (CLAUDE.md, STATUS.md, hooks, etc.)

**What's next:**
- Customize CLAUDE.md with project-specific rules
- Fill in PRD and Tech Spec if they don't exist yet
- Resume normal development using the framework

**Blockers:**
- None
STATUSEOF
  ADDED+=("STATUS.md")
fi

# --- docs/PRD.md ---
if safe_create "$PROJECT_DIR/docs/PRD.md" "docs/PRD.md"; then
  cat > "$PROJECT_DIR/docs/PRD.md" << PRDEOF
# PRD — ${PROJECT_NAME}

> **Version:** 1.0
> **Date:** ${TODAY}
> **Status:** Draft

---

## 1. Background & Context

TODO: What is the broader context? Why does this project exist?

## 2. Problem Statement

TODO: What specific problem are we solving?

## 3. Product Vision

TODO: What does the finished product do and who is it for?

## 4. Target Users

| User Type | Description | Primary Need |
|-----------|-------------|-------------|
| | | |

## 5. User Stories

### Core (MVP)
- As a [user type], I want to [action] so that [benefit]
  - **Acceptance Criteria:**
    - [ ] Criterion 1
    - [ ] Criterion 2

## 6. Feature Roadmap

### Phase 1 — MVP
| Feature | Priority | Complexity | Notes |
|---------|----------|-----------|-------|
| | P0 | | |

## 7. Technical Requirements (High-Level)

- **Performance:** TODO
- **Security:** TODO
- **Integrations:** TODO
- **Deployment:** TODO

## 8. Success Metrics

| Metric | Target | How Measured |
|--------|--------|-------------|
| | | |

## 9. Out of Scope

- TODO

## 10. Open Questions

| # | Question | Decision | Date |
|---|----------|----------|------|
| 1 | | Pending | |
PRDEOF
  ADDED+=("docs/PRD.md")
fi

# --- docs/TECH_SPEC.md ---
if safe_create "$PROJECT_DIR/docs/TECH_SPEC.md" "docs/TECH_SPEC.md"; then
  cat > "$PROJECT_DIR/docs/TECH_SPEC.md" << TECHEOF
# Tech Spec — ${PROJECT_NAME}

> **Version:** 1.0
> **PRD Reference:** docs/PRD.md
> **Date:** ${TODAY}
> **Status:** Draft

---

## 1. System Architecture Overview

TODO

## 2. Tech Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| | | |

## 3. Component Breakdown

TODO

## 4. API Design

TODO

## 5. File/Folder Structure

\`\`\`
TODO
\`\`\`

## 6. Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| | | |

## 7. Error Handling Strategy

TODO

## 8. Testing Strategy

| Test Type | Tool | What's Tested |
|-----------|------|--------------|
| | | |

## 9. Deployment

- **Target:** TODO
- **Build process:** TODO

## 10. Phases

### Phase 1 — MVP
1. [ ] TODO
TECHEOF
  ADDED+=("docs/TECH_SPEC.md")
fi

# --- .env.example ---
if safe_create "$PROJECT_DIR/.env.example" ".env.example"; then
  # Try to extract var names from existing .env or .env.local
  ENV_CONTENT="# Environment Variables — Copy to .env (or .env.local for Next.js)\n# Generated by AI Dev Toolkit adopt script\n"

  if [ -f "$PROJECT_DIR/.env" ]; then
    ENV_CONTENT="${ENV_CONTENT}\n# Detected from existing .env:\n"
    # Extract variable names, replace values with placeholders
    while IFS= read -r line; do
      if [[ "$line" =~ ^[A-Z_]+=.+ ]]; then
        VAR_NAME=$(echo "$line" | cut -d'=' -f1)
        ENV_CONTENT="${ENV_CONTENT}${VAR_NAME}=your_value_here\n"
      elif [[ "$line" =~ ^# ]]; then
        ENV_CONTENT="${ENV_CONTENT}${line}\n"
      fi
    done < "$PROJECT_DIR/.env"
  elif [ -f "$PROJECT_DIR/.env.local" ]; then
    ENV_CONTENT="${ENV_CONTENT}\n# Detected from existing .env.local:\n"
    while IFS= read -r line; do
      if [[ "$line" =~ ^[A-Z_]+=.+ ]]; then
        VAR_NAME=$(echo "$line" | cut -d'=' -f1)
        ENV_CONTENT="${ENV_CONTENT}${VAR_NAME}=your_value_here\n"
      elif [[ "$line" =~ ^# ]]; then
        ENV_CONTENT="${ENV_CONTENT}${line}\n"
      fi
    done < "$PROJECT_DIR/.env.local"
  else
    ENV_CONTENT="${ENV_CONTENT}\n# TODO: Add your environment variables here\n# EXAMPLE_API_KEY=your_key_here\n"
  fi

  echo -e "$ENV_CONTENT" > "$PROJECT_DIR/.env.example"
  ADDED+=(".env.example")
fi

# --- .gitignore (append missing entries, don't overwrite) ---
if [ -f "$PROJECT_DIR/.gitignore" ]; then
  echo -e "  ⏭️  .gitignore — ${YELLOW}already exists, checking for missing entries${NC}"

  MISSING_ENTRIES=()
  REQUIRED_ENTRIES=("tmp/" "logs/" ".env" ".env.local" ".env.*.local")

  for entry in "${REQUIRED_ENTRIES[@]}"; do
    if ! grep -qxF "$entry" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
      MISSING_ENTRIES+=("$entry")
    fi
  done

  if [ ${#MISSING_ENTRIES[@]} -gt 0 ]; then
    echo "" >> "$PROJECT_DIR/.gitignore"
    echo "# Added by AI Dev Toolkit" >> "$PROJECT_DIR/.gitignore"
    for entry in "${MISSING_ENTRIES[@]}"; do
      echo "$entry" >> "$PROJECT_DIR/.gitignore"
      echo -e "    ➕ Added: ${BOLD}${entry}${NC}"
    done
    ADDED+=(".gitignore (appended)")
  else
    echo -e "    All required entries present"
  fi
else
  safe_create "$PROJECT_DIR/.gitignore" ".gitignore"
  cat > "$PROJECT_DIR/.gitignore" << 'GIEOF'
# Environment
.env
.env.local
.env.*.local

# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
.venv/
*.egg-info/

# Project scratch
tmp/
logs/
*.log

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/settings.json
.idea/

# Build
.next/
dist/
build/
out/

# Docker
*.pid

# Test
coverage/
.pytest_cache/
htmlcov/
GIEOF
  ADDED+=(".gitignore")
fi

echo ""

# ============================================================
# Create hook scripts (only if .claude/hooks/ was empty)
# ============================================================
echo -e "${YELLOW}🪝 Checking hooks...${NC}"

# --- protect-branches.sh ---
if safe_create "$PROJECT_DIR/.claude/hooks/protect-branches.sh" "protect-branches.sh"; then
  cat > "$PROJECT_DIR/.claude/hooks/protect-branches.sh" << 'HOOKEOF'
#!/bin/bash
PROTECTED_BRANCHES=("main" "production" "master")
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" == "$branch" ]; then
    echo "❌ BLOCKED: Cannot commit directly to '$branch'. Create a feature branch first."
    echo "   Run: git checkout -b feature/your-feature-name"
    exit 1
  fi
done
echo "✅ Branch '$CURRENT_BRANCH' is not protected. Proceeding."
exit 0
HOOKEOF
  chmod +x "$PROJECT_DIR/.claude/hooks/protect-branches.sh"
  ADDED+=("protect-branches.sh")
fi

# --- safe-commands.sh ---
if safe_create "$PROJECT_DIR/.claude/hooks/safe-commands.sh" "safe-commands.sh"; then
  cat > "$PROJECT_DIR/.claude/hooks/safe-commands.sh" << 'HOOKEOF'
#!/bin/bash
COMMAND="$1"
DANGEROUS_PATTERNS=(
  "rm -rf /" "rm -rf ~" "rm -rf ."
  "git push --force" "git push -f"
  "git clean -fdx" "git reset --hard HEAD~"
  "DROP TABLE" "DROP DATABASE" "truncate"
)
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "❌ BLOCKED: Dangerous command detected: '$pattern'"
    exit 1
  fi
done
exit 0
HOOKEOF
  chmod +x "$PROJECT_DIR/.claude/hooks/safe-commands.sh"
  ADDED+=("safe-commands.sh")
fi

# --- auto-format.sh ---
if safe_create "$PROJECT_DIR/.claude/hooks/auto-format.sh" "auto-format.sh"; then
  cat > "$PROJECT_DIR/.claude/hooks/auto-format.sh" << 'HOOKEOF'
#!/bin/bash
if [ -f "package.json" ]; then
  if command -v npx &> /dev/null; then
    grep -q "prettier" package.json 2>/dev/null && npx prettier --write "src/**/*.{ts,tsx,js,jsx,css,json}" 2>/dev/null
    grep -q "eslint" package.json 2>/dev/null && npx eslint --fix "src/**/*.{ts,tsx,js,jsx}" 2>/dev/null
  fi
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  command -v black &> /dev/null && black . --quiet 2>/dev/null
  command -v isort &> /dev/null && isort . --quiet 2>/dev/null
fi
echo "✅ Formatting complete."
exit 0
HOOKEOF
  chmod +x "$PROJECT_DIR/.claude/hooks/auto-format.sh"
  ADDED+=("auto-format.sh")
fi

# --- code-review.sh ---
if safe_create "$PROJECT_DIR/.claude/hooks/code-review.sh" "code-review.sh"; then
  cat > "$PROJECT_DIR/.claude/hooks/code-review.sh" << 'HOOKEOF'
#!/bin/bash
# ⚠️  STUB — This hook lists changed files but does NOT perform actual review.
# To add real review, integrate your own linter, static analysis tool, or
# Claude Code sub-agent here. The exit code controls commit gating:
#   exit 0 = allow commit
#   exit 1 = block commit
CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || git diff --name-only)
if [ -z "$CHANGED_FILES" ]; then
  echo "ℹ️  No changed files to review."
  exit 0
fi
echo "🔍 Code review stub — files staged for commit:"
echo "$CHANGED_FILES" | sed 's/^/   - /'
echo "⚠️  No automated review configured. See .claude/hooks/code-review.sh to add one."
exit 0
HOOKEOF
  chmod +x "$PROJECT_DIR/.claude/hooks/code-review.sh"
  ADDED+=("code-review.sh")
fi

# --- settings.json ---
if safe_create "$PROJECT_DIR/.claude/settings.json" ".claude/settings.json"; then
  # NOTE: The hook trigger names below (pre-commit, post-save, etc.) are
  # conceptual. Check Claude Code's current documentation for the actual
  # hook API format: https://docs.claude.com/en/docs/claude-code/overview
  cat > "$PROJECT_DIR/.claude/settings.json" << 'SETTINGSEOF'
{
  "hooks": {
    "pre-commit": [
      ".claude/hooks/protect-branches.sh",
      ".claude/hooks/code-review.sh"
    ],
    "pre-command": [
      ".claude/hooks/safe-commands.sh"
    ],
    "post-save": [
      ".claude/hooks/auto-format.sh"
    ],
    "post-major-change": [
      ".claude/hooks/code-review.sh"
    ]
  },
  "permissions": {
    "allow": [
      "git status", "git add", "git commit", "git push",
      "git checkout", "git branch", "git log", "git diff",
      "npm install", "npm run", "npx",
      "pip install", "python", "pytest",
      "docker compose", "docker build",
      "cat", "ls", "find", "grep", "head", "tail", "wc"
    ]
  },
  "mcps": {
    "playwright": {
      "enabled": true,
      "description": "Browser automation for web app debugging"
    }
  }
}
SETTINGSEOF
  ADDED+=("settings.json")
fi

echo ""

# ============================================================
# Git: initialize if missing, create develop branch if missing
# ============================================================
echo -e "${YELLOW}🔧 Checking git...${NC}"

if [ "$HAS_GIT" = false ]; then
  cd "$PROJECT_DIR"
  git init --quiet
  git checkout -b main --quiet 2>/dev/null || true
  git add -A
  git commit -m "chore(setup): adopt ai-dev-toolkit framework" --quiet 2>/dev/null || true
  git checkout -b develop --quiet 2>/dev/null || true
  echo -e "  ✅ Git initialized (main + develop, on develop)"
  ADDED+=("git init")
else
  cd "$PROJECT_DIR"
  # Check if develop branch exists
  if ! git rev-parse --verify develop &>/dev/null; then
    echo -e "  ⚠️  No 'develop' branch found."
    echo -e "     ${BOLD}Recommendation:${NC} Create one with: git checkout -b develop"
  else
    echo -e "  ✅ Git repo with develop branch — all good"
  fi
fi

echo ""

# ============================================================
# Summary
# ============================================================
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       🎉  Project Adopted!               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

if [ ${#ADDED[@]} -gt 0 ]; then
  echo -e "${BOLD}Added:${NC}"
  for item in "${ADDED[@]}"; do
    echo -e "  ${GREEN}+ ${item}${NC}"
  done
else
  echo -e "${GREEN}Nothing to add — project already has all framework files!${NC}"
fi

echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. ${BOLD}Customize CLAUDE.md${NC}"
echo "     Open CLAUDE.md and add project-specific rules"
echo "     (API conventions, naming patterns, special constraints)"
echo ""
echo "  2. ${BOLD}Fill in STATUS.md${NC}"
echo "     Document current state: what's built, what's in progress,"
echo "     active bugs, key decisions already made"
echo ""
echo "  3. ${BOLD}Fill in docs/PRD.md${NC} (or tell Claude Code to interview you):"
echo "     ${CYAN}Read STATUS.md and CLAUDE.md. Let's create the PRD for this"
echo "     existing project. Ask me at least 10 questions about what it"
echo "     does, who it's for, and what's already built.${NC}"
echo ""
echo "  4. ${BOLD}Fill in docs/TECH_SPEC.md${NC} (same approach):"
echo "     ${CYAN}Based on PRD.md, create a Tech Spec. Ask me about the"
echo "     current architecture, stack decisions, and integrations.${NC}"
echo ""
echo "  5. ${BOLD}Commit the new files:${NC}"
echo "     git add -A && git commit -m \"chore(setup): adopt ai-dev-toolkit framework\""
echo ""
