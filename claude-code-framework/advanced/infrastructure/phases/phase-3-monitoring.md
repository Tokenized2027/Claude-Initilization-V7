# Phase 3: Monitoring & Management

> Read STATUS.md first to confirm Phase 2 is complete.

## 3.1 Logging — Dozzle

Add Dozzle container to infrastructure docker-compose.yml:
- Lightweight Docker log viewer — single container, no database
- Web UI bound to 127.0.0.1 (accessible via Tailscale)
- Shows real-time logs from all containers
- Health check configured
- Profile: `monitoring` (so monitoring stack can be started/stopped independently)
- Verification: Open Dozzle web UI via Tailscale, confirm you can see all container logs

## 3.2 Health Monitoring — Uptime Kuma

Add Uptime Kuma container to infrastructure docker-compose.yml:
- Single Docker container for service health checks
- Web UI bound to 127.0.0.1 (accessible via Tailscale)
- Health check configured
- Profile: `monitoring`
- Configure monitors for:
  - All Docker containers (via Docker socket or HTTP checks)
  - PostgreSQL (TCP check on port 5432)
  - Redis (TCP check on port 6379)
  - External API status (if applicable — add HTTP checks for any external APIs your project depends on)
  - Disk space (will use cron-based alerter in Phase 4 for this)
- Check intervals: 60 seconds for infrastructure, 5 minutes for external APIs
- Set up Telegram bot for alerts [DECISION: Chat ID from @userinfobot, bot token from @BotFather -- store in .env]
- Verification: Uptime Kuma dashboard shows all services green

## 3.3 System Resource Monitoring — cAdvisor

Add cAdvisor container to infrastructure docker-compose.yml:
- Docker resource metrics (CPU, RAM, network per container)
- Web UI bound to 127.0.0.1 (accessible via Tailscale)
- Health check configured
- Profile: `monitoring`
- Verification: cAdvisor web UI shows container stats

## 3.4 Docker Compose Profiles

The monitoring containers should use Docker Compose profiles:

```yaml
# Start everything including monitoring:
docker compose --profile monitoring up -d

# Start only core infrastructure (no monitoring):
docker compose up -d

# Stop only monitoring:
docker compose --profile monitoring down
```

NOTE: You do NOT need a full Grafana/Prometheus/Loki stack. Dozzle for logs, Uptime Kuma for health, cAdvisor for resources. Add more later if needed.

---

Update STATUS.md with monitoring service URLs and status.

Git commit: `git add -A && git commit -m "phase 3: monitoring stack"`

**STOP HERE.** Wait for confirmation before proceeding to Phase 4.
