#!/bin/bash
# ============================================================
# AI Dev Toolkit — Project Creator
# Run this script to scaffold a new project with all standard
# files, folders, hooks, and templates in one shot.
#
# Usage:
#   ./create-project.sh
#   (interactive — it will ask you questions)
#
# Or non-interactive:
#   ./create-project.sh --name "my-project" --type nextjs --path ~/projects
# ============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the directory where this script lives (to find templates)
TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================
# Parse arguments (optional — script also runs interactively)
# ============================================================
PROJECT_NAME=""
PROJECT_TYPE=""
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --type) PROJECT_TYPE="$2"; shift 2 ;;
    --path) PROJECT_PATH="$2"; shift 2 ;;
    *) echo -e "${RED}Unknown option: $1${NC}"; exit 1 ;;
  esac
done

# ============================================================
# Interactive prompts (if arguments not provided)
# ============================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   🏗️  AI Dev Toolkit — Project Creator   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# Project name
if [ -z "$PROJECT_NAME" ]; then
  echo -e "${BOLD}Project name${NC} (kebab-case, e.g. my-cool-app):"
  read -r PROJECT_NAME
  if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required.${NC}"
    exit 1
  fi
fi

# Project type
if [ -z "$PROJECT_TYPE" ]; then
  echo ""
  echo -e "${BOLD}Project type:${NC}"
  echo "  1) nextjs     — Next.js + React + TypeScript + Tailwind"
  echo "  2) python     — Python + Flask + Docker"
  echo "  3) docker     — Docker multi-service (multiple containers)"
  echo "  4) minimal    — Just the standard files, no framework setup"
  echo ""
  echo -n "Choose [1-4]: "
  read -r TYPE_CHOICE
  case $TYPE_CHOICE in
    1|nextjs)  PROJECT_TYPE="nextjs" ;;
    2|python)  PROJECT_TYPE="python" ;;
    3|docker)  PROJECT_TYPE="docker" ;;
    4|minimal) PROJECT_TYPE="minimal" ;;
    *) echo -e "${RED}Invalid choice. Using 'minimal'.${NC}"; PROJECT_TYPE="minimal" ;;
  esac
fi

# Project path
if [ -z "$PROJECT_PATH" ]; then
  DEFAULT_PATH="$(pwd)"
  echo ""
  echo -e "${BOLD}Where to create the project?${NC} (default: ${DEFAULT_PATH})"
  read -r PROJECT_PATH
  if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH="$DEFAULT_PATH"
  fi
fi

# Full project directory
PROJECT_DIR="${PROJECT_PATH}/${PROJECT_NAME}"
TODAY=$(date +%Y-%m-%d)

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
  echo -e "${RED}Error: Directory '${PROJECT_DIR}' already exists.${NC}"
  echo "Delete it first or choose a different name."
  exit 1
fi

echo ""
echo -e "${BLUE}Creating project:${NC}"
echo -e "  Name: ${BOLD}${PROJECT_NAME}${NC}"
echo -e "  Type: ${BOLD}${PROJECT_TYPE}${NC}"
echo -e "  Path: ${BOLD}${PROJECT_DIR}${NC}"
echo ""

# ============================================================
# Create folder structure
# ============================================================
echo -e "${YELLOW}📁 Creating folder structure...${NC}"

# Standard folders (every project gets these)
mkdir -p "${PROJECT_DIR}/.claude/hooks"
mkdir -p "${PROJECT_DIR}/docs"
mkdir -p "${PROJECT_DIR}/logs"
mkdir -p "${PROJECT_DIR}/tmp"

# Framework-specific folders
case $PROJECT_TYPE in
  nextjs)
    mkdir -p "${PROJECT_DIR}/app/api"
    mkdir -p "${PROJECT_DIR}/components"
    mkdir -p "${PROJECT_DIR}/lib"
    mkdir -p "${PROJECT_DIR}/types"
    mkdir -p "${PROJECT_DIR}/public"
    ;;
  python)
    mkdir -p "${PROJECT_DIR}/src/routes"
    mkdir -p "${PROJECT_DIR}/src/services"
    mkdir -p "${PROJECT_DIR}/src/models"
    mkdir -p "${PROJECT_DIR}/src/utils"
    mkdir -p "${PROJECT_DIR}/tests"
    mkdir -p "${PROJECT_DIR}/docker"
    ;;
  docker)
    mkdir -p "${PROJECT_DIR}/services"
    mkdir -p "${PROJECT_DIR}/tests"
    ;;
  minimal)
    mkdir -p "${PROJECT_DIR}/src"
    mkdir -p "${PROJECT_DIR}/tests"
    ;;
esac

echo -e "${GREEN}  ✅ Folders created${NC}"

# ============================================================
# Copy / generate template files
# ============================================================
echo -e "${YELLOW}📄 Creating template files...${NC}"

# --- CLAUDE.md ---
if [ -f "${TOOLKIT_DIR}/templates/CLAUDE.md" ]; then
  sed "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g; s/\[GIT_REPO_URL\]/TODO: add repo URL/g; s/\[DATE\]/${TODAY}/g" \
    "${TOOLKIT_DIR}/templates/CLAUDE.md" > "${PROJECT_DIR}/CLAUDE.md"
else
  cat > "${PROJECT_DIR}/CLAUDE.md" << 'CLAUDE_EOF'
# CLAUDE.md — Project Rules

## Project Info

- **Repo:** TODO: add repo URL
- **Stack:** TODO: fill in
- **Key docs:** See linked files below

## Linked Project Files

- PRD: `./docs/PRD.md`
- Tech Spec: `./docs/TECH_SPEC.md`
- Status: `./STATUS.md`

---

## Code Quality Rules

1. **Keep code clean.** No dead code, no commented-out blocks, no orphaned imports.
2. **When making changes:** If any code becomes "orphaned" (no longer called by anything), delete it immediately.
3. **DRY principle:** If a code snippet is used more than once, extract it into its own function or a shared utility file under `utils/`. Never duplicate logic.
4. **Temporary test files** go under `tmp/` which is gitignored. Never commit test scratch files.
5. **Every file must have a clear single responsibility.** If a file grows beyond ~300 lines, discuss splitting it.

## Logging & Debugging

6. **Every run must produce detailed logs.** Use structured logging with timestamps, function names, and input/output summaries. Save logs to `logs/` directory.
7. **Log levels matter:** Use DEBUG for data flow details, INFO for operations, WARNING for recoverable issues, ERROR for failures.

## Git Discipline

8. **Commit frequently.** After every completed unit of work (feature, fix, refactor), make a commit with a clear message.
9. **Never write directly to protected branches** (main, production). Always work on feature branches.
10. **Commit messages format:** `type(scope): description` — e.g., `feat(dashboard): add whale alert component`

## Self-Correction Protocol

11. **When I correct you on something substantive, add the correction to this file** under the "Learned Corrections" section below. This ensures the mistake is never repeated.
12. **After every code change, update `STATUS.md`** with what was changed, current state, and any new bugs or issues.

## Data & AI Work (CRITICAL)

13. **Never subsample or simplify data unless explicitly asked.** If analysis is requested on "the full dataset," run it on the FULL dataset. Do not silently take every Nth point to save time.
14. **Double-check numerical comparisons.** Verify what "higher is better" vs "lower is better" means for each metric before making claims.
15. **Follow instructions in this file literally.** If a procedure is documented here, do not deviate or improvise an alternative approach.

---

## Learned Corrections

<!-- Claude Code adds entries here when corrected on substantive issues -->

| Date | Correction |
|------|-----------|
| | |

---

## Project-Specific Rules

<!-- Add project-specific instructions below -->

CLAUDE_EOF
fi

# --- STATUS.md ---
if [ -f "${TOOLKIT_DIR}/templates/STATUS.md" ]; then
  sed "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g; s/\[DATE\]/${TODAY}/g" \
    "${TOOLKIT_DIR}/templates/STATUS.md" > "${PROJECT_DIR}/STATUS.md"
else
  cat > "${PROJECT_DIR}/STATUS.md" << STATUSEOF
# Project Status — ${PROJECT_NAME}

> **Last Updated:** ${TODAY}
> **Current Phase:** Phase 0 — Setup Complete
> **Active Branch:** develop

---

## Project Structure

\`\`\`
TODO: paste full file tree after first build session
\`\`\`

## What Each Module Does

| Path | Purpose |
|------|---------|
| | |

---

## Completed Work

- [x] Project skeleton created — ${TODAY}
- [x] CLAUDE.md configured — ${TODAY}
- [x] Hooks set up — ${TODAY}

## In Progress

- [ ] Create PRD — Not started
- [ ] Create Tech Spec — Not started

## Not Yet Started

- [ ] Phase 1 tasks (define after PRD/Tech Spec)

---

## Active Bugs / Issues

| # | Description | Severity | Found | Status |
|---|-------------|----------|-------|--------|
| — | None yet | — | — | — |

## Key Decisions Made

| Decision | Rationale | Date |
|----------|-----------|------|
| Project type: ${PROJECT_TYPE} | Selected during scaffolding | ${TODAY} |

## Environment / Integration Status

| Service | Status | Notes |
|---------|--------|-------|
| Git | ✅ Working | Initialized with main + develop |
| Hooks | ✅ Working | All 4 hooks configured |

## Test Status

- **Total tests:** 0
- **Passing:** 0
- **Failing:** 0
- **Skipped:** 0
- **Last run:** N/A

---

## Session Log

### ${TODAY} — Session 1
**What we did:**
- Scaffolded project with ai-dev-toolkit

**What's next:**
- Create PRD (docs/PRD.md)
- Create Tech Spec (docs/TECH_SPEC.md)
- Begin Phase 1 development

**Blockers:**
- None
STATUSEOF
fi

# --- docs/PRD.md ---
if [ -f "${TOOLKIT_DIR}/templates/PRD.md" ]; then
  sed "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g; s/\[DATE\]/${TODAY}/g; s/\[NAME\]/TODO/g" \
    "${TOOLKIT_DIR}/templates/PRD.md" > "${PROJECT_DIR}/docs/PRD.md"
else
  cat > "${PROJECT_DIR}/docs/PRD.md" << PRDEOF
# PRD — ${PROJECT_NAME}

> **Version:** 1.0
> **Author:** TODO
> **Date:** ${TODAY}
> **Status:** Draft

---

## 1. Background & Context

TODO: What is the broader context? Why does this project exist?

## 2. Problem Statement

TODO: What specific problem are we solving? Who has this problem?

## 3. Product Vision

TODO: In 2-3 sentences, what does the finished product do and who is it for?

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

### Phase 2
- ...

## 6. Feature Roadmap

### Phase 1 — MVP
| Feature | Priority | Complexity | Notes |
|---------|----------|-----------|-------|
| | P0 | | |

### Phase 2
| Feature | Priority | Complexity | Notes |
|---------|----------|-----------|-------|
| | P1 | | |

## 7. Technical Requirements (High-Level)

- **Performance:** TODO
- **Scalability:** TODO
- **Security:** TODO
- **Integrations:** TODO
- **Deployment:** TODO

## 8. Success Metrics

| Metric | Target | How Measured |
|--------|--------|-------------|
| | | |

## 9. Out of Scope

- TODO

## 10. Open Questions / Decisions Needed

| # | Question | Owner | Decision | Date |
|---|----------|-------|----------|------|
| 1 | | | Pending | |

## 11. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| | | | |
PRDEOF
fi

# --- docs/TECH_SPEC.md ---
if [ -f "${TOOLKIT_DIR}/templates/TECH_SPEC.md" ]; then
  sed "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g; s/\[DATE\]/${TODAY}/g" \
    "${TOOLKIT_DIR}/templates/TECH_SPEC.md" > "${PROJECT_DIR}/docs/TECH_SPEC.md"
else
  cat > "${PROJECT_DIR}/docs/TECH_SPEC.md" << TECHEOF
# Tech Spec — ${PROJECT_NAME}

> **Version:** 1.0
> **PRD Reference:** docs/PRD.md
> **Date:** ${TODAY}
> **Status:** Draft

---

## 1. System Architecture Overview

TODO: 2-3 sentence description

## 2. Tech Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Frontend | | |
| Backend | | |
| Database | | |
| Hosting | | |

## 3. Component Breakdown

### Component: [Name]
- **Responsibility:** TODO
- **Inputs:** TODO
- **Outputs:** TODO
- **Dependencies:** TODO
- **Key files:** TODO

## 4. Data Model / Schema

TODO

## 5. API Design

### Endpoint: \`[METHOD] /api/v1/[path]\`
- **Purpose:** TODO
- **Request:** \`{}\`
- **Response (200):** \`{}\`

## 6. File/Folder Structure

\`\`\`
TODO: detailed tree after architecture decisions
\`\`\`

## 7. Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| | | | |

## 8. Integration Points

| Service | Purpose | Auth Method | Rate Limits | Fallback |
|---------|---------|------------|-------------|----------|
| | | | | |

## 9. Authentication & Authorization

TODO

## 10. Error Handling Strategy

TODO

## 11. Testing Strategy

| Test Type | Tool | Coverage Target | What's Tested |
|-----------|------|----------------|--------------|
| Unit | | 80%+ | |
| Integration | | | |
| E2E | Playwright | | |

## 12. Deployment

- **Target:** TODO
- **Build process:** TODO
- **Rollback strategy:** TODO

## 13. Technical Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|-----------|
| | | | |

## 14. Phases & Implementation Order

### Phase 1 — MVP
1. [ ] TODO

### Phase 2
1. [ ] TODO
TECHEOF
fi

# --- .env.example ---
case $PROJECT_TYPE in
  nextjs)
    cat > "${PROJECT_DIR}/.env.example" << 'ENVEOF'
# ============================================================
# Environment Variables — Copy this file to .env.local
# ============================================================

# API Keys
# NEXT_PUBLIC_ALCHEMY_API_KEY=your_alchemy_key_here
# ETHERSCAN_API_KEY=your_etherscan_key_here
# OPENAI_API_KEY=your_openai_key_here

# Database (if needed)
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# App Config
# NEXT_PUBLIC_APP_URL=http://localhost:3000
ENVEOF
    ;;
  python)
    cat > "${PROJECT_DIR}/.env.example" << 'ENVEOF'
# ============================================================
# Environment Variables — Copy this file to .env
# ============================================================

# Flask
FLASK_ENV=development
FLASK_DEBUG=1
SECRET_KEY=change-me-in-production

# API Keys
# OPENAI_API_KEY=your_openai_key_here

# Database (if needed)
# DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# External Services
# ALCHEMY_API_KEY=your_key_here
ENVEOF
    ;;
  *)
    cat > "${PROJECT_DIR}/.env.example" << 'ENVEOF'
# ============================================================
# Environment Variables — Copy this file to .env
# ============================================================

# Add your environment variables here
# EXAMPLE_API_KEY=your_key_here
ENVEOF
    ;;
esac

# --- .gitignore ---
cat > "${PROJECT_DIR}/.gitignore" << 'GIEOF'
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

# Build outputs
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

# --- README.md ---
cat > "${PROJECT_DIR}/README.md" << READMEEOF
# ${PROJECT_NAME}

> TODO: One-line description of what this project does.

## Quick Start

\`\`\`bash
# TODO: Add setup instructions after Phase 1
\`\`\`

## Documentation

- [Product Requirements](./docs/PRD.md)
- [Technical Specification](./docs/TECH_SPEC.md)
- [Project Status](./STATUS.md)
READMEEOF

echo -e "${GREEN}  ✅ Template files created${NC}"

# ============================================================
# Create hook scripts
# ============================================================
echo -e "${YELLOW}🪝 Creating hook scripts...${NC}"

# --- Hook 1: Branch Protection ---
cat > "${PROJECT_DIR}/.claude/hooks/protect-branches.sh" << 'HOOKEOF'
#!/bin/bash
# Prevents commits to protected branches

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

# --- Hook 2: Safe Commands ---
cat > "${PROJECT_DIR}/.claude/hooks/safe-commands.sh" << 'HOOKEOF'
#!/bin/bash
# Blocks dangerous commands that could permanently delete code or data

COMMAND="$1"

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf ."
  "git push --force"
  "git push -f"
  "git clean -fdx"
  "git reset --hard HEAD~"
  "DROP TABLE"
  "DROP DATABASE"
  "truncate"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    echo "❌ BLOCKED: Dangerous command detected: '$pattern'"
    echo "   This command could permanently delete code or data."
    echo "   If you really need this, run it manually outside Claude Code."
    exit 1
  fi
done

exit 0
HOOKEOF

# --- Hook 3: Auto Format ---
cat > "${PROJECT_DIR}/.claude/hooks/auto-format.sh" << 'HOOKEOF'
#!/bin/bash
# Auto-formats code after major edits

# JavaScript/TypeScript
if [ -f "package.json" ]; then
  if command -v npx &> /dev/null; then
    if grep -q "prettier" package.json 2>/dev/null; then
      echo "🔧 Running Prettier..."
      npx prettier --write "src/**/*.{ts,tsx,js,jsx,css,json}" 2>/dev/null
    fi
    if grep -q "eslint" package.json 2>/dev/null; then
      echo "🔧 Running ESLint fix..."
      npx eslint --fix "src/**/*.{ts,tsx,js,jsx}" 2>/dev/null
    fi
  fi
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  if command -v black &> /dev/null; then
    echo "🔧 Running Black formatter..."
    black . --quiet 2>/dev/null
  fi
  if command -v isort &> /dev/null; then
    echo "🔧 Running isort..."
    isort . --quiet 2>/dev/null
  fi
fi

echo "✅ Formatting complete."
exit 0
HOOKEOF

# --- Hook 4: Code Review ---
cat > "${PROJECT_DIR}/.claude/hooks/code-review.sh" << 'HOOKEOF'
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
echo ""
echo "⚠️  No automated review configured. To add one, edit this file:"
echo "   .claude/hooks/code-review.sh"
echo ""
echo "   Options:"
echo "   - Run a linter (eslint, pylint, etc.)"
echo "   - Run static analysis"
echo "   - Call a Claude Code sub-agent to review the diff"
echo "   - Change 'exit 0' to 'exit 1' to block commits that fail review"
exit 0
HOOKEOF

# --- Hook 5: Compliance Verification (PRODUCTION READY) ---
cat > "${PROJECT_DIR}/.claude/hooks/verify-compliance.sh" << 'HOOKEOF'
#!/bin/bash
# .claude/hooks/verify-compliance.sh
#
# Checks that Claude Code is actually following CLAUDE.md rules.
# Run this as a pre-commit hook or manually after each session.
#
# Exit codes: 0 = all checks pass, 1 = violations found

VIOLATIONS=0
WARNINGS=0

echo "🔍 Running compliance check..."
echo ""

# --- Check 1: STATUS.md was updated recently ---
if [ -f "STATUS.md" ]; then
  # Check if STATUS.md is staged or was modified in the last 30 minutes
  if git diff --cached --name-only | grep -q "STATUS.md"; then
    echo "✅ STATUS.md is staged for commit"
  else
    LAST_MODIFIED=$(stat -c %Y STATUS.md 2>/dev/null || stat -f %m STATUS.md 2>/dev/null)
    NOW=$(date +%s)
    AGE=$(( (NOW - LAST_MODIFIED) / 60 ))
    if [ "$AGE" -gt 30 ]; then
      echo "⚠️  WARNING: STATUS.md hasn't been updated in ${AGE} minutes"
      WARNINGS=$((WARNINGS + 1))
    else
      echo "✅ STATUS.md was updated ${AGE} minutes ago"
    fi
  fi
else
  echo "❌ VIOLATION: STATUS.md does not exist"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# --- Check 2: No partial file markers in staged files ---
PARTIAL_MARKERS=(
  "rest stays the same"
  "rest of the code stays the same"
  "remaining code unchanged"
  "... existing code ..."
  "// ... rest"
  "# ... rest"
  "<!-- rest"
  "TRUNCATED"
)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
if [ -n "$STAGED_FILES" ]; then
  for marker in "${PARTIAL_MARKERS[@]}"; do
    FOUND=$(echo "$STAGED_FILES" | xargs grep -li "$marker" 2>/dev/null)
    if [ -n "$FOUND" ]; then
      echo "❌ VIOLATION: Partial file marker '${marker}' found in:"
      echo "$FOUND" | sed 's/^/   /'
      VIOLATIONS=$((VIOLATIONS + 1))
    fi
  done
  if [ "$VIOLATIONS" -eq 0 ]; then
    echo "✅ No partial file markers found"
  fi
fi

# --- Check 3: No hardcoded secrets in staged files ---
SECRET_PATTERNS=(
  "sk-ant-[a-zA-Z0-9]"
  "sk-[a-zA-Z0-9]{20,}"
  "AKIA[A-Z0-9]{16}"
  "password\s*=\s*['\"][^'\"$]"
)

if [ -n "$STAGED_FILES" ]; then
  SECRET_FOUND=false
  for pattern in "${SECRET_PATTERNS[@]}"; do
    FOUND=$(echo "$STAGED_FILES" | xargs grep -lE "$pattern" 2>/dev/null | grep -v ".env.example" | grep -v "HOOKS_SETUP" | grep -v "verify-compliance" | grep -v "TROUBLESHOOTING" | grep -v ".md")
    if [ -n "$FOUND" ]; then
      echo "❌ VIOLATION: Possible hardcoded secret (pattern: ${pattern}) in:"
      echo "$FOUND" | sed 's/^/   /'
      VIOLATIONS=$((VIOLATIONS + 1))
      SECRET_FOUND=true
    fi
  done
  if [ "$SECRET_FOUND" = false ]; then
    echo "✅ No hardcoded secrets detected"
  fi
fi

# --- Check 4: .env is not staged ---
if git diff --cached --name-only | grep -q "^\.env$"; then
  echo "❌ VIOLATION: .env file is staged for commit — this should be in .gitignore"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅ .env is not staged"
fi

# --- Check 5: Not committing to protected branches ---
PROTECTED_BRANCHES=("main" "production" "master")
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" == "$branch" ]; then
    echo "❌ VIOLATION: Committing directly to protected branch '$branch'"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done
if [ "$VIOLATIONS" -eq 0 ] || [ -n "$CURRENT_BRANCH" ]; then
  # Only print if no branch violation was found
  if ! printf '%s\n' "${PROTECTED_BRANCHES[@]}" | grep -q "^${CURRENT_BRANCH}$"; then
    echo "✅ Branch '$CURRENT_BRANCH' is not protected"
  fi
fi

# --- Check 6: CLAUDE.md exists ---
if [ ! -f "CLAUDE.md" ]; then
  echo "❌ VIOLATION: CLAUDE.md does not exist in project root"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅ CLAUDE.md exists"
fi

# --- Check 7: Large files check (>500 lines) ---
if [ -n "$STAGED_FILES" ]; then
  LARGE_FILES=""
  for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
      LINES=$(wc -l < "$file" 2>/dev/null)
      if [ "$LINES" -gt 500 ]; then
        LARGE_FILES="${LARGE_FILES}\n   ${file} (${LINES} lines)"
      fi
    fi
  done
  if [ -n "$LARGE_FILES" ]; then
    echo "⚠️  WARNING: Large files detected (>500 lines) — consider splitting:"
    echo -e "$LARGE_FILES"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "✅ No oversized files"
  fi
fi

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━"
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌ ${VIOLATIONS} violation(s) found, ${WARNINGS} warning(s)"
  echo "   Fix violations before committing."
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "⚠️  ${WARNINGS} warning(s) found — review above"
  echo "   Proceeding with commit (warnings don't block)."
  exit 0
else
  echo "✅ All compliance checks passed"
  exit 0
fi
HOOKEOF

# Make all hooks executable
chmod +x "${PROJECT_DIR}/.claude/hooks/"*.sh

# --- settings.json ---
# Copy from templates if available, otherwise create basic version
if [ -f "${TOOLKIT_DIR}/templates/settings.json" ]; then
  cp "${TOOLKIT_DIR}/templates/settings.json" "${PROJECT_DIR}/.claude/settings.json"
  echo -e "${GREEN}  ✅ settings.json created from template${NC}"
else
  # Fallback: create basic settings.json inline
  cat > "${PROJECT_DIR}/.claude/settings.json" << 'SETTINGSEOF'
{
  "$schema": "https://claude.ai/schemas/settings.json",
  "hooks": {
    "pre_commit": [
      ".claude/hooks/verify-compliance.sh"
    ]
  },
  "permissions": {
    "allow_commands": [
      "git status",
      "git add",
      "git commit",
      "git push",
      "git checkout",
      "git branch",
      "git log",
      "git diff",
      "git stash",
      "git merge",
      "npm install",
      "npm run",
      "npm test",
      "npx",
      "yarn",
      "pnpm",
      "pip install",
      "python",
      "python3",
      "pytest",
      "poetry",
      "docker compose",
      "docker build",
      "docker ps",
      "docker logs",
      "cat",
      "ls",
      "find",
      "grep",
      "head",
      "tail",
      "wc",
      "echo",
      "mkdir",
      "touch",
      "mv",
      "cp"
    ]
  },
  "mcps": {
    "playwright": {
      "enabled": false,
      "description": "Browser automation for web app debugging. Enable after installing Playwright MCP."
    }
  }
}
SETTINGSEOF
  echo -e "${GREEN}  ✅ settings.json created${NC}"
fi

echo -e "${GREEN}  ✅ Hooks and settings created${NC}"

# ============================================================
# Framework-specific files
# ============================================================
echo -e "${YELLOW}⚙️  Creating framework-specific files...${NC}"

case $PROJECT_TYPE in
  nextjs)
    # Basic Next.js app/layout.tsx
    cat > "${PROJECT_DIR}/app/layout.tsx" << 'NEXTEOF'
import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'TODO: App Title',
  description: 'TODO: App Description',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-950 text-white min-h-screen">
        {children}
      </body>
    </html>
  );
}
NEXTEOF

    # Basic page.tsx
    cat > "${PROJECT_DIR}/app/page.tsx" << NEXTEOF
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8">
      <h1 className="text-4xl font-bold mb-4">${PROJECT_NAME}</h1>
      <p className="text-gray-400">Project scaffolded. Start building!</p>
    </main>
  );
}
NEXTEOF

    # globals.css
    cat > "${PROJECT_DIR}/app/globals.css" << 'NEXTEOF'
/* NOTE: @tailwind directives are for Tailwind CSS v3.
   If using Tailwind v4+, replace these with: @import "tailwindcss";
   Check: https://tailwindcss.com/docs/upgrade-guide */
@tailwind base;
@tailwind components;
@tailwind utilities;
NEXTEOF

    # tsconfig.json
    cat > "${PROJECT_DIR}/tsconfig.json" << 'NEXTEOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
NEXTEOF

    # package.json
    cat > "${PROJECT_DIR}/package.json" << NEXTEOF
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22.0.0",
    "@types/react": "^19.0.0",
    "@types/react-dom": "^19.0.0",
    "autoprefixer": "^10.0.0",
    "postcss": "^8.0.0",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.0.0"
  }
}
NEXTEOF

    # tailwind.config.ts
    cat > "${PROJECT_DIR}/tailwind.config.ts" << 'NEXTEOF'
// Tailwind CSS v3 configuration
// If upgrading to Tailwind v4, remove this file and use CSS-based config instead.
// See: https://tailwindcss.com/docs/upgrade-guide
import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './lib/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};

export default config;
NEXTEOF

    # postcss.config.js
    cat > "${PROJECT_DIR}/postcss.config.js" << 'NEXTEOF'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
NEXTEOF

    # next.config.js
    cat > "${PROJECT_DIR}/next.config.js" << 'NEXTEOF'
/** @type {import('next').NextConfig} */
const nextConfig = {};

module.exports = nextConfig;
NEXTEOF

    echo -e "${GREEN}  ✅ Next.js files created${NC}"
    echo -e "${YELLOW}  ⚠️  Before the project will run, you must:${NC}"
    echo -e "${YELLOW}     1. cd ${PROJECT_DIR}${NC}"
    echo -e "${YELLOW}     2. npm install${NC}"
    echo -e "${YELLOW}     3. npm run dev${NC}"
    echo -e "${YELLOW}  Note: If your Tailwind/Next.js versions have changed, run:${NC}"
    echo -e "${YELLOW}     npx @next/codemod upgrade${NC}"
    echo -e "${YELLOW}  to align config files with your installed versions.${NC}"
    ;;

  python)
    # app.py
    cat > "${PROJECT_DIR}/src/app.py" << 'PYEOF'
"""Flask application factory."""
import os
import logging
from flask import Flask
from flask_cors import CORS

def create_app():
    """Create and configure the Flask application."""
    app = Flask(__name__)

    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-change-me')
    app.config['DEBUG'] = os.getenv('FLASK_DEBUG', '0') == '1'

    # CORS
    CORS(app)

    # Logging
    logging.basicConfig(
        level=logging.DEBUG if app.config['DEBUG'] else logging.INFO,
        format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        handlers=[
            logging.StreamHandler(),
            logging.FileHandler('logs/app.log'),
        ]
    )

    # Register blueprints
    # from src.routes.example import example_bp
    # app.register_blueprint(example_bp, url_prefix='/api')

    @app.route('/health')
    def health():
        return {'status': 'ok'}

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000)
PYEOF

    # requirements.txt
    cat > "${PROJECT_DIR}/requirements.txt" << 'PYEOF'
flask>=3.0,<4.0
flask-cors>=4.0,<5.0
python-dotenv>=1.0,<2.0
gunicorn>=22.0,<24.0
requests>=2.31,<3.0
PYEOF

    # Dockerfile
    cat > "${PROJECT_DIR}/docker/Dockerfile" << 'PYEOF'
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "src.app:create_app()"]
PYEOF

    # docker-compose.yml
    cat > "${PROJECT_DIR}/docker-compose.yml" << PYEOF
services:
  app:
    build:
      context: .
      dockerfile: docker/Dockerfile
    ports:
      - "5000:5000"
    env_file:
      - .env
    volumes:
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
PYEOF

    # __init__.py files
    touch "${PROJECT_DIR}/src/__init__.py"
    touch "${PROJECT_DIR}/src/routes/__init__.py"
    touch "${PROJECT_DIR}/src/services/__init__.py"
    touch "${PROJECT_DIR}/src/models/__init__.py"
    touch "${PROJECT_DIR}/src/utils/__init__.py"
    touch "${PROJECT_DIR}/tests/__init__.py"

    echo -e "${GREEN}  ✅ Python/Flask files created${NC}"
    echo -e "${YELLOW}  ⚠️  Run 'pip install -r requirements.txt' to install dependencies${NC}"
    ;;

  docker)
    # docker-compose.yml
    cat > "${PROJECT_DIR}/docker-compose.yml" << 'DKEOF'
services:
  # TODO: Define your services
  # service-a:
  #   build:
  #     context: ./services/service-a
  #   ports:
  #     - "5000:5000"
  #   env_file:
  #     - .env
  #   healthcheck:
  #     test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
  #     interval: 30s
  #     timeout: 10s
  #     retries: 3
DKEOF

    echo -e "${GREEN}  ✅ Docker files created${NC}"
    ;;

  minimal)
    echo -e "${GREEN}  ✅ Minimal setup — no framework files needed${NC}"
    ;;
esac

# ============================================================
# Initialize Git
# ============================================================
echo -e "${YELLOW}🔧 Initializing git...${NC}"

cd "${PROJECT_DIR}"
git init --quiet
git checkout -b main --quiet 2>/dev/null || true
git add -A
git commit -m "chore(setup): scaffold project with ai-dev-toolkit" --quiet

git checkout -b develop --quiet

echo -e "${GREEN}  ✅ Git initialized (main + develop branches, on develop)${NC}"

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🎉  Project Created!             ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Location:${NC} ${PROJECT_DIR}"
echo ""
echo -e "${BOLD}What was created:${NC}"
echo "  📄 CLAUDE.md          — Rules for Claude Code"
echo "  📄 STATUS.md          — Project state tracker"
echo "  📄 docs/PRD.md        — Product requirements (template)"
echo "  📄 docs/TECH_SPEC.md  — Technical spec (template)"
echo "  📄 .env.example       — Environment variable template"
echo "  📄 .gitignore         — Standard ignores"
echo "  📄 README.md          — Project readme"
echo "  🪝 .claude/hooks/     — 4 automated safeguard scripts"
echo "  ⚙️  .claude/settings   — Hook triggers + permissions"

case $PROJECT_TYPE in
  nextjs)
    echo "  ⚛️  app/              — Next.js App Router structure"
    echo "  📦 package.json       — Dependencies (run npm install)"
    echo ""
    echo -e "  ${YELLOW}⚠️  The Next.js boilerplate uses baseline config.${NC}"
    echo -e "  ${YELLOW}    After npm install, run 'npm run dev' to verify the app starts.${NC}"
    echo -e "  ${YELLOW}    If Tailwind or Next.js versions conflict, run:${NC}"
    echo -e "  ${YELLOW}      npx @next/codemod upgrade${NC}"
    ;;
  python)
    echo "  🐍 src/              — Flask application structure"
    echo "  🐳 docker/           — Dockerfile + docker-compose"
    echo "  📦 requirements.txt  — Dependencies (run pip install)"
    ;;
  docker)
    echo "  🐳 docker-compose.yml — Multi-service template"
    ;;
esac

echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. cd ${PROJECT_DIR}"

case $PROJECT_TYPE in
  nextjs) echo "  2. npm install" ;;
  python) echo "  2. pip install -r requirements.txt" ;;
esac

echo "  3. Open Claude Code and run:"
echo "     ${CYAN}Read STATUS.md and CLAUDE.md. Let's create the PRD —${NC}"
echo "     ${CYAN}ask me at least 10 questions before writing anything.${NC}"
echo ""
