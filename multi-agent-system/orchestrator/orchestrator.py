"""
Claude Agent Orchestrator

Routes tasks to the right agents, manages handoffs, tracks project state.
Runs as a FastAPI service on the mini PC.

v3.2.0 — Single source of truth:
  - Core logic extracted to core.py (importable by tests without side effects)
  - Single project_routes.json (no more dual-copy desync)
  - Actual token usage parsed from Claude CLI stderr
  - Atomic ledger writes (survives power loss / kill -9)
  - Log rotation (prevents disk fill on mini PC)
  - All from v3.1.x: routing fix, UTC timezone, graceful shutdown, etc.
"""

import asyncio
import json
import logging
import os
import signal
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import APIKeyHeader
from pydantic import BaseModel

from core import SpendTracker, load_routes, detect_task_type, parse_token_usage, rotate_logs

load_dotenv()

# ── Configuration ──────────────────────────────────────────────────────

MEMORY_DIR = Path(os.getenv("CLAUDE_MEMORY_DIR", str(Path.home() / "claude-memory")))
RESOURCES_DIR = Path(os.getenv("CLAUDE_RESOURCES_DIR", str(Path.home() / "Claude")))
AUTO_HANDOFF = os.getenv("AUTO_HANDOFF", "true").lower() == "true"
MAX_CONCURRENT = int(os.getenv("MAX_CONCURRENT_AGENTS", "3"))
MAX_HANDOFF_DEPTH = int(os.getenv("MAX_HANDOFF_DEPTH", "5"))
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
SKIP_PERMISSIONS = os.getenv("CLAUDE_SKIP_PERMISSIONS", "false").lower() == "true"
ORCHESTRATOR_API_KEY = os.getenv("ORCHESTRATOR_API_KEY", "")
FAILURE_WEBHOOK_URL = os.getenv("FAILURE_WEBHOOK_URL", "")

# ── Budget & Timeout Controls ─────────────────────────────────────────
AGENT_TIMEOUT_SECONDS = int(os.getenv("AGENT_TIMEOUT_SECONDS", "1800"))  # 30 min default
DAILY_BUDGET_USD = float(os.getenv("DAILY_BUDGET_USD", "50.0"))
PROJECT_BUDGET_USD = float(os.getenv("PROJECT_BUDGET_USD", "25.0"))
ESTIMATED_COST_PER_AGENT_RUN = float(os.getenv("ESTIMATED_COST_PER_AGENT_RUN", "2.50"))
MAX_LOGS_PER_PROJECT = int(os.getenv("MAX_LOGS_PER_PROJECT", "200"))

PROJECTS_DIR = MEMORY_DIR / "projects"
AGENTS_DIR = RESOURCES_DIR / "multi-agent-system" / "agent-templates"
PROFILE_PATH = RESOURCES_DIR / "YOUR_WORKING_PROFILE.md"
TASKS_STATE_FILE = MEMORY_DIR / "_tasks_state.json"
SPEND_LEDGER_FILE = MEMORY_DIR / "_spend_ledger.json"

logging.basicConfig(level=getattr(logging, LOG_LEVEL), format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("orchestrator")


# ── Initialize Core Components ────────────────────────────────────────

spend_tracker = SpendTracker(
    ledger_path=SPEND_LEDGER_FILE,
    daily_budget=DAILY_BUDGET_USD,
    project_budget=PROJECT_BUDGET_USD,
    logger=logger,
)

ROUTES_FILE = Path(__file__).parent / "project_routes.json"
TASK_ROUTING, KEYWORDS, PRIORITIES, DEFAULT_TASK_TYPE = load_routes(
    routes_file=ROUTES_FILE,
    fallback_cost=ESTIMATED_COST_PER_AGENT_RUN,
)

if not TASK_ROUTING:
    logger.warning(f"No routes loaded from {ROUTES_FILE} — all tasks will use default agent")
else:
    logger.info(f"Loaded {len(TASK_ROUTING)} task routes from {ROUTES_FILE}")


# ── Failure Notifications ─────────────────────────────────────────────

async def notify_failure(agent: str, project: str, task: str, error: str) -> None:
    if not FAILURE_WEBHOOK_URL:
        return
    try:
        import httpx
        payload = {
            "content": (
                f"\U0001f6a8 **Agent Failed**\n**Agent:** {agent}\n"
                f"**Project:** {project}\n**Task:** {task[:200]}\n**Error:** {error[:300]}"
            ),
            "agent": agent, "project": project,
            "task": task[:200], "error": error[:300],
            "timestamp": datetime.now().isoformat(),
        }
        async with httpx.AsyncClient(timeout=10) as client:
            await client.post(FAILURE_WEBHOOK_URL, json=payload)
    except Exception as e:
        logger.warning(f"Failed to send failure webhook: {e}")


def _notify_task_completion(
    task_id: str, agent: str, project: str, status: str, actual_cost: float = None,
) -> None:
    """Push task completion/failure to Telegram webhook (fire-and-forget)."""
    webhook_url = FAILURE_WEBHOOK_URL.replace("/webhook", "/webhook/task") if FAILURE_WEBHOOK_URL else ""
    if not webhook_url:
        return
    try:
        import urllib.request
        data = json.dumps({
            "task_id": task_id, "agent": agent, "project": project,
            "status": status, "actual_cost": actual_cost,
        }).encode()
        req = urllib.request.Request(
            webhook_url, data=data,
            headers={"Content-Type": "application/json"}, method="POST",
        )
        urllib.request.urlopen(req, timeout=5)
    except Exception:
        pass  # Don't let notification failures affect task processing


# ── API Key Authentication ─────────────────────────────────────────────

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)


async def verify_api_key(api_key: Optional[str] = Depends(api_key_header)):
    if not ORCHESTRATOR_API_KEY:
        logger.warning("ORCHESTRATOR_API_KEY not set — API is UNPROTECTED. Set it in .env!")
        return
    if api_key != ORCHESTRATOR_API_KEY:
        raise HTTPException(status_code=401, detail="Invalid or missing API key. Pass X-API-Key header.")


# ── Models ─────────────────────────────────────────────────────────────

class TaskRequest(BaseModel):
    task: str
    project: str
    auto_handoff: Optional[bool] = None
    working_dir: Optional[str] = None
    handoff_depth: int = 0


class TaskResponse(BaseModel):
    task_id: str
    task_type: str
    agent: str
    project: str
    status: str
    message: str
    estimated_cost: Optional[float] = None


class ProjectStatus(BaseModel):
    project: str
    status: str
    agents: list[str]
    created: str
    last_updated: str
    current_phase: Optional[str] = None
    metadata: Optional[dict] = None
    total_spend: Optional[float] = None


# ── Task State Persistence ────────────────────────────────────────────

def load_tasks_state() -> dict:
    if TASKS_STATE_FILE.exists():
        try:
            return json.loads(TASKS_STATE_FILE.read_text())
        except (json.JSONDecodeError, OSError):
            logger.warning("Failed to load tasks state file, starting fresh")
    return {}


def save_tasks_state(tasks: dict) -> None:
    TASKS_STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    try:
        TASKS_STATE_FILE.write_text(json.dumps(tasks, indent=2, default=str))
    except OSError as e:
        logger.error(f"Failed to save tasks state: {e}")


# ── Project & Agent Helpers ───────────────────────────────────────────

def load_project_state(project: str) -> dict:
    state_file = PROJECTS_DIR / project / "_state.json"
    if state_file.exists():
        return json.loads(state_file.read_text())
    return {
        "project": project, "status": "new", "agents": [],
        "created": datetime.now().isoformat(),
        "lastUpdated": datetime.now().isoformat(),
    }


def save_project_state(project: str, state: dict) -> None:
    project_dir = PROJECTS_DIR / project
    project_dir.mkdir(parents=True, exist_ok=True)
    state["lastUpdated"] = datetime.now().isoformat()
    (project_dir / "_state.json").write_text(json.dumps(state, indent=2))


def load_agent_template(agent_name: str) -> str:
    template_path = AGENTS_DIR / f"{agent_name}.md"
    if template_path.exists():
        return template_path.read_text()
    return f"You are the {agent_name} agent."


def load_profile() -> str:
    if PROFILE_PATH.exists():
        return PROFILE_PATH.read_text()
    return ""


def get_pending_handoffs(project: str, to_agent: Optional[str] = None) -> list[dict]:
    handoff_dir = PROJECTS_DIR / project / "handoffs"
    if not handoff_dir.exists():
        return []
    handoffs = []
    for f in handoff_dir.glob("*.json"):
        data = json.loads(f.read_text())
        if data.get("status") == "pending":
            if to_agent is None or data.get("to") == to_agent:
                handoffs.append(data)
    handoffs.sort(key=lambda h: h.get("timestamp", ""))
    return handoffs


# ── Agent Spawning ────────────────────────────────────────────────────

async def spawn_claude_agent(
    agent_name: str, task: str, project: str, context: str,
    state: dict, working_dir: Optional[str] = None,
) -> dict:
    """Spawn a Claude Code CLI process in non-interactive --print mode.

    Agents CANNOT ask the user questions. The prompt instructs them to
    make reasonable defaults and document assumptions instead.

    Token usage is parsed from stderr when available.
    """
    profile = load_profile()
    template = load_agent_template(agent_name)
    handoffs = get_pending_handoffs(project, to_agent=agent_name)

    prompt_parts = [
        "=== YOUR WORKING PROFILE ===", profile, "",
        "=== YOUR AGENT ROLE ===", template, "",
        "=== CONTEXT ===", context, "",
        "=== PROJECT STATE ===", json.dumps(state, indent=2),
    ]

    if handoffs:
        prompt_parts += ["", "=== PENDING HANDOFFS TO YOU ===", json.dumps(handoffs, indent=2)]

    prompt_parts += [
        "", "=== YOUR TASK ===", task, "",
        "=== AUTONOMOUS MODE INSTRUCTIONS ===",
        "You are running in AUTONOMOUS mode (non-interactive, --print).",
        "You CANNOT ask the user questions — there is no human at the terminal.",
        "Instead:",
        "  - Make reasonable default decisions and document your assumptions.",
        "  - Store assumptions as 'decision' type memories so the user can review.",
        "  - If a decision is truly blocking (e.g. which chain to deploy to),",
        "    create a handoff to 'product-manager' with your options listed.",
        "  - Prefer shipping something reviewable over blocking on uncertainty.",
        "",
        "Use the memory MCP tools (store_memory, recall_memory, update_project_state,",
        "create_agent_handoff) throughout your work.",
        "At completion, always update_project_state and create_agent_handoff",
        "if another agent needs to continue.",
    ]

    full_prompt = "\n".join(prompt_parts)
    cwd = working_dir or str(Path.home())

    logger.info(f"Spawning agent '{agent_name}' for project '{project}' task: {task[:80]}...")

    cli_args = ["claude", "--print"]
    if SKIP_PERMISSIONS:
        logger.warning(f"Agent '{agent_name}' running with --dangerously-skip-permissions")
        cli_args.append("--dangerously-skip-permissions")

    try:
        proc = await asyncio.create_subprocess_exec(
            *cli_args,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=cwd,
        )

        stdout, stderr = await asyncio.wait_for(
            proc.communicate(full_prompt.encode()),
            timeout=AGENT_TIMEOUT_SECONDS,
        )

        output = stdout.decode() if stdout else ""
        errors = stderr.decode() if stderr else ""
        logger.info(f"Agent '{agent_name}' completed with exit code {proc.returncode}")

        # Parse token usage from stderr
        token_usage = parse_token_usage(errors)
        if token_usage:
            logger.info(
                f"Agent '{agent_name}' token usage: "
                f"input={token_usage.get('input_tokens', '?')}, "
                f"output={token_usage.get('output_tokens', '?')}, "
                f"actual_cost=${token_usage.get('actual_cost', '?')}"
            )

        return {
            "agent": agent_name, "project": project,
            "output": output, "errors": errors,
            "exit_code": proc.returncode,
            "timestamp": datetime.now().isoformat(),
            "token_usage": token_usage,
        }
    except asyncio.TimeoutError:
        timeout_min = AGENT_TIMEOUT_SECONDS // 60
        msg = f"Agent timed out after {timeout_min} minutes"
        logger.warning(f"Agent '{agent_name}' {msg}")
        await notify_failure(agent_name, project, task, msg)
        state["status"] = "timeout"
        state["metadata"] = {**(state.get("metadata") or {}), "timeout_agent": agent_name}
        save_project_state(project, state)
        return {"agent": agent_name, "project": project, "output": "", "errors": msg, "exit_code": -1, "timestamp": datetime.now().isoformat(), "token_usage": None}
    except FileNotFoundError:
        msg = "Claude CLI not found — is it installed?"
        logger.error("Claude CLI not found. Ensure 'claude' is on PATH.")
        await notify_failure(agent_name, project, task, msg)
        return {"agent": agent_name, "project": project, "output": "", "errors": "Claude CLI not found. Install with: npm install -g @anthropic-ai/claude-code", "exit_code": -1, "timestamp": datetime.now().isoformat(), "token_usage": None}
    except Exception as e:
        msg = f"Unexpected error: {str(e)}"
        logger.error(f"Agent '{agent_name}' crashed: {msg}")
        await notify_failure(agent_name, project, task, msg)
        state["status"] = "error"
        state["metadata"] = {**(state.get("metadata") or {}), "error_agent": agent_name, "error": msg}
        save_project_state(project, state)
        return {"agent": agent_name, "project": project, "output": "", "errors": msg, "exit_code": -1, "timestamp": datetime.now().isoformat(), "token_usage": None}


# ── Task Routing & Execution ──────────────────────────────────────────

_agent_semaphore = asyncio.Semaphore(MAX_CONCURRENT)
_running_tasks: dict[str, dict] = load_tasks_state()


async def route_and_execute(req: TaskRequest) -> TaskResponse:
    """Detect task type, check budget, load context, spawn agent, optionally auto-handoff."""

    if req.handoff_depth > MAX_HANDOFF_DEPTH:
        logger.warning(f"Handoff depth {req.handoff_depth} exceeds max {MAX_HANDOFF_DEPTH} for '{req.project}'.")
        return TaskResponse(
            task_id=f"{int(datetime.now().timestamp())}-depth-limit",
            task_type="blocked", agent="none", project=req.project, status="blocked",
            message=f"Auto-handoff chain stopped: depth {req.handoff_depth} > limit {MAX_HANDOFF_DEPTH}. Review with GET /handoffs/{req.project}",
        )

    # Detect task type using core.detect_task_type (single source of truth)
    task_type = detect_task_type(req.task, KEYWORDS, PRIORITIES, DEFAULT_TASK_TYPE)
    routing = TASK_ROUTING.get(task_type, {"agent": "generalist", "context_type": "general", "cost_estimate": ESTIMATED_COST_PER_AGENT_RUN})
    agent_name = routing["agent"]
    cost_estimate = routing.get("cost_estimate", ESTIMATED_COST_PER_AGENT_RUN)

    # Budget check with task-specific cost
    allowed, reason = spend_tracker.can_spend(req.project, cost_estimate)
    if not allowed:
        logger.warning(f"Budget exceeded for '{req.project}': {reason}")
        return TaskResponse(
            task_id=f"{int(datetime.now().timestamp())}-budget-blocked",
            task_type=task_type, agent=agent_name, project=req.project,
            status="budget-exceeded", message=reason,
        )

    state = load_project_state(req.project)
    if agent_name not in state.get("agents", []):
        state.setdefault("agents", []).append(agent_name)
    state["status"] = "in-progress"
    save_project_state(req.project, state)

    task_id = f"{int(datetime.now().timestamp())}-{agent_name}"
    context = f"Task type detected: {task_type} ({routing['context_type']})"
    use_auto_handoff = req.auto_handoff if req.auto_handoff is not None else AUTO_HANDOFF

    async def _run() -> None:
        async with _agent_semaphore:
            result = await spawn_claude_agent(
                agent_name=agent_name, task=req.task, project=req.project,
                context=context, state=state, working_dir=req.working_dir,
            )

            # Extract actual cost from token usage if available
            token_usage = result.get("token_usage")
            actual_cost = token_usage.get("actual_cost") if token_usage else None

            # Record spend: estimated for budget enforcement, actual for tracking
            spend_tracker.record_spend(req.project, cost_estimate, actual=actual_cost)

            if actual_cost is not None:
                drift = actual_cost - cost_estimate
                drift_pct = (drift / cost_estimate * 100) if cost_estimate > 0 else 0
                logger.info(
                    f"Cost for '{task_type}': estimated=${cost_estimate:.2f}, "
                    f"actual=${actual_cost:.2f} ({drift_pct:+.0f}%)"
                )

            # Save task log
            log_dir = PROJECTS_DIR / req.project / "logs"
            log_dir.mkdir(parents=True, exist_ok=True)
            (log_dir / f"{task_id}.json").write_text(json.dumps(result, indent=2))

            # Rotate logs if project has too many
            deleted = rotate_logs(log_dir, MAX_LOGS_PER_PROJECT)
            if deleted:
                logger.info(f"Rotated {deleted} old log files for project '{req.project}'")

            if result.get("exit_code", -1) == 0:
                _running_tasks[task_id]["status"] = "completed"
            else:
                _running_tasks[task_id]["status"] = "failed"
                _running_tasks[task_id]["error"] = result.get("errors", "unknown")

            _running_tasks[task_id]["result"] = result
            if actual_cost is not None:
                _running_tasks[task_id]["actual_cost"] = actual_cost
            save_tasks_state(_running_tasks)

            # Push task completion/failure notification via Telegram webhook
            _notify_task_completion(
                task_id, agent_name, req.project,
                _running_tasks[task_id]["status"], actual_cost,
            )

            # Only auto-handoff on success
            if use_auto_handoff and result.get("exit_code", -1) == 0:
                new_handoffs = get_pending_handoffs(req.project)
                for handoff in new_handoffs:
                    to_agent = handoff.get("to", "")
                    handoff_task = handoff.get("task", "")
                    if to_agent and handoff_task:
                        logger.info(f"Auto-handoff: {agent_name} -> {to_agent} (depth {req.handoff_depth + 1}/{MAX_HANDOFF_DEPTH})")
                        handoff_req = TaskRequest(
                            task=handoff_task, project=req.project, auto_handoff=True,
                            working_dir=req.working_dir, handoff_depth=req.handoff_depth + 1,
                        )
                        asyncio.create_task(route_and_execute(handoff_req))
            elif result.get("exit_code", -1) != 0:
                logger.warning(f"Agent '{agent_name}' failed (exit {result.get('exit_code')}). Skipping auto-handoff.")

    _running_tasks[task_id] = {
        "status": "running", "agent": agent_name, "project": req.project,
        "started": datetime.now().isoformat(), "handoff_depth": req.handoff_depth,
        "estimated_cost": cost_estimate, "task_type": task_type,
    }
    save_tasks_state(_running_tasks)
    asyncio.create_task(_run())

    return TaskResponse(
        task_id=task_id, task_type=task_type, agent=agent_name, project=req.project,
        status="running", message=f"Agent '{agent_name}' spawned for task type '{task_type}'",
        estimated_cost=cost_estimate,
    )


# ── FastAPI App ────────────────────────────────────────────────────────

app = FastAPI(
    title="Claude Agent Orchestrator",
    description="Routes tasks to Claude agents, manages coordination and memory.",
    version="4.0.0",
    dependencies=[Depends(verify_api_key)],
)


@app.post("/route", response_model=TaskResponse)
async def route_task(req: TaskRequest):
    """Submit a task."""
    return await route_and_execute(req)


@app.get("/status/{project}", response_model=ProjectStatus)
async def get_project_status(project: str):
    state = load_project_state(project)
    return ProjectStatus(
        project=state.get("project", project), status=state.get("status", "unknown"),
        agents=state.get("agents", []), created=state.get("created", ""),
        last_updated=state.get("lastUpdated", ""), current_phase=state.get("currentPhase"),
        metadata=state.get("metadata"), total_spend=round(spend_tracker.project_spend(project), 2),
    )


@app.get("/tasks")
async def list_running_tasks():
    return _running_tasks


@app.get("/tasks/{task_id}")
async def get_task(task_id: str):
    if task_id not in _running_tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    return _running_tasks[task_id]


@app.get("/projects")
async def list_projects():
    if not PROJECTS_DIR.exists():
        return []
    projects = []
    for d in PROJECTS_DIR.iterdir():
        if d.is_dir():
            state = load_project_state(d.name)
            state["total_spend"] = round(spend_tracker.project_spend(d.name), 2)
            projects.append(state)
    projects.sort(key=lambda s: s.get("lastUpdated", ""), reverse=True)
    return projects


@app.get("/handoffs/{project}")
async def list_handoffs(project: str):
    handoff_dir = PROJECTS_DIR / project / "handoffs"
    if not handoff_dir.exists():
        return []
    handoffs = []
    for f in handoff_dir.glob("*.json"):
        handoffs.append(json.loads(f.read_text()))
    handoffs.sort(key=lambda h: h.get("timestamp", ""), reverse=True)
    return handoffs


@app.get("/memories/{project}")
async def list_memories(project: str, limit: int = 20):
    mem_dir = PROJECTS_DIR / project / "memories"
    if not mem_dir.exists():
        return []
    memories = []
    for f in sorted(mem_dir.glob("*.json"), reverse=True)[:limit]:
        memories.append(json.loads(f.read_text()))
    return memories


@app.get("/spend", dependencies=[Depends(verify_api_key)])
async def get_spend_summary():
    """Current spend tracking summary, including actual costs where available."""
    return spend_tracker.get_summary()


@app.post("/spend/reset-project/{project}", dependencies=[Depends(verify_api_key)])
async def reset_project_spend(project: str):
    """Reset spend counter for a project."""
    spend_tracker.ledger.setdefault("projects", {})[project] = 0.0
    spend_tracker.ledger.setdefault("actuals", {}).setdefault("projects", {})[project] = 0.0
    spend_tracker._save()
    return {"message": f"Spend reset for '{project}'", "new_balance": 0.0}


@app.post("/handoffs/{project}/retry/{handoff_id}", dependencies=[Depends(verify_api_key)])
async def retry_handoff(project: str, handoff_id: str):
    """Reset a stuck 'accepted' handoff back to 'pending' for retry."""
    handoff_dir = PROJECTS_DIR / project / "handoffs"
    if not handoff_dir.exists():
        raise HTTPException(status_code=404, detail=f"No handoffs directory for project '{project}'")

    for f in handoff_dir.glob("*.json"):
        data = json.loads(f.read_text())
        if data.get("id", "").startswith(handoff_id):
            if data.get("status") == "accepted":
                data["status"] = "pending"
                data["retry_count"] = data.get("retry_count", 0) + 1
                data["retried_at"] = datetime.now(timezone.utc).isoformat()
                f.write_text(json.dumps(data, indent=2))
                return {
                    "message": f"Handoff {handoff_id} reset to pending (retry #{data['retry_count']})",
                    "handoff": data,
                }
            elif data.get("status") == "completed":
                raise HTTPException(status_code=400, detail="Handoff already completed — nothing to retry")
            elif data.get("status") == "pending":
                raise HTTPException(status_code=400, detail="Handoff already pending — it hasn't been picked up yet")

    raise HTTPException(status_code=404, detail=f"Handoff '{handoff_id}' not found in project '{project}'")


@app.get("/health", dependencies=[])
async def health():
    return {
        "status": "healthy", "version": "3.2.0",
        "memory_dir": str(MEMORY_DIR), "resources_dir": str(RESOURCES_DIR),
        "auto_handoff": AUTO_HANDOFF, "max_concurrent": MAX_CONCURRENT,
        "max_handoff_depth": MAX_HANDOFF_DEPTH,
        "agent_timeout_seconds": AGENT_TIMEOUT_SECONDS,
        "skip_permissions": SKIP_PERMISSIONS,
        "api_key_configured": bool(ORCHESTRATOR_API_KEY),
        "running_tasks": sum(1 for t in _running_tasks.values() if t.get("status") == "running"),
        "daily_spend": round(spend_tracker.daily_spend(), 2),
        "daily_budget": DAILY_BUDGET_USD,
        "max_logs_per_project": MAX_LOGS_PER_PROJECT,
    }


# ── Entrypoint ─────────────────────────────────────────────────────────

_shutdown_event = asyncio.Event()


def _handle_shutdown(sig, frame):
    """Graceful shutdown: stop accepting new tasks, let running agents finish."""
    running = sum(1 for t in _running_tasks.values() if t.get("status") == "running")
    logger.info(f"Received {signal.Signals(sig).name}. Shutting down gracefully ({running} agents still running)...")
    _shutdown_event.set()


if __name__ == "__main__":
    import uvicorn

    signal.signal(signal.SIGTERM, _handle_shutdown)
    signal.signal(signal.SIGINT, _handle_shutdown)

    host = os.getenv("ORCHESTRATOR_HOST", "127.0.0.1")
    port = int(os.getenv("ORCHESTRATOR_PORT", "8000"))

    logger.info(f"Starting orchestrator on {host}:{port}")
    logger.info(f"Memory dir: {MEMORY_DIR}")
    logger.info(f"Resources dir: {RESOURCES_DIR}")
    logger.info(f"Auto-handoff: {AUTO_HANDOFF} | Max concurrent: {MAX_CONCURRENT}")
    logger.info(f"Max handoff depth: {MAX_HANDOFF_DEPTH}")
    logger.info(f"Agent timeout: {AGENT_TIMEOUT_SECONDS}s ({AGENT_TIMEOUT_SECONDS // 60}min)")
    logger.info(f"Daily budget: ${DAILY_BUDGET_USD:.2f} | Project budget: ${PROJECT_BUDGET_USD:.2f}")
    logger.info(f"Max logs per project: {MAX_LOGS_PER_PROJECT}")
    logger.info(f"Skip permissions: {SKIP_PERMISSIONS}")
    logger.info(f"API key configured: {bool(ORCHESTRATOR_API_KEY)}")

    if not ORCHESTRATOR_API_KEY:
        logger.warning("=" * 60)
        logger.warning("  WARNING: ORCHESTRATOR_API_KEY not set!")
        logger.warning("  API is unprotected. Set ORCHESTRATOR_API_KEY in .env.")
        logger.warning("=" * 60)

    uvicorn.run(app, host=host, port=port)
