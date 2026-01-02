#!/usr/bin/env bash
# LSP Tools - Go LSP Server Installation
# Installs gopls (official Go language server)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Go LSP Server Installation ==="
echo "Server: gopls"
echo

# Check if already installed
if command -v gopls &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} gopls is already installed"
    gopls version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check for Go installation
if ! command -v go &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Go is required but not installed"
    echo "Install Go from https://go.dev/dl/"
    exit 1
fi

# Get Go version
GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
echo "Go version: $GO_VERSION"

# Install gopls
echo "Installing gopls via go install..."
go install golang.org/x/tools/gopls@latest

# Check GOPATH/bin is in PATH
GOBIN=$(go env GOPATH)/bin
if [[ ":$PATH:" != *":$GOBIN:"* ]]; then
    echo
    echo -e "${YELLOW}[WARN]${NC} GOPATH/bin not in PATH"
    echo
    echo "Add to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "  export PATH=\"\$PATH:$(go env GOPATH)/bin\""
    echo
    echo "Or add to Claude Code settings.json:"
    echo '  "env": { "PATH": "...:'$(go env GOPATH)/bin'" }'
fi

echo
echo -e "${GREEN}[SUCCESS]${NC} Go LSP server installed!"
echo
echo "Verify installation:"
echo "  $(go env GOPATH)/bin/gopls version"
