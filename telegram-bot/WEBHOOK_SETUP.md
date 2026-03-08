# Wiring the Orchestrator to the Telegram Webhook

## Overview

The Telegram bot runs a lightweight HTTP server on port 8787 (localhost only).
The orchestrator and other services POST alerts to it, and the bot pushes them
to your Telegram chat. No auth session needed — push notifications always work.

```
Orchestrator ──POST /webhook──► Telegram Bot (port 8787) ──► Your Telegram
Disk check   ──POST /webhook/alert──► Telegram Bot ──► Your Telegram
Any script   ──POST /webhook/alert──► Telegram Bot ──► Your Telegram
```

---

## Step 1: Set the orchestrator's FAILURE_WEBHOOK_URL

In `~/claude-multi-agent/orchestrator/.env`, set:

```
FAILURE_WEBHOOK_URL=http://127.0.0.1:8787/webhook
```

That's it. The orchestrator's existing `notify_failure()` function already
POSTs JSON with `agent`, `project`, `task`, `error`, `timestamp` fields —
which is exactly what the webhook expects.

Then restart: `sudo systemctl restart claude-orchestrator`

---

## Step 2: Replace disk-check.sh with webhook version

Copy the provided `disk-check-webhook.sh`:

```bash
cp disk-check-webhook.sh ~/bin/disk-check.sh
chmod +x ~/bin/disk-check.sh
```

This replaces the direct Telegram API call with a POST to the local webhook.

---

## Step 3: Add task completion notifications (optional)

To get notified when tasks complete (not just fail), add this to the
orchestrator's `_run()` function in `orchestrator.py`, right after
the task status is updated:

Find the lines:
```python
            if result.get("exit_code", -1) == 0:
                _running_tasks[task_id]["status"] = "completed"
            else:
                _running_tasks[task_id]["status"] = "failed"
```

Add after the save_tasks_state() call (around line that says `save_tasks_state(_running_tasks)`):

```python
            # Push notification via Telegram webhook
            try:
                import urllib.request
                notify_data = json.dumps({
                    "task_id": task_id,
                    "agent": agent_name,
                    "project": req.project,
                    "status": _running_tasks[task_id]["status"],
                    "actual_cost": actual_cost,
                }).encode()
                notify_req = urllib.request.Request(
                    "http://127.0.0.1:8787/webhook/task",
                    data=notify_data,
                    headers={"Content-Type": "application/json"},
                    method="POST",
                )
                urllib.request.urlopen(notify_req, timeout=5)
            except Exception:
                pass  # Don't let notification failures affect task processing
```

This is optional — you may not want a notification for every completed task
if you're running many tasks. You can always check `/tasks` via Telegram.

---

## Step 4: Send alerts from any script

Any script on the mini PC can push a Telegram notification:

```bash
# Simple alert
curl -s -X POST http://127.0.0.1:8787/webhook/alert \
  -H "Content-Type: application/json" \
  -d '{
    "level": "warning",
    "title": "Backup Failed",
    "source": "backup-now.sh",
    "message": "PostgreSQL backup failed: connection refused"
  }'

# Levels: "critical", "warning", "info"
```

Add this pattern to any cron job or monitoring script that needs to alert you.

---

## Webhook Endpoints Reference

| Endpoint | Method | Source | Purpose |
|----------|--------|--------|---------|
| `/webhook` | POST | Orchestrator | Agent failure alerts |
| `/webhook/alert` | POST | Any script | Generic alerts (disk, backup, health) |
| `/webhook/task` | POST | Orchestrator | Task completion notifications |
| `/webhook/health` | GET | Monitoring | Webhook server health check |

### POST /webhook (agent failure)
```json
{
  "agent": "frontend-developer",
  "project": "my-analytics",
  "task": "Build dashboard",
  "error": "Claude CLI not found",
  "timestamp": "2026-02-16T10:30:00"
}
```

### POST /webhook/alert (generic)
```json
{
  "level": "warning|critical|info",
  "title": "Alert Title",
  "source": "script-name",
  "message": "Details here"
}
```

### POST /webhook/task (completion)
```json
{
  "task_id": "1708082400-frontend-developer",
  "agent": "frontend-developer",
  "project": "my-analytics",
  "status": "completed|failed",
  "actual_cost": 0.42
}
```

---

## Testing

After setup, test each endpoint:

```bash
# Test agent failure
curl -X POST http://127.0.0.1:8787/webhook \
  -H "Content-Type: application/json" \
  -d '{"agent":"test","project":"test","task":"test task","error":"test error"}'

# Test generic alert
curl -X POST http://127.0.0.1:8787/webhook/alert \
  -H "Content-Type: application/json" \
  -d '{"level":"info","title":"Test Alert","source":"manual","message":"Testing webhook"}'

# Test task completion
curl -X POST http://127.0.0.1:8787/webhook/task \
  -H "Content-Type: application/json" \
  -d '{"task_id":"test-123","agent":"test","project":"test","status":"completed","actual_cost":0.05}'

# Health check
curl http://127.0.0.1:8787/webhook/health
```

Each should trigger a Telegram message to you (no auth session needed).
