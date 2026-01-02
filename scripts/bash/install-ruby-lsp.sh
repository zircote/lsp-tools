#!/usr/bin/env bash
# LSP Tools - Ruby LSP Server Installation
# Installs ruby-lsp

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Ruby LSP Server Installation ==="
echo "Server: ruby-lsp"
echo

# Check if already installed
if command -v ruby-lsp &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} ruby-lsp is already installed"
    ruby-lsp --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check for alternative: solargraph
if command -v solargraph &>/dev/null; then
    echo -e "${GREEN}[OK]${NC} solargraph (alternative Ruby LSP) is already installed"
    solargraph --version 2>/dev/null || echo "(version check not available)"
    exit 0
fi

# Check Ruby and gem
if ! command -v ruby &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} Ruby is required but not installed"
    echo "Install via rbenv, rvm, or system package manager"
    exit 1
fi

if ! command -v gem &>/dev/null; then
    echo -e "${RED}[ERROR]${NC} gem is required but not found"
    exit 1
fi

RUBY_VERSION=$(ruby -v | cut -d' ' -f2)
echo "Ruby version: $RUBY_VERSION"

echo "Installing ruby-lsp gem..."
gem install ruby-lsp

echo
echo -e "${GREEN}[SUCCESS]${NC} Ruby LSP server installed!"
echo
echo "Verify installation:"
echo "  ruby-lsp --version"
echo
echo -e "${YELLOW}[ALTERNATIVE]${NC} Solargraph:"
echo "  gem install solargraph"
echo
echo -e "${YELLOW}[TIP]${NC} For project-specific installation, add to Gemfile:"
echo "  gem 'ruby-lsp', group: :development"
