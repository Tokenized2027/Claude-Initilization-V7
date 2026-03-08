#!/usr/bin/env python3
"""
Telegram Command Bot for Mini PC — v2.0.0
==========================================
Conversational AI interface to the mini PC via Telegram.
Supports text messages, voice messages, and slash commands.

How it works:
  - Text/voice messages → Claude Haiku interprets intent → executes actions → responds
  - Slash commands still work as before (direct, no AI overhead)
  - Voice messages → local Whisper (speech-to-text) → same as text

Security:
  - Only responds to AUTHORIZED_USER_ID (Telegram user ID whitelist)
  - Requires password authentication every 12 hours
  - Auto-locks after session expiry
  - All commands logged

Webhook server (port 8787):
  - Receives POST /webhook from orchestrator on agent failures
  - Receives POST /webhook/alert for generic alerts (disk, health, etc.)
  - Pushes notifications to Telegram proactively (no auth needed for push)
  - Only accepts from localhost (127.0.0.1) by default

v2.0.0 — February 2026
"""

import asyncio
import hashlib
import json
import logging
import os
import subprocess
import tempfile
import threading
import time
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

from dotenv import load_dotenv
from telegram import Update
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    ContextTypes,
    filters,
)

load_dotenv()

# ── Configuration ──────────────────────────────────────────────────────

BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
AUTHORIZED_USER_ID = int(os.getenv("TELEGRAM_AUTHORIZED_USER_ID", "0"))
SESSION_PASSWORD_HASH = os.getenv("TELEGRAM_SESSION_PASSWORD_HASH", "")
SESSION_DURATION_SECONDS = int(os.getenv("TELEGRAM_SESSION_DURATION_SECONDS", str(12 * 3600)))
ORCHESTRATOR_URL = os.getenv("ORCHESTRATOR_URL", "http://localhost:8000")
ORCHESTRATOR_API_KEY = os.getenv("ORCHESTRATOR_API_KEY", "")
LOG_FILE = Path(os.getenv("TELEGRAM_BOT_LOG", str(Path.home() / "logs" / "telegram-bot.log")))
WEBHOOK_PORT = int(os.getenv("TELEGRAM_WEBHOOK_PORT", "8787"))
WEBHOOK_BIND = os.getenv("TELEGRAM_WEBHOOK_BIND", "127.0.0.1")
MAX_MESSAGE_LENGTH = 4000

# AI Configuration
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
AI_MODEL = os.getenv("TELEGRAM_AI_MODEL", "claude-haiku-4-5-20251001")
AI_MAX_TOKENS = int(os.getenv("TELEGRAM_AI_MAX_TOKENS", "1024"))
AI_ENABLED = os.getenv("TELEGRAM_AI_ENABLED", "true").lower() == "true"

# Voice Configuration
WHISPER_API_URL = os.getenv("WHISPER_API_URL", "http://127.0.0.1:9000")
WHISPER_LANGUAGE = os.getenv("WHISPER_LANGUAGE", "en")

LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("telegram-bot")

# ── Session Management ─────────────────────────────────────────────────

_session: dict = {
    "authenticated": False,
    "authenticated_at": 0.0,
    "failed_attempts": 0,
    "locked_until": 0.0,
}

MAX_FAILED_ATTEMPTS = 5
LOCKOUT_DURATION = 300


def hash_password(password: str) -> str:
    return hashlib.sha256(password.strip().encode()).hexdigest()


def is_session_valid() -> bool:
    if not _session["authenticated"]:
        return False
    elapsed = time.time() - _session["authenticated_at"]
    if elapsed > SESSION_DURATION_SECONDS:
        _session["authenticated"] = False
        logger.info("Session expired (12h timeout)")
        return False
    return True


def is_locked_out() -> bool:
    if _session["locked_until"] > time.time():
        return True
    if _session["locked_until"] > 0:
        _session["locked_until"] = 0.0
        _session["failed_attempts"] = 0
    return False


def session_remaining() -> str:
    if not _session["authenticated"]:
        return "not authenticated"
    remaining = SESSION_DURATION_SECONDS - (time.time() - _session["authenticated_at"])
    if remaining <= 0:
        return "expired"
    hours = int(remaining // 3600)
    minutes = int((remaining % 3600) // 60)
    return f"{hours}h {minutes}m"


# ── Authorization ──────────────────────────────────────────────────────

def is_authorized_user(update: Update) -> bool:
    return update.effective_user and update.effective_user.id == AUTHORIZED_USER_ID


async def require_auth(update: Update) -> bool:
    if not is_authorized_user(update):
        logger.warning(f"Unauthorized access attempt from user {update.effective_user.id}")
        return False
    if is_locked_out():
        remaining = int(_session["locked_until"] - time.time())
        await update.message.reply_text(f"🔒 Too many failed attempts. Locked for {remaining}s.")
        return False
    if not is_session_valid():
        await update.message.reply_text("🔐 Session expired. Send your password to unlock.")
        return False
    return True


# ── Shell & Orchestrator Helpers ───────────────────────────────────────

def run_cmd(cmd: str, timeout: int = 30) -> str:
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        output = (result.stdout + result.stderr).strip()
        if len(output) > MAX_MESSAGE_LENGTH:
            output = output[:MAX_MESSAGE_LENGTH] + "\n\n... (truncated)"
        return output or "(no output)"
    except subprocess.TimeoutExpired:
        return f"⏰ Command timed out after {timeout}s"
    except Exception as e:
        return f"❌ Error: {e}"


def call_orchestrator(method: str, endpoint: str, data: dict = None) -> dict:
    import urllib.request
    import urllib.error

    url = f"{ORCHESTRATOR_URL}{endpoint}"
    headers = {"Content-Type": "application/json"}
    if ORCHESTRATOR_API_KEY:
        headers["X-API-Key"] = ORCHESTRATOR_API_KEY

    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}: {e.read().decode()[:500]}"}
    except Exception as e:
        return {"error": str(e)}


# ── Voice Transcription (via Whisper API Service) ──────────────────────


async def transcribe_voice(update: Update) -> str | None:
    """Download voice message and transcribe via the shared Whisper service."""
    try:
        voice = update.message.voice or update.message.audio
        if not voice:
            return None

        file = await voice.get_file()
        with tempfile.NamedTemporaryFile(suffix=".ogg", delete=False) as tmp:
            tmp_path = tmp.name
            await file.download_to_drive(tmp_path)

        # Call the shared Whisper API service
        import urllib.request
        import urllib.error

        url = f"{WHISPER_API_URL}/transcribe"
        boundary = "----WhisperBotBoundary"

        with open(tmp_path, "rb") as f:
            file_data = f.read()

        # Build multipart form data
        body = (
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="language"\r\n\r\n'
            f"{WHISPER_LANGUAGE}\r\n"
            f"--{boundary}\r\n"
            f'Content-Disposition: form-data; name="file"; filename="voice.ogg"\r\n'
            f"Content-Type: audio/ogg\r\n\r\n"
        ).encode() + file_data + f"\r\n--{boundary}--\r\n".encode()

        req = urllib.request.Request(
            url, data=body, method="POST",
            headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        )

        with urllib.request.urlopen(req, timeout=60) as resp:
            result = json.loads(resp.read().decode())

        text = result.get("text", "").strip()
        lang = result.get("language", "?")
        dur = result.get("duration_seconds", "?")
        logger.info(f"Transcribed [{lang}] in {dur}s: {text[:100]}...")

        # Cleanup
        try:
            os.unlink(tmp_path)
        except OSError:
            pass

        return text if text else None

    except urllib.error.URLError as e:
        logger.error(f"Whisper service unreachable: {e}")
        return None
    except Exception as e:
        logger.error(f"Voice transcription failed: {e}")
        return None


# ── AI Conversational Layer (Claude) ───────────────────────────────────

AI_TOOLS = [
    {
        "name": "system_health",
        "description": "Get orchestrator health: running tasks, daily spend, budget, version.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "system_resources",
        "description": "Get CPU load, RAM, disk space, temperature, uptime of the mini PC.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "docker_status",
        "description": "List all Docker containers with status and ports.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "submit_task",
        "description": "Submit a task to the multi-agent orchestrator for autonomous AI execution.",
        "input_schema": {
            "type": "object",
            "properties": {
                "project": {"type": "string", "description": "Project name (e.g. 'my-app', 'project-content')"},
                "task": {"type": "string", "description": "Task description for the agent to execute"},
            },
            "required": ["project", "task"],
        },
    },
    {
        "name": "list_tasks",
        "description": "List all running, completed, and failed tasks.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "project_status",
        "description": "Get detailed status of a specific project: agents used, spend, phase.",
        "input_schema": {
            "type": "object",
            "properties": {
                "project": {"type": "string", "description": "Project name"},
            },
            "required": ["project"],
        },
    },
    {
        "name": "budget_summary",
        "description": "Get spend tracking: daily total, per-project breakdown, budget remaining, actual vs estimated.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "list_projects",
        "description": "List all projects with their status and total spend.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "view_logs",
        "description": "View recent logs from a Docker container or the orchestrator service.",
        "input_schema": {
            "type": "object",
            "properties": {
                "service": {"type": "string", "description": "Container name. Omit for orchestrator journal logs."},
            },
            "required": [],
        },
    },
    {
        "name": "run_shell",
        "description": "Run a shell command on the mini PC. Use for anything not covered by other tools. NEVER run: rm -rf /, shutdown, reboot, mkfs, dd if=, poweroff.",
        "input_schema": {
            "type": "object",
            "properties": {
                "command": {"type": "string", "description": "Shell command to execute"},
            },
            "required": ["command"],
        },
    },
    {
        "name": "restart_container",
        "description": "Restart a Docker container by name.",
        "input_schema": {
            "type": "object",
            "properties": {
                "container": {"type": "string", "description": "Container name to restart"},
            },
            "required": ["container"],
        },
    },
    {
        "name": "trigger_backup",
        "description": "Trigger an immediate PostgreSQL database backup.",
        "input_schema": {"type": "object", "properties": {}, "required": []},
    },
]

DANGEROUS_COMMANDS = ["rm -rf /", "mkfs", "dd if=", "> /dev/sd", "shutdown", "reboot", "poweroff"]


def execute_tool(name: str, args: dict) -> str:
    """Execute a tool call from Claude and return the result as text."""
    try:
        if name == "system_health":
            return json.dumps(call_orchestrator("GET", "/health"), indent=2)

        elif name == "system_resources":
            parts = [
                f"Uptime: {run_cmd('uptime -p', 5)}",
                f"Load: {run_cmd('cat /proc/loadavg', 5)}",
                f"Memory:\n{run_cmd('free -h | head -2', 5)}",
                f"Disk: {run_cmd('df -h / | tail -1', 5)}",
            ]
            temp = run_cmd("cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{printf \"%.1f°C\", $1/1000}'", 5)
            if temp and "Error" not in temp:
                parts.append(f"Temp: {temp}")
            return "\n".join(parts)

        elif name == "docker_status":
            return run_cmd("docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>&1", 10)

        elif name == "submit_task":
            return json.dumps(call_orchestrator("POST", "/route", {"task": args["task"], "project": args["project"]}), indent=2)

        elif name == "list_tasks":
            return json.dumps(call_orchestrator("GET", "/tasks"), indent=2)[:3000]

        elif name == "project_status":
            return json.dumps(call_orchestrator("GET", f"/status/{args['project']}"), indent=2)

        elif name == "budget_summary":
            return json.dumps(call_orchestrator("GET", "/spend"), indent=2)

        elif name == "list_projects":
            return json.dumps(call_orchestrator("GET", "/projects"), indent=2)[:3000]

        elif name == "view_logs":
            svc = args.get("service", "")
            if svc:
                return run_cmd(f"docker logs --tail 30 {svc} 2>&1", 10)
            return run_cmd("journalctl -u claude-orchestrator --no-pager -n 20 2>&1", 10)

        elif name == "run_shell":
            cmd = args["command"]
            if any(d in cmd.lower() for d in DANGEROUS_COMMANDS):
                return "⛔ Command blocked for safety."
            return run_cmd(cmd, timeout=30)

        elif name == "restart_container":
            return run_cmd(f"docker restart {args['container']} 2>&1", 30)

        elif name == "trigger_backup":
            return run_cmd("bash ~/projects/infrastructure/backups/backup-now.sh 2>&1", 120)

        return f"Unknown tool: {name}"

    except Exception as e:
        return f"Tool error: {e}"


AI_SYSTEM_PROMPT = """\
You are a mini PC assistant, running on an always-on development server (Ubuntu).

You help manage the development server, multi-agent AI system, and infrastructure via Telegram messages.

Key context:
- The mini PC runs a multi-agent orchestrator that spawns Claude Code agents for autonomous task execution
- The user is a vibe coder — they describe what they want, AI builds it

Your style:
- Brief, conversational, no corporate fluff — like a capable teammate on Telegram
- Use tools to get real data before answering — don't guess or assume
- When asked about "status" or "how things are going", proactively check health + tasks + spend
- For ambiguous requests, make a reasonable call and note your assumption briefly
- Keep responses concise — this is Telegram, not a report"""


async def ai_respond(user_message: str) -> str:
    """Send message to Claude Haiku with tools, handle tool use loop, return response."""
    if not ANTHROPIC_API_KEY:
        return "⚠️ AI disabled — ANTHROPIC_API_KEY not set. Use /help for slash commands."

    try:
        import anthropic
        client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
    except ImportError:
        return "⚠️ anthropic package not installed. Run: pip install anthropic"

    messages = [{"role": "user", "content": user_message}]

    try:
        for _ in range(8):  # max 8 tool-call rounds
            response = client.messages.create(
                model=AI_MODEL,
                max_tokens=AI_MAX_TOKENS,
                system=AI_SYSTEM_PROMPT,
                tools=AI_TOOLS,
                messages=messages,
            )

            if response.stop_reason == "tool_use":
                tool_results = []
                for block in response.content:
                    if block.type == "tool_use":
                        logger.info(f"AI tool: {block.name}({json.dumps(block.input)[:200]})")
                        result = execute_tool(block.name, block.input)
                        tool_results.append({
                            "type": "tool_result",
                            "tool_use_id": block.id,
                            "content": result[:3000],
                        })

                messages.append({"role": "assistant", "content": response.content})
                messages.append({"role": "user", "content": tool_results})
                continue

            # Final text response
            text_parts = [b.text for b in response.content if hasattr(b, "text")]
            return "\n".join(text_parts).strip() or "(no response)"

        return "⚠️ Stopped after 8 tool rounds."

    except Exception as e:
        logger.error(f"AI error: {e}")
        return f"❌ AI error: {e}\n\nFallback: use /help for slash commands."


# ── Slash Command Handlers ─────────────────────────────────────────────

async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_authorized_user(update):
        return
    await update.message.reply_text(
        "🖥️ Mini PC Bot v2\n\n"
        "Send your password to authenticate.\n"
        "Sessions last 12 hours.\n\n"
        "After auth:\n"
        "• Just talk to me — text or voice 🎤\n"
        "• Or use /help for slash commands"
    )


async def cmd_help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    remaining = session_remaining()
    ai_on = "✅" if (AI_ENABLED and ANTHROPIC_API_KEY) else "❌"

    await update.message.reply_text(
        f"🖥️ Mini PC Bot (session: {remaining})\n\n"
        f"🧠 AI: {ai_on} ({AI_MODEL})\n"
        f"🎤 Voice: Whisper service @ {WHISPER_API_URL}\n\n"
        "💬 Just talk to me naturally!\n"
        "  \"how's the system doing?\"\n"
        "  \"submit a task to build analytics dashboard\"\n"
        "  \"show me disk usage\"\n"
        "  \"restart postgres\"\n"
        "  Or send a voice message 🎤\n\n"
        "⚡ Slash Commands (no AI cost)\n"
        "  /health /system /docker /logs [svc]\n"
        "  /task <proj> <desc> /tasks /status <proj>\n"
        "  /spend /projects /sh <cmd>\n"
        "  /restart <svc> /backup /alerts\n"
        "  /session /lock"
    )


async def cmd_health(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    data = call_orchestrator("GET", "/health")
    if "error" in data:
        await update.message.reply_text(f"❌ Orchestrator unreachable: {data['error']}")
        return
    s = data.get("status", "unknown")
    e = "✅" if s == "healthy" else "⚠️"
    await update.message.reply_text(
        f"{e} Orchestrator: {s}\nVersion: {data.get('version', '?')}\n"
        f"Tasks: {data.get('running_tasks', 0)}\n"
        f"Spend: ${data.get('daily_spend', 0):.2f} / ${data.get('daily_budget', 0):.2f}"
    )


async def cmd_system(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    await update.message.reply_text(
        f"🖥️ System\n\n"
        f"⏱️ {run_cmd('uptime -p', 5)}\n"
        f"📊 Load: {run_cmd('cat /proc/loadavg | awk \"{print $1, $2, $3}\"', 5)}\n"
        f"💾 Disk: {run_cmd('df -h / | tail -1 | awk \"{print $3\\\"/\\\"$2\\\" (\\\"$5\\\")\\\"}'  , 5)}\n"
        f"🧠 {run_cmd('free -h | head -2', 5)}"
    )


async def cmd_docker(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    await update.message.reply_text(f"🐳 Containers\n\n{run_cmd('docker ps --format \"table {{{{.Names}}}}\\t{{{{.Status}}}}\" 2>&1', 10)}")


async def cmd_logs(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    if context.args:
        await update.message.reply_text(f"📋 {context.args[0]}\n\n{run_cmd(f'docker logs --tail 30 {context.args[0]} 2>&1', 10)}")
    else:
        await update.message.reply_text(f"📋 Orchestrator\n\n{run_cmd('journalctl -u claude-orchestrator --no-pager -n 20 2>&1', 10)}")


async def cmd_task(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    if not context.args or len(context.args) < 2:
        await update.message.reply_text("Usage: /task <project> <description>")
        return
    data = call_orchestrator("POST", "/route", {"task": " ".join(context.args[1:]), "project": context.args[0]})
    if "error" in data:
        await update.message.reply_text(f"❌ {data['error']}")
    else:
        await update.message.reply_text(f"✅ Task submitted\nAgent: {data.get('agent', '?')}\nEst: ${data.get('estimated_cost', 0):.2f}")


async def cmd_tasks(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    data = call_orchestrator("GET", "/tasks")
    if isinstance(data, dict) and "error" in data:
        await update.message.reply_text(f"❌ {data['error']}")
        return
    if not data:
        await update.message.reply_text("No tasks.")
        return
    lines = []
    for tid, info in list(data.items())[:10]:
        e = {"running": "🔄", "completed": "✅", "failed": "❌"}.get(info.get("status"), "❓")
        lines.append(f"{e} {info.get('agent', '?')} → {info.get('project', '?')} [{info.get('status')}]")
    await update.message.reply_text("🤖 Tasks\n\n" + "\n".join(lines))


async def cmd_status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    if not context.args:
        await update.message.reply_text("Usage: /status <project>")
        return
    data = call_orchestrator("GET", f"/status/{context.args[0]}")
    if "error" in data:
        await update.message.reply_text(f"❌ {data['error']}")
    else:
        await update.message.reply_text(f"📊 {data.get('project')}\nStatus: {data.get('status')}\nAgents: {', '.join(data.get('agents', []))}\nSpend: ${data.get('total_spend', 0):.2f}")


async def cmd_spend(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    data = call_orchestrator("GET", "/spend")
    if "error" in data:
        await update.message.reply_text(f"❌ {data['error']}")
        return
    msg = f"💰 Daily: ${data.get('daily_spend_today', 0):.2f} / ${data.get('daily_budget', 50):.2f}"
    actual = data.get("actual_daily_spend")
    if actual is not None:
        msg += f"\nActual: ${actual:.2f}"
    projects = data.get("projects", {})
    if projects:
        msg += "\n\nProjects:"
        for n, s in projects.items():
            msg += f"\n  {n}: ${s:.2f}"
    await update.message.reply_text(msg)


async def cmd_projects(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    data = call_orchestrator("GET", "/projects")
    if isinstance(data, dict) and "error" in data:
        await update.message.reply_text(f"❌ {data['error']}")
        return
    if not data:
        await update.message.reply_text("No projects.")
        return
    lines = [f"• {p.get('project')} — {p.get('status')} (${p.get('total_spend', 0):.2f})" for p in data[:15]]
    await update.message.reply_text("📁 Projects\n\n" + "\n".join(lines))


async def cmd_sh(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    if not context.args:
        await update.message.reply_text("Usage: /sh <command>")
        return
    cmd = " ".join(context.args)
    if any(d in cmd.lower() for d in DANGEROUS_COMMANDS):
        await update.message.reply_text("⛔ Blocked for safety.")
        return
    logger.info(f"Shell: {cmd}")
    await update.message.reply_text(f"$ {cmd}\n\n{run_cmd(cmd, 30)}")


async def cmd_restart(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    if not context.args:
        await update.message.reply_text("Usage: /restart <container>")
        return
    await update.message.reply_text(f"🔄 {context.args[0]}\n\n{run_cmd(f'docker restart {context.args[0]} 2>&1', 30)}")


async def cmd_backup(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    await update.message.reply_text("🗄️ Starting backup...")
    await update.message.reply_text(f"🗄️ Result:\n\n{run_cmd('bash ~/projects/infrastructure/backups/backup-now.sh 2>&1', 120)}")


async def cmd_alerts(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not await require_auth(update):
        return
    import urllib.request
    try:
        data = json.dumps({"level": "info", "title": "Webhook Test", "source": "manual", "message": "Push notifications working!"}).encode()
        urllib.request.urlopen(urllib.request.Request(f"http://127.0.0.1:{WEBHOOK_PORT}/webhook/alert", data=data, headers={"Content-Type": "application/json"}, method="POST"), timeout=5)
        await update.message.reply_text("✅ Test alert sent.")
    except Exception as e:
        await update.message.reply_text(f"❌ Webhook test failed: {e}")


async def cmd_session(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_authorized_user(update):
        return
    if is_session_valid():
        await update.message.reply_text(f"🟢 Active. Expires in: {session_remaining()}")
    else:
        await update.message.reply_text("🔴 Not authenticated.")


async def cmd_lock(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_authorized_user(update):
        return
    _session["authenticated"] = False
    _session["authenticated_at"] = 0.0
    logger.info("Session locked")
    await update.message.reply_text("🔒 Locked.")


# ── Message Handlers (Text + Voice) ───────────────────────────────────

async def handle_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Text messages → password auth or conversational AI."""
    if not is_authorized_user(update):
        return

    text = update.message.text.strip()

    if not is_session_valid():
        await _try_password(update, text)
        return

    # Authenticated → AI conversation
    if AI_ENABLED and ANTHROPIC_API_KEY:
        await update.message.chat.send_action("typing")
        response = await ai_respond(text)
        for i in range(0, len(response), MAX_MESSAGE_LENGTH):
            await update.message.reply_text(response[i:i + MAX_MESSAGE_LENGTH])
    else:
        await update.message.reply_text("AI disabled. Use /help for commands.")


async def handle_voice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Voice messages → Whisper transcription → AI conversation."""
    if not is_authorized_user(update):
        return

    if not is_session_valid():
        await update.message.reply_text("🔐 Send your password (text) to unlock first.")
        return

    await update.message.reply_text("🎤 Transcribing...")
    text = await transcribe_voice(update)

    if not text:
        await update.message.reply_text("❌ Couldn't transcribe. Try again or type it.")
        return

    await update.message.reply_text(f"🎤 \"{text}\"")

    if AI_ENABLED and ANTHROPIC_API_KEY:
        await update.message.chat.send_action("typing")
        response = await ai_respond(text)
        for i in range(0, len(response), MAX_MESSAGE_LENGTH):
            await update.message.reply_text(response[i:i + MAX_MESSAGE_LENGTH])
    else:
        await update.message.reply_text("AI disabled. Use /help for commands.")


async def _try_password(update: Update, text: str):
    """Password authentication."""
    if is_locked_out():
        remaining = int(_session["locked_until"] - time.time())
        await update.message.reply_text(f"🔒 Locked. {remaining}s remaining.")
        return

    if not SESSION_PASSWORD_HASH:
        _session["authenticated"] = True
        _session["authenticated_at"] = time.time()
        await update.message.reply_text("⚠️ No password set — auto-auth. Fix your .env!")
        return

    if hash_password(text) == SESSION_PASSWORD_HASH:
        _session["authenticated"] = True
        _session["authenticated_at"] = time.time()
        _session["failed_attempts"] = 0
        logger.info("Authenticated")
        await update.message.reply_text("🔓 Authenticated (12h).\nJust talk to me — text or voice 🎤")
        try:
            await update.message.delete()
        except Exception:
            pass
    else:
        _session["failed_attempts"] += 1
        logger.warning(f"Failed password #{_session['failed_attempts']}")
        if _session["failed_attempts"] >= MAX_FAILED_ATTEMPTS:
            _session["locked_until"] = time.time() + LOCKOUT_DURATION
            await update.message.reply_text(f"🔒 Locked for {LOCKOUT_DURATION // 60} minutes.")
        else:
            r = MAX_FAILED_ATTEMPTS - _session["failed_attempts"]
            await update.message.reply_text(f"❌ Wrong password. {r} left.")


# ── Push Notifications ─────────────────────────────────────────────────

_telegram_app = None


async def push_message(text: str):
    if _telegram_app and BOT_TOKEN:
        try:
            await _telegram_app.bot.send_message(chat_id=AUTHORIZED_USER_ID, text=text[:MAX_MESSAGE_LENGTH])
        except Exception as e:
            logger.error(f"Push failed: {e}")


def push_message_sync(text: str):
    if _telegram_app:
        try:
            loop = _telegram_app._loop
            if loop and loop.is_running():
                asyncio.run_coroutine_threadsafe(push_message(text), loop)
                return
        except Exception:
            pass
    _push_via_http(text)


def _push_via_http(text: str):
    import urllib.request, urllib.parse
    if not BOT_TOKEN:
        return
    try:
        url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
        data = urllib.parse.urlencode({"chat_id": AUTHORIZED_USER_ID, "text": text[:MAX_MESSAGE_LENGTH]}).encode()
        urllib.request.urlopen(urllib.request.Request(url, data=data, method="POST"), timeout=10)
    except Exception as e:
        logger.error(f"HTTP push failed: {e}")


# ── Webhook Server ────────────────────────────────────────────────────

class WebhookHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        logger.debug(f"Webhook: {fmt % args}")

    def _json(self) -> dict:
        cl = int(self.headers.get("Content-Length", 0))
        if cl == 0:
            return {}
        try:
            return json.loads(self.rfile.read(cl))
        except Exception:
            return {}

    def _ok(self, data: dict):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def do_GET(self):
        if self.path == "/webhook/health":
            self._ok({"status": "ok", "ai": AI_MODEL, "whisper": WHISPER_API_URL, "version": "2.0.0"})
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        d = self._json()
        if self.path == "/webhook":
            msg = f"🚨 Agent Failed\n\nAgent: {d.get('agent', '?')}\nProject: {d.get('project', '?')}\nTask: {d.get('task', '?')[:200]}\nError: {d.get('error', '?')[:300]}"
            push_message_sync(msg)
            self._ok({"status": "sent"})
        elif self.path == "/webhook/alert":
            emoji = {"critical": "🔴", "warning": "⚠️", "info": "ℹ️"}.get(d.get("level", "info"), "📢")
            push_message_sync(f"{emoji} {d.get('title', 'Alert')}\n\nSource: {d.get('source', '?')}\n{d.get('message', '')[:1000]}")
            self._ok({"status": "sent"})
        elif self.path == "/webhook/task":
            e = "✅" if d.get("status") == "completed" else "❌"
            msg = f"{e} Task {d.get('status', '?')}\n\nAgent: {d.get('agent', '?')}\nProject: {d.get('project', '?')}"
            cost = d.get("actual_cost")
            if cost is not None:
                msg += f"\nCost: ${cost:.2f}"
            push_message_sync(msg)
            self._ok({"status": "sent"})
        else:
            self.send_response(404)
            self.end_headers()


def start_webhook_server():
    try:
        server = HTTPServer((WEBHOOK_BIND, WEBHOOK_PORT), WebhookHandler)
        threading.Thread(target=server.serve_forever, daemon=True).start()
        logger.info(f"Webhook on {WEBHOOK_BIND}:{WEBHOOK_PORT}")
    except Exception as e:
        logger.error(f"Webhook server failed: {e}")


# ── Main ───────────────────────────────────────────────────────────────

def main():
    global _telegram_app

    if not BOT_TOKEN:
        print("ERROR: Set TELEGRAM_BOT_TOKEN in .env")
        return

    logger.info(f"Bot v2.0 | user {AUTHORIZED_USER_ID} | AI: {AI_MODEL} | Whisper: {WHISPER_API_URL}")

    start_webhook_server()

    app = Application.builder().token(BOT_TOKEN).build()
    _telegram_app = app

    for name, fn in [
        ("start", cmd_start), ("help", cmd_help), ("health", cmd_health),
        ("system", cmd_system), ("docker", cmd_docker), ("logs", cmd_logs),
        ("task", cmd_task), ("tasks", cmd_tasks), ("status", cmd_status),
        ("spend", cmd_spend), ("projects", cmd_projects), ("sh", cmd_sh),
        ("restart", cmd_restart), ("backup", cmd_backup), ("alerts", cmd_alerts),
        ("session", cmd_session), ("lock", cmd_lock),
    ]:
        app.add_handler(CommandHandler(name, fn))

    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))
    app.add_handler(MessageHandler(filters.VOICE | filters.AUDIO, handle_voice))

    logger.info("Polling...")
    app.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
