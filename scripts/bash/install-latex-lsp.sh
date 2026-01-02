#!/usr/bin/env bash
# LSP Tools - LaTeX LSP Server Installation
# Installs texlab

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== LaTeX LSP Server Installation ==="
echo "Server: texlab"
echo

# Check if already installed
if command -v texlab &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} texlab is already installed"
    texlab --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

OS="$(uname -s)"

case "$OS" in
    Darwin)
        # macOS - use Homebrew
        if ! command -v brew &>/dev/null; then
            echo -e "${RED}[ERROR]${NC} Homebrew is required on macOS"
            echo "Install from https://brew.sh"
            exit 1
        fi

        echo "Installing texlab via Homebrew..."
        brew install texlab

        echo
        echo -e "${GREEN}[SUCCESS]${NC} LaTeX LSP server installed!"
        ;;

    Linux)
        # Linux - detect distro or use cargo
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
                arch|manjaro)
                    echo "Installing texlab via pacman..."
                    sudo pacman -S --noconfirm texlab
                    echo
                    echo -e "${GREEN}[SUCCESS]${NC} LaTeX LSP server installed!"
                    exit 0
                    ;;
            esac
        fi

        # Try snap
        if command -v snap &>/dev/null; then
            echo "Installing texlab via snap..."
            sudo snap install texlab
            echo
            echo -e "${GREEN}[SUCCESS]${NC} LaTeX LSP server installed!"
            exit 0
        fi

        # Fall back to cargo
        if command -v cargo &>/dev/null; then
            echo "Installing texlab via cargo..."
            cargo install --locked texlab
            echo
            echo -e "${GREEN}[SUCCESS]${NC} LaTeX LSP server installed!"
            exit 0
        fi

        echo -e "${RED}[ERROR]${NC} Could not install texlab"
        echo
        echo "Options:"
        echo "  1. Install via snap: sudo snap install texlab"
        echo "  2. Install via cargo: cargo install --locked texlab"
        echo "  3. Download from https://github.com/latex-lsp/texlab/releases"
        exit 1
        ;;

    *)
        echo -e "${RED}[ERROR]${NC} Unsupported OS: $OS"
        exit 1
        ;;
esac

echo
echo "Verify installation:"
echo "  texlab --version"
echo
echo -e "${YELLOW}[NOTE]${NC} Requires a TeX distribution:"
echo "  macOS: brew install --cask mactex"
echo "  Linux: apt install texlive-full (or equivalent)"
