#!/usr/bin/env bash
# LSP Tools - HTML/CSS LSP Server Installation
# Installs vscode-langservers-extracted

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== HTML/CSS LSP Server Installation ==="
echo "Server: vscode-langservers-extracted"
echo

# Check if already installed
if command -v vscode-html-language-server &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} vscode-html-language-server is already installed"
    vscode-html-language-server --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check via npm global list
if npm list -g vscode-langservers-extracted 2>/dev/null | grep -q vscode-langservers; then
    echo -e "${GREEN}[OK]${NC} vscode-langservers-extracted is installed via npm"
    exit 0
fi

# Verify npm is available
if ! command -v npm &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} npm is required but not installed"
    echo "Install Node.js from https://nodejs.org"
    exit 1
fi

echo "Installing vscode-langservers-extracted..."
npm install -g vscode-langservers-extracted

echo
echo -e "${GREEN}[SUCCESS]${NC} HTML/CSS LSP servers installed!"
echo
echo "This package provides:"
echo "  - vscode-html-language-server"
echo "  - vscode-css-language-server"
echo "  - vscode-json-language-server"
echo "  - vscode-eslint-language-server"
echo
echo "Verify installation:"
echo "  vscode-html-language-server --version"
echo "  vscode-css-language-server --version"
