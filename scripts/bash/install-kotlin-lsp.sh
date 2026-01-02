#!/usr/bin/env bash
# LSP Tools - Kotlin LSP Server Installation
# Installs kotlin-language-server

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Kotlin LSP Server Installation ==="
echo "Server: kotlin-language-server"
echo

# Check if already installed
if command -v kotlin-language-server &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} kotlin-language-server is already installed"
    kotlin-language-server --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check Java version (Kotlin LSP requires Java 17+)
if ! command -v java &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Java is required but not installed"
    echo "Install OpenJDK 17+ from https://adoptium.net"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}' | cut -d'.' -f1)
if [[ "$JAVA_VERSION" -lt 17 ]]; then
    echo -e "${YELLOW}[WARN]${NC} Java 17+ required for Kotlin LSP (found Java $JAVA_VERSION)"
    echo "Upgrade Java from https://adoptium.net"
fi

# Try Homebrew on macOS (preferred)
if [[ "$(uname -s)" == "Darwin" ]] && command -v brew &>/dev/null; then
    echo "Installing kotlin-language-server via Homebrew..."
    brew install JetBrains/utils/kotlin-lsp

    echo
    echo -e "${GREEN}[SUCCESS]${NC} Kotlin LSP server installed via Homebrew!"
    exit 0
fi

# Manual installation from GitHub releases
echo "Installing kotlin-language-server manually..."
echo

INSTALL_DIR="$HOME/.local/kotlin-language-server"
LOCAL_BIN="$HOME/.local/bin"
RELEASES_URL="https://api.github.com/repos/fwcd/kotlin-language-server/releases/latest"

# Get latest release URL
echo "Fetching latest release..."
DOWNLOAD_URL=$(curl -s "$RELEASES_URL" | grep "browser_download_url.*server.zip" | head -1 | cut -d'"' -f4)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo -e "${RED}[ERROR]${NC} Could not find release download URL"
    echo "Manual installation: https://github.com/fwcd/kotlin-language-server/releases"
    exit 1
fi

echo "Downloading from: $DOWNLOAD_URL"
curl -L -o kotlin-lsp.zip "$DOWNLOAD_URL"

echo "Extracting to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
unzip -q kotlin-lsp.zip -d "$HOME/.local/"
mv "$HOME/.local/server" "$INSTALL_DIR"
rm kotlin-lsp.zip

# Create symlink
mkdir -p "$LOCAL_BIN"
ln -sf "$INSTALL_DIR/bin/kotlin-language-server" "$LOCAL_BIN/kotlin-language-server"
chmod +x "$INSTALL_DIR/bin/kotlin-language-server"

echo
echo -e "${GREEN}[SUCCESS]${NC} Kotlin LSP server installed!"
echo
echo "Installed to: $INSTALL_DIR"
echo "Symlink: $LOCAL_BIN/kotlin-language-server"
echo
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo -e "${YELLOW}[NOTE]${NC} Add ~/.local/bin to PATH:"
    echo "  export PATH=\"\$PATH:\$HOME/.local/bin\""
fi
