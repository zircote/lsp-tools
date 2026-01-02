# LSP Server Registry

Machine-readable registry of LSP servers with verification and installation commands for all supported languages and platforms.

## Server Definitions

### TypeScript/JavaScript

| Property | Value |
|----------|-------|
| **Server Name** | vtsls |
| **Package** | @vtsls/language-server |
| **Verify Command** | `command -v vtsls || npm list -g @vtsls/language-server 2>/dev/null | grep -q vtsls` |
| **Executable Check** | `which vtsls` or check npm global |
| **Minimum Version** | N/A |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (npm) | `npm install -g @vtsls/language-server typescript` |
| All (pnpm) | `pnpm add -g @vtsls/language-server typescript` |
| All (yarn) | `yarn global add @vtsls/language-server typescript` |

**Additional Requirements:**
- Node.js 18+ (LTS recommended)
- TypeScript (installed alongside)

---

### Python

| Property | Value |
|----------|-------|
| **Server Name** | pyright |
| **Package** | pyright (npm) or pyright (pip) |
| **Verify Command** | `command -v pyright` |
| **Executable Check** | `which pyright` |
| **Minimum Version** | 1.1.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (npm) | `npm install -g pyright` |
| All (pip) | `pip install pyright` |
| All (uv) | `uv tool install pyright` |
| All (pipx) | `pipx install pyright` |

**Additional Requirements:**
- Node.js 14+ (for npm install)
- Python 3.8+

---

### Rust

| Property | Value |
|----------|-------|
| **Server Name** | rust-analyzer |
| **Package** | rustup component |
| **Verify Command** | `command -v rust-analyzer` |
| **Executable Check** | `which rust-analyzer` |
| **Minimum Version** | 2024-01-01+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (rustup) | `rustup component add rust-analyzer` |
| macOS (brew) | `brew install rust-analyzer` |
| Arch Linux | `sudo pacman -S rust-analyzer` |
| Ubuntu/Debian | Download from GitHub releases |

**Additional Requirements:**
- Rust toolchain via rustup (recommended)
- `rust-analyzer` must be in PATH

---

### Go

| Property | Value |
|----------|-------|
| **Server Name** | gopls |
| **Package** | golang.org/x/tools/gopls |
| **Verify Command** | `command -v gopls` |
| **Executable Check** | `which gopls` |
| **Minimum Version** | 0.14.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (go install) | `go install golang.org/x/tools/gopls@latest` |
| macOS (brew) | `brew install gopls` |
| Arch Linux | `sudo pacman -S gopls` |

**PATH Requirement:**
- Ensure `$(go env GOPATH)/bin` is in PATH:
  ```bash
  export PATH="$PATH:$(go env GOPATH)/bin"
  ```

**Additional Requirements:**
- Go 1.21+

---

### Java

| Property | Value |
|----------|-------|
| **Server Name** | jdtls |
| **Package** | Eclipse JDT Language Server |
| **Verify Command** | `command -v jdtls || [ -d "$HOME/jdtls" ]` |
| **Executable Check** | `which jdtls` or check ~/jdtls |
| **Minimum Version** | 1.30.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| macOS (brew) | `brew install jdtls` |
| Manual (all) | See manual installation below |

**Manual Installation:**
```bash
# Download latest snapshot
curl -LO http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz

# Extract to home directory
mkdir -p ~/jdtls
tar -xzf jdt-language-server-latest.tar.gz -C ~/jdtls

# Add wrapper script to PATH
cat > ~/.local/bin/jdtls << 'EOF'
#!/bin/bash
exec java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -noverify \
  -Xms1G \
  -jar ~/jdtls/plugins/org.eclipse.equinox.launcher_*.jar \
  -configuration ~/jdtls/config_$(uname -s | tr '[:upper:]' '[:lower:]') \
  "$@"
EOF
chmod +x ~/.local/bin/jdtls
```

**Additional Requirements:**
- Java 21+ (for jdtls itself)
- Maven or Gradle (for project support)

---

### Kotlin

| Property | Value |
|----------|-------|
| **Server Name** | kotlin-language-server |
| **Package** | JetBrains kotlin-lsp |
| **Verify Command** | `command -v kotlin-language-server` |
| **Executable Check** | `which kotlin-language-server` |
| **Minimum Version** | 1.3.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| macOS (brew) | `brew install JetBrains/utils/kotlin-lsp` |
| Manual (all) | Download from JetBrains GitHub releases |

**Additional Requirements:**
- Java 17+ (for Kotlin LSP)
- Kotlin compiler (for project support)

---

### C/C++

| Property | Value |
|----------|-------|
| **Server Name** | clangd |
| **Package** | Part of LLVM/Clang |
| **Verify Command** | `command -v clangd` |
| **Executable Check** | `which clangd` |
| **Minimum Version** | 15.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| macOS (brew) | `brew install llvm && echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zshrc` |
| Ubuntu/Debian | `sudo apt install clangd` |
| Arch Linux | `sudo pacman -S clang` |
| Fedora | `sudo dnf install clang-tools-extra` |
| Windows | Download from LLVM releases |

**Best Results:**
- Generate `compile_commands.json`:
  ```bash
  # CMake projects
  cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
  ln -s build/compile_commands.json .

  # Bear for other build systems
  bear -- make
  ```

---

### C#

| Property | Value |
|----------|-------|
| **Server Name** | OmniSharp |
| **Package** | omnisharp-roslyn |
| **Verify Command** | `command -v omnisharp || command -v OmniSharp` |
| **Executable Check** | `which omnisharp` |
| **Minimum Version** | 1.39.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| macOS (brew) | `brew install omnisharp/omnisharp-roslyn/omnisharp-mono` |
| .NET SDK | Included with .NET 6+ SDK |
| Manual (all) | Download from OmniSharp GitHub releases |

**Additional Requirements:**
- .NET SDK 6.0+ or Mono

---

### PHP

| Property | Value |
|----------|-------|
| **Server Name** | phpactor |
| **Package** | phpactor/phpactor |
| **Verify Command** | `command -v phpactor` |
| **Executable Check** | `which phpactor` |
| **Minimum Version** | 2023.01+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (composer) | `composer global require phpactor/phpactor` |
| macOS (brew) | `brew install phpactor` |

**PATH Requirement:**
```bash
export PATH="$PATH:$HOME/.composer/vendor/bin"
```

**Alternative: Intelephense**
```bash
npm install -g intelephense
```

---

### Ruby

| Property | Value |
|----------|-------|
| **Server Name** | ruby-lsp |
| **Package** | ruby-lsp gem |
| **Verify Command** | `command -v ruby-lsp` |
| **Executable Check** | `which ruby-lsp` |
| **Minimum Version** | 0.13.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (gem) | `gem install ruby-lsp` |
| Bundler | Add `gem 'ruby-lsp', group: :development` to Gemfile |

**Alternative: Solargraph**
```bash
gem install solargraph
```

---

### HTML/CSS

| Property | Value |
|----------|-------|
| **Server Name** | vscode-langservers-extracted |
| **Package** | vscode-langservers-extracted |
| **Verify Command** | `command -v vscode-html-language-server` |
| **Executable Check** | `which vscode-html-language-server` |
| **Minimum Version** | 4.8.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| All (npm) | `npm install -g vscode-langservers-extracted` |

**Provides:**
- `vscode-html-language-server`
- `vscode-css-language-server`
- `vscode-json-language-server`
- `vscode-eslint-language-server`

---

### LaTeX

| Property | Value |
|----------|-------|
| **Server Name** | texlab |
| **Package** | texlab |
| **Verify Command** | `command -v texlab` |
| **Executable Check** | `which texlab` |
| **Minimum Version** | 5.10.0+ |

**Installation by Platform:**

| Platform | Command |
|----------|---------|
| macOS (brew) | `brew install texlab` |
| Arch Linux | `sudo pacman -S texlab` |
| Cargo | `cargo install --locked texlab` |
| Snap | `sudo snap install texlab` |

**Additional Requirements:**
- TeX distribution (TeX Live, MiKTeX)

---

## Verification Script

Use this script to check all installed LSP servers:

```bash
#!/bin/bash
# lsp-check.sh - Verify LSP server installations

echo "=== LSP Server Status ==="
echo

check_server() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" &>/dev/null; then
        local version=$("$cmd" --version 2>/dev/null | head -1 || echo "installed")
        echo "✓ $name: $version"
        return 0
    else
        echo "✗ $name: not found"
        return 1
    fi
}

check_server "TypeScript (vtsls)" "vtsls" || \
    npm list -g @vtsls/language-server 2>/dev/null | grep -q vtsls && echo "  (installed via npm)"

check_server "Python (pyright)" "pyright"
check_server "Go (gopls)" "gopls"
check_server "Rust (rust-analyzer)" "rust-analyzer"
check_server "Java (jdtls)" "jdtls"
check_server "Kotlin (kotlin-language-server)" "kotlin-language-server"
check_server "C/C++ (clangd)" "clangd"
check_server "C# (omnisharp)" "omnisharp"
check_server "PHP (phpactor)" "phpactor"
check_server "Ruby (ruby-lsp)" "ruby-lsp"
check_server "HTML/CSS (vscode-html-language-server)" "vscode-html-language-server"
check_server "LaTeX (texlab)" "texlab"

echo
echo "=== Environment ==="
[ "$ENABLE_LSP_TOOL" = "1" ] && echo "✓ ENABLE_LSP_TOOL=1" || echo "✗ ENABLE_LSP_TOOL not set"
```

---

## Quick Reference Table

| Language | Server | Verify | Primary Install |
|----------|--------|--------|-----------------|
| TypeScript/JS | vtsls | `which vtsls` | `npm i -g @vtsls/language-server typescript` |
| Python | pyright | `which pyright` | `npm i -g pyright` |
| Rust | rust-analyzer | `which rust-analyzer` | `rustup component add rust-analyzer` |
| Go | gopls | `which gopls` | `go install golang.org/x/tools/gopls@latest` |
| Java | jdtls | `which jdtls` | `brew install jdtls` |
| Kotlin | kotlin-language-server | `which kotlin-language-server` | `brew install JetBrains/utils/kotlin-lsp` |
| C/C++ | clangd | `which clangd` | `brew install llvm` / `apt install clangd` |
| C# | omnisharp | `which omnisharp` | `brew install omnisharp/omnisharp-roslyn/omnisharp-mono` |
| PHP | phpactor | `which phpactor` | `composer global require phpactor/phpactor` |
| Ruby | ruby-lsp | `which ruby-lsp` | `gem install ruby-lsp` |
| HTML/CSS | vscode-html-language-server | `which vscode-html-language-server` | `npm i -g vscode-langservers-extracted` |
| LaTeX | texlab | `which texlab` | `brew install texlab` |
