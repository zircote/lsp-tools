# LSP Setup and Verification Guide

How to enable, verify, and troubleshoot LSP in Claude Code.

## Quick Setup

### Step 1: Enable LSP Tools

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, `~/.profile`):

```bash
export ENABLE_LSP_TOOL=1
```

Then reload:

```bash
source ~/.bashrc  # or ~/.zshrc
```

### Step 2: Verify Environment

```bash
echo $ENABLE_LSP_TOOL
# Should output: 1
```

### Step 3: Install Language Server

Choose your language:

| Language | Installation |
|----------|-------------|
| TypeScript/JS | `npm install -g @vtsls/language-server typescript` |
| Python | `npm install -g pyright` or `pip install pyright` |
| Go | `go install golang.org/x/tools/gopls@latest` |
| Rust | `rustup component add rust-analyzer` |
| Java | `brew install jdtls` or download from Eclipse |
| C/C++ | `brew install llvm` (macOS) or `apt install clangd` |
| C# | `brew install omnisharp/omnisharp-roslyn/omnisharp-mono` |
| PHP | `composer global require phpactor/phpactor` |
| Ruby | `gem install ruby-lsp` or `gem install solargraph` |
| Kotlin | `brew install JetBrains/utils/kotlin-lsp` |
| HTML/CSS | `npm install -g vscode-langservers-extracted` |
| LaTeX | `brew install texlab` or `cargo install --locked texlab` |

### Step 4: Install LSP Plugin (Optional)

```bash
# Add community marketplace
claude /plugin marketplace add https://github.com/boostvolt/claude-code-lsps

# View available plugins
claude /plugin discover

# Install for your language
claude /plugin install typescript-lsp
claude /plugin install python-lsp
# etc.
```

## Verification Checklist

### Environment Verification

```bash
# 1. Check environment variable
[ "$ENABLE_LSP_TOOL" = "1" ] && echo "✓ LSP enabled" || echo "✗ LSP not enabled"

# 2. Check language server installed
which pyright && echo "✓ Python LSP" || echo "✗ Python LSP missing"
which gopls && echo "✓ Go LSP" || echo "✗ Go LSP missing"
which rust-analyzer && echo "✓ Rust LSP" || echo "✗ Rust LSP missing"
# Add checks for your languages
```

### Claude Code Verification

In a Claude Code session:

```
> Can you use LSP to find the definition of [function_name] in [file]?
> Get LSP diagnostics for [file]
```

If LSP is working, you'll get semantic results. If not, you'll see an error or fallback message.

### Plugin Verification

```bash
claude /plugin list
claude /plugin errors
```

## Troubleshooting

### Problem: LSP Tool Not Available

**Symptoms:**
- "LSP tool not found"
- "Cannot execute LSP operation"

**Solutions:**
1. Verify `ENABLE_LSP_TOOL=1` is set
2. Restart Claude Code session after setting
3. Check shell profile is loaded correctly

### Problem: Language Server Not Found

**Symptoms:**
- LSP call times out
- "Cannot connect to language server"

**Solutions:**
1. Verify language server is installed: `which <server>`
2. Check server is in PATH: `echo $PATH`
3. Install missing server (see table above)

### Problem: LSP Returns Errors

**Symptoms:**
- "Invalid position"
- "File not found"

**Solutions:**
1. Verify file path is absolute, not relative
2. Check line/character are 1-based (not 0-based)
3. Ensure file exists and is saved

### Problem: Slow LSP Performance

**Symptoms:**
- LSP operations take > 5 seconds
- Timeouts on large projects

**Solutions:**
1. Restart language server (long sessions degrade)
2. Check project size (some servers struggle with huge repos)
3. Exclude large directories (node_modules, vendor, etc.)

### Problem: Race Condition on Startup

**Symptoms:**
- LSP works sometimes, not others
- "LSP not initialized" immediately after start

**Known Issue:** LSP Manager may initialize before plugins load (bug #13952)

**Workaround:**
1. Wait a few seconds after starting Claude Code
2. Or downgrade to version 2.0.67 if persistent

## Language Server Details

### TypeScript/JavaScript

**Server:** vtsls (recommended) or typescript-language-server

```bash
npm install -g @vtsls/language-server typescript
```

**Features:** Full TypeScript/JavaScript support including JSX/TSX

**Requires:** Node.js, npm

### Python

**Server:** pyright (recommended)

```bash
npm install -g pyright
# Or
pip install pyright
```

**Features:** Type checking, completion, diagnostics

**Requires:** Python 3.7+, Node.js (for npm install)

### Go

**Server:** gopls (official)

```bash
go install golang.org/x/tools/gopls@latest
```

**Features:** Full Go support including generics, modules

**Requires:** Go 1.18+

**PATH:** Ensure `$(go env GOPATH)/bin` is in PATH

### Rust

**Server:** rust-analyzer (official)

```bash
rustup component add rust-analyzer
```

**Features:** Full Rust support including macros, async, lifetimes

**Requires:** Rust via rustup

### Java

**Server:** jdtls (Eclipse)

```bash
# macOS
brew install jdtls

# Manual
curl -LO http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
mkdir -p ~/jdtls && tar -xzf jdt-language-server-latest.tar.gz -C ~/jdtls
```

**Features:** Maven/Gradle project support

**Requires:** Java 21+ for the server itself

### C/C++

**Server:** clangd

```bash
# macOS
brew install llvm

# Ubuntu/Debian
sudo apt install clangd

# Arch
sudo pacman -S clang
```

**Best Results:** Generate `compile_commands.json`:
```bash
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
```

## Configuration Files

### Settings Location

Claude Code settings: `~/.claude/settings.json`

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  }
}
```

### Per-Project Configuration

Some language servers use project-level configs:

| Language | Config File |
|----------|-------------|
| TypeScript | `tsconfig.json` |
| Python | `pyrightconfig.json` or `pyproject.toml` |
| Rust | `Cargo.toml` |
| Java | `pom.xml` or `build.gradle` |
| C/C++ | `compile_commands.json` |

## Fallback Behavior

When LSP is unavailable, Claude Code can fall back to grep-based operations.

**Important:** Fallback results are less accurate:
- May include false positives (comments, strings, similar names)
- May miss aliased or re-exported symbols
- Cannot resolve types or provide hover information

**When using fallback:**
1. Note limitation in output
2. Verify results manually if critical
3. Consider fixing LSP setup for future operations
