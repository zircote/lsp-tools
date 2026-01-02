#!/usr/bin/env bash
# LSP Tools - TypeScript/JavaScript LSP Server Installation
# Installs vtsls (VS Code TypeScript Language Server)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== TypeScript/JavaScript LSP Server Installation ==="
echo "Server: vtsls (@vtsls/language-server)"
echo

# Check if already installed
if command -v vtsls &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} vtsls is already installed"
    vtsls --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check via npm global list
if npm list -g @vtsls/language-server 2>/dev/null | grep -q vtsls; then
    echo -e "${GREEN}[OK]${NC} @vtsls/language-server is installed via npm"
    exit 0
fi

# Verify npm is available
if ! command -v npm &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} npm is required but not installed"
    echo "Install Node.js from https://nodejs.org"
    exit 1
fi

echo "Installing @vtsls/language-server and typescript..."
npm install -g @vtsls/language-server typescript

echo
echo -e "${GREEN}[SUCCESS]${NC} TypeScript LSP server installed!"
echo
echo "Verify installation:"
echo "  npm list -g @vtsls/language-server"
