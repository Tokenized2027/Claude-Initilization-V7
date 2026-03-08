#!/bin/bash
# Install Telegram Bot for Mini PC
# Run from the telegram-bot/ source directory

set -e

INSTALL_DIR="$HOME/claude-multi-agent/telegram-bot"

echo "=== Telegram Bot Installer ==="
echo ""

# 1. Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Install it first."
    exit 1
fi
echo "✅ Python 3: $(python3 --version)"

# 2. Create install directory
mkdir -p "$INSTALL_DIR"
echo "✅ Install dir: $INSTALL_DIR"

# 3. Copy files
cp bot.py "$INSTALL_DIR/"
cp requirements.txt "$INSTALL_DIR/"
cp generate-password-hash.py "$INSTALL_DIR/"
cp .env.example "$INSTALL_DIR/"

if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp .env.example "$INSTALL_DIR/.env"
    echo "📝 Created .env from template — edit it next!"
else
    echo "✅ .env already exists (not overwritten)"
fi

# 4. Create venv and install deps
echo "📦 Setting up Python virtual environment..."
python3 -m venv "$INSTALL_DIR/venv"
"$INSTALL_DIR/venv/bin/pip" install --quiet --upgrade pip
"$INSTALL_DIR/venv/bin/pip" install --quiet -r "$INSTALL_DIR/requirements.txt"
echo "✅ Dependencies installed"

# 5. Check ffmpeg (needed for voice messages)
if command -v ffmpeg &> /dev/null; then
    echo "✅ ffmpeg: $(ffmpeg -version 2>&1 | head -1)"
else
    echo "⚠️  ffmpeg not found — voice messages won't work"
    echo "   Install with: sudo apt install ffmpeg"
fi

# 6. Install systemd service
echo ""
echo "To install as a system service:"
echo ""
echo "  sudo cp telegram-bot.service /etc/systemd/system/"
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable telegram-bot"
echo "  sudo systemctl start telegram-bot"
echo ""

# 7. Remind about configuration
echo "=== Next Steps ==="
echo ""
echo "1. Create a bot with @BotFather on Telegram"
echo "   → Copy the token"
echo ""
echo "2. Generate a password hash:"
echo "   cd $INSTALL_DIR"
echo "   python3 generate-password-hash.py"
echo ""
echo "3. Install ffmpeg (for voice messages):"
echo "   sudo apt install ffmpeg"
echo ""
echo "4. Edit .env:"
echo "   nano $INSTALL_DIR/.env"
echo "   → Set TELEGRAM_BOT_TOKEN"
echo "   → Set TELEGRAM_SESSION_PASSWORD_HASH"
echo "   → Set ANTHROPIC_API_KEY (same key as orchestrator)"
echo "   → Set ORCHESTRATOR_API_KEY"
echo ""
echo "5. Start the bot:"
echo "   sudo systemctl start telegram-bot"
echo ""
echo "6. Test: send your password, then try talking naturally"
echo "   or send a voice message!"
echo ""
echo "=== Done ==="
