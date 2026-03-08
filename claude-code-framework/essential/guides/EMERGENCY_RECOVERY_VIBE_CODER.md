# Emergency Recovery — Vibe Coder Edition

When Claude Code has made 47 changes and everything is broken, this is your nuclear option guide. No theory, just commands to get back to a working state.

---

## Table of Contents

1. [The Nuclear Option (Start Here)](#the-nuclear-option-start-here)
2. [Undo Uncommitted Changes](#undo-uncommitted-changes)
3. [Undo Last Commit](#undo-last-commit)
4. [Recover Deleted Files](#recover-deleted-files)
5. [Fix Docker Issues](#fix-docker-issues)
6. [Reset Database](#reset-database)
7. [Kill Stuck Processes](#kill-stuck-processes)
8. [Disaster Recovery Scenarios](#disaster-recovery-scenarios)
9. [Prevention: Never Get Here Again](#prevention-never-get-here-again)

---

## The Nuclear Option (Start Here)

### 🚨 Everything is broken and I need to go back NOW

**Step 1: Stop Claude Code**
- Close the terminal/Claude Code session
- This prevents more damage

**Step 2: Check git log**
```bash
git log --oneline -20
```
Look for the last commit where things worked. Note the commit hash (first 7 characters).

**Step 3: Reset to working state**
```bash
# Save any uncommitted work you want to keep (optional)
git stash

# Reset everything to the last working commit
git reset --hard abc123  # Replace abc123 with your commit hash

# Verify it worked
git status  # Should say "working tree clean"
npm run dev  # Try running the app
```

**Step 4: Verify recovery**
```bash
# Test the app
npm run dev

# If it works: You're recovered!
# If it doesn't: See "Last Resort" section below
```

---

## Undo Uncommitted Changes

### Scenario: Claude made changes but hasn't committed yet

**Undo ALL uncommitted changes (safe version):**
```bash
# 1. Save your work first (just in case)
git stash

# 2. Check what you stashed
git stash list

# 3. Reset to clean state
git reset --hard HEAD

# 4. Verify
git status  # Should say "working tree clean"

# 5. If you need something back:
git stash pop
```

**Undo changes to ONE specific file:**
```bash
# Check which files changed
git status

# Restore just one file
git checkout -- path/to/file.ts

# Verify
git status
```

**Undo ALL changes (no safety net):**
```bash
# ⚠️ DANGER: This cannot be undone
git reset --hard HEAD
git clean -fdx  # Also removes untracked files
```

---

## Undo Last Commit

### Scenario: Claude just committed something broken

**Keep the changes, undo the commit:**
```bash
# Undo commit, keep changes staged
git reset --soft HEAD~1

# Now you can fix and recommit
git commit -m "Fixed version"
```

**Keep changes but unstaged:**
```bash
# Undo commit, changes become unstaged
git reset HEAD~1

# Review changes
git diff

# Fix what's broken, then commit
git add .
git commit -m "Fixed version"
```

**Discard the commit and all changes:**
```bash
# ⚠️ DANGER: Deletes your work
git reset --hard HEAD~1
```

**Undo last 3 commits (keep changes):**
```bash
git reset HEAD~3

# Changes are now unstaged
# Fix them, then commit
```

**Commit was already pushed:**
```bash
# Create a reverse commit (safer than force push)
git revert HEAD
git push

# Or force push (only if you're alone on the branch)
git reset --hard HEAD~1
git push --force origin branch-name
```

---

## Recover Deleted Files

### File deleted but NOT committed

```bash
# Restore one file
git checkout -- path/to/deleted-file.ts

# Or with newer git
git restore path/to/deleted-file.ts

# Verify
ls path/to/deleted-file.ts
```

### File deleted AND committed

```bash
# Step 1: Find when it was deleted
git log --all --full-history -- path/to/file.ts

# Output shows commits that touched this file
# Note the commit hash where it still existed

# Step 2: Restore from before deletion
git checkout abc123~1 -- path/to/file.ts

# Step 3: Commit the recovery
git add path/to/file.ts
git commit -m "Recover deleted file"
```

### Can't remember the filename

```bash
# See all deleted files in recent commits
git log --diff-filter=D --summary | grep delete

# Or search for a pattern
git log --all --diff-filter=D --summary | grep "components"
```

---

## Fix Docker Issues

### Container won't start

```bash
# 1. Stop everything
docker compose down

# 2. Remove volumes (⚠️ loses database data)
docker compose down -v

# 3. Rebuild from scratch
docker compose up -d --build

# 4. Check logs
docker compose logs -f
```

### Port already in use

```bash
# Find what's using the port (example: 3000)
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or kill Docker process
docker compose down

# Restart
docker compose up -d
```

### "No space left on device"

```bash
# Clean up Docker (frees space)
docker system prune -a --volumes

# Confirm: This removes:
# - Stopped containers
# - Unused networks  
# - Dangling images
# - Build cache
# - Volumes

# Then rebuild
docker compose up -d --build
```

### Container keeps restarting

```bash
# Check logs to see why
docker compose logs -f service-name

# Stop the problematic service
docker compose stop service-name

# Remove and recreate
docker compose rm service-name
docker compose up -d service-name
```

### Database connection failed

```bash
# Check if database is running
docker compose ps

# Restart database
docker compose restart db

# View logs
docker compose logs db

# Connect manually to verify
docker compose exec db psql -U postgres -d dbname
```

---

## Reset Database

### PostgreSQL (Docker)

```bash
# Drop and recreate database
docker compose exec db psql -U postgres -c "DROP DATABASE dbname;"
docker compose exec db psql -U postgres -c "CREATE DATABASE dbname;"

# Run migrations
docker compose exec api npx prisma migrate deploy

# Or for Flask/SQLAlchemy:
docker compose exec api flask db upgrade
```

### SQLite

```bash
# Delete database file
rm database.db

# Run migrations
npx prisma migrate deploy
# or
python manage.py migrate
```

### Reset with seed data

```bash
# Full reset: drop, create, migrate, seed
docker compose exec db psql -U postgres -c "DROP DATABASE dbname;"
docker compose exec db psql -U postgres -c "CREATE DATABASE dbname;"
docker compose exec api npx prisma migrate deploy
docker compose exec api npx prisma db seed
```

---

## Kill Stuck Processes

### Kill by port

```bash
# Find process on port 3000
lsof -i :3000

# Kill it
kill -9 <PID>

# One-liner
kill -9 $(lsof -t -i:3000)
```

### Kill by name

```bash
# Find Node processes
ps aux | grep node

# Kill all Node
pkill node

# Force kill
pkill -9 node
```

### Kill all containers

```bash
# Stop all running containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -a -q)
```

---

## Disaster Recovery Scenarios

### Scenario 1: Claude Broke Everything in One Session

**You'll know this happened when:**
- Claude made 20+ file changes
- App no longer runs
- Multiple errors you don't understand
- Can't remember what worked before

**Recovery:**
```bash
# 1. STOP CLAUDE CODE (important!)

# 2. Check recent commits
git log --oneline -10

# 3. Find last working commit (look for your own commit messages)
# Let's say it's commit "abc123"

# 4. Save Claude's work (optional)
git stash

# 5. Reset to working state
git reset --hard abc123

# 6. Verify it works
npm run dev

# 7. Start fresh conversation with Claude
# Tell it: "Start from the current working state"
```

---

### Scenario 2: Deployed to Vercel, Now Production is Broken

**Recovery:**
```bash
# Option A: Rollback in Vercel UI
# 1. Go to Vercel dashboard
# 2. Click "Deployments"
# 3. Find previous working deployment
# 4. Click "..." → "Promote to Production"

# Option B: Git reset and redeploy
# 1. Reset locally
git reset --hard abc123  # Last working commit
git push --force origin main

# 2. Vercel auto-deploys from main
# 3. Wait 2 minutes for new deployment

# Option C: Revert commit
git revert HEAD
git push origin main
# Vercel auto-deploys the revert
```

---

### Scenario 3: Database Corrupted or Schema Broken

**Recovery:**
```bash
# WARNING: This deletes all data

# 1. Backup current data (if possible)
docker compose exec db pg_dump -U postgres dbname > backup.sql

# 2. Drop and recreate
docker compose exec db psql -U postgres -c "DROP DATABASE dbname;"
docker compose exec db psql -U postgres -c "CREATE DATABASE dbname;"

# 3. Reset migration history
rm -rf prisma/migrations  # Or wherever migrations live

# 4. Create fresh migration
npx prisma migrate dev --name init

# 5. Seed data
npx prisma db seed
```

---

### Scenario 4: Git History is a Mess

**Recovery:**
```bash
# Option A: Squash recent commits
git reset --soft HEAD~5  # Last 5 commits
git commit -m "Consolidated changes"

# Option B: Start fresh branch from working commit
git checkout -b fresh-start abc123
git branch -D main
git checkout -b main
git push --force origin main

# Option C: Nuclear - rewrite history
git checkout abc123  # Last working commit
git branch -D main
git checkout -b main
git push --force origin main
```

---

### Scenario 5: Lost Code You Need Back

**Recovery:**
```bash
# Git keeps everything for ~90 days in reflog

# 1. View all recent HEAD positions
git reflog

# Output looks like:
# abc123 HEAD@{0}: reset: moving to abc123
# def456 HEAD@{1}: commit: Added feature X
# ghi789 HEAD@{2}: commit: Fixed bug Y

# 2. Find the commit with your code
# Let's say it's def456

# 3. Restore that commit
git checkout def456

# 4. Create a branch to save it
git checkout -b recover-lost-work

# 5. Now you can merge or cherry-pick changes
```

---

## Prevention: Never Get Here Again

### 1. Commit Frequently (Every Working State)

```bash
# After every small unit of work that compiles:
git add .
git commit -m "feat(component): add header - WORKS"

# Tag working states clearly
git commit -m "WORKING STATE - before refactor"
```

**Why:** You can always `git reset --hard` to any commit. More commits = more restore points.

---

### 2. Use Feature Branches (Protect Main)

```bash
# Never work on main
git checkout -b feature/add-login

# Do work, commit often
git add .
git commit -m "feat(auth): add login form"

# Push to remote
git push origin feature/add-login

# Merge only when working
# (via PR on GitHub, or locally:)
git checkout main
git merge feature/add-login
git push origin main
```

**Why:** If feature branch breaks, main is still safe.

---

### 3. Test Before Committing

```bash
# Before committing:
# 1. Run the app
npm run dev

# 2. Test the feature
# Click around, make sure it works

# 3. Run build (catches TypeScript errors)
npm run build

# 4. Only then commit
git add .
git commit -m "feat(dashboard): add charts - TESTED"
```

---

### 4. Keep STATUS.md Updated

Create a `STATUS.md` file in your project:

```markdown
# Status

## Last Known Working State
- Commit: abc123
- Date: 2025-02-11
- Features: Auth, dashboard, API working
- Deploy: https://project.vercel.app

## Current Work
- Adding whale alerts
- Modified: components/Dashboard.tsx, api/alerts.ts
- Status: In progress, not yet working

## Issues
- Whale alert sorting broken
- Need to fix API response format
```

**Why:** When things break, you know exactly where you were.

---

### 5. One Feature at a Time

```bash
# ❌ BAD: Claude changes 20 files at once
# Hard to review, hard to debug, hard to revert

# ✅ GOOD: One feature, one commit
git commit -m "feat(alerts): add whale alert component"
# Test, verify works
git commit -m "feat(alerts): add sorting to whale alerts"
# Test, verify works
git commit -m "feat(alerts): connect to API endpoint"
```

---

### 6. Push to Remote Often

```bash
# After every working commit:
git push origin feature/branch-name

# Or if on main:
git push origin main
```

**Why:** If your computer dies, code is safe on GitHub.

---

### 7. Use Stash Before Experiments

```bash
# Before trying something risky:
git stash

# Try the risky thing
# If it breaks:
git reset --hard HEAD
git stash pop

# If it works:
git add .
git commit -m "feat: risky feature - WORKS"
```

---

## Last Resort: Complete Project Reset

**When:** Everything is so broken you want to start over.

### Option 1: Reset to Specific Commit

```bash
# 1. Find a known good commit
git log --oneline -20

# 2. Reset to it (⚠️ DANGER: loses all work after)
git reset --hard abc123

# 3. Verify
npm run dev
```

### Option 2: Delete and Re-clone

```bash
# 1. Make sure code is pushed to GitHub
git log --oneline -5
git push origin main

# 2. Go up one directory
cd ..

# 3. Delete project (⚠️ DANGER)
rm -rf project-name

# 4. Re-clone
git clone https://github.com/username/project-name.git
cd project-name

# 5. Reinstall
npm install

# 6. Run
npm run dev
```

### Option 3: Nuke Everything (Docker + Code)

```bash
# ⚠️ NUCLEAR OPTION - Only use if completely stuck

# 1. Stop all Docker
docker compose down -v
docker system prune -a --volumes -f

# 2. Reset git
git reset --hard HEAD
git clean -fdx

# 3. Delete dependencies
rm -rf node_modules package-lock.json

# 4. Reinstall
npm install

# 5. Rebuild Docker
docker compose up -d --build

# 6. Test
npm run dev
```

---

## Quick Decision Tree

```
Claude broke something:
├─ Not committed yet?
│  └─ git reset --hard HEAD
├─ Just committed?
│  └─ git reset --hard HEAD~1
├─ Already pushed?
│  └─ git revert HEAD && git push
├─ Docker broken?
│  └─ docker compose down && up -d
├─ Port in use?
│  └─ kill -9 $(lsof -t -i:PORT)
├─ Database broken?
│  └─ DROP DATABASE; CREATE DATABASE; migrate
├─ Everything broken?
│  └─ git reset --hard abc123 (last working commit)
└─ Still broken?
   └─ Delete project, re-clone from GitHub
```

---

## Emergency Reference Card (Print This)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           VIBE CODER EMERGENCY CARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STOP CLAUDE:
  Close terminal/Claude Code session

UNDO UNCOMMITTED:
  git stash              Save work
  git reset --hard HEAD  Discard all

UNDO LAST COMMIT:
  git reset HEAD~1       Keep changes
  git reset --hard HEAD~1 Discard changes

GO BACK TO WORKING STATE:
  git log --oneline -20
  git reset --hard abc123

DOCKER BROKEN:
  docker compose down
  docker compose up -d --build

PORT IN USE:
  kill -9 $(lsof -t -i:PORT)

DATABASE BROKEN:
  docker compose exec db psql -U postgres
  DROP DATABASE dbname; CREATE DATABASE dbname;
  npx prisma migrate deploy

NUCLEAR OPTION:
  git reset --hard abc123  (last working commit)
  
LAST RESORT:
  rm -rf project && git clone URL

RECOVERY:
  git reflog               See all history
  git reset --hard abc123  Restore old commit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REMEMBER:
✓ Commit after every working state
✓ Push to GitHub often  
✓ Test before committing
✓ One feature at a time
✓ Git is a time machine - you can always go back

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## When to Ask for Help

If you've tried:
1. `git reset --hard` to last working commit
2. Deleted and re-cloned the project
3. Rebuilt Docker from scratch
4. Cleared all caches

**And it still doesn't work:**

The problem is not in git or Docker. It's likely:
- Environment variables missing
- External service down (database, API)
- System-level issue (permissions, network)

At this point, start a fresh Claude conversation with:
- Link to your GitHub repo
- The specific error message
- What you've already tried
- Your system info (OS, Node version, etc.)

**Remember:** As long as you pushed to GitHub, your code is safe. Everything else can be recovered or rebuilt.
