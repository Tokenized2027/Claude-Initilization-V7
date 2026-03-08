# Emergency Recovery — Quick Reference

When Claude Code breaks something mid-feature, use this cheat sheet to undo and recover. One page, no explanation, just commands.

---

## Table of Contents

1. [Undo Uncommitted Changes](#undo-uncommitted-changes)
2. [Undo Last Commit](#undo-last-commit)
3. [Recover Deleted Files](#recover-deleted-files)
4. [Fix Docker Issues](#fix-docker-issues)
5. [Reset Database](#reset-database)
6. [Kill Stuck Processes](#kill-stuck-processes)
7. [Nuclear Options](#nuclear-options)

---

## Undo Uncommitted Changes

### Undo changes to ONE file
```bash
git checkout -- path/to/file.ts
# or
git restore path/to/file.ts
```

### Undo ALL uncommitted changes (DANGER)
```bash
git checkout .
# or
git reset --hard HEAD
```

### Save work before undoing
```bash
git stash           # Save everything
git reset --hard HEAD   # Reset to clean state
# If you need it back later:
git stash pop
```

---

## Undo Last Commit

### Undo commit, keep changes staged
```bash
git reset --soft HEAD~1
```

### Undo commit, keep changes unstaged
```bash
git reset HEAD~1
```

### Undo commit, discard changes (DANGER)
```bash
git reset --hard HEAD~1
```

### Undo last 3 commits, keep changes
```bash
git reset HEAD~3
```

### Undo commit that was already pushed
```bash
git revert HEAD
git push
```

---

## Recover Deleted Files

### File deleted but NOT committed
```bash
git checkout -- path/to/deleted-file.ts
```

### File deleted AND committed
```bash
# Find commit where file existed
git log --all --oneline -- path/to/file.ts

# Restore from that commit
git checkout <commit-hash> -- path/to/file.ts
```

### File deleted many commits ago
```bash
# Find ALL commits that touched the file
git log --all --full-history -- path/to/file.ts

# Restore from commit before deletion
git checkout <commit-hash>~1 -- path/to/file.ts
```

---

## Fix Docker Issues

### Container won't start
```bash
# Stop everything
docker compose down

# Remove volumes (DANGER - loses data)
docker compose down -v

# Rebuild and restart
docker compose up -d --build
```

### Port already in use
```bash
# Find process using port (example: 5000)
lsof -i :5000

# Kill it
kill -9 <PID>

# Or kill Docker process
docker compose down
```

### "No space left on device"
```bash
# Clean up Docker
docker system prune -a --volumes

# This removes:
# - Stopped containers
# - Unused networks
# - Dangling images
# - Build cache
# - Volumes
```

### Container keeps restarting
```bash
# Check logs
docker compose logs -f <service-name>

# Stop service
docker compose stop <service-name>

# Remove and recreate
docker compose rm <service-name>
docker compose up -d <service-name>
```

### Database connection failed
```bash
# Check if database is running
docker compose ps

# Restart database
docker compose restart db

# Check database logs
docker compose logs db

# Connect to database manually to verify
docker compose exec db psql -U <username> -d <database>
```

---

## Reset Database

### PostgreSQL (Docker)
```bash
# Drop and recreate database
docker compose exec db psql -U <username> -c "DROP DATABASE <dbname>;"
docker compose exec db psql -U <username> -c "CREATE DATABASE <dbname>;"

# Run migrations
# Python/Flask:
docker compose exec api flask db upgrade

# Node/Prisma:
docker compose exec api npx prisma migrate deploy
```

### SQLite
```bash
# Delete database file
rm database.db

# Run migrations
python manage.py migrate
# or
npx prisma migrate deploy
```

### Reset with seed data
```bash
# Drop, recreate, migrate, seed
docker compose exec db psql -U user -c "DROP DATABASE mydb;"
docker compose exec db psql -U user -c "CREATE DATABASE mydb;"
docker compose exec api flask db upgrade
docker compose exec api python seed.py
```

---

## Kill Stuck Processes

### Kill process by port
```bash
# Find process
lsof -i :3000

# Kill it
kill -9 <PID>

# Or one-liner
kill -9 $(lsof -t -i:3000)
```

### Kill process by name
```bash
# Find process
ps aux | grep node

# Kill it
pkill node

# Or force kill
pkill -9 node
```

### Kill all Node processes
```bash
killall node
```

### Kill all Python processes
```bash
killall python
# or
killall python3
```

### Kill Docker containers
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -a -q)
```

---

## Nuclear Options

### Start completely fresh in project
```bash
# Save any uncommitted work first!
git stash

# Reset to last commit, discard everything
git reset --hard HEAD

# Clean untracked files (DANGER)
git clean -fdx

# Restore work if needed
git stash pop
```

### Reset to specific commit
```bash
# Go back to commit from 2 days ago
git log --oneline  # Find commit hash
git reset --hard <commit-hash>
```

### Delete everything and re-clone
```bash
# Go up one directory
cd ..

# Delete project (DANGER)
rm -rf project-name

# Re-clone from GitHub
git clone https://github.com/username/project-name.git
cd project-name

# Reinstall dependencies
npm install  # or pip install -r requirements.txt
```

### Reset Docker completely
```bash
# Stop everything
docker compose down -v

# Remove ALL Docker data (DANGER - affects all projects)
docker system prune -a --volumes -f

# Rebuild project from scratch
docker compose up -d --build
```

### Reset Node modules
```bash
rm -rf node_modules package-lock.json
npm install
```

### Reset Python virtualenv
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
```

---

## Quick Decision Tree

**Claude broke something:**

1. **Not committed yet?** → `git checkout .` (reverts all changes)
2. **Just committed?** → `git reset HEAD~1` (undo commit, keep changes)
3. **Already pushed?** → `git revert HEAD` (create reverting commit)
4. **Docker broken?** → `docker compose down && docker compose up -d`
5. **Port in use?** → `kill -9 $(lsof -t -i:PORT)`
6. **Database corrupted?** → Drop/recreate database, run migrations
7. **Everything is broken?** → `git reset --hard HEAD` (nuclear option)
8. **Still broken?** → Delete project, re-clone from GitHub

---

## Safety Tips

1. **Commit frequently** - Can always go back to a working state
2. **Use git stash** - When unsure, stash first, then experiment
3. **Test recovery commands** - Try on throwaway branch first
4. **Keep backups** - Push to GitHub often
5. **Document working states** - Note commit hash of last known good state

---

## Commands That Can't Be Undone

These commands **permanently delete data**. Be very sure before running:

```bash
git reset --hard HEAD       # Discards all uncommitted changes
git clean -fdx              # Deletes all untracked files
docker compose down -v      # Deletes Docker volumes (database data)
rm -rf directory            # Deletes directory and contents
git push --force            # Overwrites remote history
```

**Before running any of these:** Ask yourself "Do I have a backup?" If no, make one first:

```bash
git stash    # Backup uncommitted changes
git push     # Backup committed changes
cp -r project project-backup  # Backup entire directory
```

---

## If All Else Fails

1. **Stop Claude Code session** (prevent more damage)
2. **Check git log** (`git log --oneline -20`) to see recent changes
3. **Identify last known good commit** (when things worked)
4. **Reset to that commit** (`git reset --hard <commit-hash>`)
5. **Restart from there** with a fresh Claude Code session

**Remember:** As long as you committed regularly, you can always recover. Git is a time machine.

---

## Print This Section

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    EMERGENCY RECOVERY CARD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

UNDO UNCOMMITTED:
  git stash              Save work
  git checkout .         Discard all
  git checkout -- FILE   Discard one file

UNDO LAST COMMIT:
  git reset HEAD~1       Undo, keep changes
  git reset --hard HEAD~1 Undo, discard changes

DOCKER:
  docker compose down    Stop all
  docker compose up -d   Start all
  docker system prune -a Clean everything

PORTS:
  lsof -i :PORT          Find process
  kill -9 PID            Kill it
  kill -9 $(lsof -t -i:PORT)  One-liner

DATABASE:
  docker compose restart db
  DROP DATABASE dbname; CREATE DATABASE dbname;

NUCLEAR:
  git reset --hard HEAD  Discard everything
  git clean -fdx         Delete untracked
  rm -rf project && git clone URL  Start over

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
