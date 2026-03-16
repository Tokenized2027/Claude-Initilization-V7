#!/usr/bin/env python3
"""
Session Recall Hook — gives Claude memory across conversations.

Scans recent Claude Code sessions and injects summaries into context
at session start. This is the #1 hook for making Claude Code feel
like it actually remembers what you were doing yesterday.

Install:
  cp hooks/session-recall.py ~/.claude/hooks/session-recall.py

No external dependencies — stdlib only (Python 3.9+).

Configure via environment variables:
  CLAUDE_SESSION_RECALL_DIR   — override session history directory
  CLAUDE_RECALL_HOURS         — lookback window (default: 48)
  CLAUDE_RECALL_MAX_SESSIONS  — max sessions to show (default: 5)
  CLAUDE_RECALL_MAX_CHARS     — context budget in chars (default: 2000)
  TZ                          — timezone for timestamps (default: UTC)
"""

from __future__ import annotations

import json
import os
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

try:
    from zoneinfo import ZoneInfo
except ImportError:
    ZoneInfo = None


# --- Configuration (override via environment variables) ---

LOOKBACK_HOURS = int(os.environ.get("CLAUDE_RECALL_HOURS", "48"))
MAX_CONTEXT_CHARS = int(os.environ.get("CLAUDE_RECALL_MAX_CHARS", "2000"))
MAX_SESSIONS = int(os.environ.get("CLAUDE_RECALL_MAX_SESSIONS", "5"))
MAX_ASSISTANT_MESSAGES = 5
MAX_RECORDS_PER_FILE = 600
LINE_CHUNK_SIZE = 65536

TAG_RE = re.compile(r"<[^>]+>")
SPACE_RE = re.compile(r"\s+")


def default_base_dir() -> Path:
    """Find the session history directory.

    Claude Code stores session JSONL files under:
      ~/.claude/projects/<slug>/*.jsonl

    The <slug> is derived from your home directory path.
    """
    override = os.environ.get("CLAUDE_SESSION_RECALL_DIR")
    if override:
        return Path(override).expanduser()

    home_slug = "-" + "-".join(
        part for part in Path.home().parts if part and part != "/"
    )
    return Path.home() / ".claude" / "projects" / home_slug


BASE_DIR = default_base_dir()


def get_local_tz():
    """Get local timezone from TZ env var, defaulting to UTC."""
    tz_name = os.environ.get("TZ", "UTC")
    if ZoneInfo is None:
        return timezone.utc
    try:
        return ZoneInfo(tz_name)
    except Exception:
        return timezone.utc


LOCAL_TZ = get_local_tz()


def cleanup_text(text: str) -> str:
    """Strip HTML/XML tags, code fences, and collapse whitespace."""
    if not isinstance(text, str):
        return ""
    text = TAG_RE.sub(" ", text)
    text = text.replace("```", " ")
    text = SPACE_RE.sub(" ", text).strip()
    return text


def shorten(text: str, limit: int) -> str:
    """Truncate text to limit, breaking at word boundaries."""
    text = cleanup_text(text)
    if len(text) <= limit:
        return text
    trimmed = text[: max(1, limit - 1)]
    if " " in trimmed:
        trimmed = trimmed.rsplit(" ", 1)[0]
    return trimmed.rstrip(" ,.;:") + "..."


def parse_timestamp(raw: str | None) -> datetime | None:
    if not raw or not isinstance(raw, str):
        return None
    try:
        return datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except ValueError:
        return None


def iter_recent_records(path: Path, limit: int):
    """Read JSONL records from the end of file (most recent first).

    Uses reverse-file-iteration for efficiency — only reads what's needed
    instead of loading the entire file into memory.
    """
    with path.open("rb") as handle:
        handle.seek(0, os.SEEK_END)
        position = handle.tell()
        buffer = b""
        yielded = 0

        while position > 0 and yielded < limit:
            read_size = min(LINE_CHUNK_SIZE, position)
            position -= read_size
            handle.seek(position)
            buffer = handle.read(read_size) + buffer
            lines = buffer.splitlines()

            if position > 0:
                buffer = lines[0]
                lines = lines[1:]
            else:
                buffer = b""

            for line in reversed(lines):
                line = line.strip()
                if not line:
                    continue
                try:
                    yield json.loads(line)
                except json.JSONDecodeError:
                    continue
                yielded += 1
                if yielded >= limit:
                    return


def extract_user_text(record: dict) -> str:
    """Extract the user's message text from a session record."""
    if record.get("type") != "user" or record.get("isMeta"):
        return ""

    message = record.get("message") or {}
    content = message.get("content")
    if isinstance(content, str):
        return cleanup_text(content)

    if isinstance(content, list):
        parts = []
        for item in content:
            if not isinstance(item, dict):
                continue
            if item.get("type") == "text":
                parts.append(item.get("text", ""))
        return cleanup_text(" ".join(parts))

    return ""


def extract_assistant_texts(record: dict) -> list[str]:
    """Extract assistant response text blocks from a session record."""
    if record.get("type") != "assistant":
        return []

    message = record.get("message") or {}
    content = message.get("content") or []
    if not isinstance(content, list):
        return []

    texts = []
    for item in content:
        if not isinstance(item, dict) or item.get("type") != "text":
            continue
        text = cleanup_text(item.get("text", ""))
        if text:
            texts.append(text)
    return texts


def summarize_session(path: Path) -> tuple[datetime, str] | None:
    """Create a one-line summary of a session.

    Extracts:
    - The last user message (what you were working on)
    - The last assistant action (what Claude did)
    - Timestamp for sorting
    """
    assistant_messages: list[str] = []
    latest_user = ""
    latest_action = ""
    latest_timestamp = None

    for record in iter_recent_records(path, MAX_RECORDS_PER_FILE):
        timestamp = parse_timestamp(record.get("timestamp"))
        if latest_timestamp is None and timestamp is not None:
            latest_timestamp = timestamp

        if not latest_user:
            latest_user = extract_user_text(record)

        assistant_texts = extract_assistant_texts(record)
        if assistant_texts:
            for text in reversed(assistant_texts):
                if not latest_action:
                    latest_action = text
                if len(assistant_messages) < MAX_ASSISTANT_MESSAGES:
                    assistant_messages.append(text)

        if (
            latest_user
            and latest_action
            and len(assistant_messages) >= MAX_ASSISTANT_MESSAGES
        ):
            break

    if latest_timestamp is None:
        latest_timestamp = datetime.fromtimestamp(
            path.stat().st_mtime, tz=timezone.utc
        )

    topic = shorten(latest_user or "Recent session activity", 82)
    action = shorten(latest_action or "Continued prior work.", 94)
    when = latest_timestamp.astimezone(LOCAL_TZ).strftime("%b %d %H:%M")
    summary = f"- {when} | {topic} | last action: {action}"
    return latest_timestamp, summary


def main() -> int:
    try:
        hook_input = json.load(sys.stdin)
    except json.JSONDecodeError:
        hook_input = {}

    if not BASE_DIR.exists():
        return 0

    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(hours=LOOKBACK_HOURS)
    current_session = hook_input.get("session_id")

    # Find recent session files (excluding current session)
    session_files = []
    for path in BASE_DIR.glob("*.jsonl"):
        if current_session and path.stem == current_session:
            continue
        modified_at = datetime.fromtimestamp(path.stat().st_mtime, tz=timezone.utc)
        if modified_at < cutoff:
            continue
        session_files.append((modified_at, path))

    session_files.sort(reverse=True)

    # Summarize each session
    summaries = []
    for _, path in session_files:
        session_summary = summarize_session(path)
        if session_summary is None:
            continue
        summaries.append(session_summary)
        if len(summaries) >= MAX_SESSIONS:
            break

    if not summaries:
        return 0

    # Build context output (respecting character budget)
    summaries.sort(key=lambda item: item[0], reverse=True)
    context_lines = ["Recent sessions:"]
    current_length = len(context_lines[0])

    for _, line in summaries:
        projected = current_length + 1 + len(line)
        if projected > MAX_CONTEXT_CHARS:
            break
        context_lines.append(line)
        current_length = projected

    if len(context_lines) == 1:
        return 0

    # Return context to Claude via hook protocol
    payload = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": "\n".join(context_lines),
        }
    }
    json.dump(payload, sys.stdout, ensure_ascii=False)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
