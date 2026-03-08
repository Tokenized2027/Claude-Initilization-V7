"""
Orchestrator Core Logic — Side-effect-free module.

Contains SpendTracker, task routing, and token usage parsing.
Importable by both orchestrator.py and tests without triggering
FastAPI startup, load_dotenv(), or directory creation.

v3.2.0 — Extracted from orchestrator.py to eliminate test copy-paste.
"""

import json
import re
import tempfile
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional


# ── Spend Tracking ────────────────────────────────────────────────────

class SpendTracker:
    """Tracks estimated (and optionally actual) API spend per day and per project.
    Persisted to disk so it survives restarts.

    Uses atomic writes (write to temp file, then os.replace) to prevent
    ledger corruption on power loss or kill -9.
    """

    def __init__(self, ledger_path: Path, daily_budget: float = 50.0, project_budget: float = 25.0, logger=None):
        self.ledger_path = ledger_path
        self.daily_budget = daily_budget
        self.project_budget = project_budget
        self._logger = logger
        self.ledger: dict = self._load()

    def _log(self, level: str, msg: str) -> None:
        if self._logger:
            getattr(self._logger, level)(msg)

    def _load(self) -> dict:
        if self.ledger_path.exists():
            try:
                return json.loads(self.ledger_path.read_text())
            except (json.JSONDecodeError, OSError):
                self._log("warning", "Failed to load spend ledger, starting fresh")
        return {"daily": {}, "projects": {}, "actuals": {}}

    def _save(self) -> None:
        """Atomic write: write to temp file in same directory, then os.replace."""
        self.ledger_path.parent.mkdir(parents=True, exist_ok=True)
        try:
            fd, tmp_path = tempfile.mkstemp(
                dir=str(self.ledger_path.parent),
                prefix=".ledger_",
                suffix=".tmp",
            )
            try:
                with os.fdopen(fd, "w") as f:
                    json.dump(self.ledger, f, indent=2)
                os.replace(tmp_path, str(self.ledger_path))
            except BaseException:
                # Clean up temp file on any error
                try:
                    os.unlink(tmp_path)
                except OSError:
                    pass
                raise
        except OSError as e:
            self._log("error", f"Failed to save spend ledger: {e}")

    def record_spend(self, project: str, estimated: float, actual: Optional[float] = None) -> None:
        """Record spend. If actual is provided (from token parsing), track both."""
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        self.ledger.setdefault("daily", {})
        self.ledger.setdefault("projects", {})
        self.ledger.setdefault("actuals", {})

        # Always record estimated (used for budget enforcement)
        self.ledger["daily"][today] = self.ledger["daily"].get(today, 0.0) + estimated
        self.ledger["projects"][project] = self.ledger["projects"].get(project, 0.0) + estimated

        # Track actuals separately when available
        if actual is not None:
            self.ledger["actuals"].setdefault("daily", {})
            self.ledger["actuals"].setdefault("projects", {})
            self.ledger["actuals"]["daily"][today] = self.ledger["actuals"]["daily"].get(today, 0.0) + actual
            self.ledger["actuals"]["projects"][project] = self.ledger["actuals"]["projects"].get(project, 0.0) + actual

        self._save()

    def daily_spend(self) -> float:
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        return self.ledger.get("daily", {}).get(today, 0.0)

    def project_spend(self, project: str) -> float:
        return self.ledger.get("projects", {}).get(project, 0.0)

    def can_spend(self, project: str, amount: float) -> tuple[bool, str]:
        """Check if spending would exceed daily or project budget."""
        new_daily = self.daily_spend() + amount
        if new_daily > self.daily_budget:
            return False, (
                f"Daily budget exceeded: ${self.daily_spend():.2f} spent today, "
                f"limit is ${self.daily_budget:.2f}. Increase DAILY_BUDGET_USD in .env to override."
            )
        new_project = self.project_spend(project) + amount
        if new_project > self.project_budget:
            return False, (
                f"Project budget exceeded: ${self.project_spend(project):.2f} spent on '{project}', "
                f"limit is ${self.project_budget:.2f}. Increase PROJECT_BUDGET_USD in .env to override."
            )
        return True, ""

    def get_summary(self) -> dict:
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        summary = {
            "daily_spend_today": round(self.daily_spend(), 2),
            "daily_budget": self.daily_budget,
            "daily_remaining": round(max(0, self.daily_budget - self.daily_spend()), 2),
            "projects": {k: round(v, 2) for k, v in self.ledger.get("projects", {}).items()},
            "project_budget_per_project": self.project_budget,
        }
        # Include actuals if any have been recorded
        actuals = self.ledger.get("actuals", {})
        if actuals.get("daily", {}).get(today):
            summary["actual_daily_spend"] = round(actuals["daily"].get(today, 0.0), 2)
            summary["actual_vs_estimated_ratio"] = round(
                actuals["daily"][today] / max(self.daily_spend(), 0.01), 3
            )
        if actuals.get("projects"):
            summary["actual_projects"] = {k: round(v, 2) for k, v in actuals["projects"].items()}
        return summary


# ── Task Routing ──────────────────────────────────────────────────────

def load_routes(
    routes_file: Path,
    fallback_cost: float = 2.50,
) -> tuple[dict[str, dict[str, Any]], dict[str, list], dict[str, int], str]:
    """Load routing config from project_routes.json.

    Keywords support optional weights:
        plain string = weight 1, {"keyword": "...", "weight": N} = weight N.
    Routes can include "cost_estimate" for per-task-type budget math.

    Returns (task_routing, keywords, priorities, default_task_type).
    Pure function — no side effects.
    """
    try:
        data = json.loads(routes_file.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {}, {}, {}, "coding-prototype"

    routes = data.get("routes", {})
    task_routing = {}
    keywords: dict[str, list] = {}
    priorities = {}

    for task_type, cfg in routes.items():
        task_routing[task_type] = {
            "agent": cfg["agent"],
            "context_type": cfg["context_type"],
            "cost_estimate": cfg.get("cost_estimate", fallback_cost),
        }
        raw_kws = cfg.get("keywords", [])
        parsed = []
        for kw in raw_kws:
            if isinstance(kw, dict):
                parsed.append({"keyword": kw["keyword"], "weight": kw.get("weight", 1)})
            else:
                parsed.append({"keyword": kw, "weight": 1})
        keywords[task_type] = parsed
        priorities[task_type] = cfg.get("priority", 5)

    default = data.get("default_task_type", "coding-prototype")
    return task_routing, keywords, priorities, default


def detect_task_type(
    task: str,
    keywords: dict[str, list],
    priorities: dict[str, int],
    default: str = "coding-prototype",
) -> str:
    """Score each task type by WEIGHTED keyword match count.
    On ties, higher priority wins.

    Pure function — takes keyword/priority dicts as args instead of globals.
    """
    lower = task.lower()
    best_type = default
    best_score = 0
    best_priority = 0

    for task_type, kw_list in keywords.items():
        score = sum(kw["weight"] for kw in kw_list if kw["keyword"] in lower)
        priority = priorities.get(task_type, 5)
        if score > best_score or (score == best_score and score > 0 and priority > best_priority):
            best_score = score
            best_type = task_type
            best_priority = priority

    return best_type


# ── Token Usage Parsing ───────────────────────────────────────────────

# Claude CLI stderr output patterns for token usage.
# These patterns match common Claude Code output formats.
# Example: "Total tokens: 15234 (input: 12000, output: 3234)"
# Example: "Input tokens: 12000 | Output tokens: 3234"
# Example: "Tokens used: input=12000 output=3234"
_TOKEN_PATTERNS = [
    # "input: 12000, output: 3234" or "Input tokens: 12000 | Output tokens: 3234"
    re.compile(r"input[_ ]?tokens?\s*[:=]\s*([\d,]+)", re.IGNORECASE),
    re.compile(r"output[_ ]?tokens?\s*[:=]\s*([\d,]+)", re.IGNORECASE),
    # "Total cost: $0.42" or "Cost: $0.42"
    re.compile(r"(?:total\s+)?cost\s*[:=]\s*\$?([\d.]+)", re.IGNORECASE),
    # "Total tokens: 15234"
    re.compile(r"total[_ ]?tokens?\s*[:=]\s*([\d,]+)", re.IGNORECASE),
]

# Default pricing per million tokens (Sonnet 4.5 rates)
DEFAULT_INPUT_COST_PER_M = 3.00
DEFAULT_OUTPUT_COST_PER_M = 15.00


def parse_token_usage(stderr_text: str) -> Optional[dict]:
    """Parse token usage from Claude CLI stderr output.

    Returns dict with available fields:
        input_tokens, output_tokens, total_tokens, reported_cost, computed_cost

    Returns None if no token info found in stderr.
    """
    if not stderr_text:
        return None

    result = {}

    for pattern in _TOKEN_PATTERNS:
        for match in pattern.finditer(stderr_text):
            value_str = match.group(1).replace(",", "")
            key = pattern.pattern  # Use pattern to identify which field

            if "input" in key.lower():
                try:
                    result["input_tokens"] = int(value_str)
                except ValueError:
                    pass
            elif "output" in key.lower() and "cost" not in key.lower():
                try:
                    result["output_tokens"] = int(value_str)
                except ValueError:
                    pass
            elif "cost" in key.lower():
                try:
                    result["reported_cost"] = float(value_str)
                except ValueError:
                    pass
            elif "total" in key.lower():
                try:
                    result["total_tokens"] = int(value_str)
                except ValueError:
                    pass

    if not result:
        return None

    # Compute cost from tokens if we have them but no reported cost
    if "input_tokens" in result and "output_tokens" in result and "reported_cost" not in result:
        result["computed_cost"] = round(
            (result["input_tokens"] / 1_000_000) * DEFAULT_INPUT_COST_PER_M
            + (result["output_tokens"] / 1_000_000) * DEFAULT_OUTPUT_COST_PER_M,
            4,
        )

    # Use reported_cost or computed_cost as actual_cost
    result["actual_cost"] = result.get("reported_cost") or result.get("computed_cost")

    return result


# ── Log Rotation ──────────────────────────────────────────────────────

def rotate_logs(logs_dir: Path, max_logs_per_project: int = 200) -> int:
    """Remove oldest log files when a project exceeds max_logs_per_project.

    Returns number of files deleted.
    """
    if not logs_dir.exists():
        return 0

    log_files = sorted(logs_dir.glob("*.json"), key=lambda f: f.stat().st_mtime)
    excess = len(log_files) - max_logs_per_project

    if excess <= 0:
        return 0

    deleted = 0
    for f in log_files[:excess]:
        try:
            f.unlink()
            deleted += 1
        except OSError:
            pass
    return deleted
