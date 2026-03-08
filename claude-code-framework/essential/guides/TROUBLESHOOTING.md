# Troubleshooting — Common Issues & Quick Fixes

> When something breaks, check here before asking Claude Code to debug. Half the time it's one of these known issues.
>
> **How to use this:** Find your error message or symptom in the list below. Run the diagnostic command. Apply the fix.

---

## Permission & Access Errors

### "Permission denied"

```bash
# Diagnosis: is it a file permission issue?
ls -la the-file-or-script

# Fix: make a script executable
chmod +x script-name.sh

# Fix: if you need admin access
sudo command-that-failed
```

### "Permission denied (publickey)" when SSH'ing

```bash
# Your SSH key isn't set up or password auth is disabled
# From the mini PC (plug in a monitor):
sudo nano /etc/ssh/sshd_config

# Temporarily set:
#   PasswordAuthentication yes

# Then restart SSH:
sudo systemctl restart sshd

# Now SSH in from your laptop, set up keys properly, then disable password auth again
```

### "docker: permission denied"

```bash
# Your user isn't in the docker group
sudo usermod -aG docker $USER

# You MUST log out and back in (or reboot) for this to take effect
exit
# SSH back in
```

---

## "Command Not Found" Errors

### `node`, `npm`, `pnpm` not found

```bash
# If using nvm:
source ~/.nvm/nvm.sh
# Or just open a new terminal

# If Node.js isn't installed at all:
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### `claude` not found

```bash
# Check if it's installed globally
npm list -g @anthropic-ai/claude-code

# If not:
npm install -g @anthropic-ai/claude-code

# If npm itself isn't found, install Node.js first (see above)
```

### `docker` or `docker compose` not found

```bash
# Docker not installed — follow the official install:
# https://docs.docker.com/engine/install/ubuntu/

# If docker works but "docker compose" doesn't (note: no hyphen):
# You might have the old docker-compose (v1). Install the plugin:
sudo apt-get install docker-compose-plugin
```

---

## Docker & Container Issues

### Container won't start

```bash
# Step 1: Check the logs (this tells you WHY it failed)
docker compose logs service-name

# Step 2: Common fixes
docker compose down          # stop everything cleanly
docker compose pull          # pull fresh images
docker compose up -d         # try again

# Step 3: If it's a port conflict
docker compose down
sudo lsof -i :PORT_NUMBER   # find what's using the port
# Either kill that process or change the port in docker-compose.yml
```

### Container starts but the service inside doesn't work

```bash
# Check if the container is actually healthy
docker ps    # look at the STATUS column

# Get inside the container to investigate
docker exec -it container-name bash
# (or sh if bash isn't available)

# Check environment variables inside the container
docker exec container-name env | grep POSTGRES
```

### "network X not found"

```bash
# The Docker network hasn't been created yet
docker network create infra-net
docker network create app-net

# Or let docker-compose create them:
docker compose up -d
```

### Out of disk space (Docker eating storage)

```bash
# See how much Docker is using
docker system df

# Clean unused images, containers, and build cache
docker system prune -af

# Clean unused volumes (CAREFUL: this deletes data from stopped containers)
docker volume prune -f

# Nuclear option — remove EVERYTHING (data loss!):
# docker system prune -af --volumes
```

---

## Port & Network Issues

### "Port already in use" / "Address already in use"

```bash
# Find what's using the port
sudo lsof -i :3000

# Kill it by PID (replace 12345 with the actual PID from above)
kill -9 12345

# Or change the port in your docker-compose.yml and restart
```

### Can't access a service from browser via Tailscale

```bash
# Step 1: Is the container running?
docker ps | grep service-name

# Step 2: Is it bound to 127.0.0.1? (Check docker-compose.yml)
# It should be: "127.0.0.1:8080:8080"

# Step 3: Is Tailscale running?
tailscale status

# Step 4: Try accessing via Tailscale IP
# Find it with: tailscale ip -4
# Then in browser: http://TAILSCALE_IP:8080
```

### Can't access mini PC from laptop at all

```bash
# On the mini PC (plug in monitor):

# Is SSH running?
sudo systemctl status sshd

# What's the IP?
ip addr | grep "inet " | grep -v 127.0.0.1

# Is the firewall blocking you?
sudo ufw status

# Is the ethernet cable plugged in?
ip link show    # look for "state UP"
```

---

## Git Issues

### "Not a git repository"

```bash
# You're in the wrong directory
pwd                        # Where are you?
cd ~/projects/your-project # Go to the right place
git status                 # Try again
```

### "Your branch is behind origin/main"

```bash
# Pull the latest changes first
git pull origin main

# If there are conflicts, ask Claude Code to resolve them
```

### You committed something you shouldn't have (like .env)

```bash
# Remove the file from git tracking (but keep the actual file)
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "fix: remove .env from tracking"
```

### Want to undo the last commit (but keep your changes)

```bash
git reset --soft HEAD~1
# Your files are unchanged, but the commit is undone
```

### Want to undo ALL changes since last commit (DESTRUCTIVE)

```bash
# This throws away all uncommitted changes!
git checkout -- .
```

---

## Node.js / npm Issues

### "Module not found" or "Cannot find package"

```bash
# Install dependencies
npm install

# If a specific package is missing:
npm install package-name

# If you're using pnpm:
pnpm install
```

### "EACCES: permission denied" during npm install -g

```bash
# Fix npm global permissions (one-time)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Try the install again
npm install -g package-name
```

---

## Claude Code Issues

### Claude Code is confused, going in circles, or making things worse

This is the most common issue. It happens when the conversation gets too long or Claude loses track of context.

```bash
# Step 1: Make Claude save everything
# Type into Claude Code:
# "STOP. Update STATUS.md with everything we've done.
#  Commit all changes. Give me a CONTINUATION BRIEF."

# Step 2: Start a completely fresh session
# Exit Claude Code (Ctrl+C or type /exit)
claude

# Step 3: Paste this into the new session:
# "Read STATUS.md and CLAUDE.md. Here's the continuation brief
#  from our last session: [paste the brief]"
```

### Claude Code ignores CLAUDE.md rules

This is a known issue (see PITFALLS.md). Periodically remind it:

```
Before continuing, re-read CLAUDE.md and confirm you're following
all the rules. Specifically: are you updating STATUS.md? Are you
giving me complete files? Are you committing after each change?
```

### Claude Code keeps editing the wrong file

```
STOP. Run `pwd` and `ls` to confirm your current directory.
The file I need you to edit is [exact path]. Cat it first
so I can confirm it's the right one.
```

### API key issues

```bash
# Check if your key is set
echo $ANTHROPIC_API_KEY

# If empty, set it:
export ANTHROPIC_API_KEY="sk-ant-..."

# To make it permanent, add to ~/.bashrc:
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.bashrc
source ~/.bashrc
```

---

## Database Issues

### Can't connect to PostgreSQL

```bash
# Is the container running?
docker ps | grep postgres

# Check the logs
docker compose logs postgres

# Test connectivity from inside Docker
docker exec -it postgres-container-name psql -U your_db_user -d main -c "SELECT 1;"

# Common cause: wrong password in .env
cat .env | grep POSTGRES
```

### Can't connect to Redis

```bash
# Is it running?
docker ps | grep redis

# Test connectivity
docker exec -it redis-container-name redis-cli -a YOUR_PASSWORD ping
# Should respond: PONG
```

---

## System Resource Issues

### System feels slow / high CPU

```bash
# See what's using resources
htop
# Press F6 to sort by CPU or memory
# Press Q to quit

# Check Docker container resource usage
docker stats
```

### "ENOSPC: no space left on device"

```bash
# Check disk space
df -h

# What's using the most space?
du -sh /* 2>/dev/null | sort -rh | head -20

# Clean Docker (usually the biggest offender)
docker system prune -af

# Clean old logs
sudo journalctl --vacuum-time=7d

# Clean apt cache
sudo apt clean
```

### Out of memory (OOM) / container killed

```bash
# Check if swap is configured
free -h

# If no swap and RAM ≤ 16GB:
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Check which container was killed
docker ps -a | grep Exited
docker logs container-name
```

---

## Emergency Procedures

### Everything is broken, I want to start a service from scratch

```bash
# Stop the service
docker compose stop service-name

# Remove the container (data in volumes is safe)
docker compose rm service-name

# Recreate from scratch
docker compose up -d service-name

# Check it's working
docker compose logs -f service-name
```

### I need to restore from a database backup

```bash
# List available backups
~/projects/infrastructure/backups/backup-restore.sh

# Restore a specific backup
~/projects/infrastructure/backups/backup-restore.sh backup-2026-02-10.sql.gz
```

### I locked myself out of SSH

1. Plug a monitor and keyboard into the mini PC
2. Log in directly
3. Fix the SSH config: `sudo nano /etc/ssh/sshd_config`
4. Set `PasswordAuthentication yes` temporarily
5. Restart SSH: `sudo systemctl restart sshd`
6. SSH in from your laptop, fix your keys, then re-disable password auth

### The mini PC won't boot / is unresponsive

1. Hold the power button for 10 seconds to force shutdown
2. Wait 30 seconds
3. Power on again
4. If it's a recurring issue, check for disk errors: `sudo fsck /dev/sda1` (boot from USB if needed)

---

## The Golden Rule

**When in doubt: check the logs first, then ask Claude Code.**

```bash
# Docker container logs
docker compose logs service-name

# System logs
journalctl -u service-name --since "1 hour ago"

# Application logs
tail -50 ~/logs/app.log
```

Paste the log output into Claude Code with: "Here's the error log. What's wrong and how do I fix it?" — and Claude will usually nail it.
