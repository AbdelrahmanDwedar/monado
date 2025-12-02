#!/bin/bash
# Cross-platform setup script for ExMCP Test Server
# Works on both Linux and Windows (via WSL or Git Bash)

set -e

echo "=========================================="
echo "ExMCP Test Server Local Setup"
echo "=========================================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
MCP_DIR="$PROJECT_DIR/ex-mcp-test"

echo "Project directory: $PROJECT_DIR"
echo ""

# Step 1: Clone or update ex-mcp-test
if [ -d "$MCP_DIR" ]; then
    echo "✓ ex-mcp-test directory exists, pulling latest changes..."
    cd "$MCP_DIR"
    git pull
else
    echo "→ Cloning ExMCP Test Server..."
    cd "$PROJECT_DIR"
    git clone https://github.com/y86/ex-mcp-test.git
    cd "$MCP_DIR"
fi
echo ""

# Step 2: Install dependencies
echo "→ Installing dependencies..."
mix deps.get
echo ""

# Step 3: Compile the project
echo "→ Compiling project..."
mix compile
echo ""

echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "The MCP server is configured to run with:"
echo "  Command: elixir --no-halt -S mix run"
echo "  Working Directory: ./ex-mcp-test"
echo ""
echo "This configuration works on both Windows and Linux!"
echo ""
echo "Next steps:"
echo "  1. Restart Cursor/VSCode"
echo "  2. The ex-mcp-test server will start automatically"
echo ""
echo "To test manually:"
echo "  cd ex-mcp-test && mix run --no-halt"
echo ""

