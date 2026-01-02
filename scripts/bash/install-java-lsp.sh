#!/usr/bin/env bash
# LSP Tools - Java LSP Server Installation
# Installs Eclipse JDT Language Server (jdtls)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Java LSP Server Installation ==="
echo "Server: jdtls (Eclipse JDT Language Server)"
echo

# Check if already installed
if command -v jdtls &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} jdtls is already installed"
    exit 0
fi

# Check for existing installation directory
if [[ -d "$HOME/jdtls" ]]; then
    echo -e "${GREEN}[OK]${NC} jdtls found in ~/jdtls"
    echo "Add jdtls to PATH or create a wrapper script"
    exit 0
fi

# Check Java version (jdtls requires Java 21+)
if ! command -v java &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Java is required but not installed"
    echo "Install OpenJDK 21+ from https://adoptium.net"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F'"' '{print $2}' | cut -d'.' -f1)
if [[ "$JAVA_VERSION" -lt 21 ]]; then
    echo -e "${YELLOW}[WARN]${NC} Java 21+ required for jdtls (found Java $JAVA_VERSION)"
    echo "Upgrade Java from https://adoptium.net"
fi

# Try Homebrew on macOS (preferred)
if [[ "$(uname -s)" == "Darwin" ]] && command -v brew &>/dev/null; then
    echo "Installing jdtls via Homebrew..."
    brew install jdtls

    echo
    echo -e "${GREEN}[SUCCESS]${NC} Java LSP server installed via Homebrew!"
    exit 0
fi

# Manual installation
echo "Installing jdtls manually..."
echo

INSTALL_DIR="$HOME/jdtls"
DOWNLOAD_URL="http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"

echo "Downloading jdtls..."
curl -LO "$DOWNLOAD_URL"

echo "Extracting to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
tar -xzf jdt-language-server-latest.tar.gz -C "$INSTALL_DIR"
rm jdt-language-server-latest.tar.gz

# Create wrapper script
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

cat > "$LOCAL_BIN/jdtls" << 'WRAPPER'
#!/bin/bash
# jdtls wrapper script

JDTLS_HOME="$HOME/jdtls"
CONFIG_DIR="$JDTLS_HOME/config_$(uname -s | tr '[:upper:]' '[:lower:]')"

exec java \
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    -Dosgi.bundles.defaultStartLevel=4 \
    -Declipse.product=org.eclipse.jdt.ls.core.product \
    -noverify \
    -Xms1G \
    -jar "$JDTLS_HOME"/plugins/org.eclipse.equinox.launcher_*.jar \
    -configuration "$CONFIG_DIR" \
    "$@"
WRAPPER

chmod +x "$LOCAL_BIN/jdtls"

echo
echo -e "${GREEN}[SUCCESS]${NC} Java LSP server installed!"
echo
echo "Wrapper script created at: $LOCAL_BIN/jdtls"
echo
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo -e "${YELLOW}[NOTE]${NC} Add ~/.local/bin to PATH:"
    echo "  export PATH=\"\$PATH:\$HOME/.local/bin\""
fi
