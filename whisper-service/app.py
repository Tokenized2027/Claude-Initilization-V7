#!/usr/bin/env python3
"""
Whisper API Service
====================
Shared speech-to-text service running as a Docker container.
Exposes a simple REST API that any app on the mini PC can call.

Endpoints:
  POST /transcribe     — Upload audio file, get transcription
  POST /transcribe/url — Provide URL to audio file
  GET  /health         — Health check + model info
  GET  /languages      — List supported languages

Usage:
  curl -X POST http://127.0.0.1:9000/transcribe \
    -F "file=@audio.wav" \
    -F "language=en"

  curl http://127.0.0.1:9000/health

v1.0.0 — February 2026
"""

import io
import os
import tempfile
import time
import logging

import whisper
from flask import Flask, request, jsonify

# ── Configuration ──────────────────────────────────────────────────────

MODEL_NAME = os.getenv("WHISPER_MODEL", "base")
DEFAULT_LANGUAGE = os.getenv("WHISPER_LANGUAGE", "en")
MAX_FILE_SIZE_MB = int(os.getenv("WHISPER_MAX_FILE_SIZE_MB", "25"))
HOST = os.getenv("WHISPER_HOST", "0.0.0.0")
PORT = int(os.getenv("WHISPER_PORT", "9000"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("whisper-api")

# ── Load Model ─────────────────────────────────────────────────────────

logger.info(f"Loading Whisper model '{MODEL_NAME}'...")
start = time.time()
model = whisper.load_model(MODEL_NAME)
load_time = time.time() - start
logger.info(f"Model '{MODEL_NAME}' loaded in {load_time:.1f}s")

# ── Flask App ──────────────────────────────────────────────────────────

app = Flask(__name__)


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "model": MODEL_NAME,
        "default_language": DEFAULT_LANGUAGE,
        "max_file_size_mb": MAX_FILE_SIZE_MB,
    })


@app.route("/languages", methods=["GET"])
def languages():
    """List languages Whisper supports."""
    return jsonify({
        "languages": sorted(whisper.tokenizer.LANGUAGES.values()),
        "codes": sorted(whisper.tokenizer.LANGUAGES.keys()),
    })


@app.route("/transcribe", methods=["POST"])
def transcribe():
    """
    Transcribe an uploaded audio file.

    Form fields:
      file      — audio file (wav, mp3, ogg, flac, m4a, webm)
      language  — optional language code (en, he, auto). Default from env.
      task      — "transcribe" (default) or "translate" (to English)
    """
    if "file" not in request.files:
        return jsonify({"error": "No 'file' field in request"}), 400

    audio_file = request.files["file"]
    if not audio_file.filename:
        return jsonify({"error": "Empty filename"}), 400

    # Check file size
    audio_file.seek(0, 2)
    size_mb = audio_file.tell() / (1024 * 1024)
    audio_file.seek(0)
    if size_mb > MAX_FILE_SIZE_MB:
        return jsonify({"error": f"File too large ({size_mb:.1f}MB > {MAX_FILE_SIZE_MB}MB)"}), 413

    language = request.form.get("language", DEFAULT_LANGUAGE)
    task = request.form.get("task", "transcribe")

    if language == "auto":
        language = None  # Let Whisper auto-detect

    # Save to temp file (Whisper needs a file path)
    suffix = os.path.splitext(audio_file.filename)[1] or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp_path = tmp.name
        audio_file.save(tmp_path)

    try:
        logger.info(f"Transcribing: {audio_file.filename} ({size_mb:.1f}MB, lang={language or 'auto'}, task={task})")
        start = time.time()

        result = model.transcribe(
            tmp_path,
            language=language,
            task=task,
        )

        elapsed = time.time() - start
        text = result.get("text", "").strip()
        detected_lang = result.get("language", "unknown")

        logger.info(f"Done in {elapsed:.1f}s: [{detected_lang}] {text[:100]}...")

        return jsonify({
            "text": text,
            "language": detected_lang,
            "duration_seconds": round(elapsed, 2),
            "segments": [
                {
                    "start": seg["start"],
                    "end": seg["end"],
                    "text": seg["text"].strip(),
                }
                for seg in result.get("segments", [])
            ],
        })

    except Exception as e:
        logger.error(f"Transcription failed: {e}")
        return jsonify({"error": str(e)}), 500

    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


# ── Main ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    logger.info(f"Starting Whisper API on {HOST}:{PORT}")
    app.run(host=HOST, port=PORT, threaded=True)
