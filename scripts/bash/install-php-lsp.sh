#!/usr/bin/env bash
# LSP Tools - PHP LSP Server Installation
# Installs phpactor

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== PHP LSP Server Installation ==="
echo "Server: phpactor"
echo

# Check if already installed
if command -v phpactor &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} phpactor is already installed"
    phpactor --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check for Composer
if ! command -v composer &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Composer is required but not installed"
    echo "Install from https://getcomposer.org"
    exit 1
fi

# Check PHP version
if ! command -v php &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} PHP is required but not installed"
    exit 1
fi

PHP_VERSION=$(php -r 'echo PHP_VERSION;' | cut -d'.' -f1,2)
echo "PHP version: $PHP_VERSION"

echo "Installing phpactor via Composer global..."
composer global require phpactor/phpactor

# Check Composer bin in PATH
COMPOSER_BIN="$HOME/.composer/vendor/bin"
if [[ -d "$HOME/.config/composer/vendor/bin" ]]; then
    COMPOSER_BIN="$HOME/.config/composer/vendor/bin"
fi

echo
echo -e "${GREEN}[SUCCESS]${NC} PHP LSP server installed!"
echo

if [[ ":$PATH:" != *":$COMPOSER_BIN:"* ]]; then
    echo -e "${YELLOW}[IMPORTANT]${NC} Add Composer bin to PATH:"
    echo "  export PATH=\"\$PATH:$COMPOSER_BIN\""
    echo
fi

echo "Verify installation:"
echo "  phpactor --version"
echo
echo -e "${YELLOW}[ALTERNATIVE]${NC} Intelephense (commercial):"
echo "  npm install -g intelephense"
