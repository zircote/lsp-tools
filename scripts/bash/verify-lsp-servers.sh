#!/usr/bin/env bash
# LSP Tools - Verify LSP Server Installations
# Checks which LSP servers are installed and reports status

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Arrays to track status
INSTALLED=()
MISSING=()

check_server() {
    local name="$1"
    local cmd="$2"
    local fallback_check="${3:-}"

    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        echo -e "${GREEN}[OK]${NC} $name: $version"
        INSTALLED+=("$name")
        return 0
    elif [[ -n "$fallback_check" ]] && eval "$fallback_check" 2>/dev/null; then
        echo -e "${GREEN}[OK]${NC} $name: installed (via package manager)"
        INSTALLED+=("$name")
        return 0
    else
        echo -e "${RED}[MISSING]${NC} $name"
        MISSING+=("$name")
        return 1
    fi
}

echo "=== LSP Server Status ==="
echo

# Check each language server
check_server "TypeScript (vtsls)" "vtsls" "npm list -g @vtsls/language-server | grep -q vtsls"
check_server "Python (pyright)" "pyright"
check_server "Rust (rust-analyzer)" "rust-analyzer"
check_server "Go (gopls)" "gopls"
check_server "Java (jdtls)" "jdtls" "[ -d $HOME/jdtls ]"
check_server "Kotlin (kotlin-language-server)" "kotlin-language-server"
check_server "C/C++ (clangd)" "clangd"
check_server "C# (omnisharp)" "omnisharp" "command -v OmniSharp"
check_server "PHP (phpactor)" "phpactor"
check_server "Ruby (ruby-lsp)" "ruby-lsp" "command -v solargraph"
check_server "HTML/CSS (vscode-html-language-server)" "vscode-html-language-server"
check_server "LaTeX (texlab)" "texlab"

echo
echo "=== Environment ==="
if [[ "${ENABLE_LSP_TOOL:-}" == "1" ]]; then
    echo -e "${GREEN}[OK]${NC} ENABLE_LSP_TOOL=1"
else
    echo -e "${RED}[MISSING]${NC} ENABLE_LSP_TOOL not set"
    echo "       Add to ~/.bashrc or ~/.zshrc:"
    echo "         export ENABLE_LSP_TOOL=1"
fi

echo
echo "=== Summary ==="
echo -e "${GREEN}Installed:${NC} ${#INSTALLED[@]}"
echo -e "${RED}Missing:${NC} ${#MISSING[@]}"

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo
    echo "To install missing servers, use /lsp-tools:lsp-setup"
    exit 1
fi

exit 0
