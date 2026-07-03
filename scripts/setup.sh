#!/usr/bin/env bash
set -euo pipefail

# Balam-Agent Setup Script
# Idempotent — safe to run multiple times

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR"

echo "=== Balam-Agent Setup ==="

# 1. Create virtual environment
if [ ! -d ".venv" ]; then
    echo "Creating Python 3.11 virtual environment..."
    python3.11 -m venv .venv
else
    echo "Virtual environment already exists — skipping creation."
fi

# 2. Activate and install hermes-agent
echo "Installing hermes-agent v0.17.0..."
source .venv/bin/activate
pip install --upgrade pip --quiet
pip install "hermes-agent==0.17.0"

# 3. Create HERMES_HOME directory structure
HERMES_HOME_DIR="$PROJECT_DIR/home"
mkdir -p "$HERMES_HOME_DIR"

# 4. Copy config files to HERMES_HOME if they don't exist
if [ ! -f "$HERMES_HOME_DIR/config.yaml" ]; then
    cp "$PROJECT_DIR/config.yaml" "$HERMES_HOME_DIR/config.yaml"
    echo "Copied config.yaml to HERMES_HOME"
fi

if [ ! -f "$HERMES_HOME_DIR/.env" ]; then
    if [ -f "$PROJECT_DIR/.env.example" ]; then
        cp "$PROJECT_DIR/.env.example" "$HERMES_HOME_DIR/.env"
        echo "Created .env from .env.example — please edit with your API keys."
    fi
fi

if [ ! -f "$HERMES_HOME_DIR/SOUL.md" ]; then
    cp "$PROJECT_DIR/SOUL.md" "$HERMES_HOME_DIR/SOUL.md"
    echo "Copied SOUL.md to HERMES_HOME"
fi

# 5. Create wrapper script
WRAPPER_PATH="$PROJECT_DIR/balam"
cat > "$WRAPPER_PATH" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# Balam-Agent wrapper — sets HERMES_HOME and launches hermes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HERMES_HOME="$SCRIPT_DIR/home"
source "$SCRIPT_DIR/.venv/bin/activate"
exec hermes "$@"
WRAPPER_EOF
chmod +x "$WRAPPER_PATH"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Balam home: $HERMES_HOME_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $HERMES_HOME_DIR/.env with your API keys"
echo "  2. Run: ./balam chat"
echo ""
echo "The 'balam' wrapper sets HERMES_HOME automatically."
