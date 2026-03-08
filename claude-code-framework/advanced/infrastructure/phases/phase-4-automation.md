# Phase 4: Workflow & Automation

> Read STATUS.md first to confirm Phase 3 is complete.

## 4.1 Claude Code Integration

- Verify Claude Code CLI is properly configured on this machine
- Set up CLAUDE.md and STATUS.md for the infrastructure project (if not done in Phase 2)
- Create useful shell scripts in ~/bin/ (and add ~/bin to PATH in ~/.bashrc):
  - `system-health.sh` — checks disk, memory, Docker status, all services, reports any issues
  - `backup-now.sh` — symlink to ~/projects/infrastructure/backups/backup-now.sh
  - `backup-restore.sh` — symlink to ~/projects/infrastructure/backups/backup-restore.sh
- Source ~/.bashrc after adding ~/bin to PATH
- Verification: each script runs correctly

## 4.2 Git Workflow

- Configure Gitea with repos for each project:
  - infrastructure
  - [Add one repo per active project]
- Set up SSH keys so push/pull to Gitea works without passwords
- Set up a simple auto-deploy for your main project on push to main:
  - Use a small webhook listener (adnanh/webhook in a Docker container, or a simple systemd service with a bash script)
  - On push to main: pull latest → rebuild container → restart
  - Explain which approach you're using and why
- Configure standard .gitignore templates per project

## 4.3 Cron Jobs — Consolidated

Set up ALL cron jobs in a single crontab and document them:

```cron
# === Mini PC Automated Tasks ===
# All output logged to ~/logs/cron.log

# Daily 2:00 AM — PostgreSQL backup
0 2 * * * ~/projects/infrastructure/backups/backup-now.sh >> ~/logs/cron.log 2>&1

# Daily 3:00 AM — Clean old Docker images (older than 7 days)
0 3 * * * docker image prune -af --filter "until=168h" >> ~/logs/cron.log 2>&1

# Weekly Sunday 4:00 AM — System package updates
0 4 * * 0 sudo apt-get update && sudo apt-get upgrade -y >> ~/logs/cron.log 2>&1

# Every 15 minutes — Disk space check (alert if >85%)
*/15 * * * * ~/bin/disk-check.sh >> ~/logs/cron.log 2>&1
```

Create the disk-check.sh script:
- Checks all mounted filesystems
- If any mount exceeds 85% usage, sends a Telegram alert
- Include mount point, usage percentage, and available space
- Don't spam: only alert once per hour per mount point (use a lockfile)

Create ~/logs/ directory with a logrotate config:
- Rotate weekly, keep 4 weeks, compress old logs

Verification: `crontab -l` shows all jobs, `~/logs/cron.log` starts populating, disk-check.sh runs without error

## 4.4 Container Resource Limits

Add resource limits to docker-compose.yml for application containers:

```yaml
# Template — resource limits per container
deploy:
  resources:
    limits:
      memory: 512M
      cpus: '1.0'
    reservations:
      memory: 128M
      cpus: '0.25'
```

This prevents a runaway process from starving PostgreSQL or Redis.

---

Update STATUS.md with cron schedule and automation details.

Git commit: `git add -A && git commit -m "phase 4: workflow automation and cron"`

**STOP HERE.** Wait for confirmation before proceeding to Phase 4.5 (Telegram Bot).
