# Git for Vibe Coders

A practical, no-theory guide to the 10 git commands you actually need for daily work with Claude Code. If something goes wrong, there's a fix here.

---

## Table of Contents

1. [The 10 Essential Commands](#the-10-essential-commands)
2. [Daily Workflow](#daily-workflow)
3. [Feature Branch Workflow](#feature-branch-workflow)
4. [When Things Go Wrong](#when-things-go-wrong)
5. [Emergency Recovery](#emergency-recovery)

---

## The 10 Essential Commands

### 1. `git status`
**What it does:** Shows what's changed, what's staged, what branch you're on.

**When to use:** All the time. Before committing, after making changes, when confused.

```bash
git status
```

**Output example:**
```
On branch feature/login
Changes not staged for commit:
  modified:   src/Login.tsx
  
Untracked files:
  src/api.ts
```

---

### 2. `git add <file>` or `git add .`
**What it does:** Stages changes for commit.

**When to use:** After making changes, before committing.

```bash
# Stage a specific file
git add src/Login.tsx

# Stage all changes
git add .
```

**Tip:** Use `git add .` most of the time unless you want to commit files separately.

---

### 3. `git commit -m "message"`
**What it does:** Saves your staged changes with a message.

**When to use:** After staging changes with `git add`.

```bash
git commit -m "feat: add login form with validation"
```

**Good commit messages:**
- `feat: add user authentication`
- `fix: resolve login button not clickable`
- `refactor: extract API client to separate file`
- `docs: update README with setup instructions`

**Bad commit messages:**
- `update` (what was updated?)
- `fix bug` (which bug?)
- `wip` (work in progress is fine for local branches, but be more specific)

---

### 4. `git push`
**What it does:** Uploads your commits to GitHub/remote.

**When to use:** After committing, when you want to back up work or share with others.

```bash
# First time pushing a new branch
git push -u origin feature/login

# After that, just:
git push
```

**If it fails:** Someone else pushed changes. See "When Things Go Wrong" below.

---

### 5. `git checkout -b <branch-name>`
**What it does:** Creates a new branch and switches to it.

**When to use:** Starting a new feature or bug fix.

```bash
# Create and switch to new branch
git checkout -b feature/user-profile

# Now you're on feature/user-profile branch
# Make changes, commit, push
```

**Branch naming conventions:**
- `feature/description` - for new features
- `fix/description` - for bug fixes
- `refactor/description` - for code cleanup
- `docs/description` - for documentation

Examples:
- `feature/login-form`
- `fix/button-alignment`
- `refactor/extract-api-client`

---

### 6. `git checkout <branch-name>`
**What it does:** Switches to an existing branch.

**When to use:** Switching between branches, going back to main.

```bash
# Switch to main branch
git checkout main

# Switch to existing feature branch
git checkout feature/login
```

**Warning:** Commit or stash changes before switching branches, or they'll be lost.

---

### 7. `git merge <branch-name>`
**What it does:** Combines another branch into your current branch.

**When to use:** Merging a feature branch into main after work is done.

```bash
# Switch to main first
git checkout main

# Then merge your feature branch
git merge feature/login
```

**If there are conflicts:** See "Merge Conflicts" below.

---

### 8. `git stash`
**What it does:** Temporarily saves your uncommitted changes and reverts files to last commit.

**When to use:** Need to switch branches but aren't ready to commit, or need to try something without losing current work.

```bash
# Save current work
git stash

# Do other stuff (switch branches, pull updates, etc.)

# Restore your work
git stash pop
```

**Bonus:**
```bash
# List all stashes
git stash list

# Apply specific stash without removing it
git stash apply stash@{0}

# Clear all stashes
git stash clear
```

---

### 9. `git reset --soft HEAD~1`
**What it does:** Undoes last commit but keeps the changes staged.

**When to use:** Accidentally committed too early, want to add more changes to the commit, or made a typo in commit message.

```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Now you can:
# - Fix the changes
# - Add more files
# - Commit again with better message
```

**More reset options:**
```bash
# Undo last commit, keep changes unstaged
git reset HEAD~1

# Undo last commit, discard all changes (DANGEROUS!)
git reset --hard HEAD~1
```

---

### 10. `git log`
**What it does:** Shows commit history.

**When to use:** See what's been done, find a commit hash, review history.

```bash
# Show commit history (press 'q' to exit)
git log

# Show last 5 commits, one line each
git log --oneline -5

# Show commits with file changes
git log --stat
```

**Output example:**
```
commit a1b2c3d (HEAD -> feature/login)
Author: You <you@example.com>
Date:   Mon Feb 11 10:30:00 2025

    feat: add login form validation
```

---

## Daily Workflow

This is what most vibe coders should do every day:

### Morning: Start New Feature

```bash
# Make sure you're on main and it's up to date
git checkout main
git pull

# Create feature branch
git checkout -b feature/new-thing

# Work with Claude Code, make changes

# When ready to commit
git add .
git commit -m "feat: describe what you built"

# Push to GitHub
git push -u origin feature/new-thing
```

---

### During Day: Keep Committing

```bash
# After each small unit of work
git add .
git commit -m "feat: add specific feature"
git push

# Continue working
# Make more changes

# Commit again
git add .
git commit -m "fix: resolve bug in feature"
git push
```

**Key principle:** Commit often. Every working state should be committed.

---

### End of Day: Merge if Done

```bash
# Switch to main
git checkout main

# Merge your feature
git merge feature/new-thing

# Push to GitHub
git push

# Delete feature branch (optional, keeps repo clean)
git branch -d feature/new-thing
```

---

## Feature Branch Workflow

This is the standard way to work on features without breaking main branch.

### Step 1: Create Feature Branch
```bash
git checkout main
git pull
git checkout -b feature/user-auth
```

### Step 2: Work and Commit
```bash
# Make changes
# Commit frequently
git add .
git commit -m "feat: add login endpoint"

git add .
git commit -m "feat: add register endpoint"

git add .
git commit -m "test: add auth tests"
```

### Step 3: Push to Remote
```bash
git push -u origin feature/user-auth
```

### Step 4: Merge When Done
```bash
# Switch to main
git checkout main

# Make sure main is up to date
git pull

# Merge your feature
git merge feature/user-auth

# Push merged code
git push

# Delete feature branch (optional)
git branch -d feature/user-auth
```

---

## When Things Go Wrong

### Problem 1: "I Committed to Main by Accident"

The compliance hook should prevent this, but if it happens:

```bash
# Move the commit to a new branch
git branch feature/accidental-work
git reset --hard HEAD~1

# Now switch to the new branch
git checkout feature/accidental-work

# Your work is safe, you can continue or merge properly
```

---

### Problem 2: "I Need to Switch Branches but Have Uncommitted Changes"

**Option A: Commit the changes**
```bash
git add .
git commit -m "wip: partial work on feature"
git checkout other-branch
```

**Option B: Stash the changes**
```bash
git stash
git checkout other-branch

# When you come back
git checkout original-branch
git stash pop
```

---

### Problem 3: "Claude Code Changed the Wrong File"

**Undo changes to specific file:**
```bash
# Discard changes to one file
git checkout -- path/to/wrong-file.ts

# Or restore to last committed version
git restore path/to/wrong-file.ts
```

**Undo ALL uncommitted changes (DANGER - can't undo this):**
```bash
git checkout .
# or
git reset --hard HEAD
```

---

### Problem 4: "Merge Conflicts"

This happens when you and someone else changed the same file.

**Symptoms:**
```bash
git merge feature/login
# Output:
Auto-merging src/Login.tsx
CONFLICT (content): Merge conflict in src/Login.tsx
Automatic merge failed; fix conflicts and then commit the result.
```

**How to fix:**

1. **Open the conflicted file** - Git marked conflicts like this:
```typescript
<<<<<<< HEAD
// Code from main branch
const currentCode = "original";
=======
// Code from your branch
const currentCode = "your changes";
>>>>>>> feature/login
```

2. **Choose which version to keep:**
   - Delete the markers (`<<<<<<<`, `=======`, `>>>>>>>`)
   - Keep one version or combine both
   - Save the file

3. **Commit the resolution:**
```bash
git add src/Login.tsx
git commit -m "merge: resolve conflicts in Login.tsx"
```

**If conflicts are too complex:**
```bash
# Abort the merge, start over
git merge --abort

# Then figure out a better approach (rebase, or ask for help)
```

---

### Problem 5: "Git Push Failed - Remote Has Changes"

**Error:**
```
! [rejected]        main -> main (fetch first)
error: failed to push some refs
```

**Solution:**
```bash
# Pull remote changes first
git pull

# If no conflicts, this will merge automatically
# Then push again
git push

# If there are conflicts, resolve them (see Problem 4)
```

---

### Problem 6: "I Want to Undo My Last Commit"

**If you haven't pushed yet:**
```bash
# Undo commit, keep changes
git reset --soft HEAD~1

# Now fix and recommit
git add .
git commit -m "better commit message"
```

**If you already pushed:**
```bash
# Create a new commit that undoes the last one
git revert HEAD

# This creates a new "revert" commit
git push
```

---

## Emergency Recovery

### "I Deleted Code I Need"

**If you committed it:**
```bash
# Find the commit where code existed
git log --all --oneline | grep "description"

# Checkout that specific file from that commit
git checkout <commit-hash> -- path/to/file.ts
```

**If you didn't commit:**
Sorry, it's gone. This is why you commit frequently.

---

### "I Want to Go Back to How Things Were Yesterday"

```bash
# See recent commits
git log --oneline -10

# Go back to a specific commit (DANGER - discards everything after)
git reset --hard <commit-hash>

# If you already pushed, you'll need force push (DANGEROUS)
git push --force
```

**Safer option:**
```bash
# Create a new branch at that point in time
git checkout -b recovery-branch <commit-hash>

# Now you can work from that state without losing current main
```

---

### "Everything is Broken, Start Over"

**Nuclear option - revert to last good commit:**
```bash
# Discard ALL uncommitted changes
git reset --hard HEAD

# Go back one commit
git reset --hard HEAD~1

# Go back to specific commit
git reset --hard <commit-hash>
```

**Warning:** This **permanently deletes** uncommitted work. Use stash first if unsure:
```bash
git stash  # saves your work
git reset --hard HEAD  # now safe to reset
# If you need your work back: git stash pop
```

---

## Quick Reference Card

**Print this and put it next to your desk:**

```
━━━━ DAILY WORKFLOW ━━━━
git status              Check what changed
git checkout -b name    New feature branch
git add .               Stage all changes
git commit -m "msg"     Save changes
git push                Upload to remote

━━━━ UNDO COMMANDS ━━━━
git stash               Temporarily save work
git stash pop           Restore saved work
git checkout -- file    Undo changes to file
git reset --soft HEAD~1 Undo last commit (keep changes)
git reset --hard HEAD   Discard ALL changes (DANGER)

━━━━ BRANCHING ━━━━
git checkout main       Switch to main
git pull                Get latest changes
git merge branch-name   Merge branch into current
git branch -d name      Delete branch

━━━━ WHEN STUCK ━━━━
git status              What's going on?
git log --oneline -5    Recent commits
git merge --abort       Cancel merge
git reset --hard HEAD   Start over (DANGER)
```

---

## Remember

1. **Commit frequently** - Every working state should be saved
2. **Work on branches** - Never commit directly to main
3. **Use the compliance hook** - It prevents most mistakes
4. **When in doubt, stash** - `git stash` is your safety net
5. **Read error messages** - Git tells you what's wrong and how to fix it
6. **Can't break Git** - You can always reset, revert, or start over

**If you mess up:** It's okay. Everyone does. That's why we have version control.
