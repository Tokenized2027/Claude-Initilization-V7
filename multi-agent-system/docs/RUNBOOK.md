# Multi-Agent System Operational Runbook

**Version:** 3.2  
**Last Updated:** February 16, 2026  
**Audience:** System operators, admins  

---

## Daily Operations

### Check System Health

```bash
# Quick health check
curl http://your-server:8000/health

# Expected response:
{
  "status": "healthy",
  "version": "1.2.0",
  "auto_handoff": true,
  "running_tasks": 2,
  "daily_spend": 12.50,
  "daily_budget": 50.0
}
```

**Red flags:**
- `status != "healthy"` → Check logs
- `daily_spend > daily_budget * 0.9` → Budget nearly exhausted
- `running_tasks > max_concurrent` → Task queue building up

---

### Monitor Spend

```bash
# Get detailed spend summary
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend

# Response:
{
  "daily_spend_today": 12.50,
  "daily_budget": 50.0,
  "daily_remaining": 37.50,
  "projects": {
    "my-analytics": 7.50,
    "test-project": 5.00
  },
  "project_budget_per_project": 25.0,
  "actual_daily_spend": 10.80,
  "actual_vs_estimated_ratio": 0.864,
  "actual_projects": {
    "my-analytics": 6.20,
    "test-project": 4.60
  }
}
```

**Actions:**
- Daily spend > 80% of budget → Review tasks, consider increasing budget
- Project approaching limit → Reset if project is ongoing, or investigate high costs
- `actual_vs_estimated_ratio` < 0.7 → Estimates too high, tune down in `project_routes.json`
- `actual_vs_estimated_ratio` > 1.3 → Estimates too low, increase to prevent budget surprises
- `actual_daily_spend` / `actual_projects` fields appear only when token usage data is available

---

### Check Running Tasks

```bash
# List all tasks
curl http://your-server:8000/tasks

# Check specific task
curl http://your-server:8000/tasks/{task_id}
```

**Task statuses:**
- `running` → Currently executing
- `completed` → Finished successfully
- `failed` → Agent crashed or timed out
- `budget-exceeded` → Blocked by budget controls
- `blocked` → Handoff depth limit reached

---

### View Project Status

```bash
# Get project state
curl http://your-server:8000/status/my-analytics

# Response:
{
  "project": "my-analytics",
  "status": "in-progress",
  "agents": ["frontend-developer", "backend-developer"],
  "created": "2026-02-15T10:30:00Z",
  "last_updated": "2026-02-15T14:22:00Z",
  "total_spend": 12.50
}
```

**Statuses:**
- `in-progress` → Actively working
- `completed` → All tasks done
- `error` → Agent failure (check logs)

---

## Troubleshooting

### "Budget Exceeded" Errors

**Symptom:** Tasks blocked with "Daily budget exceeded" or "Project budget exceeded"

**Diagnosis:**
```bash
# Check current spend
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend
```

**Solutions:**

**Option 1: Increase budget** (if spend is legitimate)
```bash
# Edit .env
nano ~/claude-multi-agent/orchestrator/.env

# Increase limits:
DAILY_BUDGET_USD=75.0
PROJECT_BUDGET_USD=35.0

# Restart orchestrator
sudo systemctl restart claude-orchestrator
```

**Option 2: Reset project budget** (if project is ongoing)
```bash
# Reset specific project's counter
curl -X POST -H "X-API-Key: YOUR_KEY" \
  http://your-server:8000/spend/reset-project/my-analytics

# Daily budget resets automatically at midnight UTC
```

**Option 3: Wait** (if near daily limit)
- Daily budget resets at midnight UTC
- Check back tomorrow

---

### Agent Timeouts

**Symptom:** Tasks fail with "Timeout after 1800s"

**Diagnosis:**
```bash
# Check task logs
cat ~/claude-memory/projects/{project}/logs/{task_id}.json

# Look for "timeout" in errors field
```

**Causes:**
- Task complexity exceeds timeout
- Agent waiting for external API
- Infinite loop in agent logic

**Solutions:**

**Option 1: Increase timeout** (for complex tasks)
```bash
# Edit .env
nano ~/claude-multi-agent/orchestrator/.env

# Increase timeout:
AGENT_TIMEOUT_SECONDS=3600  # 60 minutes

# Restart
sudo systemctl restart claude-orchestrator
```

**Option 2: Break task into smaller pieces**
- Submit as multiple smaller tasks
- Use manual handoffs instead of auto

**Option 3: Investigate task**
- Check agent logs for stuck operations
- May need to refine agent prompt

---

### Stuck Handoffs (Agent Crashed Mid-Task)

**Symptom:** A handoff shows status "accepted" but the receiving agent crashed before completing it. No agent will pick it up because it's no longer "pending".

**Diagnosis:**
```bash
# List all handoffs — look for "accepted" status with old timestamps
curl http://your-server:8000/handoffs/{project}
```

**Solution: Retry the handoff**
```bash
# Reset the stuck handoff back to "pending"
curl -X POST -H "X-API-Key: YOUR_KEY" \
  http://your-server:8000/handoffs/{project}/retry/{handoff_id}

# The next agent spawn for this project will pick it up
```

**If the handoff keeps failing:** The task itself may be the problem. Check agent logs for the error, fix the issue, then retry.

---

### Handoff Depth Limit Reached

**Symptom:** Task blocked with "Auto-handoff chain stopped: depth X > limit Y"

**Diagnosis:**
```bash
# View handoff chain
curl http://your-server:8000/handoffs/{project}

# Shows all handoffs with from/to agents
```

**Causes:**
- Complex task requiring many agent transitions
- Circular handoff pattern (A → B → A → B...)

**Solutions:**

**Option 1: Review handoff chain**
```bash
# Check if chain makes sense
curl http://your-server:8000/handoffs/{project}

# If circular, this indicates agent prompt issue
# If linear but long, task is complex
```

**Option 2: Increase depth limit** (if chain is legitimate)
```bash
# Edit .env
nano ~/claude-multi-agent/orchestrator/.env

# Increase limit:
MAX_HANDOFF_DEPTH=7

# Restart
sudo systemctl restart claude-orchestrator
```

**Option 3: Manual completion**
- Review what's been done
- Complete remaining work manually
- Update project state

---

### Failed Tasks

**Symptom:** Task status shows "failed"

**Diagnosis:**
```bash
# Get task details
curl http://your-server:8000/tasks/{task_id}

# Check logs
cat ~/claude-memory/projects/{project}/logs/{task_id}.json

# Look at "errors" field
```

**Common errors:**

**"Claude CLI not found"**
```bash
# Verify Claude installed
which claude

# If missing, install:
npm install -g @anthropic-ai/claude-code
```

**"Module not found" / Build errors**
```bash
# Agent dependencies missing
# Check project directory
cd /path/to/project
npm install  # or pip install -r requirements.txt
```

**"Permission denied"**
```bash
# Check CLAUDE_SKIP_PERMISSIONS setting
# If false, agent hit approval prompt (can't respond in --print mode)

# Option 1: Enable skip permissions (DANGEROUS)
CLAUDE_SKIP_PERMISSIONS=true

# Option 2: Run task manually with approvals
cd /path/to/project
claude "complete the task"
```

**"API rate limit"**
```bash
# Anthropic API rate limit hit
# Reduce MAX_CONCURRENT_AGENTS or wait
nano ~/claude-multi-agent/orchestrator/.env
MAX_CONCURRENT_AGENTS=2
```

---

### Orchestrator Won't Start

**Symptom:** `sudo systemctl start claude-orchestrator` fails

**Diagnosis:**
```bash
# Check status
sudo systemctl status claude-orchestrator

# View logs
sudo journalctl -u claude-orchestrator -n 50
```

**Common issues:**

**Port 8000 already in use**
```bash
# Find process using port
sudo lsof -i :8000

# Kill it or change orchestrator port
nano ~/claude-multi-agent/orchestrator/.env
ORCHESTRATOR_PORT=8001
```

**Missing API key**
```bash
# Check .env
cat ~/claude-multi-agent/orchestrator/.env | grep ANTHROPIC_API_KEY

# If empty, add it
nano ~/claude-multi-agent/orchestrator/.env
```

**Python dependencies missing**
```bash
cd ~/claude-multi-agent/orchestrator
source venv/bin/activate
pip install -r requirements.txt
```

---

## Maintenance Tasks

### Reset Daily Spend Counter

**Daily counter resets automatically at midnight UTC.** No action needed.

To check when next reset occurs:
```bash
# Current UTC time
date -u

# Budget resets at 00:00 UTC
```

---

### Reset Project Spend Counter

```bash
# Reset specific project
curl -X POST -H "X-API-Key: YOUR_KEY" \
  http://your-server:8000/spend/reset-project/{project_name}

# Confirm reset
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend
```

**When to reset:**
- Project completed, starting new work
- Budget increase applied, want fresh counter
- Testing budget controls

---

### Clear Old Logs

```bash
# Logs stored per project
cd ~/claude-memory/projects/{project}/logs

# Remove logs older than 30 days
find . -name "*.json" -mtime +30 -delete

# Or keep only last 100 logs
ls -t *.json | tail -n +101 | xargs rm -f
```

---

### Backup Memory State

```bash
# Backup entire memory directory
tar -czf ~/backups/claude-memory-$(date +%Y%m%d).tar.gz \
  ~/claude-memory/

# Backup specific project
tar -czf ~/backups/my-analytics-$(date +%Y%m%d).tar.gz \
  ~/claude-memory/projects/my-analytics/
```

**Backup schedule:**
- Daily: Full memory backup
- Weekly: Offsite copy
- Before major changes: Snapshot

---

### Restart Orchestrator

```bash
# Restart service
sudo systemctl restart claude-orchestrator

# Check if started successfully
sudo systemctl status claude-orchestrator

# View recent logs
sudo journalctl -u claude-orchestrator -f
```

**When to restart:**
- After .env changes
- After code updates
- If service becomes unresponsive

---

### Update Agent Templates

```bash
# Edit agent prompt
nano ~/claude-multi-agent/agent-templates/frontend-developer.md

# No restart needed - agents read templates on each spawn
# Next task will use updated template
```

---

## Monitoring Best Practices

### Daily Checks (2 minutes)

```bash
# 1. Health check
curl http://your-server:8000/health

# 2. Spend check
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend

# 3. Failed tasks?
curl http://your-server:8000/tasks | grep '"status": "failed"'
```

### Weekly Review (15 minutes)

1. **Cost analysis**
   - Review spend per project
   - Calculate average cost per task type
   - Update COST_ANALYSIS.md

2. **Performance check**
   - How many tasks timed out?
   - Average completion time?
   - Handoff depth patterns?

3. **Capacity planning**
   - Daily spend trending up?
   - Need to increase budget?
   - Adjust concurrent agent limit?

### Monthly Audit (30 minutes)

1. **Budget review**
   - Total monthly spend
   - Cost per project
   - Budget utilization %

2. **System optimization**
   - Tune ESTIMATED_COST_PER_AGENT_RUN
   - Adjust timeout defaults
   - Optimize handoff patterns

3. **Backup verification**
   - Test restore from backup
   - Verify backup completeness
   - Update disaster recovery plan

---

## Emergency Procedures

### Runaway Costs

**Symptom:** Daily spend spiking unexpectedly

**Immediate action:**
```bash
# 1. Check spend FIRST (while orchestrator is still running)
curl -H "X-API-Key: YOUR_KEY" http://your-server:8000/spend

# 2. Review what's running
curl http://your-server:8000/tasks

# 3. THEN stop orchestrator to halt new agent spawns
sudo systemctl stop claude-orchestrator

# 4. If you already stopped it, read the ledger from disk:
cat ~/claude-memory/_spend_ledger.json | python3 -m json.tool
```

**Investigation:**
- Which project caused spike?
- Was it a legitimate complex task?
- Or a runaway handoff loop?

**Resolution:**
- Fix agent prompt if loop detected
- Increase budget if task was legitimate
- Set stricter limits before restarting

---

### System Unresponsive

**Symptom:** Orchestrator not responding

**Diagnosis:**
```bash
# Check if running
sudo systemctl status claude-orchestrator

# Check system resources
top
df -h
```

**Recovery:**
```bash
# 1. Restart orchestrator
sudo systemctl restart claude-orchestrator

# 2. If still unresponsive, check logs
sudo journalctl -u claude-orchestrator -n 100

# 3. If logs show crash, check system resources
# Possible causes: disk full, memory exhausted
```

---

### Data Corruption

**Symptom:** Spend ledger or project state files corrupted

**Recovery:**
```bash
# 1. Stop orchestrator
sudo systemctl stop claude-orchestrator

# 2. Restore from backup
cd ~/claude-memory
mv _spend_ledger.json _spend_ledger.json.corrupted
tar -xzf ~/backups/claude-memory-20260214.tar.gz

# 3. Restart
sudo systemctl start claude-orchestrator
```

---

## Configuration Reference

### Key .env Settings

**Budget controls:**
- `DAILY_BUDGET_USD` - Daily spend limit (all projects)
- `PROJECT_BUDGET_USD` - Per-project spend limit
- `ESTIMATED_COST_PER_AGENT_RUN` - Cost estimate for budget math

**Performance:**
- `MAX_CONCURRENT_AGENTS` - Parallel agent limit (2-5)
- `AGENT_TIMEOUT_SECONDS` - Max agent runtime (1800-3600)
- `MAX_HANDOFF_DEPTH` - Auto-handoff chain limit (2-5)

**Behavior:**
- `AUTO_HANDOFF` - Enable autonomous handoffs (true/false)
- `CLAUDE_SKIP_PERMISSIONS` - Skip approval prompts (DANGEROUS)

**Paths:**
- `CLAUDE_MEMORY_DIR` - Memory storage location
- `CLAUDE_RESOURCES_DIR` - Context files location

---

## Support & Escalation

### Check Logs

**Orchestrator logs:**
```bash
sudo journalctl -u claude-orchestrator -n 100 --no-pager
```

**Agent logs:**
```bash
cat ~/claude-memory/projects/{project}/logs/{task_id}.json
```

**System logs:**
```bash
dmesg | tail -50
```

### Useful Diagnostics

**Check disk space:**
```bash
df -h ~/claude-memory
```

**Check memory usage:**
```bash
free -h
```

**Check open files:**
```bash
lsof | grep claude
```

**Check network:**
```bash
netstat -tlnp | grep 8000
```

---

## Quick Command Reference

```bash
# Health
curl http://your-server:8000/health

# Spend
curl -H "X-API-Key: KEY" http://your-server:8000/spend

# Tasks
curl http://your-server:8000/tasks

# Project status
curl http://your-server:8000/status/{project}

# Reset project spend
curl -X POST -H "X-API-Key: KEY" http://your-server:8000/spend/reset-project/{name}

# Retry stuck handoff
curl -X POST -H "X-API-Key: KEY" http://your-server:8000/handoffs/{project}/retry/{handoff_id}

# Restart orchestrator
sudo systemctl restart claude-orchestrator

# View logs
sudo journalctl -u claude-orchestrator -f

# Read spend ledger directly (when orchestrator is stopped)
cat ~/claude-memory/_spend_ledger.json | python3 -m json.tool
```

---

**Remember:** Most issues are budget/timeout related. Check those first.
