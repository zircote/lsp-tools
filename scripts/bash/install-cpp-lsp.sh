#!/usr/bin/env bash
# LSP Tools - C/C++ LSP Server Installation
# Installs clangd

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== C/C++ LSP Server Installation ==="
echo "Server: clangd"
echo

# Check if already installed
if command -v clangd &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} clangd is already installed"
    clangd --version 2>/dev/null | head -1 || echo "(version check not available)"
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

        echo "Installing LLVM (includes clangd) via Homebrew..."
        brew install llvm

        LLVM_BIN="$(brew --prefix llvm)/bin"
        echo
        echo -e "${GREEN}[SUCCESS]${NC} C/C++ LSP server installed!"
        echo
        echo -e "${YELLOW}[IMPORTANT]${NC} Add LLVM to PATH:"
        echo "  export PATH=\"$LLVM_BIN:\$PATH\""
        echo
        echo "Or create symlink:"
        echo "  ln -sf $LLVM_BIN/clangd /usr/local/bin/clangd"
        ;;

    Linux)
        # Linux - detect distro
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
                ubuntu|debian)
                    echo "Installing clangd via apt..."
                    sudo apt update
                    sudo apt install -y clangd
                    ;;
                fedora|rhel|centos)
                    echo "Installing clang-tools-extra via dnf..."
                    sudo dnf install -y clang-tools-extra
                    ;;
                arch|manjaro)
                    echo "Installing clang via pacman..."
                    sudo pacman -S --noconfirm clang
                    ;;
                *)
                    echo -e "${RED}[ERROR]${NC} Unsupported Linux distribution: $ID"
                    echo "Install clangd manually for your distribution"
                    exit 1
                    ;;
            esac
        else
            echo -e "${RED}[ERROR]${NC} Cannot detect Linux distribution"
            exit 1
        fi

        echo
        echo -e "${GREEN}[SUCCESS]${NC} C/C++ LSP server installed!"
        ;;

    *)
        echo -e "${RED}[ERROR]${NC} Unsupported OS: $OS"
        exit 1
        ;;
esac

echo
echo "Verify installation:"
echo "  clangd --version"
echo
echo -e "${YELLOW}[TIP]${NC} For best results, generate compile_commands.json:"
echo "  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build"
echo "  ln -sf build/compile_commands.json ."
