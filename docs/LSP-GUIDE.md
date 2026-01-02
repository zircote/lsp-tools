# Claude Code LSP Setup and Troubleshooting Guide

A comprehensive guide for enabling, configuring, and troubleshooting Language Server Protocol (LSP) support in Claude Code.

---

## Table of Contents

1. [Overview](#overview)
2. [Setup Guide](#setup-guide)
   - [Prerequisites](#prerequisites)
   - [Enabling LSP in Different Shells](#enabling-lsp-in-different-shells)
   - [Language-Specific Setup](#language-specific-setup)
   - [Verifying LSP is Working](#verifying-lsp-is-working)
3. [Usage Guide](#usage-guide)
   - [LSP Operations Reference](#lsp-operations-reference)
   - [When to Use Each Operation](#when-to-use-each-operation)
   - [Example LSP Tool Calls](#example-lsp-tool-calls)
   - [Best Practices](#best-practices)
4. [Troubleshooting](#troubleshooting)
   - [Common Issues and Solutions](#common-issues-and-solutions)
   - [Diagnostic Commands](#diagnostic-commands)
   - [Language Server Status](#language-server-status)
5. [FAQ](#faq)
6. [Quick Reference](#quick-reference)

---

## Overview

Claude Code includes a built-in LSP tool that provides semantic code intelligence, enabling IDE-like precision for code navigation, refactoring, and understanding. LSP operations are significantly faster and more accurate than grep-based searches, especially in large codebases.

### Why LSP Over Grep?

| Metric | LSP | Grep |
|--------|-----|------|
| **Speed (100+ files)** | ~50-500ms | 45+ seconds |
| **Accuracy** | Exact semantic matches | Text patterns (false positives) |
| **Token usage** | ~500 tokens | Burns tokens on irrelevant matches |
| **Type resolution** | Follows aliases, re-exports | Text only |
| **Scope awareness** | Understands variable scope | Matches all text |

**Real-world example:**
```
Grep "getUserById" -> 500+ matches (comments, strings, similar names)
LSP findReferences -> 23 matches (exact function usages only)
```

---

## Setup Guide

### Prerequisites

Before using LSP in Claude Code, you need:

1. **Environment Variable**: `ENABLE_LSP_TOOL=1` must be set
2. **Language Server**: The appropriate language server for your programming language
3. **Project Configuration**: Some languages require project-level config files

### Enabling LSP in Different Shells

#### Bash (`~/.bashrc`)

```bash
# Add to ~/.bashrc
export ENABLE_LSP_TOOL=1

# Reload configuration
source ~/.bashrc
```

#### Zsh (`~/.zshrc`)

```bash
# Add to ~/.zshrc
export ENABLE_LSP_TOOL=1

# Reload configuration
source ~/.zshrc
```

#### Fish (`~/.config/fish/config.fish`)

```fish
# Add to ~/.config/fish/config.fish
set -gx ENABLE_LSP_TOOL 1

# Reload configuration
source ~/.config/fish/config.fish
```

#### Alternative: Claude Code Settings

You can also set the environment variable in Claude Code's settings file:

```json
// ~/.claude/settings.json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  }
}
```

**Important:** After setting the environment variable, you must restart your Claude Code session for changes to take effect.

### Language-Specific Setup

#### Python (Pyright)

**Installation:**
```bash
# Via npm (recommended)
npm install -g pyright

# Via pip
pip install pyright

# Via uv
uv tool install pyright
```

**Verification:**
```bash
which pyright
pyright --version
```

**Project configuration:** Create `pyrightconfig.json` or use `pyproject.toml`:
```json
{
  "include": ["src"],
  "exclude": ["**/node_modules", "**/__pycache__"],
  "typeCheckingMode": "basic"
}
```

**Recommended dev tools:**
```bash
uv add --dev ruff pyright pytest
```

---

#### TypeScript/JavaScript (vtsls)

**Installation:**
```bash
npm install -g @vtsls/language-server typescript
```

**Verification:**
```bash
which vtsls
```

**Project configuration:** Requires `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

**Recommended dev tools:**
```bash
npm install -D eslint prettier typescript
```

---

#### Go (gopls)

**Installation:**
```bash
go install golang.org/x/tools/gopls@latest
```

**Verification:**
```bash
which gopls
gopls version
```

**PATH configuration:** Ensure Go binaries are in PATH:
```bash
# Add to shell profile
export PATH="$PATH:$(go env GOPATH)/bin"
```

**Recommended tools:**
```bash
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

#### Rust (rust-analyzer)

**Installation:**
```bash
rustup component add rust-analyzer
```

**Verification:**
```bash
which rust-analyzer
rust-analyzer --version
```

**Project configuration:** Requires `Cargo.toml` in project root.

**Note:** rust-analyzer is included with rustup and automatically configured for Cargo projects.

---

#### Java (jdtls)

**Installation (macOS):**
```bash
brew install jdtls
```

**Installation (Manual):**
```bash
curl -LO http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
mkdir -p ~/jdtls && tar -xzf jdt-language-server-latest.tar.gz -C ~/jdtls
export PATH="$PATH:$HOME/jdtls/bin"
```

**Requirements:** Java 21+ for the language server

**Verification:**
```bash
which jdtls
java -version  # Should be 21+
```

**Project configuration:** Requires Maven (`pom.xml`) or Gradle (`build.gradle`) setup.

---

#### C/C++ (clangd)

**Installation (macOS):**
```bash
brew install llvm
```

**Installation (Ubuntu/Debian):**
```bash
sudo apt install clangd
```

**Installation (Arch):**
```bash
sudo pacman -S clang
```

**Verification:**
```bash
which clangd
clangd --version
```

**Project configuration:** Generate `compile_commands.json` for best results:
```bash
# CMake projects
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .

# Bear (for make-based projects)
bear -- make
```

---

#### C# (OmniSharp)

**Installation (macOS):**
```bash
brew install omnisharp/omnisharp-roslyn/omnisharp-mono
```

**Installation (Manual):**
Download from [OmniSharp releases](https://github.com/OmniSharp/omnisharp-roslyn/releases)

**Verification:**
```bash
which omnisharp
```

---

#### PHP (phpactor)

**Installation:**
```bash
composer global require phpactor/phpactor
```

**PATH configuration:**
```bash
export PATH="$PATH:$HOME/.composer/vendor/bin"
```

**Verification:**
```bash
which phpactor
phpactor --version
```

**Recommended tools:**
```bash
composer require --dev phpstan/phpstan friendsofphp/php-cs-fixer
```

---

#### Ruby (ruby-lsp or Solargraph)

**Installation:**
```bash
# ruby-lsp (recommended)
gem install ruby-lsp

# Or Solargraph
gem install solargraph
```

**Verification:**
```bash
which ruby-lsp
# Or
which solargraph
```

**Recommended tools:**
```bash
gem install rubocop
```

---

#### HTML/CSS (vscode-langservers-extracted)

**Installation:**
```bash
npm install -g vscode-langservers-extracted
```

**Verification:**
```bash
which vscode-html-language-server
which vscode-css-language-server
```

**Recommended tools:**
```bash
npm install -g prettier stylelint htmlhint
```

---

#### Kotlin (kotlin-language-server)

**Installation (macOS):**
```bash
brew install JetBrains/utils/kotlin-lsp
```

**Requirements:** Java 17+

---

#### LaTeX (texlab)

**Installation (macOS):**
```bash
brew install texlab
```

**Installation (Cargo):**
```bash
cargo install --locked texlab
```

**Verification:**
```bash
which texlab
texlab --version
```

---

### Verifying LSP is Working

#### Step 1: Check Environment Variable

```bash
echo $ENABLE_LSP_TOOL
# Should output: 1
```

#### Step 2: Check Language Server Installation

```bash
# General check script
check_lsp() {
  echo "Checking LSP environment..."
  [ "$ENABLE_LSP_TOOL" = "1" ] && echo "[OK] LSP enabled" || echo "[FAIL] LSP not enabled"

  echo ""
  echo "Checking language servers..."
  which pyright >/dev/null 2>&1 && echo "[OK] Python (pyright)" || echo "[--] Python (pyright) not found"
  which vtsls >/dev/null 2>&1 && echo "[OK] TypeScript (vtsls)" || echo "[--] TypeScript (vtsls) not found"
  which gopls >/dev/null 2>&1 && echo "[OK] Go (gopls)" || echo "[--] Go (gopls) not found"
  which rust-analyzer >/dev/null 2>&1 && echo "[OK] Rust (rust-analyzer)" || echo "[--] Rust not found"
  which clangd >/dev/null 2>&1 && echo "[OK] C/C++ (clangd)" || echo "[--] C/C++ (clangd) not found"
}
check_lsp
```

#### Step 3: Test in Claude Code Session

Start a Claude Code session and try:

```
> Use LSP to find the definition of [function_name] in [file_path]
> Use LSP hover to get type information for [symbol] in [file_path] at line [N]
> Use LSP findReferences for [symbol] in [file_path]
```

If LSP is working correctly, you will receive semantic results. If not, you will see an error message or a fallback to grep-based search.

---

## Usage Guide

### LSP Operations Reference

| Operation | Purpose | Parameters |
|-----------|---------|------------|
| `goToDefinition` | Jump to where symbol is defined | filePath, line, character |
| `findReferences` | Find all usages of a symbol | filePath, line, character |
| `goToImplementation` | Find interface implementations | filePath, line, character |
| `hover` | Get type info, docs, signatures | filePath, line, character |
| `documentSymbol` | List all symbols in a file | filePath |
| `workspaceSymbol` | Search symbols across codebase | query |
| `prepareCallHierarchy` | Prepare call hierarchy analysis | filePath, line, character |
| `incomingCalls` | Find callers of a function | callHierarchyItem |
| `outgoingCalls` | Find functions called by target | callHierarchyItem |

**Parameter notes:**
- `filePath`: Must be an **absolute path** (e.g., `/Users/project/src/app.ts`)
- `line`: 1-based line number (as shown in editors)
- `character`: 1-based column position

### When to Use Each Operation

#### goToDefinition

**Use before:**
- Modifying unfamiliar code
- Understanding how a function works
- Verifying actual implementation
- Tracing imports to their source

**Example scenarios:**
- Cursor on `getUserById()` - navigate to function definition
- Cursor on imported type - navigate to type definition
- Cursor on variable - navigate to declaration

---

#### findReferences

**Use before:**
- Refactoring or renaming symbols
- Understanding impact of changes
- Finding all callers of a function
- Tracking constant/config usage

**Example scenarios:**
- Find all calls to `validateUser()` before changing signature
- Find all usages of `UserType` before modifying
- Find all imports of a module before relocating

---

#### goToImplementation

**Use when:**
- Working with interfaces or abstract classes
- Finding concrete implementations
- Understanding inheritance hierarchies
- Verifying interface contracts

**Example scenarios:**
- Interface `Repository` - find all implementing classes
- Abstract method `process()` - find all concrete implementations

---

#### hover

**Use for:**
- Quick type checking
- Viewing documentation without navigation
- Understanding function signatures
- Verifying API contracts

**Advantage:** Instant information without file navigation.

---

#### documentSymbol

**Use when:**
- Understanding file structure
- Finding a symbol in a large file
- Getting overview of module exports
- Navigating within a file

---

#### workspaceSymbol

**Use when:**
- Finding where a utility is defined
- Discovering related implementations
- Searching for symbol by partial name
- Cross-module symbol discovery

---

#### incomingCalls / outgoingCalls

**Use for:**
- Impact analysis before changes
- Understanding function dependencies
- Debugging call chains
- Tracing execution flow

### Example LSP Tool Calls

#### Example 1: Navigate to Definition

```
Use LSP goToDefinition for the function at:
- File: /Users/project/src/services/user.ts
- Line: 45
- Character: 12
```

#### Example 2: Find All References

```
Use LSP findReferences to find all usages of:
- File: /Users/project/src/models/user.py
- Line: 23
- Character: 6
```

#### Example 3: Get Type Information

```
Use LSP hover to get type information for:
- File: /Users/project/cmd/main.go
- Line: 67
- Character: 15
```

#### Example 4: List File Symbols

```
Use LSP documentSymbol for:
- File: /Users/project/src/utils/helpers.rs
```

#### Example 5: Search Workspace Symbols

```
Use LSP workspaceSymbol to search for:
- Query: "validateUser"
```

### Best Practices

#### The Three Iron Laws

```
1. NO MODIFYING UNFAMILIAR CODE WITHOUT goToDefinition FIRST
2. NO REFACTORING WITHOUT findReferences IMPACT ANALYSIS FIRST
3. NO CLAIMING CODE WORKS WITHOUT LSP DIAGNOSTICS VERIFICATION
```

#### Pre-Edit Protocol

Before modifying ANY unfamiliar code:

1. **NAVIGATE:** `goToDefinition` - understand implementation
2. **ANALYZE:** `findReferences` - assess change impact
3. **INSPECT:** `hover` - verify type signatures
4. **THEN:** Make changes

#### Post-Edit Verification

After code changes:

1. **CHECK:** LSP diagnostics for errors/warnings
2. **VERIFY:** No new type errors introduced
3. **CONFIRM:** Imports resolve correctly
4. **VALIDATE:** Interface contracts still satisfied

#### Decision Matrix: LSP vs Grep vs Glob

| Need | Use |
|------|-----|
| Find function definition | LSP: goToDefinition |
| Find all usages of a symbol | LSP: findReferences |
| Get type info quickly | LSP: hover |
| Find TODO/FIXME comments | Grep |
| Search for string literals | Grep |
| Find configuration values | Grep |
| Find files by pattern | Glob |
| Read a known file | Read |

**Rule of thumb:** Use LSP for semantic operations (symbols, types, references). Use Grep for literal text searches.

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "LSP tool not available"

**Symptoms:**
- Error message: "LSP tool not found"
- LSP operations return errors
- Claude falls back to grep automatically

**Causes:**
1. `ENABLE_LSP_TOOL=1` not set
2. Shell profile not reloaded
3. Claude Code session started before variable was set

**Solutions:**

```bash
# 1. Verify environment variable
echo $ENABLE_LSP_TOOL
# If empty or not "1", set it:

# 2. Add to shell profile
echo 'export ENABLE_LSP_TOOL=1' >> ~/.bashrc  # or ~/.zshrc

# 3. Reload shell profile
source ~/.bashrc  # or ~/.zshrc

# 4. Restart Claude Code session completely
# (Not just a new conversation - exit and restart the application)
```

---

#### Issue: "No language server configured" for specific file types

**Symptoms:**
- LSP works for some languages but not others
- Error: "Cannot connect to language server for .xyz files"

**Causes:**
1. Language server not installed
2. Language server not in PATH
3. Project missing required configuration files

**Solutions:**

```bash
# 1. Check if language server is installed
which pyright      # Python
which gopls        # Go
which rust-analyzer # Rust
which vtsls        # TypeScript

# 2. If not found, install it (see Language-Specific Setup section)

# 3. Check PATH includes language server location
echo $PATH

# 4. Add language server to PATH if needed
export PATH="$PATH:$(go env GOPATH)/bin"  # Go example
```

---

#### Issue: Slow or unresponsive LSP

**Symptoms:**
- LSP operations take > 5 seconds
- Operations time out
- Intermittent failures

**Causes:**
1. Language server degraded over long session
2. Very large codebase without exclusions
3. Missing project configuration
4. Indexing in progress

**Solutions:**

```bash
# 1. Restart Claude Code session (restarts language servers)

# 2. Configure exclusions in project config
# tsconfig.json:
{
  "exclude": ["node_modules", "dist", "build", ".git"]
}

# pyrightconfig.json:
{
  "exclude": ["venv", "__pycache__", ".git", "node_modules"]
}

# 3. Wait for initial indexing to complete (first run in large project)

# 4. For C/C++, ensure compile_commands.json exists
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
```

---

#### Issue: "Invalid position" or "File not found" errors

**Symptoms:**
- LSP call fails with position error
- File path errors despite file existing

**Causes:**
1. Using relative path instead of absolute path
2. Using 0-based line/column numbers (LSP uses 1-based)
3. File has unsaved changes
4. File path contains special characters

**Solutions:**

```bash
# 1. Always use absolute paths
# Correct: /Users/project/src/app.ts
# Wrong:   src/app.ts or ./src/app.ts

# 2. Line and character are 1-based
# If cursor is at line 0, column 0 in code, use line: 1, character: 1

# 3. Save all files before LSP operations
# LSP may not see unsaved changes

# 4. Check for special characters in path
# Avoid paths with spaces or unicode if possible
```

---

#### Issue: LSP works sometimes but not others (race condition)

**Symptoms:**
- LSP works inconsistently
- "LSP not initialized" immediately after start
- Works after waiting a few seconds

**Cause:** Known issue where LSP Manager may initialize before plugins fully load.

**Solutions:**

1. Wait 2-3 seconds after starting Claude Code before using LSP
2. If persistent, check for updates to Claude Code
3. As a workaround, try the LSP operation again after a short delay

---

#### Issue: findReferences returns too many or too few results

**Symptoms:**
- Missing expected references
- Includes unrelated matches

**Causes:**
1. Project not fully indexed
2. Missing type definitions
3. Dynamic typing preventing analysis

**Solutions:**

```bash
# 1. Ensure project has proper configuration
# TypeScript: tsconfig.json with proper includes
# Python: pyrightconfig.json or pyproject.toml

# 2. Install type definitions
npm install -D @types/node  # TypeScript
pip install types-requests  # Python type stubs

# 3. For dynamic languages, add type hints
# Python: Use type annotations
# JavaScript: Use JSDoc comments or convert to TypeScript
```

### Diagnostic Commands

Run these commands to diagnose LSP issues:

```bash
# Check LSP environment
echo "ENABLE_LSP_TOOL=$ENABLE_LSP_TOOL"

# Check all common language servers
echo "Language Server Status:"
echo "======================"
for server in pyright gopls rust-analyzer vtsls clangd jdtls; do
  if which $server >/dev/null 2>&1; then
    echo "[OK] $server: $(which $server)"
  else
    echo "[--] $server: not found"
  fi
done

# Check PATH for common locations
echo ""
echo "PATH includes:"
echo "$PATH" | tr ':' '\n' | grep -E "(go|cargo|npm|bin)" | head -10
```

### Language Server Status

To check if a language server is functioning:

```bash
# Python (pyright)
pyright --version
echo "print('test')" | pyright --stdin

# Go (gopls)
gopls version
gopls check /path/to/main.go

# Rust (rust-analyzer)
rust-analyzer --version

# TypeScript (vtsls)
vtsls --version
```

---

## FAQ

### General Questions

**Q: Do I need to install LSP for every language I use?**

A: Yes, each programming language requires its own language server. Install only the servers for languages you actively use.

---

**Q: Can I use LSP without the lsp-tools plugin?**

A: Yes, Claude Code has built-in LSP support. The lsp-tools plugin adds hooks for automated formatting/linting and provides behavioral enforcement patterns, but basic LSP operations work without it.

---

**Q: How much overhead does LSP add?**

A: LSP operations typically take 30-500ms depending on the operation and codebase size. This is significantly faster than grep-based alternatives in codebases over 20 files. The token cost (~500 tokens per operation) is usually offset by avoiding irrelevant grep results.

---

**Q: Does LSP work with all file types?**

A: LSP works with any language that has a compatible language server. Most popular programming languages have mature LSP implementations. Configuration files, plain text, and markup languages typically do not have semantic LSP support.

---

### Setup Questions

**Q: Why doesn't LSP work even after setting ENABLE_LSP_TOOL=1?**

A: The most common causes are:
1. Shell profile not reloaded (`source ~/.bashrc`)
2. Claude Code session not restarted after setting the variable
3. Language server not installed or not in PATH

---

**Q: Can I use a different language server than the recommended one?**

A: In some cases, yes. For example, for Python you could use `pylsp` instead of `pyright`. However, the recommended servers are chosen for their completeness and compatibility with Claude Code.

---

**Q: How do I set up LSP for a monorepo with multiple languages?**

A: Install language servers for each language. Most language servers automatically detect their relevant files. For best results, ensure each sub-project has its own configuration file (tsconfig.json, pyrightconfig.json, etc.).

---

### Usage Questions

**Q: When should I use LSP hover vs goToDefinition?**

A: Use `hover` for quick type checks and documentation without leaving your current context. Use `goToDefinition` when you need to read and understand the full implementation.

---

**Q: Why does findReferences sometimes miss usages?**

A: This can happen when:
- The project is not fully indexed (wait for indexing)
- Code uses dynamic typing that the analyzer cannot trace
- References are in files excluded from the project configuration

---

**Q: Can LSP find usages across different repositories?**

A: No, LSP operates within a single workspace. For cross-repository analysis, you would need to use grep or manually check each repository.

---

### Troubleshooting Questions

**Q: LSP is very slow on my large project. How can I speed it up?**

A:
1. Add exclusions to your project config (node_modules, dist, vendor, etc.)
2. Ensure your project has proper configuration files
3. For first-time use, allow time for initial indexing
4. Consider increasing available memory if working with very large codebases

---

**Q: I get different results from LSP than from my IDE. Why?**

A: Different language servers or server versions may behave slightly differently. Ensure you are using the same language server version as your IDE, or accept minor differences in behavior.

---

**Q: How do I completely reset LSP state?**

A:
1. Restart your Claude Code session
2. If issues persist, delete language server cache directories:
   - Python (pyright): Delete `.pyright` folder if present
   - TypeScript: Delete `node_modules/.cache`
   - Rust: Delete `target/` and re-run `cargo check`

---

## Quick Reference

### Environment Setup Checklist

- [ ] `ENABLE_LSP_TOOL=1` added to shell profile
- [ ] Shell profile reloaded (`source ~/.bashrc`)
- [ ] Language server installed for your language
- [ ] Language server binary is in PATH
- [ ] Project configuration file exists (tsconfig.json, etc.)
- [ ] Claude Code session restarted after setup

### LSP Operations Quick Reference

| I want to... | Use this operation |
|--------------|-------------------|
| Understand what a function does | `goToDefinition` |
| Find all usages before refactoring | `findReferences` |
| Find interface implementations | `goToImplementation` |
| Get type info quickly | `hover` |
| See file structure | `documentSymbol` |
| Search for symbol by name | `workspaceSymbol` |
| Find who calls this function | `incomingCalls` |
| Find what this function calls | `outgoingCalls` |

### Language Server Installation Commands

```bash
# Python
npm install -g pyright

# TypeScript/JavaScript
npm install -g @vtsls/language-server typescript

# Go
go install golang.org/x/tools/gopls@latest

# Rust
rustup component add rust-analyzer

# C/C++
brew install llvm  # macOS
sudo apt install clangd  # Ubuntu/Debian

# Java
brew install jdtls  # macOS

# PHP
composer global require phpactor/phpactor

# Ruby
gem install ruby-lsp
```

### Troubleshooting Quick Checks

```bash
# Is LSP enabled?
[ "$ENABLE_LSP_TOOL" = "1" ] && echo "OK" || echo "FAIL: Set ENABLE_LSP_TOOL=1"

# Is language server in PATH?
which pyright gopls rust-analyzer 2>/dev/null || echo "Install language servers"

# Test specific server
pyright --version
gopls version
rust-analyzer --version
```

---

## Related Documentation

- [LSP Operations Guide](../skills/lsp-enable/references/lsp-operations-guide.md) - Complete operation reference
- [LSP Decision Matrix](../skills/lsp-enable/references/lsp-decision-matrix.md) - When to use LSP vs Grep vs Glob
- [LSP Enforcement Protocol](../skills/lsp-enable/references/lsp-enforcement-protocol.md) - Behavioral patterns
- [Setup & Verification](../skills/lsp-enable/references/lsp-setup-verification.md) - Detailed setup guide
- [All Languages Guide](../skills/lsp-enable/references/SETUP-GUIDE-ALL-LANGUAGES.md) - Quick setup for 12 languages

---

*This guide is part of the lsp-tools plugin for Claude Code. For issues or contributions, see the plugin repository.*
