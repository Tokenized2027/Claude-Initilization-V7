#!/usr/bin/env bash
# =============================================================================
# setup-docker.sh — Docker Setup Script for Python Web Applications
# Usage: ./setup-docker.sh [target-directory]
#        If no target directory is given, files are set up in the current dir.
# =============================================================================

set -euo pipefail

# ---- Configuration ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

TEMPLATE_FILES=(
    "Dockerfile.production"
    "docker-compose.yml"
    ".dockerignore"
    ".env.example"
)

# ---- Helpers ----
info()  { echo "[INFO]  $*"; }
warn()  { echo "[WARN]  $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# ---- Pre-flight checks ----
info "Checking prerequisites..."

if ! command -v docker &>/dev/null; then
    error "Docker is not installed. Install Docker Desktop from https://docs.docker.com/get-docker/"
fi

if ! docker info &>/dev/null 2>&1; then
    warn "Docker daemon is not running. Please start Docker Desktop before building."
fi

if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null 2>&1; then
    error "Docker Compose is not available. Install it from https://docs.docker.com/compose/install/"
fi

info "Docker is installed: $(docker --version)"

# ---- Ensure target directory exists ----
if [ ! -d "$TARGET_DIR" ]; then
    info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# ---- Copy template files ----
info "Copying template files to $TARGET_DIR ..."

for file in "${TEMPLATE_FILES[@]}"; do
    src="$SCRIPT_DIR/$file"
    dest="$TARGET_DIR/$file"

    if [ ! -f "$src" ]; then
        warn "Template file not found, skipping: $src"
        continue
    fi

    if [ -f "$dest" ]; then
        warn "File already exists, skipping (will not overwrite): $dest"
    else
        cp "$src" "$dest"
        info "Copied: $file"
    fi
done

# ---- Create .env from .env.example if it does not exist ----
if [ ! -f "$TARGET_DIR/.env" ] && [ -f "$TARGET_DIR/.env.example" ]; then
    cp "$TARGET_DIR/.env.example" "$TARGET_DIR/.env"
    info "Created .env from .env.example — edit it with your values before starting."
fi

# ---- Verify requirements.txt exists ----
if [ ! -f "$TARGET_DIR/requirements.txt" ]; then
    warn "No requirements.txt found in $TARGET_DIR. The Docker build will fail without one."
    warn "Create it with: pip freeze > requirements.txt"
fi

# ---- Summary ----
echo ""
echo "============================================="
echo "  Docker setup complete!"
echo "============================================="
echo ""
echo "Next steps:"
echo ""
echo "  1. Edit .env with your actual values:"
echo "     nano $TARGET_DIR/.env"
echo ""
echo "  2. Review and customize docker-compose.yml:"
echo "     - Rename the service (APP_NAME in .env)"
echo "     - Adjust the startup command for your framework"
echo "     - Uncomment Redis if needed"
echo ""
echo "  3. Make sure requirements.txt is up to date:"
echo "     pip freeze > requirements.txt"
echo ""
echo "  4. Build and start:"
echo "     cd $TARGET_DIR"
echo "     docker-compose up -d --build"
echo ""
echo "  5. View logs:"
echo "     docker-compose logs -f"
echo ""
echo "  6. Open in browser:"
echo "     http://localhost:\${PORT:-8000}"
echo ""
echo "============================================="
