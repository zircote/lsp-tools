#!/usr/bin/env bash
# LSP Tools - Rust LSP Server Installation
# Installs rust-analyzer

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Rust LSP Server Installation ==="
echo "Server: rust-analyzer"
echo

# Check if already installed
if command -v rust-analyzer &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} rust-analyzer is already installed"
    rust-analyzer --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Prefer rustup (official method)
if command -v rustup &>/dev/null; then
    echo "Installing rust-analyzer via rustup (recommended)..."
    rustup component add rust-analyzer

    echo
    echo -e "${GREEN}[SUCCESS]${NC} Rust LSP server installed!"
    echo
    echo "Verify installation:"
    echo "  rust-analyzer --version"
    exit 0
fi

# Fallback to brew on macOS
if [[ "$(uname -s)" == "Darwin" ]] && command -v brew &>/dev/null; then
    echo -e "${YELLOW}[INFO]${NC} rustup not found, using Homebrew..."
    brew install rust-analyzer

    echo
    echo -e "${GREEN}[SUCCESS]${NC} Rust LSP server installed via Homebrew!"
    echo
    echo "Note: For best results, install Rust via rustup:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 0
fi

# Arch Linux
if command -v pacman &>/dev/null; then
    echo "Installing rust-analyzer via pacman..."
    sudo pacman -S rust-analyzer

    echo
    echo -e "${GREEN}[SUCCESS]${NC} Rust LSP server installed!"
    exit 0
fi

echo -e "${RED}[ERROR]${NC} Cannot install rust-analyzer"
echo
echo "Please install Rust via rustup first:"
echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo
echo "Then run:"
echo "  rustup component add rust-analyzer"
exit 1
