# Claude Code LSP Setup Guide - All Languages

## Prerequisites

### 1. Enable LSP Tools (Required for All Languages)
Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export ENABLE_LSP_TOOLS=1
```

Restart your shell or run `source ~/.bashrc`.

### 2. Add the LSP Plugin Marketplace

```bash
# Add the community marketplace
claude /plugin marketplace add https://github.com/boostvolt/claude-code-lsps

# View available plugins
claude /plugin discover
```

---

## Language-Specific Setup

### Python
```bash
# Install language server
npm install -g pyright
# Or: pip install pyright

# Install plugin
claude /plugin install python-lsp

# Recommended tools
uv add --dev ruff pyright pytest
```

### TypeScript/JavaScript
```bash
# Install language server
npm install -g @vtsls/language-server typescript

# Install plugin
claude /plugin install typescript-lsp

# Recommended tools (in project)
npm install -D eslint prettier typescript
```

### Rust
```bash
# Install language server
rustup component add rust-analyzer

# Install plugin
claude /plugin install rust-lsp

# Tools included with cargo
# cargo clippy, cargo fmt
```

### Go
```bash
# Install language server
go install golang.org/x/tools/gopls@latest

# Install plugin
claude /plugin install go-lsp

# Recommended tools
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### Java
```bash
# Install language server
# macOS
brew install jdtls

# Or download from Eclipse
curl -LO http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
mkdir -p ~/jdtls && tar -xzf jdt-language-server-latest.tar.gz -C ~/jdtls

# Requires Java 21+ for the server
# Install plugin
claude /plugin install java-lsp
```

### Kotlin
```bash
# Install language server (macOS)
brew install JetBrains/utils/kotlin-lsp

# Or download from JetBrains releases
# Requires Java 17+

# Install plugin
claude /plugin install kotlin-lsp
```

### C/C++
```bash
# Install language server
# macOS
brew install llvm

# Ubuntu/Debian
sudo apt install clangd

# Arch
sudo pacman -S clang

# Install plugin
claude /plugin install cpp-lsp

# Generate compile_commands.json for best results
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
```

### C#
```bash
# Install language server
# macOS
brew install omnisharp/omnisharp-roslyn/omnisharp-mono

# Or download from OmniSharp releases
# https://github.com/OmniSharp/omnisharp-roslyn/releases

# Install plugin
claude /plugin install csharp-lsp
```

### PHP
```bash
# Install language server
composer global require phpactor/phpactor

# Ensure ~/.composer/vendor/bin is in PATH
export PATH="$PATH:$HOME/.composer/vendor/bin"

# Install plugin
claude /plugin install php-lsp

# Recommended tools (in project)
composer require --dev phpstan/phpstan friendsofphp/php-cs-fixer
```

### Ruby
```bash
# Install language server
gem install ruby-lsp
# Or: gem install solargraph

# Install plugin
claude /plugin install ruby-lsp

# Recommended tools
gem install rubocop
```

### HTML/CSS
```bash
# Install language servers
npm install -g vscode-langservers-extracted

# Install plugin
claude /plugin install html-css-lsp

# Recommended tools
npm install -g prettier stylelint htmlhint
```

### LaTeX
```bash
# Install language server
# macOS
brew install texlab

# Arch
pacman -S texlab

# Cargo
cargo install --locked texlab

# Install plugin
claude /plugin install latex-lsp
```

---

## Verification

Check that plugins are installed:
```bash
claude /plugin list
```

Check for errors:
```bash
claude /plugin errors
```

Test LSP in a session:
```
claude
> Use LSP to find the definition of [function_name] in [file]
> Get LSP diagnostics for [file]
```

---

## Project Setup

### 1. Copy CLAUDE.md Section
Choose the appropriate `*-lsp-section.md` file for your language and append to your project's `CLAUDE.md`:

```bash
cat typescript-lsp-section.md >> your-project/CLAUDE.md
```

### 2. Configure Hooks
Copy the appropriate hooks file to your project:

```bash
mkdir -p your-project/.claude
cp typescript-hooks.json your-project/.claude/hooks.json
```

### 3. For Multi-Language Projects
Combine relevant sections in CLAUDE.md and merge hooks:

```bash
# Combine CLAUDE.md sections
cat typescript-lsp-section.md python-lsp-section.md >> your-project/CLAUDE.md

# Manually merge hooks.json files or use jq:
jq -s '{ hooks: [ .[0].hooks[], .[1].hooks[] ] }' \
  typescript-hooks.json python-hooks.json > your-project/.claude/hooks.json
```

---

## Troubleshooting

### LSP Not Working
1. Verify `ENABLE_LSP_TOOLS=1`: `echo $ENABLE_LSP_TOOLS`
2. Check plugin: `claude /plugin list`
3. Verify server installed: `which <server>` (e.g., `which pyright`, `which gopls`)
4. Check errors: `claude /plugin errors`

### Slow Performance
Language servers can degrade over long sessions. Restart manually:
```
> Restart the [language] LSP server
```

### Missing Features
Some LSP operations require project configuration:
- **C/C++**: Need `compile_commands.json`
- **Java**: Need proper Maven/Gradle setup
- **TypeScript**: Need `tsconfig.json`

### Server Not Found
Ensure the binary is in your PATH:
```bash
# Check PATH
echo $PATH

# Add to PATH (example for Go)
export PATH="$PATH:$(go env GOPATH)/bin"
```

---

## Quick Reference: LSP Operations

| Operation | Description | When to Use |
|-----------|-------------|-------------|
| `goToDefinition` | Jump to symbol definition | Before modifying unfamiliar code |
| `findReferences` | Find all usages | Before refactoring |
| `documentSymbol` | Get file structure | Understanding large files |
| `diagnostics` | Get errors/warnings | After making changes |
| `hover` | Get type/docs info | Understanding APIs |

---

## Files in This Package

| File | Description |
|------|-------------|
| `python-lsp-section.md` | Python CLAUDE.md additions |
| `python-hooks.json` | Python hooks (ruff, pyright) |
| `typescript-lsp-section.md` | TypeScript/JS CLAUDE.md additions |
| `typescript-hooks.json` | TypeScript hooks (prettier, eslint, tsc) |
| `rust-lsp-section.md` | Rust CLAUDE.md additions |
| `rust-hooks.json` | Rust hooks (cargo fmt, clippy) |
| `go-lsp-section.md` | Go CLAUDE.md additions |
| `go-hooks.json` | Go hooks (goimports, go vet) |
| `java-lsp-section.md` | Java CLAUDE.md additions |
| `java-hooks.json` | Java hooks (Maven/Gradle) |
| `kotlin-lsp-section.md` | Kotlin CLAUDE.md additions |
| `kotlin-hooks.json` | Kotlin hooks (ktlint, Gradle) |
| `cpp-lsp-section.md` | C/C++ CLAUDE.md additions |
| `cpp-hooks.json` | C/C++ hooks (clang-format, clang-tidy) |
| `csharp-lsp-section.md` | C# CLAUDE.md additions |
| `csharp-hooks.json` | C# hooks (dotnet format) |
| `php-lsp-section.md` | PHP CLAUDE.md additions |
| `php-hooks.json` | PHP hooks (php-cs-fixer, phpstan) |
| `ruby-lsp-section.md` | Ruby CLAUDE.md additions |
| `ruby-hooks.json` | Ruby hooks (rubocop) |
| `html-css-lsp-section.md` | HTML/CSS CLAUDE.md additions |
| `html-css-hooks.json` | HTML/CSS hooks (prettier, stylelint) |
| `latex-lsp-section.md` | LaTeX CLAUDE.md additions |
| `latex-hooks.json` | LaTeX hooks (chktex, latexmk) |
