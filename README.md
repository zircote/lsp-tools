# LSP Tools Plugin

> LSP-first code intelligence for Claude Code with strong enforcement patterns

[![Version](https://img.shields.io/badge/version-0.4.0-blue.svg)](CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Marketplace](https://img.shields.io/badge/marketplace-zircote--lsp-purple.svg)](https://github.com/zircote/lsp-marketplace)

## Overview

LSP Tools enforces semantic code navigation using Language Server Protocol, providing IDE-like precision for code operations. The plugin ensures Claude uses LSP operations before modifying code, analyzes impact before refactoring, and verifies changes with diagnostics.

**Part of the [zircote-lsp marketplace](https://github.com/zircote/lsp-marketplace)** - A collection of LSP-focused plugins for Claude Code.

### Key Features

- **Three Iron Laws** - Mandatory behavioral constraints for code operations
- **14 Language Support** - TypeScript, Python, Go, Rust, Java, Kotlin, C/C++, C#, PHP, Ruby, HTML/CSS, LaTeX, Markdown, Terraform
- **Setup Command** - Automatically configures hooks for your project
- **Specialized Plugin Integration** - Defers to `zircote/*-lsp` plugins when installed
- **Decision Trees** - Clear guidance on when to use LSP vs Grep vs Glob

## Installation

```bash
# Install from zircote-lsp marketplace
/plugin install lsp-tools@zircote-lsp
```

### Prerequisites

1. **Enable LSP in Claude Code:**
   ```bash
   # Add to your shell profile (~/.bashrc, ~/.zshrc)
   export ENABLE_LSP_TOOL=1
   ```

2. **Install language servers for your languages:**
   ```bash
   # TypeScript/JavaScript
   npm install -g @vtsls/language-server typescript

   # Python
   npm install -g pyright

   # Go
   go install golang.org/x/tools/gopls@latest

   # Rust
   rustup component add rust-analyzer
   ```

   See [references/lsp-setup-verification.md](skills/lsp-enable/references/lsp-setup-verification.md) for all languages.

## Usage

### The Three Iron Laws

The skill enforces these mandatory behaviors:

```
1. NO MODIFYING UNFAMILIAR CODE WITHOUT goToDefinition FIRST
2. NO REFACTORING WITHOUT findReferences IMPACT ANALYSIS FIRST
3. NO CLAIMING CODE WORKS WITHOUT LSP DIAGNOSTICS VERIFICATION
```

### Trigger Phrases

The skill activates when you say:
- "find definition", "go to definition", "where is X defined"
- "find references", "who uses this", "what calls this function"
- "understand this code", "trace this function", "explore codebase"
- "before I refactor", "impact of changing", "safe to rename"
- "analyze dependencies", "call hierarchy", "incoming calls"

### Setup Command

Set up LSP hooks for your project:

```bash
# Auto-detect languages in project
/lsp-tools:lsp-setup

# Specify languages explicitly
/lsp-tools:lsp-setup typescript python

# Single language
/lsp-tools:lsp-setup go
```

This command:
1. Detects languages used in your project
2. Copies appropriate hooks to `.claude/hooks.json`
3. Optionally appends LSP guidance to `CLAUDE.md`

### LSP Operations

| Operation | Purpose | Use Before |
|-----------|---------|------------|
| `goToDefinition` | Jump to where symbol is defined | Modifying unfamiliar code |
| `findReferences` | Find all usages of a symbol | Refactoring, renaming |
| `goToImplementation` | Find interface implementations | Working with polymorphism |
| `hover` | Get type info, docs, signatures | Understanding APIs |
| `documentSymbol` | List all symbols in a file | Understanding large files |
| `workspaceSymbol` | Search symbols across codebase | Finding related code |
| `incomingCalls` | Find callers of a function | Impact analysis |
| `outgoingCalls` | Find functions called by target | Dependency tracing |

### Decision Tree

```
WHAT DO YOU NEED?
│
├─ Symbol definition or implementation
│  └─ USE LSP: goToDefinition, goToImplementation
│
├─ All usages of a symbol
│  └─ USE LSP: findReferences
│
├─ Type info, docs, or signatures
│  └─ USE LSP: hover
│
├─ Call graph or dependencies
│  └─ USE LSP: incomingCalls, outgoingCalls
│
├─ Literal text search (TODOs, strings, config)
│  └─ USE: Grep
│
└─ File discovery by pattern
   └─ USE: Glob
```

## Supported Languages

| Language | LSP Server | Hooks File | Specialized Plugin |
|----------|-----------|------------|-------------------|
| TypeScript/JavaScript | vtsls | `typescript-hooks.json` | — |
| Python | pyright | `python-hooks.json` | — |
| Go | gopls | `go-hooks.json` | — |
| Rust | rust-analyzer | `rust-hooks.json` | `zircote/rust-lsp` (16 hooks) |
| Java | jdtls | `java-hooks.json` | — |
| Kotlin | kotlin-language-server | `kotlin-hooks.json` | — |
| C/C++ | clangd | `cpp-hooks.json` | — |
| C# | OmniSharp | `csharp-hooks.json` | — |
| PHP | phpactor | `php-hooks.json` | — |
| Ruby | ruby-lsp | `ruby-hooks.json` | — |
| HTML/CSS | vscode-langservers | `html-css-hooks.json` | — |
| LaTeX | texlab | `latex-hooks.json` | — |
| Markdown | marksman | `markdown-hooks.json` | `zircote/markdown-lsp` (4 hooks) |
| Terraform | terraform-ls | `terraform-hooks.json` | `zircote/terraform-lsp` (17 hooks) |

### Specialized Plugin Integration

When a `zircote/*-lsp` plugin is installed, lsp-tools automatically defers to it:

- **Hook installation is skipped** for languages covered by specialized plugins
- **LSP server installation uses the specialized plugin's `/setup` command**
- **The final report shows** which hooks come from which source

This prevents duplicate hooks and ensures you get the full benefits of the specialized plugins (which include additional tooling like security scanners, linters, and formatters beyond basic LSP).

## Plugin Structure

```
lsp-tools/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   └── lsp-setup.md          # Setup command
├── skills/
│   └── lsp-enable/
│       ├── SKILL.md          # Main enforcement skill
│       └── references/
│           ├── lsp-operations-guide.md
│           ├── lsp-enforcement-protocol.md
│           ├── lsp-decision-matrix.md
│           ├── lsp-setup-verification.md
│           ├── SETUP-GUIDE-ALL-LANGUAGES.md
│           ├── {language}-lsp-section.md  # Per-language guidance
│           └── {language}-hooks.json      # Per-language hooks
├── README.md
├── CHANGELOG.md
└── .bumpversion.toml
```

## How Hooks Work

When you run `/lsp-tools:lsp-setup`, the command copies language-appropriate hooks to your project's `.claude/hooks.json`. These hooks automatically:

- **Format on edit** - Run formatters (prettier, ruff, gofmt) after file changes
- **Lint on edit** - Check for lint errors after edits
- **Typecheck on edit** - Run type checkers (tsc, pyright) after changes
- **Pre-commit gate** - Block commits if quality checks fail

Example TypeScript hooks:
```json
{
  "hooks": [
    {
      "name": "format-on-edit",
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "command": "npx prettier --write $CLAUDE_FILE_PATHS"
    },
    {
      "name": "typecheck-on-edit",
      "event": "PostToolUse",
      "matcher": "Write|Edit",
      "command": "npx tsc --noEmit"
    }
  ]
}
```

## Why LSP Over Grep?

| Metric | LSP | Grep |
|--------|-----|------|
| **Speed (large codebase)** | ~50ms | 45+ seconds |
| **Accuracy** | Exact semantic matches | Text patterns (false positives) |
| **Token usage** | ~500 tokens | Burns tokens on irrelevant matches |
| **Type resolution** | Follows aliases, re-exports | Text only |

**Example:**
```
Grep "getUserById" → 500+ matches (comments, strings, similar names)
LSP findReferences → 23 matches (exact function usages only)
```

## Related Plugins

Other plugins in the [zircote-lsp marketplace](https://github.com/zircote/lsp-marketplace):

| Plugin | Description |
|--------|-------------|
| `typescript-lsp` | TypeScript/JavaScript development environment |
| `python-lsp` | Python development with pyright |
| `go-lsp` | Go development with gopls |
| `rust-lsp` | Rust development with rust-analyzer (16 hooks) |
| `java-lsp` | Java development with jdtls |
| `kotlin-lsp` | Kotlin development |
| `terraform-lsp` | Terraform/OpenTofu IaC (17 hooks) |
| `markdown-lsp` | Markdown documentation (4 hooks) |

## Reference Documentation

| Document | Purpose |
|----------|---------|
| [LSP Operations Guide](skills/lsp-enable/references/lsp-operations-guide.md) | Complete guide to all 9 LSP operations |
| [Enforcement Protocol](skills/lsp-enable/references/lsp-enforcement-protocol.md) | Detailed enforcement patterns and scenarios |
| [Decision Matrix](skills/lsp-enable/references/lsp-decision-matrix.md) | When to use LSP vs Grep vs Glob vs Read |
| [Setup & Verification](skills/lsp-enable/references/lsp-setup-verification.md) | Installation and troubleshooting |
| [All Languages Guide](skills/lsp-enable/references/SETUP-GUIDE-ALL-LANGUAGES.md) | Quick setup for all 14 languages |

## Troubleshooting

### LSP Not Working

1. Verify environment variable:
   ```bash
   echo $ENABLE_LSP_TOOL  # Should output "1"
   ```

2. Check language server is installed:
   ```bash
   which pyright  # or gopls, rust-analyzer, etc.
   ```

3. Restart Claude Code session after setting environment variable

### Hooks Not Activating

1. Verify `.claude/hooks.json` exists in your project
2. Check hook syntax is valid JSON
3. Ensure file extensions match hook conditions

## Contributing

Contributions welcome! Please:
1. Follow existing code style
2. Add tests for new functionality
3. Update documentation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
