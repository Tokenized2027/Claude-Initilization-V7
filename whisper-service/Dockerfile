FROM python:3.11-slim

# Install ffmpeg (required by Whisper for audio decoding)
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download Whisper model at build time (so container starts fast)
ARG WHISPER_MODEL=base
RUN python3 -c "import whisper; whisper.load_model('${WHISPER_MODEL}')"

COPY app.py .

ENV WHISPER_MODEL=${WHISPER_MODEL}
ENV WHISPER_LANGUAGE=en
ENV WHISPER_HOST=0.0.0.0
ENV WHISPER_PORT=9000
ENV WHISPER_MAX_FILE_SIZE_MB=25

EXPOSE 9000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:9000/health')" || exit 1

CMD ["python3", "app.py"]
