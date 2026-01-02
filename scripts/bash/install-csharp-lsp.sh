#!/usr/bin/env bash
# LSP Tools - C# LSP Server Installation
# Installs OmniSharp

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== C# LSP Server Installation ==="
echo "Server: OmniSharp"
echo

# Check if already installed
if command -v omnisharp &>/dev/null || command -v OmniSharp &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} OmniSharp is already installed"
    omnisharp --version 2>/dev/null || OmniSharp --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check for .NET SDK (includes language server)
if command -v dotnet &>/dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    MAJOR_VERSION=$(echo "$DOTNET_VERSION" | cut -d'.' -f1)

    if [[ "$MAJOR_VERSION" -ge 6 ]]; then
        echo -e "${GREEN}[OK]${NC} .NET $DOTNET_VERSION includes built-in language server"
        echo "OmniSharp standalone is optional with .NET 6+"
        exit 0
    fi
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

        echo "Installing OmniSharp via Homebrew..."
        brew install omnisharp/omnisharp-roslyn/omnisharp-mono

        echo
        echo -e "${GREEN}[SUCCESS]${NC} C# LSP server installed!"
        ;;

    Linux)
        # Linux - download from GitHub releases
        echo "Installing OmniSharp from GitHub releases..."

        INSTALL_DIR="$HOME/.local/omnisharp"
        LOCAL_BIN="$HOME/.local/bin"
        RELEASES_URL="https://api.github.com/repos/OmniSharp/omnisharp-roslyn/releases/latest"

        # Detect architecture
        ARCH="$(uname -m)"
        case "$ARCH" in
            x86_64) PLATFORM="linux-x64" ;;
            aarch64) PLATFORM="linux-arm64" ;;
            *)
                echo -e "${RED}[ERROR]${NC} Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac

        echo "Fetching latest release for $PLATFORM..."
        DOWNLOAD_URL=$(curl -s "$RELEASES_URL" | grep "browser_download_url.*$PLATFORM.*tar.gz" | head -1 | cut -d'"' -f4)

        if [[ -z "$DOWNLOAD_URL" ]]; then
            echo -e "${RED}[ERROR]${NC} Could not find release for $PLATFORM"
            exit 1
        fi

        echo "Downloading from: $DOWNLOAD_URL"
        curl -L -o omnisharp.tar.gz "$DOWNLOAD_URL"

        echo "Extracting to $INSTALL_DIR..."
        rm -rf "$INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        tar -xzf omnisharp.tar.gz -C "$INSTALL_DIR"
        rm omnisharp.tar.gz

        # Create symlink
        mkdir -p "$LOCAL_BIN"
        ln -sf "$INSTALL_DIR/OmniSharp" "$LOCAL_BIN/omnisharp"
        chmod +x "$INSTALL_DIR/OmniSharp"

        echo
        echo -e "${GREEN}[SUCCESS]${NC} C# LSP server installed!"
        echo
        echo "Installed to: $INSTALL_DIR"
        echo "Symlink: $LOCAL_BIN/omnisharp"
        echo
        if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
            echo -e "${YELLOW}[NOTE]${NC} Add ~/.local/bin to PATH:"
            echo "  export PATH=\"\$PATH:\$HOME/.local/bin\""
        fi
        ;;

    *)
        echo -e "${RED}[ERROR]${NC} Unsupported OS: $OS"
        exit 1
        ;;
esac

echo
echo "Verify installation:"
echo "  omnisharp --version"
