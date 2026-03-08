# Whisper Speech-to-Text Service

Shared speech-to-text API running as a Docker container on the mini PC.
Any app, script, or service can POST audio and get a transcription back.

## Quick Start

```bash
cd ~/whisper-service

# Build and start (downloads model during build — takes a few minutes first time)
docker compose up -d

# Test
curl http://127.0.0.1:9000/health

# Transcribe a file
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "file=@test.wav" \
  -F "language=en"
```

## API

### POST /transcribe

Upload an audio file for transcription.

```bash
# Basic English transcription
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "file=@audio.wav"

# Hebrew
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "file=@audio.ogg" \
  -F "language=he"

# Auto-detect language
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "file=@audio.mp3" \
  -F "language=auto"

# Translate to English
curl -X POST http://127.0.0.1:9000/transcribe \
  -F "file=@hebrew_audio.wav" \
  -F "task=translate"
```

Response:
```json
{
  "text": "Hello, how is the system doing today?",
  "language": "en",
  "duration_seconds": 1.23,
  "segments": [
    {"start": 0.0, "end": 2.5, "text": "Hello, how is the system doing today?"}
  ]
}
```

Supported formats: wav, mp3, ogg, flac, m4a, webm

### GET /health

```json
{"status": "ok", "model": "base", "default_language": "en", "max_file_size_mb": 25}
```

### GET /languages

Lists all supported language codes and names.

## Models

| Model | Size | RAM | Speed (10s audio) | Quality |
|-------|------|-----|-------------------|---------|
| tiny | 39M | ~400MB | ~1s | OK for clear English |
| base | 74M | ~700MB | ~2s | Good balance (default) |
| small | 244M | ~1.5GB | ~5s | Better accuracy |
| medium | 769M | ~3GB | ~12s | Great for non-English |
| large | 1.5G | ~6GB | ~25s | Best quality |

For the Ryzen 7 with 32GB RAM, `base` or `small` are the sweet spot. Use `medium` if you need good Hebrew accuracy.

To change model, edit `docker-compose.yml`:
```yaml
args:
  WHISPER_MODEL: small
environment:
  - WHISPER_MODEL=small
```

Then rebuild: `docker compose up -d --build`

## Integration with Telegram Bot

The Telegram bot can use this service instead of loading Whisper in-process.
Set in the bot's `.env`:

```
WHISPER_API_URL=http://127.0.0.1:9000
```

## Integration with Any Script

```bash
#!/bin/bash
# Transcribe any audio file from the command line
RESULT=$(curl -s -X POST http://127.0.0.1:9000/transcribe -F "file=@$1")
echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin)['text'])"
```

```python
# Python example
import requests

def transcribe(audio_path, language="en"):
    with open(audio_path, "rb") as f:
        resp = requests.post(
            "http://127.0.0.1:9000/transcribe",
            files={"file": f},
            data={"language": language},
        )
    return resp.json()["text"]
```

## Resource Usage

- **Idle**: ~700MB RAM (model stays loaded), negligible CPU
- **Transcribing**: spikes to 100-400% CPU for a few seconds
- Container resource limits in docker-compose.yml prevent it from starving other services
