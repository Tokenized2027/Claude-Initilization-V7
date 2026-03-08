---
name: observability-setup
description: Set up monitoring, logging, and alerting for mini PC services and autonomous agents. Use when deploying new services, setting up health checks, or diagnosing reliability issues. Triggers on "monitoring", "logging", "alerts", "health check", "uptime", "service down", "observability".
metadata:
  author: Mastering Claude Code (adapted from community contributions)
  version: 1.0.0
  category: operations
  source: community-contributed
  license: MIT
---

# Observability Setup

Monitoring, structured logging, and alerting so your mini PC agents don't silently fail at 3 AM.

## Instructions

### Layer 1: Health Checks

Every service gets a `/health` endpoint:

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const checks = {
    api: 'ok',
    database: await checkDatabase(),
    redis: await checkRedis(),
    uptime: process.uptime(),
    memory: process.memoryUsage().heapUsed / 1024 / 1024, // MB
  }

  const healthy = checks.database === 'ok' && checks.redis === 'ok'

  return NextResponse.json(checks, {
    status: healthy ? 200 : 503,
  })
}

async function checkDatabase(): Promise<string> {
  try {
    await db.query('SELECT 1')
    return 'ok'
  } catch {
    return 'error'
  }
}

async function checkRedis(): Promise<string> {
  try {
    await redis.ping()
    return 'ok'
  } catch {
    return 'error'
  }
}
```

### Layer 2: Structured Logging

Never use `console.log` with raw strings. Use structured JSON logs:

```typescript
// lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogEntry {
  level: LogLevel
  message: string
  service: string
  timestamp: string
  [key: string]: unknown
}

export function createLogger(service: string) {
  return {
    info: (message: string, data?: Record<string, unknown>) =>
      log('info', service, message, data),
    warn: (message: string, data?: Record<string, unknown>) =>
      log('warn', service, message, data),
    error: (message: string, data?: Record<string, unknown>) =>
      log('error', service, message, data),
  }
}

function log(level: LogLevel, service: string, message: string, data?: Record<string, unknown>) {
  const entry: LogEntry = {
    level,
    message,
    service,
    timestamp: new Date().toISOString(),
    ...data,
  }
  
  // JSON logs are parseable by any log aggregator
  console.log(JSON.stringify(entry))
}

// Usage:
// const log = createLogger('orchestrator')
// log.info('Task routed', { agent: 'frontend-developer', taskId: 'abc123' })
// log.error('Agent failed', { agent: 'backend-developer', error: err.message })
```

### Layer 3: Cron Health Monitor

Simple bash script for mini PC monitoring:

```bash
#!/bin/bash
# ~//scripts/health-monitor.sh
# Run via cron every 5 minutes: */5 * * * * ~//scripts/health-monitor.sh

SERVICES=("http://localhost:8000/health" "http://localhost:3000/api/health")
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}"
LOG_FILE="/var/log/health-monitor.log"

send_alert() {
  local message="$1"
  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d text="🚨 MINI PC ALERT: ${message}" \
    -d parse_mode="Markdown" > /dev/null
}

for url in "${SERVICES[@]}"; do
  response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
  
  if [ "$response" != "200" ]; then
    echo "$(date -Iseconds) FAIL $url (HTTP $response)" >> "$LOG_FILE"
    send_alert "Service DOWN: \`$url\` returned HTTP $response"
  else
    echo "$(date -Iseconds) OK   $url" >> "$LOG_FILE"
  fi
done

# Check disk space
disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$disk_usage" -gt 85 ]; then
  send_alert "Disk usage at ${disk_usage}% — clean up needed"
fi

# Check memory
mem_available=$(free -m | awk 'NR==2 {print $7}')
if [ "$mem_available" -lt 500 ]; then
  send_alert "Low memory: only ${mem_available}MB available"
fi

# Check Docker containers
stopped=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | head -5)
if [ -n "$stopped" ]; then
  send_alert "Stopped containers: \`$stopped\`"
fi
```

### Layer 4: Docker Compose Logging

```yaml
# In docker-compose.yml — add to every service
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

View logs:
```bash
# All services
docker-compose logs --tail 100 -f

# Specific service
docker-compose logs --tail 50 orchestrator

# Search for errors
docker-compose logs | grep '"level":"error"'
```

### Layer 5: Agent Activity Dashboard (Optional)

Track agent performance over time:

```sql
-- Create a simple metrics table
CREATE TABLE agent_metrics (
  id SERIAL PRIMARY KEY,
  agent_name TEXT NOT NULL,
  task_id TEXT NOT NULL,
  status TEXT NOT NULL, -- 'started' | 'completed' | 'failed'
  tokens_used INTEGER,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Useful queries
-- Agent success rate last 24h
SELECT agent_name,
  COUNT(*) FILTER (WHERE status = 'completed') AS successes,
  COUNT(*) FILTER (WHERE status = 'failed') AS failures,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'completed') / COUNT(*), 1) AS success_rate
FROM agent_metrics
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY agent_name;

-- Average task duration by agent
SELECT agent_name, AVG(duration_ms) / 1000 AS avg_seconds
FROM agent_metrics
WHERE status = 'completed'
GROUP BY agent_name;
```

## Quick Setup Checklist

```markdown
- [ ] Health endpoint on every service
- [ ] Structured JSON logging (not raw console.log)
- [ ] Docker log rotation configured
- [ ] Cron health monitor running every 5 min
- [ ] Telegram alerts connected
- [ ] Disk and memory alerts at 85% / 500MB
- [ ] Stopped container detection
```

## When to Use This Skill

✅ Use observability-setup when:
- Deploying a new service on the mini PC
- Services fail silently
- Need to diagnose intermittent issues
- Setting up the monitoring stack for the first time

❌ Don't use for:
- Application-level debugging (use systematic-debugging)
- Docker container issues (use docker-debugger)
- Cost monitoring (use cost-optimizer)
