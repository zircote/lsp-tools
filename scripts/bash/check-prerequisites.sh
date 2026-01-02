#!/usr/bin/env bash
# LSP Tools - Prerequisite Checker
# Verifies system prerequisites for LSP server installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track status
MISSING_PREREQS=()

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_fail() {
    echo -e "${RED}[MISSING]${NC} $1"
    MISSING_PREREQS+=("$1")
}

check_command() {
    local name="$1"
    local cmd="$2"
    local install_hint="${3:-}"

    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        log_ok "$name: $version"
        return 0
    else
        log_fail "$name not found"
        if [[ -n "$install_hint" ]]; then
            echo "       Install: $install_hint"
        fi
        return 1
    fi
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian) echo "debian" ;;
                    fedora|rhel|centos) echo "fedora" ;;
                    arch|manjaro) echo "arch" ;;
                    *) echo "linux" ;;
                esac
            else
                echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

echo "=== LSP Tools Prerequisite Check ==="
echo "OS Detected: $(detect_os)"
echo

echo "--- Package Managers ---"
check_command "npm" "npm" "Install Node.js from https://nodejs.org"
check_command "pip" "pip" "Install Python from https://python.org" || \
    check_command "pip3" "pip3" "Install Python from https://python.org"

OS=$(detect_os)
case "$OS" in
    macos)
        check_command "Homebrew" "brew" "Install from https://brew.sh"
        ;;
    debian)
        check_command "apt" "apt" "Should be pre-installed on Debian/Ubuntu"
        ;;
    fedora)
        check_command "dnf" "dnf" "Should be pre-installed on Fedora/RHEL"
        ;;
    arch)
        check_command "pacman" "pacman" "Should be pre-installed on Arch"
        ;;
esac

echo
echo "--- Language Runtimes ---"
check_command "Node.js" "node" "Install from https://nodejs.org"
check_command "Python" "python3" "Install from https://python.org"
check_command "Go" "go" "Install from https://go.dev/dl/"
check_command "Rust (cargo)" "cargo" "Install from https://rustup.rs"
check_command "Ruby" "ruby" "Install via rbenv or system package manager"
check_command "PHP" "php" "Install via system package manager"
check_command "Java" "java" "Install OpenJDK 21+ from https://adoptium.net"
check_command "Composer" "composer" "Install from https://getcomposer.org"

echo
echo "--- Optional Tools ---"
check_command "rustup" "rustup" "Install from https://rustup.rs" || true

echo
echo "=== Summary ==="
if [[ ${#MISSING_PREREQS[@]} -eq 0 ]]; then
    echo -e "${GREEN}All prerequisites satisfied!${NC}"
    exit 0
else
    echo -e "${YELLOW}Missing prerequisites: ${#MISSING_PREREQS[@]}${NC}"
    for prereq in "${MISSING_PREREQS[@]}"; do
        echo "  - $prereq"
    done
    exit 1
fi
