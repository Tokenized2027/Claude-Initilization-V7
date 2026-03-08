
# Git Recovery

Quickly fix common git mistakes and recover lost work.

## Instructions

### Step 1: Identify What Went Wrong

**Common git mistakes:**
- Committed to wrong branch (committed to main instead of feature branch)
- Want to undo last commit(s)
- Accidentally deleted a file
- Merge conflict
- Detached HEAD state
- Pushed something that shouldn't have been pushed
- Lost changes after bad merge/rebase

### Step 2: Apply the Appropriate Fix

#### Undo Last Commit (Keep Changes)

**Most common scenario:** "I just committed but forgot to add a file"

```bash
# Undo commit, keep changes staged
git reset --soft HEAD~1

# Now add the forgotten file
git add forgotten-file.txt

# Commit again
git commit -m "Your message"
```

**Keep changes unstaged:**
```bash
# Undo commit, keep changes but unstaged
git reset HEAD~1

# Now you can modify files before committing again
```

---

#### Undo Last Commit (Discard Changes)

**Warning:** This deletes your work. Only use if you're sure.

```bash
# Undo commit and delete all changes
git reset --hard HEAD~1
```

**Undo last 3 commits:**
```bash
git reset --hard HEAD~3
```

**If you regret this:**
```bash
# Find your commit in reflog
git reflog

# Recover it (find the commit hash from reflog)
git reset --hard [COMMIT_HASH]
```

---

#### Recover Deleted File

**File deleted but NOT committed:**
```bash
# Recover one file
git checkout -- path/to/deleted-file.txt

# Or with newer git:
git restore path/to/deleted-file.txt
```

**File deleted AND committed:**
```bash
# Find when it was deleted
git log --all --full-history -- path/to/file.txt

# Restore from commit before deletion
git checkout [COMMIT_HASH]~1 -- path/to/file.txt

# Now commit the recovered file
git add path/to/file.txt
git commit -m "Recover deleted file"
```

**Can't remember the filename:**
```bash
# Search for deleted files
git log --diff-filter=D --summary | grep delete

# Or see all deleted files in last 10 commits
git log --diff-filter=D --name-only --pretty=format: HEAD~10..HEAD
```

---

#### Fix: Committed to Wrong Branch

**Scenario:** You committed to `main` but should have committed to `feature/login`

**If you haven't pushed yet:**
```bash
# 1. Note your commit hash
git log -1
# Copy the commit hash

# 2. Undo the commit on main (keep changes)
git reset --soft HEAD~1

# 3. Switch to correct branch (create if needed)
git checkout -b feature/login

# 4. Commit there
git commit -m "Your commit message"

# 5. Go back to main
git checkout main
```

**If you already pushed to main:**
```bash
# This is trickier - you need to revert on main

# 1. Create the feature branch from current main
git checkout -b feature/login

# 2. Go back to main
git checkout main

# 3. Revert the commit (this creates a new "undo" commit)
git revert HEAD
git push
```

---

#### Resolve Merge Conflicts

**When you see:**
```
CONFLICT (content): Merge conflict in src/App.tsx
Automatic merge failed; fix conflicts and then commit the result.
```

**Fix process:**
```bash
# 1. See which files have conflicts
git status

# 2. Open the conflicted file
# Look for conflict markers:
# <<<<<<< HEAD
# Your changes
# =======
# Their changes
# >>>>>>> branch-name

# 3. Edit the file, choose which changes to keep
# Remove the <<<<<<< ======= >>>>>>> markers

# 4. Mark as resolved
git add path/to/resolved-file.txt

# 5. Complete the merge
git commit
```

**Abort a merge:**
```bash
# If you want to start over
git merge --abort
```

**Accept "theirs" for all conflicts:**
```bash
git checkout --theirs .
git add .
git commit
```

**Accept "ours" for all conflicts:**
```bash
git checkout --ours .
git add .
git commit
```

---

#### Fix Detached HEAD

**You'll see:** `HEAD detached at [commit]`

**What happened:** You checked out a specific commit instead of a branch.

**Fix:**
```bash
# Option 1: Create a branch from here
git checkout -b new-branch-name

# Option 2: Go back to a branch
git checkout main

# If you made commits in detached HEAD:
# 1. Note the commit hash
git log -1
# 2. Go to your branch
git checkout main
# 3. Cherry-pick those commits
git cherry-pick [COMMIT_HASH]
```

---

#### Undo a Push (Rewrite History)

**Warning:** Only do this if you're the only one using the branch.

```bash
# Undo last commit locally
git reset --hard HEAD~1

# Force push to remote
git push --force origin [BRANCH_NAME]
```

**Safer alternative (doesn't rewrite history):**
```bash
# Create a "reverse" commit
git revert HEAD
git push
```

---

#### Recover Lost Commits

**Scenario:** You did `git reset --hard` and lost work.

```bash
# 1. View reflog (shows all HEAD movements)
git reflog

# Output looks like:
# a1b2c3d HEAD@{0}: reset: moving to HEAD~1
# e4f5g6h HEAD@{1}: commit: Add feature
# i7j8k9l HEAD@{2}: commit: Fix bug

# 2. Find the commit you want to recover
# 3. Reset to that commit
git reset --hard e4f5g6h
```

**Reflog is your time machine** - it keeps commits for ~90 days.

---

#### Unstage Files

**You added files you don't want to commit:**
```bash
# Unstage one file
git reset HEAD path/to/file.txt

# Unstage all files
git reset HEAD
```

---

#### Discard All Local Changes

**Start over from last commit:**
```bash
# Discard all uncommitted changes
git reset --hard HEAD

# Also delete untracked files
git clean -fd
```

---

## Common Scenarios

### Scenario 1: "I committed to main by mistake"

**User says:** "I just committed to main but I should have created a feature branch"

**Response:**
```bash
# 1. Create the feature branch (keeps your commit)
git checkout -b feature/my-work

# 2. Go back to main
git checkout main

# 3. Reset main to before your commit
git reset --hard origin/main

# 4. Go back to your feature branch
git checkout feature/my-work

# Your commit is now on feature/my-work, main is clean
```

---

### Scenario 2: "I want to undo my last commit"

**User says:** "I need to undo my last commit but keep the changes"

**Response:**
```bash
# Undo commit, keep changes staged
git reset --soft HEAD~1

# Now modify files if needed, then commit again
git commit -m "Fixed commit message"
```

---

### Scenario 3: "I accidentally deleted a file"

**User says:** "I deleted src/components/Header.tsx by accident and need it back"

**If NOT committed:**
```bash
git checkout -- src/components/Header.tsx
```

**If already committed:**
```bash
# Find the commit where you deleted it
git log --all -- src/components/Header.tsx

# Restore from one commit before deletion
git checkout [COMMIT_HASH]~1 -- src/components/Header.tsx

# Commit the recovery
git add src/components/Header.tsx
git commit -m "Recover deleted Header.tsx"
```

---

### Scenario 4: "Merge conflict - how do I fix this?"

**User says:** "I tried to merge and got conflicts in App.tsx"

**Response:**
```bash
# 1. Check which files have conflicts
git status

# 2. Open App.tsx, look for these markers:
# <<<<<<< HEAD
# Your changes
# =======  
# Their changes
# >>>>>>> branch-name

# 3. Edit the file: keep what you want, delete the markers

# 4. Mark as resolved
git add App.tsx

# 5. Complete the merge
git commit

# If you want to abort instead:
git merge --abort
```

---

### Scenario 5: "I'm in detached HEAD state"

**User says:** "Git says 'HEAD detached at abc123'"

**Response:**
```bash
# If you want to keep your changes here:
git checkout -b new-branch-name

# If you want to go back to main:
git checkout main

# Your work isn't lost - it's in reflog for 90 days
```

---

## Quick Reference

| Problem | Quick Fix |
|---------|-----------|
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| Undo last commit (discard) | `git reset --hard HEAD~1` |
| Recover deleted file (uncommitted) | `git checkout -- [FILE]` |
| Recover deleted file (committed) | `git checkout [HASH]~1 -- [FILE]` |
| Committed to wrong branch | Create branch, reset original |
| Merge conflict | Edit file, remove markers, `git add`, `git commit` |
| Detached HEAD | `git checkout -b new-branch` or `git checkout main` |
| Unstage file | `git reset HEAD [FILE]` |
| Discard all changes | `git reset --hard HEAD` |
| Recover lost commits | `git reflog` then `git reset --hard [HASH]` |

---

## Prevention Tips

**Before committing:**
```bash
# Always check what you're committing
git status
git diff

# Check which branch you're on
git branch
```

**Before pushing:**
```bash
# Review commits
git log --oneline -5

# Make sure you're on the right branch
git branch
```

**Use feature branches:**
```bash
# Never work directly on main
git checkout -b feature/my-work

# Do your work, commit, then merge via PR
```

**Commit frequently:**
```bash
# Small commits are easier to undo
# Instead of one big commit, do:
git add src/Header.tsx
git commit -m "Add Header component"

git add src/Footer.tsx
git commit -m "Add Footer component"
```

---

## When to Use This Skill

✅ Use git-recovery when:
- Made a git mistake
- Need to undo commits
- Deleted a file by accident
- Merge conflict
- Detached HEAD
- Committed to wrong branch
- Lost work after bad git operation

❌ Don't use git-recovery for:
- Learning git fundamentals (read GIT_FOR_VIBE_CODERS.md guide)
- Setting up git workflow (that's architecture)
- Advanced git operations (rebase, submodules, etc.)
- Git configuration

**This skill fixes git mistakes. For learning git workflows, see the GIT_FOR_VIBE_CODERS guide in your framework.**
