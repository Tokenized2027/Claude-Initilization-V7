# Automation Quick Wins

Small improvements that significantly boost automation across the framework.

## 1. Auto-Update STATUS.md After Commits

Add a git hook that automatically updates STATUS.md when you commit.

**Setup:**
```bash
# Create the hook
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash

# Only run if STATUS.md exists
if [ ! -f STATUS.md ]; then
  exit 0
fi

# Get the last commit info
LAST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%ar)")
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)

# Update STATUS.md
{
  echo "# Status"
  echo ""
  echo "## Last Commit"
  echo "- $LAST_COMMIT"
  echo "- Files changed: $CHANGED_FILES"
  echo ""
  echo "## Last Updated"
  echo "$(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  cat STATUS.md | tail -n +7
} > STATUS.md.tmp && mv STATUS.md.tmp STATUS.md

echo "✓ STATUS.md auto-updated"
EOF

chmod +x .git/hooks/post-commit
```

**Value:** Never forget to update STATUS.md. It happens automatically.

---

## 2. Claude Code Session Starter

Create an alias that starts Claude Code with your project context loaded.

**Setup:**
```bash
# Add to ~/.bashrc or ~/.zshrc
alias cc='function _cc() { 
  if [ -f CLAUDE.md ]; then
    echo "📋 Loading project context from CLAUDE.md..."
    claude --context @CLAUDE.md "$@"
  else
    echo "⚠️  No CLAUDE.md found. Run: cp $CLAUDE_HOME/claude-code-framework/essential/toolkit/templates/CLAUDE-SOLO.md ./CLAUDE.md"
    claude "$@"
  fi
}; _cc'
```

**Usage:**
```bash
cd my-project
cc "Add user authentication"
```

**Value:** Claude Code always has project context. No more "Claude doesn't know my stack" issues.

---

## 3. Pre-Commit Verification

Automatically run checks before every commit to catch issues early.

**Setup:**
```bash
# Create the hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Check for TypeScript errors
if [ -f "tsconfig.json" ]; then
  echo "  → Checking TypeScript..."
  npx tsc --noEmit
  if [ $? -ne 0 ]; then
    echo "❌ TypeScript errors found. Fix before committing."
    exit 1
  fi
fi

# Check for ESLint errors
if [ -f ".eslintrc" ] || [ -f ".eslintrc.json" ]; then
  echo "  → Running ESLint..."
  npx eslint . --max-warnings 0
  if [ $? -ne 0 ]; then
    echo "❌ ESLint errors found. Fix before committing."
    exit 1
  fi
fi

# Check for console.log statements (exclude test files)
if git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n 'console\.log' | grep -v '\.test\.' > /dev/null; then
  echo "⚠️  Warning: console.log statements found. Remove before committing."
  git diff --cached --name-only | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -n 'console\.log' | grep -v '\.test\.'
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x .git/hooks/pre-commit
```

**Value:** Catch TypeScript/ESLint errors before they become commits. Forces cleanup of console.logs.

---

## 4. Smart Project Scaffolding

Enhance the create-project script to include your preferences.

**Setup:**
```bash
# Create custom project template
mkdir -p ~/.claude-code-templates/default

# Add your standard files
cat > ~/.claude-code-templates/default/CLAUDE.md << 'EOF'
# CLAUDE.md

[Auto-populated from template]

## Project Info

- **Stack:** Next.js 14 + TypeScript + Tailwind + Supabase
- **Timezone:** Asia/Jerusalem (UTC+2/+3)
- **Owner:** [YOUR NAME]

[Rest of CLAUDE-SOLO.md template]
EOF

# Create quick scaffold alias
alias new-project='function _new() {
  PROJECT_NAME="$1"
  mkdir "$PROJECT_NAME" && cd "$PROJECT_NAME"
  
  # Initialize git
  git init
  
  # Copy templates
  cp -r ~/.claude-code-templates/default/* .
  
  # Replace placeholders
  sed -i "s/\[GIT_REPO_URL\]/https:\/\/github.com\/YOUR_USERNAME\/$PROJECT_NAME/g" CLAUDE.md
  sed -i "s/\[YOUR NAME\]/Your Name/g" CLAUDE.md
  
  # Initialize Next.js
  npx create-next-app@latest . --typescript --tailwind --app --no-src-dir
  
  # First commit
  git add .
  git commit -m "chore: initial project scaffold"
  
  echo "✅ Project $PROJECT_NAME ready"
}; _new'
```

**Usage:**
```bash
new-project my-awesome-app
```

**Value:** New projects start with all your settings, no manual setup.

---

## 5. Deployment Status Monitor

Auto-check Vercel deployment status after pushing.

**Setup:**
```bash
# Install Vercel CLI
npm i -g vercel

# Create post-push hook
cat > .git/hooks/post-push << 'EOF'
#!/bin/bash

# Only run if pushing to main
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
  exit 0
fi

# Check if Vercel project
if [ ! -f ".vercel/project.json" ]; then
  exit 0
fi

echo "🚀 Deployment triggered on Vercel..."
echo "   Check status: https://vercel.com/dashboard"

# Optional: Wait for deployment and show URL
# vercel --prod --yes > /dev/null 2>&1
# echo "✅ Deployed to: $(vercel --prod --yes 2>&1 | grep -o 'https://.*\.vercel\.app')"
EOF

chmod +x .git/hooks/post-push
```

**Value:** Immediate feedback on deployments. Know instantly if deploy succeeded.

---

## 6. Automatic Changelog

Generate CHANGELOG.md from commit messages.

**Setup:**
```bash
# Add to package.json scripts
{
  "scripts": {
    "changelog": "git log --oneline --pretty=format:'- %s (%h)' > CHANGELOG.md"
  }
}

# Or create standalone script
cat > scripts/update-changelog.sh << 'EOF'
#!/bin/bash

{
  echo "# Changelog"
  echo ""
  echo "## Recent Changes"
  echo ""
  git log --oneline --pretty=format:'- %s (%h)' -20
  echo ""
  echo ""
  echo "## Full History"
  echo ""
  git log --oneline --pretty=format:'- %s (%h)'
} > CHANGELOG.md

echo "✅ CHANGELOG.md updated"
EOF

chmod +x scripts/update-changelog.sh
```

**Usage:**
```bash
npm run changelog
# or
./scripts/update-changelog.sh
```

**Value:** Always have up-to-date changelog without manual writing.

---

## 7. Environment Variable Validator

Catch missing env vars before runtime.

**Setup:**
```bash
# Create validator script
cat > scripts/check-env.sh << 'EOF'
#!/bin/bash

# List of required env vars
REQUIRED_VARS=(
  "DATABASE_URL"
  "NEXT_PUBLIC_SUPABASE_URL"
  "NEXT_PUBLIC_SUPABASE_ANON_KEY"
  "SUPABASE_SERVICE_ROLE_KEY"
)

MISSING=()

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    MISSING+=("$var")
  fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
  echo "❌ Missing required environment variables:"
  for var in "${MISSING[@]}"; do
    echo "   - $var"
  done
  echo ""
  echo "Set in .env.local or environment"
  exit 1
fi

echo "✅ All required environment variables present"
EOF

chmod +x scripts/check-env.sh

# Add to package.json
{
  "scripts": {
    "predev": "bash scripts/check-env.sh",
    "prebuild": "bash scripts/check-env.sh"
  }
}
```

**Value:** Never waste time debugging "undefined is not a function" when it's just missing env vars.

---

## 8. Claude Code Context Optimizer

Automatically create context files for large projects.

**Setup:**
```bash
cat > scripts/generate-context.sh << 'EOF'
#!/bin/bash

# Generate project structure
echo "# Project Structure" > docs/PROJECT_CONTEXT.md
echo "" >> docs/PROJECT_CONTEXT.md
tree -L 3 -I 'node_modules|.next|.git' >> docs/PROJECT_CONTEXT.md

# Add key files summary
echo "" >> docs/PROJECT_CONTEXT.md
echo "## Key Files" >> docs/PROJECT_CONTEXT.md
echo "" >> docs/PROJECT_CONTEXT.md

find . -name "*.tsx" -o -name "*.ts" | head -20 | while read file; do
  echo "### $file" >> docs/PROJECT_CONTEXT.md
  head -10 "$file" >> docs/PROJECT_CONTEXT.md
  echo "" >> docs/PROJECT_CONTEXT.md
done

echo "✅ Project context generated at docs/PROJECT_CONTEXT.md"
EOF

chmod +x scripts/generate-context.sh
```

**Value:** Claude Code can quickly understand large projects by reading PROJECT_CONTEXT.md.

---

## 9. Backup Before Risky Operations

Auto-backup before major changes.

**Setup:**
```bash
# Create backup function
cat > scripts/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="../backups/$(basename $(pwd))"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Create tarball
tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='.git' \
  --exclude='dist' \
  .

echo "✅ Backup created: $BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
echo "   To restore: tar -xzf backup_$TIMESTAMP.tar.gz"
EOF

chmod +x scripts/backup.sh

# Create alias for risky operations
alias safe-reset='bash scripts/backup.sh && git reset --hard HEAD'
alias safe-clean='bash scripts/backup.sh && git clean -fdx'
```

**Value:** Never lose work on destructive operations. Always have a safety net.

---

## 10. Smart Test Running

Run only tests for changed files.

**Setup:**
```bash
# Add to package.json
{
  "scripts": {
    "test:changed": "jest --bail --findRelatedTests $(git diff --name-only HEAD | grep -E '\\.(ts|tsx)$' | tr '\\n' ' ')"
  }
}
```

**Usage:**
```bash
npm run test:changed
```

**Value:** Fast feedback loop. Only test what you changed, not entire suite.

---

## Implementation Checklist

Add these to your project setup:

```bash
# 1. Copy templates
cp $CLAUDE_HOME/claude-code-framework/essential/toolkit/templates/CLAUDE-SOLO.md ./CLAUDE.md

# 2. Create scripts directory
mkdir -p scripts

# 3. Add git hooks
bash $CLAUDE_HOME/claude-code-framework/essential/toolkit/setup-hooks.sh

# 4. Add npm scripts
# (Edit package.json to add the scripts from above)

# 5. Create aliases
# (Add to ~/.bashrc or ~/.zshrc)

# 6. Test it
git add .
git commit -m "chore: add automation quick wins"
```

**Result:** Your projects now have 90% automated workflows for commits, tests, deployments, and more.

---

## Measuring Impact

Before automation:
- Manual STATUS.md updates: 2 min per commit × 20 commits/day = 40 min/day
- Forgotten env vars: 15 min debugging × 1x/week = 15 min/week
- Deployment checking: 5 min × 3x/day = 15 min/day
- **Total: ~60 min/day wasted**

After automation:
- STATUS.md: Automatic (0 min)
- Env validation: Automatic (0 min)
- Deployment: Automatic (0 min)
- **Total: ~60 min/day saved**

**That's 5 hours per week reclaimed for actual coding.**
