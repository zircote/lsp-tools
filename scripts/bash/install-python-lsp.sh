#!/usr/bin/env bash
# LSP Tools - Python LSP Server Installation
# Installs pyright language server

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Python LSP Server Installation ==="
echo "Server: pyright"
echo

# Check if already installed
if command -v pyright &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} pyright is already installed"
    pyright --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Determine installation method
USE_NPM=false
USE_PIP=false
USE_UV=false

if command -v npm &>/dev/null; then
    USE_NPM=true
fi

if command -v uv &>/dev/null; then
    USE_UV=true
elif command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
    USE_PIP=true
fi

# Prefer npm (faster, no Python version conflicts)
if $USE_NPM; then
    echo "Installing pyright via npm (recommended)..."
    npm install -g pyright
elif $USE_UV; then
    echo "Installing pyright via uv tool..."
    uv tool install pyright
elif $USE_PIP; then
    echo "Installing pyright via pip..."
    if command -v pip3 &>/dev/null; then
        pip3 install pyright
    else
        pip install pyright
    fi
else
    echo -e "${RED}[ERROR]${NC} No package manager found (npm, uv, or pip required)"
    exit 1
fi

echo
echo -e "${GREEN}[SUCCESS]${NC} Python LSP server installed!"
echo
echo "Verify installation:"
echo "  pyright --version"
